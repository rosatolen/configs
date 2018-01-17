#######################################################################
# SETUP VARIABLES
#######################################################################
BOOT_DEVICE=/dev/sdb
BOOT_DEVICE_PARTITION=/dev/sdb1
MAIN_DRIVE=/dev/sda
MAIN_DRIVE_PARTITION=/dev/sda1



parted $BOOT_DEVICE mklabel msdos
parted $BOOT_DEVICE mkpart primary ext3 1MiB 100MiB
parted $BOOT_DEVICE set 1 boot on
parted $MAIN_DRIVE mklabel msdos
parted $MAIN_DRIVE mkpart primary ext3 100MiB 100%

#######################################################################
# Instructions here should branch for different starting state of disk
#######################################################################
# Currently assumes that the disk was previously encrypted
# Remove previous LUKS key
dd if=/dev/urandom of=$MAIN_DRIVE_PARTITION bs=512 count=20480

###################################################################
# Both cryptsetup steps will require a user generated passphrase
cryptsetup luksFormat $MAIN_DRIVE_PARTITION
cryptsetup open $MAIN_DRIVE_PARTITION base
###################################################################

mkfs.ext4 $BOOT_DEVICE_PARTITION
mkfs.ext4 /dev/mapper/base
mount /dev/mapper/base /mnt
mkdir /mnt/boot
mount $BOOT_DEVICE_PARTITION /mnt/boot

pacstrap -i /mnt base base-devel

genfstab -U /mnt > /mnt/etc/fstab
###################################################################
# Create branch to check if fstab worked properly
###################################################################
vim /mnt/etc/fstab

arch-chroot /mnt /bin/bash
