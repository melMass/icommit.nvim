# icommit.nvim

Plugin for neovim for "interactive commits".  
By default it uses a custom flavor of conventional commits (check the [config](#config) `commit_types`)

![icommit_steps](https://github.com/melMass/icommit.nvim/assets/7041726/d2963204-1a07-4a12-996e-744b5308a2bd)

> Note: If an error occured on commit the last commit is stored (for the current session) and on restore you will be asked what to do with it:

![icommit_restore](https://github.com/melMass/icommit.nvim/assets/7041726/f1d20dbd-82de-45da-a508-1c2da2ffc65c)



## Installation

- **Lazy**:

```lua
require('lazy').setup({
    {
        'melmass/icommit.nvim', 
        opts = {}, 
        dependencies = {
          'MunifTanjim/nui.nvim',
        }
    }
)
```

## Configuration

This is the default config: 

```lua
{
    command_name = "Icommit",
    -- check for staged file at each run.
    -- This is quite slow and the reason for the restore system.
    check_staged = false,

    -- If you completely want to override the commit_types set this to true
    -- otherwise commit_types you provide are merged to the defaults
    skip_core_types = false,

    commit_types = {
        feat = "✨",
        fix = "🐛",
        ci = "🤖",
        docs = "📚",
        style = "💎",
        refactor = "📦",
        test = "🚨",
        tag = "🔖",
        chore = "🧹",
        revert = "⏪",
        perf = "🚀",
        wip = "🚧",
        release = "📦",
    },

    -- Default keymaps to select, close or submit a pane
    keymap = {
        focus_next = { "j", "<Down>", "<Tab>" },
        focus_prev = { "k", "<Up>", "<S-Tab>" },
        close = { "<Esc>", "<C-c>" },
        submit = { "<CR>" },
    },
}
```
