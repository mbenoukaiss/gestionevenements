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
}

# Supprime un rendez-vous en fonction des tags fournis
# en paramètres
#
# param tag : Le tag à supprimer
function supprimerRendezvousTags {
    tag=$(echo $1 | tr -dc "[a-zA-Z0-9]")
    sed -i -E "/[0-9]{4}:[a-zA-Z0-9+]{0,}$tag[a-zA-Z0-9+]{0,}:.{0,}/d" $FICHIERRENDEZVOUS
}

function supprimerRendezvousHeure {
    chaine="$1"
    verifieChaineHeure $1 #VOIR utils.sh

    if(test $? -ne 0)
    then
        echo "L'heure renseignée est invalide"
        return $?
    fi

    sed -i "/$chaine/d" $FICHIERRENDEZVOUS
}

setupRendezvous
supprimerRendezvousTags "+tag"
supprimerRendezvousHeure "1251"
