-- Add your custom plugins here
-- Each plugin spec should be a separate file in this directory
-- or you can define them all here

return {
  -- Catppuccin theme (to match your other tools)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },

  -- Configure LazyVim to use catppuccin
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
