#include "main.h"
// 使能所有外设时钟
void clk_enable()
{
    CCM_CCGR0 = 0XFFFFFFFF;
    CCM_CCGR1 = 0XFFFFFFFF;
    CCM_CCGR2 = 0XFFFFFFFF;
    CCM_CCGR3 = 0XFFFFFFFF;
    CCM_CCGR4 = 0XFFFFFFFF;
    CCM_CCGR5 = 0XFFFFFFFF;
    CCM_CCGR6 = 0XFFFFFFFF;
}

void led_init()
{
    // 复用为GPIO1_IO03
    SW_MUX_GPIO1_IO03 = 0X5;
    // 配置IO属性
    SW_PAD_GPIO1_IO03 = 0X10B0;
    // 设置为输出
    GPIO1_GDIR |= (1 << 3);
    // 默认输出高电平
    GPIO1_DR |= (1 << 3);
}
void led_on()
{
    GPIO1_DR &= ~(1 << 3); // 与上第4位取反，置0
}
void led_off()
{
    GPIO1_DR |= (1 << 3);
}
void delay(volatile unsigned int time)
{
    while (time--)
        ;
}

/// @brief 在396MHz下大约延时1ms
/// @param ms
void delay_ms(volatile unsigned int ms)
{
    while (ms--)
    {
        delay(0x7FF);
    }
}
int main()
{
    clk_enable();
    led_init();
    while (1)
    {
        led_on();
        delay_ms(500);
        led_off();
        delay_ms(500);
    }
    return 0;
}