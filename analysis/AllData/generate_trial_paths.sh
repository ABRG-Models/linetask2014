#!/bin/bash
echo '0'>count
find . -mindepth 2 -path '*20*.txt' -exec ./outputline.sh {} \; | tee allfiles.m
rm count
