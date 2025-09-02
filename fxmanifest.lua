fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Muhaddil'
description 'A simple NPC bed configurator for FiveM'
version 'v0.0.3-beta'

shared_script {
    '@ox_lib/init.lua',
    'config.lua'
}

client_script 'client.lua'
server_script 'server.lua'

dependency 'ox_lib'