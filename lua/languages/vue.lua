local lsp_core = require('core.lsp')

-- Check if vue language server is available
local function get_vue_cmd()
  if vim.fn.executable('vue-language-server') == 1 then
    return { 'vue-language-server', '--stdio' }
  elseif vim.fn.executable('vls') == 1 then
    return { 'vls' }
  end
  return nil
end

local vue_cmd = get_vue_cmd()

if vue_cmd then
  vim.lsp.config('volar', {
    cmd = vue_cmd,
    filetypes = { 'vue' },
    root_markers = { 'package.json', 'vue.config.js', 'nuxt.config.js', '.git' },
    capabilities = lsp_core.capabilities(),
    settings = {
      vue = {
        complete = {
          casing = {
            tags = 'kebab',
            props = 'camel'
          }
        }
      }
    }
  })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'vue',
    callback = function(args)
      vim.lsp.start({ name = 'volar', bufnr = args.buf })
    end,
  })
end