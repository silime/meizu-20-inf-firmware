# Meizu 20 Inf 固件仓库

本仓库保存从 Meizu 20 Inf（`meizu,meizu-20-inf`，Qualcomm `sm8550`）上提取的设备相关固件。

## 设备信息

| 项目 | 值 |
| --- | --- |
| 机型 | Meizu 20 Inf (`meizu,meizu-20-inf`) |
| 平台 | Qualcomm SM8550 (`qcom,sm8550`) |
| SoC ID | 519 |
| 版本 | revision 2.0 |
| hw_platform / subtype | QRD / QRD |
| platform_version | 65536 |

## 目录结构

仓库路径与设备上的安装路径一一对应（去掉 `/lib/firmware` 与 `/usr/share/qcom/sm8550/MEIZU/20inf` 前缀）：

| 仓库路径 | 设备路径 | 说明 |
| --- | --- | --- |
| `ath12k/WCN7850/hw2.0/` | `/lib/firmware/ath12k/WCN7850/hw2.0/` | WCN7850 Wi-Fi 7 (NCM865 模块)：`amss.bin`、`m3.bin`、`board-2.bin` 及 `ncm865/` 变体 |
| `hexagonfs/` | `/usr/share/qcom/sm8550/MEIZU/20inf/` | ADSP/CDSP(fastrpc) 运行所需文件系统 |
| `hexagonfs/acdb/` | 同左 | ACDB 音频校准与 Audio-Reach 神经网络模型（`.pmd`） |
| `hexagonfs/dsp/adsp/` | 同左 | ADSP 音频模块（`.so.1`、`fastrpc_shell_0` 等） |
| `hexagonfs/dsp/cdsp/` | 同左 | CDSP 计算模块（`libQnnHtpV73Skel.so`、`fastrpc_shell_3` 等） |
| `hexagonfs/sensors/` | 同左 | SSC/CHRE 传感器配置与注册表 |
| `hexagonfs/socinfo/` | 同左 | 平台识别信息（soc_id、revision、平台版本等） |
| `qcom/sm8550/meizu/` | `/lib/firmware/qcom/sm8550/meizu/` | ADSP/CDSP/Modem/IPA/VPU 固件（`adsp.mbn`、`cdsp.mbn`、`modem.mbn`、`modem.mbn` 对应的 `*.jsn`/`*_dtb.mbn`、`a740_sqe.fw`、`a740_zap.mbn`、`vpu30_4v.mbn`），以及 `modem_pr/` 运营商 MCFG 配置 |
| `qcom/sm8550/MEIZU20Inf-tplg.bin` | `/lib/firmware/qcom/sm8550/MEIZU20Inf-tplg.bin` | 本机 ALSA AudioReach topology（UCM 配置另行安装） |
| `qcom/sm8550/meizu/voicemmode1-handset.bin` | `/lib/firmware/qcom/sm8550/meizu/voicemmode1-handset.bin` | q6apm hostless modem voice 图、VCPM 和校准 profile，格式 v1 |
| `tfa98xx.cnt` | `/lib/firmware/tfa98xx.cnt` | TFA98xx 智能功放配置（本机为 TFA9875，`1a75_07`） |

### 权限说明

设备上 `hexagonfs/sensors/registry/registry/` 下的注册表与 `sensors/cam_registry_dump.txt`、
`sensors/sensors_list.txt` 为 `0600 fastrpc:root`，其余文件为 `0644`、目录为 `0775`。
`scripts/install.sh` 会按此规则还原权限。

> 注意：`hexagonfs/sensors/registry/` 中的 `*_platform.*` / `*.fac_cal*` 等内容包含
> 该台机器的出厂校准数据（磁力计/加速度计/陀螺仪/气压计/光感校准等）
> 不具备通用性，请勿用于其他机器。

## 安装到目标系统

```sh
sudo scripts/install.sh            # 安装到 /
DESTDIR=/tmp/rootfs scripts/install.sh   # 安装到指定根目录
```

## 通话音频

`voicemmode1-handset.bin` 包含本机 handset 的 AudioReach RX/TX 图和 VCPM 校准，
由配套内核的 `q6apm-voice-dai` 驱动加载。DTS 的 `voice-dais` 节点需要指定
相对于 firmware 搜索目录的路径：

```dts
firmware-name = "qcom/sm8550/meizu/voicemmode1-handset.bin";
```

通话还需要 ModemManager、81voltd，以及 WirePlumber 的 `Voice Call` profile 策略
和本机 UCM 配置。UCM/WirePlumber 配置应与内核接口配套安装，不属于本固件仓库。
