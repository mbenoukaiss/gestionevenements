# Rapport projet : gestionnaire d'évènements
**Auteurs :**
- BENOU-KAÏSS Marwane
- QUERRE Clément

## Ce que fait le script
Quitter est un script bash permettant de gérer les rendez-vous d'une personne dans une journée. L'utilisateur peut alors programmer un rendez-vous à une certaine heure, ce rendez-vous sera sauvegardé dans un fichier. Lorsque l'heure du système correspond à celle du rendez-vous, une alerte sera envoyée à l'utilisateur.
Afin d'être capable de lancer une alerte au bon moment, un script est lancé en tâche de fond et vérifie toutes les 30 secondes l'heure système et la compare aux divers rendez-vous dans le fichier de données.

## Syntaxe d'appel du script
usage :   quitter HHMM message... [+tag ...] pour ajouter un rendez vous à l'heure indiquée"
          quitter -l [+tag ...] pour afficher la liste des rendez-vous à venir"
          quitter -a pour afficher la liste de tous les rendez-vous"
          quitter -r [HHMM] pour supprimer les rendez-vous de l'heure correspondante"
          quitter -r [+tag ...] pour supprimer les rendez-vous du tag correspondant"
          quitter -h pour afficher le manuel de la commande"
          quitter -q pour quitter le script"

## Traces d'execution


## Difficultés rencontrées lors du projet
- Utiliser git @Clément@Clément@Clément@Clément@Clément@Clément@Clément@Clément@Clément@Clément

## Travail réalisé


## Améliorations éventuelles
