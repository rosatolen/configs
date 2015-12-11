##########################
# Comment out en_US.UTF-8
##########################
vi /etc/locale.gen

locale-gen

echo 'LANG=en_US.UTF-8' > /etc/locale.conf

#######################################
# You may want to change your timezone
#######################################
ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

hwclock --systohc --utc

##############################################
# Open the /etc/default/grub file and add:
# * cryptdevice=/dev/sda2:base
# * root=/dev/mapper/base
# * resume=/dev/mapper/base
# to GRUB_CMDLINE_LINUX_DEFAULT="..."
##############################################
pacman -S grub os-prober
vi /etc/default/grub
grub-install --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

##############################################
# Add the word encrypt to the mkinitcpio file
##############################################
vi etc/mkinitcpio.conf
mkinitcpio -p linux
