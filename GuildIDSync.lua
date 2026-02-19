function GID:init()
   C_ChatInfo.RegisterAddonMessagePrefix(GID_PREFIX);
   GID:msg(string.format(GID_L["MSG_LOADED"], ADDON_NAME, GID_VERSION))

   SLASH_GID1, SLASH_GID2 = '/gid', '/gidsync'
   SlashCmdList["GID"] = function(msg)   -- add /gid and /gidsync to command list
      local cmd = msg:lower()
      if cmd == "show" then
         GID:showUI()
      elseif cmd == "all" then
         GID:list_all()
      elseif cmd == "own" then
         if GuildIDs ~= nil and GuildIDs[CHAR.NAME] ~= nil then
            GID:list(GuildIDs[CHAR.NAME].IDs)
         else
            GID:msg(GID_L["MSG_NO_OWN_IDS"])
         end
      elseif cmd == "clear" then
         GID:clear()
      elseif cmd == "update" then
         GID:update()
      elseif cmd == "online" then
         GID:list_online_players()
      else
         GID:msg(GID_L["MSG_CMD_LIST_TITLE"])
         GID:msg(GID_L["MSG_CMD_SHOW"])
         GID:msg(GID_L["MSG_CMD_OWN"])
         GID:msg(GID_L["MSG_CMD_ALL"])
         GID:msg(GID_L["MSG_CMD_CLEAR"])
         GID:msg(GID_L["MSG_CMD_UPDATE"])
      end
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
    end
end

function GID:onEvent(event, ...)
   if (event == "ADDON_LOADED") then
      local addonName = ...
      if addonName == ADDON_NAME then
         GID:init();
      end
   elseif (event == "CHAT_MSG_ADDON" and select(1,...) == GID_PREFIX) then
      local prefix, message, channel, sender = ...
      local data = GID:decompress(message)
      if data and data.type then
         GID:handleIncomingMessage(data, sender)
      end
   elseif (event == "PLAYER_ENTERING_WORLD") then
      GID:clean_ids()
      GID:update()
      -- Sende HELLO beim Login
      C_Timer.After(math.random(2, 5), function() GID:sendHello() end)
   end
end