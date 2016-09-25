echo #!/bin/sh
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"
service ntpd stop
rpm -i /home/sodadmin/ntpdate-4.2.6p5-2.el6.centos.x86_64.rpm
rpm -i /home/sodadmin/ntp-4.2.6p5-2.el6.centos.x86_64.rpm
echo "driftfile /var/lib/ntp/drift" > /etc/ntp.conf
echo "restrict default ignore" >> /etc/ntp.conf
echo "restrict -6 default ignore" >> /etc/ntp.conf
echo "restrict 127.0.0.1" >> /etc/ntp.conf
echo "server  169.254.0.10 iburst" >> /etc/ntp.conf
echo "restrict 169.254.0.10 mask 255.255.255.255" >> /etc/ntp.conf
echo "server  169.254.0.11 iburst" >> /etc/ntp.conf
echo "restrict 169.254.0.11 mask 255.255.255.255" >> /etc/ntp.conf
echo "server  127.127.1.0 # local clock" >> /etc/ntp.conf
echo "fudge   127.127.1.0 stratum 10" >> /etc/ntp.conf
echo "includefile /etc/ntp/crypto/pw" >> /etc/ntp.conf
echo "keys /etc/ntp/keys" >> /etc/ntp.conf
ntpdate 169.254.0.10
chkconfig ntpd on
service ntpd start
