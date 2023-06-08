#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

#VERIFICA SE OS FICHEIROS .txt EXISTEM 
if [ -f produtos.txt ] && [ -f reposicao.txt ]; then 
    ./success 3.1.1
else 
    ./error 3.1.1
    exit 1
fi 

#VERIFICA SE OS PRODUTOS NO FICHEIRO reposição.txt EIXSTEM NOS produtos.txt VALIDANDO O NOME E A QUANTIDADE DE REFILL
while read line; do 
    stock=$(echo $line | cut -d ":" -f3 )
    name=$(echo $line | cut -d ":" -f1 )
    if [ "$(grep "$name" produtos.txt)" = "" ]; then 
        ./error 3.1.2 "$name"
        exit 1
        break
    fi 
    if ! [ $stock -ge 0 ]; then 
        ./error 3.1.2 $name
        exit 1
        break
    fi
done < reposicao.txt

./success 3.1.2

#Processamento do Script

data=`date +%Y-%m-%d`

#CRIA UM txt COM TODOS OS PRODUTOS QUE ESTÃO EM FALTA
touch produtos-em-falta.txt
echo "**** Produtos em falta em $data ****" > produtos-em-falta.txt


#ADICIONA AO RESPETIVO FICHEIRO TODOS OS PRODUTOS QUE ESTÃO EM FALTA FAZENDO A DIFERENÇA DE STOCK ENTRE O STOCK MAXIMO E O STOCK ATUAL
cat produtos.txt | while read line; do
    productStock=$(echo "$line" | cut -d ":" -f4)
    maxStock=$(echo "$line" | cut -d ":" -f5)
    productName=$(echo "$line" | cut -d ":" -f1)
    if [ $productStock -lt $maxStock ]; then 
        missingStock=$((maxStock-productStock))
        echo "$productName": "$missingStock" unidades >> produtos-em-falta.txt
    else 
        true
    fi
done

if [ $? -eq 0 ]; then 
    ./success 3.2.1
else    
    ./error 3.2.1
fi

#LÊ O FICHEIRO reposicao.txt E ATUALIZA O STOCK DOS PRODUTOS NO FICHEIRO produtos.txt 
while read line; do 
    repName=$(echo $line | cut -d ":" -f1)
    repNum=$(echo $line | cut -d ":" -f3) 
    currentStock=$(grep "$repName" produtos.txt | cut -d ":" -f4)
    limitStock=$(grep "$repName" produtos.txt | cut -d ":" -f5)
    currentStock=$((currentStock+repNum))
    if [[ "$currentStock" -gt $limitStock ]]; then
        currentStock=$limitStock
    fi
    oldLine=$(grep "$repName" produtos.txt)
    newLine=$(echo $oldLine | awk -F ":" -v stock="$currentStock" '{OFS=":"; $4=stock; print}') 
    sed -i "s/$oldLine/$newLine/" produtos.txt


done < reposicao.txt

if [ $? -eq 0 ]; then
    ./success 3.2.2
else
    ./error 3.2.2
fi


