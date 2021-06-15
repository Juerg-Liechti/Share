#!/bin/bash

# Add cron job to set outputs after reboot to a fixed, defined state

# ---- FUNCTIONS -----

# Add entry to the crontab, with no duplication:
# Usage:
# add_cron_job CMD SCHEDULE [PRINT]
add_cron_job() {
    cronjob="$2 $1"
    (
        crontab -l | grep -v -F "$1"
        echo "$cronjob"
    ) | crontab -
    if [[ $3 == true ]]; then
        echo "Added cron job: $cronjob"
    fi
}

# Remove entry from the crontab whatever its current schedule:
# Usage:
# remove_cron_job CMD
#
# Btw: to remove all cron jobs: crontab -r
remove_cron_job() {
    (crontab -l | grep -v -F "$1") | crontab -
}


# ---- MAIN -----
echo "--- AGNES ioControl: adding or updating cron job for setting fixed output state at reboot ---"

# Make sure we are su
if (($EUID != 0)); then
    echo "Please run as root"
    exit
fi

# Cron jobs for for checking pins and sending emails
SETPINS_CMD="/usr/bin/ioControl configure && /usr/bin/ioControl set" 
SETPINS_ARG="OUT1=1 OUT2=1 OUT3=1 OUT4=1 OUT5=1 OUT6=1 OUT7=1 OUT8=1"
SETPINS_SCHEDULE="@reboot        "
# It makes no sense to have this more than once, so remove any existing
remove_cron_job "$SETPINS_CMD"
add_cron_job "$SETPINS_CMD $SETPINS_ARG" "$SETPINS_SCHEDULE" true
echo "Wait, sync, restart crond to ensure it gets properly written"
sleep 1
sync
systemctl restart crond
sleep 1
echo "Current crontab -l is:"
echo "----------------------"
crontab -l
