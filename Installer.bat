@echo off
title Renegade Project Installer
:menu 
ECHO      ____                                  __        ____               _           __ 
ECHO     / __ \___  ____  ___  ____ _____ _____/ ___     / __ \_________    (____  _____/ /_
ECHO    / /_/ / _ \/ __ \/ _ \/ __ `/ __ `/ __  / _ \   / /_/ / ___/ __ \  / / _ \/ ___/ __/
ECHO   / _, _/  __/ / / /  __/ /_/ / /_/ / /_/ /  __/  / ____/ /  / /_/ / / /  __/ /__/ /_  
ECHO  /_/ /_/\___/_/ /_/\___/\__, /\__,_/\__,_/\___/  /_/   /_/   \______/ /\___/\___/\__/  
ECHO                        /____/                                    /___/                
ECHO ---------------------------------------------------------------------------------------

ECHO 1- Unlock Bootloader (Fastboot Mode)
ECHO 2- Flash Orangefox Recovery (Fastboot Mode)
ECHO 3- Partition the UFS (Recovery Mode)
ECHO 4- Flash UEFI (Fastboot Mode)
ECHO 5- Reboot to Fastboot Mode on Recovery
ECHO 0- Exit
ECHO ---------------------------------------------------------------------------------------
ECHO Please select your choice.

set /P a=
if /I "%a%" EQU "1" goto :bootloader
if /I "%a%" EQU "2" goto :orangefoxrecovery
if /I "%a%" EQU "3" goto :ufs
if /I "%a%" EQU "4" goto :uefi
if /I "%a%" EQU "5" goto :rebootfastboot
if /I "%a%" EQU "0"  exit

cls &&goto :menu
:bootloader
start "" https://community.oneplus.com/thread/548216
cls
goto menu

:orangefoxrecovery
fastboot flash recovery orangefoxop5.img
fastboot boot orangefoxop5.img
cls
goto menu

:ufs
adb push parted /sbin/
adb shell chmod 755 /sbin/parted

cls
goto menu2

:uefi
adb reboot bootloader
fastboot flash boot boot-cheeseburger.img
fastboot boot boot-cheeseburger.img
cls
goto menu

:rebootfastboot
adb reboot bootloader
cls
goto menu

:menu2
ECHO 1- Delete userdata partition
ECHO 2- Create esp,win,pe,userdata partition
ECHO 3- Delete esp,win,pe,userdata partition
ECHO 4- Copy Windows Pe files to pe partition
ECHO 9- List Partition
ECHO 0- Home
ECHO Please select your choice.

set /P b=
if /I "%b%" EQU "1" goto :userdatadelete
if /I "%b%" EQU "2" goto :partitioncreate
if /I "%b%" EQU "3" goto :partitiondelete
if /I "%b%" EQU "4" goto :pecopy
if /I "%b%" EQU "9" goto :parted
if /I "%b%" EQU "0" cls && goto :menu
if /I "%b%" EQU ""  cls && goto :menu2

:userdatadelete
cls
adb shell parted /dev/block/sda print
ECHO Enter the userdata partition number
set /P userdatanumber=
adb shell parted /dev/block/sda rm %userdatanumber%
cls && goto menu2

:partitioncreate
cls
ECHO Creating esp partition...
adb shell parted /dev/block/sda mkpart esp fat32 6559MB 7000MB
adb shell parted /dev/block/sda set 13 esp on
adb shell mkfs.fat -F32 -s1 /dev/block/sda13

ECHO Creating win partition...
adb shell parted /dev/block/sda mkpart win ntfs 7000MB 92GB
adb shell mkfs.ntfs -f /dev/block/sda14

ECHO Creating pe partition...
adb shell parted /dev/block/sda mkpart pe fat32 92GB 93GB
adb shell mkfs.fat -F32 -s1 /dev/block/sda15

ECHO Creating userdata partition...
adb shell parted /dev/block/sda mkpart userdata ext4 93GB 122GB
adb shell mke2fs -t ext4 /dev/block/sda16

cls

ECHO Rebooting Recovery...
adb shell reboot recovery

goto menu

:partitiondelete
cls
adb shell parted /dev/block/sda print

ECHO Enter the esp partition number
set /P deletepartition=
if /I "%deletepartition%" EQU ""  goto :menu2
adb shell parted /dev/block/sda rm %deletepartition%
adb shell parted /dev/block/sda print

ECHO Enter the win partition number
set /P deletepartition=
if /I "%deletepartition%" EQU ""  goto :menu2
adb shell parted /dev/block/sda rm %deletepartition%
adb shell parted /dev/block/sda print

ECHO Enter the pe partition number
set /P deletepartition=
if /I "%deletepartition%" EQU ""  goto :menu2
adb shell parted /dev/block/sda rm %deletepartition%
adb shell parted /dev/block/sda print

ECHO Enter the userdata partition number
set /P deletepartition=
if /I "%deletepartition%" EQU ""  goto :menu2
adb shell parted /dev/block/sda rm %deletepartition%
adb shell parted /dev/block/sda print

cls && goto menu2

:pecopy

adb shell mount /dev/block/by-name/pe /mnt
adb push pe.zip /sdcard
adb shell unzip /sdcard/pe.zip -d /mnt
cls && goto menu2

:parted
cls
adb push parted /sbin/
adb shell chmod 755 /sbin/parted
adb shell parted /dev/block/sda print
goto menu2

