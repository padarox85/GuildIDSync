local select, ipairs, mfloor, mmax, mmin = select, pairs, math.floor, math.max, math.min

GID = GID or {};
GID.fully_loaded = false;
GID.default_options = {

	-- main frame position
	frameRef = "CENTER",
	frameX = 0,
	frameY = 0,
	hide = false,

	-- sizing
	frameW = 400,
	frameH = 600,
};

-- Expansions-Erkennung
local _, _, _, interface = GetBuildInfo()
GID.isWotLK = (interface >= 30000 and interface < 40000)
GID.isTBC = (interface >= 20000 and interface < 30000)

-- HEROICS
GID.instances = {};
if GID.isTBC then
	GID.instances["Höllenfeuerbollwerk"] = true
	GID.instances["Der Blutkessel"] = true
	GID.instances["Die Zerschmetterten Hallen"] = true
	GID.instances["Die Sklavenunterkünfte"] = true
	GID.instances["Der Tiefensumpf"] = true
	GID.instances["Die Dampfkammer"] = true
	GID.instances["Die Managruft"] = true
	GID.instances["Auchenai-Krypta"] = true
	GID.instances["Sethekkhallen"] = true
	GID.instances["Schattenlabyrinth"] = true
	GID.instances["Vorgebirge des Alten Hügellands"] = true
	GID.instances["Der Schwarze Morast"] = true
	GID.instances["Die Botanika"] = true
	GID.instances["Die Mechanar"] = true
	GID.instances["Die Arkatraz"] = true
	GID.instances["Terrasse der Magister"] = true
elseif GID.isWotLK then
	GID.instances["Burg Utgarde"] = true
	GID.instances["Turm Utgarde"] = true
	GID.instances["Der Nexus"] = true
	GID.instances["Das Oculus"] = true
	GID.instances["Azjol-Nerub"] = true
	GID.instances["Ahn'kahet: Das alte Königreich"] = true
	GID.instances["Feste Drak'Tharon"] = true
	GID.instances["Die Violette Festung"] = true
	GID.instances["Gundrak"] = true
	GID.instances["Hallen des Steins"] = true
	GID.instances["Hallen der Blitze"] = true
	GID.instances["Das Ausmerzen von Stratholme"] = true
	GID.instances["Prüfung des Champions"] = false
	GID.instances["Die Seelenschmiede"] = false
	GID.instances["Grube von Saron"] = false
	GID.instances["Hallen der Reflexion"] = false
end

-- RAIDS
GID.raids = {}
if GID.isTBC then
	GID.raids["Karazhan"] = true
	GID.raids["Zul'Aman"] = true
	GID.raids["Gruuls Unterschlupf"] = true
	GID.raids["Magtheridons Kammer"] = true
	GID.raids["Höhle des Schlangenschreins"] = true
	GID.raids["Festung der Stürme"] = true
	GID.raids["Hyjal"] = true
	GID.raids["Der Schwarze Tempel"] = true
	GID.raids["Sonnenbrunnenplateau"] = true
elseif GID.isWotLK then
	GID.raids["Archavons Kammer"] = true
	GID.raids["Das Obsidiansanktum"] = true
	GID.raids["Naxxramas"] = true
	GID.raids["Das Auge der Ewigkeit"] = true
	GID.raids["Ulduar"] = false
	GID.raids["Prüfung des Kreuzfahrers"] = false
	GID.raids["Eiskronenzitadelle"] = false
	GID.raids["Das Rubinsanktum"] = false
end

-- PVP QUESTS
GID.pvpQuests = {
	{ name = GID_L["PVP_BG_DAILY"], ids = { 
		-- TBC
		11335, 11336, 11337, 11338, 11339, 11340, 11341, 11342, 11499, 11500,
		-- WotLK (Call to Arms)
		11335, 11336, 11337, 11338, 11339, 11340, 11341, 11342, 11499, 11500, -- Repeat IDs from TBC often used
		13442, 13443, 13444, 13445, 13446, 13447, 13448, 13449, 13450, -- Newer WotLK IDs
	} },
	{ name = GID_L["PVP_HELLFIRE"], ids = { 10110, 10106 } }, -- Hellfire Fortifications (H/A)
	{ name = GID_L["PVP_TEROKKAR"], ids = { 11505, 11506 } }, -- Spirits of Auchindoun (A/H)
	{ name = GID_L["PVP_NAGRAND"], ids = { 11503, 11502 } }, -- Halaa (A/H)
}

-- Add WotLK specific PvP quests
if GID.isWotLK then
	table.insert(GID.pvpQuests, { name = GID_L["PVP_WINTERGRASP"], ids = { 13177, 13178, 13179, 13180, 13181, 13222, 13223 } })
end

function GID:MenuListItems(Items, difficulty)
	local i = 0
	for instance_name, active in pairs(Items) do
		local cb = CreateFrame("Button", "InstanceCheckBox"..i, LeftMenu,"OptionsListButtonTemplate")
		local text = cb:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		text:SetText(instance_name)
		text:SetPoint("LEFT", "InstanceCheckBox"..i, 0, 0)
		if i == 0 then
			cb:SetPoint("TOPLEFT", "LeftMenu", 10, -10)
		else
			cb:SetPoint("TOPLEFT", "InstanceCheckBox"..i-1, 0, -20)
		end
		i = i+1
		cb:Show()
		cb:SetScript("OnClick", function(event)
			for key, child in ipairs({LeftMenu:GetChildren()}) do
				child:UnlockHighlight()
			end
			cb:LockHighlight()
         for key, child in ipairs({GuildIDContainer:GetChildren()}) do
            child:Hide()
         end
			GID:ShowPlayerData(difficulty, instance_name)
		end)
	end
end

function GID:msg(msg, color)
   if color then
      if color == "green" then
         DEFAULT_CHAT_FRAME:AddMessage(msg,0,1,0);
      elseif color == "red" then
         DEFAULT_CHAT_FRAME:AddMessage(msg,1,0,0);
      elseif color == "blue" then
         DEFAULT_CHAT_FRAME:AddMessage(msg,0,0,1);
      elseif color == "yellow" then
         DEFAULT_CHAT_FRAME:AddMessage(msg,1,1,0);
      elseif color == "cyan" then
         DEFAULT_CHAT_FRAME:AddMessage(msg,0,1,1);
      elseif color == "pink" then
         DEFAULT_CHAT_FRAME:AddMessage(msg,1,0,1);
      else
         DEFAULT_CHAT_FRAME:AddMessage(msg,1,1,1);
      end
   else
      DEFAULT_CHAT_FRAME:AddMessage(msg,0.5,0.5,0.9);
   end
end

function GID:compress(data)
    if data ~= nil then
        local serialized = AceSerializer:Serialize(data)
        local compressed = LibDeflate:CompressDeflate(serialized)
        return LibDeflate:EncodeForWoWAddonChannel(compressed)
    end
end

function GID:decompress(payload)
    if payload ~= nil then
        local decoded = LibDeflate:DecodeForWoWAddonChannel(payload)
        if not decoded then return end
        local decompressed = LibDeflate:DecompressDeflate(decoded)
        if not decompressed then return end
        local success, data = AceSerializer:Deserialize(decompressed)
        if not success then return end
        return data
    end
end


function GID:Set_Contains(set, key)
   return set[key] ~= nil
end

function GID:string_split(s, delimiter)
   local result = {}
   local from  = 1
   local delim_from, delim_to = string.find(s, delimiter, from)
   while delim_from do
     table.insert( result, string.sub(s, from , delim_from-1))
     from  = delim_to + 1
     delim_from, delim_to = string.find(s, delimiter, from)
   end
   table.insert( result, string.sub(s, from))
   return result
 end