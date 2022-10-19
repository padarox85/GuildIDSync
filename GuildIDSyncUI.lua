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
MainFrame:SetToplevel()
MainFrame:SetMovable(true)
MainFrame:SetFrameLevel(1000)
MainFrame:ApplyBackdrop()
MainFrame:Hide()
MainFrame:EnableMouse(true)
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

local dropDown = CreateFrame("Frame", "DifficultyMenu", MainFrame, "UIDropDownMenuTemplate")
local dropDownText = dropDown:CreateFontString(dropDown, "ARTWORK", "GameFontNormal")
dropDownText:SetText("Wähle Schwierigkeit / Raidgröße:")
dropDownText:SetPoint("TOPLEFT", "DifficultyMenu", 20, 15)

local function DifficultyMenu_OnClick(self, arg1, arg2, checked)
	
	if arg1 == "Heroics" then
		UIDropDownMenu_SetText(dropDown, "Heroische Instanzen")
		LeftMenu:HideAllItems()
		GID:MenuListItems(GID.instances, arg1)
	elseif arg1 == "10 Spieler" then
		UIDropDownMenu_SetText(dropDown, "Raid: 10 Spieler")
		LeftMenu:HideAllItems()
		GID:MenuListItems(GID.raids, arg1)
	elseif arg1 == "25 Spieler" then
		UIDropDownMenu_SetText(dropDown, "Raid: 25 Spieler")
		LeftMenu:HideAllItems()
		GID:MenuListItems(GID.raids, arg1)
	end
end

function DifficultyMenu_Menu(frame, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.func = DifficultyMenu_OnClick
	info.text, info.arg1, info.value = "Heroische Instanzen", "Heroics", "Heroische Instanzen"
	UIDropDownMenu_AddButton(info)
	info.text, info.arg1, info.value = "Raid: 10 Spieler", "10 Spieler", "Raid: 10 Spieler"
	UIDropDownMenu_AddButton(info)
	info.text, info.arg1, info.value = "Raid: 25 Spieler", "25 Spieler", "Raid: 25 Spieler"
	UIDropDownMenu_AddButton(info)
end


dropDown:SetPoint("TOPLEFT", "GID_GUI", 10, -40)
 UIDropDownMenu_SetWidth(dropDown, 200) -- Use in place of dropDown:SetWidth
 -- Bind an initializer function to the dropdown; see previous sections for initializer function examples.
 UIDropDownMenu_Initialize(dropDown, DifficultyMenu_Menu)


LeftMenu.backdropInfo = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	tileEdge = true,
}
LeftMenu:ApplyBackdrop()
LeftMenu:SetPoint("TOPLEFT", "GID_GUI", "TOPLEFT", 25, -80)
LeftMenu:SetSize(220,495)

GuildIDContainer.backdropInfo = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	tileEdge = true,
}
GuildIDContainer:ApplyBackdrop()
GuildIDContainer:SetPoint("TOPLEFT", "GID_GUI", "TOPLEFT", 260, -25)
GuildIDContainer:SetSize(510,550)

function GID:ShowPlayerData(actual_difficulty, actual_instance)
	local config = {last = {obj = nil, name = nil}, first_column = {obj = nil, name = nil}, iter = 0}

	for player_name, player_data in pairs(GuildIDs) do
		if player_data.Level == 80 then
			if config.last.obj == nil then
				config.last.obj = GuildIDContainer
				config.last.name = "GuildIDContainer"
			elseif config.iter == 0 then
				config.last.obj = config.first_column.obj
				config.last.name = config.first_column.name
			end
			
			local charFrame = CreateFrame("Frame", player_name, config.last.obj, "BackdropTemplate")

			if config.last.name == "GuildIDContainer" then
				charFrame:SetPoint("TOPLEFT", "GuildIDContainer", -10, 60)
				config.last.obj = charFrame
				config.last.name = player_name
			elseif config.iter == 0 then
				charFrame:SetPoint("TOPLEFT", config.last.name, 0, -20)
				config.first_column.obj = charFrame
				config.first_column.name = player_name
				config.last.obj = charFrame
				config.last.name = player_name
			elseif (config.iter > 0 and config.iter < 4) then
				charFrame:SetPoint("TOPLEFT", config.last.name, 125, 0)
				config.last.obj = charFrame
				config.last.name = player_name
			end
			charFrame:SetSize(150,150)
			CharacterName = charFrame:CreateFontString(charFrame, "ARTWORK", "GameFontNormal")
			CharacterName:SetText(player_name)
			CharacterName:SetPoint("CENTER", charFrame, 0, 0)
			CharacterLevel = charFrame:CreateFontString(charFrame, "ARTWORK", "GameFontNormal")
			CharacterLevel:SetText("Level: "..player_data.Level)
			CharacterLevel:SetPoint("CENTER", CharacterName, 0, -15)
			CharacterID = charFrame:CreateFontString(charFrame, "ARTWORK", "GameFontNormal")
			CharacterID:SetPoint("CENTER", CharacterLevel, 0, -15)
			CharacterLockedUntil = charFrame:CreateFontString(charFrame, "ARTWORK", "GameFontNormal")
			CharacterLockedUntil:SetPoint("CENTER", CharacterID, 0, -15)
			if player_data.Level < 80 then
				CharacterLevel:SetTextColor(1,0,0,1)
			end

			local instance_locked = false
			for difficulty, instances in pairs(player_data.IDs) do
				if difficulty == actual_difficulty then
					for instance_name, instance_detail in pairs(instances) do
						if instance_name == actual_instance then
							if time() < instance_detail.instanceReset then
								instance_locked = true
								CharacterID:SetText("ID: "..instance_detail.instanceID)
								CharacterLockedUntil:SetText(date("%d.%m.%y %H:%M", instance_detail.instanceReset))
							end
						end
					end
				end
			end
			if instance_locked then
				CharacterName:SetTextColor(1,0,0,1)
			else
				CharacterName:SetTextColor(0,1,0,1)
				CharacterID:SetText("ID: -")
				CharacterLockedUntil:SetText("")
			end
			
			if config.iter < 3 then
				config.iter = config.iter + 1
			else
				config.iter = 0
			end
		end
	end
end