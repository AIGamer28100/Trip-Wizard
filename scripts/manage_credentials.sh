#!/bin/bash

# Credential Management Script for Trip Wizards
# This script helps safely move sensitive files to/from the creds directory

CREDS_DIR="/home/hari/Work/Flutter/learnings/creds"
PROJECT_DIR="/home/hari/Work/Flutter/learnings/build_with_speckit/TripWizards"

# Files that should be managed
GOOGLE_SERVICES="android/app/google-services.json"
KEYSTORE="upload-keystore.jks"

case "$1" in
    "backup")
        echo "Backing up credential files to $CREDS_DIR..."
        mkdir -p "$CREDS_DIR"

        if [ -f "$PROJECT_DIR/$GOOGLE_SERVICES" ]; then
            mv "$PROJECT_DIR/$GOOGLE_SERVICES" "$CREDS_DIR/"
            echo "Moved google-services.json to creds folder"
        fi

        if [ -f "$PROJECT_DIR/$KEYSTORE" ]; then
            mv "$PROJECT_DIR/$KEYSTORE" "$CREDS_DIR/"
            echo "Moved upload-keystore.jks to creds folder"
        fi
        ;;

    "restore")
        echo "Restoring credential files from $CREDS_DIR..."

        if [ -f "$CREDS_DIR/google-services.json" ]; then
            mkdir -p "$PROJECT_DIR/android/app"
            mv "$CREDS_DIR/google-services.json" "$PROJECT_DIR/$GOOGLE_SERVICES"
            echo "Restored google-services.json to project"
        fi

        if [ -f "$CREDS_DIR/upload-keystore.jks" ]; then
            mv "$CREDS_DIR/upload-keystore.jks" "$PROJECT_DIR/$KEYSTORE"
            echo "Restored upload-keystore.jks to project"
        fi
        ;;

    *)
        echo "Usage: $0 {backup|restore}"
        echo "  backup  - Move credential files from project to creds folder"
        echo "  restore - Move credential files from creds folder back to project"
        exit 1
        ;;
esac