-- Migrated from hyprland.conf to Hyprland Lua syntax.
-- Place this file at: ~/.config/hypr/hyprland.lua

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
  hl.exec_cmd("uwsm app -- awww-daemon & waybar & hypridle & hyprsunset & swaync")

  -- Clipboard history
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  -- Start polkit
  hl.exec_cmd("systemctl --user enable --now hyprpolkitagent.service")

  hl.exec_cmd("uwsm app -- nm-applet & blueman-applet")
end)

---------------------------------
---- ENVIRONMENT VARIABLES ------
---------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("HYPRSHOT_DIR", "$HOME/Pictures/Screenshots")
hl.env("_JAVA_OPTIONS", "-Dawt.useSystemAAFontSettings=on")

-- XDG variables
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 15,
    border_size = 3,
    col = {
      active_border = "0xE8CE47",
      inactive_border = "0xE8CE47",
    },
    resize_on_border = true,
    allow_tearing = true,
    layout = "dwindle",
  },

  decoration = {
    rounding = 4,
    active_opacity = 1,
    inactive_opacity = 1,
    fullscreen_opacity = 1,
    blur = {
      enabled = true,
      size = 3,
      passes = 5,
      new_optimizations = true,
      ignore_opacity = true,
      xray = false,
      popups = false,
    },
    shadow = {
      enabled = false,
      range = 10,
      render_power = 5,
      color = "rgba(00000000)",
    },
  },

  dwindle = {
    preserve_split = true,
  },

  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = false,
    mouse_move_enables_dpms = true,
    allow_session_lock_restore = true,
  },

  input = {
    kb_layout = "us",
    kb_variant = "intl",
    kb_model = "",
    kb_options = "",
    kb_rules = "",
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = {
      natural_scroll = false,
    },
  },

  gestures = {},
})

--------------------
---- ANIMATIONS ----
--------------------

hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("swirl", { type = "bezier", points = { { 0.04, 1 }, { 0.2, 1.2 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "swirl", style = "popin 0%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "linear", style = "popin 0%" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "linear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "linear" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "swirl", style = "slidefadevert -50%" })

-----------------
---- DEVICES ----
-----------------

hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})

-----------------
---- INCLUDE ----
-----------------

require("keybindings")
require("windowrules")
