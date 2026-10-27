fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

author 'bzhar'
description 'Makeup & Lifestyle'
version '1.0.0'

ui_page 'nui://jo_libs/nui/menu/index.html'

shared_scripts {
  '@jo_libs/init.lua',
  'config.lua',
  'locales/en.lua',
  'shared/lang.lua',
  'shared/makeup.lua',
}

client_scripts {
  'client/apply.lua',
  'client/menu.lua',
  'client/main.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/main.lua',
}

dependencies {
  'jo_libs',
  'vorp_core',
  'oxmysql',
}

jo_libs {
  'menu',
  'prompt',
  'pedTexture',
  'notif',
  'dataview',
}

escrow_ignore {
  'config.lua',
  'locales/en.lua',
}
