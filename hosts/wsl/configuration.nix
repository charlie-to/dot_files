{ pkgs, inputs, ... }:
let
  username = "nixos";
in
{
  imports = [
    ./podman.nix
    inputs.nixos-wsl.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];

  wsl = {
    enable = true;
    defaultUser = username;
    interop = {
      register = true;
      includePath = true;
    };
    wslConf.boot.systemd = true;
  };

  networking.hostName = "wsl";
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.overlays = [ inputs.nix-claude-code.overlays.default ];
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "claude-code"
    "1password-cli"
    "terraform"
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.${username} = import ./users/${username}/home-configuration.nix;
    backupFileExtension = "bak";
  };

  system.stateVersion = "25.11";
  
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEL7UB8u5YiNZM9l+l4ZEQh+fKauit7VIxpBOslm/xn1"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  programs.nix-ld.enable = true;
  
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
    libgcc
  ];
  
  nix.settings.fallback = true;
}