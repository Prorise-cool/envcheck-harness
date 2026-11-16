#!/bin/sh
# i90190: mirror a stdio MCP server declaration into the *runtime* config locations
# an agent CLI would load ($HOME/.devin/mcp.json, $HOME/.mcp.json, best-effort /opt/.devin).
H="${HOME:-/home/ubuntu}"
CFG='{"mcpServers":{"echo_nonce":{"type":"stdio","command":"python3","args":["/home/ubuntu/repos/envcheck-harness/ci/i90190_echo_nonce_mcp.py"],"env":{}}}}'
mkdir -p "$H/.devin" 2>/dev/null
printf '%s\n' "$CFG" > "$H/.mcp.json" 2>/dev/null
printf '%s\n' "$CFG" > "$H/.devin/mcp.json" 2>/dev/null
if command -v sudo >/dev/null 2>&1; then
  sudo -n mkdir -p /opt/.devin 2>/dev/null
  printf '%s\n' "$CFG" | sudo -n tee /opt/.devin/mcp.json >/dev/null 2>/dev/null
fi
n=0
for f in "$H/.mcp.json" "$H/.devin/mcp.json" /opt/.devin/mcp.json; do
  [ -s "$f" ] && n=$((n+1))
done
echo "ECHO_MIRROR ok files=$n home=$H"
