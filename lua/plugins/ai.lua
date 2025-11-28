return {
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("claude-code").setup({
        window = {
          split_ratio = 0.3,
          position = "botright",
          enter_insert = true,
          hide_numbers = true,
          hide_signcolumn = true,
        },
        refresh = {
          enable = true,
          updatetime = 100,
          timer_interval = 1000,
          show_notifications = true,
        },
        git = {
          use_git_root = true,
        },
        shell = {
          separator = "&&",
          pushd_cmd = "pushd",
          popd_cmd = "popd",
        },
        command = "claude",
        command_variants = {
          continue = "--continue",
          resume = "--resume",
          verbose = "--verbose",
        },
        keymaps = {
          toggle = {
            normal = "<C-,>",
            terminal = "<C-,>",
            variants = {
              continue = "<leader>cC",
              verbose = "<leader>cV",
            },
          },
          window_navigation = true,
          scrolling = true,
        },
      })
    end,
  },

  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    opts = {
      behaviour = {
        auto_suggestions = false,
        minimize_diff = false,
        enable_cursor_planning_mode = true,
        enable_claude_text_editor_tool_mode = true,
      },
      provider = "copilot",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4",
          timeout = 30000,
          extra_request_body = {
            temperature = 0,
            max_tokens = 20480,
          },
        },
        copilot = {
          endpoint = "https://api.githubcopilot.com",
          model = "gpt-4o",
          proxy = nil,
          allow_insecure = false,
          timeout = 30000,
          extra_request_body = {
            temperature = 0.1,
            max_tokens = 10240,
          },
        },
      },
    },
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "echasnovski/mini.pick",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
      "ibhagwan/fzf-lua",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },

  {
    "github/copilot.vim",
    event = "VimEnter",
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true

      -- Auto-start copilot
      vim.defer_fn(function()
        vim.cmd("Copilot status")
      end, 100)

      vim.api.nvim_set_keymap("i", "<C-j>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
      vim.api.nvim_set_keymap("i", "<C-l>", "copilot#Next()", { silent = true, expr = true })
      vim.api.nvim_set_keymap("i", "<C-h>", "copilot#Previous()", { silent = true, expr = true })
      vim.api.nvim_set_keymap("i", "<C-o>", "copilot#Dismiss()", { silent = true, expr = true })
    end,
  },
}