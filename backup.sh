#! /bin/bash
# Local backups archived and gunziped, then uploaded to Google Drive via RCLONE
# http://rclone.org/
# http://rclone.org/docs/
# You WILL NEED to have rcloned install and configured prior to running this script.
# Retention policies have to be configured on the backup targets using cleanBackup.sh
#####################################################################################
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

######### VARIABLES DECLARATIONS ###############################################
BACKUPDIR='/srv/backup'
GOOGLE_DRIVE_BACKUPDIR='insert_path_to_directory'
REMOTE_SERVER_BACKUPDIR="user@host:/srv/backup"
TWO_DAYS_AGO=$(date +%m-%d-%Y -d "2 days ago")
RESULTS=()

# FOLDERS DECLARATION SECTION: folders to backup
DIR_TO_BACKUP1='insert_path_to_directory'
DIR_TO_BACKUP2='insert_path_to_directory'
#DIR_TO_BACKUP3='insert_path_to_directory'
#DIR_TO_BACKUP4='insert_path_to_directory'
#DIR_TO_BACKUP5='insert_path_to_directory`

# BACKUP FILES NAMING SECTION
# You may add as much name definition as you have folders declared in the section
# above by copying a line below and changing nameNUMBER and dirtobacupNUMBER values.
# You will also need to uncomment or create new tar lines in the backup section.
name1=$(date -I)-${DIR_TO_BACKUP1##*/}
name2=$(date -I)-${DIR_TO_BACKUP2##*/}
#name3=$(date -I)-${DIR_TO_BACKUP3##*/}
#name4=$(date -I)-${DIR_TO_BACKUP4##*/}
#name5=$(date -I)-${DIR_TO_BACKUP5##*/}

######### FLOWS CONTROL SECTION ################################################
# Checking backup sources and remote folders configuration
if [ "$DIR_TO_BACKUP1" = 'insert_path_to_directory' ]
  then echo "This is the first time you run this script. Please edit the folders declaration sections."; exit 1
else
if [ "$remoteBACKUPDIR" = 'insert_path_to_directory' ]
  then echo "This is the first time you run this script. Please edit the folders declaration sections."; exit 1
fi
fi

if [[ $EUID -ne 0 ]]; then
echo "It is better to run this script as root!";
echo -n "Do you wish to run it as root? (y/n and press enter) "
read answer
if echo "$answer" | grep -iq "^y";then
    sudo -p 'Restarting as root, password: ' bash $0 "$@"
    exit $?
fi
fi

######### BACKUP SECTION #######################################################
echo "Creating local backups storage folder if it doesn't exist"
mkdir -p $BACKUPDIR
sleep 1

echo "Creating SQL Backup"
cd $BACKUPDIR
mysqldump --defaults-extra-file=/root/.my.cnf --all-databases > dump-$( date -I).sql
tar -zcvf $( date -I)-dump.tar.gz dump-$( date -I).sql
rm -f dump-$( date -I).sql

echo "Creating compressed archive files for backup using tar"
cd $BACKUPDIR
sleep 1
tar -zcf $name1.tar.gz $DIR_TO_BACKUP1;
tar -zcf $name2.tar.gz $DIR_TO_BACKUP2;
#tar -zcvf $name3.tar.gz $DIR_TO_BACKUP3;
#tar -zcvf $name4.tar.gz $DIR_TO_BACKUP4;
#tar -zcvf $name5.tar.gz $DIR_TO_BACKUP5;

echo "New backups created:"
ls -lhA $BACKUPDIR

echo "Cleaning up local directory, removing all backups older than 1 day before export..."
# We list all files in destination getting their date in an array called RESULTS
for i in "$BACKUPDIR"/*; do
    RESULTS+=( "$(date -r "$i" "+%m-%d-%Y")");
done
# If we have files NEWER than two days ago in this list
for d in "${RESULTS[@]}"; do
if [[ "$d" > "$TWO_DAYS_AGO" ]]; then
# Then we delete the all the backups files older than 1 days
find $BACKUPDIR -mtime +1 -print0 | xargs -r0 rm -rf -- '{}';
fi
done

echo "Exporting local backups to remote Google storage..."
rclone copy $BACKUPDIR $GOOGLE_DRIVE_BACKUPDIR

echo "Replicating backups to AWS EC2 remote storage..."
rsync -au $BACKUPDIR/* $REMOTE_SERVER_BACKUPDIR
exit 0