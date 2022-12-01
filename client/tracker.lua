RegisterNetEvent('police:client:CheckDistance', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent("police:server:SetTracker", playerId)
    else
        QBCore.Functions.Notify(Lang:t("error.none_nearby"), "error")
    end
end)

RegisterNetEvent('police:client:removeankletciv', function()               --Ankle bracelet civ removal 
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then                          --- Checking distance bewteen remover and removee. Anything more than 2.5 ig meters will not triggers
        local playerId = GetPlayerServerId(player)
		QBCore.Functions.Progressbar("removeanklet", 'Removing anklet bracelet', math.random(18000, 30000), false, true, {        ---Random amount of time , So its not exact . Dont want players getting to know the time exact 
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = true,   --optional , Locks the user so they cannot look around when removing bracelet
                disableCombat = true,
				TriggerEvent('animations:client:EmoteCommandStart', {"mechanic3"})    -- starts emote : Dp emotes should work  mechanic3 used for the lean dow
				--[place your alert for pd here , if you want them to be alerted when theres an attempt in progress]
            }, {}, {}, {}, function() -- Done
                TriggerServerEvent("police:server:SetTracker", playerId)   -- using the qb police job to remove tracker skips job check on success
				exports['ps-dispatch']:anklet()
				TriggerServerEvent('police:Server:Addbracelet', 'broken_tag', 10)
				TriggerServerEvent('police:Server:Removebracelet', 'cutter', 1)
				TriggerEvent('animations:client:EmoteCommandStart', {"c"})   -- cancels the emote that is playing to stop the player being stuck in anim
                QBCore.Functions.Notify("Tracker removed", "success")
            end, function() -- Cancel
                QBCore.Functions.Notify("Tracker Removal Cancelled", "error")
				TriggerEvent('animations:client:EmoteCommandStart', {"c"})  -- cancels the emote on playing
				exports['ps-dispatch']:anklet()
            end)
    else
        QBCore.Functions.Notify(Lang:t("error.none_nearby"), "error")
    end
end)

RegisterNetEvent('police:client:SetTracker', function(bool)
    local trackerClothingData = {
        outfitData = {
            ["accessory"]   = { item = -1, texture = 0},  -- Nek / Das
        }
    }

    if bool then
        trackerClothingData.outfitData = {
            ["accessory"] = { item = 13, texture = 0}
        }

        TriggerEvent('qb-clothing:client:loadOutfit', trackerClothingData)
    else
        TriggerEvent('qb-clothing:client:loadOutfit', trackerClothingData)
    end
end)



RegisterNetEvent('police:client:SendTrackerLocation', function(requestId)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    TriggerServerEvent('police:server:SendTrackerLocation', coords, requestId)
end)

RegisterNetEvent('police:client:TrackerMessage', function(msg, coords)
    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
    QBCore.Functions.Notify(msg, 'police')
    local transG = 250
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 458)
    SetBlipColour(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipAlpha(blip, transG)
    SetBlipScale(blip, 1.0)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Lang:t('info.ankle_location'))
    EndTextCommandSetBlipName(blip)
    while transG ~= 0 do
        Wait(180 * 4)
        transG = transG - 1
        SetBlipAlpha(blip, transG)
        if transG == 0 then
            SetBlipSprite(blip, 2)
            RemoveBlip(blip)
            return
        end
    end
end)