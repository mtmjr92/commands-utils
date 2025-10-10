#!/bin/bash
# ============================================
# Cleanup Script for Build and Temp Folders
# ============================================

echo "🧹 Cleaning up system and project folders..."

# Delete 'lost+found' folders
echo "→ Removing lost+found folders..."
sudo find /media -type d -name "lost+found" -exec rm -rf {} +

# Delete empty folders
echo "→ Removing empty folders..."
find . -type d -empty -delete

# Delete Node.js dependency folders
echo "→ Removing node_modules folders..."
find . -type d -name "node_modules" -prune -exec rm -rf {} +

# Delete Gradle build folders
echo "→ Removing Gradle build folders..."
find . -type d \( -name "build" -o -name ".gradle" -o -name "out" \) -exec rm -rf {} +

# Delete Maven target folders
echo "→ Removing Maven target folders..."
find . -type d -name "target" -exec rm -rf {} +

echo "✅ Cleanup completed successfully!"