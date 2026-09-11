.pragma library

var generalTips = [
  {
    title: "Split Direction",
    text: "Press SUPER + J to toggle whether your next window split opens horizontally or vertically.",
    shortcut: "SUPER + J"
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
  // Apps & Launching
  { key: "SUPER + RETURN", desc: "Launch Terminal", category: "apps", icon: "󰞷", action: "omarchy-launch-terminal" },
  { key: "SUPER + SHIFT + RETURN", desc: "Launch Web Browser", category: "apps", icon: "󰖟", action: "omarchy-launch-browser" },
  { key: "SUPER + SHIFT + F", desc: "Open File Manager", category: "apps", icon: "󰉋", action: "omarchy-launch-file-manager" },
  { key: "SUPER + SPACE", desc: "Open Omarchy Menu", category: "apps", icon: "󰍜", action: "omarchy-menu toggle" },
  { key: "SUPER + ALT + RETURN", desc: "Launch Tmux Terminal", category: "apps", icon: "󰒍", action: "omarchy-launch-terminal tmux" },
  { key: "SUPER + CTRL + RETURN", desc: "Launch Herdr (Scratchpad)", category: "apps", icon: "󰖮", action: "omarchy-launch-herdr" },
  { key: "SUPER + SHIFT + B", desc: "Launch Browser", category: "apps", icon: "󰖟", action: "omarchy-launch-browser" },
  { key: "SUPER + SHIFT + ALT + B", desc: "Browser (Private Window)", category: "apps", icon: "󰗹", action: "omarchy-launch-browser-private" },
  { key: "SUPER + SHIFT + ALT + F", desc: "File Manager (Current Folder)", category: "apps", icon: "󰉋", action: "omarchy-launch-file-manager-cwd" },

  // Window Management
  { key: "SUPER + W", desc: "Close Focused Window", category: "window", icon: "󰅖", action: "hyprctl dispatch 'hl.dsp.window.close()'" },
  { key: "SUPER + T", desc: "Toggle Floating / Tiling", category: "window", icon: "󰉦", action: "hyprctl dispatch 'hl.dsp.window.float({ action = \"toggle\" })'" },
  { key: "SUPER + F", desc: "Toggle Fullscreen", category: "window", icon: "󰊓", action: "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"fullscreen\" })'" },
  { key: "SUPER + ALT + F", desc: "Toggle Full Width", category: "window", icon: "󰁌", action: "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"maximized\" })'" },
  { key: "SUPER + J", desc: "Toggle Split Orientation", category: "window", icon: "󰤉", action: "hyprctl dispatch 'hl.dsp.layout(\"togglesplit\")'" },
  { key: "SUPER + O", desc: "Pop Window Out (Float & Pin)", category: "window", icon: "󰐃", action: "omarchy-hyprland-window-pop" },
  { key: "SUPER + P", desc: "Pseudo Tiling Mode", category: "window", icon: "󰹉", action: "hyprctl dispatch 'hl.dsp.window.pseudo()'" },
  { key: "SUPER + G", desc: "Toggle Window Grouping", category: "window", icon: "󰏘", action: "hyprctl dispatch 'hl.dsp.group.toggle()'" },
  { key: "SUPER + ALT + TAB", desc: "Next Window in Group", category: "window", icon: "󰹉", action: "hyprctl dispatch 'hl.dsp.group.next()'" },
  { key: "CTRL + ALT + DELETE", desc: "Close All Windows on Workspace", category: "window", icon: "󰅙", action: "omarchy-hyprland-window-close-all" },

  // Navigation & Directional Focus
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

  // Workspaces
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
  { key: "SUPER + S", desc: "Toggle Scratchpad", category: "workspace", icon: "󰖮", action: "hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"scratchpad\")'" },
  { key: "SUPER + ALT + S", desc: "Move Window to Scratchpad", category: "workspace", icon: "󰪹", action: "hyprctl dispatch 'hl.dsp.window.move({ workspace = \"special:scratchpad\", follow = false })'" },

  // Monitors
  { key: "CTRL + ALT + TAB", desc: "Focus Next Monitor", category: "monitors", icon: "󰍹", action: "hyprctl dispatch 'hl.dsp.focus({ monitor = \"+1\" })'" },
  { key: "CTRL + ALT + SHIFT + TAB", desc: "Focus Previous Monitor", category: "monitors", icon: "󰍹", action: "hyprctl dispatch 'hl.dsp.focus({ monitor = \"-1\" })'" },

  // Tools & System
  { key: "SUPER + K", desc: "Navigation Guide HUD", category: "tools", icon: "󰞋", action: "omarchy-shell nav-guide toggle" },
  { key: "SUPER + SHIFT + K", desc: "Classic Keybindings Menu", category: "tools", icon: "󰌌", action: "omarchy-menu-keybindings" },
  { key: "SUPER + CTRL + V", desc: "Clipboard History Manager", category: "tools", icon: "󰅌", action: "omarchy-shell shell summon omarchy.clipboard '{}'" },
  { key: "SUPER + CTRL + E", desc: "Emoji Picker", category: "tools", icon: "󰞅", action: "omarchy-shell shell summon omarchy.emojis '{}'" },
  { key: "SUPER + CTRL + L", desc: "Lock Screen", category: "tools", icon: "󰌾", action: "omarchy-lock" },
  { key: "SUPER + ESCAPE", desc: "System Power Menu", category: "tools", icon: "󰐥", action: "omarchy-menu system" },
  { key: "SUPER + PRINT", desc: "Color Picker", category: "tools", icon: "󰈊", action: "omarchy-color-picker" },
  { key: "PRINT", desc: "Screenshot Region", category: "tools", icon: "󰹑", action: "omarchy-capture-screenshot" },
  { key: "ALT + PRINT", desc: "Screen Recording", category: "tools", icon: "󰕧", action: "omarchy-capture-screenrecord" },
  { key: "SUPER + SHIFT + CTRL + SPACE", desc: "Theme Switcher Menu", category: "tools", icon: "󰔎", action: "omarchy-menu theme" }
];
