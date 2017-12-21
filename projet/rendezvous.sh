#!/bin/bash

RENDEZVOUS=~/.config/quitter/
FICHIERRENDEZVOUS=~/.config/quitter/horaires.db
RENDEZVOUSTMP=/tmp/quitter
FICHIERRENDEZVOUSTMP=/tmp/quitter/horaires.db

# Vérifie que les dossiers et les fichiers nécessaires
# au fonctionnement du script existent, et les créé si
# ils n'existent pas.
# De même pour les fichiers temporaires.
function setupRendezvous {
    if [ ! -e $RENDEZVOUS ]
	then
		mkdir $RENDEZVOUS
	fi

	if [ ! -e $FICHIERRENDEZVOUS ]
	then
		touch $FICHIERRENDEZVOUS
	else
		if [ ! -f $FICHIERRENDEZVOUS ]
		then
			rm -r $FICHIERRENDEZVOUS
			touch $FICHIERRENDEZVOUS
		fi
	fi

    if [ ! -e $RENDEZVOUSTMP ]
	then
		mkdir $RENDEZVOUSTMP
	fi

	# if [ ! -e $FICHIERRENDEZVOUSTMP ]
	# then
	# 	touch $FICHIERRENDEZVOUSTMP
	# else
	# 	if [ ! -f $FICHIERRENDEZVOUSTMP ]
	# 	then
	# 		rm -r $FICHIERRENDEZVOUSTMP
	# 		touch $FICHIERRENDEZVOUSTMP
	# 	fi
	# fi
}

# Supprime un rendez-vous en fonction des tags fournis
# en paramètres
#
# param tag : Le tag à supprimer
function supprimerRendezvous {
    cp $FICHIERRENDEZVOUS $FICHIERRENDEZVOUSTMP

    while read ligne
    do
        tag=$(cut -d':' -f2)
        echo "AAAa aaaaa aaaa aaaaa aaaa aaaaa aaaa" | tr -dc ' ' | wc -c
    done < $FICHIERRENDEZVOUSTMP
}
