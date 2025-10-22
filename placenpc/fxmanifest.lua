lua54 'yes'
fx_version 'cerulean'
game 'gta5'

author 'Original: Andyyy#7666 | Fixed Export by Kuncoroada'
description 'DPEmotes with GetDPTable export for external script integration'
version '1.0.1'

-- 🌐 Shared config
shared_scripts {
    'config.lua'
}

-- 💻 Client scripts
client_scripts {
    'Client/EmoteList.lua',
    'Client/AnimationList.lua',
    'Client/EmoteMenu.lua',
    'Client/Keybinds.lua',
    'Client/Sync.lua',
    'Client/Walks.lua',
    'Client/Expressions.lua',
    'Client/EmoteChat.lua',
    'Client/PropAttach.lua',
    'Client/HandsUp.lua',
    'Client/CancelEmote.lua',
    'Client/Pointing.lua',
    'Client/Crouch.lua',
    'Client/EmoteLogic.lua',
    'Client/main.lua'
}

-- 🧠 Server scripts (optional, if used)
server_scripts {
    'Server/main.lua'
}

-- 🧩 Exports (penting buat NPCs)
export 'GetDPTable'

-- 🧱 Dependencies (jika ada resource lain yang wajib aktif)
dependency '/assetpacks'

-- 📂 Files (jika butuh NUI / prop configs)
files {
    'animations.json',
    'config.lua'
}

-- ✳️ Escrow Ignore (agar tetap bisa edit konfigurasi)
escrow_ignore {
    'config.lua',
    'Client/*.lua',
    'Server/*.lua'
}

-- ✨ Informasi tambahan
description 'Modified DPEmotes for NPC Integration (includes GetDPTable export)'
