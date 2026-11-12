" Dedicated completion server; Ruff is the diagnostic provider.
call ale#linter#Define('python', {
      \ 'name': 'jedi',
      \ 'lsp': 'stdio',
      \ 'executable': expand('~/.local/bin/jedi-language-server'),
      \ 'command': ale#Escape(expand('~/.local/bin/jedi-language-server')),
      \ 'project_root': function('ale#python#FindProjectRoot'),
      \ 'initialization_options': function('master#JediOptions'),
      \ })
