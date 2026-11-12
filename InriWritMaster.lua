-- Inri's WritMaster
-- Cheapest-reputation planner for the Azeroth Commerce Authority / Durotar Supply and Logistics.
-- Prices come from Auctionator (optional). Everything is nil-safe when price data is missing.

local ADDON, WM = ...
_G.InriWritMaster = WM

local CALLER = "InriWritMaster"         -- Auctionator caller id
local GOLD = 10000
local floor, max, min, huge = math.floor, math.max, math.min, math.huge
local fmt = string.format

---------------------------------------------------------------------------
-- Colours / theme
---------------------------------------------------------------------------
local C = {
  bg      = { 0.04, 0.04, 0.05, 0.94 },
  panel   = { 0.08, 0.075, 0.07, 0.95 },
  border  = { 0.55, 0.45, 0.25, 1 },
  line    = { 0.55, 0.45, 0.25, 0.35 },
  rowAlt  = { 1, 1, 1, 0.025 },
  hover   = { 0.83, 0.69, 0.22, 0.10 },
  sel     = { 0.83, 0.69, 0.22, 0.20 },
}
local HEX = { gold = "ffd4af37", white = "ffe8e8e8", grey = "ff8a8a8a", green = "ff55d455", red = "ffd45555",
              orange = "ffe0a040", blue = "ff70a8ff" }
local function col(c, s) return "|c" .. (HEX[c] or c) .. tostring(s) .. "|r" end

local function Print(...)
  local msg = strjoin(" ", tostringall(...))
  DEFAULT_CHAT_FRAME:AddMessage(col("gold", "WritMaster") .. ": " .. msg)
end

---------------------------------------------------------------------------
-- Saved variables
---------------------------------------------------------------------------
local DEFAULTS = {
  learned = {},        -- [questID] = {name, mapID, x, y}
  recipes = {},        -- [itemID] = {yield, {{reagentID, qty}, ...}}
  vendorCost = {},     -- [itemID] = favor cost seen at a vendor
  settings = { tier = "ALL", ownedOnly = false, hideDone = false, craftOnly = false, sort = "eff", sortAsc = false, autoAH = true, autoCamp = true, minimap = true, minimapAngle = 200, tooltips = true, tipShift = true,
               vendorProf = 1, ownedWritFree = true },
  pos = nil,
}
local CHAR_DEFAULTS = { known = {} }    -- [itemID] = true for recipes this character knows

local function fill(dst, src)
  for k, v in pairs(src) do
    if type(v) == "table" then
      if type(dst[k]) ~= "table" then dst[k] = {} end
      fill(dst[k], v)
    elseif dst[k] == nil then
      dst[k] = v
    end
  end
  return dst
end

---------------------------------------------------------------------------
-- Approximate vendor buy prices for common crafting reagents (copper).
-- These are not on the AH, so craft costs use these. Edit if your vendor differs.
---------------------------------------------------------------------------
WM.VENDOR_REAGENTS = {
  [2320] = 10, [2321] = 100, [4291] = 300, [8343] = 400, [14341] = 500,     -- threads
  [3371] = 4, [3372] = 40, [8925] = 200, [18256] = 2000,                    -- vials
  [2880] = 100, [3466] = 200, [4289] = 50, [2324] = 25, [3857] = 500,       -- flux, salt, bleach, coal
  [6260] = 50, [2604] = 50, [4340] = 35, [2325] = 250, [6261] = 1000,       -- dyes
  [4342] = 2500, [4341] = 500, [2605] = 100, [10290] = 2500,
  [159] = 5, [17038] = 1000,
}

---------------------------------------------------------------------------
-- Lookups
---------------------------------------------------------------------------
WM.byQuest, WM.byWrit, WM.byItem = {}, {}, {}
for _, w in ipairs(WM.WRITS) do
  WM.byQuest[w.q] = w
  WM.byWrit[w.w] = w
  WM.byItem[w.i] = w
end

local GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
local function ItemName(id)
  if not id then return "?" end
  local name = GetItemInfo(id)
  if name then return name end
  if C_Item and C_Item.RequestLoadItemDataByID then pcall(C_Item.RequestLoadItemDataByID, id) end
  return nil
end
local function ItemLink(id)
  local _, link = GetItemInfo(id)
  return link
end
local function ItemIcon(id)
  if C_Item and C_Item.GetItemIconByID then
    local ok, icon = pcall(C_Item.GetItemIconByID, id)
    if ok and icon then return icon end
  end
  if GetItemIcon then return GetItemIcon(id) end
  return 134400
end

---------------------------------------------------------------------------
-- Money
---------------------------------------------------------------------------
local function Money(c, short)
  if not c then return col("grey", "—") end
  c = floor(c + 0.5)
  local g, s, cp = floor(c / GOLD), floor((c % GOLD) / 100), c % 100
  if g > 0 then
    if short or g >= 100 then return fmt("%s%s", col("white", g), col("gold", "g")) end
    return fmt("%s%s %s%s", col("white", g), col("gold", "g"), col("white", s), col("ffc0c0c0", "s"))
  elseif s > 0 then
    return fmt("%s%s %s%s", col("white", s), col("ffc0c0c0", "s"), col("white", cp), col("ffb87333", "c"))
  end
  return fmt("%s%s", col("white", cp), col("ffb87333", "c"))
end

---------------------------------------------------------------------------
-- Auctionator pricing (nil-safe)
---------------------------------------------------------------------------
local function HasAuctionator()
  return type(Auctionator) == "table" and type(Auctionator.API) == "table"
     and type(Auctionator.API.v1) == "table" and type(Auctionator.API.v1.GetAuctionPriceByItemID) == "function"
end
WM.HasAuctionator = HasAuctionator

local priceCache, priceCacheTime = {}, 0
local function AHPrice(id)
  if not id or not HasAuctionator() then return nil end
  local now = GetTime()
  if now - priceCacheTime > 30 then wipe(priceCache); priceCacheTime = now end
  local v = priceCache[id]
  if v ~= nil then return v or nil end
  local ok, p = pcall(Auctionator.API.v1.GetAuctionPriceByItemID, CALLER, id)
  if not ok or type(p) ~= "number" or p <= 0 then p = false end
  priceCache[id] = p
  return p or nil
end
WM.AHPrice = AHPrice

local function AHAge(id)
  if not HasAuctionator() or type(Auctionator.API.v1.GetAuctionAgeByItemID) ~= "function" then return nil end
  local ok, d = pcall(Auctionator.API.v1.GetAuctionAgeByItemID, CALLER, id)
  if ok and type(d) == "number" then return d end
end

-- Reagent price: vendor price if it is a vendor reagent, else AH.
local function ReagentPrice(id)
  local v = WM.VENDOR_REAGENTS[id]
  local ah = AHPrice(id)
  if v and ah then return min(v, ah), "vendor" end
  if v then return v, "vendor" end
  return ah, "AH"
end

-- Craft cost per one crafted item, or nil if any reagent is unpriced.
local function CraftCost(itemID)
  local r = WM.db.recipes[itemID]
  if not r or not r[2] then return nil end
  local total, parts = 0, {}
  for _, rg in ipairs(r[2]) do
    local p, src = ReagentPrice(rg[1])
    parts[#parts + 1] = { rg[1], rg[2], p, src }
    if not p then return nil, parts end
    total = total + p * rg[2]
  end
  return total / max(1, r[1] or 1), parts
end

---------------------------------------------------------------------------
-- Player state: bags, reputation, favor, faction
---------------------------------------------------------------------------
WM.owned = {}
local function ScanBags()
  wipe(WM.owned)
  local getSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
  local getID = (C_Container and C_Container.GetContainerItemID) or GetContainerItemID
  local getInfo = C_Container and C_Container.GetContainerItemInfo
  if not getSlots or not getID then return end
  local lastBag = (NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4)
  for bag = 0, lastBag do
    local n = getSlots(bag) or 0
    for slot = 1, n do
      local id = getID(bag, slot)
      if id then
        local count = 1
        if getInfo then
          local info = getInfo(bag, slot)
          if type(info) == "table" and info.stackCount then count = info.stackCount end
        elseif GetContainerItemInfo then
          local _, c = GetContainerItemInfo(bag, slot)
          count = c or 1
        end
        WM.owned[id] = (WM.owned[id] or 0) + count
      end
    end
  end
end

local function PlayerFaction()
  local f = UnitFactionGroup("player")
  if f ~= "Horde" then f = "Alliance" end
  return f
end

local function GetRep()
  local fid = WM.FACTION[PlayerFaction()]
  if C_Reputation and C_Reputation.GetFactionDataByID then
    local ok, d = pcall(C_Reputation.GetFactionDataByID, fid)
    if ok and type(d) == "table" and d.name then
      return d.name, d.reaction, d.currentStanding, d.currentReactionThreshold, d.nextReactionThreshold
    end
  end
  if GetFactionInfoByID then
    local ok, name, _, standing, bMin, bMax, val = pcall(GetFactionInfoByID, fid)
    if ok and name then return name, standing, val, bMin, bMax end
  end
  return nil
end

local function GetFavor()
  if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
    local ok, info = pcall(C_CurrencyInfo.GetCurrencyInfo, WM.FAVOR_CURRENCY)
    if ok and type(info) == "table" then return info.quantity or 0, info.iconFileID end
  end
  return nil
end

local function IsDoneToday(q)
  if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
    local ok, v = pcall(C_QuestLog.IsQuestFlaggedCompleted, q)
    return ok and v
  end
  return false
end

-- Today's plan: writs picked for this daily reset (per character)
local function PlanKey()
  local sec
  if C_DateAndTime and C_DateAndTime.GetSecondsUntilDailyReset then
    local ok, v = pcall(C_DateAndTime.GetSecondsUntilDailyReset); if ok then sec = v end
  end
  if not sec and GetQuestResetTime then sec = GetQuestResetTime() end
  if not sec then return date("%Y%m%d") end
  return math.floor((time() + sec) / 3600 + 0.5)
end
function WM.Plan()
  local c = WM.cdb
  if not c then return {} end
  local k = PlanKey()
  if not c.plan or c.plan.key ~= k then c.plan = { key = k, q = {}, c = {} } end
  return c.plan.q
end
function WM.CratePlan()
  local c = WM.cdb
  if not c then return {} end
  WM.Plan()
  c.plan.c = c.plan.c or {}
  return c.plan.c
end
function WM.TogglePlan(q)
  local p = WM.Plan()
  if p[q] then p[q] = nil else p[q] = true end
  return p[q]
end
function WM.PlanCount() local n = 0 for _ in pairs(WM.Plan()) do n = n + 1 end return n end
function WM.CratePlanCount() local n = 0 for _ in pairs(WM.CratePlan()) do n = n + 1 end return n end
local function ShopLabel()
  local n = WM.PlanCount() + WM.CratePlanCount()
  return n > 0 and ("Shop list (" .. n .. ")") or "Shop list"
end
local function PlanFor(tab) return tab == 2 and WM.CratePlan() or WM.Plan() end

local function Customer(w)
  local l = WM.db.learned[w.q]
  if l and l[2] and not (l.marker and w.c) then return l[1], l[2], l[3], l[4], true end
  if w.c then return w.c[1], w.c[2], w.c[3], w.c[4], false end
  return nil
end

local function ZoneName(map)
  if not map then return nil end
  if WM.ZONES[map] then return WM.ZONES[map] end
  if C_Map and C_Map.GetMapInfo then
    local info = C_Map.GetMapInfo(map)
    if info and info.name then WM.ZONES[map] = info.name; return info.name end
  end
  return "Map " .. map
end

---------------------------------------------------------------------------
-- Writ evaluation
---------------------------------------------------------------------------
local function EvalWrit(w)
  local e = { w = w }
  -- writ cost
  local ownedWrit = (WM.owned[w.w] or 0) > 0
  e.owned = ownedWrit
  if ownedWrit and WM.db.settings.ownedWritFree then
    e.writCost, e.writSrc = 0, "in bags"
  else
    local named = AHPrice(w.w)
    local sealed = AHPrice(WM.SEALED[w.t])
    if named then
      e.writCost, e.writSrc = named, "AH: named writ"
    elseif sealed then
      e.writCost, e.writSrc = sealed, "AH: sealed writ (random order)"
    end
  end
  -- item cost
  local qty = w.n or 1
  local ah = AHPrice(w.i)
  local known = WM.cdb.known[w.i]
  local craft, parts = CraftCost(w.i)
  e.parts = parts
  e.known = known
  local haveItem = WM.owned[w.i] or 0
  if haveItem >= qty then
    e.itemCost, e.itemSrc = 0, "in bags"
  else
    local need = qty - haveItem
    local ahTotal = ah and ah * need
    local crTotal = (known and craft) and craft * need or nil
    if WM.db.settings.craftOnly and crTotal then ahTotal = nil end
    if ahTotal and crTotal then
      if crTotal < ahTotal then e.itemCost, e.itemSrc = crTotal, "craft" else e.itemCost, e.itemSrc = ahTotal, "AH" end
    elseif crTotal then
      e.itemCost, e.itemSrc = crTotal, "craft"
    elseif ahTotal then
      e.itemCost, e.itemSrc = ahTotal, "AH"
    end
    e.ahTotal, e.crTotal = ahTotal, crTotal
  end
  -- total
  if e.itemCost and e.writCost then
    e.total, e.complete = e.itemCost + e.writCost, true
  elseif e.itemCost or e.writCost then
    e.total, e.complete = (e.itemCost or 0) + (e.writCost or 0), false
  end
  if e.total then
    e.cpr = e.total / w.r                                -- copper per 1 rep
    e.eff = e.total > 0 and (w.r / (e.total / GOLD)) or huge   -- rep per gold
  end
  e.done = IsDoneToday(w.q)
  return e
end

local function WritRows()
  local s = WM.db.settings
  local faction = PlayerFaction()
  local rows = {}
  for _, w in ipairs(WM.WRITS) do
    if not (w.ao and faction == "Horde") then
      if s.tier == "ALL" or s.tier == w.t then
        local e = EvalWrit(w)
        if (not s.ownedOnly or e.owned) and (not s.hideDone or not e.done) and (not s.planOnly or WM.Plan()[w.q]) then
          rows[#rows + 1] = e
        end
      end
    end
  end
  local key, asc = s.sort, s.sortAsc
  local function rank(e) return e.total == nil and 2 or (e.complete and 0 or 1) end
  table.sort(rows, function(a, b)
    if key == "eff" or key == "total" then
      local ra, rb = rank(a), rank(b)
      if ra ~= rb then return ra < rb end
      if a.cpr and b.cpr and a.cpr ~= b.cpr then
        if key == "eff" then return (a.cpr < b.cpr) ~= asc end
        return (a.total < b.total) ~= (not asc)
      end
    elseif key == "name" then
      local na, nb = ItemName(a.w.i) or "", ItemName(b.w.i) or ""
      if na ~= nb then return (na < nb) ~= (not asc) end
    elseif key == "tier" then
      if a.w.r ~= b.w.r then return (a.w.r < b.w.r) ~= (not asc) end
    elseif key == "prof" then
      if a.w.p ~= b.w.p then return (a.w.p < b.w.p) ~= (not asc) end
    elseif key == "zone" then
      local _, ma = Customer(a.w); local _, mb = Customer(b.w)
      local za, zb = ZoneName(ma) or "~", ZoneName(mb) or "~"
      if za ~= zb then return (za < zb) ~= (not asc) end
    end
    return a.w.q < b.w.q
  end)
  return rows
end

---------------------------------------------------------------------------
-- Waypoints & routing
---------------------------------------------------------------------------
function WM:Waypoint(map, x, y, title)
  if not (map and x and y) then Print("No coordinates known for that target yet."); return end
  local zone = ZoneName(map) or "?"
  if TomTom and TomTom.AddWaypoint then
    pcall(TomTom.AddWaypoint, TomTom, map, x / 100, y / 100, { title = title, persistent = false, minimap = true, world = true })
  elseif C_Map and C_Map.CanSetUserWaypointOnMap and C_Map.CanSetUserWaypointOnMap(map) and UiMapPoint then
    local ok = pcall(function()
      C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(map, x / 100, y / 100))
      if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
    end)
    if not ok then Print("Could not place a map pin here.") end
  end
  Print(fmt("%s — %s %s", col("white", title or "Target"), col("gold", zone), col("white", fmt("(%.1f, %.1f)", x, y))))
end

local function WorldPos(map, x, y)
  if not (C_Map and C_Map.GetWorldPosFromMapPos and CreateVector2D) then return nil end
  local ok, cont, pos = pcall(C_Map.GetWorldPosFromMapPos, map, CreateVector2D(x / 100, y / 100))
  if ok and cont and pos then return cont, pos.x, pos.y end
end

local function PlayerWorld()
  if not (C_Map and C_Map.GetBestMapForUnit) then return nil end
  local map = C_Map.GetBestMapForUnit("player")
  if not map then return nil end
  local p = C_Map.GetPlayerMapPosition(map, "player")
  if not p then return nil end
  local px, py = p:GetXY()
  return WorldPos(map, px * 100, py * 100)
end

function WM:Route()
  ScanBags()
  local stops, unknown = {}, {}
  for _, w in ipairs(WM.WRITS) do
    if (WM.owned[w.w] or 0) > 0 and not IsDoneToday(w.q) then
      local name, map, x, y = Customer(w)
      if map then
        local key = name .. map
        stops[key] = stops[key] or { name = name, map = map, x = x, y = y, items = {} }
        table.insert(stops[key].items, w)
      else
        unknown[#unknown + 1] = w
      end
    end
  end
  local list = {}
  for _, s in pairs(stops) do list[#list + 1] = s end
  if #list == 0 and #unknown == 0 then Print("No undelivered Craftsman's Writs in your bags.") return end

  -- nearest-neighbour ordering from the player's position (falls back to zone grouping)
  local cont, cx, cy = PlayerWorld()
  local ordered = {}
  if cont then
    for _, s in ipairs(list) do s.cont, s.wx, s.wy = WorldPos(s.map, s.x, s.y) end
    while #list > 0 do
      local bi, bd = 1, huge
      for i, s in ipairs(list) do
        local d
        if s.cont and s.cont == cont then d = (s.wx - cx) ^ 2 + (s.wy - cy) ^ 2
        elseif s.cont then d = 1e12 else d = 1e13 end
        if d < bd then bi, bd = i, d end
      end
      local s = table.remove(list, bi)
      ordered[#ordered + 1] = s
      if s.cont then cont, cx, cy = s.cont, s.wx, s.wy end
    end
  else
    table.sort(list, function(a, b) return (ZoneName(a.map) or "") < (ZoneName(b.map) or "") end)
    ordered = list
  end

  Print(col("gold", "Delivery route") .. fmt(" (%d stops)", #ordered))
  local lastZone
  for i, s in ipairs(ordered) do
    local zone = ZoneName(s.map)
    if zone ~= lastZone then DEFAULT_CHAT_FRAME:AddMessage("  " .. col("gold", zone)); lastZone = zone end
    local names = {}
    for _, w in ipairs(s.items) do
      local have = (WM.owned[w.i] or 0) >= (w.n or 1)
      names[#names + 1] = col(have and "green" or "red", ItemName(w.i) or ("item " .. w.i))
    end
    DEFAULT_CHAT_FRAME:AddMessage(fmt("   %d. %s (%.1f, %.1f): %s", i, col("white", s.name), s.x, s.y, table.concat(names, ", ")))
  end
  for _, w in ipairs(unknown) do
    DEFAULT_CHAT_FRAME:AddMessage("   ? " .. col("orange", ItemName(w.i) or w.i) .. col("grey", " — customer not mapped yet; follow the quest marker"))
  end
  if ordered[1] then self:Waypoint(ordered[1].map, ordered[1].x, ordered[1].y, ordered[1].name) end
end

---------------------------------------------------------------------------
-- Learning: customers, recipes, vendor costs
---------------------------------------------------------------------------
local function LearnCustomer()
  local q = GetQuestID and GetQuestID()
  if not q or not WM.byQuest[q] then return end
  local name = UnitName("questnpc") or UnitName("npc") or UnitName("target")
  local map = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  if not (name and map) then return end
  local p = C_Map.GetPlayerMapPosition(map, "player")
  if not p then return end
  local x, y = p:GetXY()
  local w = WM.byQuest[q]
  local old = WM.db.learned[q]
  WM.db.learned[q] = { name, map, floor(x * 1000 + 0.5) / 10, floor(y * 1000 + 0.5) / 10 }
  if not w.c and not old then
    Print(fmt("Learned customer for %s: %s in %s.", col("white", ItemName(w.i) or q), col("gold", name), ZoneName(map)))
  end
end

-- Read customer positions from quest map markers for writs that are in the quest log.
local ZONE_MAPS = {}
for m = 1411, 1458 do ZONE_MAPS[#ZONE_MAPS + 1] = m end
local function LearnFromQuestLog()
  if not (C_QuestLog and C_QuestLog.GetQuestsOnMap and C_QuestLog.GetLogIndexForQuestID) then return 0 end
  local want, any = {}, false
  for q, w in pairs(WM.byQuest) do
    if not WM.db.learned[q] and C_QuestLog.GetLogIndexForQuestID(q) then want[q] = w; any = true end
  end
  if not any then return 0 end
  local n = 0
  for _, map in ipairs(ZONE_MAPS) do
    local ok, quests = pcall(C_QuestLog.GetQuestsOnMap, map)
    if ok and type(quests) == "table" then
      for _, info in ipairs(quests) do
        local w = want[info.questID]
        if w and info.x and info.y then
          local known = w.c and w.c[1]
          WM.db.learned[info.questID] = { known or "Quest marker", map, floor(info.x * 1000 + 0.5) / 10, floor(info.y * 1000 + 0.5) / 10, marker = not known }
          want[info.questID] = nil
          n = n + 1
        end
      end
    end
  end
  if n > 0 then Print(fmt("Mapped %d writ customer(s) from your quest log.", n)) end
  return n
end
WM.LearnFromQuestLog = LearnFromQuestLog

local function ScanTradeSkill()
  local found = 0
  local db, known = WM.db.recipes, WM.cdb.known
  -- modern API
  if C_TradeSkillUI and C_TradeSkillUI.GetAllRecipeIDs and C_TradeSkillUI.GetRecipeSchematic then
    local ok, ids = pcall(C_TradeSkillUI.GetAllRecipeIDs)
    if ok and type(ids) == "table" and #ids > 0 then
      for _, rid in ipairs(ids) do
        local okI, info = pcall(C_TradeSkillUI.GetRecipeInfo, rid)
        local okS, sch = pcall(C_TradeSkillUI.GetRecipeSchematic, rid, false)
        if okS and type(sch) == "table" and sch.outputItemID and WM.byItem[sch.outputItemID] then
          local reagents = {}
          for _, slot in ipairs(sch.reagentSlotSchematics or {}) do
            local basic = (slot.reagentType == nil) or (Enum and Enum.CraftingReagentType and slot.reagentType == Enum.CraftingReagentType.Basic) or slot.reagentType == 1
            local first = slot.reagents and slot.reagents[1]
            if basic and first and first.itemID then reagents[#reagents + 1] = { first.itemID, slot.quantityRequired or 1 } end
          end
          db[sch.outputItemID] = { sch.quantityMin or 1, reagents }
          if okI and type(info) == "table" and info.learned then known[sch.outputItemID] = true; found = found + 1 end
        end
      end
      return found
    end
  end
  -- classic API
  if GetNumTradeSkills and GetTradeSkillItemLink then
    for i = 1, (GetNumTradeSkills() or 0) do
      local _, kind = GetTradeSkillInfo(i)
      if kind ~= "header" and kind ~= "subheader" then
        local link = GetTradeSkillItemLink(i)
        local id = link and tonumber(link:match("item:(%d+)"))
        if id and WM.byItem[id] then
          local reagents = {}
          for j = 1, (GetTradeSkillNumReagents(i) or 0) do
            local _, _, count = GetTradeSkillReagentInfo(i, j)
            local rl = GetTradeSkillReagentItemLink(i, j)
            local rid = rl and tonumber(rl:match("item:(%d+)"))
            if rid then reagents[#reagents + 1] = { rid, count or 1 } end
          end
          local made = GetTradeSkillNumMade and GetTradeSkillNumMade(i) or 1
          db[id] = { made or 1, reagents }
          known[id] = true
          found = found + 1
        end
      end
    end
  end
  return found
end

local function ScanMerchant()
  if not GetMerchantNumItems then return end
  local n = 0
  for i = 1, GetMerchantNumItems() do
    local link = GetMerchantItemLink(i)
    local id = link and tonumber(link:match("item:(%d+)"))
    if id and GetMerchantItemCostInfo then
      for j = 1, (GetMerchantItemCostInfo(i) or 0) do
        local _, value, clink, cname = GetMerchantItemCostItem(i, j)
        local isFavor = (clink and clink:find("currency:" .. WM.FAVOR_CURRENCY)) or (cname and cname:find("Merchant's Favor"))
        if isFavor and value then
          if WM.db.vendorCost[id] ~= value then n = n + 1 end
          WM.db.vendorCost[id] = value
        end
      end
    end
  end
  if n > 0 then Print(fmt("Updated %d Merchant's Favor prices from this vendor.", n)) end
end

---------------------------------------------------------------------------
-- UI helpers
---------------------------------------------------------------------------
local BACKDROP = {
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 },
}
local FLAT = { bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 }

local function Skin(f, bg, border, flat)
  if not f.SetBackdrop then Mixin(f, BackdropTemplateMixin) end
  f:SetBackdrop(flat and FLAT or BACKDROP)
  f:SetBackdropColor(unpack(bg or C.bg))
  f:SetBackdropBorderColor(unpack(border or C.border))
end

local function Button(parent, text, w, h, onClick)
  local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
  b:SetSize(w, h or 18)
  Skin(b, { 0.10, 0.09, 0.08, 1 }, { 0.40, 0.33, 0.18, 1 }, true)
  b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  b.text:SetPoint("CENTER")
  b.text:SetText(text)
  b:SetScript("OnEnter", function(s) s:SetBackdropBorderColor(0.83, 0.69, 0.22, 1) end)
  b:SetScript("OnLeave", function(s) if not s.active then s:SetBackdropBorderColor(0.40, 0.33, 0.18, 1) end end)
  b:SetScript("OnClick", onClick)
  function b:SetActive(on)
    self.active = on
    self.text:SetTextColor(on and 1 or 0.9, on and 0.82 or 0.9, on and 0.25 or 0.9)
    self:SetBackdropBorderColor(on and 0.83 or 0.40, on and 0.69 or 0.33, on and 0.22 or 0.18, 1)
    self:SetBackdropColor(on and 0.18 or 0.10, on and 0.15 or 0.09, on and 0.08 or 0.08, 1)
  end
  return b
end

local function Line(parent, y, x1, x2)
  local t = parent:CreateTexture(nil, "ARTWORK")
  t:SetColorTexture(unpack(C.line))
  t:SetHeight(1)
  t:SetPoint("TOPLEFT", x1 or 8, y)
  t:SetPoint("TOPRIGHT", x2 or -8, y)
  return t
end

---------------------------------------------------------------------------
-- Generic list widget
---------------------------------------------------------------------------
local ROW_H, VISIBLE = 18, 17

local function CreateList(parent, top, bottom)
  local L = CreateFrame("Frame", nil, parent)
  L:SetPoint("TOPLEFT", 8, top)
  L:SetPoint("BOTTOMRIGHT", -8, bottom)
  L.offset, L.data, L.cols, L.multi = 0, {}, {}, false
  L.header = CreateFrame("Frame", nil, L)
  L.header:SetPoint("TOPLEFT"); L.header:SetPoint("TOPRIGHT", -10, 0); L.header:SetHeight(ROW_H)
  L.headCells = {}
  L.rows = {}
  for i = 1, VISIBLE do
    local r = CreateFrame("Button", nil, L)
    r:SetHeight(ROW_H)
    r:SetPoint("TOPLEFT", 0, -ROW_H * i - 2)
    r:SetPoint("TOPRIGHT", -10, -ROW_H * i - 2)
    r.bg = r:CreateTexture(nil, "BACKGROUND"); r.bg:SetAllPoints()
    r.bg:SetColorTexture(unpack(i % 2 == 0 and C.rowAlt or { 0, 0, 0, 0 }))
    r.hl = r:CreateTexture(nil, "HIGHLIGHT"); r.hl:SetAllPoints(); r.hl:SetColorTexture(unpack(C.hover))
    r.planTex = r:CreateTexture(nil, "BACKGROUND", nil, 1); r.planTex:SetAllPoints(); r.planTex:SetColorTexture(0.83, 0.69, 0.22, 0.13); r.planTex:Hide()
    r.planBar = r:CreateTexture(nil, "ARTWORK", nil, 2); r.planBar:SetPoint("TOPLEFT"); r.planBar:SetPoint("BOTTOMLEFT"); r.planBar:SetWidth(2)
    r.planBar:SetColorTexture(0.83, 0.69, 0.22, 0.95); r.planBar:Hide()
    r.selTex = r:CreateTexture(nil, "BORDER"); r.selTex:SetAllPoints(); r.selTex:SetColorTexture(unpack(C.sel)); r.selTex:Hide()
    r.icon = r:CreateTexture(nil, "ARTWORK"); r.icon:SetSize(14, 14); r.icon:SetPoint("LEFT", 2, 0)
    r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    r.cells = {}
    r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    r:SetScript("OnClick", function(self, btn) if self.item and L.onClick then L.onClick(self.item, btn) end end)
    r:SetScript("OnEnter", function(self)
      L.hoverRow = self
      local st = WM.db and WM.db.settings
      if st and st.tipShift and not IsShiftKeyDown() then return end
      if self.item and L.onEnter then L.onEnter(self, self.item) end
    end)
    r:SetScript("OnLeave", function() L.hoverRow = nil; GameTooltip:Hide() end)
    L.rows[i] = r
  end
  -- Shift pressed/released while hovering a row: show/hide its tooltip
  L:RegisterEvent("MODIFIER_STATE_CHANGED")
  L:SetScript("OnEvent", function(_, _, key, down)
    local st = WM.db and WM.db.settings
    local r = L.hoverRow
    if not (st and st.tipShift and type(r) == "table" and r:IsShown() and r:IsMouseOver() and key and key:find("SHIFT")) then return end
    if down == 1 then
      if r.item and L.onEnter then L.onEnter(r, r.item) end
    else
      GameTooltip:Hide()
    end
  end)
  -- scrollbar
  local sb = CreateFrame("Slider", nil, L, "BackdropTemplate")
  sb:SetPoint("TOPRIGHT", 0, -ROW_H - 2)
  sb:SetPoint("BOTTOMRIGHT", 0, 0)
  sb:SetWidth(8)
  Skin(sb, { 0.06, 0.06, 0.06, 1 }, { 0.25, 0.2, 0.12, 1 }, true)
  sb:SetOrientation("VERTICAL")
  local thumb = sb:CreateTexture(nil, "OVERLAY")
  thumb:SetColorTexture(0.55, 0.45, 0.25, 0.9); thumb:SetSize(6, 28)
  sb:SetThumbTexture(thumb)
  sb:SetMinMaxValues(0, 0); sb:SetValueStep(1); sb:SetObeyStepOnDrag(true)
  sb:SetScript("OnValueChanged", function(_, v) v = floor(v + 0.5); if v ~= L.offset then L.offset = v; L:Render() end end)
  L.sb = sb
  L:EnableMouseWheel(true)
  L:SetScript("OnMouseWheel", function(_, d)
    local maxOff = max(0, #L.data - VISIBLE)
    L.offset = min(maxOff, max(0, L.offset - d * 3))
    sb:SetValue(L.offset)
    L:Render()
  end)

  function L:SetColumns(cols, onSort)
    self.cols = cols
    for _, c in ipairs(self.headCells) do c:Hide() end
    local x = 0
    for i, c in ipairs(cols) do
      local h = self.headCells[i]
      if not h then
        h = CreateFrame("Button", nil, self.header)
        h.text = h:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        h.text:SetAllPoints()
        self.headCells[i] = h
      end
      h:SetSize(c.w, ROW_H); h:ClearAllPoints(); h:SetPoint("LEFT", x, 0)
      h.text:SetJustifyH(c.j or "LEFT")
      h.text:SetText(c.title)
      h:SetScript("OnClick", c.sort and onSort and function() onSort(c.sort) end or nil)
      h:Show()
      x = x + c.w
    end
    for _, r in ipairs(self.rows) do
      local cx = 0
      for i, c in ipairs(cols) do
        local fs = r.cells[i]
        if not fs then fs = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); fs:SetWordWrap(false); r.cells[i] = fs end
        fs:ClearAllPoints()
        local pad = (i == 1 and c.icon) and 20 or 2
        fs:SetPoint("LEFT", cx + pad, 0)
        fs:SetWidth(c.w - pad - 4)
        fs:SetJustifyH(c.j or "LEFT")
        fs:Show()
        cx = cx + c.w
      end
      for i = #cols + 1, #r.cells do r.cells[i]:Hide() end
    end
  end

  function L:SetData(data)
    self.data = data or {}
    local maxOff = max(0, #self.data - VISIBLE)
    if self.offset > maxOff then self.offset = maxOff end
    self.sb:SetMinMaxValues(0, maxOff)
    self.sb:SetValue(self.offset)
    if maxOff == 0 then self.sb:Hide() else self.sb:Show() end
    self:Render()
  end

  function L:Render()
    for i, r in ipairs(self.rows) do
      local item = self.data[i + self.offset]
      r.item = item
      if item then
        local cells = self.cellFn(item)
        for c = 1, #self.cols do r.cells[c]:SetText(cells[c] or "") end
        if self.cols[1] and self.cols[1].icon and cells.icon then r.icon:SetTexture(cells.icon); r.icon:Show() else r.icon:Hide() end
        r:SetAlpha(cells.dim and 0.45 or 1)
        r.planTex:SetShown(cells.planned == true); r.planBar:SetShown(cells.planned == true)
        r.selTex:SetShown((self.selected ~= nil and self.selected == item.key) or (self.multi and self.multi[item.key] == true))
        r:Show()
      else
        r:Hide()
      end
    end
  end
  return L
end

---------------------------------------------------------------------------
-- Main frame
---------------------------------------------------------------------------
local UI = {}
WM.UI = UI

-- row tooltips sit beside the window instead of on top of it
local function RowTipOwner(row)
  local f = UI.frame
  if f then
    GameTooltip:SetOwner(f, "ANCHOR_NONE")
    GameTooltip:ClearAllPoints()
    if (f:GetRight() or 0) + 320 < (UIParent:GetRight() or 99999) then
      GameTooltip:SetPoint("TOPLEFT", f, "TOPRIGHT", 4, 0)
    else
      GameTooltip:SetPoint("TOPRIGHT", f, "TOPLEFT", -4, 0)
    end
  else
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
  end
end
local W, H = 860, 486

local function SavePos(f)
  local p, _, rp, x, y = f:GetPoint()
  WM.db.pos = { p, rp, x, y }
end

local function ShortTier(t) return t == "J" and "Jour" or t == "E" and "Expert" or "Artisan" end
local TIER_COL = { J = "ff1eff00", E = "ff0070dd", A = "ffa335ee" }

local function BuildFrame()
  local f = CreateFrame("Frame", "InriWritMasterFrame", UIParent, "BackdropTemplate")
  f:SetSize(W, H)
  f:SetFrameStrata("HIGH")
  f:SetClampedToScreen(true)
  f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", function(s) s:StopMovingOrSizing(); SavePos(s) end)
  Skin(f)
  local pos = WM.db.pos
  if pos then f:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4]) else f:SetPoint("CENTER") end
  tinsert(UISpecialFrames, "InriWritMasterFrame")
  f:Hide()
  UI.frame = f

  local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 12, -10)
  title:SetText(col("gold", "Inri's") .. " " .. col("white", "WritMaster"))
  UI.status = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  UI.status:SetPoint("LEFT", title, "RIGHT", 14, -1)

  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 2, 2)
  close:SetScale(0.85)

  -- always-visible toggle: open automatically at the Auction House
  UI.btnAutoAH = Button(f, "", 78, 18, function()
    local st = WM.db.settings
    st.autoAH = not st.autoAH
    WM.UpdateAutoAH()
    if UI.tab == 4 then WM:ShowTab(4) end
  end)
  UI.btnAutoAH:SetPoint("TOPRIGHT", -32, -8)
  UI.btnAutoAH:HookScript("OnEnter", function(s) GameTooltip:SetOwner(s, "ANCHOR_BOTTOM"); GameTooltip:SetText("Auto-open at the Auction House", 1, 0.82, 0)
    GameTooltip:AddLine("When on, WritMaster opens on the Writs tab whenever you open the Auction House and closes with it. Click to switch.", 1, 1, 1, true); GameTooltip:Show() end)
  UI.btnAutoAH:HookScript("OnLeave", function() GameTooltip:Hide() end)

  UI.favor = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  UI.favor:SetPoint("TOPRIGHT", -118, -13)

  Line(f, -32)

  -- tabs
  UI.tabs = {}
  local tabNames = { "Writs", "Crates", "Vendors", "Info" }
  for i, name in ipairs(tabNames) do
    local b = Button(f, name, 74, 20, function() WM:ShowTab(i) end)
    b:SetPoint("TOPLEFT", 10 + (i - 1) * 78, -38)
    UI.tabs[i] = b
  end

  -- filter bar (contents change per tab)
  UI.filters = CreateFrame("Frame", nil, f)
  UI.filters:SetPoint("TOPLEFT", 330, -38); UI.filters:SetPoint("TOPRIGHT", -10, -38); UI.filters:SetHeight(20)

  Line(f, -63)

  UI.list = CreateList(f, -68, 58)
  UI.list:SetPoint("BOTTOMRIGHT", -8, 58)

  Line(f, -(H - 54))
  UI.detail1 = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  UI.detail1:SetPoint("BOTTOMLEFT", 12, 34); UI.detail1:SetPoint("RIGHT", -380, 0); UI.detail1:SetJustifyH("LEFT")
  UI.detail2 = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  UI.detail2:SetPoint("BOTTOMLEFT", 12, 14); UI.detail2:SetPoint("RIGHT", -380, 0); UI.detail2:SetJustifyH("LEFT")

  UI.btnWay = Button(f, "Waypoint", 70, 20, function() if UI.wayTarget then WM:Waypoint(unpack(UI.wayTarget)) end end)
  UI.btnWay:SetPoint("BOTTOMRIGHT", -156, 12)
  UI.btnShop = Button(f, "Search AH", 70, 20, function() WM:ShopSelected() end)
  UI.btnShop:SetPoint("BOTTOMRIGHT", -82, 12)
  UI.btnList = Button(f, "Shop list", 70, 20, function() WM:ShoppingList() end)
  UI.btnList:SetPoint("BOTTOMRIGHT", -230, 12)
  UI.btnPlan = Button(f, "Do today", 70, 20, function()
    local m = UI.list.multi
    if m and next(m) then
      local plan, all = PlanFor(UI.tab), true
      for q in pairs(m) do if not plan[q] then all = false end end
      for q in pairs(m) do plan[q] = (not all) or nil end
      WM:Refresh(); return
    end
    local e = UI.selected
    if not (e and e.key) then Print("Select a row first (Ctrl-click to pick several, or Shift-click rows).") return end
    local plan = PlanFor(UI.tab)
    if plan[e.key] then plan[e.key] = nil else plan[e.key] = true end
    WM:Refresh()
  end)
  UI.btnPlan:SetPoint("BOTTOMRIGHT", -304, 12)
  UI.btnPlan:HookScript("OnEnter", function(s) GameTooltip:SetOwner(s, "ANCHOR_TOP"); GameTooltip:SetText("Do today", 1, 0.82, 0)
    GameTooltip:AddLine("Adds the selected writ(s) or crate(s) to today's list (or removes them). Ctrl-click rows to select several first, or Shift-click a row to toggle it directly. The list clears at daily reset.", 1, 1, 1, true); GameTooltip:Show() end)
  UI.btnPlan:HookScript("OnLeave", function() GameTooltip:Hide() end)
  UI.btnList:HookScript("OnEnter", function(s) GameTooltip:SetOwner(s, "ANCHOR_TOP"); GameTooltip:SetText("Shop list", 1, 0.82, 0)
    GameTooltip:AddLine("Creates an Auctionator shopping list called 'WritMaster' for today's writs and crates: the writ or crate itself if you don't have it, plus the item (or its materials if crafting is cheaper) and the cheapest crate filling. With nothing planned it uses the writs in your bags. It is refreshed automatically when you open the Auction House.", 1, 1, 1, true); GameTooltip:Show() end)
  UI.btnList:HookScript("OnLeave", function() GameTooltip:Hide() end)
  UI.btnRoute = Button(f, "Route", 66, 20, function() WM:Route() end)
  UI.btnRoute:SetPoint("BOTTOMRIGHT", -12, 12)

  UI.list.onEnter = function(row, item) if UI.tooltipFn then UI.tooltipFn(row, item) end end
  UI.list.onClick = function(item, btn) if UI.clickFn then UI.clickFn(item, btn) end end

  f:SetScript("OnShow", function()
    ScanBags()
    local ok, err = pcall(LearnFromQuestLog)
    if not ok then Print(col("red", "quest log scan failed: ") .. tostring(err)) end
    WM:Refresh()
  end)
end

-- filter widgets (rebuilt per tab)
local filterWidgets = {}
local function ClearFilters() for _, w in ipairs(filterWidgets) do w:Hide() end wipe(filterWidgets) end
local function AddFilter(text, w, onClick, active, tip)
  local b = Button(UI.filters, text, w, 20, onClick)
  local x = 0
  for _, o in ipairs(filterWidgets) do x = x + o:GetWidth() + 4 end
  b:SetPoint("LEFT", x, 0)
  b:SetActive(active)
  if tip then
    b:HookScript("OnEnter", function(s) GameTooltip:SetOwner(s, "ANCHOR_BOTTOM"); GameTooltip:SetText(tip, 1, 1, 1, 1, true); GameTooltip:Show() end)
    b:HookScript("OnLeave", function() GameTooltip:Hide() end)
  end
  filterWidgets[#filterWidgets + 1] = b
  return b
end

---------------------------------------------------------------------------
-- Header status
---------------------------------------------------------------------------
function WM.UpdateAutoAH()
  local b = UI.btnAutoAH
  if not b then return end
  local on = WM.db and WM.db.settings.autoAH
  b.text:SetText(on and col("gold", "AH auto: on") or col("grey", "AH auto: off"))
  b:SetActive(on and true or false)
end

local function UpdateHeader()
  local name, reaction, cur, lo, hi = GetRep()
  local camp = WM.CAMP[PlayerFaction()]
  local standing = reaction and _G["FACTION_STANDING_LABEL" .. reaction] or "?"
  if name and cur and hi and lo then
    UI.status:SetText(fmt("%s  %s  %s", col("grey", camp.name), col("gold", standing),
      col("white", fmt("%d / %d", cur - lo, max(1, hi - lo)))))
  else
    UI.status:SetText(col("grey", camp.name .. " — not discovered yet"))
  end
  local fav, icon = GetFavor()
  local ah = HasAuctionator() and "" or col("red", "Auctionator not loaded   ")
  local reset = WM.ResetText and WM.ResetText() or ""
  WM.UpdateAutoAH()
  UI.favor:SetText(ah .. reset .. (fav and fmt("%s %s", col("white", fav), icon and ("|T" .. icon .. ":12|t") or col("gold", "Favor")) or ""))
end

---------------------------------------------------------------------------
-- Tab 1: Writs
---------------------------------------------------------------------------
local WRIT_COLS = {
  { title = "Requested item", w = 196, icon = true, sort = "name" },
  { title = "Prof", w = 42, sort = "prof" },
  { title = "Qty", w = 32, j = "CENTER" },
  { title = "Tier", w = 50, sort = "tier" },
  { title = "Rep", w = 36, j = "RIGHT" },
  { title = "Writ", w = 76, j = "RIGHT" },
  { title = "Item", w = 82, j = "RIGHT" },
  { title = "Total", w = 82, j = "RIGHT", sort = "total" },
  { title = "Rep/gold", w = 70, j = "RIGHT", sort = "eff" },
  { title = "Customer zone", w = 168, sort = "zone" },
}

local function SrcTag(src)
  if src == "in bags" then return col("green", "+") end
  if src == "craft" then return col("blue", "c") end
  if src and src:find("sealed") then return col("orange", "~") end
  return ""
end

local function WritCells(e)
  local w = e.w
  local name = ItemName(w.i) or ("item " .. w.i)
  local nameCol = e.owned and "green" or "white"
  local zone
  local cname, map = Customer(w)
  zone = map and (ZoneName(map) .. col("grey", " · " .. cname)) or (w.zh and (ZoneName(w.zh) .. col("grey", " · see marker")))
    or col("grey", e.owned and "open writ to map" or "unknown")
  local eff
  if e.eff == huge then eff = col("green", "free")
  elseif e.eff then
    local c = e.complete and (e.eff >= 100 and "green" or e.eff >= 30 and "white" or "orange") or "grey"
    eff = col(c, fmt(e.eff >= 100 and "%.0f" or "%.1f", e.eff))
  else eff = col("grey", "—") end
  return {
    (WM.Plan()[w.q] and col("gold", "> ") or "") .. col(nameCol, name) .. (e.done and col("grey", " (done)") or ""),
    col("grey", w.p),
    (w.n or 1) > 1 and col("white", w.n) or col("grey", "1"),
    col(TIER_COL[w.t], ShortTier(w.t)),
    col("white", w.r),
    Money(e.writCost, true) .. SrcTag(e.writSrc),
    Money(e.itemCost, true) .. SrcTag(e.itemSrc),
    e.complete and Money(e.total, true) or (e.total and (Money(e.total, true) .. col("grey", "*")) or col("grey", "—")),
    eff,
    zone,
    icon = ItemIcon(w.i),
    dim = e.done,
    planned = WM.Plan()[w.q] == true,
  }
end

local function WritTooltip(row, e)
  local w = e.w
  RowTipOwner(row)
  GameTooltip:SetText(ItemName(w.i) or ("item " .. w.i), 1, 1, 1)
  GameTooltip:AddDoubleLine(col("gold", "Craftsman's Writ"), fmt("%s · %s · %d rep", WM.PROF_NAME[w.p] or w.p, WM.TIER_NAME[w.t], w.r))
  if w.s then GameTooltip:AddDoubleLine("Skill to craft", tostring(w.s), 0.8, 0.8, 0.8, 1, 1, 1) end
  GameTooltip:AddDoubleLine("Writ cost", Money(e.writCost) .. " " .. col("grey", e.writSrc or "no AH data"))
  local named, sealed = AHPrice(w.w), AHPrice(WM.SEALED[w.t])
  GameTooltip:AddDoubleLine(col("grey", "  named writ on AH"), Money(named))
  GameTooltip:AddDoubleLine(col("grey", "  sealed " .. WM.TIER_NAME[w.t] .. "'s writ"), Money(sealed))
  GameTooltip:AddDoubleLine("Item cost", Money(e.itemCost) .. " " .. col("grey", e.itemSrc or "no data"))
  GameTooltip:AddDoubleLine(col("grey", "  buy on AH"), Money(e.ahTotal))
  if e.parts then
    GameTooltip:AddDoubleLine(col("grey", e.known and "  craft (you know it)" or "  craft (recipe not known)"), Money(e.crTotal))
    for _, p in ipairs(e.parts) do
      GameTooltip:AddDoubleLine(col("grey", fmt("     %dx %s", p[2], ItemName(p[1]) or p[1])), Money(p[3] and p[3] * p[2]) .. col("grey", p[4] == "vendor" and " v" or ""))
    end
  else
    GameTooltip:AddLine(col("grey", "  open your profession window once to price crafting"), 1, 1, 1, true)
  end
  local age = AHAge(w.i)
  if age then GameTooltip:AddLine(col("grey", fmt("AH data for item is %d day(s) old", age))) end
  local cname, map, x, y, learned = Customer(w)
  if map then
    GameTooltip:AddDoubleLine("Customer", fmt("%s, %s (%.1f, %.1f)%s", cname, ZoneName(map), x, y, learned and col("grey", " learned") or ""))
  else
    GameTooltip:AddLine(col("orange", "Customer unknown: it is recorded automatically when you turn this writ in."), 1, 1, 1, true)
  end
  if e.done then GameTooltip:AddLine(col("grey", "Already turned in today.")) end
  if WM.Plan()[w.q] then GameTooltip:AddLine(col("gold", "On today's list")) end
  GameTooltip:AddLine(col("grey", "Click: select · Ctrl-click: select several · Shift-click: add/remove from today · Right-click: waypoint"))
  GameTooltip:Show()
end

local function SelectWrit(e)
  local w = e.w
  UI.list.selected = e.key
  UI.selected = e
  local cname, map, x, y = Customer(w)
  UI.detail1:SetText(fmt("%s  %s  %s", col("gold", ItemName(w.i) or w.i),
    col("grey", "x" .. (w.n or 1)),
    map and fmt("deliver to %s, %s (%.1f, %.1f)", col("white", cname), col("gold", ZoneName(map)), x, y)
        or col("orange", "customer not mapped yet: follow the quest marker; it will be saved on turn-in")))
  local nearby = {}
  if map then
    for _, o in ipairs(WM.WRITS) do
      local _, m2 = Customer(o)
      if o ~= w and m2 == map and (WM.owned[o.w] or 0) > 0 then nearby[#nearby + 1] = ItemName(o.i) or o.i end
    end
  end
  UI.detail2:SetText(#nearby > 0 and ("Also in this zone from your bags: " .. table.concat(nearby, ", "))
    or "+ owned  ~ sealed-writ estimate  c crafted  * partial price.  Sorted by cheapest gold per rep.")
  UI.wayTarget = map and { map, x, y, cname } or nil
  UI.btnPlan.text:SetText(WM.Plan()[w.q] and "Drop" or "Do today")
  UI.btnWay:SetEnabled(map ~= nil)
  UI.list:Render()
end

local function ShowMulti()
  local m = UI.list.multi
  if not (m and next(m)) then return end
  if UI.tab == 2 then
    local n, fav, cost, plan, all = 0, 0, 0, WM.CratePlan(), true
    for id in pairs(m) do
      for _, r in ipairs(UI.list.data) do
        if r.key == id then n = n + 1; fav = fav + (r.c.favor or 0); cost = cost + (r.total or 0) end
      end
      if not plan[id] then all = false end
    end
    UI.detail1:SetText(fmt("%s %d crates, %s Favor for about %s", col("gold", "Selected:"), n, col("white", fav), Money(cost)))
    UI.detail2:SetText("Ctrl-click to add or remove rows. Click a row without Ctrl to go back to one.")
    UI.btnPlan.text:SetText(all and "Drop" or "Do today")
    UI.list:Render()
    return
  end
  local n, rep, cost, plan, all = 0, 0, 0, WM.Plan(), true
  for q in pairs(m) do
    local w = WM.byQuest[q]
    if w then
      local e = EvalWrit(w)
      n = n + 1; rep = rep + w.r; cost = cost + (e.total or 0)
      if not plan[q] then all = false end
    end
  end
  UI.detail1:SetText(fmt("%s %d writs, %s rep for about %s", col("gold", "Selected:"), n, col("white", rep), Money(cost)))
  UI.detail2:SetText("Ctrl-click to add or remove rows. Click a row without Ctrl to go back to one.")
  UI.btnPlan.text:SetText(all and "Drop" or "Do today")
  UI.wayTarget = nil; UI.btnWay:SetEnabled(false)
  UI.list:Render()
end

local function ShowWrits()
  local s = WM.db.settings
  ClearFilters()
  for _, t in ipairs({ { "ALL", "All" }, { "J", "Jour" }, { "E", "Expert" }, { "A", "Artisan" } }) do
    AddFilter(t[2], 52, function() s.tier = t[1]; ShowWrits() end, s.tier == t[1])
  end
  AddFilter("Owned", 52, function() s.ownedOnly = not s.ownedOnly; ShowWrits() end, s.ownedOnly, "Only writs that are in your bags.")
  AddFilter("Hide done", 64, function() s.hideDone = not s.hideDone; ShowWrits() end, s.hideDone, "Hide writs already turned in today.")
  AddFilter("Today", 50, function() s.planOnly = not s.planOnly; ShowWrits() end, s.planOnly,
    "Only the writs you picked for today (Shift-click a row or use the Do today button).")
  AddFilter("Craft", 46, function() s.craftOnly = not s.craftOnly; ShowWrits() end, s.craftOnly,
    "Prefer crafting cost over AH price for recipes you know.")
  AddFilter("Free writs", 70, function() s.ownedWritFree = not s.ownedWritFree; ShowWrits() end, s.ownedWritFree,
    "Count writs already in your bags as free (sunk cost).")

  UI.list:SetColumns(WRIT_COLS, function(key)
    if s.sort == key then s.sortAsc = not s.sortAsc else s.sort, s.sortAsc = key, false end
    ShowWrits()
  end)
  UI.list.cellFn = WritCells
  UI.tooltipFn = WritTooltip
  UI.clickFn = function(e, btn)
    if btn == "LeftButton" and IsShiftKeyDown and IsShiftKeyDown() then
      WM.TogglePlan(e.w.q); UI.selected = nil; UI.list.selected = nil; UI.list.multi = false; ShowWrits(); return
    end
    if btn == "LeftButton" and IsControlKeyDown and IsControlKeyDown() then
      local m = UI.list.multi or {}
      UI.list.multi = m
      if UI.selected and UI.selected.w then m[UI.selected.w.q] = true end
      if m[e.w.q] then m[e.w.q] = nil else m[e.w.q] = true end
      UI.selected, UI.list.selected = nil, nil
      if next(m) then ShowMulti() else UI.list.multi = false; ShowWrits() end
      return
    end
    UI.list.multi = false
    SelectWrit(e)
    if btn == "RightButton" and UI.wayTarget then WM:Waypoint(unpack(UI.wayTarget)) end
  end
  local rows = WritRows()
  for _, e in ipairs(rows) do e.key = e.w.q end
  UI.list:SetData(rows)
  UI.btnRoute:Show(); UI.btnShop:Show(); UI.btnWay:Show(); UI.btnList:Show(); UI.btnPlan:Show(); UI.btnPlan.text:SetText("Do today")
  UI.btnList.text:SetText(ShopLabel())
  if not UI.selected or not UI.selected.w then
    local own, done = 0, 0
    for _, w in ipairs(WM.WRITS) do
      if (WM.owned[w.w] or 0) > 0 then own = own + 1; if IsDoneToday(w.q) then done = done + 1 end end
    end
    local pn, prep, pcost, pdone = 0, 0, 0, 0
    for q in pairs(WM.Plan()) do
      local w = WM.byQuest and WM.byQuest[q]
      if w then
        local e = EvalWrit(w)
        pn = pn + 1
        if e.done then pdone = pdone + 1 else prep = prep + w.r; pcost = pcost + (e.total or 0) end
      end
    end
    if pn > 0 then
      UI.detail1:SetText(fmt("%s %d writs, %s rep for about %s%s", col("gold", "Today:"), pn, col("white", prep), Money(pcost),
        pdone > 0 and col("grey", fmt("  (%d turned in)", pdone)) or ""))
    else
      UI.detail1:SetText(col("grey", fmt("%d writs listed. In your bags: %d (%d already turned in today, wait for reset). Shift-click writs to plan today.", #rows, own, done)))
    end
    UI.detail2:SetText("+ owned  ~ sealed-writ estimate  c crafted  * partial price.  Sorted by cheapest gold per rep.")
    UI.btnWay:SetEnabled(false)
  end
end

function WM:ShopSelected()
  local e = UI.selected
  if not (e and e.w) then Print("Select a writ first.") return end
  if not HasAuctionator() or type(Auctionator.API.v1.MultiSearchExact) ~= "function" then
    Print("Auctionator search needs Auctionator loaded and the Auction House open."); return
  end
  local terms = {}
  local n1 = ItemName(e.w.i); if n1 then terms[#terms + 1] = n1 end
  if not e.owned then
    local n2 = ItemName(e.w.w); if n2 then terms[#terms + 1] = n2 end
    local n3 = ItemName(WM.SEALED[e.w.t]); if n3 then terms[#terms + 1] = n3 end
  end
  local ok, err = pcall(Auctionator.API.v1.MultiSearchExact, CALLER, terms)
  if not ok then Print("Open the Auction House first. (" .. tostring(err) .. ")") end
end

---------------------------------------------------------------------------
-- Tab 2: Crates
---------------------------------------------------------------------------
local CRATE_COLS = {
  { title = "Waylaid crate", w = 190, icon = true },
  { title = "Lvl", w = 34, j = "CENTER" },
  { title = "Favor", w = 46, j = "RIGHT" },
  { title = "Cheapest fill", w = 220 },
  { title = "Fill cost", w = 80, j = "RIGHT" },
  { title = "Crate AH", w = 76, j = "RIGHT" },
  { title = "Total", w = 80, j = "RIGHT" },
  { title = "Favor/gold", w = 74, j = "RIGHT" },
  { title = "Have", w = 34, j = "CENTER" },
}

local function EvalCrate(c)
  local e = { c = c, key = c.id }
  for _, o in ipairs(c.opts) do
    local p = AHPrice(o[1])
    local have = WM.owned[o[1]] or 0
    local cost = p and p * max(0, o[2] - have) or ((have >= o[2]) and 0 or nil)
    if cost and (not e.fill or cost < e.fill) then e.fill, e.opt = cost, o end
  end
  e.crate = AHPrice(c.id)
  e.have = WM.owned[c.id] or 0
  local crateCost = e.have > 0 and 0 or e.crate
  if e.fill and crateCost then e.total = e.fill + crateCost elseif e.fill and e.have == 0 then e.total = nil end
  if e.fill and e.have > 0 then e.total = e.fill end
  if e.total and c.favor then e.eff = e.total > 0 and c.favor / (e.total / GOLD) or huge end
  return e
end

local ShowCrates
function ShowCrates()
  ClearFilters()
  local note = AddFilter("Crates give Merchant's Favor, not rep", 230, function() end, false,
    "Reputation comes from writs. Crates are for Favor (recipes, mount, pet, toy, titles). After Friendly, a Forged Delivery Receipt turns an empty crate into 50 rep.")
  note:SetActive(false)
  UI.list:SetColumns(CRATE_COLS)
  UI.list.cellFn = function(e)
    local c = e.c
    local fill = e.opt and fmt("%d x %s", e.opt[2], ItemName(e.opt[1]) or e.opt[1]) or col("grey", "no AH data for any option")
    local eff = e.eff == huge and col("green", "free") or (e.eff and col("white", fmt("%.1f", e.eff)) or col("grey", "—"))
    return {
      (WM.CratePlan()[c.id] and col("gold", "> ") or "") .. col("white", c.name), col("grey", c.lvl), c.favor and col("gold", c.favor) or col("grey", "?"),
      fill, Money(e.fill, true), Money(e.crate, true), Money(e.total, true), eff,
      e.have > 0 and col("green", e.have) or col("grey", "0"),
      icon = ItemIcon(c.id),
      planned = WM.CratePlan()[c.id] == true,
    }
  end
  UI.tooltipFn = function(row, e)
    local c = e.c
    RowTipOwner(row)
    GameTooltip:SetText("Waylaid Crate: " .. c.name, 1, 0.82, 0)
    GameTooltip:AddDoubleLine("Tier / level", c.tier .. " / " .. c.lvl)
    GameTooltip:AddDoubleLine("Merchant's Favor (white crate)", c.favor and tostring(c.favor) or "unconfirmed")
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(col("gold", "Fill with ONE of:"))
    for _, o in ipairs(c.opts) do
      local p = AHPrice(o[1])
      GameTooltip:AddDoubleLine(fmt("  %d x %s", o[2], ItemName(o[1]) or o[1]), Money(p and p * o[2]) ..
        ((WM.owned[o[1]] or 0) > 0 and col("green", fmt(" (have %d)", WM.owned[o[1]])) or ""))
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(col("grey", "Turn in to " .. WM.CAMP[PlayerFaction()].intake .. " at " .. WM.CAMP[PlayerFaction()].where), 1, 1, 1, true)
    if WM.CratePlan()[c.id] then GameTooltip:AddLine(col("gold", "On today's list")) end
    GameTooltip:AddLine(col("grey", "Click: select · Ctrl-click: select several · Shift-click: add/remove from today"))
    GameTooltip:Show()
  end
  UI.clickFn = function(e, btn)
    if btn == "LeftButton" and IsShiftKeyDown and IsShiftKeyDown() then
      local p = WM.CratePlan(); if p[e.key] then p[e.key] = nil else p[e.key] = true end
      UI.selected, UI.list.selected, UI.list.multi = nil, nil, false; ShowCrates(); return
    end
    if btn == "LeftButton" and IsControlKeyDown and IsControlKeyDown() then
      local m = UI.list.multi or {}
      UI.list.multi = m
      if UI.selected and UI.selected.key then m[UI.selected.key] = true end
      if m[e.key] then m[e.key] = nil else m[e.key] = true end
      UI.selected, UI.list.selected = nil, nil
      if next(m) then ShowMulti() else UI.list.multi = false; ShowCrates() end
      return
    end
    UI.list.multi = false
    UI.selected = e; UI.list.selected = e.key
    UI.btnPlan.text:SetText(WM.CratePlan()[e.key] and "Drop" or "Do today")
    UI.list:Render()
  end
  local rows = {}
  for _, c in ipairs(WM.CRATES) do rows[#rows + 1] = EvalCrate(c) end
  table.sort(rows, function(a, b)
    if (a.eff ~= nil) ~= (b.eff ~= nil) then return a.eff ~= nil end
    if a.eff and b.eff and a.eff ~= b.eff then return a.eff > b.eff end
    return a.c.id < b.c.id
  end)
  UI.list:SetData(rows)
  local camp = WM.CAMP[PlayerFaction()]
  local pn, pfav, pcost = 0, 0, 0
  for _, r in ipairs(rows) do
    if WM.CratePlan()[r.key] then pn = pn + 1; pfav = pfav + (r.c.favor or 0); pcost = pcost + (r.total or 0) end
  end
  if pn > 0 then
    UI.detail1:SetText(fmt("%s %d crates, %s Favor for about %s. Hand in to %s.", col("gold", "Today:"), pn, col("white", pfav), Money(pcost), col("white", camp.intake)))
  else
    UI.detail1:SetText(fmt("Hand in filled crates to %s, %s. Shift-click crates to plan today.", col("white", camp.intake), col("gold", camp.where)))
  end
  UI.detail2:SetText("Sorted by Merchant's Favor per gold. Crates you already hold count as free. Green crates give double Favor.")
  UI.wayTarget = { camp.map, camp.x, camp.y, camp.intake }
  UI.btnWay:SetEnabled(true); UI.btnShop:Hide(); UI.btnRoute:Hide(); UI.btnWay:Show()
  UI.btnList:Show(); UI.btnPlan:Show(); UI.btnPlan.text:SetText("Do today"); UI.btnList.text:SetText(ShopLabel())
end

---------------------------------------------------------------------------
-- Tab 3: Vendors (everything bought with Merchant's Favor)
---------------------------------------------------------------------------
local VENDOR_COLS = {
  { title = "Item", w = 300, icon = true },
  { title = "Favor", w = 60, j = "RIGHT" },
  { title = "Rep", w = 70, j = "CENTER" },
  { title = "Skill", w = 50, j = "CENTER" },
  { title = "Status", w = 120 },
  { title = "AH value", w = 90, j = "RIGHT" },
  { title = "Notes", w = 140 },
}
local REPNAME = { F = "Friendly", H = "Honored", R = "Revered", E = "Exalted" }

local function ShowVendors()
  local s = WM.db.settings
  ClearFilters()
  for i, v in ipairs(WM.VENDORS) do
    local short = ({ Alchemy = "Alch", Blacksmithing = "Smith", Enchanting = "Ench", Engineering = "Eng", Leatherworking = "LW",
                     Tailoring = "Tail", Cooking = "Cook", ["Supply Officer"] = "Misc", Mount = "Mount", ["Uncertified Scribe"] = "Scribe" })[v.prof] or v.prof
    AddFilter(short, 44, function() s.vendorProf = i; ShowVendors() end, s.vendorProf == i, v.prof)
  end
  local v = WM.VENDORS[s.vendorProf] or WM.VENDORS[1]
  local faction = PlayerFaction()
  local favor = GetFavor() or 0
  UI.list:SetColumns(VENDOR_COLS)
  UI.list.cellFn = function(it)
    local cost = WM.db.vendorCost[it[1]] or it[2]
    local learnedCost = WM.db.vendorCost[it[1]] ~= nil
    local status
    if not cost then status = col("grey", "cost unknown")
    elseif favor >= cost then status = col("green", "affordable")
    else status = col("red", fmt("need %d Favor", cost - favor)) end
    return {
      col("white", ItemName(it[1]) or ("item " .. it[1])),
      cost and (col("gold", cost) .. (learnedCost and "" or col("grey", ""))) or col("grey", "?"),
      it[3] and col("white", REPNAME[it[3]] or it[3]) or col("grey", "—"),
      it[4] and col("white", it[4]) or col("grey", "—"),
      status,
      Money(AHPrice(it[1]), true),
      (it[6] and not (learnedCost and it[6]:find("Favor cost")) and col("orange", it[6])) or (it[5] and col("grey", it[5] == "A" and "Alliance" or "Horde")) or "",
      icon = ItemIcon(it[1]),
      dim = it[5] and ((it[5] == "A") ~= (faction == "Alliance")),
    }
  end
  UI.tooltipFn = function(row, it)
    RowTipOwner(row)
    local link = ItemLink(it[1])
    if link then GameTooltip:SetHyperlink(link) else GameTooltip:SetText(ItemName(it[1]) or ("item " .. it[1])) end
    local cost = WM.db.vendorCost[it[1]] or it[2]
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(col("gold", "Merchant's Favor"), cost and tostring(cost) or "unconfirmed")
    if WM.db.vendorCost[it[1]] then GameTooltip:AddLine(col("grey", "Price confirmed at the vendor."))
    else GameTooltip:AddLine(col("grey", "Guide price; confirmed automatically when you open this vendor."), 1, 1, 1, true) end
    GameTooltip:Show()
  end
  UI.clickFn = function(it) UI.list.selected = it.key; UI.list:Render() end
  local rows = {}
  for _, it in ipairs(v.items) do
    if not (it[5] and ((it[5] == "A") ~= (faction == "Alliance"))) then
      it.key = it[1]
      rows[#rows + 1] = it
    end
  end
  table.sort(rows, function(a, b)
    local ca, cb = WM.db.vendorCost[a[1]] or a[2] or 99999, WM.db.vendorCost[b[1]] or b[2] or 99999
    if ca ~= cb then return ca < cb end
    if (a[4] or 0) ~= (b[4] or 0) then return (a[4] or 0) < (b[4] or 0) end
    return a[1] < b[1]
  end)
  UI.list:SetData(rows)
  local npc = faction == "Alliance" and v.ally or v.horde
  local camp = WM.CAMP[faction]
  UI.detail1:SetText(fmt("%s vendor: %s  %s", col("gold", v.prof), col("white", npc[1]),
    npc[2] and col("grey", fmt("(%.1f, %.1f) %s", npc[2], npc[3], ZoneName(camp.map))) or ""))
  UI.detail2:SetText(fmt("You have %s Merchant's Favor. %d items. Prices are confirmed when you open the vendor.", col("white", favor), #rows))
  UI.wayTarget = npc[2] and { camp.map, npc[2], npc[3], npc[1] } or { camp.map, camp.x, camp.y, camp.intake }
  UI.btnWay:SetEnabled(true); UI.btnShop:Hide(); UI.btnRoute:Hide(); UI.btnWay:Show(); UI.btnList:Hide(); UI.btnPlan:Hide()
end

---------------------------------------------------------------------------
-- Tab 4: Info
---------------------------------------------------------------------------
local INFO_COLS = { { title = "Reputation & Merchant's Favor", w = 820 } }
local function ShowInfo()
  ClearFilters()
  local st = WM.db.settings
  AddFilter("Auto-open at AH", 104, function() st.autoAH = not st.autoAH; WM.UpdateAutoAH(); ShowInfo() end, st.autoAH, "Open the writ list when you open the Auction House.")
  AddFilter("Auto-open at camp", 112, function() st.autoCamp = not st.autoCamp; ShowInfo() end, st.autoCamp, "Open WritMaster when you talk to a camp vendor or the crate hand-in NPC.")
  AddFilter("Minimap", 60, function() st.minimap = not st.minimap; if WM.UpdateMinimap then WM.UpdateMinimap() end; ShowInfo() end, st.minimap)
  AddFilter("Row tips need Shift", 124, function() st.tipShift = not st.tipShift; ShowInfo() end, st.tipShift,
    "Only show the tooltip for a list row while you hold Shift.")
  AddFilter("Tooltips", 60, function() st.tooltips = not st.tooltips; ShowInfo() end, st.tooltips, "Add WritMaster info to item tooltips.")
  UI.list:SetColumns(INFO_COLS)
  UI.list.cellFn = function(it) return { it.text } end
  UI.tooltipFn = nil
  UI.clickFn = nil
  local lines = {}
  local function add(t) lines[#lines + 1] = { text = t, key = #lines + 1 } end
  local faction = PlayerFaction()
  local camp = WM.CAMP[faction]
  local name, reaction, cur = GetRep()
  add(col("gold", camp.name) .. col("grey", "  —  " .. camp.where))
  if cur then
    local nextGoal
    for _, g in ipairs(WM.REP_GOALS) do if cur < g[2] then nextGoal = g; break end end
    if nextGoal then
      local need = nextGoal[2] - cur
      add(fmt("  %s rep to %s  ~ %d Journeyman / %d Expert / %d Artisan writs", col("white", need), col("gold", nextGoal[1]),
        math.ceil(need / 75), math.ceil(need / 125), math.ceil(need / 200)))
    else
      add("  " .. col("green", "Exalted. Nice."))
    end
  end
  add(" ")
  for _, l in ipairs(WM.FAVOR_INFO) do add("  " .. col("white", l)) end
  add(" ")
  -- daily cooldowns
  local cd = {}
  for _, w in ipairs(WM.WRITS) do if IsDoneToday(w.q) then cd[#cd + 1] = ItemName(w.i) or w.i end end
  add(col("gold", "Daily cooldowns") .. col("grey", "  " .. (WM.ResetText and WM.ResetText() or "")))
  add("  " .. (#cd > 0 and col("white", table.concat(cd, ", ")) or col("grey", "No writs turned in today.")))
  add(" ")
  add(col("gold", "Commands"))
  add("  /writ (or /writmaster, /iwm)  toggle window       /writ route  delivery route for writs in your bags")
  add("  /writ list  Auctionator shopping list       /writ mm  toggle minimap button")
  add("  Ctrl-click to select several writs, then Do today; Shift-click toggles one. /writ clear empties the plan")
  add("  /writ scan  re-read bags       /writ reset  reset window position       /writ forget  clear learned customers")
  add(" ")
  add(col("gold", "Tips"))
  add("  Open each profession window once so WritMaster can price crafting from materials.")
  add("  Customers for writs marked 'unknown' are saved automatically the first time you turn one in.")
  add("  Run an Auctionator full scan (or browse the AH) to refresh prices.")
  add(" ")
  local ver = (C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata or function() end)(ADDON, "Version")
  if not ver or ver:find("@") then ver = "dev" end
  add(col("gold", "About") .. col("grey", "   Inri's WritMaster " .. ver .. "  ·  Author: Inri"))
  add("  |cff04cca4Development is done by a hardworking AI (& 1 lazy human)|r")
  add(col("grey", "  github.com/DrMally5/InriWritMaster  ·  report bugs and new customer locations in Issues"))
  UI.list:SetData(lines)
  UI.detail1:SetText(fmt("Camp: %s", col("white", camp.where)))
  UI.detail2:SetText("Data decoded from your Questie database and Forever guides. Unconfirmed values are marked and learned in game.")
  UI.wayTarget = { camp.map, camp.x, camp.y, camp.intake }
  UI.btnWay:SetEnabled(true); UI.btnShop:Hide(); UI.btnRoute:Show(); UI.btnWay:Show(); UI.btnList:Hide(); UI.btnPlan:Hide()
end

---------------------------------------------------------------------------
-- Tab switching / refresh
---------------------------------------------------------------------------
local TAB_FN = { ShowWrits, ShowCrates, ShowVendors, ShowInfo }
function WM:ShowTab(i)
  if not UI.frame then return end
  UI.tab = i
  UI.list.offset, UI.list.selected, UI.selected, UI.list.multi = 0, nil, nil, false
  for j, b in ipairs(UI.tabs) do b:SetActive(j == i) end
  TAB_FN[i]()
  UpdateHeader()
end

function WM:Refresh()
  if not (UI.frame and UI.frame:IsShown()) then return end
  local sel = UI.selected
  TAB_FN[UI.tab or 1]()
  if sel and sel.w and UI.tab == 1 then
    for _, e in ipairs(UI.list.data) do if e.key == sel.w.q then SelectWrit(e) break end end
  end
  if sel and sel.c and UI.tab == 2 and not (UI.list.multi and next(UI.list.multi)) then
    for _, e in ipairs(UI.list.data) do if e.key == sel.key then UI.selected = e; UI.list.selected = e.key
      UI.btnPlan.text:SetText(WM.CratePlan()[e.key] and "Drop" or "Do today"); UI.list:Render() break end end
  end
  if UI.tab == 1 or UI.tab == 2 then ShowMulti() end
  UpdateHeader()
end

local pending = false
function WM:QueueRefresh()
  if pending then return end
  pending = true
  C_Timer.After(0.4, function() pending = false; WM:Refresh() end)
end

function WM:Toggle()
  if not UI.frame then BuildFrame() end
  if UI.frame:IsShown() then UI.frame:Hide() else UI.frame:Show(); WM:ShowTab(UI.tab or 1) end
end

function InriWritMaster_OnCompartmentClick() WM:Toggle() end

function WM:Open(tab)
  if not UI.frame then BuildFrame() end
  if not UI.frame:IsShown() then UI.frame:Show() end
  WM:ShowTab(tab or UI.tab or 1)
end

-- shared helpers for Features.lua
WM.H = { EvalWrit = EvalWrit, Customer = Customer, ItemName = ItemName, ItemLink = ItemLink, Money = Money, Print = Print,
         col = col, ZoneName = ZoneName, CraftCost = CraftCost, ScanBags = ScanBags, IsDoneToday = IsDoneToday,
         PlayerFaction = PlayerFaction, ReagentPrice = ReagentPrice, UI = UI, EvalCrate = EvalCrate }

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == ADDON then
    InriWritMasterDB = fill(InriWritMasterDB or {}, DEFAULTS)
    InriWritMasterCharDB = fill(InriWritMasterCharDB or {}, CHAR_DEFAULTS)
    WM.db, WM.cdb = InriWritMasterDB, InriWritMasterCharDB
  elseif event == "PLAYER_LOGIN" then
    Print("loaded. Type " .. col("white", "/writ") .. " or " .. col("white", "/writmaster") .. " to open.")
    ScanBags()
    for _, e in ipairs({ "BAG_UPDATE_DELAYED", "QUEST_COMPLETE", "QUEST_TURNED_IN", "TRADE_SKILL_SHOW", "TRADE_SKILL_LIST_UPDATE",
                         "MERCHANT_SHOW", "GET_ITEM_INFO_RECEIVED", "QUEST_ACCEPTED", "QUEST_LOG_UPDATE", "UPDATE_FACTION", "CURRENCY_DISPLAY_UPDATE",
                         "AUCTION_HOUSE_CLOSED" }) do
      pcall(ev.RegisterEvent, ev, e)
    end
    -- warm item cache for names
    for _, w in ipairs(WM.WRITS) do ItemName(w.i) end
    for _, s in pairs(WM.SEALED) do ItemName(s) end
  elseif event == "BAG_UPDATE_DELAYED" then
    ScanBags(); WM:QueueRefresh()
  elseif event == "QUEST_COMPLETE" then
    LearnCustomer()
  elseif event == "QUEST_ACCEPTED" or event == "QUEST_LOG_UPDATE" then
    if not WM.qlPending then
      WM.qlPending = true
      C_Timer.After(1, function() WM.qlPending = false; if LearnFromQuestLog() > 0 then WM:QueueRefresh() end end)
    end
  elseif event == "QUEST_TURNED_IN" then
    if WM.byQuest[arg1] then WM:QueueRefresh() end
  elseif event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_LIST_UPDATE" then
    C_Timer.After(0.5, function()
      local n = ScanTradeSkill()
      if n and n > 0 and event == "TRADE_SKILL_SHOW" then Print(fmt("Priced %d writ recipes you know.", n)) end
      WM:QueueRefresh()
    end)
  elseif event == "MERCHANT_SHOW" then
    C_Timer.After(0.3, ScanMerchant)
  elseif event == "AUCTION_HOUSE_CLOSED" then
    wipe(priceCache); WM:QueueRefresh()
  else
    WM:QueueRefresh()
  end
end)

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------
SLASH_INRIWRITMASTER1 = "/writmaster"
SLASH_INRIWRITMASTER2 = "/writ"
SLASH_INRIWRITMASTER3 = "/iwm"
SlashCmdList.INRIWRITMASTER = function(msg)
  msg = strlower(strtrim(msg or ""))
  if msg == "route" then WM:Route()
  elseif msg == "scan" then ScanBags(); wipe(priceCache); Print("Bags rescanned."); WM:Refresh()
  elseif msg == "reset" then WM.db.pos = nil; if UI.frame then UI.frame:ClearAllPoints(); UI.frame:SetPoint("CENTER") end
  elseif msg == "forget" then wipe(WM.db.learned); Print("Learned customer locations cleared.")
  elseif msg == "list" then WM:ShoppingList()
  elseif msg == "clear" then if WM.cdb then WM.cdb.plan = nil end; Print("Today's list cleared."); if UI.frame and UI.frame:IsShown() and UI.tab == 1 then WM:ShowTab(1) end
  elseif msg == "mm" or msg == "minimap" then WM.db.settings.minimap = not WM.db.settings.minimap; if WM.UpdateMinimap then WM.UpdateMinimap() end
  elseif msg == "help" then
    Print("/writ, /writ route, /writ list, /writ clear, /writ mm, /writ scan, /writ reset, /writ forget")
  else
    local ok, err = xpcall(function() WM:Toggle() end, function(e) return tostring(e) .. "\n" .. (debugstack and debugstack(2, 6, 0) or "") end)
    if not ok then Print(col("red", "error opening window:") .. " " .. tostring(err)) end
  end
end
