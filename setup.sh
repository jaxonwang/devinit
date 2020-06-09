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
        return 1
    fi
    return 0
}

isapt(){
    if [[ $PKG_MNGER == "apt" ]]; then
        return 1
    fi
    return 0
}

if isyum; then
    sudo yum check-update
    sudo yum install epel-release
elif isapt; then
    apt update
fi

# git
sudo $PKG_MNGER install -y git
git config --global user.name "JX Wang"
git config --global user.email "jxwang92@gmail.com"
$echo "Done forget add ssh key to github"


# nvim
# mkdir -p ~/.config/nvim/init.vim
nvim_config="set runtimepath^=~/.vim runtimepath+=~/.vim/after\n
let &packpath=&runtimepath\n
source ~/.vimrc"
echo -e $nvim_config 
# > ~/.config/nvim/init.vim







