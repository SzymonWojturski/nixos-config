{ config, lib, pkgs, ... }:
{
  # Sterownik NVIDIA (zamiast otwartego nouveau)
  services.xserver.videoDrivers = [ "nvidia" ];

  # Akceleracja sprzętowa (dawniej hardware.opengl)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # dla Steam / 32-bit gier
  };

  hardware.nvidia = {
    # KLUCZOWE dla Waylanda (Hyprland, niri) — bez tego kompozytor często nie wstaje
    modesetting.enable = true;

    # Otwarte moduły jądra NVIDIA (nowszy, zalecany standard).
    #   true  -> Turing i nowsze (RTX 20xx, GTX 16xx — np. 1660)
    #   false -> starsze karty, w tym Pascal (GTX 10xx — np. 1060)
    # Zakładamy nowszy standard. Jeśli okaże się, że masz 1060 (Pascal)
    # i system nie wstaje / brak obrazu -> zmień na false.
    open = true;

    # Aplikacja nvidia-settings w systemie
    nvidiaSettings = true;

    # Power management — pomaga przy wybudzaniu ze sleepa.
    # Bywa niestabilne na starszych kartach, w razie problemów ustaw false.
    powerManagement.enable = true;

    # Wersja sterownika. stable zwykle wystarcza;
    # dla bardzo nowych kart można dać .beta lub .production.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Zmienne środowiskowe ułatwiające życie na Wayland + NVIDIA
  environment.sessionVariables = {
    # Wymusza backend GBM (potrzebne dla wielu aplikacji na NVIDII)
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # Pomaga z kursorem / renderowaniem w Hyprlandzie
    LIBVA_DRIVER_NAME = "nvidia";
  };
}
