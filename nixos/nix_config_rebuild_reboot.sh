#!/bin/bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
path_checkpoint="$SCRIPTPATH/nix_make_ckeckpoint.sh"

source $SCRIPTPATH/../utils.sh
cuda_cachix="cuda-maintainers"
self_cachix="luksquaresma"




clear
echo "......NIXOS CONFIG-REBUILD-REBOOT SCRIPT......";

sudo -v && cd $SCRIPTPATH

{
    echo; if (fok "Do you wish to perform garbage collection?"); then
        echo; echo "...Nix garbage collection..."
        sudo nix-collect-garbage && echo
    fi
} && {
    echo
    echo; if (fok "Do you wish to use cache via cachix?"); then
        echo; echo "...Nix cache setup..."
        echo; if (fok "Do you wish to use $cuda_cachix instead of $self_cachix cachix?"); then
            sudo cachix use $cuda_cachix && echo
        else
            sudo cachix use $self_cachix && echo
        fi
    fi
} && {
    echo; echo "...Nix channel update..."
    sudo nix-channel --update && echo
} && {
    echo; echo "...Nix config edit..."
    sudo nano /etc/nixos/configuration.nix && echo
} && {
    echo; if (fok "Do you wish to rebuild on boot?"); then
        echo; sudo nixos-rebuild boot && echo
    fi
} && {
    echo; if (fok "Do you wish to push the current cache?"); then
        echo; sudo cachix push luksquaresma * && echo
    fi
} && {
    echo; if (fok "Do you wish to start checkpoint script?"); then
        echo; bash $path_checkpoint && echo
    fi
} && {
    echo; if (fok "Do you wish to restart now?"); then
        shutdown -r 0
    fi
}

