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
    openTasks: [],      // Switch to other running apps
    currentWindow: [],  // Tiling, floating, split, close
    inAppTabs: [],      // In-app tab and document switching
    quickLaunch: []     // New instances or unopened apps
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

  // -------------------------------------------------------------
  // 1. SWITCH TO EXISTING OPEN WINDOWS (PRIORITY)
  // -------------------------------------------------------------
  // Same workspace (side-by-side)
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
        desc: "Swap side-by-side position",
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

  // Other workspaces
  for (var o = 0; o < otherWsOthers.length; o++) {
    var other = otherWsOthers[o];
    var ws = String(other.client.workspace ? other.client.workspace.name : "");
    var oLabel = other.info.label;
    var oTitle = truncateTitle(other.client.title, oLabel);

    sections.openTasks.push({
      key: "SUPER + " + ws,
      title: "Switch to " + oLabel + " (WS " + ws + ")",
      desc: oTitle,
      icon: other.info.icon,
      badge: "WS " + ws,
      action: "hyprctl dispatch " + shellQuote("hl.dsp.focus({ window = \"address:" + other.client.address + "\" })")
    });
  }

  // -------------------------------------------------------------
  // 2. IN-APP TAB / NAVIGATION SHORTCUTS
  // -------------------------------------------------------------
  if (curApp.type === "browser") {
    sections.inAppTabs.push({ key: "Ctrl + Tab", title: "Next Browser Tab", desc: "Cycle to next open tab", icon: "󰖟", badge: "Tab", action: "" });
    sections.inAppTabs.push({ key: "Ctrl + Shift + Tab", title: "Previous Tab", desc: "Cycle to previous tab", icon: "󰖟", badge: "Tab", action: "" });
    sections.inAppTabs.push({ key: "Ctrl + L", title: "Focus Address Bar", desc: "Jump to URL / search input", icon: "󰖟", badge: "URL", action: "" });
    sections.inAppTabs.push({ key: "Ctrl + T", title: "New Tab in Browser", desc: "Open a fresh tab", icon: "󰖟", badge: "New Tab", action: "" });
    sections.inAppTabs.push({ key: "Ctrl + W", title: "Close Tab", desc: "Close current browser tab", icon: "󰅖", badge: "Tab", action: "" });
    sections.inAppTabs.push({ key: "Ctrl + Shift + T", title: "Reopen Closed Tab", desc: "Restore last closed tab", icon: "󰖟", badge: "Tab", action: "" });
  } else if (curApp.type === "editor") {
    sections.inAppTabs.push({ key: "Ctrl + PageDown", title: "Next Editor Tab", desc: "Switch to next open file", icon: "󰨞", badge: "Tab", action: "" });
    sections.inAppTabs.push({ key: "Ctrl + PageUp", title: "Previous Editor Tab", desc: "Switch to previous open file", icon: "󰨞", badge: "Tab", action: "" });
    sections.inAppTabs.push({ key: "Ctrl + P", title: "Quick Open File", desc: "Fuzzy search files in project", icon: "󰨞", badge: "Files", action: "" });
    sections.inAppTabs.push({ key: "Ctrl + Shift + P", title: "Command Palette", desc: "Search editor actions", icon: "󰨞", badge: "Action", action: "" });
  } else if (curApp.type === "terminal") {
    sections.inAppTabs.push({ key: "SUPER + ALT + RETURN", title: "Launch Tmux Session", desc: "Terminal tabs & splits multiplexer", icon: "󰒍", badge: "Tmux", action: "omarchy-launch-terminal tmux" });
    sections.inAppTabs.push({ key: "SUPER + CTRL + RETURN", title: "Toggle Herdr Scratchpad", desc: "Slide out persistent terminal", icon: "󰖮", badge: "Scratchpad", action: "omarchy-launch-herdr" });
    sections.inAppTabs.push({ key: "Ctrl + Shift + V", title: "Paste into Terminal", desc: "Paste from clipboard", icon: "󰅌", badge: "Edit", action: "" });
    sections.inAppTabs.push({ key: "Ctrl + L", title: "Clear Screen", desc: "Reset terminal view", icon: "󰞷", badge: "Screen", action: "" });
  }

  // -------------------------------------------------------------
  // 3. CURRENT WINDOW CONTROLS
  // -------------------------------------------------------------
  if (activeWin && activeWin.address) {
    var isFloat = activeWin.floating === true;
    var isFull = (activeWin.fullscreen !== undefined && activeWin.fullscreen !== 0);

    sections.currentWindow.push({
      key: "SUPER + T",
      title: isFloat ? "Tile Window Back" : "Float Window",
      desc: isFloat ? "Return to automatic tiling grid" : "Float freely over windows",
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
      title: isFull ? "Exit Fullscreen" : "Fullscreen Focus",
      desc: isFull ? "Restore tiled view" : "Distraction-free fullscreen",
      icon: "󰊓",
      badge: "View",
      action: "hyprctl dispatch " + shellQuote("hl.dsp.window.fullscreen({ mode = \"fullscreen\" })")
    });

    sections.currentWindow.push({
      key: "SUPER + O",
      title: "Pop Out & Pin (PIP)",
      desc: "Float and pin across all workspaces",
      icon: "󰐃",
      badge: "Pin",
      action: "omarchy-hyprland-window-pop"
    });

    sections.currentWindow.push({
      key: "SUPER + W",
      title: "Close This Window",
      desc: "Safely close active window",
      icon: "󰅖",
      badge: "Close",
      action: "hyprctl dispatch " + shellQuote("hl.dsp.window.close()")
    });
  }

  // -------------------------------------------------------------
  // 4. QUICK LAUNCH / UNOPENED APPS (OR NEW INSTANCES)
  // -------------------------------------------------------------
  // If not running: primary launch. If running: new instance.
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
    desc: "Browse storage and documents",
    icon: "󰉋",
    badge: "Launch",
    action: "omarchy-launch-file-manager"
  });

  sections.quickLaunch.push({
    key: "SUPER + SPACE",
    title: "Open Omarchy Menu",
    desc: "Search apps, power, and workflows",
    icon: "󰍜",
    badge: "Menu",
    action: "omarchy-menu toggle"
  });

  return sections;
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
