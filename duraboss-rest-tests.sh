#!/bin/bash
source setup.sh

shopt -s expand_aliases
alias enter="read -p ' Press enter to continue: '; echo" 

# GET Latest Storage Report
echo "--- GET Latest Storage Report ---"
curl $ca -u  ${user}:${pword} ${protocol}://${host}/duraboss/report/storage
echo -e "\nVerify latest storage report is printed"
enter 

# GET Storage Report List
echo "--- GET Storage Report List ---"
curl $ca -u  ${user}:${pword} ${protocol}://${host}/duraboss/report/storage/list
echo -e "\nVerify storage report list is printed"
enter 

# GET Storage Report Info
echo "--- GET Storage Report Info ---"
curl $ca -u  ${user}:${pword} ${protocol}://${host}/duraboss/report/storage/info
echo -e "\nVerify stoarge report info is printed"
enter

# Start Storage Report
echo "--- Start Storage Report ---"
curl $ca -v -u  ${rootUsername}:${rootPassword} -X POST ${protocol}://${host}/duraboss/report/storage
echo -e "\nVerify successful http response (200)"
enter

echo "--- Stop Storage Report ---" 
curl $ca -v -u  ${rootUsername}:${rootPassword} -X DELETE ${protocol}://${host}/duraboss/report/storage
echo -e "\nVerify succcessful http response"
enter

echo "--- Schedule Storage Report (to  begin one minute in the future and repeat every 10 min) ---" 
epochTime=$(((`date +%s`)*1000 + 60000))
curl $ca -v -u  ${rootUsername}:${rootPassword} -X POST ${protocol}://${host}/duraboss/report/storage/schedule?startTime=${epochTime}\&frequency=600000
echo -e "\nVerify successful httpcode (200)"
enter

echo "--- Cancel Storage Report Schedule ---"
curl $ca -v -u  ${rootUsername}:${rootPassword} -X DELETE ${protocol}://${host}/duraboss/report/storage/schedule
echo -e "\nVerify successful http response code" 
enter 
 
