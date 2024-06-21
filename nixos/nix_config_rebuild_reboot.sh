#!/bin/bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
path_checkpoint="$SCRIPTPATH/nix_make_ckeckpoint.sh"

clear;
echo "......NIXOS CONFIG-REBUILD-REBOOT SCRIPT......";

sudo -v; cd $SCRIPTPATH; echo;

fok() {
    p=$1
    if [[ "$p" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        p=true
    else
        p=false
    fi
    $p
}

{
    echo;
    echo "...Nix config edit...";
    sudo nano /etc/nixos/configuration.nix && echo
} && {
    echo
    echo "...Nix channel update..."
    sudo nix-channel --update && echo
} && {
    if read -p "Do you wish to rebuild on boot? (y/N): " && (fok $REPLY); then
        echo;
        sudo nixos-rebuild boot && echo
    fi
} && {
    if read -p "Do you wish to start checkpoint script? (y/N): " && (fok $REPLY); then
        echo; bash $path_checkpoint; echo;
    fi
} && {
    if read -p "Do you wish to restart now? (y/N): " && (fok $REPLY); then
        shutdown -r 0
    fi
}

