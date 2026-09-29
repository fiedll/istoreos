#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Preparing external package feeds"

# Keep the iStoreOS 24.10 feeds intact, but add the maintained daed/dae feed.
if ! grep -q '^src-git daede ' feeds.conf; then
  printf '\nsrc-git daede https://github.com/kenzok8/openwrt-daede.git;main\n' >> feeds.conf
fi

./scripts/feeds update -a
./scripts/feeds install -a

# The iStoreOS/packages feed can contain an older mosdns/v2ray-geodata.
# Remove those copies before importing the v5 package set so only one
# provider owns each package.
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/v2ray-geodata
rm -rf package/feeds/packages/mosdns
rm -rf package/feeds/packages/v2ray-geodata
rm -rf package/mosdns package/luci-app-mosdns package/geo2txt package/v2ray-geodata

echo "==> Installing daed/dae packages"
./scripts/feeds install -p daede dae
./scripts/feeds install -p daede daed
./scripts/feeds install -p daede luci-app-daede

test -f package/feeds/daede/dae/Makefile
test -f package/feeds/daede/daed/Makefile
test -f package/feeds/daede/luci-app-daede/Makefile

echo "==> Importing MosDNS v5"
git clone --depth 1 --branch v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone --depth 1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

test -f package/mosdns/mosdns/Makefile
test -f package/mosdns/luci-app-mosdns/Makefile
test -f package/v2ray-geodata/Makefile

# The v5 repository contains three OpenWrt packages under one tree.
ln -sfn mosdns/luci-app-mosdns package/luci-app-mosdns
ln -sfn mosdns/geo2txt package/geo2txt

echo "==> Checking Tailscale package"
test -f feeds/packages/net/tailscale/Makefile

echo "==> Package preparation complete"
