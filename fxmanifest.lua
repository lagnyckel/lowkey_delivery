fx_version 'cerulean'
games { 'gta5' }
author 'author'

client_scripts {
    'c_main.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    's_main.lua'
}

shared_scripts {
    'config.lua'
}
