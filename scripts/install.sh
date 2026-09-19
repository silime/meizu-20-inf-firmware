#!/bin/sh
# 将本仓库中的 Meizu 20 Inf 固件安装到目标系统。
#
#   sudo scripts/install.sh
#   DESTDIR=/tmp/rootfs scripts/install.sh
#
set -eu

SRC=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DESTDIR=${DESTDIR:-}

if [ -z "$DESTDIR" ] && [ "$(id -u)" -ne 0 ]; then
	echo "install.sh: 需要 root 权限，或通过 DESTDIR 指定目标根目录" >&2
	exit 1
fi

FW="$DESTDIR/lib/firmware"
QCOM="$FW/qcom/sm8550"
HF="$DESTDIR/usr/share/qcom/sm8550/MEIZU/20inf"

install -d "$FW/ath12k" "$QCOM" "$HF"

# Wi-Fi 7 (WCN7850 / NCM865)，含 Notice.txt 符号链接的目标文件
cp -a "$SRC/ath12k/." "$FW/ath12k/"

# ADSP/CDSP/Modem/IPA/VPU 固件与 MCFG 配置、ALSA topology
cp -a "$SRC/qcom/sm8550/." "$QCOM/"

# TFA98xx 智能功放配置
install -m 0644 "$SRC/tfa98xx.cnt" "$FW/tfa98xx.cnt"

# hexagonfs：ADSP/CDSP fastrpc 使用的文件系统
cp -a "$SRC/hexagonfs/." "$HF/"

# 规范权限：目录 0755、文件 0644（已有的可执行位保留）。
# 设备上 qcom/sm8550/meizu/modem_pr 为 0550 root:alarm，直接保留会让
# 打包/覆盖更新变得困难，因此这里统一放宽为可读。
for d in "$FW/ath12k/WCN7850" "$FW/ath12k/QCC2072" "$QCOM" "$HF"; do
	[ -e "$d" ] && chmod -R u+rwX,go+rX "$d"
done

# 还原设备上的属主（fastrpc:root）
chown -R fastrpc:root "$HF" 2>/dev/null || \
	echo "install.sh: 警告：无法将 $HF 的属主设为 fastrpc:root" >&2

# 传感器注册表与出厂校准数据在设备上为 0600 fastrpc:root
chmod 0600 "$HF/sensors/cam_registry_dump.txt" \
	"$HF/sensors/sensors_list.txt"

if [ -d "$HF/sensors/registry/registry" ]; then
	find "$HF/sensors/registry/registry" -type f -exec chmod 0600 {} +
fi

echo "install.sh: 固件已安装到 ${DESTDIR:-/}"
