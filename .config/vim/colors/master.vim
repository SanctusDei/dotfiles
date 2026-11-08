" Tokyo Night Moon inspired palette, adapted for opaque terminal Vim.
hi clear
if exists('syntax_on')
    syntax reset
endif
let g:colors_name = 'master'
hi Normal guifg=#D6DEED ctermfg=254 guibg=#1F2530 ctermbg=235 gui=NONE cterm=NONE
hi MasterInactive guifg=#BCC6D8 ctermfg=251 guibg=#1B212B ctermbg=235 gui=NONE cterm=NONE
hi MasterSidebar guifg=#D6DEED ctermfg=254 guibg=#1B212B ctermbg=235 gui=NONE cterm=NONE
hi Comment guifg=#7C8AA3 ctermfg=103 gui=italic cterm=italic
hi Constant guifg=#FF9E64 ctermfg=215 gui=NONE cterm=NONE
hi String guifg=#B7C9B0 ctermfg=151 gui=NONE cterm=NONE
hi Character guifg=#B7C9B0 ctermfg=151 gui=NONE cterm=NONE
hi Number guifg=#FF9E64 ctermfg=215 gui=NONE cterm=NONE
hi Boolean guifg=#FF9E64 ctermfg=215 gui=NONE cterm=NONE
hi Identifier guifg=#D6DEED ctermfg=254 gui=NONE cterm=NONE
hi Function guifg=#82AAFF ctermfg=111 gui=NONE cterm=NONE
hi Statement guifg=#BB9AF7 ctermfg=141 gui=NONE cterm=NONE
hi PreProc guifg=#86CFC3 ctermfg=115 gui=NONE cterm=NONE
hi Type guifg=#E0AF68 ctermfg=179 gui=NONE cterm=NONE
hi Special guifg=#86CFC3 ctermfg=115 gui=NONE cterm=NONE
hi Delimiter guifg=#BCC6D8 ctermfg=251 gui=NONE cterm=NONE
hi Operator guifg=#BB9AF7 ctermfg=141 gui=NONE cterm=NONE
hi LineNr guifg=#63718A ctermfg=60 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi CursorLineNr guifg=#82AAFF ctermfg=111 guibg=#2A3446 ctermbg=237 gui=NONE cterm=NONE
hi CursorLine guibg=#2A3446 ctermbg=237 gui=NONE cterm=NONE
hi SignColumn guifg=#7C8AA3 ctermfg=103 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi FoldColumn guifg=#7C8AA3 ctermfg=103 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi VertSplit guifg=#3C475C ctermfg=239 guibg=#1F2530 ctermbg=235 gui=NONE cterm=NONE
hi StatusLine guifg=#D6DEED ctermfg=254 guibg=#343E52 ctermbg=238 gui=NONE cterm=NONE
hi StatusLineNC guifg=#7C8AA3 ctermfg=103 guibg=#272F3F ctermbg=236 gui=NONE cterm=NONE
hi StatusLineTerm guifg=#D6DEED ctermfg=254 guibg=#343E52 ctermbg=238 gui=NONE cterm=NONE
hi StatusLineTermNC guifg=#7C8AA3 ctermfg=103 guibg=#272F3F ctermbg=236 gui=NONE cterm=NONE
hi Visual guibg=#38465E ctermbg=239 gui=NONE cterm=NONE
hi Search guifg=#D6DEED ctermfg=254 guibg=#3D4666 ctermbg=239 gui=NONE cterm=NONE
hi IncSearch guifg=#1F2530 ctermfg=235 guibg=#86CFC3 ctermbg=115 gui=NONE cterm=NONE
hi MatchParen guifg=#86CFC3 ctermfg=115 guibg=#343E52 ctermbg=238 gui=NONE cterm=NONE
hi Pmenu guifg=#D6DEED ctermfg=254 guibg=#2A3446 ctermbg=237 gui=NONE cterm=NONE
hi PmenuSel guifg=#82AAFF ctermfg=111 guibg=#3C475C ctermbg=239 gui=NONE cterm=NONE
hi PmenuSbar guibg=#343E52 ctermbg=238 gui=NONE cterm=NONE
hi PmenuThumb guibg=#7C8AA3 ctermbg=103 gui=NONE cterm=NONE
hi NonText guifg=#3C475C ctermfg=239 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi EndOfBuffer guifg=#3C475C ctermfg=239 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi SpecialKey guifg=#63718A ctermfg=60 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi Directory guifg=#82AAFF ctermfg=111 gui=NONE cterm=NONE
hi Title guifg=#BB9AF7 ctermfg=141 gui=NONE cterm=NONE
hi Error guifg=#F7768E ctermfg=210 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi WarningMsg guifg=#E0AF68 ctermfg=179 gui=NONE cterm=NONE
hi ErrorMsg guifg=#F7768E ctermfg=210 gui=NONE cterm=NONE
hi Todo guifg=#E0AF68 ctermfg=179 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi DiffAdd guibg=#2C3A36 ctermbg=236 gui=NONE cterm=NONE
hi DiffChange guibg=#2D384E ctermbg=237 gui=NONE cterm=NONE
hi DiffDelete guifg=#F7768E ctermfg=210 guibg=#442F3D ctermbg=237 gui=NONE cterm=NONE
hi DiffText guibg=#3D4666 ctermbg=239 gui=NONE cterm=NONE
hi ALEErrorSign guifg=#F7768E ctermfg=210 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi ALEWarningSign guifg=#E0AF68 ctermfg=179 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi ALEError gui=undercurl cterm=undercurl guisp=#F7768E
hi ALEWarning gui=undercurl cterm=undercurl guisp=#E0AF68

" Define these before plugin syntax runs, so hi-default links preserve them.
hi NERDTreeDir guifg=#82AAFF ctermfg=111 gui=NONE cterm=NONE
hi NERDTreeUp guifg=#86CFC3 ctermfg=115 gui=NONE cterm=NONE
hi NERDTreeFile guifg=#D6DEED ctermfg=254 gui=NONE cterm=NONE
hi NERDTreeCWD guifg=#BB9AF7 ctermfg=141 gui=NONE cterm=NONE
hi NERDTreeOpenable guifg=#7C8AA3 ctermfg=103 gui=NONE cterm=NONE
hi NERDTreeClosable guifg=#7C8AA3 ctermfg=103 gui=NONE cterm=NONE
hi NERDTreeExecFile guifg=#86CFC3 ctermfg=115 gui=NONE cterm=NONE
hi TagbarKind guifg=#86CFC3 ctermfg=115 gui=NONE cterm=NONE
hi TagbarScope guifg=#82AAFF ctermfg=111 gui=NONE cterm=NONE
hi TagbarType guifg=#E0AF68 ctermfg=179 gui=NONE cterm=NONE
hi TagbarAccessPublic guifg=#B7C9B0 ctermfg=151 gui=NONE cterm=NONE
hi TagbarAccessProtected guifg=#E0AF68 ctermfg=179 gui=NONE cterm=NONE
hi TagbarAccessPrivate guifg=#F7768E ctermfg=210 gui=NONE cterm=NONE
hi NERDTreeCurrentNode guifg=#D6DEED ctermfg=254 guibg=#2A3446 ctermbg=237 gui=NONE cterm=NONE
hi TagbarHighlight guifg=#D6DEED ctermfg=254 guibg=#2A3446 ctermbg=237 gui=NONE cterm=NONE
hi! link masterCFunction Function
hi! link masterPythonType Type
