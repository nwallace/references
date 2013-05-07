#!/bin/bash

# Bugs:
#   doesn't work on (Name XXXX, XXXX)
#   doesn't work on Name (XXXX)
# Requests:
#   make it display errors if last name + year is not unique (compare wc and wc after sort -u)

FILE=thesis.txt

function main {
  check_for_bad_references
  found_count=0
  for i in `references`; do
    NAME=`echo $i | cut -d, -f1`
    YEAR=`echo $i | cut -d, -f2`
    REGEX="\b$NAME\b[^0-9]+?$YEAR"
    RESULT=`file_content | grep -oP "$REGEX"`
    if [ `echo $RESULT | wc -l` -lt 1 ]; then
      echo "Could not find $i"
    else
      echo "$NAME $YEAR: `echo $RESULT | while read res; do echo -e "\n    $res"; done`"
      ((found_count++))
    fi
  done
  echo
  echo "Found $found_count out of `clean_print $(count_reference_lines)`"
}

function check_for_bad_references {
  COUNT_REFERENCE_LINES=`count_reference_lines`
  COUNT_OUTPUT_LINES=`references | wc -l`
  if [ $COUNT_OUTPUT_LINES != $COUNT_REFERENCE_LINES ]; then
    echo "It appears you have a malformatted reference. There were `clean_print $COUNT_REFERENCE_LINES` in your References, but only `clean_print $COUNT_OUTPUT_LINES` matched my reference pattern." 1>&2
    find_bad_references
  fi
}

function find_bad_references {
  
}

function count_reference_lines {
  cat $FILE |
  sed '1,/^References$/d' |
  wc -l
}

function references {
  cat $FILE |
  sed '1,/^References$/d' |
  perl -l -ne '/^([^,]*),.*?\(([-0-9]*)\)/ and print "$1,$2"'
}

function file_content {
  cat $FILE |
  sed -n '1,/^References$/p'
}

function clean_print {
  echo $1 | sed "s/\s//"
}

main 2> errors.log

