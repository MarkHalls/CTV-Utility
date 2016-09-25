#!/bin/bash
#/usr/local/bin/sodRepo.sh
#Written by Mark Halls (mhalls@securityondemand.com)
#Last modified 11/6/2015

mkdir /etc/yum.repos.d/old
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/old

echo '[base]' >> /etc/yum.repos.d/SOD.repo
echo 'name=CentOS-$releasever - Base' >> /etc/yum.repos.d/SOD.repo
echo 'baseurl=ftp://169.254.3.56/centos/$releasever/os/$basearch/' >> /etc/yum.repos.d/SOD.repo
echo 'gpgcheck=1' >> /etc/yum.repos.d/SOD.repo
echo 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6' >> /etc/yum.repos.d/SOD.repo
echo '' >> /etc/yum.repos.d/SOD.repo
echo '#released updates ' >> /etc/yum.repos.d/SOD.repo
echo '[updates]' >> /etc/yum.repos.d/SOD.repo
echo 'name=CentOS-$releasever - Updates' >> /etc/yum.repos.d/SOD.repo
echo 'baseurl=ftp://169.254.3.56/centos/$releasever/updates/$basearch/' >> /etc/yum.repos.d/SOD.repo
echo 'gpgcheck=1' >> /etc/yum.repos.d/SOD.repo
echo 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6' >> /etc/yum.repos.d/SOD.repo
echo '' >> /etc/yum.repos.d/SOD.repo
echo '#additional packages that may be useful' >> /etc/yum.repos.d/SOD.repo
echo '[extras]' >> /etc/yum.repos.d/SOD.repo
echo 'name=CentOS-$releasever - Extras' >> /etc/yum.repos.d/SOD.repo
echo 'baseurl=ftp://169.254.3.56/centos/$releasever/extras/$basearch/' >> /etc/yum.repos.d/SOD.repo
echo 'gpgcheck=1' >> /etc/yum.repos.d/SOD.repo
echo 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6' >> /etc/yum.repos.d/SOD.repo
echo '' >> /etc/yum.repos.d/SOD.repo
echo '#additional packages that extend functionality of existing packages' >> /etc/yum.repos.d/SOD.repo
echo '[centosplus]' >> /etc/yum.repos.d/SOD.repo
echo 'name=CentOS-$releasever - Plus' >> /etc/yum.repos.d/SOD.repo
echo 'baseurl=ftp://169.254.3.56/centos/$releasever/centosplus/$basearch/' >> /etc/yum.repos.d/SOD.repo
echo 'gpgcheck=1' >> /etc/yum.repos.d/SOD.repo
echo 'enabled=0' >> /etc/yum.repos.d/SOD.repo
echo 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6' >> /etc/yum.repos.d/SOD.repo
echo '' >> /etc/yum.repos.d/SOD.repo
echo '#contrib - packages by Centos Users' >> /etc/yum.repos.d/SOD.repo
echo '[contrib]' >> /etc/yum.repos.d/SOD.repo
echo 'name=CentOS-$releasever - Contrib' >> /etc/yum.repos.d/SOD.repo
echo 'baseurl=ftp://169.254.3.56/centos/$releasever/contrib/$basearch/' >> /etc/yum.repos.d/SOD.repo
echo 'gpgcheck=1' >> /etc/yum.repos.d/SOD.repo
echo 'enabled=0' >> /etc/yum.repos.d/SOD.repo
echo 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6' >> /etc/yum.repos.d/SOD.repo
echo '[rsyslog_v8]' >> /etc/yum.repos.d/SOD.repo
echo 'name=Adiscon CentOS-$releasever - local packages for $basearch' >> /etc/yum.repos.d/SOD.repo
echo 'baseurl=ftp://169.254.3.56/rsyslog/v8-stable/epel-$releasever/$basearch' >> /etc/yum.repos.d/SOD.repo
echo 'enabled=1' >> /etc/yum.repos.d/SOD.repo
echo 'gpgcheck=0' >> /etc/yum.repos.d/SOD.repo
echo 'gpgkey=http://rpms.adiscon.com/RPM-GPG-KEY-Adiscon' >> /etc/yum.repos.d/SOD.repo
echo 'protect=1' >> /etc/yum.repos.d/SOD.repo

sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf
