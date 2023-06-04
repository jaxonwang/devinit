set -x
set -e

# find distribution
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

# find arch
case $(uname -m) in
    x86_64 | x86-64 | x64 | amd64)
        ARCH=amd64
        ;;
    aarch64 | arm64)
        ARCH=arm64
        ;;
    *)
        err "CPU archtecture not supported."
        ;;
esac

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


# in case in container
if [[ $(whoami) == *root* ]]; then
    if isyum; then
        yum check-update
    elif isapt; then
        apt update
    fi
    $PKG_MNGER install -y sudo
fi

PKG_OPTS=-y
if isyum; then
    sudo yum check-update
    PKG_OPTS="$PKG_OPTS --skip-broken"
elif isapt; then
    sudo apt update
fi

# epel
if isyum; then
sudo yum install -y epel-release
yum check-update
fi

# install many
sudo $PKG_MNGER install $PKG_OPTS git curl wget \
make cmake autoconf automake \
gcc g++ clang python3 \
neovim vim python3-neovim \
zsh

# git
git config --global user.name "JX Wang"
git config --global user.email "jxwang92@gmail.com"
git config --global core.excludesFile '~/.gitignore_global'
echo "Done forget add ssh key to github"
cat << EOF >> ~/.gitignore_global
*.swp
*.swo
*.iml
build/
EOF

# change shell
sudo usermod -s $(which zsh) $(whoami)

# conda
case $ARCH in
    amd64)
        CONDA_LATEST_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        ;;
    arm64)
        CONDA_LATEST_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh
        ;;
esac
curl -L -o ~/miniconda.sh $CONDA_LATEST_URL
bash ~/miniconda.sh -b -p $HOME/miniconda
rm ~/miniconda.sh
eval "$($HOME/miniconda/bin/conda shell.bash hook)" # shell setup for conda activation
conda init
conda init zsh

# rust
curl https://sh.rustup.rs | sh -s -- -y

# vimrc
git clone https://github.com/jaxonwang/vimrc ~/vimrc
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ln -s ~/vimrc/.vimrc ~/.vimrc
ln -s ~/vimrc/.ideavimrc ~/.ideavimrc
# vim +'PlugInstall --sync' +qa

# config nvim
mkdir -p ~/.config/nvim/
nvim_config="set runtimepath^=~/.vim runtimepath+=~/.vim/after\n
let &packpath=&runtimepath\n
source ~/.vimrc"
echo -e $nvim_config > ~/.config/nvim/init.vim

# ssh key-gen
cat /dev/zero | ssh-keygen -N "" -t ed25519

# set editor
echo 'export VISUAL="vim"' >> ~/.bashrc
echo 'export EDITOR="$VISUAL"' >> ~/.bashrc
