-- RP-Alpha Ambulance/EMS - Server
-- Uses rpa-lib permissions system

local OnDuty = {}

-- Get Framework via rpa-lib
local function GetPlayer(src)
    local Framework = exports['rpa-lib']:GetFramework()
    if Framework then
        return Framework.Functions.GetPlayer(src)
    end
    return nil
end

-- Helper function to check permissions
local function CheckPermission(source, permConfig)
    return exports['rpa-lib']:HasPermission(source, permConfig, 'ambulance')
end

-- Toggle Duty
RegisterNetEvent('rpa-ambulance:server:toggleDuty', function()
    local src = source
    
    -- Check if player has ambulance job
    local hasPerm, reason = CheckPermission(src, { jobs = {'ambulance', 'ems'} })
    if not hasPerm then
        exports['rpa-lib']:Notify(src, reason or "You are not EMS", "error")
        return
    end
    
    OnDuty[src] = not OnDuty[src]
    
    if OnDuty[src] then
        exports['rpa-lib']:Notify(src, "You are now on duty", "success")
        TriggerClientEvent('rpa-ambulance:client:setDuty', src, true)
    else
        exports['rpa-lib']:Notify(src, "You are now off duty", "info")
        TriggerClientEvent('rpa-ambulance:client:setDuty', src, false)
    end
end)

-- Revive a player (Called by EMS targeting a downed player)
RegisterNetEvent('rpa-ambulance:server:revivePlayer', function(targetId)
    local src = source
    
    -- Check for admin override first
    local hasOverride = CheckPermission(src, Config.ReviveOverridePermissions)
    
    -- If no override, check normal revive permissions
    if not hasOverride then
        local hasPerm, reason = CheckPermission(src, Config.RevivePermissions)
        if not hasPerm then
            exports['rpa-lib']:Notify(src, reason or "No permission to revive", "error")
            return
        end
    end
    
    local TargetPlayer = GetPlayer(targetId)
    if not TargetPlayer then
        exports['rpa-lib']:Notify(src, "Invalid target", "error")
        return
    end
    
    -- Trigger client-side revive on target
    TriggerClientEvent('rpa-ambulance:client:revive', targetId)
    exports['rpa-lib']:Notify(src, "Player revived successfully", "success")
    exports['rpa-lib']:Notify(targetId, "You have been revived by EMS", "success")
end)

-- Check in (When player respawns at hospital)
RegisterNetEvent('rpa-ambulance:server:checkIn', function()
    local src = source
    local Player = GetPlayer(src)
    
    if not Player then return end
    
    -- Charge hospital fee (configurable)
    local hospitalFee = Config.HospitalFee or 500
    local cash = Player.PlayerData.money.cash
    local bank = Player.PlayerData.money.bank
    
    if cash >= hospitalFee then
        Player.Functions.RemoveMoney('cash', hospitalFee, 'hospital-fee')
    elseif bank >= hospitalFee then
        Player.Functions.RemoveMoney('bank', hospitalFee, 'hospital-fee')
    end
    
    exports['rpa-lib']:Notify(src, "Hospital bill: $" .. hospitalFee, "info")
    TriggerClientEvent('rpa-ambulance:client:revive', src)
end)

-- Heal a player (Give bandages, medkit, etc.)
RegisterNetEvent('rpa-ambulance:server:healPlayer', function(targetId, healAmount)
    local src = source
    
    local hasPerm, reason = CheckPermission(src, Config.RevivePermissions)
    if not hasPerm then
        exports['rpa-lib']:Notify(src, reason or "No permission", "error")
        return
    end
    
    local amount = healAmount or 50
    TriggerClientEvent('rpa-ambulance:client:heal', targetId, amount)
    exports['rpa-lib']:Notify(src, "Player healed", "success")
end)

-- Admin Commands
RegisterCommand('emshire', function(source, args, rawCommand)
    local src = source
    
    local hasPerm, reason = CheckPermission(src, Config.AdminPermissions)
    if not hasPerm then
        exports['rpa-lib']:Notify(src, reason or "No permission", "error")
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        exports['rpa-lib']:Notify(src, "Usage: /emshire [playerID]", "error")
        return
    end
    
    local Framework = exports['rpa-lib']:GetFramework()
    local TargetPlayer = Framework.Functions.GetPlayer(targetId)
    if not TargetPlayer then
        exports['rpa-lib']:Notify(src, "Player not found", "error")
        return
    end
    
    TargetPlayer.Functions.SetJob('ambulance', 0)
    exports['rpa-lib']:Notify(src, "Player hired to EMS", "success")
    exports['rpa-lib']:Notify(targetId, "You have been hired to EMS", "success")
end, false)

RegisterCommand('emsfire', function(source, args, rawCommand)
    local src = source
    
    local hasPerm, reason = CheckPermission(src, Config.AdminPermissions)
    if not hasPerm then
        exports['rpa-lib']:Notify(src, reason or "No permission", "error")
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        exports['rpa-lib']:Notify(src, "Usage: /emsfire [playerID]", "error")
        return
    end
    
    local Framework = exports['rpa-lib']:GetFramework()
    local TargetPlayer = Framework.Functions.GetPlayer(targetId)
    if not TargetPlayer then
        exports['rpa-lib']:Notify(src, "Player not found", "error")
        return
    end
    
    TargetPlayer.Functions.SetJob('unemployed', 0)
    exports['rpa-lib']:Notify(src, "Player fired from EMS", "success")
    exports['rpa-lib']:Notify(targetId, "You have been fired from EMS", "error")
end, false)

-- Cleanup on player drop
AddEventHandler('playerDropped', function()
    local src = source
    OnDuty[src] = nil
end)

-- Exports for other resources
exports('IsEMS', function(src)
    return CheckPermission(src, { jobs = {'ambulance', 'ems'} })
end)

exports('IsOnDuty', function(src)
    return OnDuty[src] == true
end)
exports('IsOnDuty', IsOnDuty)
