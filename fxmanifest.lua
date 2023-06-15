fx_version 'cerulean'
lua54 'yes'
game 'gta5'
-- use_fxv2_oal 'yes'

version '3.2.1'

files {
	'html/*.*',
	'html/img/*.*',
	'html/img/games/*.*',
	'html/img/games/map/*.*',
	'html/sounds/*.*',
}

ui_page 'html/ui.html'

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
