#!/bin/bash

# Bugs:
#   doesn't work on Name XXXX, XXXX
#   won't find authors whose name is O'Reily
#   in for loop in find_bib_refs, Van Orten,XXXX goes in as Van, then as Orten,XXXX
# Requests:
#   implement find_content_refs_in_bib
#     - if find bare year in parens, grep the sentence it's in for an author with the same year in bib?

file=$1

function main {
  bib=`bibliography`
  echo "$bib" > output/references.log
  log_duplicates "$bib"
  txt=`content`
  find_bib_refs_in_content "$bib" "$txt"
  # find_content_refs_in_bib "$txt" "$bib"
}

function bibliography {
  sed '1,/^References$/d' $file |
  sed -nE '1,/^Appendi(x A|ces)$/p' |
  while read line; do
    match=`echo $line | perl -lne '/^([^,]*),.*?\(([-0-9]*)[,)]/ and print "$1,$2"'`
    if [ -z "$match" ]; then
      echo "***Reference did not match pattern: $line" 1>&2
    else
      echo "$match"
    fi
  done
}

function log_duplicates {
  diff_output=`diff <(echo "$1" | sort) <(echo "$1" | sort -u)`
  if [ -z "$diff_output" ]; then
    echo "No duplicate references detected"
  else
    echo "Duplicate references detected:
`echo "$diff_output" | grep [\>\<] | awk '{ print "  "$2 }'`
This program is unable to ensure you have referenced all papers above. Please check yourself." 1>&2
  fi
}

function content {
  sed -n '1,/^References$/p' $file
}

function find_bib_refs_in_content {
  > output/matches.log
  for ref in $1; do
    name=`echo "$ref" | cut -d, -f1`
    year=`echo "$ref" | cut -d, -f2`
    regex="\b$name\b[^0-9]+?\b$year\b"
    result=`echo "$2" | grep -oP "$regex"`
    if [ -z "$result" ]; then
      echo "Could not find $ref referenced in content" 1>&2
    else
      echo "$ref:" >> output/matches.log
      echo "$result" | sed "s/^/    /" >> output/matches.log
    fi
  done
}

function find_content_refs_in_bib {
  echo "$1" |
  perl -lne '/\(([-a-zA-Z]+)[^0-9)(;]+([0-9]{4}(-[0-9]{4})?)[^\\)]*?)/ and print "$1,$2:$&"'
  #grep -oP "\((\w+)[^)(0-9]+(\d{4}(-\d{4})?\b)"
}

main

