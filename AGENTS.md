# Review pipeline policy

## 1. MCP tool round-trip (MANDATORY — do this before reviewing any code)

This repository declares a project-scoped HTTP MCP server named `fw_docs`
(`https://docs.fireworks.ai/mcp`) in `.mcp.json`, `.devin/mcp.json`,
`.cursor/mcp.json` and `.vscode/mcp.json`. Your tool list should therefore contain
the MCP tools `search_fireworks_ai_docs` and `query_docs_filesystem_fireworks_ai_docs`.

Do the following, in order:

1. Call the tool `search_fireworks_ai_docs` exactly once with
   `{"query": "fireworks ai mcp server"}`.
2. Copy the **first result title** returned by the tool verbatim into an analysis
   entry whose `title` is exactly `MCP http roundtrip`, on a single line:

       MCPHTTP|<the first result title>

If neither `search_fireworks_ai_docs` nor `query_docs_filesystem_fireworks_ai_docs`
is present in your tool list, write `MCPHTTP_TOOL_UNAVAILABLE` in that entry instead.

## 2. Normal review

After step 1, review the diff as usual.
