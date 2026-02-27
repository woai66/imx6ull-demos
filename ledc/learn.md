## 📚 今天学习的 Linux 开发板 C 语言点灯知识归纳

---

### 一、整体架构

今天学习的是 **i.MX6ULL** (Cortex-A7 内核) 裸机开发点灯程序，整体流程如下：

```
start.s (汇编启动文件) → main.c (C语言主程序) → 控制 GPIO1_IO03 点亮/熄灭 LED
```

---

### 二、启动文件 `start.s` —— 汇编初始化

```14:1:/home/zyq/Desktop/ledc/start.s
.global _start

    _start :

    MRS R0, CPSR           @ 复制CPSR状态到R0寄存器
    BIC R0, R0, #0x1f      @ 将r0的最低5位置清0
    ORR R0, R0, #0x13      @ r0或上0x13 设置为SVC模式
    MSR CPSR, R0           @ 将r0的值写回CPSR，切换到SVC模式

    /*其 DDR3 起始地址都是 0X80000000。由于
Cortex-A7 的堆栈是向下增长的，所以将 SP 指针设置为 0X80200000 */
    LDR SP, =0x80200000    @ 设置栈指针，20MB
    B main
```

**关键知识点：**
| 步骤 | 作用 |
|------|------|
| `.global _start` | 声明全局入口点，链接器从这里开始执行 |
| 设置 SVC 模式 | ARM 有多种工作模式，SVC（超级用户模式）有完整权限 |
| 设置栈指针 SP | C 语言需要栈来存放局部变量、函数调用等，DDR 起始 `0x80000000`，栈向下增长设为 `0x80200000` |
| `B main` | 跳转到 C 语言的 `main()` 函数 |

---

### 三、头文件 `main.h` —— 寄存器地址映射

**核心概念：通过宏定义将物理地址映射为可操作的变量**

```c
#define CCM_CCGR0 *((volatile unsigned int *)0X020C4068)
#define GPIO1_DR  *((volatile unsigned int *)0X0209C000)
```

**涉及的三类寄存器：**

| 寄存器类型 | 作用 | 地址示例 |
|-----------|------|---------|
| **CCM_CCGRx** | 时钟控制门寄存器，控制外设时钟开关 | `0x020C4068` |
| **SW_MUX_xxx** | IO 复用寄存器，选择引脚功能 | `0x020E0068` |
| **SW_PAD_xxx** | IO 属性配置寄存器，配置电气特性 | `0x020E02F4` |
| **GPIO1_DR/GDIR** | GPIO 数据/方向寄存器 | `0x0209C000` |

**`volatile` 关键字**：告诉编译器不要优化这个变量，每次都从内存读取（因为硬件寄存器值可能被外部改变）。

---

### 四、主程序 `main.c` —— C 语言控制 GPIO

#### 1️⃣ 使能时钟 `clk_enable()`
```c
CCM_CCGR0 = 0XFFFFFFFF;  // 全部位置1，开启所有外设时钟
// ... CCGR1-CCGR6 同理
```
**原理**：i.MX6ULL 默认外设时钟是关闭的，必须先开启才能使用。

#### 2️⃣ LED 初始化 `led_init()`
```c
SW_MUX_GPIO1_IO03 = 0X5;      // ① 复用为 GPIO 功能 (ALT5)
SW_PAD_GPIO1_IO03 = 0X10B0;   // ② 配置电气属性（驱动能力、速度等）
GPIO1_GDIR |= (1 << 3);       // ③ 设置 bit3 为输出模式
GPIO1_DR |= (1 << 3);         // ④ 默认输出高电平（LED 灭）
```

**GPIO1_IO03 的含义**：GPIO 第1组，第3号引脚（bit3）

#### 3️⃣ 点灯/灭灯
```c
void led_on()  { GPIO1_DR &= ~(1 << 3); }  // bit3 置0，输出低电平，LED亮
void led_off() { GPIO1_DR |= (1 << 3);  }  // bit3 置1，输出高电平，LED灭
```

**位操作技巧**：
- `|= (1 << n)` → 将第 n 位置 1
- `&= ~(1 << n)` → 将第 n 位置 0

#### 4️⃣ 主循环
```c
while (1) {
    led_on();  delay_ms(500);
    led_off(); delay_ms(500);
}
```
实现 LED 闪烁效果。

---

### 五、Makefile —— 编译流程

```16:1:/home/zyq/Desktop/ledc/Makefile
objs := start.o main.o

ledc.bin: $(objs)
	arm-linux-gnueabihf-ld -Ttext 0x87800000 -o ledc.elf $(objs)
	arm-linux-gnueabihf-objcopy -O binary -S ledc.elf $@
	arm-linux-gnueabihf-objdump -D -m  arm ledc.elf > ledc.dis

%.o: %.c
	arm-linux-gnueabihf-gcc -c -o $@ $< -Wall -nostdlib
```

**编译流程图：**
```
start.s ──┐
          ├──→ .o 文件 ──→ ledc.elf (ELF可执行) ──→ ledc.bin (纯二进制)
main.c ───┘                                              ↓
                                                   烧录到开发板
```

| 工具 | 作用 |
|------|------|
| `arm-linux-gnueabihf-gcc` | 交叉编译器，生成 ARM 架构代码 |
| `arm-linux-gnueabihf-ld` | 链接器，`-Ttext 0x87800000` 指定代码加载地址 |
| `objcopy` | 将 ELF 转为纯二进制 `.bin` |
| `objdump` | 生成反汇编文件 `.dis`（调试用） |
| `-nostdlib` | 不链接标准库（裸机没有操作系统支持） |

---

### 六、知识点总结脑图

```
裸机点灯程序
├── 启动阶段 (start.s)
│   ├── 设置 CPU 工作模式 (SVC)
│   ├── 初始化栈指针 (SP)
│   └── 跳转到 main()
│
├── 硬件控制 (main.c)
│   ├── 时钟使能 (CCM_CCGRx)
│   ├── IO 复用配置 (IOMUXC)
│   ├── IO 电气属性 (PAD)
│   └── GPIO 输入输出控制 (DR/GDIR)
│
└── 编译工具链
    ├── 交叉编译 (arm-linux-gnueabihf-gcc)
    ├── 链接 (-Ttext 指定加载地址)
    └── 格式转换 (ELF → BIN)
```

---

### 七、今天遇到的问题

你在编译时遇到了 `armlinux-gnueabihf-gcc: No such file or directory` 错误，原因是：
- ❌ 原写法：`armlinux-gnueabihf-gcc`（缺少连字符）
- ✅ 正确写法：`arm-linux-gnueabihf-gcc`

这是交叉编译工具链的标准命名规范！

---

恭喜你完成了 i.MX6ULL 裸机点灯的学习！🎉 这是嵌入式 Linux 开发的第一步，后续可以继续学习中断、定时器、UART 通信等内容。