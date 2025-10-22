-- DPEmotes Bridge Loader
-- Mengambil DPEmotes dari resource aslinya agar bisa digunakan di placenpc

CreateThread(function()
    local resourceName = "dpemotes" -- ganti jika nama resource kamu berbeda, misal "dpemotes2"

    local dpemotes = GetResourceState(resourceName)
    if dpemotes ~= "started" then
        print(("[NPCs] ⚠️ Resource '%s' belum aktif. Jalankan dulu dpemotes sebelum placenpc."):format(resourceName))
        return
    end

    -- Coba ambil global DP dari dpemotes
    if not DP then
        local chunk = LoadResourceFile(resourceName, "client/EmoteList.lua")
        if chunk then
            local f, err = load(chunk)
            if f then
                f()
                print("[NPCs] ✅ DPEmotes berhasil dimuat dari resource " .. resourceName)
            else
                print("[NPCs] ❌ Gagal load DPEmotes: " .. tostring(err))
            end
        else
            print("[NPCs] ❌ Tidak menemukan file EmoteList.lua di resource " .. resourceName)
        end
    else
        print("[NPCs] ✅ DPEmotes sudah aktif (global DP terdeteksi)")
    end
end)
