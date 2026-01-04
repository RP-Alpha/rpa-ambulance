local OnDuty = {}

-- Get Framework via rpa-lib
local function GetPlayer(src)
    local Framework = exports['rpa-lib']:GetFramework()
    if Framework then
        return Framework.Functions.GetPlayer(src)
    end
    return nil
end

-- Check if player is EMS
local function IsEMS(src)
    local Player = GetPlayer(src)
    if not Player then return false end
    
    local job = Player.PlayerData.job
    return job.name == 'ambulance' or job.name == 'ems'
end

-- Check if player is on duty
local function IsOnDuty(src)
    return OnDuty[src] == true
end

-- Toggle Duty
RegisterNetEvent('rpa-ambulance:server:toggleDuty', function()
    local src = source
    
    if not IsEMS(src) then
        exports['rpa-lib']:Notify(src, "You are not EMS", "error")
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
    
    if not IsEMS(src) then
        exports['rpa-lib']:Notify(src, "You are not EMS", "error")
        return
    end
    
    if not IsOnDuty(src) then
        exports['rpa-lib']:Notify(src, "You must be on duty to revive players", "error")
        return
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
    
    if not IsEMS(src) then
        exports['rpa-lib']:Notify(src, "You are not EMS", "error")
        return
    end
    
    if not IsOnDuty(src) then
        exports['rpa-lib']:Notify(src, "You must be on duty", "error")
        return
    end
    
    local amount = healAmount or 50
    TriggerClientEvent('rpa-ambulance:client:heal', targetId, amount)
    exports['rpa-lib']:Notify(src, "Player healed", "success")
end)

-- Cleanup on player drop
AddEventHandler('playerDropped', function()
    local src = source
    OnDuty[src] = nil
end)

-- Exports
exports('IsEMS', IsEMS)
exports('IsOnDuty', IsOnDuty)
