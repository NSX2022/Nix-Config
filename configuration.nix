# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:


{
  # BREAK GLASS IN CASE OF EMERGENCY
  # !!!!!!
  /*
  boot.loader.systemd-boot.graceful = true;
  systemd.package = pkgs.systemd.overrideAttrs (old: {
    version = "257.6";
  });
  */
  # !!!!!!

  # Why isn't this enabled by default
  nixpkgs.config.allowUnfree = true;
  
  swapDevices = [
    {
      device = "/swapfile";
      size = 34 * 1024; # Make sure it's >= your RAM if you want hibernation
    }
  ];

  hardware = {
    bluetooth.enable = true;
  };

  # Nvidia nonsense
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  hardware.nvidia.modesetting.enable = true;
  hardware.graphics.enable = true;
  hardware.nvidia.open = true;
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Optimus drivers
  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;  # nvidia-offload wrapper
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:2:0:0";
  };

  # TODO Hibernation
  # boot.resumeDevice = "/dev/disk/by-uuid/5a88c772-6b56-436b-92c6-b635c61d4030";
  # Blacklist integrated GPU, set offset for swapon memory block
  # boot.kernelParams = [ "resume_offset=70340608" "nvidia-drm.modeset=1" ];

  #TEMPORARY
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  #backlight
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", \
    RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/intel_backlight/brightness", \
    RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness"
  '';

  # Might need to tinker with this
  hardware.nvidia.powerManagement.enable = true;
  # Hibernate when the lid is closed
  # services.logind.settings.Login = {
  #  HandleLidSwitch = "hibernate";
  #  HandleLidSwitchExternalPower = "hibernate";
  # };

  # Disable this and rollback to 6.18 if wifi drivers are broken by the latest kernel version. If Nvidia drivers are broken, change to kernel 6.12
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Use GRUB, autodetect other bootable media
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
  };
  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.merlin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "nordvpn"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      # Applications
      vesktop
      obs-studio
      kdePackages.kdenlive
      protonmail-desktop
      protonvpn-gui
      libreoffice
      # Games
      rogue
      nethack
      # Utilities
      ollama-vulkan
      
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
    brightnessctl # Display brightness
    # Utilities
    tree
    unzip
    wget
    git
    alacritty
    zoxide
    fastfetch
    ffmpeg
    yt-dlp
    vulkan-tools
    speedtest-cli
    docker
    emscripten
    pciutils
    # Applications
    btop
    cmatrix
    jetbrains.idea-community
    qbittorrent
    vim
    obsidian
    vscode
    tor-browser
    vlc
    gimp
    monero-gui
    # Programming
    javaPackages.compiler.openjdk8
    javaPackages.compiler.openjdk25
    javaPackages.compiler.openjdk21
    javaPackages.compiler.openjdk11
    cargo
    zig
    chromium
    python315
    cmake
    gnumake
    gcc
    typescript
    # xfce
    xfce.xfce4-cpugraph-plugin
  ];

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
  networking.firewall.allowedUDPPorts = [ 9090 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
  
  # Do NOT change this value 
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

