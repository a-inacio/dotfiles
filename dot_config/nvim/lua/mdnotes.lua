-- mdnotes — obsidian.nvim-style behaviour on top of markdown-oxide (generic markdown, not workmode-specific;
-- workmode-aware extras live in workmode.nvim). Keymaps are bound in lua/plugins/markdown-oxide.lua.
--   follow()     gd: follow link; same-file duplicates collapsed (realpath: base memories are symlinked into
--                every domain); real duplicates → picker with path + preview; no target on a [[wikilink]] →
--                offer to CREATE the note (pick a folder), seeded with "# Title".
--   backlinks()  gr: references grouped ONE ROW PER FILE, "(n links)" when a file links several times.
--   smart_cr()   <CR>: on a link → follow(); on a checkbox → toggle; else a normal <CR>.
local M = {}

local function client() return vim.lsp.get_clients({ bufnr = 0, name = "markdown_oxide" })[1] end
local function root()
  local c = client()
  return (c and c.root_dir) or vim.fn.getcwd()
end
local function rel(p)
  local r = root() .. "/"
  return (p:sub(1, #r) == r) and p:sub(#r + 1) or vim.fn.fnamemodify(p, ":~")
end

-- Location | LocationLink → { file, lnum (1-based), col (0-based), real }
local function to_item(loc)
  local uri = loc.uri or loc.targetUri
  local range = loc.range or loc.targetSelectionRange or loc.targetRange
  local file = vim.uri_to_fname(uri)
  return { file = file, lnum = range.start.line + 1, col = range.start.character, real = vim.uv.fs_realpath(file) or file }
end

local function pick(items, title)
  Snacks.picker.pick({
    title = title,
    items = vim.tbl_map(function(it)
      return { text = it.label or rel(it.file), file = it.file, pos = { it.lnum, it.col } }
    end, items),
    format = "file",
  })
end

local function jump(it)
  vim.cmd("normal! m'") -- so <C-o> returns here
  vim.cmd.edit(vim.fn.fnameescape(it.file))
  pcall(vim.api.nvim_win_set_cursor, 0, { it.lnum, it.col })
end

-- [[target#heading|alias]] under the cursor → "target" (nil if not on a wikilink)
local function wikilink_under_cursor()
  local line, col = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2] + 1
  for s, inner, e in line:gmatch("()%[%[(.-)%]%]()") do
    if col >= s and col < e then
      return vim.trim((inner:gsub("|.*$", ""):gsub("#.*$", "")))
    end
  end
end

-- nearest ancestor (within the vault) that holds a project.md
local function project_dir(file)
  local dir, r = vim.fs.dirname(file), root()
  while dir and #dir >= #r do
    if vim.uv.fs_stat(dir .. "/project.md") then return dir end
    local parent = vim.fs.dirname(dir)
    if parent == dir then break end
    dir = parent
  end
end

local function create(target)
  if target:match("^%s*$") then return end
  local name = target:gsub("%.md$", "")
  local here = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local choices = {}
  local function add(label, dir) choices[#choices + 1] = { label = label, dir = dir } end
  add("Same folder as this note  (" .. rel(here) .. "/)", here)
  local proj = project_dir(vim.api.nvim_buf_get_name(0))
  if proj then add("This project's investigations/  (" .. rel(proj) .. "/investigations/)", proj .. "/investigations") end
  add("Vault root  (" .. vim.fn.fnamemodify(root(), ":~") .. ")", root())
  vim.ui.select(choices, {
    prompt = ('"%s.md" does not exist — create it in:'):format(name),
    format_item = function(c) return c.label end,
  }, function(choice)
    if not choice then return end
    local path = choice.dir .. "/" .. name .. ".md"
    vim.fn.mkdir(vim.fs.dirname(path), "p")
    if not vim.uv.fs_stat(path) then
      local title = vim.fs.basename(name):gsub("[-_]", " ")
      vim.fn.writefile({ "# " .. title:sub(1, 1):upper() .. title:sub(2), "" }, path)
    end
    -- oxide adds NEW files to its index only on didChangeWatchedFiles (→ reconstruct_vault)
    local c = client()
    if c then
      c:notify("workspace/didChangeWatchedFiles", { changes = { { uri = vim.uri_from_fname(path), type = 1 } } })
    end
    jump({ file = path, lnum = 1, col = 0 })
    vim.notify("Created " .. rel(path))
  end)
end

function M.follow()
  local c = client()
  if not c then return vim.lsp.buf.definition() end
  local link = wikilink_under_cursor()
  c:request("textDocument/definition", vim.lsp.util.make_position_params(0, c.offset_encoding), function(err, result)
    if err then return vim.notify("definition: " .. err.message, vim.log.levels.WARN) end
    if result and result.uri then result = { result } end
    local seen, items = {}, {}
    for _, loc in ipairs(result or {}) do
      local it = to_item(loc)
      if not seen[it.real] then seen[it.real] = true; items[#items + 1] = it end
    end
    if #items == 1 then return jump(items[1]) end
    if #items > 1 then return pick(items, ("%d notes match"):format(#items)) end
    if link then
      -- safety net: the index may lag, so look on disk before offering to create a duplicate
      -- (rg, not vim.fs.find: it skips .git/hidden/gitignored dirs — measured 62 ms vs 2.5 s on ~/work)
      local name = link:gsub("%.md$", "")
      local out = vim.system({ "rg", "--files", "-L", "-g", "**/" .. vim.fs.basename(name) .. ".md" },
        { cwd = root(), text = true }):wait()
      local hit = (out.stdout or ""):match("^[^\n]+")
      if hit then return jump({ file = root() .. "/" .. hit, lnum = 1, col = 0 }) end
      return create(link)
    end
    vim.notify("No link target under cursor", vim.log.levels.INFO)
  end, 0)
end

function M.backlinks()
  local c = client()
  if not c then return vim.lsp.buf.references() end
  local params = vim.lsp.util.make_position_params(0, c.offset_encoding)
  params.context = { includeDeclaration = false }
  c:request("textDocument/references", params, function(err, result)
    if err then return vim.notify("references: " .. err.message, vim.log.levels.WARN) end
    local by_file, order = {}, {}
    for _, loc in ipairs(result or {}) do
      local it = to_item(loc)
      if not by_file[it.real] then by_file[it.real] = { it = it, n = 0 }; order[#order + 1] = it.real end
      by_file[it.real].n = by_file[it.real].n + 1
    end
    if #order == 0 then return vim.notify("No backlinks", vim.log.levels.INFO) end
    local items = {}
    for _, k in ipairs(order) do
      local g = by_file[k]
      g.it.label = rel(g.it.file) .. (g.n > 1 and ("  (" .. g.n .. " links)") or "")
      items[#items + 1] = g.it
    end
    pick(items, ("Backlinks — %d files"):format(#items))
  end, 0)
end

function M.smart_cr()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local on_link = wikilink_under_cursor() ~= nil
  if not on_link then
    for s, e in line:gmatch("()%[[^%]]*%]%([^)]*%)()") do
      if col >= s and col < e then on_link = true end
    end
  end
  if on_link then return M.follow() end
  local new, n = line:gsub("^(%s*[-*+] )%[ %]", "%1[x]", 1)
  if n == 0 then new, n = line:gsub("^(%s*[-*+] )%[[xX]%]", "%1[ ]", 1) end
  if n > 0 then return vim.api.nvim_set_current_line(new) end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
end

return M
