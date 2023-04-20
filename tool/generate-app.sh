#!/bin/bash
set -euxo pipefail
cd "$(dirname "$0")/.."

color="#f37736"

(
  cd packages/app

  # Neon logo
  wget https://raw.githubusercontent.com/Templarian/MaterialDesign/master/svg/cable-data.svg -O assets/logo.svg
  sed -i "s/<path /<path fill=\"$color\" /g" assets/logo.svg

  # Splash screens
  inkscape assets/logo.svg -o img/splash_icon.png -w 768 -h 768 # 768px at xxxhdpi is 192dp
  convert -size 1152x1152 xc:none img/splash_icon.png -gravity center -composite img/splash_icon_android_12.png # 1152px at xxxhdpi is 288dp
  exiftool -overwrite_original -all= img/splash_icon_android_12.png # To remove timestamps

  # Android launcher icons
  export_mipmap_icon_all "assets/logo.svg" "ic_launcher" &
  for id in files news notes notifications; do
    export_mipmap_icon_all "../neon/neon_$id/assets/app.svg" "app_$id" &
  done
  wait

  fvm dart run flutter_native_splash:create
  fvm flutter gen-l10n
)

./tool/format.sh
