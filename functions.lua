local
  ---@class string
  addonName,
  ---@class ns
  addon = ...
local L = addon.L
local tooltip = addon.tooltip


local playerRealmName = GetRealmName()

local function tprint(tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  return toprint
end

local MOBILE_HERE_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat:0:0:0:0:16:16:0:16:0:16:73:177:73|t"
local MOBILE_BUSY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:0:0:0:0:16:16:0:16:0:16|t"
local MOBILE_AWAY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:0:0:0:0:16:16:0:16:0:16|t"
local CHECK_ICON = "|TInterface\\Buttons\\UI-CheckBox-Check:0:0|t"

local function ternary(cond, a, b)
	if cond then return a end
  return b
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

local function IsOfficerNoteVisible(...)
  if (not addon.db.ShowGuildONote) then return false end
  if (type(CanViewOfficerNote) == "function") then
    return CanViewOfficerNote(...)
  end
  return C_GuildInfo.CanViewOfficerNote(...)
end

-- Class support
-- Maps localized class names (both genders) back to the class token so names can
-- be class-coloured. Built from the LOCALIZED_CLASS_NAMES_* tables instead of
-- GetNumClasses()/GetClassInfo(): on Classic clients the class ID range covers
-- classes that don't exist in that flavour and GetClassInfo() returns nil for
-- them, which made the old loop error with "table index is nil".
local Classes = {}
for token, localized in pairs(_G.LOCALIZED_CLASS_NAMES_MALE or {}) do
  Classes[localized] = token
end
for token, localized in pairs(_G.LOCALIZED_CLASS_NAMES_FEMALE or {}) do
  Classes[localized] = token
end

local function addDoubleLine(indented, left, right)
	if indented then
		return tooltip:AddLine(nil, nil, left, right)
	else
		return tooltip:AddColspanLine(3, "LEFT", left, 1, "RIGHT", right)
	end
end

local function clickHeader(frame, collapseVar)
  addon.db[collapseVar] = not addon.db[collapseVar]
  if addon._tooltipAnchorFrame then
    addon:updateTooltip(addon._tooltipAnchorFrame)
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
  -- className may be a localized name (friends list, Battle.net) or already a
  -- class token (guild roster classFileName); accept either.
  local class = className and (Classes[className] or (RAID_CLASS_COLORS[className] and className))
  local colorInfo = class and RAID_CLASS_COLORS[class]
  local color = colorInfo and colorInfo.colorStr or "ffcccccc"
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

local function getStatusText(status)
	if addon.db.ShowStatus == "text" then
		if status ~= "" then
			return "|cffFFFFFF"..tostring(status).."|r "
		end
	end
	return ""
end

-- Right-click context menu for guild members. Uses the MenuUtil API that ships
-- with 11.x+ retail and the Classic clients built on the same UI codebase.
local function showGuildRightClick(player, isMobile)
  if not (MenuUtil and MenuUtil.CreateContextMenu) then
    print("Socialite: the right-click menu is not available on this client.")
    return
  end
  -- Full Name-Realm is kept for the API calls; the realm is stripped for display.
  local displayName = Ambiguate(player, "none")
  MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
    rootDescription:CreateTitle(displayName)
    rootDescription:CreateButton(WHISPER, function()
      ChatFrame_SendTell(player)
    end)
    if not isMobile then
      rootDescription:CreateButton(INVITE, function()
        C_PartyInfo.InviteUnit(player)
      end)
    end
    rootDescription:CreateDivider()
    rootDescription:CreateButton(WHO, function()
      C_FriendList.SendWho("n-" .. displayName)
    end)
  end)
end

local function clickPlayer(frame, info, button)
  local player, isGuild, isMobile = unpack(info)
  if player ~= "" then
    if button == "LeftButton" then
      if IsAltKeyDown() then
        C_PartyInfo.InviteUnit(player)
      else
        ChatFrame_SendTell(player)
      end
    elseif button == "RightButton" then
      if isGuild then
        showGuildRightClick(player, isMobile)
      else
        local info = C_FriendList.GetFriendInfo(player);
        if info then
          FriendsFrame_ShowDropdown(info.name, info.connected, nil, nil, nil, 1);
        end
      end
    end
  end
end

-- Invites a Battle.net friend to the group. Blizzard's FriendsFrame_BattlenetInvite
-- already handles friends who are online on several WoW accounts (it shows the
-- travel-pass dropdown), so prefer it when the client provides it. Otherwise
-- invite the single eligible game account, if there is exactly one.
local function sendBattleNetInvite(bnetAccountID)
  if type(FriendsFrame_BattlenetInvite) == "function" then
    FriendsFrame_BattlenetInvite(nil, bnetAccountID)
    return
  end
  local playerFactionGroup = UnitFactionGroup("player")
  local index = BNGetFriendIndex(bnetAccountID)
  if not index then return end
  local validGameAccountID = nil
  for i = 1, C_BattleNet.GetFriendNumGameAccounts(index) do
    local ai = C_BattleNet.GetFriendGameAccountInfo(index, i)
    if ai and ai.clientProgram == BNET_CLIENT_WOW and ai.factionName == playerFactionGroup and ai.realmID ~= 0 then
      if validGameAccountID and validGameAccountID ~= ai.gameAccountID then
        -- More than one eligible account; we can't tell which one to invite.
        print("Socialite: this friend is online on more than one character, use the Friends list to invite them.")
        return
      end
      validGameAccountID = ai.gameAccountID
    end
  end
  if validGameAccountID then
    BNInviteFriend(validGameAccountID)
  end
end

local function clickRealID(frame, info, button)
  local accountName, bnetAccountID = unpack(info)
  if button == "LeftButton" then
    if IsAltKeyDown() then
      if CanGroupWithAccount(bnetAccountID) then
        sendBattleNetInvite(bnetAccountID)
      end
    else
      if ChatFrameUtil and ChatFrameUtil.SendBNetTell then
        ChatFrameUtil.SendBNetTell(accountName)
      else
        ChatFrame_SendBNetTell(accountName)
      end
    end
  elseif button == "RightButton" then
    FriendsFrame_ShowBNDropdown(accountName, true, nil, nil, nil, 1, bnetAccountID);
  end
end

--[[
spacer(width, count)
PARAMETERS:
  width - number - width of the space. Defaults to TextHeight
  count - number - number of spacers. Defaults to 1
RETURNS:
string - the spacer
--]]
local function spacer(width, count)
	if not width then width = 0 end
	if not count then count = 1 end
	local height = (width == 0) and 0 or 1
	return ("|T:"..height..":"..width.."|t"):rep(count)
end

--[[
  If enabled, returns an icon if the friend is currently in your group or raid.
  @param table info
--]]
local function getGroupIndicator(info)
  if not addon.db.ShowGroupMembers or not IsInGroup() then return "" end
  local name
  if info.focus then
    if info.focus.realmName and info.focus.realmName ~= playerRealmName then
      name = info.focus.name.."-"..info.focus.realmName
    else
      name = info.focus.name
    end
  elseif info.realmName then
    name = info.name.."-"..info.realmName
  else
    name = info.name
  end

  if UnitInParty(name) or UnitInRaid(name) then return CHECK_ICON end
  return spacer()
end

--[[
  Parses and returns character and battle.net friend & character information
  @see https://wow.gamepedia.com/API_C_BattleNet.GetFriendAccountInfo
  @see https://wow.gamepedia.com/API_C_BattleNet.GetFriendGameAccountInfo

  Returns two tables, first is for friends and second is for bnet. Both are arrays of identically
  -formatted tables. "friends" is all the normal RealID friends and "bnet" is all the friends in
  the Battle.Net app. Any friends in the app and elsewhere are considered to only be elsewhere.

  The individual player tables are formatted as follows: {
      bnetAccountID,
      accountName,
      battleTag: nil if not isBattleTagFriend,
      isAFK,
      isDND,
      broadcastText,
      note,
      focus: {
          name,
          client,
          realmName,
          realmID,
          faction,
          race,
          class,
          zone,
          level,
          gameText,
          location -- zone, or gameText if zone is "" or nil
      },
      alts: nil or non-empty array of tables identical to focus,
      bnet: nil or table identical to focus
  }
  filterClients indicates whether friends with both bnet and non-bnet should
  be filtered out of the bnet list

  @param Boolean filterClients  A flag indicating if the non-WoW clients should be filtered out
  @returns {table friends, table bnetFriends}
]]
function addon:parseRealID(filterClients)
  --[[
    Returns the rich location information for a character

    @param struct BNetGameAccountInfo
    @returns String
  ]]
  local function getLocation(ai)
    if ai.clientProgram == BNET_CLIENT_WOW and ai.realmName == playerRealmName then
      return ai.areaName
    end
    return ai.richPresence
  end

  local _, numOnline = BNGetNumFriends()

  local friends, bnets = {}, {}
  for i=1, numOnline do
    local accountInfo = C_BattleNet.GetFriendAccountInfo(i);
    local toons, focus, bnet = {}, nil, nil

    for j=1, C_BattleNet.GetFriendNumGameAccounts(i) do
      local ai = C_BattleNet.GetFriendGameAccountInfo(i, j)

      local toon = {
        name = ai.characterName,
        client = ai.clientProgram,
        realmName = ai.realmName,
        realmID = ai.realmID,
        faction = ai.factionName,
        race = ai.raceName,
        class = ai.className,
        zone = ai.areaName,
        level = ai.characterLevel,
        location = getLocation(ai),
      }

      if ai.clientProgram == BNET_CLIENT_APP or ai.clientProgram == "BSAp" then
        -- assume no more than 1 bnet toon, but check anyway
        if not bnet then bnet = toon end
      elseif ai.hasFocus then
        if focus ~= nil then table.insert(toons, 1, focus) end
        focus = toon
      else
        table.insert(toons, toon)
      end
    end

    if focus == nil and #toons > 0 then
      focus = toons[1]
      table.remove(toons, 1)
    end

    if focus ~= nil or bnet ~= nil then
      local friend = {
        bnetAccountID = accountInfo.bnetAccountID,
        accountName = accountInfo.accountName,
        battleTag = ternary(accountInfo.isBattleTagFriend, accountInfo.battleTag, accountInfo.accountName),
        isAFK = accountInfo.gameAccountInfo.isAFK,
        isDND = accountInfo.gameAccountInfo.isDND,
        broadcastText = accountInfo.broadcastText,
        note = accountInfo.note,
        focus = focus,
        alts = toons,
        bnet = bnet
      }
      if focus ~= nil then table.insert(friends, friend) end
      if bnet ~= nil and (not filterClients or focus == nil) then table.insert(bnets, friend) end
    end
  end

  return friends, bnets
end

-- Returns two counts, first is for friends and second is for bnet.
-- Identical to counting the tables from parseRealID() but cheaper
-- filterClients indicates if bnet should be filtered out of friends
-- and vice versa.
function addon:countRealID(filterClients)
  local friends, bnet = 0, 0
  local _, numOnline = BNGetNumFriends()
  for i=1, numOnline do
    local ai = C_BattleNet.GetFriendAccountInfo(i);
    local ga = ai and ai.gameAccountInfo
    if (ga and ga.clientProgram == BNET_CLIENT_APP) or (ga and ga.clientProgram == "BSAp") then
      bnet = bnet + 1
    else
      if (ga and ga.clientProgram ~= "") then
        friends = friends + 1
      end
    end
  end
  return friends, bnet
end

function addon:renderBattleNet(tooltip, friends, isBnetClient, collapseVar)
  local function getFactionIndicator(faction, client)
    if addon.db.ShowRealIDFactions then
      if client == BNET_CLIENT_WOW then
        if faction == "Horde" or faction == "Alliance" then
          return "|TInterface\\PVPFrame\\PVP-Currency-"..faction..":0|t"
        elseif faction == "Neutral" then
          return "|TInterface\\FriendsFrame\\Battlenet-WoWicon:0|t"
        end
      elseif client and client ~= "" then
        if BNet_GetClientEmbeddedAtlas then
          return BNet_GetClientEmbeddedAtlas(client)
        elseif BNet_GetClientEmbeddedTexture then
          return BNet_GetClientEmbeddedTexture(client, 0)
        end
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

  for _, friend in ipairs(friends) do
    local left = ""

    local focus = isBnetClient and friend.bnet or friend.focus

    -- group member indicator
    local check = getGroupIndicator(friend)

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
        name = "|cffCCCCCC"..(focus.name or "").."|r"
      end
      left = left..getFactionIndicator(focus.faction, focus.client).." "
      left = left..getStatusIcon(playerStatus)
      left = left..name.." "
    end

    -- Full name
    left = left.."[|cff00A2E8"..friend.battleTag.."|r] "

    -- Status
    left = left..getStatusText(playerStatus).." "

    local broadcastText = friend.broadcastText

    -- Note
    if addon.db.ShowRealIDNotes then
      local note = friend.note
      if note and note ~= "" then
        left = left.."|cffFFFFFF"..note.."|r"
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

    local y = addon.tooltip:AddLine(check, level, left, right)
    addon.tooltip:SetLineScript(y, "OnMouseDown", clickRealID, { friend.accountName, friend.bnetAccountID })

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
          left = _G.FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE:format(tostring(toon.name)..cooperateLabel, tostring(toon.level), tostring(toon.race), tostring(toon.class))
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


function addon:renderFriends(tooltip, collapseVar)
	addon.tooltip:AddLine()
  local numTotal = C_FriendList.GetNumFriends()
  local numOnline = C_FriendList.GetNumOnlineFriends()

	local collapsed = addon.db[collapseVar]
	addHeader(L.TOOLTIP_FRIENDS, "FFFFFF", numOnline, numTotal, collapsed, collapseVar)

	if collapsed then return end

	for i=1, numOnline do
		local left = ""

		local info = C_FriendList.GetFriendInfoByIndex(i)
		local playerStatus = nil
		if info.afk == true then
			playerStatus = _G.CHAT_FLAG_AFK
		elseif info.dnd == true then
			playerStatus = _G.CHAT_FLAG_DND
		end
		-- Group indicator
    local check = getGroupIndicator(info)

		-- Level
		local level = "|cffFFFFFF"..info.level.."|r"

		-- Status icon
		left = left..getStatusIcon(playerStatus)

		-- Name
		left = left..colorText(info.name, info.className).." "

		-- Status
		left = left..getStatusText(playerStatus).." "

		-- Notes
		if addon.db.ShowFriendsNote then
			if info.notes and info.notes ~= "" then
				left = left.."|cffFFFFFF"..info.notes.."|r "
			end
		end
		local right = ""
		if info.area ~= nil then
			right = "|cffFFFFFF"..info.area.."|r"
		end

		local y = addon.tooltip:AddLine(check, level, left, right)
		addon.tooltip:SetLineScript(y, "OnMouseDown", clickPlayer, { info.name, false, false, false })
	end
end


function addon:renderGuild(tooltip, collapseGuildVar)
  -- Unguilded characters have no roster; on Classic the roster APIs can also
  -- report stale counts with nil entries, so bail out here as well as at the call site.
  if not IsInGuild() then return end

  local function processGuildMember(i, tooltip)
    local left = ""

    local name, rank, rankIndex, level, class, zone, note, officerNote, online, playerStatus, classFileName, achievementPoints, achievementRank, isMobile = GetGuildRosterInfo(i)
    if not name then return end

    local origname = name
    name = Ambiguate(name, "guild")

    local check = getGroupIndicator({ name = name })

    -- fix name
    -- local origname = name
    if name == "" then
      name = "Unknown"
    end

    -- fix playerStatus
    if playerStatus == 1 then
      playerStatus = CHAT_FLAG_AFK
    elseif playerStatus == 2 then
      playerStatus = CHAT_FLAG_DND
    else
      playerStatus = ""
    end

    if isMobile then
      if playerStatus == CHAT_FLAG_DND then
        name = MOBILE_BUSY_ICON..name
      elseif playerStatus == CHAT_FLAG_AFK then
        name = MOBILE_AWAY_ICON..name
      else
        name = MOBILE_HERE_ICON..name
      end
    end

    -- Level
    local level = "|cffFFFFFF"..level.."|r"

    -- Status icon
    if not isMobile then
      -- Mobile icon already shows status
      left = left..getStatusIcon(playerStatus)
    end

    -- Name
    left = left..colorText(name, class).." "

    -- Status
    left = left..getStatusText(playerStatus).." "

    -- Rank
    left = left..rank.."  "

    -- Notes
    if addon.db.ShowGuildNote then
      if note and note ~= "" then
        left = left.."|cffFFFFFF"..note.."|r  "
      end
    end

    -- Officer Notes
    if IsOfficerNoteVisible() then
      if officerNote and officerNote ~= "" then
        left = left.."|cffAAFFAA"..officerNote.."|r  "
      end
    end

    -- Location
    local right = ""
    if zone and zone ~= "" then
      right = "|cffFFFFFF"..zone.."|r"
    end

    local y = addon.tooltip:AddLine(check, level, left, right)
    addon.tooltip:SetLineScript(y, "OnMouseDown", clickPlayer, { origname, true, isMobile })
  end

  -- collectGuildRosterInfo(split, sortKey, sortAscending)
  -- collects and sorts the guild roster
  -- PARAMETERS:
  --   split - boolean - whether to split the remote chat
  --   sortKey - string - the key to sort by. nil means no sort
  --   sortAscending - boolean - whether the sort is ascending
  -- RETURNS:
  --   table - array of guild roster indices
  --   number - total guild members
  --   number - online guild members
  --
  -- If `split` is true, the online and remote sections of the roster are
  -- sorted independently. If false, they're sorted into the same table.
  -- Every entry in the roster is an index suitable for GetGuildRosterInfo()
  local function collectGuildRosterInfo(sortKey, sortAscending)
    SetGuildRosterShowOffline(false)

    local guildTotal, guildOnline = GetNumGuildMembers()
    guildTotal, guildOnline = guildTotal or 0, guildOnline or 0

    local onlineTable = {}
    for i = 1, guildOnline do
      onlineTable[i] = i
    end

    if sortKey then
      local function sortFunc(a, b)
        local aname, _, arankIndex, alevel, aclass, azone, anote = GetGuildRosterInfo(a)
        local bname, _, brankIndex, blevel, bclass, bzone, bnote = GetGuildRosterInfo(b)
        if sortKey == "rank" and arankIndex ~= brankIndex then
          -- rank indices are reversed from what you'd expect, so flip the meaning of ascending
          return ternary(sortAscending, arankIndex > brankIndex, arankIndex < brankIndex)
        end
        if sortKey == "level" and alevel ~= blevel then
          return ternary(sortAscending, alevel < blevel, alevel > blevel)
        end
        if sortKey == "class" and aclass ~= bclass then
          return ternary(sortAscending, aclass < bclass, aclass > bclass)
        end
        if sortKey == "zone" and azone ~= bzone then
          -- zones are sometimes nil when enough players are online
          if azone == nil then azone = "" end
          if bzone == nil then bzone = "" end
          return ternary(sortAscending, azone < bzone, azone > bzone)
        end
        if sortKey == "note" and anote ~= bnote then
          return ternary(sortAscending, anote < bnote, anote > bnote)
        end
        aname = string.lower(aname or "Unknown")
        bname = string.lower(bname or "Unknown")
        -- if name is the secondary sort, it's always ascending
        if sortAscending or sortKey ~= "name" then
          return aname < bname
        else
          return aname > bname
        end
      end

      table.sort(onlineTable, sortFunc)
    end

    return onlineTable, guildTotal, guildOnline
  end

	addon.tooltip:AddLine()
	local wasOffline = GetGuildRosterShowOffline()
	if wasOffline then
		-- SetGuildRosterShowOffline() seems to sometimes trigger GUILD_ROSTER_UPDATE
		SetGuildRosterShowOffline(false)
	end

	local sortKey = addon.db.GuildSort and addon.db.GuildSortKey or nil
	local roster, numTotal, numOnline = collectGuildRosterInfo(sortKey, addon.db.GuildSortAscending or false)
	local collapseGuild = addon.db[collapseGuildVar]
	addHeader(L.TOOLTIP_GUILD, "00FF00", numOnline, numTotal, collapseGuild, collapseGuildVar)

	for i, guildIndex in ipairs(roster) do
    processGuildMember(guildIndex, tooltip)
	end

	if wasOffline then
		SetGuildRosterShowOffline(wasOffline)
	end
end
