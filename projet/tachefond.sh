#!/bin/bash

RENDEZVOUS=~/.config/quitter/
FICHIERRENDEZVOUS=~/.config/quitter/horaires.db

while true
do
    while read ligne
    do
        decomposeLigne $ligne
	currenttime=$(date +"%H%M")

        if test $currenttime = $fheurechaine
        then
            chaineVersHeure $fheurechaine
            echo -e "Il est $fheures:$fminutes et vous avez un rendez-vous : \n$fmessage \nTAGS : $ftags" | xmessage -file - &
        fi
    done < $FICHIERRENDEZVOUS

    sleep 30
done
