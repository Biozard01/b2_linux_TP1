#!/bin/bash

backup_time=$(date +%Y%m%d_%H%M)

saved_folder_path=${1}

saved_folder="${saved_folder_path##*/}"

backup_name="${saved_folder}_${backup_time}"

moved_file="${saved_folder_path}/*"

echo $moved_file

tar -czf $backup_name.tar.gz $moved_file

# export nombreSave=`ls -l | grep -c /home/backup/site1- /home/backup/site2-`
# if [[ $nombreSave < 7 ]]
#   then
#       find . -mmin +60 -exec rm -f {} \;
# fi