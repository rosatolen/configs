#######################################
# SETUP THESE VARIABLES
#######################################
BOOT_DRIVE=/dev/sdb
ENCRYPTED_DRIVE_PARTITION=/dev/sda1
USERNAME=

echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

#######################################
# You may want to change your timezone
#######################################
ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc --utc

##############################################
# Open the /etc/default/grub file and add:
DRIVE_ENCRYPTION_OPTIONS="GRUB_CMDLINE_LINUX_DEFAULT=\"quiet cryptdevice=""$ENCRYPTED_DRIVE_PARTITION"":base root=/dev/mapper/base resume=/dev/mapper/base\""
# cryptdevice=/dev/sda2:base root=/dev/mapper/base resume=/dev/mapper/base
# to GRUB_CMDLINE_LINUX_DEFAULT="..."
##############################################
pacman -S grub os-prober
vi /etc/default/grub
grub-install --recheck $BOOT_DRIVE
grub-mkconfig -o /boot/grub/grub.cfg

##############################################
# Add the word encrypt to the mkinitcpio file
##############################################
MKINITCPIO_ENCRYPTION_HOOKS="HOOKS=\"base udev autodetect modconf block encrypt filesystems keyboard fsck\""
vi etc/mkinitcpio.conf
mkinitcpio -p linux

##############################################
# Add user
##############################################
useradd -m $USERNAME
passwd $USERNAME
