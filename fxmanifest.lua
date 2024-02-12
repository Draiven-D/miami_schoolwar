fx_version 'adamant'

game 'gta5'

description 'SCHOOL WAR BY DRIVE'

version '1.0.0'

-- data_file 'DLC_ITYP_REQUEST' 'stream/p_bigdice.ytyp'
-- data_file 'DLC_ITYP_REQUEST' 'stream/p_bigdice2.ytyp'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	-- 'server.lua',
}

client_scripts {
	'client.lua',
}

ui_page 'html/ui.html'

files {
    'html/main.css',
    'html/main.js',
    'html/ui.html'
}

exports {
	'getStatus'
}