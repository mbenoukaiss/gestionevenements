#!/bin/bash

CHEMINDACCES="/tmp/.config/quitter/"
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
        echo "Il est : "
        date "+%H:%M"

        echo "Voici vos prochains rendez-vous : "
        sort $CHEMINDACCES$FICHIER
        cat -n $CHEMINDACCES$FICHIER | grep "$date"
    else
        echo "ONESTAVECUNTAG"
    fi
}

function afficherAllRendezVous {
        echo "Voici la liste des rendez-vous :"
        while read ligne
        do
        chaineVersHeure $(cut -d: -f1 $CHEMINDACCES$FICHIER) #return fheures, fminutes
        message=$(cut -d: -f2 $CHEMINDACCES$FICHIER)
        tags=$(cut -d: -f3 $CHEMINDACCES$FICHIER)

        if test -z $1 || test -n $(echo $tags | grep $1)
        then
            echo "$fheures:$fminutes $message $tags"
        fi
        done < $CHEMINDACCES$FICHIER
}

case "$1" in
    -l)
        tag="$2"
        afficherRendezVousAVenir $tag
        ;;
    -a)
        tag="$2"
        afficherAllRendezVous $tag
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
        verifieProcessus

        if $? -eq 0
        then
            stopProcessus
        fi
        ;;
    *)
        if test $# -gt 1
        then
            args=$(echo $* | cut -d' ' -f2-$# | tr " " "\n")
            heurechaine=$(cut -d' ' -f1 <<< "$1")
            message=$(grep -F --invert-match + <<< "$args" | tr "\n" " ")
            tags=$(grep -F + <<< "$args" | tr -d "\n")

            ajouterRendezvous "$heurechaine" "$message" "$tags"
        else
            verifieProcessus

            if $? -eq 0
            then
                stopProcessus
            fi

            ./tachefond.sh &
            createProcessus $!
        fi
        ;;
esac
