#!/bin/bash
# Setup
# These environment variables should be set for the subsequent scripts
read -p "Enter Host (default: localhost:8080): " -a host 
host=${host:-localhost\:8080}

read -p "Enter Protocol (default: http): " -a protocol
protocol=${protocol:-http}

read -p "Enter Root Role Username (default root): " -a rootUsername 
rootUsername=${rootUsername:-root}

read -p "Enter Root Role Password (default rpw): " -a rootPassword  
rootPassword=${rootPassword:-rpw}

read -p "Enter Admin Role Username (default: admin): " -a user 
user=${user:-admin}

read -p "Enter Admin Role Password (default: apw) : " -a pword 
pword=${pword:-apw}

read -p "Enter User Role Username (default: user): " -a userUsername 
userUsername=${userUsername:-user}

read -p "Enter User Role Password (default: upw):  " -a userPassword
userPassword=${userPassword:-upw}

read -p "Enter Primary StoreId  (default: 1):  " -a storeId 
storeId=${storeId:-1}

read -p "Enter Extra Curl Arguments (e.g. -3 -v): " -a ca 

export space0=bricks
export space1=cars

# DuraStore Setup
# A small test file is needed by some of the content-related scripts

export file=file.txt
echo hello > ${file}

# DuraService Setup

export bitintegrity=0
