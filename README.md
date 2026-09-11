# Navigation Guide (`nav-guide`)

[![Omarchy Shell Plugin](https://img.shields.io/badge/Omarchy-Shell%20Plugin-00D26A?style=flat-square&logo=archlinux&logoColor=white)](https://omarchy.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Hyprland Powered](https://img.shields.io/badge/Compositor-Hyprland-58E6D9?style=flat-square)](https://hyprland.org)
[![Zero Latency](https://img.shields.io/badge/IPC-Inotify%20FileView-ff79c6?style=flat-square)](#architecture)

A live, context-aware command HUD and navigation companion for [Omarchy](https://omarchy.org).

Replaces the default static `SUPER + K` cheatsheet with an interactive, real-time navigation cockpit that detects **where you are**, **what windows you have open**, and **where you need to jump next**.

---

## ⚡ Highlights

* **🎯 Real-Time Open Window Detection**: Instantly shows all running apps across virtual workspaces (Brave, Windows VM, Blender, Code Editors, Terminals) with 1-keystroke numeric accelerators (`[1]`, `[2]`, `[3]`).
* **🔎 Auto-Focused Omnisearch**: Opens with the search cursor immediately active. Queries both live open windows and 50+ Omarchy shortcuts simultaneously with zero clicks.
* **🪟 Active Window Layout Controls**: Instant controls for the focused window: True Fullscreen (`SUPER + F`), Full Width / Maximize (`SUPER + ALT + F`), Float / Tile toggle (`SUPER + T`), Split rotation (`SUPER + J`), and Scratchpad stash (`SUPER + ALT + S`).
* **📦 Seamless Scratchpad Support**: Detects scratchpad windows and surfaces them with standard `SUPER + S` toggles rather than raw internal IDs.
* **🎨 100% Theme Adaptive**: Dynamically inherits active theme tokens (`Color.popups.*`, `Color.accent`, `Color.muted`). Seamless contrast across Tokyo Night, Catppuccin, Nord, Flexoki, and OLED.
* **⚡ 0ms Reactive Inotify Engine**: Uses a background Hyprland socket daemon and Quickshell's native `FileView` watchers. Zero polling, zero subshell delay, 100% in-memory data at launch.
* **📜 Leaderboard & Execution Log**: Tracks which key combinations you use most with podium rankings (🥇 🥈 🥉) and relative time history.
* **🥋 Muscle Memory Dojo (Tab 4)**: An interactive reflex drill mode with XP rewards and combo multipliers to master tiling shortcuts under pressure.

---

## 📸 Overview

```
┌─────────────────────────────────────────────────────────────┐
│ 󰞋 Navigation Guide       🌱 LVL 4: Tiling Specialist · 163 XP │
├─────────────────────────────────────────────────────────────┤
│ [ 🎯 Navigation ]  [ 📋 All Commands ]  [ 📜 History ] [ 🥋 Dojo ]│
├─────────────────────────────────────────────────────────────┤
│ 🔍 Search commands or open windows (brave, blender, split)...│
├─────────────────────────────────────────────────────────────┤
│ 󰖟 Currently focused: Brave Browser · Workspace 2           │
│   "He Woke Up 500 Years in the Future - YouTube - Brave"    │
├─────────────────────────────────────────────────────────────┤
│ SWITCH TO OPEN APPS                                         │
│  [1] SUPER + 3  Switch to Windows VM (Workspace 3)   [WS 3] │
│  [2] SUPER + 4  Switch to Blender 3D (Workspace 4)   [WS 4] │
│  [3] SUPER + S  Switch to Antigravity IDE (Scratchpad)     │
│      ALT + TAB  Cycle Next Window                 [Cycle]   │
├─────────────────────────────────────────────────────────────┤
│ ACTIVE WINDOW CONTROLS & TILING                             │
│      SUPER + F      Full Screen (Border-Free)               │
│      SUPER + ALT + F Full Width (Maximized)                 │
│      SUPER + T      Toggle Floating Mode                    │
│      SUPER + J      Toggle Split Orientation                │
│      SUPER + W      Close Active Window                     │
├─────────────────────────────────────────────────────────────┤
│ ESSENTIAL SYSTEM TOOLS                                      │
│      SUPER + S      Toggle Scratchpad Workspace             │
│      SUPER + SPACE  Application Launcher Menu               │
│      SUPER + RETURN Spawn Terminal                          │
│      SUPER + CTRL+V Clipboard History                       │
│      PRINT          Interactive Screenshot Region           │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Installation

### Option A: Via Omarchy CLI (Recommended)

```bash
omarchy plugin add https://github.com/infinitegithub/omarchy-nav-guide.git --enable --yes
```

### Option B: Manual Git Clone

```bash
git clone https://github.com/infinitegithub/omarchy-nav-guide.git ~/.config/omarchy/plugins/nav-guide
omarchy-shell shell rescanPlugins
omarchy plugin enable nav-guide center
omarchy-restart-shell
```

---

## ⌨️ Controls & Keybindings

Once installed, **Navigation Guide** automatically binds to **`SUPER + K`** (while preserving `SUPER + SHIFT + K` for Omarchy's classic text menu).

| Shortcut | Action |
| :--- | :--- |
| **`SUPER + K`** | Open / close Navigation Guide HUD |
| **`1` – `9`** | Instantly switch to matching open app accelerator |
| **`Down` / `Up`** | Navigate selection down / up |
| **`Enter`** | Execute highlighted command or switch to selected window |
| **`Tab` / `Shift + Tab`** | Cycle tabs (`Navigation` ↔ `All Commands` ↔ `History` ↔ `Dojo`) |
| **`Esc`** | Clear search field, or dismiss HUD if empty |
| **`SUPER + SHIFT + K`** | Classic text keybindings fallback menu |

---

## 🧭 HUD Views

### 1. 🎯 Navigation (Page 1)
* **Active Window Context**: Displays current app, window title, and active workspace.
* **Switch to Open Apps**: Lists every running window on other workspaces and scratchpads with accelerator badges.
* **Window Controls**: Quick layout actions tailored to the active window.
* **Essential Tools**: Instant access to Scratchpad, Launcher, Terminal, Files, Clipboard, and Screenshot.

### 2. 📋 All Commands (Catalog)
Full catalog of 50+ official Omarchy keybindings indexed across:
* **Apps & Launchers**: Terminal, Browser, Private Browser, Editors, Tmux, TUIs, WebApps.
* **Window Management**: Tile/Float, Fullscreen, Full-Width, Groups, Aspect, Transparency, Gaps.
* **Workspaces & Monitors**: Switching, silent movement, multi-monitor focus.
* **System Utilities**: Power menu, Volume/Audio, Bluetooth, Network, Display, Activity (btop), OCR.

### 3. 📜 History & Rank
* **Mastery Progress**: Live XP, Navigator Rank (Level 1 Novice → Level 6 Grandmaster), and daily streak counter.
* **Podium Leaderboard**: Highlights your most frequently triggered key combinations (🥇, 🥈, 🥉).
* **Execution Audit Stream**: Chronological log of recent actions with relative timestamps ("Just now", "2m ago").

### 4. 🥋 Dojo Practice
* Interactive muscle memory drill mode.
* Practice real-world layout actions under pressure, earn +XP rewards, build streak combo multipliers, and discover underused shortcuts.

---

## 🛠️ Architecture

```
nav-guide/
├── manifest.json              # Omarchy plugin manifest (schema v1)
├── Panel.qml                  # Root Quickshell KeyboardPanel & FileView watchers
├── NavigationModel.js         # App detection, spatial layout engine & omni-search
├── TipCatalog.js              # Complete Omarchy system keybindings catalog
├── bin/
│   ├── hypr-listener          # Real-time daemon monitoring Hyprland .socket2.sock
│   ├── window-state           # Generates atomic nav-guide-windows.json snapshot
│   ├── stats-manager          # Thread-safe shortcut counter and streak manager
│   ├── stats_manager.py       # Python ranking & history storage engine
│   ├── register-keybind       # SUPER + K installer for ~/.config/hypr/bindings.lua
│   └── unregister-keybind     # Clean unbinder script
└── components/
    ├── SuggestionCard.qml     # Interactive card with [1-9] accelerator badges
    ├── KeyBadge.qml           # Tactile keyboard key badge with theme adaptation
    ├── MasteryCard.qml        # Level, XP bar, and streak display
    ├── HistoryRow.qml         # Audit stream row
    └── DojoCard.qml           # Speed drill card with combo multipliers
```

* **Data Storage**:
  * Windows State: `~/.local/state/omarchy/nav-guide-windows.json`
  * Stats & History: `~/.local/state/omarchy/nav-guide-stats.json`

---

## 🤝 Contributing

Pull requests and issue reports are welcome! If you're using Omarchy on Arch Linux + Hyprland, feel free to submit new application categorizations or feature suggestions.

---

## 📄 License

Distributed under the [MIT License](LICENSE).  
Copyright © 2026 Es Sadik Sanhaji.
