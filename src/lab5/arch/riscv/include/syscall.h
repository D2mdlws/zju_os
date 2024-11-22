#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#include "stdint.h"
#include "trap.h"

uint64_t sys_write(unsigned int fd, const char* buf, uint64_t count);
uint64_t sys_getpid();
uint64_t do_fork(struct pt_regs *regs);
uint64_t walk_pgtbl(uint64_t *pgd, uint64_t va);

uint64_t walk_pgtbl(uint64_t *pgd, uint64_t va);
void change_ptb_perm(uint64_t *pgd, uint64_t va, uint64_t perm);

#endif