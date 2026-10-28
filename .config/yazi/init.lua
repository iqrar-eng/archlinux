-- https://yazi-rs.github.io/docs/dds#session.lua
require("session"):setup({
	sync_yanked = true,
})

require("relative-motions"):setup({ show_numbers = "relative", show_motion = true, enter_mode = "first" })
require("gvfs"):setup()
require("autosave"):setup()
