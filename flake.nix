{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    # wspólne moduły dla każdego hosta
    base = [
      ./configuration.nix
      inputs.home-manager.nixosModules.default
    ];
    mkHost = extraModules: nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = base ++ extraModules;
    };
  in {
    nixosConfigurations = {
      # host z kartą NVIDIA
      nixos = mkHost [ ./nvidia.nix ];

      # ten sam config, ale bez sterownika NVIDIA
      nixos-nonvidia = mkHost [ ];
    };
  };
}
