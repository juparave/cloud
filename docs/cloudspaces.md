# Cloudspaces

### Misc preparation

File permissions

    $ find . -type d -exec echo -n '"{}" ' \; | xargs chmod 755
    $ find . -type f -exec echo -n '"{}" ' \; | xargs chmod 644
