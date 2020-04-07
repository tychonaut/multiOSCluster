#/bin/bash

# check following command to verify it's the Windows partition:
# efibootmgr -v


echo "looking for OS name \"$1\" in EFI boot option listing ..."

relevantLine=$(efibootmgr -v | grep "$1")


echo ${#relevantLine}

if [[ ${#relevantLine} > 0 ]]
then
	echo "Line found in EFI boot listing matching given name:"
	echo "${relevantLine}"
else
	echo "Error: Name not listed in EFI boot options! Aborting ..."
	exit 1
fi

# take the four characters after the first four letters ("Boot")
foundHexEntry=${relevantLine:4:4}

echo "found hex entry: "
echo "${foundHexEntry}"

# hardcoded example:
#sudo efibootmgr --bootnext 0000

sudo efibootmgr --bootnext ${foundHexEntry}

sleep 3

sudo reboot
