fx_version 'cerulean'
game 'gta5'

description 'mg-vipsystem'
author 'Miguex'
version '1.2'

shared_scripts {
    'shared/config.lua',
    'locales/*.lua'
}

client_scripts {
    'GetCore.lua',
    'client/main.lua',
    'client/editable.lua'
}
server_scripts {
	-- '@mysql-async/lib/MySQL.lua', -- ⚠️ PLEASE READ ⚠️ | Uncomment this line if you use 'mysql-async' ⚠️
    'GetCore.lua',
    'server/functions.lua',
    'server/main.lua',
    'shared/server_config.lua'
}


ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/images/*.png',
    'html/images/items/*.png',
    'html/images/vehicles/*.png',
    'html/images/weapons/*.png',
    'html/images/tiers/*.png',
    'html/images/mlos/*.png',
}

escrow_ignore {
	'shared/config.lua',
    'shared/server_config.lua',
	'GetCore.lua',
	'client/main.lua',
	'server/main.lua',
    'client/editable.lua',
	'server/functions.lua',
    'locales/*.lua'
}

lua54 'yes'

dependency '/assetpacks'