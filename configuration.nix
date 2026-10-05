# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  # Environment variableds
  environment.variables = {
    #CLASSPATH = let lib = "/home/merlin/Uni/CS210/lib/lib"; in
    #  ".:./out:${lib}/stdlib.jar:${lib}/dsa.jar"; # CS210 libraries
  };

  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];

  # Why isn't this enabled by default
  nixpkgs.config.allowUnfree = true;
  
  swapDevices = [
    {
      device = "/swapfile";
      size = 33 * 1024; # Make sure it's >= your RAM if you want hibernation
    }
  ];

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  # Disable this and rollback to 6.18 if wifi drivers are broken by the latest kernel version. If Nvidia drivers are broken, change to kernel 6.12
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  
  imports =
    [
      ./hardware-configuration.nix
      ./hotfixes.nix
      ./vscode.nix
      ./fonts.nix
      ./battery.nix
    ];

  # Use the systemd-boot EFI boot loader
  # boot.loader.systemd-boot.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;
  # Use GRUB, autodetect other bootable media
  boot.loader.grub.efiInstallAsRemovable = false;
  boot.loader.grub = {
    enable = true;
    useOSProber = true;
    efiSupport = true;
    device = "nodev";
  };

  networking.hostName = "grimoire";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;


  # Set your time zone.
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  security.rtkit.enable = true;
  services = {
    xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };
      displayManager.lightdm = {
        enable = true;
      };
    };
    displayManager.defaultSession = "xfce";
    # Sound.
    pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      pulse.enable = true;
    };
    # Bluetooth
    blueman.enable = true;
  };
  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  nix.settings.trusted-users = [ "root" "@wheel" ];
  users.users.merlin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "docker" ]; # wheel = Enable ‘sudo’ for the user, video = enable display setting manipulation, docker to run containers !!!ROOTFUL!!!
    packages = with pkgs; [
      # Applications
      vesktop
      obs-studio
      kdePackages.kdenlive
      protonmail-desktop
      proton-vpn
      libreoffice
      brave # For things that need a chromium browser
      godot-mono #TODO: Update manually when new versions come out
      unityhub
      # Games
      rogue
      nethack
      prismlauncher
      vms-empire
      # Utilities
      #ollama
      wireshark
      # TODO do the NordVPN workaround
      godot
      bespokesynth
      qdirstat
    ];
  };
  
  programs.firefox.enable = true;
  # For singlebooting
  # programs.steam = {
  #  enable = true;
  #  extraCompatPackages = with pkgs; [ proton-ge-bin ];
  # };

  
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    # System
    blueman # For bluetooth
    pavucontrol # Audio Input GUI
    libsecret
    brightnessctl
    # Utilities
    tree
    unzip
    p7zip # Unzip .7z files
    wget
    git
    alacritty
    zoxide
    fastfetch
    ffmpeg
    yt-dlp
    vulkan-tools
    speedtest-cli
    emscripten
    pciutils
    dwarfs # Compression algorithm
    nvd # Nix Version Difference
    retry # Try a command until it succeeds (use sparingly)
    viddy # watch command for automation
    wine
    efibootmgr
    #winboat # TODO Package install for Winboat is broken? Prevents full build
    grub2_efi
    parted
    file
    testdisk
    lsof # Check what process is using a port
    # Applications
    btop
    cmatrix
    jetbrains.idea
    jetbrains.webstorm
    qbittorrent
    vim
    obsidian
    tor-browser
    vlc
    gimp
    aseprite
    monero-gui
    # Programming
    #TODO clean up java
    openjdk8
    openjdk25
    openjdk21
    openjdk11
    javaPackages.compiler.temurin-bin.jdk-21 # for Intellij
    pnpm
    nodejs_24
    #TODO install pip_3.15 once that is released on nixpkgs
    cargo
    zig
    python315
    python313
    uv
    cmake
    gnumake
    gcc
    typescript
    llvm
    llvm.dev
    clang
    nasm
    lua
    yarn # js build tools
    dotnet-sdk
    # Libraries
    ncurses
    raylib
    python313Packages.pyautogui
    # xfce
    xfce.xfce4-cpugraph-plugin
    xfe # file manager
    # Nvidia
    nvidia-container-toolkit
  ];

  #TODO: Move to shell .nix file
  environment.interactiveShellInit = ''
    alias update='~/Scripts/nix_update.sh';
    alias comfyui='nix run github:utensils/comfyui-nix#cuda -- --fast-disk --use-sage-attention --enable-manager --cuda-malloc';
    alias scode='sudo -E code --no-sandbox --user-data-dir /root/.vscode-root';
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
    daemon.settings = {
      runtimes = {
        nvidia = {
          path = "${pkgs.nvidia-container-toolkit.tools}/bin/nvidia-container-runtime";
          runtimeArgs = [];
        };
      };
    };
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  #Security
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true; #GUI for security troubleshooting
  security.pam.services.lightdm.enableGnomeKeyring = true; #Delete this when switching to KDE

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [  ];
  networking.firewall.allowedUDPPorts = [ 9090 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
  
  # Do NOT change this value 
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11";

}

