
----------------------------------------------------------------------
--  Local variables
----------------------------------------------------------------------

-- Debugging Mode
	bDebugMode = false;

-- Required Titan variables
	TITAN_SOCIAL_ID = "Social";
	TITAN_SOCIAL_VERSION = "4.0.1b2";
	TITAN_NIL = false;
	
-- Update frequency
	TITAN_SOCIAL_UPDATE = 15.0;	-- Update every 15 seconds to avoid roster update nastiness

-- Friend-specific variables
	iFriendsTab = 1;
-- RealID-specific variables
-- Guild-specific variables
	iGuildTab = 1;

-- Counters for Titan Bar Display
	iRealIDOnline, iFriendsOnline, iGuildOnline = 0;

----------------------------------------------------------------------
--  Global variables
----------------------------------------------------------------------


----------------------------------------------------------------------
-- TitanPanelSocial_ColorText(text, className)
----------------------------------------------------------------------

function TitanPanelGuildButton_ColorText(text, className)
	
	-- Class color index for localization.
	local TITAN_SOCIAL_CLASSCOLORINDEX = {
		[1] = "|cffff7d0a",
		[2] = "|cffabd473",
		[3] = "|cff69ccf0",
		[4] = "|cfff58cba",
		[5] = "|cffffffff",
		[6] = "|cfffff569",	
		[7] = "|cff2459ff",
		[8] = "|cff9482ca",
		[9] = "|cffc79c6e",
		[10] = "|cffc41f3b",
	}
	local index = TITAN_SOCIAL_CLASSINDEX[className];
	local coloredText = TITAN_SOCIAL_CLASSCOLORINDEX[index]..text.."|r";
	return coloredText;

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
			icon = "Interface\\FriendsFrame\\BroadcastIcon";
			savedVariables = {       
				ShowRealID = 1,
				ShowFriends = 1,
				ShowGuild = 1,
				ShowLabel = 1,
				ShowIcon = 1,
				ShowMem = 1,
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
-- TitanPanelSocialButton_OnEnter()
----------------------------------------------------------------------

function TitanPanelSocialButton_OnEnter()

	-- If in a guild, steal roster update. If not, ignore and update anyway
	if (IsInGuild()) then	
		FriendsFrame:UnregisterEvent("GUILD_ROSTER_UPDATE");
		GuildRoster();
		FriendsFrame:RegisterEvent("GUILD_ROSTER_UPDATE");
	end

	-- Update Titan button label and tooltip
	TitanPanelButton_UpdateButton(TITAN_SOCIAL_ID);	
	TitanPanelButton_UpdateTooltip(this);
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
		-- Left button only, right is for menu
		if (not FriendsFrame:IsVisible()) then
			-- If the friends frame is hidden, show friend and guild frame.
			ToggleFriendsFrame(iFriendsTab);
			FriendsFrame_Update();
			ToggleGuildFrame(iGuildTab);
		elseif (FriendsFrame:IsVisible()) then
			-- Otherwise, hide them both
			ToggleFriendsFrame(iFriendsTab);
			ToggleGuildFrame(iGuildTab);
		end
	end
	
end

----------------------------------------------------------------------
--  TitanPanelRightClickMenu_PrepareSocialMenu()
----------------------------------------------------------------------

function TitanPanelRightClickMenu_PrepareSocialMenu()     
  
    local info = {};  
    TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_SOCIAL_ID].menuText);
    TitanPanelRightClickMenu_AddToggleVar("Show RealID Friends", TITAN_SOCIAL_ID, "ShowRealID");
	TitanPanelRightClickMenu_AddToggleVar("Show Friends", TITAN_SOCIAL_ID, "ShowFriends");
	TitanPanelRightClickMenu_AddToggleVar("Show Guild Members", TITAN_SOCIAL_ID, "ShowGuild");
    TitanPanelRightClickMenu_AddSpacer();
    TitanPanelRightClickMenu_AddToggleIcon(TITAN_SOCIAL_ID);
	TitanPanelRightClickMenu_AddToggleVar("Show Label", TITAN_SOCIAL_ID, "ShowLabel");
	TitanPanelRightClickMenu_AddToggleVar("Show Memory Usage", TITAN_SOCIAL_ID, "ShowMem");
    TitanPanelRightClickMenu_AddSpacer();
    TitanPanelRightClickMenu_AddCommand("Hide", TITAN_SOCIAL_ID, TITAN_PANEL_MENU_FUNC_HIDE);
  
end

----------------------------------------------------------------------
-- TitanPanelSocialButton_GetButtonText(id)
----------------------------------------------------------------------

function TitanPanelSocialButton_GetButtonText(id)
	local id = TitanUtils_GetButton(id);
	local iRealIDTotal, iRealIDOnline = 0;
	local iFriendsTotal, iFriendsOnline = 0;
	local iGuildTotal, iGuildOnline = 0;
	local tButtonRichText = "";
	
	local tButtonTemplate1 = "%s";
	local tButtonTemplate2 = "%s |cffffd200/|r %s";
	local tButtonTemplate3 = "%s |cffffd200/|r %s |cffffd200/|r %s";

	--
	-- SavedVars//Colors
	--
	if (TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") ~= nil) then
		iRealIDTotal, iRealIDOnline = BNGetNumFriends();
		iRealIDOnline  = "|cff00A2E8"..iRealIDOnline.."|r";
	end
	
	if (TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends") ~= nil) then
		iFriendsTotal, iFriendsOnline = GetNumFriends();
		iFriendsOnline = "|cffFFFFFF"..iFriendsOnline.."|r";
	end
	
	if (TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") ~= nil) then
		iGuildTotal, iGuildOnline = GetNumGuildMembers();
		iGuildOnline   = "|cff00FF00"..iGuildOnline.."|r";
	end
	
	if(TitanGetVar(TITAN_SOCIAL_ID, "ShowLabel") ~= nil) then
		TITAN_SOCIAL_BUTTON_LABEL = "Social: ";
	else
		TITAN_SOCIAL_BUTTON_LABEL = " ";
	end
	
	--
	-- Custom Labels --
	--
	
	if (TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") ~= nil) then
		if (TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends") ~= nil) then
			if (TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") ~= nil) then
				-- ## / ## / ## Ok
				TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL..tButtonTemplate3;
				tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, iRealIDOnline, iFriendsOnline, iGuildOnline);
			else
				-- ## / ## / XX Ok
				TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL..tButtonTemplate2;
				tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, iRealIDOnline, iFriendsOnline);
			end
		else
			if (TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") ~= nil) then
				-- ## / XX / ## Ok
				TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL..tButtonTemplate2;
				tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, iRealIDOnline, iGuildOnline);
			else
				-- ## / XX / XX Ok
				TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL..tButtonTemplate1;
				tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, iRealIDOnline);
			end
		end
	else
		if (TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends") ~= nil) then
			if (TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") ~= nil) then
				-- XX / ## / ## Ok
				TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL..tButtonTemplate2;
				tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, iFriendsOnline, iGuildOnline);
			else
				-- XX / ## / XX
				TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL..tButtonTemplate1;
				tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, iFriendsOnline);
			end
		else
			if (TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") ~= nil) then
				-- XX / XX / ##
				TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL..tButtonTemplate1;
				tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, iGuildOnline);
			else
				-- XX / XX / XX
				TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL..tButtonTemplate1;
				tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, "Disabled");
			end
		end
	end

	return TITAN_SOCIAL_BUTTON_LABEL, tButtonRichText;
end

----------------------------------------------------------------------
-- TitanPanelSocialButton_GetTooltipText()
----------------------------------------------------------------------

function TitanPanelSocialButton_GetTooltipText()

	local iRealIDTotal, iRealIDOnline = 0;
	local iFriendsTotal, iFriendsOnline = 0;
	local iGuildTotal, iGuildOnline = 0;
	local tTooltipRichText, playerStatus, clientName = "";
	local bGuildOffline = GetGuildRosterShowOffline()	-- Enable/disable including offline guild members
	
	--
	--	RealID Friends
	--
	
	if(TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") ~=nil) then
		iRealIDTotal, iRealIDOnline = BNGetNumFriends();
		--iRealIDOnline  = "|cff00A2E8"..iRealIDOnline.."|r";

		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText("RealID Friends Online:").."\t".."|cff00A2E8"..iRealIDOnline.."|r"..TitanUtils_GetNormalText("/"..iRealIDTotal).."\n"
		
		for friendIndex=1, iRealIDOnline do

			presenceID, givenName, surname, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isFriend, unknown = BNGetFriendInfo(friendIndex)
			unknowntoon, toonName, client, realmName, faction, race, className, unknown, zoneName, level, gameText, broadcastText, broadcastTime = BNGetToonInfo(presenceID)

			-- playerStatus
				if (isAFK) then
					playerStatus = "AFK"
				elseif (isDND) then
					playerStatus = "DND"
				else
					playerStatus = ""
				end
				
			-- Client Information
				if (client == "S2") then
					clientName = "S2"
				elseif (client == "D3") then
					clientName = "D3"
				else
					clientName = "??"
				end
			
			-- Class Colors
			--	if (class == "Druid") then				classColor = "|cffff7d0a";
			--	elseif (class == "Hunter") then			classColor = "|cffabd473";
			--	elseif (class == "Mage") then			classColor = "|cff69ccf0";
			--	elseif (class == "Paladin") then		classColor = "|cfff58cba";
			--	elseif (class == "Priest") then			classColor = "|cffffffff";
			--	elseif (class == "Rogue") then			classColor = "|cfffff569";
			--	elseif (class == "Shaman") then			classColor = "|cff2459ff";
			--	elseif (class == "Warlock") then		classColor = "|cff9482ca";
			--	elseif (class == "Warrior") then		classColor = "|cffc79c6e";
			--	elseif (class == "Death Knight") then	classColor = "|cffc41f3b";
			--	else									classColor = "|cffCCCCCC";
			--	end
			
			-- Stan Smith {SC2} ToonName 80 <AFK/DND>\t Location
			-- Stan Smith Toonname 80 (SC2)
			
			if(client ~= "WoW") then
				-- Client Name
				tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..clientName.."|r  "
				tTooltipRichText = tTooltipRichText.."|cffCCCCCC"..toonName.."|r ";
			else
				-- Character Level
				tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..level.."|r  "
				-- Character
				tTooltipRichText = tTooltipRichText..TitanPanelGuildButton_ColorText(toonName, className).." ";
			end
			
			-- Character
			--tTooltipRichText = tTooltipRichText..TitanPanelGuildButton_ColorText(toonName, className).." ";
			
			-- Full Name
			tTooltipRichText = tTooltipRichText.."[|cff00A2E8"..givenName.." "..surname.."|r]  "
			
			-- Status
			if (playerStatus ~= "") then
				tTooltipRichText = tTooltipRichText.."<"..playerStatus..">"
			end
			
			-- Character Location
			tTooltipRichText = tTooltipRichText.."\t|cffFFFFFF"..gameText.."|r\n";

			-- Broadcast
			--if (broadcastText ~= "") then
			--	tTooltipRichText = tTooltipRichText.." \t|cff00A0E0"..broadcastText.."|r\n";
			--end		
		
		end
	end
	
	--
	-- Friends
	--
	
	if(TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends") ~=nil) then
	
		iFriendsTotal, iFriendsOnline = GetNumFriends();
	
		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText("Friends Online:").."\t".."|cffFFFFFF"..iFriendsOnline.."|r"..TitanUtils_GetNormalText("/"..iFriendsTotal).."\n"
		
		for friendIndex=1, iFriendsOnline do
		
			name, level, class, area, connected, playerStatus, playerNote, RAF = GetFriendInfo(friendIndex);

			-- Class Colors
			--	if (class == "Druid") then				classColor = "|cffff7d0a";
			--	elseif (class == "Hunter") then			classColor = "|cffabd473";
			--	elseif (class == "Mage") then			classColor = "|cff69ccf0";
			--	elseif (class == "Paladin") then		classColor = "|cfff58cba";
			--	elseif (class == "Priest") then			classColor = "|cffffffff";
			--	elseif (class == "Rogue") then			classColor = "|cfffff569";
			--	elseif (class == "Shaman") then			classColor = "|cff2459ff";
			--	elseif (class == "Warlock") then		classColor = "|cff9482ca";
			--	elseif (class == "Warrior") then		classColor = "|cffc79c6e";
			--	elseif (class == "Death Knight") then	classColor = "|cffc41f3b";
			--	else									classColor = "|cffCCCCCC";
			--	end
			
			-- Level
			--tToolTipRichText = tTooltipRichText.."|cffFFFFFF##"..level.."|r  ";
			tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..level.."|r  ";
			
			-- Name
			tTooltipRichText = tTooltipRichText..TitanPanelGuildButton_ColorText(name, class).." ";

			-- Status
			if (playerStatus ~= "") then
				tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..playerStatus.."|r ";
			end
			
			-- Notes
			--if(playerNote ~= "") then
			--	tTooltipRichText = tTooltipRichText..playerNote;
			--end
			
			-- Location
			tTooltipRichText = tTooltipRichText.."\t|cffFFFFFF"..area.."|r\n";
		
		end
	end
	
	--
	-- Guild
	--
	
	if(TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") ~=nil) then
	
		-- Turn off showoffline for tooltip
		SetGuildRosterShowOffline(false);
		
		iGuildTotal, iGuildOnline = GetNumGuildMembers();
		--iGuildOnline   = "|cff00FF00"..iGuildOnline.."|r";
		
		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText("Guild Members Online:").."\t".."|cff00FF00"..iGuildOnline.."|r"..TitanUtils_GetNormalText("/"..iGuildTotal).."\n"
		
		for guildIndex=1, iGuildOnline do
		
			name, rank, rankIndex, level, class, zone, note, officernote, online, playerStatus, classFileName = GetGuildRosterInfo(guildIndex);
			
			-- Class Colors
			--	if (class == "Druid") then				classColor = "|cffff7d0a";
			--	elseif (class == "Hunter") then			classColor = "|cffabd473";
			--	elseif (class == "Mage") then			classColor = "|cff69ccf0";
			--	elseif (class == "Paladin") then		classColor = "|cfff58cba";
			--	elseif (class == "Priest") then			classColor = "|cffffffff";
			--	elseif (class == "Rogue") then			classColor = "|cfffff569";
			--	elseif (class == "Shaman") then			classColor = "|cff2459ff";
			--	elseif (class == "Warlock") then		classColor = "|cff9482ca";
			--	elseif (class == "Warrior") then		classColor = "|cffc79c6e";
			--	elseif (class == "Death Knight") then	classColor = "|cffc41f3b";
			--	else									classColor = "|cffCCCCCC";
			--	end
		
			-- 80 {color=class::Playername} {<AFK>} Rank Note ONote\t Location
			
			-- Level
			tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..level.."|r  "
			-- Name
			tTooltipRichText = tTooltipRichText..TitanPanelGuildButton_ColorText(name, class).." ";
			-- Status
			if (playerStatus ~= "") then
				tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..playerStatus.."|r  ";
			end
			-- Rank
			tTooltipRichText = tTooltipRichText..rank.."  ";
			-- Notes
			tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..note.."|r  "
			
			-- Officer Notes
			if(CanViewOfficerNote()) then
				tTooltipRichText = tTooltipRichText.."|cffAAFFAA"..officernote.."|r  "
			end
			
			-- Location
			tTooltipRichText = tTooltipRichText.."\t|cffFFFFFF"..zone.."|r\n"			
			
		end
		
		-- Reset ShowOffline Guild Members to original value
		if (bGuildOffline) then
			SetGuildRosterShowOffline(true);
		end
	
	end
	
	if (TitanGetVar(TITAN_SOCIAL_ID, "ShowMem") ~=nil) then
		tTooltipRichText = tTooltipRichText.." \nTitanSocial Memory Utilization:\t|cff00FF00"..floor(GetAddOnMemoryUsage( "TitanSocial")).." Kb|r";
	end
	
	return tTooltipRichText;
end








































