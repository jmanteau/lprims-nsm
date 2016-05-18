# Préparation

Installer Centos 7 avec

4096 RAM
2 CPU
64Mo Mémoire Vidéo
Interface réseau bridgée

Une fois l'installation finie, se connecter avec le mot de passe root créé pendant l'installation. Lancer dhclient pour récuperer une IP en DHCP ou la définir. Récuperer l'IP et se connecter en SSH via son poste.

Passer les commandes suivantes pour finir l'installation

```
yum install wget git
cd /etc/yum.repos.d/
wget http://download.opensuse.org/repositories/network:bro/CentOS_7/network:bro.repo
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

cd
yum install wireshark argus argus argus-clients bro tcpdump perl-libwww-perl perl-Crypt-SSLeay perl-Archive-Tar perl-Sys-Syslog perl-LWP-Protocol-https https://www.snort.org/downloads/snort/daq-2.0.6-1.centos7.x86_64.rpm https://www.snort.org/downloads/snort/snort-2.9.8.2-1.centos7.x86_64.rpm

git clone https://github.com/shirkdog/pulledpork.git
cp pulledpork/pulledpork.pl /usr/local/bin/
chmod +x /usr/local/bin/pulledpork.pl
cp -v pulledpork/etc/*.conf /etc/snort/

mkdir /etc/snort/rules/iplists
touch /etc/snort/rules/iplists/default.blacklist
touch /etc/snort/rules/local.rules
sed -i 's@# output unified2: filename merged.log, limit 128, nostamp, mpls_event_types, vlan_event_types@output unified2: filename snort.log, limit 128@g' /etc/snort/snort.conf
sed -i 's@var RULE_PATH /etc/snort/rules@var RULE_PATH rules@g' /etc/snort/snort.conf
sed -i 's@var SO_RULE_PATH ../so_rules@var SO_RULE_PATH so_rules@g' /etc/snort/snort.conf
sed -i 's@var PREPROC_RULE_PATH ../preproc_rules@var PREPROC_RULE_PATH preproc_rules@g' /etc/snort/snort.conf
sed -i 's@var WHITE_LIST_PATH ../rules@var WHITE_LIST_PATH rules@g' /etc/snort/snort.conf
sed -i 's@var BLACK_LIST_PATH ../rules@var BLACK_LIST_PATH rules@g' /etc/snort/snort.conf
sed -i 's@ipvar HOME_NET any@ipvar HOME_NET [192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]@g' /etc/snort/snort.conf

sed -i 's@include $RULE_PATH@#include $RULE_PATH@g' /etc/snort/snort.conf
sed -i 's@#include $RULE_PATH/local.rules@include $RULE_PATH/local.rules \n include $RULE_PATH/snort.rules@g' /etc/snort/snort.conf
mkdir /usr/local/lib/snort_dynamicrules
chown -R snort:snort /usr/local/lib/snort_dynamicrules
chmod -R 700 /usr/local/lib/snort_dynamicrules
touch /etc/snort/rules/white_list.rules
ln -s /usr/sbin/snort /usr/local/bin/snort

sed -i 's|/usr/local/etc/snort/|/etc/snort/|g' /etc/snort/pulledpork.conf
sed -i 's@rule_url=https://www.snort.org/reg-rules/|opensource.gz|<oinkcode>@#rule_url=https://www.snort.org/reg-rules/|opensource.gz|<oinkcode>@g' /etc/snort/pulledpork.conf
sed -i 's@rule_url=https://www.snort.org/reg-rules/|snortrules-snapshot.tar.gz|<oinkcode>@#rule_url=https://www.snort.org/reg-rules/|snortrules-snapshot.tar.gz|<oinkcode>@g' /etc/snort/pulledpork.conf
sed -i 's@#rule_url=https://rules.emergingthreats.net/|emerging.rules.tar.gz|open-nogpl@rule_url=https://rules.emergingthreats.net/|emerging.rules.tar.gz|open-nogpl@g' /etc/snort/pulledpork.conf
sed -i 's@# snort_version=2.9.0.0@snort_version=2.9.8.2@g' /etc/snort/pulledpork.conf




sed -i 's/ARGUS_BIND_IP/#ARGUS_BIND_IP/g' /etc/argus.conf

export PATH=/opt/bro/bin:$PATH
ln -s /usr/bin/rabins /usr/local/bin/rabins

```

Pour chaque exercice, indiquer les commande utilisées et copier un extrait du retour terminal de chaque commande.

Les réponses les plus élégantes (ligne de commande précise) seront valorisées en bonus. Il est important de montrer de quelel façon vous souhaitez obtenir l'information.

Récupérer les pcaps depuis:
```
wget https://cloud.jmanteau.fr/index.php/s/5P2CYLmwrgwjcYa/download
```

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
* Quels sont les quatre premiers termes recherchés (toutes les recherches incrémentales comptent) ?
* Quel est le titre du premier film qu'Ann a cliqué (indice: viewMovie) ?
* Quelle est l'URL complète de la bande annonce (défni par preview-url) ?
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
