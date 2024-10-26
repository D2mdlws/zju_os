    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    
    la sp, boot_stack           # set stack pointer

    call setup_vm
    call relocate

    call mm_init
    call setup_vm_final
    call task_init

    la t0, _traps;
    csrw stvec, t0              # set stvec = _traps 

    add t0,x0,0x20
    csrs sie, t0                # - set sie[STIE] = 1 -

    li t1, 10000000     # 10MHz
    rdtime t0
    add t0, t0, t1
    addi a0, t0, 0
    call sbi_set_timer          # - set first time interrupt -

    li t1, 0x2
    csrs sstatus, t1            # - set sstatus[SIE] = 1 -

    call start_kernel

    .set VM_START,  0xffffffe000000000
    .set PHY_START, 0x0000000080000000
    .equ PA2VA_OFFSET, VM_START - PHY_START
relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)

    li t0, PA2VA_OFFSET    # 0xffffffdf80000000
    add ra, ra, t0
    add sp, sp, t0

    # set satp with early_pgtbl

    la t0, early_pgtbl
    srli t0, t0, 12
    li t1, 0x8000000000000000
    add t0, t0, t1
    csrw satp, t0

    # flush tlb
    sfence.vma zero, zero

    # flush icache
    fence.i

    ret

    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096 # <-- change to your stack size

    .globl boot_stack_top
boot_stack_top: