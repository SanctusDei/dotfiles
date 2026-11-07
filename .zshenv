# Ubuntu initializes completion in /etc/zsh/zshrc; Oh My Zsh handles it instead.
# Retain the system fallback when Oh My Zsh is unavailable.
if [[ -r "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
    skip_global_compinit=1
fi
