# Zsh 与 Vim 配置

当前 Linux / WSL 开发环境的配置快照。配置文件按家目录中的相对路径保存。

## 文件

- `.zshrc`、`.zshenv`：Oh My Zsh、NVM / Conda 延迟加载、代理、别名。
- `.config/starship.toml`、`.config/terminal-welcome.zsh`：提示符与终端欢迎信息。
- `.vimrc`、`.config/vim/`：Vim 配置、主题、Python / C / C++ 补全、格式化、运行和剪贴板辅助功能。
- [Vim 快捷键说明](.config/vim/README.md)：`;?` 或 `:VimKeys` 在 Vim 内打开。

不包含 API 密钥文件 `~/.config/env.sh`、历史记录、缓存、备份、第三方插件源码和已安装工具。

## 恢复配置

先备份目标机器上的同名文件，再从仓库目录执行：

```sh
mkdir -p ~/.config/vim
cp .zshrc .zshenv .vimrc ~/
cp .config/starship.toml .config/terminal-welcome.zsh ~/.config/
cp -R .config/vim/. ~/.config/vim/
```

配置依赖需要另外安装；复制文件不会安装这些工具。

### Zsh

需要 Zsh；完整提示符与插件功能还需要 Starship、Oh My Zsh 和其 `zsh-autosuggestions` 插件。
NVM、Conda、autojump、OpenClaw 按需安装。

`.zshrc` 默认使用本机 `127.0.0.1:7890` 的 HTTP / SOCKS 代理，迁移时请按实际环境修改或删除相关 export 行。
OpenClaw 补全路径目前为 `/home/Master/.openclaw/completions/openclaw.zsh`，其他用户名需调整。
敏感环境变量另放在 `~/.config/env.sh`，不要提交到 Git。

### Vim

需要支持 terminal 的 Vim，插件管理器 vim-plug 应安装到 `~/.vim/autoload/plug.vim`。
打开 Vim 后执行 `:PlugInstall` 安装声明的 9 个插件；首次安装完成后重新启动 Vim。
首次安装前因缺少 vim-plug 或插件出现报错时，先补齐依赖再重启。
Fugitive 使用 `~/.vim/bundle/vim-fugitive`，其余插件使用 `~/.vim/plugged/`。

常用外部工具：`python3`、`ruff`、`jedi-language-server`、`clangd`、`clang-format`、Universal Ctags、`fzf`、`rg`、`gcc` / `g++`、`gdb`。
Python 工具固定从 `~/.local/bin/ruff` 和 `~/.local/bin/jedi-language-server` 加载，可用已安装的 uv 安装：

```sh
uv tool install ruff
uv tool install jedi-language-server
```

运行 `:VimHealth` 检查依赖，`:PythonInfo` 查看项目解释器。
恢复文件和编译产物写入 `~/.local/state/vim/`。
剪贴板优先支持 WSL 的 Windows `clip.exe`，其次 `wl-copy` 或 Vim 原生 clipboard 功能。
