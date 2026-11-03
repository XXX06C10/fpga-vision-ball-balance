# 版本与证据

整理日期：2026-11-03。当前工程对应 `merged_vision_motor_logo_brake_precise6.bit`，与 `_uartfix.bit` 内容一致。

SHA256：`f29b6aa11420824540579d4b810b0ec46adca27577c0e077414b5166491f6c18`。

| 结论 | 原始证据 | 限制 |
|---|---|---|
| 已有23项电机回归通过 | `project/motor_precise6_regression.json` 及 `project/sim/` 的既有记录 | 本次未重跑；不等于实物验收 |
| Setup +0.031 ns / Hold +0.020 ns | `project/motor_precise6_verification.json`、`docs/evidence/` 的当前实现报告 | 对应该次布线结果与约束 |
| Slice 20702 / 21216；DSP 39 / 40 | 当前 `logo_phy.area` | 物理资源口径 |
| 源码对应性 | `project/motor_precise6_build_sources.json` | 本仓包含的233项源码、IP、约束等构建输入核对一致；原清单另含旧运行缓存、锁文件及会话日志，不纳入源码归档 |
| 实物验收待完成 | 核验状态 `SOFTWARE_AND_ROUTING_PASS_PHYSICAL_PENDING` | 原始报告中的平台照片和曲线不补足当前固件验收 |

当前为一维单轴闭环；不宣称二维球板控制、神经网络识别、卡尔曼滤波、实测毫米精度或60帧显示。

建议补充：绑定当前 bit 的连续演示视频、工况说明、回中时间、稳态误差、扰动恢复和停止测试。阈值属于控制策略，不能直接当实测精度。
