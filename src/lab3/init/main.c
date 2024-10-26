#include "printk.h"
#include "defs.h"

extern void test();

int start_kernel() {
    printk(FG_COLOR(175, 175, 255) "2024" CLEAR);
    printk(FG_COLOR(215, 175, 255) " ZJU Operating System\n" CLEAR);
    printk(BOLD FG_COLOR(255, 135, 255) "---------------------------------------\n\n" CLEAR);
    // uint64_t sstatus = csr_read(sstatus);
    // printk("sstatus: %#llx\n", sstatus);

    // csr_write(sscratch, (uint64_t)0xffffffffffffffff);
    // uint64_t sscratch = csr_read(sscratch);
    // printk("scratch: %#llx\n", sscratch);

    test();
    return 0;
}
