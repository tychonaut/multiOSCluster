#!/usr/bin/env python3

# code ported from https://github.com/chengxuncc/booToLinux/blob/master/main.go:

import sys

osDescriptorToFindIdentifierFor = sys.argv[1]
stringToProcess = sys.argv[2]


# firmwareLines:=strings.Split(stdout,"\r\n")
firmwareLines = stringToProcess.split("\r\n")
#print(firmwareLines)

# var identifierList []string
identifierList = []

# currentIdentifier :=""
currentIdentifier = ""

# UEFIBootList:=make(map[string]string)
UEFIBootDictionary = dict([])

# for _,line:=range firmwareLines
# {

windowsIDActive = False
for line in firmwareLines:

    # if len(line)==0 || line[0]=='-'{
    #    continue
    # }
    if len(line) == 0 or line[0] == '-':
        continue

    # lineSplit := strings.Split(line, `  `)
    # switch lineSplit[0] {
    #     case "identifier":
    #         currentIdentifier =lineSplit[len(lineSplit)-1]
    #         identifierList=append(identifierList,currentIdentifier)
    #     case "description":
    #         description:=lineSplit[len(lineSplit)-1]
    #         description=strings.Trim(description,` `)
    #         UEFIBootList[currentIdentifier]=description
    # }
    line_splitIntoWords = line.split(" ")
    firstWordOfLine = line_splitIntoWords[0]
    lastWordsOfLine = " ". join(line_splitIntoWords[1:])
    # remove leading and trailing whitespaces
    lastWordsOfLine = lastWordsOfLine.strip()


    if firstWordOfLine == "identifier":
        currentIdentifier = lastWordsOfLine

        # filter out windows and firmware - related stuff, as these loader types' entries
        # are inconsistent to the rest; on the other hand, the mnemonic for the firmware manager
        # makes this search obolete anyway:
        if currentIdentifier in ["{fwbootmgr}", "{bootmgr}"]:
            windowsIDActive = True
        else:
            identifierList.append(currentIdentifier)
            windowsIDActive = False
    elif firstWordOfLine == "description" and not windowsIDActive:
        currentDescription = lastWordsOfLine
        UEFIBootDictionary[currentDescription] = currentIdentifier
        windowsIDActive = False

# print("DEBUG: UEFIBootDictionary:\n", UEFIBootDictionary)

if not osDescriptorToFindIdentifierFor in UEFIBootDictionary:
    print("Error! given OS named ", osDescriptorToFindIdentifierFor, "not found in UEFI description entries!")
    exit(-1)
else:
    print(UEFIBootDictionary[osDescriptorToFindIdentifierFor])
    # indicate success to the caller of the script:
    exit(0)
# }
