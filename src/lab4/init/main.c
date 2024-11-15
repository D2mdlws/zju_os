#include "printk.h"
#include "defs.h"
#include "proc.h"

extern void test();
extern char _stext[];
extern char _srodata[];

int start_kernel() {
    printk(FG_COLOR(175, 175, 255) "2024" CLEAR);
    printk(FG_COLOR(215, 175, 255) " ZJU Operating System\n" CLEAR);
    printk(BOLD FG_COLOR(255, 135, 255) "---------------------------------------\n\n" CLEAR);
    // uint64_t sstatus = csr_read(sstatus);
    // printk("sstatus: %#llx\n", sstatus);

    // csr_write(sscratch, (uint64_t)0xffffffffffffffff);
    // uint64_t sscratch = csr_read(sscratch);
    // printk("scratch: %#llx\n", sscratch);

    // __asm__ __volatile__(
    //     "li t0, 0xffffffffffffffff\n"
    //     "li t1, 0xffffffe000203000\n"
    //     "sd t0, 0(t1)\n"
    //     : : : "t0", "t1"
    // );

    // // check text section: read property
    // uint64_t stext = *((uint64_t*)_stext);
    // printk("_stext = %#llx \n", stext);

    // check rodata section: read property
    // uint64_t srodata = *((uint64_t*)_srodata);
    // printk("_srodata = %#llx \n", srodata);

    // // check text section: write property
    // *((uint64_t*)_stext) = 0x12345678;

    // // check rodata section: write property
    // *((uint64_t*)_srodata) = 0x12345678;

    // check rodata section: execute property
    // void (*func)() = (void*)_srodata;
    // func();
    
    do_timer();
    test();
    return 0;
}
