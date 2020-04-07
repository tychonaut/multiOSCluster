#/bin/bash

# check following command to verify it's the Windows partition:
# efibootmgr -v


sudo efibootmgr --bootnext 0000
sleep 3
sudo reboot
