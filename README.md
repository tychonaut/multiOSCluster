# multibootCluster
Collection of scripts to allow for booting a cluster of x86 computers between Windows and Linux in any direction. This can be helpful e.g. with a visualization cluster which is supposed to run software on both platforms natively.

There seems no simple solution for "multi-booting a computer cluster" around yet, but our scientific visualization dome needs this functionality, so I created this collection of scripts. May it be helpful to others.

Warning: This project is very incomplete, untested and WIP!


General workflow:

The master computer logs into the cluster nodes via SSH with admin/super user priviledges.
SSH is provieded either natively for Linux machines, or via MSYS2 on Windows.
Manual input of user credentials are omitted via private/public keys an mutual registration of the public keys as trusted parties.



Automation without is possible
It Uses sshd with public and private keys for remote access, and executes a tiny bash script on Linux. On Windows, it is much more complicated
