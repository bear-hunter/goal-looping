#!/usr/bin/env zsh
# scripts/qa-run.sh
#
# One-command build → serve → test → cleanup loop.
# Usage:   zsh scripts/qa-run.sh
# Config:  export FLUTTER_BIN=/path/to/flutter/bin/flutter  (if not on PATH)

set -euo pipefail

PORT=8788
BUILD_DIR="build/web"
QA_DIR="qa"
MAX_WAIT=30
FLUTTER_BIN="${FLUTTER_BIN:-flutter}"

echo "======================================"
echo " Centile QA Run"
echo "======================================"
echo ""

# ── 1. Flutter build ──────────────────────────────────────────────────────────
echo "=== [1/4] Flutter web build ==="
"$FLUTTER_BIN" build web --no-wasm-dry-run 2>&1
echo ""

# ── 2. Start local server ─────────────────────────────────────────────────────
echo "=== [2/4] Starting server on :$PORT ==="
npx serve "$BUILD_DIR" -p "$PORT" -s --no-clipboard 2>/dev/null &
SERVER_PID=$!

echo "Waiting for server to be ready..."
waited=0
until curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT" | grep -q "200"; do
  if [ "$waited" -ge "$MAX_WAIT" ]; then
    echo "ERROR: Server did not start within ${MAX_WAIT}s"
    kill "$SERVER_PID" 2>/dev/null || true
    exit 1
  fi
  sleep 1
  waited=$((waited + 1))
done
echo "Server ready (${waited}s)"
echo ""

# ── 3. Playwright tests ───────────────────────────────────────────────────────
echo "=== [3/4] Running Playwright tests ==="
PLAYWRIGHT_EXIT=0
(cd "$QA_DIR" && npx playwright test 2>&1) || PLAYWRIGHT_EXIT=$?
echo ""

# ── 4. Cleanup ────────────────────────────────────────────────────────────────
echo "=== [4/4] Cleanup ==="
kill "$SERVER_PID" 2>/dev/null || true
wait "$SERVER_PID" 2>/dev/null || true
echo "Server stopped"
echo ""

# ── Result ────────────────────────────────────────────────────────────────────
if [ "$PLAYWRIGHT_EXIT" -eq 0 ]; then
  echo "✓ ALL TESTS PASSED"
else
  echo "✗ TESTS FAILED (exit $PLAYWRIGHT_EXIT)"
  echo "  Screenshots : $QA_DIR/test-results/"
  echo "  JSON report : $QA_DIR/test-results/results.json"
  echo "  HTML report : $QA_DIR/playwright-report/index.html"
fi

exit "$PLAYWRIGHT_EXIT"
