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
if [ -n "$tag" ]{
then
        echo −n "Nous sommes le : "
        date '+%j %m %Y'
        echo "et il est : "
        date '+%H:%M'
        echo "Voici vos prochains rendez-vous"
        grep '^$heure' $CHEMINDACCES$FICHIER | cut -d: -f1-3
} else {
then 
	
}
}

function afficherAllRendezVous {

less $CHEMINDACCES$FICHIER | cut -d: -f1-3

}

function error {

echo "Vous devez choisir une option parmi : \"-l\", \"-a\", \"-r\" , \"-h\" ou \"-q\"."
echo "Pour en savoir davantage, faite simplement : \" quitter.sh -h \"."

}


case "$1" in
-l)
	tag="$2"
	afficherRendezVousAVenir ;;
-a)
	afficherAllRendezVous ;;
-r)
	tag="$2"
	supprimerHeure ;;
-h)
	usage ;;
-q)
	if verifieProcessus = 0
	then  stopProcessus fi ;;
*)
	error
	exit 1
esac
