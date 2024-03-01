--from rad
local function vter(cvec)
    local i = -1
    local n = cvec:size()
    return function()
        i = i + 1
        if i < n then return cvec[i] end
    end
end

local userdata_table = mods.multiverse.userdata_table

mods.hektar = {}
local hektar = mods.hektar
hektar.arti = {laser = {}, beam = {}, missile = {} }
hektar.arti.laser = hektar.arti.laser or {}
hektar.arti.beam = hektar.arti.beam or {}
hektar.arti.missile = hektar.arti.missile or {}

hektar.arti.x, hektar.arti.y, hektar.arti.Attribx, hektar.arti.Attriby = 0,0,0,0

hektar.arti.alpha = 1.0
hektar.arti.refreshData = 0

hektar.arti.arti = {
    ["ARTILLERY_MODULAR_LASER"] = true,
    ["ARTILLERY_MODULAR_BEAM"] = true,
    ["ARTILLERY_MODULAR_MISSILE"] = true
}

hektar.arti.moduleStatus = {
    "MODULAR_BIO",
    "MODULAR_STUN",
    "MODULAR_PIERCE",
    "MODULAR_LOCKDOWN",
    "MODULAR_COOLDOWN"
}
hektar.arti.moduleAttribute = {
    "MODULAR_POWER",
    "MODULAR_HULL",
    "MODULAR_FIRE",
    "MODULAR_ACCURACY"
}

function hektar.arti.getAttribute(ship)
    for _, module in ipairs(hektar.arti.moduleAttribute) do
        if ship:HasAugmentation(module) > 0 then
            return module
        end
    end
end

function hektar.arti.getStatus(ship)
    for _, module in ipairs(hektar.arti.moduleStatus) do
        if ship:HasAugmentation(module) > 0 then
            return module
        end
    end
end

--Laser Configuration
hektar.arti.alwayshit = false
hektar.arti.lockdown = false

hektar.arti.laser = {
    MODULAR_BIO = { add = "modular_artillery/modules/bio.png", addOn = "modular_artillery/modules/bioOn.png", effect = function(weapon) weapon.blueprint.damage.iPersDamage = 10 weapon.blueprint.damage.iShieldPiercing = 1 weapon.blueprint.damage.iDamage = weapon.blueprint.damage.iDamage - 1  end },
    MODULAR_STUN = { add = "modular_artillery/modules/stun.png", addOn = "modular_artillery/modules/stunOn.png", effect = function(weapon) weapon.blueprint.damage.stunChance = 10 weapon.blueprint.damage.iStun = 20 end },
    MODULAR_PIERCE = { add = "modular_artillery/modules/pierce.png", addOn = "modular_artillery/modules/pierceOn.png", effect = function(weapon) weapon.blueprint.damage.iShieldPiercing = 2 end },
    MODULAR_LOCKDOWN = { add = "modular_artillery/modules/lockdown.png", addOn = "modular_artillery/modules/lockdownOn.png", effect = function(weapon) weapon.blueprint.damage.bLockdown = true end },
    MODULAR_COOLDOWN = { add = "modular_artillery/modules/cooldown.png", addOn = "modular_artillery/modules/cooldownOn.png", effect = function(weapon) weapon.blueprint.cooldown = 20 end },
    MODULAR_POWER = {add = "modular_artillery/modules/laser/power.png", effect = function(weapon) weapon.blueprint.damage.iDamage = 2 end },
    MODULAR_HULL = {add = "modular_artillery/modules/laser/hull.png", effect = function(weapon) weapon.blueprint.damage.breachChance = 10 weapon.blueprint.damage.bHullBuster = true end },
    MODULAR_FIRE = {add = "modular_artillery/modules/laser/fire.png", effect = function(weapon) weapon.blueprint.damage.fireChance = 10 end },
    MODULAR_ACCURACY = {add = "modular_artillery/modules/laser/accuracy.png", effect = function(weapon) hektar.arti.alwayshit = true end }
}

function hektar.arti.laser.resetStats(weapon)
    local bp = weapon.blueprint
    local dmg = bp.damage

    bp.cooldown = 25

    dmg.iDamage = 1
    dmg.iShieldPiercing = 0
    dmg.fireChance = 0
    dmg.breachChance = 0
    dmg.stunChance = 0
    dmg.iStun = 0
    dmg.bLockdown = false
    dmg.iPersDamage = 2
    dmg.bHullBuster = false
    hektar.arti.alwayshit = false
    
end

--Missile Configuration
hektar.arti.missile = {
    MODULAR_BIO = { add = "modular_artillery/modules/bio.png", addOn = "modular_artillery/modules/bioOn.png", effect = function(weapon) weapon.blueprint.damage.iPersDamage = 13 weapon.blueprint.damage.iShieldPiercing = 1 weapon.blueprint.damage.iDamage = weapon.blueprint.damage.iDamage - 2 hektar.arti.missile.aoeStatus = function(damage) damage.iPersDamage = 3 end  end },
    MODULAR_STUN = { add = "modular_artillery/modules/stun.png", addOn = "modular_artillery/modules/stunOn.png", effect = function(weapon) weapon.blueprint.damage.stunChance = 10 weapon.blueprint.damage.iStun = 40 hektar.arti.missile.aoeStatus = function(damage) damage.stunChance = 10 damage.iStun = 20 end end },
    MODULAR_LOCKDOWN = { add = "modular_artillery/modules/lockdown.png", addOn = "modular_artillery/modules/lockdownOn.png", effect = function(weapon) weapon.blueprint.damage.bLockdown = true hektar.arti.missile.aoeStatus = function(damage) damage.bLockdown = true end end },
    MODULAR_COOLDOWN = { add = "modular_artillery/modules/cooldown.png", addOn = "modular_artillery/modules/cooldownOn.png", effect = function(weapon) weapon.blueprint.cooldown = 30 end },
    MODULAR_POWER = {add = "modular_artillery/modules/missile/power.png", effect = function(weapon) weapon.blueprint.damage.iSystemDamage = 2 hektar.arti.missile.aoeAttribute = function(damage) damage.iSystemDamage = 2 end end },
    MODULAR_HULL = {add = "modular_artillery/modules/missile/hull.png", effect = function(weapon) weapon.blueprint.damage.iDamage = 3 weapon.blueprint.damage.breachChance = 10 hektar.arti.missile.aoeAttribute = function(damage) damage.breachChance = 10 end end },
    MODULAR_FIRE = {add = "modular_artillery/modules/missile/fire.png", effect = function(weapon) weapon.blueprint.damage.fireChance = 10 hektar.arti.missile.aoeAttribute = function(damage) damage.fireChance = 10 end end },
    MODULAR_ACCURACY = {add = "modular_artillery/modules/missile/accuracy.png", effect = function(weapon) hektar.arti.alwayshit = true end }
}

function hektar.arti.missile.resetStats(weapon)
    local bp = weapon.blueprint
    local dmg = bp.damage

    hektar.arti.missile.aoeStatus = function(damage) end
    hektar.arti.missile.aoeAttribute = function(damage) end

    bp.cooldown = 35
    dmg.iDamage = 2
    dmg.iSystemDamage = 0
    dmg.fireChance = 0
    dmg.breachChance = 0
    dmg.stunChance = 0
    dmg.iStun = 0
    hektar.arti.lockdown = false
    dmg.iPersDamage = 3
    hektar.arti.alwayshit = false
    
end

--Beam Configuration
hektar.arti.beam = {
    MODULAR_BIO = { add = "modular_artillery/modules/bio.png", addOn = "modular_artillery/modules/bioOn.png", effect = function(weapon) weapon.blueprint.damage.iPersDamage = 6 weapon.blueprint.damage.iShieldPiercing = 2 weapon.blueprint.damage.iDamage = weapon.blueprint.damage.iDamage - 2  end },
    MODULAR_STUN = { add = "modular_artillery/modules/stun.png", addOn = "modular_artillery/modules/stunOn.png", effect = function(weapon) weapon.blueprint.damage.stunChance = 10 weapon.blueprint.damage.iStun = 20 end },
    MODULAR_PIERCE = { add = "modular_artillery/modules/pierce.png", addOn = "modular_artillery/modules/pierceOn.png", effect = function(weapon) weapon.blueprint.damage.iShieldPiercing = 1 end },
    MODULAR_LOCKDOWN = { add = "modular_artillery/modules/lockdown.png", addOn = "modular_artillery/modules/lockdownOn.png", effect = function(weapon) hektar.arti.lockdown = true end },
    MODULAR_COOLDOWN = { add = "modular_artillery/modules/cooldown.png", addOn = "modular_artillery/modules/cooldownOn.png", effect = function(weapon) weapon.blueprint.cooldown = 21 end },
    MODULAR_POWER = {add = "modular_artillery/modules/beam/power.png", effect = function(weapon) weapon.blueprint.damage.iDamage = 4 end },
    MODULAR_HULL = {add = "modular_artillery/modules/beam/hull.png", effect = function(weapon) weapon.blueprint.damage.breachChance = 10 end },
    MODULAR_FIRE = {add = "modular_artillery/modules/beam/fire.png", effect = function(weapon) weapon.blueprint.damage.fireChance = 10 end }
}

function hektar.arti.beam.resetStats(weapon)
    local bp = weapon.blueprint
    local dmg = bp.damage

    bp.cooldown = 26

    dmg.iDamage = 2
    dmg.iShieldPiercing = 0
    dmg.fireChance = 0
    dmg.breachChance = 0
    dmg.stunChance = 0
    dmg.iStun = 0
    hektar.arti.lockdown = false
    dmg.iPersDamage = 1
    hektar.arti.alwayshit = false
    
end

function hektar.arti.applyStats(weapon, ship)
    local attrib = hektar.arti.getAttribute(ship)
    local status = hektar.arti.getStatus(ship)

    if weapon.blueprint.name == "ARTILLERY_MODULAR_LASER" then
        hektar.arti.laser.resetStats(weapon)

        if hektar.arti.laser[attrib] then
            hektar.arti.laser[attrib].effect(weapon)
        end

        if hektar.arti.laser[status] then
            hektar.arti.laser[status].effect(weapon)
        end

    elseif weapon.blueprint.name == "ARTILLERY_MODULAR_BEAM" then
        hektar.arti.beam.resetStats(weapon)

        if hektar.arti.beam[attrib] then
            hektar.arti.beam[attrib].effect(weapon)
        end

        if hektar.arti.beam[status] then
            hektar.arti.beam[status].effect(weapon)
        end
    elseif weapon.blueprint.name == "ARTILLERY_MODULAR_MISSILE" then
        hektar.arti.missile.resetStats(weapon)

        if hektar.arti.missile[attrib] then
            hektar.arti.missile[attrib].effect(weapon)
        end

        if hektar.arti.missile[status] then
            hektar.arti.missile[status].effect(weapon)
        end
    end
end

function hektar.arti.calculateCoordinates(ship, weaponAnim, shipGraph, slideOffset, offsetValues, isAttrib)
    local baseX = ship.shipImage.x + shipGraph.shipBox.x + weaponAnim.renderPoint.x + slideOffset.x
    local baseY = ship.shipImage.y + shipGraph.shipBox.y + weaponAnim.renderPoint.y +  slideOffset.y
    local offset = offsetValues or {x = 0, y = 0}
    if isAttrib then
        offset.x = offsetValues.attribX or 0
        offset.y = offsetValues.attribY or 0
    end

    return baseX + offset.x, baseY + offset.y
end

function hektar.arti.updateLayer(weaponAnim, layerType, status, attrib)
    if layerType[status] then
        hektar.arti.layerStatus = Hyperspace.Resources:CreateImagePrimitiveString(layerType[status].add, hektar.arti.x, hektar.arti.y, 0, Graphics.GL_Color(1, 1, 1, 1), hektar.arti.alpha, false)
        if weaponAnim.anim.currentFrame > 0 and layerType[status].addOn then
            hektar.arti.layerStatusOn = Hyperspace.Resources:CreateImagePrimitiveString(layerType[status].addOn, hektar.arti.x, hektar.arti.y, 0, Graphics.GL_Color(1, 1, 1, 1), hektar.arti.alpha, false)
        end
    else
        if hektar.arti.layerStatus then Graphics.CSurface.GL_DestroyPrimitive(hektar.arti.layerStatus) end
        if hektar.arti.layerStatusOn then Graphics.CSurface.GL_DestroyPrimitive(hektar.arti.layerStatusOn) end
        hektar.arti.layerStatus = nil
        hektar.arti.layerStatusOn = nil
    end

    if layerType[attrib] then
        hektar.arti.layerAttrib = Hyperspace.Resources:CreateImagePrimitiveString(layerType[attrib].add, hektar.arti.Attribx, hektar.arti.Attriby, 0, Graphics.GL_Color(1, 1, 1, 1), hektar.arti.alpha, false)
    else
        if hektar.arti.layerAttrib then Graphics.CSurface.GL_DestroyPrimitive(hektar.arti.layerAttrib) end
        hektar.arti.layerAttrib = nil
    end
end

function hektar.arti.handleVisual(weapon, ship)
    local attrib = hektar.arti.getAttribute(ship)
    local status = hektar.arti.getStatus(ship)
    local weaponAnim = weapon.weaponVisual
    local ship = Hyperspace.Global.GetInstance():GetShipManager(weapon.iShipId).ship
    local shipGraph = Hyperspace.ShipGraph.GetShipInfo(weapon.iShipId)
    local slideOffset = weaponAnim:GetSlide()

    local offsetValues = {
        ["ARTILLERY_MODULAR_LASER"] = { x = -35, y = 0, attribX = -47, attribY = 15 },
        ["ARTILLERY_MODULAR_BEAM"] = { x = -40, y = 0, attribX = -34, attribY = 6 },
        ["ARTILLERY_MODULAR_MISSILE"] = { x = -36, y = 0, attribX = -34, attribY = 9 }
    }

    hektar.arti.x, hektar.arti.y = hektar.arti.calculateCoordinates(ship, weaponAnim, shipGraph, slideOffset, offsetValues[weapon.blueprint.name])
    hektar.arti.Attribx, hektar.arti.Attriby = hektar.arti.calculateCoordinates(ship, weaponAnim, shipGraph, slideOffset, offsetValues[weapon.blueprint.name], true)

    if weapon.blueprint.name == "ARTILLERY_MODULAR_LASER" then
        hektar.arti.updateLayer(weaponAnim, hektar.arti.laser, status, attrib)
    elseif weapon.blueprint.name == "ARTILLERY_MODULAR_BEAM" then
        hektar.arti.updateLayer(weaponAnim, hektar.arti.beam, status, attrib)
    elseif weapon.blueprint.name == "ARTILLERY_MODULAR_MISSILE" then
        hektar.arti.updateLayer(weaponAnim, hektar.arti.missile, status, attrib)
    end
end

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    for arti in vter(shipManager.artillerySystems) do
        local weaponData = arti.projectileFactory
        if weaponData and hektar.arti.arti[weaponData.blueprint.name] then

            hektar.arti.handleVisual(weaponData, shipManager)
            hektar.arti.refreshData = math.max(hektar.arti.refreshData - (Hyperspace.FPS.SpeedFactor / 16), 0)

            --There is no need to refresh blueprints data every frame, we set an artificial 5 second delay
            if hektar.arti.refreshData == 0 then
                hektar.arti.applyStats(weaponData, shipManager.ship)
                hektar.arti.refreshData = 5
            end
        end
    end
end)


-- Projectile Behaviour
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, function(shipManager, projectile)
    local weaponName = nil
    pcall(function() weaponName = Hyperspace.Get_Projectile_Extend(projectile).name end)
    if (weaponName == "ARTILLERY_MODULAR_LASER" or weaponName == "ARTILLERY_MODULAR_MISSILE") and hektar.arti.alwayshit then
        if hektar.arti.alwayshit then
            return Defines.Chain.CONTINUE, Defines.Evasion.HIT
        end
    end

    return Defines.Chain.CONTINUE
end)

-- Missile Behaviour

    --from TRC
local function get_room_at_location(shipManager, location, includeWalls)
    return Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId):GetSelectedRoom(location.x, location.y, includeWalls)
end

local function get_adjacent_rooms(shipId, roomId, diagonals)
    local shipGraph = Hyperspace.ShipGraph.GetShipInfo(shipId)
    local roomShape = shipGraph:GetRoomShape(roomId)
    local adjacentRooms = {}
    local currentRoom = nil
    local function check_for_room(x, y)
        currentRoom = shipGraph:GetSelectedRoom(x, y, false)
        if currentRoom > -1 and not adjacentRooms[currentRoom] then
            adjacentRooms[currentRoom] = Hyperspace.Pointf(x, y)
        end
    end
    for offset = 0, roomShape.w - 35, 35 do
        check_for_room(roomShape.x + offset + 17, roomShape.y - 17)
        check_for_room(roomShape.x + offset + 17, roomShape.y + roomShape.h + 17)
    end
    for offset = 0, roomShape.h - 35, 35 do
        check_for_room(roomShape.x - 17,               roomShape.y + offset + 17)
        check_for_room(roomShape.x + roomShape.w + 17, roomShape.y + offset + 17)
    end
    if diagonals then
        check_for_room(roomShape.x - 17,               roomShape.y - 17)
        check_for_room(roomShape.x + roomShape.w + 17, roomShape.y - 17)
        check_for_room(roomShape.x + roomShape.w + 17, roomShape.y + roomShape.h + 17)
        check_for_room(roomShape.x - 17,               roomShape.y + roomShape.h + 17)
    end
    return adjacentRooms
end

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(shipManager, projectile, location, damage, shipFriendlyFire)
    local weaponName = nil
    pcall(function() weaponName = Hyperspace.Get_Projectile_Extend(projectile).name end)
    
    if weaponName == "ARTILLERY_MODULAR_MISSILE" then
        Hyperspace.Get_Projectile_Extend(projectile).name = ""
        local aoeDamage = Hyperspace.Damage()

        hektar.arti.missile.aoeStatus(aoeDamage)
        hektar.arti.missile.aoeAttribute(aoeDamage)
        for roomId, roomPos in pairs(get_adjacent_rooms(shipManager.iShipId, get_room_at_location(shipManager, location, false), false)) do
            shipManager:DamageArea(roomPos, aoeDamage, true)
        end
        Hyperspace.Get_Projectile_Extend(projectile).name = weaponName
    end
end)

--Beam Behaviour
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(shipManager, projectile, location, damage, realNewTile, beamHitType)
    local beamName = Hyperspace.Get_Projectile_Extend(projectile).name
    if beamName == "ARTILLERY_MODULAR_BEAM" and hektar.arti.lockdown and beamHitType == Defines.BeamHit.NEW_ROOM then
        shipManager.ship:LockdownRoom(get_room_at_location(shipManager, location, true), location)
    end
    return Defines.Chain.CONTINUE, beamHitType
end)

--Rendering Modules
script.on_render_event(Defines.RenderEvents.SHIP_FLOOR, function()

    if hektar.arti.layerStatus then
        Graphics.CSurface.GL_RenderPrimitive(hektar.arti.layerStatus)
    end
    if hektar.arti.layerStatusOn then
        Graphics.CSurface.GL_RenderPrimitive(hektar.arti.layerStatusOn)
    end
    if hektar.arti.layerAttrib then
        Graphics.CSurface.GL_RenderPrimitive(hektar.arti.layerAttrib)
    end
end, function() end)

-- from MV 5.4
local function calcJumpAlpha(progress)   return 1 - math.min(progress/0.75, 1) end
local function calcHullAlpha(cloakAlpha) return (1 - cloakAlpha)*0.5 + 0.5     end
script.on_render_event(Defines.RenderEvents.SHIP_JUMP, function() end, function(ship, progress)
    hektar.arti.alpha = calcJumpAlpha(progress)
end)
script.on_render_event(Defines.RenderEvents.SHIP_HULL, function() end, function(ship, cloakAlpha)
    hektar.arti.alpha = calcHullAlpha(cloakAlpha)
end)

mods.hektar.mindcontrol = {}

-- Hektar Elite Mind Control
script.on_internal_event(Defines.InternalEvents.ACTIVATE_POWER, function(power, ship)
    if power.crew.blueprint.name ~= "slug_hektar_elite" then return end

    for crew in vter(ship.vCrewList) do
        if power.powerRoom == crew.iRoomId and power.crew ~= crew and power.crew.iShipId ~= crew.iShipId and crew.bMindControlled == false then
            crew:SetMindControl(true)
            mods.hektar.mindcontrol[crew] = (crew.IsTelepathic and 10) or 20
            power:CancelPower(true)
            break
        end
    end
end)


script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function()
    if not mods.hektar.mindcontrol then return end
    for k, _ in pairs(mods.hektar.mindcontrol) do
        mods.hektar.mindcontrol[k] = math.max(mods.hektar.mindcontrol[k] - Hyperspace.FPS.SpeedFactor/16, 0)
        if mods.hektar.mindcontrol[k] <= 0 then
            k:SetMindControl(false)
            mods.hektar.mindcontrol[k] = nil
        end
    end
end)