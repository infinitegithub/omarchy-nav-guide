.pragma library

function detectCategory(appId, title) {
  var id = String(appId || "").toLowerCase();
  var t = String(title || "").toLowerCase();

  if (!id && !t) {
    return {
      category: "desktop",
      label: "Desktop",
      icon: "󰇄",
      description: "No window focused"
    };
  }

  // Web Browsers
  if (id.indexOf("chromium") !== -1 || id.indexOf("chrome") !== -1 ||
      id.indexOf("firefox") !== -1 || id.indexOf("brave") !== -1 ||
      id.indexOf("zen") !== -1 || id.indexOf("opera") !== -1 ||
      id.indexOf("vivaldi") !== -1 || id.indexOf("edge") !== -1) {
    return {
      category: "browser",
      label: "Web Browser (" + (appId || "Browser") + ")",
      icon: "󰖟",
      description: "Web browsing"
    };
  }

  // Terminals
  if (id.indexOf("ghostty") !== -1 || id.indexOf("foot") !== -1 ||
      id.indexOf("kitty") !== -1 || id.indexOf("alacritty") !== -1 ||
      id.indexOf("terminal") !== -1 || id.indexOf("wezterm") !== -1 ||
      t.indexOf("tmux") !== -1 || id.indexOf("xterm") !== -1) {
    return {
      category: "terminal",
      label: "Terminal (" + (appId || "Terminal") + ")",
      icon: "󰞷",
      description: "Command line shell"
    };
  }

  // Code Editors / IDEs
  if (id.indexOf("antigravity") !== -1 || id.indexOf("code") !== -1 ||
      id.indexOf("vscodium") !== -1 || id.indexOf("nvim") !== -1 ||
      id.indexOf("neovim") !== -1 || id.indexOf("zed") !== -1 ||
      id.indexOf("emacs") !== -1 || id.indexOf("cursor") !== -1) {
    return {
      category: "editor",
      label: "Code Editor (" + (appId || "Editor") + ")",
      icon: "󰨞",
      description: "Code and document editing"
    };
  }

  // File Managers
  if (id.indexOf("thunar") !== -1 || id.indexOf("nautilus") !== -1 ||
      id.indexOf("dolphin") !== -1 || id.indexOf("pcmanfm") !== -1 ||
      id.indexOf("nemo") !== -1 || id.indexOf("yazi") !== -1) {
    return {
      category: "filemanager",
      label: "File Manager (" + (appId || "Files") + ")",
      icon: "󰉋",
      description: "File manager"
    };
  }

  // Media Players
  if (id.indexOf("spotify") !== -1 || id.indexOf("vlc") !== -1 ||
      id.indexOf("mpv") !== -1 || id.indexOf("amberol") !== -1 ||
      id.indexOf("rhythmbox") !== -1 || id.indexOf("feh") !== -1) {
    return {
      category: "media",
      label: "Media (" + (appId || "Player") + ")",
      icon: "󰝚",
      description: "Audio/Video media"
    };
  }

  var display = appId ? (appId.charAt(0).toUpperCase() + appId.slice(1)) : "Application";
  return {
    category: "general",
    label: display,
    icon: "󰣆",
    description: "Application window"
  };
}

// Determines spatial direction of client relative to active window
function calculateRelativeDirection(currentAt, clientAt) {
  if (!currentAt || !clientAt || currentAt.length < 2 || clientAt.length < 2) return null;
  var curX = currentAt[0];
  var curY = currentAt[1];
  var cliX = clientAt[0];
  var cliY = clientAt[1];

  var dx = cliX - curX;
  var dy = cliY - curY;

  // Prioritize horizontal vs vertical based on larger offset
  if (Math.abs(dx) >= Math.abs(dy)) {
    if (dx < 0) return { dir: "left", label: "Left", hyprDir: "l", key: "SUPER + Left / H", swapKey: "SUPER + SHIFT + Left" };
    if (dx > 0) return { dir: "right", label: "Right", hyprDir: "r", key: "SUPER + Right / L", swapKey: "SUPER + SHIFT + Right" };
  } else {
    if (dy < 0) return { dir: "above", label: "Above", hyprDir: "u", key: "SUPER + Up / K", swapKey: "SUPER + SHIFT + Up" };
    if (dy > 0) return { dir: "below", label: "Below", hyprDir: "d", key: "SUPER + Down / J", swapKey: "SUPER + SHIFT + Down" };
  }
  return null;
}

function getAppIcon(className) {
  var c = String(className || "").toLowerCase();
  if (c.indexOf("brave") !== -1 || c.indexOf("chrome") !== -1 || c.indexOf("firefox") !== -1 || c.indexOf("zen") !== -1) return "󰖟";
  if (c.indexOf("ghostty") !== -1 || c.indexOf("foot") !== -1 || c.indexOf("kitty") !== -1 || c.indexOf("terminal") !== -1) return "󰞷";
  if (c.indexOf("antigravity") !== -1 || c.indexOf("code") !== -1 || c.indexOf("nvim") !== -1) return "󰨞";
  if (c.indexOf("thunar") !== -1 || c.indexOf("nautilus") !== -1 || c.indexOf("dolphin") !== -1) return "󰉋";
  if (c.indexOf("spotify") !== -1 || c.indexOf("vlc") !== -1 || c.indexOf("mpv") !== -1) return "󰝚";
  return "󰣆";
}

function cleanTitle(title, className) {
  var t = String(title || "").trim();
  if (!t || t.length === 0) return className || "Window";
  if (t.length > 34) return t.substring(0, 31) + "...";
  return t;
}

// Build smart suggestions based on where you are and ALL open windows
function buildSmartSuggestions(activeWin, allClients) {
  var suggestions = [];
  var curAddr = activeWin ? activeWin.address : "";
  var curWsId = (activeWin && activeWin.workspace) ? activeWin.workspace.id : 1;
  var curAt = activeWin ? activeWin.at : [0, 0];
  var catInfo = detectCategory(activeWin ? activeWin.class : "", activeWin ? activeWin.title : "");

  var clients = Array.isArray(allClients) ? allClients : [];
  var sameWorkspaceOthers = [];
  var otherWorkspaceOthers = [];

  var hasTerminalRunning = false;
  var hasBrowserRunning = false;
  var hasFileManagerRunning = false;

  for (var i = 0; i < clients.length; i++) {
    var c = clients[i];
    var cClass = String(c.class || "").toLowerCase();

    // Check running app presence
    if (cClass.indexOf("foot") !== -1 || cClass.indexOf("ghostty") !== -1 || cClass.indexOf("kitty") !== -1 || cClass.indexOf("terminal") !== -1 || cClass.indexOf("alacritty") !== -1) {
      hasTerminalRunning = true;
    }
    if (cClass.indexOf("brave") !== -1 || cClass.indexOf("chrome") !== -1 || cClass.indexOf("firefox") !== -1 || cClass.indexOf("zen") !== -1 || cClass.indexOf("chromium") !== -1) {
      hasBrowserRunning = true;
    }
    if (cClass.indexOf("thunar") !== -1 || cClass.indexOf("nautilus") !== -1 || cClass.indexOf("dolphin") !== -1) {
      hasFileManagerRunning = true;
    }

    if (c.address === curAddr) continue; // Skip active window

    if (c.workspace && c.workspace.id === curWsId) {
      sameWorkspaceOthers.push(c);
    } else if (c.workspace) {
      otherWorkspaceOthers.push(c);
    }
  }

  // -------------------------------------------------------------
  // 1. Same-workspace directional navigation (Side-by-side windows)
  // -------------------------------------------------------------
  for (var s = 0; s < sameWorkspaceOthers.length; s++) {
    var sibling = sameWorkspaceOthers[s];
    var rel = calculateRelativeDirection(curAt, sibling.at);
    var sibTitle = cleanTitle(sibling.title, sibling.class);
    var sibIcon = getAppIcon(sibling.class);

    if (rel) {
      // Focus directional shortcut
      suggestions.push({
        key: rel.key,
        title: "Focus " + sibTitle + " (" + rel.label + ")",
        desc: "Adjacent window tiled to your " + rel.label.toLowerCase(),
        icon: sibIcon,
        badge: rel.label,
        action: "hyprctl dispatch " + shellQuote("hl.dsp.focus({ window = \"address:" + sibling.address + "\" })")
      });

      // Swap directional shortcut
      suggestions.push({
        key: rel.swapKey,
        title: "Swap with " + sibTitle,
        desc: "Swap current window with the window on your " + rel.label.toLowerCase(),
        icon: "󰤉",
        badge: "Swap",
        action: "hyprctl dispatch " + shellQuote("hl.dsp.window.swap({ direction = \"" + rel.hyprDir + "\" })")
      });
    } else {
      // General sibling focus
      suggestions.push({
        key: "ALT + TAB",
        title: "Focus " + sibTitle,
        desc: "Cycle to other window on this workspace",
        icon: sibIcon,
        badge: "Same WS",
        action: "hyprctl dispatch " + shellQuote("hl.dsp.focus({ window = \"address:" + sibling.address + "\" })")
      });
    }
  }

  // -------------------------------------------------------------
  // 2. Other-workspace open window jumping
  // -------------------------------------------------------------
  for (var o = 0; o < otherWorkspaceOthers.length; o++) {
    var other = otherWorkspaceOthers[o];
    var wsName = String(other.workspace ? other.workspace.name : "");
    var oTitle = cleanTitle(other.title, other.class);
    var oIcon = getAppIcon(other.class);

    suggestions.push({
      key: "SUPER + " + wsName,
      title: "Jump to " + oTitle + " (WS " + wsName + ")",
      desc: "Open on Workspace " + wsName + " · Click to switch and focus",
      icon: oIcon,
      badge: "WS " + wsName,
      action: "hyprctl dispatch " + shellQuote("hl.dsp.focus({ window = \"address:" + other.address + "\" })")
    });
  }

  // -------------------------------------------------------------
  // 3. Recommended apps to launch (if not already running)
  // -------------------------------------------------------------
  if (!hasTerminalRunning) {
    suggestions.push({
      key: "SUPER + RETURN",
      title: "Launch Terminal",
      desc: "No terminal open · Launch a new terminal session",
      icon: "󰞷",
      badge: "Launch",
      action: "omarchy-launch-terminal"
    });
  }
  if (!hasBrowserRunning) {
    suggestions.push({
      key: "SUPER + SHIFT + RETURN",
      title: "Launch Web Browser",
      desc: "No browser open · Launch your default web browser",
      icon: "󰖟",
      badge: "Launch",
      action: "omarchy-launch-browser"
    });
  }
  if (!hasFileManagerRunning) {
    suggestions.push({
      key: "SUPER + SHIFT + F",
      title: "Launch File Manager",
      desc: "Browse storage and documents",
      icon: "󰉋",
      badge: "Files",
      action: "omarchy-launch-file-manager"
    });
  }

  // -------------------------------------------------------------
  // 4. Current Window Controls
  // -------------------------------------------------------------
  if (activeWin && activeWin.address) {
    var isFloat = activeWin.floating === true;
    var isFull = (activeWin.fullscreen !== undefined && activeWin.fullscreen !== 0);

    suggestions.push({
      key: "SUPER + T",
      title: isFloat ? "Tile Window Back" : "Float Window",
      desc: isFloat ? "Return window to tiling layout" : "Float window above the grid",
      icon: "󰉦",
      badge: isFloat ? "Floating" : "Tiled",
      action: "hyprctl dispatch " + shellQuote("hl.dsp.window.float({ action = \"toggle\" })")
    });

    suggestions.push({
      key: "SUPER + J",
      title: "Toggle Window Split",
      desc: "Toggle between horizontal and vertical split orientation",
      icon: "󰤉",
      badge: "Layout",
      action: "hyprctl dispatch " + shellQuote("hl.dsp.layout(\"togglesplit\")")
    });

    suggestions.push({
      key: "SUPER + F",
      title: isFull ? "Exit Fullscreen" : "Fullscreen",
      desc: isFull ? "Restore normal window size" : "Expand window across full display",
      icon: "󰊓",
      badge: "View",
      action: "hyprctl dispatch " + shellQuote("hl.dsp.window.fullscreen({ mode = \"fullscreen\" })")
    });

    suggestions.push({
      key: "SUPER + O",
      title: "Pop Out & Pin (PIP)",
      desc: "Float and pin this window across all workspaces",
      icon: "󰐃",
      badge: "Pin",
      action: "omarchy-hyprland-window-pop"
    });

    suggestions.push({
      key: "SUPER + W",
      title: "Close This Window",
      desc: "Close the currently focused window safely",
      icon: "󰅖",
      badge: "Close",
      action: "hyprctl dispatch " + shellQuote("hl.dsp.window.close()")
    });
  }

  // -------------------------------------------------------------
  // 5. In-App Navigation Cheatsheet (App-Specific)
  // -------------------------------------------------------------
  if (catInfo.category === "browser") {
    suggestions.push({ key: "Ctrl + L", title: "Focus Address / Search Bar", desc: "Instantly type a new URL or search query", icon: "󰖟", badge: "In-Browser", action: "" });
    suggestions.push({ key: "Ctrl + T", title: "New Browser Tab", desc: "Open a fresh tab in current window", icon: "󰖟", badge: "In-Browser", action: "" });
    suggestions.push({ key: "Ctrl + Tab", title: "Cycle to Next Tab", desc: "Hop forward through open tabs", icon: "󰖟", badge: "In-Browser", action: "" });
    suggestions.push({ key: "Ctrl + Shift + T", title: "Reopen Closed Tab", desc: "Restore the tab you just closed", icon: "󰖟", badge: "In-Browser", action: "" });
  } else if (catInfo.category === "terminal") {
    suggestions.push({ key: "SUPER + ALT + RETURN", title: "Launch Tmux", desc: "Terminal multiplexer session", icon: "󰒍", badge: "Terminal", action: "omarchy-launch-terminal tmux" });
    suggestions.push({ key: "SUPER + CTRL + RETURN", title: "Launch Herdr (Scratchpad)", desc: "Slide out persistent terminal scratchpad", icon: "󰖮", badge: "Terminal", action: "omarchy-launch-herdr" });
    suggestions.push({ key: "Ctrl + Shift + V", title: "Paste into Terminal", desc: "Paste clipboard contents into command line", icon: "󰅌", badge: "Terminal", action: "" });
    suggestions.push({ key: "Ctrl + L", title: "Clear Screen", desc: "Reset terminal view buffer", icon: "󰞷", badge: "Terminal", action: "" });
  } else if (catInfo.category === "editor") {
    suggestions.push({ key: "Ctrl + P", title: "Quick Open File", desc: "Search and jump to any project file", icon: "󰨞", badge: "In-Editor", action: "" });
    suggestions.push({ key: "Ctrl + Shift + P", title: "Command Palette", desc: "Access all editor commands and settings", icon: "󰨞", badge: "In-Editor", action: "" });
    suggestions.push({ key: "Ctrl + `", title: "Toggle Built-in Terminal", desc: "Open integrated editor terminal drawer", icon: "󰨞", badge: "In-Editor", action: "" });
  }

  // -------------------------------------------------------------
  // 6. Global Omarchy Launchers & Workspaces
  // -------------------------------------------------------------
  suggestions.push({
    key: "SUPER + SPACE",
    title: "Open Omarchy Menu",
    desc: "Search apps, power options, and system workflows",
    icon: "󰍜",
    badge: "Menu",
    action: "omarchy-menu toggle"
  });

  suggestions.push({
    key: "SUPER + CTRL + V",
    title: "Clipboard History",
    desc: "Browse and paste from clipboard manager",
    icon: "󰅌",
    badge: "Tools",
    action: "omarchy-shell shell summon omarchy.clipboard '{}'"
  });

  suggestions.push({
    key: "SUPER + K",
    title: "All Keybindings Explorer",
    desc: "Search every active Hyprland keybinding",
    icon: "󰌌",
    badge: "Cheatsheet",
    action: "omarchy-menu-keybindings"
  });

  return suggestions;
}

function shellQuote(s) {
  if (s === null || s === undefined) return "''";
  return "'" + String(s).replace(/'/g, "'\\''") + "'";
}

function parseKeys(keyString) {
  if (!keyString) return [];
  // Split on "/" or "+"
  var raw = String(keyString).split("+");
  var res = [];
  for (var i = 0; i < raw.length; i++) {
    var k = raw[i].trim();
    if (k.length > 0) res.push(k);
  }
  return res;
}
