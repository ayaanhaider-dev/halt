#!/bin/zsh
# ./release.sh   builds, makes the disk image, and publishes it as this version's GitHub release
set -e
cd "$(dirname "$0")"
VERSION=$(plutil -extract CFBundleShortVersionString raw Info.plist)
OUT="$HOME/Library/Developer/halt"
DMG="$OUT/Halt-$VERSION.dmg"
[ -z "$(git status --porcelain)" ] || { echo "Commit your changes first"; exit 1; }
./dev.sh test
./dev.sh release
STAGE=$(mktemp -d)
cp -R "$OUT/Halt.app" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
rm -f "$DMG"
hdiutil create -quiet -volname "Halt $VERSION" -srcfolder "$STAGE" -format UDZO "$DMG"
rm -rf "$STAGE"
hdiutil verify -quiet "$DMG"
[ "${1:-}" = dmg ] || gh release create "v$VERSION" "$DMG" --repo ayaanhaider-dev/halt --title "Halt $VERSION" --notes-file RELEASE_NOTES.md
