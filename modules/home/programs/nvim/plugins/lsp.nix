{ ... }:
{
  programs.nixvim.plugins.lsp = {
    enable = true;

    servers.ruff = {
      enable = true;
      # プロジェクトの flake devShell (direnv) が提供する ruff を優先し、
      # 無い場所では nixvim 管理の ruff にフォールバックする
      # (PATH 末尾に追加される)
      packageFallback = true;
    };

    # LSP アタッチ時のキーマップ
    keymaps = {
      lspBuf = {
        K = "hover";
        gd = "definition";
        gr = "references";
        "<leader>rn" = "rename";
        "<leader>ca" = "code_action";
      };
      diagnostic = {
        "<leader>e" = "open_float";
        "[d" = "goto_prev";
        "]d" = "goto_next";
      };
    };
  };
}
