#!/bin/bash

#echo "stop checking_firmware service"
#sudo service checking_firmware stop

sudo rm -rf $(pwd)/software_update.tar.xz $(pwd)/software_update
echo "Firmware_update_initiating"
sudo echo firmware_update_initiating > status_firmware.txt

#sudo sed -i '/software_update.sh/d' /etc/crontab
#sudo echo "*/2 * * * * root sudo bash /medha_gateway/software_update.sh" >>/etc/crontab

old=`cat $(pwd)/version`

URL=`cat $(pwd)/URL.txt`

sudo curl -L -k -s --output software_update.tar.xz $URL
CMD=$(ls $(pwd)/ | grep software_update.tar.xz)
#echo $CMD

        if [ `echo $CMD | grep -c "software_update.tar.xz" ` -gt 0 ]
        then
		echo "Firmware package is downloaded successfully, initiated the installation"
		sudo $(pwd)/script_success_arm
	else
		echo "Faild to download the firmware packege"
		sudo $(pwd)/script_failed_arm
		exit 
        fi

sudo mkdir software_update

sudo tar -xf $(pwd)/*.tar.xz -C $(pwd)/software_update
val=`cat $(pwd)/software_update/*/version`

function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$old"; }

if version_gt $old $val; then
	echo "----------------------------------------------------------------------------------------------------------------------------------"
	echo "Old package vresion is $old"
	echo "New package is available version is $val "
	echo "Script_success responce send sleep 3s"
	sleep 3s
	echo "Now installing the new version Please wait......."

CMD1=$(ls $(pwd)/software_update/*/ | grep iot_frmwrk)
#echo $CMD1

	if [ `echo $CMD1 | grep -c "iot_frmwrk" ` -gt 0 ]
	then
		echo "Replaceing the iot_frmwrk..."
		sudo service iot_frmwrk stop
		sudo chmod +x $(pwd)/software_update/*/iot_frmwrk
		sudo cp $(pwd)/software_update/*/iot_frmwrk /medha_gateway
		#sudo service iot_frmwrk start
	fi

CMD2=$(ls $(pwd)/software_update/*/ | grep zwave_app)
#echo $CMD2

	if [ `echo $CMD2 | grep -c "zwave_app" ` -gt 0 ]
	then
 		 echo "Replacing the zwave_app..."
       		 sudo service zwave_app stop
	       	 sudo chmod +x $(pwd)/software_update/*/zwave_app
        	 sudo cp $(pwd)/software_update/*/zwave_app /medha_gateway
      		 sudo service zwave_app start
	 fi
CMD3=$(ls $(pwd)/software_update/*/ | grep .sh)
#echo $CMD3

        if [ `echo $CMD3 | grep -c ".sh" ` -gt 0 ]
        then
                sudo bash $(pwd)/software_update/*/$CMD3
         fi

	sudo cp $(pwd)/software_update/*/version /medha_gateway
	sudo rm -rf $(pwd)/software_update
	sudo rm -rf $(pwd)/software_update.tar.xz
	sudo service iot_frmwrk start
	#sudo sed -i '/software_update.sh/d' /etc/crontab
	#sudo $(pwd)/script_success
	sudo echo success > status_firmware.txt 
	sudo ./frmwre_update_success_arm $old $val
	echo "****Update is completed****"

else

	sudo rm -rf $(pwd)/software_update
	echo ""
	sudo rm -rf $(pwd)/software_update.tar.xz
	sudo ./frmwre_update_failed_arm NULL $old
	#sudo sed -i '/software_update.sh/d' /etc/crontab
	sudo echo success > status_firmware.txt
	echo "Already packages are updated, Version is $old "
	exit

fi
