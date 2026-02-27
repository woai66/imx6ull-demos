# 嵌入式学习仓库

学习正点原子 **I.MX6ULL**（Cortex-A7）Linux 裸机开发的工程仓库。

## 开发板与工具链

- **板子**：正点原子 I.MX6ULL
- **交叉编译器**：`arm-linux-gnueabihf-gcc`
- **链接地址**：`0x87800000`（裸机程序加载地址）

## 工程说明

| 工程 | 语言 | 说明 |
|------|------|------|
| **led1** | 纯汇编 | 汇编点灯，GPIO1_IO03 常亮 |
| **ledc** | 汇编 + C | C 语言点灯，LED 闪烁 |
| **led_stm32** | - | 待开发（STM32 相关） |

### led1 — 汇编点灯

- **路径**：`led1/`
- **实现**：仅用 ARM 汇编（`led.s`）完成点灯，无 C 代码。
- **流程**：使能 CCM 时钟 → 配置 GPIO1_IO03 复用与属性 → 设为输出、输出低电平 → 死循环。
- **产物**：`led.bin`（烧录到开发板运行）。

### ledc — C 语言点灯

- **路径**：`ledc/`
- **实现**：汇编启动（`start.s`）初始化 CPU 模式与栈，再跳转到 C 的 `main()`，用 C 控制 LED 闪烁。
- **主要文件**：
  - `start.s`：SVC 模式、栈指针、`B main`
  - `main.c`：时钟使能、GPIO 初始化、亮/灭/延时、主循环
  - `main.h`：寄存器地址宏（CCM、IOMUX、GPIO1）
- **产物**：`ledc.bin`。

### led_stm32 — 

- **路径**：`led_stm32/`
- **说明**：STM32 相关工程，

## 仓库结构概览

```
.
├── readme.md          # 本说明
├── led1/              # 汇编点灯
│   ├── led.s
│   └── Makefile
├── ledc/              # C 语言点灯
│   ├── start.s
│   ├── main.c
│   ├── main.h
│   ├── Makefile
│   └── learn.md       # 学习笔记
└── led_stm32/         # 待开发
```
