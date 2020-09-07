local addonName, addon = ...
local L = addon.L
local tooltip = addon.tooltip

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

-- Class support
local Classes = {}
for i = 1, _G.GetNumClasses() do
  local name, className, classId = _G.GetClassInfo(i)
  Classes[_G.LOCALIZED_CLASS_NAMES_MALE[className]] = className
  Classes[_G.LOCALIZED_CLASS_NAMES_FEMALE[className]] = className
end

local function addDoubleLine(indented, left, right)
	if indented then
		return tooltip:AddLine(nil, nil, left, right)
	else
		return tooltip:AddColspanLine(3, "LEFT", left, 1, "RIGHT", right)
	end
end

local function addHeader(header, color, online, total, collapsed, collapseVar)
	header = header..":"
	local left = normal(header)
	if collapsed then
		left = left.." |cff808080"..L.TOOLTIP_COLLAPSED.."|r"
	end
	if color then color = "|cff"..color end
	local right = (color or "")..(online or "")..(color and "|r")..normal("/"..total)
	local y = addDoubleLine(false, left, right)
	tooltip:SetLineScript(y, "OnMouseDown", clickHeader, collapseVar)
	return y
end

local function colorText(text, className)
	local classIndex, coloredText=nil

	local class = Classes[className]
	local color = nil
	if class == nil then
		color = "ffcccccc"
	else
		color = RAID_CLASS_COLORS[class].colorStr
	end
	return "|c"..color..text.."|r"
end

local function getStatusIcon(status)
	if addon.db.ShowStatus == "icon" then
		if status == CHAT_FLAG_AFK then
			return "|T"..FRIENDS_TEXTURE_AFK..":0|t"
		elseif status == CHAT_FLAG_DND then
			return "|T"..FRIENDS_TEXTURE_DND..":0|t"
		end
	end
	return ""
end

local function clickRealID(frame, info, button)
	local accountName, bnetIDAccount = unpack(info)
	if button == "LeftButton" then
		if IsAltKeyDown() then
			if CanGroupWithAccount(bnetIDAccount) then
				sendBattleNetInvite(bnetIDAccount)
			end
		else
			ChatFrame_SendBNetTell(accountName)
		end
	elseif button == "RightButton" then
		showRealIDRightClick(accountName, bnetIDAccount)
	end
end

-- Returns two tables, first is for friends and second is for bnet.
-- Both are arrays of identically-formatted tables. "friends" is all the normal RealID friends
-- and "bnet" is all the friends in the Battle.Net app. Any friends in the app and elsewhere are considered
-- to only be elsewhere.
-- The individual player tables are formatted as follows: {
--     bnetIDAccount,
--     accountName,
--     battleTag: nil if not isBattleTagPresence,
--     isAFK,
--     isDND,
--     broadcastText,
--     noteText,
--     focus: {
--         name,
--         client,
--         realmName,
--         realmID,
--         faction,
--         race,
--         class,
--         zone,
--         level,
--         gameText,
--         location -- zone, or gameText if zone is "" or nil
--     },
--     alts: nil or non-empty array of tables identical to focus,
--     bnet: nil or table identical to focus
-- }
-- filterClients indicates whether friends with both bnet and non-bnet should
-- be filtered out of the bnet list
function addon:parseRealID(filterClients)
  local playerRealmName = GetRealmName()
  local numTotal, numOnline = BNGetNumFriends()

  -- lately we've been seeing BNGetFriendGameAccountInfo returning duplicate info for a player,
  -- making it seem as though they're playing the same toon 3 times simultaneously.
  -- Work around that by filtering out duplicates using the bnetIDGameAccount.
  local seen = {}

  local friends, bnets = {}, {}
  for i=1, numOnline do
    local bnetIDAccount, accountName, battleTag, isBattleTagPresence, _, _, _, _, _, isAFK, isDND, broadcastText, noteText = BNGetFriendInfo(i)
    if not isBattleTagPresence then
      battleTag = nil
    end

    table.wipe(seen)

    local toons, focus, bnet
    for j=1, BNGetNumFriendGameAccounts(i) do
      local hasFocus, toonName, client, realmName, realmID, faction, race, class, _, zoneName, level, gameText, _, _, _, bnetIDGameAccount = BNGetFriendGameAccountInfo(i, j)
      -- in the past I've seen this return nil data, so use the client as a marker
      if client and seen[bnetIDGameAccount] == nil then
        local toon = {
          name = toonName,
          client = client,
          realmName = realmName,
          realmID = realmID,
          faction = faction,
          race = race,
          class = class,
          zone = zoneName,
          level = level,
          gameText = gameText
        }
        if client == BNET_CLIENT_WOW then
          if zoneName and zoneName ~= "" then
            if realmName and realmName ~= "" and realmName ~= playerRealmName then
              toon.location = zoneName.." - "..realmName
            else
              toon.location = zoneName
            end
          else
            toon.location = realmName
          end
        else
          toon.location = gameText
        end
        seen[bnetIDGameAccount] = toon
        if client == "App" or client == "BSAp" then
          -- assume no more than 1 bnet toon, but check anyway
          if bnet == nil then bnet = toon end
        elseif hasFocus then
          if focus ~= nil then
            if toons == nil then toons = {} end
            table.insert(toons, 1, focus)
          end
          focus = toon
        else
          if toons == nil then toons = {} end
          table.insert(toons, toon)
        end
      end
    end

    if focus == nil and toons ~= nil and #toons > 0 then
      focus = toons[1]
      table.remove(toons, 1)
      if #toons == 0 then toons = nil end
    end

    if focus ~= nil or bnet ~= nil then
      local friend = {
        bnetIDAccount = bnetIDAccount,
        accountName = accountName,
        battleTag = battleTag,
        isAFK = isAFK,
        isDND = isDND,
        broadcastText = broadcastText,
        noteText = noteText,
        focus = focus,
        alts = toons,
        bnet = bnet
      }
      if focus ~= nil then
        table.insert(friends, friend)
      end
      if bnet ~= nil and (not filterClients or focus == nil) then
        table.insert(bnets, friend)
      end
    end
  end

  return friends, bnets
end

-- Returns two counts, first is for friends and second is for bnet.
-- Identical to counting the tables from parseRealID() but cheaper
-- filterClients indicates if bnet should be filtered out of friends
-- and vice versa.
function addon:countRealID(filterClients)
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

function addon:renderBattleNet(tooltip, friends, isBnetClient, collapseVar)
  local function getGroupIndicator(bnetIDAccount, playerRealmName)
    if addon.db.ShowGroupMembers then
      local index = BNGetFriendIndex(bnetIDAccount)
      for i = 1, BNGetNumFriendGameAccounts(index) do
        local _, characterName, client, realmName = BNGetFriendGameAccountInfo(index, i)
        if client == BNET_CLIENT_WOW then
          if realmName and realmName ~= "" and realmName ~= playerRealmName then
            realmName = realmName:gsub("[%s%-]", "")
            characterName = characterName.."-"..realmName
          end
          if UnitInParty(characterName) or UnitInRaid(characterName) then
            return CHECK_ICON
          end
        end
      end
      return spacer()
    end
    return ""
  end
  local function getFactionIndicator(faction, client)
    if addon.db.ShowRealIDFactions then
      if client == BNET_CLIENT_WOW then
        if faction == "Horde" or faction == "Alliance" then
          return "|TInterface\\PVPFrame\\PVP-Currency-"..faction..":0|t"
        elseif faction == "Neutral" then
          return "|TInterface\\FriendsFrame\\Battlenet-WoWicon:0|t"
        end
      elseif client and client ~= "" then
        return "|T"..BNet_GetClientTexture(client)..":0|t"
      end
      return spacer()
    end
    return ""
  end

  addon.tooltip:AddLine()
  local numTotal = BNGetNumFriends()

  local header
  if (isBnetClient) then
    header = L.TOOLTIP_REALID_APP
  else
    header = L.TOOLTIP_REALID
  end
  local collapsed = addon.db[collapseVar]
  addHeader(header, "00A2E8", #friends, numTotal, collapsed, collapseVar)

  if collapsed then return end

  local playerRealmName = GetRealmName()
  for _, friend in ipairs(friends) do
    local left = ""

    local focus = isBnetClient and friend.bnet or friend.focus

    -- group member indicator
    local check = getGroupIndicator(friend.bnetIDAccount, playerRealmName)

    -- player status
    local playerStatus = ""
    if friend.isAFK then
      playerStatus = CHAT_FLAG_AFK
    elseif friend.isDND then
      playerStatus = CHAT_FLAG_DND
    end

    -- Character (and faction)
    local level = friend.level
    do
      local name
      if focus.client == BNET_CLIENT_WOW then
        level = "|cffFFFFFF"..focus.level.."|r"
        name = focus.name and colorText(focus.name, focus.class) or "|cffFFFFFFUnknown|r"
      else
        local clientname = focus.client
        if clientname == BNET_CLIENT_WTCG then
          clientname = "HS"
        elseif clientname == "App" then
          clientname = "BN"
        end
        level = "|cffFFFFFF"..(clientname or "??").."|r"
        name = "|cffCCCCCC"..(focus.name or "Unknown").."|r"
      end
      left = left..getFactionIndicator(focus.faction, focus.client)
      left = left..getStatusIcon(playerStatus)
      left = left..name.." "
    end

    -- Full name
    left = left.."[|cff00A2E8"..(friend.battleTag or friend.accountName).."|r] "

    -- Status
    left = left..getStatusText(playerStatus).." "

    local broadcastText = friend.broadcastText

    -- Note
    if addon.db.ShowRealIDNotes then
      local noteText = friend.noteText
      if noteText and noteText ~= "" then
        left = left.."|cffFFFFFF"..noteText.."|r"
        -- prepend "\n" onto broadcast to put it onto next line
        if broadcastText and broadcastText ~= "" then
          broadcastText = "\n"..broadcastText
        end
      end
    end

    -- Broadcast
    local extraLines
    if addon.db.ShowRealIDBroadcasts then
      if broadcastText and broadcastText ~= "" then
        -- watch out for newlines in the broadcast text
        local color = "|cff00A2E8"
        local firstLine = broadcastText:match("^([^\n]*)\n")
        if firstLine then
          extraLines = {}
          for line in broadcastText:gmatch("\n([^\n]*)") do
            extraLines[#extraLines+1] = color..line.."|r"
          end
          broadcastText = firstLine
        end
        if broadcastText ~= "" then
          left = left..color..broadcastText.."|r"
        end
      end
    end

    -- Location
    local right = focus.location and focus.location ~= "" and ("|cffFFFFFF"..focus.location.."|r") or ""

    local y = tooltip:AddLine(check, level, left, right)
    tooltip:SetLineScript(y, "OnMouseDown", clickRealID, { friend.accountName, friend.bnetIDAccount })

    -- Extra lines
    if extraLines then
      for _, line in ipairs(extraLines) do
        addDoubleLine(true, line)
      end
    end

    -- Additional toons
    if friend.alts ~= nil then
      local playerFactionGroup = UnitFactionGroup("player")
      for _, toon in ipairs(friend.alts) do
        local left, right
        if toon.client == BNET_CLIENT_WOW then
          local cooperateLabel = ""
          if toon.realmName ~= playerRealmName or toon.faction ~= playerFactionGroup then
            cooperateLabel = _G.CANNOT_COOPERATE_LABEL
          end
          left = _G.FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE:format(toon.name..cooperateLabel, toon.level, toon.race, toon.class)
        else
          left = toon.name
        end
        left = getFactionIndicator(toon.faction, toon.client).."|cffFEE15C"..FRIENDS_LIST_PLAYING.."|cffFFFFFF "..(left or "Unknown").."|r"
        right = "|cffFFFFFF"..(toon.location or "").."|r"
        addDoubleLine(true, left, right)
      end
    end
  end
end
