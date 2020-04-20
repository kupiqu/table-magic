#!/bin/bash
#
# For this to work:
#
# 1. Copy or link this file to somewhere in your $PATH (removing the extension), e.g., $HOME/.local/bin/magic
# 2. Replace the path $path_tableMagic below to wherever you put this code in your system
# 3. Test it in the terminal by executing `magic your_preferred_data_file_here`
# 4. Your default browser should open and show the content preview
# 4. That's it, enjoy!
#

# Path

path_tableMagic="$HOME/table-magic"

# Inserting data content

mapfile -t < "$1" lines

# need a for loop to add literal '\n' to each line
cmax=$(cat "$1" | wc -l)
# just showing up to 1000 lines
if [ $cmax -gt 1000 ]; then
  # showing first 500 and last 500 lines with a "..." line in between
  for (( c=0; c<501; c++ ))
  do
    # added line numbers for better readability
    if [ $c -eq 0 ]; then
      lines[$c]="Line,${lines[$c]}\\\n"
    else
      lines[$c]="$c,${lines[$c]}\\\n"
    fi
  done
  for (( c=$(($cmax-500)); c<$cmax; c++ ))
  do
    d=$(($c-$cmax+1002))
    # added line numbers for better readability
    lines[$d]="$c,${lines[$c]}\\\n"
  done
  lines[501]="...\\\n"
  data_content=$(printf "%s" "${lines[@]: 0:1002}")
else
  for (( c=0; c<$cmax; c++ ))
  do
    # added line numbers for better readability
    if [ $c -eq 0 ]; then
      lines[$c]="Line,${lines[$c]}\\\n"
    else
      lines[$c]="$c,${lines[$c]}\\\n"
    fi
  done
  data_content=$(printf "%s" "${lines[@]}")
fi

magicjs_file="$path_tableMagic/magic.js"

sed -i "s|^var\scsv_content=.*$|var csv_content='$data_content';|" "$magicjs_file"

xdg-open "$path_tableMagic/dataPreview.html"

# Restoring data content

original_data_content=$(grep -oP "var\scsv_content_original_text=.*" "$magicjs_file" | cut -d '=' -f2)

original_data_content=$(sed 's/\\n/\\\\n/g' <<< $original_data_content)

sleep 15s

sed -i "s/^var\scsv_content=.*$/var csv_content=$original_data_content/" "$magicjs_file"
