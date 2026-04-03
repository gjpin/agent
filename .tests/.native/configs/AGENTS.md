# Behaviour
- Do NOT start implementing, designing or modifying code unless explicitely asked
- When user mentions an issue or topic, just summarize/discuss it - don't jump into action
- Wait for explicit instructions like "implement this", "fix this", "create this"

# Additional tools
There are additional command line tools you can use in ~/.pi/agent/skills. To use the tools, read the README.md file in the respective sub directory:
- ~/.pi/agent/skills/brave-search: Web search and content extraction via Brave Search API. Use for searching documentation, facts, or any web content. Lightweight, no browser required.
- ~/.pi/agent/skills/browser-tools: Interactive browser automation via Chrome DevTools Protocol. Use when you need to interact with web pages, test frontends, or when user interaction with a visible browser is required.
- ~/.pi/agent/skills/transcribe: Speech-to-text transcription using Groq Whisper API. Supports m4a, mp3, wav, ogg, flac, webm.
- ~/.pi/agent/skills/vscode: VS Code integration for viewing diffs and comparing files. Use when showing file differences to the user.
- ~/.pi/agent/skills/youtube-transcript: Fetch transcripts from YouTube videos for summarization and analysis.
- ~/.pi/agent/skills/zed: Zed integration for viewing diffs and comparing files. Use when showing file differences to the user.
