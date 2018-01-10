# Convertit une chaine de caractères sous la forme HHMM en deux
# variables : fheures contenant HH et fminutes contenant MM
#
# param tag : Le tag à supprimer
# return : 1 : Heures invalide
#          2 : Minutes invalide
function chaineVersHeure {
	chaine=$1

	let fheures=$chaine/100
	let fminutes=$chaine-$hours*100

    if( test $fheures -ge 24)
    then
        return 1
    elif( test $fminutes -ge 60)
    then
        return 2
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

    echo $fchaine
}
