# Protonet Runit Jobs

This repository contains the *runit* job manifests for Protonet.

## Configuration

Configuration is in `./config/runit.json`, the format should be
self-explanatory given the existing examples.

## Testing

Simply:

    $ bundle install
    $ rake

*FakeFS* is used so the tests won't trash your filesystem.

## Dry-Run

You can dry-run your configuration with:

    $ rake dry-run

This will use a temporary directory into which everything should be output,
it'll then launch this directory in your file browser.

The dry-run will unfortunately write a bunch of empty directories (one for
each service) to `/var/log/protonet/...`, these shouldn't do any harm as
`/var/log` is more or less ubiquitous.

## Installation

You can install the service files by running:

    $ sudo rake install

This will (be default) install everything into `/etc/sv`, these services won't
be picked up by the typical runit installation until they are symlinked into
`/etc/service/`, this can be done with:

    $ sudo find /etc/sv -type d -exec ln -s {} /etc/service/ \;
    $ ls /etc/sv | sudo xargs -i ln -sf /etc/sv/{} /etc/service/{}

Which should symlink them into the monitored directory, once they are
symlinked, runit should pick them up within ~5 seconds.
