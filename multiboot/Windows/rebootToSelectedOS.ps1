#
#	"Main code" inspired by
#	 	https://github.com/chengxuncc/booToLinux/blob/master/main.go
#
# 	PowerShell-self-elevation code (for for stuff that require Administrator rights) taken from:
# 		https://gist.github.com/atao/a103e443ffb37d5d0f0e7097e4342a28




# self-elevation to admin:
if(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{ 
	echo "DEBUG: self-elevating..."
	# you have to pass new the arguments to the elevated instance.
	# Reason: this script is RESTARTED with admin privildges, resetting current working directory and initial arguments!
	#-WorkingDirectory $currentWorkingDir
	
	$currentWorkingDir=(pwd).path
	$whichOS_name=$args[0]
	
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"  $currentWorkingDir `"$whichOS_name`" "  -Verb RunAs  ; 
	
	# exit this non-elevated script execution, otherwise two instances of this script run, one a admin and onw without
	exit 
}



# assign the params passed to the "Admin"-instance:
#https://stackoverflow.com/questions/43494863/start-process-workingdirectory-as-administrator-does-not-set-location
$currentWorkingDir=$args[0]
cd $currentWorkingDir

$whichOS_name=$args[1]




# init to mnemonic ID for windows boot manager
$whichOS_ID="{bootmgr}"

echo "DEBUG: admin: which os name:"
echo $whichOS_name

echo "DEBUG: admin: working dir:"
(pwd).path



#query UEFI boot loader configuration, store as string variable to pass to python
$queryOutput = (bcdedit /enum firmware) | Out-String



switch ( $whichOS_name )
{
    "Windows"
    {
        echo "rebooting to Windows!"
		# this mnemonic ID holds for each windows installation:
		$whichOS_ID="{bootmgr}"
    }
    default
    {
		# any non-windows OS, e.g. "Manjaro" (a Linux distribution) or PXE stuff:
		
		# take the OS name ($whichOS_name) to extract the associated Identifier from the queried list
		$whichOS_ID = python extractIdentifierFromDescriptionInEfiList.py $whichOS_name $queryOutput

		# success?
		if($?)
		{
			echo "rebooting into the folloing OS:"
			echo $whichOS_ID
			
			#this is the ID  for "Manjaro" found by hand on my machine:
			#$whichOS_ID="{c2f7e4eb-7436-11ea-8833-806e6f6e6963}" 
		}
		else
		{
			echo "unknown OS:"  
			echo $whichOS_name
			echo "exiting without changing anything ..."
			sleep 3
			exit
		}
	}
}






echo "DEBUG: OS name to set in UEFI for next boot:"
echo $whichOS_name
 
echo "DEBUG: OS ID to set in UEFI for next boot:"
echo $whichOS_ID

bcdedit /set "{fwbootmgr}" bootsequence "$whichOS_ID" /addfirst

# wait for 3 seconds for the user to realize what has happened
sleep 3

# wait for 3 seconds for the user to realize what is happening
shutdown /r /t 3




#################################################################################
# FYI the output on this machine to get the relevant IDs from:

#PS C:\Windows\system32> bcdedit /enum firmware
#
#Firmware Boot Manager
#---------------------
#identifier              {fwbootmgr}
#displayorder            {c2f7e4ec-7436-11ea-8833-806e6f6e6963}
#                        {c2f7e4eb-7436-11ea-8833-806e6f6e6963}
#                        {bootmgr}
#                        {401c3e31-5c95-11ea-9df4-a8a159046732}
#                        {401c3e32-5c95-11ea-9df4-a8a159046732}
#                        {401c3e33-5c95-11ea-9df4-a8a159046732}
#                        {401c3e34-5c95-11ea-9df4-a8a159046732}
#                        {401c3e35-5c95-11ea-9df4-a8a159046732}
#                        {401c3e36-5c95-11ea-9df4-a8a159046732}
#                        {401c3e37-5c95-11ea-9df4-a8a159046732}
#                        {401c3e30-5c95-11ea-9df4-a8a159046732}
#timeout                 1
#
#Windows Boot Manager
#--------------------
#identifier              {bootmgr}
#device                  partition=\Device\HarddiskVolume5
#path                    \EFI\MICROSOFT\BOOT\BOOTMGFW.EFI
#description             Windows Boot Manager
#locale                  en-US
#inherit                 {globalsettings}
#default                 {current}
#resumeobject            {401c3e38-5c95-11ea-9df4-a8a159046732}
#displayorder            {current}
#toolsdisplayorder       {memdiag}
#timeout                 30
#
#Firmware Application (101fffff)
#-------------------------------
#identifier              {401c3e30-5c95-11ea-9df4-a8a159046732}
#description             UEFI: HTTP IPv4 Aquantia AQtion 10Gbit Network Adapter
#
#Firmware Application (101fffff)
#-------------------------------
#identifier              {401c3e31-5c95-11ea-9df4-a8a159046732}
#description             UEFI: PXE IPv4 Aquantia AQtion 10Gbit Network Adapter
#
#Firmware Application (101fffff)
#-------------------------------
#identifier              {401c3e32-5c95-11ea-9df4-a8a159046732}
#description             UEFI: HTTP IPv6 Aquantia AQtion 10Gbit Network Adapter
#
#Firmware Application (101fffff)
#-------------------------------
#identifier              {401c3e33-5c95-11ea-9df4-a8a159046732}
#description             UEFI: PXE IPv6 Aquantia AQtion 10Gbit Network Adapter
#
#Firmware Application (101fffff)
#-------------------------------
#identifier              {401c3e34-5c95-11ea-9df4-a8a159046732}
#description             UEFI: HTTP IPv4 Realtek PCI 2.5GBE Family Controller
#
#Firmware Application (101fffff)
#-------------------------------
#identifier              {401c3e35-5c95-11ea-9df4-a8a159046732}
#description             UEFI: PXE IPv4 Realtek PCI 2.5GBE Family Controller
#
#Firmware Application (101fffff)
#-------------------------------
#identifier              {401c3e36-5c95-11ea-9df4-a8a159046732}
#description             UEFI: HTTP IPv6 Realtek PCI 2.5GBE Family Controller
#
#Firmware Application (101fffff)
#-------------------------------
#identifier              {401c3e37-5c95-11ea-9df4-a8a159046732}
#description             UEFI: PXE IPv6 Realtek PCI 2.5GBE Family Controller
#
#Firmware Application (101fffff)
#-------------------------------
#identifier              {c2f7e4eb-7436-11ea-8833-806e6f6e6963}
#device                  partition=\Device\HarddiskVolume1
#path                    \EFI\MANJARO\GRUBX64.EFI
#description             Manjaro
#
#Firmware Application (101fffff)
#-------------------------------
#identifier              {c2f7e4ec-7436-11ea-8833-806e6f6e6963}
#device                  partition=\Device\HarddiskVolume1
#path                    \EFI\BOOT\BOOTX64.EFI
#description             UEFI OS
#

#################################################################################