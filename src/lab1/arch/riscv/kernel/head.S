    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    
    # ------------------
    # - your code here -
    # ------------------

    la sp, boot_stack           # set stack pointer

    # ----------------------
    # - set stvec = _traps -
    # ----------------------

    la t0, _traps;
    csrw stvec, t0 

    # ---------------------
    # - set sie[STIE] = 1 -
    # ---------------------

    add t0,x0,0x20
    csrs sie, t0 

    # ----------------------------
    # - set first time interrupt -
    # ----------------------------

    li t1, 10000000           # 10MHz
    rdtime t0
    add t0, t0, t1
    addi a0, t0, 0
    call sbi_set_timer


    # ----------------------------
    # - set sstatus[SIE] = 1 -
    # ----------------------------

    li t1, 0x2
    csrs sstatus, t1

    call start_kernel

    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096 # <-- change to your stack size

    .globl boot_stack_top
boot_stack_top: