.pragma library

var generalTips = [
  {
    title: "Split Direction",
    text: "Press SUPER + J to toggle whether your next window split opens horizontally or vertically.",
    shortcut: "SUPER + J"
  },
  {
    title: "Scratchpad Workspace",
    text: "Press SUPER + S to toggle your floating scratchpad, or SUPER + ALT + S to send the active window there.",
    shortcut: "SUPER + S"
  },
  {
    title: "Instant Terminal",
    text: "Press SUPER + RETURN to launch your terminal from anywhere without touching the mouse.",
    shortcut: "SUPER + RETURN"
  },
  {
    title: "Fast Web Browser",
    text: "Press SUPER + SHIFT + RETURN to instantly open or focus your default web browser.",
    shortcut: "SUPER + SHIFT + RETURN"
  },
  {
    title: "App Launcher",
    text: "Press SUPER + SPACE to open the Omarchy command launcher and find anything on your system.",
    shortcut: "SUPER + SPACE"
  },
  {
    title: "Float or Tile",
    text: "Press SUPER + T to toggle the active window between floating and automatic tiling.",
    shortcut: "SUPER + T"
  },
  {
    title: "Pin Window (Picture-in-Picture)",
    text: "Press SUPER + O to pop out a window, float it, and keep it pinned across all workspaces.",
    shortcut: "SUPER + O"
  },
  {
    title: "Distraction-Free Fullscreen",
    text: "Press SUPER + F to toggle fullscreen mode, or SUPER + ALT + F for full-width view.",
    shortcut: "SUPER + F"
  },
  {
    title: "Toggle Window Gaps",
    text: "Press SUPER + SHIFT + BACKSPACE to toggle inner and outer window gaps and borders.",
    shortcut: "SUPER + SHIFT + BACKSPACE"
  },
  {
    title: "Workspace Hopping",
    text: "Press SUPER + 1 through 9 to jump directly to any workspace, or SUPER + 0 for workspace 10.",
    shortcut: "SUPER + 1..9"
  },
  {
    title: "Move Window to Workspace",
    text: "Press SUPER + SHIFT + 1 through 9 to send the active window to another workspace.",
    shortcut: "SUPER + SHIFT + 1..9"
  },
  {
    title: "Clipboard History",
    text: "Press SUPER + CTRL + V to browse and re-paste previous clipboard items.",
    shortcut: "SUPER + CTRL + V"
  },
  {
    title: "Emoji Picker",
    text: "Press SUPER + CTRL + E to summon the graphical emoji overlay.",
    shortcut: "SUPER + CTRL + E"
  },
  {
    title: "File Manager",
    text: "Press SUPER + SHIFT + F to open the file manager, or SUPER + SHIFT + ALT + F in the current directory.",
    shortcut: "SUPER + SHIFT + F"
  },
  {
    title: "Instant Screen Lock",
    text: "Press SUPER + CTRL + L to immediately lock your screen with Omarchy's lock screen.",
    shortcut: "SUPER + CTRL + L"
  },
  {
    title: "Screen Capture",
    text: "Press PRINT for interactive screenshot, or ALT + PRINT to start screen recording.",
    shortcut: "PRINT"
  },
  {
    title: "Close Window",
    text: "Press SUPER + W to cleanly close the focused window.",
    shortcut: "SUPER + W"
  },
  {
    title: "Bar Transparency Trick",
    text: "Double-click empty space on the status bar to instantly toggle transparent bar mode.",
    shortcut: "Double-Click Bar"
  }
];

var allShortcuts = [
  // -------------------------------------------------------------
  // Applications & Launchers
  // -------------------------------------------------------------
  { key: "SUPER + RETURN", desc: "Launch Terminal", category: "apps", icon: "󰞷", action: "omarchy-launch-terminal" },
  { key: "SUPER + SHIFT + RETURN", desc: "Launch Web Browser", category: "apps", icon: "󰖟", action: "omarchy-launch-browser" },
  { key: "SUPER + SHIFT + F", desc: "Open File Manager", category: "apps", icon: "󰉋", action: "omarchy-launch-file-manager" },
  { key: "SUPER + SHIFT + ALT + F", desc: "File Manager (Current Folder)", category: "apps", icon: "󰉋", action: "omarchy-launch-file-manager-cwd" },
  { key: "SUPER + SHIFT + N", desc: "Open Code Editor", category: "apps", icon: "󰨞", action: "omarchy-launch-editor" },
  { key: "SUPER + ALT + RETURN", desc: "Launch Tmux Terminal", category: "apps", icon: "󰒍", action: "omarchy-launch-terminal tmux" },
  { key: "SUPER + CTRL + RETURN", desc: "Launch Herdr (Scratchpad Terminal)", category: "apps", icon: "󰖮", action: "omarchy-launch-herdr" },
  { key: "SUPER + SHIFT + B", desc: "Launch Browser", category: "apps", icon: "󰖟", action: "omarchy-launch-browser" },
  { key: "SUPER + SHIFT + ALT + B", desc: "Browser (Private Window)", category: "apps", icon: "󰗹", action: "omarchy-launch-browser-private" },
  { key: "SUPER + SHIFT + M", desc: "Launch Spotify", category: "apps", icon: "󰝚", action: "spotify" },
  { key: "SUPER + SHIFT + ALT + M", desc: "Music Player TUI (cliamp)", category: "apps", icon: "󰝚", action: "omarchy-launch-terminal cliamp" },
  { key: "SUPER + SHIFT + D", desc: "Docker Management TUI", category: "apps", icon: "󰡨", action: "omarchy-launch-docker-tui" },
  { key: "SUPER + SHIFT + G", desc: "Launch Signal", category: "apps", icon: "󰭹", action: "signal-desktop" },
  { key: "SUPER + SHIFT + O", desc: "Launch Obsidian", category: "apps", icon: "󰠮", action: "obsidian" },
  { key: "SUPER + SHIFT + W", desc: "Launch Omawrite", category: "apps", icon: "󰷈", action: "omawrite" },
  { key: "SUPER + SHIFT + SLASH", desc: "Open 1Password", category: "apps", icon: "󰌋", action: "1password" },
  { key: "SUPER + SHIFT + A", desc: "Open ChatGPT", category: "apps", icon: "󰚩", action: "xdg-open https://chatgpt.com" },
  { key: "SUPER + SHIFT + ALT + A", desc: "Open Grok", category: "apps", icon: "󰚩", action: "xdg-open https://grok.com" },
  { key: "SUPER + SHIFT + C", desc: "Open Calendar", category: "apps", icon: "󰃭", action: "xdg-open https://app.hey.com/calendar/weeks/" },
  { key: "SUPER + SHIFT + E", desc: "Open Email", category: "apps", icon: "󰇮", action: "xdg-open https://app.hey.com" },
  { key: "SUPER + SHIFT + Y", desc: "Open YouTube", category: "apps", icon: "󰗃", action: "xdg-open https://youtube.com" },
  { key: "SUPER + SHIFT + S", desc: "Open Google Maps", category: "apps", icon: "󰍎", action: "xdg-open https://maps.google.com" },
  { key: "SUPER + SHIFT + X", desc: "Open X / Twitter", category: "apps", icon: "󰗫", action: "xdg-open https://x.com" },

  // -------------------------------------------------------------
  // Window Management & Tiling
  // -------------------------------------------------------------
  { key: "SUPER + W", desc: "Close Focused Window", category: "window", icon: "󰅖", action: "hyprctl dispatch 'hl.dsp.window.close()'" },
  { key: "CTRL + ALT + DELETE", desc: "Close All Windows on Workspace", category: "window", icon: "󰅙", action: "omarchy-hyprland-window-close-all" },
  { key: "SUPER + T", desc: "Toggle Floating / Tiling", category: "window", icon: "󰉦", action: "hyprctl dispatch 'hl.dsp.window.float({ action = \"toggle\" })'" },
  { key: "SUPER + F", desc: "Toggle Fullscreen (Border-Free)", category: "window", icon: "󰊓", action: "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"fullscreen\" })'" },
  { key: "SUPER + ALT + F", desc: "Toggle Full Width (Maximized)", category: "window", icon: "󰹑", action: "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"maximized\" })'" },
  { key: "SUPER + CTRL + F", desc: "Toggle Tiled Full Screen", category: "window", icon: "󰹉", action: "omarchy-hyprland-window-tiled-fullscreen-toggle" },
  { key: "SUPER + J", desc: "Toggle Split Orientation (Dwindle)", category: "window", icon: "󰤉", action: "hyprctl dispatch 'hl.dsp.layout(\"togglesplit\")'" },
  { key: "SUPER + O", desc: "Pop Window Out (Float & Pin PiP)", category: "window", icon: "󰐃", action: "omarchy-hyprland-window-pop" },
  { key: "SUPER + P", desc: "Pseudo Tiling Mode", category: "window", icon: "󰹉", action: "hyprctl dispatch 'hl.dsp.window.pseudo()'" },
  { key: "SUPER + L", desc: "Toggle Workspace Layout", category: "window", icon: "󱂬", action: "omarchy-hyprland-workspace-layout-toggle" },
  { key: "SUPER + G", desc: "Toggle Window Grouping", category: "window", icon: "󰏘", action: "hyprctl dispatch 'hl.dsp.group.toggle()'" },
  { key: "SUPER + ALT + TAB", desc: "Next Window in Group", category: "window", icon: "󰹉", action: "hyprctl dispatch 'hl.dsp.group.next()'" },
  { key: "SUPER + ALT + SHIFT + TAB", desc: "Previous Window in Group", category: "window", icon: "󰹉", action: "hyprctl dispatch 'hl.dsp.group.prev()'" },
  { key: "SUPER + BACKSPACE", desc: "Toggle Window Transparency", category: "window", icon: "󰂵", action: "omarchy-hyprland-window-transparency-toggle" },
  { key: "SUPER + SHIFT + BACKSPACE", desc: "Toggle Window Gaps & Borders", category: "window", icon: "󰞋", action: "omarchy-hyprland-window-gaps-toggle" },
  { key: "SUPER + CTRL + BACKSPACE", desc: "Toggle Single-Window Square Aspect", category: "window", icon: "󰄱", action: "omarchy-hyprland-window-single-square-aspect-toggle" },

  // -------------------------------------------------------------
  // Navigation & Directional Focus
  // -------------------------------------------------------------
  { key: "SUPER + Left / H", desc: "Focus Left Window", category: "navigation", icon: "󰁍", action: "hyprctl dispatch 'hl.dsp.focus({ direction = \"l\" })'" },
  { key: "SUPER + Right / L", desc: "Focus Right Window", category: "navigation", icon: "󰁔", action: "hyprctl dispatch 'hl.dsp.focus({ direction = \"r\" })'" },
  { key: "SUPER + Up / K", desc: "Focus Above Window", category: "navigation", icon: "󰁝", action: "hyprctl dispatch 'hl.dsp.focus({ direction = \"u\" })'" },
  { key: "SUPER + Down / J", desc: "Focus Below Window", category: "navigation", icon: "󰁅", action: "hyprctl dispatch 'hl.dsp.focus({ direction = \"d\" })'" },

  { key: "SUPER + SHIFT + Left", desc: "Swap Window to Left", category: "navigation", icon: "󰁍", action: "hyprctl dispatch 'hl.dsp.window.swap({ direction = \"l\" })'" },
  { key: "SUPER + SHIFT + Right", desc: "Swap Window to Right", category: "navigation", icon: "󰁔", action: "hyprctl dispatch 'hl.dsp.window.swap({ direction = \"r\" })'" },
  { key: "SUPER + SHIFT + Up", desc: "Swap Window Up", category: "navigation", icon: "󰁝", action: "hyprctl dispatch 'hl.dsp.window.swap({ direction = \"u\" })'" },
  { key: "SUPER + SHIFT + Down", desc: "Swap Window Down", category: "navigation", icon: "󰁅", action: "hyprctl dispatch 'hl.dsp.window.swap({ direction = \"d\" })'" },

  { key: "ALT + TAB", desc: "Cycle Next Window", category: "navigation", icon: "󰹉", action: "hyprctl dispatch 'hl.dsp.window.cycle_next()'" },
  { key: "ALT + SHIFT + TAB", desc: "Cycle Previous Window", category: "navigation", icon: "󰹉", action: "hyprctl dispatch 'hl.dsp.window.cycle_next({ next = false })'" },
  { key: "CTRL + ALT + TAB", desc: "Focus Next Monitor", category: "navigation", icon: "󰍹", action: "hyprctl dispatch 'hl.dsp.focus({ monitor = \"+1\" })'" },
  { key: "CTRL + ALT + SHIFT + TAB", desc: "Focus Previous Monitor", category: "navigation", icon: "󰍹", action: "hyprctl dispatch 'hl.dsp.focus({ monitor = \"-1\" })'" },

  // -------------------------------------------------------------
  // Workspaces & Scratchpad
  // -------------------------------------------------------------
  { key: "SUPER + S", desc: "Toggle Scratchpad Workspace", category: "workspace", icon: "󰖮", action: "hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"scratchpad\")'" },
  { key: "SUPER + ALT + S", desc: "Move Window to Scratchpad", category: "workspace", icon: "󰪹", action: "hyprctl dispatch 'hl.dsp.window.move({ workspace = \"special:scratchpad\", follow = false })'" },
  { key: "SUPER + 1", desc: "Switch to Workspace 1", category: "workspace", icon: "󰄲", action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"1\" })'" },
  { key: "SUPER + 2", desc: "Switch to Workspace 2", category: "workspace", icon: "󰄲", action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"2\" })'" },
  { key: "SUPER + 3", desc: "Switch to Workspace 3", category: "workspace", icon: "󰄲", action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"3\" })'" },
  { key: "SUPER + 4", desc: "Switch to Workspace 4", category: "workspace", icon: "󰄲", action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"4\" })'" },
  { key: "SUPER + 5", desc: "Switch to Workspace 5", category: "workspace", icon: "󰄲", action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"5\" })'" },
  { key: "SUPER + 6", desc: "Switch to Workspace 6", category: "workspace", icon: "󰄲", action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"6\" })'" },
  { key: "SUPER + 7", desc: "Switch to Workspace 7", category: "workspace", icon: "󰄲", action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"7\" })'" },
  { key: "SUPER + 8", desc: "Switch to Workspace 8", category: "workspace", icon: "󰄲", action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"8\" })'" },
  { key: "SUPER + 9", desc: "Switch to Workspace 9", category: "workspace", icon: "󰄲", action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"9\" })'" },
  { key: "SUPER + 0", desc: "Switch to Workspace 10", category: "workspace", icon: "󰄲", action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"10\" })'" },

  { key: "SUPER + SHIFT + 1..9", desc: "Move Window to Workspace 1-9", category: "workspace", icon: "󰪹", action: "" },
  { key: "SUPER + TAB", desc: "Next Workspace", category: "workspace", icon: "󰁔", action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'" },
  { key: "SUPER + SHIFT + TAB", desc: "Previous Workspace", category: "workspace", icon: "󰁍", action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e-1\" })'" },
  { key: "SUPER + CTRL + TAB", desc: "Former / Previous Workspace", category: "workspace", icon: "󰹉", action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"previous\" })'" },

  // -------------------------------------------------------------
  // System Tools & Menus
  // -------------------------------------------------------------
  { key: "SUPER + K", desc: "SuperK Pilot HUD", category: "tools", icon: "󰞋", action: "omarchy-shell nav-guide toggle" },
  { key: "SUPER + SHIFT + K", desc: "Classic Keybindings Menu", category: "tools", icon: "󰌌", action: "omarchy-menu-keybindings" },
  { key: "SUPER + SPACE", desc: "Open Omarchy Menu (App Search)", category: "tools", icon: "󰍜", action: "omarchy-menu toggle" },
  { key: "SUPER + ALT + SPACE", desc: "Applications Submenu", category: "tools", icon: "󰍜", action: "omarchy-menu toggle apps" },
  { key: "SUPER + ESCAPE", desc: "System Power Menu", category: "tools", icon: "󰐥", action: "omarchy-menu toggle system" },
  { key: "SUPER + CTRL + V", desc: "Clipboard History Manager", category: "tools", icon: "󰅌", action: "omarchy-shell shell summon omarchy.clipboard '{}'" },
  { key: "SUPER + CTRL + E", desc: "Emoji Picker Overlay", category: "tools", icon: "󰞅", action: "omarchy-shell shell summon omarchy.emojis '{}'" },
  { key: "SUPER + CTRL + L", desc: "Lock System Screen", category: "tools", icon: "󰌾", action: "omarchy-system-lock" },
  { key: "SUPER + CTRL + Q", desc: "Quick Calculator (omacalc)", category: "tools", icon: "󰃬", action: "omacalc" },

  { key: "PRINT", desc: "Interactive Screenshot Region", category: "tools", icon: "󰹑", action: "omarchy-capture-screenshot" },
  { key: "ALT + PRINT", desc: "Screen Recording", category: "tools", icon: "󰕧", action: "omarchy-capture-screenrecording --stop-recording || omarchy-menu toggle trigger.capture.screenrecord" },
  { key: "SUPER + PRINT", desc: "Color Picker (hyprpicker)", category: "tools", icon: "󰈊", action: "pkill hyprpicker || hyprpicker -a" },
  { key: "SUPER + CTRL + PRINT", desc: "Extract Text (OCR) from Screen", category: "tools", icon: "󰚚", action: "omarchy-capture-text" },

  { key: "SUPER + CTRL + A", desc: "Audio Settings Panel", category: "tools", icon: "󰕾", action: "omarchy-shell shell toggle omarchy.audio" },
  { key: "SUPER + CTRL + B", desc: "Bluetooth Devices Panel", category: "tools", icon: "󰂯", action: "omarchy-shell shell toggle omarchy.bluetooth" },
  { key: "SUPER + CTRL + D", desc: "Display & Monitor Panel", category: "tools", icon: "󰍹", action: "omarchy-shell shell toggle omarchy.monitor" },
  { key: "SUPER + CTRL + ALT + D", desc: "Calendar & Clock Panel", category: "tools", icon: "󰃭", action: "omarchy-shell shell toggle omarchy.clock" },
  { key: "SUPER + CTRL + W", desc: "Network & Wi-Fi Panel", category: "tools", icon: "󰖩", action: "omarchy-shell shell toggle omarchy.network" },
  { key: "SUPER + CTRL + P", desc: "Power Management Panel", category: "tools", icon: "󰐥", action: "omarchy-shell shell toggle omarchy.power" },
  { key: "SUPER + CTRL + T", desc: "Activity Monitor (btop)", category: "tools", icon: "󰒍", action: "omarchy-launch-terminal btop" },

  { key: "SUPER + SHIFT + SPACE", desc: "Toggle Top Bar Visibility", category: "tools", icon: "󱂬", action: "omarchy-bar-toggle" },
  { key: "SUPER + CTRL + SPACE", desc: "Background Wallpaper Switcher", category: "tools", icon: "󰸉", action: "omarchy-menu toggle background" },
  { key: "SUPER + SHIFT + CTRL + SPACE", desc: "Omarchy Theme Switcher", category: "tools", icon: "󰔎", action: "omarchy-menu toggle theme" },

  { key: "SUPER + COMMA", desc: "Dismiss Last Notification", category: "tools", icon: "󰂚", action: "omarchy-shell notifications dismissOne" },
  { key: "SUPER + SHIFT + COMMA", desc: "Dismiss All Notifications", category: "tools", icon: "󰂛", action: "omarchy-shell notifications dismissAll" },
  { key: "SUPER + CTRL + COMMA", desc: "Toggle Notification Silencing (DND)", category: "tools", icon: "󰂛", action: "omarchy-toggle notification-silencing" },
  { key: "SUPER + SHIFT + ALT + COMMA", desc: "Show Notification History", category: "tools", icon: "󰂚", action: "omarchy-shell notifications showHistory" }
];
