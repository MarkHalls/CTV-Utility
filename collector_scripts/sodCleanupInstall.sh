#!/bin/bash
#/usr/local/bin/sodCleanupInstall.sh
#
#This script configures logrotate to rotate the logs in $SOD/log
#it runs every sunday and removes any logfiles older than 3 days
#
#Written by Mark Halls (mhalls@securityondemand.com)
#Last updated 11/13/15

#check if exists and sets SODCleanup to run in logrotate
sodCleanup=$(cat /etc/logrotate.conf | grep '/usr/local/sod/log')
if [ -z "$sodCleanup" ]; then
echo ' ' >> /etc/logrotate.conf
echo '/usr/local/sod/log/*.log {' >> /etc/logrotate.conf
echo 'weekly' >> /etc/logrotate.conf
echo 'rotate=0' >> /etc/logrotate.conf
echo 'nocreate' >> /etc/logrotate.conf
echo 'sharedscripts' >> /etc/logrotate.conf
echo 'postrotate' >> /etc/logrotate.conf
echo 'find /var/log/directadmin -name "SOD*log*" -mtime +3 -exec /bin/rm -f {} \;' >> /etc/logrotate.conf
echo 'endscript' >> /etc/logrotate.conf
echo '}' >> /etc/logrotate.conf
echo ' ' >> /etc/logrotate.conf
fi
