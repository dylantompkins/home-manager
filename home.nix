{ config, lib, pkgs, ... }:
let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
  });
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dylan";
  home.homeDirectory = "/home/dylan";
  xdg.configHome = "/home/dylan/.config/";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dylan/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      cat ~/.nix-profile/etc/profile.d/hm-session-vars.sh | babelfish | source
    '';
  };

  imports = [ nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;

    extraPlugins = with pkgs.vimPlugins; [
      everforest
      friendly-snippets
    ];
    colorscheme = "everforest";

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    plugins = {
      alpha = {
        enable = true;
        iconsEnabled = true;
      };
      vimtex.enable = true;
      treesitter.enable = true;
      bufferline.enable = true;
      nvim-cmp = {
        enable = true;
        sources = [
          { name = "nvim_lsp"; }
          { name = "buffer"; }
          { name = "path"; }
          { name = "luasnip"; }
        ];
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                else
                  fallback()
                end
              end
            '';
            modes = [
              "i"
              "s"
            ];
          };
        };
        snippet.expand = "luasnip";
      };
      lsp = {
        enable = true;
        servers = {
          ltex.enable = true;
          rnix-lsp.enable = true;
        };
      };
      luasnip = {
        enable = true;
        fromVscode = [{ }];
      };
      lsp-format.enable = true;
      neo-tree.enable = true;
      which-key.enable = true;
      lualine.enable = true;
    };

    options = {
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      fillchars.eob = " ";
      ignorecase = true;
    };
  };
}
