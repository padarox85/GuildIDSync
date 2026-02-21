-- Konstanten
GS_PREFIX = "GS";
ADDON_NAME = "GuildSync";
GS_VERSION = "2.0.4";
CHAR = {}
CHAR.NAME, CHAR.REALM = UnitName("player")
CHAR.LEVEL = UnitLevel("player")
LAST_UPDATE = nil

-- User Variables
MYIDS = {}
GS = {}


-- imports
LibDeflate = LibStub:GetLibrary("LibDeflate")
AceSerializer = LibStub("AceSerializer-3.0")

--init Frames
MainFrame = CreateFrame("Frame", "GS_GUI", UIParent, "ButtonFrameTemplate")
LeftMenu = CreateFrame("Frame", "LeftMenu", MainFrame, "BackdropTemplate")
GuildIDContainer = CreateFrame("Frame", "GuildIDContainer", MainFrame, "BackdropTemplate")


function GS:InitMinimap()
    -- Migrate old SavedVariables if present
    if _G.GuildSyncDB == nil and _G.GuildIDSyncDB ~= nil then
        _G.GuildSyncDB = _G.GuildIDSyncDB
    end
    
    -- Ensure GuildSyncDB exists and has minimap settings
    _G.GuildSyncDB = _G.GuildSyncDB or {}
    _G.GuildSyncDB.minimap = _G.GuildSyncDB.minimap or { hide = false, pos = 45, x = -80, y = 0 }
    _G.GuildSyncDB.settings = _G.GuildSyncDB.settings or { autoAcceptLayerInvite = false }
    
    local button = CreateFrame("Button", "GuildSyncMinimapButton", Minimap)
    if _G.GuildSyncDB.minimap.hide then button:Hide() end
    button:SetSize(31, 31)
    button:SetMovable(true)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    
    -- Background
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(21, 21)
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetPoint("CENTER", 0, 0)
    bg:SetVertexColor(0.2, 0.2, 0.2, 1) -- Dunkelgrau

    -- Border
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetPoint("TOPLEFT", 0, 0)

    -- GS Text
    button.gs_text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    button.gs_text:SetPoint("CENTER", 0, 0)
    button.gs_text:SetText("GS")
    button.gs_text:SetTextColor(1, 1, 0, 1)

    -- Tooltip
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("GuildSync")
        GameTooltip:AddLine(GS_L["UI_MINIMAP_TOOLTIP_CLICK"], 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Position calculation
    local function UpdatePosition()
        button:ClearAllPoints()
        if _G.GuildSyncDB.minimap.x and _G.GuildSyncDB.minimap.y then
            button:SetPoint("CENTER", Minimap, "CENTER", _G.GuildSyncDB.minimap.x, _G.GuildSyncDB.minimap.y)
        else
            -- Fallback to old angle calculation
            local angle = _G.GuildSyncDB.minimap.pos or 45
            local radius = 80
            button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (radius * cos(angle)), (radius * sin(angle)) - 52)
        end
    end

    -- Dragging logic
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function(self)
        self:StartMoving()
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local bx, by = self:GetCenter()
            if mx and my and bx and by then
                _G.GuildSyncDB.minimap.x = (bx - mx)
                _G.GuildSyncDB.minimap.y = (by - my)
            end
        end)
    end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self:SetScript("OnUpdate", nil)
        UpdatePosition()
    end)

    button:SetScript("OnClick", function(self)
        GS:Toggle()
    end)

    UpdatePosition()
    button:Show()
end
