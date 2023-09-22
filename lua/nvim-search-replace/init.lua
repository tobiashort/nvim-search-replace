vim = vim

local function get_selection()
  local _, line_start, column_start = unpack(vim.fn.getpos("'<"))
  local _, line_end, column_end = unpack(vim.fn.getpos("'>"))
  if line_start ~= line_end then
    print("mulit line selection not supported")
    return "", false
  end
  local selection = vim.api.nvim_buf_get_text(0, line_start - 1, column_start - 1, line_end - 1, column_end - 1, {})[1]
  return selection, true
end

local function replace_all()
  local selection, success = get_selection()
  if not success then
    return
  end
  local escape_characters = "\"\\/.*$^~[]"
  local escaped_selection = vim.fn.escape(selection, escape_characters)

  -- At first a search will be executed.
  -- This is only for highlighting purposes.
  vim.api.nvim_feedkeys(
    "/"
      .. escaped_selection
      .. vim.api.nvim_replace_termcodes("<CR>N", true, false, true),
    "m",
    false)

  vim.api.nvim_feedkeys(
    ":%s/"
      .. escaped_selection
      .. "//g"
      .. vim.api.nvim_replace_termcodes("<Left><Left>", true, false, true),
    "m",
    false)
end

local function setup()
   vim.api.nvim_create_user_command(
    "ReplaceAll",
    replace_all,
    { nargs = 0, desc = "Replace all occurrences of selected text", range = true }
  )
end

return {
  replace_all = replace_all,
  setup = setup,
}
