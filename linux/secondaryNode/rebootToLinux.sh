#/bin/bash

# check following command to verify it's the Manjaro partition:
# efibootmgr -v


sudo efibootmgr --bootnext 0001
sleep 3
sudo reboot
