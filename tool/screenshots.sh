#!/usr/bin/env bash
# Regenerates doc/screenshots/*.png from test/screenshots_test.dart.
set -euo pipefail
cd "$(dirname "$0")/.."

flutter test --update-goldens --dart-define=KVKK_SCREENSHOTS=true \
  test/screenshots_test.dart
ls -lh doc/screenshots/
