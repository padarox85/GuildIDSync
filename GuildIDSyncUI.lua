function LeftMenu:HideAllItems()
	for _, child in ipairs({LeftMenu:GetChildren()}) do
		child:Hide()
	end
end

MainFrame.backdropInfo = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileEdge = true,
	tileSize = 32,
	edgeSize = 32,
	insets = { left = 11, right = 12, top = 12, bottom = 11 },
}
MainFrame:SetPoint("CENTER", UIParent ,"CENTER", 0, 0)
MainFrame:SetSize(800,600)
MainFrame:SetToplevel(true)
MainFrame:SetMovable(true)
MainFrame:SetFrameStrata("HIGH")
MainFrame:SetFrameLevel(1000)
MainFrame:ApplyBackdrop()
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

local close = CreateFrame("Button", "CloseAll", MainFrame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", "GID_GUI", 2, 2)
close:SetScript("OnClick", function(self)
	MainFrame:Hide()
end)

-- Portrait / Logo oben links
local portraitContainer = CreateFrame("Frame", nil, MainFrame)
portraitContainer:SetSize(80, 80)
portraitContainer:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", -20, 20)

local portraitTexture = portraitContainer:CreateTexture(nil, "BACKGROUND")
portraitTexture:SetTexture("Interface\\AddOns\\GuildIDSync\\GuildIDSync.png")
portraitTexture:SetSize(80, 80)
portraitTexture:SetPoint("CENTER", portraitContainer, "CENTER", 0, 0)

local dropDown = CreateFrame("Frame", "DifficultyMenu", MainFrame, "UIDropDownMenuTemplate")
local dropDownText = dropDown:CreateFontString(nil, "ARTWORK", "GameFontNormal")
dropDownText:SetText(GID_L["UI_DIFFICULTY_CHOOSE"])
dropDownText:SetPoint("TOPLEFT", "DifficultyMenu", 20, 15)

local function DifficultyMenu_OnClick(self, arg1, arg2, checked)
	
	if arg1 == "Heroics" then
		UIDropDownMenu_SetText(dropDown, GID_L["UI_HEROICS"])
		LeftMenu:HideAllItems()
		GID:MenuListItems(GID.instances, arg1)
	elseif arg1 == "10 Spieler" then
		UIDropDownMenu_SetText(dropDown, GID_L["UI_RAID10"])
		LeftMenu:HideAllItems()
		GID:MenuListItems(GID.raids, arg1)
	elseif arg1 == "25 Spieler" then
		UIDropDownMenu_SetText(dropDown, GID_L["UI_RAID25"])
		LeftMenu:HideAllItems()
		GID:MenuListItems(GID.raids, arg1)
	elseif arg1 == "PvP" then
		UIDropDownMenu_SetText(dropDown, GID_L["UI_PVP"])
		LeftMenu:HideAllItems()
		local pvpData = {}
		for _, q in ipairs(GID.pvpQuests) do pvpData[q.name] = true end
		GID:MenuListItems(pvpData, arg1)
	end
end

function DifficultyMenu_Menu(frame, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.func = DifficultyMenu_OnClick
	info.notCheckable = true
	info.text, info.arg1, info.value = GID_L["UI_HEROICS"], "Heroics", GID_L["UI_HEROICS"]
	UIDropDownMenu_AddButton(info)
	info.text, info.arg1, info.value = GID_L["UI_RAID10"], "10 Spieler", GID_L["UI_RAID10"]
	UIDropDownMenu_AddButton(info)
	info.text, info.arg1, info.value = GID_L["UI_RAID25"], "25 Spieler", GID_L["UI_RAID25"]
	UIDropDownMenu_AddButton(info)
	info.text, info.arg1, info.value = GID_L["UI_PVP"], "PvP", GID_L["UI_PVP"]
	UIDropDownMenu_AddButton(info)
end


dropDown:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 25, -100)
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
LeftMenu:SetPoint("TOPLEFT", "GID_GUI", "TOPLEFT", 25, -140)
LeftMenu:SetSize(220, 435)

GuildIDContainer.backdropInfo = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	tileEdge = true,
}
GuildIDContainer:ApplyBackdrop()
GuildIDContainer:SetPoint("TOPLEFT", "GID_GUI", "TOPLEFT", 260, -25)
GuildIDContainer:SetSize(510,550)

function GID:ShowPlayerData(actual_difficulty, actual_instance)
	-- Zuerst alle alten Einträge im Container löschen (Sicherheitshalber nochmal)
	for _, child in ipairs({GuildIDContainer:GetChildren()}) do
		child:Hide()
		child:SetParent(nil)
	end

	if not GuildIDs or next(GuildIDs) == nil then
		local noData = GuildIDContainer:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		noData:SetText(GID_L["UI_NO_DATA"])
		noData:SetPoint("CENTER", GuildIDContainer, 0, 0)
		return
	end

	local iter = 0
	local row = 0
	local col = 0
	local itemsPerRow = 4
	local itemWidth = 120
	local itemHeight = 100
	local startX = 20
	local startY = -20

	for player_name, player_data in pairs(GuildIDs) do
		-- Filter basierend auf Expansion Level
		local isLevelMatch = false
		if GID.isWotLK and player_data.Level and player_data.Level >= 70 then
			isLevelMatch = true
		elseif GID.isTBC and player_data.Level and player_data.Level >= 60 then
			isLevelMatch = true
		end

		if isLevelMatch then
			local charFrame = CreateFrame("Frame", nil, GuildIDContainer, "BackdropTemplate")
			charFrame:SetSize(itemWidth, itemHeight)
			charFrame:SetPoint("TOPLEFT", GuildIDContainer, "TOPLEFT", startX + (col * itemWidth), startY - (row * itemHeight))

			local CharacterName = charFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			CharacterName:SetText(player_name)
			CharacterName:SetPoint("TOP", charFrame, 0, -5)

			local CharacterLevel = charFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			CharacterLevel:SetText(string.format(GID_L["UI_LVL"], (player_data.Level or "??")))
			CharacterLevel:SetPoint("TOP", CharacterName, 0, -15)

			local CharacterID = charFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			CharacterID:SetPoint("TOP", CharacterLevel, 0, -15)

			local CharacterLockedUntil = charFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			CharacterLockedUntil:SetPoint("TOP", CharacterID, 0, -12)

			-- Farbe für Level unter Max
			if (GID.isWotLK and player_data.Level and player_data.Level < 80) or (GID.isTBC and player_data.Level and player_data.Level < 70) then
				CharacterLevel:SetTextColor(1, 0.5, 0, 1) -- Orange für fast max
				if player_data.Level < 70 and GID.isWotLK then CharacterLevel:SetTextColor(1,0,0,1) end
				if player_data.Level < 60 and GID.isTBC then CharacterLevel:SetTextColor(1,0,0,1) end
			end

			local instance_locked = false
			if actual_difficulty == "PvP" then
				if player_data.PvP and player_data.PvP[actual_instance] then
					if player_data.PvP[actual_instance].completed then
						instance_locked = true
						CharacterID:SetText(GID_L["UI_STATUS_COMPLETED"])
					else
						CharacterID:SetText(GID_L["UI_STATUS_OPEN"])
					end
				else
					CharacterID:SetText(GID_L["UI_STATUS_UNKNOWN"])
				end
			elseif player_data.IDs then
				for difficulty, instances in pairs(player_data.IDs) do
					if difficulty == actual_difficulty then
						for instance_name, instance_detail in pairs(instances) do
							if instance_name == actual_instance then
								if GetServerTime() < instance_detail.instanceReset then
									instance_locked = true
									CharacterID:SetText(string.format(GID_L["UI_ID"], (instance_detail.instanceID or "???")))
									CharacterLockedUntil:SetText(date("%d.%m.%y %H:%M", instance_detail.instanceReset))
								end
							end
						end
					end
				end
			end

			if instance_locked then
				CharacterName:SetTextColor(1, 0, 0, 1)
				CharacterID:SetTextColor(1, 1, 1, 1)
			else
				CharacterName:SetTextColor(0, 1, 0, 1)
				CharacterID:SetText(string.format(GID_L["UI_ID"], "-"))
				CharacterID:SetTextColor(0.5, 0.5, 0.5, 1)
				CharacterLockedUntil:SetText("")
			end

			col = col + 1
			if col >= itemsPerRow then
				col = 0
				row = row + 1
			end
			iter = iter + 1
		end
	end

	if iter == 0 then
		local noPlayers = GuildIDContainer:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		noPlayers:SetText(GID_L["UI_NO_CHARACTERS"])
		noPlayers:SetPoint("CENTER", GuildIDContainer, 0, 0)
	end
end