{isMinimal, ...}: let
  isNormal = !isMinimal;
in {
  # Add any custom options (and do feel free to upstream them!)
  # options = { ... };

  config.vim = {
    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
      transparent = true;
    };

    lsp = {
      formatOnSave = true;
      lspSignature.enable = true;
      lightbulb.enable = true; # Show Lightbulb when code action available
      trouble.enable = true; # Add diagnostics, references, telescope results, quickfix
      otter-nvim.enable = true; # Add lsp features & code completion source for code embedded in other documents
    };

    debugger = {
      nvim-dap = {
        enable = isNormal;
        ui.enable = isNormal;
      };
    };

    visuals = {
      fidget-nvim.enable = true;
      nvim-scrollbar.enable = isNormal;
    };

    ui = {
      noice.enable = true;
      colorizer.enable = true;
    };

    statusline = {
      lualine = {
        enable = true;
      };
    };

    terminal.toggleterm.enable = true;

    notes = {
      todo-comments.enable = true;
    };

    autocomplete.nvim-cmp.enable = true;
    autopairs.nvim-autopairs.enable = true;

    # Snippet engine for neovim
    snippets.luasnip.enable = isNormal;
    filetree.neo-tree.enable = true;

    # Add code context (on top of the code editor)
    treesitter.context.enable = false;

    binds = {
      whichKey.enable = true;
      cheatsheet.enable = true;
    };

    git = {
      enable = true;
      gitsigns.enable = true;
      gitsigns.codeActions.enable = false; # throws an annoying debug message
    };

    projects = {
      project-nvim.enable = isNormal;
    };

    comments = {
      comment-nvim.enable = true;
    };

    session = {
      nvim-session-manager.enable = false;
    };

    utility = {
      # ccc.enable = isNormal;
      diffview-nvim.enable = isNormal;
      images.image-nvim = {
        setupOpts.backend = "kitty";
        enable = isNormal;
      };
      # Create Tempalte file (https://github.com/otavioschwanck/new-file-template.nvim)
      new-file-template.enable = isNormal;

      vim-wakatime.enable = true;
    };

    telescope.enable = true;

    languages = {
      enableLSP = true;
      enableFormat = true;
      enableTreesitter = true;
      markdown = {
        enable = true;
        extensions.render-markdown-nvim.enable = true;
      };
      bash.enable = true;
      html.enable = true;
      nix.enable = true;
      python.enable = true;
      sql.enable = true;

      # Enable if normal install
      enableDAP = isNormal;
      assembly.enable = isNormal;
      clang.enable = isNormal;
      css.enable = isNormal;
      go.enable = isNormal;
      java.enable = isNormal;
      kotlin.enable = isNormal;
      lua.enable = isNormal;
      svelte.enable = isNormal;
      tailwind.enable = isNormal;
      ts.enable = isNormal;
      wgsl.enable = isNormal;
      zig.enable = isNormal;
      typst = {
        enable = isNormal;
        extensions.typst-preview-nvim.enable = isNormal;
      };
      rust = {
        enable = isNormal;
        crates.enable = isNormal;
      };
    };
  };
}
