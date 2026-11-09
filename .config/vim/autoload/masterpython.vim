" Present unused Python symbols as dim text rather than ALE problems.
function! masterpython#Setup() abort
    for l:linter in ale#linter#Get('python')
        if l:linter.name ==# 'ruff'
            let l:linter.callback = 'masterpython#RuffHandle'
        endif
    endfor
    if empty(prop_type_get('MasterPythonUnused'))
        call prop_type_add('MasterPythonUnused', {
                    \ 'highlight': 'MasterPythonUnused',
                    \ 'priority': 110, 'combine': 0,
                    \ })
    endif
endfunction

function! masterpython#RuffHandle(buffer, lines) abort
    let l:items = ale_linters#python#ruff#Handle(a:buffer, a:lines)
    if !bufloaded(a:buffer)
        return l:items
    endif
    let l:diagnostics = []
    let l:unused = []
    for l:item in l:items
        if index(['F401', 'F841', 'F842'], get(l:item, 'code', '')) >= 0
                    \ || get(l:item, 'code', '') =~# '^ARG00[1-5]$'
            call add(l:unused, l:item)
        else
            call add(l:diagnostics, l:item)
        endif
    endfor
    let l:tick = getbufvar(a:buffer, 'changedtick')
    let l:previous = getbufvar(a:buffer, 'master_python_unused', {})
    if get(l:previous, 'tick', -1) == l:tick
                \ && get(l:previous, 'items', []) ==# l:unused
        return l:diagnostics
    endif
    call prop_remove({'type': 'MasterPythonUnused', 'all': 1,
                \ 'bufnr': a:buffer}, 1, getbufinfo(a:buffer)[0].linecount)
    for l:item in l:unused
        " Ruff columns count characters; Vim properties use byte columns.
        for l:lnum in range(l:item.lnum, l:item.end_lnum)
            let l:lines = getbufline(a:buffer, l:lnum)
            if empty(l:lines)
                continue
            endif
            let l:text = l:lines[0]
            let l:start = l:lnum == l:item.lnum
                        \ ? byteidx(l:text, l:item.col - 1) : 0
            let l:end = l:lnum == l:item.end_lnum
                        \ ? byteidx(l:text, l:item.end_col) : strlen(l:text)
            if l:start >= 0 && l:end > l:start
                call prop_add(l:lnum, l:start + 1, {
                            \ 'bufnr': a:buffer, 'type': 'MasterPythonUnused',
                            \ 'length': l:end - l:start,
                            \ })
            endif
        endfor
    endfor
    call setbufvar(a:buffer, 'master_python_unused',
                \ {'tick': l:tick, 'items': l:unused})
    return l:diagnostics
endfunction
