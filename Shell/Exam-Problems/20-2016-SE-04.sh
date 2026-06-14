# В текущата директория има само обикновени файлове (без директории). Да се напише
# bash script, който приема 2 позиционни параметъра – числа, който мести файловете 
# от текущата директория към нови директории (a, b и c, които трябва да бъдат създадени), като определен файл се
# мести към директория ’a’, само ако той има по-малко редове от първи позиционен параметър, мести
# към директория ’b’, ако редове са между първи и втори позиционен параметър и в ’c’ в останалите
# случаи.

#!/bin/bash

if [[ ${#} -ne 2 ]]; then 
    echo "Invalid number of arguments!"
    exit 1
fi 

if ! [[ "${1}" =~ ^[0-9]+$ && "${2}" =~ ^[0-9]+$ ]]; then 
    echo "The arguments should be numbers!"
    exit 2
fi

if [[ ${1} -gt ${2} ]]; then 
    echo "The first argument should not be greater!"
    exit 3
fi

mkdir -p a b c 

find . -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do 
    lines=$(wc -l < "${file}")
    base=$(basename "${file}")

    if [[ ${lines} -lt ${1} ]]; then 
        mv "${file}" a/"${base}"
    elif [[ ${lines} -gt ${2} ]]; then
        mv "${file}" c/"${base}"
    else 
        mv "${file}" b/"${base}"
    fi
done
