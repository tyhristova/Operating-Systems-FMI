# Напишете shell скрипт, който по подаден един позиционен параметър, ако този параметър
# е директория, намира всички symlink-ове в нея и под-директориите ѝ с несъществуващ destination.

#!/bin/bash

if [[ ${#} -ne 1 ]]; then
    echo "Invalid input"
    exit 1
fi

dir="$1"

if [[ ! -d "${dir}" ]]; then
    echo "Not a directory"
    exit 1
fi

find "${dir}" -type l | while read link; do
    if [[ ! -e "${link}" ]]; then
        echo "${link}"
    fi
done

#or
#find "${dir}" -xtype l

#or
#find "${dir}" -type l ! -exec test -e {} \; -print
