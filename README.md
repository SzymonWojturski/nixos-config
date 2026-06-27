# nixos-config

Moja konfiguracja NixOS (flake + home-manager, Wayland: Hyprland / niri).

## Hosty

W `flake.nix` zdefiniowane są dwa warianty tej samej konfiguracji:

| Host             | Opis                                  |
|------------------|---------------------------------------|
| `nixos`          | maszyna z kartą **NVIDIA** (wpina `nvidia.nix`) |
| `nixos-nonvidia` | maszyna **bez** NVIDII (AMD/Intel)    |

## Rebuild (w zależności od systemu)

```bash
# maszyna z NVIDIĄ
sudo nixos-rebuild switch --flake .#nixos

# maszyna bez NVIDII (AMD / Intel)
sudo nixos-rebuild switch --flake .#nixos-nonvidia
```

Test bez aktywacji (sprawdza, czy się buduje):

```bash
sudo nixos-rebuild dry-build --flake .#nixos
nix flake check
```

## Jak sprawdzić, którą mam kartę

```bash
# bez instalowania niczego
nix-shell -p pciutils --run "lspci | grep -i -e vga -e 3d"
# albo, jeśli masz lspci:
lspci | grep -i nvidia
```

## Konfiguracja NVIDIA — co i gdzie zmienić, gdy coś nie działa

Wszystkie ustawienia NVIDIA są w **`nvidia.nix`**. Domyślnie zakładamy
**nowszy standard** (otwarte moduły jądra).

### `open` — otwarte vs proprietary moduły jądra

`hardware.nvidia.open` w `nvidia.nix`:

- `true`  → Turing i nowsze: **RTX 20xx+, GTX 16xx** (np. **1660**). Domyślne.
- `false` → starsze, w tym Pascal: **GTX 10xx** (np. **1060**).

**Objaw złego ustawienia:** po rebuildzie brak obrazu / czarny ekran /
kompozytor (Hyprland/niri) nie wstaje.
**Naprawa:** masz starą kartę (1060) → ustaw `open = false`.

### Wayland nie startuje na NVIDII

Upewnij się, że w `nvidia.nix` jest:

```nix
hardware.nvidia.modesetting.enable = true;
```

(to jest kluczowe dla Waylanda — bez tego kompozytor zwykle nie wstaje).

### Problemy po wybudzeniu ze sleepa / artefakty

W `nvidia.nix` spróbuj wyłączyć power management:

```nix
hardware.nvidia.powerManagement.enable = false;
```

### Za stara / za nowa wersja sterownika

W `nvidia.nix` zmień `package`:

```nix
# stabilny (domyślny)
package = config.boot.kernelPackages.nvidiaPackages.stable;
# nowsze karty:
# package = config.boot.kernelPackages.nvidiaPackages.beta;
# package = config.boot.kernelPackages.nvidiaPackages.production;
```

## Dodanie NVIDII do nowej maszyny

Jeśli kolejny komputer też ma NVIDIĘ, ale inną konfigurację — dodaj nowy
wpis w `flake.nix` (sekcja `nixosConfigurations`), np.:

```nix
nixos-desktop = mkHost [ ./nvidia.nix ];
```

i rebuild przez `--flake .#nixos-desktop`.

## Uwaga: ścieżki zależne od maszyny

- `configuration.nix`: `swapDevices` ma twardą ścieżkę do dysku
  (`/dev/nvme0n1p1`) — sprawdź, czy zgadza się na danej maszynie.
- `home.nix`: symlink `waypaper` wskazuje na `~/nixos-config/...` —
  dostosuj, jeśli repo leży gdzie indziej.
- `hardware-configuration.nix` jest per-maszyna (generowany przez instalator)
  i nie powinien być kopiowany między komputerami.
