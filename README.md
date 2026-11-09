# Zsh 与 Vim 配置

当前 Linux / WSL 开发环境的配置快照。配置文件按家目录中的相对路径保存。

## 文件

- `.zshrc`、`.zshenv`：Oh My Zsh、NVM / Conda 延迟加载、代理、别名。
- `.config/starship.toml`、`.config/terminal-welcome.zsh`：提示符与终端欢迎信息。
- `.vimrc`、`.config/vim/`：Vim 配置、主题、Python / C / C++ 补全、格式化、运行和剪贴板辅助功能。
- `.vim/templates/python.py`：带个人信息栏的力扣刷题模板。
- [Vim 快捷键说明](.config/vim/README.md)：`;?` 或 `:VimKeys` 在 Vim 内打开。

不包含 API 密钥文件 `~/.config/env.sh`、历史记录、缓存、备份、第三方插件源码和已安装工具。

## 恢复配置

先备份目标机器上的同名文件，再从仓库目录执行：

```sh
mkdir -p ~/.config/vim ~/.vim/templates
cp .zshrc .zshenv .vimrc ~/
cp .config/starship.toml .config/terminal-welcome.zsh ~/.config/
cp -R .config/vim/. ~/.config/vim/
cp .vim/templates/python.py ~/.vim/templates/
```

配置依赖需要另外安装；复制文件不会安装这些工具。

### Zsh

需要 Zsh；完整提示符与插件功能还需要 Starship、Oh My Zsh 和其 `zsh-autosuggestions` 插件。
NVM、Conda、autojump、OpenClaw 按需安装。

`.zshrc` 默认使用本机 `127.0.0.1:7890` 的 HTTP / SOCKS 代理，迁移时请按实际环境修改或删除相关 export 行。
OpenClaw 补全路径目前为 `/home/Master/.openclaw/completions/openclaw.zsh`，其他用户名需调整。
敏感环境变量另放在 `~/.config/env.sh`，不要提交到 Git。

### Vim

需要支持 terminal、termguicolors、timers、textprop 的 Vim（本机使用 Vim 9.1），插件管理器 vim-plug 应安装到 `~/.vim/autoload/plug.vim`。
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

### Vim 视觉与性能

使用 Tokyo Night Moon 风格的实色深蓝灰背景、柔和字符串颜色及统一的 lightline 状态栏。
NERDTree / 中央代码区 / Tagbar 的目标比例为约 18% / 63% / 19%，根据终端列数自动调整；窄屏优先保留代码空间。
启用相对行号、柔和当前行与括号匹配，保留原有快捷键、缩进、补全、诊断和运行功能。
全部使用 Vim 原生 API；未增加主题插件、覆盖式边框或自定义命令输入框。
终端透明度需自行设置，建议约 95% 不透明度；配置不会修改终端设置。

字符串补全会复用未变化缓冲区中的完整候选列表，保留原先的候选顺序、80 项上限和 10000 行范围。
可选 shellcheck 的可用性在首次打开 shell 文件时检测，减少其他语言启动时的无效 PATH 扫描。
若使用 fzf 插件目录中的二进制，可在没有同名文件时建立快捷入口，避免 WSL 反复扫描 Windows PATH：

```sh
mkdir -p "$HOME/.local/bin"
if [ -x "$HOME/.vim/plugged/fzf/bin/fzf" ] && [ ! -e "$HOME/.local/bin/fzf" ] && [ ! -L "$HOME/.local/bin/fzf" ]; then
    ln -s "$HOME/.vim/plugged/fzf/bin/fzf" "$HOME/.local/bin/fzf"
fi
```

验证覆盖 Python/C++ 语法配色、诊断、格式化、Tab/Enter 补全、侧栏、原生命令输入和终端运行。
侧栏布局已检查 60、80、100、120、160 列的缩放；原有 157 个映射保持一致。

### Python 刷题模板与未使用变量

重新启动 zsh 或执行 `source ~/.zshrc` 后：

```sh
vim test.py              # 正常打开，不添加模板
vim --template test.py   # 仅空的 .py 文件插入模板
```

模板采用 `Solution` 类结构；根据题目修改方法签名，个人信息与题目记录可自行编辑。
模板里的首个 `# @cursor` 标记在插入时删除，光标定位到该行；文件内容需要手动保存。
已有内容（包括空格）的文件不会插入模板。在 Vim 内也可以执行 `:PythonTemplate`。

Ruff 报告的未使用导入、局部变量、类型注解，以及已启用的未使用参数检查，改为暗色文字，不进入侧边诊断或错误列表；其他诊断保留。
显示在退出插入模式或保存后刷新。未变化的缓冲区和诊断会复用暗色标记，避免重复扫描与绘制。

NERDTree 在首次调用文件树命令或打开目录时加载，保留目录浏览和文件菜单。
本机启动测量各 7 次的中位数：普通启动约 52 → 19 ms，Python 文件约 70 → 33 ms；不包含语言服务就绪时间。
完整验证记录见 [VALIDATION.md](.config/vim/VALIDATION.md)。
