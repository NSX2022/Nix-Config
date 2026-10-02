{ config, pkgs, ... }:
{
  fonts.fontDir.enable = true;
  
  fonts.packages = with pkgs; [
    minecraftia
    unifont
    liberation_ttf
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    open-sans
    dejavu_fonts
    freefont_ttf
    font-awesome
  ];
}