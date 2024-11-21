#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "trap.h"
#include "syscall.h"
#include "defs.h"
#include "proc.h"
#include "mm.h"
#include "string.h"
#include "vm.h"

extern void do_timer();
extern struct task_struct *current;
extern char _sramdisk[];

const uint64_t EX_INST_PAGE_FAULT = 0xc;
const uint64_t EX_LOAD_PAGE_FAULT = 0xd;
const uint64_t EX_STORE_PAGE_FAULT = 0xf;

void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {
    int is_interrupt = (scause >> 63) & 1;
    
    if (is_interrupt) {
        if (scause == 0x8000000000000005) {
            // printk("[S] Supervisor Mode Timer Interrupt\n");
            clock_set_next_event();
            do_timer();
        } else {
            Err("[S] Unhandled interrupt/exception: scause=0x%lx", scause);
        }
    }
    else { // Exception
        uint64_t stval, sepc;
        sepc = csr_read(sepc);
        stval = csr_read(stval);
        if (scause == 0x0000000000000007) {
            Err("[S] Supervisor Mode Store/AMO Access Fault: sepc = %#llx, stval = %#llx", sepc, stval);
        } else if (scause == 0x0000000000000005) {
            Err("[S] Supervisor Mode Load Access Fault: sepc = %#llx, stval = %#llx", sepc, stval);
        } else if (scause == 0x0000000000000001) {
            Err("[S] Supervisor Mode Instruction Access Fault: sepc = %#llx, stval = %#llx", sepc, stval);
        } else if (scause == 0x0000000000000002) {
            Err("[S] Supervisor Mode Illegal Instruction: sepc = %#llx, stval = %#llx", sepc, stval);
        }
        else if (scause == EX_INST_PAGE_FAULT) {
            do_page_fault(regs);
        } else if (scause == EX_LOAD_PAGE_FAULT) {
            do_page_fault(regs);
        } else if (scause == EX_STORE_PAGE_FAULT) {
            do_page_fault(regs);
        } else if (scause == 0x0000000000000008) {
            // ecall from U-mode
            // printk("[S] Supervisor Mode Environment Call from U-mode\n");
            uint64_t ecall_num = regs->a7;
            if (ecall_num == 64) {
                uint64_t fd = regs->a0;
                char* buf = (char*)regs->a1;
                uint64_t count = regs->a2;

                regs->a0 = sys_write(fd, buf, count);
                regs->sepc += 4;
            } else if (ecall_num == 172) {
                regs->a0 = sys_getpid();
                regs->sepc += 4;
            } else if (ecall_num == 220) {
                regs->a0 = do_fork(regs);
                regs->sepc += 4;
            }
            else {
                Err("[S] Unhandled ecall: a7=0x%lx\n", ecall_num);
                regs->sepc += 4;
            }
        }
        else {
            Err("[S] Unhandled interrupt/exception: scause=0x%lx", scause);
        }
    }
}

void do_page_fault(struct pt_regs *regs) {
    uint64_t stval = csr_read(stval);
    uint64_t scause = csr_read(scause);
    struct vm_area_struct* vma = find_vma(&(current->mm), stval);
    if (vma == NULL) {
        uint64_t sepc = csr_read(sepc);
        Err("[S] Page Fault: no vma found for va = %#llx, sepc = %#llx, scause = %#llx", stval, sepc, scause);
    }

    if ((vma->vm_flags & VM_READ) == 0 && (scause == EX_LOAD_PAGE_FAULT)) {
        Err("[S] Page Fault: no read permission for va = %#llx", stval);
    }
    if ((vma->vm_flags & VM_WRITE) == 0 && (scause == EX_STORE_PAGE_FAULT)) {
        Err("[S] Page Fault: no write permission for va = %#llx", stval);
    }
    if ((vma->vm_flags & VM_EXEC) == 0 && (scause == EX_INST_PAGE_FAULT)) {
        Err("[S] Page Fault: no exec permission for va = %#llx", stval);
    }
    int is_annonymous = (vma->vm_flags & VM_ANON) == 1;
    // Log("[S] Page Fault: is_annonymous = %d", is_annonymous);
    Log("[S] [PID = %d] Valid Page Fault at '%#llx' with scause = %d", current->pid, stval, scause);
    if (is_annonymous) {
        // Log("[S] Page Fault: anonymous page");
        uint64_t perm = ((vma->vm_flags >> 1) << 1) | 0x1 | 0x10;
        uint64_t phy_new_page = (uint64_t)alloc_page() - PA2VA_OFFSET;
        create_mapping(current->pgd, PGROUNDDOWN(stval), phy_new_page, PGSIZE, perm);
        return ;
    }
    // Log("[S] Page Fault: load ELF file");
    // load elf file
    uint64_t file_size      = vma->vm_filesz;
    uint64_t mem_size       = vma->vm_end - vma->vm_start;
    uint64_t page_offset    = stval % PGSIZE;
    uint64_t new_page       = (uint64_t)alloc_page();
    uint64_t file_start_addr= (uint64_t)_sramdisk + vma->vm_pgoff;
    uint64_t file_end_addr  = file_start_addr + file_size ; // [start, end)
    uint64_t perm           = ((vma->vm_flags >> 1) << 1) | 0x1 | 0x10;
    uint64_t seg_start_addr = 0;

    // Log("file_start_addr = %#llx, file_end_addr = %#llx", file_start_addr, file_end_addr);

    if (PGROUNDDOWN(stval) == PGROUNDDOWN(vma->vm_start)) { // first page
        if (stval >= file_size + vma->vm_start) {
            // Log("out of filesz range");
            if (stval >= PGROUNDUP(file_size + vma->vm_start)) {
                uint64_t perm = ((vma->vm_flags >> 1) << 1) | 0x1 | 0x10;
                memset((void*)(new_page), 0, PGSIZE);
                create_mapping(current->pgd, PGROUNDDOWN(stval), new_page - PA2VA_OFFSET, PGSIZE, perm);
                return ;
            } else {
                uint64_t copy_size = file_size;
                memcpy((void*)(new_page), (void*)file_start_addr, copy_size);
                create_mapping(current->pgd, PGROUNDDOWN(stval), new_page - PA2VA_OFFSET, PGSIZE, perm);
                memset((void*)(new_page + copy_size), 0, PGSIZE - copy_size);
                return ;
            }
        }
        seg_start_addr = file_start_addr;
        // Log("seg_start_addr = %#llx", seg_start_addr);
        if (seg_start_addr + (PGSIZE - page_offset) <= file_end_addr) {
            uint64_t copy_size = PGSIZE - page_offset;
            memcpy((void*)(new_page + page_offset), (void*)seg_start_addr, copy_size);
            // Log("need to map %#llx", stval);
            // Err("memcpy : [%#llx, %#llx) <- [%#llx, %#llx)", new_page + page_offset, new_page + page_offset + copy_size, seg_start_addr, seg_start_addr + copy_size);
            create_mapping(current->pgd, PGROUNDDOWN(stval), new_page - PA2VA_OFFSET, copy_size + page_offset, perm);
        } else {
            uint64_t copy_size = file_size;
            memcpy((void*)(new_page + page_offset), (void*)file_start_addr, copy_size);
            // Log("need to map %#llx", stval);
            // Err("memcpy : [%#llx, %#llx) <- [%#llx, %#llx)", new_page + page_offset, new_page + page_offset + copy_size, seg_start_addr, seg_start_addr + copy_size);
            create_mapping(current->pgd, PGROUNDDOWN(stval), new_page - PA2VA_OFFSET, PGSIZE, perm);
        }       
    } else {
        if (stval >= file_size + vma->vm_start) {
            // Log("out of filesz range");
            if (stval >= PGROUNDUP(file_size + vma->vm_start)) {
                uint64_t perm = ((vma->vm_flags >> 1) << 1) | 0x1 | 0x10;
                memset((void*)(new_page), 0, PGSIZE);
                create_mapping(current->pgd, PGROUNDDOWN(stval), new_page - PA2VA_OFFSET, PGSIZE, perm);
                return ;
            }
            else return;
        }
        seg_start_addr = file_start_addr + (PGROUNDDOWN(stval) - vma->vm_start);
        // Log("seg_start_addr = %#llx", seg_start_addr);
        if (seg_start_addr + PGSIZE <= file_end_addr) {
            uint64_t copy_size = PGSIZE;
            memcpy((void*)(new_page), (void*)seg_start_addr, copy_size);
            // Log("need to map %#llx", stval);
            // Err("memcpy : [%#llx, %#llx) <- [%#llx, %#llx)", new_page + page_offset, new_page + page_offset + copy_size, seg_start_addr, seg_start_addr + copy_size);
            create_mapping(current->pgd, PGROUNDDOWN(stval), new_page - PA2VA_OFFSET, copy_size, perm);
        } else {
            uint64_t copy_size = file_end_addr - seg_start_addr;
            memcpy((void*)(new_page), (void*)seg_start_addr, copy_size);
            // Log("need to map %#llx", stval);
            // Err("memcpy : [%#llx, %#llx) <- [%#llx, %#llx)", new_page + page_offset, new_page + page_offset + copy_size, seg_start_addr, seg_start_addr + copy_size);
            create_mapping(current->pgd, PGROUNDDOWN(stval), new_page - PA2VA_OFFSET, PGSIZE, perm);
            memset((void*)(new_page + copy_size), 0, PGSIZE - copy_size);
        }
    }

}