fx_version 'cerulean'
game 'gta5'

author 'Roscript'
description 'Roscript Helper -Cams'
version '1.0.0' 

lua54 'yes' 

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',         
    'locales/en.lua'                 
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- 
    'server/server.lua'
}

client_scripts {
    'client/client.lua'
}

dependencies {
 'ox_lib'    
}
