
----------------------------------------------------------------------
--  Local variables
----------------------------------------------------------------------

-- Debugging Mode
	bDebugMode = true;

-- Required Titan variables
	TITAN_SOCIAL_ID = "Social";
	TITAN_SOCIAL_VERSION = "4.0.1a1";
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
		};
		
	--
	-- CONFIGURATION --
	--
	
		-- Load these settings from SavedVariables/&Set Defaults
		
		-- Temporary hardcode needed settings
		bAltTracker	= false;	-- Enable/disable AltTracker -- Disabled for debugging
		bFriends = true;		-- Enable/disable Friends Component
		bRealID = true;			-- Enable/disable RealID Friends Component
		bGuild = true;			-- Enable/disable Guild Component
		bButtonLabel = true;	-- Enable/disable static label text
		bButtonIcon = false;	-- Enable/disable static button icon
		
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
		end
		DEFAULT_CHAT_FRAME:AddMessage("Social: Caught Event "..event);
	end

	TitanPanelButton_UpdateButton(TITAN_SOCIAL_ID);

end

----------------------------------------------------------------------
--  TitanPanelSocialButton_OnClick(self, button)
----------------------------------------------------------------------

function TitanPanelSocialButton_OnClick(self, button)
	if (not FriendsFrame:IsVisible()) then
		ToggleFriendsFrame(iFriendsTab);
		FriendsFrame_Update();
	elseif (FriendsFrame:IsVisible()) then
		ToggleFriendsFrame(iFriendsTab);
	end
end

----------------------------------------------------------------------
-- TitanPanelSocialButton_GetButtonText(id)
----------------------------------------------------------------------

function TitanPanelSocialButton_GetButtonText(id)
	local id = TitanUtils_GetButton(id);
	local iRealIDTotal, iRealIDOnline = BNGetNumFriends();
	local iFriendsTotal, iFriendsOnline = GetNumFriends();
	local iGuildTotal, iGuildOnline = GetNumGuildMembers();
	local tButtonRichText = "";
	local tButtonLabel = "";
	
	TITAN_SOCIAL_BUTTON_LABEL = "Social: ";
	TITAN_SOCIAL_BUTTON_TEXT = TITAN_SOCIAL_BUTTON_LABEL.."%s"..TitanUtils_GetNormalText("/").."%s"..TitanUtils_GetNormalText("/").."%s";

	tButtonRichText = format(TITAN_SOCIAL_BUTTON_TEXT, "|cff00A2E8"..iRealIDOnline.."|r", TitanUtils_GetNormalText(iFriendsOnline), "|cff00FF00"..iGuildOnline.."|r");
	
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
					classColor = "|cff000000";
				end
			
			-- Stan Smith {SC2} ToonName 80 <AFK/DND>\t Location
			-- Stan Smith Toonname 80
			
			-- Full Name
			tTooltipRichText = tTooltipRichText.."|cff00A2E8"..givenName.." "..surname.."|r "
			
			-- Game Name
			--tTooltipRichText = tTooltipRichText.."{"..client.."} "

			-- Character
			tTooltipRichText = tTooltipRichText..classColor..toonName.."|r "
				
			-- Character Level
			tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..level.."|r "
						
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
		
	--
	-- Guild
	--
		
		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText("Guild Members Online:").."\t".."|cff00FF00"..iGuildOnline.."|r"..TitanUtils_GetNormalText("/"..iGuildTotal).."\n"
	
	return tTooltipRichText;
end








































