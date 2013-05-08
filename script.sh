#!/bin/bash

# Bugs:
#   doesn't work on Name XXXX, XXXX

file=$1

function main {
  bib=`bibliography`
  log_duplicates "$bib"
  txt=`content`
  find_bib_refs_in_content "$bib" "$txt"
}

function bibliography {
  sed '1,/^References$/d' $file |
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
  for ref in $1; do
    name=`echo "$ref" | cut -d, -f1`
    year=`echo "$ref" | cut -d, -f2`
    regex="\b$name\b[^0-9]+?\b$year\b"
    result=`echo "$2" | grep -oP "$regex"`
    if [ -z "$result" ]; then
      echo "Could not find $ref referenced in content" 1>&2
    fi
  done
}

function find_content_refs_in_bib {
  refs=`content_refs`
}

main

