# Cloudspaces

"universal" image that is used by default if no custom Dockerfile or image is specified. https://github.com/microsoft/vscode-dev-containers/tree/main/containers/codespaces-linux 

### Misc preparation

File permissions

    sudo apt-get update
    sudo apt-get install acl
    sudo chown -R $(whoami) .
    sudo setfacl -bnR .
    find . -type d -exec echo -n '"{}" ' \; | xargs chmod 755
    find . -type f -exec echo -n '"{}" ' \; | xargs chmod 644

### Using Docker Compose

* Create a whole develoment environment ref: https://dev.to/cmiles74/really-using-visual-studio-development-containers-561e
* Check this `.devcontainer` configuration too ref: https://github.com/pietheinstrengholt/rssmonster/

## Utils

#### Get Domain name from terminal

    jq -r ".CODESPACE_NAME" /workspaces/.codespaces/shared/environment-variables.json


## Setup new environment

### InputRc

From home directory

    ln -s .dotfiles/.inputrc .

### Install gh cli

    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/
    githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh

### Clone dotfiles and symlink them

    gh repo clone juparave/dotfiles .dotfiles
    ln -s .dotfiles/.vimrc .
    mkdir .vim
    ln -s .dotfiles/.vim/co* .vim/
    ln -s .dotfiles/.tmux.conf* .
  
### Fix Wakatime executable

    cd ~/.wakatime
    ln -s wakatime-cli-linux-amd64 wakatime-cli
