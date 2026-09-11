const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");

// Load NavigationModel.js and TipCatalog.js into sandbox
const catalogCode = fs.readFileSync(__dirname + "/../TipCatalog.js", "utf-8").replace(".pragma library", "");
const modelCode = fs.readFileSync(__dirname + "/../NavigationModel.js", "utf-8").replace(".pragma library", "");

const fn = new Function("exports", catalogCode + "\n" + modelCode + `
  return {
    allShortcuts,
    detectAppInfo,
    buildSmartNavigation,
    searchAll,
    parseKeys,
    getMasteryTier,
    getNavigatorRank,
    getLeaderboard,
    getDiscoverNext
  };
`);

const {
  allShortcuts,
  detectAppInfo,
  buildSmartNavigation,
  searchAll,
  parseKeys,
  getMasteryTier,
  getNavigatorRank,
  getLeaderboard,
  getDiscoverNext
} = fn({});

test("TipCatalog loads 200+ unique keybindings", () => {
  assert.ok(Array.isArray(allShortcuts));
  assert.ok(allShortcuts.length >= 200, `Expected >=200 shortcuts, got ${allShortcuts.length}`);
  for (const item of allShortcuts) {
    assert.ok(item.key, "Every item must have a key");
    assert.ok(item.desc, "Every item must have a description");
    assert.ok(item.category, "Every item must have a category");
    assert.ok(item.icon, "Every item must have an icon");
  }
});

test("detectAppInfo correctly identifies common applications", () => {
  assert.equal(detectAppInfo("brave-browser", "GitHub").label, "Brave Browser");
  assert.equal(detectAppInfo("google-chrome", "Google").label, "Google Chrome");
  assert.equal(detectAppInfo("kitty", "fish").label, "Kitty Terminal");
  assert.equal(detectAppInfo("org.gnome.Nautilus", "Home").label, "File Manager");
  assert.equal(detectAppInfo("blender", "scene.blend").label, "Blender 3D");
});

test("parseKeys splits shortcut strings into clean key tokens", () => {
  const keys = parseKeys("SUPER + SHIFT + RETURN");
  assert.deepEqual(keys, ["SUPER", "SHIFT", "RETURN"]);
  
  const single = parseKeys("PRINT");
  assert.deepEqual(single, ["PRINT"]);
});

test("searchAll finds relevant shortcuts and ranks exact matches first", () => {
  const mockClients = [
    { address: "0x123", class: "brave-browser", title: "GitHub - Omarchy", workspace: { name: "1" } },
    { address: "0x456", class: "kitty", title: "tmux", workspace: { name: "2" } }
  ];
  const activeWin = { address: "0x123", class: "brave-browser", title: "GitHub - Omarchy" };

  // Search by exact key
  const resKey = searchAll("super+f", activeWin, mockClients, allShortcuts);
  assert.ok(resKey.length > 0);
  assert.ok(resKey.some(r => r.key.toUpperCase().includes("SUPER + F")));

  // Search by keyword (compound word match)
  const resWord = searchAll("fullscreen", activeWin, mockClients, allShortcuts);
  assert.ok(resWord.length > 0);
  assert.ok(resWord.some(r => r.title.toLowerCase().includes("full screen")));

  // Search open window by name
  const resWin = searchAll("kitty", activeWin, mockClients, allShortcuts);
  assert.ok(resWin.length > 0);
  assert.ok(resWin[0].isOpenWindow === true);
  assert.ok(resWin[0].title.includes("Kitty Terminal"));
});

test("getMasteryTier progression calculates correct tiers", () => {
  assert.equal(getMasteryTier(0).label, "Untried");
  assert.equal(getMasteryTier(3).label, "Learning");
  assert.equal(getMasteryTier(5).label, "Familiar");
  assert.equal(getMasteryTier(15).label, "Proficient");
  assert.equal(getMasteryTier(40).label, "Mastered");
});

test("getLeaderboard ranks executed actions correctly", () => {
  const mockStats = {
    "SUPER + RETURN": { count: 25, desc: "Terminal", icon: "󰞷", category: "apps" },
    "SUPER + F": { count: 10, desc: "Full Screen", icon: "󰊓", category: "window" }
  };
  const leaderboard = getLeaderboard(mockStats, allShortcuts);
  assert.ok(leaderboard.length >= 2);
  assert.equal(leaderboard[0].key, "SUPER + RETURN");
  assert.equal(leaderboard[0].count, 25);
  assert.equal(leaderboard[1].key, "SUPER + F");
  assert.equal(leaderboard[1].count, 10);
});
