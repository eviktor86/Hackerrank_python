#Title     : HSS External Database Check
#Subdomain : HSS
#Domain    : UDC
#Author    : Viktor Török
#Created   : 15 02 2017

#!/bin/sh
Node_Distinguished_Name=$(cat /opt/telorb/axe/ims/*.cfg | grep MY_NODE_NAME | sed -e 's/[^a-z0-9\-]//g;s/  */ /g')
echo "Node Name: $Node_Distinguished_Name"

LOCAL_ADDRESS=$( grep "[Ili]hs" /etc/hosts | grep "\-s$" | awk '{print $1}' )
echo -e "LOCAL ADDRESS: $LOCAL_ADDRESS"

CUDB_ADDRESSES=$(ldapsearch -x -h jimldap -p 7323 -D "administratorName=jambala,nodeName=$Node_Distinguished_Name" -w Pokemon1 -b HSS-ExtDbConfigName=HSS-ExtDbConfig,HSS-ConfigurationContainerName=HSS-ConfigurationContainer,applicationName=HSS,nodeName=$Node_Distinguished_Name | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

ldapsearch -x -h jimldap -p 7323 -D "administratorName=jambala,nodeName=$Node_Distinguished_Name" -w Pokemon1 -b HSS-ExtDbConfigName=HSS-ExtDbConfig,HSS-ConfigurationContainerName=HSS-ConfigurationContainer,applicationName=HSS,nodeName=$Node_Distinguished_Name | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' > CUDBs.txt
echo -e "CUDB ADDRESSES:\n$CUDB_ADDRESSES"
for i in $(getboard name -os DICOS | tr ',' '\n')
do
   echo -e "\n$i"
   CONNECTED_ADDRESSES=$(t-util processors/$i/net/util/netstat | grep -f CUDBs.txt | awk '{print $4}' | grep -Po "\d+.\d+.\d+.\d+" | sort -u )
   echo -e "CONNECTED ADDRESS: $CONNECTED_ADDRESSES"
      VAR=$( t-util processors/$i/net/util/netstat | grep -f CUDBs.txt | awk '{print $4}' | grep -Po "\d+.\d+.\d+.\d+" | sort -u | wc -l )
   #TCP_STATES=$(t-util processors/$i/net/util/netstat | grep -f CUDBs.txt | awk '{print $6}' | grep -Po "\S+" | sort -u | uniq)
			
			for n in $(t-util processors/$i/net/util/netstat | grep -f CUDBs.txt | awk '{print $6}' | grep -Po "\S+" | sort -u | uniq)
			do
				#NUM_OF_TCP=$(t-util processors/$i/net/util/netstat | grep -f CUDBs.txt | awk '{print $6}' | grep $n | wc -l)
				for m in $(t-util processors/Proc_m1_s7/net/util/netstat | grep -f CUDBs.txt | grep $n | awk '{print $4}' | grep -Po "\d+.\d+.\d+.\d+" | uniq)
				do
					NUM_OF_TCP=$(t-util processors/$i/net/util/netstat | grep -f CUDBs.txt | grep $n | grep $m | wc -l)
					echo -e "Number of $n TCP Sessions from $m: $NUM_OF_TCP"
				done
			done
   if [ $VAR -eq 0 ];then
      echo -e "\e[0;32mPASSED! There is no connected address!\e[0m"
   elif [ $VAR -eq 1 ] && [ "$LOCAL_ADDRESS" == "$CONNECTED_ADDRESSES" ];then
      echo -e "\e[0;32mPASSED! The connected address is: $CONNECTED_ADDRESSES\e[0m"
   else
      echo -e "\e[0;31mFAILED! Connected Address is not the Local Address or more than one IP Address connected to the CUDBs! \e[0m"
   fi
done
