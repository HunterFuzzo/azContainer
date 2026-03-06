local mainMenu = RageUI.CreateMenu("Services", "Choisissez un service")
local shopMenu = RageUI.CreateSubMenu(mainMenu, "Epicerie", "Articles disponibles")
local weaponMenu = RageUI.CreateSubMenu(mainMenu, "Armurier", "Composants d'armes")
local vehicleMenu = RageUI.CreateSubMenu(mainMenu, "Mecano", "Personnalisation")
local teleporterMenu = RageUI.CreateSubMenu(mainMenu, "Teleporteur", "Destinations")

local currentNPC = nil
local playerComponents = {}
local weaponAttachments = { 
    -- Generic / High level
    {label = "Silencieux (Ar)", hash = `COMPONENT_AT_AR_SUPP_02`},
    {label = "Silencieux (Pistol)", hash = `COMPONENT_AT_PI_SUPP`},
    {label = "Silencieux (SMG)", hash = `COMPONENT_AT_AR_SUPP`},
    {label = "Silencieux (MK2)", hash = `COMPONENT_AT_AR_SUPP_02`}, -- Shared for some
    {label = "Lampe", hash = `COMPONENT_AT_AR_FLSH`},
    {label = "Lampe (Pistol)", hash = `COMPONENT_AT_PI_FLSH`},
    {label = "Poignée", hash = `COMPONENT_AT_AR_AFG`},
    {label = "Viseur (Petit)", hash = `COMPONENT_AT_SCOPE_MACRO`},
    {label = "Viseur (Moyen)", hash = `COMPONENT_AT_SCOPE_MEDIUM`},
    {label = "Viseur (Large)", hash = `COMPONENT_AT_SCOPE_LARGE`},
    {label = "Viseur (Avançé)", hash = `COMPONENT_AT_SCOPE_MAX`},
    
    -- MK2 Specifics
    {label = "Viseur Holo (MK2)", hash = `COMPONENT_AT_SIGHTS`},
    {label = "Viseur Macro (MK2)", hash = `COMPONENT_AT_SIGHTS_02`},
    {label = "Viseur Zoom (MK2)", hash = `COMPONENT_AT_SCOPE_MACRO_02`},
    {label = "Viseur Small (MK2)", hash = `COMPONENT_AT_SCOPE_SMALL`},
    {label = "Viseur Medium (MK2)", hash = `COMPONENT_AT_SCOPE_MEDIUM_MK2`},
    {label = "Compensateur (MK2)", hash = `COMPONENT_AT_MUZZLE_01`},
    {label = "Frein de bouche (MK2)", hash = `COMPONENT_AT_MUZZLE_02`},
    {label = "Muzzle Flash (MK2)", hash = `COMPONENT_AT_MUZZLE_03`},
    {label = "Muzzle Heavy (MK2)", hash = `COMPONENT_AT_MUZZLE_04`},
    {label = "Canon lourd (MK2)", hash = `COMPONENT_AT_AR_BARREL_01`},
    {label = "Canon long (MK2)", hash = `COMPONENT_AT_AR_BARREL_02`},

    -- Clips
    {label = "Chargeur étendu (Pistol)", hash = `COMPONENT_PISTOL_CLIP_02`},
    {label = "Chargeur étendu (SMG)", hash = `COMPONENT_SMG_CLIP_02`},
    {label = "Chargeur étendu (AR)", hash = `COMPONENT_ASSAULTRIFLE_CLIP_02`},
    {label = "Chargeur étendu (Carbine)", hash = `COMPONENT_CARBINERIFLE_CLIP_02`},
    {label = "Chargeur étendu (MK2)", hash = `COMPONENT_CARBINERIFLE_MK2_CLIP_02`},
    
    -- Skins
    {label = "Skin Luxe (Pistol)", hash = `COMPONENT_PISTOL_VARMOD_LUXE`},
    {label = "Skin Luxe (Combat P)", hash = `COMPONENT_COMBATPISTOL_VARMOD_LOWRIDER`},
}

-- Update local components from server
RegisterNetEvent('az_container:updateWeaponComponents')
AddEventHandler('az_container:updateWeaponComponents', function(components)
    playerComponents = components or {}
    ApplyGlobalComponents()
end)

RegisterNetEvent('az_container:refreshWeaponComponents')
AddEventHandler('az_container:refreshWeaponComponents', function()
    ApplyGlobalComponents()
end)

Citizen.CreateThread(function()
    Wait(2000)
    ApplyGlobalComponents()
end)

function ApplyGlobalComponents()
    local playerPed = PlayerPedId()
    local weaponHash = GetSelectedPedWeapon(playerPed)
    local weaponName = GetWeaponNameFromHash(weaponHash)

    if not weaponName then return end

    -- Loop through our known attachments and apply/remove
    for _, attachment in ipairs(weaponAttachments) do
        local shouldHave = false
        if playerComponents[weaponName] then
            for _, savedHash in ipairs(playerComponents[weaponName]) do
                if savedHash == attachment.hash then
                    shouldHave = true
                    break
                end
            end
        end

        if shouldHave then
            if DoesWeaponTakeWeaponComponent(weaponHash, attachment.hash) then
                if not HasPedGotWeaponComponent(playerPed, weaponHash, attachment.hash) then
                    GiveWeaponComponentToPed(playerPed, weaponHash, attachment.hash)
                end
            end
        else
            if HasPedGotWeaponComponent(playerPed, weaponHash, attachment.hash) then
                RemoveWeaponComponentFromPed(playerPed, weaponHash, attachment.hash)
            end
        end
    end
end

function GetWeaponNameFromHash(hash)
    local weapons = {
        -- Pistols
        [`WEAPON_PISTOL`] = "WEAPON_PISTOL",
        [`WEAPON_COMBATPISTOL`] = "WEAPON_COMBATPISTOL",
        [`WEAPON_APPISTOL`] = "WEAPON_APPISTOL",
        [`WEAPON_PISTOL50`] = "WEAPON_PISTOL50",
        [`WEAPON_REVOLVER`] = "WEAPON_REVOLVER",
        [`WEAPON_SNSPISTOL`] = "WEAPON_SNSPISTOL",
        [`WEAPON_HEAVYPISTOL`] = "WEAPON_HEAVYPISTOL",
        [`WEAPON_VINTAGEPISTOL`] = "WEAPON_VINTAGEPISTOL",
        [`WEAPON_PISTOL_MK2`] = "WEAPON_PISTOL_MK2",
        [`WEAPON_SNSPISTOL_MK2`] = "WEAPON_SNSPISTOL_MK2",
        [`WEAPON_REVOLVER_MK2`] = "WEAPON_REVOLVER_MK2",
        
        -- SMGs
        [`WEAPON_SMG`] = "WEAPON_SMG",
        [`WEAPON_MICROSMG`] = "WEAPON_MICROSMG",
        [`WEAPON_COMBATSMG`] = "WEAPON_COMBATSMG",
        [`WEAPON_SMG_MK2`] = "WEAPON_SMG_MK2",
        [`WEAPON_COMBATSMG_MK2`] = "WEAPON_COMBATSMG_MK2",
        
        -- Assault Rifles
        [`WEAPON_ASSAULTRIFLE`] = "WEAPON_ASSAULTRIFLE",
        [`WEAPON_CARBINERIFLE`] = "WEAPON_CARBINERIFLE",
        [`WEAPON_ADVANCEDRIFLE`] = "WEAPON_ADVANCEDRIFLE",
        [`WEAPON_SPECIALCARBINE`] = "WEAPON_SPECIALCARBINE",
        [`WEAPON_BULLPUPRIFLE`] = "WEAPON_BULLPUPRIFLE",
        [`WEAPON_COMPACTRIFLE`] = "WEAPON_COMPACTRIFLE",
        [`WEAPON_ASSAULTRIFLE_MK2`] = "WEAPON_ASSAULTRIFLE_MK2",
        [`WEAPON_CARBINERIFLE_MK2`] = "WEAPON_CARBINERIFLE_MK2",
        [`WEAPON_SPECIALCARBINE_MK2`] = "WEAPON_SPECIALCARBINE_MK2",
        [`WEAPON_BULLPUPRIFLE_MK2`] = "WEAPON_BULLPUPRIFLE_MK2",
        
        -- Others
        [`WEAPON_COMBATMG`] = "WEAPON_COMBATMG",
        [`WEAPON_COMBATMG_MK2`] = "WEAPON_COMBATMG_MK2",
        [`WEAPON_PUMPSHOTGUN`] = "WEAPON_PUMPSHOTGUN",
        [`WEAPON_PUMPSHOTGUN_MK2`] = "WEAPON_PUMPSHOTGUN_MK2",
        [`WEAPON_SAWNOFFSHOTGUN`] = "WEAPON_SAWNOFFSHOTGUN",
        [`WEAPON_SNIPERRIFLE`] = "WEAPON_SNIPERRIFLE",
        [`WEAPON_HEAVYSNIPER`] = "WEAPON_HEAVYSNIPER",
        [`WEAPON_HEAVYSNIPER_MK2`] = "WEAPON_HEAVYSNIPER_MK2",
        [`WEAPON_MARKSMANRIFLE`] = "WEAPON_MARKSMANRIFLE",
        [`WEAPON_MARKSMANRIFLE_MK2`] = "WEAPON_MARKSMANRIFLE_MK2",
    }
    
    if weapons[hash] then return weapons[hash] end
    return nil
end

-- Refresh components on weapon change or interaction
Citizen.CreateThread(function()
    local lastWeapon = nil
    while true do
        local playerPed = PlayerPedId()
        local currentWeapon = GetSelectedPedWeapon(playerPed)
        if currentWeapon ~= lastWeapon then
            lastWeapon = currentWeapon
            ApplyGlobalComponents()
        end
        Wait(1000)
    end
end)

function OpenNPCMenu(npc)
    if not npc then return end
    currentNPC = npc
    RageUI.Visible(mainMenu, not RageUI.Visible(mainMenu))
end

function OpenQuantityInput()
    AddTextEntry('FMMC_KEY_TIP8', "Quantité désirée")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "1", "", "", "", 10)
    while UpdateOnscreenKeyboard() == 0 do
        Wait(0)
    end
    if GetOnscreenKeyboardResult() then
        local result = GetOnscreenKeyboardResult()
        return tonumber(result)
    end
    return nil
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if RageUI.Visible(mainMenu) then
            mainMenu:IsVisible(function(Items)
                if currentNPC.type == 'shop' then
                    Items:AddButton("Accéder à l'épicerie", nil, {RightLabel = "→"}, function(onSelected)
                    end, shopMenu)
                elseif currentNPC.type == 'weapon' then
                    Items:AddButton("Modifier mon arme", nil, {RightLabel = "→"}, function(onSelected)
                    end, weaponMenu)
                elseif currentNPC.type == 'vehicle' then
                    Items:AddButton("Personnaliser mon véhicule", nil, {RightLabel = "→"}, function(onSelected)
                    end, vehicleMenu)
                elseif currentNPC.type == 'clothing' then
                    Items:AddButton("Changer de style", nil, {RightLabel = "→"}, function(onSelected)
                        if onSelected then
                            RageUI.Visible(mainMenu, false)
                            TriggerEvent('esx_skin:openSaveableMenu')
                        end
                    end)
                elseif currentNPC.type == 'teleporter' then
                    Items:AddButton("Se téléporter", nil, {RightLabel = "→"}, function(onSelected)
                    end, teleporterMenu)
                end
            end, function() end)
        end

        if RageUI.Visible(shopMenu) then
            shopMenu:IsVisible(function(Items)
                for _, item in ipairs(currentNPC.items or {}) do
                    Items:AddButton(item.label, "Prix: " .. item.price .. "$/u", {RightLabel = "→"}, function(onSelected)
                        if onSelected then
                            local count = OpenQuantityInput()
                            if count and count > 0 then
                                ESX.TriggerServerCallback('az_container:buyItem', function(success)
                                    if success then
                                        exports['az_notify']:ShowNotification("~g~Achat réussi : " .. count .. "x " .. item.label)
                                    else
                                        exports['az_notify']:ShowNotification("~r~Pas assez d'argent ou de place.")
                                    end
                                end, item.name, item.price, count)
                            end
                        end
                    end)
                end
            end, function() end)
        end

        if RageUI.Visible(weaponMenu) then
            weaponMenu:IsVisible(function(Items)
                local playerPed = PlayerPedId()
                local weaponHash = GetSelectedPedWeapon(playerPed)
                
                if weaponHash ~= `WEAPON_UNARMED` then
                    local shownCount = 0
                    for _, comp in ipairs(weaponAttachments) do
                        local isCompatible = true
                        -- Safety check: Some builds don't have this native
                        if DoesWeaponTakeWeaponComponent then
                             isCompatible = DoesWeaponTakeWeaponComponent(weaponHash, comp.hash)
                        end

                        if isCompatible then
                            local hasComp = HasPedGotWeaponComponent(playerPed, weaponHash, comp.hash)
                            Items:CheckBox(comp.label, nil, hasComp, {}, function(onSelected, IsChecked)
                                if onSelected then
                                    ToggleWeaponComponent(comp.hash)
                                end
                            end)
                            shownCount = shownCount + 1
                        end
                    end
                    if shownCount == 0 then 
                        Items:AddSeparator("~r~Aucun composant compatible avec cette arme") 
                    end
                else
                    Items:AddSeparator("~r~Sortez une arme pour la modifier")
                end
            end, function() end)
        end

        if RageUI.Visible(vehicleMenu) then
            vehicleMenu:IsVisible(function(Items)
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if vehicle ~= 0 then
                    Items:AddButton("Réparer le véhicule", nil, {RightLabel = "→"}, function(onSelected)
                        if onSelected then
                            SetVehicleFixed(vehicle)
                            SetVehicleDeformationFixed(vehicle)
                            exports['az_notify']:ShowNotification("~g~Véhicule réparé")
                        end
                    end)
                    Items:AddButton("Maxer les performances", nil, {RightLabel = "→"}, function(onSelected)
                        if onSelected then
                            SetVehicleModKit(vehicle, 0)
                            SetVehicleMod(vehicle, 11, GetNumVehicleMods(vehicle, 11) - 1, false) 
                            SetVehicleMod(vehicle, 12, GetNumVehicleMods(vehicle, 12) - 1, false) 
                            SetVehicleMod(vehicle, 13, GetNumVehicleMods(vehicle, 13) - 1, false) 
                            ToggleVehicleMod(vehicle, 18, true) 
                            exports['az_notify']:ShowNotification("~g~Moteur maxé !")
                        end
                    end)
                else
                    Items:AddSeparator("~r~Montez dans un véhicule")
                end
            end, function() end)
        end

        if RageUI.Visible(teleporterMenu) then
            teleporterMenu:IsVisible(function(Items)
                for _, loc in ipairs(currentNPC.locations or {}) do
                    Items:AddButton(loc.label, nil, {RightLabel = "→"}, function(onSelected)
                        if onSelected then
                            RageUI.Visible(teleporterMenu, false)
                            SetEntityCoords(PlayerPedId(), loc.coords)
                            exports['az_notify']:ShowNotification("~g~Téléporté vers " .. loc.label)
                        end
                    end)
                end
            end, function() end)
        end
    end
end)

function ToggleWeaponComponent(componentHash)
    local playerPed = PlayerPedId()
    local weaponHash = GetSelectedPedWeapon(playerPed)
    local weaponName = GetWeaponNameFromHash(weaponHash)
    
    if not weaponName then return exports['az_notify']:ShowNotification("~r~Arme non supportée.") end

    ESX.TriggerServerCallback('az_container:saveWeaponComponent', function(success)
        if success then
            exports['az_notify']:ShowNotification("~g~Composant mis à jour")
        end
    end, weaponName, componentHash)
end
