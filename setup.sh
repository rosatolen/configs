#!/bin/bash

set -e

gnupg_src_dir='gnupg-src'
gitcrypt_dir='gitcrypt'

if [[ $1 == 'reset' ]]; then
    rm -r $gnupg_src_dir $gitcrypt_dir 2>/dev/null
    exit
fi

_sudo () {
    echo "Running: '$@' in `pwd`"
    sudo $@
}

pkgmgr_install () {
    if [ -f /etc/fedora-release ]; then
        _sudo dnf install $@
    fi
    if [[ `uname -r` == *"ARCH"* ]]; then
        _sudo pacman -S $@
    fi
}

dev_tools() {
    pkgmgr_install autoconf automake libtool asciidoc texinfo
}

direnv_setup() {
    VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/direnv/direnv/releases/latest | cut -d / -f8)
    wget https://github.com/direnv/direnv/releases/download/$VERSION/direnv.linux-amd64 -O ~/Downloads/direnv.linux-amd64
    mv ~/Downloads/direnv.linux-amd64 ~/Downloads/direnv
    chmod u+x ~/Downloads/direnv
    _sudo mv ~/Downloads/direnv /usr/bin/
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

virtualbox_part1 () {
    wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo
    dnf update
    if [ $(rpm -qa kernel | sort -V | tail -n 1) != kernel-$(uname-r) ]; then
        echo "Kernel versions do not match"
        exit 1
    else
        echo "IMPORTANT!!"
        echo "Reboot before continuing"
    fi
}

virtualbox_part2 () {
    if [ -z "$1" ]; then
        echo "Error: No username supplied for VirtualBox setup"
        echo "Usage: $0 <username>"
        exit
    fi
    pkgmgr_install binutils gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel dkms
    pkgmgr_install VirtualBox-5.0
    _sudo /usr/lib/virtualbox/vboxdrv.sh setup
    usermod -a -G vboxusers $1
    VirtualBox
}

go_setup () {
    pkgmgr_install go
    mkdir .gopath   # Global Gopath
    mkdir .gopaths  # Project Specific Gopath
    cp envrc.example .gopaths
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

tor_setup() {
    pkgmgr_install tor
    pkgmgr_install parcimonie.sh
}

gnupg_setup() {
    dev_tools
    tor_setup

    mkdir $gnupg_src_dir && cd $gnupg_src_dir

    wget https://gnupg.org/signature_key.html
    begin_sig_line_num=$(cat signature_key.html | grep -ne '\-\-\-\-\-BEGIN.*BLOCK\-\-\-\-\-' | sed 's/^\([0-9]\+\):.*$/\1/')
    end_sig_line_num=$(cat signature_key.html | grep -ne '\-\-\-\-\-END.*BLOCK\-\-\-\-\-' | sed 's/^\([0-9]\+\):.*$/\1/')
    sed -n "$begin_sig_line_num"','"$end_sig_line_num"'p' signature_key.html | gpg --import

    wget https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.22.tar.bz2
    wget https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.22.tar.bz2.sig
    gpg --verify libgpg-error-1.22.tar.bz2.sig
    tar xjvf libgpg-error-1.22.tar.bz2
    cd libgpg-error-1.22
    ./autogen.sh
    ./configure --enable-maintainer-mode && make
    _sudo make install
    cd ..

    wget https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.7.0.tar.bz2
    wget https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.7.0.tar.bz2.sig
    gpg --verify libgcrypt-1.7.0.tar.bz2.sig
    tar xjvf libgcrypt-1.7.0.tar.bz2
    cd libgcrypt-1.7.0
    ./autogen.sh
    ./configure --enable-maintainer-mode && make
    _sudo make install
    cd ..

    wget https://gnupg.org/ftp/gcrypt/libassuan/libassuan-2.4.2.tar.bz2
    wget https://gnupg.org/ftp/gcrypt/libassuan/libassuan-2.4.2.tar.bz2.sig
    gpg --verify libassuan-2.4.2.tar.bz2.sig
    tar xjvf libassuan-2.4.2.tar.bz2
    cd libassuan-2.4.2
    ./autogen.sh
    ./configure --enable-maintainer-mode && make
    _sudo make install
    cd ..

    wget https://gnupg.org/ftp/gcrypt/libksba/libksba-1.3.4.tar.bz2
    wget https://gnupg.org/ftp/gcrypt/libksba/libksba-1.3.4.tar.bz2.sig
    gpg --verify libksba-1.3.4.tar.bz2.sig
    tar xjvf libksba-1.3.4.tar.bz2
    cd libksba-1.3.4
    ./autogen.sh
    ./configure --enable-maintainer-mode && make
    _sudo make install
    cd ..

    wget https://gnupg.org/ftp/gcrypt/npth/npth-1.2.tar.bz2
    wget https://gnupg.org/ftp/gcrypt/npth/npth-1.2.tar.bz2.sig
    gpg --verify npth-1.2.tar.bz2.sig
    tar xjvf npth-1.2.tar.bz2
    cd npth-1.2
    ./autogen.sh
    ./configure --enable-maintainer-mode && make
    _sudo make install
    cd ..

    pkgmgr_install gnupg2
}

coyim_setup () {
    tor_setup
    wget https://dl.bintray.com/twstrike/coyim/v0.3.5/linux/amd64/coyim -O ~/Downloads/coyim
    chmod u+x ~/Downloads/coyim
    mv ~/Downloads/coyim /usr/bin
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
}
