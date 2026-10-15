```bash
#!/usr/bin/env bash
set -euo pipefail

# Install Flutter SDK
git clone https://github.com/flutter/flutter.git \
  --depth 1 \
  -b stable \
  "$HOME/flutter"

export PATH="$HOME/flutter/bin:$PATH"

# Configure Flutter
flutter --version
flutter config --enable-web

# Install project dependencies
flutter pub get

# Build Gr0ve for web
flutter build web --release \
  --dart-define=PROXY=https://gr0ve-proxy.arjyuvaraj.workers.dev \
  --dart-define=SCHEDULE_URL=https://raw.githubusercontent.com/gr0ve-bca/f0rest/refs/heads/main/lib/src/schedule/schedules.json
```