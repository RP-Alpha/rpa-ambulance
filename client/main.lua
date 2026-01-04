local isOnDuty = false
local isDead = false
local deathTime = 0

-- Duty state sync
RegisterNetEvent('rpa-ambulance:client:setDuty', function(state)
    isOnDuty = state
end)

-- Revive Logic
RegisterNetEvent('rpa-ambulance:client:revive', function()
    local ped = PlayerPedId()
    
    -- Framework specific revive usually
    -- Here we do basic:
    local res = GetEntityCoords(ped)
    NetworkResurrectLocalPlayer(res.x, res.y, res.z, GetEntityHeading(ped), true, false)
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(ped)
    SetPlayerInvincible(PlayerId(), false)
    
    isDead = false
    deathTime = 0
    
    exports['rpa-lib']:Notify("You have been revived", "success")
end)

-- Heal (partial health restore)
RegisterNetEvent('rpa-ambulance:client:heal', function(amount)
    local ped = PlayerPedId()
    local currentHealth = GetEntityHealth(ped)
    local maxHealth = GetEntityMaxHealth(ped)
    local newHealth = math.min(currentHealth + (amount or 50), maxHealth)
    SetEntityHealth(ped, newHealth)
    exports['rpa-lib']:Notify("You have been healed", "success")
end)

-- Setup Interactions
CreateThread(function()
    for k, v in pairs(Config.Stations) do
        -- Locker for duty toggle
        if v.locker then
            exports['rpa-lib']:AddTargetZone('ems_locker_' .. k, v.locker, vector3(1, 1, 2), {
                options = {
                    {
                        label = "Toggle Duty",
                        icon = "fas fa-tshirt",
                        action = function()
                            TriggerServerEvent('rpa-ambulance:server:toggleDuty')
                        end
                    }
                }
            }, false)
        end
        
        -- Hospital Check-in (for downed players)
        if v.checkin then
            exports['rpa-lib']:AddTargetZone('ems_checkin_' .. k, v.checkin, vector3(2, 2, 2), {
                options = {
                    {
                        label = "Check In (Respawn)",
                        icon = "fas fa-hospital",
                        action = function()
                            if isDead and (GetGameTimer() - deathTime) > (Config.RespawnTime * 1000) then
                                TriggerServerEvent('rpa-ambulance:server:checkIn')
                            elseif isDead then
                                local remaining = math.ceil(((Config.RespawnTime * 1000) - (GetGameTimer() - deathTime)) / 1000)
                                exports['rpa-lib']:Notify("You must wait " .. remaining .. " more seconds", "error")
                            end
                        end
                    }
                }
            }, false)
        end
    end
end)

-- Target interaction to revive downed players (for EMS)
CreateThread(function()
    exports['rpa-lib']:AddGlobalVehicle({}) -- Needed to init target?
    
    -- Add target on players (model targeting for peds doesn't work well for players)
    -- This is a simplified approach - real implementation would use player targeting
end)

-- Command for EMS to revive closest player
RegisterCommand('revive', function()
    if not isOnDuty then
        exports['rpa-lib']:Notify("You must be on duty", "error")
        return
    end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closestPlayer, closestDistance = nil, 3.0
    
    -- Find closest player
    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(coords - targetCoords)
            
            if distance < closestDistance then
                closestPlayer = GetPlayerServerId(playerId)
                closestDistance = distance
            end
        end
    end
    
    if closestPlayer then
        -- Play revive animation
        RequestAnimDict("mini@cpr@char_a@cpr_str")
        while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do Wait(10) end
        TaskPlayAnim(ped, "mini@cpr@char_a@cpr_str", "cpr_pumpchest", 8.0, -8.0, 10000, 0, 0, false, false, false)
        
        exports['rpa-lib']:Notify("Reviving player...", "info")
        Wait(10000)
        
        ClearPedTasks(ped)
        TriggerServerEvent('rpa-ambulance:server:revivePlayer', closestPlayer)
    else
        exports['rpa-lib']:Notify("No player nearby", "error")
    end
end, false)
