#ifndef __TRAP_H__
#define __TRAP_H__
#include "stdint.h"

void trap_handler(uint64_t scause, uint64_t sepc);

#endif