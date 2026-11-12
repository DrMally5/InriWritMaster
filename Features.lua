-- Inri's WritMaster: tooltips, shopping list, minimap button, auto-open, daily reset, buy-or-skip
local ADDON, WM = ...
local H = WM.H
local fmt, floor, huge, max = string.format, math.floor, math.huge, math.max
local GOLD = 10000
local col, Money, ItemName = H.col, H.Money, H.ItemName

---------------------------------------------------------------------------
-- Daily reset
---------------------------------------------------------------------------
local function SecondsToReset()
  if C_DateAndTime and C_DateAndTime.GetSecondsUntilDailyReset then
    local ok, s = pcall(C_DateAndTime.GetSecondsUntilDailyReset)
    if ok and s then return s end
  end
  if GetQuestResetTime then return GetQuestResetTime() end
end

function WM.ResetText()
  local s = SecondsToReset()
  if not s or s <= 0 then return "" end
  local h, m = floor(s / 3600), floor((s % 3600) / 60)
  return col("grey", "reset ") .. col("white", h > 0 and fmt("%dh %02dm", h, m) or fmt("%dm", m)) .. "   "
end

---------------------------------------------------------------------------
-- Benchmarks for buy-or-skip: rep/gold of every fully priced writ
---------------------------------------------------------------------------
local bench = { t = -1 }
local function Benchmarks()
  local now = GetTime()
  if now - bench.t < 20 then return bench end
  local faction = H.PlayerFaction()
  local effs, itemSum, itemN = {}, { J = 0, E = 0, A = 0 }, { J = 0, E = 0, A = 0 }
  for _, w in ipairs(WM.WRITS) do
    if not (w.ao and faction == "Horde") then
      local e = H.EvalWrit(w)
      if e.complete and e.eff and e.eff < huge then effs[#effs + 1] = e.eff end
      if e.itemCost then itemSum[w.t] = itemSum[w.t] + e.itemCost; itemN[w.t] = itemN[w.t] + 1 end
    end
  end
  table.sort(effs)
  bench.effs = effs
  bench.median = #effs > 0 and effs[floor((#effs + 1) / 2)] or nil
  bench.avgItem = {}
  for t in pairs(itemSum) do bench.avgItem[t] = itemN[t] > 0 and itemSum[t] / itemN[t] or nil end
  bench.t = now
  return bench
end

-- share of priced writs that this rep/gold beats (0..1)
local function Percentile(eff)
  local b = Benchmarks()
  if not b.effs or #b.effs == 0 then return nil end
  local n = 0
  for _, v in ipairs(b.effs) do if eff >= v then n = n + 1 end end
  return n / #b.effs
end

local function Verdict(eff)
  if not eff then return nil end
  if eff == huge then return col("green", "BUY") .. col("grey", " (free)") end
  local p = Percentile(eff)
  if not p then return nil end
  local pct = floor(p * 100 + 0.5)
  if p >= 0.5 then
    return col("green", "BUY") .. col("grey", fmt(" — cheaper rep than %d%% of writs", pct))
  end
  return col("red", "SKIP") .. col("grey", fmt(" — only beats %d%% of writs", pct))
end
WM.Verdict = Verdict

---------------------------------------------------------------------------
-- Item tooltips
---------------------------------------------------------------------------
local SEALED_TIER = {}
for t, id in pairs(WM.SEALED) do SEALED_TIER[id] = t end

local function AddWritLines(tt, id)
  if not (WM.db and WM.db.settings.tooltips) then return end
  local w = WM.byWrit[id]
  local sealedTier = SEALED_TIER[id]
  local asItem = WM.byItem[id]
  if not (w or sealedTier or asItem) then return end
  tt:AddLine(" ")
  if w then
    local e = H.EvalWrit(w)
    tt:AddDoubleLine(col("gold", "WritMaster"), fmt("%s · %d rep", WM.TIER_NAME[w.t], w.r))
    tt:AddDoubleLine("Requested item", fmt("%s x%d", ItemName(w.i) or w.i, w.n or 1), 1, 1, 1, 1, 1, 1)
    tt:AddDoubleLine("Total cost", Money(e.total) .. (e.complete and "" or col("grey", " (partial)")))
    if e.eff then tt:AddDoubleLine("Rep per gold", e.eff == huge and col("green", "free") or col("white", fmt("%.1f", e.eff))) end
    local name, map, x, y = H.Customer(w)
    if map then tt:AddDoubleLine("Customer", fmt("%s, %s (%.1f, %.1f)", name, H.ZoneName(map), x, y), 1, 1, 1, 1, 1, 1)
    else tt:AddDoubleLine("Customer", col("orange", "unknown: start the quest to map it")) end
    if e.done then tt:AddLine(col("grey", "Already turned in today. ") .. (WM.ResetText() or "")) end
    -- buying this writ off the AH: price it as named-writ cost + item cost
    local named = WM.AHPrice(w.w)
    if named and e.itemCost then
      local eff = w.r / ((named + e.itemCost) / GOLD)
      tt:AddDoubleLine("Buy this writ?", Verdict(eff) or col("grey", "not enough price data"))
    end
  elseif sealedTier then
    local b = Benchmarks()
    local sealed = WM.AHPrice(id)
    local avgItem = b.avgItem[sealedTier]
    local rep = WM.TIER_REP[sealedTier]
    tt:AddDoubleLine(col("gold", "WritMaster"), fmt("random %s order · %d rep", WM.TIER_NAME[sealedTier], rep))
    tt:AddDoubleLine("Avg item cost for this tier", Money(avgItem))
    if sealed and avgItem then
      local eff = rep / ((sealed + avgItem) / GOLD)
      tt:AddDoubleLine("Expected rep per gold", col("white", fmt("%.1f", eff)))
      tt:AddDoubleLine("Buy this writ?", Verdict(eff) or col("grey", "not enough price data"))
    else
      tt:AddLine(col("grey", "Scan the AH with Auctionator to get a buy-or-skip verdict."))
    end
  elseif asItem then
    tt:AddDoubleLine(col("gold", "WritMaster"), fmt("needed for a %s writ (%d rep)", WM.TIER_NAME[asItem.t], asItem.r))
    if (WM.owned[asItem.w] or 0) > 0 then tt:AddLine(col("green", "You have the matching writ in your bags.")) end
  end
  tt:Show()
end

local hooked = false
local function HookTooltips()
  if hooked then return end
  hooked = true
  if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt, data)
      if tt ~= GameTooltip and tt ~= ItemRefTooltip then return end
      local id = data and data.id
      if not id and tt.GetItem then local _, link = tt:GetItem(); id = link and tonumber(link:match("item:(%d+)")) end
      if id then pcall(AddWritLines, tt, id) end
    end)
  else
    for _, tt in ipairs({ GameTooltip, ItemRefTooltip }) do
      if tt and tt.HookScript then
        pcall(tt.HookScript, tt, "OnTooltipSetItem", function(self)
          local _, link = self:GetItem()
          local id = link and tonumber(link:match("item:(%d+)"))
          if id then pcall(AddWritLines, self, id) end
        end)
      end
    end
  end
end

---------------------------------------------------------------------------
-- Auctionator shopping list
---------------------------------------------------------------------------
function WM:ShoppingList(auto)
  local api = Auctionator and Auctionator.API and Auctionator.API.v1
  if not (api and api.CreateShoppingList and api.ConvertToSearchString) then
    if not auto then H.Print("Auctionator is needed for shopping lists.") end
    return
  end
  H.ScanBags()
  local need = {}          -- itemID -> quantity
  local names = {}         -- itemID -> fallback search name
  local function want(id, q) need[id] = (need[id] or 0) + q end
  local plan, cplan = WM.Plan(), WM.CratePlan()
  local usePlan = next(plan) ~= nil or next(cplan) ~= nil
  local count = 0
  for _, w in ipairs(WM.WRITS) do
    local ownWrit = (WM.owned[w.w] or 0) > 0
    if not H.IsDoneToday(w.q) and ((usePlan and plan[w.q]) or (not usePlan and ownWrit)) then
      count = count + 1
      if not ownWrit then
        want(w.w, 1)
        names[w.w] = "Craftsman's Writ: " .. (ItemName(w.i) or "")
      end
      local missing = (w.n or 1) - (WM.owned[w.i] or 0)
      if missing > 0 then
        local e = H.EvalWrit(w)
        local r = WM.db.recipes[w.i]
        if e.itemSrc == "craft" and r and r[2] then
          local crafts = math.ceil(missing / max(1, r[1] or 1))
          for _, rg in ipairs(r[2]) do
            if not WM.VENDOR_REAGENTS[rg[1]] then want(rg[1], rg[2] * crafts) end
          end
        else
          want(w.i, w.n or 1)   -- bag count is subtracted below
        end
      end
    end
  end
  -- planned crates: the crate itself if not in bags, plus its cheapest fill option
  local crates = 0
  for _, c in ipairs(WM.CRATES) do
    if cplan[c.id] then
      crates = crates + 1
      local e = H.EvalCrate(c)
      if (WM.owned[c.id] or 0) == 0 then want(c.id, 1) end
      local o = e.opt or c.opts[1]
      if o then want(o[1], o[2]) end
    end
  end
  -- subtract materials already in bags
  local terms = {}
  for id, q in pairs(need) do
    local left = q - (WM.owned[id] or 0)
    local name = ItemName(id) or names[id]
    if left > 0 and name and name ~= "Craftsman's Writ: " then
      local ok, str = pcall(api.ConvertToSearchString, "InriWritMaster", { searchString = name, isExact = true, quantity = left })
      if ok and str then terms[#terms + 1] = str end
    end
  end
  if #terms == 0 then
    if auto then return end
    H.Print(count == 0 and "Nothing to buy: no undelivered writs are missing items." or "Everything needed is already in your bags.")
    return
  end
  local ok, err = pcall(api.CreateShoppingList, "InriWritMaster", "WritMaster", terms)
  if ok then
    local parts = {}
    if count > 0 then parts[#parts + 1] = fmt("%d %swrit%s", count, usePlan and "planned " or "", count == 1 and "" or "s") end
    if crates > 0 then parts[#parts + 1] = fmt("%d crate%s", crates, crates == 1 and "" or "s") end
    local what = table.concat(parts, " and ") .. (usePlan and "" or " in your bags")
    H.Print(fmt("Shopping list %s %s with %d items for %s. Open it in Auctionator's Shopping tab.", col("white", "'WritMaster'"),
      auto and "refreshed" or "created", #terms, what))
  else
    H.Print("Could not create the shopping list: " .. tostring(err))
  end
end

---------------------------------------------------------------------------
-- Minimap button
---------------------------------------------------------------------------
local mm
local function PlaceMinimap()
  if not mm then return end
  local a = math.rad(WM.db.settings.minimapAngle or 200)
  local r = (Minimap:GetWidth() / 2) + 6
  mm:ClearAllPoints()
  mm:SetPoint("CENTER", Minimap, "CENTER", math.cos(a) * r, math.sin(a) * r)
end

function WM.UpdateMinimap()
  if not Minimap then return end
  if not mm then
    mm = CreateFrame("Button", "InriWritMasterMinimapButton", Minimap)
    mm:SetSize(31, 31)
    mm:SetFrameStrata("MEDIUM")
    mm:SetFrameLevel(8)
    mm:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    mm:RegisterForDrag("LeftButton")
    mm:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local bg = mm:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background"); bg:SetSize(20, 20); bg:SetPoint("CENTER")
    local icon = mm:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\Icons\\INV_Scroll_08"); icon:SetSize(18, 18); icon:SetPoint("CENTER")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local border = mm:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder"); border:SetSize(53, 53); border:SetPoint("TOPLEFT")
    mm:SetScript("OnClick", function(_, btn) if btn == "RightButton" then WM:Route() else WM:Toggle() end end)
    mm:SetScript("OnDragStart", function(self)
      self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local s = Minimap:GetEffectiveScale()
        WM.db.settings.minimapAngle = math.deg(math.atan2(cy / s - my, cx / s - mx))
        PlaceMinimap()
      end)
    end)
    mm:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    mm:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_LEFT")
      GameTooltip:SetText(col("gold", "Inri's") .. " WritMaster")
      GameTooltip:AddLine("Left-click: open / close", 1, 1, 1)
      GameTooltip:AddLine("Right-click: delivery route", 1, 1, 1)
      GameTooltip:AddLine("Drag: move", 0.6, 0.6, 0.6)
      local r = WM.ResetText()
      if r ~= "" then GameTooltip:AddLine(r) end
      GameTooltip:Show()
    end)
    mm:SetScript("OnLeave", function() GameTooltip:Hide() end)
  end
  PlaceMinimap()
  mm:SetShown(WM.db.settings.minimap)
end

---------------------------------------------------------------------------
-- Auto-open at the AH and at camp NPCs
---------------------------------------------------------------------------
local autoOpened = false
local function IsOpen() return H.UI.frame and H.UI.frame:IsShown() end

local function CampNPC(name)
  if not name then return nil end
  for i, v in ipairs(WM.VENDORS) do
    if v.ally[1] == name or v.horde[1] == name then return "vendor", i end
  end
  for _, c in pairs(WM.CAMP) do if c.intake == name then return "intake" end end
  return nil
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function(_, event)
  local st = WM.db and WM.db.settings
  if not st then return end
  if event == "PLAYER_LOGIN" then
    HookTooltips()
    WM.UpdateMinimap()
    for _, e in ipairs({ "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED", "MERCHANT_SHOW", "MERCHANT_CLOSED",
                         "GOSSIP_SHOW", "GOSSIP_CLOSED", "QUEST_GREETING", "QUEST_FINISHED" }) do
      pcall(ev.RegisterEvent, ev, e)
    end
    -- login summary
    C_Timer.After(4, function()
      H.ScanBags()
      local ready, cd = 0, 0
      for _, w in ipairs(WM.WRITS) do
        if (WM.owned[w.w] or 0) > 0 then if H.IsDoneToday(w.q) then cd = cd + 1 else ready = ready + 1 end end
      end
      if ready + cd > 0 then
        H.Print(fmt("%d writ(s) ready to deliver, %d waiting for daily reset. %s", ready, cd, WM.ResetText()))
      end
    end)
  elseif event == "AUCTION_HOUSE_SHOW" then
    if next(WM.Plan()) or next(WM.CratePlan()) then C_Timer.After(0.5, function() pcall(WM.ShoppingList, WM, true) end) end
    if st.autoAH and not IsOpen() then WM:Open(1); autoOpened = true end
  elseif event == "MERCHANT_SHOW" or event == "GOSSIP_SHOW" or event == "QUEST_GREETING" then
    if st.autoCamp and not IsOpen() then
      local kind, idx = CampNPC(UnitName("npc"))
      if kind == "vendor" then st.vendorProf = idx; WM:Open(3); autoOpened = true
      elseif kind == "intake" then WM:Open(2); autoOpened = true end
    end
  elseif event == "AUCTION_HOUSE_CLOSED" or event == "MERCHANT_CLOSED" or event == "GOSSIP_CLOSED" or event == "QUEST_FINISHED" then
    if autoOpened and IsOpen() then H.UI.frame:Hide() end
    autoOpened = false
  end
end)
