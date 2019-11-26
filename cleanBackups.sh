#!/bin/bash

# variables and paths
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
today=$(date +%m-%d-%Y)
threedaysago=$(date +%m-%d-%Y -d "3 days ago")
workDir="/srv/backups"
logDir="/var/log"
results=()

# We list all files in destination getting their date in an array called results
#for i in $(ls "$workDir"); do
    for i in "$workDir"/*; do
    results+=("$(date -r "$i" "+%m-%d-%Y")");
done

# If we have files NEWER than three days ago in this list
for d in "${results[@]}"; do
if [[ "$d" > "$threedaysago" ]]; then

# Then we print a list of all files OLDER than 3 days in log file
find "$workDir/" -mtime +3  -printf "%TD %prn DELETED ! \n" >> $logDir/backupclean.log

# And we delete the files older than 3 days
find ~/backups -mtime +3 -print0 | xargs -r0 rm -rf -- '{}';
break


# If we have files ONLY OLDER than three days we do nothing.
else printf "%s" "$d": >> $logDir/backupclean.log && printf " TODAY IS: $today. No file newer than $threedaysago. NO DELETION ! \n" >> $logDir/backupclean.log

fi
done