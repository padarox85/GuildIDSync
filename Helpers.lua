local select, ipairs, mfloor, mmax, mmin = select, pairs, math.floor, math.max, math.min

GID = {};
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

-- HEROICS
GID.instances = {};
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
-- RAIDS
GID.raids = {}
GID.raids["Archavons Kammer"] = true
GID.raids["Das Obsidiansanktum"] = true
GID.raids["Naxxramas"] = true
GID.raids["Das Auge der Ewigkeit"] = true
GID.raids["Ulduar"] = false
GID.raids["Prüfung des Kreuzfahrers"] = false
GID.raids["Eiskronenzitadelle"] = false
GID.raids["Das Rubinsanktum"] = false

function GID:MenuListItems(Items, difficulty)
	local i = 0
	for instance_name, active in pairs(Items) do
		local cb = CreateFrame("Button", "InstanceCheckBox"..i, LeftMenu,"OptionsListButtonTemplate")
		local text = cb:CreateFontString(cb, "ARTWORK", "GameFontNormal")
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
        local serialized = LibSerialize:Serialize(data)
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
        local success, data = LibSerialize:Deserialize(decompressed)
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