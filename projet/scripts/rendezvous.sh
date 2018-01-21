#!/bin/bash

RENDEZVOUS=~/.config/quitter/
FICHIERRENDEZVOUS=~/.config/quitter/horaires.db

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

# Affiche tous les rendez-vous à venir
#
# param tag : Le tag à chercher, optionnel
function afficherRendezVousAVenir {
    heures=$(date +%H)
    minutes=$(date +%M)

    echo "Nous sommes le : $(date "+%A %d %B %Y"), il est $heures:$minutes"
    echo "Voici vos prochains rendez-vous : "

    while read ligne
    do
        chaineVersHeure $(cut -f1 <<< $ligne) #return fheures, fminutes
        message=$(cut -f3 <<< $ligne)
        tags=$(cut -f2 <<< $ligne)

        if test $fheures -gt $heures || ( test $fheures -eq $heures && $fminutes -ge $minutes) && ( test -z $1 || grep -q $1 <<< $tags )
        then
            echo "$fheures:$fminutes $message (TAGS : $tags)"
        fi
    done < $RENDEZVOUS$FICHIERRENDEZVOUS
}

# Affiche tous les rendez-vous
#
# param tag : Le tag à chercher, optionnel
function afficherAllRendezVous {
    echo "Voici la liste des rendez-vous :"

    while read ligne
    do
        chaineVersHeure $(cut -f1 <<< $ligne) #return fheures, fminutes
        message=$(cut -f3 <<< $ligne)
        tags=$(cut -f2 <<< $ligne)

        if test -z $1 || grep -q $1 <<< $tags
        then
            echo "$fheures:$fminutes $message (TAGS : $tags)"
        fi
    done < $RENDEZVOUS$FICHIERRENDEZVOUS
}

# Ajoute un rendez-vous avec le message et les tags
# fournis en paramètres.
# 
# param heure : L'heure du rendez-vous, format HHMM
# param message : Le message
# param tags : Les tags séparés par des +
function ajouterRendezvous {
    heurechaine=$1
    message=$2
    tags=$3

    verifieChaineHeure $heurechaine #VOIR utils.sh
    if(test $? -ne 0)
    then
        xmessage "L'heure renseignée est invalide"
        return $?
    fi

    echo -e "$heurechaine$TAB$tags$TAB$message" >> $FICHIERRENDEZVOUS
}

# Supprime un rendez-vous en fonction des tags fournis
# en paramètres
#
# param tag : Le tag à supprimer
function supprimerRendezvousTags {
    tag=$(echo $1 | tr -dc "[a-zA-Z0-9]")
    sed -i -E "/[0-9]{4}$TAB[a-zA-Z0-9+]{0,}$tag[a-zA-Z0-9+]{0,}$TAB.{0,}/d" $FICHIERRENDEZVOUS
}

# Supprime un rendez-vous en fonction de l'heure fournie
# en paramètres
#
# param heure : L'heure à supprimer
function supprimerRendezvousHeure {
    chaine="$1"
    verifieChaineHeure $1 #VOIR utils.sh

    if(test $? -ne 0)
    then
        xmessage "L'heure renseignee est invalide ($chaine)"
        return $?
    fi

    sed -i "/^$chaine$TAB/d" $FICHIERRENDEZVOUS
}
