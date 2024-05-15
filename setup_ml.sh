#!/bin/bash
env_name="env_ml"
env_folder="~/envs"
env_dir="~/$env_folder/$env_name"


echo "...Machine Learning Enviroment Setup..."
# echo "Proceed? (Y/n)"
# read $proceed
# if proceed == "Y" or 
{
    echo "...Basic Installs..."
    {
        sudo apt install python3-pip -y
    } && {
        sudo apt install nvidia-cudnn -y
    } && {
        sudo apt install nvidia-cuda-toolkit -y
    }
} && {
    echo "...Enviroment Cleaning..."
    if [ -d $env_dir]; then # Check if the directory exists
        rm -rf "$env_dir/*" # Remove all contents of the directory
    else # Create the directory
        {
            mkdir -p "$env_dir"
        } && {
            echo "Directory created: $env_dir"
        }
    fi
} && (
    {
        echo "...Enviroment Install..."
    } && {
        sudo apt install python3-venv
    } && {
        python3 -m venv $env_dir   
    } && {
        source $env_dir
    }
) && {
    {
        echo "...Installing Pip Packages..."
    } && {
        python3 -m pip3 install --upgrade pip --break-system-packages
    } && {
        python3 -m pip3 install wheel --break-system-packages
    } && {
        python3 -m pip3 install --upgrade tensorrt  --break-system-packages
    } && {
        python3 -m pip3 install --upgrade tensorrt_lean --break-system-packages
    } && {
        python3 -m pip3 install --upgrade tensorrt_dispatch --break-system-packages
    } && {
        python3 -m pip3 install --upgrade tensorflow --break-system-packages
    }
} && {
    {
        echo "...Testing..."
    } && {
        nvcc -V
    } && {
        python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
    }
} && {
    echo "...Everithing finished well. Bye Bye..."
}


