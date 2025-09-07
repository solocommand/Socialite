local L = LibStub("AceLocale-3.0"):NewLocale("Socialite", "ruRU")
if not L then return end

-- Configuration options
-- Russian(RU) Localization ZamestoTV
L["Battle.net Friends"] = "Друзья Battle.net"
L["ShowRealID"] = "Показывать друзей"
L["ShowRealIDDescription"] = "Показывать друзей в текстовых данных и подсказке."
L["ShowRealIDApp"] = "Показывать друзей вне игры"
L["ShowRealIDAppDescription"] = "Если включено, показывать всех друзей Battle.net, независимо от их игрового статуса."
L["ShowRealIDBroadcasts"] = "Показывать трансляции/уведомления"
L["ShowRealIDBroadcastsDescription"] = "Показывать трансляции друзей Battle.net в подсказке."
L["ShowRealIDFactions"] = "Показывать фракцию друзей"
L["ShowRealIDFactionsDescription"] = "Показывать фракцию ваших друзей Battle.net."
L["ShowRealIDNotes"] = "Показывать заметки о друзьях"
L["ShowRealIDNotesDescription"] = "Показывать заметки о ваших друзьях."
L["showInAddonCompartment"] = "Показывать в отсеке аддонов"
L["showInAddonCompartmentDescription"] = "Переключает отображение Socialite в отсеке аддонов."
L["Data text"] = "Текстовые данные"
L["Tooltip Width"] = "Дополнительная ширина подсказки"

L["Character Friends"] = "Друзья персонажа"
L["ShowFriends"] = "Показывать друзей"
L["ShowFriendsDescription"] = "Включать друзей персонажа в подсказку."
L["ShowFriendsNote"] = "Показывать заметки о друзьях"
L["ShowFriendsNoteDescription"] = "Показывать заметки о друзьях персонажа."

L["Guild Members"] = "Члены гильдии"
L["ShowGuild"] = "Показывать членов гильдии"
L["ShowGuildDescription"] = "Если включено, отображать членов гильдии в подсказке."
L["ShowGuildLabel"] = "Показывать название гильдии"
L["ShowGuildLabelDescription"] = "Если включено, текстовые данные будут начинаться с названия гильдии."
L["ShowGuildNote"] = "Показывать заметки гильдии"
L["ShowGuildNoteDescription"] = "Если включено, публичная заметка члена гильдии будет отображаться в подсказке."
L["ShowGuildONote"] = "Показывать офицерские заметки"
L["ShowGuildONoteDescription"] = "Если включено, офицерская заметка члена гильдии будет отображаться в подсказке."
L["ShowSplitRemoteChat"] = "Разделять удалённый чат"
L["ShowSplitRemoteChatDescription"] = "Если включено, члены гильдии, использующие функцию удалённого чата, будут отображаться отдельно в текстовых данных и подсказке."

L["Guild Sorting"] = "Сортировка гильдии"
L["GuildSort"] = "Пользовательская сортировка"
-- L["GuildSortDescription"] = "Если включено, следующие параметры будут использоваться для сортировки членов гильдии. Если отключено, вместо этого будут использованы последние использованные параметры сортировки гильдии."
-- L["GuildSortInverted"] = "Инвертировать направление сортировки"
-- L["GuildSortInvertedDescription"] = "GuildSortInvertedDescription"
L["GuildSortKey"] = "Ключ сортировки"
-- L["GuildSortKeyDescription"] = "GuildSortKeyDescription"

L["GuildSortAscending"] = "По возрастанию"
L["GuildSortAscendingDescription"] = "Сортировать по возрастанию (1..9 или A...Z)"

L["Tooltip Settings"] = "Настройки подсказки"
L["ShowStatus"] = "Показывать статус"
L["ShowStatusDescription"] = "Показывать статус друзей."
L["TooltipInteraction"] = "Взаимодействие с подсказкой"
L["TooltipInteractionDescription"] = "Определяет, когда подсказка будет интерактивной."

-- Messages
-- L["No currencies can be displayed."] = "Валюты для отображения отсутствуют.";
-- L["usageDescription"] = "ЛКМ для просмотра валют. ПКМ для настройки."
-- L["Settings have been reset to defaults."] = "Настройки сброшены до значений по умолчанию."

-- Labels
L["Socialite"] = "Socialite";
L["TOOLTIP"] = "Социальный"
L["TOOLTIP_REALID"] = "Друзья Battle.net онлайн"
L["TOOLTIP_REALID_APP"] = "Друзья Battle.net в приложении"
L["TOOLTIP_FRIENDS"] = "Друзья онлайн"
L["TOOLTIP_GUILD"] = "Члены гильдии онлайн"
L["TOOLTIP_REMOTE_CHAT"] = "Удалённый чат"
L["TOOLTIP_COLLAPSED"] = "(свёрнуто, нажмите для раскрытия)"

L["MENU_STATUS"] = "Показывать статус как"
L["MENU_STATUS_DESCRIPTION"] = "Показывать статус присутствия друга как..."
L["MENU_STATUS_ICON"] = "Иконка"
L["MENU_STATUS_TEXT"] = "Текст"
L["MENU_STATUS_NONE"] = "Нет"
L["MENU_STATUS_ICON_DESCRIPTION"] = "При выборе статус друга будет отображаться иконкой, например |T"..FRIENDS_TEXTURE_DND..":0|t"
L["MENU_STATUS_TEXT_DESCRIPTION"] = "При выборе статус друга будет отображаться текстом, например <Отсутствует>"
L["MENU_STATUS_NONE_DESCRIPTION"] = "При выборе статус друга не будет отображаться."

L["MENU_INTERACTION"] = "Взаимодействие с подсказкой"
L["MENU_INTERACTION_DESCRIPTION"] = "Когда подсказка должна быть интерактивной?"
L["MENU_INTERACTION_ALWAYS"] = "Всегда"
L["MENU_INTERACTION_OOC"] = "Вне боя"
L["MENU_INTERACTION_NEVER"] = "Никогда"
L["MENU_INTERACTION_ALWAYS_DESCRIPTION"] = "Подсказка всегда будет интерактивной."
L["MENU_INTERACTION_OOC_DESCRIPTION"] = "Подсказка будет интерактивной только вне боя."
L["MENU_INTERACTION_NEVER_DESCRIPTION"] = "Подсказка никогда не будет интерактивной."

L["MENU_GUILD_SORT"] = "Сортировать по"
-- L["MENU_GUILD_SORT_DEFAULT"] = "Использовать сортировку реестра гильдии"
L["MENU_GUILD_SORT_NAME"] = "Имя"
L["MENU_GUILD_SORT_NAME_DESCRIPTION"] = "Сортировать по имени члена гильдии"
L["MENU_GUILD_SORT_RANK"] = "Ранг"
L["MENU_GUILD_SORT_RANK_DESCRIPTION"] = "Сортировать по рангу члена гильдии"
L["MENU_GUILD_SORT_CLASS"] = "Класс"
L["MENU_GUILD_SORT_CLASS_DESCRIPTION"] = "Сортировать по классу члена гильдии"
L["MENU_GUILD_SORT_NOTE"] = "Заметка"
L["MENU_GUILD_SORT_NOTE_DESCRIPTION"] = "Сортировать по заметке члена гильдии"
L["MENU_GUILD_SORT_LEVEL"] = "Уровень"
L["MENU_GUILD_SORT_LEVEL_DESCRIPTION"] = "Сортировать по уровню члена гильдии"
L["MENU_GUILD_SORT_ZONE"] = "Зона"
L["MENU_GUILD_SORT_ZONE_DESCRIPTION"] = "Сортировать по зоне/дате входа члена гильдии"
-- L["MENU_GUILD_SORT_ASCENDING"] = "По возрастанию"
-- L["MENU_GUILD_SORT_DESCENDING"] = "По убыванию"

L['Display Settings'] = 'Настройки отображения'
L['Show minimap button'] = 'Показывать кнопку миникарты'
L['Show the Scoreboard minimap button'] = 'Показывать кнопку миникарты Scoreboard'
L["usageDescription"] = "Левый клик для просмотра социальных панелей. Alt+Клик для приглашения. Правый клик для настройки."

L['ShowGroupMembers'] = "Показывать членов группы"
L['ShowGroupMembersDescription'] = "Показывать иконку-индикатор рядом с другом, если он находится в той же группе"

L["ShowLabel"] = "Показывать метку"
L["ShowLabelDescription"] = "Если включено, метка аддона (или название гильдии, если включено) будет отображаться в текстовых данных."

L["DisableUsageText"] = "Отключить текст инструкций"
L["DisableUsageTextDescription"] = "Если отмечено, инструкции по использованию не будут отображаться в подсказке."

addon.L = L
