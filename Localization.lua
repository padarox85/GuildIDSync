local L = {
    -- Chat Messages
    ["MSG_LOADED"] = "%s v%s loaded. Type /gs to show the GUI",
    ["MSG_NO_OWN_IDS"] = "You have no IDs right now.",
    ["MSG_DATA_CLEARED"] = "Data cleared.",
    ["MSG_PROFILE_UPDATED"] = "Updated Profile for %d IDs and PvP Quests (Rev: %d)",
    ["MSG_CANNOT_UPDATE_IN_INSTANCE"] = "You cannot update your profile in an instance/raid.",
    ["MSG_CMD_LIST_TITLE"] = "Valid commands:",
    ["MSG_CMD_SHOW"] = "/gs show | Show GUI",
    ["MSG_CMD_OWN"] = "/gs own | List own IDs",
    ["MSG_CMD_ALL"] = "/gs all | List all IDs",
    ["MSG_CMD_CLEAR"] = "/gs clear | Clear all IDs in Database",
    ["MSG_OWN_IDS_TITLE"] = "Your currently locked IDs:",
    ["MSG_ALL_IDS_TITLE"] = "The following IDs are currently available:",
    ["MSG_RESET"] = "Reset: %s",

    -- UI
    ["UI_DIFFICULTY_CHOOSE"] = "Choose Difficulty / Raid Size:",
    ["UI_HEROICS"] = "Heroic Dungeons",
    ["UI_RAID10"] = "Raid: 10 Player",
    ["UI_RAID25"] = "Raid: 25 Player",
    ["UI_PVP"] = "PvP",
    ["UI_NO_DATA"] = "No data available.",
    ["UI_NO_CHARACTERS"] = "No characters found for this selection.",
    ["UI_LVL"] = "Lvl: %s",
    ["UI_STATUS_COMPLETED"] = "Status: Completed",
    ["UI_STATUS_OPEN"] = "Status: Open",
    ["UI_STATUS_UNKNOWN"] = "Status: Unknown",
    ["UI_ID"] = "ID: %s",
    ["UI_MINIMAP_TOOLTIP_CLICK"] = "|cffffff00Click|r to open / hide GuildSync.",

    -- PvP Quests (Names)
    ["PVP_BG_DAILY"] = "Battleground Daily",
    ["PVP_HELLFIRE"] = "Hellfire Peninsula",
    ["PVP_ZANGAR"] = "Zangarmarsh",
    ["PVP_TEROKKAR"] = "Terokkar Forest",
    ["PVP_NAGRAND"] = "Nagrand",
    ["PVP_WINTERGRASP"] = "Wintergrasp",

    -- Lockout Table UI
    ["UI_LOCKOUT_COLUMN_NAME"] = "Player",
    ["UI_LOCKOUT_COLUMN_LEVEL"] = "Lvl",
    ["UI_LOCKOUT_COLUMN_ID"] = "ID",
    ["UI_LOCKOUT_COLUMN_DATE"] = "Reset",
    ["UI_LOCKOUT_COLUMN_WHISPER"] = "Whisper",
    ["UI_LOCKOUT_COLUMN_INVITE"] = "Invite",

    -- Layering UI
    ["UI_TAB_LOCKOUTS"] = "Lockouts",
    ["UI_TAB_LAYERING"] = "Layering",
    ["UI_TAB_SETTINGS"] = "Settings",
    ["UI_LAYER_COLUMN_NAME"] = "Name",
    ["UI_LAYER_COLUMN_LEVEL"] = "Lvl",
    ["UI_LAYER_COLUMN_ZONE"] = "Zone",
    ["UI_LAYER_COLUMN_LAYER"] = "Layer",
    ["UI_LAYER_COLUMN_ACTION"] = "Action",
    ["UI_LAYER_INVITE"] = "Request Layer switch",
    ["UI_LAYER_IN_GROUP"] = "In Group",
    ["UI_LAYER_QUERY_SENT"] = "Querying guild members for layer information...",
    ["UI_LAYER_LOADING"] = "Loading Layer Infos from Guild Members...",
    ["UI_LAYER_NO_DATA"] = "No data received. Please try refreshing in a few seconds.",
    ["UI_LAYER_REFRESH"] = "Refresh",
    ["UI_LAYER_COOLDOWN"] = "Refresh available in %ds",
    ["UI_LAYER_CURRENT"] = "Current Layer: %s",
    ["UI_LAYER_UNKNOWN"] = "unknown - target npc to update",
    ["UI_LAYER_UNKNOWN_PROMPT"] = "Unknown Layer - Please Target NPC to continue!",
    ["UI_LAYER_INVITE_SENT"] = "Invite request sent to %s",
    ["UI_LAYER_INVITE_CONFIRM_TITLE"] = "Layer Switch Request",
    ["UI_LAYER_INVITE_CONFIRM_TEXT"] = "%s wants to switch to your layer - confirm for group invitation",
    ["UI_SETTINGS_AUTO_INVITE"] = "Auto-accept layer switch requests",
    ["UI_SETTINGS_HIDE_MINIMAP"] = "Hide Minimap Button",
    ["MSG_AUTO_ACCEPTED_INVITE"] = "Automatically accepted invite from %s",
    ["MSG_NEW_VERSION_AVAILABLE"] = "A new version of %s is available (v%s). Please update!",
}

-- Default to English
GS_L = L

-- Override with German if needed
if GetLocale() == "deDE" then
    GS_L["MSG_LOADED"] = "%s v%s geladen. Tippe /gs für die GUI"
    GS_L["MSG_NO_OWN_IDS"] = "Du hast aktuell keine IDs."
    GS_L["MSG_DATA_CLEARED"] = "Daten gelöscht."
    GS_L["MSG_PROFILE_UPDATED"] = "Profil für %d IDs und PvP-Quests aktualisiert (Rev: %d)"
    GS_L["MSG_CANNOT_UPDATE_IN_INSTANCE"] = "Du kannst dein Profil nicht in einer Instanz/Raid aktualisieren."
    GS_L["MSG_CMD_LIST_TITLE"] = "Gültige Befehle:"
    GS_L["MSG_CMD_SHOW"] = "/gs show | Zeige GUI"
    GS_L["MSG_CMD_OWN"] = "/gs own | Eigene IDs auflisten"
    GS_L["MSG_CMD_ALL"] = "/gs all | Alle IDs auflisten"
    GS_L["MSG_CMD_CLEAR"] = "/gs clear | Alle IDs in der Datenbank löschen"
    GS_L["MSG_OWN_IDS_TITLE"] = "Deine aktuell gesperrten IDs:"
    GS_L["MSG_ALL_IDS_TITLE"] = "Folgende IDs sind aktuell vorhanden:"
    GS_L["MSG_RESET"] = "Reset: %s"

    -- UI
    GS_L["UI_DIFFICULTY_CHOOSE"] = "Wähle Schwierigkeit / Raidgröße:"
    GS_L["UI_HEROICS"] = "Heroische Instanzen"
    GS_L["UI_RAID10"] = "Raid: 10 Spieler"
    GS_L["UI_RAID25"] = "Raid: 25 Spieler"
    GS_L["UI_PVP"] = "PvP"
    GS_L["UI_NO_DATA"] = "Keine Daten vorhanden."
    GS_L["UI_NO_CHARACTERS"] = "Keine Charaktere für diese Auswahl gefunden."
    GS_L["UI_LVL"] = "Lvl: %s"
    GS_L["UI_STATUS_COMPLETED"] = "Status: Abgeschlossen"
    GS_L["UI_STATUS_OPEN"] = "Status: Offen"
    GS_L["UI_STATUS_UNKNOWN"] = "Status: Unbekannt"
    GS_L["UI_ID"] = "ID: %s"
    GS_L["UI_MINIMAP_TOOLTIP_CLICK"] = "|cffffff00Klick|r um GuildSync zu öffnen / zu verstecken."

    -- PvP Quests (Names)
    GS_L["PVP_BG_DAILY"] = "Schlachtfeld Daily"
    GS_L["PVP_HELLFIRE"] = "Höllenfeuerhalbinsel"
    GS_L["PVP_ZANGAR"] = "Zangarmarschen"
    GS_L["PVP_TEROKKAR"] = "Wälder von Terokkar"
    GS_L["PVP_NAGRAND"] = "Nagrand"
    GS_L["PVP_WINTERGRASP"] = "Tausendwinter"

    -- Lockout Table UI
    GS_L["UI_LOCKOUT_COLUMN_NAME"] = "Spieler"
    GS_L["UI_LOCKOUT_COLUMN_LEVEL"] = "Lvl"
    GS_L["UI_LOCKOUT_COLUMN_ID"] = "ID"
    GS_L["UI_LOCKOUT_COLUMN_DATE"] = "Reset"
    GS_L["UI_LOCKOUT_COLUMN_WHISPER"] = "Whisper"
    GS_L["UI_LOCKOUT_COLUMN_INVITE"] = "Einladen"

    -- Layering UI
    GS_L["UI_TAB_LOCKOUTS"] = "IDs"
    GS_L["UI_TAB_LAYERING"] = "Layering"
    GS_L["UI_TAB_SETTINGS"] = "Einstellungen"
    GS_L["UI_LAYER_COLUMN_NAME"] = "Name"
    GS_L["UI_LAYER_COLUMN_LEVEL"] = "Lvl"
    GS_L["UI_LAYER_COLUMN_ZONE"] = "Zone"
    GS_L["UI_LAYER_COLUMN_LAYER"] = "Layer"
    GS_L["UI_LAYER_COLUMN_ACTION"] = "Aktion"
    GS_L["UI_LAYER_INVITE"] = "Layer-Wechsel anfragen"
    GS_L["UI_LAYER_IN_GROUP"] = "In Gruppe"
    GS_L["UI_LAYER_QUERY_SENT"] = "Frage Gildenmitglieder nach Layer-Infos ab..."
    GS_L["UI_LAYER_LOADING"] = "Lade Layer-Infos von Gildenmitgliedern..."
    GS_L["UI_LAYER_NO_DATA"] = "Keine Daten empfangen. Bitte versuche es in einigen Sekunden erneut mit 'Aktualisieren'."
    GS_L["UI_LAYER_REFRESH"] = "Aktualisieren"
    GS_L["UI_LAYER_COOLDOWN"] = "Aktualisierung möglich in %ds"
    GS_L["UI_LAYER_CURRENT"] = "Aktueller Layer: %s"
    GS_L["UI_LAYER_UNKNOWN"] = "unbekannt - NPC anvisieren zum Updaten"
    GS_L["UI_LAYER_UNKNOWN_PROMPT"] = "Unbekannter Layer - Bitte NPC anvisieren zum Fortfahren!"
    GS_L["UI_LAYER_INVITE_SENT"] = "Einladungsanfrage an %s gesendet"
    GS_L["UI_LAYER_INVITE_CONFIRM_TITLE"] = "Anfrage Layer-Wechsel"
    GS_L["UI_LAYER_INVITE_CONFIRM_TEXT"] = "%s möchte in deinen Layer wechseln - bestätige für Gruppeneinladung"
    GS_L["UI_SETTINGS_AUTO_INVITE"] = "Anfragen für Layer-Wechsel automatisch annehmen"
    GS_L["UI_SETTINGS_HIDE_MINIMAP"] = "Minimap Button verstecken"
    GS_L["MSG_AUTO_ACCEPTED_INVITE"] = "Einladung von %s automatisch angenommen"
    GS_L["MSG_NEW_VERSION_AVAILABLE"] = "Eine neue Version von %s ist verfügbar (v%s). Bitte aktualisiere!"
end
