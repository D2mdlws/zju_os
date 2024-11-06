// arch/riscv/kernel/vm.c

#include "stddef.h"
#include "defs.h"
#include "mm.h"
#include "string.h"
#include "printk.h"
#include "vm.h"

extern char _stext[];
extern char _etext[];
extern char _srodata[];
extern char _erodata[];
extern char _sdata[];
extern char _edata[];
extern char _sbss[];
extern char _ebss[];

/* early_pgtbl: 用于 setup_vm 进行 1GB 的 映射。 */
uint64_t  early_pgtbl[512] __attribute__((__aligned__(0x1000))); // uint64_t is 8 bytes, 4KB all together in a page
/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t  swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
    /* 
    1. 由于是进行 1GB 的映射 这里不需要使用多级页表 
    2. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
        high bit 可以忽略
        中间9 bit 作为 early_pgtbl 的 index
        低 30 bit 作为 页内偏移 这里注意到 30 = 9 + 9 + 12， 即我们只使用根页表， 根页表的每个 entry 都对应 1GB 的区域。 
    3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    */
    /* 
     * Since the 1GB mapping only needs the first page, thus the least significant 30 bits of
     * the physical are considered as the offset, and the 9 bits in the middle are used as index
     * 
     * In the pte, only PPN[2](26 bits) is needed, thus turn the phyaddr[55:30] to pte[53:28]
    */

    uint64_t pte_flags = 0x1 | 0x2 | 0x4 | 0x8; // V | R | W | X
    uint64_t table_index;
    uint64_t PHY_PPN_2 = (PHY_START >> 30) & 0x3ffffff;
    uint64_t PTE_PPN_2 = PHY_PPN_2 << 28;


    table_index = (PHY_START >> 30) & (0x1ffUL);        // GET 9-bit index
    early_pgtbl[table_index] = PTE_PPN_2 | pte_flags; // set page table entry

    table_index = (VM_START >> 30) & (0x1ffUL);        // GET 9-bit index
    early_pgtbl[table_index] = PTE_PPN_2 | pte_flags; // set page table entry

    printk(BOLD FG_COLOR(255, 95, 00)"...setup_vm done!\n" CLEAR);
    // printk( "Set equal mapping: index = %#llx, tbl_entry = %#llx\n" CLEAR, 
    //                 (PHY_START >> 30) & (0x1ffUL), (((PHY_START >> 30) & 0x3ffffff) << 28) | pte_flags);

    // printk(RED "Set direct mapping: index = %#llx, tbl_entry = %#llx\n" CLEAR, 
    //                 (VM_START >> 30) & (0x1ffUL), (((PHY_START >> 30) & 0x3ffffff) << 28) | pte_flags);

}

void setup_vm_final() {
    // Log("In setup_vm_final()");

    // No OpenSBI mapping required
    // Log("_stext = %#llx, _srodata = %#llx, sun = ", _stext, _srodata, (uint64_t)_srodata - (uint64_t)_stext);

    // mapping kernel text X|-|R|V
    printk(FG_COLOR(255, 95, 95) "Mapping kernel text section, NR_pages = %d ... \n" CLEAR, ((_srodata - _stext) >> 12)); // 1 page
    create_mapping(swapper_pg_dir, (uint64_t)_stext, (uint64_t)_stext - PA2VA_OFFSET, 
                    (uint64_t)_srodata - (uint64_t)_stext, 0xb); // 4'b1011
    printk(FG_COLOR(255, 95, 95) "...mapping kernel text section done!\n" CLEAR);


    // mapping kernel rodata -|-|R|V
    printk(FG_COLOR(255, 95, 135) "Mapping kernel rodata, NR_pages = %d ...\n" CLEAR, ((_sdata - _srodata) >> 12)); // 1 page
    create_mapping(swapper_pg_dir, (uint64_t)_srodata, (uint64_t)_srodata - PA2VA_OFFSET, 
                    (uint64_t)_sdata - (uint64_t)_srodata, 0x3); // 4'b0011
    printk(FG_COLOR(255, 95, 135) "...mapping kernel rodata section done!\n" CLEAR);

    // mapping other memory -|W|R|V
    printk(FG_COLOR(255, 95, 175) "Mapping kernel other data, NR_pages = %d ...\n" CLEAR, (PHY_SIZE - ((uint64_t)_sdata - (uint64_t)_stext) >> 12)); // 32764 pages
    create_mapping(swapper_pg_dir, (uint64_t)_sdata, (uint64_t)_sdata - PA2VA_OFFSET, 
                    PHY_SIZE - ((uint64_t)_sdata - (uint64_t)_stext), 0x7); // 4'b0111
    printk(FG_COLOR(255, 97, 215) "...mapping kernel other data done!\n" CLEAR);

    // set satp with swapper_pg_dir
    uint64_t phy_swapper_pg_dir = (uint64_t)swapper_pg_dir - PA2VA_OFFSET;
    uint64_t satp_value = (phy_swapper_pg_dir >> 12) + 0x8000000000000000;
    csr_write(satp, satp_value);

    // printk(YELLOW "Set satp = %#llx\n, addr of swapper = %#llx ,virtual addr = %#llx\n" CLEAR, satp_value, (uint64_t)phy_swapper_pg_dir, (uint64_t)swapper_pg_dir);

    // flush TLB
    asm volatile("sfence.vma zero, zero");

    // flush icache
    asm volatile("fence.i");

    printk(FG_COLOR(255, 95, 255) "...setup_vm_final done!\n" CLEAR);

    return;
}

void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
    /*
     * pgtbl 为根页表的基地址
     * va, pa 为需要映射的虚拟地址、物理地址
     * sz 为映射的大小，单位为字节
     * perm 为映射的权限（即页表项的低 8 位）
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/

    uint64_t num_pages = sz >> 12;
    if (sz % 0x1000 != 0)  num_pages++;
    // Log("num_pages = %lu", num_pages);
    // printk();


    for (uint64_t i = 0; i < num_pages; i++) {
        // Log("va = %#llx, pa = %#llx", va, pa);

        uint64_t VPN_2 = (va >> 30) & 0x1ffUL;
        uint64_t VPN_1 = (va >> 21) & 0x1ffUL;
        uint64_t VPN_0 = (va >> 12) & 0x1ffUL;
        // Log("VPN_2 = %#llx, VPN_1 = %#llx, VPN_0 = %#llx", VPN_2, VPN_1, VPN_0);

        uintptr_t* pmd;
        uintptr_t* pte;

        // Log("pgtbl[VPN_2] = %#llx", pgtbl[VPN_2]);
        if ((pgtbl[VPN_2] & 0x1) == 0) {
            uint64_t* new_pmd_va = (uint64_t*)kalloc(); // allocate a page for pmd
            uint64_t new_pmd_pa = (uint64_t)new_pmd_va - PA2VA_OFFSET;
            pgtbl[VPN_2] = (((new_pmd_pa) >> 12) << 10) | 0x1;
        }
        pmd = (uint64_t*)((pgtbl[VPN_2] >> 10) << 12); // physical addr of pmd

        // Log("pmd = %#llx", pmd);
        if ((pmd[VPN_1] & 0x1) == 0) {
            uint64_t* new_pte_va = (uint64_t*)kalloc(); // allocate a page for pte
            uint64_t new_pte_pa = (uint64_t)new_pte_va - PA2VA_OFFSET;
            pmd[VPN_1] = ((new_pte_pa >> 12) << 10) | 0x1;
        }
        pte = (uint64_t*)(((pmd[VPN_1] >> 10) << 12)); // physical addr of pte

        // Log("pte = %#llx", pte);
        pte[VPN_0] = ((pa >> 12) << 10) | perm; // set pte entry
        
        va += PGSIZE;
        pa += PGSIZE;
    }

    return;
}