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

local function termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, false, true)
end

local function feedkeys(str)
  vim.api.nvim_feedkeys(str, "m", false)
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
  feedkeys("/" .. escaped_selection .. termcodes("<CR>") .. "N")
  feedkeys(":%s/" .. escaped_selection .. "//g | noh" .. termcodes("<Left><Left>"))
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
