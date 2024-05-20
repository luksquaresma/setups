#!/bin/bash

# ---------------------------------
# NOTICE
# This is only tested and working with ubuntu 24.04 # Please be carefull!
# The usage is simple: indicate below a directory to contain your virtual 
# enviroment (env_folder) and  the enviroment name (env_name).
# The installer will create or clean these locations, so please be carefull.
# The expected test output at the end is something like:
#         [PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU')]
# ---------------------------------


# ---------------------------------
# CONFIGS
env_folder="envs"
env_name="env_ml"
env_dir=$env_folder/$env_name
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
    sulfix="${1##*$prefix}"
    sulfix="${sulfix:1:${#sulfix}}"

    if [ -d "$HOME/$base$prefix/$sulfix" ]; then # Check if the directory exists
        {
            echo "Directory $HOME/$base$prefix/$sulfix exists"
            sudo rm -rf $HOME/$base$prefix/$sulfix/* # Remove all contents of the directory
        } && {
            echo "Removed content of directory $HOME/$base$prefix/$sulfix"
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
    tree_cleaning $sulfix "$base$prefix/"
}
# ---------------------------------


# ---------------------------------
# Config preparation
env_dir=$(tree_path_prep $env_dir)


# CLI Start
echo "........MACHINE LEARNING ENVIROMENT SETUP........"
echo; echo "Directory for virtual enviroment on '$HOME/$env_dir'"
echo; read -p "Do you confirm? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
sudo -v; echo;
cd $HOME


# Path to enviroment setup
tree_cleaning $env_dir


# Instalation itselv
{
    echo; echo; echo "....Basic Installs...."
    {
         echo; sudo apt update -y
    } && {
        echo; sudo apt install locate -y
    } && {
        echo; sudo apt install python3-pip -y
    # } && {
    #     echo; sudo apt install nvidia-driver -y
    } && {
        echo; sudo apt install nvidia-cudnn -y
    } && {
        echo; sudo apt install nvidia-cuda-toolkit -y
    } && {
        echo; pip3 install --upgrade wheel --break-system-packages
    }
} && {
    {
        echo; echo; echo "....Enviroment Install...."
    } && {
        echo; sudo apt install python3-venv -y
    } && {
        echo; python3 -m venv $HOME/$env_dir
    } && {
        source $HOME/$env_dir/bin/activate
    }
} && {
    {
        echo; echo; echo "....Installing Pip Packages...."
    } && {
        echo; pip3 install --upgrade pip --break-system-packages
    } && {
        echo; pip3 install --upgrade wheel --break-system-packages
    } && {
        echo; pip3 install --upgrade nvidia-tensorrt --break-system-packages
    } && {
        echo; pip3 uninstall tensorflow --break-system-packages
    } && {
        echo; pip3 install --upgrade tensorflow[and-cuda] --break-system-packages
    }
} && {
    {
        echo; echo; echo "....Testing...."
    } && {
        echo; nvidia-smi
    } && {
        echo; nvcc -V
    } && {
        echo; python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
    }
} && {
    echo; echo; echo "........Everithing finished well. Bye Bye........"
}


