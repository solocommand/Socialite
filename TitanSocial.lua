
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

	--
	-- Get Social Online
	--
	
		-- RealID
		iRealIDTotal, iRealIDOnline = BNGetNumFriends();
		
		-- Friends
		iFriendsOnline = GetNumFriends();
		
		-- Guild
		iGuildTotal = GetNumGuildMembers(true);
		iGuildOnline = GetNumGuildMembers;
		
	--
	-- Label Generation
	--

		-- Button Label
		if(bButtonLabel) then
			tButtonLabel = "Social: "
		else
			tButtonLabel = ""
		end
		
		tButtonRichText = "";
		
		-- RealID
		if(bRealID) then
			tButtonRichText = tButtonRichText.."|cff00A2E8"..iRealIDOnline.." ".._G["FONT_COLOR_CODE_CLOSE"];
		end
		
		-- Friends
		if(bFriends) then
			tButtonRichText = tButtonRichText..iFriendsOnline.." ";
		end
		
		-- Guild
		if(bGuild) then
			tButtonRichText = tButtonRichText.."|cff00FF00"..iGuildOnline.._G["FONT_COLOR_CODE_CLOSE"];
		end
	
	
	return tButtonLabel, tButtonRichText
end

----------------------------------------------------------------------
-- TitanPanelSocialButton_GetTooltipText()
----------------------------------------------------------------------

function TitanPanelSocialButton_GetTooltipText()

end


