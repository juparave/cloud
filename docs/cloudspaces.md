# Cloudspaces

### Misc preparation

File permissions

    $ sudo apt-get update
    $ sudo apt-get install acl
    $ sudo chown -R $(whoami) .
    $ sudo setfacl -bnR .
    $ find . -type d -exec echo -n '"{}" ' \; | xargs chmod 755
    $ find . -type f -exec echo -n '"{}" ' \; | xargs chmod 644

### Using Docker Compose

* Create a whole develoment environment ref: https://dev.to/cmiles74/really-using-visual-studio-development-containers-561e
* Check this `.devcontainer` configuration too ref: https://github.com/pietheinstrengholt/rssmonster/

## Utils

#### Get Domain name from terminal

    $ jq -r ".CODESPACE_NAME" /workspaces/.codespaces/shared/environment-variables.json
