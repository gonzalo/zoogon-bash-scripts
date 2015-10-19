#!/bin/bash

########## Config variables
login="username"
pass="password"
host="ftp_server.domain.com"
source_dir="/source_folder/"
target_dir="/target_folder/"

# Uncomment one of this lines depending if you want to upload of download files
mirror_direction="-R" #from local to remote
#mirror_direction=""   #from remote to local

# Uncomment to remove files that doesn't exist in origin 
# remove_files="-e"

# uncomment to exclude files by pattern 
# adjust pattern to your needs
# exclude_files="--exclude-glob .*"

########## Config ends

base_name="$(basename "$0")"
lock_file="/tmp/$base_name.lock"
trap "rm -f $lock_file" SIGINT SIGTERM
if [ -e "$lock_file" ]
then
    echo "$base_name is running already."
    exit
else
    touch "$lock_file"

    echo
    echo "Initiating FTP connection"
    echo

    lftp -u $login,$pass $host << EOF
    set ftp:ssl-allow no
    set mirror:use-pget-n 5
    mirror $mirror_direction $remove_files $exclude_files -P5 --log="/tmp/$base_name.log" "$source_dir" "$target_dir"
    quit

    echo
    echo "Sync finished"
    echo 
EOF
    rm -f "$lock_file"
    trap - SIGINT SIGTERM
    exit

fi
