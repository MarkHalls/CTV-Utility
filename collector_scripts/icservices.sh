[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"
function start {
SERVICE1='/opt/open/jre/bin/java'
date | tee -a /var/log/icprocess.log
echo "The ic-collector process is being restarted." | tee -a /var/log/icprocess.log
if ps ax| grep -v grep| grep $SERVICE1 > /dev/null; then
        echo "$SERVICE1 service is running, shutting down." | tee -a /var/log/icprocess.log
        service ic-collector stop
        checktc
        echo "java process stopped successfully" | tee -a /var/log/icprocess.log
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
		newdate=$(date +%s)
		difDate=$[$newdate-$firstdate]
		if [ "$difDate" -gt 300 ]; then
		kill $(ps aux | grep -v grep | grep $SERVICE1  | awk '{print $2}')
		fi
        sleep 5
        checktc

fi
}



firstdate=$(date +%s)


start
echo $(date) $(hostname) $(ifconfig tun0 | grep ine| cut -d: -f2 |  awk '{ print $1}') Collector services were restarted. >> /var/log/icprocess.log
echo done
