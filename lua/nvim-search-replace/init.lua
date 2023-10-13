vim = vim

local function get_selection()
  local _, line_start, column_start = unpack(vim.fn.getpos("'<"))
  local _, line_end, column_end = unpack(vim.fn.getpos("'>"))
  if line_start ~= line_end then
    print("mulit line selection not supported")
    return "", line_start, column_start, false
  end
  local selection = vim.api.nvim_buf_get_text(0, line_start - 1, column_start - 1, line_end - 1, column_end, {})[1]
  return selection, line_start, column_start, true
end

local function replace_all()
  local selection, line_start, column_start, success = get_selection()
  if not success then
    vim.fn.cursor(line_start, column_start)
    return
  end
  local escape_characters = "\"\\/.*$^~[]"
  local escaped_selection = vim.fn.escape(selection, escape_characters)
  vim.cmd("/" .. escaped_selection)
  vim.cmd("redraw")
  local replacement = vim.fn.input({prompt = "Replace: ", cancelreturn = -1})
  if replacement == -1 then
    vim.fn.cursor(line_start, column_start)
    vim.cmd("noh")
    return
  end
  vim.cmd("%s/" .. escaped_selection .. "/" .. replacement .. "/gc")
  vim.fn.cursor(line_start, column_start)
  vim.cmd("noh")
end

local function setup()
   vim.api.nvim_create_user_command(
    "Replace",
    replace_all,
    { nargs = 0, desc = "Replace occurrences of selected text", range = true }
  )
end

return {
  replace_all = replace_all,
  setup = setup,
}
