#!/bin/bash

# Trip Wizards Advanced Memory Helper
# Comprehensive memory monitoring and optimization for Flutter development

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MIN_MEMORY_GB=2
SWAP_SIZE_GB=4
WARNING_MEMORY_GB=1

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

check_memory() {
    echo "=== Trip Wizards Memory Analysis ==="

    # Get memory info
    MEM_INFO=$(free -g)
    MEM_AVAILABLE=$(free | grep Mem | awk '{printf "%.1f", $7/1024/1024}')
    MEM_TOTAL=$(free | grep Mem | awk '{printf "%.1f", $2/1024/1024}')

    echo "Memory Status:"
    echo "$MEM_INFO"
    echo ""

    # Check available memory
    if (( $(echo "$MEM_AVAILABLE < $WARNING_MEMORY_GB" | bc -l) )); then
        log_error "Critical: Only ${MEM_AVAILABLE}GB RAM available!"
        echo "Recommendations:"
        echo "  - Close unnecessary applications"
        echo "  - Kill heavy processes"
        echo "  - Consider adding more RAM or swap space"
    elif (( $(echo "$MEM_AVAILABLE < $MIN_MEMORY_GB" | bc -l) )); then
        log_warning "Low memory: ${MEM_AVAILABLE}GB available"
        echo "Recommendations:"
        echo "  - Close browser tabs and background apps"
        echo "  - Stop Docker containers if running"
        echo "  - Run memory cleanup commands"
    else
        log_success "Good: ${MEM_AVAILABLE}GB RAM available"
    fi

    echo ""
}

check_swap() {
    echo "=== Swap Space Analysis ==="

    SWAP_INFO=$(free -h | grep Swap)
    SWAP_TOTAL=$(free | grep Swap | awk '{print $2}')

    if [ "$SWAP_TOTAL" -eq 0 ]; then
        log_warning "No swap space configured!"
        echo "Consider creating a swap file for better memory management."
        echo "Run: $0 --create-swap"
    else
        log_success "Swap space available: $SWAP_INFO"
    fi

    echo ""
}

check_processes() {
    echo "=== Top Memory-Consuming Processes ==="
    ps aux --sort=-%mem | head -10 | awk 'NR==1{print} NR>1{printf "%.1fGB %s\n", $6/1024/1024, $11}'
    echo ""

    echo "=== Flutter/Android Processes ==="
    FLUTTER_PROCS=$(ps aux | grep -E "(flutter|gradle|java.*android)" | grep -v grep)
    if [ -n "$FLUTTER_PROCS" ]; then
        echo "$FLUTTER_PROCS"
    else
        echo "No active Flutter/Android processes found."
    fi
    echo ""
}

check_disk() {
    echo "=== Disk Usage Analysis ==="

    # Project disk usage
    PROJECT_SIZE=$(du -sh "$PROJECT_ROOT" 2>/dev/null | cut -f1)
    echo "Project size: $PROJECT_SIZE"

    # Flutter/Android build artifacts
    BUILD_SIZE=$(du -sh "$PROJECT_ROOT/build" 2>/dev/null | cut -f1 || echo "0")
    echo "Build artifacts: $BUILD_SIZE"

    # Available disk space
    DISK_FREE=$(df -h "$PROJECT_ROOT" | tail -1 | awk '{print $4}')
    echo "Available disk space: $DISK_FREE"

    echo ""
}

create_swap() {
    echo "=== Creating Swap File ==="

    if [ "$EUID" -ne 0 ]; then
        log_error "Please run as root (sudo) to create swap file"
        exit 1
    fi

    SWAP_FILE="/swapfile"

    if [ -f "$SWAP_FILE" ]; then
        log_warning "Swap file already exists at $SWAP_FILE"
        swapon -s
        return
    fi

    log_info "Creating ${SWAP_SIZE_GB}GB swap file..."
    fallocate -l ${SWAP_SIZE_GB}G "$SWAP_FILE"
    chmod 600 "$SWAP_FILE"
    mkswap "$SWAP_FILE"
    swapon "$SWAP_FILE"

    # Make permanent
    if ! grep -q "$SWAP_FILE" /etc/fstab; then
        echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
        log_success "Swap file created and added to /etc/fstab"
    fi

    log_success "Swap file activated!"
    free -h
}

optimize_memory() {
    echo "=== Memory Optimization ==="

    log_info "Running memory cleanup..."

    # Clear page cache
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null && log_success "Page cache cleared" || log_warning "Could not clear page cache (requires root)"

    # Stop Gradle daemon
    if command -v ./gradlew &> /dev/null; then
        ./gradlew --stop 2>/dev/null && log_success "Gradle daemon stopped" || log_info "No Gradle daemon to stop"
    fi

    # Flutter clean if in project
    if [ -f "pubspec.yaml" ]; then
        flutter clean >/dev/null 2>&1 && log_success "Flutter cache cleaned" || log_info "Flutter clean skipped"
    fi

    echo ""
}

show_help() {
    echo "Trip Wizards Memory Helper"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --check, -c       Run memory check (default)"
    echo "  --create-swap     Create swap file (requires sudo)"
    echo "  --optimize, -o    Run memory optimization"
    echo "  --monitor         Continuous monitoring mode"
    echo "  --help, -h        Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                    # Basic memory check"
    echo "  sudo $0 --create-swap # Create swap file"
    echo "  $0 --optimize        # Clean up memory"
    echo "  $0 --monitor         # Continuous monitoring"
}

monitor_mode() {
    echo "=== Continuous Memory Monitoring ==="
    echo "Press Ctrl+C to stop"
    echo ""

    while true; do
        echo "$(date '+%H:%M:%S') - Memory: $(free | grep Mem | awk '{printf "%.1fGB available", $7/1024/1024}')"
        sleep 5
    done
}

main() {
    case "${1:-}" in
        --create-swap)
            create_swap
            ;;
        --optimize|-o)
            optimize_memory
            check_memory
            ;;
        --monitor)
            monitor_mode
            ;;
        --help|-h)
            show_help
            ;;
        --check|-c|*)
            check_memory
            check_swap
            check_processes
            check_disk
            ;;
    esac
}

main "$@"