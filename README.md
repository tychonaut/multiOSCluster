# multibootCluster
Collection of scripts to allow for booting a cluster of x86 computers between Windows and Linux in any direction. This can be helpful e.g. with a visualization cluster which is supposed to run software on both platforms natively.

There seems no simple solution for "multi-booting a computer cluster" around yet, but our scientific visualization dome needs this functionality, so I created this collection of scripts. May it be helpful to others.

Warning: This project is very incomplete, untested and WIP!


General workflow:

The master computer logs into the cluster nodes via SSH with admin/super user priviledges.
SSH is provieded either natively for Linux machines, or via MSYS2 on Windows.
Manual input of user credentials are omitted via private/public keys an mutual registration of the public keys as trusted parties.

Once logged in, local native scripts are executed that 
1. Alter the EFI settings boot into the desired OS on next reboot
2. perform the reboot.

On Linux, this is a trivial two-liner.
On Windows, it is way more complicated and currently realized as a combination of self-elevating powershell script which uses a python script for easier string manipulation.
