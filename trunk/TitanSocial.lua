
----------------------------------------------------------------------
--  Local variables
----------------------------------------------------------------------

-- Debugging Mode
	local bDebugMode = false;
	
-- Localization
	--local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)

-- Required Titan variables
	TITAN_SOCIAL_ID = "Social";
	TITAN_SOCIAL_VERSION = "5.1r18";
	TITAN_NIL = false;
	
-- Update frequency
	TITAN_SOCIAL_UPDATE = 15.0;	-- Update every 15 seconds to avoid roster update nastiness

-- Friend-specific variables
	local iFriendsTab = 1;
-- RealID-specific variables
-- Guild-specific variables
	local iGuildTab = 1;

-- Counters for Titan Bar Display
	local iRealIDOnline, iFriendsOnline, iGuildOnline = 0;

	local MOBILE_BUSY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t";
	local MOBILE_AWAY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t";

	local STATUS_ICON = "icon"
	local STATUS_TEXT = "text"
	local STATUS_NONE = "none"

-- Class support
	local TitanSocial_ClassMap = {}
	
-- Build the class map
	
	for i = 1, GetNumClasses() do
		local name, className, classId = GetClassInfo(i)
    TitanSocial_ClassMap[LOCALIZED_CLASS_NAMES_MALE[className]] = className
    TitanSocial_ClassMap[LOCALIZED_CLASS_NAMES_FEMALE[className]] = className
	end

----------------------------------------------------------------------
--  Global variables
----------------------------------------------------------------------


----------------------------------------------------------------------
-- colorText(text, className)
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

----------------------------------------------------------------------
--  TitanPanelSocialButton_OnLoad(self)
----------------------------------------------------------------------

function TitanPanelSocialButton_OnLoad(self)


	--
	-- LOCAL REGISTRY --
	--
	
		self.registry = { 
			id = TITAN_SOCIAL_ID,
			version = TITAN_SOCIAL_VERSION,
			menuText = TITAN_SOCIAL_MENU_TEXT, 
			buttonTextFunction = "TitanPanelSocialButton_GetButtonText",
			tooltipCustomFunction = TitanPanelSocialButton_SetTooltip,
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
		};

	--
	-- CONFIGURATION --
	--
	
		-- Load these settings from SavedVariables/&Set Defaults
		
		-- Dynamic Settings


	--
	-- EVENT CATCHING --
	--
	
		-- General Events
		self:RegisterEvent("PLAYER_ENTERING_WORLD");
		
		-- RealID Events
		self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE");
		self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE");
		self:RegisterEvent("BN_FRIEND_TOON_OFFLINE");
		self:RegisterEvent("BN_FRIEND_TOON_ONLINE");
		self:RegisterEvent("BN_TOON_NAME_UPDATED");
		
		-- Friend Events
		self:RegisterEvent("FRIENDLIST_UPDATE");
		
		-- Guild Events
		self:RegisterEvent("GUILD_ROSTER_UPDATE");
		
end

----------------------------------------------------------------------
--  TitanPanelSocialButton_OnEvent(self, event, ...)
----------------------------------------------------------------------

function TitanPanelSocialButton_OnEvent(self, event, ...)

	-- Debugging. Pay no attention to the man behind the curtain.
	if(bDebugMode) then
		DEFAULT_CHAT_FRAME:AddMessage("Social: OnEvent");
		if(event == "PLAYER_ENTERING_WORLD") then
			DEFAULT_CHAT_FRAME:AddMessage(TITAN_SOCIAL_ID.." v"..TITAN_SOCIAL_VERSION.." Loaded.");
		end
		DEFAULT_CHAT_FRAME:AddMessage("Social: Caught Event "..event);
	end

	-- Update button label
	TitanPanelButton_UpdateButton(TITAN_SOCIAL_ID);

end

----------------------------------------------------------------------
-- TitanPanelSocialButton_OnEnter(self)
----------------------------------------------------------------------

function TitanPanelSocialButton_OnEnter(self)

	-- If in a guild, steal roster update. If not, ignore and update anyway
	if (IsInGuild()) then	
		FriendsFrame:UnregisterEvent("GUILD_ROSTER_UPDATE");
		GuildRoster();
		FriendsFrame:RegisterEvent("GUILD_ROSTER_UPDATE");
	end

	-- Update Titan button label and tooltip
	TitanPanelButton_UpdateButton(TITAN_SOCIAL_ID);	
	TitanPanelButton_UpdateTooltip(self);
end

----------------------------------------------------------------------
--  TitanPanelSocialButton_OnUpdate(self, elapsed)
----------------------------------------------------------------------

function TitanPanelSocialButton_OnUpdate(self, elapsed)
	
	-- From wowwiki, best practices for low-intensity onupdates.
	-- Run updates every TITAN_SOCIAL_UPDATE to keep resources low
	-- and avoid 10s timeout/wait from guild_update_roster
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	
	if (self.TimeSinceLastUpdate > TITAN_SOCIAL_UPDATE) then
		TitanPanelSocialButton_GetButtonText(TitanUtils_GetButton(id));
		self.TimeSinceLastUpdate = 0;
		if(bDebugMode) then
			DEFAULT_CHAT_FRAME:AddMessage("Social: OnUpdate Timer");
		end
	end

end

----------------------------------------------------------------------
--  TitanPanelSocialButton_OnClick(self, button)
----------------------------------------------------------------------

function TitanPanelSocialButton_OnClick(self, button)

	-- Detect mouse clicks
	if (button == "LeftButton") then

		if (TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") ~= nil or TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") ~= nil) then
      ToggleFriendsFrame(iFriendsTab);
      FriendsFrame_Update();
    end
    
    if (TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") ~= nil) then
      ToggleGuildFrame(iGuildTab);
    end
    
	end
	
end

----------------------------------------------------------------------
--  TitanPanelRightClickMenu_PrepareSocialMenu()
----------------------------------------------------------------------

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

function TitanPanelRightClickMenu_PrepareSocialMenu(frame, level, menuList)
	if level == 1 then
		TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_SOCIAL_ID].menuText, level);
		
		-- RealID Menu
		addSubmenu(TITAN_SOCIAL_MENU_REALID, "RealID", level)
		
		-- Friends Menu
		addSubmenu(TITAN_SOCIAL_MENU_FRIENDS, "Friends", level)
		
		-- Guild Menu
		addSubmenu(TITAN_SOCIAL_MENU_GUILD, "Guild", level)
		
		TitanPanelRightClickMenu_AddSpacer(level);
		TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_SHOW_GROUP_MEMBERS, TITAN_SOCIAL_ID, "ShowGroupMembers", nil, level)

		-- Status menu
		addSubmenu(TITAN_SOCIAL_MENU_STATUS, "Status", level)
		
		TitanPanelRightClickMenu_AddSpacer(level)
		TitanPanelRightClickMenu_AddToggleIcon(TITAN_SOCIAL_ID, level)
		TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_LABEL, TITAN_SOCIAL_ID, "ShowLabel", nil, level)
		TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_MEM, TITAN_SOCIAL_ID, "ShowMem", nil, level)
		TitanPanelRightClickMenu_AddSpacer(level)
		TitanPanelRightClickMenu_AddCommand(TITAN_SOCIAL_MENU_HIDE, TITAN_SOCIAL_ID, TITAN_PANEL_MENU_FUNC_HIDE, level)
	elseif level == 2 then
		-- RealID Menu
		if menuList == "RealID" then
			TitanPanelRightClickMenu_AddTitle(TITAN_SOCIAL_MENU_REALID, level);
			TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_REALID_FRIENDS, TITAN_SOCIAL_ID, "ShowRealID", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_REALID_BROADCASTS, TITAN_SOCIAL_ID, "ShowRealIDBroadcasts", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_REALID_NOTE, TITAN_SOCIAL_ID, "ShowRealIDNotes", nil, level)
		end
		
		-- Friends Menu
		if menuList == "Friends" then
			TitanPanelRightClickMenu_AddTitle(TITAN_SOCIAL_MENU_FRIENDS, level);
			TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_FRIENDS_SHOW, TITAN_SOCIAL_ID, "ShowFriends", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_FRIENDS_NOTE, TITAN_SOCIAL_ID, "ShowFriendsNote", nil, level)
		end
		
		-- Guild Menu
		if menuList == "Guild" then
			TitanPanelRightClickMenu_AddTitle(TITAN_SOCIAL_MENU_GUILD, level);
			TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_GUILD_MEMBERS, TITAN_SOCIAL_ID, "ShowGuild", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_GUILD_LABEL, TITAN_SOCIAL_ID, "ShowGuildLabel", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_GUILD_NOTE, TITAN_SOCIAL_ID, "ShowGuildNote", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_GUILD_ONOTE, TITAN_SOCIAL_ID, "ShowGuildONote", nil, level)
			TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_GUILD_REMOTE_CHAT, TITAN_SOCIAL_ID, "ShowSplitRemoteChat", nil, level)
			
			TitanPanelRightClickMenu_AddSpacer(level)
			addSubmenu(TITAN_SOCIAL_MENU_GUILD_SORT, "GuildSort", level)
		end

		-- Status Menu
		if menuList == "Status" then
			addRadioRefresh(TITAN_SOCIAL_MENU_STATUS_ICON, "ShowStatus", STATUS_ICON, level)
			addRadioRefresh(TITAN_SOCIAL_MENU_STATUS_TEXT, "ShowStatus", STATUS_TEXT, level)
			addRadioRefresh(TITAN_SOCIAL_MENU_STATUS_NONE, "ShowStatus", STATUS_NONE, level)
		end
		
		if menuList == "Options" then
			TitanPanelRightClickMenu_AddTitle(TITAN_SOCIAL_MENU_OPTIONS, level);
		end
	elseif level == 3 then
		-- Guild Sorting
		if menuList == "GuildSort" then
			-- we'd like to use AddToggleVar() but we can't keep the menu open
			do
				local info = UIDropDownMenu_CreateInfo()
				info.text = TITAN_SOCIAL_MENU_GUILD_SORT_DEFAULT
				info.func = function ()
					TitanToggleVar(TITAN_SOCIAL_ID, "SortGuild")
				end
				info.keepShownOnClick = false
				info.checked = not TitanGetVar(TITAN_SOCIAL_ID, "SortGuild")
				UIDropDownMenu_AddButton(info, level)
			end
			TitanPanelRightClickMenu_AddSpacer(level)
			addSortOption(TITAN_SOCIAL_MENU_GUILD_SORT_NAME, "GuildSortKey", "name", level)
			addSortOption(TITAN_SOCIAL_MENU_GUILD_SORT_RANK, "GuildSortKey", "rank", level)
			addSortOption(TITAN_SOCIAL_MENU_GUILD_SORT_CLASS, "GuildSortKey", "class", level)
			addSortOption(TITAN_SOCIAL_MENU_GUILD_SORT_LEVEL, "GuildSortKey", "level", level)
			addSortOption(TITAN_SOCIAL_MENU_GUILD_SORT_ZONE, "GuildSortKey", "zone", level)
			TitanPanelRightClickMenu_AddSpacer(level)
			addSortOption(TITAN_SOCIAL_MENU_GUILD_SORT_ASCENDING, "GuildSortAscending", true, level)
			addSortOption(TITAN_SOCIAL_MENU_GUILD_SORT_DESCENDING, "GuildSortAscending", false, level)
		end
	end
end

----------------------------------------------------------------------
-- TitanPanelSocialButton_GetButtonText(id)
----------------------------------------------------------------------

function TitanPanelSocialButton_GetButtonText(id)
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
			label = TITAN_SOCIAL_BUTTON_TITLE
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

	return TITAN_SOCIAL_BUTTON_TITLE, label;
end

----------------------------------------------------------------------
-- TitanPanelSocialButton_SetTooltip()
----------------------------------------------------------------------

local function ternary(cond, a, b)
	if cond then
		return a
	else
		return b
	end
end

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

local function addRealID(tooltip, digitWidth)
	local numTotal, numOnline = BNGetNumFriends()

	tooltip:AddDoubleLine(TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_REALID), "|cff00A2E8"..numOnline.."|r"..TitanUtils_GetNormalText("/"..numTotal))

	for i=1, numOnline do
		local left = ""

		local presenceID, presenceName, battleTag, isBattleTagPresence, _, _, client, _, _, isAFK, isDND, broadcastText, noteText = BNGetFriendInfo(i)
		local _, toonName, client, realmName, realmID, faction, _, className, _, _, level, gameText = BNGetToonInfo(presenceID)

		-- group member indicator
		-- is this friend playing WoW on our server?
		if client == BNET_CLIENT_WOW then
			local playerRealmID = select(5, BNGetToonInfo(select(3, BNGetInfo())))
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

		-- Character
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

		tooltip:AddDoubleLine(left, right)
		if extraLines then
			local indent = getGroupIndicator("")..spacer(digitWidth, 2).."  "
			for _, line in ipairs(extraLines) do
				-- indent the line over
				line = indent..line
				tooltip:AddLine(line)
			end
		end
	end
end

local function addFriends(tooltip, digitWidth)
	local numTotal, numOnline = GetNumFriends()

	tooltip:AddDoubleLine(TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_FRIENDS), "|cffFFFFFF"..numOnline.."|r"..TitanUtils_GetNormalText("/"..numTotal))

	for i=1, numOnline do
		local left = ""

		local name, level, class, area, connected, playerStatus, playerNote, isRAF = GetFriendInfo(i)

		-- Group indicator
		left = left..getGroupIndicator(name)

		-- fix unknown names - why does this happen?
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
		if area ~= nil then
			right = "|cffFFFFFF"..area.."|r"
		end
		
		tooltip:AddDoubleLine(left, right)
	end
end

local function processGuildMember(i, isRemote, tooltip, digitWidth)
	local left = ""

	local name, rank, rankIndex, level, class, zone, note, officerNote, online, playerStatus, classFileName, achievementPoints, achievementRank, isMobile = GetGuildRosterInfo(i)

	left = left..getGroupIndicator(name)

	-- fix name
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
			name = ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)..name
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

	tooltip:AddDoubleLine(left, right)
end

local function addGuild(tooltip, digitWidth)
	local wasOffline = GetGuildRosterShowOffline()
	SetGuildRosterShowOffline(false)

	local split = TitanGetVar(TITAN_SOCIAL_ID, "ShowSplitRemoteChat")
	local sortKey = TitanGetVar(TITAN_SOCIAL_ID, "SortGuild") and TitanGetVar(TITAN_SOCIAL_ID, "GuildSortKey") or nil
	local roster, numTotal, numOnline, numRemote = collectGuildRosterInfo(split, sortKey, TitanGetVar(TITAN_SOCIAL_ID, "GuildSortAscending") or false)

	local numGuild = split and numOnline or numRemote

	tooltip:AddDoubleLine(TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_GUILD), "|cff00FF00"..numGuild.."|r"..TitanUtils_GetNormalText("/"..numTotal))

	for i, guildIndex in ipairs(roster) do
		local isRemote = guildIndex > numOnline
		processGuildMember(guildIndex, isRemote, tooltip, digitWidth)

		if split and i == numOnline then
			-- add header for Remote Chat
			local numRemoteChat = numRemote - numOnline
			tooltip:AddLine(" ")
			tooltip:AddDoubleLine(TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_REMOTE_CHAT), "|cff00FF00"..numRemoteChat.."|r"..TitanUtils_GetNormalText("/"..numTotal))
		end
	end

	SetGuildRosterShowOffline(wasOffline)
end

local function buildTooltip(tooltip, digitWidth)
	tooltip:SetText(TITAN_SOCIAL_TOOLTIP, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)

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
		tooltip:AddLine(" ")
		tooltip:AddDoubleLine(TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_MEM), "|cff00FF00"..floor(GetAddOnMemoryUsage("TitanSocial")).." "..TITAN_SOCIAL_TOOLTIP_MEM_UNIT.."|r")
	end
end

function TitanPanelSocialButton_SetTooltip()
	local tooltip = GameTooltip

	-- Calculate the width of 1 digit
	-- We're assuming that all digits in a font have the same width, since that seems to be the case
	-- Set up the tooltip with a title and one line of body text, then measure the body text
	tooltip:SetText("title")
	tooltip:AddLine("0")
	local digitWidth = GameTooltipTextLeft2:GetStringWidth()

	local ok, message = pcall(buildTooltip, tooltip, digitWidth)
	if not ok then
		print("|cffFF0000TitanSocial error: " .. message .. "|r")
		error(message, 0)
	end
end
