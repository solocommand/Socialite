local addonName, addonTable = ...
local L = addonTable.L
local tooltip = addonTable.tooltip

----------------------------------------------------------------------
--  Global variables
----------------------------------------------------------------------

-- GLOBALS: table math select string tostring tonumber ipairs print pcall select error unpack

local _G = _G
local Ambiguate = _G.Ambiguate

local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local IsInGuild, IsInGroup = _G.IsInGuild, _G.IsInGroup
local UnitInParty, UnitInRaid = _G.UnitInParty, _G.UnitInRaid
local GuildRoster = _G.GuildRoster
local GetGuildInfo, GetGuildRosterInfo, GetNumGuildMembers = _G.GetGuildInfo, _G.GetGuildRosterInfo, _G.GetNumGuildMembers
local GetGuildRosterShowOffline, SetGuildRosterShowOffline = _G.GetGuildRosterShowOffline, _G.SetGuildRosterShowOffline
local GetNumFriends, GetFriendInfo = _G.GetNumFriends, _G.GetFriendInfo
local ToggleFriendsFrame, ToggleGuildFrame = _G.ToggleFriendsFrame, _G.ToggleGuildFrame
local FriendsFrame, ShowUIPanel, HideUIPanel = _G.FriendsFrame, _G.ShowUIPanel, _G.HideUIPanel
local FriendsFrame_Update = _G.FriendsFrame_Update
local BNGetNumFriends, BNGetFriendInfo, BNGetToonInfo, BNGetInfo = _G.BNGetNumFriends, _G.BNGetFriendInfo, _G.BNGetToonInfo, _G.BNGetInfo
local BNGetFriendIndex, BNGetNumFriendToons, BNGetFriendToonInfo = _G.BNGetFriendIndex, _G.BNGetNumFriendToons, _G.BNGetFriendToonInfo
local UIDropDownMenu_CreateInfo = _G.UIDropDownMenu_CreateInfo
local UIDropDownMenu_Refresh = _G.UIDropDownMenu_Refresh
local UIDropDownMenu_GetCurrentDropDown = _G.UIDropDownMenu_GetCurrentDropDown
local UIDropDownMenu_AddButton = _G.UIDropDownMenu_AddButton
local CanViewOfficerNote = _G.CanViewOfficerNote
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
local InCombatLockdown = _G.InCombatLockdown

local TravelPassDropDown = _G.TravelPassDropDown

local BNET_CLIENT_WOW = _G.BNET_CLIENT_WOW
local BNET_CLIENT_WTCG = _G.BNET_CLIENT_WTCG
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
local TITAN_SOCIAL_VERSION = "5.4r24"
local TITAN_SOCIAL_TOOLTIP_KEY = "TitanSocialTooltip"

local MOBILE_HERE_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat:0:0:0:0:16:16:0:16:0:16:73:177:73|t"
local MOBILE_BUSY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:0:0:0:0:16:16:0:16:0:16|t"
local MOBILE_AWAY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:0:0:0:0:16:16:0:16:0:16|t"

local CHECK_ICON = "|TInterface\\Buttons\\UI-CheckBox-Check:0:0|t"

local STATUS_ICON = "icon"
local STATUS_TEXT = "text"
local STATUS_NONE = "none"

local INTERACTION_ALWAYS = "always"
local INTERACTION_OOC = "outofcombat"
local INTERACTION_NEVER = "never"

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

local updateTooltip
local countRealID

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

		-- Interaction menu
		addSubmenu(L.MENU_INTERACTION, "Interaction", level)
		
		TitanPanelRightClickMenu_AddSpacer(level)
		TitanPanelRightClickMenu_AddToggleIcon(TITAN_SOCIAL_ID, level)
		TitanPanelRightClickMenu_AddToggleVar(L.MENU_LABEL, TITAN_SOCIAL_ID, "ShowLabel", nil, level)
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
			TitanPanelRightClickMenu_AddToggleVar(L.MENU_REALID_APP, TITAN_SOCIAL_ID, "ShowRealIDApp", nil, level)
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

		-- Interaction Menu
		if menuList == "Interaction" then
			addRadioRefresh(L.MENU_INTERACTION_ALWAYS, "TooltipInteraction", INTERACTION_ALWAYS, level)
			addRadioRefresh(L.MENU_INTERACTION_OOC, "TooltipInteraction", INTERACTION_OOC, level)
			addRadioRefresh(L.MENU_INTERACTION_NEVER, "TooltipInteraction", INTERACTION_NEVER, level)
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

	local showRealID = TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID")
	local showRealIDApp = TitanGetVar(TITAN_SOCIAL_ID, "ShowRealIDApp")
	if showRealID or showRealIDApp then
		local numFriends, numBnet = countRealID(showRealID)
		if showRealID then
			table.insert(comps, "|cff00A2E8"..numFriends.."|r")
		end
		if showRealIDApp then
			table.insert(comps, "|cff00A2E8"..numBnet.."|r")
		end
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

-- GUILD_ROSTER_UPDATE recursion protection
local guildRosterIgnoreFrame = CreateFrame("frame")
local frameOver = true
guildRosterIgnoreFrame:SetScript("OnUpdate", function(self)
	frameOver = true
	self:Hide()
end)
local function isFreshFrame()
	if frameOver then
		frameOver = false
		guildRosterIgnoreFrame:Show()
		return true
	end
	return false
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
				return CHECK_ICON -- checkmark
			end
		end
		return spacer()
	end
	return ""
end

local function getRealIDGroupIndicator(presenceID, playerRealmID)
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowGroupMembers") then
		local index = BNGetFriendIndex(presenceID)
		for i = 1, BNGetNumFriendToons(index) do
			local _, toonName, client, realmName, realmID = BNGetFriendToonInfo(index, i)
			if client == BNET_CLIENT_WOW then
				if realmID ~= playerRealmID then
					toonName = toonName.."-"..realmName
				end
				if UnitInParty(toonName) or UnitInRaid(toonName) then
					return CHECK_ICON
				end
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

local function clickHeader(frame, varName, button)
	TitanSetVar(TITAN_SOCIAL_ID, varName, not TitanGetVar(TITAN_SOCIAL_ID, varName))
	updateTooltip(tooltip)
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
	local left = TitanUtils_GetNormalText(header)
	if collapsed then
		left = left.." |cff808080"..L.TOOLTIP_COLLAPSED.."|r"
	end
	if color then color = "|cff"..color end
	local right = (color or "")..online..(color and "|r")..TitanUtils_GetNormalText("/"..total)
	local y = addDoubleLine(false, left, right)
	tooltip:SetLineScript(y, "OnMouseDown", clickHeader, collapseVar)
	return y
end

-- Returns two tables, first is for friends and second is for bnet.
-- Both are arrays of identically-formatted tables. "friends" is all the normal RealID friends
-- and "bnet" is all the friends in the Battle.Net app. Any friends in the app and elsewhere are considered
-- to only be elsewhere.
-- The individual player tables are formatted as follows: {
--     presenceID,
--     presenceName,
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
--         gameText
--     },
--     alts: nil or non-empty array of tables identical to focus,
--     bnet: nil or table identical to focus
-- }
-- filterClients indicates whether friends with both bnet and non-bnet should
-- be filtered out of the bnet list
local function parseRealID(filterClients)
	local numTotal, numOnline = BNGetNumFriends()

	local friends, bnets = {}, {}
	for i=1, numOnline do
		local presenceID, presenceName, battleTag, isBattleTagPresence, _, _, _, _, _, isAFK, isDND, broadcastText, noteText = BNGetFriendInfo(i)
		if not isBattleTagPresence then
			battleTag = nil
		end

		local toons, focus, bnet
		for j=1, BNGetNumFriendToons(i) do
			local hasFocus, toonName, client, realmName, realmID, faction, race, class, _, zoneName, level, gameText = BNGetFriendToonInfo(i, j)
			-- in the past I've seen this return nil data, so use the client as a marker
			if client then
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
				if client == "App" then
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
				presenceID = presenceID,
				presenceName = presenceName,
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
function countRealID(filterClients) -- local at top of file
	local numTotal, numOnline = BNGetNumFriends()

	local friends, bnet = 0, 0
	for i=1, numOnline do
		local isRegular, isBnet = false, false
		for j=1, BNGetNumFriendToons(i) do
			local client = select(3, BNGetFriendToonInfo(i, j))
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

local function addRealID(tooltip, friends, isBnetClient, collapseVar)
	local numTotal = BNGetNumFriends()

	local header
	if isBnetClient then
		header = L.TOOLTIP_REALID_APP
	else
		header = L.TOOLTIP_REALID
	end
	local collapsed = TitanGetVar(TITAN_SOCIAL_ID, collapseVar)
	addHeader(header, "00A2E8", #friends, numTotal, collapsed, collapseVar)

	if collapsed then return end

	local playerRealmID = select(5, BNGetToonInfo(select(3, BNGetInfo())))
	for _, friend in ipairs(friends) do
		local left = ""

		local focus = isBnetClient and friend.bnet or friend.focus

		-- is this friend playing WoW on our server?
		--if focus.client == BNET_CLIENT_WOW then
			--local name
			--if focus.realmID == playerRealmID then
				--name = focus.name
			--else
				---- Cross-realm?
				--name = focus.name.."-"..focus.realmName
			--end
		--end

		-- group member indicator
		local check = getRealIDGroupIndicator(friend.presenceID, playerRealmID)

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
		left = left.."[|cff00A2E8"..(friend.battleTag or friend.presenceName).."|r] "

		-- Status
		left = left..getStatusText(playerStatus).." "

		local broadcastText = friend.broadcastText

		-- Note
		if TitanGetVar(TITAN_SOCIAL_ID, "ShowRealIDNotes") then
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
		local right = focus.gameText and ("|cffFFFFFF"..focus.gameText.."|r") or ""

		local y = tooltip:AddLine(check, level, left, right)
		tooltip:SetLineScript(y, "OnMouseDown", clickRealID, { friend.presenceName, friend.presenceID })

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
					if toon.realmID ~= playerRealmID or toon.faction ~= playerFactionGroup then
						cooperateLabel = _G.CANNOT_COOPERATE_LABEL
					end
					left = _G.FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE:format(toon.name..cooperateLabel, toon.level, toon.race, toon.class)
				else
					left = toon.name
				end
				left = getFactionIndicator(toon.faction, toon.client).."|cffFEE15C"..FRIENDS_LIST_PLAYING.."|cffFFFFFF "..(left or "Unknown").."|r"
				right = "|cffFFFFFF"..(toon.gameText or "").."|r"
				addDoubleLine(true, left, right)
			end
		end
	end
end

local function addFriends(tooltip, collapseVar)
	local numTotal, numOnline = GetNumFriends()

	local collapsed = TitanGetVar(TITAN_SOCIAL_ID, collapseVar)
	addHeader(L.TOOLTIP_FRIENDS, "FFFFFF", numOnline, numTotal, collapsed, collapseVar)

	if collapsed then return end

	for i=1, numOnline do
		local left = ""

		local name, level, class, area, connected, playerStatus, playerNote, isRAF = GetFriendInfo(i)

		-- Group indicator
		local check = getGroupIndicator(name)

		-- fix unknown names - why does this happen?
		local origname = name
		if name == "" then
			name = "Unknown"
		end

		-- Level
		local level = "|cffFFFFFF"..level.."|r"

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
		
		local y = tooltip:AddLine(check, level, left, right)
		tooltip:SetLineScript(y, "OnMouseDown", clickPlayer, { origname, false, false, false })
	end
end

local function processGuildMember(i, isRemote, tooltip)
	local left = ""

	local name, rank, rankIndex, level, class, zone, note, officerNote, online, playerStatus, classFileName, achievementPoints, achievementRank, isMobile = GetGuildRosterInfo(i)

	name = Ambiguate(name, "guild")

	local check = getGroupIndicator(name)

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

	local y = tooltip:AddLine(check, level, left, right)
	tooltip:SetLineScript(y, "OnMouseDown", clickPlayer, { origname, true, isMobile, isRemote })
end

local function addGuild(tooltip, collapseGuildVar, collapseRemoteChatVar)
	isFreshFrame() -- don't trigger GUILD_ROSTER_UPDATE events due to offline toggling
	local wasOffline = GetGuildRosterShowOffline()
	if wasOffline then
		-- SetGuildRosterShowOffline() seems to sometimes trigger GUILD_ROSTER_UPDATE
		SetGuildRosterShowOffline(false)
	end

	local split = TitanGetVar(TITAN_SOCIAL_ID, "ShowSplitRemoteChat")
	local sortKey = TitanGetVar(TITAN_SOCIAL_ID, "SortGuild") and TitanGetVar(TITAN_SOCIAL_ID, "GuildSortKey") or nil
	local roster, numTotal, numOnline, numRemote = collectGuildRosterInfo(split, sortKey, TitanGetVar(TITAN_SOCIAL_ID, "GuildSortAscending") or false)

	local numGuild = split and numOnline or numRemote

	local collapseGuild = TitanGetVar(TITAN_SOCIAL_ID, collapseGuildVar)
	local collapseRemoteChat = TitanGetVar(TITAN_SOCIAL_ID, collapseRemoteChatVar)
	addHeader(L.TOOLTIP_GUILD, "00FF00", numGuild, numTotal, collapseGuild, collapseGuildVar)

	for i, guildIndex in ipairs(roster) do
		local isRemote = guildIndex > numOnline
		local afterSplit = split and isRemote
		if (afterSplit and collapseRemoteChat) or (not afterSplit and collapseGuild) then
			-- collapsed
		else
			processGuildMember(guildIndex, isRemote, tooltip)
		end

		if split and i == numOnline then
			-- add header for Remote Chat
			local numRemoteChat = numRemote - numOnline
			tooltip:AddLine()
			addHeader(L.TOOLTIP_REMOTE_CHAT, "00FF00", numRemoteChat, numTotal, collapseRemoteChat, collapseRemoteChatVar)
		end
	end

	if wasOffline then
		SetGuildRosterShowOffline(wasOffline)
	end
end

local function buildTooltip(tooltip)
	tooltip:AddColspanHeader(3, "LEFT", L.TOOLTIP)

	local showRealID = TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID")
	local showRealIDApp = TitanGetVar(TITAN_SOCIAL_ID, "ShowRealIDApp")
	if showRealID or showRealIDApp then
		local friends, bnet = parseRealID(showRealID)

		if showRealID then
			tooltip:AddLine()
			addRealID(tooltip, friends, false, "CollapseRealID")
		end

		if showRealIDApp then
			tooltip:AddLine()
			addRealID(tooltip, bnet, true, "CollapseRealIDApp")
		end
	end
	
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends") then
		tooltip:AddLine()
		addFriends(tooltip, "CollapseFriends")
	end
	
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") then
		tooltip:AddLine()
		addGuild(tooltip, "CollapseGuild", "CollapseRemoteChat")
	end
end

function updateTooltip(tooltip) -- local at top of file
	tooltip:Clear()

	local ok, message = pcall(buildTooltip, tooltip)
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
			ShowRealID = true,
			ShowRealIDBroadcasts = false,
			ShowRealIDNotes = true,
			ShowRealIDFactions = true,
			ShowRealIDApp = true,
			ShowFriends = true,
			ShowFriendsNote = true,
			ShowGuild = true,
			ShowGuildLabel = false,
			ShowGuildNote = true,
			ShowSplitRemoteChat = true,
			ShowGuildONote = true,
			ShowGroupMembers = true,
			SortGuild = false,
			GuildSortKey = "rank",
			GuildSortAscending = true,
			ShowStatus = STATUS_ICON,
			ShowIcon = true,
			ShowLabel = true,
			TooltipInteraction = INTERACTION_ALWAYS,
			CollapseRealID = false,
			CollapseRealIDApp = false,
			CollapseFriends = false,
			CollapseGuild = false,
			CollapseRemoteChat = false
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
	self:RegisterEvent("CHAT_MSG_BN_INLINE_TOAST_BROADCAST") -- a friend changes their broadcast

	-- Friend Events
	self:RegisterEvent("FRIENDLIST_UPDATE")

	-- Guild Events
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
end

function _G.TitanPanelSocialButton_OnEvent(self, event, ...)
	-- Debugging. Pay no attention to the man behind the curtain.
	if bDebugMode then
		_G.DEFAULT_CHAT_FRAME:AddMessage("Social: OnEvent")
		if event == "PLAYER_ENTERING_WORLD" then
			_G.DEFAULT_CHAT_FRAME:AddMessage(TITAN_SOCIAL_ID.." v"..TITAN_SOCIAL_VERSION.." Loaded.")
		end
		_G.DEFAULT_CHAT_FRAME:AddMessage("Social: Caught Event "..event)
	end

	if event == "GUILD_ROSTER_UPDATE" and not isFreshFrame() then
		-- We only want to process one GUILD_ROSTER_UPDATE per frame, to avoid getting into endless loops
		-- with other addson that toggle the offline state of the guild
		return
	end

	-- Update button label
	TitanPanelButton_UpdateButton(TITAN_SOCIAL_ID)

	-- Update tooltip if shown
	if tooltip:IsVisible() then
		updateTooltip(tooltip)
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


	tooltip:Clear("LEFT", 0, "RIGHT", "LEFT", "RIGHT")
	tooltip:SetAutoHideDelay(0.2, self)
	updateTooltip(tooltip)
	tooltip:SmartAnchorTo(self)
	tooltip:Show()
end

function _G.TitanPanelSocialButton_OnLeave(self)
	local interaction = TitanGetVar(TITAN_SOCIAL_ID, "TooltipInteraction")
	if interaction == INTERACTION_NEVER or (interaction == INTERACTION_OOC and InCombatLockdown()) then
		tooltip:Hide()
	end
end

function _G.TitanPanelSocialButton_OnClick(self, button)
	-- Detect mouse clicks
	if button == "LeftButton" then
		if TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends") or TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") or TitanGetVar(TITAN_SOCIAL_ID, "ShowRealIDApp") then
			-- We want to show the friends tab, but there's a taint issue :/
			if FriendsFrame:IsShown() then
				HideUIPanel(FriendsFrame)
			else
				ShowUIPanel(FriendsFrame)
			end
			--ToggleFriendsFrame(1); -- friends tab
		end

		if TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") then
			ToggleGuildFrame(1); -- guild tab
		end
	elseif button == "RightButton" then
		tooltip:Hide()
	end
end
