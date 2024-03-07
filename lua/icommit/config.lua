local Config = {
	state = {},

	---@class Config
	config = {
		command_name = "Icommit",

		-- check for staged file at each run.
		-- This is quite slow and the reason for the restore system.
		check_staged = false,

		-- NOTE: If you completely want to override the commit_types
		-- set this to true otherwise commit_types you provide are
		-- merged to the defaults
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
	},
}

function Config:set(cfg)
	if cfg then
		if cfg.skip_core_types then
			-- NOTE: I use this diagnostic disable because I mistype Config
			-- Not sure how to do it properly in lua so the type
			-- is currently the value.
			--
			---@diagnostic disable-next-line: inject-field
			self.config.commit_types = {}
		end
		self.config = vim.tbl_deep_extend("force", self.config, cfg)
	end
	return self
end

function Config:get()
	return self.config
end

return setmetatable(Config, {
	__index = function(this, k)
		return this.state[k]
	end,
	__newindex = function(this, k, v)
		this.state[k] = v
	end,
})
