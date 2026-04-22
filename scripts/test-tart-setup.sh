#!/usr/bin/env bash
# test-tart-setup.sh - Export current machine state, provision a fresh Tart VM,
# run setup.sh inside it, verify the result, and always destroy the VM.
# Usage: ./scripts/test-tart-setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

IMAGE_NAME="${IMAGE_NAME:-ghcr.io/cirruslabs/macos-tahoe-vanilla:latest}"
VM_NAME="${VM_NAME:-laptop-test-$(date +%Y%m%d%H%M%S)}"
VM_CPU="${VM_CPU:-4}"
VM_MEMORY="${VM_MEMORY:-8192}"
VM_DISK_SIZE="${VM_DISK_SIZE:-100}"
SSH_USER="${SSH_USER:-admin}"
SSH_PASSWORD="${SSH_PASSWORD:-admin}"
MOUNT_NAME="${MOUNT_NAME:-laptop}"
LOG_DIR="${LOG_DIR:-${TMPDIR:-/tmp}/${VM_NAME}}"
RUN_LOG="$LOG_DIR/tart-run.log"
EXPORT_LOG="$LOG_DIR/export.log"
SETUP_LOG="$LOG_DIR/setup.log"
VERIFY_LOG="$LOG_DIR/verify.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

mkdir -p "$LOG_DIR"

RUN_PID=""
VM_IP=""

cleanup() {
    local exit_code=$?

    set +e

    if tart list | awk '{print $1}' | grep -qx "$VM_NAME"; then
        print_status "Stopping VM $VM_NAME"
        tart stop "$VM_NAME" --timeout 20 >/dev/null 2>&1 || true
    fi

    if [[ -n "$RUN_PID" ]]; then
        wait "$RUN_PID" >/dev/null 2>&1 || true
    fi

    if tart list | awk '{print $1}' | grep -qx "$VM_NAME"; then
        print_status "Deleting VM $VM_NAME"
        tart delete "$VM_NAME" >/dev/null 2>&1 || true
    fi

    if [[ $exit_code -eq 0 ]]; then
        print_success "Tart VM cleaned up"
    else
        print_warning "Tart VM cleaned up after failure"
    fi

    echo "Logs: $LOG_DIR"
}

trap cleanup EXIT

require_command() {
    local command_name="$1"
    if ! command -v "$command_name" >/dev/null 2>&1; then
        print_error "Required command not found: $command_name"
        exit 1
    fi
}

ssh_vm() {
    local remote_script="$1"
    local temp_script
    local remote_target
    local ssh_command
    local exit_code

    temp_script="$(mktemp "$LOG_DIR/ssh-script.XXXXXX")"
    printf '%s\n' "$remote_script" > "$temp_script"

    remote_target="${SSH_USER}@${VM_IP}"
    printf -v ssh_command "ssh -tt -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 %q 'bash -s' < %q" "$remote_target" "$temp_script"

    set +e
expect <<'EXPECT_EOF' "$SSH_PASSWORD" "$ssh_command"
set timeout -1
set password [lindex $argv 0]
set ssh_command [lindex $argv 1]

spawn sh -lc $ssh_command

expect {
    -re {yes/no} {
        send "yes\r"
        exp_continue
    }
    -re {[Pp]assword:} {
        send "$password\r"
        exp_continue
    }
    eof
}

catch wait result
exit [lindex $result 3]
EXPECT_EOF
    exit_code=$?
    set -e
    rm -f "$temp_script"
    return "$exit_code"
}

wait_for_ssh() {
    local attempts=60
    local sleep_seconds=5
    local i

    for ((i = 1; i <= attempts; i++)); do
        if ssh_vm "true" >/dev/null 2>&1; then
            return 0
        fi

        sleep "$sleep_seconds"
    done

    return 1
}

require_command tart
require_command expect
require_command ssh

print_status "Exporting configs from the current machine"
bash "$REPO_ROOT/export.sh" | tee "$EXPORT_LOG"

print_status "Cloning Tart image $IMAGE_NAME to $VM_NAME"
tart clone "$IMAGE_NAME" "$VM_NAME"
tart set "$VM_NAME" --cpu "$VM_CPU" --memory "$VM_MEMORY" --disk-size "$VM_DISK_SIZE"
tart set "$VM_NAME" --random-mac --random-serial

print_status "Booting VM"
tart run --no-graphics --dir="$MOUNT_NAME:$REPO_ROOT" "$VM_NAME" >"$RUN_LOG" 2>&1 &
RUN_PID=$!

print_status "Waiting for VM IP"
VM_IP="$(tart ip "$VM_NAME" --wait 300)"
print_success "VM IP: $VM_IP"

print_status "Waiting for SSH"
if ! wait_for_ssh; then
    print_error "VM became reachable by IP but not by SSH"
    exit 1
fi

GUEST_REPO_PATH="/Volumes/My Shared Files/$MOUNT_NAME"

print_status "Running setup.sh inside the VM"
ssh_vm "$(cat <<EOF
cd $(printf '%q' "$GUEST_REPO_PATH")
NONINTERACTIVE=1 SUDO_PASSWORD=$(printf '%q' "$SSH_PASSWORD") ./setup.sh
EOF
)" | tee "$SETUP_LOG"

print_status "Running verification inside the VM"
ssh_vm "$(cat <<EOF
cd $(printf '%q' "$GUEST_REPO_PATH")
./scripts/verify-setup.sh
EOF
)" | tee "$VERIFY_LOG"

print_success "Tart setup test completed successfully"
