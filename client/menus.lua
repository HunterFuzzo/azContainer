local mainMenu = RageUI.CreateMenu("Services", "Choose a service")
local shopMenu = RageUI.CreateSubMenu(mainMenu, "Grocery", "Available items")
local weaponMenu = RageUI.CreateSubMenu(mainMenu, "Gunsmith", "Weapon components")
local vehicleMenu = RageUI.CreateSubMenu(mainMenu, "Mechanic", "Customization (Bag)")
local customMenu = RageUI.CreateSubMenu(vehicleMenu, "Modification", "Modify your vehicle")

local colorMenu = RageUI.CreateSubMenu(customMenu, "Colors", "Primary & Secondary")
local performanceMenu = RageUI.CreateSubMenu(customMenu, "Performance", "Engine, Brakes, etc.")
local cosmeticMenu = RageUI.CreateSubMenu(customMenu, "Cosmetics", "Spoiler, Bumper, etc.")
local wheelsMenu = RageUI.CreateSubMenu(customMenu, "Wheels", "Types of rims")
local tintMenu = RageUI.CreateSubMenu(customMenu, "Window Tint", "Windows tint")

local teleporterMenu = RageUI.CreateSubMenu(mainMenu, "Teleporter", "Destinations")

local currentModVehicle = nil -- Entity or {item = "name", mods = {}}
local isCustomizingBag = false
local bagVehicles = {}
local previewVehicle = nil

local colorsList = {0,1,2,3,4,5,6,12,27,28,38,50,90,111,120}
local performanceLevels = {"Level 1", "Level 2", "Level 3", "Level 4"}
local performanceLevels3 = {"Level 1", "Level 2", "Level 3"}
local tintsList = {"Normal", "Dark Black", "Light Black", "Limo", "Green", "Smoked"}
local cosmeticOptions = {"Default", "Option 1", "Option 2", "Option 3"}
local cosmeticOptions2 = {"Default", "Option 1", "Option 2"}
local wheelTypes = {"Sport", "Muscle", "Lowrider", "SUV", "Offroad", "Tuner", "Bike"}

local function GetListIndex(list, value)
    if value == nil then return 1 end
    for i, v in ipairs(list) do
        if v == value then
            return i
        end
    end
    return 1
end

local currentNPC = nil
local playerComponents = {}
local weaponAttachments = { 
    -- Suppressors
    {label = "Silencieux", hash = `COMPONENT_AT_AR_SUPP`, type = "suppressor"},
    {label = "Silencieux (AR)", hash = `COMPONENT_AT_AR_SUPP_02`, type = "suppressor"},
    {label = "Silencieux (Pistol)", hash = `COMPONENT_AT_PI_SUPP`, type = "suppressor"},
    {label = "Silencieux (Pistol .50)", hash = `COMPONENT_AT_PI_SUPP_02`, type = "suppressor"},
    {label = "Silencieux (Sniper)", hash = `COMPONENT_AT_SR_SUPP`, type = "suppressor"},
    {label = "Silencieux (Heavy Sniper)", hash = `COMPONENT_AT_SR_SUPP_03`, type = "suppressor"},

    -- Flashlights
    {label = "Lampe", hash = `COMPONENT_AT_AR_FLSH`, type = "flashlight"},
    {label = "Lampe (Pistol)", hash = `COMPONENT_AT_PI_FLSH`, type = "flashlight"},

    -- Grips
    {label = "Poignée", hash = `COMPONENT_AT_AR_AFG`, type = "grip"},
    {label = "Poignée (SMG)", hash = `COMPONENT_AT_PI_COMP`, type = "grip"},

    -- Scopes
    {label = "Viseur Holographique", hash = `COMPONENT_AT_SCOPE_MACRO`, type = "scope"},
    {label = "Viseur Point Rouge", hash = `COMPONENT_AT_SCOPE_MACRO_02`, type = "scope"},
    {label = "Viseur Moyen", hash = `COMPONENT_AT_SCOPE_MEDIUM`, type = "scope"},
    {label = "Viseur Large", hash = `COMPONENT_AT_SCOPE_LARGE`, type = "scope"},
    {label = "Viseur Avancé", hash = `COMPONENT_AT_SCOPE_MAX`, type = "scope"},
    {label = "Lunette Sniper", hash = `COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM`, type = "scope"},
    {label = "Lunette Avancée", hash = `COMPONENT_AT_SCOPE_NV`, type = "scope"},
    {label = "Lunette Thermique", hash = `COMPONENT_AT_SCOPE_THERMAL`, type = "scope"},

    -- MK2 Specifics
    {label = "Viseur Holo (MK2)", hash = `COMPONENT_AT_SIGHTS`, type = "scope"},
    {label = "Viseur Macro (MK2)", hash = `COMPONENT_AT_SIGHTS_02`, type = "scope"},
    {label = "Viseur Zoom (MK2)", hash = `COMPONENT_AT_SCOPE_MACRO_02_MK2`, type = "scope"},
    {label = "Viseur Small (MK2)", hash = `COMPONENT_AT_SCOPE_SMALL_MK2`, type = "scope"},
    {label = "Viseur Medium (MK2)", hash = `COMPONENT_AT_SCOPE_MEDIUM_MK2`, type = "scope"},
    {label = "Lunette Large (MK2)", hash = `COMPONENT_AT_SCOPE_LARGE_MK2`, type = "scope"},
    {label = "Lunette Avancée (MK2)", hash = `COMPONENT_AT_SCOPE_MAX_MK2`, type = "scope"},
    {label = "Lunette NV (MK2)", hash = `COMPONENT_AT_SCOPE_NV_MK2`, type = "scope"},
    {label = "Lunette Thermique (MK2)", hash = `COMPONENT_AT_SCOPE_THERMAL_MK2`, type = "scope"},
    {label = "Compensateur (MK2)", hash = `COMPONENT_AT_MUZZLE_01`, type = "muzzle"},
    {label = "Frein de bouche (MK2)", hash = `COMPONENT_AT_MUZZLE_02`, type = "muzzle"},
    {label = "Muzzle Flash (MK2)", hash = `COMPONENT_AT_MUZZLE_03`, type = "muzzle"},
    {label = "Muzzle Heavy (MK2)", hash = `COMPONENT_AT_MUZZLE_04`, type = "muzzle"},
    {label = "Canon lourd (MK2)", hash = `COMPONENT_AT_AR_BARREL_01`, type = "barrel"},
    {label = "Canon court (MK2)", hash = `COMPONENT_AT_AR_BARREL_02`, type = "barrel"},
    
    -- Clips Specific
    {label = "Chargeur étendu (Pistol)", hash = `COMPONENT_PISTOL_CLIP_02`, type = "clip"},
    {label = "Chargeur tambour (Pistol)", hash = `COMPONENT_PISTOL_CLIP_03`, type = "clip"},
    {label = "Chargeur étendu (Combat P)", hash = `COMPONENT_COMBATPISTOL_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (AP Pistol)", hash = `COMPONENT_APPISTOL_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (Pistol .50)", hash = `COMPONENT_PISTOL50_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (Micro SMG)", hash = `COMPONENT_MICROSMG_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (SMG)", hash = `COMPONENT_SMG_CLIP_02`, type = "clip"},
    {label = "Chargeur tambour (SMG)", hash = `COMPONENT_SMG_CLIP_03`, type = "clip"},
    {label = "Chargeur étendu (Assault SMG)", hash = `COMPONENT_ASSAULTSMG_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (PDW)", hash = `COMPONENT_COMBATPDW_CLIP_02`, type = "clip"},
    {label = "Chargeur tambour (PDW)", hash = `COMPONENT_COMBATPDW_CLIP_03`, type = "clip"},
    {label = "Chargeur étendu (Machine Pistol)", hash = `COMPONENT_MACHINEPISTOL_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (Mini SMG)", hash = `COMPONENT_MINISMG_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (AR)", hash = `COMPONENT_ASSAULTRIFLE_CLIP_02`, type = "clip"},
    {label = "Chargeur tambour (AR)", hash = `COMPONENT_ASSAULTRIFLE_CLIP_03`, type = "clip"},
    {label = "Chargeur étendu (Carbine)", hash = `COMPONENT_CARBINERIFLE_CLIP_02`, type = "clip"},
    {label = "Chargeur tambour (Carbine)", hash = `COMPONENT_CARBINERIFLE_CLIP_03`, type = "clip"},
    {label = "Chargeur étendu (Advanced)", hash = `COMPONENT_ADVANCEDRIFLE_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (Special Carb)", hash = `COMPONENT_SPECIALCARBINE_CLIP_02`, type = "clip"},
    {label = "Chargeur tambour (Special Carb)", hash = `COMPONENT_SPECIALCARBINE_CLIP_03`, type = "clip"},
    {label = "Chargeur étendu (Bullpup)", hash = `COMPONENT_BULLPUPRIFLE_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (Compact)", hash = `COMPONENT_COMPACTRIFLE_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (MG)", hash = `COMPONENT_MG_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (Combat MG)", hash = `COMPONENT_COMBATMG_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (Sniper)", hash = `COMPONENT_MARKSMANRIFLE_CLIP_02`, type = "clip"},
    {label = "Chargeur tambour (Sniper)", hash = `COMPONENT_MARKSMANRIFLE_CLIP_03`, type = "clip"},
    {label = "Chargeur étendu (Heavy Shotgun)", hash = `COMPONENT_HEAVYSHOTGUN_CLIP_02`, type = "clip"},
    {label = "Chargeur tambour (Heavy Shotgun)", hash = `COMPONENT_HEAVYSHOTGUN_CLIP_03`, type = "clip"},
    
    -- Mk2 Clips
    {label = "Chargeur étendu (Pistol MK2)", hash = `COMPONENT_PISTOL_MK2_CLIP_02`, type = "clip"},
    {label = "Balles incendiaires (Pistol MK2)", hash = `COMPONENT_PISTOL_MK2_CLIP_04`, type = "clip"},
    {label = "Chargeur étendu (SMG MK2)", hash = `COMPONENT_SMG_MK2_CLIP_02`, type = "clip"},
    {label = "Balles incendiaires (SMG MK2)", hash = `COMPONENT_SMG_MK2_CLIP_04`, type = "clip"},
    {label = "Chargeur étendu (AR MK2)", hash = `COMPONENT_ASSAULTRIFLE_MK2_CLIP_02`, type = "clip"},
    {label = "Balles perforantes (AR MK2)", hash = `COMPONENT_ASSAULTRIFLE_MK2_CLIP_03`, type = "clip"},
    {label = "Chargeur étendu (Carbine MK2)", hash = `COMPONENT_CARBINERIFLE_MK2_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (Special Carb MK2)", hash = `COMPONENT_SPECIALCARBINE_MK2_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (Bullpup MK2)", hash = `COMPONENT_BULLPUPRIFLE_MK2_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (Combat MG MK2)", hash = `COMPONENT_COMBATMG_MK2_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (Heavy Sniper MK2)", hash = `COMPONENT_HEAVYSNIPER_MK2_CLIP_02`, type = "clip"},
    {label = "Balles explosives (Heavy Sniper MK2)", hash = `COMPONENT_HEAVYSNIPER_MK2_CLIP_03`, type = "clip"},
    {label = "Chargeur étendu (Marksman MK2)", hash = `COMPONENT_MARKSMANRIFLE_MK2_CLIP_02`, type = "clip"},
    {label = "Chargeur étendu (Pump MK2)", hash = `COMPONENT_PUMPSHOTGUN_MK2_CLIP_02`, type = "clip"},
    
    -- Tints/Skins (Common Variants)
    {label = "Skin Luxe (Pistol)", hash = `COMPONENT_PISTOL_VARMOD_LUXE`, type = "skin"},
    {label = "Skin Luxe (Combat P)", hash = `COMPONENT_COMBATPISTOL_VARMOD_LOWRIDER`, type = "skin"},
    {label = "Skin Luxe (AP Pistol)", hash = `COMPONENT_APPISTOL_VARMOD_LUXE`, type = "skin"},
    {label = "Skin Luxe (Pistol .50)", hash = `COMPONENT_PISTOL50_VARMOD_LUXE`, type = "skin"},
    {label = "Skin Luxe (Micro SMG)", hash = `COMPONENT_MICROSMG_VARMOD_LUXE`, type = "skin"},
    {label = "Skin Luxe (SMG)", hash = `COMPONENT_SMG_VARMOD_LUXE`, type = "skin"},
    {label = "Skin Luxe (AR)", hash = `COMPONENT_ASSAULTRIFLE_VARMOD_LUXE`, type = "skin"},
    {label = "Skin Luxe (Carbine)", hash = `COMPONENT_CARBINERIFLE_VARMOD_LUXE`, type = "skin"},
    {label = "Skin Luxe (Advanced)", hash = `COMPONENT_ADVANCEDRIFLE_VARMOD_LUXE`, type = "skin"},
    {label = "Skin Luxe (Sniper)", hash = `COMPONENT_SNIPERRIFLE_VARMOD_LUXE`, type = "skin"},
    {label = "Skin Luxe (Heavy Sniper)", hash = `COMPONENT_HEAVYSNIPER_VARMOD_LUXE`, type = "skin"},
    {label = "Skin Luxe (Combat MG)", hash = `COMPONENT_COMBATMG_VARMOD_LOWRIDER`, type = "skin"},
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
        [`WEAPON_SNSPISTOL`] = "WEAPON_SNSPISTOL",
        [`WEAPON_HEAVYPISTOL`] = "WEAPON_HEAVYPISTOL",
        [`WEAPON_VINTAGEPISTOL`] = "WEAPON_VINTAGEPISTOL",
        [`WEAPON_FLAREGUN`] = "WEAPON_FLAREGUN",
        [`WEAPON_MARKSMANPISTOL`] = "WEAPON_MARKSMANPISTOL",
        [`WEAPON_REVOLVER`] = "WEAPON_REVOLVER",
        [`WEAPON_DOUBLEACTION`] = "WEAPON_DOUBLEACTION",
        [`WEAPON_CERAMICPISTOL`] = "WEAPON_CERAMICPISTOL",
        [`WEAPON_GADGETPISTOL`] = "WEAPON_GADGETPISTOL",
        [`WEAPON_PISTOL_MK2`] = "WEAPON_PISTOL_MK2",
        --[`WEAPON_SNSPISTOL_MK2`] = "WEAPON_SNSPISTOL_MK2", -- admin weapon
        [`WEAPON_REVOLVER_MK2`] = "WEAPON_REVOLVER_MK2",
        
        -- SMGs
        [`WEAPON_MICROSMG`] = "WEAPON_MICROSMG",
        [`WEAPON_SMG`] = "WEAPON_SMG",
        [`WEAPON_ASSAULTSMG`] = "WEAPON_ASSAULTSMG",
        [`WEAPON_COMBATPDW`] = "WEAPON_COMBATPDW",
        [`WEAPON_MACHINEPISTOL`] = "WEAPON_MACHINEPISTOL",
        [`WEAPON_MINISMG`] = "WEAPON_MINISMG",
        [`WEAPON_SMG_MK2`] = "WEAPON_SMG_MK2",
        
        -- Shotguns
        [`WEAPON_PUMPSHOTGUN`] = "WEAPON_PUMPSHOTGUN",
        [`WEAPON_SAWNOFFSHOTGUN`] = "WEAPON_SAWNOFFSHOTGUN",
        [`WEAPON_ASSAULTSHOTGUN`] = "WEAPON_ASSAULTSHOTGUN",
        [`WEAPON_BULLPUPSHOTGUN`] = "WEAPON_BULLPUPSHOTGUN",
        [`WEAPON_MUSKET`] = "WEAPON_MUSKET",
        [`WEAPON_HEAVYSHOTGUN`] = "WEAPON_HEAVYSHOTGUN",
        [`WEAPON_DBLSHOTGUN`] = "WEAPON_DBLSHOTGUN",
        [`WEAPON_AUTOSHOTGUN`] = "WEAPON_AUTOSHOTGUN",
        [`WEAPON_COMBATSHOTGUN`] = "WEAPON_COMBATSHOTGUN",
        [`WEAPON_PUMPSHOTGUN_MK2`] = "WEAPON_PUMPSHOTGUN_MK2",
        
        -- Assault Rifles
        [`WEAPON_ASSAULTRIFLE`] = "WEAPON_ASSAULTRIFLE",
        [`WEAPON_CARBINERIFLE`] = "WEAPON_CARBINERIFLE",
        [`WEAPON_ADVANCEDRIFLE`] = "WEAPON_ADVANCEDRIFLE",
        [`WEAPON_SPECIALCARBINE`] = "WEAPON_SPECIALCARBINE",
        [`WEAPON_BULLPUPRIFLE`] = "WEAPON_BULLPUPRIFLE",
        [`WEAPON_COMPACTRIFLE`] = "WEAPON_COMPACTRIFLE",
        [`WEAPON_MILITARYRIFLE`] = "WEAPON_MILITARYRIFLE",
        [`WEAPON_HEAVYRIFLE`] = "WEAPON_HEAVYRIFLE",
        [`WEAPON_TACTICALRIFLE`] = "WEAPON_TACTICALRIFLE",
        [`WEAPON_ASSAULTRIFLE_MK2`] = "WEAPON_ASSAULTRIFLE_MK2",
        [`WEAPON_CARBINERIFLE_MK2`] = "WEAPON_CARBINERIFLE_MK2",
        [`WEAPON_SPECIALCARBINE_MK2`] = "WEAPON_SPECIALCARBINE_MK2",
        [`WEAPON_BULLPUPRIFLE_MK2`] = "WEAPON_BULLPUPRIFLE_MK2",
        
        -- LMGs
        [`WEAPON_MG`] = "WEAPON_MG",
        [`WEAPON_COMBATMG`] = "WEAPON_COMBATMG",
        [`WEAPON_COMBATMG_MK2`] = "WEAPON_COMBATMG_MK2",
        
        -- Snipers
        [`WEAPON_SNIPERRIFLE`] = "WEAPON_SNIPERRIFLE",
        [`WEAPON_HEAVYSNIPER`] = "WEAPON_HEAVYSNIPER",
        [`WEAPON_MARKSMANRIFLE`] = "WEAPON_MARKSMANRIFLE",
        [`WEAPON_PRECISIONRIFLE`] = "WEAPON_PRECISIONRIFLE",
        [`WEAPON_HEAVYSNIPER_MK2`] = "WEAPON_HEAVYSNIPER_MK2",
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
    AddTextEntry('FMMC_KEY_TIP8', "Desired quantity")
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
        local sleep = 500
        local isAnyMenuVisible = RageUI.Visible(mainMenu) or RageUI.Visible(shopMenu) or RageUI.Visible(weaponMenu) or 
                                 RageUI.Visible(vehicleMenu) or RageUI.Visible(customMenu) or RageUI.Visible(colorMenu) or 
                                 RageUI.Visible(performanceMenu) or RageUI.Visible(cosmeticMenu) or RageUI.Visible(wheelsMenu) or 
                                 RageUI.Visible(tintMenu) or RageUI.Visible(teleporterMenu)

        if isAnyMenuVisible or previewVehicle then
            sleep = 0
            
            -- Logic to cleanup preview when mecano menu is closed
            if not isAnyMenuVisible and previewVehicle then
                CleanupPreviewVehicle()
            end

            if RageUI.Visible(mainMenu) then
                mainMenu:IsVisible(function(Items)
                    if currentNPC.type == 'shop' then
                        Items:AddButton("Access the grocery", nil, {RightLabel = "→"}, function(onSelected)
                        end, shopMenu)
                    elseif currentNPC.type == 'weapon' then
                        Items:AddButton("Modify my weapon", nil, {RightLabel = "→"}, function(onSelected)
                        end, weaponMenu)
                    elseif currentNPC.type == 'vehicle' then
                        Items:AddButton("Customize my vehicle", nil, {RightLabel = "→"}, function(onSelected)
                            if onSelected then
                                ESX.TriggerServerCallback('az_container:getVehiclesInBag', function(vehicles)
                                    bagVehicles = vehicles
                                end)
                            end
                        end, vehicleMenu)
                    elseif currentNPC.type == 'clothing' then
                        Items:AddButton("Change style", nil, {RightLabel = "→"}, function(onSelected)
                            if onSelected then
                                RageUI.Visible(mainMenu, false)
                                TriggerEvent('esx_skin:openSaveableMenu')
                            end
                        end)
                    elseif currentNPC.type == 'teleporter' then
                        Items:AddButton("Teleport", nil, {RightLabel = "→"}, function(onSelected)
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
                                            exports['az_notify']:ShowNotification("~g~Purchase successful : " .. count .. "x " .. item.label)
                                        else
                                            exports['az_notify']:ShowNotification("~r~Not enough money or space.")
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

                    if weaponHash == `WEAPON_SNSPISTOL_MK2` then
                        Items:AddSeparator("~r~You cannot modify this weapon.") 
                        return
                    end

                    if weaponHash ~= `WEAPON_UNARMED` then
                        local shownCount = 0
                        for _, comp in ipairs(weaponAttachments) do
                            local isCompatible = true
                            if DoesWeaponTakeWeaponComponent then
                                 isCompatible = DoesWeaponTakeWeaponComponent(weaponHash, comp.hash)
                            end

                            if isCompatible then
                                local hasComp = HasPedGotWeaponComponent(playerPed, weaponHash, comp.hash)
                                Items:CheckBox(comp.label, nil, hasComp, {}, function(onSelected, IsChecked)
                                    if onSelected then
                                        ToggleWeaponComponent(comp)
                                    end
                                end)
                                shownCount = shownCount + 1
                            end
                        end
                        if shownCount == 0 then 
                            Items:AddSeparator("~r~No compatible components for this weapon") 
                        end
                    else
                        Items:AddSeparator("~r~Take out a weapon to modify it")
                    end
                end, function() end)
            end

            if RageUI.Visible(vehicleMenu) then
                vehicleMenu:IsVisible(function(Items)
                    if #bagVehicles > 0 then
                        for _, v in ipairs(bagVehicles) do
                            Items:AddButton(v.label, "Cliquez pour modifier (Preview)", {RightLabel = "→"}, function(onSelected)
                                if onSelected then
                                    currentModVehicle = v
                                    isCustomizingBag = true
                                    SpawnPreviewVehicle(v.name, v.mods)
                                end
                            end, customMenu)
                        end
                    else
                        Items:AddSeparator("~r~Aucun véhicule dans votre sac")
                    end
                end, function() end)
            end

            if RageUI.Visible(customMenu) then
                customMenu:IsVisible(function(Items)
                    if not isCustomizingBag and not DoesEntityExist(currentModVehicle) then
                        RageUI.GoBack()
                        return
                    end

                    Items:AddButton("Couleurs", nil, {RightLabel = "→"}, function() end, colorMenu)
                    Items:AddButton("Performances", nil, {RightLabel = "→"}, function() end, performanceMenu)
                    Items:AddButton("Esthétique", nil, {RightLabel = "→"}, function() end, cosmeticMenu)
                    Items:AddButton("Jantes", nil, {RightLabel = "→"}, function() end, wheelsMenu)
                    Items:AddButton("Vitres", nil, {RightLabel = "→"}, function() end, tintMenu)

                    if not isCustomizingBag then
                        Items:AddSeparator("~b~Actions Rapides")
                        Items:AddButton("Réparer le véhicule", nil, {RightLabel = "→"}, function(onSelected)
                            if onSelected then
                                SetVehicleFixed(currentModVehicle)
                                SetVehicleDeformationFixed(currentModVehicle)
                                exports['az_notify']:ShowNotification("~g~Véhicule réparé")
                            end
                        end)
                    end
                end, function() end)
            end

            HandleCustomizationMenus()

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
        Wait(sleep)
    end
end)

function ToggleWeaponComponent(componentData)
    local playerPed = PlayerPedId()
    local weaponHash = GetSelectedPedWeapon(playerPed)
    local weaponName = GetWeaponNameFromHash(weaponHash)
    
    if not weaponName then return exports['az_notify']:ShowNotification("~r~Arme non supportée.") end

    -- Find all conflicting components of the same type
    local conflictingHashes = {}
    if componentData.type then
        for _, comp in ipairs(weaponAttachments) do
            if comp.type == componentData.type and comp.hash ~= componentData.hash then
                table.insert(conflictingHashes, comp.hash)
            end
        end
    end

    ESX.TriggerServerCallback('az_container:saveWeaponComponent', function(success, removedHashes)
        if success then
            -- Immediately un-mount locally so UI refreshes cleanly without a flicker.
            if removedHashes and #removedHashes > 0 then
                for _, removedHash in ipairs(removedHashes) do
                    RemoveWeaponComponentFromPed(playerPed, weaponHash, removedHash)
                end
            end
            exports['az_notify']:ShowNotification("~g~Composant mis à jour")
        end
    end, weaponName, componentData.hash, conflictingHashes)
end
function HandleCustomizationMenus()
    -- Helpers
    local function GetCurrentProps()
        if isCustomizingBag then
            return currentModVehicle.mods or {}
        else
            return ESX.Game.GetVehicleProperties(currentModVehicle)
        end
    end

    local function ApplyMod(key, value)
        local props = GetCurrentProps()
        if not props then props = {} end
        props[key] = value

        if isCustomizingBag then
            currentModVehicle.mods = props
            TriggerServerEvent('az_container:saveVehicleBagMods', currentModVehicle.name, props)
        else
            ESX.Game.SetVehicleProperties(currentModVehicle, props)
        end
        
        if previewVehicle and DoesEntityExist(previewVehicle) then
            ESX.Game.SetVehicleProperties(previewVehicle, props)
        end
    end

    if RageUI.Visible(colorMenu) then
        colorMenu:IsVisible(function(Items)
            local props = GetCurrentProps()
            
            Items:AddList("Couleur Primaire", colorsList, GetListIndex(colorsList, props.color1), nil, {}, function(Index, Selected, Change)
                if Change then ApplyMod('color1', colorsList[Index]) end
            end)

            Items:AddList("Couleur Secondaire", colorsList, GetListIndex(colorsList, props.color2), nil, {}, function(Index, Selected, Change)
                if Change then ApplyMod('color2', colorsList[Index]) end
            end)
        end, function() end)
    end

    if RageUI.Visible(performanceMenu) then
        performanceMenu:IsVisible(function(Items)
            local props = GetCurrentProps()
            
            -- Engine (Mod 11)
            Items:AddList("Moteur", performanceLevels, (props.modEngine or -1) + 2, nil, {}, function(Index, Selected, Change)
                if Change then ApplyMod('modEngine', Index - 2) end
            end)

            -- Brakes (Mod 12)
            Items:AddList("Freins", performanceLevels3, (props.modBrakes or -1) + 2, nil, {}, function(Index, Selected, Change)
                if Change then ApplyMod('modBrakes', Index - 2) end
            end)

            -- Transmission (Mod 13)
            Items:AddList("Transmission", performanceLevels3, (props.modTransmission or -1) + 2, nil, {}, function(Index, Selected, Change)
                if Change then ApplyMod('modTransmission', Index - 2) end
            end)

            -- Suspension (Mod 15)
            Items:AddList("Suspension", performanceLevels, (props.modSuspension or -1) + 2, nil, {}, function(Index, Selected, Change)
                if Change then ApplyMod('modSuspension', Index - 2) end
            end)

            -- Turbo (Mod 18)
            local hasTurbo = props.modTurbo or false
            Items:CheckBox("Turbo", nil, hasTurbo, {}, function(Selected, Checked)
                if Selected then ApplyMod('modTurbo', Checked) end
            end)
        end, function() end)
    end

    if RageUI.Visible(cosmeticMenu) then
        cosmeticMenu:IsVisible(function(Items)
            local props = GetCurrentProps()

            Items:AddList("Aileron", cosmeticOptions, (props.modSpoilers or -1) + 2, nil, {}, function(Index, Selected, Change)
                if Change then ApplyMod('modSpoilers', Index - 2) end
            end)

            Items:AddList("Pare-choc Avant", cosmeticOptions2, (props.modFrontBumper or -1) + 2, nil, {}, function(Index, Selected, Change)
                if Change then ApplyMod('modFrontBumper', Index - 2) end
            end)

            Items:AddList("Échappement", cosmeticOptions2, (props.modExhaust or -1) + 2, nil, {}, function(Index, Selected, Change)
                if Change then ApplyMod('modExhaust', Index - 2) end
            end)
        end, function() end)
    end

    if RageUI.Visible(wheelsMenu) then
        wheelsMenu:IsVisible(function(Items)
            local props = GetCurrentProps()

            Items:AddList("Type de roues", wheelTypes, (props.wheels or 0) + 1, nil, {}, function(Index, Selected, Change)
                if Change then ApplyMod('wheels', Index - 1) end
            end)

            local wheelMods = {"Jante 1", "Jante 2", "Jante 3", "Jante 4", "Jante 5"}
            Items:AddList("Jantes", wheelMods, (props.modFrontWheels or -1) + 2, nil, {}, function(Index, Selected, Change)
                if Change then ApplyMod('modFrontWheels', Index - 2) end
            end)
        end, function() end)
    end

    if RageUI.Visible(tintMenu) then
        tintMenu:IsVisible(function(Items)
            local props = GetCurrentProps()
            
            Items:AddList("Teinte des vitres", tintsList, (props.windowTint or -1) + 2, nil, {}, function(Index, Selected, Change)
                if Change then ApplyMod('windowTint', Index - 2) end
            end)
            
            Items:CheckBox("Phares Xénon", nil, props.modXenon or false, {}, function(Selected, Checked)
                if Selected then ApplyMod('modXenon', Checked) end
            end)
        end, function() end)
    end
end

function SpawnPreviewVehicle(itemName, mods)
    CleanupPreviewVehicle()

    -- Convert 'VEHICLE_DELUXO' to 'deluxo'
    local modelName = string.lower(string.gsub(itemName, "VEHICLE_", ""))
    local model = GetHashKey(modelName)
    
    if not IsModelInCdimage(model) then 
        -- Fallback: try the raw itemName if the conversion didn't work (unlikely)
        model = GetHashKey(itemName)
        if not IsModelInCdimage(model) then return end
    end

    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 500 do 
        Wait(10) 
        timeout = timeout + 1
    end

    if not HasModelLoaded(model) then return end

    -- Fixed spawn location: exactly in front of the Mecano NPC (from Config.NPCs)
    -- NPC is at {x = -441.66, y = -906.43, z = 29.39, h = 90}
    -- We spawn it a bit further on the Y axis
    local spawnCoords = vector3(-441.66, -910.43, 29.39)
    local spawnHeading = 90.0

    previewVehicle = CreateVehicle(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnHeading, false, false)
    SetModelAsNoLongerNeeded(model)
    
    if previewVehicle ~= 0 then
        SetEntityAlpha(previewVehicle, 255, false) -- Max visibility
        SetVehicleModKit(previewVehicle, 0)
        SetEntityCollision(previewVehicle, false, false)
        FreezeEntityPosition(previewVehicle, true)
        
        if mods then
            ESX.Game.SetVehicleProperties(previewVehicle, mods)
        end
    end
end

function CleanupPreviewVehicle()
    if previewVehicle and DoesEntityExist(previewVehicle) then
        DeleteEntity(previewVehicle)
        previewVehicle = nil
    end
end
