#for i in $(cat /etc/hosts | grep 198.18 | cut -f 2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/sodadmin/ntp-4.2.6p5-2.el6.centos.x86_64.rpm $i:/home/sodadmin/ ; done;

#for i in $(cat /etc/hosts | grep 198.18 | cut -f 2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/sodadmin/ntpdate-4.2.6p5-2.el6.centos.x86_64.rpm $i:/home/sodadmin/ ; done;

for i in $(cat /etc/hosts | grep 198.18 | cut -f 2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/sodadmin/ntp_collectorfix.sh $i:/home/sodadmin/ ; done;

for i in $(cat /etc/hosts | grep 198.18 | cut -f 2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no $i /home/sodadmin/ntp_collectorfix.sh; done;

for i in $(cat /etc/hosts | grep 198.18 | cut -f 2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no $i /home/sodadmin/icservices.sh; done;

