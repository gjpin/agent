# Web Search Skill Refactoring Plan

## Overview

Refactor the existing `brave-search` skill (or create new `web-search` skill) into a **multi-provider architecture** that supports:
- **Brave Search** (existing)
- **Linkup** (new)

The architecture will cleanly separate:
1. **Core/Common layer** - Shared functionality (CLI parsing, output formatting, content extraction, provider-agnostic logic)
2. **Provider adapters** - Provider-specific API calls and response normalization

---

## Directory Structure

```
web-search/
├── SKILL.md                    # Updated documentation
├── package.json                # Dependencies (shared + provider-specific)
├── node_modules/
├── src/
│   ├── index.js                # Main entry - CLI routing based on --provider
│   ├── cli.js                  # Command-line argument parsing (shared)
│   ├── output.js               # Result formatting/display (shared)
│   │
│   ├── providers/
│   │   ├── base.js             # Abstract base provider class
│   │   ├── brave.js            # Brave Search adapter
│   │   └── linkup.js           # Linkup adapter
│   │
│   ├── content/
│   │   ├── extractor.js        # Common page content extraction logic
│   │   └── markdown.js         # HTML to markdown conversion (shared)
│   │
│   └── utils/
│       └── errors.js           # Custom error classes
│
├── search.js                   # CLI wrapper for search (entry point)
└── content.js                  # CLI wrapper for content extraction (unchanged or minimal)
```

---

## TODO Items

### Phase 1: Project Setup

- [ ] **1.1** Create new `web-search/` directory structure as shown above
- [ ] **1.2** Create `package.json` with shared dependencies:
  - `jsdom`
  - `@mozilla/readability`
  - `turndown`
  - `turndown-plugin-gfm`
- [ ] **1.3** Copy `content.js` to `src/content/` for content extraction module
- [ ] **1.4** Create `src/utils/errors.js` with custom error classes:
  - `SearchError` - Base error class
  - `ProviderError` - Provider-specific errors (API failures, auth issues)
  - `ContentExtractionError` - Content fetching failures

### Phase 2: Core Layer (Shared)

- [ ] **2.1** Create `src/utils/errors.js`
  ```javascript
  export class SearchError extends Error { ... }
  export class ProviderError extends Error { ... }
  export class ContentExtractionError extends Error { ... }
  ```

- [ ] **2.2** Create `src/content/markdown.js`
  - Move `htmlToMarkdown()` function from current implementation
  - Configure TurndownService with GFM support
  - Handle edge cases (empty links, extra whitespace)

- [ ] **2.3** Create `src/content/extractor.js`
  - Move `fetchPageContent()` function from current implementation
  - Extract URL, apply Readability, fallback logic
  - Return markdown-converted content

- [ ] **2.4** Create `src/output.js`
  - `formatResults(results)` - Format and print search results
  - Support consistent output format regardless of provider
  - Handle optional content display
  - Print result metadata (title, link, age, snippet, content)

- [ ] **2.5** Create `src/cli.js`
  - Parse common CLI arguments:
    - `--provider <name>` - Select provider (brave|linkup), default: first available or config
    - `-n <num>` - Number of results (default: 5)
    - `--content` - Fetch page content
    - `--freshness <period>` - Time filter (provider-specific handling)
    - `--country <code>` - Country code (Brave-specific)
  - Extract remaining args as query
  - Return parsed options object

### Phase 3: Provider Architecture

- [ ] **3.1** Create `src/providers/base.js`
  - Define abstract `SearchProvider` class
  - Abstract methods:
    - `search(query, options)` - Returns normalized results
    - `supportsFeature(feature)` - Check if provider supports a feature
  - Features enum: `CONTENT_FETCH`, `FRESHNESS`, `COUNTRY_FILTER`
  - Error handling wrapper for provider calls

- [ ] **3.2** Create `src/providers/brave.js`
  - Extend `SearchProvider`
  - Read API key from `BRAVE_API_KEY`
  - Implement `search()`:
    - Build Brave API URL with query, count, country, freshness
    - Make fetch request with proper headers
    - Normalize Brave response to standard format
  - Implement `supportsFeature()`:
    - Supports: CONTENT_FETCH, FRESHNESS, COUNTRY_FILTER
  - Map errors appropriately (401 = auth, 429 = rate limit)

- [ ] **3.3** Create `src/providers/linkup.js`
  - Extend `SearchProvider`
  - Read API key from `LINKUP_API_KEY`
  - API endpoint: `POST https://api.linkup.so/v1/structured-search`
  - Request body format:
    ```json
    {
      "query": "search query",
      "depth": "standard",  // or "shallow", "deep"
      "num_results": 5
    }
    ```
  - Response normalization (Linkup returns different structure)
  - Implement `supportsFeature()`:
    - Supports: CONTENT_FETCH (Linkup includes content in response)
    - May not support: FRESHNESS, COUNTRY_FILTER (check docs)
  - Handle Linkup-specific errors

### Phase 4: Main Entry Points

- [ ] **4.1** Create `src/index.js`
  - Load available providers based on env vars
  - Select provider (CLI arg or fallback order)
  - Instantiate provider
  - Execute search with options
  - Handle errors and format output

- [ ] **4.2** Update `search.js` (CLI wrapper)
  ```javascript
  #!/usr/bin/env node
  import { runSearch } from './src/index.js';
  runSearch();
  ```

- [ ] **4.3** Update `content.js` (unchanged from original)
  - Keep as standalone for direct URL content extraction
  - Or point to shared `src/content/extractor.js`

### Phase 5: Provider Auto-Detection

- [ ] **5.1** Implement provider auto-detection in `src/index.js`:
  ```javascript
  function getAvailableProvider() {
    if (process.env.LINKUP_API_KEY) return 'linkup';
    if (process.env.BRAVE_API_KEY) return 'brave';
    throw new Error('No search provider API key found');
  }
  ```

- [ ] **5.2** Allow `--provider` flag to override:
  ```javascript
  const provider = cliArgs.provider || getAvailableProvider();
  ```

### Phase 6: Documentation

- [ ] **6.1** Update `SKILL.md` with:
  - Multi-provider architecture overview
  - Setup instructions for each provider
  - CLI usage with `--provider` flag
  - Per-provider feature support table
  - Examples for each provider

- [ ] **6.2** Document feature matrix:

  | Feature          | Brave | Linkup |
  |------------------|-------|--------|
  | Basic Search     | ✓     | ✓      |
  | Content Extract  | ✓     | ✓      |
  | Freshness Filter | ✓     | ?      |
  | Country Filter   | ✓     | ✗      |

### Phase 7: Testing & Validation

- [ ] **7.1** Test Brave Search:
  - [ ] Basic search
  - [ ] Search with `--content`
  - [ ] Search with `--freshness`
  - [ ] Search with `--country`

- [ ] **7.2** Test Linkup Search:
  - [ ] Basic search
  - [ ] Search with `--content`
  - [ ] Verify response normalization

- [ ] **7.3** Test provider switching:
  - [ ] `--provider brave`
  - [ ] `--provider linkup`

- [ ] **7.4** Test error handling:
  - [ ] Missing API key
  - [ ] Invalid API key
  - [ ] Network errors
  - [ ] Rate limiting

---

## Implementation Order

1. **Phase 1** - Setup (create structure, package.json)
2. **Phase 2** - Core/Shared utilities
3. **Phase 3** - Provider implementations
4. **Phase 4** - Main entry points
5. **Phase 5** - Auto-detection
6. **Phase 6** - Documentation
7. **Phase 7** - Testing

---

## API Key Environment Variables

| Provider | Environment Variable |
|----------|---------------------|
| Brave    | `BRAVE_API_KEY`     |
| Linkup   | `LINKUP_API_KEY`    |

---

## Standard Result Format

All providers must normalize to this format:

```javascript
{
  title: string,      // Page title
  link: string,      // URL
  snippet: string,   // Description/summary
  age?: string,      // Publication date (if available)
  content?: string   // Extracted content (if --content used)
}
```

---

## Future Extensibility

This architecture supports easy addition of new providers:

1. Create new file in `src/providers/` (e.g., `serpapi.js`, `googlesearch.js`)
2. Extend `SearchProvider` base class
3. Implement `search()` and `supportsFeature()`
4. Register in `src/index.js` provider map

No changes to core logic required.
