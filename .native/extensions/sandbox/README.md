# Sandbox Extension

## Overview

The sandbox extension provides **OS-level sandboxing** for bash commands and **path policy enforcement** for pi's `read`/`write`/`edit` tools. It uses `@anthropic-ai/sandbox-runtime` to enforce filesystem and network restrictions.

## Architecture

### Three-Layer Defense

1. **OS-level sandbox** (`sandbox-exec` on macOS, `bubblewrap` on Linux) — wraps bash subprocesses
2. **Pre-execution network check** — validates domains before command runs
3. **Tool-level path enforcement** — intercepts `read`/`write`/`edit` tool calls

### Core Components

#### 1. Configuration System (`loadConfig`)

Loads and merges config from two files (project overrides global):

| File | Location |
|------|----------|
| Global | `~/.pi/agent/sandbox.json` |
| Project | `<cwd>/.pi/sandbox.json` |

**Merge order**: `DEFAULT_CONFIG` → global → project (project wins)

Config structure:
```typescript
interface SandboxConfig {
  enabled?: boolean;
  network: {
    allowedDomains: string[];  // e.g., ["github.com", "*.github.com"]
    deniedDomains: string[];
  };
  filesystem: {
    denyRead: string[];   // Default: ["/Users", "/home"]
    allowRead: string[];  // Default: [".", "~/.config", "~/.local", "Library"]
    allowWrite: string[]; // Default: [".", "/tmp"]
    denyWrite: string[];  // Default: [".env", ".env.*", "*.pem", "*.key"]
  };
}
```

#### 2. Session Memory vs Config Files

Three types of allowances with different persistence:

| Type | Storage | Access |
|------|---------|--------|
| **Session** | JS arrays in memory | Agent cannot access |
| **Project** | `<cwd>/.pi/sandbox.json` | Project-scoped |
| **Global** | `~/.pi/agent/sandbox.json` | All projects |

#### 3. Precedence Rules (Critical)

```
Read:   allowRead OVERRIDES denyRead
        ↑ Prompt grants add to allowRead

Write:  denyWrite OVERRIDES allowWrite
        ↑ Most-specific deny wins, never prompted
```

This means:
- `denyRead` is NOT a hard-block — it just sets the default denied state
- `denyWrite` IS a hard-block — write/edit tools are blocked, bash writes fail at OS level

## Event Handlers

### `session_start`
- Initializes `SandboxManager` with merged config
- Sets `sandboxEnabled = true` and `sandboxInitialized = true`
- Configures `NODE_OPTIONS=--use-env-proxy` for Node 22+ (proxy support)
- Updates UI status bar with domain/write path counts

### `session_shutdown`
- Calls `SandboxManager.reset()` to clean up sandbox

### `user_bash` (User-initiated bash)
- Pre-checks all domains in command
- If domain not allowed: prompts user → applies choice → returns sandboxed ops
- If aborted: returns blocked message with exit code 1

### `tool_call` (All tool calls)
Handles three cases:

**A. Bash tool network check** (if sandbox enabled):
- Extracts domains from command
- Prompts if not in `effectiveAllowedDomains`
- Returns `{ block: true }` or `{ operations: createSandboxedBashOps() }`

**B. Read tool path policy**:
- Always prompts if path not in `effectiveAllowRead`
- Granting adds to `allowRead` (overrides `denyRead`)

**C. Write/Edit tool path policy**:
```
IF path matches allowWrite:
    → ALLOW (if not in denyWrite)
    → BLOCK (if also in denyWrite, with warning)

IF path does NOT match allowWrite:
    → PROMPT (session/project/global options)
    → If granted but in denyWrite: BLOCK with warning
```

### Bash Tool Execution (sandboxed)
- Wraps command via `SandboxManager.wrapWithSandbox()`
- Spawns bash subprocess with sandbox constraints
- **Post-execution**: Detects "Operation not permitted" errors for write paths
- If write blocked: prompts → applies → retries command

### Custom Commands

| Command | Function |
|---------|----------|
| `/sandbox` | Shows current configuration |
| `sandbox-enable` | Enables sandbox mid-session |
| `sandbox-disable` | Disables sandbox mid-session |

## Key Functions

### Domain Matching
```typescript
domainMatchesPattern(domain, pattern)
// "*" prefix matches subdomains
// "github.com" matches exact
// "*.github.com" matches "api.github.com", "raw.githubusercontent.com"
```

### Path Matching
```typescript
matchesPattern(filePath, patterns)
// Expands ~ to home directory
// Resolves to absolute paths
// "*" wildcards in patterns
// Matches if path equals or is child of pattern
```

### Config File Writers
- `addDomainToConfig()` — adds domain to `allowedDomains`
- `addReadPathToConfig()` — adds path to `allowRead`
- `addWritePathToConfig()` — adds path to `allowWrite`

## UI Flow

When a block is triggered, user sees:

```
🌐 Network blocked: "example.com" is not in allowedDomains
1. Abort (keep blocked)
2. Allow for this session only
3. Allow for this project  →  .pi/sandbox.json
4. Allow for all projects  →  ~/.pi/agent/sandbox.json
```

Same prompt style for read/write, just different icons and messages.

## Flag

```typescript
pi.registerFlag("no-sandbox", {
  type: "boolean",
  default: false,
})
```
- `--no-sandbox` CLI flag disables OS-level sandboxing
- Session-temporary network/path allowances still apply

## Platform Support

| Platform | Sandbox Backend |
|----------|-----------------|
| macOS | `sandbox-exec` |
| Linux | `bubblewrap` + `socat` + `ripgrep` |
| Windows | Not supported (sandbox disabled) |

## Dependencies

- `@carderne/sandbox-runtime` (aliased as `@anthropic-ai/sandbox-runtime`)
- Node.js built-ins: `child_process`, `fs`, `os`, `path`

## Important Implementation Details

1. **Session allowances bypass OS sandbox** — they only affect tool-level path checks, not bash subprocesses

2. **Sandbox reinitialization** — after granting session/project/global allowances, `SandboxManager.reset()` + `initialize()` is called so the OS-level sandbox picks up new rules

3. **Detached child processes** — bash processes are spawned with `detached: true` to allow process group kill on timeout

4. **Process group kill** — uses `kill(-child.pid)` to kill entire process tree on timeout

5. **Node proxy config** — sets `NODE_OPTIONS=--use-env-proxy` for Node 22+ so child processes inherit HTTP_PROXY/HTTPS_PROXY

## State Variables

```typescript
let sandboxEnabled = false;        // User-facing enabled state
let sandboxInitialized = false;    // SandboxManager ready

const sessionAllowedDomains: string[] = [];
const sessionAllowedReadPaths: string[] = [];
const sessionAllowedWritePaths: string[] = [];
```

## File Locations

- Extension: `~/.pi/agent/extensions/sandbox/index.ts`
- Global config: `~/.pi/agent/sandbox.json`
- Project config: `<project>/.pi/sandbox.json`
