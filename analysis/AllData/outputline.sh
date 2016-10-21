#!/bin/bash
count=`cat count`
count=$((count+1))
echo "fnames{$count}='$1';" | sed "s/'.\//'/g" 
echo "$count" > count
