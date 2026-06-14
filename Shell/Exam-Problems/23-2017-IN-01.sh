# Напишете скрипт, който приема три задължителни позицонни аргумента:
#     • име на фаил
#     • низ1
#     • низ2

# Файлът е текстови, и съдържа редове във формат:
#     ключ=стойност
# където стойност може да бъде:
#     • празен низ, т.е. редът е ключ=
#     • низ, състоящ се от един или повече термове, разделени с интервали, т.е., редът е ключ=𝑡1 𝑡2 𝑡3

# Някъде във файла:
#     • се съдържа един ред с ключ първия подаден низ (низ1);
#     • и може да се съдържа един ред с ключ втория подаден низ (низ2).
# Скриптът трябва да променя реда с ключ низ2 така, че обединението на термовете на редовете 
# с ключове низ1 и низ2 да включва всеки терм еднократно.

# Примерен входен файл:
#     $ cat z1.txt
#     FOO=73
#     BAR=42
#     BAZ=
#     ENABLED_OPTIONS=a b c d
#     ENABLED_OPTIONS_EXTRA=c e f

# Примерно извикване:
#     $ ./a.sh z1.txt ENABLED_OPTIONS ENABLED_OPTIONS_EXTRA

# Изходен файл:
#     $ cat z1.txt
#     FOO=73
#     BAR=42
#     BAZ=
#     ENABLED_OPTIONS=a b c d
#     ENABLED_OPTIONS_EXTRA=e f


# 1)
#!/bin/bash

if [[ ${#} -ne 3 ]]; then
    echo "Usage: ${0} <file> <key1> <key2>"
    exit 1
fi

file="${1}"
key1="${2}"
key2="${3}"

if [[ ! -f "${file}" ]]; then
    echo "The first argument must be an existing file."
    exit 2
fi

tmp=$(mktemp) || exit 3

awk -F= -v key1="${key1}" -v key2="${key2}" '
BEGIN {
    found1 = 0
    found2 = 0
}

{
    lines[NR] = $0

    if ($1 == key1) {
        found1 = 1
        val1 = $2
        n = split(val1, arr1, /[[:space:]]+/)
        for (i = 1; i <= n; i++) {
            if (arr1[i] != "") {
                in_key1[arr1[i]] = 1
            }
        }
    }

    if ($1 == key2) {
        found2 = 1
        val2 = $2
    }
}

END {
    if (!found1) {
        print "Missing key: " key1 > "/dev/stderr"
        exit 4
    }

    new_val2 = ""

    if (found2 && val2 != "") {
        m = split(val2, arr2, /[[:space:]]+/)
        for (i = 1; i <= m; i++) {
            term = arr2[i]
            if (term != "" && !(term in in_key1) && !(term in already_added)) {
                if (new_val2 == "") {
                    new_val2 = term
                } else {
                    new_val2 = new_val2 " " term
                }
                already_added[term] = 1
            }
        }
    }

    for (i = 1; i <= NR; i++) {
        split(lines[i], parts, "=")
        if (parts[1] == key2) {
            print key2 "=" new_val2
        } else {
            print lines[i]
        }
    }
}
' "${file}" > "${tmp}"

status=${?}

if [[ ${status} -ne 0 ]]; then
    rm -f "${tmp}"
    exit "${status}"
fi

mv "${tmp}" "${file}"



# 2)
#!/bin/bash

if [[ ${#} -ne 3 ]]; then
    echo "Usage: ${0} <file> <key1> <key2>"
    exit 1
fi

file="${1}"
key1="${2}"
key2="${3}"

if [[ ! -f "${file}" ]]; then
    echo "File not found"
    exit 2
fi

val1=$(grep "^${key1}=" "${file}" | cut -d '=' -f 2-)
val2=$(grep "^${key2}=" "${file}" | cut -d '=' -f 2-)

list1=$(echo "${val1}" | tr ' ' '\n')
list2=$(echo "${val2}" | tr ' ' '\n')

result=$(comm -23 <(echo "${list2}" | sort) <(echo "${list1}" | sort) | tr '\n' ' ' | sed 's/ $//')

if grep -q "^${key2}=" "${file}"; then
    sed -i "s/^${key2}=.*/${key2}=${result}/" "${file}"
fi
