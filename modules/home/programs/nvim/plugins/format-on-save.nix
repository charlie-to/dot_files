{ ... }:
{
  # VSCode の formatOnSave + source.fixAll + source.organizeImports 相当。
  # Python 保存時に ruff のコードアクション → フォーマットの順で実行する。
  programs.nixvim.autoCmd = [
    {
      event = [ "BufWritePre" ];
      pattern = [ "*.py" ];
      desc = "Ruff: fixAll + organizeImports + format on save";
      callback.__raw = ''
        function()
          -- source.fixAll と source.organizeImports を同期実行
          for _, action in ipairs({ "source.fixAll", "source.organizeImports" }) do
            vim.lsp.buf.code_action({
              context = { only = { action }, diagnostics = {} },
              apply = true,
            })
          end
          -- ruff でフォーマット
          vim.lsp.buf.format({ async = false })
        end
      '';
    }
  ];
}
