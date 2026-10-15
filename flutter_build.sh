#!/usr/bin/env bash
set -euo pipefail

# Install Flutter SDK here if it is not already available.
# Add the Flutter SDK's bin directory to PATH.

flutter --version
flutter pub get

flutter build web --release \
  --dart-define=PROXY=https://gr0ve-proxy.arjyuvaraj.workers.dev \
  --dart-define=SCHEDULE_URL=https://raw.githubusercontent.com/gr0ve-bca/f0rest/refs/heads/main/lib/src/schedule/schedules.json