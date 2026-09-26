-- https://github.com/boydaihungst/gvfs.yazi/tree/master#installation
-- ya pkg add boydaihungst/gvfs
require("gvfs"):setup()

-- https://yazi-rs.github.io/docs/dds#session.lua
require("session"):setup({
	sync_yanked = true,
})

-- https://github.com/dedukun/relative-motions.yazi
-- current version mismatch workaround: ( remove in future )
-- sed -i 's/ya\.mgr_emit(/ya.emit(/g' ~/.config/yazi/plugins/relative-motions.yazi/main.lua
require("relative-motions"):setup({ show_numbers = "relative", show_motion = true, enter_mode = "first" })
