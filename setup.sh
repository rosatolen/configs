#!/bin/bash

set -e

if [[ $1 == 'reset' ]]; then
    rm -r $gnupg_src_dir $gitcrypt_dir 2>/dev/null
    exit
fi

_sudo () { echo "Running: '$@' in `pwd`"; sudo $@; }

isArch() { return $([[ `uname -r` == *"ARCH"* ]]); }

pkgmgr_install () {
    if [ -f /etc/fedora-release ]; then
        _sudo dnf install $@
    elif isArch; then
        _sudo pacman -S $@
    fi
}

dev_tools() {
    pkgmgr_install autoconf automake libtool asciidoc texinfo
}

direnv_setup() {
    if isArch; then
        pacaur -y direnv
    else
        VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/direnv/direnv/releases/latest | cut -d / -f8)
        wget https://github.com/direnv/direnv/releases/download/$VERSION/direnv.linux-amd64 -O $HOME/direnv.linux-amd64
        chmod u+x $HOME/direnv.linux-amd64
        _sudo mv $HOME/direnv.linux-amd64 /usr/bin/direnv
    fi
}

git_setup () {
    #This should be done in the configs folder :(
    ln -s $(pwd)/.gitconfig $HOME/.gitconfig
}

vim_setup () {
    #This should be done in the configs folder :(
    pkgmgr_install vim vim-systemd
    curl https://j.mp/spf13-vim3 -L > spf13-vim.sh && sh spf13-vim.sh
    #TODO: check if this file exists before trying to remove it
    #rm $HOME/.vimrc.local
    ln -s $(pwd)/.vimrc.local $HOME/.vimrc.local
    #TODO: check if this file exists before trying to remove it
    #rm $HOME/.vimrc.bundles.local
    ln -s $(pwd)/.vimrc.bundles.local $HOME/.vimrc.bundles.local
    vim +BundleInstall
    rm spf13-vim.sh
}

go_setup () {
    if [ ! hash go 2>/dev/null ]; then
        pkgmgr_install go
    fi
    if [ ! -d $HOME/.gopath ]; then
        mkdir $HOME/.gopath   # Global Gopath
    fi
    if [ ! -d $HOME/.gopaths ]; then
        mkdir $HOME/.gopaths  # Project Specific Gopath
    fi
    cp ./env.example $HOME/.gopaths
}

gitcrypt_setup() {
    mkdir gitcrypt && cd gitcrypt
    VERSION=0.6.0
    wget https://www.agwa.name/projects/git-crypt/downloads/git-crypt-$VERSION.tar.gz.asc
    wget https://www.agwa.name/projects/git-crypt/downloads/git-crypt-$VERSION.tar.gz
    #wget -O andrew.ayer.asc https://www.agwa.name/about/keys/0xEF5D84C1838F2EB6D8968C0410378EFC2080080C.pub.asc
    #gpg --import andrew.ayer.asc
    gpg --verify git-crypt-$VERSION.tar.gz.asc
    tar xvf git-crypt-$VERSION.tar.gz
    cd git-crypt-$VERSION

    make
    _sudo make install
    cd ..
    cd ..
    rm gitcrypt
}

lenovo_setup() {
    pkgmgr_install alsa-utils
    pkgmgr_install xf86-input-synaptics
}

ssh_pub_setup() {
    if [[ -z "$1" ]]; then
        echo "Usage: $0 <email>"
        echo "Please pass in the email you wish to associate this ssh key with"
        exit 1
    fi
    ssh-keygen -t rsa -b 4096 -C "$1"
    eval "$(ssh-agent)"
    ssh-add ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub
}

gnome_setup() {
    pkgmgr_install gnome gdm networkmanager network-manager-applet dhclient
    _sudo systemctl enable gdm
    _sudo systemctl enable NetworkManager.service
}

basic_install() {
    lenovo_setup
    # THIS IS ORDERED
    gitcrypt_setup
    # UNLOCK REPO HERE
    git_setup
    vim_setup
    direnv_setup
}
