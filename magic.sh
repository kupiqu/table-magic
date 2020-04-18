#!/bin/bash
#
# For this to work:
#
# 1. Copy or link this file to somewhere in your $PATH, e.g., $HOME/.local/bin/magic
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
for (( c=0; c<=$cmax-1; c++ ))
do
  lines[$c]="${lines[$c]}\\\n"
done
data_content=$(printf "%s" "${lines[@]}")

magicjs_file="$path_tableMagic/magic.js"

sed -i "s/^var\scsv_content=.*$/var csv_content='$data_content';/" "$magicjs_file"

xdg-open "$path_tableMagic/dataPreview.html"

# Restoring data content

original_data_content=$(grep -oP "var\scsv_content_original_text=.*" "$magicjs_file" | cut -d '=' -f2)

original_data_content=$(sed 's/\\n/\\\\n/g' <<< $original_data_content)

sleep 15s

sed -i "s/^var\scsv_content=.*$/var csv_content=$original_data_content/" "$magicjs_file"
