#include "mm.h"
#include "defs.h"
#include "proc.h"
#include "stdlib.h"
#include "printk.h"
#include "string.h"
#include "vm.h"
#include "elf.h"

extern void __dummy();
extern void __switch_to(struct task_struct *prev, struct task_struct *next);

extern uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));
extern char _sramdisk[];
extern char _eramdisk[];

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此, the type in the array is pointer to task_struct

void task_init() {
    srand(2024);


    // 1. 调用 kalloc() 为 idle 分配一个物理页
    // 2. 设置 state 为 TASK_RUNNING;
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    // 4. 设置 idle 的 pid 为 0
    // 5. 将 current 和 task[0] 指向 idle

    idle = (struct task_struct *)kalloc();
    idle->state = TASK_RUNNING;
    idle->counter = 0;
    idle->priority = 0;
    idle->pid = 0;

    current = idle;
    task[0] = idle;

    // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority 进行如下赋值：
    //      task[i].counter  = 0;
    //      task[i].priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.3.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    /* YOUR CODE HERE */

    for (int i = 1; i <= NR_TASKS - 1; i++) {
        task[i] = (struct task_struct *)kalloc();

        task[i]->state = TASK_RUNNING;
        task[i]->counter = 0;
        task[i]->priority = (rand() % (PRIORITY_MAX - PRIORITY_MIN + 1)) + PRIORITY_MIN;
        task[i]->pid = i;
        task[i]->pgd = (uint64_t *)alloc_page();
        memcpy(task[i]->pgd, swapper_pg_dir, PGSIZE);
        uint64_t ustack = (uint64_t)alloc_page(); // points to the bottom of the ustack

        /* set thread_struct */
        task[i]->thread.ra = (uint64_t)__dummy;
        task[i]->thread.sp = (uint64_t)task[i] + PGSIZE;

        // map the user stack to physical address  U|-|W|R|V 
        create_mapping(task[i]->pgd, USER_END - PGSIZE, ustack - PA2VA_OFFSET, PGSIZE, 0b10111);

        // // create pages and copying the user program
        // uint64_t NR_uapp_pages = ((uint64_t)_eramdisk - (uint64_t)_sramdisk) / PGSIZE;
        // if (((uint64_t)_eramdisk - (uint64_t)_sramdisk) % PGSIZE != 0) NR_uapp_pages++;
        // Log("NR_uapp_pages = %d", NR_uapp_pages);
        // uint64_t* uapp_addr = (uint64_t*)alloc_pages(NR_uapp_pages);
        // memcpy((void*)uapp_addr, (void*)_sramdisk, (uint64_t)_eramdisk - (uint64_t)_sramdisk + 1);

        // // map whole uapp to physical address  U|X|W|R|V
        // create_mapping(task[i]->pgd, USER_START, (uint64_t)uapp_addr - PA2VA_OFFSET, NR_uapp_pages * PGSIZE, 0b11111);

        load_program(task[i]);

        // set newly added three registers
        task[i]->thread.sscratch = USER_END;
        uint64_t sstatus;
        csr_read(sstatus);
        sstatus &= (~(1 << 8)); // set SPP to 0, indicating trap from user mode
        sstatus |= (1 << 5); // set SPIE to 1, enable supervisor interrupt
        sstatus |= (1 << 18); // set SUM to 1, enable accessing user memory
        task[i]->thread.sstatus = sstatus;

        printk(FG_COLOR(215,135, 255) "SET [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR, task[i]->pid, task[i]->priority, task[i]->counter);
        
    }

    printk(BOLD FG_COLOR(215, 135, 215) "...task_init done!\n" CLEAR);
}

#if TEST_SCHED
#define MAX_OUTPUT ((NR_TASKS - 1) * 10)
char tasks_output[MAX_OUTPUT];
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
    // Log("step into dummy(), current pid = %d, current counter = %d", current->pid, current->counter);
    const char* colors[] = {COLOR1, COLOR2, COLOR3, COLOR4, COLOR5, COLOR6};
    uint64_t MOD = 1000000007;
    uint64_t auto_inc_local_var = 0;
    int last_counter = -1;
    int x = 1, flag = 0;
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
            if (current->counter == 1) {
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
            switch(x) {
                case 1: printk(COLOR1 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
                        break;
                case 2: printk(COLOR2 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
                        break;
                case 3: printk(COLOR3 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
                        break;
                case 4: printk(COLOR4 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
                        break;
                case 5: printk(COLOR5 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
                        break;
                case 6: printk(COLOR6 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
                        break;
            }
            // printk(COLOR1 "[PID = %d] is running. auto_inc_local_var = %d\n" CLEAR, current->pid, auto_inc_local_var);
            if (flag == 0) {
                x++;
                if (x == 7) {
                    x = 6;
                    flag = 1;
                }
            } else {
                x--;
                if (x == 0) {
                    x = 1;
                    flag = 0;
                }
            }
            #if TEST_SCHED
            tasks_output[tasks_output_index++] = current->pid + '0';
            if (tasks_output_index == MAX_OUTPUT) {
                for (int i = 0; i < MAX_OUTPUT; ++i) {
                    if (tasks_output[i] != expected_output[i]) {
                        printk("\033[31mTest failed!\033[0m\n");
                        printk("\033[31m    Expected: %s\033[0m\n", expected_output);
                        printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
                        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
                    }
                }
                printk("\033[32mTest passed!\033[0m\n");
                printk("\033[32m    Output: %s\033[0m\n", expected_output);
                sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
            }
            #endif
        }
    }
}

void switch_to(struct task_struct *next) {
    // Log("Into switch_to func\n");
    if (next->pid != current->pid) {
        struct task_struct* tmp = current;
        current = next;
        __switch_to(tmp, next);
    }
    // Log("finish switch_to func\n");
}

void do_timer() {
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度

    // YOUR CODE HERE

    if (current->pid == 0 || current->counter <= 0) {
        schedule();
    } else {
        current->counter -= 1;
        if (current->counter <= 0) schedule();
        else return;
    }
}

void schedule() {
    // YOUR CODE HERE
    uint64_t all_counter_zero = 1;
    // struct pid_counter _counter[NR_TASKS];
    struct pid_counter _max_counter = {0, 0};

    for (int i = 1; i <= NR_TASKS - 1; i++) {
        // _counter[i].pid = i;
        // _counter[i].counter = task[i]->counter;
        if (task[i]->counter > _max_counter.counter) {
            _max_counter.counter = task[i]->counter;
            _max_counter.pid = task[i]->pid;
        }
        if (task[i]->counter > 0) all_counter_zero = 0;
    }
    // Log("all_count_zero = %d\n", all_counter_zero);
    
    if (all_counter_zero == 1) { // all of the counters are 0
        _max_counter.counter = 0;
        _max_counter.pid = 0;
        for (int i = 1; i <= NR_TASKS - 1; i++) {
            task[i]->counter = task[i]->priority;
            if (task[i]->counter > _max_counter.counter) {
                _max_counter.counter = task[i]->counter;
                _max_counter.pid = task[i]->pid;
            }
        }
        goto SWITCH_TO_FUNC;
    }

    goto SWITCH_TO_FUNC;

SWITCH_TO_FUNC:
    printk(BOLD REVERSED FG_COLOR(255, 135, 175) "SWITCH [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR,task[_max_counter.pid]->pid, \
                    task[_max_counter.pid]->priority, task[_max_counter.pid]->counter);
    switch_to(task[_max_counter.pid]);

}

void __bubble_sort(struct pid_counter* arr, uint64_t len) {
    uint64_t i, j;
    struct pid_counter tmp;
    for (i = 1; i <= len; i++) {
        for (j = 1; j <= len; j++) {
            if (arr[j].counter < arr[j+1].counter) {
                tmp = arr[j];
                arr[j]= arr[j+1];
                arr[j+1] = tmp;
            }
        }
    }
}

void load_program(struct task_struct *task) {
    // Log("step into load_program()");
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
    for (int i = 0; i < ehdr->e_phnum; ++i) {
        Elf64_Phdr *phdr = phdrs + i;
        if (phdr->p_type == PT_LOAD) {
            uint64_t data_addr = ((uint64_t)_sramdisk + phdr->p_offset);
            uint64_t va = phdr->p_vaddr;
            uint64_t memsz = phdr->p_memsz;
            uint64_t filesz = phdr->p_filesz;
            uint32_t flags = phdr->p_flags;

            uint64_t offset = va % PGSIZE;
            uint64_t NR_pages = (memsz+offset) / PGSIZE;
            if ((memsz+offset) % PGSIZE != 0) NR_pages++;

            // Log("data_addr = %#llx, va = %#llx, memsz = %#llx, filesz = %#llx, NR_pages = %d, offset = %#llx", data_addr, va, memsz, filesz, NR_pages, offset);
            uint64_t* pages_addr = (uint64_t*)alloc_pages(NR_pages);
            // Log("pages_addr = %#llx", pages_addr);
            // Log("content at pages_addr = %#llx", *((char*)ehdr + phdr->p_offset));
            // Log("content at pages_addr = %#llx", *(data_addr));
            memcpy((void*)((uint64_t)pages_addr + offset), (void*)data_addr, filesz);
            // Log("memcpy %#llx <- %#llx done, size = %#llx", (uint64_t)pages_addr + offset, data_addr, filesz);
            // flags : R|W|X
            uint64_t perm = 0x10 | (flags&0x1) << 3 | (flags&0x2) << 1 | (flags&0x4) >> 1 | 0x1;
            // uint64_t perm = 0b11111;
            
            create_mapping(task->pgd, va - offset, (uint64_t)pages_addr - PA2VA_OFFSET, (memsz + offset), perm);
            // Log("create_mapping done, map %#llx to %#llx, size = %#llx", va - offset, (uint64_t)pages_addr - PA2VA_OFFSET, memsz + offset);
            memset((void*)((uint64_t)pages_addr + offset + filesz), 0, memsz - filesz); // bss
            // Log("memset bss done");
            // while( 2);
        }   
    }

    task->thread.sepc = ehdr->e_entry;
}