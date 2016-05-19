#!/bin/bash

yum -y install wget git unzip
cd /etc/yum.repos.d/
wget http://download.opensuse.org/repositories/network:bro/CentOS_7/network:bro.repo
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

cd
yum install -y wireshark argus argus argus-clients bro tcpdump perl-libwww-perl perl-Crypt-SSLeay perl-Archive-Tar perl-Sys-Syslog perl-LWP-Protocol-https https://www.snort.org/downloads/snort/daq-2.0.6-1.centos7.x86_64.rpm https://www.snort.org/downloads/snort/snort-2.9.8.2-1.centos7.x86_64.rpm

git clone https://github.com/shirkdog/pulledpork.git
cp pulledpork/pulledpork.pl /usr/local/bin/
chmod +x /usr/local/bin/pulledpork.pl
cp -v pulledpork/etc/*.conf /etc/snort/

mkdir /etc/snort/rules/iplists
touch /etc/snort/rules/black_list.rules
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

echo "export PATH=/opt/bro/bin:$PATH" >> /etc/profile
ln -s /usr/bin/rabins /usr/local/bin/rabins
pulledpork.pl  -c /etc/snort/pulledpork.conf
