#!/bin/bash

REPERTOIRERENDEZVOUS=~/.config/quitter/
FICHIERRENDEZVOUS=horaires.db
FICHIERPID=~/.config/quitter/boucle.pid

# Caractère tabulation
# Le support de ce caractère dans la commande sed et la commande echo
# peuvent varier en fonction des versions, il est
TAB=$(printf "\t")

###################################
###				###
###	FONCTIONS UTILES	###
###				###
###################################

# Convertit une chaine de caractères sous la forme HHMM en deux
# variables : fheures contenant HH et fminutes contenant MM
#
# param tag : Le tag à supprimer
# return : 1 : Heures invalide
#          2 : Minutes invalide
function chaineVersHeure {
	chaine=$1

	let fheures=$chaine/100
	let fminutes=$chaine-$fheures*100
}

# Vérifie si une chaine représentant une heure est valide
#
# param tag : La chaine à vérifier
# return : 1 : Chaine négative
#          2 : Heures invalide
#          3 : Minutes invalide
function verifieChaineHeure {
    chaineVersHeure $1
    
    if(test $1 -lt 0)
    then
        return 1
    elif(test $fheures -ge 24)
    then
        return 2
    elif(test $fminutes -ge 60)
    then
        return 3
    else
        return 0
    fi
}

# Convertit deux entiers (heures et minutes) en une chaine de
# caractères sous la forme HHMM
#
# param heures : L'heure entre 0 et 24
# param minutes : Les minutes entre 0 et 60
# return : 1 : Heures invalide
#          2 : Minutes invalide
function heureVersChaine {
    heures=$1
    minutes=$2

    if( test $heures -ge 24 ||  test $heures -lt 0)
    then
        return 1
    elif( test $minutes -ge 60 || test $minutes -lt 0)
    then
        return 2
    else
        return 0
    fi

    fchaine="$heures$minutes"
}

# Décompose une ligne de données du fichier horaires.db
#
# param ligne : La ligne à décomposer
function decomposeLigne {
    fheurechaine=$(cut -f1 <<< "$1")
    fmessage=$(cut -f3 <<< "$1")
    ftags=$(cut -f2 <<< "$1")
}

###########################################
###					###
###    FONCTIONS LIEES AUX PROCESSUS	###
###					###
###########################################

# Fonction permettant de vérifier, toutes les 30 secondes
# si il est l'heure d'afficher un message
function tacheFond {
    while true
    do
        while read ligne
        do
            decomposeLigne "$ligne"
	    currenttime=$(date +"%H%M")

            if test $currenttime = $fheurechaine
            then
                chaineVersHeure $fheurechaine
                echo -e "Il est $fheures:$fminutes et vous avez un rendez-vous : \n$fmessage \nTAGS : $ftags" | xmessage -file - &
            fi
        done < $REPERTOIRERENDEZVOUS$FICHIERRENDEZVOUS

        sleep 30
    done
}

# Vérifie que les dossiers et les fichiers nécessaires
# au fonctionnement du script existent, et les créé si
# ils n'existent pas.
function setupConfig {
	if [ ! -e $REPERTOIRERENDEZVOUS ]
	then
		mkdir $REPERTOIRERENDEZVOUS
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

###########################################
###					###
###    FONCTIONS LIEES AUX RENDEZ-VOUS	###
###					###
###########################################

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

        if (test $fheures -gt $heures) || ( test $fheures -eq $heures && $fminutes -ge $minutes) && ( test -z $1 || grep -q $1 <<< $tags )
        then
            echo "$fheures:$fminutes $message (TAGS : $tags)"
        fi
    done < $REPERTOIRERENDEZVOUS$FICHIERRENDEZVOUS
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
    done < $REPERTOIRERENDEZVOUS$FICHIERRENDEZVOUS
}

# Vérifie que les dossiers et les fichiers nécessaires
# au fonctionnement du script existent, et les créé si
# ils n'existent pas.
# De même pour les fichiers temporaires.
function setupRendezvous {
    if [ ! -e $RENDEZVOUS ]
    then
        mkdir $RENDEZVOUS
    fi

    if [ ! -e $REPERTOIRERENDEZVOUS$FICHIERRENDEZVOUS ]
    then
        touch $REPERTOIRERENDEZVOUS$FICHIERRENDEZVOUS
    else
        if [ ! -f $REPERTOIRERENDEZVOUS$FICHIERRENDEZVOUS ]
        then
            rm -r $REPERTOIRERENDEZVOUS$FICHIERRENDEZVOUS
            touch $REPERTOIRERENDEZVOUS$FICHIERRENDEZVOUS
        fi
    fi

    if [ ! -e $RENDEZVOUSTMP ]
    then
        mkdir $RENDEZVOUSTMP
    fi
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

    echo -e "$heurechaine$TAB$tags$TAB$message" >> $REPERTOIRERENDEZVOUS$FICHIERRENDEZVOUS
}

# Supprime un rendez-vous en fonction des tags fournis
# en paramètres
#
# param tag : Le tag à supprimer
function supprimerRendezvousTags {
    tag=$(echo $1 | tr -dc "[a-zA-Z0-9]")
    sed -i -E "/[0-9]{4}$TAB[a-zA-Z0-9+]{0,}$tag[a-zA-Z0-9+]{0,}$TAB.{0,}/d" $REPERTOIRERENDEZVOUS$FICHIERRENDEZVOUS
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

    sed -i "/^$chaine$TAB/d" $REPERTOIRERENDEZVOUS$FICHIERRENDEZVOUS
}

###################################
###				###
###    EXECUTION DU SCRIPT	###
###				###
###################################

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

setupConfig
setupRendezvous

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
        stopProcessus
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
            stopProcessus
            tacheFond &
            createProcessus $!
        fi
        ;;
esac
