#!/bin/sh

# Check if sufficient arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_directory_path> <destination_directory_path>"
    exit 1
fi

# Assign command line arguments to variables
SOURCE_DIR="$1"
TARGET_DIR="$2"
XML_FILE="$SOURCE_DIR/DIRECProject.xml"  # Assuming the XML file is named 'project.xml' and located in the source directory

# Function to process each track
process_tracks() {
    # Use xmlstarlet to parse the XML file and extract needed info
    # Format: track_index, friendly_name, region_name
    xmlstarlet sel -t -m "//Track[@NumRegions>0]" -v "@Name" -o "," \
        -v "@FriendlyName" -o "," -v "Region/@Name" -nl "$XML_FILE" |
    while IFS=, read -r track_index friendly_name region_name; do
        # Remove spaces from track_index to match directory names
        sanitized_track_index=$(echo "$track_index" | tr -d ' ')

        # Define source and target file paths, properly quoted to handle spaces
        source_file="${SOURCE_DIR}/${sanitized_track_index}/${region_name}"
        target_file="${TARGET_DIR}/${friendly_name}.wav"

        # Check if source file exists and copy it, quoting paths to handle spaces
        if [ -f "$source_file" ]; then
            cp "$source_file" "$target_file"
            echo "Copied '$source_file' to '$target_file'."
        else
            echo "File $source_file does not exist."
        fi
    done
}

# Start processing
process_tracks

