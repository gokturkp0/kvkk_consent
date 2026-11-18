#!/usr/bin/env bash
# Single command every contributor (human or AI agent) runs before finishing.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== format"
dart format --output=none --set-exit-if-changed lib test example/lib
echo "== deps"
flutter pub get >/dev/null
(cd example && flutter pub get >/dev/null)
echo "== analyze"
flutter analyze
echo "== test"
flutter test
echo "✓ all checks passed"
