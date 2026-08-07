{ ... }:
{
  # プロジェクトを開くと .envrc (use flake) の環境が nvim に読み込まれ、
  # devShell の ruff が PATH 前方に入る → ruff LSP がプロジェクト版を使う
  programs.nixvim.plugins.direnv.enable = true;
}
