local languages = {
  'typescript',
  'vue',
  'lua',
  'go',
  'csharp',
  'dart',
  'web',
  'rust',
  'ruby'
}

for _, lang in ipairs(languages) do
  require('languages.' .. lang)
end