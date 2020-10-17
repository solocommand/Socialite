local addonName, addon = ...
local L = addon.L
local ldbi = LibStub('LibDBIcon-1.0', true)
local frame = addon.frame
frame.name = addonName
frame:Hide()

frame:SetScript("OnShow", function(frame)
  local function newCheckbox(key, callback)
    local label = L[key]
    local description = L[key.."Description"]
    local check = CreateFrame("CheckButton", "SocialiteCheck"..key, frame, "InterfaceOptionsCheckButtonTemplate")
    check:SetScript("OnClick", function(self)
      local tick = self:GetChecked()
      addon:setDB(key, tick and true or false)
      if tick then
        PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
      else
        PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
      end
      if (type(callback) == "function") then callback(tick and true or false) end
    end)
    check.label = _G[check:GetName() .. "Text"]
    check.label:SetText(label)
    check.tooltipText = label
    check.tooltipRequirement = description
    return check
  end

  -- Battle.net Friends
  local RealID = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  RealID:SetPoint("TOPLEFT", 16, -16)
  RealID:SetText(L["Battle.net Friends"])

  local ShowRealID = newCheckbox("ShowRealID")
  ShowRealID:SetChecked(addon.db.ShowRealID)
  ShowRealID:SetPoint("TOPLEFT", RealID, "BOTTOMLEFT", -2, -16)

  local ShowRealIDBroadcasts = newCheckbox("ShowRealIDBroadcasts")
  ShowRealIDBroadcasts:SetChecked(addon.db.ShowRealIDBroadcasts)
  ShowRealIDBroadcasts:SetPoint("TOPLEFT", ShowRealID, "BOTTOMLEFT", 0, -8)

  local ShowRealIDFactions = newCheckbox("ShowRealIDFactions")
  ShowRealIDFactions:SetChecked(addon.db.ShowRealIDFactions)
  ShowRealIDFactions:SetPoint("TOPLEFT", ShowRealIDBroadcasts, "BOTTOMLEFT", 0, -8)

  local ShowRealIDNotes = newCheckbox("ShowRealIDNotes")
  ShowRealIDNotes:SetChecked(addon.db.ShowRealIDNotes)
  ShowRealIDNotes:SetPoint("TOPLEFT", ShowRealIDFactions, "BOTTOMLEFT", 0, -8)

  local ShowRealIDApp = newCheckbox("ShowRealIDApp")
  ShowRealIDApp:SetChecked(addon.db.ShowRealIDApp)
  ShowRealIDApp:SetPoint("TOPLEFT", ShowRealIDNotes, "BOTTOMLEFT", 0, -8)

  -- Character friends
  local Friends = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  Friends:SetPoint("TOPLEFT", ShowRealIDApp, "BOTTOMLEFT", 2, -16)
  Friends:SetText(L["Character Friends"])

  local ShowFriends = newCheckbox("ShowFriends")
  ShowFriends:SetChecked(addon.db.ShowFriends)
  ShowFriends:SetPoint("TOPLEFT", Friends, "BOTTOMLEFT", -2, -16)

  local ShowFriendsNote = newCheckbox("ShowFriendsNote")
  ShowFriendsNote:SetChecked(addon.db.ShowFriendsNote)
  ShowFriendsNote:SetPoint("TOPLEFT", ShowFriends, "BOTTOMLEFT", 0, -8)

  -- Tooltip config

  local Tooltip = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  Tooltip:SetPoint("TOPLEFT", ShowFriendsNote, "BOTTOMLEFT", 2, -16)
  Tooltip:SetText(L["Tooltip Settings"])

  local info = {}

  local ShowStatusLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  ShowStatusLabel:SetPoint("TOPLEFT", Tooltip, "BOTTOMLEFT", 2, -16)
  ShowStatusLabel:SetText(L.MENU_STATUS)

	local showStatus = CreateFrame("Frame", "SocialiteShowStatus", frame, "UIDropDownMenuTemplate")
	showStatus:SetPoint("TOPLEFT", ShowStatusLabel, "BOTTOMLEFT", -15, -10)
	showStatus.initialize = function()
		wipe(info)
		local options = {
      icon={text=L.MENU_STATUS_ICON, description=L.MENU_STATUS_ICON_DESCRIPTION},
      text={text=L.MENU_STATUS_TEXT, description=L.MENU_STATUS_TEXT_DESCRIPTION},
      none={text=L.MENU_STATUS_NONE, description=L.MENU_STATUS_NONE_DESCRIPTION},
    }
		for key, opts in next, options do
      info.text = opts.text
      info.tooltipTitle = opts.text;
      info.tooltipText = opts.description;
      info.tooltipOnButton = true
			info.value = key
      info.func = function(self)
        addon:setDB("ShowStatus", self.value)
				SocialiteShowStatusText:SetText(self:GetText())
			end
      info.checked = key == addon.db.ShowStatus
      UIDropDownMenu_AddButton(info)
		end
	end
	SocialiteShowStatusText:SetText(L.MENU_STATUS)

  local TooltipInteractionLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  TooltipInteractionLabel:SetPoint("TOPLEFT", SocialiteShowStatus, "BOTTOMLEFT", 15, -16)
  TooltipInteractionLabel:SetText(L.MENU_INTERACTION)

	local tooltipInteraction = CreateFrame("Frame", "SocialiteTooltipInteraction", frame, "UIDropDownMenuTemplate")
	tooltipInteraction:SetPoint("TOPLEFT", TooltipInteractionLabel, "BOTTOMLEFT", -15, -10)
	tooltipInteraction.initialize = function()
		wipe(info)
		local options = {
      icon={text=L.MENU_INTERACTION_ALWAYS, description=L.MENU_INTERACTION_ALWAYS_DESCRIPTION},
      text={text=L.MENU_INTERACTION_OOC, description=L.MENU_INTERACTION_OOC_DESCRIPTION},
      none={text=L.MENU_INTERACTION_NEVER, description=L.MENU_INTERACTION_NEVER_DESCRIPTION},
    }
		for key, opts in next, options do
      info.text = opts.text
      info.tooltipTitle = opts.text;
      info.tooltipText = opts.description;
      info.tooltipOnButton = true
			info.value = key
			info.func = function(self)
        addon:setDB("TooltipInteraction", self.value)
				SocialiteTooltipInteractionText:SetText(self:GetText())
			end
      info.checked = key == addon.db.TooltipInteraction
      UIDropDownMenu_AddButton(info)
		end
	end
	SocialiteTooltipInteractionText:SetText(L.MENU_INTERACTION)

  -- Guild config
  local Guild = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  Guild:SetPoint("TOPLEFT", 320, -16)
  Guild:SetText(L["Guild Members"])

  local ShowGuild = newCheckbox("ShowGuild")
  ShowGuild:SetChecked(addon.db.ShowGuild)
  ShowGuild:SetPoint("TOPLEFT", Guild, "BOTTOMLEFT", -2, -16)

  local ShowGuildLabel = newCheckbox("ShowGuildLabel")
  ShowGuildLabel:SetChecked(addon.db.ShowGuildLabel)
  ShowGuildLabel:SetPoint("TOPLEFT", ShowGuild, "BOTTOMLEFT", 0, -8)

  local ShowGuildNote = newCheckbox("ShowGuildNote")
  ShowGuildNote:SetChecked(addon.db.ShowGuildNote)
  ShowGuildNote:SetPoint("TOPLEFT", ShowGuildLabel, "BOTTOMLEFT", 0, -8)

  local ShowGuildONote = newCheckbox("ShowGuildONote")
  ShowGuildONote:SetChecked(addon.db.ShowGuildONote)
  ShowGuildONote:SetPoint("TOPLEFT", ShowGuildNote, "BOTTOMLEFT", 0, -8)

  local ShowSplitRemoteChat = newCheckbox("ShowSplitRemoteChat")
  ShowSplitRemoteChat:SetChecked(addon.db.ShowSplitRemoteChat)
  ShowSplitRemoteChat:SetPoint("TOPLEFT", ShowGuildONote, "BOTTOMLEFT", 0, -8)

  -- Character friends
  local GuildSorting = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  GuildSorting:SetPoint("TOPLEFT", ShowSplitRemoteChat, "BOTTOMLEFT", 2, -16)
  GuildSorting:SetText(L["Guild Sorting"])

  -- Defined here so the sort method can modify it
	local GuildSortKey = CreateFrame("Frame", "SocialiteGuildSortKey", frame, "UIDropDownMenuTemplate")
  local GuildSortAscending = newCheckbox("GuildSortAscending")

  local GuildSort = newCheckbox("GuildSort", function(value)
    if (value) then
      UIDropDownMenu_EnableDropDown(GuildSortKey)
      GuildSortAscending:Enable()
      _G[GuildSortAscending:GetName().."Text"]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
  else
      UIDropDownMenu_DisableDropDown(GuildSortKey)
      GuildSortAscending:Disable()
      _G[GuildSortAscending:GetName().."Text"]:SetTextColor(DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);
    end
  end)
  GuildSort:SetChecked(addon.db.GuildSort)
  GuildSort:SetPoint("TOPLEFT", GuildSorting, "BOTTOMLEFT", -2, -16)

  if (not addon.db.GuildSort) then
    UIDropDownMenu_DisableDropDown(SocialiteGuildSortKey)
    GuildSortAscending:Disable()
    _G[GuildSortAscending:GetName().."Text"]:SetTextColor(DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);
  end

	-- local GuildSortKey
  GuildSortKey:SetPoint("TOPLEFT", GuildSort, "BOTTOMLEFT", -15, -10)
	GuildSortKey.initialize = function()
		wipe(info)
		local options = {
      name={text=L.MENU_GUILD_SORT_NAME, description=L.MENU_GUILD_SORT_NAME_DESCRIPTION},
      rank={text=L.MENU_GUILD_SORT_RANK, description=L.MENU_GUILD_SORT_RANK_DESCRIPTION},
      class={text=L.MENU_GUILD_SORT_CLASS, description=L.MENU_GUILD_SORT_CLASS_DESCRIPTION},
      note={text=L.MENU_GUILD_SORT_NOTE, description=L.MENU_GUILD_SORT_NOTE_DESCRIPTION},
      level={text=L.MENU_GUILD_SORT_LEVEL, description=L.MENU_GUILD_SORT_LEVEL_DESCRIPTION},
      zone={text=L.MENU_GUILD_SORT_ZONE, description=L.MENU_GUILD_SORT_ZONE_DESCRIPTION},
    }
		for key, opts in next, options do
      info.text = opts.text
      info.tooltipTitle = opts.text;
      info.tooltipText = opts.description;
      info.tooltipOnButton = true
			info.value = key
			info.func = function(self)
        addon:setDB("GuildSortKey", self.value)
				SocialiteGuildSortKeyText:SetText(self:GetText())
			end
      info.checked = key == addon.db.GuildSortKey
      UIDropDownMenu_AddButton(info)
		end
	end
  SocialiteGuildSortKeyText:SetText(L.MENU_GUILD_SORT)

	-- local GuildSortAscending
  GuildSortAscending:SetChecked(addon.db.GuildSortAscending)
  -- GuildSortAscending:SetPoint("TOPLEFT", GuildSortKey, "BOTTOMLEFT", 0, -8)
  GuildSortAscending:SetPoint("TOPLEFT", GuildSortKey, "BOTTOMLEFT", 16, -16)

  -- Minimap button
  local MinimapButton = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  MinimapButton:SetPoint("TOPLEFT", GuildSortAscending, "BOTTOMLEFT", 2, -16)
  MinimapButton:SetText(L["Minimap Button"])

  local minimapToggle = CreateFrame("CheckButton", "SocialiteCheckMinimapToggle", frame, "InterfaceOptionsCheckButtonTemplate")
  minimapToggle:SetScript("OnClick", function(self)
    local value = self:GetChecked()
    local config = addon.db.minimap
    config.hide = not value
    addon:setDB("minimap", config)
    ldbi:Refresh(addonName)
  end)
  minimapToggle.label = _G[minimapToggle:GetName() .. "Text"]
  minimapToggle.label:SetText(L['Show minimap button'])
  minimapToggle.tooltipText = L['Show minimap button']
  minimapToggle.tooltipRequirement = L['Show the Socialite minimap button']

  minimapToggle:SetChecked(not addon.db.minimap.hide)
  minimapToggle:SetPoint("TOPLEFT", MinimapButton, "BOTTOMLEFT", -2, -16)

  local ShowGroupMembers = newCheckbox("ShowGroupMembers")
  ShowGroupMembers:SetChecked(addon.db.ShowGroupMembers)
  ShowGroupMembers:SetPoint("TOPLEFT", minimapToggle, "BOTTOMLEFT", 0, -8)

  frame:SetScript("OnShow", nil)
end)
InterfaceOptions_AddCategory(frame)
