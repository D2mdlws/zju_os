#include "sbi.h"
#include "printk.h"
extern void dummy();

void test() {
    int i = 0;
    while (1) {
        if ((++i) % 100000000 == 0) {
            // printk("kernel is running!\n");
            i = 0;
        }
    }
}
