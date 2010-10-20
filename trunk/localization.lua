local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)

TITAN_SOCIAL_MENU_TEXT = "TitanSocial"
TITAN_SOCIAL_BUTTON_LABEL = "Social: "
TITAN_SOCIAL_BUTTON_TEXT = "Social: "


-- default (enUS)

TITAN_SOCIAL_TOOLTIP = "Social Information"
TITAN_SOCIAL_TOOLTIP_REALID = "RealID Friends";
TITAN_SOCIAL_TOOLTIP_FRIENDS = "Friends";
TITAN_SOCIAL_TOOLTIP_GUILD = "Guild Members";
TITAN_SOCIAL_MENU_REALID = "RealID";
TITAN_SOCIAL_MENU_REALID_FRIENDS = "Show RealID Friends";
TITAN_SOCIAL_MENU_REALID_BROADCASTS = "Show RealID Broadcasts";
TITAN_SOCIAL_MENU_FRIENDS = "Friends";
TITAN_SOCIAL_MENU_FRIENDS_NOTE = "Show Friends Note";
TITAN_SOCIAL_MENU_GUILD = "Guild";
TITAN_SOCIAL_MENU_GUILD_MEMBERS = "Show Guild Members";
TITAN_SOCIAL_MENU_GUILD_LABEL = "Show Guild Label";
TITAN_SOCIAL_MENU_GUILD_NOTE = "Show Guild Note";
TITAN_SOCIAL_MENU_GUILD_ONOTE = "Show Officer Note";
TITAN_SOCIAL_MENU_LABEL = "Show Label";
TITAN_SOCIAL_MENU_MEM = "Show Memory Usage";
TITAN_SOCIAL_MENU_HIDE = "Hide";


-- frFR

if (GetLocale() == "frFR") then

	TITAN_SOCIAL_TOOLTIP = "Information Sociale";
	TITAN_SOCIAL_TOOLTIP_REALID = "Amis RealID";
	TITAN_SOCIAL_TOOLTIP_FRIENDS = "Amis";
	TITAN_SOCIAL_TOOLTIP_GUILD = "Membres de la guilde";
	TITAN_SOCIAL_MENU_REALID = "Montrer les amis RealID";
	TITAN_SOCIAL_MENU_FRIENDS = "Montrer les amis";
	TITAN_SOCIAL_MENU_GUILD = "Montrer les membres de la guilde";
	--TITAN_SOCIAL_MENU_ICON = "";
	--TITAN_SOCIAL_MENU_LABEL = "";
	--TITAN_SOCIAL_MENU_MEM = "";
	--TITAN_SOCIAL_MENU_HIDE = "Hide";
	
end


-- deDE

if (GetLocale() == "deDE") then

	--TITAN_SOCIAL_TOOLTIP = "";
	--TITAN_SOCIAL_TOOLTIP_REALID = "";
	--TITAN_SOCIAL_TOOLTIP_FRIENDS = "";
	--TITAN_SOCIAL_TOOLTIP_GUILD = "";
	--TITAN_SOCIAL_MENU_REALID = "";
	--TITAN_SOCIAL_MENU_FRIENDS = "";
	--TITAN_SOCIAL_MENU_GUILD = "";
	--TITAN_SOCIAL_MENU_ICON = "";
	--TITAN_SOCIAL_MENU_LABEL = "";
	--TITAN_SOCIAL_MENU_MEM = "";
	--TITAN_SOCIAL_MENU_HIDE = "Hide";
	
end


-- esES

if (GetLocale() == "esES") then

	--TITAN_SOCIAL_TOOLTIP = "";
	--TITAN_SOCIAL_TOOLTIP_REALID = "";
	--TITAN_SOCIAL_TOOLTIP_FRIENDS = "";
	--TITAN_SOCIAL_TOOLTIP_GUILD = "";
	--TITAN_SOCIAL_MENU_REALID = "";
	--TITAN_SOCIAL_MENU_FRIENDS = "";
	--TITAN_SOCIAL_MENU_GUILD = "";
	--TITAN_SOCIAL_MENU_ICON = "";
	--TITAN_SOCIAL_MENU_LABEL = "";
	--TITAN_SOCIAL_MENU_MEM = "";
	--TITAN_SOCIAL_MENU_HIDE = "Hide";
	
end


-- ruRU

if (GetLocale() == "ruRU") then

	--TITAN_SOCIAL_TOOLTIP = "";
	--TITAN_SOCIAL_TOOLTIP_REALID = "";
	--TITAN_SOCIAL_TOOLTIP_FRIENDS = "";
	--TITAN_SOCIAL_TOOLTIP_GUILD = "";
	--TITAN_SOCIAL_MENU_REALID = "";
	--TITAN_SOCIAL_MENU_FRIENDS = "";
	--TITAN_SOCIAL_MENU_GUILD = "";
	--TITAN_SOCIAL_MENU_ICON = "";
	--TITAN_SOCIAL_MENU_LABEL = "";
	--TITAN_SOCIAL_MENU_MEM = "";
	--TITAN_SOCIAL_MENU_HIDE = "Hide";
	
end

-- CLASSINDEX via TitanGuild
TITAN_SOCIAL_CLASSINDEX = {
	--enUS
	["Druid"]        = 1,
	["Hunter"]       = 2,
	["Mage"]         = 3,
	["Paladin"]      = 4,
	["Priest"]       = 5,
	["Rogue"]        = 6,
	["Shaman"]       = 7,
	["Warlock"]      = 8,
	["Warrior"]      = 9,
	["Death Knight"] = 10,

	-- de
	["Druide"] = 1,
	["Druidin"] = 1,
	["J\195\164ger"] = 2,
	["J\195\164gerin"] = 2,
	["Magier"] = 3,
	["Magierin"] = 3,
	["Paladin"] = 4,
	["Priester"] = 5,
	["Priesterin"] = 5,
	["Schurke"] = 6,
	["Schurkin"] = 6,
	["Schamane"] = 7,
	["Schamanin"] = 7,
	["Hexenmeister"] = 8,
	["Hexenmeisterin"] = 8,
	["Krieger"] = 9,
	["Kriegerin"] = 9,
    ["Todesritter"] = 10,

	-- fr
	["Druide"] = 1,
	["Druidesse"] = 1,
	["Chasseur"] = 2,
	["Chasseresse"] = 2,
	["Mage"] = 3,
	["Paladin"] = 4,
	["Pr\195\170tre"] = 5,
	["Pr\195\170tresse"] = 5,
	["Voleur"] = 6,
	["Voleuse"] = 6,
	["Chaman"] = 7,
	["Chamane"] = 7,
	["D\195\169moniste"] = 8,
	["Guerrier"] = 9,
	["Guerri\195\168re"] = 9,
    ["Chevalier de la mort"] = 10,

	-- es
	["Druida"]   = 1,
	["Cazador"]  = 2,
	["Cazadora"]  = 2,
	["Mago"]    = 3,
	["Maga"]    = 3,
	["Palad\195\173n"] = 4,
	["Sacerdote"]  = 5,
	["Sacerdotisa"]  = 5,
	["P\195\173caro"]   = 6,
	["P\195\173cara"]   = 6,
	["Cham\195\161n"]  = 7,
	["Brujo"] = 8,
	["Bruja"] = 8,
	["Guerrero"] = 9,
	["Guerrera"] = 9,
    ["Caballero de la Muerte"] = 10,

	-- ru	
	["Друид"]   = 1,
	["Охотник"]  = 2,
	["Охотница"]  = 2,
	["Маг"]    = 3,
	["Паладин"] = 4,
	["Жрец"]  = 5,
	["Жрица"]  = 5,
	["Разбойник"]   = 6,
	["Разбойница"]   = 6,
	["Шаман"]  = 7,
	["Шаманка"]  = 7,
	["Чернокнижник"] = 8,
	["Чернокнижница"] = 8,
	["Воин"] = 9,
	["Рыцарь смерти"] = 10,
};