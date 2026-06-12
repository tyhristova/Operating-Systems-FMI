Вашите колеги от съседната лаборатория ползват специализиран софтуер за оптометрични изследвания, който записва резултатите от всяко измерване в отделен файл. 
Файловете имат уникално съдържание, по което се определя за кое измерване се отнася файла. За съжаление, тъй като колегите
ви ползват бета версия на софтуера, той понякога записва по няколко пъти резултатите от дадено измерване в произволна комбинация от следните варианти:
    • нула или повече отделни обикновени файла с еднакво съдържание;
    • нула или повече групи от hardlink-ове, като всяка група съдържа две или повече имена на даден файл с измервания.
Помогнете на колегите си, като напишете shell скрипт, който приема параметър – име на директория,
съдържаща файлове с измервания. Скриптът трябва да извежда на стандартния изход списък с имена
на файлове, кандидати за изтриване, по следните критерии:
    • ако измерването е записано само в отделни файлове, трябва да остане един от тях;
    • ако измерването е записано само в групи от hardlink-ове, всяка група трябва да се намали с едно име;
    • ако измерването е записано и в групи, и като отделни файлове, за групите се ползва горния критерий, а всички отделни файлове се премахват.

#!/bin/bash

if [[ ${#} -ne  1 ]]; then
    echo "You must enter one argument" 1>&2
    exit 1
fi

if [[ ! -d ${1} && ! -r ${1} ]]; then
    echo "Your argument must be a directory" 1>&2
    exit 2
fi

mktemp TEMP_FILE

while read -r FILE; do

    HASH_FILE=$(sha256sum $FILE)  #извежда хешираната стойност и пътя на файла

    INODE=$(stat -c "%i" "$FILE")

    echo "$HASH_FILE $INODE" >> $TEMP_FILE

done < <(find ${1} -type f)

#Първо ще видя проблемните от hash-a 

sort -k 1 -o "$TEMP_FILE" "$TEMP_FILE"

touch FINAL_FILE

PREV_HASH=""

while read -r FILE; do

    GET_HASH=$(awk '{print $1}' <<< $FILE)

    if [[ $GET_HASH == $PREV_HASH ]]; then
        echo "$FILE" >> FINAL_FILE
    fi

    PREV_HASH=$GET_HASH

done < $TEMP_FILE

#Проверяваме проблемни по inode

PREV_INODE=""

sort -k 3 -n -o "$TEMP_FILE" "$TEMP_FILE"

while read -r FILE; do

  GET_INODE=$(awk '{print$3}' <<< $FILE)

  if [[ $GET_INODE == $PREV_INODE ]]; then
    echo "$FILE" >> FINAL_FILE
  fi

  PREV_INODE=$GET_INODE

done < $TEMP_FILE

cut -d ' ' -f 2 $FINAL_FILE | sort -u

cat "$FINAL_FILE"

rm -f $TEMP_FILE $FINAL_FILE