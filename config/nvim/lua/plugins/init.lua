return {
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- markview.nvim – podgląd Markdown, HTML, LaTeX, Typst i YAML
  
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    config = function()
      require("markview").setup({
        preview = {
          icon_provider = "internal",
        },
      })

      vim.schedule(function()
        vim.keymap.set("n", "<leader>z", ":Markview toggle<CR>", { silent = true })
      end)
    end,
  }

}
