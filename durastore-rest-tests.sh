#!/bin/bash

source setup.sh

shopt -s expand_aliases
alias enter="read -p '  Press enter to continue: '; echo"

# Get Stores
echo "--- Get Stores ---"
curl ${ca} -u ${user}:${pword} ${protocol}://${host}/durastore/stores

echo -e "\nVerify that store listing is printed."
enter

# Get Spaces
echo "--- Get Spaces ---"
curl ${ca} -u ${user}:${pword} ${protocol}://${host}/durastore/spaces

echo -e "\nVerify that space listing is printed for primary store."
enter

curl ${ca} -u ${user}:${pword} ${protocol}://${host}/durastore/spaces?storeID=1

echo -e "\nVerify that space listing is printed for store with ID 1."
enter

# Create Space
echo "--- Create Space ---"
curl ${ca} -u ${user}:${pword} -X PUT ${protocol}://${host}/durastore/${space0}

echo -e "\nVerify that space named $space0 has been created in the primary storage provider."
enter

curl ${ca} -u ${user}:${pword} -X PUT ${protocol}://${host}/durastore/${space1}?storeID=1

echo -e "\nVerify that space named $space1 has been created in storage provider with ID=1" 
enter

# Store Content
echo "--- Store Content ---"
curl ${ca} -u ${user}:${pword} -T ${file} ${protocol}://${host}/durastore/${space0}/test.txt

echo -e "\nVerify that space $space0 now has a content item called test.txt."
enter

curl ${ca} -u ${user}:${pword} -T ${file} ${protocol}://${host}/durastore/${space0}/item.txt

echo -e "\nVerify that space $space0 now has a content item called item.txt."
enter

# Get Space
echo "--- Get Space ---"
curl ${ca} -u ${user}:${pword} ${protocol}://${host}/durastore/${space0}

echo -e "\nVerify that space $space0 listing has been printed."
enter

curl ${ca} -u ${user}:${pword} ${protocol}://${host}/durastore/${space1}?storeID=1

echo -e "\nVerify that space $space1 listing has been printed."
enter

curl ${ca} -u ${user}:${pword} ${protocol}://${host}/durastore/${space0}?prefix=test

echo -e "\nVerify that space $space0 listing of files starting with 'test' has been printed."
enter

# Get Space Metadata
echo "--- Get Space Metadata ---"
curl ${ca} -u ${user}:${pword} -I ${protocol}://${host}/durastore/${space0}

echo "Verify that the metadata listing of $space0 has been printed."
enter

curl ${ca} -u ${user}:${pword} -I ${protocol}://${host}/durastore/${space1}?storeID=1

echo -e "\nVerify that the metadata listing of $space1 has been printed."
enter

# Get Content
echo "--- Get Content ---"
curl ${ca} -u ${user}:${pword} ${protocol}://${host}/durastore/${space0}/test.txt

echo -e "\nVerify that the contents of file test.txt (hello) has been retrieved."
enter

curl ${ca} -u ${user}:${pword} ${protocol}://${host}/durastore/${space0}/test.txt?storeID=0\&attachment=true

echo -e "\nVerify that the file test.txt has been retrieved as an attachment."
enter

# Set Content Metadata
echo "--- Set Content Metadata ---"
curl ${ca} -u ${user}:${pword} -X POST -H "x-dura-meta-color: green" ${protocol}://${host}/durastore/${space0}/test.txt

echo -e "\nVerify that test.txt in $space0 now has a metadata item color=green."
enter

# Get Content Metadata
echo "--- Get Content Metadata ---"
curl ${ca} -u ${user}:${pword} -I ${protocol}://${host}/durastore/${space0}/test.txt

echo -e "\nVerify that the metadata of test.txt in $space0 has been printed."
enter

# Delete Content
echo "--- Delete Content ---"
curl ${ca} -u ${user}:${pword} -X DELETE ${protocol}://${host}/durastore/${space0}/test.txt

echo -e "\nVerify that test.txt in $space0 has been deleted."
enter

# Delete Space
echo "--- Delete Space ---"
curl ${ca} -u ${user}:${pword} -X DELETE ${protocol}://${host}/durastore/${space0}

echo -e "\nVerify that space $space0 in the primary provider has been deleted."
enter

curl ${ca} -u ${user}:${pword} -X DELETE ${protocol}://${host}/durastore/${space1}?storeID=1

echo -e "\nVerify that space $space1 in provider 1 has been deleted."
enter

# Get Tasks
echo "--- Get Tasks ---"
curl ${ca} -u ${user}:${pword} ${protocol}://${host}/durastore/task

echo -e "\nVerify the tasks list has been printed."
enter
