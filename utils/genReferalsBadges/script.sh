#!/bin/bash
#function geraPDF(){
 # heroku run rake sei:qrc_generator\[$1,$2,SU\]
#  tail -n +1 $1.in | sed  's/
#//g' > temp
  #cat temp > $1.in
  make $1.pdf
  mv $1.pdf pdf
#}


#while IFS="," read -r col1 col2
#do
#  geraPDF $col1 $col2
#done < $1

