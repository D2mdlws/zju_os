#ifndef __VM_H__
#define __VM_H__

#include "stdint.h"

void setup_vm();
void setup_vm_final();
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm);

#endif