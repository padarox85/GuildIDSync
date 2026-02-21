local select, ipairs, mfloor, mmax, mmin = select, pairs, math.floor, math.max, math.min

GS = GS or {};
GS.fully_loaded = false;
GS.default_options = {

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
GS.isWotLK = (interface >= 30000 and interface < 40000)
GS.isTBC = (interface >= 20000 and interface < 30000)

-- HEROICS
GS.instances = {};
if GS.isTBC then
	GS.instances["Höllenfeuerbollwerk"] = true
	GS.instances["Der Blutkessel"] = true
	GS.instances["Die Zerschmetterten Hallen"] = true
	GS.instances["Die Sklavenunterkünfte"] = true
	GS.instances["Der Tiefensumpf"] = true
	GS.instances["Die Dampfkammer"] = true
	GS.instances["Die Managruft"] = true
	GS.instances["Auchenai-Krypta"] = true
	GS.instances["Sethekkhallen"] = true
	GS.instances["Schattenlabyrinth"] = true
	GS.instances["Vorgebirge des Alten Hügellands"] = true
	GS.instances["Der Schwarze Morast"] = true
	GS.instances["Die Botanika"] = true
	GS.instances["Die Mechanar"] = true
	GS.instances["Die Arkatraz"] = true
	GS.instances["Terrasse der Magister"] = true
elseif GS.isWotLK then
	GS.instances["Burg Utgarde"] = true
	GS.instances["Turm Utgarde"] = true
	GS.instances["Der Nexus"] = true
	GS.instances["Das Oculus"] = true
	GS.instances["Azjol-Nerub"] = true
	GS.instances["Ahn'kahet: Das alte Königreich"] = true
	GS.instances["Feste Drak'Tharon"] = true
	GS.instances["Die Violette Festung"] = true
	GS.instances["Gundrak"] = true
	GS.instances["Hallen des Steins"] = true
	GS.instances["Hallen der Blitze"] = true
	GS.instances["Das Ausmerzen von Stratholme"] = true
	GS.instances["Prüfung des Champions"] = false
	GS.instances["Die Seelenschmiede"] = false
	GS.instances["Grube von Saron"] = false
	GS.instances["Hallen der Reflexion"] = false
end

-- RAIDS
GS.raids = {}
if GS.isTBC then
	GS.raids["Karazhan"] = true
	GS.raids["Zul'Aman"] = true
	GS.raids["Gruuls Unterschlupf"] = true
	GS.raids["Magtheridons Kammer"] = true
	GS.raids["Höhle des Schlangenschreins"] = true
	GS.raids["Festung der Stürme"] = true
	GS.raids["Hyjal"] = true
	GS.raids["Der Schwarze Tempel"] = true
	GS.raids["Sonnenbrunnenplateau"] = true
elseif GS.isWotLK then
	GS.raids["Archavons Kammer"] = true
	GS.raids["Das Obsidiansanktum"] = true
	GS.raids["Naxxramas"] = true
	GS.raids["Das Auge der Ewigkeit"] = true
	GS.raids["Ulduar"] = false
	GS.raids["Prüfung des Kreuzfahrers"] = false
	GS.raids["Eiskronenzitadelle"] = false
	GS.raids["Das Rubinsanktum"] = false
end

-- PVP QUESTS
GS.pvpQuests = {
	{ name = GS_L["PVP_BG_DAILY"], ids = { 
		-- TBC
		11335, 11336, 11337, 11338, 11339, 11340, 11341, 11342, 11499, 11500,
		-- WotLK (Call to Arms)
		11335, 11336, 11337, 11338, 11339, 11340, 11341, 11342, 11499, 11500, -- Repeat IDs from TBC often used
		13442, 13443, 13444, 13445, 13446, 13447, 13448, 13449, 13450, -- Newer WotLK IDs
	} },
	{ name = GS_L["PVP_HELLFIRE"], ids = { 10110, 10106 } }, -- Hellfire Fortifications (H/A)
	{ name = GS_L["PVP_TEROKKAR"], ids = { 11505, 11506 } }, -- Spirits of Auchindoun (A/H)
	{ name = GS_L["PVP_NAGRAND"], ids = { 11503, 11502 } }, -- Halaa (A/H)
}

-- Add WotLK specific PvP quests
if GS.isWotLK then
	table.insert(GS.pvpQuests, { name = GS_L["PVP_WINTERGRASP"], ids = { 13177, 13178, 13179, 13180, 13181, 13222, 13223 } })
end

function GS:MenuListItems(Items, difficulty)
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
			GS:ShowPlayerData(difficulty, instance_name)
		end)
	end
end

function GS:msg(msg, color)
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

function GS:compress(data)
    if data ~= nil then
        local serialized = AceSerializer:Serialize(data)
        local compressed = LibDeflate:CompressDeflate(serialized)
        return LibDeflate:EncodeForWoWAddonChannel(compressed)
    end
end

function GS:decompress(payload)
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


function GS:Set_Contains(set, key)
   return set[key] ~= nil
end

function GS:string_split(s, delimiter)
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
