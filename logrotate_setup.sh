#!/bin/bash

# Log file and configuration variables
LOG_FILE="/var/log/httpd/access_log"  # Change this to the log file you want to rotate
LOGROTATE_CONFIG="/etc/logrotate.d/custom_logrotate"
MAX_LOG_FILES=5  # Number of rotated logs to keep
ROTATE_DAYS=7    # Keep logs for 7 days
COMPRESS_LOGS="yes"  # Enable compression for old logs
WEEKLY_ROTATE="yes"  # Rotate weekly

# Check if the system is Debian or RedHat-based and install logrotate
if [[ -f /etc/debian_version ]]; then
    echo "Debian-based system detected. Installing logrotate..."
    apt-get update && apt-get install -y logrotate
elif [[ -f /etc/redhat-release ]]; then
    echo "RedHat-based system detected. Installing logrotate..."
    yum install -y logrotate
else
    echo "Unsupported OS. Exiting script."
    exit 1
fi

# Create a custom logrotate configuration file
echo "Creating custom logrotate configuration..."

cat <<EOF > "$LOGROTATE_CONFIG"
$LOG_FILE {
    daily
    missingok
    rotate $MAX_LOG_FILES
    compress $COMPRESS_LOGS
    delaycompress
    notifempty
    create 0640 root root
    dateext
    dateyesterday
    postrotate
        # Restart the service that logs to the file (e.g., Apache)
        systemctl reload httpd > /dev/null 2>&1 || true
    endscript
}
EOF

# Set permissions for the configuration file
chmod 644 "$LOGROTATE_CONFIG"
chown root:root "$LOGROTATE_CONFIG"

# Reload logrotate configuration to apply the new log rotation settings
echo "Reloading logrotate..."
logrotate /etc/logrotate.conf --debug

echo "Log rotation setup complete for $LOG_FILE."
