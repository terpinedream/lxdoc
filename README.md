# lxdoctor

System diagnostics CLI for systemd-based Linux systems with optional PipeWire support. Designed for Arch Linux but avoids hardcoded Arch assumptions where possible; works on other systemd-based distributions.

## Requirements

- Bash 5 or later
- Standard core utilities: `systemctl`, `journalctl`, `ip`, `awk`, `sed`, `grep`, `lsblk`, `df`, etc.

## Usage

```text
lxdoctor [--json] [module]
```

- With no arguments, runs the **base** module.
- **--json** — output a single JSON object with all checks (no color).
- **module** — one of: base, network, graphics, audio, boot, dev, fs.

## Modules

| Module   | Description                          |
|----------|--------------------------------------|
| base     | Kernel, OS, uptime, memory, systemd  |
| network  | NetworkManager, routes, DNS, ICMP    |
| graphics | Session type, GPU drivers, NVIDIA    |
| audio    | PipeWire, WirePlumber, default sink |
| boot     | Boot time, slowest services, failed  |
| dev      | gcc, clang, glibc, pkg-config, libs |
| fs       | Disk usage, inodes, pacman, /etc     |

## Output

- **TTY:** Status lines with colors: `[OK]`, `[WARN]`, `[FAIL]`, `[INFO]`.
- **Non-TTY / pipe:** Same lines, no color.
- **--json:** One JSON object per run. Status values: `ok`, `warn`, `fail`, `info`.

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

## Architecture

- **Main script:** `lxdoctor` — strict mode (`set -euo pipefail`), argument parsing, and dispatch. Defines `ok()`, `warn()`, `fail()`, `info()` used by modules.
- **Modules:** Sourced from `modules/<name>.sh`. Each defines a single entry point `run_<name>()`. No shared globals; modules only call the reporting functions provided by the main script.
- **JSON:** When `--json` is set, reporting functions append to an internal array; the main script prints one JSON object after the module returns.

## Example JSON output

See [example-output.json](example-output.json) for sample `lxdoctor --json base` output.
