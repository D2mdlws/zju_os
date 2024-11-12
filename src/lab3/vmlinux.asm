
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    
    la sp, boot_stack           # set stack pointer
ffffffe000200000:	00005117          	auipc	sp,0x5
ffffffe000200004:	00010113          	mv	sp,sp

    call setup_vm
ffffffe000200008:	3e4010ef          	jal	ffffffe0002013ec <setup_vm>
    call relocate
ffffffe00020000c:	048000ef          	jal	ffffffe000200054 <relocate>

    call mm_init
ffffffe000200010:	40c000ef          	jal	ffffffe00020041c <mm_init>
    call setup_vm_final
ffffffe000200014:	450010ef          	jal	ffffffe000201464 <setup_vm_final>
    call task_init
ffffffe000200018:	448000ef          	jal	ffffffe000200460 <task_init>

    la t0, _traps;
ffffffe00020001c:	00000297          	auipc	t0,0x0
ffffffe000200020:	07c28293          	addi	t0,t0,124 # ffffffe000200098 <_traps>
    csrw stvec, t0              # set stvec = _traps 
ffffffe000200024:	10529073          	csrw	stvec,t0

    add t0,x0,0x20
ffffffe000200028:	02000293          	li	t0,32
    csrs sie, t0                # - set sie[STIE] = 1 -
ffffffe00020002c:	1042a073          	csrs	sie,t0

    li t1, 10000000     # 10MHz
ffffffe000200030:	00989337          	lui	t1,0x989
ffffffe000200034:	6803031b          	addiw	t1,t1,1664 # 989680 <OPENSBI_SIZE+0x789680>
    rdtime t0
ffffffe000200038:	c01022f3          	rdtime	t0
    add t0, t0, t1
ffffffe00020003c:	006282b3          	add	t0,t0,t1
    addi a0, t0, 0
ffffffe000200040:	00028513          	mv	a0,t0
    call sbi_set_timer          # - set first time interrupt -
ffffffe000200044:	0e0010ef          	jal	ffffffe000201124 <sbi_set_timer>

    li t1, 0x2
ffffffe000200048:	00200313          	li	t1,2
    csrs sstatus, t1            # - set sstatus[SIE] = 1 -
ffffffe00020004c:	10032073          	csrs	sstatus,t1

    call start_kernel
ffffffe000200050:	00d010ef          	jal	ffffffe00020185c <start_kernel>

ffffffe000200054 <relocate>:
    .equ PA2VA_OFFSET, VM_START - PHY_START
relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)

    li t3, PA2VA_OFFSET    # 0xffffffdf80000000
ffffffe000200054:	fbf00e1b          	addiw	t3,zero,-65
ffffffe000200058:	01fe1e13          	slli	t3,t3,0x1f
    add ra, ra, t3
ffffffe00020005c:	01c080b3          	add	ra,ra,t3
    add sp, sp, t3
ffffffe000200060:	01c10133          	add	sp,sp,t3

    /* set stvec to label 1 */
    la t1, 1f
ffffffe000200064:	00000317          	auipc	t1,0x0
ffffffe000200068:	03030313          	addi	t1,t1,48 # ffffffe000200094 <relocate+0x40>
    add t1, t1, t3
ffffffe00020006c:	01c30333          	add	t1,t1,t3
    csrw stvec, t1
ffffffe000200070:	10531073          	csrw	stvec,t1

    # flush tlb
    sfence.vma zero, zero
ffffffe000200074:	12000073          	sfence.vma

    # set satp with early_pgtbl

    la t0, early_pgtbl
ffffffe000200078:	00007297          	auipc	t0,0x7
ffffffe00020007c:	f8828293          	addi	t0,t0,-120 # ffffffe000207000 <early_pgtbl>
    srli t0, t0, 12
ffffffe000200080:	00c2d293          	srli	t0,t0,0xc
    li t1, 0x8000000000000000
ffffffe000200084:	fff0031b          	addiw	t1,zero,-1
ffffffe000200088:	03f31313          	slli	t1,t1,0x3f
    or t0, t0, t1
ffffffe00020008c:	0062e2b3          	or	t0,t0,t1
    csrw satp, t0
ffffffe000200090:	18029073          	csrw	satp,t0

.align 2
1:
    

    ret
ffffffe000200094:	00008067          	ret

ffffffe000200098 <_traps>:
    .globl _traps 
_traps:

    # 1. save 32 registers and sepc to stack

    addi sp, sp, -33*8
ffffffe000200098:	ef810113          	addi	sp,sp,-264 # ffffffe000204ef8 <_edata+0xec7>

    sd x0, 0*8(sp)
ffffffe00020009c:	00013023          	sd	zero,0(sp)
    sd x1, 1*8(sp)
ffffffe0002000a0:	00113423          	sd	ra,8(sp)
    sd x2, 2*8(sp)
ffffffe0002000a4:	00213823          	sd	sp,16(sp)
    sd x3, 3*8(sp)
ffffffe0002000a8:	00313c23          	sd	gp,24(sp)
    sd x4, 4*8(sp)
ffffffe0002000ac:	02413023          	sd	tp,32(sp)
    sd x5, 5*8(sp)
ffffffe0002000b0:	02513423          	sd	t0,40(sp)
    sd x6, 6*8(sp)
ffffffe0002000b4:	02613823          	sd	t1,48(sp)
    sd x7, 7*8(sp)
ffffffe0002000b8:	02713c23          	sd	t2,56(sp)
    sd x8, 8*8(sp)
ffffffe0002000bc:	04813023          	sd	s0,64(sp)
    sd x9, 9*8(sp)
ffffffe0002000c0:	04913423          	sd	s1,72(sp)
    sd x10, 10*8(sp)
ffffffe0002000c4:	04a13823          	sd	a0,80(sp)
    sd x11, 11*8(sp)
ffffffe0002000c8:	04b13c23          	sd	a1,88(sp)
    sd x12, 12*8(sp)
ffffffe0002000cc:	06c13023          	sd	a2,96(sp)
    sd x13, 13*8(sp)
ffffffe0002000d0:	06d13423          	sd	a3,104(sp)
    sd x14, 14*8(sp)
ffffffe0002000d4:	06e13823          	sd	a4,112(sp)
    sd x15, 15*8(sp)
ffffffe0002000d8:	06f13c23          	sd	a5,120(sp)
    sd x16, 16*8(sp)
ffffffe0002000dc:	09013023          	sd	a6,128(sp)
    sd x17, 17*8(sp)
ffffffe0002000e0:	09113423          	sd	a7,136(sp)
    sd x18, 18*8(sp)
ffffffe0002000e4:	09213823          	sd	s2,144(sp)
    sd x19, 19*8(sp)
ffffffe0002000e8:	09313c23          	sd	s3,152(sp)
    sd x20, 20*8(sp)
ffffffe0002000ec:	0b413023          	sd	s4,160(sp)
    sd x21, 21*8(sp)
ffffffe0002000f0:	0b513423          	sd	s5,168(sp)
    sd x22, 22*8(sp)
ffffffe0002000f4:	0b613823          	sd	s6,176(sp)
    sd x23, 23*8(sp)
ffffffe0002000f8:	0b713c23          	sd	s7,184(sp)
    sd x24, 24*8(sp)
ffffffe0002000fc:	0d813023          	sd	s8,192(sp)
    sd x25, 25*8(sp)
ffffffe000200100:	0d913423          	sd	s9,200(sp)
    sd x26, 26*8(sp)
ffffffe000200104:	0da13823          	sd	s10,208(sp)
    sd x27, 27*8(sp)
ffffffe000200108:	0db13c23          	sd	s11,216(sp)
    sd x28, 28*8(sp)
ffffffe00020010c:	0fc13023          	sd	t3,224(sp)
    sd x29, 29*8(sp)
ffffffe000200110:	0fd13423          	sd	t4,232(sp)
    sd x30, 30*8(sp)
ffffffe000200114:	0fe13823          	sd	t5,240(sp)
    sd x31, 31*8(sp)
ffffffe000200118:	0ff13c23          	sd	t6,248(sp)

    csrr t0, sepc
ffffffe00020011c:	141022f3          	csrr	t0,sepc
    sd t0, 32*8(sp)
ffffffe000200120:	10513023          	sd	t0,256(sp)

    # 2. call trap_handler

    csrr t1, scause
ffffffe000200124:	14202373          	csrr	t1,scause
    mv a0, t1
ffffffe000200128:	00030513          	mv	a0,t1
    mv a1, t0
ffffffe00020012c:	00028593          	mv	a1,t0
    call trap_handler
ffffffe000200130:	1a8010ef          	jal	ffffffe0002012d8 <trap_handler>

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack

    ld x0, 0*8(sp)
ffffffe000200134:	00013003          	ld	zero,0(sp)
    ld x1, 1*8(sp)
ffffffe000200138:	00813083          	ld	ra,8(sp)
    ld x3, 3*8(sp)
ffffffe00020013c:	01813183          	ld	gp,24(sp)
    ld x4, 4*8(sp)
ffffffe000200140:	02013203          	ld	tp,32(sp)
    ld x5, 5*8(sp)
ffffffe000200144:	02813283          	ld	t0,40(sp)
    ld x6, 6*8(sp)
ffffffe000200148:	03013303          	ld	t1,48(sp)
    ld x7, 7*8(sp)
ffffffe00020014c:	03813383          	ld	t2,56(sp)
    ld x8, 8*8(sp)
ffffffe000200150:	04013403          	ld	s0,64(sp)
    ld x9, 9*8(sp)
ffffffe000200154:	04813483          	ld	s1,72(sp)
    ld x10, 10*8(sp)
ffffffe000200158:	05013503          	ld	a0,80(sp)
    ld x11, 11*8(sp)
ffffffe00020015c:	05813583          	ld	a1,88(sp)
    ld x12, 12*8(sp)
ffffffe000200160:	06013603          	ld	a2,96(sp)
    ld x13, 13*8(sp)
ffffffe000200164:	06813683          	ld	a3,104(sp)
    ld x14, 14*8(sp)
ffffffe000200168:	07013703          	ld	a4,112(sp)
    ld x15, 15*8(sp)
ffffffe00020016c:	07813783          	ld	a5,120(sp)
    ld x16, 16*8(sp)
ffffffe000200170:	08013803          	ld	a6,128(sp)
    ld x17, 17*8(sp)
ffffffe000200174:	08813883          	ld	a7,136(sp)
    ld x18, 18*8(sp)
ffffffe000200178:	09013903          	ld	s2,144(sp)
    ld x19, 19*8(sp)
ffffffe00020017c:	09813983          	ld	s3,152(sp)
    ld x20, 20*8(sp)
ffffffe000200180:	0a013a03          	ld	s4,160(sp)
    ld x21, 21*8(sp)
ffffffe000200184:	0a813a83          	ld	s5,168(sp)
    ld x22, 22*8(sp)
ffffffe000200188:	0b013b03          	ld	s6,176(sp)
    ld x23, 23*8(sp)
ffffffe00020018c:	0b813b83          	ld	s7,184(sp)
    ld x24, 24*8(sp)    
ffffffe000200190:	0c013c03          	ld	s8,192(sp)
    ld x25, 25*8(sp)
ffffffe000200194:	0c813c83          	ld	s9,200(sp)
    ld x26, 26*8(sp)
ffffffe000200198:	0d013d03          	ld	s10,208(sp)
    ld x27, 27*8(sp)
ffffffe00020019c:	0d813d83          	ld	s11,216(sp)
    ld x28, 28*8(sp)
ffffffe0002001a0:	0e013e03          	ld	t3,224(sp)
    ld x29, 29*8(sp)
ffffffe0002001a4:	0e813e83          	ld	t4,232(sp)
    ld x30, 30*8(sp)
ffffffe0002001a8:	0f013f03          	ld	t5,240(sp)
    ld x31, 31*8(sp)
ffffffe0002001ac:	0f813f83          	ld	t6,248(sp)
    ld t0, 32*8(sp)
ffffffe0002001b0:	10013283          	ld	t0,256(sp)
    csrw sepc, t0
ffffffe0002001b4:	14129073          	csrw	sepc,t0
    ld x2, 2*8(sp)
ffffffe0002001b8:	01013103          	ld	sp,16(sp)

    addi sp, sp, 33*8
ffffffe0002001bc:	10810113          	addi	sp,sp,264

    # 4. return from trap

    sret
ffffffe0002001c0:	10200073          	sret

ffffffe0002001c4 <__dummy>:

    .extern dummy
    .globl __dummy
__dummy:

    la t0, dummy
ffffffe0002001c4:	00000297          	auipc	t0,0x0
ffffffe0002001c8:	50028293          	addi	t0,t0,1280 # ffffffe0002006c4 <dummy>
    csrw sepc, t0       # set sepc to dummy
ffffffe0002001cc:	14129073          	csrw	sepc,t0
    sret
ffffffe0002001d0:	10200073          	sret

ffffffe0002001d4 <__switch_to>:
    .globl __switch_to
__switch_to:
    # save state to prev process
    # YOUR CODE HERE

    addi a0, a0, 4*8            # let a0 point to process_struct
ffffffe0002001d4:	02050513          	addi	a0,a0,32

    sd ra, 0*8(a0)
ffffffe0002001d8:	00153023          	sd	ra,0(a0)
    sd sp, 1*8(a0)
ffffffe0002001dc:	00253423          	sd	sp,8(a0)
    sd s0, 2*8(a0)
ffffffe0002001e0:	00853823          	sd	s0,16(a0)
    sd s1, 3*8(a0)
ffffffe0002001e4:	00953c23          	sd	s1,24(a0)
    sd s2, 4*8(a0)
ffffffe0002001e8:	03253023          	sd	s2,32(a0)
    sd s3, 5*8(a0)
ffffffe0002001ec:	03353423          	sd	s3,40(a0)
    sd s4, 6*8(a0)
ffffffe0002001f0:	03453823          	sd	s4,48(a0)
    sd s5, 7*8(a0)
ffffffe0002001f4:	03553c23          	sd	s5,56(a0)
    sd s6, 8*8(a0)
ffffffe0002001f8:	05653023          	sd	s6,64(a0)
    sd s7, 9*8(a0)
ffffffe0002001fc:	05753423          	sd	s7,72(a0)
    sd s8, 10*8(a0)
ffffffe000200200:	05853823          	sd	s8,80(a0)
    sd s9, 11*8(a0)
ffffffe000200204:	05953c23          	sd	s9,88(a0)
    sd s10, 12*8(a0)
ffffffe000200208:	07a53023          	sd	s10,96(a0)
    sd s11, 13*8(a0)
ffffffe00020020c:	07b53423          	sd	s11,104(a0)


    # restore state from next process
    # YOUR CODE HERE

    addi a1, a1, 4*8            # let a1 point to process_struct
ffffffe000200210:	02058593          	addi	a1,a1,32

    ld ra, 0*8(a1)
ffffffe000200214:	0005b083          	ld	ra,0(a1)
    ld sp,  1*8(a1)
ffffffe000200218:	0085b103          	ld	sp,8(a1)

    addi a1, a1, 2*8            # let a1 point to process_struct->s
ffffffe00020021c:	01058593          	addi	a1,a1,16

    ld s0, 0*8(a1)
ffffffe000200220:	0005b403          	ld	s0,0(a1)
    ld s1, 1*8(a1)
ffffffe000200224:	0085b483          	ld	s1,8(a1)
    ld s2, 2*8(a1)
ffffffe000200228:	0105b903          	ld	s2,16(a1)
    ld s3, 3*8(a1)
ffffffe00020022c:	0185b983          	ld	s3,24(a1)
    ld s4, 4*8(a1)
ffffffe000200230:	0205ba03          	ld	s4,32(a1)
    ld s5, 5*8(a1)
ffffffe000200234:	0285ba83          	ld	s5,40(a1)
    ld s6, 6*8(a1)
ffffffe000200238:	0305bb03          	ld	s6,48(a1)
    ld s7, 7*8(a1)
ffffffe00020023c:	0385bb83          	ld	s7,56(a1)
    ld s8, 8*8(a1)
ffffffe000200240:	0405bc03          	ld	s8,64(a1)
    ld s9, 9*8(a1)
ffffffe000200244:	0485bc83          	ld	s9,72(a1)
    ld s10, 10*8(a1)
ffffffe000200248:	0505bd03          	ld	s10,80(a1)
    ld s11, 11*8(a1)
ffffffe00020024c:	0585bd83          	ld	s11,88(a1)

ffffffe000200250:	00008067          	ret

ffffffe000200254 <get_cycles>:
#include "clock.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
ffffffe000200254:	fe010113          	addi	sp,sp,-32
ffffffe000200258:	00813c23          	sd	s0,24(sp)
ffffffe00020025c:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    uint64_t time;
    __asm__ volatile(
ffffffe000200260:	c01027f3          	rdtime	a5
ffffffe000200264:	fef43423          	sd	a5,-24(s0)
        "rdtime %[time]"
        : [time] "=r" (time)
    );
    return time;
ffffffe000200268:	fe843783          	ld	a5,-24(s0)
}
ffffffe00020026c:	00078513          	mv	a0,a5
ffffffe000200270:	01813403          	ld	s0,24(sp)
ffffffe000200274:	02010113          	addi	sp,sp,32
ffffffe000200278:	00008067          	ret

ffffffe00020027c <clock_set_next_event>:

void clock_set_next_event() {
ffffffe00020027c:	fe010113          	addi	sp,sp,-32
ffffffe000200280:	00113c23          	sd	ra,24(sp)
ffffffe000200284:	00813823          	sd	s0,16(sp)
ffffffe000200288:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
ffffffe00020028c:	fc9ff0ef          	jal	ffffffe000200254 <get_cycles>
ffffffe000200290:	00050713          	mv	a4,a0
ffffffe000200294:	00004797          	auipc	a5,0x4
ffffffe000200298:	d6c78793          	addi	a5,a5,-660 # ffffffe000204000 <TIMECLOCK>
ffffffe00020029c:	0007b783          	ld	a5,0(a5)
ffffffe0002002a0:	00f707b3          	add	a5,a4,a5
ffffffe0002002a4:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
ffffffe0002002a8:	fe843503          	ld	a0,-24(s0)
ffffffe0002002ac:	679000ef          	jal	ffffffe000201124 <sbi_set_timer>
ffffffe0002002b0:	00000013          	nop
ffffffe0002002b4:	01813083          	ld	ra,24(sp)
ffffffe0002002b8:	01013403          	ld	s0,16(sp)
ffffffe0002002bc:	02010113          	addi	sp,sp,32
ffffffe0002002c0:	00008067          	ret

ffffffe0002002c4 <kalloc>:

struct {
    struct run *freelist;
} kmem;

void *kalloc() {
ffffffe0002002c4:	fe010113          	addi	sp,sp,-32
ffffffe0002002c8:	00113c23          	sd	ra,24(sp)
ffffffe0002002cc:	00813823          	sd	s0,16(sp)
ffffffe0002002d0:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
ffffffe0002002d4:	00006797          	auipc	a5,0x6
ffffffe0002002d8:	d2c78793          	addi	a5,a5,-724 # ffffffe000206000 <kmem>
ffffffe0002002dc:	0007b783          	ld	a5,0(a5)
ffffffe0002002e0:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
ffffffe0002002e4:	fe843783          	ld	a5,-24(s0)
ffffffe0002002e8:	0007b703          	ld	a4,0(a5)
ffffffe0002002ec:	00006797          	auipc	a5,0x6
ffffffe0002002f0:	d1478793          	addi	a5,a5,-748 # ffffffe000206000 <kmem>
ffffffe0002002f4:	00e7b023          	sd	a4,0(a5)
    
    memset((void *)r, 0x0, PGSIZE);
ffffffe0002002f8:	00001637          	lui	a2,0x1
ffffffe0002002fc:	00000593          	li	a1,0
ffffffe000200300:	fe843503          	ld	a0,-24(s0)
ffffffe000200304:	59c020ef          	jal	ffffffe0002028a0 <memset>
    return (void *)r;
ffffffe000200308:	fe843783          	ld	a5,-24(s0)
}
ffffffe00020030c:	00078513          	mv	a0,a5
ffffffe000200310:	01813083          	ld	ra,24(sp)
ffffffe000200314:	01013403          	ld	s0,16(sp)
ffffffe000200318:	02010113          	addi	sp,sp,32
ffffffe00020031c:	00008067          	ret

ffffffe000200320 <kfree>:

void kfree(void *addr) {
ffffffe000200320:	fd010113          	addi	sp,sp,-48
ffffffe000200324:	02113423          	sd	ra,40(sp)
ffffffe000200328:	02813023          	sd	s0,32(sp)
ffffffe00020032c:	03010413          	addi	s0,sp,48
ffffffe000200330:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    *(uintptr_t *)&addr = (uintptr_t)addr & ~(PGSIZE - 1);
ffffffe000200334:	fd843783          	ld	a5,-40(s0)
ffffffe000200338:	00078693          	mv	a3,a5
ffffffe00020033c:	fd840793          	addi	a5,s0,-40
ffffffe000200340:	fffff737          	lui	a4,0xfffff
ffffffe000200344:	00e6f733          	and	a4,a3,a4
ffffffe000200348:	00e7b023          	sd	a4,0(a5)

    memset(addr, 0x0, (uint64_t)PGSIZE);
ffffffe00020034c:	fd843783          	ld	a5,-40(s0)
ffffffe000200350:	00001637          	lui	a2,0x1
ffffffe000200354:	00000593          	li	a1,0
ffffffe000200358:	00078513          	mv	a0,a5
ffffffe00020035c:	544020ef          	jal	ffffffe0002028a0 <memset>

    r = (struct run *)addr;
ffffffe000200360:	fd843783          	ld	a5,-40(s0)
ffffffe000200364:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
ffffffe000200368:	00006797          	auipc	a5,0x6
ffffffe00020036c:	c9878793          	addi	a5,a5,-872 # ffffffe000206000 <kmem>
ffffffe000200370:	0007b703          	ld	a4,0(a5)
ffffffe000200374:	fe843783          	ld	a5,-24(s0)
ffffffe000200378:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
ffffffe00020037c:	00006797          	auipc	a5,0x6
ffffffe000200380:	c8478793          	addi	a5,a5,-892 # ffffffe000206000 <kmem>
ffffffe000200384:	fe843703          	ld	a4,-24(s0)
ffffffe000200388:	00e7b023          	sd	a4,0(a5)

    return;
ffffffe00020038c:	00000013          	nop
}
ffffffe000200390:	02813083          	ld	ra,40(sp)
ffffffe000200394:	02013403          	ld	s0,32(sp)
ffffffe000200398:	03010113          	addi	sp,sp,48
ffffffe00020039c:	00008067          	ret

ffffffe0002003a0 <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe0002003a0:	fd010113          	addi	sp,sp,-48
ffffffe0002003a4:	02113423          	sd	ra,40(sp)
ffffffe0002003a8:	02813023          	sd	s0,32(sp)
ffffffe0002003ac:	03010413          	addi	s0,sp,48
ffffffe0002003b0:	fca43c23          	sd	a0,-40(s0)
ffffffe0002003b4:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe0002003b8:	fd843703          	ld	a4,-40(s0)
ffffffe0002003bc:	000017b7          	lui	a5,0x1
ffffffe0002003c0:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe0002003c4:	00f70733          	add	a4,a4,a5
ffffffe0002003c8:	fffff7b7          	lui	a5,0xfffff
ffffffe0002003cc:	00f777b3          	and	a5,a4,a5
ffffffe0002003d0:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe0002003d4:	01c0006f          	j	ffffffe0002003f0 <kfreerange+0x50>
        kfree((void *)addr);
ffffffe0002003d8:	fe843503          	ld	a0,-24(s0)
ffffffe0002003dc:	f45ff0ef          	jal	ffffffe000200320 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe0002003e0:	fe843703          	ld	a4,-24(s0)
ffffffe0002003e4:	000017b7          	lui	a5,0x1
ffffffe0002003e8:	00f707b3          	add	a5,a4,a5
ffffffe0002003ec:	fef43423          	sd	a5,-24(s0)
ffffffe0002003f0:	fe843703          	ld	a4,-24(s0)
ffffffe0002003f4:	000017b7          	lui	a5,0x1
ffffffe0002003f8:	00f70733          	add	a4,a4,a5
ffffffe0002003fc:	fd043783          	ld	a5,-48(s0)
ffffffe000200400:	fce7fce3          	bgeu	a5,a4,ffffffe0002003d8 <kfreerange+0x38>
    }
}
ffffffe000200404:	00000013          	nop
ffffffe000200408:	00000013          	nop
ffffffe00020040c:	02813083          	ld	ra,40(sp)
ffffffe000200410:	02013403          	ld	s0,32(sp)
ffffffe000200414:	03010113          	addi	sp,sp,48
ffffffe000200418:	00008067          	ret

ffffffe00020041c <mm_init>:

void mm_init(void) {
ffffffe00020041c:	ff010113          	addi	sp,sp,-16
ffffffe000200420:	00113423          	sd	ra,8(sp)
ffffffe000200424:	00813023          	sd	s0,0(sp)
ffffffe000200428:	01010413          	addi	s0,sp,16
    kfreerange(_ekernel, (char *)PHY_END + PA2VA_OFFSET);
ffffffe00020042c:	c0100793          	li	a5,-1023
ffffffe000200430:	01b79593          	slli	a1,a5,0x1b
ffffffe000200434:	00009517          	auipc	a0,0x9
ffffffe000200438:	bcc50513          	addi	a0,a0,-1076 # ffffffe000209000 <_ebss>
ffffffe00020043c:	f65ff0ef          	jal	ffffffe0002003a0 <kfreerange>
    printk(BOLD FG_COLOR(255, 95, 00) "...mm_init done!\n" CLEAR);
ffffffe000200440:	00003517          	auipc	a0,0x3
ffffffe000200444:	bc050513          	addi	a0,a0,-1088 # ffffffe000203000 <_srodata>
ffffffe000200448:	338020ef          	jal	ffffffe000202780 <printk>
}
ffffffe00020044c:	00000013          	nop
ffffffe000200450:	00813083          	ld	ra,8(sp)
ffffffe000200454:	00013403          	ld	s0,0(sp)
ffffffe000200458:	01010113          	addi	sp,sp,16
ffffffe00020045c:	00008067          	ret

ffffffe000200460 <task_init>:

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此, the type in the array is pointer to task_struct

void task_init() {
ffffffe000200460:	fe010113          	addi	sp,sp,-32
ffffffe000200464:	00113c23          	sd	ra,24(sp)
ffffffe000200468:	00813823          	sd	s0,16(sp)
ffffffe00020046c:	02010413          	addi	s0,sp,32
    srand(2024);
ffffffe000200470:	7e800513          	li	a0,2024
ffffffe000200474:	38c020ef          	jal	ffffffe000202800 <srand>
    // 2. 设置 state 为 TASK_RUNNING;
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    // 4. 设置 idle 的 pid 为 0
    // 5. 将 current 和 task[0] 指向 idle

    idle = (struct task_struct *)kalloc();
ffffffe000200478:	e4dff0ef          	jal	ffffffe0002002c4 <kalloc>
ffffffe00020047c:	00050713          	mv	a4,a0
ffffffe000200480:	00006797          	auipc	a5,0x6
ffffffe000200484:	b8878793          	addi	a5,a5,-1144 # ffffffe000206008 <idle>
ffffffe000200488:	00e7b023          	sd	a4,0(a5)

    idle->state = TASK_RUNNING;
ffffffe00020048c:	00006797          	auipc	a5,0x6
ffffffe000200490:	b7c78793          	addi	a5,a5,-1156 # ffffffe000206008 <idle>
ffffffe000200494:	0007b783          	ld	a5,0(a5)
ffffffe000200498:	0007b023          	sd	zero,0(a5)

    idle->counter = 0;
ffffffe00020049c:	00006797          	auipc	a5,0x6
ffffffe0002004a0:	b6c78793          	addi	a5,a5,-1172 # ffffffe000206008 <idle>
ffffffe0002004a4:	0007b783          	ld	a5,0(a5)
ffffffe0002004a8:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
ffffffe0002004ac:	00006797          	auipc	a5,0x6
ffffffe0002004b0:	b5c78793          	addi	a5,a5,-1188 # ffffffe000206008 <idle>
ffffffe0002004b4:	0007b783          	ld	a5,0(a5)
ffffffe0002004b8:	0007b823          	sd	zero,16(a5)

    idle->pid = 0;
ffffffe0002004bc:	00006797          	auipc	a5,0x6
ffffffe0002004c0:	b4c78793          	addi	a5,a5,-1204 # ffffffe000206008 <idle>
ffffffe0002004c4:	0007b783          	ld	a5,0(a5)
ffffffe0002004c8:	0007bc23          	sd	zero,24(a5)

    current = idle;
ffffffe0002004cc:	00006797          	auipc	a5,0x6
ffffffe0002004d0:	b3c78793          	addi	a5,a5,-1220 # ffffffe000206008 <idle>
ffffffe0002004d4:	0007b703          	ld	a4,0(a5)
ffffffe0002004d8:	00006797          	auipc	a5,0x6
ffffffe0002004dc:	b3878793          	addi	a5,a5,-1224 # ffffffe000206010 <current>
ffffffe0002004e0:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe0002004e4:	00006797          	auipc	a5,0x6
ffffffe0002004e8:	b2478793          	addi	a5,a5,-1244 # ffffffe000206008 <idle>
ffffffe0002004ec:	0007b703          	ld	a4,0(a5)
ffffffe0002004f0:	00006797          	auipc	a5,0x6
ffffffe0002004f4:	b3878793          	addi	a5,a5,-1224 # ffffffe000206028 <task>
ffffffe0002004f8:	00e7b023          	sd	a4,0(a5)
    //     - ra 设置为 __dummy（见 4.3.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    /* YOUR CODE HERE */

    for (int i = 1; i <= NR_TASKS - 1; i++) {
ffffffe0002004fc:	00100793          	li	a5,1
ffffffe000200500:	fef42623          	sw	a5,-20(s0)
ffffffe000200504:	1900006f          	j	ffffffe000200694 <task_init+0x234>
        task[i] = (struct task_struct *)kalloc();
ffffffe000200508:	dbdff0ef          	jal	ffffffe0002002c4 <kalloc>
ffffffe00020050c:	00050693          	mv	a3,a0
ffffffe000200510:	00006717          	auipc	a4,0x6
ffffffe000200514:	b1870713          	addi	a4,a4,-1256 # ffffffe000206028 <task>
ffffffe000200518:	fec42783          	lw	a5,-20(s0)
ffffffe00020051c:	00379793          	slli	a5,a5,0x3
ffffffe000200520:	00f707b3          	add	a5,a4,a5
ffffffe000200524:	00d7b023          	sd	a3,0(a5)

        task[i]->state = TASK_RUNNING;
ffffffe000200528:	00006717          	auipc	a4,0x6
ffffffe00020052c:	b0070713          	addi	a4,a4,-1280 # ffffffe000206028 <task>
ffffffe000200530:	fec42783          	lw	a5,-20(s0)
ffffffe000200534:	00379793          	slli	a5,a5,0x3
ffffffe000200538:	00f707b3          	add	a5,a4,a5
ffffffe00020053c:	0007b783          	ld	a5,0(a5)
ffffffe000200540:	0007b023          	sd	zero,0(a5)
        task[i]->counter = 0;
ffffffe000200544:	00006717          	auipc	a4,0x6
ffffffe000200548:	ae470713          	addi	a4,a4,-1308 # ffffffe000206028 <task>
ffffffe00020054c:	fec42783          	lw	a5,-20(s0)
ffffffe000200550:	00379793          	slli	a5,a5,0x3
ffffffe000200554:	00f707b3          	add	a5,a4,a5
ffffffe000200558:	0007b783          	ld	a5,0(a5)
ffffffe00020055c:	0007b423          	sd	zero,8(a5)
        task[i]->priority = (rand() % (PRIORITY_MAX - PRIORITY_MIN + 1)) + PRIORITY_MIN;
ffffffe000200560:	2e4020ef          	jal	ffffffe000202844 <rand>
ffffffe000200564:	00050793          	mv	a5,a0
ffffffe000200568:	00078713          	mv	a4,a5
ffffffe00020056c:	00a00793          	li	a5,10
ffffffe000200570:	02f767bb          	remw	a5,a4,a5
ffffffe000200574:	0007879b          	sext.w	a5,a5
ffffffe000200578:	0017879b          	addiw	a5,a5,1
ffffffe00020057c:	0007869b          	sext.w	a3,a5
ffffffe000200580:	00006717          	auipc	a4,0x6
ffffffe000200584:	aa870713          	addi	a4,a4,-1368 # ffffffe000206028 <task>
ffffffe000200588:	fec42783          	lw	a5,-20(s0)
ffffffe00020058c:	00379793          	slli	a5,a5,0x3
ffffffe000200590:	00f707b3          	add	a5,a4,a5
ffffffe000200594:	0007b783          	ld	a5,0(a5)
ffffffe000200598:	00068713          	mv	a4,a3
ffffffe00020059c:	00e7b823          	sd	a4,16(a5)
        task[i]->pid = i;
ffffffe0002005a0:	00006717          	auipc	a4,0x6
ffffffe0002005a4:	a8870713          	addi	a4,a4,-1400 # ffffffe000206028 <task>
ffffffe0002005a8:	fec42783          	lw	a5,-20(s0)
ffffffe0002005ac:	00379793          	slli	a5,a5,0x3
ffffffe0002005b0:	00f707b3          	add	a5,a4,a5
ffffffe0002005b4:	0007b783          	ld	a5,0(a5)
ffffffe0002005b8:	fec42703          	lw	a4,-20(s0)
ffffffe0002005bc:	00e7bc23          	sd	a4,24(a5)

        /* set thread_struct */
        task[i]->thread.ra = (uint64_t)__dummy;
ffffffe0002005c0:	00006717          	auipc	a4,0x6
ffffffe0002005c4:	a6870713          	addi	a4,a4,-1432 # ffffffe000206028 <task>
ffffffe0002005c8:	fec42783          	lw	a5,-20(s0)
ffffffe0002005cc:	00379793          	slli	a5,a5,0x3
ffffffe0002005d0:	00f707b3          	add	a5,a4,a5
ffffffe0002005d4:	0007b783          	ld	a5,0(a5)
ffffffe0002005d8:	00000717          	auipc	a4,0x0
ffffffe0002005dc:	bec70713          	addi	a4,a4,-1044 # ffffffe0002001c4 <__dummy>
ffffffe0002005e0:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp = (uint64_t)task[i] + PGSIZE;
ffffffe0002005e4:	00006717          	auipc	a4,0x6
ffffffe0002005e8:	a4470713          	addi	a4,a4,-1468 # ffffffe000206028 <task>
ffffffe0002005ec:	fec42783          	lw	a5,-20(s0)
ffffffe0002005f0:	00379793          	slli	a5,a5,0x3
ffffffe0002005f4:	00f707b3          	add	a5,a4,a5
ffffffe0002005f8:	0007b783          	ld	a5,0(a5)
ffffffe0002005fc:	00078693          	mv	a3,a5
ffffffe000200600:	00006717          	auipc	a4,0x6
ffffffe000200604:	a2870713          	addi	a4,a4,-1496 # ffffffe000206028 <task>
ffffffe000200608:	fec42783          	lw	a5,-20(s0)
ffffffe00020060c:	00379793          	slli	a5,a5,0x3
ffffffe000200610:	00f707b3          	add	a5,a4,a5
ffffffe000200614:	0007b783          	ld	a5,0(a5)
ffffffe000200618:	00001737          	lui	a4,0x1
ffffffe00020061c:	00e68733          	add	a4,a3,a4
ffffffe000200620:	02e7b423          	sd	a4,40(a5)
        printk(FG_COLOR(215,135, 255) "SET [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR, task[i]->pid, task[i]->priority, task[i]->counter);
ffffffe000200624:	00006717          	auipc	a4,0x6
ffffffe000200628:	a0470713          	addi	a4,a4,-1532 # ffffffe000206028 <task>
ffffffe00020062c:	fec42783          	lw	a5,-20(s0)
ffffffe000200630:	00379793          	slli	a5,a5,0x3
ffffffe000200634:	00f707b3          	add	a5,a4,a5
ffffffe000200638:	0007b783          	ld	a5,0(a5)
ffffffe00020063c:	0187b583          	ld	a1,24(a5)
ffffffe000200640:	00006717          	auipc	a4,0x6
ffffffe000200644:	9e870713          	addi	a4,a4,-1560 # ffffffe000206028 <task>
ffffffe000200648:	fec42783          	lw	a5,-20(s0)
ffffffe00020064c:	00379793          	slli	a5,a5,0x3
ffffffe000200650:	00f707b3          	add	a5,a4,a5
ffffffe000200654:	0007b783          	ld	a5,0(a5)
ffffffe000200658:	0107b603          	ld	a2,16(a5)
ffffffe00020065c:	00006717          	auipc	a4,0x6
ffffffe000200660:	9cc70713          	addi	a4,a4,-1588 # ffffffe000206028 <task>
ffffffe000200664:	fec42783          	lw	a5,-20(s0)
ffffffe000200668:	00379793          	slli	a5,a5,0x3
ffffffe00020066c:	00f707b3          	add	a5,a4,a5
ffffffe000200670:	0007b783          	ld	a5,0(a5)
ffffffe000200674:	0087b783          	ld	a5,8(a5)
ffffffe000200678:	00078693          	mv	a3,a5
ffffffe00020067c:	00003517          	auipc	a0,0x3
ffffffe000200680:	9b450513          	addi	a0,a0,-1612 # ffffffe000203030 <_srodata+0x30>
ffffffe000200684:	0fc020ef          	jal	ffffffe000202780 <printk>
    for (int i = 1; i <= NR_TASKS - 1; i++) {
ffffffe000200688:	fec42783          	lw	a5,-20(s0)
ffffffe00020068c:	0017879b          	addiw	a5,a5,1
ffffffe000200690:	fef42623          	sw	a5,-20(s0)
ffffffe000200694:	fec42783          	lw	a5,-20(s0)
ffffffe000200698:	0007871b          	sext.w	a4,a5
ffffffe00020069c:	00400793          	li	a5,4
ffffffe0002006a0:	e6e7d4e3          	bge	a5,a4,ffffffe000200508 <task_init+0xa8>

    }

    printk(BOLD FG_COLOR(215, 135, 215) "...task_init done!\n" CLEAR);
ffffffe0002006a4:	00003517          	auipc	a0,0x3
ffffffe0002006a8:	9d450513          	addi	a0,a0,-1580 # ffffffe000203078 <_srodata+0x78>
ffffffe0002006ac:	0d4020ef          	jal	ffffffe000202780 <printk>
}
ffffffe0002006b0:	00000013          	nop
ffffffe0002006b4:	01813083          	ld	ra,24(sp)
ffffffe0002006b8:	01013403          	ld	s0,16(sp)
ffffffe0002006bc:	02010113          	addi	sp,sp,32
ffffffe0002006c0:	00008067          	ret

ffffffe0002006c4 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
ffffffe0002006c4:	fa010113          	addi	sp,sp,-96
ffffffe0002006c8:	04113c23          	sd	ra,88(sp)
ffffffe0002006cc:	04813823          	sd	s0,80(sp)
ffffffe0002006d0:	06010413          	addi	s0,sp,96
    // Log("step into dummy(), current pid = %d, current counter = %d", current->pid, current->counter);
    const char* colors[] = {COLOR1, COLOR2, COLOR3, COLOR4, COLOR5, COLOR6};
ffffffe0002006d4:	00003797          	auipc	a5,0x3
ffffffe0002006d8:	d3478793          	addi	a5,a5,-716 # ffffffe000203408 <_srodata+0x408>
ffffffe0002006dc:	0007b503          	ld	a0,0(a5)
ffffffe0002006e0:	0087b583          	ld	a1,8(a5)
ffffffe0002006e4:	0107b603          	ld	a2,16(a5)
ffffffe0002006e8:	0187b683          	ld	a3,24(a5)
ffffffe0002006ec:	0207b703          	ld	a4,32(a5)
ffffffe0002006f0:	0287b783          	ld	a5,40(a5)
ffffffe0002006f4:	faa43023          	sd	a0,-96(s0)
ffffffe0002006f8:	fab43423          	sd	a1,-88(s0)
ffffffe0002006fc:	fac43823          	sd	a2,-80(s0)
ffffffe000200700:	fad43c23          	sd	a3,-72(s0)
ffffffe000200704:	fce43023          	sd	a4,-64(s0)
ffffffe000200708:	fcf43423          	sd	a5,-56(s0)
    uint64_t MOD = 1000000007;
ffffffe00020070c:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe000200710:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe000200714:	fcf43823          	sd	a5,-48(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe000200718:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
ffffffe00020071c:	fff00793          	li	a5,-1
ffffffe000200720:	fef42223          	sw	a5,-28(s0)
    int x = 1, flag = 0;
ffffffe000200724:	00100793          	li	a5,1
ffffffe000200728:	fef42023          	sw	a5,-32(s0)
ffffffe00020072c:	fc042e23          	sw	zero,-36(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000200730:	fe442783          	lw	a5,-28(s0)
ffffffe000200734:	0007871b          	sext.w	a4,a5
ffffffe000200738:	fff00793          	li	a5,-1
ffffffe00020073c:	00f70e63          	beq	a4,a5,ffffffe000200758 <dummy+0x94>
ffffffe000200740:	00006797          	auipc	a5,0x6
ffffffe000200744:	8d078793          	addi	a5,a5,-1840 # ffffffe000206010 <current>
ffffffe000200748:	0007b783          	ld	a5,0(a5)
ffffffe00020074c:	0087b703          	ld	a4,8(a5)
ffffffe000200750:	fe442783          	lw	a5,-28(s0)
ffffffe000200754:	fcf70ee3          	beq	a4,a5,ffffffe000200730 <dummy+0x6c>
ffffffe000200758:	00006797          	auipc	a5,0x6
ffffffe00020075c:	8b878793          	addi	a5,a5,-1864 # ffffffe000206010 <current>
ffffffe000200760:	0007b783          	ld	a5,0(a5)
ffffffe000200764:	0087b783          	ld	a5,8(a5)
ffffffe000200768:	fc0784e3          	beqz	a5,ffffffe000200730 <dummy+0x6c>
            if (current->counter == 1) {
ffffffe00020076c:	00006797          	auipc	a5,0x6
ffffffe000200770:	8a478793          	addi	a5,a5,-1884 # ffffffe000206010 <current>
ffffffe000200774:	0007b783          	ld	a5,0(a5)
ffffffe000200778:	0087b703          	ld	a4,8(a5)
ffffffe00020077c:	00100793          	li	a5,1
ffffffe000200780:	00f71e63          	bne	a4,a5,ffffffe00020079c <dummy+0xd8>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
ffffffe000200784:	00006797          	auipc	a5,0x6
ffffffe000200788:	88c78793          	addi	a5,a5,-1908 # ffffffe000206010 <current>
ffffffe00020078c:	0007b783          	ld	a5,0(a5)
ffffffe000200790:	0087b703          	ld	a4,8(a5)
ffffffe000200794:	fff70713          	addi	a4,a4,-1
ffffffe000200798:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
ffffffe00020079c:	00006797          	auipc	a5,0x6
ffffffe0002007a0:	87478793          	addi	a5,a5,-1932 # ffffffe000206010 <current>
ffffffe0002007a4:	0007b783          	ld	a5,0(a5)
ffffffe0002007a8:	0087b783          	ld	a5,8(a5)
ffffffe0002007ac:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe0002007b0:	fe843783          	ld	a5,-24(s0)
ffffffe0002007b4:	00178713          	addi	a4,a5,1
ffffffe0002007b8:	fd043783          	ld	a5,-48(s0)
ffffffe0002007bc:	02f777b3          	remu	a5,a4,a5
ffffffe0002007c0:	fef43423          	sd	a5,-24(s0)
            switch(x) {
ffffffe0002007c4:	fe042783          	lw	a5,-32(s0)
ffffffe0002007c8:	0007871b          	sext.w	a4,a5
ffffffe0002007cc:	00600793          	li	a5,6
ffffffe0002007d0:	18e7e063          	bltu	a5,a4,ffffffe000200950 <dummy+0x28c>
ffffffe0002007d4:	fe046783          	lwu	a5,-32(s0)
ffffffe0002007d8:	00279713          	slli	a4,a5,0x2
ffffffe0002007dc:	00003797          	auipc	a5,0x3
ffffffe0002007e0:	cac78793          	addi	a5,a5,-852 # ffffffe000203488 <_srodata+0x488>
ffffffe0002007e4:	00f707b3          	add	a5,a4,a5
ffffffe0002007e8:	0007a783          	lw	a5,0(a5)
ffffffe0002007ec:	0007871b          	sext.w	a4,a5
ffffffe0002007f0:	00003797          	auipc	a5,0x3
ffffffe0002007f4:	c9878793          	addi	a5,a5,-872 # ffffffe000203488 <_srodata+0x488>
ffffffe0002007f8:	00f707b3          	add	a5,a4,a5
ffffffe0002007fc:	00078067          	jr	a5
                case 1: printk(COLOR1 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
ffffffe000200800:	00006797          	auipc	a5,0x6
ffffffe000200804:	81078793          	addi	a5,a5,-2032 # ffffffe000206010 <current>
ffffffe000200808:	0007b783          	ld	a5,0(a5)
ffffffe00020080c:	0187b703          	ld	a4,24(a5)
ffffffe000200810:	00006797          	auipc	a5,0x6
ffffffe000200814:	80078793          	addi	a5,a5,-2048 # ffffffe000206010 <current>
ffffffe000200818:	0007b783          	ld	a5,0(a5)
ffffffe00020081c:	00078693          	mv	a3,a5
ffffffe000200820:	fe843603          	ld	a2,-24(s0)
ffffffe000200824:	00070593          	mv	a1,a4
ffffffe000200828:	00003517          	auipc	a0,0x3
ffffffe00020082c:	88050513          	addi	a0,a0,-1920 # ffffffe0002030a8 <_srodata+0xa8>
ffffffe000200830:	751010ef          	jal	ffffffe000202780 <printk>
                        break;
ffffffe000200834:	11c0006f          	j	ffffffe000200950 <dummy+0x28c>
                case 2: printk(COLOR2 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
ffffffe000200838:	00005797          	auipc	a5,0x5
ffffffe00020083c:	7d878793          	addi	a5,a5,2008 # ffffffe000206010 <current>
ffffffe000200840:	0007b783          	ld	a5,0(a5)
ffffffe000200844:	0187b703          	ld	a4,24(a5)
ffffffe000200848:	00005797          	auipc	a5,0x5
ffffffe00020084c:	7c878793          	addi	a5,a5,1992 # ffffffe000206010 <current>
ffffffe000200850:	0007b783          	ld	a5,0(a5)
ffffffe000200854:	00078693          	mv	a3,a5
ffffffe000200858:	fe843603          	ld	a2,-24(s0)
ffffffe00020085c:	00070593          	mv	a1,a4
ffffffe000200860:	00003517          	auipc	a0,0x3
ffffffe000200864:	8a850513          	addi	a0,a0,-1880 # ffffffe000203108 <_srodata+0x108>
ffffffe000200868:	719010ef          	jal	ffffffe000202780 <printk>
                        break;
ffffffe00020086c:	0e40006f          	j	ffffffe000200950 <dummy+0x28c>
                case 3: printk(COLOR3 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
ffffffe000200870:	00005797          	auipc	a5,0x5
ffffffe000200874:	7a078793          	addi	a5,a5,1952 # ffffffe000206010 <current>
ffffffe000200878:	0007b783          	ld	a5,0(a5)
ffffffe00020087c:	0187b703          	ld	a4,24(a5)
ffffffe000200880:	00005797          	auipc	a5,0x5
ffffffe000200884:	79078793          	addi	a5,a5,1936 # ffffffe000206010 <current>
ffffffe000200888:	0007b783          	ld	a5,0(a5)
ffffffe00020088c:	00078693          	mv	a3,a5
ffffffe000200890:	fe843603          	ld	a2,-24(s0)
ffffffe000200894:	00070593          	mv	a1,a4
ffffffe000200898:	00003517          	auipc	a0,0x3
ffffffe00020089c:	8d050513          	addi	a0,a0,-1840 # ffffffe000203168 <_srodata+0x168>
ffffffe0002008a0:	6e1010ef          	jal	ffffffe000202780 <printk>
                        break;
ffffffe0002008a4:	0ac0006f          	j	ffffffe000200950 <dummy+0x28c>
                case 4: printk(COLOR4 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
ffffffe0002008a8:	00005797          	auipc	a5,0x5
ffffffe0002008ac:	76878793          	addi	a5,a5,1896 # ffffffe000206010 <current>
ffffffe0002008b0:	0007b783          	ld	a5,0(a5)
ffffffe0002008b4:	0187b703          	ld	a4,24(a5)
ffffffe0002008b8:	00005797          	auipc	a5,0x5
ffffffe0002008bc:	75878793          	addi	a5,a5,1880 # ffffffe000206010 <current>
ffffffe0002008c0:	0007b783          	ld	a5,0(a5)
ffffffe0002008c4:	00078693          	mv	a3,a5
ffffffe0002008c8:	fe843603          	ld	a2,-24(s0)
ffffffe0002008cc:	00070593          	mv	a1,a4
ffffffe0002008d0:	00003517          	auipc	a0,0x3
ffffffe0002008d4:	8f850513          	addi	a0,a0,-1800 # ffffffe0002031c8 <_srodata+0x1c8>
ffffffe0002008d8:	6a9010ef          	jal	ffffffe000202780 <printk>
                        break;
ffffffe0002008dc:	0740006f          	j	ffffffe000200950 <dummy+0x28c>
                case 5: printk(COLOR5 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
ffffffe0002008e0:	00005797          	auipc	a5,0x5
ffffffe0002008e4:	73078793          	addi	a5,a5,1840 # ffffffe000206010 <current>
ffffffe0002008e8:	0007b783          	ld	a5,0(a5)
ffffffe0002008ec:	0187b703          	ld	a4,24(a5)
ffffffe0002008f0:	00005797          	auipc	a5,0x5
ffffffe0002008f4:	72078793          	addi	a5,a5,1824 # ffffffe000206010 <current>
ffffffe0002008f8:	0007b783          	ld	a5,0(a5)
ffffffe0002008fc:	00078693          	mv	a3,a5
ffffffe000200900:	fe843603          	ld	a2,-24(s0)
ffffffe000200904:	00070593          	mv	a1,a4
ffffffe000200908:	00003517          	auipc	a0,0x3
ffffffe00020090c:	92050513          	addi	a0,a0,-1760 # ffffffe000203228 <_srodata+0x228>
ffffffe000200910:	671010ef          	jal	ffffffe000202780 <printk>
                        break;
ffffffe000200914:	03c0006f          	j	ffffffe000200950 <dummy+0x28c>
                case 6: printk(COLOR6 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
ffffffe000200918:	00005797          	auipc	a5,0x5
ffffffe00020091c:	6f878793          	addi	a5,a5,1784 # ffffffe000206010 <current>
ffffffe000200920:	0007b783          	ld	a5,0(a5)
ffffffe000200924:	0187b703          	ld	a4,24(a5)
ffffffe000200928:	00005797          	auipc	a5,0x5
ffffffe00020092c:	6e878793          	addi	a5,a5,1768 # ffffffe000206010 <current>
ffffffe000200930:	0007b783          	ld	a5,0(a5)
ffffffe000200934:	00078693          	mv	a3,a5
ffffffe000200938:	fe843603          	ld	a2,-24(s0)
ffffffe00020093c:	00070593          	mv	a1,a4
ffffffe000200940:	00003517          	auipc	a0,0x3
ffffffe000200944:	94850513          	addi	a0,a0,-1720 # ffffffe000203288 <_srodata+0x288>
ffffffe000200948:	639010ef          	jal	ffffffe000202780 <printk>
                        break;
ffffffe00020094c:	00000013          	nop
            }
            // printk(COLOR1 "[PID = %d] is running. auto_inc_local_var = %d\n" CLEAR, current->pid, auto_inc_local_var);
            if (flag == 0) {
ffffffe000200950:	fdc42783          	lw	a5,-36(s0)
ffffffe000200954:	0007879b          	sext.w	a5,a5
ffffffe000200958:	02079a63          	bnez	a5,ffffffe00020098c <dummy+0x2c8>
                x++;
ffffffe00020095c:	fe042783          	lw	a5,-32(s0)
ffffffe000200960:	0017879b          	addiw	a5,a5,1
ffffffe000200964:	fef42023          	sw	a5,-32(s0)
                if (x == 7) {
ffffffe000200968:	fe042783          	lw	a5,-32(s0)
ffffffe00020096c:	0007871b          	sext.w	a4,a5
ffffffe000200970:	00700793          	li	a5,7
ffffffe000200974:	02f71e63          	bne	a4,a5,ffffffe0002009b0 <dummy+0x2ec>
                    x = 6;
ffffffe000200978:	00600793          	li	a5,6
ffffffe00020097c:	fef42023          	sw	a5,-32(s0)
                    flag = 1;
ffffffe000200980:	00100793          	li	a5,1
ffffffe000200984:	fcf42e23          	sw	a5,-36(s0)
ffffffe000200988:	0280006f          	j	ffffffe0002009b0 <dummy+0x2ec>
                }
            } else {
                x--;
ffffffe00020098c:	fe042783          	lw	a5,-32(s0)
ffffffe000200990:	fff7879b          	addiw	a5,a5,-1
ffffffe000200994:	fef42023          	sw	a5,-32(s0)
                if (x == 0) {
ffffffe000200998:	fe042783          	lw	a5,-32(s0)
ffffffe00020099c:	0007879b          	sext.w	a5,a5
ffffffe0002009a0:	00079863          	bnez	a5,ffffffe0002009b0 <dummy+0x2ec>
                    x = 1;
ffffffe0002009a4:	00100793          	li	a5,1
ffffffe0002009a8:	fef42023          	sw	a5,-32(s0)
                    flag = 0;
ffffffe0002009ac:	fc042e23          	sw	zero,-36(s0)
                }
            }
            #if TEST_SCHED
            tasks_output[tasks_output_index++] = current->pid + '0';
ffffffe0002009b0:	00005797          	auipc	a5,0x5
ffffffe0002009b4:	66078793          	addi	a5,a5,1632 # ffffffe000206010 <current>
ffffffe0002009b8:	0007b783          	ld	a5,0(a5)
ffffffe0002009bc:	0187b783          	ld	a5,24(a5)
ffffffe0002009c0:	0ff7f713          	zext.b	a4,a5
ffffffe0002009c4:	00005797          	auipc	a5,0x5
ffffffe0002009c8:	65478793          	addi	a5,a5,1620 # ffffffe000206018 <tasks_output_index>
ffffffe0002009cc:	0007a783          	lw	a5,0(a5)
ffffffe0002009d0:	0017869b          	addiw	a3,a5,1
ffffffe0002009d4:	0006861b          	sext.w	a2,a3
ffffffe0002009d8:	00005697          	auipc	a3,0x5
ffffffe0002009dc:	64068693          	addi	a3,a3,1600 # ffffffe000206018 <tasks_output_index>
ffffffe0002009e0:	00c6a023          	sw	a2,0(a3)
ffffffe0002009e4:	0307071b          	addiw	a4,a4,48
ffffffe0002009e8:	0ff77713          	zext.b	a4,a4
ffffffe0002009ec:	00005697          	auipc	a3,0x5
ffffffe0002009f0:	66468693          	addi	a3,a3,1636 # ffffffe000206050 <tasks_output>
ffffffe0002009f4:	00f687b3          	add	a5,a3,a5
ffffffe0002009f8:	00e78023          	sb	a4,0(a5)
            if (tasks_output_index == MAX_OUTPUT) {
ffffffe0002009fc:	00005797          	auipc	a5,0x5
ffffffe000200a00:	61c78793          	addi	a5,a5,1564 # ffffffe000206018 <tasks_output_index>
ffffffe000200a04:	0007a783          	lw	a5,0(a5)
ffffffe000200a08:	00078713          	mv	a4,a5
ffffffe000200a0c:	02800793          	li	a5,40
ffffffe000200a10:	d2f710e3          	bne	a4,a5,ffffffe000200730 <dummy+0x6c>
                for (int i = 0; i < MAX_OUTPUT; ++i) {
ffffffe000200a14:	fc042c23          	sw	zero,-40(s0)
ffffffe000200a18:	0800006f          	j	ffffffe000200a98 <dummy+0x3d4>
                    if (tasks_output[i] != expected_output[i]) {
ffffffe000200a1c:	00005717          	auipc	a4,0x5
ffffffe000200a20:	63470713          	addi	a4,a4,1588 # ffffffe000206050 <tasks_output>
ffffffe000200a24:	fd842783          	lw	a5,-40(s0)
ffffffe000200a28:	00f707b3          	add	a5,a4,a5
ffffffe000200a2c:	0007c683          	lbu	a3,0(a5)
ffffffe000200a30:	00003717          	auipc	a4,0x3
ffffffe000200a34:	5d870713          	addi	a4,a4,1496 # ffffffe000204008 <expected_output>
ffffffe000200a38:	fd842783          	lw	a5,-40(s0)
ffffffe000200a3c:	00f707b3          	add	a5,a4,a5
ffffffe000200a40:	0007c783          	lbu	a5,0(a5)
ffffffe000200a44:	00068713          	mv	a4,a3
ffffffe000200a48:	04f70263          	beq	a4,a5,ffffffe000200a8c <dummy+0x3c8>
                        printk("\033[31mTest failed!\033[0m\n");
ffffffe000200a4c:	00003517          	auipc	a0,0x3
ffffffe000200a50:	89c50513          	addi	a0,a0,-1892 # ffffffe0002032e8 <_srodata+0x2e8>
ffffffe000200a54:	52d010ef          	jal	ffffffe000202780 <printk>
                        printk("\033[31m    Expected: %s\033[0m\n", expected_output);
ffffffe000200a58:	00003597          	auipc	a1,0x3
ffffffe000200a5c:	5b058593          	addi	a1,a1,1456 # ffffffe000204008 <expected_output>
ffffffe000200a60:	00003517          	auipc	a0,0x3
ffffffe000200a64:	8a050513          	addi	a0,a0,-1888 # ffffffe000203300 <_srodata+0x300>
ffffffe000200a68:	519010ef          	jal	ffffffe000202780 <printk>
                        printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
ffffffe000200a6c:	00005597          	auipc	a1,0x5
ffffffe000200a70:	5e458593          	addi	a1,a1,1508 # ffffffe000206050 <tasks_output>
ffffffe000200a74:	00003517          	auipc	a0,0x3
ffffffe000200a78:	8ac50513          	addi	a0,a0,-1876 # ffffffe000203320 <_srodata+0x320>
ffffffe000200a7c:	505010ef          	jal	ffffffe000202780 <printk>
                        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
ffffffe000200a80:	00000593          	li	a1,0
ffffffe000200a84:	00000513          	li	a0,0
ffffffe000200a88:	600000ef          	jal	ffffffe000201088 <sbi_system_reset>
                for (int i = 0; i < MAX_OUTPUT; ++i) {
ffffffe000200a8c:	fd842783          	lw	a5,-40(s0)
ffffffe000200a90:	0017879b          	addiw	a5,a5,1
ffffffe000200a94:	fcf42c23          	sw	a5,-40(s0)
ffffffe000200a98:	fd842783          	lw	a5,-40(s0)
ffffffe000200a9c:	0007871b          	sext.w	a4,a5
ffffffe000200aa0:	02700793          	li	a5,39
ffffffe000200aa4:	f6e7dce3          	bge	a5,a4,ffffffe000200a1c <dummy+0x358>
                    }
                }
                printk("\033[32mTest passed!\033[0m\n");
ffffffe000200aa8:	00003517          	auipc	a0,0x3
ffffffe000200aac:	89850513          	addi	a0,a0,-1896 # ffffffe000203340 <_srodata+0x340>
ffffffe000200ab0:	4d1010ef          	jal	ffffffe000202780 <printk>
                printk("\033[32m    Output: %s\033[0m\n", expected_output);
ffffffe000200ab4:	00003597          	auipc	a1,0x3
ffffffe000200ab8:	55458593          	addi	a1,a1,1364 # ffffffe000204008 <expected_output>
ffffffe000200abc:	00003517          	auipc	a0,0x3
ffffffe000200ac0:	89c50513          	addi	a0,a0,-1892 # ffffffe000203358 <_srodata+0x358>
ffffffe000200ac4:	4bd010ef          	jal	ffffffe000202780 <printk>
                sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
ffffffe000200ac8:	00000593          	li	a1,0
ffffffe000200acc:	00000513          	li	a0,0
ffffffe000200ad0:	5b8000ef          	jal	ffffffe000201088 <sbi_system_reset>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000200ad4:	c5dff06f          	j	ffffffe000200730 <dummy+0x6c>

ffffffe000200ad8 <switch_to>:
            #endif
        }
    }
}

void switch_to(struct task_struct *next) {
ffffffe000200ad8:	fd010113          	addi	sp,sp,-48
ffffffe000200adc:	02113423          	sd	ra,40(sp)
ffffffe000200ae0:	02813023          	sd	s0,32(sp)
ffffffe000200ae4:	03010413          	addi	s0,sp,48
ffffffe000200ae8:	fca43c23          	sd	a0,-40(s0)
    // Log("Into switch_to func\n");
    if (next->pid != current->pid) {
ffffffe000200aec:	fd843783          	ld	a5,-40(s0)
ffffffe000200af0:	0187b703          	ld	a4,24(a5)
ffffffe000200af4:	00005797          	auipc	a5,0x5
ffffffe000200af8:	51c78793          	addi	a5,a5,1308 # ffffffe000206010 <current>
ffffffe000200afc:	0007b783          	ld	a5,0(a5)
ffffffe000200b00:	0187b783          	ld	a5,24(a5)
ffffffe000200b04:	02f70863          	beq	a4,a5,ffffffe000200b34 <switch_to+0x5c>
        struct task_struct* tmp = current;
ffffffe000200b08:	00005797          	auipc	a5,0x5
ffffffe000200b0c:	50878793          	addi	a5,a5,1288 # ffffffe000206010 <current>
ffffffe000200b10:	0007b783          	ld	a5,0(a5)
ffffffe000200b14:	fef43423          	sd	a5,-24(s0)
        current = next;
ffffffe000200b18:	00005797          	auipc	a5,0x5
ffffffe000200b1c:	4f878793          	addi	a5,a5,1272 # ffffffe000206010 <current>
ffffffe000200b20:	fd843703          	ld	a4,-40(s0)
ffffffe000200b24:	00e7b023          	sd	a4,0(a5)
        __switch_to(tmp, next);
ffffffe000200b28:	fd843583          	ld	a1,-40(s0)
ffffffe000200b2c:	fe843503          	ld	a0,-24(s0)
ffffffe000200b30:	ea4ff0ef          	jal	ffffffe0002001d4 <__switch_to>
    }
    // Log("finish switch_to func\n");
}
ffffffe000200b34:	00000013          	nop
ffffffe000200b38:	02813083          	ld	ra,40(sp)
ffffffe000200b3c:	02013403          	ld	s0,32(sp)
ffffffe000200b40:	03010113          	addi	sp,sp,48
ffffffe000200b44:	00008067          	ret

ffffffe000200b48 <do_timer>:

void do_timer() {
ffffffe000200b48:	ff010113          	addi	sp,sp,-16
ffffffe000200b4c:	00113423          	sd	ra,8(sp)
ffffffe000200b50:	00813023          	sd	s0,0(sp)
ffffffe000200b54:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度

    // YOUR CODE HERE

    if (current->pid == 0 || current->counter <= 0) {
ffffffe000200b58:	00005797          	auipc	a5,0x5
ffffffe000200b5c:	4b878793          	addi	a5,a5,1208 # ffffffe000206010 <current>
ffffffe000200b60:	0007b783          	ld	a5,0(a5)
ffffffe000200b64:	0187b783          	ld	a5,24(a5)
ffffffe000200b68:	00078c63          	beqz	a5,ffffffe000200b80 <do_timer+0x38>
ffffffe000200b6c:	00005797          	auipc	a5,0x5
ffffffe000200b70:	4a478793          	addi	a5,a5,1188 # ffffffe000206010 <current>
ffffffe000200b74:	0007b783          	ld	a5,0(a5)
ffffffe000200b78:	0087b783          	ld	a5,8(a5)
ffffffe000200b7c:	00079663          	bnez	a5,ffffffe000200b88 <do_timer+0x40>
        schedule();
ffffffe000200b80:	05c000ef          	jal	ffffffe000200bdc <schedule>
ffffffe000200b84:	0480006f          	j	ffffffe000200bcc <do_timer+0x84>
    } else {
        current->counter -= 1;
ffffffe000200b88:	00005797          	auipc	a5,0x5
ffffffe000200b8c:	48878793          	addi	a5,a5,1160 # ffffffe000206010 <current>
ffffffe000200b90:	0007b783          	ld	a5,0(a5)
ffffffe000200b94:	0087b703          	ld	a4,8(a5)
ffffffe000200b98:	00005797          	auipc	a5,0x5
ffffffe000200b9c:	47878793          	addi	a5,a5,1144 # ffffffe000206010 <current>
ffffffe000200ba0:	0007b783          	ld	a5,0(a5)
ffffffe000200ba4:	fff70713          	addi	a4,a4,-1
ffffffe000200ba8:	00e7b423          	sd	a4,8(a5)
        if (current->counter <= 0) schedule();
ffffffe000200bac:	00005797          	auipc	a5,0x5
ffffffe000200bb0:	46478793          	addi	a5,a5,1124 # ffffffe000206010 <current>
ffffffe000200bb4:	0007b783          	ld	a5,0(a5)
ffffffe000200bb8:	0087b783          	ld	a5,8(a5)
ffffffe000200bbc:	00079663          	bnez	a5,ffffffe000200bc8 <do_timer+0x80>
ffffffe000200bc0:	01c000ef          	jal	ffffffe000200bdc <schedule>
ffffffe000200bc4:	0080006f          	j	ffffffe000200bcc <do_timer+0x84>
        else return;
ffffffe000200bc8:	00000013          	nop
    }
}
ffffffe000200bcc:	00813083          	ld	ra,8(sp)
ffffffe000200bd0:	00013403          	ld	s0,0(sp)
ffffffe000200bd4:	01010113          	addi	sp,sp,16
ffffffe000200bd8:	00008067          	ret

ffffffe000200bdc <schedule>:

void schedule() {
ffffffe000200bdc:	fd010113          	addi	sp,sp,-48
ffffffe000200be0:	02113423          	sd	ra,40(sp)
ffffffe000200be4:	02813023          	sd	s0,32(sp)
ffffffe000200be8:	03010413          	addi	s0,sp,48
    // YOUR CODE HERE
    uint64_t all_counter_zero = 1;
ffffffe000200bec:	00100793          	li	a5,1
ffffffe000200bf0:	fef43423          	sd	a5,-24(s0)
    // struct pid_counter _counter[NR_TASKS];
    struct pid_counter _max_counter = {0, 0};
ffffffe000200bf4:	fc043823          	sd	zero,-48(s0)
ffffffe000200bf8:	fc043c23          	sd	zero,-40(s0)

    for (int i = 1; i <= NR_TASKS - 1; i++) {
ffffffe000200bfc:	00100793          	li	a5,1
ffffffe000200c00:	fef42223          	sw	a5,-28(s0)
ffffffe000200c04:	0980006f          	j	ffffffe000200c9c <schedule+0xc0>
        // _counter[i].pid = i;
        // _counter[i].counter = task[i]->counter;
        if (task[i]->counter > _max_counter.counter) {
ffffffe000200c08:	00005717          	auipc	a4,0x5
ffffffe000200c0c:	42070713          	addi	a4,a4,1056 # ffffffe000206028 <task>
ffffffe000200c10:	fe442783          	lw	a5,-28(s0)
ffffffe000200c14:	00379793          	slli	a5,a5,0x3
ffffffe000200c18:	00f707b3          	add	a5,a4,a5
ffffffe000200c1c:	0007b783          	ld	a5,0(a5)
ffffffe000200c20:	0087b703          	ld	a4,8(a5)
ffffffe000200c24:	fd843783          	ld	a5,-40(s0)
ffffffe000200c28:	04e7f263          	bgeu	a5,a4,ffffffe000200c6c <schedule+0x90>
            _max_counter.counter = task[i]->counter;
ffffffe000200c2c:	00005717          	auipc	a4,0x5
ffffffe000200c30:	3fc70713          	addi	a4,a4,1020 # ffffffe000206028 <task>
ffffffe000200c34:	fe442783          	lw	a5,-28(s0)
ffffffe000200c38:	00379793          	slli	a5,a5,0x3
ffffffe000200c3c:	00f707b3          	add	a5,a4,a5
ffffffe000200c40:	0007b783          	ld	a5,0(a5)
ffffffe000200c44:	0087b783          	ld	a5,8(a5)
ffffffe000200c48:	fcf43c23          	sd	a5,-40(s0)
            _max_counter.pid = task[i]->pid;
ffffffe000200c4c:	00005717          	auipc	a4,0x5
ffffffe000200c50:	3dc70713          	addi	a4,a4,988 # ffffffe000206028 <task>
ffffffe000200c54:	fe442783          	lw	a5,-28(s0)
ffffffe000200c58:	00379793          	slli	a5,a5,0x3
ffffffe000200c5c:	00f707b3          	add	a5,a4,a5
ffffffe000200c60:	0007b783          	ld	a5,0(a5)
ffffffe000200c64:	0187b783          	ld	a5,24(a5)
ffffffe000200c68:	fcf43823          	sd	a5,-48(s0)
        }
        if (task[i]->counter > 0) all_counter_zero = 0;
ffffffe000200c6c:	00005717          	auipc	a4,0x5
ffffffe000200c70:	3bc70713          	addi	a4,a4,956 # ffffffe000206028 <task>
ffffffe000200c74:	fe442783          	lw	a5,-28(s0)
ffffffe000200c78:	00379793          	slli	a5,a5,0x3
ffffffe000200c7c:	00f707b3          	add	a5,a4,a5
ffffffe000200c80:	0007b783          	ld	a5,0(a5)
ffffffe000200c84:	0087b783          	ld	a5,8(a5)
ffffffe000200c88:	00078463          	beqz	a5,ffffffe000200c90 <schedule+0xb4>
ffffffe000200c8c:	fe043423          	sd	zero,-24(s0)
    for (int i = 1; i <= NR_TASKS - 1; i++) {
ffffffe000200c90:	fe442783          	lw	a5,-28(s0)
ffffffe000200c94:	0017879b          	addiw	a5,a5,1
ffffffe000200c98:	fef42223          	sw	a5,-28(s0)
ffffffe000200c9c:	fe442783          	lw	a5,-28(s0)
ffffffe000200ca0:	0007871b          	sext.w	a4,a5
ffffffe000200ca4:	00400793          	li	a5,4
ffffffe000200ca8:	f6e7d0e3          	bge	a5,a4,ffffffe000200c08 <schedule+0x2c>
    }
    // Log("all_count_zero = %d\n", all_counter_zero);
    
    if (all_counter_zero == 1) { // all of the counters are 0
ffffffe000200cac:	fe843703          	ld	a4,-24(s0)
ffffffe000200cb0:	00100793          	li	a5,1
ffffffe000200cb4:	0cf71a63          	bne	a4,a5,ffffffe000200d88 <schedule+0x1ac>
        _max_counter.counter = 0;
ffffffe000200cb8:	fc043c23          	sd	zero,-40(s0)
        _max_counter.pid = 0;
ffffffe000200cbc:	fc043823          	sd	zero,-48(s0)
        for (int i = 1; i <= NR_TASKS - 1; i++) {
ffffffe000200cc0:	00100793          	li	a5,1
ffffffe000200cc4:	fef42023          	sw	a5,-32(s0)
ffffffe000200cc8:	0ac0006f          	j	ffffffe000200d74 <schedule+0x198>
            task[i]->counter = task[i]->priority;
ffffffe000200ccc:	00005717          	auipc	a4,0x5
ffffffe000200cd0:	35c70713          	addi	a4,a4,860 # ffffffe000206028 <task>
ffffffe000200cd4:	fe042783          	lw	a5,-32(s0)
ffffffe000200cd8:	00379793          	slli	a5,a5,0x3
ffffffe000200cdc:	00f707b3          	add	a5,a4,a5
ffffffe000200ce0:	0007b703          	ld	a4,0(a5)
ffffffe000200ce4:	00005697          	auipc	a3,0x5
ffffffe000200ce8:	34468693          	addi	a3,a3,836 # ffffffe000206028 <task>
ffffffe000200cec:	fe042783          	lw	a5,-32(s0)
ffffffe000200cf0:	00379793          	slli	a5,a5,0x3
ffffffe000200cf4:	00f687b3          	add	a5,a3,a5
ffffffe000200cf8:	0007b783          	ld	a5,0(a5)
ffffffe000200cfc:	01073703          	ld	a4,16(a4)
ffffffe000200d00:	00e7b423          	sd	a4,8(a5)
            if (task[i]->counter > _max_counter.counter) {
ffffffe000200d04:	00005717          	auipc	a4,0x5
ffffffe000200d08:	32470713          	addi	a4,a4,804 # ffffffe000206028 <task>
ffffffe000200d0c:	fe042783          	lw	a5,-32(s0)
ffffffe000200d10:	00379793          	slli	a5,a5,0x3
ffffffe000200d14:	00f707b3          	add	a5,a4,a5
ffffffe000200d18:	0007b783          	ld	a5,0(a5)
ffffffe000200d1c:	0087b703          	ld	a4,8(a5)
ffffffe000200d20:	fd843783          	ld	a5,-40(s0)
ffffffe000200d24:	04e7f263          	bgeu	a5,a4,ffffffe000200d68 <schedule+0x18c>
                _max_counter.counter = task[i]->counter;
ffffffe000200d28:	00005717          	auipc	a4,0x5
ffffffe000200d2c:	30070713          	addi	a4,a4,768 # ffffffe000206028 <task>
ffffffe000200d30:	fe042783          	lw	a5,-32(s0)
ffffffe000200d34:	00379793          	slli	a5,a5,0x3
ffffffe000200d38:	00f707b3          	add	a5,a4,a5
ffffffe000200d3c:	0007b783          	ld	a5,0(a5)
ffffffe000200d40:	0087b783          	ld	a5,8(a5)
ffffffe000200d44:	fcf43c23          	sd	a5,-40(s0)
                _max_counter.pid = task[i]->pid;
ffffffe000200d48:	00005717          	auipc	a4,0x5
ffffffe000200d4c:	2e070713          	addi	a4,a4,736 # ffffffe000206028 <task>
ffffffe000200d50:	fe042783          	lw	a5,-32(s0)
ffffffe000200d54:	00379793          	slli	a5,a5,0x3
ffffffe000200d58:	00f707b3          	add	a5,a4,a5
ffffffe000200d5c:	0007b783          	ld	a5,0(a5)
ffffffe000200d60:	0187b783          	ld	a5,24(a5)
ffffffe000200d64:	fcf43823          	sd	a5,-48(s0)
        for (int i = 1; i <= NR_TASKS - 1; i++) {
ffffffe000200d68:	fe042783          	lw	a5,-32(s0)
ffffffe000200d6c:	0017879b          	addiw	a5,a5,1
ffffffe000200d70:	fef42023          	sw	a5,-32(s0)
ffffffe000200d74:	fe042783          	lw	a5,-32(s0)
ffffffe000200d78:	0007871b          	sext.w	a4,a5
ffffffe000200d7c:	00400793          	li	a5,4
ffffffe000200d80:	f4e7d6e3          	bge	a5,a4,ffffffe000200ccc <schedule+0xf0>
            }
        }
        goto SWITCH_TO_FUNC;
ffffffe000200d84:	0080006f          	j	ffffffe000200d8c <schedule+0x1b0>
    }

    goto SWITCH_TO_FUNC;
ffffffe000200d88:	00000013          	nop

SWITCH_TO_FUNC:
    printk(BOLD REVERSED FG_COLOR(255, 135, 175) "SWITCH [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR,task[_max_counter.pid]->pid, \
ffffffe000200d8c:	fd043783          	ld	a5,-48(s0)
ffffffe000200d90:	00005717          	auipc	a4,0x5
ffffffe000200d94:	29870713          	addi	a4,a4,664 # ffffffe000206028 <task>
ffffffe000200d98:	00379793          	slli	a5,a5,0x3
ffffffe000200d9c:	00f707b3          	add	a5,a4,a5
ffffffe000200da0:	0007b783          	ld	a5,0(a5)
ffffffe000200da4:	0187b583          	ld	a1,24(a5)
                    task[_max_counter.pid]->priority, task[_max_counter.pid]->counter);
ffffffe000200da8:	fd043783          	ld	a5,-48(s0)
ffffffe000200dac:	00005717          	auipc	a4,0x5
ffffffe000200db0:	27c70713          	addi	a4,a4,636 # ffffffe000206028 <task>
ffffffe000200db4:	00379793          	slli	a5,a5,0x3
ffffffe000200db8:	00f707b3          	add	a5,a4,a5
ffffffe000200dbc:	0007b783          	ld	a5,0(a5)
    printk(BOLD REVERSED FG_COLOR(255, 135, 175) "SWITCH [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR,task[_max_counter.pid]->pid, \
ffffffe000200dc0:	0107b603          	ld	a2,16(a5)
                    task[_max_counter.pid]->priority, task[_max_counter.pid]->counter);
ffffffe000200dc4:	fd043783          	ld	a5,-48(s0)
ffffffe000200dc8:	00005717          	auipc	a4,0x5
ffffffe000200dcc:	26070713          	addi	a4,a4,608 # ffffffe000206028 <task>
ffffffe000200dd0:	00379793          	slli	a5,a5,0x3
ffffffe000200dd4:	00f707b3          	add	a5,a4,a5
ffffffe000200dd8:	0007b783          	ld	a5,0(a5)
    printk(BOLD REVERSED FG_COLOR(255, 135, 175) "SWITCH [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR,task[_max_counter.pid]->pid, \
ffffffe000200ddc:	0087b783          	ld	a5,8(a5)
ffffffe000200de0:	00078693          	mv	a3,a5
ffffffe000200de4:	00002517          	auipc	a0,0x2
ffffffe000200de8:	65450513          	addi	a0,a0,1620 # ffffffe000203438 <_srodata+0x438>
ffffffe000200dec:	195010ef          	jal	ffffffe000202780 <printk>
    switch_to(task[_max_counter.pid]);
ffffffe000200df0:	fd043783          	ld	a5,-48(s0)
ffffffe000200df4:	00005717          	auipc	a4,0x5
ffffffe000200df8:	23470713          	addi	a4,a4,564 # ffffffe000206028 <task>
ffffffe000200dfc:	00379793          	slli	a5,a5,0x3
ffffffe000200e00:	00f707b3          	add	a5,a4,a5
ffffffe000200e04:	0007b783          	ld	a5,0(a5)
ffffffe000200e08:	00078513          	mv	a0,a5
ffffffe000200e0c:	ccdff0ef          	jal	ffffffe000200ad8 <switch_to>

}
ffffffe000200e10:	00000013          	nop
ffffffe000200e14:	02813083          	ld	ra,40(sp)
ffffffe000200e18:	02013403          	ld	s0,32(sp)
ffffffe000200e1c:	03010113          	addi	sp,sp,48
ffffffe000200e20:	00008067          	ret

ffffffe000200e24 <__bubble_sort>:

void __bubble_sort(struct pid_counter* arr, uint64_t len) {
ffffffe000200e24:	fc010113          	addi	sp,sp,-64
ffffffe000200e28:	02813c23          	sd	s0,56(sp)
ffffffe000200e2c:	04010413          	addi	s0,sp,64
ffffffe000200e30:	fca43423          	sd	a0,-56(s0)
ffffffe000200e34:	fcb43023          	sd	a1,-64(s0)
    uint64_t i, j;
    struct pid_counter tmp;
    for (i = 1; i <= len; i++) {
ffffffe000200e38:	00100793          	li	a5,1
ffffffe000200e3c:	fef43423          	sd	a5,-24(s0)
ffffffe000200e40:	0dc0006f          	j	ffffffe000200f1c <__bubble_sort+0xf8>
        for (j = 1; j <= len; j++) {
ffffffe000200e44:	00100793          	li	a5,1
ffffffe000200e48:	fef43023          	sd	a5,-32(s0)
ffffffe000200e4c:	0b80006f          	j	ffffffe000200f04 <__bubble_sort+0xe0>
            if (arr[j].counter < arr[j+1].counter) {
ffffffe000200e50:	fe043783          	ld	a5,-32(s0)
ffffffe000200e54:	00479793          	slli	a5,a5,0x4
ffffffe000200e58:	fc843703          	ld	a4,-56(s0)
ffffffe000200e5c:	00f707b3          	add	a5,a4,a5
ffffffe000200e60:	0087b703          	ld	a4,8(a5)
ffffffe000200e64:	fe043783          	ld	a5,-32(s0)
ffffffe000200e68:	00178793          	addi	a5,a5,1
ffffffe000200e6c:	00479793          	slli	a5,a5,0x4
ffffffe000200e70:	fc843683          	ld	a3,-56(s0)
ffffffe000200e74:	00f687b3          	add	a5,a3,a5
ffffffe000200e78:	0087b783          	ld	a5,8(a5)
ffffffe000200e7c:	06f77e63          	bgeu	a4,a5,ffffffe000200ef8 <__bubble_sort+0xd4>
                tmp = arr[j];
ffffffe000200e80:	fe043783          	ld	a5,-32(s0)
ffffffe000200e84:	00479793          	slli	a5,a5,0x4
ffffffe000200e88:	fc843703          	ld	a4,-56(s0)
ffffffe000200e8c:	00f707b3          	add	a5,a4,a5
ffffffe000200e90:	0007b703          	ld	a4,0(a5)
ffffffe000200e94:	fce43823          	sd	a4,-48(s0)
ffffffe000200e98:	0087b783          	ld	a5,8(a5)
ffffffe000200e9c:	fcf43c23          	sd	a5,-40(s0)
                arr[j]= arr[j+1];
ffffffe000200ea0:	fe043783          	ld	a5,-32(s0)
ffffffe000200ea4:	00178793          	addi	a5,a5,1
ffffffe000200ea8:	00479793          	slli	a5,a5,0x4
ffffffe000200eac:	fc843703          	ld	a4,-56(s0)
ffffffe000200eb0:	00f70733          	add	a4,a4,a5
ffffffe000200eb4:	fe043783          	ld	a5,-32(s0)
ffffffe000200eb8:	00479793          	slli	a5,a5,0x4
ffffffe000200ebc:	fc843683          	ld	a3,-56(s0)
ffffffe000200ec0:	00f687b3          	add	a5,a3,a5
ffffffe000200ec4:	00073683          	ld	a3,0(a4)
ffffffe000200ec8:	00d7b023          	sd	a3,0(a5)
ffffffe000200ecc:	00873703          	ld	a4,8(a4)
ffffffe000200ed0:	00e7b423          	sd	a4,8(a5)
                arr[j+1] = tmp;
ffffffe000200ed4:	fe043783          	ld	a5,-32(s0)
ffffffe000200ed8:	00178793          	addi	a5,a5,1
ffffffe000200edc:	00479793          	slli	a5,a5,0x4
ffffffe000200ee0:	fc843703          	ld	a4,-56(s0)
ffffffe000200ee4:	00f707b3          	add	a5,a4,a5
ffffffe000200ee8:	fd043703          	ld	a4,-48(s0)
ffffffe000200eec:	00e7b023          	sd	a4,0(a5)
ffffffe000200ef0:	fd843703          	ld	a4,-40(s0)
ffffffe000200ef4:	00e7b423          	sd	a4,8(a5)
        for (j = 1; j <= len; j++) {
ffffffe000200ef8:	fe043783          	ld	a5,-32(s0)
ffffffe000200efc:	00178793          	addi	a5,a5,1
ffffffe000200f00:	fef43023          	sd	a5,-32(s0)
ffffffe000200f04:	fe043703          	ld	a4,-32(s0)
ffffffe000200f08:	fc043783          	ld	a5,-64(s0)
ffffffe000200f0c:	f4e7f2e3          	bgeu	a5,a4,ffffffe000200e50 <__bubble_sort+0x2c>
    for (i = 1; i <= len; i++) {
ffffffe000200f10:	fe843783          	ld	a5,-24(s0)
ffffffe000200f14:	00178793          	addi	a5,a5,1
ffffffe000200f18:	fef43423          	sd	a5,-24(s0)
ffffffe000200f1c:	fe843703          	ld	a4,-24(s0)
ffffffe000200f20:	fc043783          	ld	a5,-64(s0)
ffffffe000200f24:	f2e7f0e3          	bgeu	a5,a4,ffffffe000200e44 <__bubble_sort+0x20>
            }
        }
    }
}
ffffffe000200f28:	00000013          	nop
ffffffe000200f2c:	00000013          	nop
ffffffe000200f30:	03813403          	ld	s0,56(sp)
ffffffe000200f34:	04010113          	addi	sp,sp,64
ffffffe000200f38:	00008067          	ret

ffffffe000200f3c <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe000200f3c:	f9010113          	addi	sp,sp,-112
ffffffe000200f40:	06813423          	sd	s0,104(sp)
ffffffe000200f44:	07010413          	addi	s0,sp,112
ffffffe000200f48:	fca43423          	sd	a0,-56(s0)
ffffffe000200f4c:	fcb43023          	sd	a1,-64(s0)
ffffffe000200f50:	fac43c23          	sd	a2,-72(s0)
ffffffe000200f54:	fad43823          	sd	a3,-80(s0)
ffffffe000200f58:	fae43423          	sd	a4,-88(s0)
ffffffe000200f5c:	faf43023          	sd	a5,-96(s0)
ffffffe000200f60:	f9043c23          	sd	a6,-104(s0)
ffffffe000200f64:	f9143823          	sd	a7,-112(s0)
	
	struct sbiret ret;
    __asm__ volatile(
ffffffe000200f68:	fc843783          	ld	a5,-56(s0)
ffffffe000200f6c:	fc043703          	ld	a4,-64(s0)
ffffffe000200f70:	fb843683          	ld	a3,-72(s0)
ffffffe000200f74:	fb043603          	ld	a2,-80(s0)
ffffffe000200f78:	fa843583          	ld	a1,-88(s0)
ffffffe000200f7c:	fa043503          	ld	a0,-96(s0)
ffffffe000200f80:	f9843803          	ld	a6,-104(s0)
ffffffe000200f84:	f9043883          	ld	a7,-112(s0)
ffffffe000200f88:	00078893          	mv	a7,a5
ffffffe000200f8c:	00070813          	mv	a6,a4
ffffffe000200f90:	00068513          	mv	a0,a3
ffffffe000200f94:	00060593          	mv	a1,a2
ffffffe000200f98:	00058613          	mv	a2,a1
ffffffe000200f9c:	00050693          	mv	a3,a0
ffffffe000200fa0:	00080713          	mv	a4,a6
ffffffe000200fa4:	00088793          	mv	a5,a7
ffffffe000200fa8:	00000073          	ecall
ffffffe000200fac:	00050713          	mv	a4,a0
ffffffe000200fb0:	00058793          	mv	a5,a1
ffffffe000200fb4:	fce43823          	sd	a4,-48(s0)
ffffffe000200fb8:	fcf43c23          	sd	a5,-40(s0)
		"mv %[ret_error], a0\n"
		"mv %[ret_value], a1\n"
		: [ret_error] "=r" (ret.error), [ret_value] "=r" (ret.value)
		: [eid] "r" (eid), [fid] "r" (fid), [arg0] "r" (arg0), [arg1] "r" (arg1), [arg2] "r" (arg2), [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
	 );
	return ret;
ffffffe000200fbc:	fd043783          	ld	a5,-48(s0)
ffffffe000200fc0:	fef43023          	sd	a5,-32(s0)
ffffffe000200fc4:	fd843783          	ld	a5,-40(s0)
ffffffe000200fc8:	fef43423          	sd	a5,-24(s0)
ffffffe000200fcc:	fe043703          	ld	a4,-32(s0)
ffffffe000200fd0:	fe843783          	ld	a5,-24(s0)
ffffffe000200fd4:	00070313          	mv	t1,a4
ffffffe000200fd8:	00078393          	mv	t2,a5
ffffffe000200fdc:	00030713          	mv	a4,t1
ffffffe000200fe0:	00038793          	mv	a5,t2
}
ffffffe000200fe4:	00070513          	mv	a0,a4
ffffffe000200fe8:	00078593          	mv	a1,a5
ffffffe000200fec:	06813403          	ld	s0,104(sp)
ffffffe000200ff0:	07010113          	addi	sp,sp,112
ffffffe000200ff4:	00008067          	ret

ffffffe000200ff8 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe000200ff8:	fc010113          	addi	sp,sp,-64
ffffffe000200ffc:	02113c23          	sd	ra,56(sp)
ffffffe000201000:	02813823          	sd	s0,48(sp)
ffffffe000201004:	03213423          	sd	s2,40(sp)
ffffffe000201008:	03313023          	sd	s3,32(sp)
ffffffe00020100c:	04010413          	addi	s0,sp,64
ffffffe000201010:	00050793          	mv	a5,a0
ffffffe000201014:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e, 2, byte, 0, 0, 0, 0, 0);
ffffffe000201018:	fcf44603          	lbu	a2,-49(s0)
ffffffe00020101c:	00000893          	li	a7,0
ffffffe000201020:	00000813          	li	a6,0
ffffffe000201024:	00000793          	li	a5,0
ffffffe000201028:	00000713          	li	a4,0
ffffffe00020102c:	00000693          	li	a3,0
ffffffe000201030:	00200593          	li	a1,2
ffffffe000201034:	44424537          	lui	a0,0x44424
ffffffe000201038:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe00020103c:	f01ff0ef          	jal	ffffffe000200f3c <sbi_ecall>
ffffffe000201040:	00050713          	mv	a4,a0
ffffffe000201044:	00058793          	mv	a5,a1
ffffffe000201048:	fce43823          	sd	a4,-48(s0)
ffffffe00020104c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201050:	fd043703          	ld	a4,-48(s0)
ffffffe000201054:	fd843783          	ld	a5,-40(s0)
ffffffe000201058:	00070913          	mv	s2,a4
ffffffe00020105c:	00078993          	mv	s3,a5
ffffffe000201060:	00090713          	mv	a4,s2
ffffffe000201064:	00098793          	mv	a5,s3
}
ffffffe000201068:	00070513          	mv	a0,a4
ffffffe00020106c:	00078593          	mv	a1,a5
ffffffe000201070:	03813083          	ld	ra,56(sp)
ffffffe000201074:	03013403          	ld	s0,48(sp)
ffffffe000201078:	02813903          	ld	s2,40(sp)
ffffffe00020107c:	02013983          	ld	s3,32(sp)
ffffffe000201080:	04010113          	addi	sp,sp,64
ffffffe000201084:	00008067          	ret

ffffffe000201088 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe000201088:	fc010113          	addi	sp,sp,-64
ffffffe00020108c:	02113c23          	sd	ra,56(sp)
ffffffe000201090:	02813823          	sd	s0,48(sp)
ffffffe000201094:	03213423          	sd	s2,40(sp)
ffffffe000201098:	03313023          	sd	s3,32(sp)
ffffffe00020109c:	04010413          	addi	s0,sp,64
ffffffe0002010a0:	00050793          	mv	a5,a0
ffffffe0002010a4:	00058713          	mv	a4,a1
ffffffe0002010a8:	fcf42623          	sw	a5,-52(s0)
ffffffe0002010ac:	00070793          	mv	a5,a4
ffffffe0002010b0:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0, reset_type, reset_reason, 0, 0, 0, 0);
ffffffe0002010b4:	fcc46603          	lwu	a2,-52(s0)
ffffffe0002010b8:	fc846683          	lwu	a3,-56(s0)
ffffffe0002010bc:	00000893          	li	a7,0
ffffffe0002010c0:	00000813          	li	a6,0
ffffffe0002010c4:	00000793          	li	a5,0
ffffffe0002010c8:	00000713          	li	a4,0
ffffffe0002010cc:	00000593          	li	a1,0
ffffffe0002010d0:	53525537          	lui	a0,0x53525
ffffffe0002010d4:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe0002010d8:	e65ff0ef          	jal	ffffffe000200f3c <sbi_ecall>
ffffffe0002010dc:	00050713          	mv	a4,a0
ffffffe0002010e0:	00058793          	mv	a5,a1
ffffffe0002010e4:	fce43823          	sd	a4,-48(s0)
ffffffe0002010e8:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002010ec:	fd043703          	ld	a4,-48(s0)
ffffffe0002010f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002010f4:	00070913          	mv	s2,a4
ffffffe0002010f8:	00078993          	mv	s3,a5
ffffffe0002010fc:	00090713          	mv	a4,s2
ffffffe000201100:	00098793          	mv	a5,s3
}
ffffffe000201104:	00070513          	mv	a0,a4
ffffffe000201108:	00078593          	mv	a1,a5
ffffffe00020110c:	03813083          	ld	ra,56(sp)
ffffffe000201110:	03013403          	ld	s0,48(sp)
ffffffe000201114:	02813903          	ld	s2,40(sp)
ffffffe000201118:	02013983          	ld	s3,32(sp)
ffffffe00020111c:	04010113          	addi	sp,sp,64
ffffffe000201120:	00008067          	ret

ffffffe000201124 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value) {
ffffffe000201124:	fc010113          	addi	sp,sp,-64
ffffffe000201128:	02113c23          	sd	ra,56(sp)
ffffffe00020112c:	02813823          	sd	s0,48(sp)
ffffffe000201130:	03213423          	sd	s2,40(sp)
ffffffe000201134:	03313023          	sd	s3,32(sp)
ffffffe000201138:	04010413          	addi	s0,sp,64
ffffffe00020113c:	fca43423          	sd	a0,-56(s0)
	return sbi_ecall(0x54494d45, 0, stime_value, 0, 0, 0, 0, 0);
ffffffe000201140:	00000893          	li	a7,0
ffffffe000201144:	00000813          	li	a6,0
ffffffe000201148:	00000793          	li	a5,0
ffffffe00020114c:	00000713          	li	a4,0
ffffffe000201150:	00000693          	li	a3,0
ffffffe000201154:	fc843603          	ld	a2,-56(s0)
ffffffe000201158:	00000593          	li	a1,0
ffffffe00020115c:	54495537          	lui	a0,0x54495
ffffffe000201160:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe000201164:	dd9ff0ef          	jal	ffffffe000200f3c <sbi_ecall>
ffffffe000201168:	00050713          	mv	a4,a0
ffffffe00020116c:	00058793          	mv	a5,a1
ffffffe000201170:	fce43823          	sd	a4,-48(s0)
ffffffe000201174:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201178:	fd043703          	ld	a4,-48(s0)
ffffffe00020117c:	fd843783          	ld	a5,-40(s0)
ffffffe000201180:	00070913          	mv	s2,a4
ffffffe000201184:	00078993          	mv	s3,a5
ffffffe000201188:	00090713          	mv	a4,s2
ffffffe00020118c:	00098793          	mv	a5,s3
}
ffffffe000201190:	00070513          	mv	a0,a4
ffffffe000201194:	00078593          	mv	a1,a5
ffffffe000201198:	03813083          	ld	ra,56(sp)
ffffffe00020119c:	03013403          	ld	s0,48(sp)
ffffffe0002011a0:	02813903          	ld	s2,40(sp)
ffffffe0002011a4:	02013983          	ld	s3,32(sp)
ffffffe0002011a8:	04010113          	addi	sp,sp,64
ffffffe0002011ac:	00008067          	ret

ffffffe0002011b0 <sbi_debug_console_write>:

struct sbiret sbi_debug_console_write(unsigned long num_bytes,
									  unsigned long base_addr_lo,
									  unsigned long base_addr_hi) {
ffffffe0002011b0:	fb010113          	addi	sp,sp,-80
ffffffe0002011b4:	04113423          	sd	ra,72(sp)
ffffffe0002011b8:	04813023          	sd	s0,64(sp)
ffffffe0002011bc:	03213c23          	sd	s2,56(sp)
ffffffe0002011c0:	03313823          	sd	s3,48(sp)
ffffffe0002011c4:	05010413          	addi	s0,sp,80
ffffffe0002011c8:	fca43423          	sd	a0,-56(s0)
ffffffe0002011cc:	fcb43023          	sd	a1,-64(s0)
ffffffe0002011d0:	fac43c23          	sd	a2,-72(s0)
	return sbi_ecall(0x4442434e, 0, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
ffffffe0002011d4:	00000893          	li	a7,0
ffffffe0002011d8:	00000813          	li	a6,0
ffffffe0002011dc:	00000793          	li	a5,0
ffffffe0002011e0:	fb843703          	ld	a4,-72(s0)
ffffffe0002011e4:	fc043683          	ld	a3,-64(s0)
ffffffe0002011e8:	fc843603          	ld	a2,-56(s0)
ffffffe0002011ec:	00000593          	li	a1,0
ffffffe0002011f0:	44424537          	lui	a0,0x44424
ffffffe0002011f4:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe0002011f8:	d45ff0ef          	jal	ffffffe000200f3c <sbi_ecall>
ffffffe0002011fc:	00050713          	mv	a4,a0
ffffffe000201200:	00058793          	mv	a5,a1
ffffffe000201204:	fce43823          	sd	a4,-48(s0)
ffffffe000201208:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020120c:	fd043703          	ld	a4,-48(s0)
ffffffe000201210:	fd843783          	ld	a5,-40(s0)
ffffffe000201214:	00070913          	mv	s2,a4
ffffffe000201218:	00078993          	mv	s3,a5
ffffffe00020121c:	00090713          	mv	a4,s2
ffffffe000201220:	00098793          	mv	a5,s3
}
ffffffe000201224:	00070513          	mv	a0,a4
ffffffe000201228:	00078593          	mv	a1,a5
ffffffe00020122c:	04813083          	ld	ra,72(sp)
ffffffe000201230:	04013403          	ld	s0,64(sp)
ffffffe000201234:	03813903          	ld	s2,56(sp)
ffffffe000201238:	03013983          	ld	s3,48(sp)
ffffffe00020123c:	05010113          	addi	sp,sp,80
ffffffe000201240:	00008067          	ret

ffffffe000201244 <sbi_debug_console_read>:

struct sbiret sbi_debug_console_read(unsigned long num_bytes,
									 unsigned long base_addr_lo,
									 unsigned long base_addr_hi) {
ffffffe000201244:	fb010113          	addi	sp,sp,-80
ffffffe000201248:	04113423          	sd	ra,72(sp)
ffffffe00020124c:	04813023          	sd	s0,64(sp)
ffffffe000201250:	03213c23          	sd	s2,56(sp)
ffffffe000201254:	03313823          	sd	s3,48(sp)
ffffffe000201258:	05010413          	addi	s0,sp,80
ffffffe00020125c:	fca43423          	sd	a0,-56(s0)
ffffffe000201260:	fcb43023          	sd	a1,-64(s0)
ffffffe000201264:	fac43c23          	sd	a2,-72(s0)
	return sbi_ecall(0x4442434e, 1, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
ffffffe000201268:	00000893          	li	a7,0
ffffffe00020126c:	00000813          	li	a6,0
ffffffe000201270:	00000793          	li	a5,0
ffffffe000201274:	fb843703          	ld	a4,-72(s0)
ffffffe000201278:	fc043683          	ld	a3,-64(s0)
ffffffe00020127c:	fc843603          	ld	a2,-56(s0)
ffffffe000201280:	00100593          	li	a1,1
ffffffe000201284:	44424537          	lui	a0,0x44424
ffffffe000201288:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe00020128c:	cb1ff0ef          	jal	ffffffe000200f3c <sbi_ecall>
ffffffe000201290:	00050713          	mv	a4,a0
ffffffe000201294:	00058793          	mv	a5,a1
ffffffe000201298:	fce43823          	sd	a4,-48(s0)
ffffffe00020129c:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002012a0:	fd043703          	ld	a4,-48(s0)
ffffffe0002012a4:	fd843783          	ld	a5,-40(s0)
ffffffe0002012a8:	00070913          	mv	s2,a4
ffffffe0002012ac:	00078993          	mv	s3,a5
ffffffe0002012b0:	00090713          	mv	a4,s2
ffffffe0002012b4:	00098793          	mv	a5,s3
ffffffe0002012b8:	00070513          	mv	a0,a4
ffffffe0002012bc:	00078593          	mv	a1,a5
ffffffe0002012c0:	04813083          	ld	ra,72(sp)
ffffffe0002012c4:	04013403          	ld	s0,64(sp)
ffffffe0002012c8:	03813903          	ld	s2,56(sp)
ffffffe0002012cc:	03013983          	ld	s3,48(sp)
ffffffe0002012d0:	05010113          	addi	sp,sp,80
ffffffe0002012d4:	00008067          	ret

ffffffe0002012d8 <trap_handler>:
#include "clock.h"
#include "trap.h"

extern void do_timer();

void trap_handler(uint64_t scause, uint64_t sepc) {
ffffffe0002012d8:	fd010113          	addi	sp,sp,-48
ffffffe0002012dc:	02113423          	sd	ra,40(sp)
ffffffe0002012e0:	02813023          	sd	s0,32(sp)
ffffffe0002012e4:	03010413          	addi	s0,sp,48
ffffffe0002012e8:	fca43c23          	sd	a0,-40(s0)
ffffffe0002012ec:	fcb43823          	sd	a1,-48(s0)
    // 如果是 interrupt 判断是否是 timer interrupt
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试

    int is_interrupt = (scause >> 63) & 1;
ffffffe0002012f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002012f4:	03f7d793          	srli	a5,a5,0x3f
ffffffe0002012f8:	fef42623          	sw	a5,-20(s0)
    
    if (is_interrupt) {
ffffffe0002012fc:	fec42783          	lw	a5,-20(s0)
ffffffe000201300:	0007879b          	sext.w	a5,a5
ffffffe000201304:	02078c63          	beqz	a5,ffffffe00020133c <trap_handler+0x64>
        if (scause == 0x8000000000000005) {
ffffffe000201308:	fd843703          	ld	a4,-40(s0)
ffffffe00020130c:	fff00793          	li	a5,-1
ffffffe000201310:	03f79793          	slli	a5,a5,0x3f
ffffffe000201314:	00578793          	addi	a5,a5,5
ffffffe000201318:	00f71863          	bne	a4,a5,ffffffe000201328 <trap_handler+0x50>
            // printk("[S] Supervisor Mode Timer Interrupt\n");
            
            clock_set_next_event();
ffffffe00020131c:	f61fe0ef          	jal	ffffffe00020027c <clock_set_next_event>
            do_timer();
ffffffe000201320:	829ff0ef          	jal	ffffffe000200b48 <do_timer>
            printk("[S] Supervisor Mode Store/AMO page fault\n");
        } else {
            printk("[S] Unhandled interrupt/exception: scause=0x%lx\n", scause);
        }
    }
ffffffe000201324:	0b40006f          	j	ffffffe0002013d8 <trap_handler+0x100>
            printk("[S] Unhandled interrupt/exception: scause=0x%lx\n", scause);
ffffffe000201328:	fd843583          	ld	a1,-40(s0)
ffffffe00020132c:	00002517          	auipc	a0,0x2
ffffffe000201330:	17c50513          	addi	a0,a0,380 # ffffffe0002034a8 <_srodata+0x4a8>
ffffffe000201334:	44c010ef          	jal	ffffffe000202780 <printk>
ffffffe000201338:	0a00006f          	j	ffffffe0002013d8 <trap_handler+0x100>
        if (scause == 0x0000000000000007) {
ffffffe00020133c:	fd843703          	ld	a4,-40(s0)
ffffffe000201340:	00700793          	li	a5,7
ffffffe000201344:	00f71a63          	bne	a4,a5,ffffffe000201358 <trap_handler+0x80>
            printk("[S] Supervisor Mode Store/AMO Access Fault\n");
ffffffe000201348:	00002517          	auipc	a0,0x2
ffffffe00020134c:	19850513          	addi	a0,a0,408 # ffffffe0002034e0 <_srodata+0x4e0>
ffffffe000201350:	430010ef          	jal	ffffffe000202780 <printk>
ffffffe000201354:	0840006f          	j	ffffffe0002013d8 <trap_handler+0x100>
        } else if (scause == 0x0000000000000005) {
ffffffe000201358:	fd843703          	ld	a4,-40(s0)
ffffffe00020135c:	00500793          	li	a5,5
ffffffe000201360:	00f71a63          	bne	a4,a5,ffffffe000201374 <trap_handler+0x9c>
            printk("[S] Supervisor Mode Load Access Fault\n");
ffffffe000201364:	00002517          	auipc	a0,0x2
ffffffe000201368:	1ac50513          	addi	a0,a0,428 # ffffffe000203510 <_srodata+0x510>
ffffffe00020136c:	414010ef          	jal	ffffffe000202780 <printk>
ffffffe000201370:	0680006f          	j	ffffffe0002013d8 <trap_handler+0x100>
        } else if (scause == 0x0000000000000001) {
ffffffe000201374:	fd843703          	ld	a4,-40(s0)
ffffffe000201378:	00100793          	li	a5,1
ffffffe00020137c:	00f71a63          	bne	a4,a5,ffffffe000201390 <trap_handler+0xb8>
            printk("[S] Supervisor Mode Instruction Access Fault\n");
ffffffe000201380:	00002517          	auipc	a0,0x2
ffffffe000201384:	1b850513          	addi	a0,a0,440 # ffffffe000203538 <_srodata+0x538>
ffffffe000201388:	3f8010ef          	jal	ffffffe000202780 <printk>
ffffffe00020138c:	04c0006f          	j	ffffffe0002013d8 <trap_handler+0x100>
        } else if (scause == 0x000000000000000c) {
ffffffe000201390:	fd843703          	ld	a4,-40(s0)
ffffffe000201394:	00c00793          	li	a5,12
ffffffe000201398:	00f71a63          	bne	a4,a5,ffffffe0002013ac <trap_handler+0xd4>
            printk("[S] Supervisor Mode Instruction Page Fault\n");
ffffffe00020139c:	00002517          	auipc	a0,0x2
ffffffe0002013a0:	1cc50513          	addi	a0,a0,460 # ffffffe000203568 <_srodata+0x568>
ffffffe0002013a4:	3dc010ef          	jal	ffffffe000202780 <printk>
ffffffe0002013a8:	0300006f          	j	ffffffe0002013d8 <trap_handler+0x100>
        } else if (scause == 0x000000000000000f) {
ffffffe0002013ac:	fd843703          	ld	a4,-40(s0)
ffffffe0002013b0:	00f00793          	li	a5,15
ffffffe0002013b4:	00f71a63          	bne	a4,a5,ffffffe0002013c8 <trap_handler+0xf0>
            printk("[S] Supervisor Mode Store/AMO page fault\n");
ffffffe0002013b8:	00002517          	auipc	a0,0x2
ffffffe0002013bc:	1e050513          	addi	a0,a0,480 # ffffffe000203598 <_srodata+0x598>
ffffffe0002013c0:	3c0010ef          	jal	ffffffe000202780 <printk>
ffffffe0002013c4:	0140006f          	j	ffffffe0002013d8 <trap_handler+0x100>
            printk("[S] Unhandled interrupt/exception: scause=0x%lx\n", scause);
ffffffe0002013c8:	fd843583          	ld	a1,-40(s0)
ffffffe0002013cc:	00002517          	auipc	a0,0x2
ffffffe0002013d0:	0dc50513          	addi	a0,a0,220 # ffffffe0002034a8 <_srodata+0x4a8>
ffffffe0002013d4:	3ac010ef          	jal	ffffffe000202780 <printk>
ffffffe0002013d8:	00000013          	nop
ffffffe0002013dc:	02813083          	ld	ra,40(sp)
ffffffe0002013e0:	02013403          	ld	s0,32(sp)
ffffffe0002013e4:	03010113          	addi	sp,sp,48
ffffffe0002013e8:	00008067          	ret

ffffffe0002013ec <setup_vm>:
/* early_pgtbl: 用于 setup_vm 进行 1GB 的 映射。 */
uint64_t  early_pgtbl[512] __attribute__((__aligned__(0x1000))); // uint64_t is 8 bytes, 4KB all together in a page
/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t  swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
ffffffe0002013ec:	fd010113          	addi	sp,sp,-48
ffffffe0002013f0:	02113423          	sd	ra,40(sp)
ffffffe0002013f4:	02813023          	sd	s0,32(sp)
ffffffe0002013f8:	03010413          	addi	s0,sp,48
     * the physical are considered as the offset, and the 9 bits in the middle are used as index
     * 
     * In the pte, only PPN[2](26 bits) is needed, thus turn the phyaddr[55:30] to pte[53:28]
    */

    uint64_t pte_flags = 0x1 | 0x2 | 0x4 | 0x8; // V | R | W | X
ffffffe0002013fc:	00f00793          	li	a5,15
ffffffe000201400:	fef43423          	sd	a5,-24(s0)
    uint64_t table_index;
    uint64_t PHY_PPN_2 = (PHY_START >> 30) & 0x3ffffff;
ffffffe000201404:	00200793          	li	a5,2
ffffffe000201408:	fef43023          	sd	a5,-32(s0)
    uint64_t PTE_PPN_2 = PHY_PPN_2 << 28;
ffffffe00020140c:	fe043783          	ld	a5,-32(s0)
ffffffe000201410:	01c79793          	slli	a5,a5,0x1c
ffffffe000201414:	fcf43c23          	sd	a5,-40(s0)


    // table_index = (PHY_START >> 30) & (0x1ffUL);        // GET 9-bit index
    // early_pgtbl[table_index] = PTE_PPN_2 | pte_flags; // set page table entry

    table_index = (VM_START >> 30) & (0x1ffUL);        // GET 9-bit index
ffffffe000201418:	18000793          	li	a5,384
ffffffe00020141c:	fcf43823          	sd	a5,-48(s0)
    early_pgtbl[table_index] = PTE_PPN_2 | pte_flags; // set page table entry
ffffffe000201420:	fd843703          	ld	a4,-40(s0)
ffffffe000201424:	fe843783          	ld	a5,-24(s0)
ffffffe000201428:	00f76733          	or	a4,a4,a5
ffffffe00020142c:	00006697          	auipc	a3,0x6
ffffffe000201430:	bd468693          	addi	a3,a3,-1068 # ffffffe000207000 <early_pgtbl>
ffffffe000201434:	fd043783          	ld	a5,-48(s0)
ffffffe000201438:	00379793          	slli	a5,a5,0x3
ffffffe00020143c:	00f687b3          	add	a5,a3,a5
ffffffe000201440:	00e7b023          	sd	a4,0(a5)

    printk(BOLD FG_COLOR(255, 95, 00)"...setup_vm done!\n" CLEAR);
ffffffe000201444:	00002517          	auipc	a0,0x2
ffffffe000201448:	18450513          	addi	a0,a0,388 # ffffffe0002035c8 <_srodata+0x5c8>
ffffffe00020144c:	334010ef          	jal	ffffffe000202780 <printk>
    //                 (PHY_START >> 30) & (0x1ffUL), (((PHY_START >> 30) & 0x3ffffff) << 28) | pte_flags);

    // printk(RED "Set direct mapping: index = %#llx, tbl_entry = %#llx\n" CLEAR, 
    //                 (VM_START >> 30) & (0x1ffUL), (((PHY_START >> 30) & 0x3ffffff) << 28) | pte_flags);

}
ffffffe000201450:	00000013          	nop
ffffffe000201454:	02813083          	ld	ra,40(sp)
ffffffe000201458:	02013403          	ld	s0,32(sp)
ffffffe00020145c:	03010113          	addi	sp,sp,48
ffffffe000201460:	00008067          	ret

ffffffe000201464 <setup_vm_final>:

void setup_vm_final() {
ffffffe000201464:	fd010113          	addi	sp,sp,-48
ffffffe000201468:	02113423          	sd	ra,40(sp)
ffffffe00020146c:	02813023          	sd	s0,32(sp)
ffffffe000201470:	03010413          	addi	s0,sp,48

    // No OpenSBI mapping required
    // Log("_stext = %#llx, _srodata = %#llx, sun = ", _stext, _srodata, (uint64_t)_srodata - (uint64_t)_stext);

    // mapping kernel text X|-|R|V
    printk(FG_COLOR(255, 95, 95) "Mapping kernel text section, NR_pages = %d ... \n" CLEAR, ((_srodata - _stext) >> 12)); // 1 page
ffffffe000201474:	00002717          	auipc	a4,0x2
ffffffe000201478:	b8c70713          	addi	a4,a4,-1140 # ffffffe000203000 <_srodata>
ffffffe00020147c:	fffff797          	auipc	a5,0xfffff
ffffffe000201480:	b8478793          	addi	a5,a5,-1148 # ffffffe000200000 <_skernel>
ffffffe000201484:	40f707b3          	sub	a5,a4,a5
ffffffe000201488:	40c7d793          	srai	a5,a5,0xc
ffffffe00020148c:	00078593          	mv	a1,a5
ffffffe000201490:	00002517          	auipc	a0,0x2
ffffffe000201494:	16850513          	addi	a0,a0,360 # ffffffe0002035f8 <_srodata+0x5f8>
ffffffe000201498:	2e8010ef          	jal	ffffffe000202780 <printk>
    create_mapping(swapper_pg_dir, (uint64_t)_stext, (uint64_t)_stext - PA2VA_OFFSET, 
ffffffe00020149c:	fffff597          	auipc	a1,0xfffff
ffffffe0002014a0:	b6458593          	addi	a1,a1,-1180 # ffffffe000200000 <_skernel>
ffffffe0002014a4:	fffff717          	auipc	a4,0xfffff
ffffffe0002014a8:	b5c70713          	addi	a4,a4,-1188 # ffffffe000200000 <_skernel>
ffffffe0002014ac:	04100793          	li	a5,65
ffffffe0002014b0:	01f79793          	slli	a5,a5,0x1f
ffffffe0002014b4:	00f70633          	add	a2,a4,a5
                    (uint64_t)_srodata - (uint64_t)_stext, 0xb); // 4'b1011
ffffffe0002014b8:	00002717          	auipc	a4,0x2
ffffffe0002014bc:	b4870713          	addi	a4,a4,-1208 # ffffffe000203000 <_srodata>
ffffffe0002014c0:	fffff797          	auipc	a5,0xfffff
ffffffe0002014c4:	b4078793          	addi	a5,a5,-1216 # ffffffe000200000 <_skernel>
    create_mapping(swapper_pg_dir, (uint64_t)_stext, (uint64_t)_stext - PA2VA_OFFSET, 
ffffffe0002014c8:	40f707b3          	sub	a5,a4,a5
ffffffe0002014cc:	00b00713          	li	a4,11
ffffffe0002014d0:	00078693          	mv	a3,a5
ffffffe0002014d4:	00007517          	auipc	a0,0x7
ffffffe0002014d8:	b2c50513          	addi	a0,a0,-1236 # ffffffe000208000 <swapper_pg_dir>
ffffffe0002014dc:	174000ef          	jal	ffffffe000201650 <create_mapping>
    printk(FG_COLOR(255, 95, 95) "...mapping kernel text section done!\n" CLEAR);
ffffffe0002014e0:	00002517          	auipc	a0,0x2
ffffffe0002014e4:	16050513          	addi	a0,a0,352 # ffffffe000203640 <_srodata+0x640>
ffffffe0002014e8:	298010ef          	jal	ffffffe000202780 <printk>


    // mapping kernel rodata -|-|R|V
    printk(FG_COLOR(255, 95, 135) "Mapping kernel rodata, NR_pages = %d ...\n" CLEAR, ((_sdata - _srodata) >> 12)); // 1 page
ffffffe0002014ec:	00003717          	auipc	a4,0x3
ffffffe0002014f0:	b1470713          	addi	a4,a4,-1260 # ffffffe000204000 <TIMECLOCK>
ffffffe0002014f4:	00002797          	auipc	a5,0x2
ffffffe0002014f8:	b0c78793          	addi	a5,a5,-1268 # ffffffe000203000 <_srodata>
ffffffe0002014fc:	40f707b3          	sub	a5,a4,a5
ffffffe000201500:	40c7d793          	srai	a5,a5,0xc
ffffffe000201504:	00078593          	mv	a1,a5
ffffffe000201508:	00002517          	auipc	a0,0x2
ffffffe00020150c:	17850513          	addi	a0,a0,376 # ffffffe000203680 <_srodata+0x680>
ffffffe000201510:	270010ef          	jal	ffffffe000202780 <printk>
    create_mapping(swapper_pg_dir, (uint64_t)_srodata, (uint64_t)_srodata - PA2VA_OFFSET, 
ffffffe000201514:	00002597          	auipc	a1,0x2
ffffffe000201518:	aec58593          	addi	a1,a1,-1300 # ffffffe000203000 <_srodata>
ffffffe00020151c:	00002717          	auipc	a4,0x2
ffffffe000201520:	ae470713          	addi	a4,a4,-1308 # ffffffe000203000 <_srodata>
ffffffe000201524:	04100793          	li	a5,65
ffffffe000201528:	01f79793          	slli	a5,a5,0x1f
ffffffe00020152c:	00f70633          	add	a2,a4,a5
                    (uint64_t)_sdata - (uint64_t)_srodata, 0x3); // 4'b0011
ffffffe000201530:	00003717          	auipc	a4,0x3
ffffffe000201534:	ad070713          	addi	a4,a4,-1328 # ffffffe000204000 <TIMECLOCK>
ffffffe000201538:	00002797          	auipc	a5,0x2
ffffffe00020153c:	ac878793          	addi	a5,a5,-1336 # ffffffe000203000 <_srodata>
    create_mapping(swapper_pg_dir, (uint64_t)_srodata, (uint64_t)_srodata - PA2VA_OFFSET, 
ffffffe000201540:	40f707b3          	sub	a5,a4,a5
ffffffe000201544:	00300713          	li	a4,3
ffffffe000201548:	00078693          	mv	a3,a5
ffffffe00020154c:	00007517          	auipc	a0,0x7
ffffffe000201550:	ab450513          	addi	a0,a0,-1356 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201554:	0fc000ef          	jal	ffffffe000201650 <create_mapping>
    printk(FG_COLOR(255, 95, 135) "...mapping kernel rodata section done!\n" CLEAR);
ffffffe000201558:	00002517          	auipc	a0,0x2
ffffffe00020155c:	16850513          	addi	a0,a0,360 # ffffffe0002036c0 <_srodata+0x6c0>
ffffffe000201560:	220010ef          	jal	ffffffe000202780 <printk>

    // mapping other memory -|W|R|V
    printk(FG_COLOR(255, 95, 175) "Mapping kernel other data, NR_pages = %d ...\n" CLEAR, (PHY_SIZE - ((uint64_t)_sdata - (uint64_t)_stext) >> 12)); // 32764 pages
ffffffe000201564:	fffff717          	auipc	a4,0xfffff
ffffffe000201568:	a9c70713          	addi	a4,a4,-1380 # ffffffe000200000 <_skernel>
ffffffe00020156c:	080007b7          	lui	a5,0x8000
ffffffe000201570:	00f70733          	add	a4,a4,a5
ffffffe000201574:	00003797          	auipc	a5,0x3
ffffffe000201578:	a8c78793          	addi	a5,a5,-1396 # ffffffe000204000 <TIMECLOCK>
ffffffe00020157c:	40f707b3          	sub	a5,a4,a5
ffffffe000201580:	00c7d793          	srli	a5,a5,0xc
ffffffe000201584:	00078593          	mv	a1,a5
ffffffe000201588:	00002517          	auipc	a0,0x2
ffffffe00020158c:	17850513          	addi	a0,a0,376 # ffffffe000203700 <_srodata+0x700>
ffffffe000201590:	1f0010ef          	jal	ffffffe000202780 <printk>
    create_mapping(swapper_pg_dir, (uint64_t)_sdata, (uint64_t)_sdata - PA2VA_OFFSET, 
ffffffe000201594:	00003597          	auipc	a1,0x3
ffffffe000201598:	a6c58593          	addi	a1,a1,-1428 # ffffffe000204000 <TIMECLOCK>
ffffffe00020159c:	00003717          	auipc	a4,0x3
ffffffe0002015a0:	a6470713          	addi	a4,a4,-1436 # ffffffe000204000 <TIMECLOCK>
ffffffe0002015a4:	04100793          	li	a5,65
ffffffe0002015a8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002015ac:	00f70633          	add	a2,a4,a5
                    PHY_SIZE - ((uint64_t)_sdata - (uint64_t)_stext), 0x7); // 4'b0111
ffffffe0002015b0:	fffff717          	auipc	a4,0xfffff
ffffffe0002015b4:	a5070713          	addi	a4,a4,-1456 # ffffffe000200000 <_skernel>
ffffffe0002015b8:	080007b7          	lui	a5,0x8000
ffffffe0002015bc:	00f70733          	add	a4,a4,a5
ffffffe0002015c0:	00003797          	auipc	a5,0x3
ffffffe0002015c4:	a4078793          	addi	a5,a5,-1472 # ffffffe000204000 <TIMECLOCK>
    create_mapping(swapper_pg_dir, (uint64_t)_sdata, (uint64_t)_sdata - PA2VA_OFFSET, 
ffffffe0002015c8:	40f707b3          	sub	a5,a4,a5
ffffffe0002015cc:	00700713          	li	a4,7
ffffffe0002015d0:	00078693          	mv	a3,a5
ffffffe0002015d4:	00007517          	auipc	a0,0x7
ffffffe0002015d8:	a2c50513          	addi	a0,a0,-1492 # ffffffe000208000 <swapper_pg_dir>
ffffffe0002015dc:	074000ef          	jal	ffffffe000201650 <create_mapping>
    printk(FG_COLOR(255, 97, 215) "...mapping kernel other data done!\n" CLEAR);
ffffffe0002015e0:	00002517          	auipc	a0,0x2
ffffffe0002015e4:	16850513          	addi	a0,a0,360 # ffffffe000203748 <_srodata+0x748>
ffffffe0002015e8:	198010ef          	jal	ffffffe000202780 <printk>

    // set satp with swapper_pg_dir
    uint64_t phy_swapper_pg_dir = (uint64_t)swapper_pg_dir - PA2VA_OFFSET;
ffffffe0002015ec:	00007717          	auipc	a4,0x7
ffffffe0002015f0:	a1470713          	addi	a4,a4,-1516 # ffffffe000208000 <swapper_pg_dir>
ffffffe0002015f4:	04100793          	li	a5,65
ffffffe0002015f8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002015fc:	00f707b3          	add	a5,a4,a5
ffffffe000201600:	fef43423          	sd	a5,-24(s0)
    uint64_t satp_value = (phy_swapper_pg_dir >> 12) + 0x8000000000000000;
ffffffe000201604:	fe843783          	ld	a5,-24(s0)
ffffffe000201608:	00c7d713          	srli	a4,a5,0xc
ffffffe00020160c:	fff00793          	li	a5,-1
ffffffe000201610:	03f79793          	slli	a5,a5,0x3f
ffffffe000201614:	00f707b3          	add	a5,a4,a5
ffffffe000201618:	fef43023          	sd	a5,-32(s0)
    csr_write(satp, satp_value);
ffffffe00020161c:	fe043783          	ld	a5,-32(s0)
ffffffe000201620:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201624:	fd843783          	ld	a5,-40(s0)
ffffffe000201628:	18079073          	csrw	satp,a5

    // printk(YELLOW "Set satp = %#llx\n, addr of swapper = %#llx ,virtual addr = %#llx\n" CLEAR, satp_value, (uint64_t)phy_swapper_pg_dir, (uint64_t)swapper_pg_dir);

    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe00020162c:	12000073          	sfence.vma

    // flush icache
    // asm volatile("fence.i");

    printk(FG_COLOR(255, 95, 255) "...setup_vm_final done!\n" CLEAR);
ffffffe000201630:	00002517          	auipc	a0,0x2
ffffffe000201634:	15850513          	addi	a0,a0,344 # ffffffe000203788 <_srodata+0x788>
ffffffe000201638:	148010ef          	jal	ffffffe000202780 <printk>

    return;
ffffffe00020163c:	00000013          	nop
}
ffffffe000201640:	02813083          	ld	ra,40(sp)
ffffffe000201644:	02013403          	ld	s0,32(sp)
ffffffe000201648:	03010113          	addi	sp,sp,48
ffffffe00020164c:	00008067          	ret

ffffffe000201650 <create_mapping>:

void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe000201650:	f6010113          	addi	sp,sp,-160
ffffffe000201654:	08113c23          	sd	ra,152(sp)
ffffffe000201658:	08813823          	sd	s0,144(sp)
ffffffe00020165c:	0a010413          	addi	s0,sp,160
ffffffe000201660:	f8a43423          	sd	a0,-120(s0)
ffffffe000201664:	f8b43023          	sd	a1,-128(s0)
ffffffe000201668:	f6c43c23          	sd	a2,-136(s0)
ffffffe00020166c:	f6d43823          	sd	a3,-144(s0)
ffffffe000201670:	f6e43423          	sd	a4,-152(s0)
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/

    uint64_t num_pages = sz >> 12;
ffffffe000201674:	f7043783          	ld	a5,-144(s0)
ffffffe000201678:	00c7d793          	srli	a5,a5,0xc
ffffffe00020167c:	fef43423          	sd	a5,-24(s0)
    if (sz % 0x1000 != 0)  num_pages++;
ffffffe000201680:	f7043703          	ld	a4,-144(s0)
ffffffe000201684:	000017b7          	lui	a5,0x1
ffffffe000201688:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe00020168c:	00f777b3          	and	a5,a4,a5
ffffffe000201690:	00078863          	beqz	a5,ffffffe0002016a0 <create_mapping+0x50>
ffffffe000201694:	fe843783          	ld	a5,-24(s0)
ffffffe000201698:	00178793          	addi	a5,a5,1
ffffffe00020169c:	fef43423          	sd	a5,-24(s0)
    // Log("va = %#llx, pa = %#llx", va, pa);
    // printk();
    
    for (uint64_t i = 0; i < num_pages; i++) {
ffffffe0002016a0:	fe043023          	sd	zero,-32(s0)
ffffffe0002016a4:	1980006f          	j	ffffffe00020183c <create_mapping+0x1ec>
        // Log("va = %#llx, pa = %#llx", va, pa);
        // Log("VPN_2 = %#llx, VPN_1 = %#llx, VPN_0 = %#llx", VPN_2, VPN_1, VPN_0);
        uint64_t VPN_2 = (va >> 30) & 0x1ffUL;
ffffffe0002016a8:	f8043783          	ld	a5,-128(s0)
ffffffe0002016ac:	01e7d793          	srli	a5,a5,0x1e
ffffffe0002016b0:	1ff7f793          	andi	a5,a5,511
ffffffe0002016b4:	fcf43c23          	sd	a5,-40(s0)
        uint64_t VPN_1 = (va >> 21) & 0x1ffUL;
ffffffe0002016b8:	f8043783          	ld	a5,-128(s0)
ffffffe0002016bc:	0157d793          	srli	a5,a5,0x15
ffffffe0002016c0:	1ff7f793          	andi	a5,a5,511
ffffffe0002016c4:	fcf43823          	sd	a5,-48(s0)
        uint64_t VPN_0 = (va >> 12) & 0x1ffUL;
ffffffe0002016c8:	f8043783          	ld	a5,-128(s0)
ffffffe0002016cc:	00c7d793          	srli	a5,a5,0xc
ffffffe0002016d0:	1ff7f793          	andi	a5,a5,511
ffffffe0002016d4:	fcf43423          	sd	a5,-56(s0)

        uintptr_t* pmd;
        uintptr_t* pte;

        // Log("pgtbl[VPN_2] = %#llx", pgtbl[VPN_2]);
        if ((pgtbl[VPN_2] & 0x1) == 0) {
ffffffe0002016d8:	fd843783          	ld	a5,-40(s0)
ffffffe0002016dc:	00379793          	slli	a5,a5,0x3
ffffffe0002016e0:	f8843703          	ld	a4,-120(s0)
ffffffe0002016e4:	00f707b3          	add	a5,a4,a5
ffffffe0002016e8:	0007b783          	ld	a5,0(a5)
ffffffe0002016ec:	0017f793          	andi	a5,a5,1
ffffffe0002016f0:	04079263          	bnez	a5,ffffffe000201734 <create_mapping+0xe4>
            uint64_t* new_pmd_va = (uint64_t*)kalloc(); // allocate a page for pmd
ffffffe0002016f4:	bd1fe0ef          	jal	ffffffe0002002c4 <kalloc>
ffffffe0002016f8:	fca43023          	sd	a0,-64(s0)
            uint64_t new_pmd_pa = (uint64_t)new_pmd_va - PA2VA_OFFSET;
ffffffe0002016fc:	fc043703          	ld	a4,-64(s0)
ffffffe000201700:	04100793          	li	a5,65
ffffffe000201704:	01f79793          	slli	a5,a5,0x1f
ffffffe000201708:	00f707b3          	add	a5,a4,a5
ffffffe00020170c:	faf43c23          	sd	a5,-72(s0)
            // Log("new_pmd_va = %#llx, new_pmd_pa = %#llx", new_pmd_va, new_pmd_pa);
            pgtbl[VPN_2] = (((new_pmd_pa) >> 12) << 10) | 0x1;
ffffffe000201710:	fb843783          	ld	a5,-72(s0)
ffffffe000201714:	00c7d793          	srli	a5,a5,0xc
ffffffe000201718:	00a79713          	slli	a4,a5,0xa
ffffffe00020171c:	fd843783          	ld	a5,-40(s0)
ffffffe000201720:	00379793          	slli	a5,a5,0x3
ffffffe000201724:	f8843683          	ld	a3,-120(s0)
ffffffe000201728:	00f687b3          	add	a5,a3,a5
ffffffe00020172c:	00176713          	ori	a4,a4,1
ffffffe000201730:	00e7b023          	sd	a4,0(a5)
        }
        pmd = (uint64_t*)(((pgtbl[VPN_2] >> 10) << 12) + PA2VA_OFFSET); // physical addr of pmd
ffffffe000201734:	fd843783          	ld	a5,-40(s0)
ffffffe000201738:	00379793          	slli	a5,a5,0x3
ffffffe00020173c:	f8843703          	ld	a4,-120(s0)
ffffffe000201740:	00f707b3          	add	a5,a4,a5
ffffffe000201744:	0007b783          	ld	a5,0(a5)
ffffffe000201748:	00a7d793          	srli	a5,a5,0xa
ffffffe00020174c:	00c79713          	slli	a4,a5,0xc
ffffffe000201750:	fbf00793          	li	a5,-65
ffffffe000201754:	01f79793          	slli	a5,a5,0x1f
ffffffe000201758:	00f707b3          	add	a5,a4,a5
ffffffe00020175c:	faf43823          	sd	a5,-80(s0)

        // Log("pmd = %#llx", pmd);
        // Log("pmd[VPN_1] = %#llx", pmd[VPN_1]);
        if ((pmd[VPN_1] & 0x1) == 0) {
ffffffe000201760:	fd043783          	ld	a5,-48(s0)
ffffffe000201764:	00379793          	slli	a5,a5,0x3
ffffffe000201768:	fb043703          	ld	a4,-80(s0)
ffffffe00020176c:	00f707b3          	add	a5,a4,a5
ffffffe000201770:	0007b783          	ld	a5,0(a5)
ffffffe000201774:	0017f793          	andi	a5,a5,1
ffffffe000201778:	04079263          	bnez	a5,ffffffe0002017bc <create_mapping+0x16c>
            uint64_t* new_pte_va = (uint64_t*)kalloc(); // allocate a page for pte
ffffffe00020177c:	b49fe0ef          	jal	ffffffe0002002c4 <kalloc>
ffffffe000201780:	faa43423          	sd	a0,-88(s0)
            uint64_t new_pte_pa = (uint64_t)new_pte_va - PA2VA_OFFSET;
ffffffe000201784:	fa843703          	ld	a4,-88(s0)
ffffffe000201788:	04100793          	li	a5,65
ffffffe00020178c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201790:	00f707b3          	add	a5,a4,a5
ffffffe000201794:	faf43023          	sd	a5,-96(s0)
            pmd[VPN_1] = ((new_pte_pa >> 12) << 10) | 0x1;
ffffffe000201798:	fa043783          	ld	a5,-96(s0)
ffffffe00020179c:	00c7d793          	srli	a5,a5,0xc
ffffffe0002017a0:	00a79713          	slli	a4,a5,0xa
ffffffe0002017a4:	fd043783          	ld	a5,-48(s0)
ffffffe0002017a8:	00379793          	slli	a5,a5,0x3
ffffffe0002017ac:	fb043683          	ld	a3,-80(s0)
ffffffe0002017b0:	00f687b3          	add	a5,a3,a5
ffffffe0002017b4:	00176713          	ori	a4,a4,1
ffffffe0002017b8:	00e7b023          	sd	a4,0(a5)
        }
        pte = (uint64_t*)(((pmd[VPN_1] >> 10) << 12) + PA2VA_OFFSET); // physical addr of pte
ffffffe0002017bc:	fd043783          	ld	a5,-48(s0)
ffffffe0002017c0:	00379793          	slli	a5,a5,0x3
ffffffe0002017c4:	fb043703          	ld	a4,-80(s0)
ffffffe0002017c8:	00f707b3          	add	a5,a4,a5
ffffffe0002017cc:	0007b783          	ld	a5,0(a5)
ffffffe0002017d0:	00a7d793          	srli	a5,a5,0xa
ffffffe0002017d4:	00c79713          	slli	a4,a5,0xc
ffffffe0002017d8:	fbf00793          	li	a5,-65
ffffffe0002017dc:	01f79793          	slli	a5,a5,0x1f
ffffffe0002017e0:	00f707b3          	add	a5,a4,a5
ffffffe0002017e4:	f8f43c23          	sd	a5,-104(s0)

        // Log("pte = %#llx", pte);
        pte[VPN_0] = ((pa >> 12) << 10) | perm; // set pte entry
ffffffe0002017e8:	f7843783          	ld	a5,-136(s0)
ffffffe0002017ec:	00c7d793          	srli	a5,a5,0xc
ffffffe0002017f0:	00a79693          	slli	a3,a5,0xa
ffffffe0002017f4:	fc843783          	ld	a5,-56(s0)
ffffffe0002017f8:	00379793          	slli	a5,a5,0x3
ffffffe0002017fc:	f9843703          	ld	a4,-104(s0)
ffffffe000201800:	00f707b3          	add	a5,a4,a5
ffffffe000201804:	f6843703          	ld	a4,-152(s0)
ffffffe000201808:	00e6e733          	or	a4,a3,a4
ffffffe00020180c:	00e7b023          	sd	a4,0(a5)
        
        va += PGSIZE;
ffffffe000201810:	f8043703          	ld	a4,-128(s0)
ffffffe000201814:	000017b7          	lui	a5,0x1
ffffffe000201818:	00f707b3          	add	a5,a4,a5
ffffffe00020181c:	f8f43023          	sd	a5,-128(s0)
        pa += PGSIZE;
ffffffe000201820:	f7843703          	ld	a4,-136(s0)
ffffffe000201824:	000017b7          	lui	a5,0x1
ffffffe000201828:	00f707b3          	add	a5,a4,a5
ffffffe00020182c:	f6f43c23          	sd	a5,-136(s0)
    for (uint64_t i = 0; i < num_pages; i++) {
ffffffe000201830:	fe043783          	ld	a5,-32(s0)
ffffffe000201834:	00178793          	addi	a5,a5,1 # 1001 <PGSIZE+0x1>
ffffffe000201838:	fef43023          	sd	a5,-32(s0)
ffffffe00020183c:	fe043703          	ld	a4,-32(s0)
ffffffe000201840:	fe843783          	ld	a5,-24(s0)
ffffffe000201844:	e6f762e3          	bltu	a4,a5,ffffffe0002016a8 <create_mapping+0x58>
    }

    return;
ffffffe000201848:	00000013          	nop
ffffffe00020184c:	09813083          	ld	ra,152(sp)
ffffffe000201850:	09013403          	ld	s0,144(sp)
ffffffe000201854:	0a010113          	addi	sp,sp,160
ffffffe000201858:	00008067          	ret

ffffffe00020185c <start_kernel>:

extern void test();
extern char _stext[];
extern char _srodata[];

int start_kernel() {
ffffffe00020185c:	ff010113          	addi	sp,sp,-16
ffffffe000201860:	00113423          	sd	ra,8(sp)
ffffffe000201864:	00813023          	sd	s0,0(sp)
ffffffe000201868:	01010413          	addi	s0,sp,16
    printk(FG_COLOR(175, 175, 255) "2024" CLEAR);
ffffffe00020186c:	00002517          	auipc	a0,0x2
ffffffe000201870:	f4c50513          	addi	a0,a0,-180 # ffffffe0002037b8 <_srodata+0x7b8>
ffffffe000201874:	70d000ef          	jal	ffffffe000202780 <printk>
    printk(FG_COLOR(215, 175, 255) " ZJU Operating System\n" CLEAR);
ffffffe000201878:	00002517          	auipc	a0,0x2
ffffffe00020187c:	f6050513          	addi	a0,a0,-160 # ffffffe0002037d8 <_srodata+0x7d8>
ffffffe000201880:	701000ef          	jal	ffffffe000202780 <printk>
    printk(BOLD FG_COLOR(255, 135, 255) "---------------------------------------\n\n" CLEAR);
ffffffe000201884:	00002517          	auipc	a0,0x2
ffffffe000201888:	f8450513          	addi	a0,a0,-124 # ffffffe000203808 <_srodata+0x808>
ffffffe00020188c:	6f5000ef          	jal	ffffffe000202780 <printk>
    // check rodata section: execute property
    // void (*func)() = (void*)_srodata;
    // func();
   

    test();
ffffffe000201890:	01c000ef          	jal	ffffffe0002018ac <test>
    return 0;
ffffffe000201894:	00000793          	li	a5,0
}
ffffffe000201898:	00078513          	mv	a0,a5
ffffffe00020189c:	00813083          	ld	ra,8(sp)
ffffffe0002018a0:	00013403          	ld	s0,0(sp)
ffffffe0002018a4:	01010113          	addi	sp,sp,16
ffffffe0002018a8:	00008067          	ret

ffffffe0002018ac <test>:
#include "sbi.h"
#include "printk.h"
extern void dummy();

void test() {
ffffffe0002018ac:	fe010113          	addi	sp,sp,-32
ffffffe0002018b0:	00813c23          	sd	s0,24(sp)
ffffffe0002018b4:	02010413          	addi	s0,sp,32
    int i = 0;
ffffffe0002018b8:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
ffffffe0002018bc:	fec42783          	lw	a5,-20(s0)
ffffffe0002018c0:	0017879b          	addiw	a5,a5,1
ffffffe0002018c4:	fef42623          	sw	a5,-20(s0)
ffffffe0002018c8:	fec42783          	lw	a5,-20(s0)
ffffffe0002018cc:	00078713          	mv	a4,a5
ffffffe0002018d0:	05f5e7b7          	lui	a5,0x5f5e
ffffffe0002018d4:	1007879b          	addiw	a5,a5,256 # 5f5e100 <OPENSBI_SIZE+0x5d5e100>
ffffffe0002018d8:	02f767bb          	remw	a5,a4,a5
ffffffe0002018dc:	0007879b          	sext.w	a5,a5
ffffffe0002018e0:	fc079ee3          	bnez	a5,ffffffe0002018bc <test+0x10>
            // printk("kernel is running!\n");
            i = 0;
ffffffe0002018e4:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
ffffffe0002018e8:	fd5ff06f          	j	ffffffe0002018bc <test+0x10>

ffffffe0002018ec <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe0002018ec:	fe010113          	addi	sp,sp,-32
ffffffe0002018f0:	00113c23          	sd	ra,24(sp)
ffffffe0002018f4:	00813823          	sd	s0,16(sp)
ffffffe0002018f8:	02010413          	addi	s0,sp,32
ffffffe0002018fc:	00050793          	mv	a5,a0
ffffffe000201900:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe000201904:	fec42783          	lw	a5,-20(s0)
ffffffe000201908:	0ff7f793          	zext.b	a5,a5
ffffffe00020190c:	00078513          	mv	a0,a5
ffffffe000201910:	ee8ff0ef          	jal	ffffffe000200ff8 <sbi_debug_console_write_byte>
    return (char)c;
ffffffe000201914:	fec42783          	lw	a5,-20(s0)
ffffffe000201918:	0ff7f793          	zext.b	a5,a5
ffffffe00020191c:	0007879b          	sext.w	a5,a5
}
ffffffe000201920:	00078513          	mv	a0,a5
ffffffe000201924:	01813083          	ld	ra,24(sp)
ffffffe000201928:	01013403          	ld	s0,16(sp)
ffffffe00020192c:	02010113          	addi	sp,sp,32
ffffffe000201930:	00008067          	ret

ffffffe000201934 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe000201934:	fe010113          	addi	sp,sp,-32
ffffffe000201938:	00813c23          	sd	s0,24(sp)
ffffffe00020193c:	02010413          	addi	s0,sp,32
ffffffe000201940:	00050793          	mv	a5,a0
ffffffe000201944:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000201948:	fec42783          	lw	a5,-20(s0)
ffffffe00020194c:	0007871b          	sext.w	a4,a5
ffffffe000201950:	02000793          	li	a5,32
ffffffe000201954:	02f70263          	beq	a4,a5,ffffffe000201978 <isspace+0x44>
ffffffe000201958:	fec42783          	lw	a5,-20(s0)
ffffffe00020195c:	0007871b          	sext.w	a4,a5
ffffffe000201960:	00800793          	li	a5,8
ffffffe000201964:	00e7de63          	bge	a5,a4,ffffffe000201980 <isspace+0x4c>
ffffffe000201968:	fec42783          	lw	a5,-20(s0)
ffffffe00020196c:	0007871b          	sext.w	a4,a5
ffffffe000201970:	00d00793          	li	a5,13
ffffffe000201974:	00e7c663          	blt	a5,a4,ffffffe000201980 <isspace+0x4c>
ffffffe000201978:	00100793          	li	a5,1
ffffffe00020197c:	0080006f          	j	ffffffe000201984 <isspace+0x50>
ffffffe000201980:	00000793          	li	a5,0
}
ffffffe000201984:	00078513          	mv	a0,a5
ffffffe000201988:	01813403          	ld	s0,24(sp)
ffffffe00020198c:	02010113          	addi	sp,sp,32
ffffffe000201990:	00008067          	ret

ffffffe000201994 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe000201994:	fb010113          	addi	sp,sp,-80
ffffffe000201998:	04113423          	sd	ra,72(sp)
ffffffe00020199c:	04813023          	sd	s0,64(sp)
ffffffe0002019a0:	05010413          	addi	s0,sp,80
ffffffe0002019a4:	fca43423          	sd	a0,-56(s0)
ffffffe0002019a8:	fcb43023          	sd	a1,-64(s0)
ffffffe0002019ac:	00060793          	mv	a5,a2
ffffffe0002019b0:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe0002019b4:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe0002019b8:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe0002019bc:	fc843783          	ld	a5,-56(s0)
ffffffe0002019c0:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe0002019c4:	0100006f          	j	ffffffe0002019d4 <strtol+0x40>
        p++;
ffffffe0002019c8:	fd843783          	ld	a5,-40(s0)
ffffffe0002019cc:	00178793          	addi	a5,a5,1
ffffffe0002019d0:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe0002019d4:	fd843783          	ld	a5,-40(s0)
ffffffe0002019d8:	0007c783          	lbu	a5,0(a5)
ffffffe0002019dc:	0007879b          	sext.w	a5,a5
ffffffe0002019e0:	00078513          	mv	a0,a5
ffffffe0002019e4:	f51ff0ef          	jal	ffffffe000201934 <isspace>
ffffffe0002019e8:	00050793          	mv	a5,a0
ffffffe0002019ec:	fc079ee3          	bnez	a5,ffffffe0002019c8 <strtol+0x34>
    }

    if (*p == '-') {
ffffffe0002019f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002019f4:	0007c783          	lbu	a5,0(a5)
ffffffe0002019f8:	00078713          	mv	a4,a5
ffffffe0002019fc:	02d00793          	li	a5,45
ffffffe000201a00:	00f71e63          	bne	a4,a5,ffffffe000201a1c <strtol+0x88>
        neg = true;
ffffffe000201a04:	00100793          	li	a5,1
ffffffe000201a08:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe000201a0c:	fd843783          	ld	a5,-40(s0)
ffffffe000201a10:	00178793          	addi	a5,a5,1
ffffffe000201a14:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201a18:	0240006f          	j	ffffffe000201a3c <strtol+0xa8>
    } else if (*p == '+') {
ffffffe000201a1c:	fd843783          	ld	a5,-40(s0)
ffffffe000201a20:	0007c783          	lbu	a5,0(a5)
ffffffe000201a24:	00078713          	mv	a4,a5
ffffffe000201a28:	02b00793          	li	a5,43
ffffffe000201a2c:	00f71863          	bne	a4,a5,ffffffe000201a3c <strtol+0xa8>
        p++;
ffffffe000201a30:	fd843783          	ld	a5,-40(s0)
ffffffe000201a34:	00178793          	addi	a5,a5,1
ffffffe000201a38:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe000201a3c:	fbc42783          	lw	a5,-68(s0)
ffffffe000201a40:	0007879b          	sext.w	a5,a5
ffffffe000201a44:	06079c63          	bnez	a5,ffffffe000201abc <strtol+0x128>
        if (*p == '0') {
ffffffe000201a48:	fd843783          	ld	a5,-40(s0)
ffffffe000201a4c:	0007c783          	lbu	a5,0(a5)
ffffffe000201a50:	00078713          	mv	a4,a5
ffffffe000201a54:	03000793          	li	a5,48
ffffffe000201a58:	04f71e63          	bne	a4,a5,ffffffe000201ab4 <strtol+0x120>
            p++;
ffffffe000201a5c:	fd843783          	ld	a5,-40(s0)
ffffffe000201a60:	00178793          	addi	a5,a5,1
ffffffe000201a64:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe000201a68:	fd843783          	ld	a5,-40(s0)
ffffffe000201a6c:	0007c783          	lbu	a5,0(a5)
ffffffe000201a70:	00078713          	mv	a4,a5
ffffffe000201a74:	07800793          	li	a5,120
ffffffe000201a78:	00f70c63          	beq	a4,a5,ffffffe000201a90 <strtol+0xfc>
ffffffe000201a7c:	fd843783          	ld	a5,-40(s0)
ffffffe000201a80:	0007c783          	lbu	a5,0(a5)
ffffffe000201a84:	00078713          	mv	a4,a5
ffffffe000201a88:	05800793          	li	a5,88
ffffffe000201a8c:	00f71e63          	bne	a4,a5,ffffffe000201aa8 <strtol+0x114>
                base = 16;
ffffffe000201a90:	01000793          	li	a5,16
ffffffe000201a94:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe000201a98:	fd843783          	ld	a5,-40(s0)
ffffffe000201a9c:	00178793          	addi	a5,a5,1
ffffffe000201aa0:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201aa4:	0180006f          	j	ffffffe000201abc <strtol+0x128>
            } else {
                base = 8;
ffffffe000201aa8:	00800793          	li	a5,8
ffffffe000201aac:	faf42e23          	sw	a5,-68(s0)
ffffffe000201ab0:	00c0006f          	j	ffffffe000201abc <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe000201ab4:	00a00793          	li	a5,10
ffffffe000201ab8:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe000201abc:	fd843783          	ld	a5,-40(s0)
ffffffe000201ac0:	0007c783          	lbu	a5,0(a5)
ffffffe000201ac4:	00078713          	mv	a4,a5
ffffffe000201ac8:	02f00793          	li	a5,47
ffffffe000201acc:	02e7f863          	bgeu	a5,a4,ffffffe000201afc <strtol+0x168>
ffffffe000201ad0:	fd843783          	ld	a5,-40(s0)
ffffffe000201ad4:	0007c783          	lbu	a5,0(a5)
ffffffe000201ad8:	00078713          	mv	a4,a5
ffffffe000201adc:	03900793          	li	a5,57
ffffffe000201ae0:	00e7ee63          	bltu	a5,a4,ffffffe000201afc <strtol+0x168>
            digit = *p - '0';
ffffffe000201ae4:	fd843783          	ld	a5,-40(s0)
ffffffe000201ae8:	0007c783          	lbu	a5,0(a5)
ffffffe000201aec:	0007879b          	sext.w	a5,a5
ffffffe000201af0:	fd07879b          	addiw	a5,a5,-48
ffffffe000201af4:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201af8:	0800006f          	j	ffffffe000201b78 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe000201afc:	fd843783          	ld	a5,-40(s0)
ffffffe000201b00:	0007c783          	lbu	a5,0(a5)
ffffffe000201b04:	00078713          	mv	a4,a5
ffffffe000201b08:	06000793          	li	a5,96
ffffffe000201b0c:	02e7f863          	bgeu	a5,a4,ffffffe000201b3c <strtol+0x1a8>
ffffffe000201b10:	fd843783          	ld	a5,-40(s0)
ffffffe000201b14:	0007c783          	lbu	a5,0(a5)
ffffffe000201b18:	00078713          	mv	a4,a5
ffffffe000201b1c:	07a00793          	li	a5,122
ffffffe000201b20:	00e7ee63          	bltu	a5,a4,ffffffe000201b3c <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe000201b24:	fd843783          	ld	a5,-40(s0)
ffffffe000201b28:	0007c783          	lbu	a5,0(a5)
ffffffe000201b2c:	0007879b          	sext.w	a5,a5
ffffffe000201b30:	fa97879b          	addiw	a5,a5,-87
ffffffe000201b34:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201b38:	0400006f          	j	ffffffe000201b78 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe000201b3c:	fd843783          	ld	a5,-40(s0)
ffffffe000201b40:	0007c783          	lbu	a5,0(a5)
ffffffe000201b44:	00078713          	mv	a4,a5
ffffffe000201b48:	04000793          	li	a5,64
ffffffe000201b4c:	06e7f863          	bgeu	a5,a4,ffffffe000201bbc <strtol+0x228>
ffffffe000201b50:	fd843783          	ld	a5,-40(s0)
ffffffe000201b54:	0007c783          	lbu	a5,0(a5)
ffffffe000201b58:	00078713          	mv	a4,a5
ffffffe000201b5c:	05a00793          	li	a5,90
ffffffe000201b60:	04e7ee63          	bltu	a5,a4,ffffffe000201bbc <strtol+0x228>
            digit = *p - ('A' - 10);
ffffffe000201b64:	fd843783          	ld	a5,-40(s0)
ffffffe000201b68:	0007c783          	lbu	a5,0(a5)
ffffffe000201b6c:	0007879b          	sext.w	a5,a5
ffffffe000201b70:	fc97879b          	addiw	a5,a5,-55
ffffffe000201b74:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe000201b78:	fd442783          	lw	a5,-44(s0)
ffffffe000201b7c:	00078713          	mv	a4,a5
ffffffe000201b80:	fbc42783          	lw	a5,-68(s0)
ffffffe000201b84:	0007071b          	sext.w	a4,a4
ffffffe000201b88:	0007879b          	sext.w	a5,a5
ffffffe000201b8c:	02f75663          	bge	a4,a5,ffffffe000201bb8 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
ffffffe000201b90:	fbc42703          	lw	a4,-68(s0)
ffffffe000201b94:	fe843783          	ld	a5,-24(s0)
ffffffe000201b98:	02f70733          	mul	a4,a4,a5
ffffffe000201b9c:	fd442783          	lw	a5,-44(s0)
ffffffe000201ba0:	00f707b3          	add	a5,a4,a5
ffffffe000201ba4:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe000201ba8:	fd843783          	ld	a5,-40(s0)
ffffffe000201bac:	00178793          	addi	a5,a5,1
ffffffe000201bb0:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe000201bb4:	f09ff06f          	j	ffffffe000201abc <strtol+0x128>
            break;
ffffffe000201bb8:	00000013          	nop
    }

    if (endptr) {
ffffffe000201bbc:	fc043783          	ld	a5,-64(s0)
ffffffe000201bc0:	00078863          	beqz	a5,ffffffe000201bd0 <strtol+0x23c>
        *endptr = (char *)p;
ffffffe000201bc4:	fc043783          	ld	a5,-64(s0)
ffffffe000201bc8:	fd843703          	ld	a4,-40(s0)
ffffffe000201bcc:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe000201bd0:	fe744783          	lbu	a5,-25(s0)
ffffffe000201bd4:	0ff7f793          	zext.b	a5,a5
ffffffe000201bd8:	00078863          	beqz	a5,ffffffe000201be8 <strtol+0x254>
ffffffe000201bdc:	fe843783          	ld	a5,-24(s0)
ffffffe000201be0:	40f007b3          	neg	a5,a5
ffffffe000201be4:	0080006f          	j	ffffffe000201bec <strtol+0x258>
ffffffe000201be8:	fe843783          	ld	a5,-24(s0)
}
ffffffe000201bec:	00078513          	mv	a0,a5
ffffffe000201bf0:	04813083          	ld	ra,72(sp)
ffffffe000201bf4:	04013403          	ld	s0,64(sp)
ffffffe000201bf8:	05010113          	addi	sp,sp,80
ffffffe000201bfc:	00008067          	ret

ffffffe000201c00 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe000201c00:	fd010113          	addi	sp,sp,-48
ffffffe000201c04:	02113423          	sd	ra,40(sp)
ffffffe000201c08:	02813023          	sd	s0,32(sp)
ffffffe000201c0c:	03010413          	addi	s0,sp,48
ffffffe000201c10:	fca43c23          	sd	a0,-40(s0)
ffffffe000201c14:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe000201c18:	fd043783          	ld	a5,-48(s0)
ffffffe000201c1c:	00079863          	bnez	a5,ffffffe000201c2c <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe000201c20:	00002797          	auipc	a5,0x2
ffffffe000201c24:	c3078793          	addi	a5,a5,-976 # ffffffe000203850 <_srodata+0x850>
ffffffe000201c28:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe000201c2c:	fd043783          	ld	a5,-48(s0)
ffffffe000201c30:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe000201c34:	0240006f          	j	ffffffe000201c58 <puts_wo_nl+0x58>
        putch(*p++);
ffffffe000201c38:	fe843783          	ld	a5,-24(s0)
ffffffe000201c3c:	00178713          	addi	a4,a5,1
ffffffe000201c40:	fee43423          	sd	a4,-24(s0)
ffffffe000201c44:	0007c783          	lbu	a5,0(a5)
ffffffe000201c48:	0007871b          	sext.w	a4,a5
ffffffe000201c4c:	fd843783          	ld	a5,-40(s0)
ffffffe000201c50:	00070513          	mv	a0,a4
ffffffe000201c54:	000780e7          	jalr	a5
    while (*p) {
ffffffe000201c58:	fe843783          	ld	a5,-24(s0)
ffffffe000201c5c:	0007c783          	lbu	a5,0(a5)
ffffffe000201c60:	fc079ce3          	bnez	a5,ffffffe000201c38 <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe000201c64:	fe843703          	ld	a4,-24(s0)
ffffffe000201c68:	fd043783          	ld	a5,-48(s0)
ffffffe000201c6c:	40f707b3          	sub	a5,a4,a5
ffffffe000201c70:	0007879b          	sext.w	a5,a5
}
ffffffe000201c74:	00078513          	mv	a0,a5
ffffffe000201c78:	02813083          	ld	ra,40(sp)
ffffffe000201c7c:	02013403          	ld	s0,32(sp)
ffffffe000201c80:	03010113          	addi	sp,sp,48
ffffffe000201c84:	00008067          	ret

ffffffe000201c88 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe000201c88:	f9010113          	addi	sp,sp,-112
ffffffe000201c8c:	06113423          	sd	ra,104(sp)
ffffffe000201c90:	06813023          	sd	s0,96(sp)
ffffffe000201c94:	07010413          	addi	s0,sp,112
ffffffe000201c98:	faa43423          	sd	a0,-88(s0)
ffffffe000201c9c:	fab43023          	sd	a1,-96(s0)
ffffffe000201ca0:	00060793          	mv	a5,a2
ffffffe000201ca4:	f8d43823          	sd	a3,-112(s0)
ffffffe000201ca8:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe000201cac:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201cb0:	0ff7f793          	zext.b	a5,a5
ffffffe000201cb4:	02078663          	beqz	a5,ffffffe000201ce0 <print_dec_int+0x58>
ffffffe000201cb8:	fa043703          	ld	a4,-96(s0)
ffffffe000201cbc:	fff00793          	li	a5,-1
ffffffe000201cc0:	03f79793          	slli	a5,a5,0x3f
ffffffe000201cc4:	00f71e63          	bne	a4,a5,ffffffe000201ce0 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe000201cc8:	00002597          	auipc	a1,0x2
ffffffe000201ccc:	b9058593          	addi	a1,a1,-1136 # ffffffe000203858 <_srodata+0x858>
ffffffe000201cd0:	fa843503          	ld	a0,-88(s0)
ffffffe000201cd4:	f2dff0ef          	jal	ffffffe000201c00 <puts_wo_nl>
ffffffe000201cd8:	00050793          	mv	a5,a0
ffffffe000201cdc:	2a00006f          	j	ffffffe000201f7c <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe000201ce0:	f9043783          	ld	a5,-112(s0)
ffffffe000201ce4:	00c7a783          	lw	a5,12(a5)
ffffffe000201ce8:	00079a63          	bnez	a5,ffffffe000201cfc <print_dec_int+0x74>
ffffffe000201cec:	fa043783          	ld	a5,-96(s0)
ffffffe000201cf0:	00079663          	bnez	a5,ffffffe000201cfc <print_dec_int+0x74>
        return 0;
ffffffe000201cf4:	00000793          	li	a5,0
ffffffe000201cf8:	2840006f          	j	ffffffe000201f7c <print_dec_int+0x2f4>
    }

    bool neg = false;
ffffffe000201cfc:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe000201d00:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201d04:	0ff7f793          	zext.b	a5,a5
ffffffe000201d08:	02078063          	beqz	a5,ffffffe000201d28 <print_dec_int+0xa0>
ffffffe000201d0c:	fa043783          	ld	a5,-96(s0)
ffffffe000201d10:	0007dc63          	bgez	a5,ffffffe000201d28 <print_dec_int+0xa0>
        neg = true;
ffffffe000201d14:	00100793          	li	a5,1
ffffffe000201d18:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe000201d1c:	fa043783          	ld	a5,-96(s0)
ffffffe000201d20:	40f007b3          	neg	a5,a5
ffffffe000201d24:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe000201d28:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe000201d2c:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201d30:	0ff7f793          	zext.b	a5,a5
ffffffe000201d34:	02078863          	beqz	a5,ffffffe000201d64 <print_dec_int+0xdc>
ffffffe000201d38:	fef44783          	lbu	a5,-17(s0)
ffffffe000201d3c:	0ff7f793          	zext.b	a5,a5
ffffffe000201d40:	00079e63          	bnez	a5,ffffffe000201d5c <print_dec_int+0xd4>
ffffffe000201d44:	f9043783          	ld	a5,-112(s0)
ffffffe000201d48:	0057c783          	lbu	a5,5(a5)
ffffffe000201d4c:	00079863          	bnez	a5,ffffffe000201d5c <print_dec_int+0xd4>
ffffffe000201d50:	f9043783          	ld	a5,-112(s0)
ffffffe000201d54:	0047c783          	lbu	a5,4(a5)
ffffffe000201d58:	00078663          	beqz	a5,ffffffe000201d64 <print_dec_int+0xdc>
ffffffe000201d5c:	00100793          	li	a5,1
ffffffe000201d60:	0080006f          	j	ffffffe000201d68 <print_dec_int+0xe0>
ffffffe000201d64:	00000793          	li	a5,0
ffffffe000201d68:	fcf40ba3          	sb	a5,-41(s0)
ffffffe000201d6c:	fd744783          	lbu	a5,-41(s0)
ffffffe000201d70:	0017f793          	andi	a5,a5,1
ffffffe000201d74:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe000201d78:	fa043703          	ld	a4,-96(s0)
ffffffe000201d7c:	00a00793          	li	a5,10
ffffffe000201d80:	02f777b3          	remu	a5,a4,a5
ffffffe000201d84:	0ff7f713          	zext.b	a4,a5
ffffffe000201d88:	fe842783          	lw	a5,-24(s0)
ffffffe000201d8c:	0017869b          	addiw	a3,a5,1
ffffffe000201d90:	fed42423          	sw	a3,-24(s0)
ffffffe000201d94:	0307071b          	addiw	a4,a4,48
ffffffe000201d98:	0ff77713          	zext.b	a4,a4
ffffffe000201d9c:	ff078793          	addi	a5,a5,-16
ffffffe000201da0:	008787b3          	add	a5,a5,s0
ffffffe000201da4:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe000201da8:	fa043703          	ld	a4,-96(s0)
ffffffe000201dac:	00a00793          	li	a5,10
ffffffe000201db0:	02f757b3          	divu	a5,a4,a5
ffffffe000201db4:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe000201db8:	fa043783          	ld	a5,-96(s0)
ffffffe000201dbc:	fa079ee3          	bnez	a5,ffffffe000201d78 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe000201dc0:	f9043783          	ld	a5,-112(s0)
ffffffe000201dc4:	00c7a783          	lw	a5,12(a5)
ffffffe000201dc8:	00078713          	mv	a4,a5
ffffffe000201dcc:	fff00793          	li	a5,-1
ffffffe000201dd0:	02f71063          	bne	a4,a5,ffffffe000201df0 <print_dec_int+0x168>
ffffffe000201dd4:	f9043783          	ld	a5,-112(s0)
ffffffe000201dd8:	0037c783          	lbu	a5,3(a5)
ffffffe000201ddc:	00078a63          	beqz	a5,ffffffe000201df0 <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe000201de0:	f9043783          	ld	a5,-112(s0)
ffffffe000201de4:	0087a703          	lw	a4,8(a5)
ffffffe000201de8:	f9043783          	ld	a5,-112(s0)
ffffffe000201dec:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe000201df0:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000201df4:	f9043783          	ld	a5,-112(s0)
ffffffe000201df8:	0087a703          	lw	a4,8(a5)
ffffffe000201dfc:	fe842783          	lw	a5,-24(s0)
ffffffe000201e00:	fcf42823          	sw	a5,-48(s0)
ffffffe000201e04:	f9043783          	ld	a5,-112(s0)
ffffffe000201e08:	00c7a783          	lw	a5,12(a5)
ffffffe000201e0c:	fcf42623          	sw	a5,-52(s0)
ffffffe000201e10:	fd042783          	lw	a5,-48(s0)
ffffffe000201e14:	00078593          	mv	a1,a5
ffffffe000201e18:	fcc42783          	lw	a5,-52(s0)
ffffffe000201e1c:	00078613          	mv	a2,a5
ffffffe000201e20:	0006069b          	sext.w	a3,a2
ffffffe000201e24:	0005879b          	sext.w	a5,a1
ffffffe000201e28:	00f6d463          	bge	a3,a5,ffffffe000201e30 <print_dec_int+0x1a8>
ffffffe000201e2c:	00058613          	mv	a2,a1
ffffffe000201e30:	0006079b          	sext.w	a5,a2
ffffffe000201e34:	40f707bb          	subw	a5,a4,a5
ffffffe000201e38:	0007871b          	sext.w	a4,a5
ffffffe000201e3c:	fd744783          	lbu	a5,-41(s0)
ffffffe000201e40:	0007879b          	sext.w	a5,a5
ffffffe000201e44:	40f707bb          	subw	a5,a4,a5
ffffffe000201e48:	fef42023          	sw	a5,-32(s0)
ffffffe000201e4c:	0280006f          	j	ffffffe000201e74 <print_dec_int+0x1ec>
        putch(' ');
ffffffe000201e50:	fa843783          	ld	a5,-88(s0)
ffffffe000201e54:	02000513          	li	a0,32
ffffffe000201e58:	000780e7          	jalr	a5
        ++written;
ffffffe000201e5c:	fe442783          	lw	a5,-28(s0)
ffffffe000201e60:	0017879b          	addiw	a5,a5,1
ffffffe000201e64:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000201e68:	fe042783          	lw	a5,-32(s0)
ffffffe000201e6c:	fff7879b          	addiw	a5,a5,-1
ffffffe000201e70:	fef42023          	sw	a5,-32(s0)
ffffffe000201e74:	fe042783          	lw	a5,-32(s0)
ffffffe000201e78:	0007879b          	sext.w	a5,a5
ffffffe000201e7c:	fcf04ae3          	bgtz	a5,ffffffe000201e50 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
ffffffe000201e80:	fd744783          	lbu	a5,-41(s0)
ffffffe000201e84:	0ff7f793          	zext.b	a5,a5
ffffffe000201e88:	04078463          	beqz	a5,ffffffe000201ed0 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe000201e8c:	fef44783          	lbu	a5,-17(s0)
ffffffe000201e90:	0ff7f793          	zext.b	a5,a5
ffffffe000201e94:	00078663          	beqz	a5,ffffffe000201ea0 <print_dec_int+0x218>
ffffffe000201e98:	02d00793          	li	a5,45
ffffffe000201e9c:	01c0006f          	j	ffffffe000201eb8 <print_dec_int+0x230>
ffffffe000201ea0:	f9043783          	ld	a5,-112(s0)
ffffffe000201ea4:	0057c783          	lbu	a5,5(a5)
ffffffe000201ea8:	00078663          	beqz	a5,ffffffe000201eb4 <print_dec_int+0x22c>
ffffffe000201eac:	02b00793          	li	a5,43
ffffffe000201eb0:	0080006f          	j	ffffffe000201eb8 <print_dec_int+0x230>
ffffffe000201eb4:	02000793          	li	a5,32
ffffffe000201eb8:	fa843703          	ld	a4,-88(s0)
ffffffe000201ebc:	00078513          	mv	a0,a5
ffffffe000201ec0:	000700e7          	jalr	a4
        ++written;
ffffffe000201ec4:	fe442783          	lw	a5,-28(s0)
ffffffe000201ec8:	0017879b          	addiw	a5,a5,1
ffffffe000201ecc:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000201ed0:	fe842783          	lw	a5,-24(s0)
ffffffe000201ed4:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201ed8:	0280006f          	j	ffffffe000201f00 <print_dec_int+0x278>
        putch('0');
ffffffe000201edc:	fa843783          	ld	a5,-88(s0)
ffffffe000201ee0:	03000513          	li	a0,48
ffffffe000201ee4:	000780e7          	jalr	a5
        ++written;
ffffffe000201ee8:	fe442783          	lw	a5,-28(s0)
ffffffe000201eec:	0017879b          	addiw	a5,a5,1
ffffffe000201ef0:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000201ef4:	fdc42783          	lw	a5,-36(s0)
ffffffe000201ef8:	0017879b          	addiw	a5,a5,1
ffffffe000201efc:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201f00:	f9043783          	ld	a5,-112(s0)
ffffffe000201f04:	00c7a703          	lw	a4,12(a5)
ffffffe000201f08:	fd744783          	lbu	a5,-41(s0)
ffffffe000201f0c:	0007879b          	sext.w	a5,a5
ffffffe000201f10:	40f707bb          	subw	a5,a4,a5
ffffffe000201f14:	0007871b          	sext.w	a4,a5
ffffffe000201f18:	fdc42783          	lw	a5,-36(s0)
ffffffe000201f1c:	0007879b          	sext.w	a5,a5
ffffffe000201f20:	fae7cee3          	blt	a5,a4,ffffffe000201edc <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000201f24:	fe842783          	lw	a5,-24(s0)
ffffffe000201f28:	fff7879b          	addiw	a5,a5,-1
ffffffe000201f2c:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201f30:	03c0006f          	j	ffffffe000201f6c <print_dec_int+0x2e4>
        putch(buf[i]);
ffffffe000201f34:	fd842783          	lw	a5,-40(s0)
ffffffe000201f38:	ff078793          	addi	a5,a5,-16
ffffffe000201f3c:	008787b3          	add	a5,a5,s0
ffffffe000201f40:	fc87c783          	lbu	a5,-56(a5)
ffffffe000201f44:	0007871b          	sext.w	a4,a5
ffffffe000201f48:	fa843783          	ld	a5,-88(s0)
ffffffe000201f4c:	00070513          	mv	a0,a4
ffffffe000201f50:	000780e7          	jalr	a5
        ++written;
ffffffe000201f54:	fe442783          	lw	a5,-28(s0)
ffffffe000201f58:	0017879b          	addiw	a5,a5,1
ffffffe000201f5c:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000201f60:	fd842783          	lw	a5,-40(s0)
ffffffe000201f64:	fff7879b          	addiw	a5,a5,-1
ffffffe000201f68:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201f6c:	fd842783          	lw	a5,-40(s0)
ffffffe000201f70:	0007879b          	sext.w	a5,a5
ffffffe000201f74:	fc07d0e3          	bgez	a5,ffffffe000201f34 <print_dec_int+0x2ac>
    }

    return written;
ffffffe000201f78:	fe442783          	lw	a5,-28(s0)
}
ffffffe000201f7c:	00078513          	mv	a0,a5
ffffffe000201f80:	06813083          	ld	ra,104(sp)
ffffffe000201f84:	06013403          	ld	s0,96(sp)
ffffffe000201f88:	07010113          	addi	sp,sp,112
ffffffe000201f8c:	00008067          	ret

ffffffe000201f90 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe000201f90:	f4010113          	addi	sp,sp,-192
ffffffe000201f94:	0a113c23          	sd	ra,184(sp)
ffffffe000201f98:	0a813823          	sd	s0,176(sp)
ffffffe000201f9c:	0c010413          	addi	s0,sp,192
ffffffe000201fa0:	f4a43c23          	sd	a0,-168(s0)
ffffffe000201fa4:	f4b43823          	sd	a1,-176(s0)
ffffffe000201fa8:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe000201fac:	f8043023          	sd	zero,-128(s0)
ffffffe000201fb0:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe000201fb4:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe000201fb8:	7a40006f          	j	ffffffe00020275c <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe000201fbc:	f8044783          	lbu	a5,-128(s0)
ffffffe000201fc0:	72078e63          	beqz	a5,ffffffe0002026fc <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe000201fc4:	f5043783          	ld	a5,-176(s0)
ffffffe000201fc8:	0007c783          	lbu	a5,0(a5)
ffffffe000201fcc:	00078713          	mv	a4,a5
ffffffe000201fd0:	02300793          	li	a5,35
ffffffe000201fd4:	00f71863          	bne	a4,a5,ffffffe000201fe4 <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe000201fd8:	00100793          	li	a5,1
ffffffe000201fdc:	f8f40123          	sb	a5,-126(s0)
ffffffe000201fe0:	7700006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe000201fe4:	f5043783          	ld	a5,-176(s0)
ffffffe000201fe8:	0007c783          	lbu	a5,0(a5)
ffffffe000201fec:	00078713          	mv	a4,a5
ffffffe000201ff0:	03000793          	li	a5,48
ffffffe000201ff4:	00f71863          	bne	a4,a5,ffffffe000202004 <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe000201ff8:	00100793          	li	a5,1
ffffffe000201ffc:	f8f401a3          	sb	a5,-125(s0)
ffffffe000202000:	7500006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe000202004:	f5043783          	ld	a5,-176(s0)
ffffffe000202008:	0007c783          	lbu	a5,0(a5)
ffffffe00020200c:	00078713          	mv	a4,a5
ffffffe000202010:	06c00793          	li	a5,108
ffffffe000202014:	04f70063          	beq	a4,a5,ffffffe000202054 <vprintfmt+0xc4>
ffffffe000202018:	f5043783          	ld	a5,-176(s0)
ffffffe00020201c:	0007c783          	lbu	a5,0(a5)
ffffffe000202020:	00078713          	mv	a4,a5
ffffffe000202024:	07a00793          	li	a5,122
ffffffe000202028:	02f70663          	beq	a4,a5,ffffffe000202054 <vprintfmt+0xc4>
ffffffe00020202c:	f5043783          	ld	a5,-176(s0)
ffffffe000202030:	0007c783          	lbu	a5,0(a5)
ffffffe000202034:	00078713          	mv	a4,a5
ffffffe000202038:	07400793          	li	a5,116
ffffffe00020203c:	00f70c63          	beq	a4,a5,ffffffe000202054 <vprintfmt+0xc4>
ffffffe000202040:	f5043783          	ld	a5,-176(s0)
ffffffe000202044:	0007c783          	lbu	a5,0(a5)
ffffffe000202048:	00078713          	mv	a4,a5
ffffffe00020204c:	06a00793          	li	a5,106
ffffffe000202050:	00f71863          	bne	a4,a5,ffffffe000202060 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe000202054:	00100793          	li	a5,1
ffffffe000202058:	f8f400a3          	sb	a5,-127(s0)
ffffffe00020205c:	6f40006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe000202060:	f5043783          	ld	a5,-176(s0)
ffffffe000202064:	0007c783          	lbu	a5,0(a5)
ffffffe000202068:	00078713          	mv	a4,a5
ffffffe00020206c:	02b00793          	li	a5,43
ffffffe000202070:	00f71863          	bne	a4,a5,ffffffe000202080 <vprintfmt+0xf0>
                flags.sign = true;
ffffffe000202074:	00100793          	li	a5,1
ffffffe000202078:	f8f402a3          	sb	a5,-123(s0)
ffffffe00020207c:	6d40006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe000202080:	f5043783          	ld	a5,-176(s0)
ffffffe000202084:	0007c783          	lbu	a5,0(a5)
ffffffe000202088:	00078713          	mv	a4,a5
ffffffe00020208c:	02000793          	li	a5,32
ffffffe000202090:	00f71863          	bne	a4,a5,ffffffe0002020a0 <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe000202094:	00100793          	li	a5,1
ffffffe000202098:	f8f40223          	sb	a5,-124(s0)
ffffffe00020209c:	6b40006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe0002020a0:	f5043783          	ld	a5,-176(s0)
ffffffe0002020a4:	0007c783          	lbu	a5,0(a5)
ffffffe0002020a8:	00078713          	mv	a4,a5
ffffffe0002020ac:	02a00793          	li	a5,42
ffffffe0002020b0:	00f71e63          	bne	a4,a5,ffffffe0002020cc <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe0002020b4:	f4843783          	ld	a5,-184(s0)
ffffffe0002020b8:	00878713          	addi	a4,a5,8
ffffffe0002020bc:	f4e43423          	sd	a4,-184(s0)
ffffffe0002020c0:	0007a783          	lw	a5,0(a5)
ffffffe0002020c4:	f8f42423          	sw	a5,-120(s0)
ffffffe0002020c8:	6880006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe0002020cc:	f5043783          	ld	a5,-176(s0)
ffffffe0002020d0:	0007c783          	lbu	a5,0(a5)
ffffffe0002020d4:	00078713          	mv	a4,a5
ffffffe0002020d8:	03000793          	li	a5,48
ffffffe0002020dc:	04e7f663          	bgeu	a5,a4,ffffffe000202128 <vprintfmt+0x198>
ffffffe0002020e0:	f5043783          	ld	a5,-176(s0)
ffffffe0002020e4:	0007c783          	lbu	a5,0(a5)
ffffffe0002020e8:	00078713          	mv	a4,a5
ffffffe0002020ec:	03900793          	li	a5,57
ffffffe0002020f0:	02e7ec63          	bltu	a5,a4,ffffffe000202128 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe0002020f4:	f5043783          	ld	a5,-176(s0)
ffffffe0002020f8:	f5040713          	addi	a4,s0,-176
ffffffe0002020fc:	00a00613          	li	a2,10
ffffffe000202100:	00070593          	mv	a1,a4
ffffffe000202104:	00078513          	mv	a0,a5
ffffffe000202108:	88dff0ef          	jal	ffffffe000201994 <strtol>
ffffffe00020210c:	00050793          	mv	a5,a0
ffffffe000202110:	0007879b          	sext.w	a5,a5
ffffffe000202114:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe000202118:	f5043783          	ld	a5,-176(s0)
ffffffe00020211c:	fff78793          	addi	a5,a5,-1
ffffffe000202120:	f4f43823          	sd	a5,-176(s0)
ffffffe000202124:	62c0006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe000202128:	f5043783          	ld	a5,-176(s0)
ffffffe00020212c:	0007c783          	lbu	a5,0(a5)
ffffffe000202130:	00078713          	mv	a4,a5
ffffffe000202134:	02e00793          	li	a5,46
ffffffe000202138:	06f71863          	bne	a4,a5,ffffffe0002021a8 <vprintfmt+0x218>
                fmt++;
ffffffe00020213c:	f5043783          	ld	a5,-176(s0)
ffffffe000202140:	00178793          	addi	a5,a5,1
ffffffe000202144:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe000202148:	f5043783          	ld	a5,-176(s0)
ffffffe00020214c:	0007c783          	lbu	a5,0(a5)
ffffffe000202150:	00078713          	mv	a4,a5
ffffffe000202154:	02a00793          	li	a5,42
ffffffe000202158:	00f71e63          	bne	a4,a5,ffffffe000202174 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe00020215c:	f4843783          	ld	a5,-184(s0)
ffffffe000202160:	00878713          	addi	a4,a5,8
ffffffe000202164:	f4e43423          	sd	a4,-184(s0)
ffffffe000202168:	0007a783          	lw	a5,0(a5)
ffffffe00020216c:	f8f42623          	sw	a5,-116(s0)
ffffffe000202170:	5e00006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe000202174:	f5043783          	ld	a5,-176(s0)
ffffffe000202178:	f5040713          	addi	a4,s0,-176
ffffffe00020217c:	00a00613          	li	a2,10
ffffffe000202180:	00070593          	mv	a1,a4
ffffffe000202184:	00078513          	mv	a0,a5
ffffffe000202188:	80dff0ef          	jal	ffffffe000201994 <strtol>
ffffffe00020218c:	00050793          	mv	a5,a0
ffffffe000202190:	0007879b          	sext.w	a5,a5
ffffffe000202194:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe000202198:	f5043783          	ld	a5,-176(s0)
ffffffe00020219c:	fff78793          	addi	a5,a5,-1
ffffffe0002021a0:	f4f43823          	sd	a5,-176(s0)
ffffffe0002021a4:	5ac0006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe0002021a8:	f5043783          	ld	a5,-176(s0)
ffffffe0002021ac:	0007c783          	lbu	a5,0(a5)
ffffffe0002021b0:	00078713          	mv	a4,a5
ffffffe0002021b4:	07800793          	li	a5,120
ffffffe0002021b8:	02f70663          	beq	a4,a5,ffffffe0002021e4 <vprintfmt+0x254>
ffffffe0002021bc:	f5043783          	ld	a5,-176(s0)
ffffffe0002021c0:	0007c783          	lbu	a5,0(a5)
ffffffe0002021c4:	00078713          	mv	a4,a5
ffffffe0002021c8:	05800793          	li	a5,88
ffffffe0002021cc:	00f70c63          	beq	a4,a5,ffffffe0002021e4 <vprintfmt+0x254>
ffffffe0002021d0:	f5043783          	ld	a5,-176(s0)
ffffffe0002021d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002021d8:	00078713          	mv	a4,a5
ffffffe0002021dc:	07000793          	li	a5,112
ffffffe0002021e0:	30f71263          	bne	a4,a5,ffffffe0002024e4 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe0002021e4:	f5043783          	ld	a5,-176(s0)
ffffffe0002021e8:	0007c783          	lbu	a5,0(a5)
ffffffe0002021ec:	00078713          	mv	a4,a5
ffffffe0002021f0:	07000793          	li	a5,112
ffffffe0002021f4:	00f70663          	beq	a4,a5,ffffffe000202200 <vprintfmt+0x270>
ffffffe0002021f8:	f8144783          	lbu	a5,-127(s0)
ffffffe0002021fc:	00078663          	beqz	a5,ffffffe000202208 <vprintfmt+0x278>
ffffffe000202200:	00100793          	li	a5,1
ffffffe000202204:	0080006f          	j	ffffffe00020220c <vprintfmt+0x27c>
ffffffe000202208:	00000793          	li	a5,0
ffffffe00020220c:	faf403a3          	sb	a5,-89(s0)
ffffffe000202210:	fa744783          	lbu	a5,-89(s0)
ffffffe000202214:	0017f793          	andi	a5,a5,1
ffffffe000202218:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe00020221c:	fa744783          	lbu	a5,-89(s0)
ffffffe000202220:	0ff7f793          	zext.b	a5,a5
ffffffe000202224:	00078c63          	beqz	a5,ffffffe00020223c <vprintfmt+0x2ac>
ffffffe000202228:	f4843783          	ld	a5,-184(s0)
ffffffe00020222c:	00878713          	addi	a4,a5,8
ffffffe000202230:	f4e43423          	sd	a4,-184(s0)
ffffffe000202234:	0007b783          	ld	a5,0(a5)
ffffffe000202238:	01c0006f          	j	ffffffe000202254 <vprintfmt+0x2c4>
ffffffe00020223c:	f4843783          	ld	a5,-184(s0)
ffffffe000202240:	00878713          	addi	a4,a5,8
ffffffe000202244:	f4e43423          	sd	a4,-184(s0)
ffffffe000202248:	0007a783          	lw	a5,0(a5)
ffffffe00020224c:	02079793          	slli	a5,a5,0x20
ffffffe000202250:	0207d793          	srli	a5,a5,0x20
ffffffe000202254:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe000202258:	f8c42783          	lw	a5,-116(s0)
ffffffe00020225c:	02079463          	bnez	a5,ffffffe000202284 <vprintfmt+0x2f4>
ffffffe000202260:	fe043783          	ld	a5,-32(s0)
ffffffe000202264:	02079063          	bnez	a5,ffffffe000202284 <vprintfmt+0x2f4>
ffffffe000202268:	f5043783          	ld	a5,-176(s0)
ffffffe00020226c:	0007c783          	lbu	a5,0(a5)
ffffffe000202270:	00078713          	mv	a4,a5
ffffffe000202274:	07000793          	li	a5,112
ffffffe000202278:	00f70663          	beq	a4,a5,ffffffe000202284 <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe00020227c:	f8040023          	sb	zero,-128(s0)
ffffffe000202280:	4d00006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe000202284:	f5043783          	ld	a5,-176(s0)
ffffffe000202288:	0007c783          	lbu	a5,0(a5)
ffffffe00020228c:	00078713          	mv	a4,a5
ffffffe000202290:	07000793          	li	a5,112
ffffffe000202294:	00f70a63          	beq	a4,a5,ffffffe0002022a8 <vprintfmt+0x318>
ffffffe000202298:	f8244783          	lbu	a5,-126(s0)
ffffffe00020229c:	00078a63          	beqz	a5,ffffffe0002022b0 <vprintfmt+0x320>
ffffffe0002022a0:	fe043783          	ld	a5,-32(s0)
ffffffe0002022a4:	00078663          	beqz	a5,ffffffe0002022b0 <vprintfmt+0x320>
ffffffe0002022a8:	00100793          	li	a5,1
ffffffe0002022ac:	0080006f          	j	ffffffe0002022b4 <vprintfmt+0x324>
ffffffe0002022b0:	00000793          	li	a5,0
ffffffe0002022b4:	faf40323          	sb	a5,-90(s0)
ffffffe0002022b8:	fa644783          	lbu	a5,-90(s0)
ffffffe0002022bc:	0017f793          	andi	a5,a5,1
ffffffe0002022c0:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe0002022c4:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe0002022c8:	f5043783          	ld	a5,-176(s0)
ffffffe0002022cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002022d0:	00078713          	mv	a4,a5
ffffffe0002022d4:	05800793          	li	a5,88
ffffffe0002022d8:	00f71863          	bne	a4,a5,ffffffe0002022e8 <vprintfmt+0x358>
ffffffe0002022dc:	00001797          	auipc	a5,0x1
ffffffe0002022e0:	59478793          	addi	a5,a5,1428 # ffffffe000203870 <upperxdigits.1>
ffffffe0002022e4:	00c0006f          	j	ffffffe0002022f0 <vprintfmt+0x360>
ffffffe0002022e8:	00001797          	auipc	a5,0x1
ffffffe0002022ec:	5a078793          	addi	a5,a5,1440 # ffffffe000203888 <lowerxdigits.0>
ffffffe0002022f0:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe0002022f4:	fe043783          	ld	a5,-32(s0)
ffffffe0002022f8:	00f7f793          	andi	a5,a5,15
ffffffe0002022fc:	f9843703          	ld	a4,-104(s0)
ffffffe000202300:	00f70733          	add	a4,a4,a5
ffffffe000202304:	fdc42783          	lw	a5,-36(s0)
ffffffe000202308:	0017869b          	addiw	a3,a5,1
ffffffe00020230c:	fcd42e23          	sw	a3,-36(s0)
ffffffe000202310:	00074703          	lbu	a4,0(a4)
ffffffe000202314:	ff078793          	addi	a5,a5,-16
ffffffe000202318:	008787b3          	add	a5,a5,s0
ffffffe00020231c:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe000202320:	fe043783          	ld	a5,-32(s0)
ffffffe000202324:	0047d793          	srli	a5,a5,0x4
ffffffe000202328:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe00020232c:	fe043783          	ld	a5,-32(s0)
ffffffe000202330:	fc0792e3          	bnez	a5,ffffffe0002022f4 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe000202334:	f8c42783          	lw	a5,-116(s0)
ffffffe000202338:	00078713          	mv	a4,a5
ffffffe00020233c:	fff00793          	li	a5,-1
ffffffe000202340:	02f71663          	bne	a4,a5,ffffffe00020236c <vprintfmt+0x3dc>
ffffffe000202344:	f8344783          	lbu	a5,-125(s0)
ffffffe000202348:	02078263          	beqz	a5,ffffffe00020236c <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe00020234c:	f8842703          	lw	a4,-120(s0)
ffffffe000202350:	fa644783          	lbu	a5,-90(s0)
ffffffe000202354:	0007879b          	sext.w	a5,a5
ffffffe000202358:	0017979b          	slliw	a5,a5,0x1
ffffffe00020235c:	0007879b          	sext.w	a5,a5
ffffffe000202360:	40f707bb          	subw	a5,a4,a5
ffffffe000202364:	0007879b          	sext.w	a5,a5
ffffffe000202368:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe00020236c:	f8842703          	lw	a4,-120(s0)
ffffffe000202370:	fa644783          	lbu	a5,-90(s0)
ffffffe000202374:	0007879b          	sext.w	a5,a5
ffffffe000202378:	0017979b          	slliw	a5,a5,0x1
ffffffe00020237c:	0007879b          	sext.w	a5,a5
ffffffe000202380:	40f707bb          	subw	a5,a4,a5
ffffffe000202384:	0007871b          	sext.w	a4,a5
ffffffe000202388:	fdc42783          	lw	a5,-36(s0)
ffffffe00020238c:	f8f42a23          	sw	a5,-108(s0)
ffffffe000202390:	f8c42783          	lw	a5,-116(s0)
ffffffe000202394:	f8f42823          	sw	a5,-112(s0)
ffffffe000202398:	f9442783          	lw	a5,-108(s0)
ffffffe00020239c:	00078593          	mv	a1,a5
ffffffe0002023a0:	f9042783          	lw	a5,-112(s0)
ffffffe0002023a4:	00078613          	mv	a2,a5
ffffffe0002023a8:	0006069b          	sext.w	a3,a2
ffffffe0002023ac:	0005879b          	sext.w	a5,a1
ffffffe0002023b0:	00f6d463          	bge	a3,a5,ffffffe0002023b8 <vprintfmt+0x428>
ffffffe0002023b4:	00058613          	mv	a2,a1
ffffffe0002023b8:	0006079b          	sext.w	a5,a2
ffffffe0002023bc:	40f707bb          	subw	a5,a4,a5
ffffffe0002023c0:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002023c4:	0280006f          	j	ffffffe0002023ec <vprintfmt+0x45c>
                    putch(' ');
ffffffe0002023c8:	f5843783          	ld	a5,-168(s0)
ffffffe0002023cc:	02000513          	li	a0,32
ffffffe0002023d0:	000780e7          	jalr	a5
                    ++written;
ffffffe0002023d4:	fec42783          	lw	a5,-20(s0)
ffffffe0002023d8:	0017879b          	addiw	a5,a5,1
ffffffe0002023dc:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe0002023e0:	fd842783          	lw	a5,-40(s0)
ffffffe0002023e4:	fff7879b          	addiw	a5,a5,-1
ffffffe0002023e8:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002023ec:	fd842783          	lw	a5,-40(s0)
ffffffe0002023f0:	0007879b          	sext.w	a5,a5
ffffffe0002023f4:	fcf04ae3          	bgtz	a5,ffffffe0002023c8 <vprintfmt+0x438>
                }

                if (prefix) {
ffffffe0002023f8:	fa644783          	lbu	a5,-90(s0)
ffffffe0002023fc:	0ff7f793          	zext.b	a5,a5
ffffffe000202400:	04078463          	beqz	a5,ffffffe000202448 <vprintfmt+0x4b8>
                    putch('0');
ffffffe000202404:	f5843783          	ld	a5,-168(s0)
ffffffe000202408:	03000513          	li	a0,48
ffffffe00020240c:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000202410:	f5043783          	ld	a5,-176(s0)
ffffffe000202414:	0007c783          	lbu	a5,0(a5)
ffffffe000202418:	00078713          	mv	a4,a5
ffffffe00020241c:	05800793          	li	a5,88
ffffffe000202420:	00f71663          	bne	a4,a5,ffffffe00020242c <vprintfmt+0x49c>
ffffffe000202424:	05800793          	li	a5,88
ffffffe000202428:	0080006f          	j	ffffffe000202430 <vprintfmt+0x4a0>
ffffffe00020242c:	07800793          	li	a5,120
ffffffe000202430:	f5843703          	ld	a4,-168(s0)
ffffffe000202434:	00078513          	mv	a0,a5
ffffffe000202438:	000700e7          	jalr	a4
                    written += 2;
ffffffe00020243c:	fec42783          	lw	a5,-20(s0)
ffffffe000202440:	0027879b          	addiw	a5,a5,2
ffffffe000202444:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000202448:	fdc42783          	lw	a5,-36(s0)
ffffffe00020244c:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202450:	0280006f          	j	ffffffe000202478 <vprintfmt+0x4e8>
                    putch('0');
ffffffe000202454:	f5843783          	ld	a5,-168(s0)
ffffffe000202458:	03000513          	li	a0,48
ffffffe00020245c:	000780e7          	jalr	a5
                    ++written;
ffffffe000202460:	fec42783          	lw	a5,-20(s0)
ffffffe000202464:	0017879b          	addiw	a5,a5,1
ffffffe000202468:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe00020246c:	fd442783          	lw	a5,-44(s0)
ffffffe000202470:	0017879b          	addiw	a5,a5,1
ffffffe000202474:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202478:	f8c42703          	lw	a4,-116(s0)
ffffffe00020247c:	fd442783          	lw	a5,-44(s0)
ffffffe000202480:	0007879b          	sext.w	a5,a5
ffffffe000202484:	fce7c8e3          	blt	a5,a4,ffffffe000202454 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000202488:	fdc42783          	lw	a5,-36(s0)
ffffffe00020248c:	fff7879b          	addiw	a5,a5,-1
ffffffe000202490:	fcf42823          	sw	a5,-48(s0)
ffffffe000202494:	03c0006f          	j	ffffffe0002024d0 <vprintfmt+0x540>
                    putch(buf[i]);
ffffffe000202498:	fd042783          	lw	a5,-48(s0)
ffffffe00020249c:	ff078793          	addi	a5,a5,-16
ffffffe0002024a0:	008787b3          	add	a5,a5,s0
ffffffe0002024a4:	f807c783          	lbu	a5,-128(a5)
ffffffe0002024a8:	0007871b          	sext.w	a4,a5
ffffffe0002024ac:	f5843783          	ld	a5,-168(s0)
ffffffe0002024b0:	00070513          	mv	a0,a4
ffffffe0002024b4:	000780e7          	jalr	a5
                    ++written;
ffffffe0002024b8:	fec42783          	lw	a5,-20(s0)
ffffffe0002024bc:	0017879b          	addiw	a5,a5,1
ffffffe0002024c0:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe0002024c4:	fd042783          	lw	a5,-48(s0)
ffffffe0002024c8:	fff7879b          	addiw	a5,a5,-1
ffffffe0002024cc:	fcf42823          	sw	a5,-48(s0)
ffffffe0002024d0:	fd042783          	lw	a5,-48(s0)
ffffffe0002024d4:	0007879b          	sext.w	a5,a5
ffffffe0002024d8:	fc07d0e3          	bgez	a5,ffffffe000202498 <vprintfmt+0x508>
                }

                flags.in_format = false;
ffffffe0002024dc:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe0002024e0:	2700006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe0002024e4:	f5043783          	ld	a5,-176(s0)
ffffffe0002024e8:	0007c783          	lbu	a5,0(a5)
ffffffe0002024ec:	00078713          	mv	a4,a5
ffffffe0002024f0:	06400793          	li	a5,100
ffffffe0002024f4:	02f70663          	beq	a4,a5,ffffffe000202520 <vprintfmt+0x590>
ffffffe0002024f8:	f5043783          	ld	a5,-176(s0)
ffffffe0002024fc:	0007c783          	lbu	a5,0(a5)
ffffffe000202500:	00078713          	mv	a4,a5
ffffffe000202504:	06900793          	li	a5,105
ffffffe000202508:	00f70c63          	beq	a4,a5,ffffffe000202520 <vprintfmt+0x590>
ffffffe00020250c:	f5043783          	ld	a5,-176(s0)
ffffffe000202510:	0007c783          	lbu	a5,0(a5)
ffffffe000202514:	00078713          	mv	a4,a5
ffffffe000202518:	07500793          	li	a5,117
ffffffe00020251c:	08f71063          	bne	a4,a5,ffffffe00020259c <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000202520:	f8144783          	lbu	a5,-127(s0)
ffffffe000202524:	00078c63          	beqz	a5,ffffffe00020253c <vprintfmt+0x5ac>
ffffffe000202528:	f4843783          	ld	a5,-184(s0)
ffffffe00020252c:	00878713          	addi	a4,a5,8
ffffffe000202530:	f4e43423          	sd	a4,-184(s0)
ffffffe000202534:	0007b783          	ld	a5,0(a5)
ffffffe000202538:	0140006f          	j	ffffffe00020254c <vprintfmt+0x5bc>
ffffffe00020253c:	f4843783          	ld	a5,-184(s0)
ffffffe000202540:	00878713          	addi	a4,a5,8
ffffffe000202544:	f4e43423          	sd	a4,-184(s0)
ffffffe000202548:	0007a783          	lw	a5,0(a5)
ffffffe00020254c:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe000202550:	fa843583          	ld	a1,-88(s0)
ffffffe000202554:	f5043783          	ld	a5,-176(s0)
ffffffe000202558:	0007c783          	lbu	a5,0(a5)
ffffffe00020255c:	0007871b          	sext.w	a4,a5
ffffffe000202560:	07500793          	li	a5,117
ffffffe000202564:	40f707b3          	sub	a5,a4,a5
ffffffe000202568:	00f037b3          	snez	a5,a5
ffffffe00020256c:	0ff7f793          	zext.b	a5,a5
ffffffe000202570:	f8040713          	addi	a4,s0,-128
ffffffe000202574:	00070693          	mv	a3,a4
ffffffe000202578:	00078613          	mv	a2,a5
ffffffe00020257c:	f5843503          	ld	a0,-168(s0)
ffffffe000202580:	f08ff0ef          	jal	ffffffe000201c88 <print_dec_int>
ffffffe000202584:	00050793          	mv	a5,a0
ffffffe000202588:	fec42703          	lw	a4,-20(s0)
ffffffe00020258c:	00f707bb          	addw	a5,a4,a5
ffffffe000202590:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202594:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000202598:	1b80006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe00020259c:	f5043783          	ld	a5,-176(s0)
ffffffe0002025a0:	0007c783          	lbu	a5,0(a5)
ffffffe0002025a4:	00078713          	mv	a4,a5
ffffffe0002025a8:	06e00793          	li	a5,110
ffffffe0002025ac:	04f71c63          	bne	a4,a5,ffffffe000202604 <vprintfmt+0x674>
                if (flags.longflag) {
ffffffe0002025b0:	f8144783          	lbu	a5,-127(s0)
ffffffe0002025b4:	02078463          	beqz	a5,ffffffe0002025dc <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
ffffffe0002025b8:	f4843783          	ld	a5,-184(s0)
ffffffe0002025bc:	00878713          	addi	a4,a5,8
ffffffe0002025c0:	f4e43423          	sd	a4,-184(s0)
ffffffe0002025c4:	0007b783          	ld	a5,0(a5)
ffffffe0002025c8:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe0002025cc:	fec42703          	lw	a4,-20(s0)
ffffffe0002025d0:	fb043783          	ld	a5,-80(s0)
ffffffe0002025d4:	00e7b023          	sd	a4,0(a5)
ffffffe0002025d8:	0240006f          	j	ffffffe0002025fc <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe0002025dc:	f4843783          	ld	a5,-184(s0)
ffffffe0002025e0:	00878713          	addi	a4,a5,8
ffffffe0002025e4:	f4e43423          	sd	a4,-184(s0)
ffffffe0002025e8:	0007b783          	ld	a5,0(a5)
ffffffe0002025ec:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe0002025f0:	fb843783          	ld	a5,-72(s0)
ffffffe0002025f4:	fec42703          	lw	a4,-20(s0)
ffffffe0002025f8:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe0002025fc:	f8040023          	sb	zero,-128(s0)
ffffffe000202600:	1500006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe000202604:	f5043783          	ld	a5,-176(s0)
ffffffe000202608:	0007c783          	lbu	a5,0(a5)
ffffffe00020260c:	00078713          	mv	a4,a5
ffffffe000202610:	07300793          	li	a5,115
ffffffe000202614:	02f71e63          	bne	a4,a5,ffffffe000202650 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe000202618:	f4843783          	ld	a5,-184(s0)
ffffffe00020261c:	00878713          	addi	a4,a5,8
ffffffe000202620:	f4e43423          	sd	a4,-184(s0)
ffffffe000202624:	0007b783          	ld	a5,0(a5)
ffffffe000202628:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe00020262c:	fc043583          	ld	a1,-64(s0)
ffffffe000202630:	f5843503          	ld	a0,-168(s0)
ffffffe000202634:	dccff0ef          	jal	ffffffe000201c00 <puts_wo_nl>
ffffffe000202638:	00050793          	mv	a5,a0
ffffffe00020263c:	fec42703          	lw	a4,-20(s0)
ffffffe000202640:	00f707bb          	addw	a5,a4,a5
ffffffe000202644:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202648:	f8040023          	sb	zero,-128(s0)
ffffffe00020264c:	1040006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe000202650:	f5043783          	ld	a5,-176(s0)
ffffffe000202654:	0007c783          	lbu	a5,0(a5)
ffffffe000202658:	00078713          	mv	a4,a5
ffffffe00020265c:	06300793          	li	a5,99
ffffffe000202660:	02f71e63          	bne	a4,a5,ffffffe00020269c <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe000202664:	f4843783          	ld	a5,-184(s0)
ffffffe000202668:	00878713          	addi	a4,a5,8
ffffffe00020266c:	f4e43423          	sd	a4,-184(s0)
ffffffe000202670:	0007a783          	lw	a5,0(a5)
ffffffe000202674:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000202678:	fcc42703          	lw	a4,-52(s0)
ffffffe00020267c:	f5843783          	ld	a5,-168(s0)
ffffffe000202680:	00070513          	mv	a0,a4
ffffffe000202684:	000780e7          	jalr	a5
                ++written;
ffffffe000202688:	fec42783          	lw	a5,-20(s0)
ffffffe00020268c:	0017879b          	addiw	a5,a5,1
ffffffe000202690:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202694:	f8040023          	sb	zero,-128(s0)
ffffffe000202698:	0b80006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe00020269c:	f5043783          	ld	a5,-176(s0)
ffffffe0002026a0:	0007c783          	lbu	a5,0(a5)
ffffffe0002026a4:	00078713          	mv	a4,a5
ffffffe0002026a8:	02500793          	li	a5,37
ffffffe0002026ac:	02f71263          	bne	a4,a5,ffffffe0002026d0 <vprintfmt+0x740>
                putch('%');
ffffffe0002026b0:	f5843783          	ld	a5,-168(s0)
ffffffe0002026b4:	02500513          	li	a0,37
ffffffe0002026b8:	000780e7          	jalr	a5
                ++written;
ffffffe0002026bc:	fec42783          	lw	a5,-20(s0)
ffffffe0002026c0:	0017879b          	addiw	a5,a5,1
ffffffe0002026c4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002026c8:	f8040023          	sb	zero,-128(s0)
ffffffe0002026cc:	0840006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe0002026d0:	f5043783          	ld	a5,-176(s0)
ffffffe0002026d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002026d8:	0007871b          	sext.w	a4,a5
ffffffe0002026dc:	f5843783          	ld	a5,-168(s0)
ffffffe0002026e0:	00070513          	mv	a0,a4
ffffffe0002026e4:	000780e7          	jalr	a5
                ++written;
ffffffe0002026e8:	fec42783          	lw	a5,-20(s0)
ffffffe0002026ec:	0017879b          	addiw	a5,a5,1
ffffffe0002026f0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002026f4:	f8040023          	sb	zero,-128(s0)
ffffffe0002026f8:	0580006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe0002026fc:	f5043783          	ld	a5,-176(s0)
ffffffe000202700:	0007c783          	lbu	a5,0(a5)
ffffffe000202704:	00078713          	mv	a4,a5
ffffffe000202708:	02500793          	li	a5,37
ffffffe00020270c:	02f71063          	bne	a4,a5,ffffffe00020272c <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe000202710:	f8043023          	sd	zero,-128(s0)
ffffffe000202714:	f8043423          	sd	zero,-120(s0)
ffffffe000202718:	00100793          	li	a5,1
ffffffe00020271c:	f8f40023          	sb	a5,-128(s0)
ffffffe000202720:	fff00793          	li	a5,-1
ffffffe000202724:	f8f42623          	sw	a5,-116(s0)
ffffffe000202728:	0280006f          	j	ffffffe000202750 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe00020272c:	f5043783          	ld	a5,-176(s0)
ffffffe000202730:	0007c783          	lbu	a5,0(a5)
ffffffe000202734:	0007871b          	sext.w	a4,a5
ffffffe000202738:	f5843783          	ld	a5,-168(s0)
ffffffe00020273c:	00070513          	mv	a0,a4
ffffffe000202740:	000780e7          	jalr	a5
            ++written;
ffffffe000202744:	fec42783          	lw	a5,-20(s0)
ffffffe000202748:	0017879b          	addiw	a5,a5,1
ffffffe00020274c:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe000202750:	f5043783          	ld	a5,-176(s0)
ffffffe000202754:	00178793          	addi	a5,a5,1
ffffffe000202758:	f4f43823          	sd	a5,-176(s0)
ffffffe00020275c:	f5043783          	ld	a5,-176(s0)
ffffffe000202760:	0007c783          	lbu	a5,0(a5)
ffffffe000202764:	84079ce3          	bnez	a5,ffffffe000201fbc <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000202768:	fec42783          	lw	a5,-20(s0)
}
ffffffe00020276c:	00078513          	mv	a0,a5
ffffffe000202770:	0b813083          	ld	ra,184(sp)
ffffffe000202774:	0b013403          	ld	s0,176(sp)
ffffffe000202778:	0c010113          	addi	sp,sp,192
ffffffe00020277c:	00008067          	ret

ffffffe000202780 <printk>:

int printk(const char* s, ...) {
ffffffe000202780:	f9010113          	addi	sp,sp,-112
ffffffe000202784:	02113423          	sd	ra,40(sp)
ffffffe000202788:	02813023          	sd	s0,32(sp)
ffffffe00020278c:	03010413          	addi	s0,sp,48
ffffffe000202790:	fca43c23          	sd	a0,-40(s0)
ffffffe000202794:	00b43423          	sd	a1,8(s0)
ffffffe000202798:	00c43823          	sd	a2,16(s0)
ffffffe00020279c:	00d43c23          	sd	a3,24(s0)
ffffffe0002027a0:	02e43023          	sd	a4,32(s0)
ffffffe0002027a4:	02f43423          	sd	a5,40(s0)
ffffffe0002027a8:	03043823          	sd	a6,48(s0)
ffffffe0002027ac:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe0002027b0:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe0002027b4:	04040793          	addi	a5,s0,64
ffffffe0002027b8:	fcf43823          	sd	a5,-48(s0)
ffffffe0002027bc:	fd043783          	ld	a5,-48(s0)
ffffffe0002027c0:	fc878793          	addi	a5,a5,-56
ffffffe0002027c4:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe0002027c8:	fe043783          	ld	a5,-32(s0)
ffffffe0002027cc:	00078613          	mv	a2,a5
ffffffe0002027d0:	fd843583          	ld	a1,-40(s0)
ffffffe0002027d4:	fffff517          	auipc	a0,0xfffff
ffffffe0002027d8:	11850513          	addi	a0,a0,280 # ffffffe0002018ec <putc>
ffffffe0002027dc:	fb4ff0ef          	jal	ffffffe000201f90 <vprintfmt>
ffffffe0002027e0:	00050793          	mv	a5,a0
ffffffe0002027e4:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe0002027e8:	fec42783          	lw	a5,-20(s0)
}
ffffffe0002027ec:	00078513          	mv	a0,a5
ffffffe0002027f0:	02813083          	ld	ra,40(sp)
ffffffe0002027f4:	02013403          	ld	s0,32(sp)
ffffffe0002027f8:	07010113          	addi	sp,sp,112
ffffffe0002027fc:	00008067          	ret

ffffffe000202800 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe000202800:	fe010113          	addi	sp,sp,-32
ffffffe000202804:	00813c23          	sd	s0,24(sp)
ffffffe000202808:	02010413          	addi	s0,sp,32
ffffffe00020280c:	00050793          	mv	a5,a0
ffffffe000202810:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe000202814:	fec42783          	lw	a5,-20(s0)
ffffffe000202818:	fff7879b          	addiw	a5,a5,-1
ffffffe00020281c:	0007879b          	sext.w	a5,a5
ffffffe000202820:	02079713          	slli	a4,a5,0x20
ffffffe000202824:	02075713          	srli	a4,a4,0x20
ffffffe000202828:	00003797          	auipc	a5,0x3
ffffffe00020282c:	7f878793          	addi	a5,a5,2040 # ffffffe000206020 <seed>
ffffffe000202830:	00e7b023          	sd	a4,0(a5)
}
ffffffe000202834:	00000013          	nop
ffffffe000202838:	01813403          	ld	s0,24(sp)
ffffffe00020283c:	02010113          	addi	sp,sp,32
ffffffe000202840:	00008067          	ret

ffffffe000202844 <rand>:

int rand(void) {
ffffffe000202844:	ff010113          	addi	sp,sp,-16
ffffffe000202848:	00813423          	sd	s0,8(sp)
ffffffe00020284c:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe000202850:	00003797          	auipc	a5,0x3
ffffffe000202854:	7d078793          	addi	a5,a5,2000 # ffffffe000206020 <seed>
ffffffe000202858:	0007b703          	ld	a4,0(a5)
ffffffe00020285c:	00001797          	auipc	a5,0x1
ffffffe000202860:	04478793          	addi	a5,a5,68 # ffffffe0002038a0 <lowerxdigits.0+0x18>
ffffffe000202864:	0007b783          	ld	a5,0(a5)
ffffffe000202868:	02f707b3          	mul	a5,a4,a5
ffffffe00020286c:	00178713          	addi	a4,a5,1
ffffffe000202870:	00003797          	auipc	a5,0x3
ffffffe000202874:	7b078793          	addi	a5,a5,1968 # ffffffe000206020 <seed>
ffffffe000202878:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe00020287c:	00003797          	auipc	a5,0x3
ffffffe000202880:	7a478793          	addi	a5,a5,1956 # ffffffe000206020 <seed>
ffffffe000202884:	0007b783          	ld	a5,0(a5)
ffffffe000202888:	0217d793          	srli	a5,a5,0x21
ffffffe00020288c:	0007879b          	sext.w	a5,a5
}
ffffffe000202890:	00078513          	mv	a0,a5
ffffffe000202894:	00813403          	ld	s0,8(sp)
ffffffe000202898:	01010113          	addi	sp,sp,16
ffffffe00020289c:	00008067          	ret

ffffffe0002028a0 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe0002028a0:	fc010113          	addi	sp,sp,-64
ffffffe0002028a4:	02813c23          	sd	s0,56(sp)
ffffffe0002028a8:	04010413          	addi	s0,sp,64
ffffffe0002028ac:	fca43c23          	sd	a0,-40(s0)
ffffffe0002028b0:	00058793          	mv	a5,a1
ffffffe0002028b4:	fcc43423          	sd	a2,-56(s0)
ffffffe0002028b8:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe0002028bc:	fd843783          	ld	a5,-40(s0)
ffffffe0002028c0:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe0002028c4:	fe043423          	sd	zero,-24(s0)
ffffffe0002028c8:	0280006f          	j	ffffffe0002028f0 <memset+0x50>
        s[i] = c;
ffffffe0002028cc:	fe043703          	ld	a4,-32(s0)
ffffffe0002028d0:	fe843783          	ld	a5,-24(s0)
ffffffe0002028d4:	00f707b3          	add	a5,a4,a5
ffffffe0002028d8:	fd442703          	lw	a4,-44(s0)
ffffffe0002028dc:	0ff77713          	zext.b	a4,a4
ffffffe0002028e0:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe0002028e4:	fe843783          	ld	a5,-24(s0)
ffffffe0002028e8:	00178793          	addi	a5,a5,1
ffffffe0002028ec:	fef43423          	sd	a5,-24(s0)
ffffffe0002028f0:	fe843703          	ld	a4,-24(s0)
ffffffe0002028f4:	fc843783          	ld	a5,-56(s0)
ffffffe0002028f8:	fcf76ae3          	bltu	a4,a5,ffffffe0002028cc <memset+0x2c>
    }
    return dest;
ffffffe0002028fc:	fd843783          	ld	a5,-40(s0)
}
ffffffe000202900:	00078513          	mv	a0,a5
ffffffe000202904:	03813403          	ld	s0,56(sp)
ffffffe000202908:	04010113          	addi	sp,sp,64
ffffffe00020290c:	00008067          	ret
