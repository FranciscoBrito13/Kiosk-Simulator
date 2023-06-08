#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

#Confirma a quantidade de argumentos
if [[ $# -eq 3 ]] || [[ $# -eq 4 ]]; then
    ./success 1.1.1
else
    ./error 1.1.1
    exit
fi

#Associa variáveis aos argumentos
nif=$((0))
nome=$1
senha=$2
saldo=$3

#Se for dado NIF então é associado à variável NIF
if [[ $# -eq 4 ]]; then
    nif=$4
fi

#PROCURA O NOME DE UTILIZADOR DADO NA BASE DE DADOS DO TIGRE
if [[ "$(grep ":$1," /etc/passwd | wc -w )" != 0 ]]; then
    ./success 1.1.2
else
    ./error 1.1.2 
    exit
fi

#VERIFICA SE O ARGUMENTO DO SALDO DADO É UM NÚMERO
if [[ $saldo =~ ^[0-9]+$ ]]; then
    ./success 1.1.3
else
    ./error 1.1.3
    exit
fi
#VERIFICA SE O SALDO FOI MESMO PASSADO E SE SIM SE É MESMO VÁLIDO OU NÃO
if [[ $# -eq 4 ]]; then
    if [[ $nif =~ ^[0-9]+$ ]] && [[ ${#nif} -eq 9 ]]; then
        ./success 1.1.4
    else 
        ./error 1.1.4
        exit
    fi
fi

#VERIFICA A EXISTENCIA DE UM FICHEIRO .txt COM OS UTILIZADORES, SE NAO EXISTIR CRIA ESSE FICHEIRO, CASO NAO O CONSIGA FAZER DÁ ERRO
if [ -f utilizadores.txt ]; then
    ./success 1.2.1
else
    ./error 1.2.1
    if touch utilizadores.txt; then
        ./success 1.2.2
    else
        ./error 1.2.2
    fi 
fi

#PROCURA O NOME DE UTILIZADOR NO FICHEIRO .TXT PARA SABER SE É UM NOVO UTILIZADOR OU NÃO
if [[ "$(grep "$nome" utilizadores.txt | wc -l)" != 0 ]]; then 
    ./success 1.2.3
else
    ./error 1.2.3
#VERIFICA A VÁLIDADE DO ARGUEMENTO DO NIF PASSADO
    if [[ $nif =~ ^[0-9]+$ ]] && [[ ${#nif} -eq 9 ]]; then
        ./success 1.2.4
        
        if [ -s utilizadores.txt ]; then
#CRIA UM NOVO ID PARA O UTILIZADOR SE O MESMO SE TIVER A REGISTAR
            lastId="$(grep -o "^[0-9]*" utilizadores.txt | tail -n 1)"
            newId=$(( $lastId+1 ))
            ./success 1.2.5 $newId
        else
            ./error 1.2.5
            newId=1
        fi
#VERIFICA SE PODE SER CRIADO UM EMAIL PARA O UTILIZADOR
        if [[ $(echo $nome | wc -w) -ge 2 ]]; then
            firstWord=$(echo $nome | cut -d' ' -f1 | tr '[:upper:]' '[:lower:]')
            lastWord=$(echo $nome | rev | cut -d' ' -f1 | rev | tr '[:upper:]' '[:lower:]')
    
            email=$firstWord.$lastWord@kiosk-iul.pt
            ./success 1.2.6 $email
        else 
            ./error 1.2.6

        fi
    #ENVIA O NOVO UTILIZADOR PARA O FICHEIRO .TXT
    echo -e "$newId:$nome:$senha:$email:$nif:0" >> utilizadores.txt

    if [ $? -eq 0 ]; then
        ./success 1.2.7 "$newId:$nome:$senha:$email:$nif:$saldo"
    else
        ./error 1.2.7
    fi

    else 
        ./error 1.2.4
        exit
    fi
fi


#ATUALIZA O SALDO NO UTILIZADOR 
saldoAtual="$(grep "$nome" utilizadores.txt | cut -d ":" -f 6)"
saldoFinal=$(( $saldoAtual + $saldo ))

#SUBSTITUI A LINHA ANTIGA COM O SALDO ANTIGO PELA LINHA COM O NOVO SALDO
oldLine=$(grep "$nome" utilizadores.txt)
newLine=$(echo $oldLine | sed "s/:[[:digit:]]*$/:$saldoFinal/")

sed -i "s/^$oldLine$/$newLine/" utilizadores.txt

#VERIFICA SE O NOME DADO COM A SENHA EXISTE NA BASE DE DADOS 
if [[ "$(grep ":$nome:$senha:" utilizadores.txt | wc -l)"  != 0 ]]; then
    ./success 1.3.1
else
    ./error 1.3.1
fi

if [ $? -eq 0 ]; then
    ./success 1.3.2 $saldoFinal
else
    ./error 1.3.2
fi

#CRIA UM FICHEIRO .TXT EM QUE DÁ SORT AOS UTILIZADORES ATRAVÉS DO SEU SALDO
sort -t':' -k6nr "utilizadores.txt" > "saldos-ordenados.txt"

if [ $? -eq 0 ]; then
    ./success 1.4.1
else
    ./error 1.4.1
fi
