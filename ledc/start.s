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
