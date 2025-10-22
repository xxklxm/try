local createdNPCs = {}
local hasLoadedNPCs = false

local function debugLog(msg)
    if Config and Config.Debug then print(msg) end
end

----------------------------------------------------------
-- 🔹 DPEmotes Loader (auto detect with capital folder)
----------------------------------------------------------
CreateThread(function()
    local dpResource = "dpemotes" -- nama folder resource kamu
    local possiblePaths = {
        "Client/EmoteList.lua",
        "Client/Emotes.lua",
        "Client/DP_Emotes.lua",
        "Client/AnimationList.lua"
    }

    local loaded = false
    for _, path in ipairs(possiblePaths) do
        local chunk = LoadResourceFile(dpResource, path)
        if chunk then
            local fn, err = load(chunk, "DPEmotes", "t", _G)
            if fn then
                local ok, result = pcall(fn)
                if ok then
                    loaded = true
                    print(("[NPCs] ✅ DPEmotes loaded successfully from '%s/%s'"):format(dpResource, path))
                    break
                else
                    print(("[NPCs] ⚠️ Failed to run %s: %s"):format(path, tostring(result)))
                end
            end
        end
    end

    if not loaded then
        print("[NPCs] ❌ Tidak menemukan definisi DPEmotes. Pastikan path benar (Client/*.lua).")
    end
end)


-- =====================================================
-- ================  BASIC UTILS  ======================
-- =====================================================

local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
end

local function makeNPCInvincible(ped)
    SetEntityInvincible(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedCanBeTargetted(ped, false)
    SetPedCanBeKnockedOffVehicle(ped, false)
    SetPedDiesWhenInjured(ped, false)
    SetPedConfigFlag(ped, 188, true)
end

local function attachPropToNPC(ped, propName, bone, x, y, z, rx, ry, rz)
    local model = GetHashKey(propName)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    local obj = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, bone or 57005),
        x or 0.0, y or 0.0, z or 0.0, rx or 0.0, ry or 0.0, rz or 0.0,
        true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(model)
    return obj
end

----------------------------------------------------------
-- 🔹 Ambil Emote langsung dari exports DPEmotes
----------------------------------------------------------
local function getDPEmote(emoteName)
    if not emoteName or emoteName == "" then return nil end

    local dpResource = "dpemotes" -- nama folder resource kamu
    local success, DPData = pcall(function()
        return exports[dpResource]:GetDPTable()
    end)

    if not success or not DPData then
        print("[NPCs] ⚠️ Gagal ambil DP data dari exports. Pastikan dpemotes aktif & punya export GetDPTable.")
        return nil
    end

    -- cari di semua kategori
    local pools = {
        DPData.Emotes,
        DPData.PropEmotes,
        DPData.Dances,
        DPData.Shared,
        DPData.Expressions,
        DPData.Walks,
        DPData.Scenarios
    }

    for _, pool in ipairs(pools) do
        if pool and pool[emoteName] then
            return pool[emoteName]
        end
    end

    print(("[NPCs] ⚠️ Emote '%s' tidak ditemukan di DPEmotes."):format(emoteName))
    return nil
end


-- =====================================================
-- ================  NPC SPAWNER  ======================
-- =====================================================

local function spawnNPC(npcData)
    debugLog("^2[NPCs] Spawning NPC...^7")

    if not npcData.model then
        debugLog("^1[NPCs] Error: No model specified^7")
        return
    end

    loadModel(npcData.model)
    local coords = npcData.coords or GetEntityCoords(PlayerPedId())
    local ped = CreatePed(4, npcData.model, coords.x, coords.y, coords.z - 1.0, npcData.heading or 0.0, false, true)

    if not DoesEntityExist(ped) then
        debugLog("^1[NPCs] Failed to create ped!^7")
        return
    end

    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    makeNPCInvincible(ped)

    local emoteName = npcData.anim_name
    local anim = getDPEmote(emoteName)

    if anim then
        local dict, name = anim[1], anim[2]

        -- Support Scenario (like smoke, sit, etc)
        if dict == "Scenario" then
            TaskStartScenarioInPlace(ped, name, 0, true)
            debugLog(("[NPCs] ▶ Scenario started '%s'"):format(name))
        else
            local loopFlag = (anim.AnimationOptions and anim.AnimationOptions.EmoteLoop) and 1 or 0
            loadAnimDict(dict)
            TaskPlayAnim(ped, dict, name, 8.0, -8.0, -1, loopFlag, 0, false, false, false)
            debugLog(("[NPCs] ▶ Playing anim '%s' (dict=%s, anim=%s, loop=%s)"):format(emoteName, dict, name, tostring(loopFlag == 1)))

            -- Prop handling
            if anim.AnimationOptions then
                if anim.AnimationOptions.Prop then
                    local prop = anim.AnimationOptions.Prop
                    local bone = anim.AnimationOptions.PropBone or 57005
                    local pos = anim.AnimationOptions.PropPlacement
                    if pos then
                        attachPropToNPC(ped, prop, bone, pos[1], pos[2], pos[3], pos[4], pos[5], pos[6])
                        debugLog(("[NPCs] 🪄 Attached prop '%s'"):format(prop))
                    end
                end
                if anim.AnimationOptions.Prop2 then
                    local prop2 = anim.AnimationOptions.Prop2
                    local bone2 = anim.AnimationOptions.PropBone2 or 18905
                    local pos2 = anim.AnimationOptions.PropPlacement2
                    if pos2 then
                        attachPropToNPC(ped, prop2, bone2, pos2[1], pos2[2], pos2[3], pos2[4], pos2[5], pos2[6])
                        debugLog(("[NPCs] 🪄 Attached secondary prop '%s'"):format(prop2))
                    end
                end
            end
        end
    else
        debugLog(("[NPCs] ⚠️ Emote '%s' not found in DPEmotes"):format(tostring(emoteName)))
    end

    local name = npcData.name or ("NPC_" .. tostring(#createdNPCs + 1))
    createdNPCs[name] = ped

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName("🧍 NPC created: " .. name)
    EndTextCommandThefeedPostTicker(true, false)
end

-- =====================================================
-- ================  NPC CLEANUP  ======================
-- =====================================================

RegisterCommand('clearnpc', function(_, args)
    if not args[1] then
        for n, ped in pairs(createdNPCs) do
            if DoesEntityExist(ped) then DeleteEntity(ped) end
        end
        createdNPCs = {}
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName('🧹 All NPCs deleted')
        EndTextCommandThefeedPostTicker(true, false)
        return
    end

    local name = table.concat(args, " ")
    for n, ped in pairs(createdNPCs) do
        if string.lower(n) == string.lower(name) then
            if DoesEntityExist(ped) then DeleteEntity(ped) end
            createdNPCs[n] = nil
            BeginTextCommandThefeedPost('STRING')
            AddTextComponentSubstringPlayerName('🧹 Deleted NPC: ' .. n)
            EndTextCommandThefeedPostTicker(true, false)
            return
        end
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName('⚠️ No NPC found with name: ' .. name)
    EndTextCommandThefeedPostTicker(true, false)
end, false)

-- =====================================================
-- ================  NUI CALLBACKS  ====================
-- =====================================================

RegisterNUICallback('createNPC', function(data, cb)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    local npcData = {
        model = data.model,
        coords = coords,
        heading = heading,
        name = data.name,
        anim_name = data.animName
    }

    spawnNPC(npcData)
    TriggerServerEvent('npcs:addToConfig', npcData)

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName('✅ NPC placed successfully')
    EndTextCommandThefeedPostTicker(true, false)
    cb('ok')
end)

RegisterNUICallback('toggleCursor', function(data, cb)
    SetNuiFocus(data.show, data.show)
    cb('ok')
end)

-- =====================================================
-- ================  LOAD EVENT  =======================
-- =====================================================

RegisterNetEvent('npcs:loadNPCs')
AddEventHandler('npcs:loadNPCs', function(npcs)
    if hasLoadedNPCs then return end
    for _, npc in ipairs(npcs) do
        spawnNPC(npc)
        Wait(100)
    end
    hasLoadedNPCs = true
end)

AddEventHandler('onClientResourceStart', function(res)
    if (GetCurrentResourceName() ~= res) then return end
    while not NetworkIsPlayerActive(PlayerId()) do Wait(100) end
    Wait(1000)
    TriggerServerEvent('npcs:playerJoined')
end)

-- =====================================================
-- ================  OPEN UI COMMAND  ==================
-- =====================================================

local function openNPCUI()
    SendNUIMessage({ type = 'openUI' })
    SetNuiFocus(true, true)
end

RegisterCommand('placenpc', function()
    TriggerServerEvent('npcs:checkPermission')
end, false)

RegisterNetEvent('npcs:permissionResponse')
AddEventHandler('npcs:permissionResponse', function(hasPermission)
    if hasPermission then
        openNPCUI()
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName('❌ You do not have permission to place NPCs')
        EndTextCommandThefeedPostTicker(true, false)
    end
end)

-- =====================================================
-- ================  RESOURCE STOP  ====================
-- =====================================================

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() ~= res then return end
    for n, ped in pairs(createdNPCs) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    createdNPCs = {}
    print("[NPCs] Resource stopped → all NPCs deleted.")
end)
