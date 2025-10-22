local spawnedNPCs = {}
local resourceStarted = false

local function debugLog(message)
    if Config and Config.Debug then
        print(message)
    end
end

local function LoadNPCs()
    debugLog("^2[NPCs] Attempting to load NPCs from database...^7")
    local NPCs = MySQL.query.await('SELECT * FROM npcs')

    if not NPCs then
        debugLog("^1[NPCs] Failed to load NPCs from database^7")
        return {}
    end

    for _, npc in ipairs(NPCs) do
        npc.coords = vector3(npc.x, npc.y, npc.z)
        npc.animation = {
            dict = npc.anim_dict,
            name = npc.anim_name
        }
        spawnedNPCs[npc.id] = true
    end
    return NPCs
end

RegisterNetEvent('xeno-placenpc:spawnNPC')
AddEventHandler('xeno-placenpc:spawnNPC', function(npcData)
    local npcId = npcData.id
    if spawnedNPCs[npcId] then return end
    spawnedNPCs[npcId] = true
end)

RegisterNetEvent('xeno-placenpc:removeNPC')
AddEventHandler('xeno-placenpc:removeNPC', function(npcId)
    if spawnedNPCs[npcId] then
        spawnedNPCs[npcId] = nil
    end
end)

RegisterServerEvent('npcs:addToConfig')
AddEventHandler('npcs:addToConfig', function(npcData)
    print("^2[NPCs] Saving NPC to database...^7")
    local success = MySQL.insert.await('INSERT INTO npcs (model, x, y, z, heading, anim_dict, anim_name, name) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        npcData.model,
        npcData.coords.x,
        npcData.coords.y,
        npcData.coords.z,
        npcData.heading,
        npcData.anim_dict or nil,
        npcData.anim_name or nil,
        npcData.name or nil
    })
    if success then
        print(string.format("^2[NPCs] Saved NPC: %s (%s)^7", npcData.name or "Unnamed", npcData.model))
    else
        print("^1[NPCs] Failed to save NPC^7")
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    print("^2[NPCs] Resource starting...^7")
    resourceStarted = true
end)

RegisterNetEvent('npcs:playerJoined')
AddEventHandler('npcs:playerJoined', function()
    local src = source
    if not resourceStarted then return end
    local NPCs = LoadNPCs()
    if #NPCs > 0 then
        TriggerClientEvent('npcs:loadNPCs', src, NPCs)
    end
end)

RegisterServerEvent('npcs:checkPermission')
AddEventHandler('npcs:checkPermission', function()
    local src = source
    local hasPermission = true -- bypass permission
    TriggerClientEvent('npcs:permissionResponse', src, hasPermission)
end)
