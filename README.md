# lxdoctor

System diagnostics CLI for systemd-based Linux systems with optional PipeWire support. Designed for Arch Linux but avoids hardcoded Arch assumptions where possible; works on other systemd-based distributions.

## Requirements

- Bash 5 or later
- Standard core utilities: `systemctl`, `journalctl`, `ip`, `awk`, `sed`, `grep`, `lsblk`, `df`, etc.

## Usage

```text
lxdoctor [--json] [--no-color] [--version] [--report] [module]
```

- With no arguments, runs the **base** module.
- **--json** — output a single JSON object (no color). Use `all` as module to get one object with every module's checks.
- **--no-color** — disable color and use text status (`[OK]` / `[WARN]` etc.) in the table. Respects the `NO_COLOR` environment variable when set.
- **--version** — print version and exit.
- **--report** — run all modules and print a **detailed issues report** (warnings and failures only), grouped by module. Useful for spotting common or recent problems quickly. Exit code is 1 if any failure occurred.
- **module** — one of: **all**, base, network, graphics, audio, boot, dev, fs (default: base). Use **all** to run every module.

## Modules

| Module   | Description                          |
|----------|--------------------------------------|
| all      | Run every module (table per module or one JSON) |
| base     | Kernel, OS, uptime, memory, systemd  |
| network  | NetworkManager, routes, DNS, ICMP    |
| graphics | Session type, GPU drivers, NVIDIA   |
| audio    | PipeWire, WirePlumber, default sink |
| boot     | Boot time, slowest services, failed  |
| dev      | gcc, clang, glibc, pkg-config, libs |
| fs       | Disk usage, inodes, pacman, /etc     |

## Output

- **TTY:** A Unicode table with columns Check, Status, Message. Status uses symbols (✓ ⚠ ✗ ℹ) and color. Use `--no-color` to disable color and show `[OK]` / `[WARN]` / `[FAIL]` / `[INFO]` in the table.
- **Non-TTY (pipe/redirect):** Line-by-line `[OK]` / `[WARN]` / `[FAIL]` / `[INFO]` with no color.
- **--json:** One JSON object per run. Status values: `ok`, `warn`, `fail`, `info`. Exit code is 1 if any check has status `fail`.

### JSON schema

```json
{
  "module": "base",
  "checks": [
    { "name": "kernel", "status": "ok", "message": "6.5.0-arch1-1" },
    { "name": "os_release", "status": "ok", "message": "Arch Linux" }
  ]
}
```

## Installation

- Ensure the **`modules/`** directory sits next to the `lxdoctor` script (same layout as in this repo). Then put `lxdoctor` on your PATH.
- **Symlink (recommended):** e.g. copy the project to `/opt/lxdoc`, then `ln -s /opt/lxdoc/lxdoctor /usr/bin/lxdoctor` and `ln -s /opt/lxdoc/modules /usr/bin/modules`. Or symlink both into `~/.local/bin` if that is on your PATH.
- **Copy:** Copy `lxdoctor` and the whole `modules/` directory into a directory on your PATH (e.g. `/usr/bin/lxdoctor` and `/usr/bin/modules/`).

## Architecture

- **Main script:** `lxdoctor` — strict mode (`set -euo pipefail`), argument parsing, and dispatch. Defines `ok()`, `warn()`, `fail()`, `info()` used by modules. Module list is discovered from `modules/*.sh`; the virtual module **all** runs every discovered module.
- **Modules:** Sourced from `modules/<name>.sh`. Each defines a single entry point `run_<name>()`. No shared globals; modules only call the reporting functions provided by the main script.
- **JSON:** When `--json` is set, reporting functions append to an internal array; the main script prints one JSON object after the module returns (or a combined object with `"run":"all"` when module is **all**).

## Example JSON output

See [example-output.json](example-output.json) for sample `lxdoctor --json base` output.
