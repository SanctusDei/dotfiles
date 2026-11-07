# Display once per interactive terminal; no subprocesses on startup.
if [[ -o interactive && -t 1 && ${TERM:-dumb} != dumb && -z ${TERMINAL_WELCOME_SHOWN:-} ]]; then
    typeset -g TERMINAL_WELCOME_SHOWN=1
    print -P '
  %B%F{cyan}MASTER %F{240}/ TERMINAL%f%b'
    print -P '  %F{245}%D{%Y.%m.%d}  ·  %D{%H:%M}%f'
    print -P '  %F{240}zsh  /  starship%f
'
fi
