#!/bin/sh

[ ! -d "screenshots" ] && mkdir screenshots
[ ! -d "screenshots-forwarded" ] && mkdir screenshots-forwarded

gowitness --disable-db -P screenshots $@
gowitness --header "X-Forwarded-For: 127.0.0.1" --disable-db -P screenshots-forwarded $@

root_folder="/data"
screenshot_original_dir="screenshots"
screenshot_forwarded_dir="screenshots-forwarded"

for screenshot_original in $(find $screenshot_original_dir -name *.png -type f)
do
    screenshot_original=$(echo $screenshot_original |rev |cut -d"/" -f1 |rev)
    check_if_exist=$(ls $screenshot_forwarded_dir |grep $screenshot_original)
    if [ $check_if_exist ]
    then
        echo "[+] Comparing: $screenshot_original"
        check_diff=$(perceptualdiff --threshold 30000 $screenshot_original_dir/$screenshot_original $screenshot_forwarded_dir/$screenshot_original)
        
        if [ ! -z "$check_diff" ]
        then
            [ ! -d "$root_folder/screenshots-diff" ] && mkdir $root_folder/screenshots-diff
            forwarded_filename=$(echo $screenshot_original |sed "s#.png#-forwarded.png#")
            cp $screenshot_original_dir/$screenshot_original $root_folder/screenshots-diff
            cp $screenshot_forwarded_dir/$screenshot_original $root_folder/screenshots-diff/$forwarded_filename
        fi
    fi
done
