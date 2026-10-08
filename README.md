# oohistory: Sovereign Tamper-Evident Command History & Audit Ledger

<div align="center">

```
================================================================================
                                 oohistory
               Sovereign openOODA Tamper-Evident Audit Ledger
================================================================================
```

**Sovereign Command History & Audit Ledger**  
*Tamper-evident append-only shell command history with cryptographic hash chaining and automatic secret redaction.*  
*Two Faces, One Engine:* Modern terminal ergonomics for humans • Zero-leakage MCP for AI agents  
Written in 100% pure [openOODA](https://github.com/openOODA).

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![openOODA](https://img.shields.io/badge/openOODA-1.0-emerald.svg)](https://openooda.org)
[![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-orange.svg)]()
[![Architecture: x86_64](https://img.shields.io/badge/Arch-x86__64-lightgrey.svg)]()

</div>

---

## 1. Quick Install

### Automated Installer (Linux x86_64)
```bash
curl -fsSL https://openooda-tools.github.io/oohistory/install.sh | bash
```

### Native Package Managers
```bash
# Arch Linux (PKGBUILD)
cd packaging/arch && makepkg -si

# Debian / Ubuntu (.deb)
curl -fsSL https://openooda-tools.github.io/oohistory/install.sh | bash -s -- --deb

# Fedora / RHEL (.rpm)
curl -fsSL https://openooda-tools.github.io/oohistory/install.sh | bash -s -- --rpm
```

### Uninstallation
```bash
oohistory-uninstall
# or: curl -fsSL https://openooda-tools.github.io/oohistory/uninstall.sh | bash
```

---

## 2. CLI Usage

```
usage: oohistory [options] [ARGUMENTS]...

Tamper-evident append-only shell command history with redaction of credential tokens.

Options:
  -n, --limit <NUM>     display only the last <NUM> command records
  -s, --search <QUERY>  filter history by keyword or substring
  -a, --append <CMD>    append a new command entry with secret redaction and hash chaining
  -V, --verify          audit cryptographic hash chain integrity
      --stats           display command counts, unique records, and security metrics
  -f, --file <PATH>     override default ledger file location (~/.oohistory_ledger)
      --no-color        suppress ANSI status colors
  -j, --json            output structured JSON telemetry
  -D, --demo            run interactive secret redaction and tamper detection showcase
      --test            run internal verification anchor self-test suite
  -h, --help            display this help and exit
  -v, --version         output version information and exit
      --mcp             run as Model Context Protocol stdio server
```

### Examples
```bash
# Display the last 15 command entries
oohistory -n 15

# Search history for docker commands
oohistory -s docker

# Append a command record (automatically masks credentials like sk-..., AKIA..., passwords)
oohistory -a "curl -H 'Authorization: Bearer sk-secret123' https://api.openai.com/v1"

# Cryptographically audit the history ledger for tampering
oohistory --verify

# View ledger telemetry and integrity metrics
oohistory --stats

# Export structured JSON Lines
oohistory -j
```

---

## 3. Model Context Protocol (MCP)

When invoked with `--mcp`, `oohistory` runs a JSON-RPC 2.0 stdio server providing structured tools for AI coding agents:

```bash
oohistory --mcp
```

### Exposed MCP Tools

1. `history_list`: List recent command history entries with limit filtering.
   - Arguments: `limit` (Int, optional, default: 20)
2. `history_search`: Search command history entries matching a keyword query.
   - Arguments: `query` (String, required)
3. `history_append`: Append a new command to the audit ledger with automatic secret redaction.
   - Arguments: `command` (String, required), `cwd` (String, optional)
4. `history_verify`: Audit cryptographic hash chain integrity to detect retro-modification or tampering.
   - Arguments: none
5. `history_demo`: Run full interactive credential redaction and tamper detection simulation.
   - Arguments: none

---

## 4. Cryptographic Integrity & Secret Redaction

* **Merkle Hash Chaining**: Every command entry contains `prev_hash` linked to the cryptographic digest of the preceding record, forming an unbroken chain starting from a deterministic genesis digest.
* **Tamper Detection**: Any modification, insertion, deletion, or reordering breaks the chain hash link and is flagged immediately with record coordinates.
* **Automatic Secret Redaction**: Intercepts OpenAI keys (`sk-...`), AWS Access Key IDs (`AKIA...`), GitHub PATs (`ghp_...`), Bearer authorization tokens, and inline passwords (`password=...`), recording sanitized tokens in persistent logs while tagging metadata.
* **Zero Ambient Authority**: Capabilities bounded strictly under explicit `&FsReadCap`, `&FsWriteCap`, `&ProcessCap`, and `&EnvCap` tokens. Zero ambient disk or socket operations.

---

## 5. License

Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
