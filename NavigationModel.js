.pragma library

function detectAppInfo(appId, title) {
  var id = String(appId || "").toLowerCase();
  var t = String(title || "").toLowerCase();

  if (!id && !t) {
    return {
      type: "desktop",
      label: "Desktop",
      icon: "󰇄",
      appCategory: "system"
    };
  }

  // Web Browsers
  if (id.indexOf("chromium") !== -1 || id.indexOf("chrome") !== -1 ||
      id.indexOf("firefox") !== -1 || id.indexOf("brave") !== -1 ||
      id.indexOf("zen") !== -1 || id.indexOf("opera") !== -1 ||
      id.indexOf("vivaldi") !== -1 || id.indexOf("edge") !== -1) {
    var name = "Browser";
    if (id.indexOf("brave") !== -1) name = "Brave";
    else if (id.indexOf("firefox") !== -1) name = "Firefox";
    else if (id.indexOf("chrome") !== -1) name = "Chrome";
    else if (id.indexOf("zen") !== -1) name = "Zen";
    return {
      type: "browser",
      label: name,
      icon: "󰖟",
      appCategory: "web"
    };
  }

  // Terminals
  if (id.indexOf("ghostty") !== -1 || id.indexOf("foot") !== -1 ||
      id.indexOf("kitty") !== -1 || id.indexOf("alacritty") !== -1 ||
      id.indexOf("terminal") !== -1 || id.indexOf("wezterm") !== -1 ||
      t.indexOf("tmux") !== -1 || id.indexOf("xterm") !== -1) {
    var term = "Terminal";
    if (id.indexOf("ghostty") !== -1) term = "Ghostty";
    else if (id.indexOf("foot") !== -1) term = "Foot";
    else if (id.indexOf("kitty") !== -1) term = "Kitty";
    else if (id.indexOf("alacritty") !== -1) term = "Alacritty";
    return {
      type: "terminal",
      label: term,
      icon: "󰞷",
      appCategory: "dev"
    };
  }

  // Code Editors / IDEs
  if (id.indexOf("antigravity") !== -1 || id.indexOf("code") !== -1 ||
      id.indexOf("vscodium") !== -1 || id.indexOf("nvim") !== -1 ||
      id.indexOf("neovim") !== -1 || id.indexOf("zed") !== -1 ||
      id.indexOf("emacs") !== -1 || id.indexOf("cursor") !== -1) {
    var ed = "Code Editor";
    if (id.indexOf("antigravity") !== -1) ed = "Antigravity";
    else if (id.indexOf("code") !== -1) ed = "VS Code";
    else if (id.indexOf("nvim") !== -1 || id.indexOf("neovim") !== -1) ed = "Neovim";
    else if (id.indexOf("zed") !== -1) ed = "Zed";
    return {
      type: "editor",
      label: ed,
      icon: "󰨞",
      appCategory: "dev"
    };
  }

  // File Managers
  if (id.indexOf("thunar") !== -1 || id.indexOf("nautilus") !== -1 ||
      id.indexOf("dolphin") !== -1 || id.indexOf("pcmanfm") !== -1 ||
      id.indexOf("nemo") !== -1 || id.indexOf("yazi") !== -1) {
    return {
      type: "filemanager",
      label: "Files",
      icon: "󰉋",
      appCategory: "files"
    };
  }

  // Media
  if (id.indexOf("spotify") !== -1 || id.indexOf("vlc") !== -1 ||
      id.indexOf("mpv") !== -1 || id.indexOf("amberol") !== -1) {
    return {
      type: "media",
      label: "Media",
      icon: "󰝚",
      appCategory: "media"
    };
  }

  var display = appId ? (appId.charAt(0).toUpperCase() + appId.slice(1)) : "Application";
  return {
    type: "general",
    label: display,
    icon: "󰣆",
    appCategory: "app"
  };
}

function calculateRelativeDirection(curAt, cliAt) {
  if (!curAt || !cliAt || curAt.length < 2 || cliAt.length < 2) return null;
  var dx = cliAt[0] - curAt[0];
  var dy = cliAt[1] - curAt[1];

  if (Math.abs(dx) >= Math.abs(dy)) {
    if (dx < 0) return { label: "Left", hyprDir: "l", key: "SUPER + Left / H", swapKey: "SUPER + SHIFT + Left" };
    if (dx > 0) return { label: "Right", hyprDir: "r", key: "SUPER + Right / L", swapKey: "SUPER + SHIFT + Right" };
  } else {
    if (dy < 0) return { label: "Above", hyprDir: "u", key: "SUPER + Up / K", swapKey: "SUPER + SHIFT + Up" };
    if (dy > 0) return { label: "Below", hyprDir: "d", key: "SUPER + Down / J", swapKey: "SUPER + SHIFT + Down" };
  }
  return null;
}

function truncateTitle(title, fallback) {
  var t = String(title || "").trim();
  if (!t) return fallback || "Window";
  if (t.length > 28) return t.substring(0, 25) + "...";
  return t;
}

function buildSmartNavigation(activeWin, allClients) {
  var curAddr = activeWin ? activeWin.address : "";
  var curWsId = (activeWin && activeWin.workspace) ? activeWin.workspace.id : 1;
  var curAt = activeWin ? activeWin.at : [0, 0];
  var curApp = detectAppInfo(activeWin ? activeWin.class : "", activeWin ? activeWin.title : "");

  var clients = Array.isArray(allClients) ? allClients : [];

  var sections = {
    openTasks: [],      // Navigate between open windows and workspaces
    currentWindow: [],  // Tiling, floating, split, close
    quickLaunch: []     // Launch new apps or new instances
  };

  var hasTerminal = false;
  var hasBrowser = false;
  var hasFileManager = false;

  var sameWsOthers = [];
  var otherWsOthers = [];

  for (var i = 0; i < clients.length; i++) {
    var c = clients[i];
    var info = detectAppInfo(c.class, c.title);

    if (info.type === "terminal") hasTerminal = true;
    if (info.type === "browser") hasBrowser = true;
    if (info.type === "filemanager") hasFileManager = true;

    if (c.address === curAddr) continue;

    if (c.workspace && c.workspace.id === curWsId) {
      sameWsOthers.push({ client: c, info: info });
    } else if (c.workspace) {
      otherWsOthers.push({ client: c, info: info });
    }
  }

  // 1. SWITCH TO EXISTING OPEN WINDOWS (TOP PRIORITY)
  for (var s = 0; s < sameWsOthers.length; s++) {
    var item = sameWsOthers[s];
    var rel = calculateRelativeDirection(curAt, item.client.at);
    var label = item.info.label;
    var title = truncateTitle(item.client.title, label);

    if (rel) {
      sections.openTasks.push({
        key: rel.key,
        title: "Switch to " + label + " (" + rel.label + ")",
        desc: title,
        icon: item.info.icon,
        badge: "Switch (" + rel.label + ")",
        action: "hyprctl dispatch " + shellQuote("hl.dsp.focus({ window = \"address:" + item.client.address + "\" })")
      });
      sections.openTasks.push({
        key: rel.swapKey,
        title: "Swap with " + label,
        desc: "Swap position with " + label,
        icon: "󰤉",
        badge: "Swap",
        action: "hyprctl dispatch " + shellQuote("hl.dsp.window.swap({ direction = \"" + rel.hyprDir + "\" })")
      });
    } else {
      sections.openTasks.push({
        key: "ALT + TAB",
        title: "Switch to " + label,
        desc: title,
        icon: item.info.icon,
        badge: "Switch",
        action: "hyprctl dispatch " + shellQuote("hl.dsp.focus({ window = \"address:" + item.client.address + "\" })")
      });
    }
  }

  for (var o = 0; o < otherWsOthers.length; o++) {
    var other = otherWsOthers[o];
    var ws = String(other.client.workspace ? other.client.workspace.name : "");
    var oLabel = other.info.label;
    var oTitle = truncateTitle(other.client.title, oLabel);

    sections.openTasks.push({
      key: "SUPER + " + ws,
      title: "Switch to " + oLabel + " (Workspace " + ws + ")",
      desc: oTitle,
      icon: other.info.icon,
      badge: "WS " + ws,
      action: "hyprctl dispatch " + shellQuote("hl.dsp.focus({ window = \"address:" + other.client.address + "\" })")
    });
  }

  // Fast Navigation & Cycling
  if (clients.length > 1) {
    sections.openTasks.push({
      key: "ALT + TAB",
      title: "Cycle Next Window",
      desc: "Fast cycle through open windows",
      icon: "󰹉",
      badge: "Cycle",
      action: "hyprctl dispatch 'hl.dsp.window.cycle_next()'"
    });
    sections.openTasks.push({
      key: "SUPER + TAB",
      title: "Next Workspace",
      desc: "Jump to next active workspace",
      icon: "󰁔",
      badge: "Workspace",
      action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'"
    });
  } else {
    // Only 1 or 0 windows: show fundamental directional movement
    sections.openTasks.push({
      key: "SUPER + Left / H",
      title: "Focus Left Window",
      desc: "Move focus to window on the left",
      icon: "󰁍",
      badge: "Focus",
      action: "hyprctl dispatch 'hl.dsp.focus({ direction = \"l\" })'"
    });
    sections.openTasks.push({
      key: "SUPER + Right / L",
      title: "Focus Right Window",
      desc: "Move focus to window on the right",
      icon: "󰁔",
      badge: "Focus",
      action: "hyprctl dispatch 'hl.dsp.focus({ direction = \"r\" })'"
    });
    sections.openTasks.push({
      key: "ALT + TAB",
      title: "Cycle Windows",
      desc: "Cycle between windows",
      icon: "󰹉",
      badge: "Cycle",
      action: "hyprctl dispatch 'hl.dsp.window.cycle_next()'"
    });
  }

  // 2. WINDOW TILING & LAYOUT CONTROLS
  if (activeWin && activeWin.address) {
    var isFloat = activeWin.floating === true;
    var isFull = (activeWin.fullscreen !== undefined && activeWin.fullscreen !== 0);

    sections.currentWindow.push({
      key: "SUPER + T",
      title: isFloat ? "Tile Window Back" : "Float Window",
      desc: isFloat ? "Snap back to auto-tiling grid" : "Float freely over other windows",
      icon: "󰉦",
      badge: isFloat ? "Floating" : "Tiled",
      action: "hyprctl dispatch " + shellQuote("hl.dsp.window.float({ action = \"toggle\" })")
    });

    sections.currentWindow.push({
      key: "SUPER + J",
      title: "Toggle Split Orientation",
      desc: "Switch between horizontal & vertical splits",
      icon: "󰤉",
      badge: "Split",
      action: "hyprctl dispatch " + shellQuote("hl.dsp.layout(\"togglesplit\")")
    });

    sections.currentWindow.push({
      key: "SUPER + F",
      title: isFull ? "Exit Fullscreen" : "Toggle Fullscreen",
      desc: isFull ? "Restore tiled view" : "Distraction-free fullscreen",
      icon: "󰊓",
      badge: "View",
      action: "hyprctl dispatch " + shellQuote("hl.dsp.window.fullscreen({ mode = \"fullscreen\" })")
    });

    sections.currentWindow.push({
      key: "SUPER + W",
      title: "Close Focused Window",
      desc: "Close the currently active window",
      icon: "󰅖",
      badge: "Close",
      action: "hyprctl dispatch " + shellQuote("hl.dsp.window.close()")
    });
  }

  // 3. QUICK LAUNCH / UNOPENED APPS (OR NEW INSTANCES)
  sections.quickLaunch.push({
    key: "SUPER + RETURN",
    title: hasTerminal ? "Open New Terminal" : "Launch Terminal",
    desc: hasTerminal ? "Open an additional terminal window" : "Start a new terminal session",
    icon: "󰞷",
    badge: hasTerminal ? "New Window" : "Launch",
    action: "omarchy-launch-terminal"
  });

  sections.quickLaunch.push({
    key: "SUPER + SHIFT + RETURN",
    title: hasBrowser ? "Open New Browser Window" : "Launch Web Browser",
    desc: hasBrowser ? "Open an additional browser window" : "Launch default browser",
    icon: "󰖟",
    badge: hasBrowser ? "New Window" : "Launch",
    action: "omarchy-launch-browser"
  });

  sections.quickLaunch.push({
    key: "SUPER + SHIFT + F",
    title: "Launch File Manager",
    desc: "Browse files and directories",
    icon: "󰉋",
    badge: "Launch",
    action: "omarchy-launch-file-manager"
  });

  sections.quickLaunch.push({
    key: "SUPER + SPACE",
    title: "Open Omarchy Menu",
    desc: "Application launcher and search",
    icon: "󰍜",
    badge: "Menu",
    action: "omarchy-menu toggle"
  });

  return sections;
}

// -------------------------------------------------------------
// MASTERY & STATS RANKING SYSTEM
// -------------------------------------------------------------

function getMasteryTier(count) {
  var c = Number(count) || 0;
  if (c >= 40) return { tier: "mastered", label: "Mastered", icon: "👑", count: c, tag: "👑 " + c + "x" };
  if (c >= 15) return { tier: "proficient", label: "Proficient", icon: "🏆", count: c, tag: "🏆 " + c + "x" };
  if (c >= 5)  return { tier: "familiar", label: "Familiar", icon: "⚡", count: c, tag: "⚡ " + c + "x" };
  if (c >= 1)  return { tier: "learning", label: "Learning", icon: "🌱", count: c, tag: "🌱 " + c + "x" };
  return { tier: "untried", label: "Untried", icon: "·", count: 0, tag: "0x" };
}

function formatTimeAgo(timestampMs) {
  if (!timestampMs) return "";
  var diff = Math.max(0, Date.now() - Number(timestampMs));
  var sec = Math.floor(diff / 1000);
  if (sec < 45) return "Just now";
  var min = Math.floor(sec / 60);
  if (min < 60) return min + "m ago";
  var hr = Math.floor(min / 60);
  if (hr < 24) return hr + "h ago";
  var days = Math.floor(hr / 24);
  if (days === 1) return "Yesterday";
  if (days < 30) return days + "d ago";
  return "Past";
}

function getNavigatorRank(totalActions, streak) {
  var total = Number(totalActions) || 0;
  var s = Number(streak) || 1;

  if (total < 15) {
    return {
      title: "Novice Tiler",
      icon: "🌱",
      level: 1,
      current: total,
      max: 15,
      percent: Math.min(1.0, total / 15),
      nextTitle: "Keyboard Apprentice",
      streak: s
    };
  }
  if (total < 40) {
    return {
      title: "Keyboard Apprentice",
      icon: "⚡",
      level: 2,
      current: total,
      max: 40,
      percent: Math.min(1.0, (total - 15) / 25),
      nextTitle: "Window Operator",
      streak: s
    };
  }
  if (total < 90) {
    return {
      title: "Window Operator",
      icon: "🎯",
      level: 3,
      current: total,
      max: 90,
      percent: Math.min(1.0, (total - 40) / 50),
      nextTitle: "Tiling Specialist",
      streak: s
    };
  }
  if (total < 180) {
    return {
      title: "Tiling Specialist",
      icon: "🥷",
      level: 4,
      current: total,
      max: 180,
      percent: Math.min(1.0, (total - 90) / 90),
      nextTitle: "Desktop Master",
      streak: s
    };
  }
  if (total < 350) {
    return {
      title: "Desktop Master",
      icon: "🏆",
      level: 5,
      current: total,
      max: 350,
      percent: Math.min(1.0, (total - 180) / 170),
      nextTitle: "Omarchy Grandmaster",
      streak: s
    };
  }
  return {
    title: "Omarchy Grandmaster",
    icon: "👑",
    level: 6,
    current: total,
    max: Math.max(total, 500),
    percent: 1.0,
    nextTitle: "Keyboard Legend",
    streak: s
  };
}

function normalizeKey(k) {
  return String(k || "").replace(/\s+/g, " ").trim().toUpperCase();
}

function synthesizeKeyDesc(key) {
  var k = normalizeKey(key);
  if (k === "SUPER + RETURN" || k === "SUPER + ENTER") return "Launch Terminal";
  if (k === "SUPER + B") return "Launch Browser";
  if (k === "SUPER + E") return "File Manager";
  if (k === "SUPER + W") return "Close Window";
  if (k === "SUPER + F") return "Full Screen";
  if (k === "SUPER + ALT + F") return "Full Width";
  if (k === "SUPER + T") return "Toggle Floating";
  if (k === "SUPER + J") return "Toggle Split";
  if (k === "SUPER + K") return "Navigation Guide HUD";
  if (k === "SUPER + SHIFT + K") return "Classic Keybindings Menu";
  if (k === "SUPER + SHIFT + BACKSPACE") return "Toggle Window Gaps";
  if (k.indexOf("SUPER + CODE:1") !== -1 || k.indexOf("SUPER + 1") !== -1) return "Switch to Workspace 1";
  if (k.indexOf("SUPER + CODE:11") !== -1 || k.indexOf("SUPER + 2") !== -1) return "Switch to Workspace 2";
  if (k.indexOf("SUPER + CODE:12") !== -1 || k.indexOf("SUPER + 3") !== -1) return "Switch to Workspace 3";
  if (k.indexOf("SUPER + LEFT") !== -1) return "Focus Left Window";
  if (k.indexOf("SUPER + RIGHT") !== -1) return "Focus Right Window";
  if (k.indexOf("SUPER + UP") !== -1) return "Focus Above Window";
  if (k.indexOf("SUPER + DOWN") !== -1) return "Focus Below Window";
  if (k === "ALT + TAB") return "Focus Next Window";
  return key;
}

function getLeaderboard(statsMap, allCatalog) {
  var catalog = Array.isArray(allCatalog) ? allCatalog : [];
  var map = (statsMap && typeof statsMap === "object") ? statsMap : {};

  // Build catalog lookup map
  var catMap = {};
  for (var i = 0; i < catalog.length; i++) {
    var cItem = catalog[i];
    catMap[normalizeKey(cItem.key)] = cItem;
  }

  var list = [];
  var seenKeys = {};

  // 1. Process all keys from statsMap so nothing is dropped
  var statKeys = Object.keys(map);
  for (var j = 0; j < statKeys.length; j++) {
    var rawKey = statKeys[j];
    var stat = map[rawKey];
    var count = stat ? (Number(stat.count) || 0) : 0;
    if (count <= 0) continue;

    var norm = normalizeKey(rawKey);
    seenKeys[norm] = true;
    var matched = catMap[norm];

    var desc = (matched && matched.desc) || (stat && stat.desc) || synthesizeKeyDesc(rawKey);
    var icon = (matched && matched.icon) || (stat && stat.icon) || "󰌌";
    var category = (matched && matched.category) || (stat && stat.category) || "shortcut";
    var action = (matched && matched.action) || "";

    list.push({
      key: (matched && matched.key) || rawKey,
      desc: desc,
      icon: icon,
      category: category,
      action: action,
      count: count,
      tier: getMasteryTier(count)
    });
  }

  // Sort descending by usage count
  list.sort(function(a, b) {
    return b.count - a.count;
  });

  return list;
}

function getDiscoverNext(statsMap, allCatalog) {
  var catalog = Array.isArray(allCatalog) ? allCatalog : [];
  var map = (statsMap && typeof statsMap === "object") ? statsMap : {};

  var candidates = [];
  for (var i = 0; i < catalog.length; i++) {
    var item = catalog[i];
    var norm = normalizeKey(item.key);
    var stat = map[item.key] || map[norm];
    var count = stat ? (Number(stat.count) || 0) : 0;
    if (count < 3) {
      candidates.push({
        key: item.key,
        desc: item.desc,
        icon: item.icon,
        category: item.category,
        action: item.action,
        count: count
      });
    }
  }

  return candidates.slice(0, 4);
}

function getDojoDrills() {
  return [
    {
      id: "fullscreen",
      title: "True Fullscreen",
      prompt: "Strip borders and expand to full monitor screen",
      targetKey: "SUPER + F",
      action: "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"fullscreen\" })'",
      icon: "󰊓",
      difficulty: "Easy",
      xp: 15
    },
    {
      id: "maximize",
      title: "Full Width (Maximized)",
      prompt: "Fill the screen workspace while keeping the top bar visible",
      targetKey: "SUPER + ALT + F",
      action: "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"maximized\" })'",
      icon: "󰹑",
      difficulty: "Medium",
      xp: 25
    },
    {
      id: "gaps",
      title: "Toggle Window Gaps",
      prompt: "Toggle outer/inner window gaps and borders globally",
      targetKey: "SUPER + SHIFT + BACKSPACE",
      action: "omarchy-hyprland-window-gaps-toggle",
      icon: "󰞋",
      difficulty: "Medium",
      xp: 25
    },
    {
      id: "float",
      title: "Toggle Floating Mode",
      prompt: "Switch active window between floating and tiled layout",
      targetKey: "SUPER + T",
      action: "hyprctl dispatch 'hl.dsp.window.float({ action = \"toggle\" })'",
      icon: "󰉈",
      difficulty: "Easy",
      xp: 15
    },
    {
      id: "split",
      title: "Toggle Split Orientation",
      prompt: "Rotate the current tiling split between horizontal and vertical",
      targetKey: "SUPER + J",
      action: "hyprctl dispatch 'hl.dsp.layout(\"togglesplit\")'",
      icon: "󰤻",
      difficulty: "Medium",
      xp: 20
    },
    {
      id: "terminal",
      title: "Spawn Terminal",
      prompt: "Launch or switch focus to your primary terminal",
      targetKey: "SUPER + RETURN",
      action: "omarchy-launch-terminal",
      icon: "󰞷",
      difficulty: "Easy",
      xp: 10
    },
    {
      id: "workspace-layout",
      title: "Workspace Layout Switcher",
      prompt: "Switch layout on the active workspace between Dwindle and Scrolling",
      targetKey: "SUPER + L",
      action: "omarchy-hyprland-workspace-layout-toggle",
      icon: "󱂬",
      difficulty: "Hard",
      xp: 35
    }
  ];
}

function shellQuote(s) {
  if (s === null || s === undefined) return "''";
  return "'" + String(s).replace(/'/g, "'\\''") + "'";
}

function parseKeys(keyString) {
  if (!keyString) return [];
  var raw = String(keyString).split("+");
  var res = [];
  for (var i = 0; i < raw.length; i++) {
    var k = raw[i].trim();
    if (k.length > 0) res.push(k);
  }
  return res;
}
