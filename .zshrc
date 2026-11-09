# Use the newest installed Node as a bootstrap; NVM selects its default on first use.
typeset -U path PATH
export NVM_DIR="$HOME/.nvm"
# Numeric glob sorting avoids spawning find/sort/tail on every startup.
typeset -a _node_bins
_node_bins=("$NVM_DIR"/versions/node/*/bin(N/n))
(( ${#_node_bins} == 0 )) || path=("${_node_bins[-1]}" "${path[@]}")
unset _node_bins
# --- 1. Oh My Zsh 基础设置 ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

# 仅保留必要的插件，不要添加太多
plugins=(git zsh-autosuggestions)

[ ! -r "$ZSH/oh-my-zsh.sh" ] || source "$ZSH/oh-my-zsh.sh"

# --- 2. 提示符由 Starship 接管 ---

# --- 3. 环境变量与代理 ---
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7890
# Preserve existing bypass rules and add local addresses.
typeset -a _proxy_bypass
_proxy_bypass=("${(@s:,:)no_proxy}" "${(@s:,:)NO_PROXY}" localhost 127.0.0.1 ::1)
typeset -U _proxy_bypass
_proxy_bypass=("${(@)_proxy_bypass:#}")
export no_proxy="${(j:,:)_proxy_bypass}"
export NO_PROXY="$no_proxy"
unset _proxy_bypass

# --- 4. 性能优化加载区 ---

# [优化] Autojump：检查文件是否存在再加载
[ -f /usr/share/autojump/autojump.sh ] && source /usr/share/autojump/autojump.sh

# [警告] incr 插件：如果打字卡顿，请注释掉下面这一行
# source ~/.oh-my-zsh/plugins/incr/incr*.zsh

# Load NVM only when an installed Node command is first used.
if [ -s "$NVM_DIR/nvm.sh" ]; then
    _load_nvm() {
        unset -f nvm node npm npx _load_nvm
        (( $+functions[corepack] )) && unset -f corepack
        . "$NVM_DIR/nvm.sh" || return
        "$@"
    }
    nvm() { _load_nvm nvm "$@"; }
    node() { _load_nvm node "$@"; }
    npm() { _load_nvm npm "$@"; }
    npx() { _load_nvm npx "$@"; }
    if (( $+commands[corepack] )); then
        corepack() { _load_nvm corepack "$@"; }
    fi
fi

# --- 5. Conda 延迟加载 (Lazy Load) ---
# 只有当你输入 conda 时才真正加载 Conda
conda() {
    unset -f conda
    local __conda_setup
    __conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
            . "$HOME/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="$HOME/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    conda "$@"
}

# --- 6. 别名 (Aliases) ---
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias md='mkdir -p'
alias ports='ss -tulanp'
alias myip='curl -s ip.sb'
export PATH="$HOME/.local/bin:$PATH"

# 敏感环境变量（API 密钥等）放在独立的私密文件中
[ -f "$HOME/.config/env.sh" ] && source "$HOME/.config/env.sh"

# --- 7. Starship 提示符 ---
if [[ -o interactive && ${TERM:-dumb} != dumb ]] && command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# OpenClaw Completion
[ -f "/home/Master/.openclaw/completions/openclaw.zsh" ] && source "/home/Master/.openclaw/completions/openclaw.zsh"

# Keep the first occurrence of each PATH entry (including Windows interoperability).
typeset -U path PATH

# --- Terminal welcome ---
[[ ! -r "$HOME/.config/terminal-welcome.zsh" ]] || source "$HOME/.config/terminal-welcome.zsh"

function vim() {
    local use_template=0 # 模板开关, 0表示不启用
    # 暂存当前处理的参数
    local arg
    #
    local -a vim_args=()

    while (( $# )); do
        arg="$1"
        shift

        case "$arg" in
            --template) use_template=1 ;;
            --)
                vim_args+=("--" "$@")
                break
                ;;
            *) vim_args+=("$arg") ;;
        esac
    done

    if (( use_template )); then
        command vim -c 'PythonTemplate' "${vim_args[@]}"
    else
        command vim "${vim_args[@]}"
    fi
}
