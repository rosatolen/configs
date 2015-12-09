parted /dev/sda mklabel msdos
parted /dev/sda mkpart primary ext3 1MiB 100MiB
parted /dev/sda set 1 boot on
parted /dev/sda mkpart primary ext3 100MiB 100%

###################################################################
# Instructions here will branch for different starting state of disk
# Currently assumes that the disk was previously encrypted
###################################################################
dd if=/dev/urandom of=/dev/sda2 bs=512 count=20480

###################################################################
# Both cryptsetup steps will require a user generated passphrase
cryptsetup luksFormat /dev/sda2
cryptsetup open /dev/sda2 base
###################################################################

mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/mapper/base
mount /dev/mapper/base /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

pacstrap -i /mnt base base-devel
genfstab -U /mnt > /mnt/etc/fstab

###################################################################
# Create branch to check if fstab worked properly
###################################################################

arch-chroot /mnt /bin/bash
