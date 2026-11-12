" Master Vim — one plugin manager, isolated runtime, explicit tools.
set nocompatible
scriptencoding utf-8
let mapleader = ';'
let maplocalleader = ','

" Exclude the legacy plugin/ftplugin tree without deleting it.
let s:legacy = [expand('~/.vim'), expand('~/.vim/after')]
let &runtimepath = join(filter(split(&runtimepath, ','),
      \ 'index(s:legacy, expand(v:val)) < 0'), ',')
set runtimepath^=~/.config/vim
set runtimepath+=~/.config/vim/after
let &packpath = &runtimepath

" Tools must also work when Vim is launched outside an interactive zsh.
if index(split($PATH, ':'), expand('~/.local/bin')) < 0
    let $PATH = expand('~/.local/bin') . ':' . $PATH
endif
if !executable('fzf') && executable(expand('~/.vim/plugged/fzf/bin/fzf'))
    let $PATH .= ':' . expand('~/.vim/plugged/fzf/bin')
endif

" vim-plug: reuse installed repositories; no downloads during startup.
execute 'source ' . fnameescape(expand('~/.vim/autoload/plug.vim'))
call plug#begin('~/.vim/plugged')
" Load the file tree when requested; directory buffers are handled below.
Plug 'preservim/nerdtree', {'on': ['NERDTree', 'NERDTreeToggle',
      \ 'NERDTreeExplore', 'NERDTreeClose', 'NERDTreeFromBookmark',
      \ 'NERDTreeMirror', 'NERDTreeFind', 'NERDTreeRefreshRoot',
      \ 'NERDTreeFocus', 'NERDTreeCWD']}
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'dense-analysis/ale'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-commentary'
Plug 'itchyny/lightline.vim'
Plug 'preservim/tagbar'
Plug 'tpope/vim-fugitive', {'dir': expand('~/.vim/bundle/vim-fugitive')}
call plug#end()

" Editing and display.
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,latin1
set hidden
set number relativenumber
set cursorline
set showmatch matchtime=1
set signcolumn=yes
set laststatus=2
set noshowmode
set showcmd
" Avoid completion status messages while typing, including Chinese text.
set shortmess+=Ic
set cmdheight=2
set scrolloff=5 sidescrolloff=5
set nowrap
set splitbelow splitright
set mouse=a
set selection=inclusive
set backspace=indent,eol,start
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
set autoindent
set nosmartindent nocindent
set ignorecase smartcase incsearch hlsearch
set wildmenu
set wildmode=longest:full,full
set wildignore+=*.o,*.obj,*.so,*.pyc,*/.git/*,*/node_modules/*,*/.venv/*
set completeopt=menuone,noselect
set pumheight=12
set updatetime=400
set timeoutlen=500
set ttimeoutlen=50
" Silence both audible and visual bells: visualbell may flash the screen.
set noerrorbells novisualbell
if exists('+belloff')
    set belloff=all
endif
if exists('+t_vb')
    set t_vb=
endif
set history=2000
set list
set listchars=tab:»\ ,trail:·,extends:›,precedes:‹,nbsp:␣
set fillchars=vert:│
set formatoptions-=t
set noautochdir
set autoread
set tags=./tags;,tags;
if exists('+termguicolors')
    set termguicolors
endif
set background=dark
colorscheme master

" Recovery files live outside projects, with private permissions.
let s:state = expand('~/.local/state/vim')
for s:sub in ['undo', 'swap', 'backup', 'build']
    call mkdir(s:state . '/' . s:sub, 'p', 0700)
endfor
let &undodir = s:state . '/undo//'
let &directory = s:state . '/swap//'
let &backupdir = s:state . '/backup//'
set undofile swapfile backup writebackup
set backupcopy=auto
set backupskip=/tmp/*,/private/tmp/*

" ALE: Ruff diagnostics + Jedi completions for Python; clangd for C/C++.
let g:ale_linters_explicit = 1
let g:ale_linters = {
      \ 'c': executable('clangd') ? ['clangd'] : ['cc'],
      \ 'cpp': executable('clangd') ? ['clangd'] : ['cc'],
      \ 'python': ['ruff', 'jedi'],
      \ 'sh': [],
      \ }
" Resolve the optional shell checker only when a shell buffer is opened.
let s:shellcheck_checked = 0
let g:ale_root = {'clangd': function('master#ProjectRoot')}
let g:ale_c_cc_executable = 'gcc'
let g:ale_cpp_cc_executable = 'g++'
let g:ale_c_cc_options = '-std=c11 -Wall -Wextra'
let g:ale_cpp_cc_options = '-std=c++17 -Wall -Wextra'
let g:ale_fixers = {
      \ 'python': ['ruff_format'],
      \ 'c': ['clang-format'],
      \ 'cpp': ['clang-format'],
      \ }
let g:ale_python_ruff_executable = expand('~/.local/bin/ruff')
" Allow personal import ordering and typing.List-style annotations.
let g:ale_python_ruff_options = '--extend-ignore I001,UP006,UP035,RUF013,PLW1508,BLE001'
let g:ale_python_ruff_format_executable = expand('~/.local/bin/ruff')
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 0
let g:ale_completion_enabled = 1
let g:ale_completion_delay = 180
let g:ale_virtualtext_cursor = 'disabled'
" Keep signs, but avoid asynchronous text underlines and command-line churn.
let g:ale_set_highlights = 0
let g:ale_echo_cursor = 0
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '!'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_set_loclist = 1
let g:ale_open_list = 0

" Enter is handled centrally so completion confirmation never inserts a newline.
let g:AutoPairsMapCR = 0

" Sidebars and status line; use symbols that need no patched font.
let g:NERDTreeWinSize = max([12, (&columns - 2) * 18 / 100])
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeDirArrowExpandable = '›'
let g:NERDTreeDirArrowCollapsible = '⌄'
let g:NERDTreeIgnore = ['^\.git$', '^__pycache__$', '\.pyc$']
let g:tagbar_width = max([14, (&columns - 2) * 19 / 100])
let g:tagbar_autofocus = 1
let g:tagbar_ctags_bin = exepath('ctags')
let g:lightline = {
      \ 'colorscheme': 'master_moon',
      \ 'active': {
      \   'left': [['mode', 'paste'], ['gitbranch', 'readonly', 'filename', 'modified']],
      \   'right': [['lineinfo'], ['percent'], ['filetype', 'fileencoding']]
      \ },
      \ 'component_function': {'gitbranch': 'FugitiveHead'},
      \ 'separator': {'left': '', 'right': ''},
      \ 'subseparator': {'left': '│', 'right': '│'}
      \ }
let g:fzf_layout = {'down': '40%'}
if empty($FZF_DEFAULT_COMMAND) && executable('rg')
    let $FZF_DEFAULT_COMMAND = "rg --files --hidden -g '!.git' -g '!node_modules' -g '!.venv' -g '!__pycache__'"
endif

" Core window, motion and clipboard bindings retain Vim defaults.
nnoremap <silent> <Esc> :nohlsearch<CR>
nnoremap <silent> <leader>? :VimKeys<CR>
nnoremap <silent> <leader>w :update<CR>
nnoremap <silent> <leader>e :NERDTreeFind<CR>
nnoremap <silent> <leader>v :vsplit<CR>
nnoremap <silent> <leader>s :split<CR>
nnoremap <silent> <leader>bn :bnext<CR>
nnoremap <silent> <leader>bp :bprevious<CR>
nnoremap <silent> <leader>bd :bdelete<CR>
nnoremap <silent> <C-p> :Files<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>/ :Rg<Space>
nnoremap <silent> <leader>g :Git<CR>
nnoremap <silent> <leader>l :ALELint<CR>
nnoremap <silent> <leader>k :ALEDetail<CR>
nnoremap <silent> <leader>f :call master#Format()<CR>
nnoremap <silent> <leader>n :ALENextWrap<CR>
nnoremap <silent> <leader>p :ALEPreviousWrap<CR>
nnoremap <silent> <leader>d :ALEGoToDefinition<CR>
nnoremap <silent> <leader>r :ALEFindReferences<CR>
nnoremap <expr> <leader>y master#CopyBegin()
nnoremap <silent> <leader>yy :call master#CopyLines(line('.'), line('.'))<CR>
xnoremap <silent> <leader>y :<C-U>call master#CopySelection()<CR>
xnoremap <silent> <C-c> :<C-U>call master#CopySelection()<CR>
nnoremap <silent> <leader>Y :Copy<CR>
nnoremap <leader>P "+p
nnoremap <silent> <F3> :NERDTreeToggle<CR>
inoremap <silent> <F3> <C-O>:NERDTreeToggle<CR>
nnoremap <silent> <F4> :StopRun<CR>
inoremap <silent> <F4> <C-O>:StopRun<CR>
nnoremap <silent> <F5> :Run<CR>
nnoremap <silent> <F6> :call master#Format()<CR>
nnoremap <silent> <F8> :Run!<CR>
nnoremap <silent> <F9> :TagbarToggle<CR>
nnoremap <silent> <F12> mzgg=G`z
nnoremap <S-Left> :tabprevious<CR>
nnoremap <S-Right> :tabnext<CR>
inoremap <silent> <expr> <CR> master#Enter()
inoremap <expr> <Tab> pumvisible() ? "\<C-N>" : master#Tab()
inoremap <expr> <S-Tab> pumvisible() ? "\<C-P>" : "\<C-D>"
inoremap <C-Space> <C-X><C-O>
inoremap <C-@> <C-X><C-O>
if has('terminal')
    tnoremap <Esc><Esc> <C-W>N
endif
command! -range=% Copy call master#CopyLines(<line1>, <line2>)
" Wall-clock limit for F5, including compilation and waiting for input; 0 disables it.
let g:master_run_timeout_ms = get(g:, 'master_run_timeout_ms', 5000)
command! -bang Run call master#Run(<bang>0)
command! StopRun call master#StopRun()
command! PythonInfo call master#PythonInfo()
command! VimHealth call master#Health()
command! -nargs=? -complete=customlist,master#KeyTopics VimKeys call master#Keys(<q-args>)

augroup MasterVim
    autocmd!
    autocmd FileType sh if !s:shellcheck_checked | let g:ale_linters.sh = executable('shellcheck') ? ['shellcheck'] : [] | let s:shellcheck_checked = 1 | endif
    autocmd FileType python setlocal omnifunc=ale#completion#OmniFunc completefunc=master#StringComplete | call masterpython#Setup()
    autocmd FileType c,cpp setlocal omnifunc=ale#completion#OmniFunc completefunc=master#StringComplete
    autocmd FileType markdown,text setlocal wrap linebreak spelllang=en_us
    autocmd FileType make setlocal noexpandtab
    autocmd FileType javascript,typescript,json,yaml,html,css,vue setlocal shiftwidth=2 softtabstop=2
    autocmd FileType * setlocal formatoptions-=o formatoptions-=r
    autocmd BufEnter,VimEnter * if !exists('g:loaded_nerd_tree') && isdirectory(expand('<amatch>')) | call masterui#BrowseDirectory(expand('<amatch>')) | endif
    autocmd SwapExists * call master#SwapDialog(expand('<afile>'))
    autocmd BufWritePost * call master#ArchiveRecoveredSwap()
    autocmd BufReadPost * call master#RestorePosition()
    autocmd FocusGained * if &buftype ==# '' | silent! checktime | endif
    autocmd BufEnter * if &buftype ==# '' | silent! execute 'checktime ' . bufnr('') | endif
    autocmd TextChangedI * if index(['python', 'c', 'cpp'], &filetype) >= 0 | call master#QueueStringCompletion() | endif
    autocmd CompleteDone * if &filetype ==# 'python' | call masterpython#MainDone() | endif
    autocmd InsertLeave,BufLeave * call master#StopStringTimer()
    autocmd TerminalOpen * setlocal nonumber norelativenumber nospell
    autocmd QuitPre * if get(b:, 'master_run', 0) | call master#StopRun() | endif
augroup END

" Detect external file/directory changes while the tree is visible.
augroup MasterTreeRefresh
    autocmd!
    autocmd FocusGained,BufWritePost,WinEnter,TabEnter * call mastertree#Poll()
augroup END

" Native window styling; delayed layout work coalesces terminal resize events.
augroup MasterMoonUI
    autocmd!
    autocmd VimEnter,VimResized,TabEnter,BufWinEnter,WinClosed * call masterui#Schedule()
    autocmd FileType nerdtree,tagbar call masterui#Schedule()
    autocmd WinEnter * call masterui#ScheduleFocus()
    autocmd ColorScheme master call masterui#ScheduleFocus()
augroup END

" Explicit Python contest template: vim --template file.py.
function! s:PythonTemplate() abort
    " Preserve every buffer that contains text, including whitespace.
    if &buftype !=# '' || expand('%:e') !=# 'py'
        return
    endif
    if line('$') != 1 || getline(1) !=# ''
        return
    endif
    if !&modifiable || &readonly
        return
    endif

    let l:path = expand('~/.vim/templates/python.py')
    if !filereadable(l:path)
        echoerr '找不到模板：' . l:path
        return
    endif

    let l:lines = readfile(l:path)
    if empty(l:lines)
        return
    endif

    " Remove the first cursor marker and remember its code line.
    let l:target = 1
    for l:i in range(len(l:lines))
        if l:lines[l:i] =~# '# @cursor\s*$'
            let l:lines[l:i] = substitute(
                        \ l:lines[l:i], '\s*# @cursor\s*$', '', '')
            let l:target = l:i + 1
            break
        endif
    endfor

    call setline(1, l:lines)
    call cursor(l:target, max([1, match(getline(l:target), '\S') + 1]))
endfunction

command! PythonTemplate call <SID>PythonTemplate()
