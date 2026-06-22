-- Migrated from windowrules.conf to Hyprland Lua syntax.
-- Place this file at: ~/.config/hypr/windowrules.lua

------------------------
---- WINDOW RULES ----
------------------------

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland.
hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

-- Hyprland-run windowrule.
hl.window_rule({
  name = "move-hyprland-run",
  match = { class = "hyprland-run" },
  move = "20 monitor_h-120",
  float = true,
})

-- Center all floating windows except XWayland popups.
hl.window_rule({
  match = { float = true, xwayland = false },
  center = true,
})

-- SafeEyes dual-monitor fullscreen rules.
hl.window_rule({ match = { title = "SafeEyes-0" }, fullscreen = true })
hl.window_rule({ match = { title = "SafeEyes-1" }, fullscreen = true })
hl.window_rule({ match = { title = "SafeEyes-0" }, monitor = "0" })
hl.window_rule({ match = { title = "SafeEyes-1" }, monitor = "1" })

-- Floating windows.
hl.window_rule({ match = { class = "quickshell" }, float = true })
hl.window_rule({ match = { class = "openrgb" }, float = true })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, float = true })
hl.window_rule({ match = { class = "blueman-manager" }, float = true })

-- Floating window sizes.
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, size = "70% 50%" })
hl.window_rule({ match = { class = "blueman-manager" }, size = "70% 60%" })
hl.window_rule({ match = { class = "openrgb" }, size = "70% 60%" })

-- Moonlight.
hl.window_rule({ match = { class = "com.moonlight_stream.Moonlight" }, fullscreen = true })
hl.window_rule({ match = { class = "com.moonlight_stream.Moonlight" }, idle_inhibit = "always" })

-- Minecraft Launcher: always tiled (WIP).
hl.window_rule({
  match = { title = "Minecraft Launcher", class = "Minecraft Launcher" },
  tile = true,
})

-- XWayland popups.
hl.window_rule({
  name = "xwayland-popups",
  match = {
    xwayland = true,
    title = "win[0-9]+",
  },
  no_dim = true,
  no_shadow = true,
  rounding = 10,
})

-- Obsidian opacity.
hl.window_rule({ match = { class = "obsidian" }, opacity = "0.92" })

-- Steam.
-- Ensure Steam main client is not forced floating.
hl.window_rule({ match = { title = "Steam", class = "steam" }, tile = true })

hl.window_rule({
  name = "steam-friends-list",
  match = { title = "Friends List", class = "steam" },
  float = true,
  center = true,
  size = "50% 80%",
})

hl.window_rule({
  name = "steam-settings",
  match = { title = "Steam Settings", class = "steam" },
  float = true,
  center = true,
  size = "50% 80%",
})

-- Allow tearing and inhibit idle for Steam games.
hl.window_rule({ match = { class = "steam_app_[0-9]+" }, immediate = true })
hl.window_rule({ match = { class = "steam_app_[0-9]+" }, idle_inhibit = "always" })

-------------------------
---- WORKSPACE RULES ----
-------------------------

hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 20, gaps_in = 20 })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 20, gaps_in = 20 })

----------------------
---- LAYER RULES ----
----------------------

-- UI stuff.
hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })

-- Colour picker out animation.
hl.layer_rule({ match = { namespace = "hyprpicker" }, animation = "fade" })

-- Screenshot fixes.
hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })

hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "selection" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "wayfreeze" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "hyprpicker" }, animation = "fade" })

-- Screenshot fixes.
hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })

hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "selection" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "wayfreeze" }, animation = "fade" })
