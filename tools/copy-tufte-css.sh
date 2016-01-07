#!/bin/bash

cd inst/rmarkdown/templates/tufte_html/resources/
cp ../../../../../../tufte-css/{tufte.css,LICENSE} ./
[ ! -d et-book ] && mkdir et-book
find ../../../../../../tufte-css/et-book -type f -name \*.ttf -exec cp {} et-book/ \;
cd et-book
for i in `ls *.ttf`; do
  mv $i ${i#et-book-}
done
sed -e 's@et-book/et-book-.*/@@' -e 's@\(url."et-book\)-@\1/@' -i '' ../tufte.css
