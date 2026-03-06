local playerWeaponComponents = {}

Citizen.CreateThread(function()
    Wait(500)
    local xPlayers = ESX.GetExtendedPlayers()
    for _, xPlayer in ipairs(xPlayers) do
        local result = MySQL.scalar.await('SELECT weapon_components FROM users WHERE identifier = ?', {xPlayer.identifier})
        if result then
            playerWeaponComponents[xPlayer.identifier] = json.decode(result)
            TriggerClientEvent('az_container:updateWeaponComponents', xPlayer.source, playerWeaponComponents[xPlayer.identifier])
        end
    end
end)

-- Load player weapon components on join
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    MySQL.scalar('SELECT weapon_components FROM users WHERE identifier = ?', {xPlayer.identifier}, function(result)
        if result then
            playerWeaponComponents[xPlayer.identifier] = json.decode(result)
            TriggerClientEvent('az_container:updateWeaponComponents', playerId, playerWeaponComponents[xPlayer.identifier])
        end
    end)
end)

-- Function to ensure components are loaded (handles script restarts)
function EnsurePlayerComponents(identifier)
    if not playerWeaponComponents[identifier] then
        local result = MySQL.scalar.await('SELECT weapon_components FROM users WHERE identifier = ?', {identifier})
        if result then
            playerWeaponComponents[identifier] = json.decode(result) or {}
        else
            playerWeaponComponents[identifier] = {}
        end
    end
    return playerWeaponComponents[identifier]
end

-- Save player weapon components
ESX.RegisterServerCallback('az_container:saveWeaponComponent', function(source, cb, weaponName, componentHash)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false) end

    local identifier = xPlayer.identifier
    local components = EnsurePlayerComponents(identifier)

    if not components[weaponName] then
        components[weaponName] = {}
    end

    -- Toggle component
    local found = false
    for i, hash in ipairs(components[weaponName]) do
        if hash == componentHash then
            table.remove(components[weaponName], i)
            found = true
            break
        end
    end

    if not found then
        table.insert(components[weaponName], componentHash)
    end

    MySQL.update('UPDATE users SET weapon_components = ? WHERE identifier = ?', {
        json.encode(components),
        identifier
    }, function(affectedRows)
        playerWeaponComponents[identifier] = components
        TriggerClientEvent('az_container:updateWeaponComponents', source, components)
        cb(true)
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
