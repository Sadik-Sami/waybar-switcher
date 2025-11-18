#!/bin/bash
todo_location=~/.local/share/calcurse/todo
apts_location=~/.local/share/calcurse/apts

TODOS_COUNT=$(wc -l < $todo_location)
TODOS=$(cat $todo_location | head -c -1 - | sed -z 's/\n/\\n/g')

CUR_DATE=$(date +"%m/%d/%Y")
CUR_APTS=$(grep "$CUR_DATE" "$apts_location")
FOUND=$?
APTS_COUNT=$(wc -l <<< $CUR_APTS)
APTS=$(echo $CUR_APTS | head -c -1 - | sed -z 's/\n/\\n/g')

if [ $FOUND -eq 1 ]
then
  printf '{"text": "TODO: %s", "tooltip": "%s"}\n' "$TODOS_COUNT" "$TODOS"
else
  printf '{"text": "TODO: %s, APT: %s", "tooltip": "%s"}\n' "$TODOS_COUNT" "$APTS_COUNT" "$TODOS"
fi