# MyCodespace

Using remote tmux to emulate codespace feel

### Dependencies

NodeJS

    $ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
    $ nvm install 16
    $ nvm use 16

Neovim modules for python3 and node

    $ pip3 install neovim
    $ pip3 install pynvim --upgrade
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

If error `not a terminal` then use `-t`

    $ ssh -t remote.com tmux attach -t work

To end remote session and not the tmux session, just detatch from it with:

    ctrl-b d

## Data Analisys

### Using Pandas

Install on the virtual environment

    $ pip3 install numpy pandas

Install JupyterLab (optional)

    $ pip install jupyterlab

**Install jupyter kernel for the virtual environment using the following command:**

Running the following command will create a kernel that can be used to run jupyter notebook commands inside the virtual environment.

    $ ipython kernel install --user --name=venv

\*\*Create a configuration file to remove `localhost` restriction

    $ jupyter lab --generate-config
    $ vim /home/user/.jupyter/jupyter_lab_config.py

( add the following two line anywhere because the default values are commented anyway)

    c.ServerApp.allow_origin = '*' #allow all origins
    c.ServerApp.ip = '0.0.0.0' # listen on all IPs

Protect session with a password

    $ jupyter lab password

Start `Jupyter lab`

    $ jupyter lab

## Troubleshooting

When using pip from inside vim

`ERROR: Can not perform a '--user' install. User site-packages are not visible in this virtualenv.`

QF:

    * Go to the `pyvenv.cfg` file in the Virtual environment folder
    * Set the `include-system-site-packages` to `true` and save the change
    * Reactivate the virtual environment.
