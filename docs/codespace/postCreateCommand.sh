#!/bin/bash

# Fix directories permissions
cd /workspaces && sudo chown -R $(whoami) . && sudo setfacl -bnR . \
       && find . -type d -exec echo -n '"{}" ' \; | xargs chmod 755 
       # && find . -type f ! -name "*.sh" -exec echo -n '"{}" ' \; | xargs chmod 644

# Install air https://github.com/cosmtrek/air
# binary will be $(go env GOPATH)/bin/air
curl -sSfL https://raw.githubusercontent.com/cosmtrek/air/master/install.sh | sh -s -- -b $(go env GOPATH)/bin

# Install gh CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

# Install neovim
sudo apt install software-properties-common -y
# Import Stable Neovim PPA
# sudo add-apt-repository ppa:neovim-ppa/stable -y
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt-get update
sudo apt install neovim -y

# Install tmux
sudo apt-get install -y tmux

# Setting dotfiles
cd ~ && gh repo clone juparave/dotfiles .dotfiles 

ln -s ~/.dotfiles/.inputrc ~/.inputrc
ln -s ~/.dotfiles/.vimrc ~/.vimrc
mkdir -p ~/.vim
ln -s ~/.dotfiles/.vim/* ~/.vim
ln -s ~/.dotfiles/.config/nvim_lua/ ~/.config/nvim
ln -s ~/.dotfiles/.tmux* ~/
