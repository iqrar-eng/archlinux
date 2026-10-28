local mod = "SHIFT + CTRL + ALT + SUPER + "

-- Switch workspaces with SUPER + [0-9]
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind("SUPER + 2", hl.dsp.exec_cmd("~/archlinux/.config/tmux/bin/open"))
hl.bind("SUPER + 3", hl.dsp.exec_cmd("~/archlinux/.config/tmux/bin/open --term"))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind("SUPER + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind("SUPER + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with SUPER + SHIFT + [0-9]
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

---------------------------------------------

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"SHIFT + XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 25%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"SHIFT + XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 25%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"SUPER + XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 100%"),
	{ locked = true, repeating = true }
)
hl.bind(
	"SUPER + XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 50%"),
	{ locked = true, repeating = true }
)

hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind(
	"SUPER + XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 100%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"SUPER + XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 100%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"SHIFT + XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 25%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"SHIFT + XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 25%-"),
	{ locked = true, repeating = true }
)

-- ------------------------------------------------

local function paste_slot(n)
	return function()
		hl.dispatch(hl.dsp.exec_cmd("copyq select " .. n))
		hl.dispatch(hl.dsp.exec_cmd("~/archlinux/.config/hypr/bin/paste"))
	end
end

hl.bind(mod .. "G", paste_slot(1))
hl.bind(mod .. "H", paste_slot(2))
hl.bind(mod .. "I", paste_slot(3))

local cmd = "tmux switch-client -t \"$(tmux display-message -p '#S'):nvim\" && ~/archlinux/.config/tmux/bin/slime "
hl.bind(mod .. "A", hl.dsp.exec_cmd(cmd .. "--execute --jump"))
hl.bind(mod .. "B", hl.dsp.exec_cmd(cmd .. "--execute"))
hl.bind(mod .. "C", hl.dsp.exec_cmd(cmd .. "--jump"))
hl.bind(mod .. "Q", hl.dsp.exec_cmd(cmd .. "--jump --no-cancel"))

hl.bind(mod .. "F", hl.dsp.exec_cmd("~/archlinux/.local/bin/clipboard-run-and-copy"))
hl.bind(mod .. "M", hl.dsp.exec_cmd("~/archlinux/.local/bin/toggle-theme"))
hl.bind(mod .. "S", hl.dsp.exec_cmd("/home/iqrar/archlinux/.config/hypr/bin/toggle-archangel"))
hl.bind(mod .. "U", hl.dsp.exec_cmd('[float; size 1100 600] kitty sh -c "nmcli device wifi list ; nmtui-connect"'))
hl.bind(mod .. "O", hl.dsp.exec_cmd("systemctl poweroff"))
hl.bind(mod .. "P", hl.dsp.exec_cmd("loginctl terminate-user $USER"))
hl.bind("XF86Favorites", hl.dsp.exec_cmd("systemctl suspend"))

hl.bind(mod .. "R", hl.dsp.exec_cmd("normcap"))
hl.bind(mod .. "T", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(mod .. "N", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + Tab", hl.dsp.window.cycle_next())
hl.bind("SUPER + mouse:272", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + X", hl.dsp.layout("swapsplit"))
hl.bind("SUPER + equal", hl.dsp.layout("splitratio 1.0 exact"))
hl.bind(mod .. "E", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. "D", hl.dsp.focus({ workspace = "previous" }))
