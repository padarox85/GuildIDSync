local L = {
    -- Chat Messages
    ["MSG_LOADED"] = "%s v%s loaded. Type /gid to show the GUI",
    ["MSG_NO_OWN_IDS"] = "You have no IDs right now.",
    ["MSG_DATA_CLEARED"] = "Data cleared.",
    ["MSG_PROFILE_UPDATED"] = "Updated Profile for %d IDs and PvP Quests (Rev: %d)",
    ["MSG_CANNOT_UPDATE_IN_INSTANCE"] = "You cannot update your profile in an instance/raid.",
    ["MSG_CMD_LIST_TITLE"] = "Valid commands:",
    ["MSG_CMD_SHOW"] = "/gid show | Show GUI",
    ["MSG_CMD_OWN"] = "/gid own | List own IDs",
    ["MSG_CMD_ALL"] = "/gid all | List all IDs",
    ["MSG_CMD_CLEAR"] = "/gid clear | Clear all IDs in Database",
    ["MSG_CMD_UPDATE"] = "/gid update | Update own data",
    ["MSG_OWN_IDS_TITLE"] = "Your currently locked IDs:",
    ["MSG_ALL_IDS_TITLE"] = "The following IDs are currently available:",
    ["MSG_RESET"] = "Reset: %s",

    -- UI
    ["UI_DIFFICULTY_CHOOSE"] = "Choose Difficulty / Raid Size:",
    ["UI_HEROICS"] = "Heroic Dungeons",
    ["UI_RAID10"] = "Raid: 10 Player",
    ["UI_RAID25"] = "Raid: 25 Player",
    ["UI_PVP"] = "PvP",
    ["UI_NO_DATA"] = "No data available. Use /gid update",
    ["UI_NO_CHARACTERS"] = "No characters found for this selection.",
    ["UI_LVL"] = "Lvl: %s",
    ["UI_STATUS_COMPLETED"] = "Status: Completed",
    ["UI_STATUS_OPEN"] = "Status: Open",
    ["UI_STATUS_UNKNOWN"] = "Status: Unknown",
    ["UI_ID"] = "ID: %s",
    ["UI_MINIMAP_TOOLTIP_CLICK"] = "|cffffff00Click|r to open / hide GuildIDSync.",

    -- PvP Quests (Names)
    ["PVP_BG_DAILY"] = "Battleground Daily",
    ["PVP_HELLFIRE"] = "Hellfire Peninsula",
    ["PVP_ZANGAR"] = "Zangarmarsh",
    ["PVP_TEROKKAR"] = "Terokkar Forest",
    ["PVP_NAGRAND"] = "Nagrand",
    ["PVP_WINTERGRASP"] = "Wintergrasp"
}

-- Default to English
GID_L = L

-- Override with German if needed
if GetLocale() == "deDE" then
    GID_L["MSG_LOADED"] = "%s v%s geladen. Tippe /gid für die GUI"
    GID_L["MSG_NO_OWN_IDS"] = "Du hast aktuell keine IDs."
    GID_L["MSG_DATA_CLEARED"] = "Daten gelöscht."
    GID_L["MSG_PROFILE_UPDATED"] = "Profil für %d IDs und PvP-Quests aktualisiert (Rev: %d)"
    GID_L["MSG_CANNOT_UPDATE_IN_INSTANCE"] = "Du kannst dein Profil nicht in einer Instanz/Raid aktualisieren."
    GID_L["MSG_CMD_LIST_TITLE"] = "Gültige Befehle:"
    GID_L["MSG_CMD_SHOW"] = "/gid show | Zeige GUI"
    GID_L["MSG_CMD_OWN"] = "/gid own | Eigene IDs auflisten"
    GID_L["MSG_CMD_ALL"] = "/gid all | Alle IDs auflisten"
    GID_L["MSG_CMD_CLEAR"] = "/gid clear | Alle IDs in der Datenbank löschen"
    GID_L["MSG_CMD_UPDATE"] = "/gid update | Eigene Daten aktualisieren"
    GID_L["MSG_OWN_IDS_TITLE"] = "Deine aktuell gesperrten IDs:"
    GID_L["MSG_ALL_IDS_TITLE"] = "Folgende IDs sind aktuell vorhanden:"
    GID_L["MSG_RESET"] = "Reset: %s"

    -- UI
    GID_L["UI_DIFFICULTY_CHOOSE"] = "Wähle Schwierigkeit / Raidgröße:"
    GID_L["UI_HEROICS"] = "Heroische Instanzen"
    GID_L["UI_RAID10"] = "Raid: 10 Spieler"
    GID_L["UI_RAID25"] = "Raid: 25 Spieler"
    GID_L["UI_PVP"] = "PvP"
    GID_L["UI_NO_DATA"] = "Keine Daten vorhanden. Nutze /gid update"
    GID_L["UI_NO_CHARACTERS"] = "Keine Charaktere für diese Auswahl gefunden."
    GID_L["UI_LVL"] = "Lvl: %s"
    GID_L["UI_STATUS_COMPLETED"] = "Status: Abgeschlossen"
    GID_L["UI_STATUS_OPEN"] = "Status: Offen"
    GID_L["UI_STATUS_UNKNOWN"] = "Status: Unbekannt"
    GID_L["UI_ID"] = "ID: %s"
    GID_L["UI_MINIMAP_TOOLTIP_CLICK"] = "|cffffff00Klick|r um GuildIDSync zu öffnen / zu verstecken."

    -- PvP Quests (Names)
    GID_L["PVP_BG_DAILY"] = "Schlachtfeld Daily"
    GID_L["PVP_HELLFIRE"] = "Höllenfeuerhalbinsel"
    GID_L["PVP_ZANGAR"] = "Zangarmarschen"
    GID_L["PVP_TEROKKAR"] = "Wälder von Terokkar"
    GID_L["PVP_NAGRAND"] = "Nagrand"
    GID_L["PVP_WINTERGRASP"] = "Tausendwinter"
end
