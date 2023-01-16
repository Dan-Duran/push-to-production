#!/bin/bash

# Variables (change items in [])
src_dir="/home/[USER]/[FOLDER]"
dst_dir="/var/www//html"

# create a changelog.txt and place it on the root source and destination. This script will check the version and copy files over if the version has change on the souce folder. Example:

# VERSION 0.1 - Jan 12, 2023
# - My Changes

changelog="$src_dir/changelog.txt"

# Exclude any other files
exclude_files=(".htaccess" "includes/config.php")

# Check if changelog.txt exists
if [ ! -f $changelog ]; then
echo "Changelog.txt not found in $src_dir. Exiting..."
exit 1
fi

# Get current version from changelog
current_version=$(head -n 1 $changelog | awk '{print $2}')

# Check if destination folder exists
if [ ! -d $dst_dir ]; then
echo "Destination folder $dst_dir not found. Exiting..."
exit 1
fi

# Check if destination folder contains a changelog.txt file. Also change permissions and ownership
if [ ! -f "$dst_dir/changelog.txt" ]; then
echo "Changelog.txt not found in $dst_dir. Copying all files..."
rsync -av --include='/' --include='' --exclude='' --exclude={$exclude_files[@]} $src_dir/ $dst_dir/
files_copied=$(find $dst_dir -type f | wc -l)
chmod -R 755 $dst_dir
chmod 644 $dst_dir/
chown -R www-data:www-data $dst_dir
cp $changelog "$dst_dir/changelog.txt"
echo "Successfully copied $files_copied files and replaced changelog.txt with new version."
exit 0
fi

# Get version from destination folder changelog
dest_version=$(head -n 1 "$dst_dir/changelog.txt" | awk '{print $2}')

# Compare versions
if [ $current_version == $dest_version ]; then
echo "Current version ($current_version) is the same as the destination version ($dest_version). Exiting..."
exit 0
else
echo "Current version ($current_version) is different from the destination version ($dest_version). Copying modified files and folders..."
rsync -avu --exclude={$exclude_files[@]} $src_dir/ $dst_dir/
files_copied=$(find $dst_dir -type f | wc -l)
chmod -R 755 $dst_dir
chmod 644 $dst_dir/*
chown -R www-data:www-data $dst_dir
cp $changelog "$dst_dir/changelog.txt"
echo "Successfully copied $files_copied modified files and folders and replaced changelog.txt with new version."
fi
