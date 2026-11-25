# Lab: Air-gap capstone (History cleanup, strategies and structure).
# outside/ is the connected repo, inside/ the offline one, usb/ the removable media.
# outside's feature branch "rates" changes code, adds a Git LFS file and moves a submodule
# (vendor/units) to a version the inside doesn't have yet.
# Needs git-lfs.
# Steps: 1 nothing carried yet, 2 patches applied (LFS objects carried), 3 submodule commits carried

LAB_STEPS=3
LAB_NEEDS=git-lfs

airgap_step1_done() { # patches tried, LFS objects carried, patches applied
  (cd outside && git format-patch -q main..rates -o ../usb/patches)
  (cd outside && cp -R .git/lfs/objects ../usb/lfs-objects)
  (
    cd inside || exit 2
    git switch -q -c rates
    cp -R ../usb/lfs-objects/. .git/lfs/objects/
    tick
    git am -q ../usb/patches/*.patch
  )
}

airgap_step2_done() { # the library's new commits carried by bundle, submodule updated
  git -C units.git bundle create ../usb/units.bundle v1.0..main v1.1 2>/dev/null
  git -C inside-units.git fetch -q ../usb/units.bundle main:main refs/tags/v1.1:refs/tags/v1.1
  (cd inside && git -c protocol.file.allow=always submodule update -q)
}

airgap_need_lfs() {
  if ! git lfs version >/dev/null 2>&1; then
    echo "The air-gap lab needs git-lfs. Install it (macOS: brew install git-lfs) and run: git lfs install" >&2
    exit 1
  fi
}

airgap_png() { # airgap_png <file> <seed>: a small binary file (bytes vary with the seed)
  local i=0
  mkdir -p "$(dirname "$1")"
  : > "$1"
  while [ "$i" -lt 64 ]; do
    printf "\\$(printf '%03o' $(( (i * 7 + $2 * 13) % 256 )))" >> "$1"
    i=$(( i + 1 ))
  done
}

build_step() {
  airgap_need_lfs
  mkdir -p usb

  # The units library, outside: v1.0, then v1.1.
  git init -q --bare -b main units.git
  new_repo units-work
  (
    cd units-work || exit 2
    put units.sh <<'EOF'
# Unit conversions.
cents_to_euros() { echo "$(( $1 / 100 )).$(( $1 % 100 ))"; }
EOF
    commit "Add cents_to_euros"
    git tag v1.0
    git remote add origin ../units.git
    git push -q origin main v1.0
  )

  # The inside copy of the library only has v1.0.
  git clone -q --bare units.git inside-units.git

  # The library moves on outside.
  (
    cd units-work || exit 2
    echo 'cents_to_dollars() { cents_to_euros "$1"; }' >> units.sh
    commit "Add cents_to_dollars"
    git tag v1.1
    git push -q origin main v1.1
  )
  rm -rf units-work

  # The app, outside.
  new_repo outside
  (
    cd outside || exit 2
    git lfs install --local >/dev/null
    # Written by hand: "git lfs track" writes CRLF on Windows, which would change the hashes.
    put .gitattributes <<'EOF'
assets/*.png filter=lfs diff=lfs merge=lfs -text
EOF
    put src/prices.sh <<'EOF'
# Prices in cents.
price_of() { echo 250; }
EOF
    airgap_png assets/logo.png 1
    git -c protocol.file.allow=always submodule add -q ../units.git vendor/units
    git -C vendor/units checkout -q v1.0
    commit "Start the shop app"

    # The inside gets a copy of main as it is now.
    git clone -q --no-local . ../inside
    git -C ../inside remote remove origin

    git switch -q -c rates
    put src/rates.sh <<'EOF'
# Exchange rates, in cents per euro.
RATE_USD=108
EOF
    commit "Add exchange rates"
    airgap_png assets/chart.png 2
    commit "Add the rates chart"
    git -C vendor/units checkout -q v1.1
    commit "Use units v1.1"
    git switch -q main

    git -c protocol.file.allow=always submodule update -q
  )

  # The inside repo: LFS on, submodule pointed at the inside copy of the library.
  (
    cd inside || exit 2
    git lfs install --local >/dev/null
    # The inside already has main's LFS file (logo.png), as if carried on an earlier trip.
    local oid
    oid="$(git -C ../outside lfs ls-files -l main | awk '/logo.png/ { print $1 }')"
    mkdir -p ".git/lfs/objects/$(printf '%s' "$oid" | cut -c1-2)/$(printf '%s' "$oid" | cut -c3-4)"
    cp "../outside/.git/lfs/objects/$(printf '%s' "$oid" | cut -c1-2)/$(printf '%s' "$oid" | cut -c3-4)/$oid" \
       ".git/lfs/objects/$(printf '%s' "$oid" | cut -c1-2)/$(printf '%s' "$oid" | cut -c3-4)/"
    git lfs checkout >/dev/null

    git config submodule.vendor/units.url "$(cd .. && pwd)/inside-units.git"
    git -c protocol.file.allow=always submodule update -q --init
  )

  if [ "$1" -ge 2 ]; then airgap_step1_done; fi
  if [ "$1" -ge 3 ]; then airgap_step2_done; fi
}
