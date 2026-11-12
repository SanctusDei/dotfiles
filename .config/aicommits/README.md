# Git 提交信息模板

编辑 `~/.config/aicommits/commit-prompt.txt` 即可修改模板。使用 UTF-8 纯文本，无需转义、无需重启。下一次 `git commit` 自动读取。

默认使用中文和 Conventional Commits 标题加正文。仅对使用当前已打补丁的 aicommits 安装的 Git hook 生效。

## 升级或切换 Node 版本后

在能找到目标 aicommits 安装的终端中执行：

```sh
python3 ~/.config/aicommits/apply-template.py
```

脚本不会覆盖模板，会先验证程序结构和语法、备份程序文件，再接入模板。重复运行不会重复打补丁。若新版结构不兼容，会停止，不修改程序。

新仓库安装 hook：`aicommits hook install`。已有仓库切换到另一份安装时，应重新安装该仓库的 hook。

## 注意

模板文件必须存在且非空。不要在模板中放 API 密钥等秘密，它会作为提示词发送给配置的模型。备份位于 aicommits 的 dist 目录，名称含 before-file-template；最早的修改前备份以 before-detailed-template 结尾。

本目录中的 apply-template.py 是兼容补丁，aicommits 暂不原生支持 hook 自定义模板配置。
