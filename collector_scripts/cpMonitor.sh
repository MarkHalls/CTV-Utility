#!/bin/bash
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

#takes CUST as argument
function check_checkpointTime {
#check if .stopalerting exists. if exists, skip device
        if [ -a /usr/local/"$1"/.stopalerting ]; then
        echo '/usr/local/'"$1"'/.stopalerting exists, Skipping'"$1"
        else
                if [ -a /usr/local/"$1"/log/logfile.log ]; then
                        if ps ax| grep -v grep| grep $1 > /dev/null; then
                                #get date in epoch time by delayEpoch
                                curdate=$(date +%s)
                                #calculate time of newest file in chkpnt directory and convert to epoch
                                modDate=$(stat --printf="%Y" $(ls -tr $(find /usr/local/$1/log -type f)|tail -n 1) )
                                modDateHuman=$(stat --printf="%y" $(ls -tr $(find /usr/local/$1/log -type f)|tail -n 1)| cut -d '.' -f1 )
                                #find time since file was last updated
                                difDate=$[$curdate-$modDate]
                                #write last modified date to .dat file
                                setDat $1 lastTime $modDate

                                #if difDate more than $delayEpoch, restart service
                                if [ "$difDate" -gt "$delayEpoch" ]; then
                                                if [ $(cat /usr/local/$1.dat | grep killedCounter | cut -d '=' -f2) = 0 ]; then
                                                        email_alert $1 '"logfile too old"' "$modDateHuman" $filesizeHuman '"Retrying"' '"Process Killed"'
                                                        killall -r $1
                                                        setDat $1 killedCounter 1

                                                elif [ $(cat /usr/local/$1.dat | grep killedCounter | cut -d '=' -f2) = 1 ]; then
                                                        email_alert $1 '"logfile too old"' "$modDateHuman" $filesizeHuman '"Retrying"' '"Process Killed"' '"Logfile Deleted"'
                                                        killall -r $1
                                                        rm -rf /usr/local/$1/log/logfile.log
                                                        setDat $1 killedCounter 2


                                                elif [ $(cat /usr/local/$1.dat | grep killedCounter | cut -d '=' -f2) = 2 ]; then
                                                        email_alert $1 '"logfile too old"' "$modDateHuman" $filesizeHuman '"Disabled"' '"Process Killed"' '"Logfile Deleted"' '"Manual intervention required"'
                                                        killall -r $1
                                                        rm -rf /usr/local/$1/log/logfile.log
                                                        setDat $1 killedCounter 0
                                                        touch /usr/local/$1/.stopalerting

                                                fi

                                #check if file is in the future
                                elif [ "$difDate" -lt -1 ]; then
                                                #if it is in the future
                                                email_alert $1 '"logfile has future date"' "$modDateHuman" $filesizeHuman '"Retrying"' '"Process Killed"' '"Logfile Deleted"'
                                                killall -r $1
                                                rm -rf /usr/local/$1/log/logfile.log

                                fi
                        fi
                        check_cpSize $1
                else
                echo "Log Grabber process not running, Skipping "$1
                fi
        fi
}

function check_cpSize {
  filesize=$(du -sk /usr/local/$1/log | cut -f1)
  filesizeHuman=$(du -skh /usr/local/$1/log | cut -f1)
  #greater than 1GB
  if [ $filesize -ge 1000000 ]; then
        #stop process and delete all files in log directory
                if [ $(cat /usr/local/$1.dat | grep killedCounter | cut -d '=' -f2) = 0 ]; then
                        email_alert $1 '"directory too large"' "$modDateHuman" $filesizeHuman '"Retrying"' '"Process Killed"'
                        killall -r $1
                        setDat $1 killedCounter 1

                elif [ $(cat /usr/local/$1.dat | grep killedCounter | cut -d '=' -f2) = 1 ]; then
                        email_alert $1 '"directory too large"' "$modDateHuman" $filesizeHuman '"Retrying"' '"Process Killed"' '"Folder Contents Deleted"'
                        killall -r $1
                        rm -Rf /usr/local/$1/log/*
                        setDat $1 killedCounter 2


                elif [ $(cat /usr/local/$1.dat | grep killedCounter | cut -d '=' -f2) = 2 ]; then
                        email_alert $1 '"directory too large"' "$modDateHuman" $filesizeHuman '"Disabled"' '"Process Killed"' '"Folder Contents Deleted"' '"Manual intervention required, emails suspended. To resume, see below instructions."'
                        killall -r $1
                        rm -Rf /usr/local/$1/log/*
                        setDat $1 killedCounter 0
                        touch /usr/local/$1/.stopalerting

                fi
        email_alert $1 '"directory too large"' "$modDateHuman" $filesizeHuman '"Process Killed"' '"Folder Contents Deleted"'
        killall -r $1
        rm -Rf /usr/local/$1/log/*
  else
        #check file size of log file and compare to previous value
        prevSize=$(cat /usr/local/$1.dat | grep lastSize | cut -d '=' -f2)
        logsize=$(du -sk /usr/local/$1/log/logfile.log | cut -f1)
        logsizeHuman=$(du -skh /usr/local/$1/log/logfile.log | cut -f1)
                #update lastSize value
        setDat $1 lastSize $logsize
        difSize=$[$logsize-$prevSize]
          if [ "$difSize" -ge 1 ]; then
                        #logfile is growing
                        #reset kill counter to 0
                        setDat $1 killedCounter 0

          elif [ "$difSize" -lt -1 ]; then
                        #logfile just rolled
                        #reset kill counter to 0
                        setDat $1 killedCounter 0

          else
                        #stop process and delete file
                        if [ $(cat /usr/local/$1.dat | grep killedCounter | cut -d '=' -f2) = 0 ]; then
                                email_alert $1 '"logfile not increasing"' "$modDateHuman" $logsizeHuman '"Retrying"' '"Process Killed"'
                                killall -r $1
                                setDat $1 killedCounter 1

                        elif [ $(cat /usr/local/$1.dat | grep killedCounter | cut -d '=' -f2) = 1 ]; then
                                email_alert $1 '"logfile not increasing"' "$modDateHuman" $logsizeHuman '"Retrying"' '"Process Killed"' '"Logfile Deleted"'
                                killall -r $1
                                rm -rf /usr/local/$1/log/logfile.log
                                setDat $1 killedCounter 2


                        elif [ $(cat /usr/local/$1.dat | grep killedCounter | cut -d '=' -f2) = 2 ]; then
                                email_alert $1 '"logfile not increasing"' "$modDateHuman" $logsizeHuman '"Disabled"' '"Process Killed"' '"Logfile Deleted"' '"Manual intervention required"'
                                killall -r $1
                                rm -rf /usr/local/$1/log/logfile.log
                                echo "Should create stopalerting file here"
                                setDat $1 killedCounter 0
                                touch /usr/local/$1/.stopalerting

                        fi

          fi
  fi

}
#check if dat file exists, if it doesn't, create it.
function checkfile {
  if [ -a /usr/local/"$1".dat ]; then
  :
  else
  echo  lastSize=0 > /usr/local/$1.dat
  echo  lastTime=0 >> /usr/local/$1.dat
  echo  killedCounter=0 >> /usr/local/$1.dat
  fi
}

#format: email_alert 1dev_id 2desc 3file_dateHuman 4sizeHuman 5disposition 6action 7secondary_action 8tertiary_action
function email_alert {
echo ========== > /usr/local/email.txt
echo 'Process: '$1 >> /usr/local/email.txt
echo 'Alert: '$2 >> /usr/local/email.txt
echo 'Action: '$6','$7','$8'.'     >> /usr/local/email.txt
echo 'Running on: '$(hostname) >> /usr/local/email.txt
echo 'IP Address: '$(ifconfig | grep 198 | cut -d ':' -f2 | cut -d ' ' -f1) >> /usr/local/email.txt
echo 'Disposition: '$5 >> /usr/local/email.txt
echo ========== >> /usr/local/email.txt
echo ' ' >> /usr/local/email.txt
echo 'Alert Details:' >> /usr/local/email.txt
echo 'Notification Script: cpMonitor.sh dev_vendor=Checkpoint dev_id='$1' desc='$2 >> /usr/local/email.txt
echo 'file_date='$3 >> /usr/local/email.txt
echo 'size='$4 >> /usr/local/email.txt
echo 'primary_action=Process /usr/local/'$1'/bin/'$1' killed, auto restart in 60 seconds' >> /usr/local/email.txt
echo 'secondary_action='$7 >> /usr/local/email.txt
echo ' ' >> /usr/local/email.txt
echo 'To stop these messages, run this command on '$(hostname)':' >> /usr/local/email.txt

echo 'touch /usr/local/'$1'/.stopalerting' >> /usr/local/email.txt
echo ' ' >> /usr/local/email.txt
echo 'To re-enable these messages, run this command on '$(hostname)':' >> /usr/local/email.txt
echo 'rm -f /usr/local/'$1'/.stopalerting' >> /usr/local/email.txt

logger 'dev_vendor=Checkpoint dev_id='$1' desc='$2' file_date='$3' size='$4' disposition='$5' action='$6' secondary_action='$7

  subject='Checkpoint Error on '$(hostname)
  recipient=tcadmins@securityondemand.com
  mail -s "$subject" $recipient < /usr/local/email.txt

}

#first email function, no longer used. Saved for reference.
function email_alert_old {
  logger $1
  subject='Checkpoint Error on '$(hostname)
  recipient=tcadmins@securityondemand.com
  body=$1
  echo -e $body "        To stop receiving these messages, rename the directory indicated by dev_id."| mail -s "$subject" $recipient

}
#pass CUST followed by the field you want to update as argument followed by its value (ex: setDat $1 lastSize 34432)
function setDat {

  currentValue=$(cat /usr/local/$1.dat | grep $2)
  sed -i "s/$currentValue/$2=$3/" /usr/local/$1.dat
}
#check/install crontab for this script

crontab -l > /usr/mycron
cpMonitor=$(cat /usr/mycron | grep cpMonitor.sh)
if [ -z "$cpMonitor" ]; then
echo '*/5     *       *       *       *       /usr/local/bin/cpMonitor.sh 2>&1 > /dev/null 2>&1 &' >> /usr/mycron
crontab /usr/mycron
fi
rm -f /usr/mycron

delayEpoch=600
for i in $(ls /usr/local | grep ChkPt | grep -v dat | grep -v .zip);do echo running checkfile on $i;checkfile $i;echo running checkpoint on $i; check_checkpointTime $i; done;
for i in $(ls /usr/local | grep fw | grep -v dat | grep -v .zip ); do echo running checkfile on $i;checkfile $i;echo running checkpoint on $i; check_checkpointTime $i; done;

