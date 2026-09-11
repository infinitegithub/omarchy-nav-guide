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
      id.indexOf("vivaldi") !== -1 || id.indexOf("edge") !== -1 ||
      t.indexOf("brave") !== -1 || t.indexOf("firefox") !== -1) {
    var bName = "Web Browser";
    if (id.indexOf("brave") !== -1 || t.indexOf("brave") !== -1) bName = "Brave Browser";
    else if (id.indexOf("firefox") !== -1 || t.indexOf("firefox") !== -1) bName = "Firefox";
    else if (id.indexOf("chrome") !== -1) bName = "Google Chrome";
    else if (id.indexOf("zen") !== -1) bName = "Zen Browser";
    return {
      type: "browser",
      label: bName,
      icon: "󰖟",
      appCategory: "web"
    };
  }

  // Virtual Machines & Remote Desktop
  if (id.indexOf("xfreerdp") !== -1 || id.indexOf("rdp") !== -1 ||
      id.indexOf("remmina") !== -1 || id.indexOf("moonlight") !== -1 ||
      id.indexOf("sunshine") !== -1 || id.indexOf("virt-manager") !== -1 ||
      id.indexOf("quickemu") !== -1 || id.indexOf("qemu") !== -1 ||
      t.indexOf("windows vm") !== -1 || t.indexOf("virtual machine") !== -1 ||
      t.indexOf("vm") !== -1 || t.indexOf("remote desktop") !== -1) {
    var vmName = "Remote Desktop";
    if (t.indexOf("windows") !== -1 || id.indexOf("windows") !== -1) vmName = "Windows VM";
    return {
      type: "vm",
      label: vmName,
      icon: "󰍹",
      appCategory: "vm"
    };
  }

  // 3D & Creative Design
  if (id.indexOf("blender") !== -1 || id.indexOf("gimp") !== -1 ||
      id.indexOf("inkscape") !== -1 || id.indexOf("krita") !== -1 ||
      id.indexOf("kdenlive") !== -1 || id.indexOf("obs") !== -1 ||
      id.indexOf("darktable") !== -1 || id.indexOf("figma") !== -1) {
    var creatName = "Creative App";
    if (id.indexOf("blender") !== -1) creatName = "Blender 3D";
    else if (id.indexOf("gimp") !== -1) creatName = "GIMP";
    else if (id.indexOf("inkscape") !== -1) creatName = "Inkscape";
    else if (id.indexOf("obs") !== -1) creatName = "OBS Studio";
    return {
      type: "creative",
      label: creatName,
      icon: "󰽉",
      appCategory: "creative"
    };
  }

  // Terminals
  if (id.indexOf("ghostty") !== -1 || id.indexOf("foot") !== -1 ||
      id.indexOf("kitty") !== -1 || id.indexOf("alacritty") !== -1 ||
      id.indexOf("terminal") !== -1 || id.indexOf("wezterm") !== -1 ||
      t.indexOf("tmux") !== -1 || id.indexOf("xterm") !== -1) {
    var term = "Terminal";
    if (id.indexOf("ghostty") !== -1) term = "Ghostty Terminal";
    else if (id.indexOf("foot") !== -1) term = "Foot Terminal";
    else if (id.indexOf("kitty") !== -1) term = "Kitty Terminal";
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
    if (id.indexOf("antigravity") !== -1) ed = "Antigravity IDE";
    else if (id.indexOf("code") !== -1) ed = "VS Code";
    else if (id.indexOf("nvim") !== -1 || id.indexOf("neovim") !== -1) ed = "Neovim";
    else if (id.indexOf("zed") !== -1) ed = "Zed Editor";
    return {
      type: "editor",
      label: ed,
      icon: "󰨞",
      appCategory: "dev"
    };
  }

  // Communication & Chat
  if (id.indexOf("discord") !== -1 || id.indexOf("slack") !== -1 ||
      id.indexOf("telegram") !== -1 || id.indexOf("signal") !== -1 ||
      id.indexOf("element") !== -1 || id.indexOf("thunderbird") !== -1 ||
      id.indexOf("omamail") !== -1) {
    var commName = "Chat";
    if (id.indexOf("signal") !== -1) commName = "Signal";
    else if (id.indexOf("discord") !== -1) commName = "Discord";
    else if (id.indexOf("slack") !== -1) commName = "Slack";
    else if (id.indexOf("telegram") !== -1) commName = "Telegram";
    return {
      type: "chat",
      label: commName,
      icon: "󰭹",
      appCategory: "comm"
    };
  }

  // File Managers
  if (id.indexOf("thunar") !== -1 || id.indexOf("nautilus") !== -1 ||
      id.indexOf("dolphin") !== -1 || id.indexOf("pcmanfm") !== -1 ||
      id.indexOf("nemo") !== -1 || id.indexOf("yazi") !== -1) {
    return {
      type: "filemanager",
      label: "File Manager",
      icon: "󰉋",
      appCategory: "files"
    };
  }

  // Media
  if (id.indexOf("spotify") !== -1 || id.indexOf("vlc") !== -1 ||
      id.indexOf("mpv") !== -1 || id.indexOf("amberol") !== -1) {
    var med = "Media Player";
    if (id.indexOf("spotify") !== -1) med = "Spotify";
    return {
      type: "media",
      label: med,
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
  if (t.length > 34) return t.substring(0, 31) + "...";
  return t;
}

function buildSmartNavigation(activeWin, allClients) {
  var curAddr = (activeWin && activeWin.address) ? String(activeWin.address) : "";
  var curWsId = (activeWin && activeWin.workspace) ? activeWin.workspace.id : null;
  var curAt = (activeWin && activeWin.at) ? activeWin.at : [0, 0];
  var curApp = detectAppInfo(activeWin ? activeWin.class : "", activeWin ? activeWin.title : "");

  var clients = Array.isArray(allClients) ? allClients : [];

  var sections = {
    openTasks: [],      // Switch to other open windows and apps (top priority)
    currentWindow: [],  // Tiling, floating, split, fullscreen, close active
    essentialTools: []  // Instant system navigation tools
  };

  var sameWsOthers = [];
  var otherWsOthers = [];

  for (var i = 0; i < clients.length; i++) {
    var c = clients[i];
    var info = detectAppInfo(c.class, c.title);

    // Don't show current active window in switch list
    if (curAddr && c.address === curAddr) continue;

    if (curWsId !== null && c.workspace && c.workspace.id === curWsId) {
      sameWsOthers.push({ client: c, info: info });
    } else if (c.workspace) {
      otherWsOthers.push({ client: c, info: info });
    }
  }

  // 1. Same workspace neighbors (spatial Left/Right/Up/Down)
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
        badge: "Focus " + rel.label,
        action: "hyprctl dispatch " + shellQuote("hl.dsp.focus({ window = \"address:" + item.client.address + "\" })")
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

  // 2. Sort other workspace clients: numerical 1..10 first, then scratchpad
  otherWsOthers.sort(function(a, b) {
    var aWs = a.client.workspace ? String(a.client.workspace.name) : "";
    var bWs = b.client.workspace ? String(b.client.workspace.name) : "";
    var aIsSpecial = aWs.indexOf("special:") === 0;
    var bIsSpecial = bWs.indexOf("special:") === 0;
    if (aIsSpecial && !bIsSpecial) return 1;
    if (!aIsSpecial && bIsSpecial) return -1;
    var aId = a.client.workspace ? Number(a.client.workspace.id) || 0 : 0;
    var bId = b.client.workspace ? Number(b.client.workspace.id) || 0 : 0;
    return aId - bId;
  });

  // Windows open on other workspaces (Workspace jump + direct address focus)
  for (var o = 0; o < otherWsOthers.length; o++) {
    var other = otherWsOthers[o];
    var ws = String(other.client.workspace ? other.client.workspace.name : "");
    var isScratchpad = (ws === "special:scratchpad" || ws.indexOf("special:") === 0);
    var keyStr = isScratchpad ? "SUPER + S" : ("SUPER + " + ws);
    var badgeStr = isScratchpad ? "Scratchpad" : ("WS " + ws);
    var titleStr = "Switch to " + other.info.label + (isScratchpad ? " (Scratchpad)" : (" (Workspace " + ws + ")"));
    var actionStr = isScratchpad
      ? "hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"scratchpad\")'"
      : ("hyprctl dispatch " + shellQuote("hl.dsp.focus({ window = \"address:" + other.client.address + "\" })"));

    sections.openTasks.push({
      key: keyStr,
      title: titleStr,
      desc: truncateTitle(other.client.title, other.info.label),
      icon: other.info.icon,
      badge: badgeStr,
      action: actionStr
    });
  }

  // Fast Navigation & Cycling
  if (clients.length > 1) {
    sections.openTasks.push({
      key: "ALT + TAB",
      title: "Cycle Next Window",
      desc: "Fast cycle through all open windows",
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
  }

  // 3. ACTIVE WINDOW ACTIONS & LAYOUT
  if (activeWin && activeWin.address) {
    var isFloat = activeWin.floating === true;
    var isFull = (activeWin.fullscreen !== undefined && activeWin.fullscreen !== 0);
    var appName = curApp.label || "Window";

    sections.currentWindow.push({
      key: "SUPER + F",
      title: isFull ? "Exit Fullscreen" : "Full Screen " + appName,
      desc: isFull ? "Restore standard tiled workspace layout" : "Strip window borders and top bar for distraction-free view",
      icon: "󰊓",
      badge: isFull ? "Fullscreen" : "Tiled",
      action: "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"fullscreen\" })'"
    });

    sections.currentWindow.push({
      key: "SUPER + ALT + F",
      title: "Full Width (Maximized)",
      desc: "Fill screen workspace while keeping top status bar visible",
      icon: "󰹑",
      badge: "Maximize",
      action: "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"maximized\" })'"
    });

    sections.currentWindow.push({
      key: "SUPER + T",
      title: isFloat ? "Tile Window Back" : "Float Window",
      desc: isFloat ? "Snap window back into auto-tiling grid" : "Float freely over other windows",
      icon: "󰉦",
      badge: isFloat ? "Floating" : "Tile",
      action: "hyprctl dispatch 'hl.dsp.window.float({ action = \"toggle\" })'"
    });

    sections.currentWindow.push({
      key: "SUPER + J",
      title: "Toggle Split Orientation",
      desc: "Switch next tile between horizontal & vertical",
      icon: "󰤉",
      badge: "Split",
      action: "hyprctl dispatch 'hl.dsp.layout(\"togglesplit\")'"
    });

    sections.currentWindow.push({
      key: "SUPER + ALT + S",
      title: "Send to Scratchpad",
      desc: "Hide active window into background scratchpad",
      icon: "󰖮",
      badge: "Scratchpad",
      action: "hyprctl dispatch 'hl.dsp.window.move({ workspace = \"special:scratchpad\", follow = false })'"
    });

    sections.currentWindow.push({
      key: "SUPER + W",
      title: "Close " + appName,
      desc: "Cleanly close the active window",
      icon: "󰅖",
      badge: "Close",
      action: "hyprctl dispatch 'hl.dsp.window.close()'"
    });
  }

  // 4. ESSENTIAL SYSTEM NAVIGATION TOOLS
  sections.essentialTools.push({
    key: "SUPER + S",
    title: "Toggle Scratchpad",
    desc: "Summon or hide drop-down workspace overlay",
    icon: "󰖮",
    badge: "Tool",
    action: "hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"scratchpad\")'"
  });

  sections.essentialTools.push({
    key: "SUPER + SPACE",
    title: "Application Menu",
    desc: "Search and launch any application or system utility",
    icon: "󰍜",
    badge: "Menu",
    action: "omarchy-menu toggle"
  });

  sections.essentialTools.push({
    key: "SUPER + RETURN",
    title: "Launch Terminal",
    desc: "Open a new terminal window",
    icon: "󰞷",
    badge: "Terminal",
    action: "omarchy-launch-terminal"
  });

  sections.essentialTools.push({
    key: "SUPER + SHIFT + F",
    title: "Open File Manager",
    desc: "Browse files and directories",
    icon: "󰉋",
    badge: "Files",
    action: "omarchy-launch-file-manager"
  });

  sections.essentialTools.push({
    key: "SUPER + CTRL + V",
    title: "Clipboard History",
    desc: "Browse and re-paste previous clipboard items",
    icon: "󰅌",
    badge: "Clipboard",
    action: "omarchy-shell shell summon omarchy.clipboard '{}'"
  });

  sections.essentialTools.push({
    key: "PRINT",
    title: "Screenshot Region",
    desc: "Capture interactive selection to clipboard",
    icon: "󰹑",
    badge: "Capture",
    action: "omarchy-capture-screenshot"
  });

  return sections;
}

// -------------------------------------------------------------
// UNIVERSAL SEARCH (OPEN WINDOWS + SYSTEM SHORTCUT CATALOG)
// -------------------------------------------------------------

function searchAll(query, activeWin, allClients, allCatalog) {
  if (!query) return [];
  var q = String(query).toLowerCase().trim();
  var scoredResults = [];
  var seenActions = {};

  var curAddr = activeWin ? activeWin.address : "";
  var clients = Array.isArray(allClients) ? allClients : [];

  var qNorm = q.replace(/\s*\+\s*/g, "+").replace(/\s+/g, " ");
  var qWithPlus = q.replace(/\s+/g, "+");
  var qAlpha = q.replace(/[^a-z0-9]/g, "");
  var tokens = q.split(/[\s\+]+/).filter(function(t) { return t.length > 0; });

  // 1. Search Open Windows First (High Priority)
  for (var i = 0; i < clients.length; i++) {
    var c = clients[i];
    var info = detectAppInfo(c.class, c.title);
    var t = String(c.title || "").toLowerCase();
    var cls = String(c.class || "").toLowerCase();
    var lbl = info.label.toLowerCase();
    var ws = String(c.workspace ? c.workspace.name : "");
    var isScratchpad = (ws === "special:scratchpad" || ws.indexOf("special:") === 0);

    var isCurrent = (c.address === curAddr);
    var switchAction = isScratchpad
      ? "hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"scratchpad\")'"
      : ("hyprctl dispatch " + shellQuote("hl.dsp.focus({ window = \"address:" + c.address + "\" })"));

    var score = 0;
    var combinedWin = (lbl + " " + t + " " + cls + " " + ws).toLowerCase();

    if (lbl === q || t === q) {
      score += 2600;
    } else if (lbl.indexOf(q) === 0) {
      score += 2200;
    } else if (lbl.indexOf(q) !== -1) {
      score += 1800;
    } else if (t.indexOf(q) !== -1) {
      score += 1400;
    } else if (qAlpha.length >= 3 && (lbl.replace(/[^a-z0-9]/g, "").indexOf(qAlpha) !== -1 || t.replace(/[^a-z0-9]/g, "").indexOf(qAlpha) !== -1)) {
      score += 1200;
    } else if (tokens.length > 0) {
      var allMatch = true;
      for (var tk = 0; tk < tokens.length; tk++) {
        if (combinedWin.indexOf(tokens[tk]) === -1) {
          allMatch = false;
          break;
        }
      }
      if (allMatch) score += 900;
    }

    if (score > 0) {
      seenActions[switchAction] = true;
      scoredResults.push({
        score: score,
        item: {
          key: isCurrent ? "Active" : (isScratchpad ? "SUPER + S" : ("SUPER + " + ws)),
          title: "Switch to " + info.label + (isCurrent ? " (Current)" : (isScratchpad ? " (Scratchpad)" : (" (Workspace " + ws + ")"))),
          desc: truncateTitle(c.title, info.label),
          icon: info.icon,
          category: "window",
          badge: isCurrent ? "Focused" : (isScratchpad ? "Scratchpad" : ("WS " + ws)),
          action: switchAction,
          isOpenWindow: true
        }
      });
    }
  }

  // 2. Search Shortcut Catalog
  var catalog = Array.isArray(allCatalog) ? allCatalog : [];
  for (var j = 0; j < catalog.length; j++) {
    var item = catalog[j];
    var d = String(item.desc || "").toLowerCase();
    var k = String(item.key || "").toLowerCase();
    var cat = String(item.category || "").toLowerCase();
    var kNorm = k.replace(/\s*\+\s*/g, "+").replace(/\s+/g, " ");
    var kTokens = k.split(/[\s\+]+/).filter(function(t) { return t.length > 0; });
    var dTokens = d.split(/[\s\-_]+/).filter(function(t) { return t.length > 0; });

    var itemScore = 0;

    // Exact key match
    if (kNorm === qNorm || kNorm === qWithPlus) {
      itemScore += 3000;
    } else if (kNorm.indexOf(qNorm) !== -1 || kNorm.indexOf(qWithPlus) !== -1) {
      itemScore += 1500;
    }

    // Exact or starting title match
    if (d === q || d.replace(/[^a-z0-9]/g, "") === qAlpha) {
      itemScore += 2000;
    } else if (d.indexOf(q) === 0) {
      itemScore += 1200;
    } else if (d.indexOf(q) !== -1) {
      itemScore += 700;
    }

    // Alpha merged match (e.g. "fullscreen" -> "full screen")
    if (qAlpha.length >= 3) {
      var dAlpha = d.replace(/[^a-z0-9]/g, "");
      if (dAlpha.indexOf(qAlpha) === 0) {
        itemScore += 900;
      } else if (dAlpha.indexOf(qAlpha) !== -1) {
        itemScore += 450;
      }
    }

    // Token matching
    if (tokens.length > 0) {
      var allTokensMatch = true;
      var tokenScore = 0;
      for (var t = 0; t < tokens.length; t++) {
        var tok = tokens[t];
        var matchedTok = false;

        // If single char token (like "f", "1", "k")
        if (tok.length === 1) {
          if (kTokens.indexOf(tok) !== -1) {
            matchedTok = true;
            tokenScore += 350;
          } else {
            for (var dt = 0; dt < dTokens.length; dt++) {
              if (dTokens[dt].indexOf(tok) === 0) {
                matchedTok = true;
                tokenScore += 120;
                break;
              }
            }
          }
        } else {
          // Multichar token (e.g. "super", "move", "workspace")
          if (kNorm.indexOf(tok) !== -1) {
            matchedTok = true;
            tokenScore += 250;
          } else if (d.indexOf(tok) !== -1) {
            matchedTok = true;
            tokenScore += 180;
          } else if (cat.indexOf(tok) !== -1) {
            matchedTok = true;
            tokenScore += 80;
          }
        }

        if (!matchedTok) {
          allTokensMatch = false;
          break;
        }
      }

      if (allTokensMatch) {
        itemScore += tokenScore;
      }
    }

    if (itemScore > 0) {
      if (item.action && seenActions[item.action]) continue;
      // Slight bonus for more concise descriptions on direct matches
      itemScore -= Math.min(80, d.length);

      scoredResults.push({
        score: itemScore,
        item: {
          key: item.key,
          title: item.desc,
          desc: "Category: " + item.category.toUpperCase(),
          icon: item.icon,
          category: item.category,
          badge: item.category,
          action: item.action,
          isOpenWindow: false
        }
      });
    }
  }

  scoredResults.sort(function(a, b) {
    return b.score - a.score;
  });

  return scoredResults.map(function(s) {
    return s.item;
  });
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
  if (k === "SUPER + S") return "Toggle Scratchpad";
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

  var catMap = {};
  for (var i = 0; i < catalog.length; i++) {
    var cItem = catalog[i];
    catMap[normalizeKey(cItem.key)] = cItem;
  }

  var list = [];
  var seenKeys = {};

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

  return candidates.slice(0, 5);
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
      id: "scratchpad",
      title: "Toggle Scratchpad",
      prompt: "Summon or dismiss your quick-access floating workspace",
      targetKey: "SUPER + S",
      action: "hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"scratchpad\")'",
      icon: "󰖮",
      difficulty: "Easy",
      xp: 15
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
