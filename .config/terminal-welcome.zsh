# Display once per interactive terminal; no subprocesses on startup.
if [[ -o interactive && -t 1 && ${TERM:-dumb} != dumb && -z ${TERMINAL_WELCOME_SHOWN:-} ]]; then
    typeset -g TERMINAL_WELCOME_SHOWN=1
    print -P '
  %B%F{255}MASTER %F{117}/ TERMINAL%f%b'
    print -P '  %F{252}%D{%Y.%m.%d}  ·  %D{%H:%M}%f'
    print -P '  %F{117}zsh  /  starship%f
'
fi
