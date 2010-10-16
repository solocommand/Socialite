
----------------------------------------------------------------------
--  Local variables
----------------------------------------------------------------------

-- Debugging Mode
	bDebugMode = true;

-- Required Titan variables
	TITAN_SOCIAL_ID = "Social";
	TITAN_SOCIAL_VERSION = "4.0.1r12-beta";
	TITAN_NIL = false;

-- Friend-specific variables
	iFriendsTab = 1;
-- RealID-specific variables
-- Guild-specific variables
	

-- Counters for Titan Bar Display
	iRealIDOnline, iFriendsOnline, iGuildOnline = 0;

----------------------------------------------------------------------
--  Global variables
----------------------------------------------------------------------



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
			savedVariables = {       
				ShowRealID = 1,
				ShowFriends = 1,
				ShowGuild = 1,
				ShowLabel = 1,
				ShowIcon = 1,
			  }
		};

	--
	-- CONFIGURATION --
	--
	
		-- Load these settings from SavedVariables/&Set Defaults
		
		-- Temporary hardcode needed settings
		--bAltTracker	= false;	-- Enable/disable AltTracker -- Disabled for debugging
		--bRealID = true;			-- Enable/disable RealID Friends Component
		--bFriends = true;		-- Enable/disable Friends Component
		--bGuild = true;			-- Enable/disable Guild Component
		--bButtonLabel = true;	-- Enable/disable static label text
		--bButtonIcon = false;	-- Enable/disable static button icon
		
		-- bAltTracker = TitanGetVar(TITAN_SOCIAL_ID, "bAltTracker");
		--bRealID = 		TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID");
		--bFriends = 		TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends");
		--bGuild = 		TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild");
		--bButtonLabel =	TitanGetVar(TITAN_SOCIAL_ID, "ShowLabel");
		--bButtonIcon =	TitanGetVar(TITAN_SOCIAL_ID, "ShowIcon");
		
		-- Dynamic Settings
		bGuildOffline = GetGuildRosterShowOffline()	-- Enable/disable including offline guild members

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

	if(bDebugMode) then
		if(event == "PLAYER_ENTERING_WORLD") then
			DEFAULT_CHAT_FRAME:AddMessage(TITAN_SOCIAL_ID.." v"..TITAN_SOCIAL_VERSION.." Loaded.");
			--DEFAULT_CHAT_FRAME:AddMessage(TITAN_SOCIAL_ID.." bRealID: "..bRealID);
			if (TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") ~= nil) then
				svarresult = "True";
			else
				svarresult = "False";
			end
			DEFAULT_CHAT_FRAME:AddMessage(TITAN_SOCIAL_ID.." SavedVariable: "..svarresult);
			
		end
		DEFAULT_CHAT_FRAME:AddMessage("Social: Caught Event "..event);
	end

	TitanPanelButton_UpdateButton(TITAN_SOCIAL_ID);

end

----------------------------------------------------------------------
--  TitanPanelSocialButton_OnUpdate(self, elapsed)
----------------------------------------------------------------------

function TitanPanelSocialButton_OnUpdate(self, elapsed)

	TitanPanelSocialButton_GetButtonText(TitanUtils_GetButton(id));

end

----------------------------------------------------------------------
--  TitanPanelSocialButton_OnClick(self, button)
----------------------------------------------------------------------

function TitanPanelSocialButton_OnClick(self, button)

	if (button == "LeftButton") then
		if (not FriendsFrame:IsVisible()) then
			ToggleFriendsFrame(iFriendsTab);
			FriendsFrame_Update();
		elseif (FriendsFrame:IsVisible()) then
			ToggleFriendsFrame(iFriendsTab);
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
	
	tButtonTemplate1 = "%s";
	tButtonTemplate2 = "%s |cffffd200/|r %s";
	tButtonTemplate3 = "%s |cffffd200/|r %s |cffffd200/|r %s";

	if(TitanGetVar(TITAN_SOCIAL_ID, "ShowLabel") ~= nil) then
		TITAN_SOCIAL_BUTTON_LABEL = "Social: ";
	else
		TITAN_SOCIAL_BUTTON_LABEL = " ";
	end
	

	-- Custom Labels
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
	
	
	-- Custom Labels
	--if(bRealID) and (bFriends) and (bGuild) then
	--	-- ## / ## / ##
	--	TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL.."%s"..TitanUtils_GetNormalText("/").."%s"..TitanUtils_GetNormalText("/").."%s";
	--	tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, "|cff00A2E8"..iRealIDOnline.."|r", "|cffFFFFFF"..iFriendsOnline.."|r", "|cff00FF00"..iGuildOnline.."|r");
	--elseif (bRealID) and (bFriends) and (not bGuild) then
	--	-- ## / ## / XX
	--	TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL.."%s"..TitanUtils_GetNormalText("/").."%s";
	--	tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, "|cff00A2E8"..iRealIDOnline.."|r", "|cffFFFFFF"..iFriendsOnline.."|r");
	--elseif (bRealID) and (not bFriends) and (bGuild) then
	--	-- ## / XX / ##
	--	TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL.."%s"..TitanUtils_GetNormalText("/").."%s";
	--	tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, "|cff00A2E8"..iRealIDOnline.."|r", "|cffFFFFFF"..iGuildOnline.."|r");
	--elseif (bRealID) and (not bFriends) and (not bGuild) then
	--	-- ## / XX / XX
	--	TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL.."%s";
	--	tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, "|cff00A2E8"..iRealIDOnline.."|r");
	--elseif (not bRealID) and (bFriends) and (bGuild) then
	--	-- XX / ## / ##
	--	TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL.."%s"..TitanUtils_GetNormalText("/").."%s";
	--	tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, "|cffFFFFFF"..iFriendsOnline.."|r", "|cff00FF00"..iGuildOnline.."|r");
	--elseif (not bRealID) and (bFriends) and (not bGuild) then
	--	-- XX / ## / XX
	--	TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL.."%s";
	--	tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, "|cffFFFFFF"..iFriendsOnline.."|r");
	--elseif (not bRealID) and (not bFriends) and (bGuild) then
	--	-- XX / XX / ##
	--	TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL.."%s";
	--	tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, "|cff00FF00"..iGuildOnline.."|r");
	--else
	--	-- XX / XX / XX
	--	TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL.."%s";
	--	tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, "Disabled");
	--end
	
	
	-- 		TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL.."%s"..TitanUtils_GetNormalText("/").."%s"..TitanUtils_GetNormalText("/").."%s";
	--		tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, "|cff00A2E8"..iRealIDOnline.."|r", "|cffFFFFFF"..iFriendsOnline.."|r", "|cff00FF00"..iGuildOnline.."|r");
	
	
	--
	-- Label Generation
	--
	--
	--	-- Button Label
	--	if(bButtonLabel) then
	--		tButtonLabel = "Social: ";
	--	end
	--		
	--	-- RealID
	--	if(bRealID) then
	--		tButtonRichText = tButtonRichText.."|cff00A2E8"..iRealIDOnline.."|r";
	--	end
	--	
	--	-- Friends
	--	if(bFriends) then
	--		if(not bRealID) then
	--			tButtonRichText = tButtonRichText..iFriendsOnline.." ";
	--		else
	--			tButtonRichText = tButtonRichText..TitanUtils_GetNormalText(" / ")..iFriendsOnline.." ";
	--		end
	--	end
	--	
	--	-- Guild
	--	if(bGuild) then
	--		if(not bFriends) and (not bRealID) then
	--			tButtonRichText = tButtonRichText.."|cff00FF00"..iGuildOnline.."|r";
	--		elseif(not bFriends) then
	--			tButtonRichText = tButtonRichText..TitanUtils_GetNormalText(" / ").."|cff00FF00"..iGuildOnline.."|r";
	--		end
	--	end
	
	return TITAN_SOCIAL_BUTTON_LABEL, tButtonRichText;
end

----------------------------------------------------------------------
-- TitanPanelSocialButton_GetTooltipText()
----------------------------------------------------------------------

function TitanPanelSocialButton_GetTooltipText()

	local iRealIDTotal, iRealIDOnline = BNGetNumFriends();
	local iFriendsTotal, iFriendsOnline = GetNumFriends();
	local iGuildTotal, iGuildOnline = GetNumGuildMembers();
	local tTooltipRichText, playerStatus, clientName = "";
		
	--
	-- Tooltip Header
	--
	--	tTooltipRichText = tTooltipRichText..TitanUtils_GetNormalText("RealID Friends Online:").."\t".."|cff00A2E8"..iRealIDOnline.."|r"..TitanUtils_GetNormalText("/"..iRealIDTotal).."\n"
	--	tTooltipRichText = tTooltipRichText..TitanUtils_GetNormalText("Normal Friends Online:").."\t".."|cffFFFFFF"..iFriendsOnline.."|r"..TitanUtils_GetNormalText("/"..iFriendsTotal).."\n"
	--	tTooltipRichText = tTooltipRichText..TitanUtils_GetNormalText("Guild Members Online:").."\t".."|cff00FF00"..iGuildOnline.."|r"..TitanUtils_GetNormalText("/"..iGuildTotal).."\n"
	--	tTooltipRichText = tTooltipRichText.." ".."\n"	-- Line Break
	
	--
	-- RealID Friends
	--
	
		tTooltipRichText = tTooltipRichText..TitanUtils_GetNormalText("RealID Friends Online:").."\t".."|cff00A2E8"..iRealIDOnline.."|r"..TitanUtils_GetNormalText("/"..iRealIDTotal).."\n"
		
		for friendIndex=1, iRealIDOnline do

			presenceID, givenName, surname, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isFriend, unknown = BNGetFriendInfo(friendIndex)
			unknowntoon, toonName, client, realmName, faction, race, class, unknown, zoneName, level, gameText, broadcastText, broadcastTime = BNGetToonInfo(presenceID)

			-- playerStatus
				if (isAFK) then
					playerStatus = "AFK"
				elseif (isDND) then
					playerStatus = "DND"
				else
					playerStatus = ""
				end
				
			-- Client Information
				if (client == "WoW") then
					clientName = "World of Warcraft"
				elseif (client == "S2") then
					clientName = "Starcraft 2"
				elseif (client == "D3") then
					clientName = "Diablo 3"
				else
					clientName = "Unknown Client"
				end
			
			-- Class Colors
				if (class == "Druid") then
					classColor = "|cffff7d0a";
				elseif (class == "Hunter") then
					classColor = "|cffabd473";
				elseif (class == "Mage") then
					classColor = "|cff69ccf0";
				elseif (class == "Paladin") then
					classColor = "|cfff58cba";
				elseif (class == "Priest") then
					classColor = "|cffffffff";
				elseif (class == "Rogue") then
					classColor = "|cfffff569";
				elseif (class == "Shaman") then
					classColor = "|cff2459ff";
				elseif (class == "Warlock") then
					classColor = "|cff9482ca";
				elseif (class == "Warrior") then
					classColor = "|cffc79c6e";
				elseif (class == "Death Knight") then
					classColor = "|cffc41f3b";
				else
					classColor = "|cffCCCCCC";
				end
			
			-- Stan Smith {SC2} ToonName 80 <AFK/DND>\t Location
			-- Stan Smith Toonname 80 (SC2)
			
			-- Character Level
			tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..level.."|r  "
			
			-- Character
			tTooltipRichText = tTooltipRichText..classColor..toonName.."|r  "
			
			-- Full Name
			tTooltipRichText = tTooltipRichText.."[|cff00A2E8"..givenName.." "..surname.."|r]  "
			
			-- Game Name
			if(client~="WoW") then
				tTooltipRichText = tTooltipRichText.."("..clientName..")  ";
			end
						
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
	
	--
	-- Friends
	--
		
		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText("Normal Friends Online:").."\t".."|cffFFFFFF"..iFriendsOnline.."|r"..TitanUtils_GetNormalText("/"..iFriendsTotal).."\n"
		
		for friendIndex=1, iFriendsOnline do
		
			name, friendLevel, class, area, connected, playerStatus, playerNote, RAF = GetFriendInfo(friendIndex);

			-- Class Colors
				if (class == "Druid") then				classColor = "|cffff7d0a";
				elseif (class == "Hunter") then			classColor = "|cffabd473";
				elseif (class == "Mage") then			classColor = "|cff69ccf0";
				elseif (class == "Paladin") then		classColor = "|cfff58cba";
				elseif (class == "Priest") then			classColor = "|cffffffff";
				elseif (class == "Rogue") then			classColor = "|cfffff569";
				elseif (class == "Shaman") then			classColor = "|cff2459ff";
				elseif (class == "Warlock") then		classColor = "|cff9482ca";
				elseif (class == "Warrior") then		classColor = "|cffc79c6e";
				elseif (class == "Death Knight") then	classColor = "|cffc41f3b";
				else									classColor = "|cffCCCCCC";
				end
			
			-- Level
			tToolTipRichText = tTooltipRichText.."|cffFFFFFF"..friendLevel.."|r  ";
			
			-- Name
			tTooltipRichText = tTooltipRichText..classColor..name.."|r ";

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
		
	--
	-- Guild
	--
		
		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText("Guild Members Online:").."\t".."|cff00FF00"..iGuildOnline.."|r"..TitanUtils_GetNormalText("/"..iGuildTotal).."\n"
		
		for guildIndex=1, iGuildOnline do
		
			name, rank, rankIndex, level, class, zone, note, officernote, online, playerStatus, classFileName = GetGuildRosterInfo(guildIndex);
			
				-- Class Colors
				if (class == "Druid") then				classColor = "|cffff7d0a";
				elseif (class == "Hunter") then			classColor = "|cffabd473";
				elseif (class == "Mage") then			classColor = "|cff69ccf0";
				elseif (class == "Paladin") then		classColor = "|cfff58cba";
				elseif (class == "Priest") then			classColor = "|cffffffff";
				elseif (class == "Rogue") then			classColor = "|cfffff569";
				elseif (class == "Shaman") then			classColor = "|cff2459ff";
				elseif (class == "Warlock") then		classColor = "|cff9482ca";
				elseif (class == "Warrior") then		classColor = "|cffc79c6e";
				elseif (class == "Death Knight") then	classColor = "|cffc41f3b";
				else									classColor = "|cffCCCCCC";
				end
		
			-- 80 {color=class::Playername} {<AFK>} Rank Note ONote\t Location
			
			-- Level
			tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..level.."|r  "
			-- Name
			tTooltipRichText = tTooltipRichText..classColor..name.."|r  "
			-- Status
			if (playerStatus ~= "") then
				tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..playerStatus.."|r  ";
			end
			-- Rank
			tTooltipRichText = tTooltipRichText..rank.."  ";
			-- Notes
			tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..note.."|r  "
			tTooltipRichText = tTooltipRichText.."|cffAAFFAA"..officernote.."|r  "
			-- Location
			tTooltipRichText = tTooltipRichText.."\t|cffFFFFFF"..zone.."|r\n"			
			
		end
	
	return tTooltipRichText;
end








































