#!/bin/bash
#logChecker.sh
#Monitors collector.log.0 and emails any SEVERE messages
#Written by Mark Halls (mhalls@securityondemand.com)
#Last updated on 11/6/15
while [ -d '/opt/open/stm/log/' ];do
startdate=$(date +%s)
tail -f /opt/open/stm/log/collector.log.0 | while read LINE;do
case $LINE in
#        "SEVERE"*timestamp*)
#			echo $(date) $LINE >> /root/error.log
 #           echo $(date) $LINE | mail -s "SEVERE on $(hostname)" mhalls@securityondemand.com
#;;
#		"SEVERE"*filters*)
#			echo $LINE >> /root/error.log
#		;;
#		"SEVERE"*reinit*)
#			echo $LINE >> /root/error.log
#		;;
		"SEVERE"*)
		echo $(date) $LINE >> /root/error.log
             echo $(date) $LINE | mail -s "SEVERE on $(hostname)" mhalls@securityondemand.com
esac
newdate=$(date +%s)
difDate=$[$newdate-$startdate]
if [ "$difDate" -gt 600 ]; then
echo $(date) >> /root/test.log
	break
fi
done
done
