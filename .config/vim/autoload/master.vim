" Small helpers, loaded only when used.
function! master#Tab() abort
    let l:col = col('.') - 1
    if l:col == 0 || getline('.')[l:col - 1] =~# '\s'
        return "\<Tab>"
    endif
    if master#InString()
        return "\<C-X>\<C-U>"
    endif
    " Use the language server, rather than only words from open buffers.
    return &omnifunc ==# 'ale#completion#OmniFunc' ? "\<C-X>\<C-O>" : "\<C-N>"
endfunction

function! master#RestorePosition() abort
    if &buftype ==# '' && &filetype !~# 'commit\|rebase' && line("'\"") > 0 && line("'\"") <= line('$')
        execute "normal! g`\""
    endif
endfunction

function! master#Format() abort
    if &buftype !=# '' || !&modifiable
        return
    endif
    if index(['python', 'c', 'cpp'], &filetype) >= 0
        let l:tool = &filetype ==# 'python' ? expand('~/.local/bin/ruff') : 'clang-format'
        if !executable(l:tool)
            echohl WarningMsg | echomsg 'Formatter missing: ' . l:tool | echohl None
            return
        endif
        ALEFix
    else
        let l:view = winsaveview()
        normal! gg=G
        call winrestview(l:view)
    endif
endfunction

" Build a quoted command first so both running and validation share one path.
function! master#RunCommand(debug) abort
    let l:file = expand('%:p')
    if empty(l:file) || &buftype !=# ''
        throw 'Run: save a source file first.'
    endif
    let l:qfile = shellescape(l:file)
    let l:ft = &filetype
    let l:required = []
    let l:cmd = ''
    if a:debug && index(['c', 'cpp'], l:ft) < 0
        throw 'Run!: debugging supports C/C++ files only.'
    endif
    if index(['c', 'cpp'], l:ft) >= 0
        let l:compiler = l:ft ==# 'c' ? 'gcc' : 'g++'
        let l:flags = l:ft ==# 'c' ? '-std=c11' : '-std=c++17'
        let l:build = expand('~/.local/state/vim/build/') . sha256(l:file)[0:15]
        call mkdir(l:build, 'p', 0700)
        let l:exe = shellescape(l:build . '/program')
        let l:required = [l:compiler] + (a:debug ? ['gdb'] : [])
        let l:cmd = l:compiler . ' ' . l:flags . ' -Wall -Wextra -g ' . l:qfile . ' -o ' . l:exe
              \ . ' && ' . (a:debug ? 'gdb --quiet --args ' : '') . l:exe
    elseif l:ft ==# 'python'
        let l:python = master#Python(bufnr(''))
        let l:required = [l:python]
        let l:cmd = shellescape(l:python) . ' ' . l:qfile
    elseif l:ft ==# 'sh'
        let l:required = ['bash']
        let l:cmd = 'bash ' . l:qfile
    elseif l:ft ==# 'go'
        let l:required = ['go']
        let l:cmd = 'go run ' . l:qfile
    elseif l:ft ==# 'java'
        let l:required = ['java']
        let l:cmd = 'java ' . l:qfile
    else
        throw 'Run: supported types are C, C++, Python, shell, Go and Java.'
    endif
    for l:tool in l:required
        if !executable(l:tool)
            throw 'Run: missing tool: ' . l:tool
        endif
    endfor
    return 'cd ' . shellescape(fnamemodify(l:file, ':h')) . ' && ' . l:cmd
endfunction

function! master#Run(debug) abort
    try
        if !has('terminal')
            throw 'Run: this Vim does not support terminal windows.'
        endif
        let l:command = master#RunCommand(a:debug)
        update
        let l:name = 'Run: ' . expand('%:t')
        botright new
        resize 12
        call term_start(['sh', '-c', l:command], {'curwin': 1, 'term_name': l:name, 'term_finish': 'open'})
    catch
        echohl WarningMsg | echomsg v:exception | echohl None
    endtry
endfunction

" Standalone C/C++ files also need an LSP workspace.
function! master#ProjectRoot(buffer) abort
    let l:root = ale#c#FindProjectRoot(a:buffer)
    return empty(l:root) ? fnamemodify(bufname(a:buffer), ':p:h') : l:root
endfunction


" Resolve one Python interpreter for both F5 and Jedi's analysis environment.
function! master#Python(buffer) abort
    let l:override = getbufvar(a:buffer, 'master_python', '')
    if !empty(l:override)
        let l:python = exepath(expand(l:override))
        if empty(l:python)
            throw 'Python: b:master_python is not executable: ' . l:override
        endif
        return l:python
    endif
    for l:env in [$VIRTUAL_ENV, $CONDA_PREFIX]
        if !empty(l:env)
            for l:bin in ['python3', 'python']
                let l:python = l:env . '/bin/' . l:bin
                if executable(l:python)
                    return l:python
                endif
            endfor
        endif
    endfor
    let l:dir = fnamemodify(bufname(a:buffer), ':p:h')
    if empty(bufname(a:buffer))
        let l:dir = getcwd()
    endif
    while !empty(l:dir)
        for l:env in ['.venv', 'venv']
            for l:bin in ['python3', 'python']
                let l:python = l:dir . '/' . l:env . '/bin/' . l:bin
                if executable(l:python)
                    return l:python
                endif
            endfor
        endfor
        " Do not inherit an unrelated virtualenv above a repository root.
        if isdirectory(l:dir . '/.git') || filereadable(l:dir . '/.git')
            break
        endif
        let l:parent = fnamemodify(l:dir, ':h')
        if l:parent ==# l:dir
            break
        endif
        let l:dir = l:parent
    endwhile
    for l:bin in ['python3', 'python']
        if executable(l:bin)
            return exepath(l:bin)
        endif
    endfor
    throw 'Python: no interpreter found.'
endfunction

function! master#JediOptions(buffer) abort
    return {'diagnostics': {'enable': v:false},
          \ 'workspace': {'environmentPath': master#Python(a:buffer)}}
endfunction

function! master#PythonInfo() abort
    echo 'Run / Jedi analysis: ' . master#Python(bufnr(''))
    echo 'Jedi service: ' . expand('~/.local/bin/jedi-language-server')
    echo 'Lint / format: ' . expand('~/.local/bin/ruff')
endfunction

function! master#Health() abort
    let l:lines = ['Master Vim health', '', 'Config: ' . $MYVIMRC,
          \ 'Theme: ' . get(g:, 'colors_name', ''),
          \ 'Python run / analysis: ' . master#Python(bufnr('')),
          \ 'Visual bell: ' . (&visualbell ? 'ON' : 'off'),
          \ 'Bell sequence: ' . string(&t_vb),
          \ 'Recovery: undo=' . &undofile . ' swap=' . &swapfile . ' backup=' . &backup,
          \ '', 'Tools:']
    for l:tool in ['python3', 'jedi-language-server', 'ruff', 'clangd', 'clang-format', 'ctags', 'fzf', 'rg', 'gdb']
        call add(l:lines, '  ' . l:tool . ': ' . (executable(l:tool) ? exepath(l:tool) : 'MISSING'))
    endfor
    call add(l:lines, '')
    call add(l:lines, 'Plugin directories:')
    for [l:name, l:plug] in items(g:plugs)
        call add(l:lines, '  ' . l:name . ': ' . (isdirectory(l:plug.dir) ? 'OK' : 'MISSING'))
    endfor
    botright new
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
    call setline(1, l:lines)
    setlocal nomodifiable nomodified
endfunction


function! master#InString() abort
    if index(['python', 'c', 'cpp'], &filetype) < 0 || col('.') <= 1
        return 0
    endif
    let l:id = synID(line('.'), col('.') - 1, 1)
    return synIDattr(l:id, 'name') =~? 'string\|quotes'
          \ || synIDattr(synIDtrans(l:id), 'name') ==# 'String'
endfunction

" Keep Jedi's contextual suggestions, then add ordinary text/path candidates.
function! master#StringComplete(findstart, base) abort
    if a:findstart
        let l:left = strpart(getline('.'), 0, col('.') - 1)
        let b:master_string_start = match(l:left, '\k*$')
        let b:master_string_path = matchstr(l:left, '[^"''[:space:]]*$')
        let b:master_string_lsp_start = -1
        if !get(b:, 'master_string_local_only', 0)
            let b:master_string_lsp_start = ale#completion#OmniFunc(1, '')
        endif
        let b:master_string_local_only = 0
        return b:master_string_start
    endif
    let l:items = []
    let l:seen = {}
    if get(b:, 'master_string_lsp_start', -1) == get(b:, 'master_string_start', -2)
        let l:items = ale#completion#OmniFunc(0, a:base)
        for l:item in l:items
            let l:seen[l:item.word] = 1
        endfor
    endif
    if !empty(a:base)
        for l:buf in getbufinfo({'bufloaded': 1})
            if !getbufvar(l:buf.bufnr, '&buflisted') || getbufvar(l:buf.bufnr, '&buftype') !=# ''
                continue
            endif
            for l:word in master#TextWords(l:buf.bufnr, a:base)
                if !has_key(l:seen, l:word)
                    let l:seen[l:word] = 1
                    call add(l:items, {'word': l:word, 'menu': '[text]', 'icase': 1})
                    if len(l:items) >= 80 | return l:items | endif
                endif
            endfor
        endfor
    endif
    let l:path = get(b:, 'master_string_path', '')
    if l:path =~# '/'
        let l:dir = fnamemodify(expand('%:p'), ':h')
        let l:pattern = l:path =~# '^[/~]' ? expand(l:path) : l:dir . '/' . l:path
        let l:fragment = matchstr(l:path, '\k*$')
        let l:lead = strpart(fnamemodify(l:path, ':t'), 0, strlen(fnamemodify(l:path, ':t')) - strlen(l:fragment))
        for l:file in glob(escape(l:pattern, '*?[]{}') . '*', 0, 1)[:79]
            let l:word = strpart(fnamemodify(l:file, ':t'), strlen(l:lead)) . (isdirectory(l:file) ? '/' : '')
            if !has_key(l:seen, l:word)
                let l:seen[l:word] = 1
                call add(l:items, {'word': l:word, 'menu': '[path]'})
            endif
        endfor
    endif
    return l:items
endfunction

function! master#StopStringTimer() abort
    if get(b:, 'master_string_timer', -1) >= 0
        call timer_stop(b:master_string_timer)
        let b:master_string_timer = -1
    endif
endfunction

function! master#StringFallback(buffer, position, tick, timer) abort
    if bufnr('') == a:buffer && get(b:, 'master_string_timer', -1) == a:timer
        let b:master_string_timer = -1
    endif
    if bufnr('') != a:buffer || mode() !=# 'i' || getpos('.')[1:2] != a:position
          \ || b:changedtick != a:tick || pumvisible() || !master#InString() || &paste
        return
    endif
    let l:left = strpart(getline('.'), 0, col('.') - 1)
    if l:left !~# '\k\{2}$' && l:left !~# '/$'
        return
    endif
    " A delayed server reply must not overwrite the fallback menu.
    if exists('b:ale_completion_info')
        let b:ale_completion_info.request_id = 0
    endif
    call ale#completion#StopTimer()
    let b:master_string_local_only = 1
    call feedkeys("\<C-X>\<C-U>", 'n')
endfunction

function! master#QueueStringCompletion() abort
    call master#StopStringTimer()
    if &filetype ==# 'python' && masterpython#QueueMain()
        return
    endif
    if &paste || pumvisible() || &buftype !=# ''
        return
    endif
    let l:left = strpart(getline('.'), 0, col('.') - 1)
    if (l:left =~# '\k\{2}$' || l:left =~# '/$') && master#InString()
        let b:master_string_timer = timer_start(350, function('master#StringFallback',
              \ [bufnr(''), getpos('.')[1:2], b:changedtick]))
    endif
endfunction


function! master#Enter() abort
    if pumvisible()
        " noselect: Enter accepts the first item even before Tab is pressed.
        return complete_info(['selected']).selected < 0 ? "\<C-N>\<C-Y>" : "\<C-Y>"
    endif
    " Run AutoPairs' indentation helper only for a real newline.
    if exists('*AutoPairsReturn') && exists('b:AutoPairsList')
        return "\<CR>\<C-R>=AutoPairsReturn()\<CR>"
    endif
    return "\<CR>"
endfunction


" Replace E325's long technical prompt with a small recovery menu.
function! master#SwapDialog(file) abort
    let l:info = swapinfo(v:swapname)
    let l:host = get(l:info, 'host', '')
    let l:pid = get(l:info, 'pid', 0)
    let l:local = !empty(l:host) && l:host ==# strpart(hostname(), 0, 39)
    let l:stale = l:local && l:pid > 0 && isdirectory('/proc') && !isdirectory('/proc/' . l:pid)
    let l:name = fnamemodify(a:file, ':~:.')
    if l:stale && !has_key(l:info, 'error')
        let l:choice = confirm('发现遗留编辑会话：' . l:name
              \ . "\n恢复后请检查内容，按 ;w 保存。",
              \ "&R 恢复未保存内容\n&O 只读打开\n&Q 取消", 1)
        let v:swapchoice = get({1: 'r', 2: 'o'}, l:choice, 'q')
        if v:swapchoice ==# 'r'
            if !exists('g:master_swap_recoveries')
                let g:master_swap_recoveries = {}
            endif
            let g:master_swap_recoveries[fnamemodify(a:file, ':p')] = {
                  \ 'path': v:swapname, 'mtime': getftime(v:swapname),
                  \ 'size': getfsize(v:swapname), 'pid': l:pid}
        endif
    else
        let l:status = l:local && isdirectory('/proc/' . l:pid)
              \ ? '另一个编辑进程仍在运行' : '无法确认原编辑会话是否已结束'
        let l:choice = confirm(l:status . '：' . l:name,
              \ "&O 只读打开\n&Q 取消", 2)
        let v:swapchoice = l:choice == 1 ? 'o' : 'q'
    endif
endfunction


" Archive the old recovery record only after the recovered buffer is saved.
function! master#ArchiveRecoveredSwap() abort
    let l:key = expand('%:p')
    if !has_key(get(g:, 'master_swap_recoveries', {}), l:key)
        return
    endif
    let l:record = g:master_swap_recoveries[l:key]
    if !filereadable(l:record.path)
        call remove(g:master_swap_recoveries, l:key)
        return
    endif
    let l:info = swapinfo(l:record.path)
    if getftime(l:record.path) != l:record.mtime || getfsize(l:record.path) != l:record.size
          \ || get(l:info, 'pid', -1) != l:record.pid || isdirectory('/proc/' . l:record.pid)
        return
    endif
    let l:dir = expand('~/.local/state/vim/recovery/') . strftime('%Y%m%d-%H%M%S') . '-' . getpid()
    call mkdir(l:dir, 'p', 0700)
    if rename(l:record.path, l:dir . '/' . fnamemodify(l:record.path, ':t')) == 0
        call remove(g:master_swap_recoveries, l:key)
    endif
endfunction


" Search inside Vim's native engine; cache only unchanged buffer/prefix pairs.
function! master#TextWords(buffer, base) abort
    let l:tick = getbufvar(a:buffer, 'changedtick')
    let l:cache = getbufvar(a:buffer, 'master_text_words', {})
    if get(l:cache, 'tick', -1) == l:tick && get(l:cache, 'prefix', '') ==# a:base
        return l:cache.words
    endif
    " A complete previous result can be narrowed without rescanning the buffer.
    " Truncated lists, changed buffers and shorter prefixes still use the scan.
    let l:previous = get(l:cache, 'prefix', '')
    if get(l:cache, 'tick', -1) == l:tick && get(l:cache, 'complete', 0)
          \ && l:previous =~# '^\w\+$' && a:base =~# '^\w\+$'
          \ && strlen(a:base) > strlen(l:previous)
          \ && stridx(tolower(a:base), tolower(l:previous)) == 0
        let l:prefix = tolower(a:base)
        let l:words = filter(copy(l:cache.words),
              \ 'v:val !=# a:base && stridx(tolower(v:val), l:prefix) == 0')
        call setbufvar(a:buffer, 'master_text_words',
              \ {'tick': l:tick, 'prefix': a:base, 'words': l:words, 'complete': 1})
        return l:words
    endif
    let l:words = []
    let l:seen = {}
    let l:last = min([10000, getbufinfo(a:buffer)[0].linecount])
    let l:pattern = '\c\m\%(\w\)\@<!\V' . escape(a:base, '\') . '\m\w*'
    for l:first in range(1, l:last, 256)
        for l:match in matchbufline(a:buffer, l:pattern, l:first, min([l:first + 255, l:last]))
            let l:word = l:match.text
            if l:word !=# a:base && !has_key(l:seen, l:word)
                let l:seen[l:word] = 1
                call add(l:words, l:word)
                if len(l:words) >= 80 | break | endif
            endif
        endfor
        if len(l:words) >= 80 | break | endif
    endfor
    call setbufvar(a:buffer, 'master_text_words', {'tick': l:tick, 'prefix': a:base, 'words': l:words, 'complete': len(l:words) < 80})
    return l:words
endfunction

function! master#KeyTopics(lead, line, position) abort
    return filter(['快速开始', '补全', '文件搜索', '窗口缓冲区', 'Tagbar', '运行调试', '诊断格式化',
          \ 'Python', '注释剪贴板', 'Git', '恢复', '自检', '配置'],
          \ 'stridx(tolower(v:val), tolower(a:lead)) == 0')
endfunction

function! master#Keys(topic) abort
    let l:name = '[VimKeys]'
    let l:buf = get(s:, 'keys_buffer', -1)
    if !bufexists(l:buf) || !getbufvar(l:buf, 'master_keys', 0)
        let l:buf = -1
    endif
    let l:win = l:buf > 0 ? bufwinnr(l:buf) : -1
    if l:win > 0
        execute l:win . 'wincmd w'
    elseif l:buf > 0
        execute 'botright sbuffer ' . l:buf
    else
        botright new
        silent execute 'file ' . fnameescape(l:name)
        setlocal buftype=nofile bufhidden=hide noswapfile nobuflisted
        let b:master_keys = 1
        let s:keys_buffer = bufnr('')
    endif
    setlocal modifiable noreadonly
    silent %delete _
    call setline(1, readfile(expand('~/.config/vim/README.md')))
    setlocal filetype=markdown
    setlocal nomodified readonly nomodifiable noswapfile
    setlocal number norelativenumber wrap linebreak conceallevel=0
    nnoremap <silent> <buffer> q :call master#CloseKeys()<CR>
    normal! gg
    if !empty(a:topic)
        if !search('\m^## .*\V' . escape(a:topic, '\'), 'w')
            call search('\V' . escape(a:topic, '\'), 'w')
        endif
        normal! zt
    endif
endfunction

function! master#CloseKeys() abort
    if winnr('$') > 1
        close
    else
        enew
    endif
endfunction


function! master#CopyBegin() abort
    let s:copy_previous_operator = &operatorfunc
    let &operatorfunc = 'master#CopyOperator'
    return 'g@'
endfunction

function! master#CopyOperator(type) abort
    let l:selection = &selection
    let l:z = getreginfo('z')
    let l:unnamed = getreginfo('"')
    try
        set selection=inclusive
        if a:type ==# 'line'
            silent normal! '[V']"zy
        elseif a:type ==# 'block'
            execute "silent normal! `[\<C-V>`]\"zy"
        else
            silent normal! `[v`]"zy
        endif
        let l:text = getreg('z')
        let l:type = getregtype('z')
    finally
        let &selection = l:selection
        let &operatorfunc = get(s:, 'copy_previous_operator', '')
        call setreg('z', l:z)
        call setreg('"', l:unnamed)
    endtry
    call master#Clipboard(l:text, l:type)
endfunction

function! master#CopySelection() abort
    let l:z = getreginfo('z')
    let l:unnamed = getreginfo('"')
    try
        silent normal! gv"zy
        let l:text = getreg('z')
        let l:type = getregtype('z')
    finally
        call setreg('z', l:z)
        call setreg('"', l:unnamed)
    endtry
    call master#Clipboard(l:text, l:type)
endfunction

function! master#CopyLines(first, last) abort
    call master#Clipboard(join(getline(a:first, a:last), "\n") . "\n", 'V')
endfunction

function! master#Clipboard(text, type) abort
    call setreg('"', a:text, a:type)
    try
        if executable('/mnt/c/Windows/System32/clip.exe') && executable('/usr/bin/python3')
            let l:command = shellescape('/usr/bin/python3') . ' ' . shellescape(expand('~/.config/vim/clipboard.py'))
            silent let l:output = system(l:command, a:text)
            if v:shell_error
                throw 'Windows 剪贴板写入失败'
            endif
        elseif executable('wl-copy')
            silent let l:output = system('wl-copy', a:text)
            if v:shell_error | throw 'wl-copy 写入失败' | endif
        elseif has('clipboard')
            call setreg('+', a:text, a:type)
        else
            throw '系统剪贴板不可用，内容已复制到 Vim，按 p 粘贴'
        endif
        echo '已复制，可在系统其他应用中粘贴'
    catch
        echohl WarningMsg | echomsg v:exception | echohl None
    endtry
endfunction
