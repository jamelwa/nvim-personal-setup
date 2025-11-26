local lsp_core = require("core.lsp")
local lspconfig = require("lspconfig")

lspconfig.rust_analyzer.setup({
  capabilities = lsp_core.capabilities(),
  on_attach = lsp_core.on_attach,
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        loadOutDirsFromCheck = false,
        buildScripts = {
          enable = false,
        },
      },
      checkOnSave = {
        command = "clippy",
        extraArgs = { "--no-deps" },
      },
      procMacro = {
        enable = true,
        ignored = {
          ["async-trait"] = { "async_trait" },
          ["napi-derive"] = { "napi" },
          ["async-recursion"] = { "async_recursion" },
        },
      },
      rustfmt = {
        extraArgs = { "+nightly" },
      },
      hover = {
        actions = {
          enable = true,
          implementations = {
            enable = true,
          },
          references = {
            enable = true,
          },
          run = {
            enable = true,
          },
          debug = {
            enable = true,
          },
        },
      },
      inlayHints = {
        bindingModeHints = {
          enable = false,
        },
        chainingHints = {
          enable = true,
        },
        closingBraceHints = {
          enable = true,
          minLines = 25,
        },
        closureReturnTypeHints = {
          enable = "never",
        },
        lifetimeElisionHints = {
          enable = "never",
          useParameterNames = false,
        },
        maxLength = 25,
        parameterHints = {
          enable = true,
        },
        reborrowHints = {
          enable = "never",
        },
        renderColons = true,
        typeHints = {
          enable = true,
          hideClosureInitialization = false,
          hideNamedConstructor = false,
        },
      },
      lens = {
        enable = false,
        debug = {
          enable = false,
        },
        implementations = {
          enable = false,
        },
        references = {
          adt = {
            enable = false,
          },
          enumVariant = {
            enable = false,
          },
          method = {
            enable = false,
          },
          trait = {
            enable = false,
          },
        },
        run = {
          enable = false,
        },
      },
      numThreads = 1,
      completion = {
        limit = 25,
      },
      diagnostics = {
        enable = true,
        disabled = {},
        enableExperimental = false,
      },
      showUnlinkedFileNotification = false,
    },
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(args)
    local opts = { noremap = true, silent = true, buffer = args.buf }

    -- Rust project commands with accessible <leader>cg prefix (cargo)
    local Terminal = require("toggleterm.terminal").Terminal

    vim.keymap.set("n", "<leader>cgr", function()
      local cargo_run = Terminal:new({
        cmd = "cargo run",
        direction = "float",
        close_on_exit = false,
      })
      cargo_run:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Cargo: Run project" }))

    vim.keymap.set("n", "<leader>cgt", function()
      local cargo_test = Terminal:new({
        cmd = "cargo test",
        direction = "float",
        close_on_exit = false,
      })
      cargo_test:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Cargo: Test project" }))

    vim.keymap.set("n", "<leader>cgb", function()
      local cargo_build = Terminal:new({
        cmd = "cargo build",
        direction = "float",
        close_on_exit = false,
      })
      cargo_build:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Cargo: Build project" }))

    vim.keymap.set("n", "<leader>cgc", function()
      local cargo_check = Terminal:new({
        cmd = "cargo check",
        direction = "float",
        close_on_exit = false,
      })
      cargo_check:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Cargo: Check project" }))

    vim.keymap.set("n", "<leader>cgl", function()
      local cargo_clippy = Terminal:new({
        cmd = "cargo clippy",
        direction = "float",
        close_on_exit = false,
      })
      cargo_clippy:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Cargo: Lint with clippy" }))

    vim.keymap.set("n", "<leader>cgf", function()
      local cargo_fmt = Terminal:new({
        cmd = "cargo fmt",
        direction = "float",
        close_on_exit = false,
      })
      cargo_fmt:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Cargo: Format code" }))

    vim.keymap.set("n", "<leader>cgd", function()
      local cargo_doc = Terminal:new({
        cmd = "cargo doc --open",
        direction = "float",
        close_on_exit = false,
      })
      cargo_doc:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Cargo: Generate docs" }))

    vim.keymap.set("n", "<leader>cgR", function()
      local cargo_run_release = Terminal:new({
        cmd = "cargo run --release",
        direction = "float",
        close_on_exit = false,
      })
      cargo_run_release:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Cargo: Run release build" }))

    vim.keymap.set("n", "<leader>cgB", function()
      local cargo_build_release = Terminal:new({
        cmd = "cargo build --release",
        direction = "float",
        close_on_exit = false,
      })
      cargo_build_release:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Cargo: Build release" }))

    vim.keymap.set("n", "<leader>cgu", function()
      local cargo_update = Terminal:new({
        cmd = "cargo update",
        direction = "float",
        close_on_exit = false,
      })
      cargo_update:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Cargo: Update dependencies" }))

    vim.keymap.set("n", "<leader>cga", function()
      local crate = vim.fn.input("Crate name: ")
      if crate ~= "" then
        local cargo_add = Terminal:new({
          cmd = "cargo add " .. crate,
          direction = "float",
          close_on_exit = false,
        })
        cargo_add:toggle()
      end
    end, vim.tbl_extend("force", opts, { desc = "Cargo: Add dependency" }))

    vim.keymap.set("n", "<leader>cgn", function()
      local name = vim.fn.input("Project name: ")
      if name ~= "" then
        local cargo_new = Terminal:new({
          cmd = "cargo new " .. name,
          direction = "float",
          close_on_exit = false,
        })
        cargo_new:toggle()
      end
    end, vim.tbl_extend("force", opts, { desc = "Cargo: New project" }))

    -- Keep F-key debug bindings consistent with dotnet
    local dap = require("dap")
    if not vim.g.rust_debug_keys_set then
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<S-F9>", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Set Conditional Breakpoint" })

      local dapui = require("dapui")
      vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Debug: Toggle UI" })

      vim.g.rust_debug_keys_set = true
    end
  end,
})
