#!/bin/bash

CHEMINDACCES="~/.config/quitter/"
FICHIER="horaires.db"

#HHMM:tag:message
#tag:chaine (ex tag1+tag2+tag3)
#ON PEUT L'AMÉLIORER AVEC JOUR ET MOIS EN PLUS

function usage {
    echo "usage :   quitter HHMM message... [+tag ...] pour ajouter un rendez vous à l'heure indiquée"
    echo "          quitter -l [+tag ...] pour afficher la liste des rendez-vous à venir"
    echo "          quitter -a pour afficher la liste de tous les rendez-vous"
    echo "          quitter -r [HHMM] pour supprimer les rendez-vous de l'heure correspondante"
    echo "          quitter -r [+tag ...] pour supprimer les rendez-vous du tag correspondant"
    echo "          quitter -h pour afficher le manuel de la commande"
    echo "          quitter -q pour quitter le script"
}

function afficherRendezVousAVenir {
    if test -z "$tag"
    then
        echo -n "Nous sommes le : "
        date "+%A %d %B %Y"
        echo -n "et il est : "
        date "+%H:%M"
        date=$(date "+%H%M")
        echo "Voici vos prochains rendez-vous : "
        sort $FICHIER
        cat -n $FICHIER | grep "$date"
    else
        echo "ONESTAVECUNTAG"
    fi
}

function afficherAllRendezVous {
    if test -z "$tag"
    then     
        while read ligne
        do
        heure=$(cut -d: -f1 $CHEMINDACCES$FICHIER)
        message=$(cut -d: -f3 $CHEMINDACCES$FICHIER)
        tags=$(cut -d: -f2 $CHEMINDACCES$FICHIER)
        echo "$heure $message $tags"
        done < $CHEMINDACCES$FICHIER
    else
        sed '/$tag/' $FICHIER
    fi
}

case "$1" in
    -l)
        tag="$2"
        afficherRendezVousAVenir $2
        ;;
    -a)
        tag="$2"
        afficherAllRendezVous
        ;;
    -r)
        args=$(cut -d':' -f2)

        #Si il n'y a pas de + (donc c'est une heure)
        if(test $args == $(echo $1 | tr -dc'+'))
        then
            supprimerRendezvousHeure $args
        else
            supprimerRendezvousTags $args
        fi
        ;;
    -h)
        usage
        ;;
    -q)
        if verifieProcessus = 0
        then
            stopProcessus
        fi
        ;;
    *)
        ajouterRendezvous "$*" $#
        ;;
esac
