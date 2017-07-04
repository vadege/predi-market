#!/bin/sh
cat en.i18n.json | cut -d':' -f 1 | sort > master.txt
cat ${1}.i18n.json | cut -d':' -f 1 | sort > trans.txt
diff -w master.txt trans.txt | grep '<' | cut -d'"' -f 2 | while read key ; do
   grep -C 0 "\"$key\"" en.i18n.json
done

rm master.txt
rm trans.txt
