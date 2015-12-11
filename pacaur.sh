git clone https://aur.archlinux.org/cower.git
cd cower
makepkg -i
cd ..
rm -r cower

git clone https://aur.archlinux.org/expac-git.git
cd expac-git
makepkg -i
cd ..
rm -r expac-git

git clone https://aur.archlinux.org/pacaur.git
cd pacaur
makepkg -i
cd ..
rm -r pacaur
