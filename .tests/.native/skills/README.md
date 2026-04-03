# pi-skills

A collection of skills for [pi-coding-agent](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent), compatible with Claude Code, Codex CLI, Amp, and Droid.

## Available Skills

| Skill | Description |
|-------|-------------|
| [brave-search](brave-search/SKILL.md) | Web search and content extraction via Brave Search |
| [browser-tools](browser-tools/SKILL.md) | Interactive browser automation via Chrome DevTools Protocol |
| [transcribe](transcribe/SKILL.md) | Speech-to-text transcription via Groq Whisper API |
| [vscode](vscode/SKILL.md) | VS Code integration for diffs and file comparison |
| [youtube-transcript](youtube-transcript/SKILL.md) | Fetch YouTube video transcripts |
| [zed](zed/SKILL.md) | Zed integration for diffs and file comparison |

## Skill Format

Each skill follows the pi/Claude Code format:

```markdown
---
name: skill-name
description: Short description shown to agent
---

# Instructions

Detailed instructions here...
Helper files available at: {baseDir}/
```

The `{baseDir}` placeholder is replaced with the skill's directory path at runtime.

## Requirements

Some skills require additional setup. Generally, the agent will walk you through that. But if not, here you go:

- **brave-search**: Requires Node.js. Run `npm install` in the skill directory.
- **browser-tools**: Requires Chrome and Node.js. Run `npm install` in the skill directory.
- **transcribe**: Requires curl and a Groq API key.
- **vscode**: Requires VS Code with `code` CLI in PATH.
- **youtube-transcript**: Requires Node.js. Run `npm install` in the skill directory.
- **zed**: Requires Zed with `zed` CLI in PATH.

## License

MIT
