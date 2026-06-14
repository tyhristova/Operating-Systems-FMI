# Напишете shell script, който получава задължителен първи позиционен параметър – директория и незадължителен втори – име на файл. 
# Скриптът трябва да намира в подадената директория и нейните под-директории всички symlink-ове и да извежда (при подаден аргумент файл –
# добавяйки към файла, а ако не е – на стандартния изход) за тях следната информация:
#     • ако destination-a съществува – името на symlink-а -> името на destination-а;
#     • броя на symlink-овете, чийто destination не съществува.

# Примерен изход:
#     lbaz -> /foo/bar/baz
#     lqux -> ../../../qux
#     lquux -> /foo/quux
#     Broken symlinks: 34


#!/bin/bash

if [[ ${#} -lt 1 || ${#} -gt 2 ]]; then 
    echo "Invalid input!"
    exit 1
fi 

dir="${1}"

if [[ ! -d "${dir}" ]]; then 
    echo "The argument should be a directory!"
    exit 2
fi 

output_file="${2}"

broken=0

if [[ -n "${output_file}" ]]; then
    exec >> "${output_file}"
fi

while IFS= read -r link; do
    target=$(readlink "${link}")

    if [[ -e "${link}" ]]; then
        echo "${link} -> ${target}"
    else
        $((broken++))
    fi
done < <(find "${dir}" -type l)

echo "Broken symlinks: ${broken}"


# exec >> file -> оттук нататък всички изходи на скрипта отиват във файла 
# >> -> append
# > -> презаписва файла
#
# realpath = readlink -> премахва . и ..
#                        разрешава symlink-ове
#                        връща реалния файл
#                        -> за broken symlink: проверяваме дали съществува -> -е
