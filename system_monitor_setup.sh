#!/bin/bash

# Script to install monitoring tools, set up system resource checks, and configure alerts

# Configurations
CPU_THRESHOLD=80        # CPU usage threshold (percent)
MEMORY_THRESHOLD=80     # Memory usage threshold (percent)
DISK_THRESHOLD=80       # Disk usage threshold (percent)
EMAIL="your-email@example.com"  # Email to send alerts

# Step 1: Install necessary packages
install_packages() {
    echo "Installing necessary packages..."

    # Install monitoring tools
    sudo apt update
    sudo apt install -y htop procps coreutils mailutils msmtp

    # Verify installation
    if command -v htop &>/dev/null && command -v df &>/dev/null && command -v free &>/dev/null && command -v top &>/dev/null; then
        echo "Monitoring tools installed successfully."
    else
        echo "Failed to install monitoring tools."
        exit 1
    fi
}

# Step 2: Configure msmtp for email notifications (using Gmail)
configure_msmtp() {
    echo "Configuring msmtp for email notifications..."

    # Create msmtp configuration file
    cat <<EOL > ~/.msmtprc
account gmail
host smtp.gmail.com
port 587
from your-email@gmail.com
auth on
user your-email@gmail.com
password your-email-password
tls on
tls_starttls on
logfile ~/.msmtp.log

account default : gmail
EOL

    # Set appropriate file permissions
    chmod 600 ~/.msmtprc

    echo "msmtp configured successfully."
}

# Step 3: Create system monitoring script to check resource usage
create_monitor_script() {
    echo "Creating system monitor script..."

    cat <<'EOL' > /usr/local/bin/system_monitor.sh
#!/bin/bash

# Configurations
CPU_THRESHOLD=80        # CPU usage threshold (percent)
MEMORY_THRESHOLD=80     # Memory usage threshold (percent)
DISK_THRESHOLD=80       # Disk usage threshold (percent)
EMAIL="your-email@example.com"  # Email to send alerts

# Function to check CPU usage
check_cpu_usage() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        echo "Warning: High CPU usage detected! Usage is at ${CPU_USAGE}%." | mail -s "CPU Usage Alert" "$EMAIL"
    fi
}

# Function to check memory usage
check_memory_usage() {
    MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    
    if (( $(echo "$MEM_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
        echo "Warning: High Memory usage detected! Usage is at ${MEM_USAGE}%." | mail -s "Memory Usage Alert" "$EMAIL"
    fi
}

# Function to check disk usage
check_disk_usage() {
    DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
    
    if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
        echo "Warning: High Disk usage detected! Usage is at ${DISK_USAGE}%." | mail -s "Disk Usage Alert" "$EMAIL"
    fi
}

# Run checks
check_cpu_usage
check_memory_usage
check_disk_usage
EOL

    # Make the script executable
    sudo chmod +x /usr/local/bin/system_monitor.sh
    echo "System monitor script created successfully."
}

# Step 4: Set up a cron job to run the monitoring script every 5 minutes
setup_cron_job() {
    echo "Setting up cron job to run monitoring script every 5 minutes..."
    
    # Add a cron job for the current user
    (crontab -l ; echo "*/5 * * * * /usr/local/bin/system_monitor.sh") | crontab -
    
    echo "Cron job set up successfully."
}

# Step 5: Running the complete setup
run_setup() {
    install_packages
    configure_msmtp
    create_monitor_script
    setup_cron_job

    echo "System monitoring setup completed successfully!"
}

# Run the setup
run_setup
