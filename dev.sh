#!/bin/zsh
# ./dev.sh        build and open Halt
# ./dev.sh build  build only
# ./dev.sh test   run the logic tests
# ./dev.sh release  build with a trusted timestamp, for release.sh
set -e
cd "$(dirname "$0")"
# Outside iCloud Drive, which can lock files while it syncs them.
OUT="$HOME/Library/Developer/halt"
FINAL="$OUT/Halt.app"
# Built aside, so a failed build leaves the working app alone.
APP="$OUT/build/Halt.app"
SWIFT=(swiftc -target arm64-apple-macos27.0 -swift-version 5 -O)
mkdir -p "$OUT"
if [ "${1:-}" = test ]; then
  "${SWIFT[@]}" Sources/Settings/*.swift Sources/Battery/{Estimates,PowerFlow,AppEnergyUse}.swift Sources/App/Command.swift Sources/Updates/Release.swift Tests/*.swift -o "$OUT/tests"
  exec "$OUT/tests"
fi
# Releases outlive the certificate only with a trusted timestamp.
TIMESTAMP=--timestamp=none
[ "${1:-}" = release ] && TIMESTAMP=--timestamp
# The helper refuses unsigned callers, so a real certificate is required.
SIGN=$(security find-identity -v -p codesigning | awk '/Apple Development/{print $2; exit}')
[ -n "$SIGN" ] || { echo "No Apple Development certificate found"; exit 1; }
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Library/LaunchServices"
# Shortcuts finds Halt's actions through metadata that Xcode normally extracts.
META="$OUT/intents"
rm -rf "$META" && mkdir -p "$META"
echo '["AppIntent","EntityQuery","AppEntity","TransientEntity","AppEnum","AppShortcutProviding","AppShortcutsProvider","AnyResolverProviding","AppIntentsPackage","DynamicOptionsProvider"]' > "$META/protocols.json"
"${SWIFT[@]}" -wmo -module-name Halt -emit-const-values-path "$META/Halt.swiftconstvalues" -Xfrontend -const-gather-protocols-file -Xfrontend "$META/protocols.json" \
  Sources/**/*.swift -o "$APP/Contents/MacOS/Halt"
print -l $PWD/Sources/**/*.swift > "$META/sources"
echo "$META/Halt.swiftconstvalues" > "$META/constvalues"
mkdir -p "$APP/Contents/Resources"
TOOLS="$(dirname "$(xcrun --find appintentsmetadataprocessor)")/../.."
xcrun appintentsmetadataprocessor --output "$APP/Contents/Resources" --toolchain-dir "$TOOLS" --module-name Halt --sdk-root "$(xcrun --show-sdk-path)" \
  --xcode-version "$(xcodebuild -version | awk '/Build/{print $3}')" --platform-family macOS --deployment-target 27.0 --target-triple arm64-apple-macos27.0 \
  --source-file-list "$META/sources" --swift-const-vals-list "$META/constvalues" --quiet-warnings > "$META/log" 2>&1 || { cat "$META/log"; exit 1; }
# macOS installs the helper only if app and helper name each other, signed by this team.
TEAM=$(security find-certificate -c "Apple Development" -p | openssl x509 -noout -subject | sed -E 's/.*OU ?= ?([A-Z0-9]+).*/\1/')
for f in Info.plist Helper/Info.plist; do sed "s/TEAMID/$TEAM/" $f > "$META/${f//\//-}"; done
HELPER="$APP/Contents/Library/LaunchServices/com.lveno.halt.helper"
"${SWIFT[@]}" Sources/Shared/*.swift Helper/*.swift -o "$HELPER" \
  -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker "$META/Helper-Info.plist" \
  -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __launchd_plist -Xlinker Helper/Launchd.plist
cp "$META/Info.plist" "$APP/Contents/"
cp Assets/haltTemplate*.png Assets/*.svg "$APP/Contents/Resources/"
# The tool only takes a full path.
xcrun actool "$PWD/Assets/Halt.icon" --compile "$APP/Contents/Resources" --app-icon Halt --platform macosx --minimum-deployment-target 27.0 \
  --output-partial-info-plist "$META/icon.plist" > "$META/icon.log" 2>&1 || { cat "$META/icon.log"; exit 1; }
codesign --force $TIMESTAMP --options runtime --identifier com.lveno.halt.helper --sign "$SIGN" "$HELPER"
codesign --force $TIMESTAMP --options runtime --sign "$SIGN" "$APP"
codesign --verify --strict "$APP"
rm -rf "$FINAL" && mv "$APP" "$FINAL"
[ -n "${1:-}" ] || open "$FINAL"
