echo '169.254.1.15     sodbigfix1     sodbigfix1.securityondemand.com' >> /etc/hosts
rpm -ivh /Source/BigFix/BESAgent-8.2.1310.0-rhe5.x86_64.rpm
cp /Source/BigFix/actionsite.afxm /etc/opt/BESClient/
/etc/init.d/besclient start
chkconfig besclient on 
