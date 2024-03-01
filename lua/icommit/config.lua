local Config = {
	state = {},
	config = {
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
		self.config = vim.tbl_deep_extend("force", self.config, cfg)
	end
	return self
end

function Config:get()
	return self.config
end

---@export Config
return setmetatable(Config, {
	__index = function(this, k)
		return this.state[k]
	end,
	__newindex = function(this, k, v)
		this.state[k] = v
	end,
})
