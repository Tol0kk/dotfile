{ pkgs, lib, config, inputs, ... }:

with lib;
let
  cfg = config.modules.nixvim;
in
{
  options.modules.nixvim = {
    enable = mkOption {
      description = "Enable nixvim";
      type = types.bool;
      default = false;
    };
  };

  imports = [
    inputs.nixvim.nixosModules.nixvim
    #   ./plugins/startify.nix
    #   ./plugins/lsp.nix
  ];

  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };
      extraPlugins = with pkgs.vimPlugins; [
        gruvbox
      ];
      colorscheme = "gruvbox";
      options = {
        clipboard.register = "unnamed";
        clipboard.clipboard.providers.wl-copy.enable = true;
        number = true; # Show line numbers
        relativenumber = true; # Show relative line numbers
        incsearch = true;
        shiftwidth = 2; # Tab width should be 2
      };

      plugins = {
        # image.enable = true; // TODO update nixvim (in 24.05)
        # lightline.enable = true;
        # lsp-format.enable = true;
        # nvim-tree.enable = true;
        which-key.enable = true;
        floaterm = {
          enable = true;
          keymaps.toggle = "<leader>,";
        };
        barbar = {
          enable = true;
          # keymaps = {
          #   next = "<TAB>";
          #   previous = "<S-TAB>";
          #   close = "<C-w>";
          # };
        };
        efmls-configs = {
          enable = true;
          setup = {
            jsonc = {
              formatter = "biome";
              linter = "codespell";
            };
          };
        };
        alpha.enable = false; # Greeter
        # dashboard.enable = true; # Dashboard TODO compare with alpha
        # autoclose.enable = true; Update nixvim + complete configuration
        # barbecue.enable = true; # LSP context
        # coverage.enable = true; # TODO test it on rust and python
        crates-nvim.enable = true; # Rust crate manager
        cursorline = {
          enable = true;
          cursorline.enable = true;
        };
        # dap.enable = true; # TODO setup Debugger for C/C++, Rust
        # debugprint.nvim = true; # TODO test
        # diffview.enable = true; # TODO setup
        # direnv.enable = true; # FIXME
        # goyo.enable = true; # focus for nvim TODO test
        # hardtime.enable = true; # Tool to correct your vim motion
        # hmts.enable = true; # Correct inline code in nix string conf file. # TODO place it with nix lsp
        illuminate.enable = true; # automatically highlighting other uses of the word under the cursor
        # molten.enable = true; # Jupiter notebook for nvim
        # multicursors.enable = true;
        # TODO autosave plugin
        # TODO add  vim-visual-multi  plugins manully
        telescope = {
          enable = true;
          keymaps = {
            # Find files using Telescope command-line sugar.
            "<leader>ff" = "find_files";
            "<leader>fg" = "live_grep";
            "<leader>b" = "buffers";
            "<leader>fh" = "help_tags";
            "<leader>fd" = "diagnostics";

            # FZF like bindings
            "<C-p>" = "git_files";
            "<leader>fr" = "oldfiles";
            "<C-f>" = "live_grep";
          };
          settings.mappings.i = {
            "<C-up>" = {
              __raw = ''function(prompt_bufnr)
					local current_picker =
						require("telescope.actions.state").get_current_picker(prompt_bufnr)
					-- cwd is only set if passed as telescope option
					local cwd = current_picker.cwd and tostring(current_picker.cwd)
						or vim.loop.cwd()
					local parent_dir = vim.fs.dirname(cwd)

					require("telescope.actions").close(prompt_bufnr)
					require("telescope.builtin").find_files {
						prompt_title = vim.fs.basename(parent_dir),
						cwd = parent_dir,
					}
				end,
                '';
            };
          };
          defaults.file_ignore_patterns = [
            "^.git/"
            "^.flake.lock"
            "^target/"
            "^.mypy_cache/"
            "^__pycache__/"
            "^output/"
            "^data/"
            "%.ipynb"
          ];
        };
        lsp = {
          enable = true;
          keymaps = {
            silent = true;
            diagnostic = {
              "<leader>k" = "goto_prev";
              "<leader>j" = "goto_next";
            };

            lspBuf = {
              gd = "definition";
              K = "hover";
            };
          };
        };
      };
    };
  };
}
