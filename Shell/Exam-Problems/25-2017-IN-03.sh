# Напишете скрипт, който извежда името на потребителския акаунт, в чиято home директория има най-скоро променен обикновен файл и кой е този файл. 
# Напишете скрипта с подходящите проверки, така че да бъде валиден инструмент.

#!/bin/bash

if [ ! -d "/home" ]; then
    echo "Грешка: /home директорията не съществува."
    exit 1
fi

result=$(find /home -type f -printf "%T@ %u %p\n" 2>/dev/null | sort -nr | head -n 1)

if [ -z "$result" ]; then
    echo "Няма намерени файлове."
    exit 1
fi

user=$(echo "$result" | cut -d ' ' -f2)
file=$(echo "$result" | cut -d ' ' -f3-)

echo "Потребител: $user"
echo "Файл: $file"
