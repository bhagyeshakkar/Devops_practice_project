#!/bin/bash

# Website to monitor
WEBSITE="https://www.example.com"

# Email settings
TO_EMAIL="your_email@example.com"
FROM_EMAIL="monitoring@example.com"
SUBJECT="Website Down Alert"
SMTP_SERVER="smtp.example.com"
SMTP_PORT="587"
SMTP_USER="your_smtp_user"
SMTP_PASS="your_smtp_password"

# Log file to track last status
LOG_FILE="/var/log/website_monitor.log"

# Git repository settings
GIT_REPO_DIR="/path/to/your/git/repository"
GIT_REMOTE="origin"  # Change this if your remote repo is named differently
GIT_BRANCH="master"  # Change to 'main' if using the main branch

# Function to handle Git version control (commit and push)
function git_version_control() {
    cd $GIT_REPO_DIR

    # Initialize the Git repository if it's not already initialized
    if [ ! -d ".git" ]; then
        git init
        git remote add $GIT_REMOTE https://github.com/yourusername/yourrepository.git  # Replace with your actual repo URL
    fi

    # Add changes (including the monitor script and logs)
    git add monitor_website.sh
    git add $LOG_FILE

    # Commit changes with a message
    git commit -m "Automated update: $(date)"

    # Push changes to the remote repository
    git push $GIT_REMOTE $GIT_BRANCH
}

# Function to install msmtp
function install_msmtp() {
    # Check if msmtp is installed
    if ! command -v msmtp &> /dev/null
    then
        echo "msmtp not found, installing it now..."

        # Update package list and install msmtp
        if [ -f /etc/lsb-release ]; then
            # Ubuntu/Debian-based systems
            sudo apt update
            sudo apt install msmtp msmtp-mta -y
        elif [ -f /etc/redhat-release ]; then
            # CentOS/RHEL-based systems
            sudo yum install msmtp -y
        else
            echo "Unsupported Linux distribution. Please install msmtp manually."
            exit 1
        fi

        echo "msmtp installed successfully."
    else
        echo "msmtp is already installed."
    fi
}

# Install msmtp if not already installed
install_msmtp

# Ping the website and check if it's reachable
ping -c 4 -W 5 $WEBSITE > /dev/null 2>&1

if [ $? -ne 0 ]; then
    # If ping fails, send an email alert

    # Message body for the email
    MESSAGE="The website $WEBSITE is down! Please check it immediately."

    # Send email using `msmtp` (make sure `msmtp` is configured with an SMTP relay or local mail server)
    echo -e "From: $FROM_EMAIL\nTo: $TO_EMAIL\nSubject: $SUBJECT\n\n$MESSAGE" | msmtp --host=$SMTP_SERVER --port=$SMTP_PORT --auth=on --user=$SMTP_USER --passwordeval="echo $SMTP_PASS" -t

    # Log the event
    echo "$(date): Website $WEBSITE is DOWN" >> $LOG_FILE

    # Call Git version control function to commit and push the changes
    git_version_control

else
    # If website is up, log the success status
    echo "$(date): Website $WEBSITE is UP" >> $LOG_FILE

    # Call Git version control function to commit and push the changes
    git_version_control
fi
