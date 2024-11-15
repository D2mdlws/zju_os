#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#include "stdint.h"

uint64_t sys_write(unsigned int fd, const char* buf, uint64_t count);
uint64_t sys_getpid();

#endif