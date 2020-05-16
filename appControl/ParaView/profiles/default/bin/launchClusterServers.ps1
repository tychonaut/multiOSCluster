
#mpiexec.exe -np 2 -machinefile D:\apps\ParaView\v5.8.0_CAVE\bin\machines.txt  D:\apps\ParaView\v5.8.0_CAVE\bin\pvserver.exe D:\apps\ParaView\v5.8.0_CAVE\bin\dome_arena.pvx


#--reverse-connection --client-host=arenamaster
# --log=myPvserverLog.txt,9

mpiexec.exe -np 2 -machinefile D:\apps\ParaView\v5.8.0_CAVE\bin\machines.txt  D:\apps\ParaView\v5.8.0_CAVE\bin\pvserver.exe --mpi --force-onscreen-rendering  D:\apps\ParaView\v5.8.0_CAVE\bin\dome_arena.pvx