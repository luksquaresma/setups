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
      ./cachix.nix
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
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "thinkpad";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # ===== BLUETOOTH CONFIFGS
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;

  # QMK VIA Suport
  hardware.keyboard.qmk.enable = true;
  services.udev.packages = [ pkgs.via ];

  # ==== TEMPORARY FIX FOR AUDIO BUGS ON KERNEL
  # boot.extraModprobeConfig = "options snd-hda-intel model=auto";
  # boot.kernelModules = ["snd_hda_intel"];
  # boot.kernelParams = [ "snd-intel-dspcfg.dsp_driver=1" ];  
  # boot.blacklistedKernelModules = [
  #   "snd_soc_avs"
  # ];
  # boot.kernelPatches = [
  #   {
  #     name = "fix-audio-1";
  #     patch = builtins.fetchurl {
  #       url = "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/patch/sound/soc/soc-topology.c?id=e0e7bc2cbee93778c4ad7d9a792d425ffb5af6f7";
  #       sha256 = "sha256:1y5nv1vgk73aa9hkjjd94wyd4akf07jv2znhw8jw29rj25dbab0q";
  #     };
  #   }
  #   {
  #     name = "fix-audio-2";
  #     patch = builtins.fetchurl {
  #       url = "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/patch/sound/soc/soc-topology.c?id=0298f51652be47b79780833e0b63194e1231fa34";
  #       sha256 = "sha256:14xb6nmsyxap899mg9ck65zlbkvhyi8xkq7h8bfrv4052vi414yb";
  #     };
  #   }
  # ];

  # ===== SOUND WITH PIPEWIRE
  sound.enable = false;
  security.rtkit.enable = true;
  hardware.pulseaudio = {
    enable = false;
    package = unstable.pulseaudioFull;
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber = {
      enable = true;
      package = unstable.wireplumber;
    };    
  };
  
  # Fix for audio testing
  # boot.extraModprobeConfig = ''
  #   options snd-intel-dspcfg dsp_driver=1
  # '';

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.luks = {
    isNormalUser = true;
    description = "luks";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "luks";

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
    btop
    cachix
    curl
    docker
    ffmpeg
    jump
    gcc
    git
    glow
    glmark2
    gnome.dconf-editor
    gnome.gnome-tweaks
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
    nix-search-cli
    obsidian
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
    unstable.vscode
    webcord
    xclip

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
  ];
  
  programs.bash.promptInit = ''
    # Provide a nice prompt if the terminal supports it.
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
  system.stateVersion = "24.05"; # Did you read the comment?

  # ===== NVIDIA CONFIGS
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    driSupport = true;
    driSupport32Bit = true;
    setLdLibraryPath = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

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
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
    sync.enable = true;
    # offload = {
    #   enable = true;
    #   enableOffloadCmd = true;
    # };
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
  # Retrived files are save in:
  #   /run/current-system/configuration.nix
  system.copySystemConfiguration = true;
}
