#!/bin/bash

# Run tests
flutter test

# Build Android APK
flutter build apk --release

# Build iOS (requires macOS)
# flutter build ipa --release