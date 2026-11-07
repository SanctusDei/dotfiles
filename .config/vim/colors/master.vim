" Muted blue/cyan theme with standard terminal fallbacks.
hi clear
if exists('syntax_on')
    syntax reset
endif
let g:colors_name = 'master'
hi Normal       guifg=#d8dee9 guibg=#202630 ctermfg=253 ctermbg=235
hi Comment      guifg=#8090a4 gui=italic ctermfg=244
hi Constant     guifg=#b9a0cc ctermfg=140
hi String       guifg=#a3be8c ctermfg=150
hi Character    guifg=#a3be8c ctermfg=150
hi Number       guifg=#b9a0cc ctermfg=140
hi Boolean      guifg=#b9a0cc ctermfg=140
hi Identifier   guifg=#d8dee9 ctermfg=253
hi Function     guifg=#88c0d0 ctermfg=116
hi Statement    guifg=#81a1c1 gui=bold ctermfg=110
hi PreProc      guifg=#8fbcbb ctermfg=109
hi Type         guifg=#8fbcbb ctermfg=109
hi Special      guifg=#ebcb8b ctermfg=222
hi Delimiter    guifg=#c4cbd6 ctermfg=251
hi Operator     guifg=#81a1c1 ctermfg=110
hi LineNr       guifg=#596779 guibg=#202630 ctermfg=60 ctermbg=235
hi CursorLineNr guifg=#88c0d0 guibg=#293240 gui=bold ctermfg=116 ctermbg=236
hi CursorLine   guibg=#293240 ctermbg=236 cterm=NONE
hi SignColumn   guifg=#8090a4 guibg=#202630 ctermfg=244 ctermbg=235
hi VertSplit    guifg=#414d5d guibg=#202630 ctermfg=240 ctermbg=235
hi StatusLine   guifg=#d8dee9 guibg=#3b495c gui=NONE ctermfg=253 ctermbg=238
hi StatusLineNC guifg=#8090a4 guibg=#293240 gui=NONE ctermfg=244 ctermbg=236
hi Visual       guibg=#414f66 ctermbg=239
hi Search       guifg=#202630 guibg=#ebcb8b ctermfg=235 ctermbg=222
hi IncSearch    guifg=#202630 guibg=#88c0d0 ctermfg=235 ctermbg=116
hi Pmenu        guifg=#d8dee9 guibg=#303c4c ctermfg=253 ctermbg=237
hi PmenuSel     guifg=#202630 guibg=#88c0d0 ctermfg=235 ctermbg=116
hi PmenuSbar    guibg=#414d5d ctermbg=240
hi PmenuThumb   guibg=#8090a4 ctermbg=244
hi NonText      guifg=#414d5d ctermfg=240
hi SpecialKey   guifg=#596779 ctermfg=60
hi Directory    guifg=#88c0d0 ctermfg=116
hi Title        guifg=#88c0d0 gui=bold ctermfg=116
hi Error        guifg=#bf616a guibg=NONE ctermfg=167
hi WarningMsg   guifg=#ebcb8b ctermfg=222
hi ErrorMsg     guifg=#bf616a ctermfg=167
hi Todo         guifg=#ebcb8b guibg=NONE gui=bold ctermfg=222
hi DiffAdd      guibg=#304536 ctermbg=22
hi DiffChange   guibg=#303d52 ctermbg=24
hi DiffDelete   guifg=#bf616a guibg=#4b3038 ctermfg=167 ctermbg=52
hi DiffText     guibg=#435570 ctermbg=60
hi ALEErrorSign   guifg=#bf616a guibg=#202630 ctermfg=167 ctermbg=235
hi ALEWarningSign guifg=#ebcb8b guibg=#202630 ctermfg=222 ctermbg=235
hi ALEError       gui=undercurl guisp=#bf616a cterm=underline
hi ALEWarning     gui=undercurl guisp=#ebcb8b cterm=underline
