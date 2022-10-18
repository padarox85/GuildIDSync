-- Konstanten
GID_PREFIX = "GID";
ADDON_NAME = "GuildIDSync";
GID_VERSION = "0.0.1";
CHAR = {}
CHAR.NAME, CHAR.REALM = UnitName("player")
CHAR.LEVEL = UnitLevel("player")
LAST_UPDATE = nil

-- User Variables
MYIDS = {}
GID = {}


-- imports
LibDeflate = LibStub:GetLibrary("LibDeflate")
LibSerialize = LibStub("LibSerialize")
LibIcon = LibStub("LibDBIcon-1.0")

--init Frames
MainFrame = CreateFrame("Frame", "GID_GUI", UIParent, "BackdropTemplate")
LeftMenu = CreateFrame("Frame", "LeftMenu", MainFrame, "BackdropTemplate")
GuildIDContainer = CreateFrame("Frame", "GuildIDContainer", MainFrame, "BackdropTemplate")


--init MiniMapButton
local addon = LibStub("AceAddon-3.0"):NewAddon("GuildIDSync", "AceConsole-3.0")
local GIDLDB = LibStub("LibDataBroker-1.1"):NewDataObject("GuildIDMinimap", {
    type = "data source",
    text = "GuildIDSync",
    icon = "Interface\\Icons\\INV_Chest_Cloth_17",
    OnClick = function() GID:Toggle() end,
    OnTooltipShow = function(tt)
        tt:AddLine("GuildIDSync")
        tt:AddLine("|cffffff00Klick|r um GuildIDSync zu öffnen / zu verstecken.")
    end,
})
local icon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("GuildIDSyncDB", { profile = { minimap = { hide = false, }, }, })
    icon:Register("GuildIDSync", GIDLDB, self.db.profile.minimap)
end