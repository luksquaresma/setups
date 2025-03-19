# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # cache from cachix
      #./cachix.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true; 

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = false; # ! hyprland
  
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # ===== BLUETOOTH CONFIFGS
  #powerManagement.powerUpCommands = ''
  #  rfkill block bluetooth
  #  rfkill unblock bluetooth
  #'';
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
    package = unstable.bluez;
    input = {
      General = {
        ClassicBondedOnly = false;
        IdleTimeout = 30;
      };
    };
    settings = {
      General = {
        AlwaysPairable = true;
        DiscoverableTimeout = 0;
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        FastConnectable = true;
        JustWorksRepairing = "always";
        KernelExperimental = true;
      };
    };
  };
  services.blueman.enable = true;
  powerManagement.powerUpCommands = ''
    set -e
    set -u
    PS4=" $ "
    ID_VENDOR="0bda"
    ID_PRODUCT="a729"

    ___fix_bt_reset_paths() {
      for p in "$@"; do
        echo 0 > "$p"/authorized
      	sleep 1
        echo 1 > "$p"/authorized
      done
    }

      __fix_bt_main() {
	systemctl stop bluetooth; sleep 4;

	local p
	local found_vnd
	local found_prd
	declare -a paths

	for p in /sys/bus/usb/devices/\*; do 
          found_vnd="$(cat "$p/idVendor" 2>/dev/null)" || :
          found_prd="$(cat "$p/idProduct" 2>/dev/null)" || :
          if [[ "$found_vnd" == "$ID_VENDOR" && "$found_prd" == "$ID_PRODUCT" ]]; then
            __fix_bt_paths+=("$p")
          fi
        done

        __fix_bt_reset_paths "''${__fix_bt_paths[@]}"; sleep 1;
        __fix_bt_reset_paths "''${__fix_bt_paths[@]}"; sleep 2;
        systemctl restart bluetooth;
      }
      __fix_bt_main
  '';

  # QMK VIA Suport
  hardware.keyboard.qmk.enable = true;
  services.udev.packages = [ pkgs.via ];

  # ===== SOUND WITH PIPEWIRE
  security.rtkit.enable = true;
  hardware.pulseaudio = {
    enable = false;
    package = unstable.pulseaudioFull;
    extraModules = [ unstable.pulseaudio-module-xrdp ];
  };
  services.pipewire = {
    enable = true;
    package = unstable.pipewire;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber = {
      enable = true;
      package = unstable.wireplumber;
    };    
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.luks = {
    isNormalUser = true;
    description = "luks";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "luks";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    unstable.aider-chat
    unstable.alpaca
    alacarte
    btop
    cachix
    curl
    discord-ptb
    docker-compose
    ffmpeg
    jump
    gcc
    git
    glow
    glmark2
    dconf-editor
    gnome-tweaks
    htop
    insync
    jump
    lazygit
    libsecret
    linuxHeaders
    lm_sensors
    lshw
    mc
    neofetch
    nix-prefetch-github
    nix-search-cli
    unstable.nvtopPackages.full
    obsidian
    oterm
    pavucontrol
    parallel
    pciutils
    pulsemixer
    remmina
    rustup
    slack
    speedtest-cli
    spotify
    sqlite
    tlrc
    tmux
    tree
    usbutils
    via
    vlc
    unstable.vscode
    webcord
    wl-clipboard
   
    # bluetooth
    bluez-alsa
    bluez-experimental
    bluez-tools

    # Python
    python311Full
    python311Packages.pip
    python311Packages.wheel
    python311Packages.numpy
    python311Packages.setuptools
    python311Packages.jupyter
    python311Packages.pyspark
    python311Packages.pyyaml
    python311Packages.toml    

    # Nvidia
    cudaPackages.cudnn
    cudaPackages.cudatoolkit
    cudaPackages.cuda_cudart
    # cudaPackages.tensorrt

    # ML
    # python311Packages.tensorflow
    # python311Packages.tensorflowWithCuda
    # python311Packages.tensorrt

    # Hyprland
    gnome-themes-extra
    unstable.hyprshot
    unstable.hyprlock
    unstable.hypridle
    unstable.networkmanagerapplet
    unstable.dunst
    unstable.libnotify
    unstable.lxappearance
    unstable.nautilus
    unstable.nwg-look
    unstable.nwg-displays
    unstable.waybar
    unstable.udiskie
    unstable.kitty
    unstable.swww
    unstable.rofi-wayland
    unstable.rofi-power-menu
    unstable.playerctl

    # Recording
    unstable.obs-studio
    kdePackages.kdenlive
    kdePackages.mlt
    movit
    rtaudio
  ];

  # ===== DOCKER
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
    package = unstable.docker;
    rootless = {
      enable = true;
      setSocketVariable = true;
      package = unstable.docker;
    };
  };

  # ===== OLLAMA
  services.ollama = {
    package = unstable.ollama; # ollama-cuda; # Uncomment if you want to use the unstable channel, see https://fictionbecomesfact.com/nixos-unstable-channel
    enable = true;
    acceleration = "cuda"; # Or "rocm"
    #environmentVariables = { # I haven't been able to get this to work myself yet, but I'm sharing it for the sake of completeness
      # HOME = "/home/ollama";
      # OLLAMA_MODELS = "/home/ollama/models";
      # OLLAMA_HOST = "0.0.0.0:11434"; # Make Ollama accesible outside of localhost
      # OLLAMA_ORIGINS = "http://localhost:8080,http://192.168.0.10:*"; # Allow access, otherwise Ollama returns 403 forbidden due to CORS
    #};
  };


  # ===== OPEN-WEBUI
  services.open-webui = {
    enable = true;
    package = unstable.open-webui;
    host = "0.0.0.0";
    port = 12345;
    openFirewall = true;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_URL = "http://0.0.0.0/12345";
      # WEBUI_AUTH = "False";
      ENABLE_REALTIME_CHAT_SAVE = "False";
    };
  };

  programs.bash.promptInit = ''
    function luks_nix_config() {
      bash setups/nixos/nix_config_rebuild_reboot.sh
    };
  
    function get_git_branch() {
      git name-rev --name-only HEAD > /dev/null 2>&1
      if [[ $? -eq 0 ]]; then
        echo "($(git name-rev --name-only HEAD))";
      else
        echo "";
      fi
    };

    if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
      PROMPT_COLOR="1;35m"
      ((UID)) && PROMPT_COLOR="1;35m"
      if [ -n "$INSIDE_EMACS" ]; then
        # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
        PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\\n\$(get_git_branch)\$\[\033[0m\] "
      else
        PS1="\n\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\n\$(get_git_branch)\$\[\033[0m\] "
      fi
      if test "$TERM" = "xterm"; then
        PS1="\[\033]2;\h:\u:\w\007\]$PS1"
      fi
    fi
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  # ===== NVIDIA CONFIGS
  # Enable OpenGL
  hardware.graphics = {
    enable = true;    
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    enable32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };
  
  # hardware.nvidia.prime = {
    # intelBusId = "PCI:0:2:0";
    # amdgpuBusId = 
    # nvidiaBusId = "PCI:1:0:0";
    # sync.enable = true;
    # offload = {
    #   enable = true;
    #   enableOffloadCmd = true;
    # };
  # };


  hardware.nvidia.forceFullCompositionPipeline = true;
  
  # ===== STEAM
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # ===== GARBAGE COLLECTOR
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 60d";
    };
  };

  # ===== RETRIVAL OF config.nix ON ROLLBACK BUILDS
  # Retrived files are save in: /run/current-system/configuration.nix
  system.copySystemConfiguration = true;

  # ===== ECTRON FIX
  environment.sessionVariables = {
    MUTTER_DEBUG_KMS_THREAD_TYPE="user";
    # WLR_NO_HARDWARE_CURSORS = "1"; # if no cursor is visible
    NIXOS_OZONE_WL = "1";  
  };

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = ["amdgpu.sg_display=0"];


  # ===== HYPRLAND
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    #package = unstable.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };
  services.hypridle.enable = true;
  xdg.portal = {
    enable = true;
    #xdgOpenUsePortal = true;
    extraPortals = [
      # pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };
  fonts.packages = with pkgs; [ nerdfonts ];
  services.udisks2.enable = true;

  # ===== AUTOUPDATE
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

}
