#!/bin/bash 

# quick n dirty, have to do it right when there is time
 
scp -r $1 ARENART1+arena@arenart1:$1
scp -r $1 ARENART2+arena@arenart2:$1
scp -r $1 ARENART3+arena@arenart3:$1
scp -r $1 ARENART4+arena@arenart4:$1
scp -r $1 ARENART5+arena@arenart5:$1

