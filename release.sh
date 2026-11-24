#!/bin/zsh
# ./release.sh   builds, makes the disk image, and publishes it as this version's GitHub release
set -e
cd "$(dirname "$0")"
VERSION=$(plutil -extract CFBundleShortVersionString raw Info.plist)
# Sparkle compares the build version, so the two must agree.
[ "$VERSION" = "$(plutil -extract CFBundleVersion raw Info.plist)" ] || { echo "Set both versions in Info.plist"; exit 1; }
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
# The list of versions, signed with the private key in this Mac's Keychain.
APPCAST=$(mktemp -d)
cp "$DMG" "$APPCAST/"
"$OUT/sparkle-2.10.1/bin/generate_appcast" --account halt --maximum-versions 1 \
  --download-url-prefix "https://github.com/ayaanhaider-dev/halt/releases/download/v$VERSION/" -o "$OUT/appcast.xml" "$APPCAST"
rm -rf "$APPCAST"
grep -q edSignature "$OUT/appcast.xml" || { echo "The update list isn't signed"; exit 1; }
[ "${1:-}" = dmg ] || gh release create "v$VERSION" "$DMG" "$OUT/appcast.xml" --repo ayaanhaider-dev/halt --title "Halt $VERSION" --notes-file RELEASE_NOTES.md
