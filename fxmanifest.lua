fx_version 'cerulean'
lua54 'yes'
game 'gta5'
-- use_fxv2_oal 'yes'

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
	"@vrp/lib/Tunnel.lua",
	"@vrp/lib/Proxy.lua",
	'config.lua',
	'server/main.lua',
}

client_scripts {
	"@vrp/client/Tunnel.lua",
	"@vrp/client/Proxy.lua",
	'config.lua',
	'client/scaleform.lua',
	'client/main.lua',
	'client/PauseMenu.lua',
}

