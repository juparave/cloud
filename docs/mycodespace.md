# MyCodespace

Using remote tmux to emulate codespace feel

### Dependencies

NodeJS

    $ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
    $ nvm install 16
    $ nvm use 16

Neovim modules for python3 and node

    $ pip3 install neovim
    $ npm install -g neovim

```bash
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# node's NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

### golang
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
```


   19  gh
   20  cat /etc/issue
   21  su -
   22  gh
   23  gh repo --help
   24  ls
   25  mkdir workspace
   26  cd $_
   27  gh repo clone juparave/gowebstore
   28  gh --version
   29  gh -version
   30  gh version
   31  gh --help
   32  git clone git@github.com:juparave/gowebstore.git
   33  ssh-keygen -b 2048 -t rsa
   34  cat ~/.ssh/id_rsa.pub
   35  git clone git@github.com:juparave/gowebstore.git
   36  ls
   37  cd ..
   38  ls
   39  git clone git@github.com:juparave/dotfiles.git .dotfiles
   40  ls
   41  ls -lsa
   42  rm .bashrc
   43  ln -s .dotfiles/.bashrc .
   44  ls -lsa
   45  ln -s .dotfiles/.vimrc
   46  ls -lsa
   47  ln -s .dotfiles/.vim
   48  ls -lsa
   49  mkdir .config
   50  ln -s .dotfiles/.config/nvim .config/
   51  ls -lsa
   52  ls -lsa .config/
   53  ln -s ~/.dotfiles/.config/nvim .config/
   54  rm -rf .config/nvim
   55  ln -s ~/.dotfiles/.config/nvim .config/
   56  ls -lsa .config/
   57  ls -lsa .dotfiles/.config/
   58  ls -lsa .dotfiles/
   59  ln -s ~/.dotfiles/.tmux.conf* .
   60  ls -lsa
   61  tmux
   62  cd .dotfiles/
   63  ls
   64  cd bin/
   65  ls
   66  vim nordfonts.sh
   67  ls
   68  mv nordfonts.sh nerdfonts.sh
   69  chmod +x nerdfonts.sh
   70  ls
   71  ./nerdfonts.sh
   72  su -
   73  vim nerdfonts.sh





tmux new -s work -d
