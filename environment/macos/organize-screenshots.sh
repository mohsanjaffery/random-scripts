#!/bin/bash

# Script to organize macOS screenshots into year/month folders
# Usage: Can be run as a folder action or manually

SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
TARGET_DIR="$SCREENSHOTS_DIR"

# Create base directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Process each screenshot file
for file in "$@"; do
    # Skip if file doesn't exist
    [ -f "$file" ] || continue
    
    # Get file modification date (or creation date if modification is today)
    # Use stat to get the file's creation date
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS stat format
        file_date=$(stat -f "%Sm" -t "%Y-%m-%d" "$file")
        year=$(stat -f "%Sm" -t "%Y" "$file")
        month=$(stat -f "%Sm" -t "%m" "$file")
    else
        # Linux stat format (for compatibility)
        file_date=$(stat -c "%y" "$file" | cut -d' ' -f1)
        year=$(echo "$file_date" | cut -d'-' -f1)
        month=$(echo "$file_date" | cut -d'-' -f2)
    fi
    
    # Create year/month directory if it doesn't exist
    month_dir="$TARGET_DIR/$year/$month"
    mkdir -p "$month_dir"
    
    # Get just the filename
    filename=$(basename "$file")
    
    # Move file to appropriate folder
    # Only move if file is not already in the target location
    if [[ "$file" != "$month_dir/$filename" ]]; then
        # Check if file already exists in destination
        if [ -f "$month_dir/$filename" ]; then
            # Add timestamp to avoid overwrite
            name_without_ext="${filename%.*}"
            extension="${filename##*.}"
            timestamp=$(date +"%Y%m%d_%H%M%S")
            new_filename="${name_without_ext}_${timestamp}.${extension}"
            mv "$file" "$month_dir/$new_filename"
            echo "Moved $filename to $month_dir/$new_filename (renamed to avoid conflict)"
        else
            mv "$file" "$month_dir/"
            echo "Moved $filename to $month_dir/"
        fi
    fi
done

