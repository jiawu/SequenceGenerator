#!/bin/sh
if [ -n $(qselect -u jjw036 -s R)]; then
  echo "there are no jobs"
else
  echo "there are jobs"
fi
