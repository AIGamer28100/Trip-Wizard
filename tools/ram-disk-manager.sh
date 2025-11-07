#!/bin/bash

# Trip Wizards RAM Disk Manager
# Creates RAM disks for faster Flutter builds

set -e

# Configuration
RAM_DISK_SIZE_MB=2048  # 2GB RAM disk
RAM_DISK_PATH="/tmp/tripwizards-ramdisk"
MOUNT_POINT="$HOME/.tripwizards-ramdisk"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

check_ram_available() {
    local available_mb=$(free | grep Mem | awk '{print $7/1024}')
    if (( $(echo "$available_mb < $RAM_DISK_SIZE_MB + 512" | bc -l) )); then
        log_error "Not enough RAM available. Need at least $((RAM_DISK_SIZE_MB + 512))MB free."
        return 1
    fi
    return 0
}

create_ram_disk() {
    echo "=== Creating RAM Disk ==="

    # Check if already exists
    if mount | grep -q "$MOUNT_POINT"; then
        log_warning "RAM disk already mounted at $MOUNT_POINT"
        return
    fi

    # Check available RAM
    check_ram_available || exit 1

    # Create mount point
    mkdir -p "$MOUNT_POINT"

    # Create RAM disk
    log_info "Creating ${RAM_DISK_SIZE_MB}MB RAM disk..."
    sudo mount -t tmpfs -o size=${RAM_DISK_SIZE_MB}m tmpfs "$MOUNT_POINT"

    # Set permissions
    sudo chown "$USER:$USER" "$MOUNT_POINT"

    log_success "RAM disk created at $MOUNT_POINT"
    df -h "$MOUNT_POINT"
}

setup_build_cache() {
    echo "=== Setting up Build Cache on RAM Disk ==="

    if [ ! -d "$MOUNT_POINT" ]; then
        log_error "RAM disk not mounted. Run '$0 --create' first."
        exit 1
    fi

    local cache_dir="$MOUNT_POINT/flutter-cache"

    # Create cache directory
    mkdir -p "$cache_dir"

    # Link Flutter cache if it exists
    if [ -d "$HOME/.pub-cache" ]; then
        log_info "Moving Flutter pub cache to RAM disk..."
        mv "$HOME/.pub-cache" "$cache_dir/pub-cache"
        ln -s "$cache_dir/pub-cache" "$HOME/.pub-cache"
    fi

    # Link Gradle cache if it exists
    if [ -d "$HOME/.gradle" ]; then
        log_info "Moving Gradle cache to RAM disk..."
        mv "$HOME/.gradle" "$cache_dir/gradle"
        ln -s "$cache_dir/gradle" "$HOME/.gradle"
    fi

    log_success "Build caches moved to RAM disk"
}

remove_ram_disk() {
    echo "=== Removing RAM Disk ==="

    if ! mount | grep -q "$MOUNT_POINT"; then
        log_warning "No RAM disk mounted"
        return
    fi

    # Unmount
    sudo umount "$MOUNT_POINT"
    rmdir "$MOUNT_POINT"

    log_success "RAM disk removed"
}

show_status() {
    echo "=== RAM Disk Status ==="

    if mount | grep -q "$MOUNT_POINT"; then
        log_success "RAM disk mounted at $MOUNT_POINT"
        df -h "$MOUNT_POINT"
    else
        log_info "No RAM disk mounted"
    fi

    echo ""
    echo "Available RAM:"
    free -h | grep Mem
}

show_help() {
    echo "Trip Wizards RAM Disk Manager"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --create, -c      Create RAM disk"
    echo "  --setup-cache     Move build caches to RAM disk"
    echo "  --remove, -r      Remove RAM disk"
    echo "  --status, -s      Show RAM disk status"
    echo "  --help, -h        Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --create          # Create 2GB RAM disk"
    echo "  $0 --setup-cache     # Move caches to RAM disk"
    echo "  $0 --status          # Check status"
    echo "  $0 --remove          # Remove RAM disk"
    echo ""
    echo "Note: Requires sudo for mounting operations"
}

main() {
    case "${1:-}" in
        --create|-c)
            create_ram_disk
            ;;
        --setup-cache)
            setup_build_cache
            ;;
        --remove|-r)
            remove_ram_disk
            ;;
        --status|-s)
            show_status
            ;;
        --help|-h)
            show_help
            ;;
        *)
            show_help
            ;;
    esac
}

main "$@"