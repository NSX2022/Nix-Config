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
      size = 34 * 1024; # Make sure it's >= your RAM
    }
  ];

  hardware = {
    bluetooth.enable = true;
  };

  # Nvidia nonsense
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.modesetting.enable = true;
  hardware.graphics.enable = true;
  hardware.nvidia.open = false;
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Hibernation
  boot.resumeDevice = "/dev/disk/by-uuid/5a88c772-6b56-436b-92c6-b635c61d4030";
  # Blacklist integrated GPU, set offset for swapon memory block
  boot.kernelParams = [ "module_blacklist=i915" "resume_offset=70340608" ];
  # Might need to tinker with this
  hardware.nvidia.powerManagement.enable = true;
  # Hibernate when the lid is closed
  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "hibernate";
  };

  # Disable this and rollback to 6.18 if drivers are broken by the latest kernel version
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
      
      # Games
      rogue
      vintagestory
      nethack
      # Utilities
      ollama-vulkan
      
    ];
  };
  
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };
  
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    # System
    blueman # For bluetooth
    pavucontrol # Audio Input GUI
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
    (discord.override {
      withVencord = true;
    })
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
    gcc
    typescript
    # xfce
    xfce.xfce4-cpugraph-plugin
    xfce.xfce4-battery-plugin
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

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

