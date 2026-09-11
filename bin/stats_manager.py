#!/usr/bin/env python3
"""
Stats and history manager for Navigation Guide (nav-guide).
Handles atomic updates, chronological history logging, usage ranking,
and daily active streaks.
"""
import sys
import os
import json
import time
from datetime import datetime, date

STATE_DIR = os.path.expanduser("~/.local/state/omarchy")
STATS_FILE = os.path.join(STATE_DIR, "nav-guide-stats.json")
MAX_HISTORY = 100

def synthesize_meta(key):
    k = key.strip().upper()
    if "RETURN" in k or "ENTER" in k:
        return "Launch Terminal", "󰞷", "dev"
    if k == "SUPER + B":
        return "Launch Browser", "󰖟", "web"
    if k == "SUPER + E":
        return "File Manager", "󰉋", "files"
    if k == "SUPER + W":
        return "Close Window", "󰅖", "window"
    if k == "SUPER + F":
        return "Full Screen", "󰊓", "window"
    if k == "SUPER + ALT + F":
        return "Full Width (Maximized)", "󰹑", "window"
    if k == "SUPER + SHIFT + F":
        return "Tiled Full Screen", "󰊓", "window"
    if k == "SUPER + T":
        return "Toggle Floating Mode", "󰉈", "window"
    if k == "SUPER + J":
        return "Toggle Split Layout", "󰤻", "window"
    if k == "SUPER + K":
        return "Navigation Guide HUD", "󰞋", "tools"
    if k == "SUPER + SHIFT + K":
        return "Classic Keybindings Menu", "󰌌", "tools"
    if k == "SUPER + SHIFT + BACKSPACE":
        return "Toggle Window Gaps", "󰞋", "window"
    if "RIGHT" in k:
        return "Focus Right Window", "󰅂", "navigation"
    if "LEFT" in k:
        return "Focus Left Window", "󰅁", "navigation"
    if "UP" in k:
        return "Focus Above Window", "󰅃", "navigation"
    if "DOWN" in k:
        return "Focus Below Window", "󰅀", "navigation"
    if "ALT + TAB" in k:
        return "Focus Next Window", "󰌌", "navigation"
    for i in range(1, 11):
        if f"SUPER + {i}" in k or f"CODE:{i+9}" in k:
            return f"Switch to Workspace {i}", "󰍹", "workspace"
    return key, "󰌌", "shortcut"

def load_data():
    os.makedirs(STATE_DIR, exist_ok=True)
    if not os.path.exists(STATS_FILE):
        return {
            "totalActions": 0,
            "streak": 1,
            "lastActiveDate": str(date.today()),
            "history": [],
            "stats": {}
        }
    try:
        with open(STATS_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            if not isinstance(data, dict):
                data = {}
            data.setdefault("totalActions", 0)
            data.setdefault("streak", 1)
            data.setdefault("lastActiveDate", str(date.today()))
            data.setdefault("history", [])
            data.setdefault("stats", {})
            return data
    except Exception:
        return {
            "totalActions": 0,
            "streak": 1,
            "lastActiveDate": str(date.today()),
            "history": [],
            "stats": {}
        }

def save_data(data):
    os.makedirs(STATE_DIR, exist_ok=True)
    tmp_file = f"{STATS_FILE}.tmp.{os.getpid()}"
    with open(tmp_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    os.replace(tmp_file, STATS_FILE)

def update_streak(data):
    today_str = str(date.today())
    last_str = data.get("lastActiveDate")
    streak = data.get("streak", 1)

    if last_str != today_str:
        try:
            last_date = datetime.strptime(last_str, "%Y-%m-%d").date()
            diff = (date.today() - last_date).days
            if diff == 1:
                streak += 1
            elif diff > 1:
                streak = 1
        except Exception:
            streak = 1
        data["lastActiveDate"] = today_str
        data["streak"] = streak

def record_action(key, desc="", icon="", category=""):
    data = load_data()
    now_ms = int(time.time() * 1000)

    # Fill metadata if missing
    syn_desc, syn_icon, syn_cat = synthesize_meta(key)
    desc = desc or syn_desc
    icon = icon or syn_icon
    category = category or syn_cat

    # 1. Update streak
    update_streak(data)

    # 2. Update totals
    data["totalActions"] = data.get("totalActions", 0) + 1

    # 3. Update stats map
    stats = data.setdefault("stats", {})
    item = stats.setdefault(key, {
        "count": 0,
        "lastUsed": now_ms,
        "desc": desc,
        "icon": icon,
        "category": category
    })
    item["count"] = item.get("count", 0) + 1
    item["lastUsed"] = now_ms
    item["desc"] = desc
    item["icon"] = icon
    item["category"] = category

    # 4. Append to chronological history stream (newest first)
    history = data.setdefault("history", [])
    history_entry = {
        "id": f"h_{now_ms}_{len(history)}",
        "key": key,
        "desc": desc,
        "icon": icon,
        "category": category,
        "timestamp": now_ms
    }
    history.insert(0, history_entry)
    if len(history) > MAX_HISTORY:
        data["history"] = history[:MAX_HISTORY]

    save_data(data)
    return data

def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "get"

    if cmd == "get":
        data = load_data()
        print(json.dumps(data, ensure_ascii=False))
    elif cmd == "record":
        if len(sys.argv) < 3 or not sys.argv[2].strip():
            print(json.dumps(load_data(), ensure_ascii=False))
            sys.exit(0)
        key = sys.argv[2].strip()
        desc = sys.argv[3].strip() if len(sys.argv) > 3 else ""
        icon = sys.argv[4].strip() if len(sys.argv) > 4 else ""
        category = sys.argv[5].strip() if len(sys.argv) > 5 else ""
        data = record_action(key, desc, icon, category)
        print(json.dumps(data, ensure_ascii=False))
    elif cmd == "clear-history":
        data = load_data()
        data["history"] = []
        save_data(data)
        print(json.dumps(data, ensure_ascii=False))
    elif cmd == "reset":
        data = {
            "totalActions": 0,
            "streak": 1,
            "lastActiveDate": str(date.today()),
            "history": [],
            "stats": {}
        }
        save_data(data)
        print(json.dumps(data, ensure_ascii=False))
    else:
        print(f"Unknown command: {cmd}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
