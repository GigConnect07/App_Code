#!/bin/bash

# Install Flutter dependencies
flutter pub get

# Install Firebase Tools
npm install -g firebase-tools

# Configure Firebase project
firebase login
firebase projects:list
echo "Run 'firebase use --add' to select your project"