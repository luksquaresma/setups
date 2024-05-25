#!/bin/bash

# ---------------------------------
# CONFIGS
path_obsidian="Obsidian"
path_projects="Projects"

git_name="Lucas Quaresma"
git_email="lucas.quaresma1@gmail.com"

pkgs_apt=(
    "git"
    "chrome-gnome-shell"
    "htop"
    "gnome-tweaks"
    "dconf-editor"
    "docker.io"
    "curl"
    "rustup"
)

pkgs_snap=(
    "obsidian --classic"
    "code --classic"
    "teams-for-linux"
    "spotify"
    "docker"
)

# gnome_extensions=(
#     # hide top bar
#     "hidetopbar@mathieu.bidon.ca"
    
#     # dash to dock
#     "dash-to-dock@micxgx.gmail.com"

#     # disable unredirect on full screen (dash + top bar gub solve)
#     "unredirect@vaina.lt"
    
#     # icons in alphabetical order
#     "AlphabeticalAppGrid@stuarthayhurst"
# )
# ---------------------------------

# ---------------------------------
# FUNCTIONS
tree_path_prep() {
    p=$1
    if [[ -n $p && ${p:0:1} == "/" ]]; then
        p=${p:1:${#p}}
    fi
    if [[ -n $p && ${p:(-1):1} == "/" ]]; then
        p=${p:0:(${#p}-1)}
    fi
    echo $p
}
tree_cleaning() {
    base=$2 # should allways have trainling "/"
    prefix="${1%%/*}"
    suffix="${1##*$prefix}"
    suffix="${suffix:1:${#suffix}}"

    if [ -d "$HOME/$base$prefix/$suffix" ]; then # Check if the directory exists
        {
            echo "Directory $HOME/$base$prefix/$suffix exists"
            sudo rm -rf $HOME/$base$prefix/$suffix/* # Remove all contents of the directory
        } && {
            echo "Removed content of directory $HOME/$base$prefix/$suffix"
            return
        }
    elif [ -d "$HOME/$base$prefix" ]; then # Check if the directory exists
        {
            echo "Directory $HOME/$base$prefix exists."
            sudo rm -rf $HOME/$base$prefix/* # Remove all contents of the directory
        } && {
            echo "Removed content of directory $HOME/$base$prefix"
        }
    else # Create the directory
        {
            sudo mkdir -m 777 $HOME/$base$prefix
        } && {
            echo "Created directory $HOME/$base$prefix"
        }
    fi
    tree_cleaning $suffix "$base$prefix/"
}
# ---------------------------------


# ---------------------------------
# Config preparation
path_obsidian=$(tree_path_prep $path_obsidian)
path_projects=$(tree_path_prep $path_projects)

# CLI Start
echo "........PERSONAL ENVIROMENT SETUP........"
echo; echo "Directory for Obsidian files on '$HOME/$path_obsidian'"
echo; echo "Directory for Projects files on '$HOME/$path_projects'"
echo; read -p "Do you confirm? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
sudo -v; echo;
# cd $HOME


# clear path to enviroment setup
{
    echo; echo; echo "....Path Preparations...."
    {
        tree_cleaning $path_obsidian
    } && {
        tree_cleaning $path_projects
    } 
} && {
    echo; echo; echo "....APT Packages...."
    {
        echo; sudo apt update -y
    } && {
        echo; sudo apt upgrade -y
    } && {
        for p in "${pkgs_apt[@]}"
        do
            echo; sudo apt install $p -y
        done            
    } 
} && {
    echo; echo; echo "....Snap Packages...."
    {
        echo; sudo snap refresh
    } && {
        for p in "${pkgs_snap[@]}"
        do
            echo; sudo snap install $p
        done       
    } 
} && {
    echo; echo; echo "....GIT Configs...."
    {
        git config --global user.name $git_name
        sudo git config --global user.name $git_name
    } && {
        git config --global user.email $git_email
        sudo git config --global user.email $git_email
    } && {
        sudo git config --global credential.helper cache
    } && {
        # one year credential validity
        git config --global credential.helper 'cache --timeout=31536000'
    }
} && {
    echo; echo; echo "....Docker Configs...."
    {
        echo; sudo groupadd docker
    } && {
        echo; sudo usermod -aG docker $USER
    } && {
        echo; su - $USER
    } && {
        echo; export PATH="$PATH:/usr/bin/docker"
    } && {
        echo; source ~/.bashrc
    } && {
        echo; docker --version
    } && {
        echo; sudo systemctl daemon-reload
    } && {
        echo; sudo systemctl restart docker
    }
} && {
    echo; echo; echo "....Rust Configs...."
    {
        echo; exec $SHELL
    } && {
        echo; sudo rustup default stable
    } && {
        echo; sudo rustup update
    } && {
        echo "Testing: "
        rustup check
    }
} && {
    echo; echo; echo "........Everithing finished well. Bye Bye........"
}