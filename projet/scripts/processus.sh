#!/bin/bash

CONFIGQUITTER=~/.config/quitter/
FICHIERPID=~/.config/quitter/boucle.pid

# Vérifie que les dossiers et les fichiers nécessaires
# au fonctionnement du script existent, et les créé si
# ils n'existent pas.
function setupConfig {
	if [ ! -e $CONFIGQUITTER ]
	then
		mkdir $CONFIGQUITTER
	fi

	if [ ! -e $FICHIERPID ]
	then
		touch FICHIERPID
	else
		if [ ! -f $FICHIERPID ]
		then
			rm -r $FICHIERPID
			touch $FICHIERPID
		fi
	fi
}

# Vérifie qu'il y a un processus valide dans le fichier
# de processus.
#
# return 1 : Le fichier de processus est vide
# return 2 : Le processus contenu dans le fichier n'est pas valide
function verifieProcessus {
	pid=$(cat $FICHIERPID)

	if test -n $pid
	then
		if test -n $(ps axu | cut -d' ' -f2 | grep $pid)
		then
			return 0
		else
			return 2 #LE PROCESSUS N'EST PAS VALIDE
                fi
	else
		return 1 #FICHIER VIDE
	fi
}

# Sauvegarde l'id du processus qui vient d'être créé
#
# param pid : L'id du processus
function createProcessus {
	pid=$1
	echo $pid > $FICHIERPID
}

# Arrête le processus contenu dans le fichier $FICHIERPID
#
# return 1 : Le processus contenu dans le fichier n'est
#            pas valide
function stopProcessus {
	verifieProcessus

	if test $? -eq 0
	then
		pid=$(cat $FICHIERPID)

		if test $? -eq 0
		then
			kill -9 $pid 2> /dev/null
		fi

		rm $FICHIERPID
                touch $FICHIERPID
	else
		return 1
	fi
}
