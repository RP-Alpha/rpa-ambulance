Config = {}

Config.HospitalFee = 500 -- Fee charged when checking into hospital

Config.RespawnTime = 300 -- Seconds before player can respawn at hospital (5 minutes)

Config.Stations = {
    ['pillbox'] = {
        label = "Pillbox Hill MC",
        coords = vector3(291.2, -581.6, 43.1),
        locker = vector3(309.8, -594.0, 43.3),
        garage = vector4(295.3, -584.7, 43.1, 340.0),
        checkin = vector3(307.8, -596.0, 43.3), -- Hospital check-in point
    }
}

Config.Vehicles = {
    ['ambulance'] = { label = 'Ambulance', rank = 0 },
    ['emssuv'] = { label = 'EMS SUV', rank = 1 },
}
