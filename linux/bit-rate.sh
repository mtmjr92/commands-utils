#!/bin/bash

# Directory to scan (current directory)
DIR="."

# Loop through supported audio files
for file in "$DIR"/*.{mp3,wav,m4a,flac}; do
    # Skip if no matching file
    [ -e "$file" ] || continue

    # Get extension and temporary output filename
    ext="${file##*.}"
    tmpfile="$(mktemp --suffix=".$ext")"

    echo "Converting and replacing: $file"

    # Convert to 128k and store in a temp file
    ffmpeg -y -i "$file" -b:a 128k "$tmpfile" >/dev/null 2>&1

    # Replace original with converted version
    mv "$tmpfile" "$file"
done

echo "All files converted to 128k and originals replaced."

