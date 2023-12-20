#!/bin/bash

for FILE in $(ls *.tex); do
    echo
    echo =========================================
    echo $FILE
    texsc $FILE
done
