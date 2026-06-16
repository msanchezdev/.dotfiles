--- @alias KeymapMapper fun(keys: string, func: string | function, desc?: string, opts?: table)
---
--- @class ModeHelper
--- @field normal KeymapMapper,
--- @field insert KeymapMapper,
--- @field visual KeymapMapper,
--- @field command KeymapMapper,
--- @field terminal KeymapMapper,
--- @field augroup fun(name: string, opts: vim.api.keyset.create_augroup),
--- @field autocmd fun(name: string | table, opts: vim.api.keyset.create_autocmd)
---
--- @param name string
--- @param callback fun(m: ModeHelper)
function group(name, callback)
  local function mapper_for_mode(mode)
    return function(keys, func, desc, opts)
      opts = opts or {}
      if desc then
        opts['desc'] = name .. ': ' .. desc
      end

      vim.keymap.set(mode, keys, func, opts)
    end
  end

  callback({
    normal = mapper_for_mode('n'),
    insert = mapper_for_mode('i'),
    visual = mapper_for_mode('v'),
    command = mapper_for_mode('c'),
    terminal = mapper_for_mode('t'),
    augroup = vim.api.nvim_create_augroup,
    autocmd = vim.api.nvim_create_autocmd,
  })
end

group('Buffers', function(m)
  m.normal('<leader>`', '<cmd>e #<cr>', 'Switch to Other Buffer')
  m.normal('<leader>bd', '<cmd>:bd<cr>', 'Delete Buffer and Window')
  m.normal('<leader>bD', '<cmd>:bd!<cr>', 'Delete Buffer and Window (discard changes)')
end)

group('Move Lines', function(m)
  m.normal('<C-A-j>', '<cmd>m .+1<cr>==', 'Move Down')
  m.normal('<C-A-k>', '<cmd>m .-2<cr>==', 'Move Up')
  m.insert('<C-A-j>', '<esc><cmd>m .+1<cr>==gi', 'Move Down')
  m.insert('<C-A-k>', '<esc><cmd>m .-2<cr>==gi', 'Move Up')
  m.visual('<C-A-j>', ':m \'>+1<cr>gv=gv', 'Move Down')
  m.visual('<C-A-k>', ':m \'<-2<cr>gv=gv', 'Move Up')
end)

group('Project', function(m)
  m.normal('<leader>pv', vim.cmd.Ex, 'Project View')
end)

group('Others', function(m)
  m.normal('Q', '<nop>')
  m.normal('<C-d>', '<C-d>zz')
  m.normal('<C-u>', '<C-u>zz')
  m.normal('n', 'nzzzv')
  m.normal('N', 'Nzzzv')

  m.insert('<C-h>', '<Left>')
  m.insert('<C-j>', '<Down>')
  m.insert('<C-k>', '<Up>')
  m.insert('<C-l>', '<Right>')

  m.normal('<leader>y', '"+y')
  m.visual('<leader>y', '"+y')
  m.normal('<leader>Y', '"+Y')

  m.normal('<leader>d', '"_d')
  m.visual('<leader>d', '"_d')

  m.insert('<C-c>', '<Esc>')
end)
