_sudo () {
    echo "Running: sudo '$@' in `pwd`"
    sudo $@
}


## TODO: script to verify the ArchLinux ISO

##if [ "$#" -ne 3 ]; then
##    echo "Usage: $0 <location of ArchLinux ISO>"
##    exit 1
##fi

ISO_LOCATION=$HOME/Downloads/archlinux-2018.01.01-x86_64.iso
UNMOUNTED_DRIVE=/dev/sdb

_sudo dd bs=4M if=$ISO_LOCATION of=$UNMOUNTED_DRIVE status=progress oflag=sync

[ -z $(lsblk -f | grep ARCHISO) ] && echo 'ISO not installed correctly. Check installation using lsblk'
