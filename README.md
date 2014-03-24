# Backup files and database to FTP server

## Description

Performs backup of files and database.

Files will syncronize once a day, database will archived each 8 hours with rotation.

- db_make_dump.sh perfoms database backup
- lftp_sync_upload.conf config file for syncing files with lftp

## Requirements

OS - linux. Tested on Debian.
Works only with MySQL, mysqldump is required.
For FTP it uses lftp.

## Installation

Copy files db_make_dump.sh and lftp_sync_upload.conf to server from wich you will du backup

In db_make_dump.sh specify settings for FTP and mysql connection and path to remote backup folder.
Optionally you can change amount of days database backup will store.
In lftp_sync_upload.conf specify settings for FTP connection, path to source folder for syncing and path to remote backup folder.

Add to CRON folowing tasks:

    0 */8 * * * /path/to/db_make_dump.sh  > /dev/null 2>&1
    0 0 * * * lftp -f /path/to/lftp_sync_upload.conf > /dev/null 2>&1
