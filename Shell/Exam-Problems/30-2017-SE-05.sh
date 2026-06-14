# Напишете скрипт, който получава два задължителни позиционни параметъра – директория и низ. 
# Сред файловете в директорията би могло да има такива, чиито имена имат структура
# vmlinuz-x.y.z-arch където:
#     • vmlinuz е константен низ;
#     • тиретата “-” и точките “.” присъстват задължително;
#     • x е число, version;
#     • y е число, major revision;
#     • z е число, minor revision;
#     • наредената тройка x.y.z формира глобалната версия на ядрото;
#     • arch е низ, архитектура (платформа) за която е съответното ядро.

# Скриптът трябва да извежда само името на файла, намиращ се в подадената директория (но не и
# нейните поддиректории), който:
#     • спазва гореописаната структура;
#     • е от съответната архитектура спрямо параметъра-низ, подаден на скрипта;
#     • има най-голяма глобална версия.

# Пример:
# • Съдържание на ./kern/:
#     vmlinuz-3.4.113-amd64
#     vmlinuz-4.11.12-amd64
#     vmlinuz-4.12.4-amd64
#     vmlinuz-4.19.1-i386
# • Извикване и изход:
#     $ ./task1.sh ./kern/ amd64
#     vmlinuz-4.12.4-amd64


#!/bin/bash

if [[ ${#} -ne 2 ]]; then
    echo "Invalid number of arguments!"
    exit 1
fi 

if [[ ! -d "${1}" ]]; then 
    echo "The first argument should be a directory!"
    exit 2
fi 

if [[ -z "${2}" ]]; then 
    echo "The second argument should not be an empty string!"
    exit 3
fi 

dir="${1}"
str="${2}"

version=$(find "${dir}" -maxdepth 1 -type f -regextype posix-extended -regex ".*/vmlinuz-[0-9]+\.[0-9]+\.[0-9]+-${str}" 
| cut -d "-" -f 2
| sort -t '.' -nk 1,1 -nk 2,2 -nk 3,3 
| tail -n 1)

echo "vmlinuz-${version}-${str}"


#sort -t '.' -nk 1,1 -nk 2,2 -nk 3,3  -> -k start,end , иначе -k start (до края на реда)
#                                     -> ако за първа колона има еднакви стойности => премини към втора ... => към трета 