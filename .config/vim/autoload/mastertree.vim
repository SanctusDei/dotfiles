" Watch expanded NERDTree directories without loading the plugin at startup.
function! s:Snapshot(node) abort
    let l:path = a:node.path.str()
    let l:entries = isdirectory(l:path) ? sort(readdir(l:path)) : []
    let l:result = [[l:path, l:entries]]
    for l:child in a:node.children
        if l:child.path.isDirectory && l:child.isOpen
            call extend(l:result, s:Snapshot(l:child))
        endif
    endfor
    return l:result
endfunction

function! mastertree#Refresh() abort
    if !exists('b:NERDTree') || !empty(getcmdwintype())
        return
    endif
    let l:snapshot = s:Snapshot(b:NERDTree.root)
    if l:snapshot ==# get(b:, 'mastertree_snapshot', [])
        return
    endif
    let l:view = winsaveview()
    call b:NERDTree.root.refresh()
    call b:NERDTree.ui.renderViewSavingPosition()
    let l:view.lnum = line('.')
    let l:view.col = col('.') - 1
    call winrestview(l:view)
    let b:mastertree_snapshot = s:Snapshot(b:NERDTree.root)
endfunction

function! mastertree#Poll(...) abort
    if !exists('g:loaded_nerd_tree') || !empty(getcmdwintype())
        return
    endif
    for l:window in getwininfo()
        if l:window.tabnr == tabpagenr()
                    \ && getbufvar(l:window.bufnr, '&filetype') ==# 'nerdtree'
            call win_execute(l:window.winid, 'call mastertree#Refresh()')
        endif
    endfor
endfunction
