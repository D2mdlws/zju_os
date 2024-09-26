#include "printk.h"
#include "defs.h"

extern void test();

int start_kernel() {
    printk("2024");
    printk(" ZJU Operating System\n");
    uint64_t sstatus = csr_read(sstatus);
    printk("sstatus: %#llx\n", sstatus);

    csr_write(sscratch, (uint64_t)0xffffffffffffffff);
    uint64_t sscratch = csr_read(sscratch);
    printk("scratch: %#llx\n", sscratch);

    test();
    return 0;
}
