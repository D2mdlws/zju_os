#include "syscall.h"
#include "stdint.h"
#include "sbi.h"
#include "proc.h"

extern struct task_struct *current;

uint64_t sys_write(unsigned int fd, const char* buf, uint64_t count) {
    int ret = 0;
    if (fd != 1) {
        printk("sys_write: unsupported file descriptor: %d\n", fd);
        return 0;
    }
    for (uint64_t i = 0; i < count; i++) {
        sbi_debug_console_write_byte((uint8_t)buf[i]);
        ret++;
    }
    return ret;
}

uint64_t sys_getpid() {
    return current->pid;
}