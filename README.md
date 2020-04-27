# multiOSCluster

This is a collection of scripts to allow for booting a cluster of x86 computers between Windows and Linux in any direction, launch and kill applications all machines via SSH, file copy and syncing.

This can be helpful e.g. with automating a visualization cluster which is supposed to run software on different platforms natively.

Cross-platform-scriptability is desireable, hence bash was chosen as primary scripting language. 
Remote access performed via SSH. 
To enable this workflow on Windows, msys2's sshd is used: 

Warning: This project is WIP, hence incomplete, partially untested and hardcoded to our own cluster!
E.g., I have written and tested locally some "clustered dual boot" scripts, yet we haven'T even installed Linux on our cluster yet!
I am trying to make this repo as generally applicable as possible. 
Still, keep in mind that general applicability is only a by-product, while the main purpose is to automate a specific visualization dome, the ARENA2 at GEOMAR, Kiel (https://www.geomar.de/en/research/fb4/fb4-muhs/infrastructure/arena/) .



## clustered multi-boot

There seems no simple solution for "multi-booting a computer cluster" around yet, but our scientific visualization dome needs this functionality, so I created this collection of scripts. May it be helpful to others.


General workflow for booting of the cluster into a different OS:

The master computer logs into the cluster nodes via SSH with admin/super user priviledges.
SSH is provieded either natively for Linux machines, or via MSYS2 on Windows.
Manual input of user credentials are omitted via private/public keys an mutual registration of the public keys as trusted parties.

Once logged in, local native scripts are executed that 
1. Alter the EFI settings boot into the desired OS on next reboot
2. perform the reboot.

On Linux, this is a trivial two-liner.
On Windows, it is way more complicated and currently realized as a combination of self-elevating powershell script which uses a python script for easier string manipulation.

## setup & config

TODO write doc

## file copy & snyc

TODO write doc

## application launch

TODO write doc



