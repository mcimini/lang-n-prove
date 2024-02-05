#!/bin/bash

shopt -s nullglob

here="$(dirname "$0")"
cd "$here/generated"

total=0
fails=0
for i in *.thm; do
    total=$(($total + 1))
    abella "$i" > /dev/null || {
        fails=$(($fails + 1))
        echo -e "failed: $i\n"
    }
done
echo $total proofs attempted
echo $fails failures
