#!/bin/bash

source setup.sh

deployFile=deploy.xml.filtered
newDeployFile=deploy-new.xml.filtered

shopt -s expand_aliases
alias enter="read -p '  Press enter to continue: '; echo"

read -p "Enter duracloud veresion (default: 2.3-SNAPSHOT): " -a duracloudVersion 
duracloudVersion=${duracloudVersion:-2.3-SNAPSHOT}

echo Using version ${duracloudVersion}

filter=s/\$\{duracloud\.version\}/${duracloudVersion}/g
for i in `find . -name "deploy*.xml"`; do 
  cat $i | sed  $filter >  $i.filtered;
done;

# Get Services
echo "--- Get Available Services---" 
curl $ca -u ${user}:${pword} ${protocol}://${host}/duraservice/services
echo "
Verify that available services are  printed." 
enter 

echo "--- Get Deployed Services---" 
curl $ca -u ${user}:${pword} "${protocol}://${host}/duraservice/services?show=deployed"
echo "
Verify that deployed services are  printed." 
enter 

# Deploy Service as anonymous user 
# should fail
echo "--- Verifying that deploying service as an anonymous user fails ---" 
curl $ca -v -X PUT -T ${deployFile}  ${protocol}://${host}/duraservice/${bitintegrity}
echo "Verify that response returned a 401 http code." 
enter 

# Deploy Service as USER_ROLE  user 
# should fail
echo "--- Verifying that deploying service in USER_ROLE  fails ---" 
curl $ca -v -u ${userUsername}:${userPassword}  -X PUT -T ${deployFile} ${protocol}://${host}/duraservice/${bitintegrity}
echo "
Verify that response returned a 401 http code." 
enter

# Deploy Service
echo "--- Verifying that deployment of bit integrity service as non-USER_ROLE succeeds ---" 
curl $ca -v -u ${user}:${pword} -X PUT -T ${deployFile} ${protocol}://${host}/duraservice/${bitintegrity}
echo "
Verify successful response 200." 
enter

# Get Service
echo "--- Testing Get Service  Info ---" 
curl $ca -u ${user}:${pword} ${protocol}://${host}/duraservice/${bitintegrity}
echo "
Verify service info is printed." 
enter

# Get Deployed Service
deployment=1
echo "--- Testing Get Deployed Service  ---" 
curl $ca -u ${user}:${pword} ${protocol}://${host}/duraservice/${bitintegrity}/${deployment}
echo "
Verify deployed service info is printed." 
enter

# Get Deployed Service Properties
echo "--- Testing Get Deployed Service  Properties ---" 
curl $ca -u ${user}:${pword} ${protocol}://${host}/duraservice/${bitintegrity}/${deployment}/properties
echo "
Verify deployed service properties are printed." 
enter

# Update Service Configuration
echo "--- Testing uppdate service configuration fails for Anonymous user ---" 
curl $ca -v -X POST -T ${newDeployFile} ${protocol}://${host}/duraservice/${bitintegrity}/${deployment}
echo "
Verify 401 response code" 
enter

echo "--- Testing uppdate service configuration fails for USER_ROLE ---" 
curl $ca -v -u ${userUsername}:${userPassword} -X POST -T ${newDeployFile} ${protocol}://${host}/duraservice/${bitintegrity}/${deployment}
echo "
Verify 401 response code" 
enter

echo "--- Testing update service configuration succeeds  for admin or greater role---" 
curl $ca -v -u ${user}:${pword} -X POST -T ${newDeployFile} ${protocol}://${host}/duraservice/${bitintegrity}/${deployment}
echo -e "\nVerify successful response" 
enter


# UnDeploy Service

echo "--- Testing undeploy service configuration fails for Anonymous user ---" 
curl $ca -v -u ${user}:${pword} -X DELETE ${protocol}://${host}/duraservice/${bitintegrity}/${deployment}

echo "
Verify 401 response code" 
enter

echo "--- Testing undeploy service configuration fails for USER_ROLE ---"
curl $ca -v -u ${userUsername}:${userPassword} -X DELETE ${protocol}://${host}/duraservice/${bitintegrity}/${deployment}
echo "
Verify 401 response code" 
enter

echo "--- Testing undeploy service configuration succeeds for admin or greater role---" 
curl $ca -v -u ${user}:${pword} -X DELETE ${protocol}://${host}/duraservice/${bitintegrity}/${deployment} 
echo "
Verify successful response" 
enter
