" Native Vim layout and focus styling; no overlay windows or key mappings.
let s:timer = -1
let s:focus_timer = -1
let s:busy = 0

function! s:Windows() abort
    return filter(getwininfo(), 'v:val.tabnr == tabpagenr() && v:val.winnr > 0')
endfunction

function! s:SetOption(window, option, value) abort
    if getwinvar(a:window, '&' . a:option) !=# a:value
        call setwinvar(a:window, '&' . a:option, a:value)
    endif
endfunction

function! masterui#Focus(...) abort
    " A layout update also satisfies any pending focus refresh.
    if s:focus_timer >= 0
        call timer_stop(s:focus_timer)
        let s:focus_timer = -1
    endif
    if get(g:, 'colors_name', '') !=# 'master'
        return
    endif
    let l:active = win_getid()
    for l:w in s:Windows()
        let l:ft = getbufvar(l:w.bufnr, '&filetype')
        if index(['nerdtree', 'tagbar'], l:ft) >= 0
            call s:SetOption(l:w.winid, 'wincolor', 'MasterSidebar')
            call s:SetOption(l:w.winid, 'cursorline', l:w.winid == l:active)
        elseif getbufvar(l:w.bufnr, '&buftype') ==# ''
            call s:SetOption(l:w.winid, 'wincolor', l:w.winid == l:active ? '' : 'MasterInactive')
            call s:SetOption(l:w.winid, 'cursorline', l:w.winid == l:active)
        endif
    endfor
endfunction

function! masterui#Layout(timer) abort
    let s:timer = -1
    if s:busy || !empty(getcmdwintype())
        return
    endif
    let s:busy = 1
    try
        let l:windows = s:Windows()
        let l:left = filter(copy(l:windows), 'getbufvar(v:val.bufnr, "&filetype") ==# "nerdtree"')
        let l:right = filter(copy(l:windows), 'getbufvar(v:val.bufnr, "&filetype") ==# "tagbar"')
        let l:count = len(l:left) + len(l:right)
        let l:usable = max([1, &columns - l:count])
        let l:tree = max([12, l:usable * 18 / 100])
        let l:tags = max([14, l:usable * 19 / 100])
        " Keep approximately 63% for code; shrink sidebars on narrow terminals.
        let l:center = min([72, max([24, l:usable * 63 / 100])])
        let l:budget = max([l:count, l:usable - l:center])
        let l:requested = len(l:left) * l:tree + len(l:right) * l:tags
        if l:requested > l:budget
            let l:tree = max([1, l:tree * l:budget / l:requested])
            let l:tags = max([1, (l:budget - len(l:left) * l:tree) / max([1, len(l:right)])])
        endif
        let g:NERDTreeWinSize = l:tree
        let g:tagbar_width = l:tags
        for l:w in l:left + l:right
            let l:width = getbufvar(l:w.bufnr, '&filetype') ==# 'nerdtree' ? l:tree : l:tags
            if l:w.width != l:width
                call win_execute(l:w.winid, 'silent noautocmd vertical resize ' . l:width)
            endif
        endfor
        call masterui#Focus()
    finally
        let s:busy = 0
    endtry
endfunction

function! masterui#Schedule() abort
    if s:busy
        return
    endif
    if s:timer >= 0
        call timer_stop(s:timer)
    endif
    let s:timer = timer_start(35, function('masterui#Layout'))
endfunction

" Plugins temporarily visit other windows inside their WinEnter handlers.
function! masterui#ScheduleFocus() abort
    if s:focus_timer >= 0
        call timer_stop(s:focus_timer)
    endif
    let s:focus_timer = timer_start(10, function('masterui#Focus'))
endfunction

" Keep NERDTree's directory browsing behavior with command-based loading.
function! masterui#BrowseDirectory(path) abort
    call plug#load('nerdtree')
    if get(g:, 'NERDTreeHijackNetrw', 1)
        silent! autocmd! FileExplorer
        call nerdtree#checkForBrowse(a:path)
    endif
endfunction
