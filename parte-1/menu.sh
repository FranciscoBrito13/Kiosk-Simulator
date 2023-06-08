#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

#LOOP WHILE QUE CORRE ATÉ QUE A VARIÁVEL $opcao SEJA IGUAL A 0
while [[ $opcao != 0 ]]
do
#ECHO DO QUE SERÁ APRESENTADO AO UTILIZADOR
    echo MENU:
    echo 1: Regista/Atualiza saldo utilizador
    echo 2: Compra produto
    echo 3: Reposiçao de Stock
    echo 4: Estatísticas
    echo 0: Sair
#LÊ A OPÇAO DO UTILIZADOR
    read -p "Opçao: " opcao 

#VERIFICA SE A VARIÁVEL OPCAO DE FACTO É NAO NULA (PARA EVITAR WARNINGS) E DEPOIS INVOCA UM SUB-MENU E EXECUTA UM SCRIPT TENDO EM CONTA A 
#OPÇÃO SELECIONADA PELO UTILIZADOR

    if [ -n "$opcao" ] && [ $opcao -eq "1" ]; then 
        echo "Regista Utilizador / Atualizar saldo utilizador: "
        read -p "Indique o nome do utilizador: " nome
        read -p "Indique a senha do utilizador: " senha
        read -p "Para registar o utilizador, insira o NIF do utilizador: " nif
        read -p "Indique o saldo a adicionar ao utilizador: " saldo 
        if [ $nif = "" ]; then
            ./regista_utilizador.sh "$nome" $senha $saldo
            ./success 5.2.2.1
        else 
            ./regista_utilizador.sh "$nome" $senha $saldo $nif
            ./success 5.2.2.1
        fi
    elif [ -n "$opcao" ] && [ $opcao -eq "2" ]; then
        ./compra.sh
        ./success 5.2.2.2
    elif [ -n "$opcao" ] && [ $opcao -eq "3" ]; then
        ./refill.sh
        ./success 5.2.2.3
    elif [ -n "$opcao" ] && [ $opcao -eq "4" ]; then 
#CRIA O SUB-MENU DAS ESTATÍSTICAS
        echo "Estatísticas:"
        echo "1: Listar utilizadores que já fizeram compras"
        echo "2: Listar os produtos mais vendidos"
        echo "3: Histograma de vendas"
        echo "0: Voltar ao menu principal"
        read subopcao
#VERIFICA SE AS OPÇOES NO SUBMENU SÃO VÁLIDAS
        if ([ $subopcao -le 3 ] && [ $subopcao -ge 0 ]); then
#DÁ O ARGUEMENTO DESEJADO AO FICHEIRO stats.sh TENDO EM CONTA A OPÇÃO ESCOLHIDA PELO UTILIZADOR
            if [ $subopcao -eq "1" ]; then
                ./stats.sh listar
            elif [ $subopcao -eq "2" ]; then
                echo "0: Voltar ao menu principal"
                read -p "Indique o número de produtos mais vendidos a listar: " qnt
                if [ -n "$qnt" ] && [ $qnt -ne 0 ]; then
                    ./stats.sh "popular" $qnt
                fi

            elif [ $subopcao -eq "3" ]; then
                ./stats.sh "histograma"
            fi
        else 
            ./error 5.2.2.4 $subopcao
        fi

    elif [ -n "$opcao" ] && [ $opcao -eq "0" ]; then
        exit 1
    else 
        ./error 5.2.1 $opcao
    fi
done 
    
