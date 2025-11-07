#!/bin/bash

# Trip Wizards Build Memory Monitor
# Monitors memory usage during Flutter/Android builds

set -e

# Configuration
MONITOR_INTERVAL=2  # seconds
LOG_FILE="/tmp/build-memory-log.txt"
MAX_MEMORY_LOG="${LOG_FILE}.max"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')]${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%H:%M:%S')]${NC} $1"
}

cleanup() {
    # Clean up background process if script is interrupted
    if [ ! -z "$MONITOR_PID" ]; then
        kill "$MONITOR_PID" 2>/dev/null
    fi
    echo ""
    log_info "Build memory monitoring stopped"
    exit 0
}

trap cleanup SIGINT SIGTERM

get_memory_info() {
    # Get memory stats
    local mem_total=$(free | grep Mem | awk '{print $2}')
    local mem_used=$(free | grep Mem | awk '{print $3}')
    local mem_available=$(free | grep Mem | awk '{print $7}')

    # Calculate percentages
    local mem_used_percent=$((mem_used * 100 / mem_total))
    local mem_available_gb=$(echo "scale=1; $mem_available/1024/1024" | bc)

    echo "$mem_used_percent $mem_available_gb"
}

monitor_memory() {
    log_info "Starting memory monitoring (interval: ${MONITOR_INTERVAL}s)"
    log_info "Press Ctrl+C to stop monitoring"

    # Clear previous logs
    > "$LOG_FILE"

    local max_memory_used=0
    local max_memory_time=""

    while true; do
        read -r mem_percent mem_available <<< "$(get_memory_info)"

        # Log to file
        echo "$(date '+%s %H:%M:%S') $mem_percent $mem_available" >> "$LOG_FILE"

        # Track maximum memory usage
        if (( mem_percent > max_memory_used )); then
            max_memory_used=$mem_percent
            max_memory_time=$(date '+%H:%M:%S')
        fi

        # Display current status
        printf "\rMemory: %3d%% used, %.1fGB available | Max: %3d%% at %s" \
               "$mem_percent" "$mem_available" "$max_memory_used" "$max_memory_time"

        # Warnings
        if (( mem_percent > 90 )); then
            printf " ${RED}[CRITICAL]${NC}"
        elif (( mem_percent > 80 )); then
            printf " ${YELLOW}[WARNING]${NC}"
        fi

        sleep "$MONITOR_INTERVAL"
    done
}

show_report() {
    if [ ! -f "$LOG_FILE" ]; then
        log_error "No memory log found. Run monitoring first."
        exit 1
    fi

    echo "=== Build Memory Report ==="
    echo ""

    # Calculate statistics
    local total_samples=$(wc -l < "$LOG_FILE")
    local duration=$((total_samples * MONITOR_INTERVAL))

    echo "Monitoring Duration: ${duration}s (${total_samples} samples)"
    echo ""

    # Memory usage statistics
    local max_mem=$(awk 'BEGIN{max=0} {if($3>max) max=$3} END{print max}' "$LOG_FILE")
    local min_mem=$(awk 'BEGIN{min=999} {if($3<min) min=$3} END{print min}' "$LOG_FILE")
    local avg_mem=$(awk '{sum+=$3} END{printf "%.1f", sum/NR}' "$LOG_FILE")

    echo "Memory Usage Statistics:"
    echo "  Maximum: ${max_mem}%"
    echo "  Minimum: ${min_mem}%"
    echo "  Average: ${avg_mem}%"
    echo ""

    # Peak memory periods
    echo "Peak Memory Usage (>80%):"
    awk '$3 > 80 {print "  " $2 ": " $3 "% used"}' "$LOG_FILE" | head -5

    echo ""
    echo "Memory Timeline (last 10 samples):"
    tail -10 "$LOG_FILE" | while read -r timestamp time mem_percent mem_available; do
        printf "  %s: %3d%% used, %.1fGB available\n" "$time" "$mem_percent" "$mem_available"
    done
}

background_monitor() {
    # Start monitoring in background
    monitor_memory &
    MONITOR_PID=$!

    log_info "Memory monitoring started in background (PID: $MONITOR_PID)"
    log_info "Run '$0 --report' to see results"
    log_info "Run '$0 --stop' to stop monitoring"

    # Wait for the command passed as arguments
    if [ $# -gt 0 ]; then
        log_info "Executing: $*"
        "$@"
        exit_code=$?

        # Stop monitoring
        kill "$MONITOR_PID" 2>/dev/null
        wait "$MONITOR_PID" 2>/dev/null

        log_info "Build completed with exit code: $exit_code"
        show_report
        exit $exit_code
    fi
}

stop_monitoring() {
    if [ -f "/tmp/monitor.pid" ]; then
        local pid=$(cat /tmp/monitor.pid)
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            log_success "Monitoring stopped"
        else
            log_warning "Monitoring process not running"
        fi
        rm -f /tmp/monitor.pid
    else
        log_warning "No monitoring process found"
    fi
}

show_help() {
    echo "Trip Wizards Build Memory Monitor"
    echo ""
    echo "Usage: $0 [OPTIONS] [COMMAND]"
    echo ""
    echo "Options:"
    echo "  --monitor, -m     Start interactive memory monitoring"
    echo "  --background, -b  Start background monitoring and run COMMAND"
    echo "  --report, -r      Show memory usage report"
    echo "  --stop, -s        Stop background monitoring"
    echo "  --help, -h        Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --monitor                    # Interactive monitoring"
    echo "  $0 --background flutter build apk  # Monitor during build"
    echo "  $0 --report                     # Show memory report"
    echo "  $0 --stop                       # Stop monitoring"
    echo ""
    echo "Note: Use --background for automated build monitoring"
}

main() {
    case "${1:-}" in
        --monitor|-m)
            monitor_memory
            ;;
        --background|-b)
            shift
            background_monitor "$@"
            ;;
        --report|-r)
            show_report
            ;;
        --stop|-s)
            stop_monitoring
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