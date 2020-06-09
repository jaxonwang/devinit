if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

shopt -s nocasematch
if [[ $OS == *"centos"* ]]; then
    PKG_MNGER=yum
elif [[ $OS == *"ubuntu"* ]]; then
    PKG_MNGER=apt
elif [[ $OS == *"debian"* ]]; then
    PKG_MNGER=apt
fi
echo "Set the pacakge manager to "$PKG_MNGER

isyum(){
    if [[ $PKG_MNGER == "yum" ]]; then
        return 0 # true
    fi
    return 1
}

isapt(){
    if [[ $PKG_MNGER == "apt" ]]; then
        return 0
    fi
    return 1
}


if isyum; then
    yum check-update
elif isapt; then
    apt update
fi

# in case in container
if [[ $(whoami) == *root* ]]; then
    $PKG_MNGER install -y sudo
fi

# epel
if isyum; then
sudo yum install -y epel-release
yum check-update
fi

# git
sudo $PKG_MNGER install -y git
git config --global user.name "JX Wang"
git config --global user.email "jxwang92@gmail.com"
$echo "Done forget add ssh key to github"

# make
sudo $PKG_MNGER install -y curl make cmake gcc python3 neovim vim ctags
sudo $PKG_MNGER install -y g++ python3-neovim

# to home
CWD=$(pwd)
cd ~

# vimrc
git clone https://github.com/jaxonwang/vimrc
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp ./vimrc/.vimrc ~/
vim -E --not-a-term -c "PlugInstall|q|q"

# config nvim
mkdir -p ~/.config/nvim/
nvim_config="set runtimepath^=~/.vim runtimepath+=~/.vim/after\n
let &packpath=&runtimepath\n
source ~/.vimrc"
echo -e $nvim_config > ~/.config/nvim/init.vim

# ssh key-gen
cat /dev/zero | ssh-keygen -N ""

# finish
cd ${CWD}
