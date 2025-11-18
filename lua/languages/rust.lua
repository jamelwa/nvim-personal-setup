local lsp_core = require('core.lsp')

vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'Cargo.lock', '.git' },
  capabilities = lsp_core.capabilities(),
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        buildScripts = {
          enable = true,
        },
      },
      checkOnSave = {
        allFeatures = true,
        command = 'clippy',
        extraArgs = { '--no-deps' },
      },
      procMacro = {
        enable = true,
        ignored = {
          ['async-trait'] = { 'async_trait' },
          ['napi-derive'] = { 'napi' },
          ['async-recursion'] = { 'async_recursion' },
        },
      },
      rustfmt = {
        extraArgs = { '+nightly' },
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
          enable = 'never',
        },
        lifetimeElisionHints = {
          enable = 'never',
          useParameterNames = false,
        },
        maxLength = 25,
        parameterHints = {
          enable = true,
        },
        reborrowHints = {
          enable = 'never',
        },
        renderColons = true,
        typeHints = {
          enable = true,
          hideClosureInitialization = false,
          hideNamedConstructor = false,
        },
      },
      lens = {
        enable = true,
        debug = {
          enable = true,
        },
        implementations = {
          enable = true,
        },
        references = {
          adt = {
            enable = true,
          },
          enumVariant = {
            enable = true,
          },
          method = {
            enable = true,
          },
          trait = {
            enable = true,
          },
        },
        run = {
          enable = true,
        },
      },
    },
  },
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'rust',
  callback = function(args)
    vim.lsp.start({ name = 'rust_analyzer', bufnr = args.buf })

    local opts = { noremap = true, silent = true, buffer = args.buf }

    vim.keymap.set('n', '<leader>cr', function()
      vim.cmd('!cargo run')
    end, vim.tbl_extend('force', opts, { desc = 'Cargo run' }))

    vim.keymap.set('n', '<leader>ct', function()
      vim.cmd('!cargo test')
    end, vim.tbl_extend('force', opts, { desc = 'Cargo test' }))

    vim.keymap.set('n', '<leader>cb', function()
      vim.cmd('!cargo build')
    end, vim.tbl_extend('force', opts, { desc = 'Cargo build' }))

    vim.keymap.set('n', '<leader>cC', function()
      vim.cmd('!cargo check')
    end, vim.tbl_extend('force', opts, { desc = 'Cargo check' }))

    vim.keymap.set('n', '<leader>cl', function()
      vim.cmd('!cargo clippy')
    end, vim.tbl_extend('force', opts, { desc = 'Cargo clippy' }))

    vim.keymap.set('n', '<leader>cF', function()
      vim.cmd('!cargo fmt')
    end, vim.tbl_extend('force', opts, { desc = 'Cargo format' }))

    vim.keymap.set('n', '<leader>cd', function()
      vim.cmd('!cargo doc --open')
    end, vim.tbl_extend('force', opts, { desc = 'Cargo doc' }))

    local dap = require('dap')
    vim.keymap.set('n', '<leader>dd', dap.toggle_breakpoint, vim.tbl_extend('force', opts, { desc = 'Toggle breakpoint' }))
    vim.keymap.set('n', '<leader>dc', dap.continue, vim.tbl_extend('force', opts, { desc = 'Debug continue' }))
    vim.keymap.set('n', '<leader>dn', dap.step_over, vim.tbl_extend('force', opts, { desc = 'Debug step over' }))
    vim.keymap.set('n', '<leader>di', dap.step_into, vim.tbl_extend('force', opts, { desc = 'Debug step into' }))
    vim.keymap.set('n', '<leader>do', dap.step_out, vim.tbl_extend('force', opts, { desc = 'Debug step out' }))
  end,
})