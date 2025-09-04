#!/bin/bash
# A Nautilus script to extract a specified number of frames, evenly spaced, from video files.

# Determine input file paths from Nautilus or a command-line argument.
if [[ -z "${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS}" ]]; then
  FILE_PATHS="$1"
else
  FILE_PATHS="${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS}"
fi

# Exit if no files are provided.
if [[ -z "${FILE_PATHS}" ]]; then
  zenity --error --text="No video file selected."
  exit 1
fi

# Prompt user for the desired number of frames with a clear, simple dialog.
FRAME_COUNT=$(zenity --entry \
  --title="Extract Video Frames" \
  --text="Enter the total number of frames to extract from each video:" \
  --entry-text="10")

# Exit cleanly if the user pressed "Cancel".
if [[ $? -ne 0 ]]; then
  echo "User cancelled."
  exit 0
fi

# Validate user input to ensure it's a positive number.
if ! [[ "$FRAME_COUNT" =~ ^[1-9][0-9]*$ ]]; then
  zenity --error --text="Invalid input. Please enter a positive number."
  exit 1
fi

# This string will store the results for the final summary message.
COMPLETED_SUMMARY=""

# --- Main Processing Loop ---
# Correctly loop through newline-separated file paths provided by Nautilus.
while IFS= read -r VIDEO_FILE; do
  # Skip empty lines that might be in the input variable.
  [[ -z "$VIDEO_FILE" ]] && continue

  printf "Processing file: %s\n" "${VIDEO_FILE}"

  # Get video duration. This is the only metric needed.
  DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")

  # Check if ffprobe failed to get the duration.
  if [[ -z "$DURATION" ]]; then
    printf "  - ERROR: Could not read video duration. Skipping.\n"
    COMPLETED_SUMMARY="${COMPLETED_SUMMARY}\n$(basename "$VIDEO_FILE"): ERROR - No duration"
    continue
  fi
  
  # Calculate the output frame rate required to get the desired number of frames.
  # e.g., for a 60s video and 10 frames, we need 10/60 = 0.166 frames per second.
  OUTPUT_FPS=$(echo "scale=4; $FRAME_COUNT / $DURATION" | bc)

  printf "  - Duration: %.2fs\n" "$DURATION"
  printf "  - Desired frames: %d\n" "$FRAME_COUNT"
  printf "  - Required FPS for extraction: %s\n" "$OUTPUT_FPS"

  # Create a unique output directory based on the video file's name.
  OUTPUT_DIR="${VIDEO_FILE%.*}_frames"
  mkdir -p "$OUTPUT_DIR"

  # Extract frames using the simpler and more robust 'fps' filter.
  # The `-an` flag disables audio processing for a slight speed increase.
  # Output is correctly silenced with `>/dev/null 2>&1`.
  ffmpeg -i "$VIDEO_FILE" -an -vf "fps=${OUTPUT_FPS}" -vframes "$FRAME_COUNT" "${OUTPUT_DIR}/frame_%04d.png" >/dev/null 2>&1

  # Check the exit code of ffmpeg and report success or failure.
  if [[ $? -eq 0 ]]; then
    printf "  - Success! Frames extracted to: %s\n" "$OUTPUT_DIR"
    COMPLETED_SUMMARY="${COMPLETED_SUMMARY}\n- $(basename "$VIDEO_FILE"): Success"
  else
    printf "  - FAILED to extract frames.\n"
    COMPLETED_SUMMARY="${COMPLETED_SUMMARY}\n- $(basename "$VIDEO_FILE"): FAILED"
  fi
done <<< "$FILE_PATHS"


# Show a final summary notification to the user.
zenity --info \
  --title="Extraction Complete" \
  --text="Processing finished. Summary:${COMPLETED_SUMMARY}"
