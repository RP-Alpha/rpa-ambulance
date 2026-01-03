-- Revive Logic
RegisterNetEvent('rpa-ambulance:client:revive', function()
    local ped = PlayerPedId()
    
    -- Framework specific revive usually
    -- Here we do basic:
    local res = GetEntityCoords(ped)
    NetworkResurrectLocalPlayer(res.x, res.y, res.z, GetEntityHeading(ped), true, false)
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(ped)
    
    exports['rpa-lib']:Notify("You have been revived", "success")
end)

-- Interaction to revive someone (Target -> Server -> Client)
-- Here we simulate the receiving end
