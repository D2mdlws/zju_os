#include "syscall.h"
#include "stdint.h"
#include "sbi.h"
#include "proc.h"
#include "printk.h"
#include "mm.h"
#include "string.h"
#include "defs.h"
#include "trap.h"
#include "vm.h"

extern char __ret_from_fork[];

extern struct task_struct *current;
extern struct task_struct *task[NR_TASKS];
extern uint64_t nr_tasks;
extern uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

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

uint64_t do_fork(struct pt_regs *regs) {
    Log("-----in do_fork()-----");
    // copy kernel stack
    struct task_struct *new_task = (struct task_struct *)alloc_page();
    memcpy(new_task, current, PGSIZE); // copy the whole task_struct and kernel stack
    new_task->pid = nr_tasks;
    new_task->thread.ra = (uint64_t)__ret_from_fork;

    new_task->pgd = (uint64_t *)alloc_page();
    new_task->mm.mmap = NULL;

    // create child process
    task[nr_tasks++] = new_task;
    memcpy(new_task->pgd, swapper_pg_dir, PGSIZE);
    // walk through the parent's vm_area_struct list and copy each allocated memory page
    struct vm_area_struct *vma = current->mm.mmap;
    for (; vma != NULL; vma = vma->vm_next) {
        do_mmap(&(new_task->mm), vma->vm_start, vma->vm_end - vma->vm_start, vma->vm_pgoff, vma->vm_filesz, vma->vm_flags);
        uint64_t addr = PGROUNDDOWN(vma->vm_start);
        uint64_t end_addr = PGROUNDUP(vma->vm_end);
        for (; addr < end_addr; addr += PGSIZE) {
            uint64_t pte_entry = walk_pgtbl(current->pgd, addr);
            uint64_t phy_addr = (pte_entry >> 10) << 12;
            uint64_t perm = ((vma->vm_flags >> 1) << 1) | 0x1 | 0x10;
            if (pte_entry != 0) {
                uint64_t new_page = (uint64_t)alloc_page();
                memcpy((void*)new_page, (void*)(phy_addr + PA2VA_OFFSET), PGSIZE);
                create_mapping(new_task->pgd, addr, new_page - PA2VA_OFFSET, PGSIZE, perm);
            }
        }
    }
    // set child's pt_regs and stacks
    uint64_t kernel_sp = (uint64_t)(regs->sp);
    uint64_t ksp_offset_to_bottom = kernel_sp - (uint64_t)current;
    new_task->thread.sp = (uint64_t)new_task + ksp_offset_to_bottom; // points to child's pt_regs
    uint64_t sscratch = csr_read(sscratch);
    new_task->thread.sscratch = sscratch; 
    ((uint64_t*)(new_task->thread.sp))[2] = new_task->thread.sp; // _trap will change to user stack in the end
    ((uint64_t*)(new_task->thread.sp))[10] = 0; // set child's pt_regs->a0 to 0
    ((uint64_t*)(new_task->thread.sp))[32] += 4; // set child's pt_regs->sepc to the next fork() instruction 
    Log("-----finish fork, new pid = %d-----", new_task->pid);
    return new_task->pid;
}

uint64_t walk_pgtbl(uint64_t *pgd, uint64_t va) {
    uint64_t* pmd;
    uint64_t* pte;
    uint64_t VPN2 = (va >> 30) & 0x1ff;
    uint64_t VPN1 = (va >> 21) & 0x1ff;
    uint64_t VPN0 = (va >> 12) & 0x1ff;

    if ((pgd[VPN2] & 0x1) == 0) {
        return 0;
    }
    pmd = (uint64_t*)(((pgd[VPN2] >> 10) << 12) + PA2VA_OFFSET);
    if ((pmd[VPN1] & 0x1) == 0) {
        return 0;
    }
    pte = (uint64_t*)(((pmd[VPN1] >> 10) << 12) + PA2VA_OFFSET);
    if ((pte[VPN0] & 0x1) == 0) {
        return 0;
    }
    return pte[VPN0];
}