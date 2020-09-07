local addonName, addon = ...
local L = addon.L
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local function print(...) _G.print("|c259054ffSocialite:|r", ...) end

local function showConfig()
  InterfaceOptionsFrame_OpenToCategory(addonName)
  InterfaceOptionsFrame_OpenToCategory(addonName)
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

    if type(SocialiteSettings) ~= "table" then SocialiteSettings = {} end
    local sv = SocialiteSettings
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
    if type(sv.ShowSplitRemoteChat) ~= "boolean" then sv.ShowSplitRemoteChat = false end
    if type(sv.GuildSort) ~= "boolean" then sv.GuildSort = false end
    if type(sv.GuildSortInverted) ~= "boolean" then sv.GuildSortInverted = false end
    if type(sv.GuildSortKey) ~= "string" then sv.GuildSortKey = "rank" end

    if type(sv.ShowStatus) ~= "string" then sv.ShowStatus = "icon" end
    if type(sv.TooltipInteraction) ~= "string" then sv.TooltipInteraction = "always" end

    addon.db = sv

		SlashCmdList.SOCIALITE = showConfig
		SLASH_SOCIALITE1 = "/social"
		SLASH_SOCIALITE2 = "/socialite"

		self:SetScript("OnEvent", nil)
	end)
	eventFrame:RegisterEvent("ADDON_LOADED")
  addon.frame = eventFrame
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
    OnClick = function(self, button)
      if button == "RightButton" then
        showConfig()
      else
        if addon.db.ShowFriends or addon.db.ShowRealID or addon.db.ShowRealIDApp then
          -- ToggleFriendsFrame(1); -- friends tab
          -- We want to show the friends tab, but there's a taint issue :/
          if FriendsFrame:IsShown() then
            HideUIPanel(FriendsFrame)
          else
            ShowUIPanel(FriendsFrame)
          end
        end

        if addon.db.ShowGuild then ToggleGuildFrame(1) end
      end
    end
  })

  -- Returns two counts, first is for friends and second is for bnet.
  -- Identical to counting the tables from parseRealID() but cheaper
  -- filterClients indicates if bnet should be filtered out of friends
  -- and vice versa.
  local function countRealID(filterClients)
    local numTotal, numOnline = BNGetNumFriends()

    local friends, bnet = 0, 0
    for i=1, numOnline do
      local isRegular, isBnet = false, false
      for j=1, BNGetNumFriendGameAccounts(i) do
        local client = select(3, BNGetFriendGameAccountInfo(i, j))
        if client then
          if client == "App" then
            isBnet = true
          else
            isRegular = true
            if filterClients then
              isBnet = false
              break
            end
          end
        end
      end
      if isBnet then bnet = bnet + 1 end
      if isRegular then friends = friends + 1 end
    end

    return friends, bnet
  end

  local function updateText()
    showConfig()
    local text = L["Socialite"]..": "
    local comps = {}

    -- Prefix/guild label
    if addon.db.ShowGuildLabel and addon.db.ShowGuild and IsInGuild() then
      local guildName = GetGuildInfo("player")
      if guildName then text = guildName..": " end
    end

    -- Battle.net Friends
    local showRealID = addon.db.ShowRealID
    local showRealIDApp = addon.db.ShowRealIDApp
    if showRealID or showRealIDApp then
      local numFriends, numBnet = countRealID(showRealID)
      if showRealID then
        table.insert(comps, "|cff00A2E8"..numFriends.."|r")
      end
      if showRealIDApp then
        table.insert(comps, "|cff00A2E8"..numBnet.."|r")
      end
    end

    -- Character Friends
    if addon.db.ShowFriends then
      table.insert(comps, "|cffFFFFFF"..C_FriendList.GetNumOnlineFriends().."|r")
    end

    -- Guild Members
    if addon.db.ShowGuild and IsInGuild() then
      local online, remote = select(2, GetNumGuildMembers())
      local _, online, remote = GetNumGuildMembers()
      if addon.db.ShowSplitRemoteChat then
        remote = remote - online
      else
        online, remote = remote, nil
      end
      table.insert(comps, "|cff00FF00"..online.."|r")
      if remote ~= nil then
        table.insert(comps, "|cff00BB00"..remote.."|r")
      end
    end

    dataobj.text = text..table.concat(comps, " |cffffd200/|r ")
  end

  local function updateTooltip()
    print("Update tooltip!")
    GameTooltip:AddLine(L["Socialite"].."\n")
    GameTooltip:AddLine(muted("NYI"))
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

  f:SetScript("OnEvent", updateText)

  function dataobj:OnTooltipShow() updateTooltip() end

  function dataobj:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
    GameTooltip:ClearLines()
    dataobj.OnTooltipShow()
    GameTooltip:Show()
  end

  function dataobj:OnLeave()
    GameTooltip:Hide()
  end
end
