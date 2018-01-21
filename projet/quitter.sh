#!/bin/bash

##########################################
###
###                         QUITTER.SH
###
###  Script shell permettant de gérer différents évènements sans 
###             avoir à vous soucier de l'heure !
###
###         Auteurs :
###      BENOU-KAÏSS Marwane, QUERRE Clément
###
###    Cette oeuvre, création, site ou texte est sous licence 
###    Creative Commons Attribution -  Partage dans les Mêmes 
###    Conditions 4.0 International. Pour accéder à une copie 
###  de cette licence, merci de vous rendre à l'adresse suivante 
###       http://creativecommons.org/licenses/by-sa/4.0/     
###
###################################################################

# Repertoire pour les sauvegardes
REPERTOIREQUITTER=~/.config/quitter/

# Fichier de rendez-vous
FICHIERRENDEZVOUS=horaires.db

# Fichier du processus
FICHIERPID=boucle.pid

# Caractère tabulation
# Le support de ce caractère dans la commande sed et la commande echo peuvent
# varier en fonction des versions, il est donc utile de le définir ici
TAB=$(printf "\t")

###################################
###				###
###	FONCTIONS UTILES	###
###				###
###################################

# Convertit une chaine de caractères sous la forme HHMM en deux
# variables : fheures contenant HH et fminutes contenant MM
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
    
    if test $1 -lt 0
    then
        return 1
    elif test $fheures -ge 24
    then
        return 2
    elif test $fminutes -ge 60
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

    if test $heures -ge 24 ||  test $heures -lt 0
    then
        return 1
    elif test $minutes -ge 60 || test $minutes -lt 0
    then
        return 2
    else
        return 0
    fi

    fchaine="$heures$minutes"
}

# Vérifie si l'heure fournie en paramètre en tant que chaine
# de caractères sous la forme HHMM est cohérente avec
# l'heure système
#
# param heure : Heure dans le format HHMM
# return : 1 : L'heure n'est pas cohérente avec l'heure système
function coherenceHeures {
    heurechaine=$1
    heures=$(date +%H)
    minutes=$(date +%M)

    chaineVersHeure $heurechaine
    
    if test $fheures -lt $heures || ( test $fheures -eq $heures && test $fminutes -le $minutes )
    then
        return 1
    else
        return 0
    fi
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
###    FONCTIONS LIÉES AUX PROCESSUS	###
###					###
###########################################

# Fonction permettant de vérifier, toutes les 30 secondes
# si il est l'heure d'afficher un message
# Si un message est envoyé, alors le script attend 60 
# secondes pour ne pas envoyer deux fois le message
function tacheFond {
    while true
    do
        notificationEnvoyee=false

        while read ligne
        do
            decomposeLigne "$ligne"
	    currenttime=$(date +"%H%M")

            if test $currenttime = $fheurechaine
            then
                notificationEnvoyee=true
                chaineVersHeure $fheurechaine
                echo -e "Il est $fheures:$fminutes et vous avez un rendez-vous : \n$fmessage \nTAGS : $ftags" | xmessage -title "Quitter.sh - Notification" -center -file - &
            fi
        done < $REPERTOIREQUITTER$FICHIERRENDEZVOUS

        if $notificationEnvoyee
        then
            sleep 60
        else
            sleep 30
        fi
    done
}

# Vérifie que les dossiers et les fichiers nécessaires
# au fonctionnement du script existent, et les créé si
# ils n'existent pas.
function setup {
    if [ ! -e $REPERTOIREQUITTER ]
    then
        mkdir $REPERTOIREQUITTER
    fi

    if [ ! -e $REPERTOIREQUITTER$FICHIERPID ]
    then
        touch $REPERTOIREQUITTER$FICHIERPID
    else
        if [ ! -f $REPERTOIREQUITTER$FICHIERPID ]
        then
            rm -r $REPERTOIREQUITTER$FICHIERPID
            touch $REPERTOIREQUITTER$FICHIERPID
        fi
    fi
	
    if [ ! -e $REPERTOIREQUITTER$FICHIERRENDEZVOUS ]
    then
        touch $REPERTOIREQUITTER$FICHIERRENDEZVOUS
    else
        if [ ! -f $REPERTOIREQUITTER$FICHIERRENDEZVOUS ]
        then
            rm -r $REPERTOIREQUITTER$FICHIERRENDEZVOUS
            touch $REPERTOIREQUITTER$FICHIERRENDEZVOUS
        fi
    fi
}

# Vérifie qu'il y a un processus valide dans le fichier
# de processus.
#
# return 1 : Le fichier de processus est vide
# return 2 : Le processus contenu dans le fichier n'est pas valide
function verifieProcessus {
	pid=$(cat $REPERTOIREQUITTER$FICHIERPID)

	if test -n $pid
	then
		if test -n $(ps axu | cut -d' ' -f2 | grep $pid)
		then
			return 0
		else
			return 2
                fi
	else
		return 1
	fi
}

# Sauvegarde l'id du processus qui vient d'être créé
#
# param pid : L'id du processus
function createProcessus {
	pid=$1
	echo $pid > $REPERTOIREQUITTER$FICHIERPID
}

# Arrête le processus contenu dans le fichier $FICHIERPID
#
# return 1 : Le processus contenu dans le fichier n'est
#            pas valide
function stopProcessus {
	verifieProcessus

	if test $? -eq 0
	then
		pid=$(cat $REPERTOIREQUITTER$FICHIERPID)

		if test $? -eq 0
		then
			kill -9 $pid 2> /dev/null
		fi

		rm $REPERTOIREQUITTER$FICHIERPID
                touch $REPERTOIREQUITTER$FICHIERPID
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

        if test $fheures -gt $heures || ( test $fheures -eq $heures && $fminutes -ge $minutes) && ( test -z $1 || grep -q $1 <<< $tags )
        then
            echo "$fheures:$fminutes $message (TAGS : $tags)"
        fi
    done < $REPERTOIREQUITTER$FICHIERRENDEZVOUS
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
    done < $REPERTOIREQUITTER$FICHIERRENDEZVOUS
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
    if test $? -ne 0
    then
        xmessage -title "Quitter.sh - Information" -center "L'heure renseignee est invalide ($chaine)"
        return $?
    fi

    coherenceHeures $heurechaine
    if test $? -ne 0
    then
        xmessage -title "Quitter.sh - Information" -center "L'heure renseignee n'est pas coherente avec l'heure systeme"
        return $?
    fi

    echo -e "$heurechaine$TAB$tags$TAB$message" >> $REPERTOIREQUITTER$FICHIERRENDEZVOUS
}

# Supprime un rendez-vous en fonction des tags fournis
# en paramètres
#
# param tag : Le tag à supprimer
function supprimerRendezvousTags {
    tag=$(echo $1 | tr -dc "[a-zA-Z0-9]")
    sed -i -E "/[0-9]{4}$TAB[a-zA-Z0-9+]{0,}$tag[a-zA-Z0-9+]{0,}$TAB.{0,}/d" $REPERTOIREQUITTER$FICHIERRENDEZVOUS
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
        xmessage -title "Quitter.sh - Information" -center "L'heure renseignee est invalide ($chaine)"
        return $?
    fi

    sed -i "/^$chaine$TAB/d" $REPERTOIREQUITTER$FICHIERRENDEZVOUS
}

###################################
###				###
###    EXECUTION DU SCRIPT	###
###				###
###################################

# Affiche une aide pour utiliser le script
function usage {
    echo "usage :  quitter                            lance le processus de vérification des évènements"
    echo "         quitter HHMM message... [+tag ...] ajoute un rendez vous à l'heure indiquée"
    echo "         quitter -l [+tag ...]              affiche la liste des rendez-vous à venir"
    echo "         quitter -a                         affiche la liste de tous les rendez-vous"
    echo "         quitter -r [HHMM]                  supprime les rendez-vous de l'heure correspondante"
    echo "         quitter -r [+tag ...]              supprime les rendez-vous du tag correspondant"
    echo "         quitter -h                         affiche le manuel de la commande"
    echo "         quitter -q                         arrête le processus de vérification des évènements"
}

setup

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
        args=$2

        #Si il y a un + (donc c'est un tag)
        if grep -q "+" <<< $args
        then
            echo "hey"
            supprimerRendezvousTags $args
        else
            echo "hoh"
            supprimerRendezvousHeure $args
        fi
        ;;
    -h)
        usage
        ;;
    -q)
        stopProcessus
        ;;
    [-]*)
        echo "quitter : option invalide '$1'"
        echo "Saisissez "./quitter.sh -h" pour plus d'informations."
        ;;
    *)
        if test $# -gt 1
        then
            args=$(echo $* | cut -d' ' -f2-$# | tr " " "\n")
            heurechaine=$(cut -d' ' -f1 <<< "$1")
            message=$(grep -F --invert-match + <<< "$args" | tr "\n" " ")
            tags=$(grep -F + <<< "$args" | tr -d "\n")

            ajouterRendezvous "$heurechaine" "$message" "$tags"
        fi

        stopProcessus
        tacheFond &
        createProcessus $!
        ;;
esac
