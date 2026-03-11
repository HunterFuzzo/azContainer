local playerWeaponComponents = {}
local playerVehiclePresets = {}

Citizen.CreateThread(function()
    Wait(500)
    local xPlayers = ESX.GetExtendedPlayers()
    for _, xPlayer in ipairs(xPlayers) do
        local result = MySQL.prepare.await('SELECT weapon_components, vehicle_presets FROM users WHERE identifier = ?', {xPlayer.identifier})
        if result then
            if result.weapon_components then
                playerWeaponComponents[xPlayer.identifier] = json.decode(result.weapon_components)
                TriggerClientEvent('az_container:updateWeaponComponents', xPlayer.source, playerWeaponComponents[xPlayer.identifier])
            end
            if result.vehicle_presets then
                playerVehiclePresets[xPlayer.identifier] = json.decode(result.vehicle_presets)
            else
                playerVehiclePresets[xPlayer.identifier] = {}
            end
        end
    end
end)

-- Load player weapon components and vehicle presets on join
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    MySQL.prepare('SELECT weapon_components, vehicle_presets FROM users WHERE identifier = ?', {xPlayer.identifier}, function(result)
        if result then
            if result.weapon_components then
                playerWeaponComponents[xPlayer.identifier] = json.decode(result.weapon_components)
                TriggerClientEvent('az_container:updateWeaponComponents', playerId, playerWeaponComponents[xPlayer.identifier])
            end
            if result.vehicle_presets then
                playerVehiclePresets[xPlayer.identifier] = json.decode(result.vehicle_presets)
            else
                playerVehiclePresets[xPlayer.identifier] = {}
            end
        end
    end)
end)

-- Function to ensure data is loaded (handles script restarts)
function EnsurePlayerData(identifier)
    if not playerWeaponComponents[identifier] or not playerVehiclePresets[identifier] then
        local result = MySQL.prepare.await('SELECT weapon_components, vehicle_presets FROM users WHERE identifier = ?', {identifier})
        if result then
            playerWeaponComponents[identifier] = json.decode(result.weapon_components) or {}
            playerVehiclePresets[identifier] = json.decode(result.vehicle_presets) or {}
        else
            playerWeaponComponents[identifier] = playerWeaponComponents[identifier] or {}
            playerVehiclePresets[identifier] = playerVehiclePresets[identifier] or {}
        end
    end
end

-- Build a master lookup table of all items and their categories from the Config (or we can just receive it from client)
-- Since the client sends the componentData directly, we can use it to determine the category
ESX.RegisterServerCallback('az_container:saveWeaponComponent', function(source, cb, weaponName, componentHash, conflictingHashes)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false) end

    local identifier = xPlayer.identifier
    EnsurePlayerData(identifier)
    local components = playerWeaponComponents[identifier]

    if not components[weaponName] then
        components[weaponName] = {}
    end

    local removedHashes = {}
    local found = false

    -- 1. Check if the exact component is already installed (Toggle OFF)
    for i, hash in ipairs(components[weaponName]) do
        if hash == componentHash then
            table.remove(components[weaponName], i)
            found = true
            table.insert(removedHashes, hash)
            break
        end
    end

    -- 2. If we are turning it ON, check for conflicting categories and remove them first
    if not found then
        if conflictingHashes and #conflictingHashes > 0 then
            -- We iterate backwards when removing elements from a table
            for i = #components[weaponName], 1, -1 do
                local savedHash = components[weaponName][i]
                for _, conflictHash in ipairs(conflictingHashes) do
                    if savedHash == conflictHash then
                        table.remove(components[weaponName], i)
                        table.insert(removedHashes, savedHash)
                        break
                    end
                end
            end
        end
        table.insert(components[weaponName], componentHash)
    end

    MySQL.update('UPDATE users SET weapon_components = ? WHERE identifier = ?', {
        json.encode(components),
        identifier
    }, function(affectedRows)
        playerWeaponComponents[identifier] = components
        TriggerClientEvent('az_container:updateWeaponComponents', source, components)
        cb(true, removedHashes)
    end)
end)

-- Shop Logic
ESX.RegisterServerCallback('az_container:buyItem', function(source, cb, itemName, price, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false) end

    local amount = count or 1
    local totalPrice = price * amount

    if xPlayer.getMoney() >= totalPrice then
        if xPlayer.canCarryItem(itemName, amount) then
            xPlayer.removeMoney(totalPrice)
            xPlayer.addInventoryItem(itemName, amount)
            cb(true)
        else
            TriggerClientEvent('az_notify:ShowNotification', source, "~r~Vous n'avez pas assez de place.")
            cb(false)
        end
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('az_container:getVehiclesInBag', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb({}) end

    local identifier = xPlayer.identifier
    EnsurePlayerData(identifier)
    local presets = playerVehiclePresets[identifier]

    local vehicles = {}
    local inventory = xPlayer.getInventory(false) -- Get full inventory

    for _, item in ipairs(inventory) do
        -- We detect vehicles by name pattern
        if item.count > 0 and (string.find(item.name, "VEHICLE_") or string.find(item.name, "CAR_") or item.name == "deluxo") then
            local modelName = string.lower(string.gsub(item.name, "VEHICLE_", ""))
            table.insert(vehicles, {
                name = item.name,
                label = item.label,
                mods = presets[modelName] or {}
            })
        end
    end

    cb(vehicles)
end)

RegisterNetEvent('az_container:saveVehicleBagMods')
AddEventHandler('az_container:saveVehicleBagMods', function(itemName, mods)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not xPlayer then return end

    local identifier = xPlayer.identifier
    local modelName = string.lower(string.gsub(itemName, "VEHICLE_", ""))
    
    EnsurePlayerData(identifier)
    playerVehiclePresets[identifier][modelName] = mods

    MySQL.update('UPDATE users SET vehicle_presets = ? WHERE identifier = ?', {
        json.encode(playerVehiclePresets[identifier]),
        identifier
    })
end)
