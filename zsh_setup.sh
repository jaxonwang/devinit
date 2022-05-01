#!/usr/bin/env bash

mkdir ~/.zsh

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.zsh/fast-syntax-highlighting
curl -sSL -O --output-dir ~/.zsh https://raw.githubusercontent.com/agkozak/zsh-z/master/zsh-z.plugin.zsh
curl -sSL -O --output-dir ~/.zsh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/lib/completion.zsh 

cat << EOF >~/.zshrc
source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $HOME/.zsh/zsh-z.plugin.zsh
source $HOME/.zsh/completion.zsh
EOF

