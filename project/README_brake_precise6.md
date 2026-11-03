# Logo 工程电机控制替换为 brake_precise6

2026-10-29 更新：实机日志发现旧整合 bit 的 D2 帧头/换行异常，导致完整 VIS=6 报文被粘连拒收。新面板位于 `host/start_brake_precise6.cmd`，支持严格校验后的 VIS 重同步；修复固件文件名带 `_uartfix`，交付以最新核验报告为准。旧 bit 和日志保存在 `evidence/uart_fix_20261029/`。

本工程保留原摄像头、检测、视频算法、Logo 和 HDMI 链路及显示效果，将电机控制与活动参数切换为 brake_precise6。

交付文件：`output/merged_vision_motor_logo_brake_precise6_uartfix.bit`，兼容文件名 `output/merged_vision_motor_logo.bit`。交付以 `motor_precise6_verification.json` 通过为准。

## 来源与改动

- 用户指定 bit：`../vision_follow_20261028_refactor/output/brake_precise6.bit`。
- 其 SHA256 为 `f86441586081166212696fe3914a27fc522889ec9d2a684833e76c5ad2998934`，与 `../vision_follow_20261022/output/brake_precise6.bit` 一致。
- 电机源码从 `../vision_follow_20261022` 提取，先与 precise6 发布清单核对。未使用后续 ball_track_refactor 控制策略。
- 顶层仅修改 vision_monitor 参数：DEADZONE=100、ASYM_SMOOTH=1、REGION100=1、REGION_FAST=1，其余原参数保留。
- 导入 precise6 电机策略、执行内核、换向恢复及有界脱困逻辑。原限位、反馈、故障、脉冲预算与启停语义随 precise6 完整保留。
- 原样整合超过器件容量，因此 OSD 采用共享字模查找；VIS/D2 发送器采用先选原始半字节再统一转 ASCII 的组合逻辑。寄存器、UART 状态机与波形周期不变。OSD 786,432 次像素比对、VIS 1,048,576 次及 D2 524,288 次格式字节比对通过；详见 evidence/ 中的记录。
- precise6 的显示预测模块随 RTL 合集存在，但未在顶层实例化；本次保留 Logo 工程原有检测与显示。
- 原工程和旧 bit 备份在 `backup_before_brake_precise6/project_before.zip`。

## 构建与核验

1. `python run_motor_precise6_regression.py`
2. `python build_motor_precise6.py`
3. `python finalize_motor_precise6.py`

构建使用 PH1P35MDG324，独立输出到 `motor_precise6_Runs`。交付前检查全部 23 项电机回归、OSD/串口等价性、当前源码快照、器件、布线时序、官方摄像头引脚、电机引脚镜像与原视频/Logo文件哈希。precise6 原有显示修复专项不用于本工程，因为未导入其显示预测/框校正。

## 板上操作

使用本工程配套上位机：`host/start_brake_precise6.cmd`。先关闭旧面板释放 COM3，再启动本地新版面板；连接不会自动发送参数或启动运动。新版可从粘连数据中识别完整且合法的 VIS=6 帧，D2 仍要求原始帧头及 XOR 校验。

沿用 precise6 操作：先调平，K1 使能；放球到目标中心后 K3 记录中心，再 K2 启动，K2 再按停止。K4 保持原立即停止/释放使能行为，也仍连接原工程的显示模式切换功能。默认不自动运动。

软件和布线通过不能替代实板验证；本次不自动烧录或写入 Flash。烧入整合 bit 后需确认 Logo/OSD 显示及实际回中效果。

## 2026-10-28 交付记录（旧 bit 已归档，D2 异常见顶部说明）

23 项电机回归、OSD/串口等价比对、PH1P35MDG324 器件与全部引脚镜像、源码快照和完整布线时序均通过。最终 setup +0.109ns、hold +0.014ns；Slice 21035/21216、DSP 39/40。尚未烧录，实板效果待验。

整合 bit SHA256：`01ae2141961516940c35ed34339d04f29a88696ec14f23aeb84015766f83d214`。两个 output 文件名内容一致。

## 2026-10-29 UART 修复交付

- 实测日志中有 100 帧完整 VIS=6，原面板因前置损坏 D2 的粘连字节全部拒收。新版面板只重同步完整且通过原严格校验的 VIS，不拼造字段，不放宽 D2 XOR 校验。
- D2 帧头和 CR/LF 改为显式组合逻辑；完整布局报告中 D2 ERAM=0。综合后核心逻辑连续 8 帧 UART 与 RTL 逐周期一致，头尾和 hex 数据检查通过。
- 23 项电机回归、旧版字节等价性及日志分片回放全部通过。PH1P35MDG324、原引脚和镜像、时钟与源码快照通过；setup +0.031ns、hold +0.020ns、STNS/HTNS=0。Slice 20702/21216、ERAM 66、DSP 39/40。
- 新 bit 为 `output/merged_vision_motor_logo_brake_precise6_uartfix.bit`，两个标准文件名也指向本次相同内容；旧 bit 保存在 evidence/uart_fix_20261029。
- SHA256：`f29b6aa11420824540579d4b810b0ec46adca27577c0e077414b5166491f6c18`。未自动烧录；新固件的实机重烧验证待确认。新面板可先用于旧整合 bit 的 VIS 读取，D2 正常诊断输出需使用修复 bit。
