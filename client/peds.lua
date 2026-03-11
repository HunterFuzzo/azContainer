local spawnedPeds = {}
local stashProp = nil

-- Blips Manager
Citizen.CreateThread(function()
    Wait(2000)
    -- NPC Blips
    for _, npc in ipairs(Config.NPCs or {}) do
        local blip = AddBlipForCoord(npc.coords.x, npc.coords.y, npc.coords.z)
        SetBlipSprite(blip, 280) 
        if npc.type == 'shop' then SetBlipSprite(blip, 52)
        elseif npc.type == 'weapon' then SetBlipSprite(blip, 110)
        elseif npc.type == 'vehicle' then SetBlipSprite(blip, 446)
        elseif npc.type == 'clothing' then SetBlipSprite(blip, 73)
        elseif npc.type == 'teleporter' then SetBlipSprite(blip, 407)
        end
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(npc.label)
        EndTextCommandSetBlipName(blip)
    end
    
    -- Stash Blip
    local stashPos = Config.StashLocation
    local stashBlip = AddBlipForCoord(stashPos.x, stashPos.y, stashPos.z)
    SetBlipSprite(stashBlip, 50)
    SetBlipDisplay(stashBlip, 4)
    SetBlipScale(stashBlip, 0.8)
    SetBlipColour(stashBlip, 5)
    SetBlipAsShortRange(stashBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("My chest")
    EndTextCommandSetBlipName(stashBlip)
end)

-- Entity Manager (Spawning/Cleanup) - 1Hz
Citizen.CreateThread(function()
    local stashModel = `p_v_43_safe_s`
    
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- 1. STASH PROP
        local stashPos = vector3(Config.StashLocation.x, Config.StashLocation.y, Config.StashLocation.z)
        local stashDist = #(playerCoords - stashPos)
        
        if stashDist < 60.0 then
            if not stashProp or not DoesEntityExist(stashProp) then
                -- Cleanup any residue first
                local existing = GetClosestObjectOfType(stashPos.x, stashPos.y, stashPos.z, 2.0, stashModel, false, false, false)
                if DoesEntityExist(existing) then DeleteObject(existing) end

                RequestModel(stashModel)
                while not HasModelLoaded(stashModel) do Wait(10) end
                
                stashProp = CreateObject(stashModel, stashPos.x, stashPos.y, stashPos.z - 0.98, false, false, false)
                SetEntityHeading(stashProp, Config.StashLocation.h or 0.0)
                FreezeEntityPosition(stashProp, true)
            end
        else
            if stashProp and DoesEntityExist(stashProp) then DeleteObject(stashProp) stashProp = nil end
        end

        -- 2. NPC PEDS
        for i, npc in ipairs(Config.NPCs or {}) do
            local npcPos = vector3(npc.coords.x, npc.coords.y, npc.coords.z)
            local dist = #(playerCoords - npcPos)

            if dist < 60.0 then
                if not spawnedPeds[i] or not DoesEntityExist(spawnedPeds[i]) then
                    -- Cleanup residue
                    local existing = GetClosestPed(npc.coords.x, npc.coords.y, npc.coords.z, 2.0, 0, 0, 0, 0, 0)
                    if DoesEntityExist(existing) and not IsPedAPlayer(existing) then DeleteEntity(existing) end

                    RequestModel(npc.model)
                    while not HasModelLoaded(npc.model) do Wait(10) end
                    
                    local h = (npc.coords.h or 0.0) + 0.0
                    local zOffset = -0.98
                    if npc.type == 'shop' then zOffset = -1.0 end -- Subtle adjustment

                    local ped = CreatePed(4, npc.model, npc.coords.x, npc.coords.y, npc.coords.z + zOffset, h, false, true)
                    SetEntityHeading(ped, h)
                    SetEntityAsMissionEntity(ped, true, true)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    SetEntityInvincible(ped, true)
                    FreezeEntityPosition(ped, true)
                    spawnedPeds[i] = ped
                end
            else
                if spawnedPeds[i] then DeleteEntity(spawnedPeds[i]) spawnedPeds[i] = nil end
            end
        end
        Wait(1000)
    end
end)

-- Unified Interaction Loop (High Frequency) - FIXES FLICKERING/LAG
Citizen.CreateThread(function()
    while true do
        local sleep = 500
        local playerCoords = GetEntityCoords(PlayerPedId())
        local showingHelp = false

        -- Check Stash
        local stashPos = vector3(Config.StashLocation.x, Config.StashLocation.y, Config.StashLocation.z)
        if #(playerCoords - stashPos) < 2.0 then
            sleep = 0
            ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le ~y~Coffre")
            if IsControlJustPressed(0, 38) then
                TriggerEvent('az_inventory:openStash')
            end
            showingHelp = true
        end

        -- Check NPCs (if stash not showing)
        if not showingHelp then
            for i, npc in ipairs(Config.NPCs or {}) do
                local npcPos = vector3(npc.coords.x, npc.coords.y, npc.coords.z)
                if #(playerCoords - npcPos) < 2.5 then
                    sleep = 0
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour : ~y~" .. npc.label)
                    if IsControlJustPressed(0, 38) then
                        OpenNPCMenu(npc)
                    end
                    showingHelp = true
                    break
                end
            end
        end

        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if stashProp and DoesEntityExist(stashProp) then DeleteObject(stashProp) end
        for _, ped in pairs(spawnedPeds) do if DoesEntityExist(ped) then DeleteEntity(ped) end end
    end
end)
