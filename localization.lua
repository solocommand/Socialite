local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)

TITAN_SOCIAL_MENU_TEXT = "TitanSocial"
TITAN_SOCIAL_BUTTON_LABEL = "Social: "

-- default (enUS)

TITAN_SOCIAL_BUTTON_TITLE = "Social: "

TITAN_SOCIAL_TOOLTIP = "Social"
TITAN_SOCIAL_TOOLTIP_REALID = "RealID Friends Online:";
TITAN_SOCIAL_TOOLTIP_FRIENDS = "Friends Online:";
TITAN_SOCIAL_TOOLTIP_GUILD = "Guild Members Online:";
TITAN_SOCIAL_TOOLTIP_MEM = "Memory Utilization:";
TITAN_SOCIAL_TOOLTIP_MEM_UNIT = "Kb";

TITAN_SOCIAL_MENU_REALID = "RealID";
TITAN_SOCIAL_MENU_REALID_FRIENDS = "Show RealID Friends";
TITAN_SOCIAL_MENU_REALID_BROADCASTS = "Show RealID Broadcasts";

TITAN_SOCIAL_MENU_FRIENDS = "Friends";
TITAN_SOCIAL_MENU_FRIENDS_SHOW = "Show Friends";
TITAN_SOCIAL_MENU_FRIENDS_NOTE = "Show Friends Note";

TITAN_SOCIAL_MENU_GUILD = "Guild";
TITAN_SOCIAL_MENU_GUILD_MEMBERS = "Show Guild Members";
TITAN_SOCIAL_MENU_GUILD_LABEL = "Show Guild Label";
TITAN_SOCIAL_MENU_GUILD_NOTE = "Show Guild Note";
TITAN_SOCIAL_MENU_GUILD_ONOTE = "Show Officer Note";

TITAN_SOCIAL_MENU_LABEL = "Show Label";
TITAN_SOCIAL_MENU_MEM = "Show Memory Usage";
TITAN_SOCIAL_MENU_HIDE = "Hide";
TITAN_SOCIAL_MENU_OPTIONS = "Options";


-- frFR

if (GetLocale() == "frFR") then

-- Last Update by Sasmira: 10/29/2010

	TITAN_SOCIAL_BUTTON_TITLE = "Social: "

	TITAN_SOCIAL_TOOLTIP = "Social"; -- Work  in french
	TITAN_SOCIAL_TOOLTIP_REALID = "Amis R\195\169els:"; -- Don't Work in french
	TITAN_SOCIAL_TOOLTIP_FRIENDS = "Contacts:"; -- Don't Work in french
	TITAN_SOCIAL_TOOLTIP_GUILD = "Membres de la guilde:"; -- Don't Work in french
	TITAN_SOCIAL_TOOLTIP_MEM = "Mémoire Utilis\195\169e:";
	TITAN_SOCIAL_TOOLTIP_MEM_UNIT = "Ko";
	
	TITAN_SOCIAL_MENU_REALID = "Amis R\195\169els"; -- Don't Work in french
	TITAN_SOCIAL_MENU_REALID_FRIENDS = "Afficher: Amis R\195\169els"; -- Don't Work in french
	TITAN_SOCIAL_MENU_REALID_BROADCASTS = "Afficher: Nombre d'Amis R\195\169els"; -- Don't Work in french
	
	TITAN_SOCIAL_MENU_FRIENDS = "Contacts"; -- Don't Work in french
	TITAN_SOCIAL_MENU_FRIENDS_SHOW = "Afficher: Contacts";
	TITAN_SOCIAL_MENU_FRIENDS_NOTE = "Afficher: Notes Contacts"; -- Don't Work in french
		
	TITAN_SOCIAL_MENU_GUILD = "Guilde"; -- Don't Work in french
	TITAN_SOCIAL_MENU_GUILD_MEMBERS = "Afficher: Membres de Guilde"; -- Don't Work in french
	TITAN_SOCIAL_MENU_GUILD_LABEL = "Afficher: Nom de Guilde"; -- Don't Work in french
	TITAN_SOCIAL_MENU_GUILD_NOTE = "Afficher: Notes de Guilde"; -- Don't Work in french
	TITAN_SOCIAL_MENU_GUILD_ONOTE = "Afficher: Notes d'Officier"; -- Don't Work in french
	
	TITAN_SOCIAL_MENU_LABEL = "Afficher l'\195\169tiquette"; -- Don't Work in french
	TITAN_SOCIAL_MENU_MEM = "Afficher: Mémoire utilis\195\169e"; -- Don't Work in french
	TITAN_SOCIAL_MENU_HIDE = "Cacher"; -- Don't Work in french
	TITAN_SOCIAL_MENU_OPTIONS = "";
	
end


-- deDE

if (GetLocale() == "deDE") then

	--
	
end


-- esES

if (GetLocale() == "esES") then

	--
	
end


-- ruRU

if (GetLocale() == "ruRU") then

	--
	
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