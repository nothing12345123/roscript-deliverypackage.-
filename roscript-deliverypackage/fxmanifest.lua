fx_version 'cerulean'
game 'gta5'

author 'Roscript'
description 'Roscript'
version '1.0.0' -- 

lua54 'yes'  -- Lua 5.4を有効にする

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',            -- ox_libの初期化スクリプト
    'locales/en.lua'                 -- ローカライズファイル
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- 
    'server/server.lua'
}

client_scripts {
    'client/client.lua'
}

dependencies {
 'ox_lib'    -- ox_libライブラリ
}