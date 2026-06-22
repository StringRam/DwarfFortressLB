-- Migrated from keybindings.conf to Hyprland Lua syntax.
-- Place this file at: ~/.config/hypr/keybindings.lua

------------------
---- PROGRAMS ----
------------------

local terminal = "kitty"
local fileManager = "nautilus"
local menu = "rofi -show drun"
local mainMod = "SUPER"

---------------------
---- KEYBINDINGS ----
---------------------

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("uwsm app -- " .. terminal))
hl.bind(mainMod .. " + X", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("uwsm app -- " .. fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("uwsm app -- " .. menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle

-- Hyprpicker
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("uwsm app -- hyprpicker -a"))

-- Clipboard
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("uwsm app -- cliphist pick -t rofi-wayland"))

-- Screenshots
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("uwsm app -- hyprshot -m window"))
hl.bind("Print", hl.dsp.exec_cmd("uwsm app -- hyprshot -m output"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("uwsm app -- hyprshot -m region"))

-- Custom binds
hl.bind("ALT + TAB", hl.dsp.exec_cmd("uwsm app -- wlogout -b 2"))
hl.bind("ALT + w", hl.dsp.exec_cmd("uwsm app -- ~/.config/hypr/wallpaper.sh"))
hl.bind("ALT + a", hl.dsp.exec_cmd("uwsm app -- ~/.config/waybar/refresh.sh"))
hl.bind("ALT + r", hl.dsp.exec_cmd("uwsm app -- ~/.config/swaync/refresh.sh"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces and move active windows with mainMod + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace / scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("uwsm app -- wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("uwsm app -- wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("uwsm app -- wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("uwsm app -- wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("uwsm app -- brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("uwsm app -- brightnessctl s 10%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("uwsm app -- playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("uwsm app -- playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("uwsm app -- playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("uwsm app -- playerctl previous"), { locked = true })
