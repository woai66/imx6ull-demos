.global _start @全局标号

    _start :
/* 初始化所有外设时钟 */
    ldr r0, =0x020C4068 @CCGR0
    ldr r1, =0xFFFFFFFF
    str r1, [r0]

    ldr r0, =0x020C406C @CCGR1
    str r1, [r0]

    ldr r0, =0x020C4070 @CCGR2
    str r1, [r0]

    ldr r0, =0x020C4074 @CCGR3
    str r1, [r0]

    ldr r0, =0x020C4078 @CCGR4
    str r1, [r0]

    ldr r0, =0x020C407C @CCGR5
    str r1, [r0]

    ldr r0, =0x020C4080 @CCGR6
    str r1, [r0]
/* 配置GPIO1_IO3引脚复用功能 */
    ldr r0, =0x020E0068 @IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO03
    ldr r1, =0x00000005 @设置为GPIO功能
    str r1, [r0]
/* 配置GPIO1_IO3引脚属性\
 * bit0~bit15:属性设置 下拉，速度100MHz
 */
    ldr r0, =0x020E02F4 @IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO03
    ldr r1, =0x000010b0 @根据32bit,看手册配置，前16bit保留
    str r1, [r0]

/* 配置GPIO1_IO3为输出-direction寄存器 */
    ldr r0, =0x0209C004 @GPIO1_GDIR
    ldr r1, =0x00000008 @设置GPIO1_IO3为输出模式·
    str r1, [r0]
/* 配置GPIO1_IO3为低电平 */
    ldr r0, =0x0209C000 @GPIO1_DR
    ldr r1, =0 @设置GPIO1_IO3为低电平
    str r1, [r0]
/* 死循环 */
loop:
    b loop
