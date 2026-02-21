StaticPopupDialogs["GUILDSYNC_CONFIRM_LAYER_INVITE"] = {
    text = GID_L["UI_LAYER_INVITE_CONFIRM_TEXT"],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function(self, data)
        if C_PartyInfo and C_PartyInfo.InviteUnit then
            C_PartyInfo.InviteUnit(data)
        else
            InviteUnit(data)
        end
    end,
    timeout = 30,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function GID:init()
   C_ChatInfo.RegisterAddonMessagePrefix(GID_PREFIX);
   GID:msg(string.format(GID_L["MSG_LOADED"], ADDON_NAME, GID_VERSION))

   SLASH_GS1 = '/gs'
   SlashCmdList["GS"] = function(msg)
      GID:Toggle()
   end
end


function GID:send(data)
   -- sende Update an Addon Chat channel (nicht sichtbar)
   C_ChatInfo.SendAddonMessage(GID_PREFIX, GID:compress(data), "GUILD");
end


function GID:showUI() GID:Toggle(); end

function GID:getTime()
   local inInstance, instanceType = IsInInstance()
   if not inInstance then
      return GetServerTime()
   else
      return nil
   end
end

function GID:Toggle()
   if MainFrame:IsVisible() then
      MainFrame:Hide()
   else
      MainFrame:Show()
   end
end

-- build the users id Table
function GID:builtIDs(myInstances)
   local ids = {}
   for instanceID=1, myInstances, 1
   do
      local instanceName, instanceID, instanceReset, instanceDifficulty, instanceLocked, instanceExtended, instanceIDMostSig, instanceIsRaid, instanceMaxPlayers, instanceDifficultyName, instanceNumEncounters, instanceEncounterProgress, instanceExtendDisabled = GetSavedInstanceInfo(instanceID)
      -- TBC Anniversary 2.5.5 Fix: Falls instanceDifficultyName leer ist (kommt vor), setzen wir einen Standardwert
      if not instanceDifficultyName or instanceDifficultyName == "" then
          if instanceIsRaid then
              instanceDifficultyName = "Raid"
          else
              instanceDifficultyName = "Dungeon"
          end
      end
      if ids[instanceDifficultyName] == nil then
         ids[instanceDifficultyName] = {}
      end
      ids[instanceDifficultyName][instanceName] = {instanceReset = GetServerTime() + instanceReset, instanceID = instanceID, instanceLocked = instanceLocked}
   end
   return ids
   end

   function GID:InitLayerScan()
       GID.detectedLayers = GID_DetectedLayers
       GID.lastKnownLayerID = nil
       
       -- Wir nutzen denselben Frame GID, um Events zentral in onEvent zu verarbeiten.
       -- Der extra Frame hier ist nicht nötig und könnte zu Konflikten führen,
       -- da er dieselben Events wie der Hauptframe registriert.
   end

   local function ParseAndRecordLayerFromGUID(guid, isPassive)
       if not guid then return false end
       local parts = { strsplit("-", guid) }
       local unitType = parts[1]
       local instanceID = parts[4]
       if unitType ~= "Creature" or not instanceID then return false end
       local instID = tonumber(instanceID)
       if instID == nil then return false end

       local mapID = C_Map.GetBestMapForUnit("player")
       if not mapID then return false end

       local changed = false
       if GID.lastKnownLayerID ~= instID then
           -- Only update lastKnownLayerID passively if we already had a layer.
           -- This satisfies the user's request to show "unknown" at the start
           -- until they manually target or mouseover an NPC.
           if not isPassive or GID.lastKnownLayerID ~= nil then
               GID.lastKnownLayerID = instID
               changed = true
           end
           
           -- Ensure table for current map exists
           GID.detectedLayers[mapID] = GID.detectedLayers[mapID] or {}
           
           -- neue ID ggf. in die bekannte Liste aufnehmen (Mapping immer aktualisieren)
           local found = false
           for _, id in ipairs(GID.detectedLayers[mapID]) do
               if id == instID then
                   found = true
                   break
               end
           end
           if not found then
               table.insert(GID.detectedLayers[mapID], instID)
               table.sort(GID.detectedLayers[mapID])
               
               -- Share discovery with guild so everyone has same layer mapping
               GID:send({type = "LAYER_MAP_UPDATE", mapID = mapID, layerID = instID})
               changed = true
           end
           
           -- UI live aktualisieren, falls sichtbar und etwas sich geändert hat
           if changed and MainFrame and MainFrame:IsVisible() and GID.currentTab == 2 then
               GID:UpdateLayerTable()
           end
           return true
       end
       return false
   end

   function GID:ScanLayer(event, unit)
       local targetUnit = unit or "mouseover"
       if event == "PLAYER_TARGET_CHANGED" then targetUnit = "target" end
       local guid = UnitGUID(targetUnit)
       ParseAndRecordLayerFromGUID(guid, false) -- active scan
   end

   function GID:GetLayer()
       -- 0. Check NovaWorldBuffs integration if available
       if _G.NWB_CurrentLayer and _G.NWB_CurrentLayer > 0 then
           return tostring(_G.NWB_CurrentLayer)
       end
       if _G.NWB and _G.NWB.currentLayer and _G.NWB.currentLayer > 0 then
           return tostring(_G.NWB.currentLayer)
       end

       -- 1. Unsere eigene NPC-basierte Heuristik (NPCs in der Zone scannen)
       if GID.lastKnownLayerID ~= nil then
           local mapID = C_Map.GetBestMapForUnit("player")
           if mapID and GID.detectedLayers[mapID] then
               for i, id in ipairs(GID.detectedLayers[mapID]) do
                   if id == GID.lastKnownLayerID then
                       return tostring(i)
                   end
               end
           end
       end

       -- 2. Wenn wir keinen präzisen Layer haben, geben wir nil zurück.
       return nil
   end

   function GID:builtPvPQuests()
   local quests = {}
   for _, pvpQuest in ipairs(GID.pvpQuests) do
      local completed = false
      for _, questID in ipairs(pvpQuest.ids) do
         if C_QuestLog.IsQuestFlaggedCompleted(questID) then
            completed = true
            break
         end
      end
      quests[pvpQuest.name] = { completed = completed }
   end
   return quests
end

function GID:update()
   MYIDS = GID:builtIDs(GetNumSavedInstances());
   MYPVP = GID:builtPvPQuests();
   if GID:getTime() ~= nil then
      if GuildIDs == nil then
         GuildIDs = {[CHAR.NAME] = {Level = CHAR.LEVEL, LastUpdated = GetServerTime(), IDs = MYIDS, PvP = MYPVP, rev = 1}};
      elseif GuildIDs then
         local currentRev = (GuildIDs[CHAR.NAME] and GuildIDs[CHAR.NAME].rev) or 0
         GuildIDs[CHAR.NAME] = {LastUpdated = GID:getTime(), Level = CHAR.LEVEL, IDs = MYIDS, PvP = MYPVP, rev = currentRev + 1}
      end
      GID:msg(string.format(GID_L["MSG_PROFILE_UPDATED"], GetNumSavedInstances(), GuildIDs[CHAR.NAME].rev))
      
      -- Nach dem Update schicken wir Manifeste für unsere eigenen Buckets
      local myBucket = GID:getBucket(CHAR.NAME)
      C_Timer.After(math.random(1, 5), function() GID:sendManifest(myBucket) end)
   else
      GID:msg(GID_L["MSG_CANNOT_UPDATE_IN_INSTANCE"])
   end
end

function GID:list_online_players()
   for name, _ in pairs(GID:get_online_players()) do
      GID:msg(name)
   end
end

function GID:send_all()
   for key, values in pairs(GuildIDs) do
      if not GID:check_player_is_online(key) then
         GID:send({[key] = values})
      end
   end
end

function GID:get_online_players()
   local online_players = {}
   GuildRoster();
   local numTotalMembers, numOnlineMaxLevelMembers, numOnlineMembers = GetNumGuildMembers();
   for player_index=1, numTotalMembers, 1 do
      local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, isSoREligible, standingID = GetGuildRosterInfo(player_index);
      -- TBC Anniversary Compatibility: Falls GetGuildRosterInfo weniger Argumente zurückgibt (vor MoP gab es keine AchievementPoints etc.)
      -- Die wichtigsten Felder (name, online) sind aber immer an den ersten Stellen.
      if name then
         local char_name = GID:string_split(name, "-")[1]
         if online then
            online_players[char_name] = true
         end
      end
   end
   return online_players
end

function GID:check_player_is_online(player_name)
   if GID:Set_Contains(GID:get_online_players(), player_name) then
      return true
   end
   return false
end

function GID:clear()
   GuildIDs = nil
   GID:msg(GID_L["MSG_DATA_CLEARED"])
end

function GID:clean_ids()
   if GuildIDs ~= nil then
      local new_GuildIDs = {}
      for player_name, player_data in pairs(GuildIDs) do
         if GID:check_valid_difficulty_for_player(player_name, "ALL") then
            local new_player_data = {}
            for data_key, data_value in pairs(player_data) do
               if data_key == "LastUpdated" then
                  new_player_data[data_key] = data_value
               elseif data_key == "IDs" then
                  local new_difficulty = {}
                  for difficulty, instances in pairs(data_value) do
                     if GID:check_valid_difficulty_for_player(player_name, difficulty) then
                        local new_instances = {}
                        for instanceName, instanceDetails in pairs(instances) do
                           if instanceDetails.instanceReset > GID:getTime() then
                              new_instances[instanceName] = instanceDetails
                           end
                        end
                        new_difficulty[difficulty] = new_instances
                     end
                  end
                  new_player_data[data_key] = new_difficulty
               end
            end
            new_GuildIDs[player_name] = new_player_data
         end
      end
      GuildIDs = new_GuildIDs
   end
end

function GID:check_valid_difficulty_for_player(player_name, instance_difficulty)
   local has_valid_difficulty = false
   if GuildIDs ~= nil then
      for difficulty, instances in pairs(GuildIDs[player_name].IDs) do
         if difficulty == instance_difficulty or difficulty == 'ALL' then
            for _, instance_details in pairs(instances) do
               if instance_details.instanceReset > GID:getTime() then
                  has_valid_difficulty = true
               end
            end
         end
      end
   end
   return has_valid_difficulty
end

function GID:list(data)
-- print the users id Table into chat
   GID:msg(GID_L["MSG_OWN_IDS_TITLE"])
   for difficulty, instances in pairs(data) do
      GID:msg(difficulty .. ":", "cyan")
      for instanceName, instanceDetails in pairs(instances) do
         GID:msg("- " .. instanceName .. ":", "yellow")
         for key, value in pairs(instanceDetails) do
            if key == "instanceReset" then
               GID:msg("- - " .. string.format(GID_L["MSG_RESET"], date("%d.%m.%y %H:%M", value)))
            else
               GID:msg("- - "..key..": "..tostring(value))
            end
         end
      end
   end
end

function GID:list_all()
   GID:msg(GID_L["MSG_ALL_IDS_TITLE"])
   -- print the users id Table into chat
      for player_name, player_data in pairs(GuildIDs) do
         GID:msg(player_name..":", "red")
         for data_key, data_value in pairs(player_data) do
            if data_key == "LastUpdated" then
               GID:msg("Last Update: "..date("%d.%m.%y %H:%M",data_value).. ":", "green")
            elseif data_key == "IDs" then
               for difficulty, instances in pairs(data_value) do
                  GID:msg(difficulty .. ":", "cyan")
                  for instanceName, instanceDetails in pairs(instances) do
                     GID:msg("- " .. instanceName .. ":", "yellow")
                     for key, value in pairs(instanceDetails) do
                        if key == "instanceReset" then
                           GID:msg("- - " .. string.format(GID_L["MSG_RESET"], date("%d.%m.%y %H:%M", value)))
                        else
                           GID:msg("- - "..key..": "..tostring(value))
                        end
                     end
                  end
               end
            end
         end
      end
   end

-- ============================================================================
-- Gossip / Manifest Implementation
-- ============================================================================

local MANIFEST_BUCKETS = 8

function GID:getBucket(name)
    local hash = 0
    for i = 1, #name do
        hash = (hash * 31 + string.byte(name, i)) % 2^31
    end
    return (hash % MANIFEST_BUCKETS) + 1
end

function GID:sendHello()
    GID:send({type = "HELLO", version = GID_VERSION})
end

function GID:sendManifest(bucket)
    local entries = {}
    for name, data in pairs(GuildIDs) do
        if GID:getBucket(name) == bucket then
            entries[name] = data.rev
        end
    end
    GID:send({type = "MANIFEST", bucket = bucket, entries = entries})
end

function GID:handleIncomingMessage(data, sender)
    if not data or not data.type then return end
    
    local senderName = GID:string_split(sender, "-")[1]
    if senderName == CHAR.NAME then return end

    if data.type == "HELLO" then
        -- Wenn jemand online kommt, schicken wir ihm (verzögert) Manifeste für unsere Buckets
        for b = 1, MANIFEST_BUCKETS do
            C_Timer.After(math.random(5, 30) + (b * 2), function()
                GID:sendManifest(b)
            end)
        end
    
    elseif data.type == "MANIFEST" then
        local needed = {}
        for name, remoteRev in pairs(data.entries) do
            local localData = GuildIDs[name]
            if not localData or remoteRev > (localData.rev or 0) then
                table.insert(needed, name)
            end
        end
        
        if #needed > 0 then
            -- Deterministisches Peer-Picking: Um zu verhindern, dass 10 Leute gleichzeitig 
            -- denselben Record anfordern, wenn sie das Manifest sehen, könnten wir hier 
            -- noch Logik einbauen. Aber da wir nur den anfragen, der das Manifest geschickt hat,
            -- und Manifeste zeitlich versetzt gesendet werden, ist das Risiko gering.
            
            -- Wir drosseln die Requests: Maximal 5 Spieler pro Request
            for i = 1, #needed, 5 do
                local batch = {}
                for j = i, math.min(i + 4, #needed) do
                    table.insert(batch, needed[j])
                end
                C_Timer.After((i-1)/5 * 2, function()
                    GID:send({type = "REQUEST", players = batch, bucket = data.bucket})
                end)
            end
        end

    elseif data.type == "REQUEST" then
        -- Jemand will Daten von uns
        local count = 0
        for _, name in ipairs(data.players) do
            local localData = GuildIDs[name]
            if localData then
                -- Sende RECORD für diesen Spieler
                -- Verzögert, um Burst zu vermeiden
                count = count + 1
                C_Timer.After(math.random(0.1, 2) + (count * 0.2), function()
                    GID:send({
                        type = "RECORD",
                        name = name,
                        data = localData
                    })
                end)
            end
        end

    elseif data.type == "RECORD" then
        -- Wir empfangen einen Record
        local name = data.name
        local remoteData = data.data
        if not GuildIDs[name] or (remoteData.rev or 0) > (GuildIDs[name].rev or 0) then
            GuildIDs[name] = remoteData
            -- GID:msg("Received updated record for " .. name .. " (Rev: " .. (remoteData.rev or 0) .. ")")
        end
    elseif data.type == "LAYER_QUERY" then
        GID:send({
            type = "LAYER_RESPONSE",
            name = CHAR.NAME,
            level = UnitLevel("player"),
            zone = GetRealZoneText(),
            layer = GID:GetLayer(),
            inGroup = IsInGroup()
        })
    elseif data.type == "LAYER_RESPONSE" then
        if not GID.LayerData then GID.LayerData = {} end
        GID.LayerData[data.name] = {
            level = data.level,
            zone = data.zone,
            layer = data.layer,
            inGroup = data.inGroup,
            time = GetTime()
        }
        if MainFrame:IsVisible() and GID.currentTab == 2 then
            GID:UpdateLayerTable()
        end
    elseif data.type == "LAYER_INVITE_REQUEST" then
        if data.target == CHAR.NAME and not IsInGroup() then
            -- Check if auto-accept is enabled in settings
            if GuildSyncDB.settings and GuildSyncDB.settings.autoAcceptLayerInvite then
                if C_PartyInfo and C_PartyInfo.InviteUnit then
                    C_PartyInfo.InviteUnit(sender)
                else
                    InviteUnit(sender)
                end
            else
                -- We are the target, we ask for confirmation before inviting the sender
                StaticPopup_Show("GUILDSYNC_CONFIRM_LAYER_INVITE", sender, nil, sender)
            end
        end
    elseif data.type == "LAYER_INVITE_ACK" then
        -- The sender of the request acknowledged that they sent an invite (if we were the target)
        -- Or in this case: The requester sent a message, and we (the target) invited them.
        -- Actually, we need to track on the REQUESTER side.
        -- Let's re-think the flow.
        -- 1. Player A clicks "Invite" on Player B in the list.
        -- 2. Player A sends LAYER_INVITE_REQUEST { target = B }
        -- 3. Player B receives it, checks if target is self and not in group.
        -- 4. Player B invites Player A.
        -- 5. Player A receives PARTY_INVITE_REQUEST from Player B.
        -- 6. Player A should auto-accept.
    elseif data.type == "LAYER_MAP_UPDATE" then
        local mID = data.mapID
        local lID = data.layerID
        if mID and lID then
            GID.detectedLayers[mID] = GID.detectedLayers[mID] or {}
            local found = false
            for _, id in ipairs(GID.detectedLayers[mID]) do
                if id == lID then found = true break end
            end
            if not found then
                table.insert(GID.detectedLayers[mID], lID)
                table.sort(GID.detectedLayers[mID])
            end
        end
    end
end

function GID:mergeRecords(payload, sender)
    GuildIDs = GuildIDs or {}
    for name, record in pairs(payload) do
        if type(name) == "string" and type(record) == "table" then
            local localRev = (GuildIDs[name] and GuildIDs[name].rev) or 0
            local remoteRev = (record.rev) or 0
            if not GuildIDs[name] or remoteRev >= localRev then
                if not record.rev then record.rev = 1 end
                GuildIDs[name] = record
            end
        end
    end
end

function GID:onEvent(event, ...)
   if (event == "ADDON_LOADED") then
      local addonName = ...
      if addonName == ADDON_NAME then
         GuildIDs = GuildIDs or {}
         GID_DetectedLayers = GID_DetectedLayers or {}
         GID:init();
         GID:InitMinimap();
         GID:InitLayerScan();
      end
   elseif (event == "CHAT_MSG_ADDON" and select(1,...) == GID_PREFIX) then
      local prefix, message, channel, sender = ...
      local data = GID:decompress(message)
      if type(data) == "table" then
         if data.type then
            GID:handleIncomingMessage(data, sender)
         else
            -- Legacy/Bulk payload without explicit type: treat as { [playerName] = record, ... }
            GID:mergeRecords(data, sender)
         end
      end
   elseif (event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA") then
      GID.lastKnownLayerID = nil
      GID:clean_ids()
      if event == "PLAYER_ENTERING_WORLD" then
          GID:update()
          C_Timer.After(math.random(2, 5), function() GID:sendHello() end)
      end
   elseif (event == "UPDATE_INSTANCE_INFO" or event == "QUEST_TURNED_IN") then
      GID:update()
   elseif (event == "UPDATE_MOUSEOVER_UNIT" or event == "PLAYER_TARGET_CHANGED" or event == "UNIT_TARGET") then
      GID:ScanLayer(event)
   elseif (event == "NAME_PLATE_UNIT_ADDED") then
      local unit = ...
      if unit then
         local guid = UnitGUID(unit)
         if guid then ParseAndRecordLayerFromGUID(guid, true) end
      end
   elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
      local _, subEvent, _, sourceGUID, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
      if sourceGUID then ParseAndRecordLayerFromGUID(sourceGUID, true) end
      if destGUID then ParseAndRecordLayerFromGUID(destGUID, true) end
   elseif (event == "PARTY_INVITE_REQUEST") then
      local sender = ...
      if GID.ExpectedInviteSender and (sender == GID.ExpectedInviteSender or GID:string_split(sender, "-")[1] == GID.ExpectedInviteSender) then
         -- Check if still within timeout (e.g. 30 seconds)
         if GetTime() - (GID.ExpectedInviteTime or 0) < 30 then
            AcceptGroup()
            -- Hide the invite popup
            StaticPopup_Hide("PARTY_INVITE")
            GID:msg(string.format(GID_L["MSG_AUTO_ACCEPTED_INVITE"], sender), "green")
         end
         GID.ExpectedInviteSender = nil
         GID.ExpectedInviteTime = nil
      end
   end
end