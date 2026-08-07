{ inputs, pkgs, ... }:
{
  imports = [
    ./options.nix
    ./keymaps.nix
    ./plugins/oil.nix
    ./plugins/which-key.nix
    ./plugins/web-devicons.nix
    ./plugins/no-neck-pain.nix
    ./plugins/flash.nix
    ./plugins/lsp.nix
    ./plugins/direnv.nix
    ./plugins/format-on-save.nix
  ];

  programs.nixvim = {
    enable = true;
    nixpkgs.source = inputs.nixpkgs;
  };
}
