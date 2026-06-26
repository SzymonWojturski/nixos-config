{ config, pkgs, ... }:
{
  home.username = "szywoj";
  home.homeDirectory = "/home/szywoj";
  home.stateVersion = "26.11";

  home.file = {
    "bin".source = ./personal-binaries;

    ".config/kitty".source = ./config/kitty;
    ".config/niri".source = ./config/niri;
    ".config/nvim".source = ./config/nvim;
    ".config/waybar".source = ./config/waybar;
    ".config/fastfetch".source = ./config/fastfetch;
    ".config/hellwal".source = ./config/hellwal;
    ".config/waypaper".source = config.lib.file.mkOutOfStoreSymlink "/home/szywoj/nixos-config/config/waypaper";
  };

  programs.home-manager.enable = true;
}
