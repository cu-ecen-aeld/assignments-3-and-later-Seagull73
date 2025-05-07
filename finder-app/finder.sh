#!/bin/sh

filesdir=$1
searchstr=$2

if [ -z $filesdir ]
then
    echo "Directory not specified!"
    exit 1
fi

if [ -z $searchstr ]
then
    echo "String not specified!"
    exit 1
fi

if ! [ -d "$filesdir" ]
then
    echo "Provided path is not a directory"
    exit 1
fi

filenum=$(find $filesdir -maxdepth 1 -type f | wc -l)
findnum=$(find $filesdir -maxdepth 1 -type f | xargs grep $searchstr | wc -l)

echo "The number of files are $filenum and the number of matching lines are $findnum"


