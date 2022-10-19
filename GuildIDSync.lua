function GID:init()
   C_ChatInfo.RegisterAddonMessagePrefix(GID_PREFIX);
   GID:msg("GuildIDSync loaded...")

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
            GID:msg("You have no IDs right now.")
         end
      elseif cmd == "clear" then
         GID:clear()
      elseif cmd == "update" then
         GID:update()
      elseif cmd == "online" then
         GID:list_online_players()
      else
         GID:msg("No valid command entered.")
         GID:msg("/gid show | Show GUI")
         GID:msg("/gid own | List own IDs")
         GID:msg("/gid all | List all IDs")
         GID:msg("/gid clear | Clear all IDs in Database")
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
      if ids[instanceDifficultyName] == nil then
         ids[instanceDifficultyName] = {}
      end
      ids[instanceDifficultyName][instanceName] = {instanceReset = GetServerTime() + instanceReset, instanceID = instanceID, instanceLocked = instanceLocked}
   end
   return ids
end

function GID:update()
   MYIDS = GID:builtIDs(GetNumSavedInstances());
   if GID:getTime() ~= nil then
      if GuildIDs == nil then
         GuildIDs = {[CHAR.NAME] = {Level = CHAR.LEVEL, LastUpdated = GetServerTime(), IDs = MYIDS}};
      elseif GuildIDs then
         GuildIDs[CHAR.NAME] = {LastUpdated = GID:getTime(), Level = CHAR.LEVEL, IDs = MYIDS}
      end
      GID:msg("Updated Profile for "..GetNumSavedInstances().." IDs")
      if LAST_UPDATE == nil or LAST_UPDATE < GID:getTime() - 300 then
         GID:send_all()
         LAST_UPDATE = GID:getTime()
      end
   else
      GID:msg("You cannot update your profile in an instance/raid.")
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
      local char_name = GID:string_split(name, "-")[1]
      if online then
         online_players[char_name] = true
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
   GID:msg("Data cleared.")
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
   GID:msg("Deine aktuell gesperrten IDs:")
   for difficulty, instances in pairs(data) do
      GID:msg(difficulty .. ":", "cyan")
      for instanceName, instanceDetails in pairs(instances) do
         GID:msg("- " .. instanceName .. ":", "yellow")
         for key, value in pairs(instanceDetails) do
            if key == "instanceReset" then
               GID:msg("- - Reset: "..date("%d.%m.%y %H:%M", value))
            else
               GID:msg("- - "..key..": "..tostring(value))
            end
         end
      end
   end
end

function GID:list_all()
   GID:msg("Folgende IDs sind aktuell vorhanden:")
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
                           GID:msg("- - Reset: "..date("%d.%m.%y %H:%M", value))
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

function GID:onEvent(event, ...)
   if (event == "ADDON_LOADED") then
      GID:init();
   elseif (event == "CHAT_MSG_ADDON" and select(1,...) == GID_PREFIX) then
      local args = {...};
      for key, value in pairs(args) do
         if key == 2 then
            for player_name, player_data in pairs(GID:decompress(value)) do
               if GuildIDs[player_name] ~= nil then
                  if player_data.LastUpdated > GuildIDs[player_name].LastUpdated then
                     GuildIDs[player_name] = player_data
                  end
               else
                  GuildIDs[player_name] = player_data
               end
            end
         end
      end
   elseif (event == "PLAYER_ENTERING_WORLD") then
      GID:clean_ids()
      GID:update()
   end
end