#!/bin/sh

IFS='
'
for arq in `ls  -rlt ~/.kde/share/apps/okular/docdata/ | head -50 | awk '{$1=$2=$3=$4=$5=$6=$7=$8=""; print}' | sed 's/^\ *//g'`; do 
#    rm -f ~/.kde/share/apps/okular/docdata/$arq; 
    rm -f "$HOME/.kde/share/apps/okular/docdata/$arq"
done

