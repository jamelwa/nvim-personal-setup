return {
  {
    'GustavEikaas/easy-dotnet.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
      vim.env.PATH = "/home/jamal/.dotnet:" .. (vim.env.PATH or "")

      -- Ensure dotnet is available for the server
      local handle = io.popen("which dotnet 2>/dev/null")
      local dotnet_path = handle:read("*a"):gsub("%s+", "")
      handle:close()

      if dotnet_path == "" then
        vim.env.DOTNET_ROOT = "/home/jamal/.dotnet"
        vim.env.PATH = "/home/jamal/.dotnet:" .. vim.env.PATH
      end

      local function get_secret_path(secret_guid)
        local path = ""
        local home_dir = os.getenv("HOME")
        if vim.fn.has("win32") == 1 then
          path = home_dir .. "\\AppData\\Roaming\\Microsoft\\UserSecrets\\" .. secret_guid .. "\\secrets.json"
        else
          path = home_dir .. "/.microsoft/usersecrets/" .. secret_guid .. "/secrets.json"
        end
        return path
      end

      local dotnet = require("easy-dotnet")
      dotnet.setup({
        get_sdk_path = function()
          return "/home/jamal/.dotnet/dotnet"
        end,
        dotnet_cli_path = "/home/jamal/.dotnet/dotnet",
        bootstrap = false,  -- Disable server bootstrap
        terminal = function(path, action)
          local commands = {
            run = function()
              return "dotnet run --project " .. path
            end,
            test = function()
              return "dotnet test " .. path
            end,
            restore = function()
              return "dotnet restore " .. path
            end,
            build = function()
              return "dotnet build " .. path
            end
          }
          local command = commands[action] and commands[action]() or ""
          if command ~= "" then
            vim.cmd("vsplit")
            vim.cmd("terminal " .. command)
            vim.cmd("startinsert")
          end
        end,
        secrets = {
          get_secret_path = get_secret_path
        },
        csproj_mappings = true,
        fsproj_mappings = true,
        auto_bootstrap_namespace = true
      })

      vim.keymap.set("n", "<leader>netb", function()
        vim.cmd("split | terminal /home/jamal/.dotnet/dotnet build")
      end, { desc = "Build .NET project" })

      vim.keymap.set("n", "<leader>netr", function()
        local projects = vim.fn.glob("**/*.csproj", false, true)
        if #projects == 0 then
          vim.cmd("split | terminal /home/jamal/.dotnet/dotnet run")
          return
        elseif #projects == 1 then
          local Terminal = require('toggleterm.terminal').Terminal
          local dotnet_run = Terminal:new({
            cmd = "/home/jamal/.dotnet/dotnet run --project " .. projects[1],
            direction = "float",
            close_on_exit = false,
          })
          dotnet_run:toggle()
          return
        end

        vim.ui.select(projects, {
          prompt = "Select project to run:",
          format_item = function(item)
            return vim.fn.fnamemodify(item, ":t:r")
          end
        }, function(choice)
          if choice then
            local Terminal = require('toggleterm.terminal').Terminal
            local dotnet_run = Terminal:new({
              cmd = "/home/jamal/.dotnet/dotnet run --project " .. choice,
              direction = "float",
              close_on_exit = false,
            })
            dotnet_run:toggle()
          end
        end)
      end, { desc = "Run .NET project" })

      vim.keymap.set("n", "<leader>nett", function()
        vim.cmd("split | terminal /home/jamal/.dotnet/dotnet test")
      end, { desc = "Test .NET project" })

      vim.keymap.set("n", "<leader>netR", function()
        vim.cmd("split | terminal /home/jamal/.dotnet/dotnet restore")
      end, { desc = "Restore .NET project" })
    end,
  },
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')
      local dap_virtual_text = require('nvim-dap-virtual-text')

      dapui.setup({
        icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },
        mappings = {
          expand = { '<CR>', '<2-LeftMouse>' },
          open = 'o',
          remove = 'd',
          edit = 'e',
          repl = 'r',
          toggle = 't',
        },
        element_mappings = {},
        expand_lines = vim.fn.has('nvim-0.7') == 1,
        layouts = {
          {
            elements = {
              { id = 'scopes', size = 0.25 },
              'breakpoints',
              'stacks',
              'watches',
            },
            size = 40,
            position = 'left',
          },
          {
            elements = {
              'repl',
              'console',
            },
            size = 0.25,
            position = 'bottom',
          },
        },
        controls = {
          enabled = true,
          element = 'repl',
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = 'single',
          mappings = {
            close = { 'q', '<Esc>' },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        },
      })

      dap_virtual_text.setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
        display_callback = function(variable, buf, stackframe, node, options)
          if options.virt_text_pos == 'inline' then
            return ' = ' .. variable.value
          else
            return variable.name .. ' = ' .. variable.value
          end
        end,
        virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil
      })

      dap.adapters.lldb = {
        type = 'executable',
        command = 'lldb-vscode',
        name = 'lldb'
      }

      dap.adapters.netcoredbg = {
        type = 'executable',
        command = '/home/jamal/.local/share/nvim/mason/bin/netcoredbg',
        args = {'--interpreter=vscode'}
      }

      dap.adapters.ruby = {
        type = 'executable',
        command = 'ruby-debug-ide',
        args = { '--host', '127.0.0.1', '--port', '${port}', '--dispatcher-port', '${port}' },
        port = 38698
      }

      dap.configurations.rust = {
        {
          name = 'Launch',
          type = 'lldb',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
        },
        {
          name = 'Attach to process',
          type = 'lldb',
          request = 'attach',
          pid = require('dap.utils').pick_process,
          args = {},
        },
      }

      -- Common debug configuration function
      local function get_dotnet_debug_config()
        return {
          type = "netcoredbg",
          name = "Launch .NET Core",
          request = "launch",
          program = function()
            local cwd = vim.fn.getcwd()
            local projects = vim.fn.glob("**/*.csproj", false, true)

            local function find_dll(project_path)
              local project_name = vim.fn.fnamemodify(project_path, ":t:r")
              local project_dir = vim.fn.fnamemodify(project_path, ":h")

              -- Check common .NET versions
              for _, version in ipairs({"net8.0", "net6.0", "net5.0", "netcoreapp3.1"}) do
                local dll_path = project_dir .. '/bin/Debug/' .. version .. '/' .. project_name .. '.dll'
                if vim.fn.filereadable(dll_path) == 1 then
                  return dll_path
                end
              end
              return nil
            end

            if #projects == 0 then
              return vim.fn.input('Path to dll: ', cwd .. '/bin/Debug/', 'file')
            elseif #projects == 1 then
              local dll = find_dll(projects[1])
              if dll then return dll end
              return vim.fn.input('Path to dll: ', cwd .. '/bin/Debug/', 'file')
            else
              local choices = {}
              for i, project in ipairs(projects) do
                local name = vim.fn.fnamemodify(project, ":t:r")
                table.insert(choices, string.format("%d. %s", i, name))
              end

              local choice = vim.fn.inputlist(vim.tbl_extend("force", {"Select project to debug:"}, choices))
              if choice > 0 and choice <= #projects then
                local dll = find_dll(projects[choice])
                if dll then return dll end
              end
              return vim.fn.input('Path to dll: ', cwd .. '/bin/Debug/', 'file')
            end
          end,
          cwd = '${workspaceFolder}',
          stopAtEntry = false,
        }
      end

      dap.configurations.cs = {
        get_dotnet_debug_config(),
        {
          type = "netcoredbg",
          name = "Attach to process",
          request = "attach",
          processId = require('dap.utils').pick_process,
        }
      }

      -- Also support debugging from solution directory (netrw)
      dap.configurations.netrw = { get_dotnet_debug_config() }

      dap.configurations.ruby = {
        {
          name = "Debug Ruby file",
          type = "ruby",
          request = "launch",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          name = "Debug Ruby script with args",
          type = "ruby",
          request = "launch",
          program = function()
            return vim.fn.input("Path to ruby script: ", vim.fn.expand("%:p"), "file")
          end,
          args = function()
            local input = vim.fn.input("Script arguments: ")
            return vim.split(input, " ")
          end,
          cwd = "${workspaceFolder}",
        },
        {
          name = "Debug Rails server",
          type = "ruby",
          request = "launch",
          program = "bin/rails",
          args = { "server" },
          cwd = "${workspaceFolder}",
        },
        {
          name = "Attach to Ruby process",
          type = "ruby",
          request = "attach",
          host = "127.0.0.1",
          port = 38698,
        }
      }

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<S-F9>', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Conditional Breakpoint' })
      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })
    end,
  },
}