####################################################
# This will install pacaur (including dependencies)
####################################################
set -e

# Install Dependency for Cower
sudo pacman -S --noconfirm yajl
# Get Cower Key
gpg2 --list-keys  # Initialize trust_db for the first time
gpg2 --search-key 0x1EB2638FF56C0C53

git clone https://aur.archlinux.org/cower.git
cd cower
makepkg -i
cd ..
rm -rf cower

git clone https://aur.archlinux.org/expac-git.git
cd expac-git
makepkg -i
cd ..
rm -rf expac-git

git clone https://aur.archlinux.org/pacaur.git
cd pacaur
makepkg -i
cd ..
rm -rf pacaur
