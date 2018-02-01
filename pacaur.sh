####################################################
# This will install pacaur (including dependencies)
####################################################
set -e

# Install Dependency for Cower
sudo pacman -S --noconfirm yajl
gpg2 --list-keys  # Initialize trust_db for the first time
# Get Cower Key (Dave Reisner <d@falconindy.com>)
gpg2 --recv-key '487E ACC0 8557 AD08 2088  DABA 1EB2 638F F56C 0C53'

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
