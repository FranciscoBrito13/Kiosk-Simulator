#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

#VERIFICA SE OS FICHEIROS .txt EXISTEM, SE EXISTIREM ENTÃO ENTRA NO WHILE QUE DA ECHO DO MENU DA COMPRA

if [[ -f produtos.txt ]] && [[ -f utilizadores.txt ]]; then
    ./success 2.1.1
    comStock=$(grep "" produtos.txt | awk -F ":" '$4>0')
    count=0
    echo "$comStock" | cut -d ":" -f1 | while read line; do
        if ! [ "$line" = "" ]; then
            ((count++))
            precoStock=$(echo "$comStock" | grep "$line" | cut -d ":" -f3)
            echo "$count": $line: $precoStock EUR
        fi
    done
    echo "0: Sair"
    read -p "Insira a sua opção: " optionSelected
    
else
    ./error 2.1.1
    exit
fi

#VÊ A QUANTIDADE DE PRODUTOS QUE EXISTEM ATRAVÉS DO wc, SE NAO TIVER NADA ENTÃO EXISTEM 0 PRODUTOS, CASO CONTRÁRIO EXISTEM $qntDeProdutosDiferentesQueExistem
qntDeProdutosDiferentesQueExistem=$(echo "$comStock" | wc -l)
if [ "$comStock" = "" ]; then
    qntDeProdutosDiferentesQueExistem=0
else

#VAI BUSCAR A LINHA DO PRODUTO SELECIONADO E DEPOIS O SER RESPETIVO NOME, TIPO, STOCK, E PREÇO
    if [[ "${optionSelected}" =~ ^[1-9][0-9]*$ ]]; then
        product=$(echo "$comStock" | sed -n "${optionSelected}p")
    else
        echo "Invalid option selected"
    fi
    productName=$(echo "$product" | cut -d ":" -f1)
    productType=$(echo "$product" | cut -d ":" -f2)
    productStock=$(echo "$product" | cut -d ":" -f4)
    productPrice=$(echo "$product" | cut -d ":" -f3)
fi

#VERIFICA SE A OPÇAO ESCOLHIDA É UM INTEIRO, E DEPOIS SE É 0 OU UMA OPÇAO VÁLIDA
if ! [[ "$optionSelected" =~ ^[0-9]+$ ]]; then
    echo "Tem de ser um inteiro"
    ./error 2.1.2
    exit
elif [ "$optionSelected" -eq "0" ]; then
    ./success 2.1.2
    exit
elif [ $optionSelected -gt "$qntDeProdutosDiferentesQueExistem" ]; then
    ./error 2.1.2
    exit
else
    ./success 2.1.2 "$optionSelected" "$productName"
fi

read -p "Insira o ID do seu utilizador: " userID

allIDs=$(grep "" utilizadores.txt | cut -d ":" -f1)


#APÓS O UTILIZADOR SELECIONAR O ID VAI BUSCAR AS SUAS INFORMAÇÕES
if [ $(echo "$allIDs" | grep "$userID" | wc -l) != 0 ]; then
    userName=$(grep "^$userID:" utilizadores.txt | cut -d ":" -f2)
    userPass=$(grep "^$userID:" utilizadores.txt | cut -d ":" -f3)
    userMail=$(grep "^$userID:" utilizadores.txt | cut -d ":" -f4)
    userNIF=$(grep "^$userID:" utilizadores.txt | cut -d ":" -f5)
    userSaldo=$(grep "^$userID:" utilizadores.txt | cut -d ":" -f6)
    
    ./success 2.1.3 "$optionSelected" "$userName"
else
    ./error 2.1.3
    exit
fi

read -p "Insira a sua senha de utilizador: " givenPass

#CONFIRMA SE A PASSWD DADA É IGUAL À REGISTADA NO FICHEIRO .txt 
if [ "$givenPass" = "$userPass" ]; then
    ./success 2.1.4
else 
    ./error 2.1.4
    exit
fi

#CONFIRMA SE O UTILIZADOR TEM SALDO SUFICIENTE PARA EFETUAR A COMPRA
if [ "$productPrice" -gt "$userSaldo" ]; then
    ./error 2.2.1 $productPrice $userSaldo
    exit
else 
    ./success 2.2.1 $productPrice $userSaldo
fi

#CRIA UMA NOVA LINHA COM O NOVO SALDO DO UTILIZADOR E SUBSTITUI PELA LINHA ANTIGA
saldoFinal=$((userSaldo-productPrice))
oldLine=$(grep "$userName" utilizadores.txt)
newLine=$(echo "$oldLine" | sed "s/:[[:digit:]]*$/:$saldoFinal/")

sed -i "s/$oldLine/$newLine/" utilizadores.txt

if [ $? -eq 0 ]; then
    ./success 2.2.2
else  
    ./error 2.2.2
    exit
fi

#ATUALIZA O STOCK DOS PRODUTOS TROCANDO A SUA RESPETIVA LINHA TAL COMO NO SALDO DO UTILIZADOR
newProductStock=$((productStock-1))
newProductLine=$(echo "$product" | awk -F ":" -v new_val=$"$newProductStock" '{$4=new_val; print}' OFS=":")

sed -i "s/$product/$newProductLine/" produtos.txt

if [ $? -eq 0 ]; then
    ./success 2.2.3
else  
    ./error 2.2.3
    exit
fi

#CONFIRMA SE O FICHEIRO .txt EXISTE
if ! [ -f relatorio_compras.txt ]; then
    touch relatorio_compras.txt
else 
    true
fi

data=`date +%Y-%m-%d`

#ADICIONA AO RELATORIO DE COMPRAS A NOVA COMPRA 
echo "$productName":"$productType":"$userID":"$data"  >> relatorio_compras.txt

if [ $? -eq 0 ]; then
    ./success 2.2.4
else  
    ./error 2.2.4
    exit
fi

#CRIA O FICHEIRO COM A LISTA DE COMPRAS DO ULTIMO UTILIZADOR QUE REALIZOU UMA COMPRA
touch lista-compras-utilizador.txt
echo "**** $data: Compras de $userName ****" > lista-compras-utilizador.txt

grep ":$userID:" relatorio_compras.txt | awk "-F[:]" '{print $1",", $4}' >> lista-compras-utilizador.txt

#oldDate=$(head -n 1 lista-compras-utilizador.txt | awk "-F[ :]" '{print $2}' )
#sed -i "0,/$oldDate/ s/$oldDate/$data/" lista-compras-utilizador.txt
#grep "$userID" relatorio_compras.txt > 
#echo "$productName, $data" >> lista-compras-utilizador.txt


if [ $? -eq 0 ]; then
    ./success 2.2.5
else  
    ./error 2.2.5
    exit
fi
