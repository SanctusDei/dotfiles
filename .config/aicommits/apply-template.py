"""Reapply the file-based hook prompt after upgrading aicommits.

Only the known hook structure is supported. Unknown versions are left untouched.
"""
from datetime import datetime
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


def patch_source(source):
    start = source.index('var ict=o(')
    end = source.index('"prepareCommitMessageHook"', start)
    hook = source[start:end]
    reader = 'await an.readFile(nr.join(gh.homedir(),".config","aicommits","commit-prompt.txt"),"utf8")'
    if 'customPrompt:aicommitsCustomPrompt' in hook and reader in hook:
        return source
    # Accept either the original hook or the earlier inline template.
    pattern = r'includeBody:u,timeout:a(?:,customPrompt:"(?:[^"\\]|\\.)*")?\}'
    hook, count = re.subn(pattern, lambda _: 'includeBody:u,timeout:a,customPrompt:aicommitsCustomPrompt}', hook)
    if count != 1:
        raise ValueError('Unrecognized hook structure; no changes made')
    model = 'const v=s.getGenerationModel(l);'
    if hook.count(model) != 1:
        raise ValueError('Unrecognized generation structure; no changes made')
    hook = hook.replace(model, model + 'const aicommitsCustomPrompt=(' + reader + ').trim();if(!aicommitsCustomPrompt)throw new Error("Commit prompt file is empty: ~/.config/aicommits/commit-prompt.txt");')
    updated = source[:start] + hook + source[end:]
    old = 'n?"Return a concise, non-empty body after a blank line.":"Return no body."'
    new = 'n?(s?"Return a non-empty body after a blank line, following the custom instructions below.":"Return a concise, non-empty body after a blank line."):"Return no body."'
    if new not in updated:
        if updated.count(old) != 1:
            raise ValueError('Unrecognized prompt instructions; no changes made')
        updated = updated.replace(old, new)
    return updated


def main():
    executable = shutil.which('aicommits')
    if not executable:
        raise SystemExit('aicommits is not on PATH')
    prompt = Path.home() / '.config/aicommits/commit-prompt.txt'
    if not prompt.read_text().strip():
        raise SystemExit(f'Template is empty: {prompt}')
    cli = Path(executable).resolve()
    imports = re.findall(r'import\s*"\./(cli-[^"/]+\.mjs)"', cli.read_text())
    if len(imports) != 1:
        raise SystemExit('Unrecognized aicommits entry point; no changes made')
    bundle = cli.parent / imports[0]
    source = bundle.read_text()
    updated = patch_source(source)
    if updated != source:
        with tempfile.TemporaryDirectory(prefix='aicommits-template-') as directory:
            check = Path(directory) / 'check.mjs'
            check.write_text(updated)
            subprocess.run(['node', '--check', str(check)], check=True)
        backup = bundle.with_name(bundle.name + '.before-file-template-' + datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
        shutil.copy2(bundle, backup)
        bundle.write_text(updated)
        print(f'Backup: {backup}')
    subprocess.run(['aicommits', 'config', 'set', 'type=conventional+body', 'locale=zh'], check=True)
    print(f'Hook template: {prompt}')


if __name__ == '__main__':
    main()
