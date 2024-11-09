fx_version 'cerulean'
game 'gta5'
description 'Made by Kacperek'
lua54 'yes'
server_scripts {
  "@oxmysql/lib/MySQL.lua",
  'server.lua'
}
client_script 'client.lua'

shared_scripts {
  '@ox_lib/init.lua',
  '@es_extended/imports.lua',
  "config.lua"
}