fx_version 'cerulean'
lua54 'yes'
game 'gta5'
-- use_fxv2_oal 'yes'

version '3.4.8.2'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
	'server/main.lua',
	'server/lobbymenu.lua',
}

client_scripts {
	'client/ScaleformUI.lua',
	'client/scaleform.lua',
	'config.lua',
	'client/function.lua',
	'client/main.lua',
	'client/PauseMenu.lua',

	'client/menu/menu_lobby.lua',
	'client/menu/menu_player.lua',
}


files {
	'client/ui/*.*',
	'client/ui/img/*.*',
	'client/ui/img/games/*.*',
	'client/ui/img/games/map/*.*',
	'client/ui/sounds/*.*',

	'files/MINIMAP_LOADER.gfx',
}

ui_page 'client/ui/ui.html'
