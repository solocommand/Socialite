local addonName, addon = ...
local L = addon.L
local ldbi = LibStub('LibDBIcon-1.0', true)

local function buildCheckbox(key, order)
  return {
    type = 'toggle',
    name = L[key],
    order = order or 0,
    desc = L[key.."Description"],
    get = function(info) return addon.db[info[#info]] end,
    set = function(info, value) return addon:setDB(info[#info], value) end,
  }
end

local function buildDropdown(key, label, opts, order)
  return {
    type = 'select',
    name = label,
    order = order or 0,
    values = opts,
    disabled = true, -- @todo fix dropdowns!
    get = function(info) return addon.db[info[#info]] end,
    set = function(info, value) addon.setDB(info[#info], value) end,
    style = 'dropdown',
  }
end

local function build()
  local t = {
    name = "Socialite",
    type = 'group',
    args = {
      showMinimapIcon = {
        type = 'toggle',
        name = L['Show minimap button'],
        desc = L['Show the Socialite minimap button'],
        order = 0,
        get = function(info) return not addon.db.minimap.hide end,
        set = function(info, value)
          local config = addon.db.minimap
          config.hide = not value
          addon:setDB("minimap", config)
          ldbi:Refresh(addonName)
        end,
      },
      showInAddonCompartment = {
        type = 'toggle',
        name = L.showInAddonCompartment,
        desc = L.showInAddonCompartmentDescription,
        order = 1,
        get = function(info) return addon.db[info[#info]] end,
        set = function(info, value)
          addon:setDB(info[#info], value)
          if value then
            ldbi:AddButtonToCompartment(addonName)
          else
            ldbi:RemoveButtonFromCompartment(addonName)
          end
        end
      },
      DisableUsageText = buildCheckbox("DisableUsageText", 2),
      battleNetFriends = {
        type = "group",
        name = L["Battle.net Friends"],
        order = 10,
        args = {
          ShowRealID = buildCheckbox("ShowRealID", 11),
          ShowRealIDBroadcasts = buildCheckbox("ShowRealIDBroadcasts", 12),
          ShowRealIDFactions = buildCheckbox("ShowRealIDFactions", 13),
          ShowRealIDNotes = buildCheckbox("ShowRealIDNotes", 14),
          ShowRealIDApp = buildCheckbox("ShowRealIDApp", 15),
        }
      },
      characterFriends = {
        type = "group",
        name = L["Character Friends"],
        order = 20,
        args = {
          ShowFriends = buildCheckbox("ShowFriends", 21),
          ShowFriendsNote = buildCheckbox("ShowFriendsNote", 22),
        }
      },
      dataText = {
        type = "group",
        name = L["Data text"],
        order = 25,
        args = {
          ShowLabel = buildCheckbox("ShowLabel", 3),
        },
      },
      tooltip = {
        type = "group",
        name = L["Tooltip Settings"],
        order = 30,
        args = {
          -- @todo review these, they don't seem to work!
          ShowStatus = buildDropdown("ShowStatus", L.MENU_STATUS, {
            icon = L.MENU_STATUS_ICON,
            text = L.MENU_STATUS_TEXT,
            none = L.MENU_STATUS_NONE,
          }, 31),
          TooltipInteraction = buildDropdown("TooltipInteraction", L.MENU_INTERACTION, {
            always = L.MENU_INTERACTION_ALWAYS,
            outofcombat = L.MENU_INTERACTION_OOC,
            never = L.MENU_INTERACTION_NEVER,
          }, 32),
          ShowGroupMembers = buildCheckbox("ShowGroupMembers", 33),
        },
      },
      guild = {
        type = 'group',
        name = L['Guild Members'],
        order = 40,
        args = {
          ShowGuild = buildCheckbox("ShowGuild", 41),
          ShowGuildLabel = buildCheckbox("ShowGuildLabel", 42),
          ShowGuildNote = buildCheckbox("ShowGuildNote", 43),
          ShowGuildONote = buildCheckbox("ShowGuildONote", 44),
          ShowSplitRemoteChat = buildCheckbox("ShowSplitRemoteChat", 45),
          GuildSorting = {
            type = 'header',
            name = L["Guild Sorting"],
            order = 46,
          },
          GuildSort = buildCheckbox("GuildSort", 47),
          -- @todo
          GuildSortKey = buildDropdown("GuildSortKey", L.MENU_GUILD_SORT, {
            name = L.MENU_GUILD_SORT_NAME,
            rank = L.MENU_GUILD_SORT_RANK,
            class = L.MENU_GUILD_SORT_CLASS,
            note = L.MENU_GUILD_SORT_NOTE,
            level = L.MENU_GUILD_SORT_LEVEL,
            zone = L.MENU_GUILD_SORT_ZONE,
          }, 48),
          GuildSortAscending = buildCheckbox("GuildSortAscending", 49),
        },
      },
    },
  }

  return t
end

LibStub("AceConfig-3.0"):RegisterOptionsTable("Socialite", build, "/socialite")
addon.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, "Socialite")
-- LibStub("AceConsole-3.0"):RegisterChatCommand("socialite", function() Settings.OpenToCategory(addonName) end)
