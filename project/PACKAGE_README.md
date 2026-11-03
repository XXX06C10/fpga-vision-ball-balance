# brake_precise6 源码交付包

整理日期：2026-11-03。

对应文件：output/merged_vision_motor_logo_brake_precise6.bit
SHA256：f29b6aa11420824540579d4b810b0ec46adca27577c0e077414b5166491f6c18

构建源码清单 motor_precise6_build_sources.json 中的 291 个文件均已逐一核对，当前文件哈希全部一致。原清单中的锁文件及 TD 会话日志不属于源码，未纳入本次一致性结论。该 bit 与工程 README 中 2026-10-29 UART 修复版本一致。此为既有工程源码副本，本次没有重新综合或验证重新生成的 bit 是否逐字节一致。

## 使用

1. 完整解压后打开 td_project/vision_follow_20261022.al。工程名称为历史名称；顶层为 design_top_wrapper，器件 PH1P35MDG324，工程记录 TD 6.2.168116。
2. 完整构建流程参考 build_motor_precise6.tcl，该脚本切换到自身所在目录并使用相对路径。工程 .al 的 Project Path 保留原路径，换电脑打开时需在 TD 中检查工程位置和源文件路径。
3. rtl/ 为控制 RTL；user_source/ 含视频链路、IP及约束；sim/ 含仿真材料；host/ 含上位机。第三方加密 IP 保留原件，仍需相应 TD 环境支持。
4. 不包含大型综合布局布线缓存、历史备份和仿真波形。既有验证结论见原工程 JSON 和 README_brake_precise6.md，不视为本次重新测试结果。

ARCHIVE_SHA256.json 记录包内文件的 SHA256。RAR 使用存储模式，保留原始文件内容。
