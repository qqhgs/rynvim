local present, bufferline = pcall(require, "bufferline")
if not present then
  return
end
local configs = {
  options = {
    close_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
    right_mouse_command = "vert sbuffer %d", -- can be a string | function, see "Mouse actions"
    left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(count, level)
      local icon = level:match "error" and " " or " "
      return " " .. icon .. count .. " "
    end,
    separator_style = { "", "" },
    offsets = {
      {
        filetype = "NvimTree",
        text = "",
        highlight = "NvimTreeNormal",
        padding = 1,
      },
    },
    name_formatter = function(buf) -- buf contains a "name", "path" and "bufnr"
      -- remove extension from markdown files for example
      if buf.name:match "%.md" then
        return vim.fn.fnamemodify(buf.name, ":t:r")
      end
    end,
    modified_icon = " ",
    show_buffer_icons = true, -- disable filetype icons for buffers
    show_buffer_close_icons = true,
    show_close_icon = false,
    show_tab_indicators = true,
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
    enforce_regular_tabs = false,
    always_show_bufferline = false,
    sort_by = "id",
  },
}

bufferline.setup(configs)


local bufferline_present, _ = pcall(require, "bufferline")
if bufferline_present then
  vim.cmd [[ command! BufferKill lua require('user.modules.bufferline').buf_kill('bd!') ]]
end

local M = {}

function M.buf_kill(kill_command, bufnr, force)
  local bo = vim.bo
  local api = vim.api

  if bufnr == 0 or bufnr == nil then
    bufnr = api.nvim_get_current_buf()
  end

  kill_command = kill_command or "bd"

  -- If buffer is modified and force isn't true, print error and abort
  if not force and bo[bufnr].modified then
    return api.nvim_err_writeln(
      string.format("No write since last change for buffer %d (set force to true to override)", bufnr)
    )
  end

  -- Get list of windows IDs with the buffer to close
  local windows = vim.tbl_filter(function(win)
    return api.nvim_win_get_buf(win) == bufnr
  end, api.nvim_list_wins())

  if #windows == 0 then
    return
  end

  if force then
    kill_command = kill_command .. "!"
  end

  -- Get list of active buffers
  local buffers = vim.tbl_filter(function(buf)
    return api.nvim_buf_is_valid(buf) and bo[buf].buflisted
  end, api.nvim_list_bufs())

  -- If there is only one buffer (which has to be the current one), vim will
  -- create a new buffer on :bd.
  -- For more than one buffer, pick the previous buffer (wrapping around if necessary)
  if #buffers > 1 then
    for i, v in ipairs(buffers) do
      if v == bufnr then
        local prev_buf_idx = i == 1 and (#buffers - 1) or (i - 1)
        local prev_buffer = buffers[prev_buf_idx]
        for _, win in ipairs(windows) do
          api.nvim_win_set_buf(win, prev_buffer)
        end
      end
    end
  end

  -- Check if buffer still exists, to ensure the target buffer wasn't killed
  -- due to options like bufhidden=wipe.
  if api.nvim_buf_is_valid(bufnr) and bo[bufnr].buflisted then
    vim.cmd(string.format("%s %d", kill_command, bufnr))
  end
end

return M