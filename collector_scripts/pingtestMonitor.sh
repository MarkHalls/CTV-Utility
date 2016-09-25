#!/bin/bash
# pintestMonitor.sh
# Version 2.0 This does not check any tunnel status relationship between parent and child collectors.
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

function pingtest {
   utility=169.254.3.47
   ping -c 5 $utility> pingtest
   pingStatus=$(tail -n 2 pingtest | grep ' 0%')
   if [ -z "$pingStatus" ]; then
      utility=169.254.0.10
      ping -c 5 $utility> pingtest
      pingStatus=$(tail -n 2 pingtest | grep ' 0%')
      if [ -z "$pingStatus" ]; then
         if [ $failcount -ge "4" ]; then
            echo $(date) $(hostname) "SOD Tunnel could not be restarted. Rebooting." >> /var/log/icprocess.log
            shutdown -r now
            exit
         fi
         killall -e -r SOD_.*
         #check to make sure processes have been killed
         ded=$(ps aux | grep 'SOD_.*')
         if [ ! -z "$ded" ]; then
            # If processes are not dead, kill immediately.
            killall -s SIGKILL -e -r SOD_.*
         fi
         service rma-startup start
         failcount=$((failcount + 1))
         echo $(date) $(hostname) "Executed killall -e -r SOD_.* Attempt: "$failcount >> /var/log/icprocess.log
      else
         failcount=0
      fi
   else
      failcount=0
   fi
}

service rma-startup start
sleep 60

#set pingtestMonitor to run at boot
monitor=$(cat /etc/rc.d/rc.local | grep pingtestMonitor.sh)
if [ -z "$monitor" ]; then
   echo '/usr/bin/pingtestMonitor.sh &' >> /etc/rc.d/rc.local
fi

service ntpd stop
ntpdate 169.254.0.10
service ntpd start

failcount=0

while true; do
   pingtest
   sleep 900
done
 
