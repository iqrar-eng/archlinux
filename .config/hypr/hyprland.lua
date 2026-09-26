---------------------
---- MY PROGRAMS ----
---------------------

local firefox = "firefox"
local tmux = "kitty --class kitty-tmux ~/archlinux/.config/tmux/bin/open"
local clipboard = "copyq --start-server show"
local fileManager = "~/archlinux/.config/yazi/bin/open"
local player = "vlc"

------------------------
---- RULES ---
------------------------

hl.workspace_rule({ workspace = "1", on_created_empty = firefox })
hl.workspace_rule({ workspace = "2", on_created_empty = tmux })
hl.workspace_rule({ workspace = "4", on_created_empty = clipboard })
hl.workspace_rule({ workspace = "5", on_created_empty = fileManager })
hl.workspace_rule({ workspace = "6", on_created_empty = player })

hl.window_rule({ match = { class = "firefox" }, workspace = "1" })
hl.window_rule({ match = { class = "kitty-tmux" }, workspace = "2" })
hl.window_rule({ match = { class = "com.github.hluk.copyq" }, workspace = "4" })
hl.window_rule({ match = { class = "kitty-yazi" }, workspace = "5" })
hl.window_rule({ match = { class = "vlc" }, workspace = "6" })

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
	hl.exec_cmd("trash-empty -f 30")
	hl.exec_cmd("batsignal -e -b -p -w 35 -c 20 -d 10 -f 80")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	xwayland = {
		force_zero_scaling = true,
	},

	general = {
		border_size = 0,
		gaps_in = 1,
		gaps_out = 0,
	},

	decoration = {
		rounding = 0,
		shadow = { enabled = false },
		blur = { enabled = false },
	},

	animations = { enabled = false },

	-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
	dwindle = {
		preserve_split = true, -- You probably want this
		force_split = 2,
	},

	misc = {
		focus_on_activate = true,
		force_default_wallpaper = false,
		disable_splash_rendering = true,
		disable_hyprland_logo = true,
	},

	input = {
		sensitivity = 0.7,
		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

require("bind")
