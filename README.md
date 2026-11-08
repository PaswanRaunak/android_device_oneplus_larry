# OnePlus Nord CE 3 Lite 5G (larry) — PenguinOS device tree

> **⚠️ BUILD STATUS: UNTESTED — NOT BOOT-VERIFIED.**
> This repository has been configuration-audited and its product graph parses
> against PenguinOS `celerity`, but **no build has been completed and no device
> has booted this software**. Treat as experimental.

Device tree for the **OnePlus Nord CE 3 Lite 5G** (codename **larry**) on
**PenguinOS** (AOSPA-based custom ROM, Android 17, branch `celerity`).

## Device information

| | |
|---|---|
| Device | OnePlus Nord CE 3 Lite 5G (CPH2465 / CPH2467) · also sold as OnePlus Nord N30 5G |
| Codename | `larry` |
| SoC | Qualcomm Snapdragon 695 (SM6375, "holi") · Adreno 619 |
| Display | 6.72" IPS LCD, 120 Hz, 1080×2400 |
| RAM / Storage | 8 GB LPDDR4X / 128–256 GB UFS 2.2 |
| Battery | 5000 mAh, 67 W SUPERVOOC |
| Camera | 108 MP main (Samsung HM6) |
| Released | April 2023 · shipped Android 13 (OxygenOS 13.1), updated to Android 15 |
| Kernel | Linux 5.4 (Qualcomm msm-5.4, QGKI) |

## Supported ROM

| ROM | Android | Branch | Status |
|---|---|---|---|
| PenguinOS (AOSPA-based) | 17 (`android-security-17.0.0_r2`) | `celerity` | **UNTESTED / NOT BOOT-VERIFIED** |

## Purpose

PenguinOS product integration (`aospa_larry`) on top of the **unmodified**
LineageOS 24.0 device trees. The ROM layer is AOSPA-style
(`vendor/aospa/target/product/aospa-target.mk`). This repository is a faithful
mirror of the upstream LineageOS tree plus documentation; the PenguinOS product
overlay (`aospa_larry.mk` + `AndroidProducts.mk`, synced to
`device/oneplus/larry-aospa`) is published separately in the companion
repository `PaswanRaunak/android_device_oneplus_larry-aospa` (Phase C, after
first build validation) — see `larry-penguin.xml` in the release package.

## Build prerequisites

- 64-bit Linux (Ubuntu 24.04 LTS validated), 64 GB RAM minimum, ~400 GB disk
- AOSP build package set (`git`, `repo`, OpenJDK per AOSP release prebuilts,
  `zip`, `unzip`, `build-essential`, `flex`, `bison`, `gperf`, `libssl-dev`,
  `libncurses-dev`, `libxml2-utils`, `rsync`, `ccache` recommended)

## Dependencies

| Repository | Path | Branch |
|---|---|---|
| `LineageOS/android_device_oneplus_sm6375-common` | `device/oneplus/sm6375-common` | `lineage-24.0` |
| `LineageOS/android_kernel_oneplus_sm6375` | `kernel/oneplus/sm6375` | `lineage-24.0` |
| `LineageOS/android_hardware_oplus` | `hardware/oplus` | `lineage-24.0` |
| `LineageOS/android_device_qcom_sepolicy_vndr` | `device/qcom/sepolicy_vndr/legacy-um` | `lineage-24.0-legacy-um` |
| `LineageOS/android_hardware_qcom-caf_common` | `hardware/qcom-caf/common` | `lineage-24.0` |
| `LineageOS/android_hardware_qcom_audio` | `hardware/qcom-caf/sm8350/audio` | `lineage-24.0-caf-sm8350` |
| `LineageOS/android_hardware_qcom_display` | `hardware/qcom-caf/sm8350/display` | `lineage-24.0-caf-sm8350` |
| `LineageOS/android_hardware_lineage_interfaces` | `hardware/lineage/interfaces` | `lineage-24.0` |
| `LineageOS/android_device_lineage_sepolicy` | `device/lineage/sepolicy` | `lineage-24.0` |
| `LineageOS/android_vendor_lineage` | `vendor/lineage` | `lineage-24.0` |
| Vendor blobs (private until rights confirmed) | `vendor/oneplus/larry`, `vendor/oneplus/sm6375-common` | see manifest example |

## Required manifest entries

See [`larry-penguin.xml`](../larry-penguin.xml) in the release package — a
`.repo/local_manifests/` fragment listing every dependency above with
PenguinOS-aware branches.

## Branch information

- **`celerity`** — PenguinOS integration branch: lineage-24.0 content +
  publication commits (this README, LICENSE, `aospa_larry.mk` product files).
- Upstream tracking: `upstream` = `LineageOS/android_device_oneplus_larry`
  (`lineage-24.0`), merged forward only, never rewritten.

## Credits & upstream attribution

- **LineageOS Project** and the original tree authors — **Vivekachooz**
  (lead author, larry + sm6375-common), **Michael Bestas**, **LuK1337**.
- **AOSPA (Paranoid Android)** — ROM framework on which PenguinOS is based.
- **Project PenguinOS** — `celerity` platform.
- Proprietary blobs derived from OnePlus firmware; see vendor repository
  proposal (private) for provenance.

## Known issues

- **Not boot-tested.** First-build watch items: `overlay-lineage` RRO resource
  links vs AOSPA frameworks; kernel toolchain (celerity clang vs msm-5.4).
- `odm/etc/nfc/libnfc-nxp_RF.conf_22872` missing from the vendor blob set
  (one display-panel variant's NFC RF configuration; may affect NFC on some units).
- SELinux: LOS `legacy-um` sepolicy included; permissive mode may be required
  on first boot images.

## Build status

```
[ UNTESTED / NOT BOOT-VERIFIED ]
Configuration audit: PASSED (product graph parses: aospa_larry)
Build:               NOT ATTEMPTED
Device boot:         NOT ATTEMPTED
```
