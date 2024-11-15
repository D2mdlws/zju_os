#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "trap.h"
#include "syscall.h"

extern void do_timer();

void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {
    // 通过 `scause` 判断 trap 类型
    // 如果是 interrupt 判断是否是 timer interrupt
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试

    int is_interrupt = (scause >> 63) & 1;
    
    if (is_interrupt) {
        if (scause == 0x8000000000000005) {
            // printk("[S] Supervisor Mode Timer Interrupt\n");
            
            clock_set_next_event();
            do_timer();
        } else {
            printk("[S] Unhandled interrupt/exception: scause=0x%lx\n", scause);
        }
    }
    else { // Exception
        if (scause == 0x0000000000000007) {
            printk("[S] Supervisor Mode Store/AMO Access Fault\n");
        } else if (scause == 0x0000000000000005) {
            printk("[S] Supervisor Mode Load Access Fault\n");
        } else if (scause == 0x0000000000000001) {
            printk("[S] Supervisor Mode Instruction Access Fault\n");
        } else if (scause == 0x000000000000000c) {
            printk("[S] Supervisor Mode Instruction Page Fault\n");
        } else if (scause == 0x000000000000000f) {
            printk("[S] Supervisor Mode Store/AMO page fault\n");
        } else if (scause == 0x0000000000000008) {
            // ecall from U-mode
            // printk("[S] Supervisor Mode Environment Call from U-mode\n");
            uint64_t ecall_num = regs->a7;
            if (ecall_num == 64) {
                uint64_t fd = regs->a0;
                char* buf = (char*)regs->a1;
                uint64_t count = regs->a2;

                regs->a0 = sys_write(fd, buf, count);
                regs->sepc += 4;
            } else if (ecall_num == 172) {
                regs->a0 = sys_getpid();
                regs->sepc += 4;
            }
            else {
                printk("[S] Unhandled ecall: a7=0x%lx\n", ecall_num);
                regs->sepc += 4;
            }
            
        }
        else {
            printk("[S] Unhandled interrupt/exception: scause=0x%lx\n", scause);
        }
    }
}