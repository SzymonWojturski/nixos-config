{config, lib, pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    # nvidia.nix NIE jest tu importowany — wpina go flake.nix
    # tylko dla hosta "nixos" (z NVIDIĄ). Host "nixos-nonvidia" go pomija.
    #inputs.home-manager.nixosModules.default
  ];
  fonts.packages = with pkgs; [
    lexend
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  systemd.tmpfiles.rules = [
    "w /sys/devices/system/cpu/cpufreq/boost - - - - 0"
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME     = "pl_PL.UTF-8";   # format daty/czasu
    LC_MONETARY = "pl_PL.UTF-8";   # waluta (zł)
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };
  # dźwięk
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  # hyprland
  programs.hyprland.enable = true;
  security.polkit.enable = true;
  programs.xwayland.enable = true;
  # login manager
  services.displayManager.ly.enable = true;
  # swap
  swapDevices = [{ device = "/dev/nvme0n1p1"; }];
  # garbage collection — trzymaj tylko ostatnie generacje
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  users.users.szywoj = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    packages = with pkgs; [
      tree
    ];
  };
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users."szywoj" = import ./home.nix;
  };
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    spotify
    neovim
    wget
    git
    kitty
    fuzzel
    waybar
    waypaper
    wl-clipboard
    mako
    swaylock
    grim
    slurp
    chromium
    vesktop
    awww
    hellwal
    gh
    yazi
    # hyprland — narzędzia z configu
    brightnessctl
    playerctl
    cbatticon
    hyprshot
    bibata-cursors
    lxqt.lxqt-policykit
  ];
  system.stateVersion = "26.11";
}
