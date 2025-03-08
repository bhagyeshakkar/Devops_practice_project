#!/bin/bash

# Configurations
LOG_DIR="/var/log"
SOURCE_DIR="/home/user/data"
BACKUP_DIR="/backup"
AGE=30
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DISK_THRESHOLD=80 # Disk usage threshold in percentage
SERVICES=("apache2" "mysql")

# Function to clean up old log files
cleanup_logs() {
    echo "Cleaning up log files older than $AGE days in $LOG_DIR..."
    find "$LOG_DIR" -name "*.log" -type f -mtime +$AGE -exec rm -f {} \;
    echo "Log file cleanup completed."
}

# Function to back up important data
backup_data() {
    BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"
    mkdir -p "$BACKUP_PATH"
    
    echo "Backing up files from $SOURCE_DIR to $BACKUP_PATH..."
    cp -r "$SOURCE_DIR"/* "$BACKUP_PATH"
    echo "Backup completed at $BACKUP_PATH."
}

# Function to update the system (update and upgrade packages)
system_update() {
    echo "Updating package list..."
    sudo apt update
    
    echo "Upgrading installed packages..."
    sudo apt upgrade -y
    
    echo "Removing unnecessary packages..."
    sudo apt autoremove -y
    
    echo "System update completed successfully!"
}

# Function to check disk space usage
check_disk_space() {
    echo "Checking disk space usage..."
    DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
    
    if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
        echo "Warning: Disk space usage is over $DISK_THRESHOLD%! Currently at $DISK_USAGE%."
    else
        echo "Disk space usage is under control: $DISK_USAGE%."
    fi
}

# Function to check system health (high CPU or memory usage)
check_system_health() {
    echo "Checking system health..."
    TOP_PROCESSES=$(ps aux --sort=-%cpu | head -n 6) # Shows top 5 CPU consumers
    
    echo "Top CPU consuming processes:"
    echo "$TOP_PROCESSES"
    
    TOP_MEMORY_PROCESSES=$(ps aux --sort=-%mem | head -n 6) # Shows top 5 memory consumers
    
    echo "Top memory consuming processes:"
    echo "$TOP_MEMORY_PROCESSES"
}

# Function to clear system cache
clear_cache() {
    echo "Clearing system cache..."
    sudo sync && sudo echo 3 > /proc/sys/vm/drop_caches
    echo "System cache cleared."
}

# Function to check the status of important services
check_services_status() {
    echo "Checking service status..."
    
    for SERVICE in "${SERVICES[@]}"; do
        SYSTEMD_STATUS=$(systemctl is-active "$SERVICE")
        
        if [ "$SYSTEMD_STATUS" == "active" ]; then
            echo "$SERVICE is running."
        else
            echo "$SERVICE is not running."
        fi
    done
}

# Main function to run all tasks
run_all_tasks() {
    cleanup_logs
    backup_data
    system_update
    check_disk_space
    check_system_health
    clear_cache
    check_services_status
}

# Main execution
echo "Starting administrative tasks..."
run_all_tasks
echo "All tasks completed successfully!"
