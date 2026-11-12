# 验证记录（2026-11-07）

- 默认交互式 vim 自动加载 /home/Master/.vimrc；启动和功能验证无配置错误。
- 仅启用 9 个插件；旧 ~/.vim/plugin、ftplugin、after 未加载；Ctrl-w 无覆盖映射。
- Python：Ruff 能报告未使用 import 和未定义变量；格式化已通过。
- Python：真实插入模式中 Ctrl-x Ctrl-o 返回 os.pa 的 6 项候选，含 path、pardir。
- Jedi 初始化成功且关闭诊断，由 Ruff 负责 Python 诊断。
- C++：clangd 报告 missing_name 未声明；无项目标记的独立文件也能检查。
- C++：clang-format 实际格式化通过。
- 带空格、单引号的 C++ 与 Python 文件路径运行成功。
- C++ 编译失败返回非零，未执行旧产物。
- F5 实际创建 Vim 终端并输出 TERMINAL_OK。
- NERDTree 文件树与 Tagbar 侧栏均实际打开成功。
- 启用 swap、集中备份、持久撤销；旧配置和旧插件脚本已备份。

临时测试记录：/tmp/vim-integration-u27k3hot/、/tmp/vim-final-check-2av762jw/。

## 复查补齐（2026-11-07）

- 关闭视觉铃声与终端闪烁序列，belloff=all；模式切换不更改行号。
- 命令区固定两行，诊断保留标记，按 ;k 查看详情。
- 新增 :PythonInfo、:VimHealth，所有必要工具与插件目录检查通过。
- 项目 .venv 的 F5 实际执行路径与 Jedi environmentPath 一致。
- 验证已激活环境、项目虚拟环境、手动指定解释器的选择顺序。
- 实际插入模式补全成功返回仅安装在测试 .venv 中的 unique_env_function。
- 启动与配置检查无报错。
- 测试记录：/tmp/vim-review-x5o4g1r8/。

## 自动补全修复（2026-11-07）

- 开启 ALE 自动补全，延迟 180 毫秒。
- 修复 Tab：非缩进位置调用语言服务补全，不再仅搜索缓冲区单词。
- 真实插入模式实测：自动请求来源为 ale-automatic，返回项目环境独有函数。
- 暂时关闭测试缓冲区自动补全后，Tab 请求来源为 ale-omnifunc，仍能返回该函数；再次 Tab 成功插入候选。

## 字符串补全（2026-11-07）

- 普通 Python 字符串自动弹出已有文本 hello_world，Tab 插入后保留引号。
- 字符串路径 ./data-files/re 手动 Tab 返回 report.csv；选择后得到 ./data-files/report.csv，引号与前缀完整。
- 直接候选检查与交互式输入均无错误。
- 测试记录：/tmp/vim-strings-59ieqrie/。

## C++ 字符串 / Enter（2026-11-07）

- C++ 字符串实际输入自动弹出 hello_world；未选候选时 Enter 接受第一项，文件仍为两行。
- Python 字符串 Tab 选候选再 Enter 确认，文件仍为两行。
- 无补全菜单时在 C++ {} 中 Enter 正常生成中间缩进行，括号配对保留。
- 以上交互式测试无配置错误；记录 /tmp/vim-cpp-enter-4q5_kefv/。

## 效率与 VimKeys（2026-11-07）

- 字符串文本扫描改为 Vim matchbufline 原生搜索，按缓冲区 changedtick 与输入前缀缓存；范围保持前 10000 行和最多 80 个文本候选。
- 同一临时 10000 行样例：旧实现约 417/430 ms；新实现首次约 11.2 ms、未修改的重复查询约 0.06 ms。该结果为本机合成样例，不代表全部项目。
- 7 组候选与旧实现逐项一致；编辑后缓存失效、新词可见，已删除词不再出现。
- 缩减无效字符串计时器，离开缓冲区取消待执行计时器；BufEnter 仅检查进入的文件，FocusGained 仍执行全局检查。
- Python/C++ 实际自动补全、Tab、Enter 均通过，确认候选后文件仍为两行。
- VimKeys 重写为当前功能说明；支持 ;?、:VimKeys 主题、Tab 主题选择、q 返回；只读窗口复用，不修改源码。
- 测试记录：/tmp/vim-efficiency-kdw66_4a/。备份：~/.config/vim-backups/efficiency-20261107-161759/。

## 性能优化（2026-11-08）

- 保持全部 9 个插件、现有快捷键、不透明主题、补全延迟和备份恢复设置。
- 为现有 fzf 二进制建立 ~/.local/bin/fzf 链接，避免每次启动遍历 Windows PATH 后才找到回退路径；使用的二进制不变。
- shellcheck 可用性检测移到首次打开 sh 缓冲区时执行，仍按是否安装决定启用；Python/C++ 的检查和补全设置不变。
- 字符串补全仅在旧候选完整且缓冲区未改变时，复用更短前缀的结果；候选达到 80 项、缩短前缀、非单词前缀或文本改变时仍重新扫描。保持前 10000 行、最多 80 项和候选顺序。
- 相同的 vim -es --startuptime 启动测试各 5 次：中位数 122.91 ms → 57.51 ms。
- 10000 行合成样例、5 个连续前缀、各 7 次：整组中位数 945.61 ms → 207.84 ms；这不是首次全量扫描的单次耗时。
- 30 组补全查询与旧实现逐项一致，覆盖大小写、80 项截断、10000 行边界、前缀变化；另验证修改内容后缓存失效。
- Python/C++ 诊断与格式化、文件树、Tagbar、fzf、终端运行和 shell 检查规则通过回归。
- 真实伪终端验证 Jedi 的 path 候选和字符串 hello_world 补全；Tab/Enter、引号与行数保持正确。
- 备份：/home/Master/.config/vim-backups/performance-20261108-210235/。测试与原始数据：/tmp/vim-performance-aymj8lff/。

## 效率复查（2026-11-09）

- 保留 9 个插件、原有快捷键、备份恢复选项、补全与检查时机；未修改插件源文件。
- NERDTree 按命令加载，首次使用时承担原加载开销；保留所有原有命令。直接启动目录、:edit 目录、:tabedit 目录均验证由 NERDTree 接管，文件菜单正常加载。
- 暗色标记通过缓冲区元数据取得行数，避免复制全部文本；缓冲区 changedtick 和未使用诊断均相同时复用标记。Unicode 位置、修改后失效、使用后清除均通过验证。
- 窗口焦点样式仅在选项变化时写入；布局刷新合并待执行的焦点刷新，侧栏和活动窗口配色行为保留。
- 同一 vim -es --startuptime 命令各 7 次：普通启动中位数 52.415 ms → 18.842 ms；Python 文件启动 69.794 ms → 32.545 ms。仅衡量本机该启动场景，不含语言服务就绪时间。
- 五万行合成缓冲区、相同 Ruff 输出重复处理 20 次、各 7 组：整组中位数 77.390 ms → 0.819 ms；结果只说明未修改内容重复刷新时的开销，不代表每次实际检查耗时。
- Python/C++ 诊断和格式化、fzf、文件树、Tagbar、shell 检查规则、终端运行均通过回归。
- 真实伪终端中的 Jedi path 候选、字符串补全、Tab/Enter、引号与行数均验证通过。
- 保留用户自行修改后的模板，模板仅插入空文件，重复调用不插入，光标定位到用户当前独立的 @cursor 标记行；未使用导入/局部变量/注解继续变暗，未定义名称诊断保留。
- 备份：/home/Master/.config/vim-backups/efficiency-20261109-170736/。
- 测试及原始耗时：/tmp/vim-efficiency-review-hk5k9fqc/。
# 运行终止修复（2026-11-12）

- F5 新增默认 5000 毫秒时限；忽略 SIGINT/SIGTERM 的死循环被自动终止，原输出保留，末尾追加“运行超时 / Time Limit Exceeded”。
- 正常完成不误报；设置时限为 0 后不自动停止，F4 仍可停止；超时输出可按 q 关闭。
- 自动测试：/tmp/vim-run-timeout-s64w8c1s/。
- 使用忽略 SIGINT 和 SIGTERM 的 Python 死循环验证：源码窗口的 F4 和运行终端输入模式的 F4 均能强制终止任务。
- 停止后保留输出；重复停止已结束任务不会报错，普通 Python 程序输出 RUN_OK 保留。
- 真实伪终端验证 Esc Esc 后 q 停止并关闭运行窗口，:qa 在仍有死循环时正常退出；脚本验证 :q 关闭当前运行窗口。
- 配置备份：~/.config/vim-backups/run-stop-20261112-165325/。测试记录：/tmp/vim-run-stop-9873os9g/。

## Dotfiles 同步复核（2026-11-12）

- 使用待提交的 .vimrc 加载 Vim，无配置错误；Python 模板可解析并运行。
- 空 Python 文件插入模板后移除 @cursor、定位到 pass；重复插入不修改内容。
- 包内 Python 文件以 -m 执行，相对导入成功；仓库边界下的文件可找到所属 pyproject.toml 项目的虚拟环境。
- 忽略 SIGINT/SIGTERM 的循环在超时后终止，保留原输出和超时提示；正常程序输出保留且不误报。
- 关闭时限后可从源码窗口手动停止最近的运行任务；文件树在创建文件后通过 Poll 刷新。
- 本次临时验证记录：/tmp/dotfiles-vim-check-e47bec_j/。未重新执行本文件中其他历史验证。
