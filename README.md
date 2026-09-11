# Navigation Guide (`nav-guide`)

[![Omarchy Plugin](https://img.shields.io/badge/Omarchy-Shell%20Plugin-blue)](https://omarchy.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A smart, context-aware navigation tutor and companion for [Omarchy](https://omarchy.org). 

Instead of showing static cheat-sheets, **Navigation Guide** continuously watches your desktop layout and active applications to suggest relevant, practical keybindings based on **where you are and what you have open**.

---

## Features

- **Spatial Directional Awareness**:
  - When working side-by-side with other windows on the same workspace, the plugin calculates their relative positions (`Left`, `Right`, `Above`, `Below`).
  - Suggests directional focus shortcuts (e.g. `SUPER + Left` / `SUPER + H` to focus the browser on your left).
  - Suggests directional swap shortcuts (e.g. `SUPER + SHIFT + Left` to swap positions).
- **Cross-Workspace Window Jumping**:
  - Detects windows open across all virtual workspaces.
  - Suggests exact workspace hops (e.g. `SUPER + 2` to jump to a browser on Workspace 2).
- **Unopened Application Suggestions**:
  - Intelligently detects if essential tools (Terminal, Browser, File Manager) are not running anywhere and suggests their launch keybindings.
- **Current Window Controls**:
  - Quick access to tile/float toggle (`SUPER + T`), split layout orientation (`SUPER + J`), fullscreen (`SUPER + F`), pop-out/pin picture-in-picture (`SUPER + O`), and clean window closing (`SUPER + W`).
- **In-App Navigation Cheatsheets**:
  - When focused in a browser, shows tab & address bar hotkeys (`Ctrl + L`, `Ctrl + T`, `Ctrl + Tab`).
  - When focused in an editor, shows quick open and command palette hotkeys (`Ctrl + P`, `Ctrl + Shift + P`).
  - When focused in a terminal, shows clipboard, tmux, and Herdr hotkeys.
- **Universal Theme Adaptation**:
  - Automatically adapts to every Omarchy theme (Tokyo Night, Catppuccin Latte, Flexoki Light, Nord, OLED, etc.) without contrast bugs or hardcoded colors.
- **True Chronological History & Universal Leaderboard**:
  - Audit log of your recent shortcut executions with relative time chips ("Just now", "2m ago").
  - Tracks all shortcuts used across the system, with a 🥇, 🥈, 🥉 leaderboard podium and daily active streak (🔥).
- **Interactive Shortcut Dojo (Practice Trainer)**:
  - In-HUD muscle memory challenges that test your tiling and navigation reflexes against real-world tasks.
  - Multiplier combos (🔥 3x Combo!) and XP rewards that level up your Navigator rank from Novice Tiler to Omarchy Grandmaster.
- **Instant Number Accelerators (`1`–`9`) & Vim Navigation**:
  - Press `1` through `9` to instantly execute any open-window jump or action without touching your mouse.
  - Full keyboard support: navigate with `j`/`k` or arrow keys, press `Enter` to run, and press `Tab` to cycle between Views.
- **Instant Search with Quick Run**:
  - Press `/` anywhere in the HUD to filter shortcuts in real time, then hit `Enter` to instantly execute the top match.

---

## Installation

### Via Omarchy CLI

```bash
omarchy plugin add https://github.com/<your-username>/nav-guide.git --enable --yes
```

### Manual Installation

Clone directly into your Omarchy user plugins folder:

```bash
git clone https://github.com/<your-username>/nav-guide.git ~/.config/omarchy/plugins/nav-guide
omarchy-shell shell rescanPlugins
omarchy plugin enable nav-guide center
```

---

## Configuration

The plugin is configured in `~/.config/omarchy/shell.json`:

```json
{
  "id": "nav-guide"
}
```

### Move on Bar

Move the widget between bar sections:
```bash
omarchy bar move nav-guide --section center
omarchy bar move nav-guide --section right
omarchy bar move nav-guide --section left
```

### Keybinding Summon (`SUPER + K`)

When installed and enabled, Navigation Guide **automatically registers itself to `SUPER + K`**, replacing the default static keybindings pop-up with this interactive HUD.

- **`SUPER + K`**: Toggles the Navigation Guide HUD.
- **`SUPER + SHIFT + K`**: Retained as a fallback shortcut to open Omarchy's classic text-based keybindings menu (`omarchy-menu-keybindings`).

*(Note: The setup is performed once on initial load and written into an isolated block in `~/.config/hypr/bindings.lua`. If you ever uninstall the plugin, you can run `./bin/unregister-keybind` to restore defaults).*

---

## Project Structure

```
nav-guide/
├── manifest.json              # Plugin manifest (schema version 1)
├── Panel.qml                  # Bar widget and KeyboardPanel root
├── NavigationModel.js         # Spatial calculation and context rule engine
├── TipCatalog.js              # Shortcut catalog and educational tips
├── bin/
│   ├── window-state           # Real-time activewindow and clients query script
│   ├── stats-manager          # Usage and shortcut ranking persistence
│   ├── register-keybind       # Automatic SUPER + K installer for bindings.lua
│   └── unregister-keybind     # Clean unbinder for bindings.lua
├── components/
│   ├── ContextHeader.qml      # Active window and workspace status header
│   ├── KeyBadge.qml           # Keyboard key cap badges with tactile depth
│   ├── SuggestionCard.qml     # Interactive card with [1-9] accelerators
│   ├── HistoryRow.qml         # Chronological execution history row with relative timestamps
│   ├── DojoCard.qml           # Interactive speed drill & combo practice card
│   ├── TipBanner.qml          # Rotating tips carousel
│   └── MasteryCard.qml        # Rank, XP level, and daily streak card
├── LICENSE                    # MIT License
└── README.md                  # Documentation and guide
```

---

## License

[MIT](LICENSE) © 2026 Es Sadik Sanhaji
