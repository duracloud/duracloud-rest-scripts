#!/bin/bash
source setup.sh

shopt -s expand_aliases
alias enter="read -p ' Press enter to continue: '; echo" 

echo "--- checking that duraboss is initialized"
curl -i $ca -u ${user}:${pword} https://${host}/duraboss/init

echo -e "\n Verify expected response: 
DuraBoss is initialized and ready for use
"
enter 

echo "--- check exec status ---"
curl -i $ca -u ${user}:${pword} https://${host}/duraboss/exec
echo "
Verify the following was printed above: 

<map>
  <entry>
    <string>media-streaming-handler</string>
    <string>Media Streamer: Idle</string>
  </entry>
  <entry>
    <string>bit-integrity-handler</string>
    <string>Bit Integrity: Idle</string>
  </entry>
</map>
"

enter 


echo " ---- get supported actions ----"

curl -i $ca -u ${user}:${pword} https://${host}/duraboss/exec/action

echo "
Verify the following expected results were printed above
<set>
  <string>stop-streaming-space</string>
  <string>start-streaming-space</string>
  <string>start-bit-integrity</string>
  <string>stop-streaming</string>
  <string>start-streaming</string>
  <string>cancel-bit-integrity</string>
</set>
"

enter 


echo "--- start streaming ---"
curl -i $ca -u ${rootUsername}:${rootPassword} -X POST https://${host}/duraboss/exec/start-streaming 

echo "--- verify that the streaming service is not idle ---"
curl -i $ca -u ${user}:${pword} https://${host}/duraboss/exec
echo -e "\nVerify that response shows enabled streaming service"
enter

echo "--- stop streaming ---"
curl -i $ca -u ${rootUsername}:${rootPassword} -X POST https://${host}/duraboss/exec/stop-streaming
curl -i $ca -u ${user}:${pword} https://${host}/duraboss/exec
echo -e "\nVerify expected results:  the streaming service is stopped."

echo "--- turn on the streaming service again.---"
curl -i $ca -u ${rootUsername}:${rootPassword} -X POST https://${host}/duraboss/exec/start-streaming
curl -i $ca -u ${user}:${pword} https://${host}/duraboss/exec
echo -e "\nVerify expected results: confirm the streaming service is started."
enter 

echo "---- start  streaming space ---"
read -p "Enter space to stream: " -a space
curl -i $ca -u ${rootUsername}:${rootPassword} -X POST https://${host}/duraboss/exec/start-streaming-space -d "${space}"
curl -i $ca -u ${user}:${pword} https://${host}/duraboss/exec
echo -e "\nverify that the spaces stream has been incremented by one."
enter 

echo "---- stop streaming space ----"
curl -i $ca -u ${rootUsername}:${rootPassword} -X POST https://${host}/duraboss/exec/stop-streaming-space -d "${space}"
curl -i $ca -u ${user}:${pword} https://${host}/duraboss/exec
echo -e "\nverify that the spaces stream has been decremented by one."
enter 

#bit integrity 
echo "--- checking  that bit integrity service is idle ---"
curl -i $ca -u ${user}:${pword} https://${host}/duraboss/exec
echo "--- verify that bit integrity service is idle ---"
enter 

echo "---- start bit integrity---"
#calculate 5 seconds into the future in epoch milliseconds
epochTime=$(((`date +%s`)*1000 + 5000))

curl -i $ca -u ${rootUsername}:${rootPassword} -X POST https://${host}/duraboss/exec/start-bit-integrity -d "${epochTime},600000"

sleep 10; 

curl -i $ca -u ${user}:${pword} https://${host}/duraboss/exec
echo -e "\nVerify that bit integrity is running"
enter 


echo "--- cancel bit integrity ---"
curl -i $ca -u ${rootUsername}:${rootPassword} -X POST https://${host}/duraboss/exec/cancel-bit-integrity 

echo "--- wait for the current integrity run to finish. ---"
enter
echo "wait ten minutes and verify another run does not automatically start within 10 minutes of the end the run."
enter
curl -i $ca -u ${user}:${pword} https://${host}/duraboss/exec
echo -e "\nVerify bit integrity is not running."
