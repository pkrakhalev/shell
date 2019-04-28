#!/bin/sh

# select current directory
cd "`dirname -- "$0"`"

# check if input directory is not empty
if ! [ "$(ls -A input)" ]; then
  echo "input directory is empty"
  exit 1
fi

# get time and date
TIME=$(stat -f "%Sm" -t "%H_%M" input)

if [ "$?" -ne "0" ]; then
  echo "Sorry, cannot find folder input in the current folder"
  exit 1
fi

DATE=$(stat -f "%Sm" -t "%d_%m_%Y" input)

# create 'output' folder if it is not exist
mkdir -p output/$DATE

if [ "$?" -ne "0" ]; then
  echo "Sorry, cannot create output directory"
  exit 1
fi

# check that the file is exist to prevent owerwriting
COMPRESS_FILE=output/$DATE/$TIME-files.tar.gz
if [ -f "$COMPRESS_FILE" ]; then
  echo "Sorry, file output/$DATE/$TIME-files.tar.gz is already exist"
  exit 1
fi

# compress all files from input directory and 
# put them into output/<date>/<time>-files.tar.gz
cd input/ && tar -zcvf ../$COMPRESS_FILE  . && cd - 

if [ "$?" -ne "0" ]; then
  rm $COMPRESS_FILE
  echo "Sorry, unable to compress files"
  exit 1
fi

# look through all files ending with .log inside inbox
# put all lines that start with "error:" into a file
ERROR_FILE=output/$DATE/$TIME-errors.txt
for filename in input/*.log; do
  cat "$filename" | grep ^error:* 
done > $ERROR_FILE;

if [ "$?" -eq "2" ]; then
  rm $ERROR_FILE
  echo "Sorry, cannot get errors"
  exit 1
fi

# remove file with errors if it is empty
if ! [ -s "$ERROR_FILE" ]; then
  echo "No errors found. Delete error file"
  rm $ERROR_FILE
fi

# remove all files from 'input' folder
rm input/*
if [ "$?" -ne "0" ]; then
  rm $COMPRESS_FILE
  echo "Sorry, unable to delete files from input directory $status"
  exit 1
fi

# for MACOS folders
find input -name '.DS_Store' -type f -delete
if [ "$?" -ne "0" ]; then
  rm $COMPRESS_FILE
  echo "Sorry, unable to delete files from input directory $status"
  exit 1
fi


