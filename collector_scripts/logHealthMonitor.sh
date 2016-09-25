#!/bin/bash
### logHealthMonitor.sh - Monitors the log output directory for excessive unzipped logs and the unmatched lines directory as measure that the icservices.sh script is still running.
#
#
##  Written by Chase Hatch (chatch@securityondemand.com) under consultation of Mark Halls (mhalls@securityondemand.com)
##  Last modified Nov/3/2015


output='/opt/open/stm/slm/output/'
unmatched_lines='/opt/open/stm/tmp/'
last_UML_dir_size_count=0  # initialize; used to keep track of if service is running.
THRESH_MAX_UNGZIPPED=10
LAST_PASS_GZIPPED=0 # keeps track of num gzipped files on last pass
THRESH_MIN_GZIPPED=5
THRESH_MAX_GZIPPED=10
THRESH_MAX_DISK_USAGE=40  # percentage
EVALUATE_INTERVAL=600  # in seconds
GZ_COUNT=$(find $output -type f -name '*.gz$' | wc -l)
SHA_COUNT=$(find $output -type f -name '*.gz.sha' | wc -l)
THRESH_DIFFERENCE=3



## High-volume clients use Unmatched Lines as a metric of health monitoring.
UnmatchedLinesIsMetric=0  # only sets to 1 if the client is listed in the array.
declare -a HighVolClients=( "Sitel" ) # array; syntax = ( "one", "two", "three" )
for i in "${HighVolClients[@]}"; do if [[ $(hostname |grep -ci `echo $i |sed s/,//g`) -ge 1 ]]; then UnmatchedLinesIsMetric=1; fi; done


 
logHealthMonitor=$(cat /etc/rc.d/rc.local | grep logHealthMonitor.sh)
if [ -z "$logHealthMonitor" ]; then
echo '/usr/bin/logHealthMonitor.sh > /dev/null 2>&1 &' >> /etc/rc.d/rc.local
fi
 
 
 
cd $output  # ensure we're in the right directory
 
 
 
while [ -d "$output" ]; do
		if [[ $UnmatchedLinesIsMetric -eq 1 ]]; then
			# IF this host has been explicitly noted as needing to scrutinize the unmatched lines dir for activity (i.e., ic-collector service running?)
			if [[ $(du -scb $unmatched_lines |cut -f 1 |head -n 1) -eq  $last_UML_dir_size_count ]]; then
					# if true then we know with almost 100% confidence that the service must have stopped so we need to restart it; this should always be a different value across two pollings.
					# STUB:  restart the service
					icservices.sh
					logger "$(date) /usr/bin/logHealthMonitor.sh: Restarted icservices.sh." |tee -a /var/log/icprocess.log					
			fi
		fi
        if [[ $(ls -al $output | grep -v .gz | grep -v .sha | wc -l) -gt $THRESH_MAX_UNGZIPPED ]] || [[ $(df |grep -e /$ | cut -f 1 -d % | cut -f 8 -d " ") -gt $THRESH_MAX_DISK_USAGE ]]; then
                # IF $output dir has more unzipped files than a given threshold, then cleanup script needs to be running.
                # OR
                # IF $output dir's disk partition usage greater than threshold, then cleanup script needs to be running.
                # STUB:  Mark's multi-thread cleanup.sh bash one-liner
                logger "$(date) /usr/bin/logHealthMonitor.sh: Too many files in output... running cleanup script instances per-file." |tee -a /var/log/icprocess.log
				$(for i in $(ls -1tr /opt/open/stm/slm/output/ | grep -v \.gz); do /boot/cleanupparallel.sh $i & done;)
 
        fi
        if [[ $(ls $output | grep \.gz | wc -l) -ge $THRESH_MAX_GZIPPED ]] && [[ $(ls $output | grep \.gz | wc -l) -ge $THRESH_MIN_GZIPPED ]]; then
                # IF the gzipped files aren't transferring, restart the services.
				# ONLY do so if the number of gzipped files is above a certain number.
				logger "$(date) /usr/bin/logHealthMonitor.sh: Gzipped files not transferring out; restarting the SOD services to remediate this." |tee -a /var/log/icprocess.log
				killall -r SOD*
        fi
		if [[ $(($GZ_COUNT - $SHA_COUNT)) -ge $THRESH_DIFFERENCE ]] || [[ $(($SHA_COUNT - $GZ_COUNT)) -ge  $THRESH_DIFFERENCE ]]; then
				# IF (number of .gz) minus (number of .sha) greater-than-or-equal-to $THRESH_DIFFERENCE
				# OR
				# IF (number of .sha) minus (number of .gz) greater-than-or-equal-to $THRESH_DIFFERENCE
				# THEN delete all .sha files, and re-generate per each .gz file.
				logger "$(date) /usr/bin/logHealthMonitor.sh: Detected variation between count of .gz files ($GZ_COUNT) amd matching .sha files ($SHA_count) in output dir ($output).  Re-generating .sha files to fix this." |tee -a /var/log/icprocess.log
				rm -f /opt/open/stm/slm/output/*.sha
				for i in $( ls -1tr /opt/open/stm/slm/output/ |grep \.gz | grep -v \.sha ); do sha1sum /opt/open/stm/slm/output/$i > /opt/open/stm/slm/output/$i.sha & done;
		fi
        LAST_PASS_GZIPPED=$(ls $output | grep \.gz | wc -l)
        last_UML_dir_size_count=$(du -scb $unmatched_lines |cut -f 1 |head -n 1) # grab size of dir
        sleep $EVALUATE_INTERVAL #, then sleep for n seconds
done

# 
