#!/bin/bash

source setup.sh

shopt -s expand_aliases
alias enter="read -p '  Press enter to continue: '; echo"

echo "--- make sure there are no existing audit logs for 'audit' space (x-duracloud-admin/audit/storage-audit-log*) --"
enter 

echo "--- delete and (re)create two new spaces, audit-src and audit ---"
curl $ca -u ${rootUsername}:${rootPassword} -X DELETE ${protocol}://${host}/durastore/audit-src
curl $ca -u ${rootUsername}:${rootPassword} -X DELETE ${protocol}://${host}/durastore/audit

curl $ca -v -u ${rootUsername}:${rootPassword} -X PUT ${protocol}://${host}/durastore/audit-src
echo -e "\nVerify audit-src space successfully created." 
enter 

curl $ca -v -u ${rootUsername}:${rootPassword} -X PUT ${protocol}://${host}/durastore/audit
echo -e "\nVerify audit space successfully created." 
enter 

echo "--- add file to 'audit-src' ---" 
curl $ca -v -u ${rootUsername}:${rootPassword} --upload-file file.txt ${protocol}://${host}/durastore/audit-src/file.txt
echo -e "\nVerify successful upload of file.txt to audit-src"
enter 

echo "--- start auditor" 
curl $ca -v -u ${rootUsername}:${rootPassword} -X POST ${protocol}://${host}/duraboss/audit
enter 

echo "-- run three concurrent processes uploading files to space 'audit', deleting a subset, and copying a subset,  pausing for a few seconds between each operation and simultaneously verify changes to local cache of audit log by running the following script in a separate terminal
*** note, populates every 60 seconds
while true; do ls -l [catalina.home]/temp/audit/*; sleep 5; done
tail -f [catalina.home]/temp/audit/storage-audit-log-audit-*.tsv"
enter
for x in {0..20}; do echo $x; curl $ca -u ${rootUsername}:${rootPassword} --upload-file file.txt ${protocol}://${host}/durastore/audit/file-$x.txt;done
sleep 2; for x in {5..20}; do echo $x; curl $ca -u ${rootUsername}:${rootPassword} -X DELETE ${protocol}://${host}/durastore/audit/file-$x.txt;done
sleep 5; for x in {11..20}; do echo $x; curl $ca -u ${rootUsername}:${rootPassword} -X PUT --header "x-dura-meta-copy-source: audit-src/file.txt" ${protocol}://${host}/durastore/audit/file-$x.txt;done

echo "
verify correct local and DuraCloud logs exist 
#*** [catalina.home]/temp/audit...
#*** x-duracloud-admin/audit...
"
enter 

echo "--- test initial log creation with current events ---"
curl $ca -u ${rootUsername}:${rootPassword} -X POST ${protocol}://${host}/duraboss/audit
echo -e "\n verify existing logs are removed"
echo -e "\n verify logs for all spaces (across all providers) are being regenerated"
enter 

echo "--- while logs are being generated, create current events ---"
for x in {100..120}; do echo $x; curl $ca -u ${rootUsername}:${rootPassword} --upload-file file.txt ${protocol}://${host}/durastore/audit/file-$x.txt;sleep 5;done
enter 

echo "----  verify 'current events' entries were postponed in the log until after the existing items were added ---"
enter 

echo "--- test log retrieval ---"
echo "--  test the case where one space is a substring of the spaceId of another space --"
#** for each space
curl $ca -u ${rootUsername}:${rootPassword} ${protocol}://${host}/duraboss/audit/audit

echo -e "\nVerify that the audit log from the "audit" space was retrieved";
enter 

echo "--- test stop auditor & restart ---"
echo -e"\n---testing  stop ---"
curl $ca -v -u ${rootUsername}:${rootPassword} -X DELETE ${protocol}://${host}/duraboss/audit
echo -e"\nVerify that http returned success code."
enter

echo "\n--- verify that audit events are not recorded while the auditor is turned off by looking at the log in x-duracloud-admin."

