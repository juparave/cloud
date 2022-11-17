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

Create or add to existing `~/.bash_profile`
```bash
# ~/.bash_profile

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

air

    $ curl -sSfL https://raw.githubusercontent.com/cosmtrek/air/master/install.sh | sh -s -- -b $(go env GOPATH)/bin

entr

    # apt install entr

### Workflow

On remote machine run:

    $ tmux new -s work -d

    :new create a new tmux session
    :-s work session name `work`
    :-d detach

On client machine:

    $ ssh remote.com tmux attach -t work
    
    :remote.com remote hostname
    :tmux attach attach to a tmux session if exists
    :-t work attach to the detached session `work`

To end remote session and not the tmux session, just detatch from it with:

    ctrl-b d
