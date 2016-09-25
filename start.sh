#!/bin/bash
#/home/utitities_MH/root/start.sh
# Written by Mark Halls (mhalls@securityondemand.com)
# Last update 11/12/15

echo off
function menu {
for i in {1..3}; do echo ' ' >> /home/log/$(whoami).log; done;
echo ""
echo "           ------------------------------------"
echo "                Linux Management Server v3.5"
echo "           ------------------------------------"
echo ""
echo "      0. Exit "
echo "      1. SSH by ClientID"
echo "      2. SCP a File"
#echo "      3. SSH by SOD System"                               #not implemented yet
echo "      4. Push ctvutility collector scripts"
echo "          (warning, this will update all collectors, ETC 15 minutes)"
echo "      5. Check Collector Online"
echo "      6. Restart Logmatrix services"
echo "      7. Check All Collector script logs"
echo "      8. Restart SOD collector services by ClientID (killall -r SOD*)"
echo "      9. Add Collector to this System"
#echo "     10. Add SOD Server to this System"
echo "      11. View User Logs"
echo "      12. Fix NTP by Client"
echo "      13. Deploy BigFix"
echo "      14. Restart Hostmon Service on all Clients"
echo "      15. Check date on all collectors"
echo "      16. Reboot All Collectors"
echo "      17. Run Yum Update on all collectors"
echo ""
echo "      000. Change Password"
echo "      001. Add User to CTVUtility"
#echo "      100. Threat Center Admin Tools"             #not implemented yet

read -p "     Select Option: " option
if [[ $option = "0" ]]; then
        exit
elif [[ $option = "000" ]]; then
        passwd
        menu
elif [[ $option = "001" ]]; then
                user=$(whoami)
                [ "$(whoami)" != "root" ] && echo "error not root" && menu
                read -p "Enter New User ID: " ooga
                useradd $ooga
                passwd $ooga
                touch /home/log/$ooga.log
                chown $ooga:sodadmin /home/log/$ooga.log
                cp -R /home/root/.ssh /home/$ooga/
                chown -R $ooga:root /home/$ooga/.ssh

                sed -i "s?/home/$ooga:/bin/bash?/home/$ooga:/home/utilities_MH/root/start.sh?g" /etc/passwd
                usermod -aG sodadmin $ooga
        menu
elif [[ $option = "1" ]]; then
        clientssh
        menu
elif [[ $option = "2" ]]; then
        clientscp
        menu
elif [[ $option = "3" ]]; then
        sodssh
        menu
elif [[ $option = "4" ]]; then
        read -p "Are you sure you want to push the scripts??? (Y/N): " verify
        if [ $verify = "y" ] || [ $verify = "Y" ]; then
                deploy_scripts
                menu
        else
                clear
                menu
        fi
elif [[ $option = "5" ]]; then
        check_online
        menu
elif [[ $option = "6" ]]; then
        icservicesClient
        menu
elif [[ $option = "7" ]]; then
        checkIClog
        menu
elif [[ $option = "8" ]]; then
        killallSOD
        menu
elif [[ $option = "9" ]]; then
        addCollector
        menu
elif [[ $option = "10" ]]; then
        addSODServer
        menu
elif [[ $option = "11" ]]; then
        userLogs
        menu
elif [[ $option = "12" ]]; then
        fixNTP
        menu
elif [[ $option = "13" ]]; then
        deployBigfix
        menu
elif [[ $option = "14" ]]; then
                rmaRestart
                menu
elif [[ $option = "15" ]]; then
                checkDate
                menu
elif [[ $option = "16" ]]; then
        read -p "Are you sure you want to reboot the collectors??? (Y/N): " verify
        if [ $verify = "y" ] || [ $verify = "Y" ]; then
                for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i 'reboot'| tee -a /home/log/$(whoami).log & done;
                menu
        else
                clear
                menu
        fi
elif [[ $option = "17" ]]; then
                yumUpdate
                menu
elif [[ $option = "100" ]]; then
        menu

elif [[ $option = "101" ]]; then
                rebuild_etcHosts
                menu
else
        menu
fi
}


function clientssh {
ls /clients
echo ' '
read -p "Enter a client ID from above, you will be logged into the collector in order. If the collector you log into is not the correct machine type 'exit' and it will log you into the next on the list: " ID
for i in $(cat /etc/hosts | grep $ID | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i| tee -a /home/log/$(whoami).log; done;

clear
menu
}

function deploy_scripts {

#for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/sodadmin/ntp-4.2.6p5-2.el6.centos.x86_64.rpm root@$i:/home/sodadmin/  && echo 'ntp-4.2.6p5-2.el6.centos.x86_64.rpm scp success!'| tee -a /home/log/$(whoami).log & done;
#for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/sodadmin/ntpdate-4.2.6p5-2.el6.centos.x86_64.rpm root@$i:/home/sodadmin/  && echo 'ntpdate-4.2.6p5-2.el6.centos.x86_64.rpm scp success!'| tee -a /home/log/$(whoami).log & done;
#for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/sodadmin/ntp_collectorfix.sh root@$i:/home/sodadmin/  && echo 'ntp_collectorfix.sh scp success!'| tee -a /home/log/$(whoami).log & done;
#for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i /home/sodadmin/ntp_collectorfix.sh| tee -a /home/log/$(whoami).log & done;
#for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i /home/sodadmin/icservices.sh| tee -a /home/log/$(whoami).log & done;


#SCP /home/utilities_MH/root/collector_scripts/icservices.sh
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/icservices.sh root@$i:/usr/bin && echo 'icservices.sh scp success!' $(grep $i /etc/hosts)| tee -a /home/log/$(whoami).log & done;

#SCP /home/utilities_MH/root/collector_scripts/output.sh
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/output.sh root@$i:/usr/bin  && echo 'output.sh scp success!' $(grep $i /etc/hosts)| tee -a /home/log/$(whoami).log & done;

#SCP /home/utilities_MH/root/collector_scripts/collector.log.0.sh
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/collector.log.0.sh root@$i:/usr/bin  && echo 'collector.log.0.sh scp success!' $(grep $i /etc/hosts)| tee -a /home/log/$(whoami).log & done;

#SCP /home/utilities_MH/root/collector_scripts/unmatched.sh
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/unmatched.sh root@$i:/usr/bin  && echo 'unmatched.sh scp success!' $(grep $i /etc/hosts)| tee -a /home/log/$(whoami).log & done;

#SCP /home/utilities_MH/root/collector_scripts/motd
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/motd root@$i:/etc/  && echo 'motd scp success!' $(grep $i /etc/hosts)| tee -a /home/log/$(whoami).log & done;

#kill icservicesMonitor.sh
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i 'pkill -f icservicesMonitor.sh'| tee -a /home/log/$(whoami).log; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/icservicesMonitor.sh root@$i:/usr/bin  && echo 'icservicesMonitor.sh scp success!' $(grep $i /etc/hosts)| tee -a /home/log/$(whoami).log; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i 'nohup /usr/bin/icservicesMonitor.sh > foo.out 2> foo.err < /dev/null &' | tee -a /home/log/$(whoami).log & done;

#kill pingtestMonitor.sh
#scp pingtestMonitor
#set pingtestMonitor to run at boot
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i 'pkill -f pingtestMonitor.sh'| tee -a /home/log/$(whoami).log & scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/pingtestMonitor.sh root@$i:/usr/bin  && echo 'pingtestMonitor.sh scp success!' $(grep $i /etc/hosts)| tee -a /home/log/$(whoami).log && ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i 'nohup /usr/bin/pingtestMonitor.sh > foo.out 2> foo.err < /dev/null &' | tee -a /home/log/$(whoami).log & ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i 'touch /root/pingtest && touch /root/foo.out && touch foo.err && chmod 666 /root/pingtest && chmod 666 /root/foo.out && chmod 666 /root/foo.err' | tee -a /home/log/$(whoami).log & done;

#scp cpMonitor.sh
#set cpMonitor.sh to run in cron
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/cpMonitor.sh root@$i:/usr/local/bin && echo 'cpMonitor.sh scp success!' && ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i '/usr/local/bin/cpMonitor.sh'& done;

#kill logHealthMonitor.sh
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i 'pkill -f logHealthMonitor.sh'| tee -a /home/log/$(whoami).log; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/logHealthMonitor.sh root@$i:/usr/bin  && echo 'logHealthMonitor.sh scp success!' $(grep $i /etc/hosts)| tee -a /home/log/$(whoami).log; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i 'nohup /usr/bin/logHealthMonitor.sh > foo.out 2> foo.err < /dev/null &' | tee -a /home/log/$(whoami).log & done;

#scp logHealthMonitor.sh
#set logHealthMonitor.sh to run at boot
#for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2); do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/logHealthMonitor.sh root@$i:/usr/bin && echo 'logHealthMonitor.sh scp success!' && ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i '/usr/bin/logHealthMonitor.sh' & done;

#scp sodRepo.sh
#run sodRepo.sh
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2); do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/sodRepo.sh root@$i:/usr/bin && echo 'sodRepo.sh scp success!' && ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i '/usr/bin/sodRepo.sh' & done;

#fix email
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2); do grep $i /etc/hosts;ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$ipaddress 'sed -i -e "0,/#mydomain/s//mydomain = ctv.local\n&/" -e "0,/#myhostname/s//myhostname = $HOSTNAME.ctv.local\n&/" -e "0,/#relayhost/s//relayhost = relay.securityondemand.com\n&/" /etc/postfix/main.cf '| tee -a /home/log/$(whoami).log & done;
}


function check_online {
ls /clients
echo ' '
read -p "Enter a client ID from above, blank returns to menu: " ID
for i in $(cat /etc/hosts | grep $ID | cut -d ' ' -f2);do ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i echo $i' online' | tee -a /home/log/$(whoami).log; done;

menu
}

function icservicesClient {
ls /clients
echo ' '
read -p "Enter a client ID from above, blank restarts on all clients, q quits: " ID
if [ $ID = "q" ]; then
        menu
elif [[ -z "$ID" ]]; then
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i /usr/bin/icservices.sh| tee -a /home/log/$(whoami).log & done;
else
for i in $(cat /etc/hosts | grep $ID | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i /usr/bin/icservices.sh| tee -a /home/log/$(whoami).log & done;
fi
}

function killallSOD {
ls /clients
echo ' '
read -p "Enter a client ID from above: " ID
for i in $(cat /etc/hosts | grep $ID | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i killall -r SOD*| tee -a /home/log/$(whoami).log & done;
}

function clientscp {
ls /clients
echo ' '
read -p "Enter a client ID from above, leave blank to scp to all clients, 'q' to quit: " ID
read -p "Enter path of file you want to scp: " filename
read -p "Enter destination location, leave blank for /root: " destlocal
if [ $ID = "q" ]; then
        menu
elif [[ -z "$ID" ]]; then
        if [[ -z "$filename" ]]; then
                menu
        elif [[ -z "$destlocal" ]]; then
                for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no $filename root@$i:/root/ | tee -a /home/log/$(whoami).log & done;
        else
                for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no $filename root@$i:$destlocal | tee -a /home/log/$(whoami).log & done;
        fi
elif [[ -z "$filename" ]]; then
        menu
elif [[ -z "$destlocal" ]]; then
        for i in $(cat /etc/hosts | grep $ID | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no $filename root@$i:/root/ | tee -a /home/log/$(whoami).log & done;
else
        for i in $(cat /etc/hosts | grep $ID | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no $filename root@$i:$destlocal | tee -a /home/log/$(whoami).log & done;
        menu
fi
}

function addCollector {
read -p "Enter Collector Name: " name
read -p "Enter Tunnel IP Address: " ipaddress
echo $ipaddress" "$name" "$name".ctv.local" >> /etc/hosts_collectors
rebuild_etcHosts
for i in $(cat /etc/hosts | grep 198. | cut -f2 | cut -d '-' -f2 | cut -d ' ' -f1); do mkdir -p -v /clients/$i| tee -a /home/log/$(whoami).log; done;

#SCP /home/utilities_MH/root/collector_scripts/icservices.sh
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/icservices.sh root@$ipaddress:/usr/bin && echo 'icservices.sh scp success!' $(grep $ipaddress /etc/hosts)| tee -a /home/log/$(whoami).log
#SCP /home/utilities_MH/root/collector_scripts/output.sh
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/output.sh root@$ipaddress:/usr/bin  && echo 'output.sh scp success!' $(grep $ipaddress /etc/hosts)| tee -a /home/log/$(whoami).log
#SCP /home/utilities_MH/root/collector_scripts/collector.log.0.sh
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/collector.log.0.sh root@$ipaddress:/usr/bin  && echo 'collector.log.0.sh scp success!' $(grep $ipaddress /etc/hosts)| tee -a /home/log/$(whoami).log
#SCP /home/utilities_MH/root/collector_scripts/unmatched.sh
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/unmatched.sh root@$ipaddress:/usr/bin  && echo 'unmatched.sh scp success!' $(grep $ipaddress /etc/hosts)| tee -a /home/log/$(whoami).log
#SCP /home/utilities_MH/root/collector_scripts/motd
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/motd root@$ipaddress:/etc/  && echo 'motd scp success!' $(grep $ipaddress /etc/hosts)| tee -a /home/log/$(whoami).log
#SCP /home/utilities_MH/root/collector_scripts/icservicesMonitor.sh
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/icservicesMonitor.sh root@$ipaddress:/usr/bin  && echo 'icservicesMonitor.sh scp success!' $(grep $ipaddress /etc/hosts)| tee -a /home/log/$(whoami).log
#set icservicesMonitor to run at boot
ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$ipaddress 'nohup /usr/bin/icservicesMonitor.sh > foo.out 2> foo.err < /dev/null &' | tee -a /home/log/$(whoami).log
#SCP /home/utilities_MH/root/collector_scripts/pingtestMonitor.sh
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/pingtestMonitor.sh root@$ipaddress:/usr/bin  && echo 'pingtestMonitor.sh scp success!' $(grep $ipaddress /etc/hosts)| tee -a /home/log/$(whoami).log
#set pingtestMonitor to run at boot
ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$ipaddress 'nohup /usr/bin/pingtestMonitor.sh > foo.out 2> foo.err < /dev/null &' | tee -a /home/log/$(whoami).log

#fixntp
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/ntp-4.2.6p5-2.el6.centos.x86_64.rpm root@$ipaddress:/home/sodadmin/  && echo 'ntp-4.2.6p5-2.el6.centos.x86_64.rpm scp success!'| tee -a /home/log/$(whoami).log
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/ntpdate-4.2.6p5-2.el6.centos.x86_64.rpm root@$ipaddress:/home/sodadmin/  && echo 'ntpdate-4.2.6p5-2.el6.centos.x86_64.rpm scp success!'| tee -a /home/log/$(whoami).log
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/ntp_collectorfix.sh root@$ipaddress:/home/sodadmin/  && echo 'ntp_collectorfix.sh scp success!'| tee -a /home/log/$(whoami).log
ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$ipaddress /home/sodadmin/ntp_collectorfix.sh| tee -a /home/log/$(whoami).log
ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$ipaddress /usr/bin/icservices.sh| tee -a /home/log/$(whoami).log

#deploy Bigfix
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/BigFix_Install.sh root@$ipaddress:/Source/BigFix/  && echo 'BigFix_Install.sh scp success!'| tee -a /home/log/$(whoami).log
ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$ipaddress /Source/BigFix/BigFix_Install.sh| tee -a /home/log/$(whoami).log

#fix email
ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$ipaddress 'sed -i -e "0,/#mydomain/s//mydomain = ctv.local\n&/" -e "0,/#myhostname/s//myhostname = $HOSTNAME.ctv.local\n&/" -e "0,/#relayhost/s//relayhost = relay.securityondemand.com\n&/" /etc/postfix/main.cf '| tee -a /home/log/$(whoami).log

#scp cpMonitor.sh
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/cpMonitor.sh root@$ipaddress:/usr/local/bin  && echo 'cpMonitor.sh scp success!' && ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$ipaddress '/usr/loca/bin/cpMonitor.sh'| tee -a /home/log/$(whoami).log

#scp logHealthMonitor.sh
#set logHealthMonitor to run at boot
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/logHealthMonitor.sh root@$ipaddress:/usr/bin && echo 'logHealthMonitor.sh scp success!' && ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$ipaddress '/usr/bin/logHealthMonitor.sh'

#scp sodRepo.sh
#run sodRepo.sh
scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/sodRepo.sh root@$ipaddress:/usr/bin && echo 'sodRepo.sh scp success!' && ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$ipaddress '/usr/bin/sodRepo.sh'
}

function addSODServer {
read -p "Enter Collector Name: " name
read -p "Enter Tunnel IP Address: " ipaddress
read -p "Enter Domain in the form of domain.local: " domain
echo $ipaddress"        "$name" "$name"."$domain >> /etc/hosts_sodservers
rebuild_etcHosts
for i in $(cat /etc/hosts | grep sod | cut -f2 | cut -d '-' -f2 | cut -d ' ' -f1); do mkdir -p -v /clients/sod/$i| tee -a /home/log/$(whoami).log; done;

}

function rebuild_etcHosts {
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo ' ' >> /etc/hosts
cat /etc/hosts_collectors >> /etc/hosts
cat /etc/hosts_sodservers >> /etc/hosts

}

function checkIClog {
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i tail -n 1 /var/log/icprocess.log| tee -a /home/log/$(whoami).log & done;
}

function userLogs {
ls /home/log/
read -p "Enter the filename of the log you would like to see: " user
read -p "Enter a search term (leave blank to output entire log): " search
if [[ -z "$search" ]]; then
cat /home/log/$user

else
cat /home/log/$user | grep $search
fi
}

function fixNTP {
ls /clients
echo ' '
read -p "Enter a client ID from above, blank returns to menu: " ID
for i in $(cat /etc/hosts | grep $ID | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/ntp-4.2.6p5-2.el6.centos.x86_64.rpm root@$i:/home/sodadmin/  && echo 'ntp-4.2.6p5-2.el6.centos.x86_64.rpm scp success!'| tee -a /home/log/$(whoami).log; done;
for i in $(cat /etc/hosts | grep $ID | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/ntpdate-4.2.6p5-2.el6.centos.x86_64.rpm root@$i:/home/sodadmin/  && echo 'ntpdate-4.2.6p5-2.el6.centos.x86_64.rpm scp success!'| tee -a /home/log/$(whoami).log; done;
for i in $(cat /etc/hosts | grep $ID | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/ntp_collectorfix.sh root@$i:/home/sodadmin/  && echo 'ntp_collectorfix.sh scp success!'| tee -a /home/log/$(whoami).log; done;
for i in $(cat /etc/hosts | grep $ID | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i /home/sodadmin/ntp_collectorfix.sh| tee -a /home/log/$(whoami).log; done;
for i in $(cat /etc/hosts | grep $ID | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i /usr/bin/icservices.sh| tee -a /home/log/$(whoami).log; done;
}

function deployBigfix {
ls /clients
echo ' '
read -p "Enter a client ID from above, blank returns to menu: " ID
for i in $(cat /etc/hosts | grep $ID | cut -d ' ' -f2);do grep $i /etc/hosts; scp -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no /home/utilities_MH/root/collector_scripts/BigFix_Install.sh root@$i:/Source/BigFix/  && echo 'BigFix_Install.sh scp success!'| tee -a /home/log/$(whoami).log; done;
for i in $(cat /etc/hosts | grep $ID | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i /Source/BigFix/BigFix_Install.sh| tee -a /home/log/$(whoami).log; done;
}

function rmaRestart {
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i 'service rma-startup stop' ;  ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i 'service rma-startup start' ; done;
}

function checkDate {
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i echo '$(date) $(hostname)'| tee -a /home/log/$(whoami).log & done;
}

function yumUpdate {
for i in $(cat /etc/hosts | grep 198. | cut -d ' ' -f2);do grep $i /etc/hosts; ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no root@$i 'yum -y update' | tee -a /home/log/$(whoami).log & done;


}

#Start the script
menu

