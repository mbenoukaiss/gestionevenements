#!/bin/bash

RENDEZVOUS=~/.config/quitter/
FICHIERRENDEZVOUS=~/.config/quitter/horaires.db

# Affiche une aide pour utiliser le script
function usage {
    echo "usage :   quitter HHMM message... [+tag ...] pour ajouter un rendez vous à l'heure indiquée"
    echo "          quitter -l [+tag ...] pour afficher la liste des rendez-vous à venir"
    echo "          quitter -a pour afficher la liste de tous les rendez-vous"
    echo "          quitter -r [HHMM] pour supprimer les rendez-vous de l'heure correspondante"
    echo "          quitter -r [+tag ...] pour supprimer les rendez-vous du tag correspondant"
    echo "          quitter -h pour afficher le manuel de la commande"
    echo "          quitter -q pour quitter le script"
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
        tags=$(cut -f2 <<< $2)

        #Si il n'y a pas de + (donc c'est une heure)
        if(test $tags == $(echo $1 | tr -dc'+'))
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
