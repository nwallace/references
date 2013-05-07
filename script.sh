#!/bin/bash

file=thesis.txt

function main {
  bibliography
}

function bibliography {
  counter=1
  cat $file |
  sed '1,/^References$/d' |

  #while read line; do
    #counter=$[$counter +1]
    #match=`perl -lne '/^([^,]*),.*?\(([-0-9]*)\)/ and print "$1,$2"'`
    #if [ `echo $match | wc -l` -gt 0 ]; then
      #echo "$counter:$match"
    #else
      #echo "***No match on $counter:$line" 1>&2
    #fi
    #((counter++))
  #done
}

main

