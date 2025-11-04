# macOS Screenshot Organization Setup

This setup organizes your macOS screenshots into `~/Pictures/Screenshots/<year>/<month>/` folders.

## Quick Setup

Run the setup script:

```bash
chmod +x setup-screenshot-organization.sh
./setup-screenshot-organization.sh
```

Then restart your Mac or log out and back in.

## Manual Setup

### Step 1: Set Default Screenshot Location

```bash
defaults write com.apple.screencapture location ~/Pictures/Screenshots
killall SystemUIServer
```

### Step 2: Create Base Directory

```bash
mkdir -p ~/Pictures/Screenshots
```

### Step 3: Choose Organization Method

You have two options for automatic organization:

#### Option A: Automator Folder Action (Recommended)

1. Open Automator (Applications > Automator)
2. Choose "Folder Action"
3. Set "Folder Action receives files and folders added to" to `~/Pictures/Screenshots`
4. Add "Run Shell Script" action
5. Set "Pass input" to "as arguments"
6. Paste this script:

```bash
for file in "$@"; do
    if [ -f "$file" ]; then
        year=$(stat -f "%Sm" -t "%Y" "$file")
        month=$(stat -f "%Sm" -t "%m" "$file")
        month_dir="$HOME/Pictures/Screenshots/$year/$month"
        mkdir -p "$month_dir"
        
        filename=$(basename "$file")
        if [ -f "$month_dir/$filename" ]; then
            name_without_ext="${filename%.*}"
            extension="${filename##*.}"
            timestamp=$(date +"%Y%m%d_%H%M%S")
            new_filename="${name_without_ext}_${timestamp}.${extension}"
            mv "$file" "$month_dir/$new_filename"
        else
            mv "$file" "$month_dir/"
        fi
    fi
done
```

7. Save as "Organize Screenshots" in `~/Library/Workflows/Applications/Folder Actions/`

#### Option B: LaunchAgent (Less Reliable)

The setup script creates a LaunchAgent, but macOS LaunchAgents have limitations with file watching. The Automator approach is more reliable.

### Step 4: Organize Existing Screenshots

If you have existing screenshots to organize:

```bash
chmod +x organize-screenshots.sh
./organize-screenshots.sh ~/Desktop/Screen*.png
```

Or to organize all screenshots in a directory:

```bash
find ~/Desktop -name "Screen*.png" -exec ./organize-screenshots.sh {} +
```

## How It Works

1. Screenshots are saved to `~/Pictures/Screenshots/` by default
2. The folder action/script automatically moves new screenshots to `~/Pictures/Screenshots/YYYY/MM/` based on the file's creation date
3. If a file with the same name exists, it's renamed with a timestamp

## Testing

1. Take a screenshot (Cmd+Shift+3 or Cmd+Shift+4)
2. Check that it appears in `~/Pictures/Screenshots/<current_year>/<current_month>/`

## Troubleshooting

- **Screenshots still going to Desktop**: Restart your Mac or log out and back in
- **Files not organizing**: Check that the folder action is enabled in System Settings > Extensions > Folder Actions
- **Permission errors**: Make sure the script has execute permissions: `chmod +x organize-screenshots.sh`

