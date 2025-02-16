#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH;

source $SCRIPTPATH/../utils.sh

path_config=(
    "/etc/nixos/"
    "$HOME/.config/hypr/"
    "$HOME/.config/kitty/"
    "$HOME/.config/hypr/"
    "$HOME/.config/nwg-bar/"
    "$HOME/.config/nwg-displays/"
    "$HOME/.config/rofi/"
    "$HOME/.config/waybar/"
    "$HOME/.config/nwg-look/"
    "$HOME/.config/nwg-look/"
)
path_shell="$HOME/shell.nix"
path_temp="./tmp/"
ok_custom_commit=false
ok_commit=false
ok_sync=false
commit_msg="Manual NixOS configuration sync via Bash"
commit_usr="luks"


f_custom_commit() {
    if (fok "Do you wish a custom commit message?"); then
        echo; read -p "Type your commit message: " commit_msg
    fi
    echo; echo "    Commit message:"; echo "        $commit_msg"; echo;
    
    if ! (fok "Do you confirm the above commit message?"); then
        if (fok "Do you wish to retry?"); then
            f_custom_commit;
        else
            echo "ABORT - No commit message"; exit 1;
        fi
    fi
}


f_copy() {
    echo; if (fok "Do you wish to copy configs on directory $1 ?"); then
        echo "Case for $1"
        if [ ! -d $1 ]; then
            echo "ERROR - Directory not found on: $1"
            exit 1
        else
            save_on=$1
            save_on="${save_on%/}"
            save_on="${save_on##*/}"
            sudo mkdir -m 777 -p $path_temp/$save_on;
            sudo cp -r $1 $path_temp/$save_on;
            echo "OK -  $save_on";
        fi
    fi
}

echo; echo "........NIXOS CHECKPOINT ON GITHUB........"
sudo -v;

{
    echo; echo; echo "...Temporary files..."
    echo ">>>>File path $path_temp..."
    sudo mkdir -m 777 -p ./tmp
    
    for c in "${path_config[@]}"; do
        f_copy $c
    done
} && {
    echo; echo; echo "...GIT parameters..."
    {
        git_name=$(git config user.name)
        git_email=$(git config user.email)
        git_remote_origin_url=$(git config remote.origin.url)
    } && {
        echo "USER:               '$git_name'";
        echo "EMAIL:              '$git_email'";
        echo "REMOTE ORIGIN URL:  '$git_remote_origin_url'";
    } && {
        echo; 
        if ! (fok "Do you confirm the GIT credentials above?"); then
            echo "ABORT - GIT credentials not accepted!"; exit 1
        fi
    } && {
        f_custom_commit
    }
} && {
    if (fok "Do you really wish to proceed with git sync?"); then
        {
            sudo -u $commit_usr git add $path_temp
        } && {
            sudo -u $commit_usr git commit -m "$commit_msg"
        } && {
            sudo -u $commit_usr git push
        }
    else
        echo "ABORT - Last second!"; exit 1
    fi
}
