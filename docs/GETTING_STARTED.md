# 工程入口

本仓库固定到 Logo + brake_precise6 + UART 修复工程，未混入旧交接包的独立工程。

1. 完整下载仓库，使用 TD 6.2 对应环境打开 `project/td_project/vision_follow_20261022.al`。
2. 检查顶层 `design_top_wrapper`，器件 `PH1P35MDG324`；工程记录 TD 6.2.168116。
3. 工程名称保留历史名称。`.al` 的工程位置包含原电脑路径，换电脑需检查工程位置和引用；主体源文件引用为相对路径。
4. 当前构建流程参见 `project/build_motor_precise6.tcl`。请先检查脚本路径与输出位置。`compose.py` 会重建聚合源，未核对前勿直接执行。
5. 上位机入口 `project/host/start_brake_precise6.cmd`。上位机用于配置与观测，控制执行在 FPGA。

本次整理未重新综合、烧录或执行整套回归。原构建与核验说明见 `project/README_brake_precise6.md`。

可离线浏览 `site/index.html`。GitHub 代码页里的 HTML 链接显示源码，不会直接变成网页；本次没有发布公开网站。
