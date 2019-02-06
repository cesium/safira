#!/bin/bash

# exemplo de input:
#Nome do Badge
#1111-2222
#3333-4444
#A34F-AC32

# exemplo de output correspondente:
#\badge{Nome do Badge}{1111-2222}
#\badge{Nome do Badge}{3333-4444}
#\badge{Nome do Badge}{A34F-AC32}

text=$(<$1)

name=""

sed '/^--code goes here--$/,$d' 'modelo.tex'

printf %s "$text" | while IFS= read -r line
do
  if [ -z "$name" ]
  then
    name="$line"
  else
    echo "\\badge{$name}{$line}"
  fi
done

sed '1,/^--code goes here--$/d' 'modelo.tex'
