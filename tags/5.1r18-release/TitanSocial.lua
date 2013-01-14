
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
-- TitanPanelSocial_ColorText(text, className)
----------------------------------------------------------------------

function TitanPanelSocialButton_ColorText(text, className)

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
			tooltipTitle = TITAN_SOCIAL_TOOLTIP,
			tooltipTextFunction = "TitanPanelSocialButton_GetTooltipText",
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

local function setGuildSortOption(info, key, value)
	TitanSetVar(TITAN_SOCIAL_ID, key, value)
end

local function sortCheckedFunc(button)
	local current = TitanGetVar(TITAN_SOCIAL_ID, button.arg1)
	return (current or false) == button.arg2
end

local function addSortOption(text, key, value, level)
	local info = UIDropDownMenu_CreateInfo()
	info.text = text
	info.func = setGuildSortOption
	info.arg1 = key
	info.arg2 = value
	info.keepShownOnClick = false -- can't update the menu while visible
	info.checked = sortCheckedFunc
	info.disabled = not TitanGetVar(TITAN_SOCIAL_ID, "SortGuild")
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
-- TitanPanelSocialButton_GetTooltipText()
----------------------------------------------------------------------

local function getGroupIndicator(name)
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowGroupMembers") then
		if IsInGroup() and name ~= "" then -- don't check self if we're not in a group
			if UnitInParty(name) or UnitInRaid(name) then
				return "|TInterface\\Buttons\\UI-CheckBox-Check:0:0|t" -- checkmark
			end
		end
		return "|T:0:0|t" -- square spacer
	end
	return ""
end

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

local knownLocalRealmID = nil

function TitanPanelSocialButton_GetTooltipText()

	local iRealIDTotal, iRealIDOnline = 0;
	local iFriendsTotal, iFriendsOnline = 0;
	local tTooltipRichText, playerStatus, clientName = "";
	
	--
	--	RealID Friends
	--
	
	if(TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") ~=nil) then
		iRealIDTotal, iRealIDOnline = BNGetNumFriends();
		--iRealIDOnline  = "|cff00A2E8"..iRealIDOnline.."|r";

		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_REALID).."\t".."|cff00A2E8"..iRealIDOnline.."|r"..TitanUtils_GetNormalText("/"..iRealIDTotal).."\n"
		
		for friendIndex=1, iRealIDOnline do
			local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isFriend, unknown = BNGetFriendInfo(friendIndex)
			local hasFocus, toonName, client, realmName, realmID, faction, race, className, _, zoneName, level, gameText, broadcastText, broadcastTime = BNGetToonInfo(presenceID)

			-- group member indicator
			do
				if knownLocalRealmID == nil then
					-- find our local realm ID
					knownLocalRealmID = select(5, BNGetToonInfo(select(3,BNGetInfo())))
				end
				-- is this friend playing WoW on our server?
				local name = ""
				if client == BNET_CLIENT_WOW then
					if realmID == knownLocalRealmID then
						name = toonName
					else
						-- how about a different server? Cross-realm exists
						name = toonName.."-"..realmName
					end
				end
				tTooltipRichText = tTooltipRichText..getGroupIndicator(name)
			end

			-- playerStatus
				if (isAFK) then
					playerStatus = "AFK"
				elseif (isDND) then
					playerStatus = "DND"
				else
					playerStatus = ""
				end
				
			-- Client Information
				if (client == BNET_CLIENT_SC2) then
					clientName = "S2"
				elseif (client == BNET_CLIENT_D3) then
					clientName = "D3"
				else
					clientName = "??"
				end
			
			-- Stan Smith {SC2} ToonName 80 <AFK/DND>\t Location
			-- Stan Smith Toonname 80 (SC2)
			
			if(client ~= BNET_CLIENT_WOW) then
				-- Client Name
				tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..clientName.."|r  "
				tTooltipRichText = tTooltipRichText.."|cffCCCCCC"..toonName.."|r ";
			else
				-- Character Level
				tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..level.."|r  "
				-- Character
				tTooltipRichText = tTooltipRichText..TitanPanelSocialButton_ColorText(toonName, className).." ";
			end
			
			-- Character
			--tTooltipRichText = tTooltipRichText..TitanPanelSocialButton_ColorText(toonName, className).." ";
			
			-- Full Name
			local fullName
			if isBattleTagPresence then
				fullName = battleTag
			else
				fullName = presenceName
			end
			tTooltipRichText = tTooltipRichText.."[|cff00A2E8"..fullName.."|r]  "
			
			-- Status
			if (playerStatus ~= 0) then
                  if (playerStatus == 1) then
                    tTooltipRichText = tTooltipRichText.."|cffFFFFFF".."<AFK>".."|r  ";
                  end
	           end
			
			-- Broadcast
			if(TitanGetVar(TITAN_SOCIAL_ID, "ShowRealIDBroadcasts") ~= nil) then
				if (broadcastText ~= nil) then
				-- it seems as though newlines in broadcastText reset the coloration
				-- Also try to nudge subsequent lines over a bit
				local color = "|cff00A2E8"
				broadcastText = broadcastText:gsub("\n", "|r".."\n        "..color)
				tTooltipRichText = tTooltipRichText..color..broadcastText.."|r ";
				end
			end
			
			-- Character Location
			tTooltipRichText = tTooltipRichText.."\t|cffFFFFFF"..gameText.."|r\n";

		end
	end
	
	--
	-- Friends
	--
	
	if(TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends") ~=nil) then
	
		iFriendsTotal, iFriendsOnline = GetNumFriends();
	
		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_FRIENDS).."\t".."|cffFFFFFF"..iFriendsOnline.."|r"..TitanUtils_GetNormalText("/"..iFriendsTotal).."\n"
		
		for friendIndex=1, iFriendsOnline do
		
			name, level, class, area, connected, playerStatus, playerNote, RAF = GetFriendInfo(friendIndex);
			
			tTooltipRichText = tTooltipRichText..getGroupIndicator(name)

			-- toonName Fix
				if (name == "") then
					name = "Unknown"
				end
			
			-- Level
			tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..level.."|r  ";
			
			-- Name
			tTooltipRichText = tTooltipRichText..TitanPanelSocialButton_ColorText(name, class).." ";

			-- Status
			if (playerStatus ~= 0) then
                  if (playerStatus == 1) then
                    tTooltipRichText = tTooltipRichText.."|cffFFFFFF".."<AFK>".."|r  ";
                  end
	           end
			
			-- Notes
			if(TitanGetVar(TITAN_SOCIAL_ID, "ShowFriendsNote") ~= nil) then
				if(playerNote ~= nil) then
					tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..playerNote.."|r ";
				end
			end
			
			-- Location
			--tTooltipRichText = tTooltipRichText.."\t|cffFFFFFF"..area.."|r\n";
			if (area ~= nil) then 
				tTooltipRichText = tTooltipRichText.."\t|cffFFFFFF"..area.."|r\n" 
			end 
		
		end
	end
	
	--
	-- Guild
	--
	
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") then
		local wasOffline = GetGuildRosterShowOffline()
		SetGuildRosterShowOffline(false)

		local split = TitanGetVar(TITAN_SOCIAL_ID, "ShowSplitRemoteChat")
		local sortKey = TitanGetVar(TITAN_SOCIAL_ID, "SortGuild") and TitanGetVar(TITAN_SOCIAL_ID, "GuildSortKey") or nil
		local roster, guildTotal, guildOnline, guildRemote = collectGuildRosterInfo(split, sortKey, TitanGetVar(TITAN_SOCIAL_ID, "GuildSortAscending") or false)

		local remoteChatText = nil
		local numGuild = guildRemote
		if split then
			remoteChatText = ""
			numGuild = guildOnline
		end
		local guildText = ""
		
		for _, guildIndex in ipairs(roster) do
			name, rank, rankIndex, level, class, zone, note, officernote, online, playerStatus, classFileName, achievementPoints, achievementRank, isMobile = GetGuildRosterInfo(guildIndex)
			
			local currentText = ""

			currentText = currentText..getGroupIndicator(name)
			
			-- toonName Fix
			if name=="" then
				name = "Unknown"
			end
			
			local isRemote = guildIndex > guildOnline
			if isMobile then
				if isRemote then zone = REMOTE_CHAT end
				if playerStatus == 2 then
					name = MOBILE_BUSY_ICON..name
				elseif playerStatus == 1 then
					name = MOBILE_AWAY_ICON..name
				else
					name = ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)..name
				end
			end
			
			-- 80 {color=class::Playername} {<AFK>} Rank Note ONote\t Location
			
			-- Level
			currentText = currentText.."|cffFFFFFF"..level.."|r  "

			-- Name
			currentText = currentText..TitanPanelSocialButton_ColorText(name, class).." ";

			-- Status
			if playerStatus ~= 0 then
				if playerStatus == 1 then
					currentText = currentText.."|cffFFFFFF".."<AFK>".."|r  ";
				else
					currentText = currentText.."|cffFFFFFF".."<DND>".."|r  ";
				end
			end

			-- Rank
			currentText = currentText..rank.."  ";
			
			-- Notes
			if TitanGetVar(TITAN_SOCIAL_ID, "ShowGuildNote") then
				currentText = currentText.."|cffFFFFFF"..note.."|r  "
			end
			
			-- Officer Notes
			if TitanGetVar(TITAN_SOCIAL_ID, "ShowGuildONote") then
				if CanViewOfficerNote() then
					currentText = currentText.."|cffAAFFAA"..officernote.."|r  "
				end
			end
			
			-- Location
			if zone ~= nil then 
				currentText = currentText.."\t|cffFFFFFF"..zone.."|r\n"
			else
				currentText = currentText.."\n"
			end
			
			if isRemote and remoteChatText ~= nil then
				remoteChatText = remoteChatText..currentText
			else
				guildText = guildText..currentText
			end
		end
		
		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_GUILD).."\t".."|cff00FF00"..numGuild.."|r"..TitanUtils_GetNormalText("/"..guildTotal).."\n"..guildText

		if remoteChatText ~= nil then
			local numRemoteChat = guildRemote - guildOnline
			tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_REMOTE_CHAT).."\t".."|cff00FF00"..numRemoteChat.."|r"..TitanUtils_GetNormalText("/"..guildTotal).."\n"..remoteChatText
		end

		SetGuildRosterShowOffline(wasOffline)
	end
	
	if (TitanGetVar(TITAN_SOCIAL_ID, "ShowMem") ~=nil) then
		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_MEM).."\t|cff00FF00"..floor(GetAddOnMemoryUsage("TitanSocial")).." "..TITAN_SOCIAL_TOOLTIP_MEM_UNIT.."|r";
	end
	
	return tTooltipRichText;
end
