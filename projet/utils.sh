#!/bin/bash

# Caractère tabulation
# Le support de ce caractère dans la commande sed et la commande echo
# peuvent varier en fonction des versions, il est
TAB=$(printf "\t")

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
    fmessage=$(cut -f2 <<< "$1")
    ftags=$(cut -f3 <<< "$1")
}
