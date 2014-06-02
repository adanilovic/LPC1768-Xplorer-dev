#!/bin/bash -u

#-e causes bash to exit when a command fails
#-u causes bash to display a message when it tries to expand an unset variable
#-x turns on script debugging

#print the name of the command
echo "Running $0"

#the following prints the program running this script
#ps -f

symbol_to_find=$1
directory1=~/x-tools
directory2=~/crosstool-ng-toolchain

echo "Searching for libraries that contain the symbol: ${symbol_to_find}"

directories="$directory1 $directory2"
echo "directories = $directories"

#the -o is for or
files_found=$(find ${directories} -type f -iname "*.a" -o -iname "*.o")
#echo "files_found = ${files_found}"

while read file_name
do
#echo "Looking in ${file_name}"
nm $file_name 2>/dev/null | grep --color "${symbol_to_find}" 2>/dev/null
if [ $? == 0 ]; then
echo "Found in $file_name"
fi
#echo $?
done <<< "$files_found"

#$? reads the exit status of the last command executes
#echo $?

#use unset to remove a variable declared in this script from the currently running shell
unset symbol_to_find
unset directory1
unset directory2
unset directories
unset files_found
