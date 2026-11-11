local
  ---@class string
  addonName,
  ---@class ns
  addon = ...
local L = addon.L
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local ldbi = LibStub:GetLibrary('LibDBIcon-1.0')
local function print(...) _G.print("|c259054ffSocialite:|r", ...) end

local function showConfig()
  Settings.OpenToCategory(addon.optionsFrame)
end

local function toggleGuildFrame()
  if type(ToggleGuildFrame) == "function" then
    ToggleGuildFrame(1)
  elseif type(ToggleFriendsFrame) == "function" then
    -- Classic clients keep the guild roster inside the Friends frame.
    ToggleFriendsFrame(3)
  end
end

local function normal(text)
  if not text then return "" end
  return NORMAL_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE;
end

local function highlight(text)
  if not text then return "" end
  return HIGHLIGHT_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE;
end

local function muted(text)
  if not text then return "" end
  return DISABLED_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE;
end

-- Init & config panel
do
	local eventFrame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
  eventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")

    if type(SocialiteSettings) ~= "table" then SocialiteSettings = {
      minimap={hide=true},
      showInAddonCompartment=true,
      DisableUsageText=false,
      TooltipWidth=0,
    } end
    local sv = SocialiteSettings
    if type(sv.minimap) ~= "table" then sv.minimap = {hide=true} end
    if type(sv.showInAddonCompartment) ~= "boolean" then sv.showInAddonCompartment = true end
    if type(sv.DisableUsageText) ~= "boolean" then sv.DisableUsageText = false end

    if type(sv.ShowLabel) ~= "boolean" then sv.ShowLabel = true end
    if type(sv.ShowRealID) ~= "boolean" then sv.ShowRealID = true end
    if type(sv.ShowRealIDApp) ~= "boolean" then sv.ShowRealIDApp = false end
    if type(sv.ShowRealIDBroadcasts) ~= "boolean" then sv.ShowRealIDBroadcasts = true end
    if type(sv.ShowRealIDFactions) ~= "boolean" then sv.ShowRealIDFactions = true end
    if type(sv.ShowRealIDNotes) ~= "boolean" then sv.ShowRealIDNotes = true end

    if type(sv.ShowFriends) ~= "boolean" then sv.ShowFriends = true end
    if type(sv.ShowFriendsNote) ~= "boolean" then sv.ShowFriendsNote = true end

    if type(sv.ShowGuild) ~= "boolean" then sv.ShowGuild = true end
    if type(sv.ShowGuildLabel) ~= "boolean" then sv.ShowGuildLabel = true end
    if type(sv.ShowGuildNote) ~= "boolean" then sv.ShowGuildNote = true end
    if type(sv.ShowGuildONote) ~= "boolean" then sv.ShowGuildONote = true end
    if type(sv.GuildSort) ~= "boolean" then sv.GuildSort = false end
    if type(sv.GuildSortAscending) ~= "boolean" then sv.GuildSortAscending = false end
    if type(sv.GuildSortKey) ~= "string" then sv.GuildSortKey = "rank" end

    if type(sv.ShowGroupMembers) ~= "boolean" then sv.ShowGroupMembers = true end
    if type(sv.ShowStatus) ~= "string" then sv.ShowStatus = "icon" end
    if type(sv.TooltipInteraction) ~= "string" then sv.TooltipInteraction = "always" end
    if type(sv.TooltipWidth) ~= "number" then sv.TooltipWidth = 0 end

    addon.db = sv


    ldbi:Register(addonName, addon.dataobj, addon.db.minimap)
    if sv.showInAddonCompartment then ldbi:AddButtonToCompartment(addonName) end

		self:SetScript("OnEvent", nil)
	end)
	eventFrame:RegisterEvent("ADDON_LOADED")
  addon.frame = eventFrame
end

-- Guild zones and character-friend areas are not pushed by the server; the
-- client cache only refreshes when something asks for it. Ask when the tooltip
-- opens and periodically while it stays open. The server silently ignores
-- GuildRoster() calls made within 10s of the previous one, so match that.
local ROSTER_REQUEST_INTERVAL = 10
local lastRosterRequest = -ROSTER_REQUEST_INTERVAL
local function requestRosterUpdates()
  local now = GetTime()
  if now - lastRosterRequest < ROSTER_REQUEST_INTERVAL then return end
  lastRosterRequest = now
  if addon.db.ShowGuild and IsInGuild() then
    if C_GuildInfo and C_GuildInfo.GuildRoster then
      C_GuildInfo.GuildRoster()
    elseif type(GuildRoster) == "function" then
      GuildRoster()
    end
  end
  if addon.db.ShowFriends and C_FriendList and C_FriendList.ShowFriends then
    C_FriendList.ShowFriends()
  end
end

-- data text
do
  local f = CreateFrame("frame")
  local text = "..loading.."
  local tooltip = ""
  local dataobj = ldb:NewDataObject("Socialite", {
    type = "data source",
    icon = "Interface\\FriendsFrame\\BroadcastIcon",
    text = text,
    OnEnter = function(frame)
      requestRosterUpdates()
      addon.tooltip:Clear("LEFT", 0, "RIGHT", "LEFT", "RIGHT")
      addon.tooltip:SetAutoHideDelay(0.2, frame)
      addon:updateTooltip(frame)
      addon.tooltip:SmartAnchorTo(frame)
      addon.tooltip:Show()
    end,
    OnLeave = function()
      local i = addon.db.TooltipInteraction
      if i == "never" or (i == "outofcombat" and InCombatLockdown()) then
        addon.tooltip:Hide()
      end
    end,
    OnClick = function(self, button)
      if button == "RightButton" or self == nil then
        showConfig()
      else
        if addon.db.ShowFriends or addon.db.ShowRealID then ToggleFriendsFrame(1) end
        if addon.db.ShowGuild then toggleGuildFrame() end
      end
    end
  })

  addon.dataobj = dataobj

  local function updateText()
    local text = ""
    local comps = {}

    -- Prefix/guild label
    if (addon.db.ShowLabel) then
      if (addon.db.ShowGuildLabel and addon.db.ShowGuild and IsInGuild()) then
        local guildName = GetGuildInfo("player") or "<unknown>"
        text = normal(tostring(guildName)..": ")
      else
        text = L['Socialite']..': '
      end
    end

    -- Battle.net Friends
    local showRealID = addon.db.ShowRealID
    local showRealIDApp = addon.db.ShowRealIDApp
    if showRealID then
      local friendsInGames, friendsInApps = addon:countRealID(showRealID)
      if showRealID then
        table.insert(comps, "|cff00A2E8"..friendsInGames.."|r")
      end
      if showRealIDApp then
        table.insert(comps, "|cffcccccc"..friendsInApps.."|r")
      end
    end

    -- Character Friends
    if addon.db.ShowFriends then
      table.insert(comps, "|cffFFFFFF"..C_FriendList.GetNumOnlineFriends().."|r")
    end

    -- Guild Members
    if addon.db.ShowGuild and IsInGuild() then
      local _, online = GetNumGuildMembers()
      table.insert(comps, "|cff00FF00"..online.."|r")
    end

    dataobj.text = text..table.concat(comps, " |cffffd200/|r ")
  end

  function addon:updateTooltip(frame)
    if not frame then return end
    -- remembered so header-collapse clicks can re-render in place
    addon._tooltipAnchorFrame = frame
    local ok, message = pcall(function ()
      addon.tooltip:Clear()
      addon.tooltip:AddColspanHeader(3, "LEFT", L["Socialite"])
      if not addon.db.DisableUsageText then
        addon.tooltip:AddColspanLine(3, "LEFT", muted(L["usageDescription"]))
      end
      local showRealID = addon.db.ShowRealID
      local showRealIDApp = addon.db.ShowRealIDApp
      if (showRealID or showRealIDApp) then
        local friends, bnet = addon:parseRealID(showRealID)
        if (showRealID) then
          addon:renderBattleNet(frame, friends, false, "CollapseRealID")
          if (showRealIDApp) then
            addon:renderBattleNet(frame, bnet, true, "CollapseRealIDApp")
          end
        end
      end
      if (addon.db.ShowFriends) then addon:renderFriends(frame, "CollapseFriends") end
      if (addon.db.ShowGuild and IsInGuild()) then addon:renderGuild(frame, "CollapseGuild") end
    end)
    addon._lastRender = GetTime()

    if (not ok) then
      print("error: "..message)
      error(message, 0)
    end
  end

  function addon:setDB(key, value)
    addon.db[key] = value
    updateText()
  end

  f:RegisterEvent("PLAYER_ENTERING_WORLD");
  f:RegisterEvent("PLAYER_LOGIN")
  f:RegisterEvent("GUILD_ROSTER_UPDATE")
  f:RegisterEvent("FRIENDLIST_UPDATE")
  f:RegisterEvent("CHAT_MSG_BN_INLINE_TOAST_BROADCAST")
  f:RegisterEvent("BN_FRIEND_INFO_CHANGED")
  f:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
  f:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")

  -- Re-render an open tooltip when fresh data arrives, coalescing bursts of
  -- events. Events within 0.5s of our own render are ignored: toggling
  -- SetGuildRosterShowOffline() in renderGuild can itself fire GUILD_ROSTER_UPDATE,
  -- which would otherwise re-render in a loop.
  local refreshPending = false
  local function refreshOpenTooltip()
    refreshPending = false
    if addon.tooltip:IsShown() and addon._tooltipAnchorFrame then
      addon:updateTooltip(addon._tooltipAnchorFrame)
    end
  end

  f:SetScript("OnEvent", function(self, event)
    updateText()
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then return end
    if refreshPending or not addon.tooltip:IsShown() then return end
    if addon._lastRender and GetTime() - addon._lastRender < 0.5 then return end
    refreshPending = true
    C_Timer.After(0.25, refreshOpenTooltip)
  end)

  -- Keep requesting fresh roster data while the tooltip is open.
  C_Timer.NewTicker(ROSTER_REQUEST_INTERVAL, function()
    if addon.db and addon.tooltip:IsShown() then requestRosterUpdates() end
  end)

end
