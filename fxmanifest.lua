-- ██╗  ██╗ ██████╗     ██████╗ ███████╗██╗   ██╗███████╗██╗      ██████╗ ██████╗ ███████╗██████╗ 
-- ██║  ██║██╔════╝     ██╔══██╗██╔════╝██║   ██║██╔════╝██║     ██╔═══██╗██╔══██╗██╔════╝██╔══██╗
-- ███████║██║  ███╗    ██║  ██║█████╗  ██║   ██║█████╗  ██║     ██║   ██║██████╔╝█████╗  ██████╔╝
-- ██╔══██║██║   ██║    ██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║     ██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗
-- ██║  ██║╚██████╔╝    ██████╔╝███████╗ ╚████╔╝ ███████╗███████╗╚██████╔╝██║     ███████╗██║  ██║
-- ╚═╝  ╚═╝ ╚═════╝     ╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝

fx_version 'adamant'
games { 'gta5'}

name 'hg_garage'
description 'HG DEVELOPER | GARAGE FREE'
discord 'https://discord.gg/ZmsRXSdPxV'
author 'HG DEVELOPER'

shared_scripts {
   'config/config.ganeral.lua',
   'config/config.function.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',

	'source/title_en.lua',
	'source/server.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config/garage/config.ganeral.lua',
	'config/garage/config.location.lua',
	'config/job/config.ganeral.lua',
	'config/job/config.location.lua',
	'config/pound/config.ganeral.lua',
	'config/pound/config.location.lua',


	'source/title_en.lua',
	'source/client.lua'
}


ui_page 'interface/index.html'

files {
	'interface/**',
}