{ config, pkgs, ... }:
{
  #Didn't feel right to put this in the hotfixes module, since this should be consant between migrations
  services.tlp = {
    enable = true;
    settings = {
      STOP_CHARGE_THRESH_BAT0 = 1;  # Stop charging at 80%
    };
  };
  #TODO(?) find a way to cap to 85% for longer battery life (might not be possible)
}
