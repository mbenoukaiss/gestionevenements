# Rapport projet : gestionnaire d'évènements
**Auteurs :**
- BENOU-KAÏSS Marwane
- QUERRE Clément

## Ce que fait le script

Quitter est un script bash permettant de gérer les rendez-vous d'une personne dans une journée. L'utilisateur peut alors programmer un rendez-vous à une certaine heure, ce rendez-vous sera sauvegardé dans un fichier. Lorsque l'heure du système correspond à celle du rendez-vous, une alerte sera envoyée à l'utilisateur.
Afin d'être capable de lancer une alerte au bon moment, un script est lancé en tâche de fond et vérifie toutes les 30 secondes l'heure système et la compare aux divers rendez-vous dans le fichier de données.

## Syntaxe d'appel du script

- quitter HHMM message... [+tag ...] pour ajouter un rendez vous à l'heure indiquée"
- quitter -l [+tag ...] pour afficher la liste des rendez-vous à venir"
- quitter -a pour afficher la liste de tous les rendez-vous"
- quitter -r [HHMM] pour supprimer les rendez-vous de l'heure correspondante"
- quitter -r [+tag ...] pour supprimer les rendez-vous du tag correspondant"
- quitter -h pour afficher le manuel de la commande"
- quitter -q pour quitter le script"

## Traces d'execution

- quitter 1245 Manger avec mes parents +manger +parents :
	- Notre programme se lance et rentre dans la boucle case. N'ayant aucune option sur cette commande, ce cas découpera en trois grosses parties, l'horaire : 1245, le message : Manger avec mes parents, et la chaîne de caractère des tags : +manger +parents.
	- Ces trois parties seront lancer en argument sur notre fonction ajouterRendezvous qui ajoutera dans notre fichier horaire.db le rendez-vous sous la forme : 1245:+manger +parents:Manger avec mes parents

- quitter -a :
	- Notre programme rentrera dans notre boucle case pour lancer la fonction afficherAllRendezVous qui remettra chacune des parties de chaque ligne de rendez-vous afin d'afficher la liste de tous les rendez-vous sous la forme : HHMM message... [+tag +tag ...]

- quitter -l +diner +jeanne
	- Ici, notre programme rentre la fonction afficherRendezVousAVenir en prenant en premier argument le tag diner et en second tag jeanne. Notre fonction vas donc chercher dans la liste des rendez-vous à venir ceux qui auront comme tags jeanne et diner pour pouvoir les afficher.

- quitter -r 1245
	- Notre programme va executer la fonction supprimerRendezVous dans notre case et lancer la fonction supprimerRendezVousHeure en prenant en argument la chaine 1245. Cette dernière fonction va supprimer dans la liste de tous les rendez-vous du fichier horaire.db qui correspondent à cette horaire.

- quitter -r +manger
	-De même ici, notre programme lancer la fonction supprimerRendezVous dans notre case et identifier manger comme un tag pour lancer la fonction supprimerRendezVousTags avec en argument la liste de tous les tags. Cette dernière fonction recherche le tag dans les tags des rendez-vous du fichier horaires.db et les supprimes.

- quitter -h
	- Ce paramètre permet à notre script d'executer la fonction usage qui affichera dans la console l'ensemble des fonctionnalités proposés par notre script comme écrit dans la syntaxe d'appel.

- quitter -q
	- Enfin, ce paramètre permettra à notre script de s'arrêter.

## Difficultés rencontrées lors du projet

- L'utilisation nouvelle de github et des commandes git à l'aide d'un terminal.

## Travail réalisé

- Nous avons réalisé sept fonctions pour executer répondant aux différentes options pouvant être executées par l'utilisateur lorsqu'il appelle le script (Voir syntaxe d'appel du script). 

## Améliorations éventuelles

- Il aurait été plus pratique d'avoir un gestionnaire d'évènements qui permette aussi de renseigner le jour, le mois et l'année afin de pouvoir noter des rendez-vous plusieurs jours ou mois voir même années à l'avances.
 
- À chaque execution du script, celui-ci supprimerait tous les évènements passés (si l'utilisateur avait arrêté le script ou si son ordinateur n'était pas allumé lorsqu'un évènement aurait du se déclencher).
