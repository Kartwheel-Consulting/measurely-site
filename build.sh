#!/usr/bin/env bash
# Build script for Render (or any Linux CI).
#
# Render's static-site image has no Flutter, so this fetches it, builds, and
# leaves the site in build/web.
#
# PIN THE VERSION. Set FLUTTER_VERSION in Render's environment to exactly what
# `flutter --version` prints on the machine where the tests passed (e.g.
# 3.35.4). Left on "stable", a new Flutter release can change the build
# without anyone touching this project.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"
FLUTTER_DIR="${HOME}/flutter-${FLUTTER_VERSION}"

if [ ! -x "${FLUTTER_DIR}/bin/flutter" ]; then
  echo "Installing Flutter ${FLUTTER_VERSION}..."
  git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
fi
export PATH="${FLUTTER_DIR}/bin:${PATH}"

flutter --version
flutter config --no-analytics >/dev/null
flutter pub get
flutter test
flutter build web --release

# Render's rewrite handles unknown paths, but a real 404 page is kinder to
# anything that ignores the rewrite (and to other hosts).
cp build/web/index.html build/web/404.html
echo "Built build/web"
