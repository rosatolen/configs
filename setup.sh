#!/bin/bash

set -e

gnupg_src_dir='gnupg-src'
gitcrypt_dir='gitcrypt'

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
    VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/direnv/direnv/releases/latest | cut -d / -f8)
    wget https://github.com/direnv/direnv/releases/download/$VERSION/direnv.linux-amd64 -O $HOME/direnv.linux-amd64
    chmod u+x $HOME/direnv.linux-amd64
    _sudo mv $HOME/direnv.linux-amd64 /usr/bin/direnv
}

git_setup () {
    ln -s .gitconfig $HOME/.gitconfig
}

vim_setup () {
    pkgmgr_install vim
    curl https://j.mp/spf13-vim3 -L > spf13-vim.sh && sh spf13-vim.sh
    if [ -f $HOME/.vimrc.local ]; then
        ln -s .vimrc.local $HOME/.vimrc.local
    fi
    if [ -f $HOME/.vimrc.bundles.local ]; then
        ln -s .vimrc.bundles.local $HOME/.vimrc.bundles.local
    fi
    vim +BundleInstall
    rm spf13-vim.sh
}

go_setup () {
    if ! hash go 2>/dev/null; then
        pkgmgr_install go
    fi
    if [ ! -d $HOME/.gopath; ]; then
        mkdir $HOME/.gopath   # Global Gopath
    fi
    if [ ! -d $HOME/.gopaths; ]; then
        mkdir $HOME/.gopaths  # Project Specific Gopath
    fi
    cp ./env.example $HOME/.gopaths
}

yubikey_setup() {
    pkgmgr_install libusb mingw63-qt libyubikey libyubikey-devel

    git clone https://github.com/Yubico/yubico-c
    cd yubico-c
    autoreconf --install
    ./configure
    _sudo make install
    cd ..
    rm yubico-c

    git clone https://github.com/Yubico/yubikey-personalization
    cd yubikey-personalization
    autoreconf --install
    ./configure
    _sudo make install
    cd ..
    rm yubikey-personalization
}

gitcrypt_setup() {
    mkdir gitcrypt && cd gitcrypt
    wget https://www.agwa.name/projects/git-crypt/downloads/git-crypt-0.5.0.tar.gz.asc
    wget https://www.agwa.name/projects/git-crypt/downloads/git-crypt-0.5.0.tar.gz
    wget -O andrew.ayer.asc https://www.agwa.name/about/keys/0xEF5D84C1838F2EB6D8968C0410378EFC2080080C.pub.asc
    gpg --import andrew.ayer.asc
    gpg --verify git-crypt-0.5.0.tar.gz.asc
    tar xvf git-crypt-0.5.0.tar.gz
    cd git-crypt-0.5.0

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

basic_install() {
    gitcrypt_setup
    vim_setup
    ssh_pub_setup $1
    direnv_setup
}
