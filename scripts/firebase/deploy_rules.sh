#!/bin/bash

# Deploy Firestore security rules
firebase deploy --only firestore:rules

# Deploy Firebase functions
firebase deploy --only functions

# Optional: Deploy hosting
# firebase deploy --only hosting