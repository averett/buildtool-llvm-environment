#!/bin/sh

cat $1.cmake
echo 'export TARGET=<your_target_tuple> # EXPORT dumbass export...' >2
