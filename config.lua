Config = {}

--[[
    ==========================================
    PERMISSIONS
    ==========================================
    
    You can grant permissions via:
    1. QB-Core/QBOX groups (admin, mod, etc.)
    2. Server.cfg ConVars with player identifiers
    
    server.cfg examples:
    setr rpa_ambulance:admin "steam:110000123456789,license:abc123"
    setr rpa_ambulance:revive_anyone "steam:110000987654321"
]]

-- Who can use EMS admin commands (hire, fire, manage ranks)
Config.AdminPermissions = {
    groups = {'admin', 'god'},
    jobs = {'ambulance'},
    minGrade = 4,
    resourceConvar = 'admin'
}

-- Who can revive players (normal EMS function)
Config.RevivePermissions = {
    jobs = {'ambulance'},
    minGrade = 0,
    onDuty = true
}

-- Who can revive anyone regardless of timer (admin override)
Config.ReviveOverridePermissions = {
    groups = {'admin', 'god'},
    resourceConvar = 'revive_anyone'
}

-- Who can access EMS vehicles
Config.VehiclePermissions = {
    jobs = {'ambulance'},
    minGrade = 0,
    onDuty = true
}

Config.HospitalFee = 500 -- Fee charged when checking into hospital

Config.RespawnTime = 300 -- Seconds before player can respawn at hospital (5 minutes)

Config.Stations = {
    ['pillbox'] = {
        label = "Pillbox Hill MC",
        coords = vector3(291.2, -581.6, 43.1),
        locker = vector3(309.8, -594.0, 43.3),
        garage = vector4(295.3, -584.7, 43.1, 340.0),
        checkin = vector3(307.8, -596.0, 43.3),
    }
}

Config.Vehicles = {
    ['ambulance'] = { label = 'Ambulance', rank = 0 },
    ['emssuv'] = { label = 'EMS SUV', rank = 1 },
}
