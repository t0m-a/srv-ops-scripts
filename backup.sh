#! /bin/bash
# Local backups archived and gunziped, then uploaded to Google Drive via RCLONE
# http://rclone.org/
# http://rclone.org/docs/
# You WILL NEED to have rcloned install and configured prior to running this script.
# Retention policies have to be configured on the backup targets using cleanBackup.sh
#####################################################################################
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

######### VARIABLES DECLARATIONS ###############################################
backupdir='/srv/backup'
googledrivebackupdir='insert_path_to_directory'
remoteserverbackupdir="user@host:/srv/backup"
twodaysago=$(date +%m-%d-%Y -d "2 days ago")
results=()

# FOLDERS DECLARATION SECTION: folders to backup
dirtobackup1='insert_path_to_directory'
dirtobackup2='insert_path_to_directory'
#dirtobackup3='insert_path_to_directory'
#dirtobackup4='insert_path_to_directory'
#dirtobackup5='insert_path_to_directory`

# BACKUP FILES NAMING SECTION
# You may add as much name definition as you have folders declared in the section
# above by copying a line below and changing nameNUMBER and dirtobacupNUMBER values.
# You will also need to uncomment or create new tar lines in the backup section.
name1=$(date -I)-${dirtobackup1##*/}
name2=$(date -I)-${dirtobackup2##*/}
#name3=$(date -I)-${dirtobackup3##*/}
#name4=$(date -I)-${dirtobackup4##*/}
#name5=$(date -I)-${dirtobackup5##*/}

######### FLOWS CONTROL SECTION ################################################
# Checking backup sources and remote folders configuration
if [ "$dirtobackup1" = 'insert_path_to_directory' ]
  then echo "This is the first time you run this script. Please edit the folders declaration sections."; exit 1
else
if [ "$remotebackupdir" = 'insert_path_to_directory' ]
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
mkdir -p $backupdir
sleep 1

echo "Creating SQL Backup"
cd $backupdir
mysqldump --defaults-extra-file=/root/.my.cnf --all-databases > dump-$( date -I).sql
tar -zcvf $( date -I)-dump.tar.gz dump-$( date -I).sql
rm -f dump-$( date -I).sql

echo "Creating compressed archive files for backup using tar"
cd $backupdir
sleep 1
tar -zcf $name1.tar.gz $dirtobackup1;
tar -zcf $name2.tar.gz $dirtobackup2;
#tar -zcvf $name3.tar.gz $dirtobackup3;
#tar -zcvf $name4.tar.gz $dirtobackup4;
#tar -zcvf $name5.tar.gz $dirtobackup5;

echo "New backups created:"
ls -lhA $backupdir

echo "Cleaning up local directory, removing all backups older than 1 day before export..."
# We list all files in destination getting their date in an array called results
for i in "$backupdir"/*; do
    results+=( "$(date -r "$i" "+%m-%d-%Y")");
done
# If we have files NEWER than two days ago in this list
for d in "${results[@]}"; do
if [[ "$d" > "$twodaysago" ]]; then
# Then we delete the all the backups files older than 1 days
find $backupdir -mtime +1 -print0 | xargs -r0 rm -rf -- '{}';
fi
done

echo "Exporting local backups to remote Google storage..."
rclone copy $backupdir $googledrivebackupdir

echo "Replicating backups to AWS EC2 remote storage..."
rsync -au $backupdir/* $remoteserverbackupdir
exit 0