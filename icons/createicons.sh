#! /usr/bin/env bash

# set +x

rm -rf *.png
rm -rf *.ico

LOGLEVEL="error"

# --- Github.com logos for the repository---
# 500x500 for use as github.com logo
ffmpeg -y -hide_banner -loglevel "${LOGLEVEL}" -f "lavfi" -i "smptehdbars=size=500x500" -vframes "1" "testpatterns_500x500.png"
# 1280x640 github.com social media logo
ffmpeg -y -hide_banner -loglevel "${LOGLEVEL}" -f "lavfi" -i "smptehdbars=size=1280x640" -vframes "1" "testpatterns_1280x640.png"

# --- Create favicons ---
# TODO - Enhance to use pngquant.
# TODO - Check whether imagemagick is installed
ffmpeg -y -hide_banner -loglevel "${LOGLEVEL}" -f "lavfi" -i "smptehdbars=size=16x16" -vframes "1" "favicon-16.png"
ffmpeg -y -hide_banner -loglevel "${LOGLEVEL}" -f "lavfi" -i "smptehdbars=size=32x32" -vframes "1" "favicon-32.png"
ffmpeg -y -hide_banner -loglevel "${LOGLEVEL}" -f "lavfi" -i "smptehdbars=size=48x48" -vframes "1" "favicon-48.png"
ffmpeg -y -hide_banner -loglevel "${LOGLEVEL}" -f "lavfi" -i "smptehdbars=size=64x64" -vframes "1" "favicon-64.png"
magick convert "favicon-16.png" "favicon-32.png" "favicon-48.png" "favicon-64.png" "../favicon.ico"

exit 0
