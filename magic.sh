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

# Converting DOS style endlines to UNIX (if any)

rsync -a "$1" "$path_tableMagic/.tmpfile"
sed -i 's/\r$//' "$path_tableMagic/.tmpfile"

# Extracting data content

mapfile -t < "$path_tableMagic/.tmpfile" lines

# need a for loop to add literal '\n' to each line
cmax=$(cat "$path_tableMagic/.tmpfile" | wc -l)

# Removing the temporal file

rm -f "$path_tableMagic/.tmpfile"

# Showing up to 100 lines

if [ $cmax -gt 100 ]; then

  # showing first 50 and last 50 lines with a "..." line in between

  for (( c=0; c<51; c++ ))
  do
    # added line numbers for better readability
    if [ $c -eq 0 ]; then
      lines[$c]="Line,${lines[$c]}\\\n"
    else
      lines[$c]="$c,${lines[$c]}\\\n"
    fi
  done

  for (( c=$(($cmax-50)); c<$cmax; c++ ))
  do
    d=$(($c-$cmax+102))
    # added line numbers for better readability
    lines[$d]="$c,${lines[$c]}\\\n"
  done

  lines[51]="...\\\n"
  data_content=$(printf "%s" "${lines[@]: 0:102}")

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

# Inserting data content

magicjs_file="$path_tableMagic/magic.js"

{ # try

    # using `|` as delimiter as some entries might be paths using `/`

    sed -i "s|^var\scsv_content=.*$|var csv_content='$data_content';|" "$magicjs_file"

} || { # catch

    # sed failed, cannot use `|` as delimiter, trying `/`

    { # try

      sed -i "s/^var\scsv_content=.*$/var csv_content='$data_content';/" "$magicjs_file"

  } || { # catch

      # neither delimiter was successful, requesting manual intervention

      sed -i "s/^var\scsv_content=.*$/var csv_content='Line,The data parser failed\\\n1,The most likely explanation is that data contains pipe symbols and forward slashes\\\n2,Please replace one either of the symbols externally and try again';/" "$magicjs_file"

  }

}

# Previewing the result in the browser

xdg-open "$path_tableMagic/dataPreview.html"

# Restoring data content

original_data_content=$(grep -oP "var\scsv_content_original_text=.*" "$magicjs_file" | cut -d '=' -f2)

original_data_content=$(sed 's/\\n/\\\\n/g' <<< $original_data_content)

sleep 15s

sed -i "s/^var\scsv_content=.*$/var csv_content=$original_data_content/" "$magicjs_file"
