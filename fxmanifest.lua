fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Muhaddil'
description 'A simple NPC bed configurator for FiveM'
version 'v0.0.93-beta'

ui_page 'html/build/index.html'

files {
    'html/build/index.html',
    'html/build/assets/**/*',
}

shared_script {
    '@ox_lib/init.lua',
    'shared/*'
}

client_script 'client/*'
server_script 'server/*'

dependency 'ox_lib'
