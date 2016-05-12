#TP Network Security Monitoring

* Préparation
* Présentation des logiciels utilisés (tcpdump, Wireshark/tshark, Argus, Snort, Bro)
* Utilisation pour générer des informations


## Préparation

Utiliser l'ISO Security Onion pour lancer une VM avec Virtual Box.

Créer un nouvel utilisateur et récupérer l'IP de la VM pour y accéder en SSH depuis votre client habituel.

```
sudo su  
\#Put tpuser as password
adduser tpuser
addgroup tpuser sudo


# Quelques petites corrections

mkdir /var/log/barnyard2
cp /etc/nsm/templates/barnyard2/barnyard2.conf /etc/nsm/templates/barnyard2/barnyard2.conf.bak
cat << EOF >> /etc/nsm/templates/barnyard2/barnyard2.conf
config utc
config logdir: /var/log/snort
config daemon
input unified2
config reference_file:      /etc/nsm/templates/snort/reference.config
config classification_file: /etc/nsm/templates/snort/classification.config
config gen_file:            /etc/nsm/templates/snort/gen-msg.map
config sid_file:           /etc/nsm/rules/sid-msg.map
output database: log, mysql, user=root dbname=snorby host=127.0.0.1
EOF

/usr/bin/barnyard2 -c /etc/nsm/templates/barnyard2/barnyard2.conf 

cd /opt/snorby/
RAILS_ENV=production bundle exec rake snorby:setup
RAILS_ENV=production bundle exec rails runner 'User.create(:name => "tpuser", :email => "tpuser@rims.fr", :password => "tpuser", :password_confirmation => "tpuser", :admin => true)'
# snorby accessible sur https://$IP:444

apt-get install librrds-perl
mkdir /var/log/snort/
ln -s /usr/bin/rabins /usr/local/bin/rabins

# Et mon IP ?
ip a 
```






** Optionnel: ELK
```
add-apt-repository ppa:openjdk-r/ppa
apt-get update 
apt-get install openjdk-8-jdk
```

```
wget https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/5.0.0-alpha1/elasticsearch-5.0.0-alpha1.deb https://download.elastic.co/logstash/logstash/packages/debian/logstash_5.0.0~alpha1-1_all.deb https://download.elastic.co/kibana/kibana/kibana_5.0.0-alpha1_amd64.deb https://download.elastic.co/beats/packetbeat/packetbeat-5.0.0-alpha1-x86_64.rpm https://download.elastic.co/beats/filebeat/filebeat-5.0.0-alpha1-x86_64.rpm
dpkg -i *.deb
```

## Présentation des logiciels
Rappel:  

* Full content : copie intégrale du traffic (PCAP)  
* Extracted content : Information extraite depuis le traffic réseau comme des fichiers  ou des pages web  
* Session data : résumé des conversation réseaux se concentrent sur qui parle avec qui, quand et combien d'information on été échangées  
* Transaction data: se concentre de façon plus granulaires sur les échanges et réponses dans les sessions réseaux.  
* Statistical data: information calculée à partir des précédentes information et caractérise l'activité réseau  
* Metadata: enrichissement des informations précédentes avec des informations tierces  
* Alert data: remontée d'information par les outils  

### tcpdump

**tcpdump** est un outil de capture et d'analyse réseau. Il permet d'avoir une analyse en direct du réseau ou d'enregistrer la capture dans un fichier afin de l'analyser pour plus tard. Il permet d'écrire des filtres afin de sélectionner les paquets à capturer/analyser.

Il est basé sur la libpcap pour la capture, ce qui permet à ses sauvegardes d'être compatible avec d'autres analyseurs réseaux, comme Wireshark . Cette bibliothèque étant multiplateforme, tcpdump est lui aussi porté sur la plupart des architectures.

C'est un outil indispensable à l'administration et au débugage d'applications réseaux. 

#### Présentation d'une capture

```
# tcpdump -n -i eth0
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ppp0, link-type LINUX_SLL (Linux cooked), capture size 96 bytes
01:04:28.531663 IP 71.197.145.153.46872 > 90.2.255.58.37727: . ack 816315239 win 65535 <nop,nop,timestamp 20729106 202488928>
01:04:28.539138 IP 90.2.255.58.37727 > 71.197.145.153.46872: . 9801:11201(1400) ack 0 win 2003 <nop,nop,timestamp 202489014 20729106>
01:04:28.569227 IP 81.242.185.212.17936 > 90.2.255.58.38835: . ack 1861880354 win 63552 <nop,nop,timestamp 522312 202488943,nop,nop,sack 1 {2801:4201}>
01:04:28.569286 IP 90.2.255.58.38835 > 81.242.185.212.17936: . 4201:5601(1400) ack 0 win 182 <nop,nop,timestamp 202489023 522312>
01:04:28.586301 IP 71.197.145.153.46872 > 90.2.255.58.37727: . ack 2801 win 65535 <nop,nop,timestamp 20729106 202488950>
01:04:28.586362 IP 90.2.255.58.37727 > 71.197.145.153.46872: . 11201:12601(1400) ack 0 win 2003 <nop,nop,timestamp 202489027 20729106>
01:04:28.609962 IP 71.197.145.153.46872 > 90.2.255.58.37727: . ack 5601 win 65535 <nop,nop,timestamp 20729107 202488958>
01:04:28.610020 IP 90.2.255.58.37727 > 71.197.145.153.46872: . 12601:14001(1400) ack 0 win 2003 <nop,nop,timestamp 202489033 20729107>
01:04:28.646915 IP 71.197.145.153.46872 > 90.2.255.58.37727: . ack 8401 win 65535 <nop,nop,timestamp 20729107 202488966>
01:04:28.646977 IP 90.2.255.58.37727 > 71.197.145.153.46872: . 14001:15401(1400) ack 0 win 2003 <nop,nop,timestamp 202489042 20729107>
01:04:28.647007 IP 90.2.255.58.37727 > 71.197.145.153.46872: . 15401:16801(1400) ack 0 win 2003 <nop,nop,timestamp 202489042 20729107> 

11 packets captured
22 packets received by filter
0 packets dropped by kernel
```

Les options avec lesquelles ont été invoquées tcpdump ne sont pas importantes ici. Elles sont détaillées à la section suivante.

Détails champ à champ de la ligne bleue (attention, le format de sortie dépend du type de protocole analysé et des options passées):
    
* l'heure
* le type de protocole (ici, IP)
* l'IP source.port_source > l'IP destination.port_destination
* les flags TCP : il peut y en avoir plusieurs pour un même paquet, on verra apparaître les lettres suivantes pour symboliser un drapeau levé :
	* S (SYN)
	* F (FIN)
	* P (PUSH)
	* R (RST)
	* W (ECN CWR)
	* E (ECN-Echo)
	* ou juste un point comme ici quand on n'a pas de drapeaux
* ack numéro : le numéro de séquence que l'on attend de la part de l'autre interlocuteur à son prochain envoie de paquets
* win numéro : le numéro représente la taille de la fenêtre TCP
* <des options> : les options TCP portées par le paquet, ici, on n'a que le timestamp

Les trois dernières lignes de la capture représentent :

    11 packets captured : c'est le nombre de paquet que tcpdump a reçu de l'OS et a traité
    22 packets received by filter : c'est le nombre de paquets qui ont été capturés car ils correspondaient aux filtres, cela ne signifie pas qu'ils auront été traités par tcpdump
    0 packets dropped by kernel : les paquets qui n'ont pas été capturés par l'OS car il n'y avait pas assez de place dans son buffer de réception
    
    
####Les options importantes

Voici une liste des options importantes avec leurs utilités:

*     -S: permet à tcpdump de suivre les sessions TCP, ainsi il calculera des numéros de séquence relatif au premier numéro de séquence qu'il a reçu. Cette option a un contre-coup, elle fait consommer de la mémoire afin de sauvegarder les informations sur les sessions en cours, donc ne vous étonnez pas de voir la RAM prise par tcpdump grossir si cette option est activée.
*     -p: dit à tcpdump de ne pas passer l'interface en mode "promiscous", alors celui-ci ne pourra capturer que les paquets qui sont adressé à la machine qui capture, il n'analysera pas les autres paquets qui peuvent passer sur le cable. Notez que cela peut permettre d'échapper aux outils de détection de sniffer (qui essayent de savoir si une machine du réseau possède une interface en mode "promiscous" par diverses techniques), mais cela fait de par la même occasion perdre une partie de l'intérêt du sniffing.
*     -n: tcpdump ne convertira pas les adresses et les numéros de ports en leurs noms. Pour les numéros de ports, en général, ce n'est pas bien grave, cela ne prend pas beaucoup de temps (c'est en local), mais pour les adresses, la recherche inverse de DNS peut-être un peu longue, elle peut alors ralentir TPCdump.
*     -i nom_interface : permet de choisir l'interface d'écoute. Par défaut, tcpdump écoute la première interface qu'il trouve. Si vous souhaitez écouter toutes vos interfaces à la fois, vous pouvez spécifier "any" à la place d'un nom d'interface, cela aura pour effet d'écouter TOUTES vos interfaces. (sous GNU/Linux "ifconfig -a" vous affiche toutes les interfaces réseaux de votre machine)
*     -w lefichier.pcap : enregistre toute la capture dans le fichier fichier.pcap. Cela permet de réanalyser le trafic plus tard. Le format PCAP étant reconnu par Wireshark, cela permet de donner le fichier à analyser à Wireshark pour une analyse plus fine des champs.
*     -r lefichier.pcap : le complémentaire de l'option précédente, qui permet de relire un fichier d'une session précédente. Peut notamment être utilisé sur une machine qui n'a pas le réseau ou autre pour une analyse post-mortem.
*     -s taille_de_la_capture : la taille de la fenêtre de capture. C'est la taille maximale que pourra faire un paquet capturé, au-delà de cette taille, la fin du paquet sera tronquée. Il peut être parfois intéressant de capturer les paquets complets, dans ce cas, il est possible de spécifier comme taille de capture 0 et tcpdump capturera alors l'intégralité du paquet quelque soit sa taille.
*     -c le nombre de paquets à capturer
*     -v : permet d'afficher encore plus d'informations sur les paquets, il y a trois niveaux de verbosité. Le nombre de 'v' correspond au niveau de verbosité.
*     -XX : affiche les paquets en hexadécimal et en ASCII. Assez utile pour analyser les protocoles basés sur le texte (HTTP, POP3, etc).

#### Les filtres BPF

tcpdump dispose d'un filtre puissant des paquets nommés BPF (abréviation de BSD packet filter). Cette section ne détaillera pas en profondeur toutes les possibilités des filtres. Vous êtes donc invité à lire le manuel si vous désirez plus de précisions.

##### Syntaxe
La syntaxe des filtres de base dans tcpdump s’utilise de la manière suivante :

proto[start:end]

où :

    proto représente le protocole (par exemple ip ou tcp) ;
    start représente le numéro de byte de début (le premier valant 0) ;
    end représente le numéro de byte de fin.

Ainsi, tcp[13] fait référence au byte numéro 13 (douzième byte) d'un paquet TCP (les drapeaux TCP).

La notation ip[4:2] fait référence au paramètre "id" d'un paquet IP (voir structure des paquets IP et TCP).

Seuls les filtres les plus utilisés sont présentés ici.

**host**  
   Permet de filtrer par nom de domaine.
   Exemple : tcpdump host google.com n'intercepte que les paquets à destination ou en provenance de google.com.

**net**  
   Permet de ne capturer que les paquets concernant un réseau particulier.  
   Exemple : tcpdump net 192.168 permet de filtrer les paquets émis ou destinés à une adresse IP commençant par 192.168.  
   Exemple : tcpdump dst net 212.27 permet de filtrer les paquets du réseau 212.27.0.0.  

 **port**  
   Permet de n'intercepter que les paquets originaires ou à destination d'un port particulier.  
   Exemple : tcpdump port 25 permet de surveiller les communications sur le port 25 (smtp).  
   Remarque : Le filtre port n'autorise pas la spécification d'une plage. Si vous voulez filtrer le trafic sur la plage de ports  source tcp/udp 20-80, utilisez le filtre avancé suivant :  
     `(tcp[0:2]>20 and tcp [0:2]<80) || (udp[0:2]>20 and udp[0:2]<80)`

**src**  
   Le mot clé src peut précéder les filtres afin restreindre les captures à un traffic provenant d'un hôte, d'un réseau ou d'un port. S'applique à host, net, port.

 **dst**  
   Le mot clé dst peut précéder les filtres afin restreindre les captures à un traffic à destination d'un hôte, d'un
   réseau ou d'un port. S'applique à host, net, port.

 **Filtre par protocole**  
   Filtrage par protocole (tcp, udp, arp, udp, icmp, etc.)  
   Exemple : tcpdump –eth1 arp permet de ne capturer que les trames du protocole ARP.

 **not ou !** 
   Le mot clé spécifie le contraire de ce qui suit
   Exemple : tcpdump –i eth1 not ssh signifie que l'on n'affiche pas ce qui concerne ssh (peut être utile dans le cas où
   l'on a effectué la capture à partir d'un shell ssh)

 **and ou &&**  
   Permet d'additionner des filtres avec une logique binaire ET
   Exemple : tcpdump –i eth1 

 **or ou ||**  
   Permet d'additionner des filtres avec une logique binaire OU


##### Exemples
Permet d'afficher uniquement les paquets ftp du port 21

`
 # tcpdump port ftp
`
 ou 
`
 # tcpdump port 21
`

Permet d'afficher les paquets qui ont pour adresse de destination et/ou sources 192.168.1.144


```
 # tcpdump host 192.168.1.144
```

Permet d'afficher les paquets qui ont pour adresse de destination 192.168.1.144

```
 # tcpdump dst 192.168.1.144
```

Permet d'afficher les paquets qui ont pour adresse source 192.168.1.144

```
 # tcpdump src 192.168.1.144
```


Permet d'afficher tous les paquets ftp à destination ou de sources de l'IP 192.168.1.55

```
 # tcpdump host 192.168.1.55 and port ftp
```


Affiche tous les paquets en provenance de 192.168.1.144 vers 192.168.20.32 sur le port 21 en tcp.

```
 # tcpdump src host 192.168.1.144 and dst host 192.168.20.32 and port 21 and tcp
```

Affiche tous les paquets en provenance de 192.168.1.144 vers 192.168.20.32 sur le port 21 en tcp.

```
 # tcpdump -x -X -s 0 src host 192.168.1.144 and dst host 192.168.20.32 and port 21 and tcp
```

tcpdump filter to match DHCP packets including a specific Client MAC Address:    
```
tcpdump -i br0 -vvv -s 1500 '((port 67 or port 68) and (udp[38:4] = 0x3e0ccf08))'
```

tcpdump filter to capture packets sent by the client (DISCOVER, REQUEST, INFORM):  

```
tcpdump -i br0 -vvv -s 1500 '((port 67 or port 68) and (udp[8:1] = 0x1))'
```

to find all packets with both the SYN and RST flags sey:  

```
tcpdump 'tcp[13] = 6'
``` 

##### Liens
[http://danielmiessler.com/study/tcpdump/]()  
[https://staff.washington.edu/dittrich/talks/core02/tools/tcpdump-filters.txt  
]()
[https://blog.wains.be/2007/2007-10-01-tcpdump-advanced-filters.md
]()

### Wireshark/tshark


#### Introduction

Wireshark est l'analyseur réseau le plus populaire du monde. Cet outil extrêmement puissant fournit des informations sur des protocoles réseaux et applications à partir de données capturées sur un réseau.
Comme un grand nombre de programmes, Wireshark utilise la librairie réseau pcap pour capturer les paquets.

La force de Wireshark vient de:
- sa facilité d'installation.
- sa simplicité d'utilisation de son interface graphique.
- son très grand nombre de fonctionnalités.

Wireshark fut appelé Ethereal jusqu'en 2006 où le développeur principal décida de changer son nom en raison de problèmes de copyright avec le nom de Ethereal qui était enregistré par la société qu'il décida de quitter en 2006.

Si vous n'avez pas d'interface graphique, vous pourriez être intéressé par "TShark" qui est une version en ligne de commande de Wireshark. TShark supporte les mêmes fonctionnalités que Wireshark. 

Une connaissance de Wireshark en mode GUI ainsi que la notion de filtre wireshark ( [filtre capture BPF](https://wiki.wireshark.org/CaptureFilters) diffère des [filtres d'affichage](https://wiki.wireshark.org/DisplayFilters) ) est supposée pour ce TP. Pour rappel, consulter [http://openmaniak.com/fr/wireshark.php]() ou les liens précédents qui mènent au [Wiki Wireshark](https://wiki.wireshark.org/).

#### Filtres intéressants Wireshark/Tshark

Sets a filter for any packet with 10.0.0.1, as either the source or dest  

```
ip.addr == 10.0.0.1 
```

sets a conversation filter between the two defined IP addresses 
 
```
ip.addr==10.0.0.1  && ip.addr==10.0.0.2
```

sets a filter to display all http and dns  

```
http or dns
```

sets a filter for any TCP packet with 4000 as a source or dest port

```
tcp.port==4000
```

TCP Syn

```
tcp.flags.syn==1
```

Displays all TCP resets

```
tcp.flags.reset==1
```

displays all HTTP GET requests

```
http.request
```

displays all TCP packets that contain the word ‘traffic’. Excellent when searching on a specific string or user ID

```
tcp contains traffic
```

masks out arp, icmp, dns, or whatever other protocols may be background noise. Allowing you to focus on the traffic of interest

```
!(arp or icmp or dns)
```

sets a filter for the HEX values of 0x33 0x27 0x58 at any offset

```
udp contains 33:27:58 
```

displays all retransmissions in the trace. Helps when tracking down slow application performance and packet loss

```
tcp.analysis.retransmission
```

Lister les conversations


```
tshark -r <pcapfile> -q -z conv,ip
tshark -r <pcapfile> -q -z conv,tcp -z conv,udp
```

Protocole hiérarchie

````
tshark -r <pcapfile> -q -z io,phs
````

Statistiques sur les retransmissions et fenetre TCP
```
tshark -r <pcapfile> -qz io,stat,60,"COUNT(tcp.analysis.retransmission)tcp.analysis.retransmission","MIN(tcp.window_size)tcp.window_size","MAX(tcp.window_size)tcp.window_size","AVG(tcp.window_size)tcp.window_size"
```

Statistiques sur les hosts présents dans la capture
````
tshark -r <pcapfile> -qz ip_hosts,tree
```

show HTTP Requests 
```
tshark -r <pcapfile> -R "tcp.port == 80 && (http.request || http.response)"  -T fields -E separator=, -E quote=d -e frame.time_epoch -e frame.number -e ip.src -e ip.dst  -e tcp.srcport -e tcp.dstport -e http.request.full_uri -e http.response.code
``` 
Ou

```
tshark -r <pcapfile> -qz http_req,tree
```
Répartition des codes HTTP

```
tshark -r <pcapfile>  -qz http,tree
```

DNS Analysis

```
tshark -r /tmp/dns.pcap -n -T fields -E separator=, -E quote=d -e frame.time_epoch -e frame.number -e frame.protocols -e ip.src -e ip.dst -e udp.srcport -e udp.dstport -e tcp.srcport -e tcp.dstport -e dns.time -e dns.id -e dns.response_in -e dns.response_to -e dns.flags. -e dns.qry.name -e dns.qry.type -e dns.qry.class
```

RTP Analysis

```
tshark -nr rtp.pcap -d udp.port==1-65535,rtp -T fields -e frame.number -e frame.time_epoch -e ip.src -e ip.dst -e ip.dsfield.dscp -e ip.proto -e udp.srcport -e udp.dstport -e rtp.timestamp -e rtp.seq -2 -E separator=";" -E header=y > rtp.csv
```

### Argus

#### Présentation
Argus (Audit Record Generation and Utilisation System) est un outil permettant de faire de l'audit de réseau IP.

Argus peut être utilisé selon deux modes :
  
* analyse à partir d'une trace réseau existante pour en dégager des flux 'anormaux'
* déploiement de sondes argus qui enregistrent le trafic, et exploitation des
données générées.

Les informations générées par Argus permettent notamment :  

* de diagnostiquer des problèmes réseau, par exemple de performances.
* d'aider à faire de la sécurité sur ses réseaux

Argus travaille au niveau flow mais n'est ni Netflow, ni IPFIX, autres standards connu de flow collection.

#### Fonctionnement de Argus 

Argus est composé de plusieurs programmes, dont le fonctionnement est
contrôlable par des fichiers de configuration et / ou par des options en ligne
de commande :

* le programme argus lit du trafic réseau (en écoutant sur le réseau, ou en
relisant une trace au format pcap) et génère des informations sur
les flux au format argus (génération de flow), soit sur le réseau, soit dans un fichier. 5
sorties différentes peuvent être précisées.

* les programmes ra* prennent en entrée des données au format argus, soit via
le réseau, soit en relisant un fichier au format argus, et produisent une
sortie au format ASCII.

Il est enfin possible de spécifier des filtres de type bpf pour chacun des
programmes composant argus.Bien que la syntaxe soit celle de bpf, des expressions propres à argus
sont disponibles pour faire des filtres sur les flux générés. 


#### argus

Les principales options de argus : 

-d : met argus en mode 'démon'  
-r <fichier> : pour qu'argus relise une trace générée par tcpdump / snoop  
-i <interface> : pour spécifier l'interface sur laquelle argus écoute  
-w <fichier> : pour enregistrer la sortie d'argus dans un fichier  
-P <port> : pour qu'argus écoute sur le port TCP <port>  

Quand l'option -P est utilisée, argus supporte TCP-Wrappers pour le contrôle
d'accès, et SASL pour l'authentification - le support de SASL doit cependant
être précisé au moment de la compilation.

Pour analyser un fichier pcap et le transformer il faut donc faire

```
argus -r <pcapfile> -w output.arg -mAJZR
```



#### ra*

Options communes aux programmes ra* :

-r : pour lire une trace au format argus  
-S <serveur> : pour spécifier un serveur argus et lire les données de ce serveur  
-P : pour spécifier le port du serveur argus  
-F <fichier> : pour spécifier un fichier de configuration  
-a : pour afficher un résumé par protocole à la fin de la sortie générée  
-c : pour afficher le nombre de paquets et le nombre d'octets d'un flux  
-g : pour afficher la durée d'un flux  
-n : pour supprimer la résolution dns  
-p <nombre> : fixe le nombre de décimales pour les dates à <nombre>  
-m : pour afficher les adresses MAC  
-w <fichier> : pour envoyer la sortie de ra* dans un fichier (par défaut la sortie se fait sur la sortie standard)  

Il est également possible de spécifier une plage de temps avec l'options -t : cette possibilité permet par exemple de se concentrer sur les flux quand il n'y a plus d'utilisateurs sur le réseau et ainsi être à même d'identifier plus facilement des flux qui n'ont pas lieu d'être.

Par exemple :  
    -t 02/12 pour les flux du 12 février  
    -t 14 pour les flux de 14 à 15 h chaque jour  
    -t 02/07.18 - 02/08.08 pour les flux de 18h le 7 février à 8h le 8 février   

Le "-" à la fin d'une commande ra* indique que le début du filtre.

##### Les principaux programmes ra\*

* ra : prend en entrée des données générées par argus, filtre et produit une sortie ASCII. 

* racluster : fait de l'aggrégation de flux à partir de données argus. 

* rasort : trie les données générées (le tri peut être multi-critères), et en
ressort des flux au format argus.

* ragraph: réalise des graphiques

* raxml : produit une sortie au format xml.

* rasplit, rastrip, ragrep: découpe, enlève des données ou recherche

* ratopf: live display
 

Les programmes ra* prennent également en entrée des données au format Cisco
Netflow.

Un exemple classique de ligne de commande :

```
argus -i ep0 -w - | ra -n -g -c -L 0 - 'ip and src net 192.70.106.0/24'
```

L'option -L 0 est utilisée pour afficher le nom des colonnes.


### Argus et la gestion des flux 

Un des points forts de Argus pour pouvoir mettre en évidence des anomalies sur
un réseau est sa notion de 'flux'.

Pour ICMP, Argus considère les adresses source et destination ainsi que le
type icmp, détaillé dans la sortie de Argus. Par exemple :

```
Start_Time        Duration   Type   SrcAddr    Sport  Dir       DstAddr  port  SrcPkt   Dstpkt    Response Information    State
14 Feb 02 13:33:39        0  icmp   192.168.3.75       <->     192.168.3.33       1        1         98           98        ECO
```

indique un flux icmp echo request de 192.168.3.75 vers 192.168.3.33. La colonne
'Dir' ainsi que la colonne 'Dstpkt' indiquent que 192.168.3.33 a bien répondu
avec un paquet echo reply.

Pour UDP, sont considérés les couples (adresse source, port source) et (adresse
destination, port destination) ainsi que l'état de la 'connexion' : 

INT pour indiquer une demande de connexion : un paquet UDP a été envoyé de
l'adresse source vers l'adresse destination.

ACC pour indiquer qu'il y a eu une réponse de la destination :

```
14 Feb 02 13:44:32        0   udp   192.168.3.75.1493  <->     192.168.2.99.53    1        1         66           121         ACC
```

Cette trace montre une interrogation DNS de 192.168.3.75 vers 192.168.2.99 et
sa réponse (de 121 octets)

CON pour indiquer qu'il y a une connexion établie avec échange de plusieurs
datagrammes UDP entre la source et la destination. Ici pour une synchronisation
NTP :

```
14 Feb 02 13:50:46        0   udp   192.168.3.75.123   <->     192.168.3.33.123   4        4         360          360         CON
```

Pour TCP, les mêmes couples que pour UDP sont bien entendu considérés, mais en tenant compte également des drapeaux TCP positionnés :

REQ indique une demande de connexion (bit SYN de la source vers la
destination).
EST indique que la session TCP est établie
CLO indique que la session TCP s'est terminée normalement, avec les échanges de
paquets ayant le bit FIN de positionné en fin de connexion.

L'avantage donc par rapport à tcpdump est la vision par "flow"

#### Utilisations de Argus

Argus peut trouver de multiples emplois en terme de sécurité.

Le premier est de permettre de synthétiser les flux circulants, pour apprendre à caractériser son réseau, connaitre les flux légitimes, et ainsi le cloisonner.

Cette synthèse permet également de mettre en évidence des flux non légitimes et / ou des règles de filtrage trop laxistes :

* trafic à des heures anormales, par exemple flux irc vers Internet ou nombreuses requêtes DNS émanant d'une station du réseau la nuit

* trafic vers des destinations 'anormales'

* trafic présentant des caractéristiques 'anormales', par exemple flux icmp avec des tailles de paquets importantes

Toutes ces anomalies peuvent être le signe d'une machine compromise.

Il est par ailleurs possible de mettre en évidence des scans lents, notamment en utilisant ra :
(L'option -G affiche l'heure de début et l'heure de fin du flux)


```
./ra -n -G -c -L 0 -R -r /data/trace3.arg
13 Feb 02 20:01:41  14 Feb 02 09:27:27  icmp      192.168.0.11        ->     172.16.3.33   	85 	0         5610         0           ECO
```
Ici, 85 datagrammes icmp (echo request) ont été émis par la source, de 20h01 le
13 février à 9h27 le 14 février). La destination n'a répondu à ces paquets.

```
13 Feb 02 18:47:47  14 Feb 02 09:22:57  icmp      192.168.22.68       <->     172.16.3.25       352      352       34496        34496       ECO
```

Ici, la destination a bien répondu des echo reply à chacun des echo request
envoyés par 192.168.22.68.

#### Exemples

Lister toutes les connections TCP

```
ra -r filename.arg - tcp
```

Statistiques sur le DNS

```
racount -r out.arg - udp port domain
```

Grapher la bande passante

```
ragraph bytes -M 10s -r out.arg  -title "Load" -w load.png
```

Par protocol et en séparant input/output

```
ragraph sbytes dbytes dport -M 10s -r out.arg  -title "Load" -w load.png
```

Graphe bande passant par IPs en IPV4

```
ragraph sbytes dbytes saddr -M 10s -r out.arg  -title "Load" -w load.png - "ipv4"
```

Nombre de transaction concurrentes

```
ragraph trans -M 10s -r out.arg -title 'Concurrent Transactions' -w transac.png
```

Top talkers par bytes sur port 80

```
racluster -M rmon -m proto sport -r out.arg -w - "port 80" | rasort -r - -m bytes | less
```

Top conversation

```
racluster -M matrix -r out.arg -w - | rasort -m bytes -  | head
```

Packet Loss (with IP address):

```
ragraph loss saddr daddr -M 10s -r argus.out - -title 'Packet Loss / IPs' -w ploss.png
```

Un graph complet avec rmon et pivot via daddr

```
ragraph sbytes dbytes daddr -M rmon -m daddr -M time 1s -r internet.arr -title "Load" -w load2.png -height 2750 -width 4000 - "ipv4"
```


Recherches sur les statuts TCP

```
ra -r file - syn and not ack
ra -r file - src syn and dst ack
ra -r file - src push and dst urg
```


#### Liens
Cette partie est reprise de : [http://www.hsc.fr/ressources/breves/backup/argus_fr.html]()  
Lire également:  
[http://www.cert.org/flocon/2010/presentations/Bullard_IntroductionToArgus.pdf
]()  
[http://nsmwiki.org/Argus]()  
[http://qosient.com/argus/presentations/Argus.FloCon.2014.Past.Present.Future.pdf]()  
[http://help.it.ox.ac.uk/sites/ithelp/files/resources/network_security_documents_itss-argus.pdf]()  
[http://qosient.com/argus/presentations/Argus.FloCon.2014.Metadata.Tutorial.pdf]()

### Snort

#### Introduction

Snort est un système de détection d'intrusions réseau en Open Source, capable d'effectuer l'analyse du trafic en temps réel. 

On l'utilise en général pour détecter une variété d'attaques et de scans  tels que des débordements de tampons, des scans de ports furtifs, des  attaques CGI, des scans SMB, des tentatives d'identification d'OS, et  bien plus. Snort permet d’analyser le trafic réseau, il peut être  configuré pour fonctionner en plusieurs modes : 

* Le mode sniffer : dans ce mode, SNORT lit les paquets circulant  sur le réseau et les affiche d’une façon continue sur l’écran 

* Le mode packet logger : dans ce mode SNORT journalise le trafic réseau dans des répertoires sur le disque.

* Le mode détecteur d’intrusion réseau (NIDS) : dans ce mode,  SNORT analyse le trafic du réseau, compare ce trafic à des  règles déjà définies par l’utilisateur et établi des actions à  exécuter. 

* Le mode Prévention des intrusions réseau (IPS) : c’est  SNORTinline

#### Les composants principaux de SNORT

```
                                         +---------+          +--------+
  Packets                                | Ruleset |          |Alert   |
   +                                     +----+----+          |Database|
   |                                          |               +---+----+
   |                                          |                   ^
   v                                          V                   |
+-------+          +----------+         +----------+        +-----+----+
|Packet +--------->|Pre-      +-------->|Detection +------->|Alert     +-----> Alerts
|Decoder|          |Processors|         |  Engine  |        |Generation|
+-------+          +----------+         +----------+        +----------+
```
##### Le décodeur de paquet 
 
Le décodeur de paquet récupère les paquets provenant de différents types d’interface réseau et le prépare pour les préprocesseurs ou le  moteur de détection

##### Les préprocesseurs
 
Les préprocesseurs sont des modules d’extension pour arranger ou modifier les paquets de données avant que le moteur de détection n’intervienne. Des exemples de préprocesseurs sont HTTP, RPC, etc. Certains préprocesseurs détectent aussi des anomalies dans les entêtes des paquets et génèrent alors des alertes.  Les préprocesseurs sont chargés et configurés en utilisant le mot clé préprocesseur. Le format de directive d'un préprocesseur dans une règle SNORT est de la forme:  	Préprocesseur \<name> : \<options>  Les différentes options propres à chaque préprocesseur sont données dans [le manuel](http://manual.snort.org/node17.html.).

##### Moteur de détectionLe moteur de détection de SNORT constitue le cœur de L’IDS. Il est responsable de détecter toute activité d’intrusion dans les flux de données. Il utilise des règles qui consistent en une définition d’un ensemble de critères sur le paquets. Si un paquet correspond a une règle, une action est réalisée (typiquement une alerte). 

##### Génération d'événements

Selon les décisions prises par le moteur de détection, les paquets peuvent être journalisés ou générer une alerte. La journalisation peut s’effectuer par de simples fichiers textes, des fichiers selon le format tcpdump, ou encore avec le format natif [Unified2](https://www.snort.org/faq/readme-unified2) de Snort. Ce format est maintenant la sortie par défaut de Snort. Unified2 est un format binaire qui comprend à la fois l'évenement (avec l'alerte, date, IPs, etc) et le paquet au format binaire pour analyse ultérieure.   
￼Les modules de sortie peuvent effectuer différents opérations selon la manière dont on désire sauvegarder les informations générées par le système de journalisations d’alertes :
* Enregistrement simple dans un fichier (comme /log/snort/alerts)* Envoyer des notifications d’événements SNMP* Enregistrer dans une base de données comme MySQL* Transformer dans un format XML* Envoyer des messages SMB (Server Message Block)...etc


#### Modes Sniffer et Packer Logger

Voici une courte introduction aux modes Sniffer et Packer Logger.

##### Mode Packet Sniffer :  

En mode Sniffer, une variété d'information sur le paquet peut être lue, comme l'en−tête TCP/IP :

```
$ ./snort −v
```

En sortie, nous aurons seulement l'en−tête IP/TCP/ICMP/UDP. Il y a de nombreuses options, seules quelques
unes seront mentionnées ici.

*  −d = va livrer le paquet de données
*  −e = montre le Data Link Layer
 
##### Mode Packet Logger :  
A la différence du mode Sniffer, le mode Packet Logger peut écrire les paquets sur le disque dur. Nous devons seulement assigner un répertoire dans lequel Snort peut les écrire et il va automatiquement passer en mode Packet Logger :

```
# repertoiredeloggin doit exister :
$ ./snort −dev −l ./repertoiredelogging
```

Lorsqu'on entre « −l », Snort récupère parfois l'adresse de l'ordinateur distant et l'utilise comme nom de
répertoire (dans lequel se trouvent les logs), d'autres fois, il prend l'adresse de l'hôte local. Pour noter le réseau maison (home network), nous devons spécifier ce réseau dans la ligne de commande :

```
$ ./snort −dev −l ./repertoiredelogging −h 192.168.1.0./24
```

Une autre possibilité est d'enregistrer en format TCPDUMP :

```
./snort −l ./repertoiredelogging −b
```

Maintenant, le paquet tout entier sera écrit, pas seulement des sections spécifiques ; cela élimine la nécessité de spécifier des commandes additionnelles. Il est possible d'utiliser des programmes comme tcpdump pour traduire les fichiers en texte ASCII mais Snort peut faire cela aussi :

```
$ ./snort −dv −r paquetaverifier.log
```

#### Mode Network Intrusion Detection : 

Pour basculer en mode NIDS:

```
$ ./snort −dev −l ./log −h 192.168.1.0/24 −c snort.conf
```

Dans ce cas, snort.conf est le fichier de configuration. Il est utilisé pour faire savoir à Snort où il peut trouver ses « règles » pour déterminer s'il y a une attaque ou pas, si la requête doit être permise...   
Le fichier snort.conf permet de configurer tous les composants (décodeurs, preprocesseurs, moteur, output) et est bien documenté.

Les règles, telles que définies dans snort.conf, seront alors appliquées au paquet pour l'analyser. Si aucun répertoire de sortie spécifique n'a été établi, le répertoire par défaut /var/log/snort est utilisé. Le résultat de sortie de Snort dépend du mode d'alerte.

Snort offre de nombreuses options ; si vous rencontrez un problème, entrez juste « snort −h » ou regardez dans les mailing lists si votre problème était apparu autre part. 

#### Règles

L'essentiel de l'intelligence de SNORT, c'est ses règles de détection. Ce sont en effet celles-ci qui vont définir la façon dont Snort doit se comporter.

Snort vient par défaut avec un petit lot de règles, disponibles sous /etc/snort/rules. Elles sont classées dans différents fichiers, chacun correspondant à un type de comportements/intrusions détectés. Si vous souhaitez en rajouter manuellement, vous pouvez le faire dans le fichier /etc/snort/rules/local.rules.

Si vous souhaitez rajouter des fichiers de règles, vous pouvez les placer dans ce dossier, puis ajouter une ligne à la fin de votre fichier de configuration (typiquement /etc/snort/snort.conf) pour lui demander d'inclure vos règles :

```
include $RULE_PATH/audit.rules
```

L'écriture de règles en détails ne va pas être détaillée, mais simplement présentée les grandes lignes du fonctionnement de celles-ci. Le meilleur moyen d'en apprendre plus est de lire le PDF de la doc officielle.

##### Variables

Dans Snort, vous pouvez définir des variables, qui s'utiliseront et serviront aux mêmes choses que les variables de n'importe quel langage de programmation.

On distingue 3 types de variables :

* Les variables IP
* Les variables port
* Les variables normales

Il existe tout d'abord des règles générales à propos des variables :

* on accède à une variable en préfixant son nom d'un $, et en mettant son nom (<var_name>) entre parenthèses (ou non) 
* lors de l'accès à une variable, si l'on est pas sûr qu'elle contient des données, on peut ajouter une valeur qui sera utilisée par défaut : $(<var_name>:-<valeur_par_default>) 
* si on souhaite afficher un message d'erreur plutôt que de remplacer par une valeur par défaut : $(<var_name>:?<message>)
* chaque variable peut contenir any, qui correspond à toutes les valeurs que peut contenir ce type
* elles peuvent contenir des négations : !$(<var_name>)

##### Adresses IP

Les variables IP sont définies de la façon suivante, le nom étant préfixé du mot clé ipvar, et peuvent contenir une IP, une liste d'IP, ou un bloc CIDR. On peut bien évidemment combiner le tout dans une seule variable.

ipvar IP_1 192.168.1.1
ipvar IP_LIST [192.168.1.1 , 192.168.1.2 , 192.168.1.3]
ipvar IP_CIDR [192.168.1.0/24]
ipvar IP_MIX [192.168.1.1, 10.100.1.0/24, ![8.8.8.8, 8.8.8.4]]

##### Ports

Les variables ports fonctionnent sensiblement de la même façon que les variables IP, à la différence qu'on les précède de portvar, et elles peuvent contenir un port, une liste de ports ou un intervalle de ports.

portvar PORT_1 80
portvar PORT_LIST [80,443]
portvar PORT_RANGE [80:100]
portvar PORT_MIX [80, 443, ![81:100]]

##### Variables "normales"

Enfin, les variables standard, commencant par var, contiennent tout et n'importe quoi, y compris des ports et des IP (cependant, ces 2 derniers cas ne sont conservés dans Snort que par compatibilité avec les précédentes releases et il est conseillé d'utiliser les 2 types mis à votre disposition plutôt que var).

var CONF_FILE /etc/snort/snort.conf
var HTTP_PORT 80
var SERV_IP 192.168.1.10

##### Écriture de règles

Abordons donc désormais en détail le coeur de Snort : ses règles, et la façon de les écrire.

Pour présenter une règle synthétiquement, disons qu'elle va exécuter une action, si elle trouve des paquets utlisant un protocole venant d'une IP et d'un port donnés, allant vers une IP et un port donnés, et que ces paquets correspondent à une liste de critères définis.

Les règles se présentent sous la forme suivante :

```
<action> <protocol> <ip_src> <port_src> <direction> <ip_dst> <port_dst> (<options>)
```

Avec :

* <action> : L'action à lever si un évènement est relevé : alert, log, pass, ... ;
* <protocol> : Le protocole utilisé : ip, tcp, udp ou icmp ;
* <ip_src> et <ip_dst> : Les adresses IP source et destination ;
* <port_src> et <port_dst> : Les ports source et destination ;
* <direction> : La direction de la règle : -> de A vers B, ou bien <> de A vers B et/ou de B vers A ;
* <options> : Puis, entre paranthèses, des options permettant de filtrer les paquets qui vont lever des évènements.

 

Avec tout ceci, et la doc officielle, vous pourrez désormais écrire toutes vos règles !
 

Les options sont à formater de la manière suivante :

* (key=value;key=value;key=value;)

Avec key étant le nom de l'option, et value la valeur que vous voulez qu'elle ait. Certaines options filtrent le payload du paquet (ie. le contenu qui est envoyé), d'autres filtres portent sur tout, sauf sur le payload, enfin, des options permettent de faciliter la lecture des logs ou la correlation des alertes.

La partie suivante va lister les différentes options qui sont intéressantes , accompagnées d'un court texte les présentant et d'un exemple.

 

* content : Doit être contenu dans le paquet. Exemple : content:"User-Agent: WhatWeb.0.4.8-dev";
* http_method : Placé directement un content, permet de préciser que le filtre content précédent ne s'applique qu'à la méthode HTTP employée.
* http_uri : Idem, mais avec l'URI HTTP.
* http_header : Idem, avec le contenu des headers HTTP.
* msg : Le message qui sera affiché dans les logs. Exemple : msg:"Scan avec WhatWeb";
* sid : L'identifiant de la règle. Exemple : sid:1337;
* pcre : Identique à content, mais avec des Expressions Régulières compatibles Perl (pcre). Exemple : ```pcre:"/GET\s*\/should\/not\/exists\.html/i";```
* flags : Valeur des flags TCP. Exemple : flags:"SA";
* flow : Définit le sens du traffic (depuis le client ou le serveur), si la connexion doit être établie, etc.... Exemple : flow:established, to_server;
* session : Permet d'afficher le contenu de toute une session TCP, pour par exemple loguer le contenu d'un échange telnet, ou ftp. Sa valeur permet de préciser ce qui doit être affiché (printable --> Contenu affiché, binary --> Données au format binaire, et all qui remplace les caractères non affichables par leur valeur hexadécimale). Exemple : session:printable;

Pour que vous puissiez voir un peu mieux à quoi ressemblent des règles snort, en voici quelques unes :

```
alert tcp any any -> $SERV_IP_TEST $HTTP_PORTS_TEST (msg:"AUDIT_TOOLS Possible Dirb Brute-Force attack";content:"GET";detection_filter:track by_src, count 5, seconds 1;flow:established,to_server;sid:9990005;)

alert tcp any any -> $SERV_IP_TEST $HTTP_PORTS_TEST (msg:"AUDIT_TOOLS DirBuster \"Fail Case\" test";content:"GET";http_method;content"/thereIsNoWayThat-You-CanBeThere/";http_uri;flow:established,to_server;sid:9990006;)
alert tcp any any -> $SERV_IP_TEST $HTTP_PORTS_TEST (msg:"AUDIT_TOOLS DirBuster User-Agent detected more than 5 times in 2 seconds";content:"Dir";pcre:"/^User-Agent\s*:\s*DirBuster/i";detection_filter:track by_src,count 5,seconds 2;sid:9990007;)

log tcp any any <> any 23 (session:printable;)
```
 
```
Et la sortie de Snort :

        --== Initialization Complete ==--

   ,,_     -*> Snort! <*-
  o"  )~   Version 2.9.2.2 IPv6 GRE (Build 121) 
   ''''    By Martin Roesch & The Snort Team: http://www.snort.org/snort/snort-team
           Copyright (C) 1998-2012 Sourcefire, Inc., et al.
           Using libpcap version 1.3.0
           Using PCRE version: 8.30 2012-02-04
           Using ZLIB version: 1.2.7

           Rules Engine: SF_SNORT_DETECTION_ENGINE  Version 1.15  <Build 18>
           Preprocessor Object: SF_SDF (IPV6)  Version 1.1  <Build 1>
           Preprocessor Object: SF_REPUTATION (IPV6)  Version 1.1  <Build 1>
           Preprocessor Object: SF_SMTP (IPV6)  Version 1.1  <Build 9>
           Preprocessor Object: SF_DNP3 (IPV6)  Version 1.1  <Build 1>
           Preprocessor Object: SF_SSH (IPV6)  Version 1.1  <Build 3>
           Preprocessor Object: SF_SIP (IPV6)  Version 1.1  <Build 1>
           Preprocessor Object: SF_POP (IPV6)  Version 1.0  <Build 1>
           Preprocessor Object: SF_GTP (IPV6)  Version 1.1  <Build 1>
           Preprocessor Object: SF_DNS (IPV6)  Version 1.1  <Build 4>
           Preprocessor Object: SF_DCERPC2 (IPV6)  Version 1.0  <Build 3>
           Preprocessor Object: SF_FTPTELNET (IPV6)  Version 1.2  <Build 13>
           Preprocessor Object: SF_MODBUS (IPV6)  Version 1.1  <Build 1>
           Preprocessor Object: SF_SSLPP (IPV6)  Version 1.1  <Build 4>
           Preprocessor Object: SF_IMAP (IPV6)  Version 1.0  <Build 1>
Commencing packet processing (pid=1656)
03/13-14:17:31.930128  [**] [1:9990006:0] AUDIT_TOOLS DirBuster "Fail Case" test [**] [Priority: 0] {TCP} 192.168.56.1:33302 -> 192.168.56.101:80
03/13-14:20:56.800271  [**] [1:9990008:0] AUDIT TOOLS SkipFish User-Agent detected more than 150 times in 60 seconds [**] [Priority: 0] {TCP} 192.168.56.1:53482 -> 192.168.56.101:80
```



### Utlisation de Snort

Pour scanner un PCAP à partir de Snort 2.9

```
snort --daq pcap --daq-mode read-file -r pcaps/q1.pcap -c /etc/nsm/templates/snort/snort.conf
```
 
Pour lire un fichier d'alerte unified2

```
u2spewfoo /var/log/snort/snort.unified2.*
``` 
 
#### Liens
[http://d2zmdbbm9feqrf.cloudfront.net/2014/usa/pdf/BRKSEC-2025.pdf]()
[http://repo.hackerzvoice.net/depot_madchat/reseau/ids%7Cnids/L'%E9criture%20de%20r%E8gles%20Snort.htm]()

### Bro

#### Introduction

Bro est un système de détection d’intrusion réseau (« Network Intrusion Detection System ») open source, disponible pour les systèmes d’exploitation de type Unix (dont Linux, FreeBSD et OpenBSD), qui analyse le trafic réseau à la recherche de toute activité suspecte (caractéristique d’une attaque ou d’une violation de la politique de sécurité en vigueur sur le réseau surveillé). 

Bro détecte les intrusions en trois étapes :  
* la première consiste à capter le trafic réseau et à décoder les différentes couches protocolaires (de manière à en extraire la sémantique applicative). Cette étape fournit des événements de « haut niveau » qui pourront par la suite être analysés ;* la seconde (réalisée au cours du déroulement de la première étape) consiste à vérifier la présence de motifs, qui constituent des signatures d’attaques, dans la charge des paquets IP (ou du flux TCP si le ré-assemblement de flux TCP est activé) ou de certains champs des protocoles applicatifs (par exemple, HTTP dans la version évaluée du produit). Des événements sont générés en cas de concordance ;* la troisième étape consiste à analyser les événements générés lors des deux étapes précédentes par des scripts d’analyse. Cette analyse permet à la fois la détection d’attaques connues au préalable (qui sont décrites en termes de signatures ou d’événements) et d’anomalies (par exemple, la présence de connexions de certains utilisateurs vers certains services ou l’occurrence de tentatives de connexions infructueuses).

Bro fournit des logs de connection par défaut lors de l'analyse d'un fichier ou d'un pcap mais sa force réside dans son language de programmation qui permet d'extraire et d'analyser du traffic réseau.

Nous allons nous concentrer sur les fonctionnalités par défaut sans se lancer dans l'écriture de script Bro.

#### Utilisation

Pour fournir un fichier pcap à analyser

```
bro -r monfichier.pcap
```

Bro écrira les fichiers de log dans le répertoire local.

Il est intéressant d'ajouter la configuration par défaut fournir par Security Onion dans /opt/bro/share/bro/site/local.bro en lancant Bro avec

```
bro -r monfichier.pcap local
```

##### Les logs

* conn.log
	
	Contient une entrée pour chaque connection vue avec des informations telles que le temps et la durée, l'IP source et destination, les services et ports, la taille et bien plus. Ce log est celui qui fournit une vue synthètique de l'activité réseau.

 * notice.log

 	Identifie les activités que Bro indentifie comme potentiellement intéressante, anormale or nuisible. EN language Bro, une activité de ce type est appelée "notice"
 	
Le reste des logs portent des noms identiquant relativement clairement le type d'information présente (http.log, dns.log)

Un résumé complet est disponible ici [http://gauss.ececs.uc.edu/Courses/c6055/pdf/bro_log_vars.pdf]() ou sur [https://www.bro.org/sphinx-git/script-reference/log-files.html]()

##### Exemples d'utilisation

Répartition du nombre de connections par services

```
bro-cut service < conn.log | sort | uniq -c | sort -rn
```

Avec les numéros de ports

```
bro-cut service id.resp_p < conn.log | awk '{print $2 }' | sort | uniq -c | sort -rn | head
```

TOP User Agents du traffic Web

```
cat http.log | bro-cut user_agent | sort | uniq -c | sort -rn
```
Et avec le mimetype

```
cat http.log | bro-cut user_agent resp_mime_types | sort | uniq -c | sort -n
```

Et nos statuts HTTP ?

```
cat http.log | bro-cut status_code | sort | uniq -c | sort -n
```
Connection avec des pertes de paquets

```
cat conn.log | bro-cut id.orig_h id.resp_h orig_bytes resp_bytes missed_bytes | awk '$5 > 10000
```

Hosts faisant de la résolution DNS

```
bro-cut id.resp_p id.orig_h id.orig_p < dns.log | awk '{ print $2}' | sort | uniq
```

Les 20 plus longues connections

```
bro-cut duration id.{orig,resp}_{h,p} < conn.log | sort -rn | head -n 20
```

Connection durant entre 1 et 2 minutes

```
bro-cut duration id.{orig,resp}_{h,p} < conn.log | awk '$1 >= 60 && $1 <= 120'
```

Extraire les fichiers du pcap

```
bro -r pcaps/q1.pcap  -C extract-all-files.bro
```

#### Liens

[https://www.bro.org/sphinx-git/index.html]()  
[https://www.bro.org/current/slides/broverview-2015.pdf]()
[http://matthias.vallentin.net/slides/berke1337-bro-intro.pdf]()
[http://matthias.vallentin.net/slides/bro-nf.pdf]()

## Utilisation

### Résumé
| Type              | Tools                    |
|:------------------|:------------------------:|
| Full Content      | tcpdump Wireshark/tshark |
| Extracted content | Xplico, Wireshark        |
| Session Data      | Argus                    |
| Transaction Data  | Bro, tshark              |
| Metadata          | Bro                      |
| Alert Data        | Snort, Bro               |

### Cas 1

````

``