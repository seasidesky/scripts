#!/bin/sh

if [ $# -lt 1 ] ; then
    echo ""
    echo " Informe um diretório para pesquisar os arquivos .java "
    exit 1
fi


find $1 -name \*.java -exec file {} \; | egrep -v 'ASCII|UTF' | while read s; do 
	ff=`echo $s | awk -F ':' '{print $1}'`;  
	file $ff; 
	echo " charset   "; konwert any/pt/all-test  $ff; 
done