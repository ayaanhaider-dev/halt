#!/bin/zsh
# ./dmg.sh Halt.app out.dmg   makes the disk image people download
set -e
APP="$1"; DMG="$2"; HERE="$(dirname "$0")"
VOLUME="Halt"
WORK=$(mktemp -d)
mkdir -p "$WORK/stage/.background"
cp -R "$APP" "$WORK/stage/"
cp "$HERE/Assets/dmg/background.tiff" "$WORK/stage/.background/"
ln -s /Applications "$WORK/stage/Applications"
hdiutil create -quiet -volname "$VOLUME" -srcfolder "$WORK/stage" -format UDRW "$WORK/rw.dmg"
[ ! -e "/Volumes/$VOLUME" ] || { echo "Eject /Volumes/$VOLUME first"; exit 1; }
hdiutil attach -quiet -readwrite -noverify "$WORK/rw.dmg" 2>/dev/null
# Finder remembers the layout inside the image.
osascript <<APPLESCRIPT
tell application "Finder"
  tell disk "$VOLUME"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set bounds of container window to {200, 160, 840, 608}
    set options to icon view options of container window
    set arrangement of options to not arranged
    set icon size of options to 112
    set text size of options to 13
    set background picture of options to file ".background:background.tiff"
    set position of item "Halt.app" of container window to {160, 190}
    set position of item "Applications" of container window to {480, 190}
    update without registering applications
    delay 2
    close
  end tell
end tell
APPLESCRIPT
sync
hdiutil detach -quiet "/Volumes/$VOLUME" 2>/dev/null
rm -f "$DMG"
hdiutil convert -quiet "$WORK/rw.dmg" -format UDZO -o "$DMG"
rm -rf "$WORK"
