"""Bridge UTF-8 stdin to the Windows clipboard without shell interpolation."""
import subprocess
import sys


def main():
    text = sys.stdin.buffer.read().decode("utf-8")
    data = b"\xff\xfe" + text.encode("utf-16le")
    result = subprocess.run(
        ["/mnt/c/Windows/System32/clip.exe"],
        input=data,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=10,
        check=False,
    )
    if result.returncode:
        sys.stderr.buffer.write(result.stderr)
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
