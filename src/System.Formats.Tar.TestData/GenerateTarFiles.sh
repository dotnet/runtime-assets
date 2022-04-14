#/bin/bash

# Script that generates tar files for the contents of all the folders located inside the folder
# runtime-assets/src/System.Formats.Tar.TestData/TarTestData/unarchived/
# and saves them in additional new folders under 'TarTestData', one folder for each compression method.
# The user executing this script must be part of the sudo group.

# The tests should verify these preselected permission and ownership values
TarUser="dotnet"
TarGroup="devdiv"
TarUserId=7913
TarGroupId=3579

# These DevMajor and DevMinor numbers have no meaning, but those are the
# numbers that the tests should look for when reading device files.
CharDevMajor=49
CharDevMinor=86
BlockDevMajor=71
BlockDevMinor=53
# The Mode for all filesystem entries is set to 744 (rwx,r,r) inside the method ChangeUnarchivedMode

# pax_gea is a special case for the pax format that includes global extended attributes
FormatsArray=( "v7" "ustar" "pax" "pax_gea" "oldgnu" "gnu" )

# .NET currently only offers Gzip compression of all the ones tar supports
CompressionMethodsArray=( "tar" "targz" )

GEAKey="globexthdr.MyGlobalExtendedAttribute"
GEAValue="hello"
GEAPAXOptions="--pax-option=$GEAKey=$GEAValue"

### FUNCTIONS ###

function Echo()
{
    Color=$1
    Message=$2
    OriginalColor="\e[0m"

    echo -e "$Color$Message$OriginalColor"
}

function EchoError()
{
    red="\e[31m"
    Echo $red "$1"
}

function EchoWarning()
{
    yellow="\e[33m"
    Echo $yellow "$1"
}

function EchoSuccess()
{
    green="\e[32m"
    Echo $green "$1"
}

function EchoInfo()
{
    cyan="\e[36m"
    Echo $cyan "$1"
}

function CheckLastErrorOrExit()
{
    message=$1

    if [ $? -ne 0 ]; then
        EchoError "Failure: $message"
        EchoError "Script failed to finish."
        exit 1
    else
        EchoSuccess "Success: $message"
    fi
}

function ConfirmDirExists()
{
    Dir=$1

    if [ ! -d $Dir ]; then
        EchoError "Directory did not exist: $Dir"
        exit 1
    fi
}

function DeleteAndRecreateDir()
{
    Dir=$1

    if [ -d $Dir ]; then
        EchoWarning "Deleting folder: $Dir"
        sudo rm -r $Dir
    fi

    EchoWarning "Creating folder: $Dir"
    mkdir $Dir

    ConfirmDirExists $Dir
}

function ExecuteTar()
{
    FullPathFolderToArchive=$1
    Arguments=$2
    FileName=$3
    Format=$4
    WithGEA=$5

    EchoSuccess "----------------------------------------------"

    GEAArgument=""
    FormatArgument="$Format"
    if [ $Format = "pax_gea" ] && [ $WithGEA = 1 ]; then
        EchoWarning "Creating extra pax file with global a extended attributes entry"
        FormatArgument="pax"
        GEAArgument="$GEAPAXOptions"
    fi

    # IMPORTANT: "-C" will ensure we archive entries that have relative paths to this folder
    TarCommand="tar $Arguments $FileName -C $FullPathFolderToArchive $(ls $FullPathFolderToArchive) --format=$FormatArgument $GEAArgument"
    EchoInfo "$TarCommand"

    # Execute the command as the user that owns the files
    # to archive, otherwise tar fails to pack them
    sudo $TarCommand

    if [ $? -ne 0 ]; then
        EchoError "Tar command failed!"
        if [ -f $FileName ]; then
            EchoError "Deleting malformed file: $FileName"
            sudo rm $FileName
        fi
    else
        EchoSuccess "Tar archive created successfully: $FileName"
    fi

    EchoSuccess "----------------------------------------------"
}

function GenerateArchive()
{
    DirsRoot=$1
    TargetDir=$2
    Arguments=$3
    Extension=$4

    UnarchivedDir="$DirsRoot/unarchived"
    FoldersToArchiveArray=($(sudo ls $UnarchivedDir))

    for Format in "${FormatsArray[@]}"; do

        OutputDir="$TargetDir/$Format"
        DeleteAndRecreateDir $OutputDir

        for FolderToArchive in "${FoldersToArchiveArray[@]}"; do

            if [ $Format = "v7" ]; then
                if [ $FolderToArchive = "longpath_over255" ] || [ $FolderToArchive = "longpath_splitable_under255" ] || [ $FolderToArchive = "longfilename_over100_under255" ] || [ $FolderToArchive = "specialfiles" ]; then
                    EchoWarning "Skipping V7 unsupported folder: $FolderToArchive"
                    continue
                fi
            fi

            FullPathFolderToArchive="$UnarchivedDir/$FolderToArchive/"
            FileName="$OutputDir/$FolderToArchive$Extension"

            WithGEA=0
            if [ $Format = "pax_gea" ]; then
                WithGEA=1
            fi

            ExecuteTar "$FullPathFolderToArchive" "$Arguments" "$FileName" "$Format" $WithGEA

        done
    done

    # Tar was executed elevated, need to ensure the
    # generated archives are readable by current user
    ResetOwnership $TargetDir
}

function GenerateTarArchives()
{
    DirsRoot=$1
    TargetDir=$2
    CompressionMethod=$3

    if [ $CompressionMethod = "tar" ]; then
        GenerateArchive $DirsRoot $TargetDir "cvf" ".tar"

    elif [ $CompressionMethod = "targz" ]; then
        GenerateArchive $DirsRoot $TargetDir "cvzf" ".tar.gz"

    else
        EchoError "Unsupported compression method: $CompressionMethod"
        exit 1
    fi
}

function GenerateCompressionMethodDir()
{
    DirsRoot=$1
    CompressionMethod=$2

    TargetDir="$DirsRoot/$CompressionMethod"
    DeleteAndRecreateDir $TargetDir

    GenerateTarArchives "$DirsRoot" "$TargetDir" "$CompressionMethod"
}

function Generate()
{
    DirsRoot=$1

    for CompressionMethod in "${CompressionMethodsArray[@]}"; do
        GenerateCompressionMethodDir "$DirsRoot" "$CompressionMethod"
    done
}

function ConfirmUserAndGroupExist()
{
    EchoWarning "Checking if user '$TarUser' and group '$TarGroup' exist..."

    if [ $(getent group $TarGroup) ]; then
        EchoSuccess "Group '$TarGroup' exists. No action taken."

    else
        EchoWarning "Group '$TarGroup' does not exist. Adding it."
        sudo groupadd $TarGroup
        EchoWarning "Changing id of '$TarGroup' to $TarGroupId"
        sudo groupmod -g $TarGroupId $TarGroup
    fi

    if id $TarUser &>/dev/null; then
        EchoSuccess "User '$TarUser' exists. No action taken."

    else
        EchoWarning "User '$TarUser' does not exist. Adding it."
        sudo useradd $TarUser
        EchoWarning "Changing id of '$TarUser' to $TarUserId"
        sudo usermod -u $TarUserId $TarUser
        EchoWarning "Adding new '$TarUser' user to new '$TarGroup' group."
        sudo usermod -a -G $TarGroup $TarUser
        EchoWarning "Setting password for new '$TarUser' user."
        sudo passwd $TarUser
    fi
}

function ResetOwnership()
{
    Folder=$1

    CurrentUser=$(id -u)
    CurrentGroup=$(id -g)

    sudo chown -R $CurrentUser:$CurrentGroup "$Folder"
    CheckLastErrorOrExit "Chown $CurrentUser:$CurrentGroup $Folder"
}

function ChangeUnarchivedOwnership()
{
    DirsRoot=$1

    UnarchivedDir=$DirsRoot/unarchived
    UnarchivedDirContents=$UnarchivedDir/*
    UnarchivedChildrenArray=($(sudo ls $UnarchivedDir))

    # First, we recursively change ownership of all files and folders
    EchoWarning "Changing ownership of contents of 'unarchived' folder to '$TarUser:$TarGroup'."
    sudo chown -R $TarUser:$TarGroup $UnarchivedDirContents
    CheckLastErrorOrExit "Chown $TarUser:$TarGroup $UnarchivedDirContents"

    # Second, we revert the ownership of the parent folders (no recursion).
    for UnarchivedChildDir in "${UnarchivedChildrenArray[@]}"; do
        EchoWarning "Preserving ownership of child folder: $UnarchivedChildDir"
        sudo chown $TarUserId:$TarGroupId $UnarchivedDir/$UnarchivedChildDir
        CheckLastErrorOrExit "Chown $TarUserId:$TarGroupId $UnarchivedChildDir"
    done
}

function ResetUnarchivedOwnership()
{
    DirsRoot=$1

    ResetOwnership "$DirsRoot/unarchived"
}

function ChangeUnarchivedMode()
{
    DirsRoot=$1

    EchoWarning "Setting 744 (rwx,r,r) permissions to contents of 'unarchived' folder."

    UnarchivedDirContents=$DirsRoot/unarchived/*

    # 744
    sudo chmod -R a=r $UnarchivedDirContents
    CheckLastErrorOrExit "Chmod a=r $UnarchivedDirContents"

    sudo chmod -R u+wx $UnarchivedDirContents
    CheckLastErrorOrExit "Chmod u+wx $UnarchivedDirContents"

    sudo chmod -R g-wx $UnarchivedDirContents
    CheckLastErrorOrExit "Chmod g-wx $UnarchivedDirContents"

    sudo chmod -R o-wx $UnarchivedDirContents
    CheckLastErrorOrExit "Chmod o-wx $UnarchivedDirContents"
}

# Character device, block device and fifo file (named pipe).
function CreateSpecialFiles()
{
    DirsRoot=$1

    DevicesDir=$DirsRoot/unarchived/specialfiles
    CharacterDevice=$DevicesDir/chardev
    BlockDevice=$DevicesDir/blockdev
    FifoFile=$DevicesDir/fifofile

    if [ -d $DevicesDir ]; then
        EchoSuccess "Devices folder exists. No action taken."
    else
        # Empty directories can't get added to git
        EchoWarning "Devices folder does not exist. Creating it: $DevicesDir"
        mkdir $DevicesDir
    fi

    if [ -c $CharacterDevice ]; then
        EchoSuccess "Character device exists. No action taken."
    else
        EchoWarning "Character device does not exist. Creating it: $CharacterDevice"
        sudo mknod $CharacterDevice c $CharDevMajor $CharDevMinor
        CheckLastErrorOrExit "Creating character device $CharacterDevice"
        sudo chown $TarUserId:$TarGroupId $CharacterDevice
        CheckLastErrorOrExit "chown $TarUserId:$TarGroupId $CharacterDevice"
    fi

    if [ -b $BlockDevice ]; then
        EchoSuccess "Block device exists. No action taken."
    else
        EchoWarning "Block device does not exist. Creating it: $BlockDevice"
        sudo mknod $BlockDevice b $BlockDevMajor $BlockDevMinor
        CheckLastErrorOrExit "Creating block device $BlockDevice"
        sudo chown $TarUserId:$TarGroupId $BlockDevice
        CheckLastErrorOrExit "chown $TarUserId:$TarGroupId $BlockDevice"
    fi

    if [ -p $FifoFile ]; then
        EchoSuccess "Fifo file exists. No action taken."
    else
        EchoWarning "Fifo file does not exist. Creating it: $FifoFile"
        sudo mknod $FifoFile p
        CheckLastErrorOrExit "Creating fifo file $FifoFile"
        sudo chown $TarUserId:$TarGroupId $FifoFile
        CheckLastErrorOrExit "chown $TarUserId:$TarGroupId $FifoFile"
    fi
}

function CreateLongDirAndLongFile()
{
    DirsRoot=$1

    TestName=$2
    DirName=$3
    FileName=$4
    TestDir="$DirsRoot/unarchived/$TestName"

    if [ ! -d $TestDir ]; then
        EchoInfo "Restoring $TestName root directory"
        sudo mkdir $TestDir
        CheckLastErrorOrExit "mkdir $TestDir"
    fi

    # The long directory is optional
    LongDirPath="$TestDir"
    if [ ! -z $DirName ]; then
        LongDirPath="$TestDir/$DirName"
        if [ ! -d $LongDirPath ]; then
            EchoInfo "Restoring $TestName directory that VS does not support"
            sudo mkdir $LongDirPath
            CheckLastErrorOrExit "mkdir $LongDirPath"
        fi
    fi

    LongFilePath="$LongDirPath/$FileName"

    if [ ! -f $LongFilePath ]; then
        EchoInfo "Restoring $TestName file that VS does not support"
        sudo sh -c "echo \"Hello $TestName\" > $LongFilePath"
        CheckLastErrorOrExit "echo 'Hello $TestName' > $LongFilePath"
    fi
}

# These files cannot be packed correctly by nuget, or have too long paths that VS cannot render them and fails to load the test project.
function ResetUnsupportedFiles()
{
    DirsRoot=$1

    # Creates a file at the test root folder with a name that is between 100 and 255 bytes
    CreateLongDirAndLongFile $DirsRoot "longfilename_over100_under255" "" "000000000011111111112222222222333333333344444444445555555555666666666677777777778888888888999999999900000000001111111111222222222233333333334444444444.txt"

    # Creates a directory at the test root folder with a name that is 255 bytes in length,
    # and a file inside of that folder, with a name that is 255 bytes in length
    CreateLongDirAndLongFile $DirsRoot "longpath_over255" "000000000011111111112222222222333333333344444444445555555555666666666677777777778888888888999999999900000000001111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000111111111122222222223333333333444444444455555" "00000000001111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999000000000011111111112222222222333333333344444444445.txt"

    # Creates a directory at the test root folder with a name that is 98 bytes in length,
    # and a file inside of that folder, with a name that is 99 bytes in length
    CreateLongDirAndLongFile $DirsRoot "longpath_splitable_under255" "00000000001111111111222222222233333333334444444444555555555566666666667777777777888888888899999999" "00000000001111111111222222222233333333334444444444555555555566666666667777777777888888888899999.txt"

    # Creates a directory at the test root folder with a name that is 255 bytes in length,
    # then a file inside of that folder, with a name that is 255 bytes in length,
    # and then a symbolic link inside of that folder, with the name 'link.txt'
    CreateLongDirAndLongFile $DirsRoot "file_longsymlink" "000000000011111111112222222222333333333344444444445555555555666666666677777777778888888888999999999900000000001111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000111111111122222222223333333333444444444455555" "00000000001111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999000000000011111111112222222222333333333344444444445.txt"
    SymlinkPath="$DirsRoot/unarchived/file_longsymlink/link.txt"
    TargetPath="000000000011111111112222222222333333333344444444445555555555666666666677777777778888888888999999999900000000001111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000111111111122222222223333333333444444444455555/00000000001111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999000000000011111111112222222222333333333344444444445.txt"
    if [ ! -L $SymlinkPath ]; then
        EchoInfo "Restoring $TestName that nupkg does not support"
        sudo ln -s $TargetPath $SymlinkPath
        CheckLastErrorOrExit "ln -s $TargetPath $SymlinkPath"
    fi
}

# Keep the root folders, delete the unsupported contents
function RemoveUnsupportedFiles()
{
    DirsRoot=$1

    TestDirs=( "file_longsymlink" "longfilename_over100_under255" "longpath_over255" "longpath_splitable_under255" "specialfiles" )

    EchoInfo "Deleting unsupported folders..."
    for FolderName in "${TestDirs[@]}"; do
        TestDir="$DirsRoot/unarchived/$FolderName"
        if [ -d $TestDir ]; then
            EchoWarning "Deleting unsupported root folder: $TestDir"
            sudo rm -r $TestDir
            CheckLastErrorOrExit "rm -r $TestDir"
        else
            EchoError "Folder was not found: $TestDir"
        fi
    done
}

function BeginGeneration()
{
    DirsRoot=$1
    ConfirmUserAndGroupExist
    ConfirmDirExists $DirsRoot
    ResetUnsupportedFiles $DirsRoot
    ChangeUnarchivedMode $DirsRoot
    ChangeUnarchivedOwnership $DirsRoot
    CreateSpecialFiles $DirsRoot
    Generate $DirsRoot
    ResetUnarchivedOwnership $DirsRoot
    RemoveUnsupportedFiles $DirsRoot
    EchoSuccess "Script finished successfully!"
}

### SCRIPT EXECUTION ###

# IMPORTANT: Do not move the script to another location.
# It assumes it's located inside the 'TarTestData' folder, and on the same level as the 'unarchived' folder.
ScriptPath=$(readlink -f $0)
DirsRoot=$(dirname $ScriptPath)

BeginGeneration $DirsRoot
