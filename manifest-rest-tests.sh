#!/bin/bash

source setup.sh

shopt -s expand_aliases
alias enter="read -p ' Press enter to continue: '; echo"

echo " Before proceeding, by way of setup we will  
1) turn on duplication-on-change service via duradmin (service tab)
2) create a space called space-id 
3) add, delete, update items in that space 
4) download audit log from x-duracloud-admin for that space 
"
enter

echo "--- turn on duplication on change service in duradmin ---"
enter 

echo "--- delete space if exists --- "
curl ${ca} -u ${user}:${pword} -X DELETE ${protocol}://${host}/durastore/space-id
echo "--- creating space --- "
curl ${ca} -u ${user}:${pword} -X PUT ${protocol}://${host}/durastore/space-id


echo "--- staring audit service  --- "
curl ${ca} -u ${rootUsername}:${rootPassword} -X POST ${protocol}://${host}/duraboss/audit

echo "--- adding, deleting and updating items in that space ---"
for i in {1..3}; do 
  curl ${ca} -u ${user}:${pword} -T file.txt  ${protocol}://${host}/durastore/space-id/file-${i}.txt
done

curl ${ca} -u ${user}:${pword} -X DELETE ${protocol}://${host}/durastore/space-id/file-1.txt;

echo  "hello2" > file-2.txt;

curl ${ca} -u ${user}:${pword} -T file-2.txt  ${protocol}://${host}/durastore/space-id/file-2.txt;

echo "--- wait 60 seconds to insure most up to date audit log---" 
sleep 60 

echo "--- downloading audit log from x-duracloud-admin for space"  
curl $ca -u ${user}:${pword} ${protocol}://${host}/duraboss/audit/space-id
echo "--- verify audit log is printed." 
enter 

echo "--- ready to start tests ---"
enter 

echo "--- test getting default manifest ---"
curl $ca -u ${user}:${pword} ${protocol}://${host}/duraboss/manifest/space-id 
echo -e "\nVerify the default manifest was printed"
enter

echo "--- test getting default manifest with specific format (bagit)---"
curl $ca -u ${user}:${pword} ${protocol}://${host}/duraboss/manifest/space-id?format=bagit 
echo -e "\nVerify manifest was printed in bagit format."
enter

echo "--- test getting default manifest with specific store-id (1) ---"
curl $ca -u ${user}:${pword} ${protocol}://${host}/duraboss/manifest/space-id?storeID=1 
echo -e "\nVerify the manifest was printed"
enter

echo "--- test getting default manifest with specific as-of-date ---"
echo "--- note: date format can be any of those supported by common/util/DateUtil ---"
read -p "Enter Date (e.g. yyyy-MM-dd)  : " -a manifestDate 
curl $ca -u ${user}:${pword} ${protocol}://${host}/duraboss/manifest/space-id?date=${manifestDate}
echo -e "\nVerify that manifest was printed" 

echo "test error cases:  for the following tests verify http error codes are returned in responses ---"


echo "--- test bad format ---"
curl $ca -v -u ${user}:${pword} ${protocol}://${host}/duraboss/manifest/space-id?format=badformat
echo -e "\nVerify http error response code" 
enter

echo "--- test bad date ---"
curl $ca -v -u ${user}:${pword} ${protocol}://${host}/duraboss/manifest/space-id?date=23423423
echo -e "\nVerify http error response code" 
enter


echo "--- test bad store id ---"
curl $ca -v -u ${user}:${pword} ${protocol}://${host}/duraboss/manifest/space-id?storeID=23423423
echo -e "\nVerify http error response code" 
enter

echo "--- test bad space id ---"
curl $ca -v -u ${user}:${pword} ${protocol}://${host}/duraboss/manifest/thisisaninvalidspaceid
echo -e "\nVerify http error response code" 
enter

echo "--- cleaning up ---"

curl ${ca} -u ${user}:${pword} -X DELETE ${protocol}://${host}/durastore/space-id
