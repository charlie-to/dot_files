{ pkgs, lib, config, inputs, ... }:
{
  imports = [
    ./op.nix
    ./packages/nvim.nix
    ./programs/nvim
    inputs.nixvim.homeModules.nixvim
    inputs.skills.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    # claude-code (overlay applied at nixpkgs level in each host configuration)
    claude-code

    # custom packages
    (callPackage ./packages/gwq.nix { })
    (callPackage ./packages/givy.nix { })
    # navigation / search
    ghq
    fzf
    zoxide
    peco

    # dev environments / build
    devenv
    chezmoi
    devbox
    uv
    pnpm
    gradle
    luarocks
    go-task

    # CI / automation
    act
    wrkflw
    terraform

    # network tools
    arp-scan
    httpie
    wget
    rsync

    # data
    duckdb
    jq

    # file/dir/utility
    bat
    eza
    fd
    dust
    gibo

    # git
    git
    git-lfs
    gh
    lazygit
    (callPackage ./packages/keifu.nix { })

    # shell / prompt
    sheldon
    starship
    zsh-completions
    zsh-syntax-highlighting

    # terminal multiplexer
    tmux

    # shell
    zsh

    # llm-agents
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr
    inputs.takt.packages.${pkgs.stdenv.hostPlatform.system}.default

    # diagram
    d2
  ];

  home.sessionVariables = {
    PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.local/share/pnpm/bin"
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ls = "eza -l --icons";
      la = "eza -la";
      lsl = "eza --icons -a -RT --level 2";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      lg = "lazygit";
      gg = "keifu";
      claude-personal = "CLAUDE_CONFIG_DIR=~/.claude-personal claude";
      claude-work = "CLAUDE_CONFIG_DIR=~/.claude-work claude";
    };
    initContent = ''
      # lang settings for hyper
      export LANG=en_US.UTF-8
      export LC_ALL=C.UTF-8

      # givy web UI を ghq のホスト単位で起動。
      # givy は <owner>/<repo> 固定2階層・シンボリックリンク非追従・1プロセス1 root のため、
      # ホスト (github.com / localhost 等) ごとに root を切り替える。
      #   gy            -> ~/ghq/github.com を serve
      #   gy localhost  -> ~/ghq/localhost を serve
      #   gy github.com --port 6300  -> 追加フラグはそのまま givy へ渡す
      gy() { givy serve "$HOME/ghq/''${1:-github.com}" "''${@:2}"; }

      # 履歴
      # メモリに保存される履歴の件数
      export HISTSIZE=1000
      # 履歴ファイルに保存される履歴の件数
      export SAVEHIST=100000
      ## ヒストリを共有
      setopt share_history
      setopt hist_expire_dups_first # 履歴を切り詰める際に、重複する最も古いイベントから消す
      setopt hist_ignore_all_dups   # 履歴が重複した場合に古い履歴を削除する

      # ghq and gwq worktree search
      function ghq-fzf() {
        local ghq_repos=$(ghq list -p)
        local target_dir=$(echo "$ghq_repos\n$worktree_repos" | fzf --query="$LBUFFER")

        if [ -n "$target_dir" ]; then
          BUFFER="cd $target_dir"
          zle accept-line
        fi

        zle reset-prompt
      }
      zle -N ghq-fzf
      bindkey "^]" ghq-fzf
      eval "$(devbox global shellenv)"
    '';

    syntaxHighlighting.enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      scan_timeout = 1000;
      character = {
        success_symbol = "[>>](bold green)";
        error_symbol = "[>>](bold red)";
      };
      package.disabled = true;
    };
  };

  programs.fzf.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # only available on linux
  services.ssh-agent.enable = pkgs.stdenv.isLinux;

  home.file = {
    ".config/alacritty/alacritty.toml".source = ../../config/alacritty/alacritty.toml;
    ".config/alacritty/themes".source = ../../config/alacritty/themes;
    ".config/ghostty/config".source = ../../config/ghostty/config;
    ".config/gwq/config.toml".source = ../../config/gwq/config.toml;
  };

  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.optionalString pkgs.stdenv.isLinux ''
      ANTHROPIC_AUTH_TOKEN=$("$HOME/.local/bin/op" read "op://Employee/ICA_API/credential" 2>/dev/null || echo "")
      mkdir -p "$HOME/.claude"
      ${pkgs.jq}/bin/jq --arg token "$ANTHROPIC_AUTH_TOKEN" \
        '.env.ANTHROPIC_AUTH_TOKEN = $token' \
        ${../../config/claude/settings.json} > "$HOME/.claude/settings.json"
    ''
  );

  home.stateVersion = "24.11";
}
