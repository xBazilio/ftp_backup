#!/bin/sh

# >>> BEGIN CONFIG

# ftp account
FTP_USER=ftpuser
FTP_PASS=ftppass
FTP_HOST=ftphost

# mysql account
DB_USER=dbuser
DB_PASS=dbpass
DB_NAME=dbname
DB_HOST=dbhost

# remote folder
REMOTE_FOLDER=/path/to/remote/folder/

#store days
STORE_DAYS=20

# <<< END CONFIG

# source file for dump
FILE=/tmp/$DB_NAME.dump.`date +%Y%m%d%H%M%S`.sql.gz

# make dump
mysqldump -u$DB_USER -p$DB_PASS -h$DB_HOST --add-drop-table --single-transaction --quick $DB_NAME | gzip -c > $FILE

# save dump to ftp folder
lftp -e "mput ${FILE} -O ${REMOTE_FOLDER}; bye;" -u $FTP_USER,$FTP_PASS $FTP_HOST
rm $FILE

# rotation
# will delete files older then STORE_DAYS days

CURDATE=`date +%s`
CHECKDATE=$((CURDATE-(86400*$STORE_DAYS)))
CHECKDATE=`date -d@${CHECKDATE} +%Y%m%d%H%M%S`

echo $CHECKDATE
echo "open $FTP_USER:$FTP_PASS@$FTP_HOST" >> /tmp/sync.database.lftp

lftp -e "cd ${REMOTE_FOLDER}; nlist; bye;" -u $FTP_USER,$FTP_PASS $FTP_HOST | while read filename; do
        MDATE=`echo $filename | sed -e s/[^0-9]*//g`
        if [ "$MDATE" != "" ] ; then
                if [ "$CHECKDATE" -ge "$MDATE" ] ; then
                        echo "rm $REMOTE_FOLDER$filename;" >> /tmp/sync.database.lftp
                fi
        fi
done

echo "exit" >> /tmp/sync.database.lftp

lftp -f /tmp/sync.database.lftp
rm /tmp/sync.database.lftp

exit 0
