#!/bin/bash

sudo -v; echo;
fok() {
    p=$1
    if [[ "$p" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        p=true
    else
        p=false
    fi
    $p
}

clear;
{
    sudo nano /etc/nixos/configuration.nix
} && {
    if read -p "Do you wish to rebuild on boot? (y/N): " && ! (fok $REPLY); then
        sudo nixos-rebuild boot
    fi
} &&{
    if read -p "Do you wish to restart now? (y/N): " && ! (fok $REPLY); then
        shutdown -r 0
    fi
}

