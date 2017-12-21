#!/bin/bash

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
	usage
	exit 1
esac
