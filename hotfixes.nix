{ pkgs, lib, config, ... }:
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
  
  # Nvidia nonsense
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  hardware.nvidia.modesetting.enable = true;
  hardware.graphics.enable = true;
  hardware.nvidia.open = true;
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia-container-toolkit.enable = true;  # for ollama-docker

  # Optimus drivers
  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;  # nvidia-offload wrapper
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:2:0:0";
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvme_core.default_ps_max_latency_us=0"
  ];
  boot.initrd.kernelModules = [];
  boot.initrd.systemd.enable = true;

  #backlight
  services.udev.packages = [ pkgs.brightnessctl ]; # uses video over udev rules
  services.udev.extraRules = ''
  ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="nvidia_0", \
    RUN+="${pkgs.coreutils}/bin/chmod a-w /sys/class/backlight/nvidia_0/brightness"

  ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", \
    RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/intel_backlight/brightness", \
    RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness"
  '';

  # Might need to tinker with this
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = false;
  # Hibernate when the lid is closed
  # services.logind.settings.Login = {
  #  HandleLidSwitch = "hibernate";
  #  HandleLidSwitchExternalPower = "hibernate";
  # };

  # For when programs crash due to DLL errors
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    
  ];
}