Задачата ви е да напишете скрипт benchmark.sh, който измерва средното време за изпълнение на
дадена команда. Първият аргумент на скрипта е число (време за провеждане на експеримента, в секунди), а останалите аргументи на скрипта са измерваната команда и нейните аргументи.
Скриптът трябва да изпълнява подадената команда многократно, докато изтече подаденото време.
Когато това се случи, скриптът трябва да изчака последното извикване на командата да приключи и да
изведе съобщение, описващо броя направени извиквания, общото и средното време за изпълнение.
    $ ./benchmark.sh 60 convert image.jpg result.png
    Ran the command 'convert image.jpg result.png' 8 times for 63 seconds.
    Average runtime: 7.88 seconds.

    $ ./benchmark.sh 10 sleep 1.5
    Ran the command 'sleep 1.5' 7 times for 10.56 seconds.
    Average runtime: 1.51 seconds.
Забележки:
    • Времената се извеждат в секунди, с точност два знака след запетайката.
    • Приемете, че времето на изпълнение на частите от скрипта извън подадената команда е пренабрежимо малко.


#!/bin/bash

if [[ ${#} -eq 0 ]]; then 
    echo "The script requires arguments!" 1>&2
    exit 1
fi

if [[ "${1}" =~ '^[0-9]+$']]

number=${1}
shift

counter=0
elapsed_time=0

while [ $(echo "${elapsed_time} ${number}" | awk '$1 < $2 {print 1}') ==  1 ]; do
   
    before=$(date +'%s.%N')    
    (${@} &>/dev/null)
    after=$(date +'%s.%N')

    duration=$(echo "${after} - ${before}" | bc)

    elapsed_time=$(echo "${elapsed_time} + ${duration}" | bc)
    counter=$(( "${counter}" + 1 ))
    
done

avg=$(echo "scale=2; ${elapsed_time} / ${counter}" | bc)

rounded=$(echo "scale=2; ${elapsed_time}" | bc)

echo "Ran ${@} for ${rounded} seconds ${counter} times"
echo "${avg}"


