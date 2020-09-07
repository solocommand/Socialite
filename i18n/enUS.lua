-- @todo pull from localization
local addonName, addon = ...

local L = {}

-- Configuration options

L["Battle.net Friends"] = "Battle.net Friends"
L["ShowRealID"] = "Show friends"
L["ShowRealIDDescription"] = "Show friends in the data text and tooltip."
L["ShowRealIDApp"] = "Show non-playing friends"
L["ShowRealIDAppDescription"] = "If enabled, show all Battle.net friends, regardless of in-game status."
L["ShowRealIDBroadcasts"] = "Show broadcasts/toasts"
L["ShowRealIDBroadcastsDescription"] = "ShowRealIDBroadcastsDescription"
L["ShowRealIDFactions"] = "Show friends faction"
L["ShowRealIDFactionsDescription"] = "ShowRealIDFactionsDescription"
L["ShowRealIDNotes"] = "Show friend note"
L["ShowRealIDNotesDescription"] = "ShowRealIDNotesDescription"

L["Character Friends"] = "Character Friends"
L["ShowFriends"] = "Show friends"
L["ShowFriendsDescription"] = "ShowFriendsDescription"
L["ShowFriendsNote"] = "Show friend note"
L["ShowFriendsNoteDescription"] = "ShowFriendsNoteDescription"

L["Guild Members"] = "Guild Members"
L["ShowGuild"] = "Show guild members"
L["ShowGuildDescription"] = "ShowGuildDescription"
L["ShowGuildLabel"] = "Show guild label"
L["ShowGuildLabelDescription"] = "If enabled, the data text will be prefixed with the guild name."
L["ShowGuildNote"] = "Show guild note"
L["ShowGuildNoteDescription"] = "If enabled, the guild member's public note will be displayed in the tooltip."
L["ShowGuildONote"] = "Show officer note"
L["ShowGuildONoteDescription"] = "If enabled, the guild member's officer note will be displayed in the tooltip."
L["ShowSplitRemoteChat"] = "Separate remote chat"
L["ShowSplitRemoteChatDescription"] = "If enabled, guild members utilizing the remote chat feature will be displayed separately within the data text and tooltip."
L["GuildSort"] = "Custom Sort"
L["GuildSortDescription"] = "If enabled, the following options will be used to sort the guild members. If disabled, the most recently used guild sort options will be used instead."
L["GuildSortInverted"] = "Invert sort direction"
L["GuildSortInvertedDescription"] = "GuildSortInvertedDescription"
L["GuildSortKey"] = "GuildSortKey"
L["GuildSortKeyDescription"] = "GuildSortKeyDescription"

L["Tooltip Settings"] = "Tooltip Settings"
L["ShowStatus"] = "ShowStatus"
L["ShowStatusDescription"] = "ShowStatusDescription"
L["TooltipInteraction"] = "TooltipInteraction"
L["TooltipInteractionDescription"] = "TooltipInteractionDescription"


-- Messages
-- L["No currencies can be displayed."] = "No currencies can be displayed.";
-- L["usageDescription"] = "Left-click to view currencies. Right-click to configure."
-- L["Settings have been reset to defaults."] = "Settings have been reset to defaults."

-- Labels
L["Socialite"] = "Socialite";
L["TOOLTIP"] = "Social"
L["TOOLTIP_REALID"] = "RealID Friends Online"
L["TOOLTIP_REALID_APP"] = "RealID Friends in Battle.Net App"
L["TOOLTIP_FRIENDS"] = "Friends Online"
L["TOOLTIP_GUILD"] = "Guild Members Online"
L["TOOLTIP_REMOTE_CHAT"] = "Remote Chat"
L["TOOLTIP_COLLAPSED"] = "(collapsed, click to expand)"

addon.L = L
