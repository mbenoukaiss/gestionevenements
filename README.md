# Gestionnaire d'évènements
**Auteurs :** BENOU-KAÏSS Marwane, QUERRE Clément

## Ce que fait le script

Quitter est un script bash permettant de gérer les rendez-vous d'une personne dans une journée. L'utilisateur peut alors programmer un rendez-vous à une certaine heure, ce rendez-vous sera sauvegardé dans un fichier. Lorsque l'heure du système correspond à celle du rendez-vous, une alerte sera envoyée à l'utilisateur.
Afin d'être capable de lancer une alerte au bon moment, un script est lancé en tâche de fond et vérifie toutes les 30 secondes l'heure système et la compare aux divers rendez-vous dans le fichier de données.

## Syntaxe d'appel du script

- quitter HHMM message... [+tag ...] pour ajouter un rendez-vous à l'heure indiquée"
- quitter -l [+tag ...] pour afficher la liste des rendez-vous à venir"
- quitter -a pour afficher la liste de tous les rendez-vous"
- quitter -r [HHMM] pour supprimer les rendez-vous de l'heure correspondante"
- quitter -r [+tag ...] pour supprimer les rendez-vous du tag correspondant"
- quitter -h pour afficher le manuel de la commande"
- quitter -q pour quitter le script"

## Sauvegarde des données
Pour sauvegarder les données de l'utilisateur et du processus, nous utilisons deux fichiers : horaires.db et processus.pid

Le fichier horaires.db, qui contient tous les rendez-vous de l'utilisateur est formatté de la façon suivante : *heure \t tags \t message*

- heure : l'heure de l'évènement sous la forme HHMM
- tags : les tags sous la forme +tag1+tag2+...
- message : le message de l'utilisateur
- La séquence de caractères "\t" représente une tabulation
- Les espaces sont présent ici afin d'améliorer la lisibilité, ils ne sont pas dans le vrai fichier.

Le fichier processus.pid contient uniquement l'ID de la tache de fond si jamais il y en a une, sinon le fichier est vide.






## Traces d'execution
- quitter
	- Lance la fonction chargée d'envoyer des notifications à l'aide de xmessage lorsqu'il est l'heure d'en afficher en tâche de fond. L'ID du processus est sauvegardé dans le fichier processus.pid. Si un processus était déjà en cours d'execution, il est arrêté afin d'en lancer un nouveau.
- quitter 1245 Manger avec mes parents +manger +parents :
	- Notre programme se lance et rentre dans la boucle case. N'ayant aucune option sur cette commande, ce cas découpera en trois grosses parties, l'horaire : 1245, le message : "Manger avec mes parents", et la chaîne de caractère des tags : "+manger +parents".
	- Ces trois parties seront lancées en arguments sur notre fonction ajouterRendezVous qui ajoutera, dans notre fichier horaire.db, le rendez-vous sous la forme : 1245	+manger +parents	Manger avec mes parents

- quitter -a :
	- Notre programme rentrera dans notre boucle case pour lancer la fonction afficherAllRendezVous qui remettra chacune des parties de chaque ligne de rendez-vous afin d'afficher la liste de tous les rendez-vous sous la forme : HHMM message... [+tag +tag ...]

- quitter -l +diner +jeanne
	- Ici, notre programme rentre la fonction afficherRendezVousAVenir en prenant en premier argument le tag diner et en second tag jeanne. Notre fonction vas donc chercher dans la liste des rendez-vous à venir ceux qui auront comme tags jeanne et diner pour pouvoir les afficher.

- quitter -r 1245
	- Notre programme va executer la fonction supprimerRendezVous dans notre case et lancer la fonction supprimerRendezVousHeure en prenant en argument la chaine 1245. Cette dernière fonction va supprimer dans la liste de tous les rendez-vous du fichier horaire.db qui correspondent à cet horaire.

- quitter -r +manger
	-De même ici, notre programme lancer la fonction supprimerRendezVous dans notre case et identifier manger comme un tag pour lancer la fonction supprimerRendezVousTags avec en argument la liste de tous les tags. Cette dernière fonction recherche le tag +manger dans les tags des rendez-vous du fichier horaires.db et les supprimes.

- quitter -h
	- Ce paramètre permet à notre script d'executer la fonction usage qui affichera dans la console l'ensemble des fonctionnalités proposées par notre script comme écrit dans la syntaxe d'appel.

- quitter -q
	- Enfin, ce paramètre permettra à notre script de s'arrêter.

## Difficultés rencontrées lors du projet

- Lors de la sauvegarde des évènements dans le fichier, il était important de trouver un délimiteur qui permette au script de continuer de fonctionner quel que soit le message de l'utilisateur. Nous avions au départ opté pour le caractère ':', mais il se peut que l'utilisateur en utilise dans son message. Finalement, nous avons choisi la tabulation, en effet, il est impossible d'en mettre depuis le terminal.

## Travail réalisé

- Nous avons réalisé sept fonctions pour executer répondant aux différentes options pouvant être executées par l'utilisateur lorsqu'il appelle le script.
	- Ajout d'un rendez-vous
	- Suppression d'un rendez-vous (par tag ou par heure)
	- Affichage des rendez-vous à venir (possibilité d'utiliser un tag)
	- Affichage de tous les rendez-vous (possibilité d'utiliser un tag)
	- Lancement/arrêt d'un processus de fond pour notifier l'utilisateur d'un rendez-vous
