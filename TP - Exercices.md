# Préparation

Installer Centos 7 avec

à minima 2048 de RAM mais 4096 RAM est préférable.
2 CPU
64Mo Mémoire Vidéo
Interface réseau bridgée

Une fois l'installation finie, se connecter avec le mot de passe root créé pendant l'installation. Lancer ``dhclient`` pour récuperer une IP en DHCP ou la définir statiquement. Récuperer l'IP et se connecter en SSH via son poste.

Passer les commandes suivantes en root pour finir l'installation.

```
yum -y install wget
wget https://raw.githubusercontent.com/jmanteau/lprims-nsm/master/post_install.sh
bash post_install.sh
source /etc/profile
```
Si les PCAPS n'ont pas été récupéré, les prendre avec

```
wget https://s3-eu-west-1.amazonaws.com/jmanteau/pcapsTP.zip
unzip pcapsTP.zip
```

Lien alternatif pour les PCAPS

```
wget https://cloud.jmanteau.fr/index.php/s/5P2CYLmwrgwjcYa/download
```


Pour chaque exercice, indiquer les commande utilisées et copier un extrait du retour terminal de chaque commande.

Les réponses les plus élégantes (ligne de commande précise) seront valorisées en bonus. Il est important de montrer de quelle façon vous souhaitez obtenir l'information.


# Exercice 1

Utiliser le fichier exercice1.pcap du fichier pcaps.tar.gz


Vous obtenez un stage en tant qu'assistant sécurité pour un lycée et le second jour vous constater que Youtube est innacessible et que la page ne peut pas se charger lorsqu'on essaye d'y accéder.
Heureusement, un full content pcap est disponible.

Vous devez analyser le pcap pour voir comment l'accès youtube a été pertubé.


* Grapher la bande passante du pcap

* Lister les conversations DNS de q1.pcap avec tcpdump, tshark, argus, bro.

* Quelles sont les IPs de youtube (donner les /24) ?

* Quels sont l'état des connections TCP vers ces IPs (prendre le /16 74.125 pour cette question) ?

* Quelle attaque a été faite ?

* Combient de temps d'interruption (arrondir à la minute) ?

* Que voit Snort sur ce pcap ?

* Est-ce que les alertes vous semble justifiées ?

* Quel est la dernière version d'Ubuntu au moment de la capture ?


# Exercice 2

Utiliser le fichier exercice2.pcap du fichier pcaps.tar.gz

Ann a obtenu récemment une AppleTV configuré avec une IP statique en 192.168.1.10. Dans le cadre d'une investigation, il vous est demandé d'analyser le type d'activité faite par Ann. Le pcap contient les dernières traces obtenues.

Votre mission est de trouver ce qu'Ann a recherché et de collecter les informations suivantes:

* Quelle est la MAC adresse de l'AppleTV ?

* Quel est le User Agent de l'AppleTV vu dans les requêtes web ?

* Quels sont les quatre premiers termes recherchés (toutes les recherches incrémentales comptent) (indice: regarder les requetes HTTP) ?

* Quel est le titre du premier film qu'Ann a cliqué (indice: viewMovie) ?

* Quelle est l'URL complète de la bande annonce (défini par preview-url) ?

* Quel est le dernier terme recherché par Ann ?


# Exercice 3

Utiliser le fichier exercice3.pcap du fichier pcaps.tar.gz

* Quels sont les hostnames des 3 machines Windows, leur IP et leur @MAC (indice: Netbios et DHCP) ?

* Quels sont les alertes détectées par Snort et leur signification ?

* Quel est le nom de l'exploit kit utilisé ?

* Quels sont le ou les IPs adresses et Mac adresses des machines ayant eu un exploit kit ?

* Quel est le nom de domaine du site web compromis (ayant servi à exécuter l'exploit) ?

* Quel est le nom de de domaine ayant servi à télécharger l'exploit kit ?

* Grapher la bande passante de la machine ayant été infectée en séparant input/ouput

* Quel est le nom du fichier javascript ayant amené à l'infection ?
