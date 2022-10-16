function GID:init()
   C_ChatInfo.RegisterAddonMessagePrefix(GID_PREFIX);

   SLASH_GID1, SLASH_GID2 = '/gid', '/gidsync'
   SlashCmdList["GID"] = function(msg)   -- add /gid and /gidsync to command list
      local cmd = msg:lower()
      if cmd == "show" then
         GID:showUI()
      elseif cmd == "all" then
         GID:list_all()
      elseif cmd == "own" then
         GID:list(GuildIDs[CHAR.NAME].IDs)
      elseif cmd == "clear" then
         GID:clear()
      else
         GID:msg("No valid command entered.")
         GID:msg("/gid show | Show GUI")
         GID:msg("/gid own | List own IDs")
         GID:msg("/gid all | List all IDs")
         GID:msg("/gid clear | Clear all IDs in Database")
      end
   end

   GID:msg("msg_loaded", ADDON_NAME, GID_VERSION);
   GID:update()
end


function GID:send(data)
   -- sende Update an Addon Chat channel (nicht sichtbar)
   C_ChatInfo.SendAddonMessage(GID_PREFIX, GID:compress(data), "GUILD");
end


function GID:showUI() GID:Toggle(); end

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
      ids[instanceDifficultyName][instanceName] = {instanceReset = time() + instanceReset, instanceID = instanceID, instanceLocked = instanceLocked}
   end
   return ids
end

function GID:update()
   MYIDS = GID:builtIDs(GetNumSavedInstances());

   if GuildIDs == nil then
      GuildIDs = {[CHAR.NAME] = {Level = CHAR.LEVEL, LastUpdated = time(), IDs = MYIDS}}; -- This is the first time this addon is loaded; initialize the count to 0.
   elseif GuildIDs then
      GuildIDs[CHAR.NAME] = {LastUpdated = time(), Level = CHAR.LEVEL, IDs = MYIDS}
   end
   for key, values in pairs(GuildIDs) do
      GID:send({[key] = values})
   end
end

function GID:clear()
   GuildIDs = {}
   GID:msg("Data cleared and own ids rebuilt.")
   GID:update()
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
   if (event == "ADDON_LOADED" and select(1,...) == ADDON_NAME) then
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
   elseif (event == "PLAYER_ENTERING_WORLD" and select(1,...) == GID_PREFIX) then
      GID:update()
   end
end