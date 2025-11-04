#!/bin/bash

# Setup script for macOS screenshot organization
# This configures macOS to save screenshots to ~/Pictures/Screenshots
# and sets up automatic organization into year/month folders

set -e

SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
ORGANIZE_SCRIPT="$HOME/organize-screenshots.sh"

echo "Setting up screenshot organization..."
echo ""

# Step 1: Create base directory
echo "Creating Screenshots directory..."
mkdir -p "$SCREENSHOTS_DIR"

# Step 2: Set default screenshot location
echo "Setting default screenshot location to $SCREENSHOTS_DIR..."
defaults write com.apple.screencapture location "$SCREENSHOTS_DIR"
killall SystemUIServer 2>/dev/null || true

# Step 3: Copy organize script to home directory
echo "Installing organize script..."
cp "$(dirname "$0")/organize-screenshots.sh" "$ORGANIZE_SCRIPT"
chmod +x "$ORGANIZE_SCRIPT"

# Step 4: Create LaunchAgent to watch the Screenshots folder
echo "Setting up LaunchAgent for automatic organization..."
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$LAUNCH_AGENT_DIR"

cat > "$LAUNCH_AGENT_DIR/com.user.organize-screenshots.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.organize-screenshots</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$ORGANIZE_SCRIPT</string>
        <string>%f</string>
    </array>
    <key>WatchPaths</key>
    <array>
        <string>$SCREENSHOTS_DIR</string>
    </array>
    <key>RunAtLoad</key>
    <false/>
    <key>QueueDirectories</key>
    <array>
        <string>$SCREENSHOTS_DIR</string>
    </array>
</dict>
</plist>
EOF

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Restart your Mac or log out and back in for the screenshot location change to take effect"
echo "2. Or manually load the LaunchAgent:"
echo "   launchctl load $LAUNCH_AGENT_DIR/com.user.organize-screenshots.plist"
echo ""
echo "Note: LaunchAgents have limitations with file watching. An alternative is to use"
echo "an Automator Folder Action (see README for instructions)."
echo ""
echo "Test it by taking a screenshot (Cmd+Shift+3 or Cmd+Shift+4)"

