### Nautilus Image Converter (ConvertImage.sh)

#### Overview
`SnapImagesFromVideo.sh` is a Bash script that integrates with the Nautilus file manager in Linux, providing a convenient right-click option to extract frames/image files from a Video. Uses `zenity` for graphical interface and `ffprobe` and `ffmpeg` for extraction (they need to be installed in the system), it allows users to easily extract images from the Nautilus File Manager Graphical User Interface.

#### Requirements
- Linux with Nautilus file manager
- Zenity
- ffmpeg

#### Installation
1. Download `SnapImagesFromVideo.sh` or clone the repository
2. Make the script executable: `chmod +x SnapImagesFromVideo.sh`.
3. Place the script in `~/.local/share/nautilus/scripts/` to integrate with Nautilus for the current user.

#### Usage
1. Right-click on Video file in Nautilus.
2. Navigate to 'Scripts' > 'SnapImagesFromVideo.sh'.
3. Select the desired number of frames to extract by spliting the video in equal parts
4. The script will create a new folder and create the frames.

#### Notes

#### Contributing
Feel free to contribute by submitting pull requests or opening issues for any bugs or feature requests.
