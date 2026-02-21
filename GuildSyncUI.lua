function LeftMenu:HideAllItems()
	for _, child in ipairs({LeftMenu:GetChildren()}) do
		child:Hide()
	end
end

-- Standard UI Frame (ButtonFrameTemplate is set in init.lua)
MainFrame:SetPoint("CENTER", UIParent ,"CENTER", 0, 0)
MainFrame:SetSize(820,620)
MainFrame:SetToplevel(true)
MainFrame:SetMovable(true)
MainFrame:SetFrameStrata("HIGH")
MainFrame:SetFrameLevel(1000)
MainFrame:Hide()
MainFrame:EnableMouse(true)
MainFrame:SetClampedToScreen(true)
MainFrame:RegisterForDrag("LeftButton")
MainFrame:SetScript("OnDragStart", function(self, button)
	self:StartMoving()
end)
MainFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

-- Title and portrait for the standard frame
if MainFrame.TitleText then MainFrame.TitleText:SetText("GuildSync") end
if MainFrame.portrait then MainFrame.portrait:SetTexture("Interface\\AddOns\\GuildSync\\GuildSync.png") end

-- Tab System
GS.currentTab = 1
local tab1 = CreateFrame("Button", "GS_GUITab1", MainFrame, "CharacterFrameTabButtonTemplate")
tab1:SetPoint("BOTTOMLEFT", MainFrame, "BOTTOMLEFT", 10, -8)
tab1:SetText(GS_L["UI_TAB_LOCKOUTS"])
tab1:SetID(1)

local tab2 = CreateFrame("Button", "GS_GUITab2", MainFrame, "CharacterFrameTabButtonTemplate")
tab2:SetPoint("LEFT", tab1, "RIGHT", -16, 0)
tab2:SetText(GS_L["UI_TAB_LAYERING"])
tab2:SetID(2)

local tab3 = CreateFrame("Button", "GS_GUITab3", MainFrame, "CharacterFrameTabButtonTemplate")
tab3:SetPoint("LEFT", tab2, "RIGHT", -16, 0)
tab3:SetText(GS_L["UI_TAB_SETTINGS"])
tab3:SetID(3)

local function Tab_OnClick(self)
    PanelTemplates_SetTab(MainFrame, self:GetID())
    GS.currentTab = self:GetID()
    if GS.currentTab == 1 then
        DifficultyMenu:Show()
        LeftMenu:Show()
        if GS.LayerFrame then GS.LayerFrame:Hide() end
        if GS.SettingsFrame then GS.SettingsFrame:Hide() end
        GuildIDContainer:Show()
    elseif GS.currentTab == 2 then
        DifficultyMenu:Hide()
        LeftMenu:Hide()
        GuildIDContainer:Hide()
        if GS.SettingsFrame then GS.SettingsFrame:Hide() end
        GS:ShowLayeringTab()
        
        -- Auto Refresh if data is older than 5 minutes or no data at all
        local now = GetTime()
        local lastQuery = GS.LayerLastQueryTime or 0
        local hasRecentData = false
        if GS.LayerData then
            for _, data in pairs(GS.LayerData) do
                if now - data.time < 300 then
                    hasRecentData = true
                    break
                end
            end
        end

        if not hasRecentData or (now - lastQuery > 300) then
            GS:RefreshLayerData()
        end
    else
        DifficultyMenu:Hide()
        LeftMenu:Hide()
        GuildIDContainer:Hide()
        if GS.LayerFrame then GS.LayerFrame:Hide() end
        GS:ShowSettingsTab()
    end
end

tab1:SetScript("OnClick", Tab_OnClick)
tab2:SetScript("OnClick", Tab_OnClick)
tab3:SetScript("OnClick", Tab_OnClick)

PanelTemplates_SetNumTabs(MainFrame, 3)
PanelTemplates_SetTab(MainFrame, 1)


-- Portrait wird über ButtonFrameTemplate gesetzt (siehe oben)

local dropDown = CreateFrame("Frame", "DifficultyMenu", MainFrame, "UIDropDownMenuTemplate")
local dropDownText = dropDown:CreateFontString(nil, "ARTWORK", "GameFontNormal")
dropDownText:SetText(GS_L["UI_DIFFICULTY_CHOOSE"])
dropDownText:SetPoint("TOPLEFT", "DifficultyMenu", 40, 10)

local function DifficultyMenu_OnClick(self, arg1, arg2, checked)
	
	-- Clear the right side box when changing category
	for _, child in ipairs({GuildIDContainer:GetChildren()}) do
		child:Hide()
		child:SetParent(nil)
	end

	if arg1 == "Heroics" then
		UIDropDownMenu_SetText(dropDown, GS_L["UI_HEROICS"])
		LeftMenu:HideAllItems()
		GS:MenuListItems(GS.instances, arg1)
	elseif arg1 == "10 Spieler" then
		UIDropDownMenu_SetText(dropDown, GS_L["UI_RAID10"])
		LeftMenu:HideAllItems()
		GS:MenuListItems(GS.raids, arg1)
	elseif arg1 == "25 Spieler" then
		UIDropDownMenu_SetText(dropDown, GS_L["UI_RAID25"])
		LeftMenu:HideAllItems()
		GS:MenuListItems(GS.raids, arg1)
	elseif arg1 == "PvP" then
		UIDropDownMenu_SetText(dropDown, GS_L["UI_PVP"])
		LeftMenu:HideAllItems()
		local pvpData = {}
		for _, q in ipairs(GS.pvpQuests) do pvpData[q.name] = true end
		GS:MenuListItems(pvpData, arg1)
	end
end

function DifficultyMenu_Menu(frame, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.func = DifficultyMenu_OnClick
	info.notCheckable = true
	info.text, info.arg1, info.value = GS_L["UI_HEROICS"], "Heroics", GS_L["UI_HEROICS"]
	UIDropDownMenu_AddButton(info)
	info.text, info.arg1, info.value = GS_L["UI_RAID10"], "10 Spieler", GS_L["UI_RAID10"]
	UIDropDownMenu_AddButton(info)
	info.text, info.arg1, info.value = GS_L["UI_RAID25"], "25 Spieler", GS_L["UI_RAID25"]
	UIDropDownMenu_AddButton(info)
	info.text, info.arg1, info.value = GS_L["UI_PVP"], "PvP", GS_L["UI_PVP"]
	UIDropDownMenu_AddButton(info)
end


dropDown:SetPoint("TOPLEFT", MainFrame.Inset or MainFrame, "TOPLEFT", 50, 25)
UIDropDownMenu_SetWidth(dropDown, 180) -- Etwas schmaler
UIDropDownMenu_SetButtonWidth(dropDown, 180) -- Wichtig für korrekte Ausrichtung
UIDropDownMenu_JustifyText(dropDown, "LEFT")
UIDropDownMenu_Initialize(dropDown, DifficultyMenu_Menu)


LeftMenu.backdropInfo = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	tileEdge = true,
}
LeftMenu:ApplyBackdrop()
LeftMenu:SetPoint("TOPLEFT", MainFrame.Inset or MainFrame, "TOPLEFT", 10, -10)
LeftMenu:SetSize(220, 510)

GuildIDContainer.backdropInfo = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	tileEdge = true,
}
GuildIDContainer:ApplyBackdrop()
GuildIDContainer:SetPoint("TOPLEFT", MainFrame.Inset or MainFrame, "TOPLEFT", 240, -10)
GuildIDContainer:SetSize(560,510)

function GS:ShowPlayerData(actual_difficulty, actual_instance)
	-- Zuerst alle alten Einträge im Container löschen (Sicherheitshalber nochmal)
	for _, child in ipairs({GuildIDContainer:GetChildren()}) do
		child:Hide()
		child:SetParent(nil)
	end

	if not GuildIDs or next(GuildIDs) == nil then
		local noData = GuildIDContainer:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		noData:SetText(GS_L["UI_NO_DATA"])
		noData:SetPoint("CENTER", GuildIDContainer, 0, 0)
		return
	end

	-- Header Erstellen
	local headers = {
		{name = GS_L["UI_LOCKOUT_COLUMN_NAME"], width = 120},
		{name = GS_L["UI_LOCKOUT_COLUMN_LEVEL"], width = 40},
		{name = GS_L["UI_LOCKOUT_COLUMN_ID"], width = 70},
		{name = GS_L["UI_LOCKOUT_COLUMN_DATE"], width = 130},
		{name = GS_L["UI_LOCKOUT_COLUMN_WHISPER"], width = 80},
		{name = GS_L["UI_LOCKOUT_COLUMN_INVITE"], width = 80},
	}
	
	local currentX = 20
	for i, h in ipairs(headers) do
		local fs = GuildIDContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		fs:SetText(h.name)
		fs:SetPoint("TOPLEFT", GuildIDContainer, "TOPLEFT", currentX, -20)
		currentX = currentX + h.width
	end

	local playerList = {}
	for name, data in pairs(GuildIDs) do
		table.insert(playerList, {name = name, data = data})
	end
	table.sort(playerList, function(a, b) return a.name < b.name end)

	local iter = 0
	local rowHeight = 25
	local startY = -50

	for _, p in ipairs(playerList) do
		local player_name = p.name
		local player_data = p.data
		
		-- Filter basierend auf Expansion Level
		local isLevelMatch = false
		if GS.isWotLK and player_data.Level and player_data.Level >= 70 then
			isLevelMatch = true
		elseif GS.isTBC and player_data.Level and player_data.Level >= 60 then
			isLevelMatch = true
		end

		if isLevelMatch then
			local row = CreateFrame("Frame", nil, GuildIDContainer)
			row:SetSize(540, rowHeight)
			row:SetPoint("TOPLEFT", GuildIDContainer, "TOPLEFT", 0, startY - (iter * rowHeight))

			local CharacterName = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
			CharacterName:SetPoint("LEFT", row, "LEFT", 20, 0)
			CharacterName:SetWidth(120)
			CharacterName:SetJustifyH("LEFT")
			CharacterName:SetText(player_name)

			local CharacterLevel = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
			CharacterLevel:SetPoint("LEFT", row, "LEFT", 140, 0)
			CharacterLevel:SetWidth(40)
			CharacterLevel:SetText(player_data.Level or "??")

			local CharacterID = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
			CharacterID:SetPoint("LEFT", row, "LEFT", 180, 0)
			CharacterID:SetWidth(70)
			CharacterID:SetJustifyH("LEFT")

			local CharacterLockedUntil = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
			CharacterLockedUntil:SetPoint("LEFT", row, "LEFT", 250, 0)
			CharacterLockedUntil:SetWidth(130)
			CharacterLockedUntil:SetJustifyH("LEFT")

			-- Farbe für Level unter Max
			if (GS.isWotLK and player_data.Level and player_data.Level < 80) or (GS.isTBC and player_data.Level and player_data.Level < 70) then
				CharacterLevel:SetTextColor(1, 0.5, 0, 1) -- Orange für fast max
				if player_data.Level < 70 and GS.isWotLK then CharacterLevel:SetTextColor(1,0,0,1) end
				if player_data.Level < 60 and GS.isTBC then CharacterLevel:SetTextColor(1,0,0,1) end
			end

			local instance_locked = false
			local status_text = GS_L["UI_STATUS_OPEN"]
			local date_text = ""

			if actual_difficulty == "PvP" then
				if player_data.PvP and player_data.PvP[actual_instance] then
					if player_data.PvP[actual_instance].completed then
						instance_locked = true
						status_text = GS_L["UI_STATUS_COMPLETED"]
					else
						status_text = GS_L["UI_STATUS_OPEN"]
					end
				else
					status_text = GS_L["UI_STATUS_UNKNOWN"]
				end
			elseif player_data.IDs then
				for difficulty, instances in pairs(player_data.IDs) do
					if difficulty == actual_difficulty then
						for instance_name, instance_detail in pairs(instances) do
							if instance_name == actual_instance then
								if GetServerTime() < instance_detail.instanceReset then
									instance_locked = true
									status_text = tostring(instance_detail.instanceID or "???")
									date_text = date("%d.%m.%y %H:%M", instance_detail.instanceReset)
								end
							end
						end
					end
				end
			end

			CharacterID:SetText(status_text)
			CharacterLockedUntil:SetText(date_text)

			if instance_locked then
				CharacterName:SetTextColor(1, 0, 0, 1)
				CharacterID:SetTextColor(1, 1, 1, 1)
			else
				CharacterName:SetTextColor(0, 1, 0, 1)
				CharacterID:SetTextColor(0.5, 0.5, 0.5, 1)
			end

			-- Whisper Button
			local whisperBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
			whisperBtn:SetSize(75, 20)
			whisperBtn:SetPoint("LEFT", row, "LEFT", 380, 0)
			whisperBtn:SetText(GS_L["UI_LOCKOUT_COLUMN_WHISPER"])
			whisperBtn:SetScript("OnClick", function()
				ChatFrame_OpenChat("/w " .. player_name .. " ", DEFAULT_CHAT_FRAME)
			end)

			-- Invite Button
			local inviteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
			inviteBtn:SetSize(75, 20)
			inviteBtn:SetPoint("LEFT", row, "LEFT", 460, 0)
			inviteBtn:SetText(GS_L["UI_LOCKOUT_COLUMN_INVITE"])
			inviteBtn:SetScript("OnClick", function()
				if C_PartyInfo and C_PartyInfo.InviteUnit then
					C_PartyInfo.InviteUnit(player_name)
				else
					InviteUnit(player_name)
				end
			end)

			iter = iter + 1
		end
	end

	if iter == 0 then
		local noPlayers = GuildIDContainer:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		noPlayers:SetText(GS_L["UI_NO_CHARACTERS"])
		noPlayers:SetPoint("CENTER", GuildIDContainer, 0, 0)
	end
end

function GS:ShowLayeringTab()
    if not GS.LayerFrame then
        GS.LayerFrame = CreateFrame("Frame", "GS_LayerFrame", MainFrame, "BackdropTemplate")
        GS.LayerFrame:SetPoint("TOPLEFT", MainFrame.Inset or MainFrame, "TOPLEFT", 10, -10)
        GS.LayerFrame:SetSize(780, 510)
        GS.LayerFrame.backdropInfo = GuildIDContainer.backdropInfo
        GS.LayerFrame:ApplyBackdrop()
        
        -- Header
        local headers = {
            {name = GS_L["UI_LAYER_COLUMN_NAME"], width = 150},
            {name = GS_L["UI_LAYER_COLUMN_LEVEL"], width = 50},
            {name = GS_L["UI_LAYER_COLUMN_ZONE"], width = 250},
            {name = GS_L["UI_LAYER_COLUMN_LAYER"], width = 100},
            {name = GS_L["UI_LAYER_COLUMN_ACTION"], width = 150},
        }
        
        local currentX = 20
        for i, h in ipairs(headers) do
            local fs = GS.LayerFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
            fs:SetText(h.name)
            fs:SetPoint("TOPLEFT", GS.LayerFrame, "TOPLEFT", currentX, -20)
            currentX = currentX + h.width
        end
        
        GS.LayerTableContent = CreateFrame("Frame", nil, GS.LayerFrame)
        GS.LayerTableContent:SetPoint("TOPLEFT", GS.LayerFrame, "TOPLEFT", 0, -50)
        GS.LayerTableContent:SetSize(770, 500)

        -- Refresh Button
        GS.LayerRefreshBtn = CreateFrame("Button", "GS_LayerRefreshBtn", GS.LayerFrame, "UIPanelButtonTemplate")
        GS.LayerRefreshBtn:SetSize(120, 25)
        GS.LayerRefreshBtn:SetPoint("TOPRIGHT", GS.LayerFrame, "TOPRIGHT", -10, 40)
        GS.LayerRefreshBtn:SetText(GS_L["UI_LAYER_REFRESH"])
        GS.LayerRefreshBtn:SetScript("OnClick", function()
            GS:RefreshLayerData()
        end)
        
        -- Cooldown Text
        GS.LayerCooldownFS = GS.LayerFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        GS.LayerCooldownFS:SetPoint("RIGHT", GS.LayerRefreshBtn, "LEFT", -10, 0)
        GS.LayerCooldownFS:Hide()

        -- Current Layer Text (top-left, same height as refresh button)
        if not GS.LayerCurrentFS then
            GS.LayerCurrentFS = GS.LayerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            GS.LayerCurrentFS:SetPoint("TOPLEFT", GS.LayerFrame, "TOPLEFT", 50, 40)
        end
        GS.LayerCurrentFS:SetText(string.format(GS_L["UI_LAYER_CURRENT"], GS:GetLayer() or GS_L["UI_LAYER_UNKNOWN"]))

        -- Recurring update for "Current Layer" text
        GS.LayerFrame:SetScript("OnUpdate", function(self, elapsed)
            self.updateTimer = (self.updateTimer or 0) + elapsed
            if self.updateTimer >= 1 then
                self.updateTimer = 0
                if GS.LayerCurrentFS then
                    GS.LayerCurrentFS:SetText(string.format(GS_L["UI_LAYER_CURRENT"], GS:GetLayer() or GS_L["UI_LAYER_UNKNOWN"]))
                end
            end
        end)
    end
    
    GS.LayerFrame:Show()
    GS:UpdateLayerTable()
end

function GS:RefreshLayerData()
    local now = GetTime()
    local lastQuery = GS.LayerLastQueryTime or 0
    local cooldown = 30
    
    if now - lastQuery < cooldown then
        -- Still on cooldown
        return
    end

    if not GS:GetLayer() then
        -- Layer unknown, don't send query
        GS:UpdateLayerTable()
        return
    end
    
    GS.LayerLastQueryTime = now
    GS:send({type = "LAYER_QUERY"})
    GS:msg(GS_L["UI_LAYER_QUERY_SENT"])
    
    -- Update UI to show loading immediately
    GS:UpdateLayerTable()
    
    -- Schedule a check in 30 seconds to show error if no data arrived
    C_Timer.After(cooldown + 0.5, function()
        if GS.LayerFrame and GS.LayerFrame:IsVisible() and GS.currentTab == 2 then
            GS:UpdateLayerTable()
        end
    end)
    
    -- Update Button State
    if GS.LayerRefreshBtn then
        GS.LayerRefreshBtn:Disable()
        C_Timer.After(cooldown, function()
            if GS.LayerRefreshBtn then GS.LayerRefreshBtn:Enable() end
            if GS.LayerCooldownFS then GS.LayerCooldownFS:Hide() end
        end)
        
        -- Cooldown Countdown
        if GS.LayerCooldownFS then
            GS.LayerCooldownFS:Show()
            local remaining = cooldown
            local function updateCooldown()
                if remaining > 0 and GS.LayerFrame and GS.LayerFrame:IsVisible() then
                    GS.LayerCooldownFS:SetText(string.format(GS_L["UI_LAYER_COOLDOWN"], remaining))
                    remaining = remaining - 1
                    C_Timer.After(1, updateCooldown)
                else
                    if GS.LayerCooldownFS then GS.LayerCooldownFS:Hide() end
                end
            end
            updateCooldown()
        end
    end
end

function GS:UpdateLayerTable()
    if not GS.LayerTableContent then return end
    if GS.LayerCurrentFS then
        GS.LayerCurrentFS:SetText(string.format(GS_L["UI_LAYER_CURRENT"], GS:GetLayer() or GS_L["UI_LAYER_UNKNOWN"]))
    end
    
    -- Vorherige Inhalte löschen (Frames und FontStrings)
    for _, child in ipairs({GS.LayerTableContent:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    -- FontStrings, die direkt am Frame hängen, müssen ebenfalls gelöscht oder versteckt werden
    -- Da wir CreateFontString nutzen, können wir diese nicht einfach via GetChildren finden.
    -- Besser: Wir nutzen einen permanenten FontString für Statusmeldungen.
    if not GS.LayerStatusFS then
        GS.LayerStatusFS = GS.LayerTableContent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        GS.LayerStatusFS:SetPoint("CENTER", GS.LayerTableContent, 0, 0)
    end
    GS.LayerStatusFS:Hide()
    
    local now = GetTime()
    local sortedPlayers = {}
    if GS.LayerData then
        for name, data in pairs(GS.LayerData) do
            -- Nur Daten der letzten 5 Minuten anzeigen
            if now - data.time < 300 then
                table.insert(sortedPlayers, {name = name, data = data})
            end
        end
    end
    
    if #sortedPlayers == 0 then
        local msg = GS_L["UI_LAYER_LOADING"]
        local lastQuery = GS.LayerLastQueryTime or 0
        
        if not GS:GetLayer() then
            msg = GS_L["UI_LAYER_UNKNOWN_PROMPT"]
        elseif GetTime() - lastQuery > 30 then
            msg = GS_L["UI_LAYER_NO_DATA"]
        end
        
        GS.LayerStatusFS:SetText(msg)
        GS.LayerStatusFS:Show()
        return
    end

    table.sort(sortedPlayers, function(a, b) return a.name < b.name end)
    
    local rowHeight = 25
    for i, p in ipairs(sortedPlayers) do
        local row = CreateFrame("Frame", nil, GS.LayerTableContent)
        row:SetSize(770, rowHeight)
        row:SetPoint("TOPLEFT", GS.LayerTableContent, "TOPLEFT", 0, -(i-1) * rowHeight)
        
        local nameFS = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        nameFS:SetText(p.name)
        nameFS:SetPoint("LEFT", row, "LEFT", 20, 0)
        nameFS:SetWidth(150)
        nameFS:SetJustifyH("LEFT")
        
        local lvlFS = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        lvlFS:SetText(p.data.level or "??")
        lvlFS:SetPoint("LEFT", row, "LEFT", 170, 0)
        lvlFS:SetWidth(50)
        
        local zoneFS = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        zoneFS:SetText(p.data.zone or "Unknown")
        zoneFS:SetPoint("LEFT", row, "LEFT", 220, 0)
        zoneFS:SetWidth(250)
        zoneFS:SetJustifyH("LEFT")
        
        local layerFS = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        layerFS:SetText(p.data.layer or "-")
        layerFS:SetPoint("LEFT", row, "LEFT", 470, 0)
        layerFS:SetWidth(100)
        
        local isSameLayer = false
        local myLayer = GS:GetLayer()
        if myLayer and p.data.layer and tostring(p.data.layer) == tostring(myLayer) then
            isSameLayer = true
        end
        
        if not p.data.inGroup then
            local btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            btn:SetSize(120, 20)
            btn:SetPoint("LEFT", row, "LEFT", 570, 0)
            btn:SetText(GS_L["UI_LAYER_INVITE"])
            
            if isSameLayer then
                btn:Disable()
            end

            btn:SetScript("OnClick", function()
                GS.ExpectedInviteSender = p.name
                GS.ExpectedInviteTime = GetTime()
                GS:send({type = "LAYER_INVITE_REQUEST", target = p.name})
                GS:msg(string.format(GS_L["UI_LAYER_INVITE_SENT"], p.name))
            end)
        else
            local inGrpFS = row:CreateFontString(nil, "ARTWORK", "GameFontDisable")
            inGrpFS:SetText(GS_L["UI_LAYER_IN_GROUP"])
            inGrpFS:SetPoint("LEFT", row, "LEFT", 570, 0)
            inGrpFS:SetWidth(120)
        end
    end
end

function GS:ShowSettingsTab()
    if not GS.SettingsFrame then
        GS.SettingsFrame = CreateFrame("Frame", "GS_SettingsFrame", MainFrame, "BackdropTemplate")
        GS.SettingsFrame:SetPoint("TOPLEFT", MainFrame.Inset or MainFrame, "TOPLEFT", 10, -10)
        GS.SettingsFrame:SetSize(780, 510)
        GS.SettingsFrame.backdropInfo = GuildIDContainer.backdropInfo
        GS.SettingsFrame:ApplyBackdrop()

        local title = GS.SettingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 20, -20)
        title:SetText(GS_L["UI_TAB_SETTINGS"])

        -- Auto-invite Checkbox
        local autoInviteCb = CreateFrame("CheckButton", "GS_Settings_AutoInviteCB", GS.SettingsFrame, "ChatConfigCheckButtonTemplate")
        autoInviteCb:SetPoint("TOPLEFT", 20, -60)
        _G[autoInviteCb:GetName() .. "Text"]:SetText(GS_L["UI_SETTINGS_AUTO_INVITE"])
        
        autoInviteCb:SetScript("OnShow", function(self)
            self:SetChecked(GuildSyncDB.settings and GuildSyncDB.settings.autoAcceptLayerInvite)
        end)

        autoInviteCb:SetScript("OnClick", function(self)
            GuildSyncDB.settings = GuildSyncDB.settings or {}
            GuildSyncDB.settings.autoAcceptLayerInvite = self:GetChecked()
        end)

        -- Hide Minimap Checkbox
        local hideMinimapCb = CreateFrame("CheckButton", "GS_Settings_HideMinimapCB", GS.SettingsFrame, "ChatConfigCheckButtonTemplate")
        hideMinimapCb:SetPoint("TOPLEFT", 20, -100)
        _G[hideMinimapCb:GetName() .. "Text"]:SetText(GS_L["UI_SETTINGS_HIDE_MINIMAP"])
        
        hideMinimapCb:SetScript("OnShow", function(self)
            self:SetChecked(GuildSyncDB.minimap and GuildSyncDB.minimap.hide)
        end)

        hideMinimapCb:SetScript("OnClick", function(self)
            GuildSyncDB.minimap = GuildSyncDB.minimap or {}
            GuildSyncDB.minimap.hide = self:GetChecked()
            if GuildSyncMinimapButton then
                if GuildSyncDB.minimap.hide then
                    GuildSyncMinimapButton:Hide()
                else
                    GuildSyncMinimapButton:Show()
                end
            end
        end)
    end

    GS.SettingsFrame:Show()
end
