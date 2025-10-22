--------------------------------------------------------
-- 🔁 GROUP EMOTE SYNC SYSTEM (by Xeno)
-- Sinkronisasi NPC dengan emote pemain
--------------------------------------------------------

local syncActiveEmote = nil

-- Fungsi ambil emote dari dpemotes
local function getDPEmote(emoteName)
    if not emoteName or emoteName == "" then return nil end
    local dpResource = "dpemotes"
    local ok, DPData = pcall(function() return exports[dpResource]:GetDPTable() end)
    if not ok or not DPData then return nil end

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
    return nil
end

-- Fungsi buat NPC ikut animasi
local function playEmoteOnNearbyNPCs(emoteName)
    local anim = getDPEmote(emoteName)
    if not anim then
        print("[Sync] Emote tidak ditemukan:", emoteName)
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for name, ped in pairs(createdNPCs) do
        if DoesEntityExist(ped) then
            local dist = #(playerCoords - GetEntityCoords(ped))
            if dist < 15.0 then
                local dict, nameAnim = anim[1], anim[2]

                if dict == "Scenario" then
                    TaskStartScenarioInPlace(ped, nameAnim, 0, true)
                else
                    local loop = (anim.AnimationOptions and anim.AnimationOptions.EmoteLoop) and 1 or 0
                    RequestAnimDict(dict)
                    while not HasAnimDictLoaded(dict) do Wait(5) end
                    TaskPlayAnim(ped, dict, nameAnim, 8.0, -8.0, -1, loop, 0, false, false, false)
                end
            end
        end
    end
end

-- Fungsi stop semua NPC anim
local function stopNPCEmotes()
    for name, ped in pairs(createdNPCs) do
        if DoesEntityExist(ped) then
            ClearPedTasks(ped)
        end
    end
end

--------------------------------------------------------
-- 🔸 EVENT: DETEKSI EMOTE PEMAIN
-- (harus panggil dari dpemotes export event)
--------------------------------------------------------

-- Hook ke event custom dpemotes (pastikan ada export)
RegisterNetEvent('dpemotes:PlayEmote')
AddEventHandler('dpemotes:PlayEmote', function(emoteName)
    syncActiveEmote = emoteName
    playEmoteOnNearbyNPCs(emoteName)
end)

RegisterNetEvent('dpemotes:StopEmote')
AddEventHandler('dpemotes:StopEmote', function()
    syncActiveEmote = nil
    stopNPCEmotes()
end)

--------------------------------------------------------
-- 🔹 Fallback Command (manual)
--------------------------------------------------------
RegisterCommand('groupemote', function(_, args)
    local emoteName = args[1]
    if not emoteName then
        print("Usage: /groupemote [namaemote]")
        return
    end
    playEmoteOnNearbyNPCs(emoteName)
end, false)

RegisterCommand('groupstop', function()
    stopNPCEmotes()
end, false)
