#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

./scripts/feeds update -a

rm -rf feeds/packages/lang/golang
git clone --depth 1 --branch 26.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

rm -rf feeds/packages/net/mosdns feeds/packages/net/v2ray-geodata
rm -rf package/feeds/packages/mosdns package/feeds/packages/v2ray-geodata

grep -q '^src-git daede ' feeds.conf.default || printf '\nsrc-git daede https://github.com/kenzok8/openwrt-daede.git;main\n' >> feeds.conf.default
grep -q '^src-git passwall ' feeds.conf.default || printf 'src-git passwall https://github.com/Openwrt-Passwall/openwrt-passwall.git;main\n' >> feeds.conf.default
grep -q '^src-git passwall_packages ' feeds.conf.default || printf 'src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main\n' >> feeds.conf.default

./scripts/feeds update daede
./scripts/feeds update passwall
./scripts/feeds update passwall_packages
./scripts/feeds install -a

rm -rf package/mosdns package/v2ray-geodata package/luci-app-mosdns package/geo2txt
git clone --depth 1 --branch v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone --depth 1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
ln -sfn mosdns/luci-app-mosdns package/luci-app-mosdns
ln -sfn mosdns/geo2txt package/geo2txt

./scripts/feeds install -p daede dae daed luci-app-daede
./scripts/feeds install -p packages tailscale
./scripts/feeds install -p passwall luci-app-passwall
./scripts/feeds install -p passwall_packages xray-core sing-box tcping chinadns-ng dns2socks ipt2socks microsocks

test -f feeds/daede/daed/Makefile
test -f feeds/daede/luci-app-daede/Makefile
test -f feeds/passwall/luci-app-passwall/Makefile
test -f feeds/passwall_packages/xray-core/Makefile
test -f feeds/packages/net/tailscale/Makefile
