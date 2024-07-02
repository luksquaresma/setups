#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH;

source $SCRIPTPATH/../utils.sh

path_config="/etc/nixos/configuration.nix"
path_shell="$HOME/shell.nix"
path_temp="./tmp/"
ok_config=false
ok_shell=false
ok_git=false
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


echo; echo "........NIXOS CHECKPOINT ON GITHUB........"
sudo -v;

{ 
    echo; echo "...Option selection...";
    {
        echo; if (fok "Do you wish to copy config on $path_config ?"); then
            ok_config=true && echo ">>>>Copy config enabled!"
        else
            ok_config=false && echo ">>>>Copy config disabled!"
        fi
    } && {
        echo; if (fok "Do you wish to copy shell on $path_shell"); then
            ok_shell=true && echo ">>>>Copy shell enabled!"
        else
            ok_shell=false && echo ">>>>Copy shell disabled!"
        fi
    }
} && {
    echo; echo; echo "...File finding...";
    if ($ok_config || $ok_shell); then
        echo;
        {
            if $ok_config; then
                if [ ! -f $path_config ]; then
                    echo "ERROR - Config file not found in: $path_config"
                    exit 1
                else
                    echo "OK - Config file found in: $path_config"
                fi
            fi
        } && {
            if $ok_shell; then
                if [ ! -f $path_shell ]; then
                    echo "ERROR - Shell file not found in:  $path_shell"
                    exit 1
                else
                    echo "OK - Shell file found in:  $path_shell"
                fi
            fi
        }
    else
        echo "ABORT - No files to copy!"; exit 1
    fi
} && {
    {
        echo; echo; echo "...Temporary files..."
        echo ">>>>File path $path_temp..."
        sudo mkdir -m 777 -p ./tmp
    } && {
        if $ok_config; then
            sudo cp $path_config $path_temp; echo "OK - config.nix";
        fi
        if $ok_shell; then
            sudo cp $path_shell $path_temp; echo "OK - shell.nix";
        fi
    }
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
            sudo -u $commit_usr git add tmp/\*.nix
        } && {
            sudo -u $commit_usr git commit -m "$commit_msg"
        } && {
            sudo -u $commit_usr git pull && git push
        }
    else
        echo "ABORT - Last second!"; exit 1
    fi
}
