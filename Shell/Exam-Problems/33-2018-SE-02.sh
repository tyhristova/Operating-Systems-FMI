# Напишете скрипт, който приема два позиционни аргумента – име на текстови файл и директория. 
# Директорията не трябва да съдържа обекти, а текстовият файл (US-ASCII) е стенограма
# и всеки ред е в следния формат:
#     ИМЕ ФАМИЛИЯ (уточнения): Реплика
# където:
#     • ИМЕ ФАМИЛИЯ присъстват задължително;
#     • ИМЕ и ФАМИЛИЯ се състоят само от малки/главни латински букви и тирета;
#     • (уточнения) не е задължително да присъстват;
#     • двоеточието ‘:’ присъства задължително;
#     • Репликата не съдържа знаци за нов ред;
#     • в стринга преди двоеточието ‘:’ задължително има поне един интервал между ИМЕ и ФАМИЛИЯ;
#     • наличието на други интервали където и да е на реда е недефинирано.

# Примерен входен файл:
#     John Lennon (The Beatles): Time you enjoy wasting, was not wasted.
#     Roger Waters: I'm in competition with myself and I'm losing.
#     John Lennon:Reality leaves a lot to the imagination.
#     Leonard Cohen:There is a crack in everything, that's how the light gets in.

# Скриптът трябва да:
#     • създава текстови файл dict.txt в посочената директория, който на всеки ред да съдържа:
#         ИМЕ ФАМИЛИЯ;НОМЕР
#     където:
#         – ИМЕ ФАМИЛИЯ е уникален участник в стенограмата (без да се отчитат уточненията);
#         – НОМЕР е уникален номер на този участник, избран от вас.
#     • създава файл НОМЕР.txt в посочената директория, който съдържа всички (и само) редовете на
# дадения участник.


#!/bin/bash

if [[ ${#} -ne 2 ]]; then 
    echo "Invalid number of arguments!"
    exit 1
fi

if [[ ! -f "${1}" ]]; then
    echo "The first argument should be a file!"
    exit 2
fi

if [[ ! -d "${2}" ]]; then
    echo "The first argument should be a directory!"
    exit 3
fi

file="${1}"
dir="${2}"

if [[ -n "$(find "${dir}" -mindepth 1 -print -quit 2>/dev/null )" ]]; then
    echo "Non-empty directory!"
    exit 4
fi

touch "${dir}/dict.txt"

declare -A ids
id=0

while IFS= read -r line; do
    speaker_part="${line%%:*}"

    speaker_part="$(echo "${speaker_part}" | sed 's/[[:space:]]*(.*)[[:space:]]*$//')"
    speaker_part="$(echo "${speaker_part}" | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//')"

    if [[ -z "${ids[${speaker_part}]}" ]]; then
        ((id++))
        ids["${speaker_part}"]="$id"
        echo "${speaker_part};${id}" >> "${dir}/dict.txt"
    fi

    num="${ids[${speaker_part}]}"
    echo "${line}" >> "${dir}/${num}.txt"

done < "${file}"
