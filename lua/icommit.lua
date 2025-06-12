local M = {}

local _mem = {}

---Function to prompt the user with options and handle their choice
---@param on_validate function: callback when validating this dialog. The function either receives nil or a string as a param.
local function ui_commit_restore(on_validate)
  local Menu = require('nui.menu')
  local menu_items = {
    Menu.item(' Use stored commit message', { text_align = 'center', id = 1 }),
    Menu.item('󰒭 Skip stored commit message', { id = 2 }),
    Menu.item(' Delete stored commit message', { id = 3 }),
  }

  local commit_options_menu = Menu({
    position = '50%',
    size = {
      width = 50,
      height = #menu_items + 2,
    },
    border = {
      style = 'single',
      text = {
        top = '[Restore Commit]',
        top_align = 'center',
      },
    },
    win_options = {
      winhighlight = 'Normal:Normal',
    },
  }, {
    lines = menu_items,
    on_submit = function(item)
      if item.id == 1 then
        -- Use store commit message
        on_validate(_mem)
      elseif item.id == 2 then
        -- Skip stored commit message
        on_validate(nil)
      elseif item.id == 3 then
        -- Delete stored commit message
        _G.icommit_saved_commit = nil
        on_validate(nil)
      end
    end,
  })

  commit_options_menu:mount()
end

---Spawn dropdown for long commit
local function ui_long_commit()
  local Popup = require('nui.popup')
  local utils = require('icommit.utils')

  local long_input = Popup({
    position = '50%',
    enter = true,
    focusable = true,
    size = {
      width = 80,
      height = 30,
    },
    border = {
      style = 'single',
      text = {
        top = '[Long Commit Message]',
        top_align = 'center',
      },
    },
  })

  local opts = _mem.opts
  local selected_type = _mem.commit_type
  local emoji = opts.commit_types[selected_type]
  local short_message = _mem.short_commit

  --NOTE: map all the submit keys
  for _, shortcut in ipairs(opts.keymap.submit) do
    long_input:map('n', shortcut, function()
      local text = utils.buffer_to_string(long_input.bufnr)
      if utils.do_commit(text) then
        _mem = { opts = opts }
      end
      long_input:unmount()
    end, { noremap = true })
  end

  --NOTE: map all the close keys
  for _, shortcut in ipairs(opts.keymap.close) do
    long_input:map('n', shortcut, function()
      long_input:unmount()
    end, { noremap = true })
  end

  long_input:mount()

  -- if restored_content then
  -- local lines = vim.split(restored_content, '\n')
  -- utils.insert_to_buffer(lines, long_input.winid, long_input.bufnr)
  -- else
  local commit_message = selected_type
  if _mem.scope ~= nil then
    commit_message = commit_message .. '(' .. _mem.scope .. ')'
  end
  if _mem.breaking == true then
    commit_message = commit_message .. '!'
  end

  commit_message = string.format('%s: %s %s', commit_message, emoji, short_message)
  local lines = { commit_message, '', '' }

  utils.insert_to_buffer(lines, long_input.winid, long_input.bufnr)
  -- end
end

local function ui_short_commit()
  local Input = require('nui.input')

  local short_input = Input({
    position = '50%',
    size = {
      width = 50,
    },
    border = {
      style = 'single',
      text = {
        top = '[Short Commit Message]',
        top_align = 'center',
      },
    },
    win_options = {
      winhighlight = 'Normal:Normal,FloatBorder:Normal',
    },
  }, {
    prompt = '> ',
    on_close = function() end,
    on_submit = function(value)
      _mem.short_commit = value
      ui_long_commit()
    end,
  })

  short_input:mount()
end

local function ui_breaking()
  local Menu = require('nui.menu')

  -- Sort alphabeticaly
  -- local types = {}
  -- for type, _ in pairs(opts.commit_types) do
  --   table.insert(types, type)
  -- end
  -- table.sort(types)

  -- Build menu labels
  local menu_items = {}
  for _, k in ipairs({ 'no', 'yes' }) do
    table.insert(menu_items, Menu.item(k))
  end

  local dropdown = Menu({
    position = '50%',
    size = {
      width = 18,
      --   height = 15,
    },
    border = {
      style = 'single',
      text = {
        top = '[Breaking Change?]',
        top_align = 'center',
      },
    },
    win_options = {
      winhighlight = 'Normal:Normal,FloatBorder:Normal',
    },
  }, {
    lines = menu_items,
    keymap = _mem.opts.keymap,
    on_close = function() end,
    on_submit = function(item)
      ui_short_commit()
    end,
  })

  dropdown:mount()
end

local function ui_scope()
  local Input = require('nui.input')

  -- Sort alphabeticaly
  -- local types = {}
  -- for type, _ in pairs(opts.commit_types) do
  --   table.insert(types, type)
  -- end
  -- table.sort(types)

  -- Build menu labels

  local dropdown = Input({
    position = '50%',
    size = {
      width = 18,
      --   height = 15,
    },
    border = {
      style = 'single',
      text = {
        top = '[Scope]',
        top_align = 'center',
      },
    },
    win_options = {
      winhighlight = 'Normal:Normal,FloatBorder:Normal',
    },
  }, {
    prompt = '',
    on_close = function() end,
    on_submit = function(value)
      if value == nil or value == '' then
        _mem.scope = nil
      else
        _mem.scope = value
      end
      if _mem.opts.skip_breaking then
        ui_short_commit()
      else
        ui_breaking()
      end
    end,
  })

  dropdown:mount()
end

local function ui_commit_type()
  local Menu = require('nui.menu')
  local opts = _mem.opts

  -- Sort alphabeticaly
  local types = {}
  for type, _ in pairs(opts.commit_types) do
    table.insert(types, type)
  end
  table.sort(types)

  -- Build menu labels
  local menu_items = {}
  for _, type in pairs(types) do
    local emoji = opts.commit_types[type]
    table.insert(menu_items, Menu.item(type .. ': ' .. emoji, { value = type }))
  end

  local dropdown = Menu({
    position = '50%',
    size = {
      width = 25,
      height = 15,
    },
    border = {
      style = 'single',
      text = {
        top = '[Choose a Commit Type]',
        top_align = 'center',
      },
    },
    win_options = {
      winhighlight = 'Normal:Normal,FloatBorder:Normal',
    },
  }, {
    lines = menu_items,
    keymap = opts.keymap,
    on_close = function() end,
    on_submit = function(item)
      _mem.commit_type = item.value
      if opts.skip_scope then
        ui_short_commit()
      else
        ui_scope()
      end
    end,
  })

  dropdown:mount()
end

--- The entry point that takes the user options and setups the command
---@param opts Config: the options
local make_command = function(opts)
  -- decide if we should use the long commit or the commit type selection
  local validate_commit = function(commit)
    if commit ~= nil then
      ui_long_commit()
      -- _G.icommit_saved_commit = nil
      return
    end
    ui_commit_type()
  end

  local icommit = function()
    if opts.check_staged then
      local utils = require('icommit.utils')
      if not utils.has_staged_changes() then
        utils.print_error('icommit', 'No staged files')
        return
      end
    end

    if _mem.commit_type ~= nil then
      ui_commit_restore(validate_commit)
      return
    else
      -- reset mem
      _mem = { opts = opts }
      ui_commit_type()
    end
  end
  return icommit
end

M.setup = function(opts)
  local cfg = require('icommit.config'):set(opts):get()
  local utils = require('icommit.utils')

  if vim.fn.executable('git') == 0 then
    utils.print_error('icommit', 'git not in path. Aborting setup')
    return
  end

  local command = make_command(cfg)
  vim.api.nvim_create_user_command(cfg.command_name, command, {})
end

return M
