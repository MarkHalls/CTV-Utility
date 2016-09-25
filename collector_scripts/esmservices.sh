[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"
function start {
SERVICE1='/opt/McAfee/siem/siem_collector'
date | tee -a /var/log/icprocess.log
echo "The ESM process is being restarted." | tee -a /var/log/icprocess.log
if ps ax| grep -v grep| grep $SERVICE1 > /dev/null; then
        echo "$SERVICE1 service is running, shutting down." | tee -a /var/log/icprocess.log
        /etc/init.d/syslog-ng stop
	checktc1
        /etc/init.d/mcafee_siem_collector stop
        checktc2
        echo "ESM process stopped successfully" | tee -a /var/log/icprocess.log
        echo "Restarting services" | tee -a /var/log/icprocess.log
        service ic-collector start
        echo "Services started successfully" | tee -a /var/log/icprocess.log
else
date | tee -a /var/log/icprocess.log
        echo "Services are not running" | tee -a /var/log/icprocess.log
        echo "Restarting services" | tee -a /var/log/tcprocess.log
        service ic-collector start
        echo "Services started successfully" | tee -a /var/log/icprocess.log
fi
}

function checktc {   #sleeps the script until java has finished shutting down
        hostname
		ifconfig | grep -a1 tun | grep ine
		date
        echo 'Java PID'
		ps aux | grep -v grep | grep $SERVICE1  | awk '{print $2}'
        if ps ax| grep -v grep| grep $SERVICE1 > /dev/null; then
        sleep 5
        checktc

fi
}
start
echo $(date) $(hostname) $(ifconfig tun0 | grep ine| cut -d: -f2 |  awk '{ print $1}') Collector services were restarted. >> /var/log/icprocess.log
echo done
 
