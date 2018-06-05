# Préparation



Télécharger la VM suivante: [VM-NSM](https://s3-eu-west-1.amazonaws.com/jmanteau/NSM-VM.ova)

Les identifiants sont root/lprimsnsm

Se connecter sur la VM via le logiciel de virtualisation. Récupérer l'adresse IP soit en la demandant en DHCP (dhclient) soit en la fixant.

Se connecter en SSH sur la VM avec cette adresse IP. Le TP est à effectuer depuis le client SSH.

Les fichiers des TPs sont situés sous /opt/lprims-nsm/

```
# ls /opt/lprims-nsm/
exercice1  exercice2  exercice3
```

Un serveur web est disponible à http://$ADRESSE_IP . Il permet de visualiser plus aisément les fichiers produits lors des exercices.

Pour chaque exercice, indiquer les commande utilisées et copier un extrait du retour terminal de chaque commande.

Les réponses les plus élégantes (ligne de commande précise) seront valorisées en bonus. Il est important de montrer de quelle façon vous souhaitez obtenir l'information demandée.

Il est fortement conseillé de lire [le manuel d'utilisation des logiciels](https://github.com/jmanteau/lprims-nsm/blob/master/TP%20-%20Utilisation%20Tcpdump%20Tshark%20Argus%20Snort%20Bro.md). Il fournit les bases des commandes nécessaires durant le TP.


# Exercice 1

**Utiliser le fichier exercice1.pcap**

Vous obtenez un stage en tant qu'assistant sécurité pour un lycée et le second jour vous constatez que Youtube est inacessible et que la page ne peut pas se charger lorsqu'on essaye d'y accéder.

Heureusement, un full content pcap du traffic est disponible à l'heure de l'interruption.

Vous devez analyser le pcap pour voir comment l'accès youtube a été pertubé.


* Grapher la bande passante du pcap

* Lister les conversations DNS de exercice1.pcap avec tcpdump, tshark, argus, bro.

* Quelles sont les IPs de youtube (donner les /24) ?

* Quels sont l'état des connections TCP vers ces IPs (prendre le /16 74.125 pour cette question) ?

* Quelle attaque a été faite ?

* Combient de temps d'interruption (arrondir à la minute) ?

* Que voit Snort sur ce pcap ?

* Est-ce que les alertes vous semble justifiées ?

* Quel est la dernière version d'Ubuntu au moment de la capture ?


# Exercice 2

**Utiliser le fichier exercice2.pcap** 

Ann possède une AppleTV configuré avec une IP statique en 192.168.1.10. Le comportement d'Ann a engendré plusieurs alertes dans le système de sécurité de l'entreprise.

Dans le cadre d'une investigation, il vous est donc demandé d'analyser le type d'activités faite par Ann.

Le pcap contient les dernières traces réseaux obtenues de son traffic.

Votre mission est d'analyser les activités d'Ann en collectant les informations suivantes:

* Quelle est la MAC adresse de l'AppleTV ?

* Quel est le User Agent de l'AppleTV vu dans les requêtes web ?

* Quels sont les quatre premiers termes recherchés dans la partie Films de l'Apple Store (toutes les recherches incrémentales comptent) (indice: regarder les requetes HTTP) ?

* Quel est le titre du premier film qu'Ann a cliqué (indice: viewMovie) ?

* Quelle est l'URL complète de la bande annonce (défini par preview-url) ?

* Quel est le dernier terme recherché par Ann ?


# Exercice 3

**Utiliser le fichier exercice3.pcap** 

Vous êtes opérateur SOC dans une grande entreprise.

L'antivirus a détecté une compromission sur l'un des postes. On vous fournit le pcap du traffic des dernières 24h du réseau du poste.

Votre objectif est de déterminer comment l'infection s'est produite.

* Quels sont les hostnames des 3 machines Windows, leur IP et leur @MAC (indice: Netbios et DHCP) ?

* Quels sont les alertes détectées par Snort et leur signification ?

* Quel est le nom de l'exploit kit utilisé ?

* Quels sont le ou les IPs adresses et Mac adresses des machines ayant eu un exploit kit ?

* Quel est le nom de domaine du site web compromis (ayant servi à exécuter l'exploit) ?

* Quel est le nom de de domaine ayant servi à télécharger l'exploit kit ?

* Grapher la bande passante de la machine ayant été infectée en séparant input/ouput

* Quel est le nom du fichier javascript ayant amené à l'infection ?
