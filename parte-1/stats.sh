#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

#VERIFICA OS ARGUEMENTOS PASSADOS E VÊ SE SÃO OU NÃO VÁLIDOS
if ([ -n "$1" ] && [ $1 = "listar" ] &&  [ $# -eq 1 ] ) || ([ -n "$1" ] && [ $1 = "histograma" ] && [ $# -eq 1 ] ) || ([ -n "$1" ] && [ $1 = "popular" ] && [[ $2 =~ ^[0-9]+$ ]] && [ $# -eq 2 ]); then 
    ./success 4.1.1
else 
    ./error 4.1.1
fi

#CRIA UM FICHEIRO stats.txt COM O NOME DE TODOS OS UTIIZADORES QUE JÁ FIZERAM COMPRAS POR ORDEM DESCRESCENTE
if ([ -n "$1" ] && [ $1 = "listar" ]); then
    touch stats.txt
    if [ ! -f relatorio_compras.txt ] || [ ! -f utilizadores.txt ]; then
        exit 1
    fi
    rcId=$(grep "" relatorio_compras.txt | cut -d ":" -f3)
    sortedrcId=$(echo "$rcId" | sort | uniq -c | sort -rn)
    echo "$sortedrcId"
    > stats.txt

    echo "$sortedrcId" | while read line; do 
        userId=$(echo "$line" | cut -d " " -f2) 
        compras=$(echo "$line" | cut -d " " -f1)
        userName=$(grep "^$userId:" utilizadores.txt | cut -d ":" -f2)
        echo "$userName": "$compras" compras >> stats.txt 
    
    done #<<< "$sortedrcId"

    if [ $? -eq 0 ]; then
        ./success 4.2.1
    else
        ./error 4.2.1
    fi


#CRIA UM FICHEIRO stats.txt EM QUE LISTA OS TOP n PRODUTOS COMPRADOS PELOS UTILIZADORES
elif ([ -n "$1" ] && [ $1 = "popular" ]); then
if [ ! -f relatorio_compras.txt ]; then
        exit 1
    fi
    touch stats.txt
    rcNome=$(grep "" relatorio_compras.txt | cut -d ":" -f1)
    sortedrcNome=$(echo "$rcNome" | sort | uniq -c | sort -rn)
    > stats.txt
    i=1

    while read line; do
        productName=$(echo "$line" | cut -d " " -f 2-)
        quantidade=$(echo "$line" | cut -d " " -f1)
        plural=""
        if [[ quantidade -gt 1 ]];then 
            plural="s"
        fi
        echo "$productName": "$quantidade" compra"$plural" >> stats.txt
        ((i++))
        if [[ $i -gt $2 ]]; then 
            break
        fi
    done <<< $sortedrcNome

    if [ $? -eq 0 ]; then
        ./success 4.2.2
    else
        ./error 4.2.2
    fi

#CRIA UM FICHEIRO stats.txt COM UM HISTOGRAMA DOS PRODUTOS VENDIDOS 
elif ([ -n "$1" ] && [ $1 = "histograma" ]); then
    if [ ! -f relatorio_compras.txt ]; then
        exit 1
    fi
    touch stats.txt
    rcCategoria=$(grep "" relatorio_compras.txt | cut -d ":" -f2)
    sortedrcCategoria=$(echo "$rcCategoria" | sort | uniq -c )
    > stats.txt

    while read line; do
        productType=$(echo "$line" | cut -d " " -f 2-)
        quantidade2=$(echo "$line" | cut -d " " -f1)
        stars=""
        for ((j=1; j<=$quantidade2; j++))
        do 
            stars+="*"
        done
        echo "$productType"  "$stars"  >> stats.txt

    done <<< $sortedrcCategoria

    if [ $? -eq 0 ]; then
        ./success 4.2.3
    else
        ./error 4.2.3
    fi
else 
    true
fi
