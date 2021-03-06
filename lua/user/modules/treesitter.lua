local present, treesitter = pcall(require, "nvim-treesitter.configs")
if not present then
  return
end

local configs = {
  ensure_installed = {
    "html",
    "css",
    "scss",
    "c",
    "go",
    "json",
    "javascript",
		"typescript",
		"tsx",
    "svelte",
    "lua",
    "vim",
    "bash",
    "markdown",
  },
  highlight = {
    enable = true,
    use_languagetree = true,
  },
  autopairs = {
    enable = true,
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  indent = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
	matchup = {
		enable = true,
	},
}

-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

treesitter.setup(configs)
