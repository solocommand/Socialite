local addonName, addonTable = ...
local L = addonTable.L

----------------------------------------------------------------------
--  Libraries
----------------------------------------------------------------------

local LibQTip = _G.LibStub('LibQTip-1.0')

----------------------------------------------------------------------
--  Global variables
----------------------------------------------------------------------

-- GLOBALS: table math select string tostring tonumber ipairs print pcall select error unpack

local _G = _G
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local IsInGuild, IsInGroup = _G.IsInGuild, _G.IsInGroup
local UnitInParty, UnitInRaid = _G.UnitInParty, _G.UnitInRaid
local GuildRoster = _G.GuildRoster
local GetGuildInfo, GetGuildRosterInfo, GetNumGuildMembers = _G.GetGuildInfo, _G.GetGuildRosterInfo, _G.GetNumGuildMembers
local GetGuildRosterShowOffline, SetGuildRosterShowOffline = _G.GetGuildRosterShowOffline, _G.SetGuildRosterShowOffline
local GetNumFriends, GetFriendInfo = _G.GetNumFriends, _G.GetFriendInfo
local ToggleFriendsFrame, ToggleGuildFrame = _G.ToggleFriendsFrame, _G.ToggleGuildFrame
local FriendsFrame_Update = _G.FriendsFrame_Update
local BNGetNumFriends, BNGetFriendInfo, BNGetToonInfo, BNGetInfo = _G.BNGetNumFriends, _G.BNGetFriendInfo, _G.BNGetToonInfo, _G.BNGetInfo
local BNGetFriendIndex, BNGetNumFriendToons, BNGetFriendToonInfo = _G.BNGetFriendIndex, _G.BNGetNumFriendToons, _G.BNGetFriendToonInfo
local UIDropDownMenu_CreateInfo = _G.UIDropDownMenu_CreateInfo
local UIDropDownMenu_Refresh = _G.UIDropDownMenu_Refresh
local UIDropDownMenu_GetCurrentDropDown = _G.UIDropDownMenu_GetCurrentDropDown
local UIDropDownMenu_AddButton = _G.UIDropDownMenu_AddButton
local CanViewOfficerNote = _G.CanViewOfficerNote
local UpdateAddOnMemoryUsage, GetAddOnMemoryUsage = _G.UpdateAddOnMemoryUsage, _G.GetAddOnMemoryUsage
local ChatFrame_SendTell, ChatFrame_SendSmartTell = _G.ChatFrame_SendTell, _G.ChatFrame_SendSmartTell
local InviteUnit, BNInviteFriend = _G.InviteUnit, _G.BNInviteFriend
local CanGroupWithAccount = _G.CanGroupWithAccount
local IsAltKeyDown = _G.IsAltKeyDown
local UnitPopup_ShowMenu = _G.UnitPopup_ShowMenu
local CreateFrame = _G.CreateFrame
local ToggleDropDownMenu, CloseDropDownMenus = _G.ToggleDropDownMenu, _G.CloseDropDownMenus
local PlaySound = _G.PlaySound
local UnitFactionGroup = _G.UnitFactionGroup
local BNet_GetClientTexture = _G.BNet_GetClientTexture

local TravelPassDropDown = _G.TravelPassDropDown

local BNET_CLIENT_WOW = _G.BNET_CLIENT_WOW
local REMOTE_CHAT = _G.REMOTE_CHAT
local CHAT_FLAG_AFK, CHAT_FLAG_DND = _G.CHAT_FLAG_AFK, _G.CHAT_FLAG_DND
local FRIENDS_TEXTURE_AFK, FRIENDS_TEXTURE_DND = _G.FRIENDS_TEXTURE_AFK, _G.FRIENDS_TEXTURE_DND
local NORMAL_FONT_COLOR, HIGHLIGHT_FONT_COLOR = _G.NORMAL_FONT_COLOR, _G.HIGHLIGHT_FONT_COLOR
local FRIENDS_LIST_PLAYING = _G.FRIENDS_LIST_PLAYING

local TitanPanelButton_UpdateButton = _G.TitanPanelButton_UpdateButton
local TitanPanelButton_UpdateTooltip = _G.TitanPanelButton_UpdateTooltip
local TitanGetVar, TitanSetVar, TitanToggleVar = _G.TitanGetVar, _G.TitanSetVar, _G.TitanToggleVar
local TitanUtils_GetNormalText = _G.TitanUtils_GetNormalText
local TitanUtils_GetPlugin = _G.TitanUtils_GetPlugin
local TitanPanelRightClickMenu_AddTitle = _G.TitanPanelRightClickMenu_AddTitle
local TitanPanelRightClickMenu_AddSpacer = _G.TitanPanelRightClickMenu_AddSpacer
local TitanPanelRightClickMenu_AddToggleVar = _G.TitanPanelRightClickMenu_AddToggleVar
local TitanPanelRightClickMenu_AddCommand = _G.TitanPanelRightClickMenu_AddCommand
local TitanPanelRightClickMenu_AddToggleIcon = _G.TitanPanelRightClickMenu_AddToggleIcon
local TitanPanelRightClickMenu_IsVisible = _G.TitanPanelRightClickMenu_IsVisible

----------------------------------------------------------------------
--  Local variables
----------------------------------------------------------------------

-- Debugging Mode
local bDebugMode = false

-- Required Titan variables
local TITAN_SOCIAL_ID = "Social"
local TITAN_SOCIAL_VERSION = "5.1r19"
local TITAN_SOCIAL_TOOLTIP_KEY = "TitanSocialTooltip"

local MOBILE_HERE_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat:0:0:0:0:16:16:0:16:0:16:73:177:73|t"
local MOBILE_BUSY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:0:0:0:0:16:16:0:16:0:16|t"
local MOBILE_AWAY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:0:0:0:0:16:16:0:16:0:16|t"

local STATUS_ICON = "icon"
local STATUS_TEXT = "text"
local STATUS_NONE = "none"

local shouldIgnoreGuildRosterUpdate = false

-- Class support
local TitanSocial_ClassMap = {}

-- Build the class map
for i = 1, _G.GetNumClasses() do
	local name, className, classId = _G.GetClassInfo(i)
	TitanSocial_ClassMap[_G.LOCALIZED_CLASS_NAMES_MALE[className]] = className
	TitanSocial_ClassMap[_G.LOCALIZED_CLASS_NAMES_FEMALE[className]] = className
end

----------------------------------------------------------------------
--  Code
----------------------------------------------------------------------

local function colorText(text, className)
	local classIndex, coloredText=nil

	local class = TitanSocial_ClassMap[className]
	local color = nil
	if class == nil then
		color = "ffcccccc"
	else
		color = RAID_CLASS_COLORS[class].colorStr
	end
	return "|c"..color..text.."|r"
end

local function addSubmenu(text, value, level)
	local info = UIDropDownMenu_CreateInfo()
	info.text = text
	info.menuList = value
	info.hasArrow = true
	info.notCheckable = true
	info.keepShownOnClick = true
	UIDropDownMenu_AddButton(info, level)
end

local function setTitanSocialOption(info, key, value)
	TitanSetVar(TITAN_SOCIAL_ID, key, value)
end

local function setTitanSocialOptionRefresh(info, key, value)
	TitanSetVar(TITAN_SOCIAL_ID, key, value)
	UIDropDownMenu_Refresh(UIDropDownMenu_GetCurrentDropDown())
end

local function optionDropdownCheckedFunc(button)
	local current = TitanGetVar(TITAN_SOCIAL_ID, button.arg1)
	return (current or false) == button.arg2
end

local function addSortOption(text, key, value, level)
	local info = UIDropDownMenu_CreateInfo()
	info.text = text
	info.func = setTitanSocialOption
	info.arg1 = key
	info.arg2 = value
	info.keepShownOnClick = false -- can't update the menu while visible
	info.checked = optionDropdownCheckedFunc
	info.disabled = not TitanGetVar(TITAN_SOCIAL_ID, "SortGuild")
	UIDropDownMenu_AddButton(info, level)
end

local function addRadioRefresh(text, key, value, level)
	local info = UIDropDownMenu_CreateInfo()
	info.text = text
	info.func = setTitanSocialOptionRefresh
	info.arg1 = key
	info.arg2 = value
	info.keepShownOnClick = true
	info.checked = optionDropdownCheckedFunc
	UIDropDownMenu_AddButton(info, level)
end

-- TitanPanelRightClickMenu_PrepareSocialMenu() must be global for TitanPanel to find it
function _G.TitanPanelRightClickMenu_PrepareSocialMenu(frame, level, menuList)
	if level == 1 then
		TitanPanelRightClickMenu_AddTitle(TitanUtils_GetPlugin(TITAN_SOCIAL_ID).menuText, level)
		
		-- RealID Menu
		addSubmenu(L.MENU_REALID, "RealID", level)
		
		-- Friends Menu
		addSubmenu(L.MENU_FRIENDS, "Friends", level)
		
		-- Guild Menu
		addSubmenu(L.MENU_GUILD, "Guild", level)
		
		TitanPanelRightClickMenu_AddSpacer(level)
		TitanPanelRightClickMenu_AddToggleVar(L.MENU_SHOW_GROUP_MEMBERS, TITAN_SOCIAL_ID, "ShowGroupMembers", nil, level)

		-- Status menu
		addSubmenu(L.MENU_STATUS, "Status", level)
		
		TitanPanelRightClickMenu_AddSpacer(level)
		TitanPanelRightClickMenu_AddToggleIcon(TITAN_SOCIAL_ID, level)
		TitanPanelRightClickMenu_AddToggleVar(L.MENU_LABEL, TITAN_SOCIAL_ID, "ShowLabel", nil, level)
		TitanPanelRightClickMenu_AddToggleVar(L.MENU_MEM, TITAN_SOCIAL_ID, "ShowMem", nil, level)
		TitanPanelRightClickMenu_AddSpacer(level)
		TitanPanelRightClickMenu_AddCommand(L.MENU_HIDE, TITAN_SOCIAL_ID, _G.TITAN_PANEL_MENU_FUNC_HIDE, level)
	elseif level == 2 then
		-- RealID Menu
		if menuList == "RealID" then
			TitanPanelRightClickMenu_AddTitle(L.MENU_REALID, level)
			TitanPanelRightClickMenu_AddToggleVar(L.MENU_REALID_FRIENDS, TITAN_SOCIAL_ID, "ShowRealID", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(L.MENU_REALID_BROADCASTS, TITAN_SOCIAL_ID, "ShowRealIDBroadcasts", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(L.MENU_REALID_FACTIONS, TITAN_SOCIAL_ID, "ShowRealIDFactions", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(L.MENU_REALID_NOTE, TITAN_SOCIAL_ID, "ShowRealIDNotes", nil, level)
		end
		
		-- Friends Menu
		if menuList == "Friends" then
			TitanPanelRightClickMenu_AddTitle(L.MENU_FRIENDS, level)
			TitanPanelRightClickMenu_AddToggleVar(L.MENU_FRIENDS_SHOW, TITAN_SOCIAL_ID, "ShowFriends", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(L.MENU_FRIENDS_NOTE, TITAN_SOCIAL_ID, "ShowFriendsNote", nil, level)
		end
		
		-- Guild Menu
		if menuList == "Guild" then
			TitanPanelRightClickMenu_AddTitle(L.MENU_GUILD, level)
			TitanPanelRightClickMenu_AddToggleVar(L.MENU_GUILD_MEMBERS, TITAN_SOCIAL_ID, "ShowGuild", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(L.MENU_GUILD_LABEL, TITAN_SOCIAL_ID, "ShowGuildLabel", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(L.MENU_GUILD_NOTE, TITAN_SOCIAL_ID, "ShowGuildNote", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(L.MENU_GUILD_ONOTE, TITAN_SOCIAL_ID, "ShowGuildONote", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(L.MENU_GUILD_REMOTE_CHAT, TITAN_SOCIAL_ID, "ShowSplitRemoteChat", nil, level)
			
			TitanPanelRightClickMenu_AddSpacer(level)
			addSubmenu(L.MENU_GUILD_SORT, "GuildSort", level)
		end

		-- Status Menu
		if menuList == "Status" then
			addRadioRefresh(L.MENU_STATUS_ICON, "ShowStatus", STATUS_ICON, level)
			addRadioRefresh(L.MENU_STATUS_TEXT, "ShowStatus", STATUS_TEXT, level)
			addRadioRefresh(L.MENU_STATUS_NONE, "ShowStatus", STATUS_NONE, level)
		end
		
		if menuList == "Options" then
			TitanPanelRightClickMenu_AddTitle(L.MENU_OPTIONS, level)
		end
	elseif level == 3 then
		-- Guild Sorting
		if menuList == "GuildSort" then
			-- we'd like to use AddToggleVar() but we can't keep the menu open
			do
				local info = UIDropDownMenu_CreateInfo()
				info.text = L.MENU_GUILD_SORT_DEFAULT
				info.func = function ()
					TitanToggleVar(TITAN_SOCIAL_ID, "SortGuild")
				end
				info.keepShownOnClick = false
				info.checked = not TitanGetVar(TITAN_SOCIAL_ID, "SortGuild")
				UIDropDownMenu_AddButton(info, level)
			end
			TitanPanelRightClickMenu_AddSpacer(level)
			addSortOption(L.MENU_GUILD_SORT_NAME, "GuildSortKey", "name", level)
			addSortOption(L.MENU_GUILD_SORT_RANK, "GuildSortKey", "rank", level)
			addSortOption(L.MENU_GUILD_SORT_CLASS, "GuildSortKey", "class", level)
			addSortOption(L.MENU_GUILD_SORT_LEVEL, "GuildSortKey", "level", level)
			addSortOption(L.MENU_GUILD_SORT_ZONE, "GuildSortKey", "zone", level)
			TitanPanelRightClickMenu_AddSpacer(level)
			addSortOption(L.MENU_GUILD_SORT_ASCENDING, "GuildSortAscending", true, level)
			addSortOption(L.MENU_GUILD_SORT_DESCENDING, "GuildSortAscending", false, level)
		end
	end
end

-- TitanPanelSocialButton_GetButtonText() must be global so TitanPanel can see it
function _G.TitanPanelSocialButton_GetButtonText(id)
	local label = " "
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowLabel") then
		if TitanGetVar(TITAN_SOCIAL_ID, "ShowGuildLabel") and TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") and IsInGuild() then
			local guildName = GetGuildInfo("player")
			if guildName then
				label = guildName..": "
			else
				label = "...: "
			end
		else
			label = L.BUTTON_TITLE
		end
	end

	local comps = {}

	if TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") then
		table.insert(comps, "|cff00A2E8"..select(2, BNGetNumFriends()).."|r")
	end
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends") then
		table.insert(comps, "|cffFFFFFF"..select(2,GetNumFriends()).."|r")
	end
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") then
		local online, remote = select(2, GetNumGuildMembers())
		local _, online, remote = GetNumGuildMembers()
		if TitanGetVar(TITAN_SOCIAL_ID, "ShowSplitRemoteChat") then
			remote = remote - online
		else
			online, remote = remote, nil
		end
		table.insert(comps, "|cff00FF00"..online.."|r")
		if remote ~= nil then
			table.insert(comps, "|cff00BB00"..remote.."|r")
		end
	end

	label = label .. table.concat(comps, " |cffffd200/|r ")

	return L.BUTTON_TITLE, label
end

local function ternary(cond, a, b)
	if cond then
		return a
	else
		return b
	end
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
--   number - remote guild members
--
-- If `split` is true, the online and remote sections of the roster are
-- sorted independently. If false, they're sorted into the same table.
-- Every entry in the roster is an index suitable for GetGuildRosterInfo()
local function collectGuildRosterInfo(split, sortKey, sortAscending)
	SetGuildRosterShowOffline(false)

	local guildTotal, guildOnline, guildRemote = GetNumGuildMembers()

	local onlineTable, remoteTable = {}, {}
	local numOnline = split and guildOnline or guildRemote
	for i = 1, numOnline do
		onlineTable[i] = i
	end
	for i = numOnline+1, guildRemote do
		remoteTable[i-numOnline] = i
	end
	local function tableDesc(t)
		local desc = "{"
		for i = 1, #t do
			if i ~= 1 then desc = desc .. ", " end
			desc = desc .. (t[i] == nil and "nil" or tostring(t[i]))
		end
		return desc.."}"
	end

	if sortKey then
		local function sortFunc(a, b)
			local aname, _, arankIndex, alevel, aclass, azone = GetGuildRosterInfo(a)
			local bname, _, brankIndex, blevel, bclass, bzone = GetGuildRosterInfo(b)
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
				return ternary(sortAscending, azone < bzone, azone > bzone)
			end
			aname = string.lower(aname)
			bname = string.lower(bname)
			-- if name is the secondary sort, it's always ascending
			if sortAscending or sortKey ~= "name" then
				return aname < bname
			else
				return aname > bname
			end
		end

		table.sort(onlineTable, sortFunc)
		table.sort(remoteTable, sortFunc)
	end

	-- tack remoteTable onto the end of onlineTable so our caller only has 1 table to traverse
	for i, v in ipairs(remoteTable) do
		onlineTable[i+numOnline] = v
	end

	return onlineTable, guildTotal, guildOnline, guildRemote
end

-- spacer(width, count)
-- PARAMETERS:
--   width - number - width of the space. Defaults to TextHeight
--   count - number - number of spacers. Defaults to 1
-- RETURNS:
--   string - the spacer
local function spacer(width, count)
	if not width then width = 0 end
	if not count then count = 1 end
	local height = (width == 0) and 0 or 1
	return ("|T:"..height..":"..width.."|t"):rep(count)
end

local function getGroupIndicator(name)
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowGroupMembers") then
		if IsInGroup() and name ~= "" then -- don't check self if we're not in a group
			if UnitInParty(name) or UnitInRaid(name) then
				return "|TInterface\\Buttons\\UI-CheckBox-Check:0:0|t" -- checkmark
			end
		end
		return spacer()
	end
	return ""
end

local function getFactionIndicator(faction, client)
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowRealIDFactions") then
		if client == BNET_CLIENT_WOW then
			if faction == "Horde" or faction == "Alliance" then
				return "|TInterface\\PVPFrame\\PVP-Currency-"..faction..":0|t"
			end
		elseif client and client ~= "" then
			return "|T"..BNet_GetClientTexture(client)..":0|t"
		end
		return spacer()
	end
	return ""
end

local function getStatusIcon(status)
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowStatus") == STATUS_ICON then
		if status == CHAT_FLAG_AFK then
			return "|T"..FRIENDS_TEXTURE_AFK..":0|t"
		elseif status == CHAT_FLAG_DND then
			return "|T"..FRIENDS_TEXTURE_DND..":0|t"
		end
	end
	return ""
end

local function getStatusText(status)
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowStatus") == STATUS_TEXT then
		if status ~= "" then
			return "|cffFFFFFF"..status.."|r "
		end
	end
	return ""
end

local function padLevel(level, digitWidth)
	level = tostring(tonumber(level) or 0)
	if #level < 2 then
		level = spacer(digitWidth)..level
	end
	return level
end

local rightClickFrame
local function getRightClickFrame()
	if not rightClickFrame then
		rightClickFrame = CreateFrame("Frame", addonName.."TooltipContextualMenu", _G.UIParent, "UIDropDownMenuTemplate")
	end
	return rightClickFrame
end

local function showGuildRightClick(player, isMobile)
	local frame = getRightClickFrame()
	frame.initialize = function() UnitPopup_ShowMenu(_G.UIDROPDOWNMENU_OPEN_MENU, "GUILD", nil, player) end
	frame.displayMode = "MENU";
	frame.friendsList = false
	frame.presenceID = nil
	frame.isMobile = isMobile
	ToggleDropDownMenu(1, nil, frame, "cursor")
end

local function showFriendRightClick(player)
	local frame = getRightClickFrame()
	frame.initialize = function() UnitPopup_ShowMenu(_G.UIDROPDOWNMENU_OPEN_MENU, "FRIEND", nil, player) end
	frame.displayMode = "MENU"
	frame.friendsList = true
	frame.presenceID = nil
	frame.isMobile = nil
	ToggleDropDownMenu(1, nil, frame, "cursor")
end

local function showRealIDRightClick(presenceName, presenceID)
	local frame = getRightClickFrame()
	frame.initialize = function() UnitPopup_ShowMenu(_G.UIDROPDOWNMENU_OPEN_MENU, "BN_FRIEND", nil, presenceName) end
	frame.displayMode = "MENU"
	frame.friendsList = true
	frame.presenceID = presenceID
	frame.isMobile = nil
	ToggleDropDownMenu(1, nil, frame, "cursor")
end

local function clickPlayer(frame, info, button)
	local player, isGuild, isMobile, isRemote = unpack(info)
	if player ~= "" then
		if button == "LeftButton" then
			if IsAltKeyDown() then
				if not isRemote then InviteUnit(player) end
			else
				ChatFrame_SendTell(player)
			end
		elseif button == "RightButton" then
			if isGuild then
				showGuildRightClick(player, isRemote)
			else
				showFriendRightClick(player)
			end
		end
	end
end

local function sendBattleNetInvite(presenceID)
	local index = BNGetFriendIndex(presenceID)
	if index then
		local numToons = BNGetNumFriendToons(index)
		if numToons > 1 then
			PlaySound("igMainMenuOptionCheckBoxOn")
			local dropDown = TravelPassDropDown
			if dropDown.index ~= index then
				CloseDropDownMenus()
			end
			dropDown.index = index
			ToggleDropDownMenu(1, nil, dropDown, "cursor", 1, -1)
		else
			local toonID = select(6, BNGetFriendInfo(index))
			if toonID then
				BNInviteFriend(toonID)
			end
		end
	end
end

local function clickRealID(frame, info, button)
	local presenceName, presenceID = unpack(info)
	if button == "LeftButton" then
		if IsAltKeyDown() then
			if CanGroupWithAccount(presenceID) then
				sendBattleNetInvite(presenceID)
			end
		else
			ChatFrame_SendSmartTell(presenceName)
		end
	elseif button == "RightButton" then
		showRealIDRightClick(presenceName, presenceID)
	end
end

local function addRealID(tooltip, digitWidth)
	local numTotal, numOnline = BNGetNumFriends()

	tooltip:AddLine(TitanUtils_GetNormalText(L.TOOLTIP_REALID), "|cff00A2E8"..numOnline.."|r"..TitanUtils_GetNormalText("/"..numTotal))

	for i=1, numOnline do
		local left = ""

		local presenceID, presenceName, battleTag, isBattleTagPresence, _, _, client, _, _, isAFK, isDND, broadcastText, noteText = BNGetFriendInfo(i)
		local _, toonName, client, realmName, realmID, faction, _, className, _, _, level, gameText, _, _, _, toonID = BNGetToonInfo(presenceID)

		-- group member indicator
		-- is this friend playing WoW on our server?
		local playerRealmID = select(5, BNGetToonInfo(select(3, BNGetInfo())))
		if client == BNET_CLIENT_WOW then
			local name
			if realmID == playerRealmID then
				name = toonName
			else
				-- Cross-realm?
				name = toonName.."-"..realmName
			end
			left = left..getGroupIndicator(name)
		else
			left = left..getGroupIndicator("")
		end

		-- player status
		local playerStatus = ""
		if isAFK then
			playerStatus = CHAT_FLAG_AFK
		elseif isDND then
			playerStatus = CHAT_FLAG_DND
		end

		-- Character (and faction)
		do
			local first, second
			if client == BNET_CLIENT_WOW then
				first = padLevel(level, digitWidth)
				second = colorText(toonName, className)
			else
				first = client
				second = "|cffCCCCCC"..toonName.."|r"
			end
			left = left.."|cffFFFFFF"..first.."|r  "
			left = left..getFactionIndicator(faction, client)
			left = left..getStatusIcon(playerStatus)
			left = left..second.." "
		end

		-- Full name
		left = left.."[|cff00A2E8"..(isBattleTagPresence and battleTag or presenceName).."|r] "

		-- Status
		left = left..getStatusText(playerStatus).." "

		-- Note
		if TitanGetVar(TITAN_SOCIAL_ID, "ShowRealIDNotes") then
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
		if TitanGetVar(TITAN_SOCIAL_ID, "ShowRealIDBroadcasts") then
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
		local right = "|cffFFFFFF"..gameText.."|r"

		local y = tooltip:AddLine(left, right)
		tooltip:SetLineScript(y, "OnMouseDown", clickRealID, { presenceName, presenceID })

		-- Extra lines
		local indent = getGroupIndicator("")..spacer(digitWidth, 2).."  "..getFactionIndicator("", "")
		if extraLines then
			for _, line in ipairs(extraLines) do
				-- indent the line over
				line = indent..line
				local y, x = tooltip:AddLine()
				tooltip:SetCell(y, x, line, nil, nil, 2)
			end
		end

		-- Additional toons
		local playerFactionGroup = UnitFactionGroup("player")
		for j = 2, BNGetNumFriendToons(i) do
			local _, toonName, client, _, realmID, faction, race, class, _, zoneName, level, gameText = BNGetFriendToonInfo(i, j)
			local left, right
			if client == BNET_CLIENT_WOW then
				local cooperateLabel = ""
				if realmID ~= playerRealmID or faction ~= playerFactionGroup then
					cooperateLabel = _G.CANNOT_COOPERATE_LABEL
				end
				left = _G.FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE:format(toonName..cooperateLabel, level, race, class)
				right = zoneName
			else
				left = toonName
				right = gameText
			end
			tooltip:AddLine(indent.."|cffFEE15C"..FRIENDS_LIST_PLAYING.."|cffFFFFFF "..left.."|r", "|cffFFFFFF"..right.."|r")
		end
	end
end

local function addFriends(tooltip, digitWidth)
	local numTotal, numOnline = GetNumFriends()

	tooltip:AddLine(TitanUtils_GetNormalText(L.TOOLTIP_FRIENDS), "|cffFFFFFF"..numOnline.."|r"..TitanUtils_GetNormalText("/"..numTotal))

	for i=1, numOnline do
		local left = ""

		local name, level, class, area, connected, playerStatus, playerNote, isRAF = GetFriendInfo(i)

		-- Group indicator
		left = left..getGroupIndicator(name)

		-- fix unknown names - why does this happen?
		local origname = name
		if name == "" then
			name = "Unknown"
		end

		-- Level
		left = left.."|cffFFFFFF"..padLevel(level, digitWidth).."|r  "

		-- Status icon
		left = left..getStatusIcon(playerStatus)

		-- Name
		left = left..colorText(name, class).." "

		-- Status
		left = left..getStatusText(playerStatus).." "

		-- Notes
		if TitanGetVar(TITAN_SOCIAL_ID, "ShowFriendsNote") then
			if playerNote and playerNote ~= "" then
				left = left.."|cffFFFFFF"..playerNote.."|r "
			end
		end
		local right = ""
		if area ~= nil then
			right = "|cffFFFFFF"..area.."|r"
		end
		
		local y =tooltip:AddLine(left, right)
		tooltip:SetLineScript(y, "OnMouseDown", clickPlayer, { origname, false, false, false })
	end
end

local function processGuildMember(i, isRemote, tooltip, digitWidth)
	local left = ""

	local name, rank, rankIndex, level, class, zone, note, officerNote, online, playerStatus, classFileName, achievementPoints, achievementRank, isMobile = GetGuildRosterInfo(i)

	left = left..getGroupIndicator(name)

	-- fix name
	local origname = name
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
		if isRemote then zone = REMOTE_CHAT end
		if playerStatus == CHAT_FLAG_DND then
			name = MOBILE_BUSY_ICON..name
		elseif playerStatus == CHAT_FLAG_AFK then
			name = MOBILE_AWAY_ICON..name
		else
			name = MOBILE_HERE_ICON..name
		end
	end

	-- Level
	left = left.."|cffFFFFFF"..padLevel(level, digitWidth).."|r  "

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
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowGuildNote") then
		if note and note ~= "" then
			left = left.."|cffFFFFFF"..note.."|r  "
		end
	end

	-- Officer Notes
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowGuildONote") then
		if CanViewOfficerNote() then
			if officerNote and officerNote ~= "" then
				left = left.."|cffAAFFAA"..officerNote.."|r  "
			end
		end
	end

	-- Location
	local right = ""
	if zone and zone ~= "" then
		right = "|cffFFFFFF"..zone.."|r"
	end

	local y = tooltip:AddLine(left, right)
	tooltip:SetLineScript(y, "OnMouseDown", clickPlayer, { origname, true, isMobile, isRemote })
end

local function addGuild(tooltip, digitWidth)
	local wasOffline = GetGuildRosterShowOffline()
	if wasOffline then
		-- SetGuildRosterShowOffline() seems to sometimes trigger GUILD_ROSTER_UPDATE
		shouldIgnoreGuildRosterUpdate = true
		SetGuildRosterShowOffline(false)
		shouldIgnoreGuildRosterUpdate = false
	end

	local split = TitanGetVar(TITAN_SOCIAL_ID, "ShowSplitRemoteChat")
	local sortKey = TitanGetVar(TITAN_SOCIAL_ID, "SortGuild") and TitanGetVar(TITAN_SOCIAL_ID, "GuildSortKey") or nil
	local roster, numTotal, numOnline, numRemote = collectGuildRosterInfo(split, sortKey, TitanGetVar(TITAN_SOCIAL_ID, "GuildSortAscending") or false)

	local numGuild = split and numOnline or numRemote

	tooltip:AddLine(TitanUtils_GetNormalText(L.TOOLTIP_GUILD), "|cff00FF00"..numGuild.."|r"..TitanUtils_GetNormalText("/"..numTotal))

	for i, guildIndex in ipairs(roster) do
		local isRemote = guildIndex > numOnline
		processGuildMember(guildIndex, isRemote, tooltip, digitWidth)

		if split and i == numOnline then
			-- add header for Remote Chat
			local numRemoteChat = numRemote - numOnline
			tooltip:AddLine(" ")
			tooltip:AddLine(TitanUtils_GetNormalText(L.TOOLTIP_REMOTE_CHAT), "|cff00FF00"..numRemoteChat.."|r"..TitanUtils_GetNormalText("/"..numTotal))
		end
	end

	if wasOffline then
		shouldIgnoreGuildRosterUpdate = true
		SetGuildRosterShowOffline(wasOffline)
		shouldIgnoreGuildRosterUpdate = false
	end
end

local function buildTooltip(tooltip, digitWidth)
	tooltip:AddHeader(_G.HIGHLIGHT_FONT_COLOR_CODE .. L.TOOLTIP .. "|r")

	if TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") then
		tooltip:AddLine(" ")
		addRealID(tooltip, digitWidth)
	end
	
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends") then
		tooltip:AddLine(" ")
		addFriends(tooltip, digitWidth)
	end
	
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") then
		tooltip:AddLine(" ")
		addGuild(tooltip, digitWidth)
	end
	
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowMem") then
		UpdateAddOnMemoryUsage()
		tooltip:AddLine(" ")
		tooltip:AddLine(TitanUtils_GetNormalText(L.TOOLTIP_MEM), "|cff00FF00"..math.floor(GetAddOnMemoryUsage("TitanSocial")).." "..L.TOOLTIP_MEM_UNIT.."|r")
	end
end

-- getDigitWidth(font)
-- PARAMETERS:
--   font - Font - the font we want the width of
-- RETURNS:
--   number - the width of a single digit in the specified font
local getDigitWidthFontString = _G.UIParent:CreateFontString()
getDigitWidthFontString:Hide()
local function getDigitWidth(font)
	getDigitWidthFontString:SetFontObject(font)
	getDigitWidthFontString:SetText("0")
	return getDigitWidthFontString:GetStringWidth()
end

local tooltipFont = _G.CreateFont(addonName.."TooltipFont")
tooltipFont:SetFontObject(_G.GameTooltipText)
tooltipFont:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
local function updateTooltip(tooltip)
	-- Calculate the width of 1 digit
	-- We're assuming that all digits in a font have the same width, since that seems to be the case
	-- Ask the LabelProvider for a cell for our tooltip using the current font
	--local cell = LibQTip.LabelProvider:AcquireCell(tooltip)
	--tooltip:SetText("title")
	--tooltip:AddLine("0")
	--local digitWidth = _G.GameTooltipTextLeft2:GetStringWidth()

	local digitWidth = getDigitWidth(tooltip:GetFont())

	tooltip:Clear()

	tooltip:SetFont(tooltipFont)

	local ok, message = pcall(buildTooltip, tooltip, digitWidth)
	if not ok then
		print("|cffFF0000TitanSocial error: " .. message .. "|r")
		error(message, 0)
	end
end

----------------------------------------------------------------------
--  Event Handlers
----------------------------------------------------------------------

function _G.TitanPanelSocialButton_OnLoad(self)
	--
	-- LOCAL REGISTRY --
	--

	self.registry = {
		id = TITAN_SOCIAL_ID,
		version = TITAN_SOCIAL_VERSION,
		menuText = L.MENU_TEXT,
		buttonTextFunction = "TitanPanelSocialButton_GetButtonText",
		iconWidth = 16,
		icon = "Interface\\FriendsFrame\\BroadcastIcon",
		category = "Information",
		controlVariables = {
			ShowIcon = true,
			--ShowLabelText = true,
			DisplayOnRightSide = false
			--ShowRegularText = false,
			--ShowColoredText = true,
		},
		savedVariables = {
			ShowRealID = 1,
			ShowRealIDBroadcasts = false,
			ShowRealIDNotes = true,
			ShowRealIDFactions = true,
			ShowFriends = 1,
			ShowFriendsNote = 1,
			ShowGuild = 1,
			ShowGuildLabel = false,
			ShowGuildNote = 1,
			ShowSplitRemoteChat = 1,
			ShowGuildONote = 1,
			ShowGroupMembers = 1,
			SortGuild = false,
			GuildSortKey = "rank",
			GuildSortAscending = true,
			ShowStatus = STATUS_ICON,
			ShowIcon = 1,
			ShowLabel = 1,
			ShowTooltipTotals = 1,
			ShowMem = false,
		}
	}

	--
	-- EVENT CATCHING --
	--

	-- General Events
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	-- RealID Events
	self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	self:RegisterEvent("BN_FRIEND_TOON_OFFLINE")
	self:RegisterEvent("BN_FRIEND_TOON_ONLINE")
	self:RegisterEvent("BN_TOON_NAME_UPDATED")

	-- Friend Events
	self:RegisterEvent("FRIENDLIST_UPDATE")

	-- Guild Events
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
end

function _G.TitanPanelSocialButton_OnEvent(self, event, ...)
	if shouldIgnoreGuildRosterUpdate and event == "GUILD_ROSTER_UPDATE" then return end

	-- Debugging. Pay no attention to the man behind the curtain.
	if bDebugMode then
		_G.DEFAULT_CHAT_FRAME:AddMessage("Social: OnEvent")
		if event == "PLAYER_ENTERING_WORLD" then
			_G.DEFAULT_CHAT_FRAME:AddMessage(TITAN_SOCIAL_ID.." v"..TITAN_SOCIAL_VERSION.." Loaded.")
		end
		_G.DEFAULT_CHAT_FRAME:AddMessage("Social: Caught Event "..event)
	end

	-- Update button label
	TitanPanelButton_UpdateButton(TITAN_SOCIAL_ID)

	-- Update tooltip if shown
	if LibQTip:IsAcquired(TITAN_SOCIAL_TOOLTIP_KEY) then
		local tooltip = LibQTip:Acquire(TITAN_SOCIAL_TOOLTIP_KEY)
		if tooltip:IsVisible() then -- we're getting events while the tooltip isn't visible, for some reason
			updateTooltip(tooltip)
			tooltip:UpdateScrolling()
		end
	end
end

function _G.TitanPanelSocialButton_OnEnter(self)
	if TitanPanelRightClickMenu_IsVisible() then return end -- ignore OnEnter when the contextual menu is visible

	-- If in a guild, steal roster update. If not, ignore and update anyway
	if IsInGuild() then
		_G.FriendsFrame:UnregisterEvent("GUILD_ROSTER_UPDATE")
		GuildRoster()
		_G.FriendsFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
	end

	-- Update Titan button label and tooltip
	TitanPanelButton_UpdateButton(TITAN_SOCIAL_ID)

	local tooltip = LibQTip:Acquire(TITAN_SOCIAL_TOOLTIP_KEY, 2, "LEFT", "RIGHT")
	tooltip:SetAutoHideDelay(0.2, self)
	updateTooltip(tooltip)
	tooltip:SmartAnchorTo(self)
	tooltip:SetFrameStrata("FULLSCREEN_DIALOG") -- so contextual menu works
	tooltip:Show()
	tooltip:UpdateScrolling()
end

function _G.TitanPanelSocialButton_OnClick(self, button)
	-- Detect mouse clicks
	if button == "LeftButton" then
		if TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends") or TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") then
			ToggleFriendsFrame(1); -- friends tab
			FriendsFrame_Update()
		end

		if TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") then
			ToggleGuildFrame(1); -- guild tab
		end
	elseif button == "RightButton" then
		-- hide the tooltip so the contextual menu will be visible
		if LibQTip:IsAcquired(TITAN_SOCIAL_TOOLTIP_KEY) then
			local tooltip = LibQTip:Acquire(TITAN_SOCIAL_TOOLTIP_KEY)
			tooltip:Hide()
			tooltip:Release()
		end
	end
end
