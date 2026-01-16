#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.0.1/g' package/base-files/files/bin/config_generate

# Fix Material theme progressbar font size
sed -i 's/1.3em/1em/g' package/feeds/luci/luci-theme-material/htdocs/luci-static/material/cascade.css

# DHCP defaults
sed -i 's/100/10/g' package/network/services/dnsmasq/files/dhcp.conf
sed -i 's/150/25/g' package/network/services/dnsmasq/files/dhcp.conf

# 修复 Rust 在 CI 环境中的构建问题
echo "修复 Rust 构建配置..."
if [ -d package/feeds/packages/rust ]; then
    # 方法1：修改 config.toml
    cat > /tmp/rust-config-fix.patch << 'EOF'
--- a/config.toml
+++ b/config.toml
@@ -1,4 +1,4 @@
 [llvm]
-download-ci-llvm = true
+download-ci-llvm = "if-unchanged"
 
 [rust]
EOF
    
    # 或者方法2：在编译前设置环境变量
    echo "在编译前设置 Rust 环境变量..."
    export CI=""
    export CARGO_HOME=$(pwd)/dl/cargo
    export RUSTUP_HOME=$(pwd)/dl/rustup
fi

## Enable vlmcsd auto activation
echo srv-host=_vlmcs._tcp.lan,OpenWrt.lan,1688,0,100 >> package/network/services/dnsmasq/files/dnsmasq.conf

# Set default root password
sed -i 's/root:::0:99999:7:::/root:$1$o4gFHnsz$gDNYwhnsRl3LH9vGDJypB\/:19341:0:99999:7:::/g' package/base-files/files/etc/shadow
