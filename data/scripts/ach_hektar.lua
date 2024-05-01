local hektarWeapon = {
    ["MODULAR_LASER"] = true,
	["MODULAR_BEAM"] = true,
	["MODULAR_MISSILE"] = true,
	["MODULAR_ION"] = true,

    ["MODULAR_FOCUS"] = true,
	["MODULAR_BOMB"] = true,
	["MODULAR_SHOTGUN"] = true,
	["MODULAR_MINELAUNCHER"] = true
}

local hektarDrone = {
    ["MODULAR_DRONE_LASER"] = true,
	["MODULAR_DRONE_BEAM"] = true,
	["MODULAR_DRONE_ION"] = true,
	["MODULAR_DRONEBATTLE_BOARDER"] = true
}

local hektarCrew = {
    ["slug_hektar_elite"] = true,
    ["slug_hektar"] = true,
    ["lizard"] = true,
    ["unique_billy"] = true,
    ["unique_metyunt"] = true
}

local hektarArti = {
    ["ARTILLERY_MODULAR_LASER"] = true,
    ["ARTILLERY_MODULAR_MISSILE"] = true,
    ["ARTILLERY_MODULAR_BEAM"] = true
}

-- Yes its in MV mods, but I'm stubborn
local function vter(cvec)
    local i = -1
    local n = cvec:size()
    return function()
        i = i + 1
        if i < n then return cvec[i] end
    end
end

local function string_starts(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

local function should_track_achievement(achievement, ship, shipClassName)
    return ship and
           Hyperspace.Global.GetInstance():GetCApp().world.bStartedGame and
           Hyperspace.CustomAchievementTracker.instance:GetAchievementStatus(achievement) < Hyperspace.Settings.difficulty and
           string_starts(ship.myBlueprint.blueprintName, shipClassName)
end

-- ACH_THC_BRAND_LOYALTY
local function checkForLoyalty(playerShip)
    if should_track_achievement("ACH_THC_BRAND_LOYALTY", playerShip, "PLAYER_SHIP_HEKTAR_MODULAR") then
        local weapons = playerShip:GetWeaponList()
        local drones = playerShip:GetDroneList()
        local crew = playerShip.vCrewList

        local shipBp = playerShip.myBlueprint
        local weapSlot = shipBp.weaponSlots
        local droneSlot = shipBp.droneSlots

        if weapons:size() ~= weapSlot or drones:size() ~= droneSlot then
            return
        end

        for weapon in vter(weapons) do
            local verify = false
            for k,_ in pairs(hektarWeapon) do
                if string_starts(weapon.blueprint.name, k) then
                    verify = true
                    break
                end
            end

            if not verify then
                return
            end
        end

        for drone in vter(drones) do
            local verify = false
            for k,_ in pairs(hektarDrone) do
                if string_starts(drone.blueprint.name, k) then
                    verify = true
                    break
                end
            end
            if not verify then
                return
            end
        end

        for crewMember in vter(crew) do
            local verify = false
            for k,_ in pairs(hektarCrew) do
                if string_starts(crewMember.blueprint.name, k) then
                    verify = true
                    break
                end
            end
            if not verify then
                return
            end
        end

        Hyperspace.CustomAchievementTracker.instance:SetAchievement("ACH_THC_BRAND_LOYALTY", false)
    end
end

script.on_internal_event(Defines.InternalEvents.ON_TICK, function()
    checkForLoyalty(Hyperspace.ships.player)
end)

-- ACH_THC_NO_MONEY
local thc_fired_tracking = false
script.on_init(function()
    local playerShip = Hyperspace.ships.player
    if should_track_achievement("ACH_THC_NO_MONEY", playerShip, "PLAYER_SHIP_HEKTAR_MODULAR") then
        thc_fired_tracking = true
    else
        thc_fired_tracking = false
    end
end)

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(_, weapon)
    if thc_fired_tracking and weapon.iShipId == 0 and not hektarArti[weapon.blueprint.name] then
        thc_fired_tracking = false
    end
end)

script.on_game_event("LASTSTAND_WARP_REAL", false, function()
    if thc_fired_tracking then
        Hyperspace.CustomAchievementTracker.instance:SetAchievement("ACH_THC_NO_MONEY", false)
    end
end)

-- ACH_THC_TAX_EVADE
local thc_laroach_hard = false
script.on_game_event("DEBT_COLLECTOR_HARD", false, function()
    local playerShip = Hyperspace.ships.player
    if should_track_achievement("ACH_THC_TAX_EVADE", playerShip, "PLAYER_SHIP_HEKTAR_MODULAR") then
        thc_laroach_hard = true
    end
end)

script.on_game_event("DEBT_COLLECTOR_DEFEAT", false, function()
    if thc_laroach_hard then
        Hyperspace.CustomAchievementTracker.instance:SetAchievement("ACH_THC_TAX_EVADE", false)
    end
end)


-------------------------------------
-- LAYOUT UNLOCKS FOR ACHIEVEMENTS --
-------------------------------------

local achUnlock = {
    ["PLAYER_SHIP_HEKTAR_MODULAR_2"] = 1,
    ["PLAYER_SHIP_HEKTAR_MODULAR_3"] = 2
}
local hektAch = {
    "ACH_THC_BRAND_LOYALTY",
    "ACH_THC_NO_MONEY",
    "ACH_THC_TAX_EVADE"
}

local function get_hektar_ach_count()
    local count = 0
    for ach in hektAch do
        if Hyperspace.CustomAchievementTracker.instance:GetAchievementStatus(ach) > -1 then
            count = count + 1
        end
    end
    return count
end

script.on_internal_event(Defines.InternalEvents.ON_TICK, function()
    local unlockTracker = Hyperspace.CustomShipUnlocks.instance
    for ship, number in ipairs(achUnlock) do
        if not unlockTracker:GetCustomShipUnlocked(ship) and get_hektar_ach_count() >= number then
            unlockTracker:UnlockShip(ship, false)
        end
    end
end)
