local lsp_core = require("core.lsp")
local lspconfig = require("lspconfig")

-- Get current RVM ruby version dynamically
local function get_rvm_ruby_bin(gem_name)
  local handle = io.popen("rvm current 2>/dev/null")
  local ruby_version = handle:read("*a"):gsub("%s+", "")
  handle:close()

  if ruby_version and ruby_version ~= "" then
    return string.format("%s/.rvm/gems/%s/bin/%s", os.getenv("HOME"), ruby_version, gem_name)
  end
  return gem_name -- fallback to system gem
end

local ruby_lsp_cmd = get_rvm_ruby_bin("ruby-lsp")

lspconfig.ruby_lsp.setup({
  cmd = { ruby_lsp_cmd },
  capabilities = lsp_core.capabilities(),
  on_attach = lsp_core.on_attach,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ruby", "eruby" },
  callback = function(args)
    local opts = { noremap = true, silent = true, buffer = args.buf }

    -- Ruby project commands with accessible <leader>cr prefix (ruby)
    local Terminal = require("toggleterm.terminal").Terminal

    vim.keymap.set("n", "<leader>crr", function()
      local file = vim.fn.expand("%:p")
      local ruby_run = Terminal:new({
        cmd = "ruby " .. file,
        direction = "float",
        close_on_exit = false,
      })
      ruby_run:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Run current file" }))

    vim.keymap.set("n", "<leader>crt", function()
      local ruby_test = Terminal:new({
        cmd = "ruby -I test test/",
        direction = "float",
        close_on_exit = false,
      })
      ruby_test:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Run tests" }))

    vim.keymap.set("n", "<leader>crT", function()
      local rspec_test = Terminal:new({
        cmd = "rspec",
        direction = "float",
        close_on_exit = false,
      })
      rspec_test:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Run RSpec tests" }))

    vim.keymap.set("n", "<leader>crf", function()
      local file = vim.fn.expand("%:p")
      local current_line = vim.api.nvim_win_get_cursor(0)[1]
      local rspec_file = Terminal:new({
        cmd = string.format("rspec %s:%d", file, current_line),
        direction = "float",
        close_on_exit = false,
      })
      rspec_file:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Run RSpec at cursor" }))

    vim.keymap.set("n", "<leader>crc", function()
      local rubocop_check = Terminal:new({
        cmd = "rubocop",
        direction = "float",
        close_on_exit = false,
      })
      rubocop_check:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Rubocop check" }))

    vim.keymap.set("n", "<leader>crC", function()
      local rubocop_fix = Terminal:new({
        cmd = "rubocop -a",
        direction = "float",
        close_on_exit = false,
      })
      rubocop_fix:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Rubocop auto-fix" }))

    vim.keymap.set("n", "<leader>crb", function()
      local bundle_install = Terminal:new({
        cmd = "bundle install",
        direction = "float",
        close_on_exit = false,
      })
      bundle_install:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Bundle install" }))

    vim.keymap.set("n", "<leader>cru", function()
      local bundle_update = Terminal:new({
        cmd = "bundle update",
        direction = "float",
        close_on_exit = false,
      })
      bundle_update:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Bundle update" }))

    vim.keymap.set("n", "<leader>crs", function()
      local rails_server = Terminal:new({
        cmd = "rails server",
        direction = "float",
        close_on_exit = false,
      })
      rails_server:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Rails server" }))

    vim.keymap.set("n", "<leader>crm", function()
      local rails_migrate = Terminal:new({
        cmd = "rails db:migrate",
        direction = "float",
        close_on_exit = false,
      })
      rails_migrate:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Rails migrate" }))

    vim.keymap.set("n", "<leader>crR", function()
      local rails_routes = Terminal:new({
        cmd = "rails routes",
        direction = "float",
        close_on_exit = false,
      })
      rails_routes:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Rails routes" }))

    vim.keymap.set("n", "<leader>crg", function()
      local rails_generate = vim.fn.input("Generate: ")
      if rails_generate ~= "" then
        local rails_gen = Terminal:new({
          cmd = "rails generate " .. rails_generate,
          direction = "float",
          close_on_exit = false,
        })
        rails_gen:toggle()
      end
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Rails generate" }))

    vim.keymap.set("n", "<leader>cri", function()
      local irb = Terminal:new({
        cmd = "irb",
        direction = "float",
        close_on_exit = false,
      })
      irb:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: IRB console" }))

    vim.keymap.set("n", "<leader>crI", function()
      local rails_console = Terminal:new({
        cmd = "rails console",
        direction = "float",
        close_on_exit = false,
      })
      rails_console:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Rails console" }))

    vim.keymap.set("n", "<leader>crv", function()
      local ruby_version = Terminal:new({
        cmd = "ruby --version",
        direction = "float",
        close_on_exit = false,
      })
      ruby_version:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Show version" }))

    vim.keymap.set("n", "<leader>crG", function()
      local gem_list = Terminal:new({
        cmd = "gem list",
        direction = "float",
        close_on_exit = false,
      })
      gem_list:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: List gems" }))

    vim.keymap.set("n", "<leader>crl", function()
      local reek = Terminal:new({
        cmd = "reek",
        direction = "float",
        close_on_exit = false,
      })
      reek:toggle()
    end, vim.tbl_extend("force", opts, { desc = "Ruby: Reek code smells" }))

    -- Keep F-key debug bindings consistent with other languages
    local dap = require("dap")
    if not vim.g.ruby_debug_keys_set then
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

      vim.g.ruby_debug_keys_set = true
    end
  end,
})