# SuperK Pilot 🧭

[![Omarchy Shell Plugin](https://img.shields.io/badge/Omarchy-Shell%20Plugin-00D26A?style=flat-square&logo=archlinux&logoColor=white)](https://omarchy.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Hyprland Powered](https://img.shields.io/badge/Compositor-Hyprland-58E6D9?style=flat-square)](https://hyprland.org)
[![Zero Latency](https://img.shields.io/badge/Engine-Socket2%20Inotify-ff79c6?style=flat-square)](#architecture)

> **The real-time `SUPER + K` learning co-pilot that turns shortcut memorization into pure muscle memory.**

<p align="center">
  <img src="preview.png" alt="SuperK Pilot HUD" width="700" />
</p>

---

## 🎯 The Philosophy: Teach Shortcuts, Don't Replace Them

Most navigation helpers try to replace your keyboard with clickable mouse menus. **SuperK Pilot does the exact opposite.**

It acts as an intelligent, real-time flight instructor that sits beside you in the cockpit. Whenever you summon it with `SUPER + K`, it inspects your active workspace, surfaces the exact key combination you need, and coaches your fingers to execute it until navigation becomes second nature.

* **Exact Keys Displayed Everywhere**: Every suggestion prominently features its physical key sequence (`SUPER + 1`, `SUPER + F`, `SUPER + T`).
* **1-Keystroke Numeric Accelerators**: Jump to any running app across workspaces instantly with `[1]`, `[2]`, `[3]`.
* **The Goal Is Graduation**: With live XP tracking, daily streaks, and reflex drills, SuperK Pilot is built so that you eventually won't even need to open it—because your fingers will already know what to do.

---

## 🥊 Default `SUPER + K` vs. SuperK Pilot

| Feature | Built-in Omarchy `SUPER + K` | SuperK Pilot 🧭 |
| :--- | :---: | :---: |
| **Interface** | Static text dump (80+ lines) | High-contrast, theme-adaptive interactive HUD |
| **Context Awareness** | ❌ None (shows everything at once) | ✅ **0ms In-Memory** (knows active app, workspace, and state) |
| **Open App Radar** | ❌ None (you must memorize where apps live) | ✅ **Live App Switcher** (`[1]` Brave, `[2]` Blender, `[3]` VM) |
| **Learning Model** | ❌ Passive reading | ✅ **Active Muscle Memory** (accelerators & physical key prompts) |
| **Search Engine** | ❌ None | ✅ **Zero-Click Omnisearch** across open windows & 50+ keybindings |
| **Mastery Tracking** | ❌ 0 feedback | ✅ **Live XP Bar**, daily streaks, and shortcut podium (🥇🥈🥉) |
| **Reflex Training** | ❌ None | ✅ **Dojo Speed Drills** to lock shortcuts into subconscious memory |
| **End Result** | You stay dependent on cheat sheets | **You build reflex speed and master your keyboard** |

---

## ⚡ Key Highlights

### 1. 🎯 Live Open-App Radar (0ms Latency)
No more guessing where you left your browser or 3D viewport. SuperK Pilot streams live window state directly from Hyprland's `socket2.sock`. When summoned, it instantly surfaces all running apps across workspaces and scratchpads with single-keystroke accelerators:
* `[1]` `SUPER + 1` → Switch to Brave Browser (Workspace 1)
* `[2]` `SUPER + 4` → Switch to Blender 3D (Workspace 4)
* `[3]` `SUPER + S` → Switch to Antigravity IDE (Scratchpad)

### 2. 🪟 Contextual Window & Tiling Controls
Adapts to the active window on your screen:
* **Full Screen**: `SUPER + F` (border-free focus)
* **Full Width / Maximize**: `SUPER + ALT + F` (fills screen while keeping the status bar visible)
* **Float / Tile Toggle**: `SUPER + T` (snap floating windows back into the tiling grid)
* **Split Orientation**: `SUPER + J` (toggle next split between horizontal and vertical)
* **Stash to Scratchpad**: `SUPER + ALT + S` (hide window into background)

### 3. 🔍 Zero-Click Omnisearch
The search cursor is auto-focused the millisecond `SUPER + K` opens. Type a partial app name (`brave`, `blender`, `vm`) or a layout concept (`split`, `scratch`, `gaps`, `calc`) to filter open windows and the complete 50+ Omarchy system catalog simultaneously. Hit `Enter` to execute immediately.

### 4. 🏆 Gamified Mastery Progression & Podium
Every physical key combination you trigger is logged in real-time in the background:
* **Navigator Ranks**: Level 1 Novice → Level 6 Grandmaster.
* **Podium Leaderboard**: Highlights your three most frequently triggered shortcuts (🥇, 🥈, 🥉).
* **Audit Stream**: Relative timestamp log of recent shortcuts ("Just now", "2m ago") so you can audit your workflow efficiency.

### 5. 🥋 Reflex Dojo (Tab 4)
A dedicated, distraction-free practice drill mode. Run 60-second muscle memory speed drills under pressure to lock complex window and workspace shortcuts into subconscious reflexes.

---

## 🚀 Quick Install

Install and enable SuperK Pilot directly from git into your Omarchy environment:

```bash
omarchy plugin add https://github.com/infinitegithub/omarchy-nav-guide.git --enable --yes
```

To bind `SUPER + K` to SuperK Pilot, run the included keybind installer:

```bash
~/.config/omarchy/plugins/nav-guide/bin/register-keybind
```

> **Note**: This preserves Omarchy's classic text keybindings menu on `SUPER + SHIFT + K` as a fallback.

---

## 🎮 Keyboard Controls

| Keystroke | Action |
| :--- | :--- |
| `SUPER + K` | Summon / Dismiss SuperK Pilot HUD |
| `1` .. `9` | Instant accelerator to switch directly to open app `[N]` |
| `Down` / `Up` | Navigate suggestions or search results |
| `Enter` | Execute highlighted shortcut or switch to selected window |
| `Tab` / `Shift + Tab` | Cycle tabs (`Navigation` ↔ `All Commands` ↔ `History & Rank` ↔ `Dojo Practice`) |
| `Esc` | Clear search query, or close the HUD if already empty |
| `SUPER + SHIFT + K` | Classic fallback keybindings menu |

---

## 🛠️ Architecture

```
nav-guide/
├── manifest.json              # Omarchy plugin manifest (schema v1)
├── Panel.qml                  # Quickshell KeyboardPanel HUD & inotify watchers
├── NavigationModel.js         # Contextual suggestion engine & omnisearch
├── TipCatalog.js              # Complete Omarchy system keybindings catalog
├── preview.png                # Pixel-perfect storefront hero screenshot
├── bin/
│   ├── hypr-listener          # Real-time daemon monitoring Hyprland socket2.sock
│   ├── window-state           # Generates atomic nav-guide-windows.json snapshot
│   ├── stats-manager          # Thread-safe shortcut counter and streak engine
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

* **Data State Storage**:
  * Windows State: `~/.local/state/omarchy/nav-guide-windows.json`
  * Stats & History: `~/.local/state/omarchy/nav-guide-stats.json`

---

## 🤝 Contributing

Contributions and ideas are welcome! Feel free to open an issue or pull request to add new application recognition rules or workflow enhancements.

---

## 📄 License

Distributed under the [MIT License](LICENSE).  
Copyright © 2026 Es Sadik Sanhaji.
