# Напишете скрипт, който приема задължителен позиционен аргумент - име на потребител FOO. 
# Ако скриптът се изпълнява от root:
#     а) да извежда имената на потребителите, които имат повече на брой процеси от FOO, ако има такива;
#     б) да извежда средното време (в секунди), за което са работили процесите на всички потребители
#     на системата (TIME, във формат HH:MM:SS);
#     в) ако съществуват процеси на FOO, които са работили над два пъти повече от средното време,
#     скриптът да прекратява изпълнението им по подходящ начин.

# За справка:
# $ ps -e -o user,pid,%cpu,%mem,vsz,rss,tty,stat,time,command | head -5
# USER PID %CPU %MEM VSZ RSS TT STAT TIME COMMAND
# root 1 0.0 0.0 15820 1920 ? Ss 00:00:05 init [2]
# root 2 0.0 0.0 0 0 ? S 00:00:00 [kthreadd]
# root 3 0.0 0.0 0 0 ? S 00:00:01 [ksoftirqd/0]
# root 5 0.0 0.0 0 0 ? S< 00:00:00 [kworker/0:0H]


#!/bin/bash

if [[ ${#} -ne 1 ]]; then
    echo "Usage: ${0} <username>"
    exit 1
fi

FOO="${1}"

if [[ ${EUID} -ne 0 ]]; then
    echo "This script must be run as root."
    exit 2
fi

if ! id "${FOO}" &>/dev/null; then
    echo "No such user: $FOO"
    exit 3
fi

tmp=$(mktemp) || exit 4

ps -e -o user=,pid=,time= > "${tmp}"

foo_count=$(awk -v user="${FOO}" '${1} == user { c++ } END { print c+0 }' "${tmp}")

awk -v foo="${foo_count}" '
{
    count[$1]++
}
END {
    for (u in count) {
        if (u != "'"${FOO}"'" && count[u] > foo) {
            print u
        }
    }
}
' "${tmp}"

avg=$(
awk '
function tosec(t, a) {
    split(t, a, ":")
    return a[1]*3600 + a[2]*60 + a[3]
}
{
    sum += tosec($3)
    cnt++
}
END {
    if (cnt == 0) {
        print 0
    } else {
        print sum / cnt
    }
}
' "${tmp}"
)

echo "Average process time: $avg seconds"

limit=$(awk -v a="${avg}" 'BEGIN { print 2*a }')

awk -v user="${FOO}" -v lim="${limit}" '
function tosec(t, a) {
    split(t, a, ":")
    return a[1]*3600 + a[2]*60 + a[3]
}
$1 == user {
    secs = tosec($3)
    if (secs > lim) {
        print $2
    }
}
' "${tmp}" | while read -r pid; do
    [[ -n "${pid}" ]] && kill "${pid}"
done

rm -f "${tmp}"
