#!/bin/sh
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"
function check_icservice {
if ps ax| grep -v grep| grep '/opt/open/jre/bin/java' > /dev/null; then

        curdate=$(date +%s)
        modDate=$(stat --printf="%Y" $(ls -tr $(find /opt/open/stm/slm/output/ -type f)|tail -n 1) )
        difDate=$[$curdate-$modDate]
        minutes=60
        sinceLast=$[$difDate/$minutes]
        if [ $sinceLast -ge $interval ]; then
        /usr/bin/icservices.sh
        sleep 900
#        check_icservice

        elif [ $difDate -lt -1 ]; then
       /usr/bin/icservices.sh
        sleep 900
#        check_icservice

        else
        sleep 30
#        check_icservice
        fi
else
sleep 30
#check_icservice
fi
}
#set icservicesMonitor to run at boot
icMonitor=$(cat /etc/rc.d/rc.local | grep icservicesMonitor.sh)
if [ -z "$icMonitor" ]; then
echo '/usr/bin/icservicesMonitor.sh > /dev/null 2>&1 &' >> /etc/rc.d/rc.local
fi
interval=$(cat /root/.restartinterval)
while true; do
check_icservice
done
 
