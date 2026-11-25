# Test fixture for the air-gap lab, including the failures the README promises.
# Not a walkthrough for attendees. Runs from the workspace folder.

solve_step1() (
  (cd outside && git format-patch -q main..rates -o ../usb/patches) || exit 1
  cd inside || exit 1
  git switch -q -c rates
  git am -q ../usb/patches/*.patch >/dev/null 2>&1 && exit 1   # must stop on the LFS file
  git am --abort
  rm -f assets/chart.png
  (cd ../outside && cp -R .git/lfs/objects ../usb/lfs-objects)
  cp -R ../usb/lfs-objects/. .git/lfs/objects/
  git am -q ../usb/patches/*.patch
)

solve_step2() (
  cd inside || exit 1
  git -c protocol.file.allow=always submodule update -q >/dev/null 2>&1 && exit 1   # must fail
  cd .. || exit 1
  git -C units.git bundle create ../usb/units.bundle v1.0..main v1.1 2>/dev/null
  git -C inside-units.git fetch -q ../usb/units.bundle main:main refs/tags/v1.1:refs/tags/v1.1
  cd inside || exit 1
  git -c protocol.file.allow=always submodule update -q
)

solve_step3() (
  (cd outside && git bundle create ../usb/rates.bundle main..rates 2>/dev/null) || exit 1
  cd inside || exit 1
  git bundle verify -q ../usb/rates.bundle
  git fetch -q ../usb/rates.bundle rates:rates-bundle
  [ "$(git rev-parse rates-bundle)" = "$(git -C ../outside rev-parse rates)" ] || exit 1
  [ "$(git rev-parse rates)" != "$(git rev-parse rates-bundle)" ]
)

solve_from() {
  local s
  for s in 1 2 3; do
    if [ "$s" -ge "$1" ]; then "solve_step$s" || return 1; fi
  done
}
