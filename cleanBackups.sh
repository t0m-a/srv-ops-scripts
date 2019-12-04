#!/bin/bash
# variables and paths
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
TODAY=$(date +%m-%d-%Y)
THREE_DAYS_AGO=$(date +%m-%d-%Y -d "3 days ago")
WORK_DIR="/srv/backups"
LOG_DIR="/var/log"
RESULTS=()

# We list all files in destination getting their date in an array called RESULTS
#for i in $(ls "$WORK_DIR"); do
    for i in "$WORK_DIR"/*; do
    RESULTS+=("$(date -r "$i" "+%m-%d-%Y")");
done

# If we have files NEWER than three days ago in this list
for d in "${RESULTS[@]}"; do
if [[ "$d" > "$THREE_DAYS_AGO" ]]; then

# Then we print a list of all files OLDER than 3 days in log file
find "$WORK_DIR/" -mtime +3  -printf "%TD %prn DELETED ! \n" >> $LOG_DIR/backupclean.log && \

# And we delete the files older than 3 days
find ~/backups -mtime +3 -print0 | xargs -r0 rm -rf -- '{}';
break

# If we have files ONLY OLDER than three days we do nothing.
else printf "%s" "$d": >> $LOG_DIR/backupclean.log && printf " TODAY IS: $TODAY. No file newer than $THREE_DAYS_AGO. NO DELETION ! \n" >> $LOG_DIR/backupclean.log

fi
done
exit 0