declare -i count
count=1
for i in $(cat /etc/hosts | grep 198.18 | cut -f 2);do echo -ne "Checking SSH Connections" "."*$count\r\c; count=count+1; ssh -q -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no $i exit; done 2>&1 | tee ssherr
