#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Update iStoreOS 25.12 feeds"
./scripts/feeds update -a

# MosDNS v5 requires a modern Go toolchain.
rm -rf feeds/packages/lang/golang
git clone --depth 1 --branch 26.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# Remove feed-provided MosDNS/geodata packages before importing maintained v5 sources.
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/v2ray-geodata
rm -rf package/feeds/packages/mosdns
rm -rf package/feeds/packages/v2ray-geodata

# Add maintained daed/dae feed.
if ! grep -q '^src-git daede ' feeds.conf.default && ! grep -q '^src-git daede ' feeds.conf; then
  printf '\nsrc-git daede https://github.com/kenzok8/openwrt-daede.git;main\n' >> feeds.conf.default
fi
./scripts/feeds update daede

./scripts/feeds install -a

echo "==> Import MosDNS v5"
rm -rf package/mosdns package/v2ray-geodata package/luci-app-mosdns package/geo2txt
git clone --depth 1 --branch v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone --depth 1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
ln -sfn mosdns/luci-app-mosdns package/luci-app-mosdns
ln -sfn mosdns/geo2txt package/geo2txt

echo "==> Install selected feeds"
./scripts/feeds install -p daede dae daed luci-app-daede
./scripts/feeds install -p packages tailscale

test -f package/mosdns/mosdns/Makefile
test -f package/mosdns/luci-app-mosdns/Makefile
test -f package/v2ray-geodata/Makefile
test -f feeds/daede/dae/Makefile
test -f feeds/daede/daed/Makefile
test -f feeds/daede/luci-app-daede/Makefile
test -f feeds/packages/net/tailscale/Makefile

echo "==> Package preparation complete"
