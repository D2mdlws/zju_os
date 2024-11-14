
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
ffffffe000200008:	3f0010ef          	jal	ffffffe0002013f8 <setup_vm>
    call relocate
ffffffe00020000c:	048000ef          	jal	ffffffe000200054 <relocate>

    call mm_init
ffffffe000200010:	418000ef          	jal	ffffffe000200428 <mm_init>
    call setup_vm_final
ffffffe000200014:	46c010ef          	jal	ffffffe000201480 <setup_vm_final>
    call task_init
ffffffe000200018:	454000ef          	jal	ffffffe00020046c <task_init>

    la t0, _traps;
ffffffe00020001c:	00000297          	auipc	t0,0x0
ffffffe000200020:	08828293          	addi	t0,t0,136 # ffffffe0002000a4 <_traps>
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
ffffffe000200044:	0ec010ef          	jal	ffffffe000201130 <sbi_set_timer>

    li t1, 0x2
ffffffe000200048:	00200313          	li	t1,2
    csrs sstatus, t1            # - set sstatus[SIE] = 1 -
ffffffe00020004c:	10032073          	csrs	sstatus,t1

    call start_kernel
ffffffe000200050:	035010ef          	jal	ffffffe000201884 <start_kernel>

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
    la t0, _traps
ffffffe000200094:	00000297          	auipc	t0,0x0
ffffffe000200098:	01028293          	addi	t0,t0,16 # ffffffe0002000a4 <_traps>
    csrw stvec, t0
ffffffe00020009c:	10529073          	csrw	stvec,t0
    ret
ffffffe0002000a0:	00008067          	ret

ffffffe0002000a4 <_traps>:
    .globl _traps 
_traps:

    # 1. save 32 registers and sepc to stack

    addi sp, sp, -33*8
ffffffe0002000a4:	ef810113          	addi	sp,sp,-264 # ffffffe000204ef8 <_edata+0xec7>

    sd x0, 0*8(sp)
ffffffe0002000a8:	00013023          	sd	zero,0(sp)
    sd x1, 1*8(sp)
ffffffe0002000ac:	00113423          	sd	ra,8(sp)
    sd x2, 2*8(sp)
ffffffe0002000b0:	00213823          	sd	sp,16(sp)
    sd x3, 3*8(sp)
ffffffe0002000b4:	00313c23          	sd	gp,24(sp)
    sd x4, 4*8(sp)
ffffffe0002000b8:	02413023          	sd	tp,32(sp)
    sd x5, 5*8(sp)
ffffffe0002000bc:	02513423          	sd	t0,40(sp)
    sd x6, 6*8(sp)
ffffffe0002000c0:	02613823          	sd	t1,48(sp)
    sd x7, 7*8(sp)
ffffffe0002000c4:	02713c23          	sd	t2,56(sp)
    sd x8, 8*8(sp)
ffffffe0002000c8:	04813023          	sd	s0,64(sp)
    sd x9, 9*8(sp)
ffffffe0002000cc:	04913423          	sd	s1,72(sp)
    sd x10, 10*8(sp)
ffffffe0002000d0:	04a13823          	sd	a0,80(sp)
    sd x11, 11*8(sp)
ffffffe0002000d4:	04b13c23          	sd	a1,88(sp)
    sd x12, 12*8(sp)
ffffffe0002000d8:	06c13023          	sd	a2,96(sp)
    sd x13, 13*8(sp)
ffffffe0002000dc:	06d13423          	sd	a3,104(sp)
    sd x14, 14*8(sp)
ffffffe0002000e0:	06e13823          	sd	a4,112(sp)
    sd x15, 15*8(sp)
ffffffe0002000e4:	06f13c23          	sd	a5,120(sp)
    sd x16, 16*8(sp)
ffffffe0002000e8:	09013023          	sd	a6,128(sp)
    sd x17, 17*8(sp)
ffffffe0002000ec:	09113423          	sd	a7,136(sp)
    sd x18, 18*8(sp)
ffffffe0002000f0:	09213823          	sd	s2,144(sp)
    sd x19, 19*8(sp)
ffffffe0002000f4:	09313c23          	sd	s3,152(sp)
    sd x20, 20*8(sp)
ffffffe0002000f8:	0b413023          	sd	s4,160(sp)
    sd x21, 21*8(sp)
ffffffe0002000fc:	0b513423          	sd	s5,168(sp)
    sd x22, 22*8(sp)
ffffffe000200100:	0b613823          	sd	s6,176(sp)
    sd x23, 23*8(sp)
ffffffe000200104:	0b713c23          	sd	s7,184(sp)
    sd x24, 24*8(sp)
ffffffe000200108:	0d813023          	sd	s8,192(sp)
    sd x25, 25*8(sp)
ffffffe00020010c:	0d913423          	sd	s9,200(sp)
    sd x26, 26*8(sp)
ffffffe000200110:	0da13823          	sd	s10,208(sp)
    sd x27, 27*8(sp)
ffffffe000200114:	0db13c23          	sd	s11,216(sp)
    sd x28, 28*8(sp)
ffffffe000200118:	0fc13023          	sd	t3,224(sp)
    sd x29, 29*8(sp)
ffffffe00020011c:	0fd13423          	sd	t4,232(sp)
    sd x30, 30*8(sp)
ffffffe000200120:	0fe13823          	sd	t5,240(sp)
    sd x31, 31*8(sp)
ffffffe000200124:	0ff13c23          	sd	t6,248(sp)

    csrr t0, sepc
ffffffe000200128:	141022f3          	csrr	t0,sepc
    sd t0, 32*8(sp)
ffffffe00020012c:	10513023          	sd	t0,256(sp)

    # 2. call trap_handler

    csrr t1, scause
ffffffe000200130:	14202373          	csrr	t1,scause
    mv a0, t1
ffffffe000200134:	00030513          	mv	a0,t1
    mv a1, t0
ffffffe000200138:	00028593          	mv	a1,t0
    call trap_handler
ffffffe00020013c:	1a8010ef          	jal	ffffffe0002012e4 <trap_handler>

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack

    ld x0, 0*8(sp)
ffffffe000200140:	00013003          	ld	zero,0(sp)
    ld x1, 1*8(sp)
ffffffe000200144:	00813083          	ld	ra,8(sp)
    ld x3, 3*8(sp)
ffffffe000200148:	01813183          	ld	gp,24(sp)
    ld x4, 4*8(sp)
ffffffe00020014c:	02013203          	ld	tp,32(sp)
    ld x5, 5*8(sp)
ffffffe000200150:	02813283          	ld	t0,40(sp)
    ld x6, 6*8(sp)
ffffffe000200154:	03013303          	ld	t1,48(sp)
    ld x7, 7*8(sp)
ffffffe000200158:	03813383          	ld	t2,56(sp)
    ld x8, 8*8(sp)
ffffffe00020015c:	04013403          	ld	s0,64(sp)
    ld x9, 9*8(sp)
ffffffe000200160:	04813483          	ld	s1,72(sp)
    ld x10, 10*8(sp)
ffffffe000200164:	05013503          	ld	a0,80(sp)
    ld x11, 11*8(sp)
ffffffe000200168:	05813583          	ld	a1,88(sp)
    ld x12, 12*8(sp)
ffffffe00020016c:	06013603          	ld	a2,96(sp)
    ld x13, 13*8(sp)
ffffffe000200170:	06813683          	ld	a3,104(sp)
    ld x14, 14*8(sp)
ffffffe000200174:	07013703          	ld	a4,112(sp)
    ld x15, 15*8(sp)
ffffffe000200178:	07813783          	ld	a5,120(sp)
    ld x16, 16*8(sp)
ffffffe00020017c:	08013803          	ld	a6,128(sp)
    ld x17, 17*8(sp)
ffffffe000200180:	08813883          	ld	a7,136(sp)
    ld x18, 18*8(sp)
ffffffe000200184:	09013903          	ld	s2,144(sp)
    ld x19, 19*8(sp)
ffffffe000200188:	09813983          	ld	s3,152(sp)
    ld x20, 20*8(sp)
ffffffe00020018c:	0a013a03          	ld	s4,160(sp)
    ld x21, 21*8(sp)
ffffffe000200190:	0a813a83          	ld	s5,168(sp)
    ld x22, 22*8(sp)
ffffffe000200194:	0b013b03          	ld	s6,176(sp)
    ld x23, 23*8(sp)
ffffffe000200198:	0b813b83          	ld	s7,184(sp)
    ld x24, 24*8(sp)    
ffffffe00020019c:	0c013c03          	ld	s8,192(sp)
    ld x25, 25*8(sp)
ffffffe0002001a0:	0c813c83          	ld	s9,200(sp)
    ld x26, 26*8(sp)
ffffffe0002001a4:	0d013d03          	ld	s10,208(sp)
    ld x27, 27*8(sp)
ffffffe0002001a8:	0d813d83          	ld	s11,216(sp)
    ld x28, 28*8(sp)
ffffffe0002001ac:	0e013e03          	ld	t3,224(sp)
    ld x29, 29*8(sp)
ffffffe0002001b0:	0e813e83          	ld	t4,232(sp)
    ld x30, 30*8(sp)
ffffffe0002001b4:	0f013f03          	ld	t5,240(sp)
    ld x31, 31*8(sp)
ffffffe0002001b8:	0f813f83          	ld	t6,248(sp)
    ld t0, 32*8(sp)
ffffffe0002001bc:	10013283          	ld	t0,256(sp)
    csrw sepc, t0
ffffffe0002001c0:	14129073          	csrw	sepc,t0
    ld x2, 2*8(sp)
ffffffe0002001c4:	01013103          	ld	sp,16(sp)

    addi sp, sp, 33*8
ffffffe0002001c8:	10810113          	addi	sp,sp,264

    # 4. return from trap

    sret
ffffffe0002001cc:	10200073          	sret

ffffffe0002001d0 <__dummy>:

    .extern dummy
    .globl __dummy
__dummy:

    la t0, dummy
ffffffe0002001d0:	00000297          	auipc	t0,0x0
ffffffe0002001d4:	50028293          	addi	t0,t0,1280 # ffffffe0002006d0 <dummy>
    csrw sepc, t0       # set sepc to dummy
ffffffe0002001d8:	14129073          	csrw	sepc,t0
    sret
ffffffe0002001dc:	10200073          	sret

ffffffe0002001e0 <__switch_to>:
    .globl __switch_to
__switch_to:
    # save state to prev process
    # YOUR CODE HERE

    addi a0, a0, 4*8            # let a0 point to process_struct
ffffffe0002001e0:	02050513          	addi	a0,a0,32

    sd ra, 0*8(a0)
ffffffe0002001e4:	00153023          	sd	ra,0(a0)
    sd sp, 1*8(a0)
ffffffe0002001e8:	00253423          	sd	sp,8(a0)
    sd s0, 2*8(a0)
ffffffe0002001ec:	00853823          	sd	s0,16(a0)
    sd s1, 3*8(a0)
ffffffe0002001f0:	00953c23          	sd	s1,24(a0)
    sd s2, 4*8(a0)
ffffffe0002001f4:	03253023          	sd	s2,32(a0)
    sd s3, 5*8(a0)
ffffffe0002001f8:	03353423          	sd	s3,40(a0)
    sd s4, 6*8(a0)
ffffffe0002001fc:	03453823          	sd	s4,48(a0)
    sd s5, 7*8(a0)
ffffffe000200200:	03553c23          	sd	s5,56(a0)
    sd s6, 8*8(a0)
ffffffe000200204:	05653023          	sd	s6,64(a0)
    sd s7, 9*8(a0)
ffffffe000200208:	05753423          	sd	s7,72(a0)
    sd s8, 10*8(a0)
ffffffe00020020c:	05853823          	sd	s8,80(a0)
    sd s9, 11*8(a0)
ffffffe000200210:	05953c23          	sd	s9,88(a0)
    sd s10, 12*8(a0)
ffffffe000200214:	07a53023          	sd	s10,96(a0)
    sd s11, 13*8(a0)
ffffffe000200218:	07b53423          	sd	s11,104(a0)


    # restore state from next process
    # YOUR CODE HERE

    addi a1, a1, 4*8            # let a1 point to process_struct
ffffffe00020021c:	02058593          	addi	a1,a1,32

    ld ra, 0*8(a1)
ffffffe000200220:	0005b083          	ld	ra,0(a1)
    ld sp,  1*8(a1)
ffffffe000200224:	0085b103          	ld	sp,8(a1)

    addi a1, a1, 2*8            # let a1 point to process_struct->s
ffffffe000200228:	01058593          	addi	a1,a1,16

    ld s0, 0*8(a1)
ffffffe00020022c:	0005b403          	ld	s0,0(a1)
    ld s1, 1*8(a1)
ffffffe000200230:	0085b483          	ld	s1,8(a1)
    ld s2, 2*8(a1)
ffffffe000200234:	0105b903          	ld	s2,16(a1)
    ld s3, 3*8(a1)
ffffffe000200238:	0185b983          	ld	s3,24(a1)
    ld s4, 4*8(a1)
ffffffe00020023c:	0205ba03          	ld	s4,32(a1)
    ld s5, 5*8(a1)
ffffffe000200240:	0285ba83          	ld	s5,40(a1)
    ld s6, 6*8(a1)
ffffffe000200244:	0305bb03          	ld	s6,48(a1)
    ld s7, 7*8(a1)
ffffffe000200248:	0385bb83          	ld	s7,56(a1)
    ld s8, 8*8(a1)
ffffffe00020024c:	0405bc03          	ld	s8,64(a1)
    ld s9, 9*8(a1)
ffffffe000200250:	0485bc83          	ld	s9,72(a1)
    ld s10, 10*8(a1)
ffffffe000200254:	0505bd03          	ld	s10,80(a1)
    ld s11, 11*8(a1)
ffffffe000200258:	0585bd83          	ld	s11,88(a1)

ffffffe00020025c:	00008067          	ret

ffffffe000200260 <get_cycles>:
#include "clock.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
ffffffe000200260:	fe010113          	addi	sp,sp,-32
ffffffe000200264:	00813c23          	sd	s0,24(sp)
ffffffe000200268:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    uint64_t time;
    __asm__ volatile(
ffffffe00020026c:	c01027f3          	rdtime	a5
ffffffe000200270:	fef43423          	sd	a5,-24(s0)
        "rdtime %[time]"
        : [time] "=r" (time)
    );
    return time;
ffffffe000200274:	fe843783          	ld	a5,-24(s0)
}
ffffffe000200278:	00078513          	mv	a0,a5
ffffffe00020027c:	01813403          	ld	s0,24(sp)
ffffffe000200280:	02010113          	addi	sp,sp,32
ffffffe000200284:	00008067          	ret

ffffffe000200288 <clock_set_next_event>:

void clock_set_next_event() {
ffffffe000200288:	fe010113          	addi	sp,sp,-32
ffffffe00020028c:	00113c23          	sd	ra,24(sp)
ffffffe000200290:	00813823          	sd	s0,16(sp)
ffffffe000200294:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
ffffffe000200298:	fc9ff0ef          	jal	ffffffe000200260 <get_cycles>
ffffffe00020029c:	00050713          	mv	a4,a0
ffffffe0002002a0:	00004797          	auipc	a5,0x4
ffffffe0002002a4:	d6078793          	addi	a5,a5,-672 # ffffffe000204000 <TIMECLOCK>
ffffffe0002002a8:	0007b783          	ld	a5,0(a5)
ffffffe0002002ac:	00f707b3          	add	a5,a4,a5
ffffffe0002002b0:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
ffffffe0002002b4:	fe843503          	ld	a0,-24(s0)
ffffffe0002002b8:	679000ef          	jal	ffffffe000201130 <sbi_set_timer>
ffffffe0002002bc:	00000013          	nop
ffffffe0002002c0:	01813083          	ld	ra,24(sp)
ffffffe0002002c4:	01013403          	ld	s0,16(sp)
ffffffe0002002c8:	02010113          	addi	sp,sp,32
ffffffe0002002cc:	00008067          	ret

ffffffe0002002d0 <kalloc>:

struct {
    struct run *freelist;
} kmem;

void *kalloc() {
ffffffe0002002d0:	fe010113          	addi	sp,sp,-32
ffffffe0002002d4:	00113c23          	sd	ra,24(sp)
ffffffe0002002d8:	00813823          	sd	s0,16(sp)
ffffffe0002002dc:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
ffffffe0002002e0:	00006797          	auipc	a5,0x6
ffffffe0002002e4:	d2078793          	addi	a5,a5,-736 # ffffffe000206000 <kmem>
ffffffe0002002e8:	0007b783          	ld	a5,0(a5)
ffffffe0002002ec:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
ffffffe0002002f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002002f4:	0007b703          	ld	a4,0(a5)
ffffffe0002002f8:	00006797          	auipc	a5,0x6
ffffffe0002002fc:	d0878793          	addi	a5,a5,-760 # ffffffe000206000 <kmem>
ffffffe000200300:	00e7b023          	sd	a4,0(a5)
    
    memset((void *)r, 0x0, PGSIZE);
ffffffe000200304:	00001637          	lui	a2,0x1
ffffffe000200308:	00000593          	li	a1,0
ffffffe00020030c:	fe843503          	ld	a0,-24(s0)
ffffffe000200310:	5b8020ef          	jal	ffffffe0002028c8 <memset>
    return (void *)r;
ffffffe000200314:	fe843783          	ld	a5,-24(s0)
}
ffffffe000200318:	00078513          	mv	a0,a5
ffffffe00020031c:	01813083          	ld	ra,24(sp)
ffffffe000200320:	01013403          	ld	s0,16(sp)
ffffffe000200324:	02010113          	addi	sp,sp,32
ffffffe000200328:	00008067          	ret

ffffffe00020032c <kfree>:

void kfree(void *addr) {
ffffffe00020032c:	fd010113          	addi	sp,sp,-48
ffffffe000200330:	02113423          	sd	ra,40(sp)
ffffffe000200334:	02813023          	sd	s0,32(sp)
ffffffe000200338:	03010413          	addi	s0,sp,48
ffffffe00020033c:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    *(uintptr_t *)&addr = (uintptr_t)addr & ~(PGSIZE - 1);
ffffffe000200340:	fd843783          	ld	a5,-40(s0)
ffffffe000200344:	00078693          	mv	a3,a5
ffffffe000200348:	fd840793          	addi	a5,s0,-40
ffffffe00020034c:	fffff737          	lui	a4,0xfffff
ffffffe000200350:	00e6f733          	and	a4,a3,a4
ffffffe000200354:	00e7b023          	sd	a4,0(a5)

    memset(addr, 0x0, (uint64_t)PGSIZE);
ffffffe000200358:	fd843783          	ld	a5,-40(s0)
ffffffe00020035c:	00001637          	lui	a2,0x1
ffffffe000200360:	00000593          	li	a1,0
ffffffe000200364:	00078513          	mv	a0,a5
ffffffe000200368:	560020ef          	jal	ffffffe0002028c8 <memset>

    r = (struct run *)addr;
ffffffe00020036c:	fd843783          	ld	a5,-40(s0)
ffffffe000200370:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
ffffffe000200374:	00006797          	auipc	a5,0x6
ffffffe000200378:	c8c78793          	addi	a5,a5,-884 # ffffffe000206000 <kmem>
ffffffe00020037c:	0007b703          	ld	a4,0(a5)
ffffffe000200380:	fe843783          	ld	a5,-24(s0)
ffffffe000200384:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
ffffffe000200388:	00006797          	auipc	a5,0x6
ffffffe00020038c:	c7878793          	addi	a5,a5,-904 # ffffffe000206000 <kmem>
ffffffe000200390:	fe843703          	ld	a4,-24(s0)
ffffffe000200394:	00e7b023          	sd	a4,0(a5)

    return;
ffffffe000200398:	00000013          	nop
}
ffffffe00020039c:	02813083          	ld	ra,40(sp)
ffffffe0002003a0:	02013403          	ld	s0,32(sp)
ffffffe0002003a4:	03010113          	addi	sp,sp,48
ffffffe0002003a8:	00008067          	ret

ffffffe0002003ac <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe0002003ac:	fd010113          	addi	sp,sp,-48
ffffffe0002003b0:	02113423          	sd	ra,40(sp)
ffffffe0002003b4:	02813023          	sd	s0,32(sp)
ffffffe0002003b8:	03010413          	addi	s0,sp,48
ffffffe0002003bc:	fca43c23          	sd	a0,-40(s0)
ffffffe0002003c0:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe0002003c4:	fd843703          	ld	a4,-40(s0)
ffffffe0002003c8:	000017b7          	lui	a5,0x1
ffffffe0002003cc:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe0002003d0:	00f70733          	add	a4,a4,a5
ffffffe0002003d4:	fffff7b7          	lui	a5,0xfffff
ffffffe0002003d8:	00f777b3          	and	a5,a4,a5
ffffffe0002003dc:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe0002003e0:	01c0006f          	j	ffffffe0002003fc <kfreerange+0x50>
        kfree((void *)addr);
ffffffe0002003e4:	fe843503          	ld	a0,-24(s0)
ffffffe0002003e8:	f45ff0ef          	jal	ffffffe00020032c <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe0002003ec:	fe843703          	ld	a4,-24(s0)
ffffffe0002003f0:	000017b7          	lui	a5,0x1
ffffffe0002003f4:	00f707b3          	add	a5,a4,a5
ffffffe0002003f8:	fef43423          	sd	a5,-24(s0)
ffffffe0002003fc:	fe843703          	ld	a4,-24(s0)
ffffffe000200400:	000017b7          	lui	a5,0x1
ffffffe000200404:	00f70733          	add	a4,a4,a5
ffffffe000200408:	fd043783          	ld	a5,-48(s0)
ffffffe00020040c:	fce7fce3          	bgeu	a5,a4,ffffffe0002003e4 <kfreerange+0x38>
    }
}
ffffffe000200410:	00000013          	nop
ffffffe000200414:	00000013          	nop
ffffffe000200418:	02813083          	ld	ra,40(sp)
ffffffe00020041c:	02013403          	ld	s0,32(sp)
ffffffe000200420:	03010113          	addi	sp,sp,48
ffffffe000200424:	00008067          	ret

ffffffe000200428 <mm_init>:

void mm_init(void) {
ffffffe000200428:	ff010113          	addi	sp,sp,-16
ffffffe00020042c:	00113423          	sd	ra,8(sp)
ffffffe000200430:	00813023          	sd	s0,0(sp)
ffffffe000200434:	01010413          	addi	s0,sp,16
    kfreerange(_ekernel, (char *)PHY_END + PA2VA_OFFSET);
ffffffe000200438:	c0100793          	li	a5,-1023
ffffffe00020043c:	01b79593          	slli	a1,a5,0x1b
ffffffe000200440:	00009517          	auipc	a0,0x9
ffffffe000200444:	bc050513          	addi	a0,a0,-1088 # ffffffe000209000 <_ebss>
ffffffe000200448:	f65ff0ef          	jal	ffffffe0002003ac <kfreerange>
    printk(BOLD FG_COLOR(255, 95, 00) "...mm_init done!\n" CLEAR);
ffffffe00020044c:	00003517          	auipc	a0,0x3
ffffffe000200450:	bb450513          	addi	a0,a0,-1100 # ffffffe000203000 <_srodata>
ffffffe000200454:	354020ef          	jal	ffffffe0002027a8 <printk>
}
ffffffe000200458:	00000013          	nop
ffffffe00020045c:	00813083          	ld	ra,8(sp)
ffffffe000200460:	00013403          	ld	s0,0(sp)
ffffffe000200464:	01010113          	addi	sp,sp,16
ffffffe000200468:	00008067          	ret

ffffffe00020046c <task_init>:

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此, the type in the array is pointer to task_struct

void task_init() {
ffffffe00020046c:	fe010113          	addi	sp,sp,-32
ffffffe000200470:	00113c23          	sd	ra,24(sp)
ffffffe000200474:	00813823          	sd	s0,16(sp)
ffffffe000200478:	02010413          	addi	s0,sp,32
    srand(2024);
ffffffe00020047c:	7e800513          	li	a0,2024
ffffffe000200480:	3a8020ef          	jal	ffffffe000202828 <srand>
    // 2. 设置 state 为 TASK_RUNNING;
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    // 4. 设置 idle 的 pid 为 0
    // 5. 将 current 和 task[0] 指向 idle

    idle = (struct task_struct *)kalloc();
ffffffe000200484:	e4dff0ef          	jal	ffffffe0002002d0 <kalloc>
ffffffe000200488:	00050713          	mv	a4,a0
ffffffe00020048c:	00006797          	auipc	a5,0x6
ffffffe000200490:	b7c78793          	addi	a5,a5,-1156 # ffffffe000206008 <idle>
ffffffe000200494:	00e7b023          	sd	a4,0(a5)

    idle->state = TASK_RUNNING;
ffffffe000200498:	00006797          	auipc	a5,0x6
ffffffe00020049c:	b7078793          	addi	a5,a5,-1168 # ffffffe000206008 <idle>
ffffffe0002004a0:	0007b783          	ld	a5,0(a5)
ffffffe0002004a4:	0007b023          	sd	zero,0(a5)

    idle->counter = 0;
ffffffe0002004a8:	00006797          	auipc	a5,0x6
ffffffe0002004ac:	b6078793          	addi	a5,a5,-1184 # ffffffe000206008 <idle>
ffffffe0002004b0:	0007b783          	ld	a5,0(a5)
ffffffe0002004b4:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
ffffffe0002004b8:	00006797          	auipc	a5,0x6
ffffffe0002004bc:	b5078793          	addi	a5,a5,-1200 # ffffffe000206008 <idle>
ffffffe0002004c0:	0007b783          	ld	a5,0(a5)
ffffffe0002004c4:	0007b823          	sd	zero,16(a5)

    idle->pid = 0;
ffffffe0002004c8:	00006797          	auipc	a5,0x6
ffffffe0002004cc:	b4078793          	addi	a5,a5,-1216 # ffffffe000206008 <idle>
ffffffe0002004d0:	0007b783          	ld	a5,0(a5)
ffffffe0002004d4:	0007bc23          	sd	zero,24(a5)

    current = idle;
ffffffe0002004d8:	00006797          	auipc	a5,0x6
ffffffe0002004dc:	b3078793          	addi	a5,a5,-1232 # ffffffe000206008 <idle>
ffffffe0002004e0:	0007b703          	ld	a4,0(a5)
ffffffe0002004e4:	00006797          	auipc	a5,0x6
ffffffe0002004e8:	b2c78793          	addi	a5,a5,-1236 # ffffffe000206010 <current>
ffffffe0002004ec:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe0002004f0:	00006797          	auipc	a5,0x6
ffffffe0002004f4:	b1878793          	addi	a5,a5,-1256 # ffffffe000206008 <idle>
ffffffe0002004f8:	0007b703          	ld	a4,0(a5)
ffffffe0002004fc:	00006797          	auipc	a5,0x6
ffffffe000200500:	b2c78793          	addi	a5,a5,-1236 # ffffffe000206028 <task>
ffffffe000200504:	00e7b023          	sd	a4,0(a5)
    //     - ra 设置为 __dummy（见 4.3.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    /* YOUR CODE HERE */

    for (int i = 1; i <= NR_TASKS - 1; i++) {
ffffffe000200508:	00100793          	li	a5,1
ffffffe00020050c:	fef42623          	sw	a5,-20(s0)
ffffffe000200510:	1900006f          	j	ffffffe0002006a0 <task_init+0x234>
        task[i] = (struct task_struct *)kalloc();
ffffffe000200514:	dbdff0ef          	jal	ffffffe0002002d0 <kalloc>
ffffffe000200518:	00050693          	mv	a3,a0
ffffffe00020051c:	00006717          	auipc	a4,0x6
ffffffe000200520:	b0c70713          	addi	a4,a4,-1268 # ffffffe000206028 <task>
ffffffe000200524:	fec42783          	lw	a5,-20(s0)
ffffffe000200528:	00379793          	slli	a5,a5,0x3
ffffffe00020052c:	00f707b3          	add	a5,a4,a5
ffffffe000200530:	00d7b023          	sd	a3,0(a5)

        task[i]->state = TASK_RUNNING;
ffffffe000200534:	00006717          	auipc	a4,0x6
ffffffe000200538:	af470713          	addi	a4,a4,-1292 # ffffffe000206028 <task>
ffffffe00020053c:	fec42783          	lw	a5,-20(s0)
ffffffe000200540:	00379793          	slli	a5,a5,0x3
ffffffe000200544:	00f707b3          	add	a5,a4,a5
ffffffe000200548:	0007b783          	ld	a5,0(a5)
ffffffe00020054c:	0007b023          	sd	zero,0(a5)
        task[i]->counter = 0;
ffffffe000200550:	00006717          	auipc	a4,0x6
ffffffe000200554:	ad870713          	addi	a4,a4,-1320 # ffffffe000206028 <task>
ffffffe000200558:	fec42783          	lw	a5,-20(s0)
ffffffe00020055c:	00379793          	slli	a5,a5,0x3
ffffffe000200560:	00f707b3          	add	a5,a4,a5
ffffffe000200564:	0007b783          	ld	a5,0(a5)
ffffffe000200568:	0007b423          	sd	zero,8(a5)
        task[i]->priority = (rand() % (PRIORITY_MAX - PRIORITY_MIN + 1)) + PRIORITY_MIN;
ffffffe00020056c:	300020ef          	jal	ffffffe00020286c <rand>
ffffffe000200570:	00050793          	mv	a5,a0
ffffffe000200574:	00078713          	mv	a4,a5
ffffffe000200578:	00a00793          	li	a5,10
ffffffe00020057c:	02f767bb          	remw	a5,a4,a5
ffffffe000200580:	0007879b          	sext.w	a5,a5
ffffffe000200584:	0017879b          	addiw	a5,a5,1
ffffffe000200588:	0007869b          	sext.w	a3,a5
ffffffe00020058c:	00006717          	auipc	a4,0x6
ffffffe000200590:	a9c70713          	addi	a4,a4,-1380 # ffffffe000206028 <task>
ffffffe000200594:	fec42783          	lw	a5,-20(s0)
ffffffe000200598:	00379793          	slli	a5,a5,0x3
ffffffe00020059c:	00f707b3          	add	a5,a4,a5
ffffffe0002005a0:	0007b783          	ld	a5,0(a5)
ffffffe0002005a4:	00068713          	mv	a4,a3
ffffffe0002005a8:	00e7b823          	sd	a4,16(a5)
        task[i]->pid = i;
ffffffe0002005ac:	00006717          	auipc	a4,0x6
ffffffe0002005b0:	a7c70713          	addi	a4,a4,-1412 # ffffffe000206028 <task>
ffffffe0002005b4:	fec42783          	lw	a5,-20(s0)
ffffffe0002005b8:	00379793          	slli	a5,a5,0x3
ffffffe0002005bc:	00f707b3          	add	a5,a4,a5
ffffffe0002005c0:	0007b783          	ld	a5,0(a5)
ffffffe0002005c4:	fec42703          	lw	a4,-20(s0)
ffffffe0002005c8:	00e7bc23          	sd	a4,24(a5)

        /* set thread_struct */
        task[i]->thread.ra = (uint64_t)__dummy;
ffffffe0002005cc:	00006717          	auipc	a4,0x6
ffffffe0002005d0:	a5c70713          	addi	a4,a4,-1444 # ffffffe000206028 <task>
ffffffe0002005d4:	fec42783          	lw	a5,-20(s0)
ffffffe0002005d8:	00379793          	slli	a5,a5,0x3
ffffffe0002005dc:	00f707b3          	add	a5,a4,a5
ffffffe0002005e0:	0007b783          	ld	a5,0(a5)
ffffffe0002005e4:	00000717          	auipc	a4,0x0
ffffffe0002005e8:	bec70713          	addi	a4,a4,-1044 # ffffffe0002001d0 <__dummy>
ffffffe0002005ec:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp = (uint64_t)task[i] + PGSIZE;
ffffffe0002005f0:	00006717          	auipc	a4,0x6
ffffffe0002005f4:	a3870713          	addi	a4,a4,-1480 # ffffffe000206028 <task>
ffffffe0002005f8:	fec42783          	lw	a5,-20(s0)
ffffffe0002005fc:	00379793          	slli	a5,a5,0x3
ffffffe000200600:	00f707b3          	add	a5,a4,a5
ffffffe000200604:	0007b783          	ld	a5,0(a5)
ffffffe000200608:	00078693          	mv	a3,a5
ffffffe00020060c:	00006717          	auipc	a4,0x6
ffffffe000200610:	a1c70713          	addi	a4,a4,-1508 # ffffffe000206028 <task>
ffffffe000200614:	fec42783          	lw	a5,-20(s0)
ffffffe000200618:	00379793          	slli	a5,a5,0x3
ffffffe00020061c:	00f707b3          	add	a5,a4,a5
ffffffe000200620:	0007b783          	ld	a5,0(a5)
ffffffe000200624:	00001737          	lui	a4,0x1
ffffffe000200628:	00e68733          	add	a4,a3,a4
ffffffe00020062c:	02e7b423          	sd	a4,40(a5)
        printk(FG_COLOR(215,135, 255) "SET [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR, task[i]->pid, task[i]->priority, task[i]->counter);
ffffffe000200630:	00006717          	auipc	a4,0x6
ffffffe000200634:	9f870713          	addi	a4,a4,-1544 # ffffffe000206028 <task>
ffffffe000200638:	fec42783          	lw	a5,-20(s0)
ffffffe00020063c:	00379793          	slli	a5,a5,0x3
ffffffe000200640:	00f707b3          	add	a5,a4,a5
ffffffe000200644:	0007b783          	ld	a5,0(a5)
ffffffe000200648:	0187b583          	ld	a1,24(a5)
ffffffe00020064c:	00006717          	auipc	a4,0x6
ffffffe000200650:	9dc70713          	addi	a4,a4,-1572 # ffffffe000206028 <task>
ffffffe000200654:	fec42783          	lw	a5,-20(s0)
ffffffe000200658:	00379793          	slli	a5,a5,0x3
ffffffe00020065c:	00f707b3          	add	a5,a4,a5
ffffffe000200660:	0007b783          	ld	a5,0(a5)
ffffffe000200664:	0107b603          	ld	a2,16(a5)
ffffffe000200668:	00006717          	auipc	a4,0x6
ffffffe00020066c:	9c070713          	addi	a4,a4,-1600 # ffffffe000206028 <task>
ffffffe000200670:	fec42783          	lw	a5,-20(s0)
ffffffe000200674:	00379793          	slli	a5,a5,0x3
ffffffe000200678:	00f707b3          	add	a5,a4,a5
ffffffe00020067c:	0007b783          	ld	a5,0(a5)
ffffffe000200680:	0087b783          	ld	a5,8(a5)
ffffffe000200684:	00078693          	mv	a3,a5
ffffffe000200688:	00003517          	auipc	a0,0x3
ffffffe00020068c:	9a850513          	addi	a0,a0,-1624 # ffffffe000203030 <_srodata+0x30>
ffffffe000200690:	118020ef          	jal	ffffffe0002027a8 <printk>
    for (int i = 1; i <= NR_TASKS - 1; i++) {
ffffffe000200694:	fec42783          	lw	a5,-20(s0)
ffffffe000200698:	0017879b          	addiw	a5,a5,1
ffffffe00020069c:	fef42623          	sw	a5,-20(s0)
ffffffe0002006a0:	fec42783          	lw	a5,-20(s0)
ffffffe0002006a4:	0007871b          	sext.w	a4,a5
ffffffe0002006a8:	00400793          	li	a5,4
ffffffe0002006ac:	e6e7d4e3          	bge	a5,a4,ffffffe000200514 <task_init+0xa8>

    }

    printk(BOLD FG_COLOR(215, 135, 215) "...task_init done!\n" CLEAR);
ffffffe0002006b0:	00003517          	auipc	a0,0x3
ffffffe0002006b4:	9c850513          	addi	a0,a0,-1592 # ffffffe000203078 <_srodata+0x78>
ffffffe0002006b8:	0f0020ef          	jal	ffffffe0002027a8 <printk>
}
ffffffe0002006bc:	00000013          	nop
ffffffe0002006c0:	01813083          	ld	ra,24(sp)
ffffffe0002006c4:	01013403          	ld	s0,16(sp)
ffffffe0002006c8:	02010113          	addi	sp,sp,32
ffffffe0002006cc:	00008067          	ret

ffffffe0002006d0 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
ffffffe0002006d0:	fa010113          	addi	sp,sp,-96
ffffffe0002006d4:	04113c23          	sd	ra,88(sp)
ffffffe0002006d8:	04813823          	sd	s0,80(sp)
ffffffe0002006dc:	06010413          	addi	s0,sp,96
    // Log("step into dummy(), current pid = %d, current counter = %d", current->pid, current->counter);
    const char* colors[] = {COLOR1, COLOR2, COLOR3, COLOR4, COLOR5, COLOR6};
ffffffe0002006e0:	00003797          	auipc	a5,0x3
ffffffe0002006e4:	d2878793          	addi	a5,a5,-728 # ffffffe000203408 <_srodata+0x408>
ffffffe0002006e8:	0007b503          	ld	a0,0(a5)
ffffffe0002006ec:	0087b583          	ld	a1,8(a5)
ffffffe0002006f0:	0107b603          	ld	a2,16(a5)
ffffffe0002006f4:	0187b683          	ld	a3,24(a5)
ffffffe0002006f8:	0207b703          	ld	a4,32(a5)
ffffffe0002006fc:	0287b783          	ld	a5,40(a5)
ffffffe000200700:	faa43023          	sd	a0,-96(s0)
ffffffe000200704:	fab43423          	sd	a1,-88(s0)
ffffffe000200708:	fac43823          	sd	a2,-80(s0)
ffffffe00020070c:	fad43c23          	sd	a3,-72(s0)
ffffffe000200710:	fce43023          	sd	a4,-64(s0)
ffffffe000200714:	fcf43423          	sd	a5,-56(s0)
    uint64_t MOD = 1000000007;
ffffffe000200718:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe00020071c:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe000200720:	fcf43823          	sd	a5,-48(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe000200724:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
ffffffe000200728:	fff00793          	li	a5,-1
ffffffe00020072c:	fef42223          	sw	a5,-28(s0)
    int x = 1, flag = 0;
ffffffe000200730:	00100793          	li	a5,1
ffffffe000200734:	fef42023          	sw	a5,-32(s0)
ffffffe000200738:	fc042e23          	sw	zero,-36(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe00020073c:	fe442783          	lw	a5,-28(s0)
ffffffe000200740:	0007871b          	sext.w	a4,a5
ffffffe000200744:	fff00793          	li	a5,-1
ffffffe000200748:	00f70e63          	beq	a4,a5,ffffffe000200764 <dummy+0x94>
ffffffe00020074c:	00006797          	auipc	a5,0x6
ffffffe000200750:	8c478793          	addi	a5,a5,-1852 # ffffffe000206010 <current>
ffffffe000200754:	0007b783          	ld	a5,0(a5)
ffffffe000200758:	0087b703          	ld	a4,8(a5)
ffffffe00020075c:	fe442783          	lw	a5,-28(s0)
ffffffe000200760:	fcf70ee3          	beq	a4,a5,ffffffe00020073c <dummy+0x6c>
ffffffe000200764:	00006797          	auipc	a5,0x6
ffffffe000200768:	8ac78793          	addi	a5,a5,-1876 # ffffffe000206010 <current>
ffffffe00020076c:	0007b783          	ld	a5,0(a5)
ffffffe000200770:	0087b783          	ld	a5,8(a5)
ffffffe000200774:	fc0784e3          	beqz	a5,ffffffe00020073c <dummy+0x6c>
            if (current->counter == 1) {
ffffffe000200778:	00006797          	auipc	a5,0x6
ffffffe00020077c:	89878793          	addi	a5,a5,-1896 # ffffffe000206010 <current>
ffffffe000200780:	0007b783          	ld	a5,0(a5)
ffffffe000200784:	0087b703          	ld	a4,8(a5)
ffffffe000200788:	00100793          	li	a5,1
ffffffe00020078c:	00f71e63          	bne	a4,a5,ffffffe0002007a8 <dummy+0xd8>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
ffffffe000200790:	00006797          	auipc	a5,0x6
ffffffe000200794:	88078793          	addi	a5,a5,-1920 # ffffffe000206010 <current>
ffffffe000200798:	0007b783          	ld	a5,0(a5)
ffffffe00020079c:	0087b703          	ld	a4,8(a5)
ffffffe0002007a0:	fff70713          	addi	a4,a4,-1
ffffffe0002007a4:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
ffffffe0002007a8:	00006797          	auipc	a5,0x6
ffffffe0002007ac:	86878793          	addi	a5,a5,-1944 # ffffffe000206010 <current>
ffffffe0002007b0:	0007b783          	ld	a5,0(a5)
ffffffe0002007b4:	0087b783          	ld	a5,8(a5)
ffffffe0002007b8:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe0002007bc:	fe843783          	ld	a5,-24(s0)
ffffffe0002007c0:	00178713          	addi	a4,a5,1
ffffffe0002007c4:	fd043783          	ld	a5,-48(s0)
ffffffe0002007c8:	02f777b3          	remu	a5,a4,a5
ffffffe0002007cc:	fef43423          	sd	a5,-24(s0)
            switch(x) {
ffffffe0002007d0:	fe042783          	lw	a5,-32(s0)
ffffffe0002007d4:	0007871b          	sext.w	a4,a5
ffffffe0002007d8:	00600793          	li	a5,6
ffffffe0002007dc:	18e7e063          	bltu	a5,a4,ffffffe00020095c <dummy+0x28c>
ffffffe0002007e0:	fe046783          	lwu	a5,-32(s0)
ffffffe0002007e4:	00279713          	slli	a4,a5,0x2
ffffffe0002007e8:	00003797          	auipc	a5,0x3
ffffffe0002007ec:	ca078793          	addi	a5,a5,-864 # ffffffe000203488 <_srodata+0x488>
ffffffe0002007f0:	00f707b3          	add	a5,a4,a5
ffffffe0002007f4:	0007a783          	lw	a5,0(a5)
ffffffe0002007f8:	0007871b          	sext.w	a4,a5
ffffffe0002007fc:	00003797          	auipc	a5,0x3
ffffffe000200800:	c8c78793          	addi	a5,a5,-884 # ffffffe000203488 <_srodata+0x488>
ffffffe000200804:	00f707b3          	add	a5,a4,a5
ffffffe000200808:	00078067          	jr	a5
                case 1: printk(COLOR1 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
ffffffe00020080c:	00006797          	auipc	a5,0x6
ffffffe000200810:	80478793          	addi	a5,a5,-2044 # ffffffe000206010 <current>
ffffffe000200814:	0007b783          	ld	a5,0(a5)
ffffffe000200818:	0187b703          	ld	a4,24(a5)
ffffffe00020081c:	00005797          	auipc	a5,0x5
ffffffe000200820:	7f478793          	addi	a5,a5,2036 # ffffffe000206010 <current>
ffffffe000200824:	0007b783          	ld	a5,0(a5)
ffffffe000200828:	00078693          	mv	a3,a5
ffffffe00020082c:	fe843603          	ld	a2,-24(s0)
ffffffe000200830:	00070593          	mv	a1,a4
ffffffe000200834:	00003517          	auipc	a0,0x3
ffffffe000200838:	87450513          	addi	a0,a0,-1932 # ffffffe0002030a8 <_srodata+0xa8>
ffffffe00020083c:	76d010ef          	jal	ffffffe0002027a8 <printk>
                        break;
ffffffe000200840:	11c0006f          	j	ffffffe00020095c <dummy+0x28c>
                case 2: printk(COLOR2 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
ffffffe000200844:	00005797          	auipc	a5,0x5
ffffffe000200848:	7cc78793          	addi	a5,a5,1996 # ffffffe000206010 <current>
ffffffe00020084c:	0007b783          	ld	a5,0(a5)
ffffffe000200850:	0187b703          	ld	a4,24(a5)
ffffffe000200854:	00005797          	auipc	a5,0x5
ffffffe000200858:	7bc78793          	addi	a5,a5,1980 # ffffffe000206010 <current>
ffffffe00020085c:	0007b783          	ld	a5,0(a5)
ffffffe000200860:	00078693          	mv	a3,a5
ffffffe000200864:	fe843603          	ld	a2,-24(s0)
ffffffe000200868:	00070593          	mv	a1,a4
ffffffe00020086c:	00003517          	auipc	a0,0x3
ffffffe000200870:	89c50513          	addi	a0,a0,-1892 # ffffffe000203108 <_srodata+0x108>
ffffffe000200874:	735010ef          	jal	ffffffe0002027a8 <printk>
                        break;
ffffffe000200878:	0e40006f          	j	ffffffe00020095c <dummy+0x28c>
                case 3: printk(COLOR3 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
ffffffe00020087c:	00005797          	auipc	a5,0x5
ffffffe000200880:	79478793          	addi	a5,a5,1940 # ffffffe000206010 <current>
ffffffe000200884:	0007b783          	ld	a5,0(a5)
ffffffe000200888:	0187b703          	ld	a4,24(a5)
ffffffe00020088c:	00005797          	auipc	a5,0x5
ffffffe000200890:	78478793          	addi	a5,a5,1924 # ffffffe000206010 <current>
ffffffe000200894:	0007b783          	ld	a5,0(a5)
ffffffe000200898:	00078693          	mv	a3,a5
ffffffe00020089c:	fe843603          	ld	a2,-24(s0)
ffffffe0002008a0:	00070593          	mv	a1,a4
ffffffe0002008a4:	00003517          	auipc	a0,0x3
ffffffe0002008a8:	8c450513          	addi	a0,a0,-1852 # ffffffe000203168 <_srodata+0x168>
ffffffe0002008ac:	6fd010ef          	jal	ffffffe0002027a8 <printk>
                        break;
ffffffe0002008b0:	0ac0006f          	j	ffffffe00020095c <dummy+0x28c>
                case 4: printk(COLOR4 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
ffffffe0002008b4:	00005797          	auipc	a5,0x5
ffffffe0002008b8:	75c78793          	addi	a5,a5,1884 # ffffffe000206010 <current>
ffffffe0002008bc:	0007b783          	ld	a5,0(a5)
ffffffe0002008c0:	0187b703          	ld	a4,24(a5)
ffffffe0002008c4:	00005797          	auipc	a5,0x5
ffffffe0002008c8:	74c78793          	addi	a5,a5,1868 # ffffffe000206010 <current>
ffffffe0002008cc:	0007b783          	ld	a5,0(a5)
ffffffe0002008d0:	00078693          	mv	a3,a5
ffffffe0002008d4:	fe843603          	ld	a2,-24(s0)
ffffffe0002008d8:	00070593          	mv	a1,a4
ffffffe0002008dc:	00003517          	auipc	a0,0x3
ffffffe0002008e0:	8ec50513          	addi	a0,a0,-1812 # ffffffe0002031c8 <_srodata+0x1c8>
ffffffe0002008e4:	6c5010ef          	jal	ffffffe0002027a8 <printk>
                        break;
ffffffe0002008e8:	0740006f          	j	ffffffe00020095c <dummy+0x28c>
                case 5: printk(COLOR5 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
ffffffe0002008ec:	00005797          	auipc	a5,0x5
ffffffe0002008f0:	72478793          	addi	a5,a5,1828 # ffffffe000206010 <current>
ffffffe0002008f4:	0007b783          	ld	a5,0(a5)
ffffffe0002008f8:	0187b703          	ld	a4,24(a5)
ffffffe0002008fc:	00005797          	auipc	a5,0x5
ffffffe000200900:	71478793          	addi	a5,a5,1812 # ffffffe000206010 <current>
ffffffe000200904:	0007b783          	ld	a5,0(a5)
ffffffe000200908:	00078693          	mv	a3,a5
ffffffe00020090c:	fe843603          	ld	a2,-24(s0)
ffffffe000200910:	00070593          	mv	a1,a4
ffffffe000200914:	00003517          	auipc	a0,0x3
ffffffe000200918:	91450513          	addi	a0,a0,-1772 # ffffffe000203228 <_srodata+0x228>
ffffffe00020091c:	68d010ef          	jal	ffffffe0002027a8 <printk>
                        break;
ffffffe000200920:	03c0006f          	j	ffffffe00020095c <dummy+0x28c>
                case 6: printk(COLOR6 "[PID = %d] is running. auto_inc_local_var = %d, addr_begin = %#llx\n" CLEAR, current->pid, auto_inc_local_var, (uint64_t)current);
ffffffe000200924:	00005797          	auipc	a5,0x5
ffffffe000200928:	6ec78793          	addi	a5,a5,1772 # ffffffe000206010 <current>
ffffffe00020092c:	0007b783          	ld	a5,0(a5)
ffffffe000200930:	0187b703          	ld	a4,24(a5)
ffffffe000200934:	00005797          	auipc	a5,0x5
ffffffe000200938:	6dc78793          	addi	a5,a5,1756 # ffffffe000206010 <current>
ffffffe00020093c:	0007b783          	ld	a5,0(a5)
ffffffe000200940:	00078693          	mv	a3,a5
ffffffe000200944:	fe843603          	ld	a2,-24(s0)
ffffffe000200948:	00070593          	mv	a1,a4
ffffffe00020094c:	00003517          	auipc	a0,0x3
ffffffe000200950:	93c50513          	addi	a0,a0,-1732 # ffffffe000203288 <_srodata+0x288>
ffffffe000200954:	655010ef          	jal	ffffffe0002027a8 <printk>
                        break;
ffffffe000200958:	00000013          	nop
            }
            // printk(COLOR1 "[PID = %d] is running. auto_inc_local_var = %d\n" CLEAR, current->pid, auto_inc_local_var);
            if (flag == 0) {
ffffffe00020095c:	fdc42783          	lw	a5,-36(s0)
ffffffe000200960:	0007879b          	sext.w	a5,a5
ffffffe000200964:	02079a63          	bnez	a5,ffffffe000200998 <dummy+0x2c8>
                x++;
ffffffe000200968:	fe042783          	lw	a5,-32(s0)
ffffffe00020096c:	0017879b          	addiw	a5,a5,1
ffffffe000200970:	fef42023          	sw	a5,-32(s0)
                if (x == 7) {
ffffffe000200974:	fe042783          	lw	a5,-32(s0)
ffffffe000200978:	0007871b          	sext.w	a4,a5
ffffffe00020097c:	00700793          	li	a5,7
ffffffe000200980:	02f71e63          	bne	a4,a5,ffffffe0002009bc <dummy+0x2ec>
                    x = 6;
ffffffe000200984:	00600793          	li	a5,6
ffffffe000200988:	fef42023          	sw	a5,-32(s0)
                    flag = 1;
ffffffe00020098c:	00100793          	li	a5,1
ffffffe000200990:	fcf42e23          	sw	a5,-36(s0)
ffffffe000200994:	0280006f          	j	ffffffe0002009bc <dummy+0x2ec>
                }
            } else {
                x--;
ffffffe000200998:	fe042783          	lw	a5,-32(s0)
ffffffe00020099c:	fff7879b          	addiw	a5,a5,-1
ffffffe0002009a0:	fef42023          	sw	a5,-32(s0)
                if (x == 0) {
ffffffe0002009a4:	fe042783          	lw	a5,-32(s0)
ffffffe0002009a8:	0007879b          	sext.w	a5,a5
ffffffe0002009ac:	00079863          	bnez	a5,ffffffe0002009bc <dummy+0x2ec>
                    x = 1;
ffffffe0002009b0:	00100793          	li	a5,1
ffffffe0002009b4:	fef42023          	sw	a5,-32(s0)
                    flag = 0;
ffffffe0002009b8:	fc042e23          	sw	zero,-36(s0)
                }
            }
            #if TEST_SCHED
            tasks_output[tasks_output_index++] = current->pid + '0';
ffffffe0002009bc:	00005797          	auipc	a5,0x5
ffffffe0002009c0:	65478793          	addi	a5,a5,1620 # ffffffe000206010 <current>
ffffffe0002009c4:	0007b783          	ld	a5,0(a5)
ffffffe0002009c8:	0187b783          	ld	a5,24(a5)
ffffffe0002009cc:	0ff7f713          	zext.b	a4,a5
ffffffe0002009d0:	00005797          	auipc	a5,0x5
ffffffe0002009d4:	64878793          	addi	a5,a5,1608 # ffffffe000206018 <tasks_output_index>
ffffffe0002009d8:	0007a783          	lw	a5,0(a5)
ffffffe0002009dc:	0017869b          	addiw	a3,a5,1
ffffffe0002009e0:	0006861b          	sext.w	a2,a3
ffffffe0002009e4:	00005697          	auipc	a3,0x5
ffffffe0002009e8:	63468693          	addi	a3,a3,1588 # ffffffe000206018 <tasks_output_index>
ffffffe0002009ec:	00c6a023          	sw	a2,0(a3)
ffffffe0002009f0:	0307071b          	addiw	a4,a4,48
ffffffe0002009f4:	0ff77713          	zext.b	a4,a4
ffffffe0002009f8:	00005697          	auipc	a3,0x5
ffffffe0002009fc:	65868693          	addi	a3,a3,1624 # ffffffe000206050 <tasks_output>
ffffffe000200a00:	00f687b3          	add	a5,a3,a5
ffffffe000200a04:	00e78023          	sb	a4,0(a5)
            if (tasks_output_index == MAX_OUTPUT) {
ffffffe000200a08:	00005797          	auipc	a5,0x5
ffffffe000200a0c:	61078793          	addi	a5,a5,1552 # ffffffe000206018 <tasks_output_index>
ffffffe000200a10:	0007a783          	lw	a5,0(a5)
ffffffe000200a14:	00078713          	mv	a4,a5
ffffffe000200a18:	02800793          	li	a5,40
ffffffe000200a1c:	d2f710e3          	bne	a4,a5,ffffffe00020073c <dummy+0x6c>
                for (int i = 0; i < MAX_OUTPUT; ++i) {
ffffffe000200a20:	fc042c23          	sw	zero,-40(s0)
ffffffe000200a24:	0800006f          	j	ffffffe000200aa4 <dummy+0x3d4>
                    if (tasks_output[i] != expected_output[i]) {
ffffffe000200a28:	00005717          	auipc	a4,0x5
ffffffe000200a2c:	62870713          	addi	a4,a4,1576 # ffffffe000206050 <tasks_output>
ffffffe000200a30:	fd842783          	lw	a5,-40(s0)
ffffffe000200a34:	00f707b3          	add	a5,a4,a5
ffffffe000200a38:	0007c683          	lbu	a3,0(a5)
ffffffe000200a3c:	00003717          	auipc	a4,0x3
ffffffe000200a40:	5cc70713          	addi	a4,a4,1484 # ffffffe000204008 <expected_output>
ffffffe000200a44:	fd842783          	lw	a5,-40(s0)
ffffffe000200a48:	00f707b3          	add	a5,a4,a5
ffffffe000200a4c:	0007c783          	lbu	a5,0(a5)
ffffffe000200a50:	00068713          	mv	a4,a3
ffffffe000200a54:	04f70263          	beq	a4,a5,ffffffe000200a98 <dummy+0x3c8>
                        printk("\033[31mTest failed!\033[0m\n");
ffffffe000200a58:	00003517          	auipc	a0,0x3
ffffffe000200a5c:	89050513          	addi	a0,a0,-1904 # ffffffe0002032e8 <_srodata+0x2e8>
ffffffe000200a60:	549010ef          	jal	ffffffe0002027a8 <printk>
                        printk("\033[31m    Expected: %s\033[0m\n", expected_output);
ffffffe000200a64:	00003597          	auipc	a1,0x3
ffffffe000200a68:	5a458593          	addi	a1,a1,1444 # ffffffe000204008 <expected_output>
ffffffe000200a6c:	00003517          	auipc	a0,0x3
ffffffe000200a70:	89450513          	addi	a0,a0,-1900 # ffffffe000203300 <_srodata+0x300>
ffffffe000200a74:	535010ef          	jal	ffffffe0002027a8 <printk>
                        printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
ffffffe000200a78:	00005597          	auipc	a1,0x5
ffffffe000200a7c:	5d858593          	addi	a1,a1,1496 # ffffffe000206050 <tasks_output>
ffffffe000200a80:	00003517          	auipc	a0,0x3
ffffffe000200a84:	8a050513          	addi	a0,a0,-1888 # ffffffe000203320 <_srodata+0x320>
ffffffe000200a88:	521010ef          	jal	ffffffe0002027a8 <printk>
                        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
ffffffe000200a8c:	00000593          	li	a1,0
ffffffe000200a90:	00000513          	li	a0,0
ffffffe000200a94:	600000ef          	jal	ffffffe000201094 <sbi_system_reset>
                for (int i = 0; i < MAX_OUTPUT; ++i) {
ffffffe000200a98:	fd842783          	lw	a5,-40(s0)
ffffffe000200a9c:	0017879b          	addiw	a5,a5,1
ffffffe000200aa0:	fcf42c23          	sw	a5,-40(s0)
ffffffe000200aa4:	fd842783          	lw	a5,-40(s0)
ffffffe000200aa8:	0007871b          	sext.w	a4,a5
ffffffe000200aac:	02700793          	li	a5,39
ffffffe000200ab0:	f6e7dce3          	bge	a5,a4,ffffffe000200a28 <dummy+0x358>
                    }
                }
                printk("\033[32mTest passed!\033[0m\n");
ffffffe000200ab4:	00003517          	auipc	a0,0x3
ffffffe000200ab8:	88c50513          	addi	a0,a0,-1908 # ffffffe000203340 <_srodata+0x340>
ffffffe000200abc:	4ed010ef          	jal	ffffffe0002027a8 <printk>
                printk("\033[32m    Output: %s\033[0m\n", expected_output);
ffffffe000200ac0:	00003597          	auipc	a1,0x3
ffffffe000200ac4:	54858593          	addi	a1,a1,1352 # ffffffe000204008 <expected_output>
ffffffe000200ac8:	00003517          	auipc	a0,0x3
ffffffe000200acc:	89050513          	addi	a0,a0,-1904 # ffffffe000203358 <_srodata+0x358>
ffffffe000200ad0:	4d9010ef          	jal	ffffffe0002027a8 <printk>
                sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
ffffffe000200ad4:	00000593          	li	a1,0
ffffffe000200ad8:	00000513          	li	a0,0
ffffffe000200adc:	5b8000ef          	jal	ffffffe000201094 <sbi_system_reset>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000200ae0:	c5dff06f          	j	ffffffe00020073c <dummy+0x6c>

ffffffe000200ae4 <switch_to>:
            #endif
        }
    }
}

void switch_to(struct task_struct *next) {
ffffffe000200ae4:	fd010113          	addi	sp,sp,-48
ffffffe000200ae8:	02113423          	sd	ra,40(sp)
ffffffe000200aec:	02813023          	sd	s0,32(sp)
ffffffe000200af0:	03010413          	addi	s0,sp,48
ffffffe000200af4:	fca43c23          	sd	a0,-40(s0)
    // Log("Into switch_to func\n");
    if (next->pid != current->pid) {
ffffffe000200af8:	fd843783          	ld	a5,-40(s0)
ffffffe000200afc:	0187b703          	ld	a4,24(a5)
ffffffe000200b00:	00005797          	auipc	a5,0x5
ffffffe000200b04:	51078793          	addi	a5,a5,1296 # ffffffe000206010 <current>
ffffffe000200b08:	0007b783          	ld	a5,0(a5)
ffffffe000200b0c:	0187b783          	ld	a5,24(a5)
ffffffe000200b10:	02f70863          	beq	a4,a5,ffffffe000200b40 <switch_to+0x5c>
        struct task_struct* tmp = current;
ffffffe000200b14:	00005797          	auipc	a5,0x5
ffffffe000200b18:	4fc78793          	addi	a5,a5,1276 # ffffffe000206010 <current>
ffffffe000200b1c:	0007b783          	ld	a5,0(a5)
ffffffe000200b20:	fef43423          	sd	a5,-24(s0)
        current = next;
ffffffe000200b24:	00005797          	auipc	a5,0x5
ffffffe000200b28:	4ec78793          	addi	a5,a5,1260 # ffffffe000206010 <current>
ffffffe000200b2c:	fd843703          	ld	a4,-40(s0)
ffffffe000200b30:	00e7b023          	sd	a4,0(a5)
        __switch_to(tmp, next);
ffffffe000200b34:	fd843583          	ld	a1,-40(s0)
ffffffe000200b38:	fe843503          	ld	a0,-24(s0)
ffffffe000200b3c:	ea4ff0ef          	jal	ffffffe0002001e0 <__switch_to>
    }
    // Log("finish switch_to func\n");
}
ffffffe000200b40:	00000013          	nop
ffffffe000200b44:	02813083          	ld	ra,40(sp)
ffffffe000200b48:	02013403          	ld	s0,32(sp)
ffffffe000200b4c:	03010113          	addi	sp,sp,48
ffffffe000200b50:	00008067          	ret

ffffffe000200b54 <do_timer>:

void do_timer() {
ffffffe000200b54:	ff010113          	addi	sp,sp,-16
ffffffe000200b58:	00113423          	sd	ra,8(sp)
ffffffe000200b5c:	00813023          	sd	s0,0(sp)
ffffffe000200b60:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度

    // YOUR CODE HERE

    if (current->pid == 0 || current->counter <= 0) {
ffffffe000200b64:	00005797          	auipc	a5,0x5
ffffffe000200b68:	4ac78793          	addi	a5,a5,1196 # ffffffe000206010 <current>
ffffffe000200b6c:	0007b783          	ld	a5,0(a5)
ffffffe000200b70:	0187b783          	ld	a5,24(a5)
ffffffe000200b74:	00078c63          	beqz	a5,ffffffe000200b8c <do_timer+0x38>
ffffffe000200b78:	00005797          	auipc	a5,0x5
ffffffe000200b7c:	49878793          	addi	a5,a5,1176 # ffffffe000206010 <current>
ffffffe000200b80:	0007b783          	ld	a5,0(a5)
ffffffe000200b84:	0087b783          	ld	a5,8(a5)
ffffffe000200b88:	00079663          	bnez	a5,ffffffe000200b94 <do_timer+0x40>
        schedule();
ffffffe000200b8c:	05c000ef          	jal	ffffffe000200be8 <schedule>
ffffffe000200b90:	0480006f          	j	ffffffe000200bd8 <do_timer+0x84>
    } else {
        current->counter -= 1;
ffffffe000200b94:	00005797          	auipc	a5,0x5
ffffffe000200b98:	47c78793          	addi	a5,a5,1148 # ffffffe000206010 <current>
ffffffe000200b9c:	0007b783          	ld	a5,0(a5)
ffffffe000200ba0:	0087b703          	ld	a4,8(a5)
ffffffe000200ba4:	00005797          	auipc	a5,0x5
ffffffe000200ba8:	46c78793          	addi	a5,a5,1132 # ffffffe000206010 <current>
ffffffe000200bac:	0007b783          	ld	a5,0(a5)
ffffffe000200bb0:	fff70713          	addi	a4,a4,-1
ffffffe000200bb4:	00e7b423          	sd	a4,8(a5)
        if (current->counter <= 0) schedule();
ffffffe000200bb8:	00005797          	auipc	a5,0x5
ffffffe000200bbc:	45878793          	addi	a5,a5,1112 # ffffffe000206010 <current>
ffffffe000200bc0:	0007b783          	ld	a5,0(a5)
ffffffe000200bc4:	0087b783          	ld	a5,8(a5)
ffffffe000200bc8:	00079663          	bnez	a5,ffffffe000200bd4 <do_timer+0x80>
ffffffe000200bcc:	01c000ef          	jal	ffffffe000200be8 <schedule>
ffffffe000200bd0:	0080006f          	j	ffffffe000200bd8 <do_timer+0x84>
        else return;
ffffffe000200bd4:	00000013          	nop
    }
}
ffffffe000200bd8:	00813083          	ld	ra,8(sp)
ffffffe000200bdc:	00013403          	ld	s0,0(sp)
ffffffe000200be0:	01010113          	addi	sp,sp,16
ffffffe000200be4:	00008067          	ret

ffffffe000200be8 <schedule>:

void schedule() {
ffffffe000200be8:	fd010113          	addi	sp,sp,-48
ffffffe000200bec:	02113423          	sd	ra,40(sp)
ffffffe000200bf0:	02813023          	sd	s0,32(sp)
ffffffe000200bf4:	03010413          	addi	s0,sp,48
    // YOUR CODE HERE
    uint64_t all_counter_zero = 1;
ffffffe000200bf8:	00100793          	li	a5,1
ffffffe000200bfc:	fef43423          	sd	a5,-24(s0)
    // struct pid_counter _counter[NR_TASKS];
    struct pid_counter _max_counter = {0, 0};
ffffffe000200c00:	fc043823          	sd	zero,-48(s0)
ffffffe000200c04:	fc043c23          	sd	zero,-40(s0)

    for (int i = 1; i <= NR_TASKS - 1; i++) {
ffffffe000200c08:	00100793          	li	a5,1
ffffffe000200c0c:	fef42223          	sw	a5,-28(s0)
ffffffe000200c10:	0980006f          	j	ffffffe000200ca8 <schedule+0xc0>
        // _counter[i].pid = i;
        // _counter[i].counter = task[i]->counter;
        if (task[i]->counter > _max_counter.counter) {
ffffffe000200c14:	00005717          	auipc	a4,0x5
ffffffe000200c18:	41470713          	addi	a4,a4,1044 # ffffffe000206028 <task>
ffffffe000200c1c:	fe442783          	lw	a5,-28(s0)
ffffffe000200c20:	00379793          	slli	a5,a5,0x3
ffffffe000200c24:	00f707b3          	add	a5,a4,a5
ffffffe000200c28:	0007b783          	ld	a5,0(a5)
ffffffe000200c2c:	0087b703          	ld	a4,8(a5)
ffffffe000200c30:	fd843783          	ld	a5,-40(s0)
ffffffe000200c34:	04e7f263          	bgeu	a5,a4,ffffffe000200c78 <schedule+0x90>
            _max_counter.counter = task[i]->counter;
ffffffe000200c38:	00005717          	auipc	a4,0x5
ffffffe000200c3c:	3f070713          	addi	a4,a4,1008 # ffffffe000206028 <task>
ffffffe000200c40:	fe442783          	lw	a5,-28(s0)
ffffffe000200c44:	00379793          	slli	a5,a5,0x3
ffffffe000200c48:	00f707b3          	add	a5,a4,a5
ffffffe000200c4c:	0007b783          	ld	a5,0(a5)
ffffffe000200c50:	0087b783          	ld	a5,8(a5)
ffffffe000200c54:	fcf43c23          	sd	a5,-40(s0)
            _max_counter.pid = task[i]->pid;
ffffffe000200c58:	00005717          	auipc	a4,0x5
ffffffe000200c5c:	3d070713          	addi	a4,a4,976 # ffffffe000206028 <task>
ffffffe000200c60:	fe442783          	lw	a5,-28(s0)
ffffffe000200c64:	00379793          	slli	a5,a5,0x3
ffffffe000200c68:	00f707b3          	add	a5,a4,a5
ffffffe000200c6c:	0007b783          	ld	a5,0(a5)
ffffffe000200c70:	0187b783          	ld	a5,24(a5)
ffffffe000200c74:	fcf43823          	sd	a5,-48(s0)
        }
        if (task[i]->counter > 0) all_counter_zero = 0;
ffffffe000200c78:	00005717          	auipc	a4,0x5
ffffffe000200c7c:	3b070713          	addi	a4,a4,944 # ffffffe000206028 <task>
ffffffe000200c80:	fe442783          	lw	a5,-28(s0)
ffffffe000200c84:	00379793          	slli	a5,a5,0x3
ffffffe000200c88:	00f707b3          	add	a5,a4,a5
ffffffe000200c8c:	0007b783          	ld	a5,0(a5)
ffffffe000200c90:	0087b783          	ld	a5,8(a5)
ffffffe000200c94:	00078463          	beqz	a5,ffffffe000200c9c <schedule+0xb4>
ffffffe000200c98:	fe043423          	sd	zero,-24(s0)
    for (int i = 1; i <= NR_TASKS - 1; i++) {
ffffffe000200c9c:	fe442783          	lw	a5,-28(s0)
ffffffe000200ca0:	0017879b          	addiw	a5,a5,1
ffffffe000200ca4:	fef42223          	sw	a5,-28(s0)
ffffffe000200ca8:	fe442783          	lw	a5,-28(s0)
ffffffe000200cac:	0007871b          	sext.w	a4,a5
ffffffe000200cb0:	00400793          	li	a5,4
ffffffe000200cb4:	f6e7d0e3          	bge	a5,a4,ffffffe000200c14 <schedule+0x2c>
    }
    // Log("all_count_zero = %d\n", all_counter_zero);
    
    if (all_counter_zero == 1) { // all of the counters are 0
ffffffe000200cb8:	fe843703          	ld	a4,-24(s0)
ffffffe000200cbc:	00100793          	li	a5,1
ffffffe000200cc0:	0cf71a63          	bne	a4,a5,ffffffe000200d94 <schedule+0x1ac>
        _max_counter.counter = 0;
ffffffe000200cc4:	fc043c23          	sd	zero,-40(s0)
        _max_counter.pid = 0;
ffffffe000200cc8:	fc043823          	sd	zero,-48(s0)
        for (int i = 1; i <= NR_TASKS - 1; i++) {
ffffffe000200ccc:	00100793          	li	a5,1
ffffffe000200cd0:	fef42023          	sw	a5,-32(s0)
ffffffe000200cd4:	0ac0006f          	j	ffffffe000200d80 <schedule+0x198>
            task[i]->counter = task[i]->priority;
ffffffe000200cd8:	00005717          	auipc	a4,0x5
ffffffe000200cdc:	35070713          	addi	a4,a4,848 # ffffffe000206028 <task>
ffffffe000200ce0:	fe042783          	lw	a5,-32(s0)
ffffffe000200ce4:	00379793          	slli	a5,a5,0x3
ffffffe000200ce8:	00f707b3          	add	a5,a4,a5
ffffffe000200cec:	0007b703          	ld	a4,0(a5)
ffffffe000200cf0:	00005697          	auipc	a3,0x5
ffffffe000200cf4:	33868693          	addi	a3,a3,824 # ffffffe000206028 <task>
ffffffe000200cf8:	fe042783          	lw	a5,-32(s0)
ffffffe000200cfc:	00379793          	slli	a5,a5,0x3
ffffffe000200d00:	00f687b3          	add	a5,a3,a5
ffffffe000200d04:	0007b783          	ld	a5,0(a5)
ffffffe000200d08:	01073703          	ld	a4,16(a4)
ffffffe000200d0c:	00e7b423          	sd	a4,8(a5)
            if (task[i]->counter > _max_counter.counter) {
ffffffe000200d10:	00005717          	auipc	a4,0x5
ffffffe000200d14:	31870713          	addi	a4,a4,792 # ffffffe000206028 <task>
ffffffe000200d18:	fe042783          	lw	a5,-32(s0)
ffffffe000200d1c:	00379793          	slli	a5,a5,0x3
ffffffe000200d20:	00f707b3          	add	a5,a4,a5
ffffffe000200d24:	0007b783          	ld	a5,0(a5)
ffffffe000200d28:	0087b703          	ld	a4,8(a5)
ffffffe000200d2c:	fd843783          	ld	a5,-40(s0)
ffffffe000200d30:	04e7f263          	bgeu	a5,a4,ffffffe000200d74 <schedule+0x18c>
                _max_counter.counter = task[i]->counter;
ffffffe000200d34:	00005717          	auipc	a4,0x5
ffffffe000200d38:	2f470713          	addi	a4,a4,756 # ffffffe000206028 <task>
ffffffe000200d3c:	fe042783          	lw	a5,-32(s0)
ffffffe000200d40:	00379793          	slli	a5,a5,0x3
ffffffe000200d44:	00f707b3          	add	a5,a4,a5
ffffffe000200d48:	0007b783          	ld	a5,0(a5)
ffffffe000200d4c:	0087b783          	ld	a5,8(a5)
ffffffe000200d50:	fcf43c23          	sd	a5,-40(s0)
                _max_counter.pid = task[i]->pid;
ffffffe000200d54:	00005717          	auipc	a4,0x5
ffffffe000200d58:	2d470713          	addi	a4,a4,724 # ffffffe000206028 <task>
ffffffe000200d5c:	fe042783          	lw	a5,-32(s0)
ffffffe000200d60:	00379793          	slli	a5,a5,0x3
ffffffe000200d64:	00f707b3          	add	a5,a4,a5
ffffffe000200d68:	0007b783          	ld	a5,0(a5)
ffffffe000200d6c:	0187b783          	ld	a5,24(a5)
ffffffe000200d70:	fcf43823          	sd	a5,-48(s0)
        for (int i = 1; i <= NR_TASKS - 1; i++) {
ffffffe000200d74:	fe042783          	lw	a5,-32(s0)
ffffffe000200d78:	0017879b          	addiw	a5,a5,1
ffffffe000200d7c:	fef42023          	sw	a5,-32(s0)
ffffffe000200d80:	fe042783          	lw	a5,-32(s0)
ffffffe000200d84:	0007871b          	sext.w	a4,a5
ffffffe000200d88:	00400793          	li	a5,4
ffffffe000200d8c:	f4e7d6e3          	bge	a5,a4,ffffffe000200cd8 <schedule+0xf0>
            }
        }
        goto SWITCH_TO_FUNC;
ffffffe000200d90:	0080006f          	j	ffffffe000200d98 <schedule+0x1b0>
    }

    goto SWITCH_TO_FUNC;
ffffffe000200d94:	00000013          	nop

SWITCH_TO_FUNC:
    printk(BOLD REVERSED FG_COLOR(255, 135, 175) "SWITCH [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR,task[_max_counter.pid]->pid, \
ffffffe000200d98:	fd043783          	ld	a5,-48(s0)
ffffffe000200d9c:	00005717          	auipc	a4,0x5
ffffffe000200da0:	28c70713          	addi	a4,a4,652 # ffffffe000206028 <task>
ffffffe000200da4:	00379793          	slli	a5,a5,0x3
ffffffe000200da8:	00f707b3          	add	a5,a4,a5
ffffffe000200dac:	0007b783          	ld	a5,0(a5)
ffffffe000200db0:	0187b583          	ld	a1,24(a5)
                    task[_max_counter.pid]->priority, task[_max_counter.pid]->counter);
ffffffe000200db4:	fd043783          	ld	a5,-48(s0)
ffffffe000200db8:	00005717          	auipc	a4,0x5
ffffffe000200dbc:	27070713          	addi	a4,a4,624 # ffffffe000206028 <task>
ffffffe000200dc0:	00379793          	slli	a5,a5,0x3
ffffffe000200dc4:	00f707b3          	add	a5,a4,a5
ffffffe000200dc8:	0007b783          	ld	a5,0(a5)
    printk(BOLD REVERSED FG_COLOR(255, 135, 175) "SWITCH [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR,task[_max_counter.pid]->pid, \
ffffffe000200dcc:	0107b603          	ld	a2,16(a5)
                    task[_max_counter.pid]->priority, task[_max_counter.pid]->counter);
ffffffe000200dd0:	fd043783          	ld	a5,-48(s0)
ffffffe000200dd4:	00005717          	auipc	a4,0x5
ffffffe000200dd8:	25470713          	addi	a4,a4,596 # ffffffe000206028 <task>
ffffffe000200ddc:	00379793          	slli	a5,a5,0x3
ffffffe000200de0:	00f707b3          	add	a5,a4,a5
ffffffe000200de4:	0007b783          	ld	a5,0(a5)
    printk(BOLD REVERSED FG_COLOR(255, 135, 175) "SWITCH [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR,task[_max_counter.pid]->pid, \
ffffffe000200de8:	0087b783          	ld	a5,8(a5)
ffffffe000200dec:	00078693          	mv	a3,a5
ffffffe000200df0:	00002517          	auipc	a0,0x2
ffffffe000200df4:	64850513          	addi	a0,a0,1608 # ffffffe000203438 <_srodata+0x438>
ffffffe000200df8:	1b1010ef          	jal	ffffffe0002027a8 <printk>
    switch_to(task[_max_counter.pid]);
ffffffe000200dfc:	fd043783          	ld	a5,-48(s0)
ffffffe000200e00:	00005717          	auipc	a4,0x5
ffffffe000200e04:	22870713          	addi	a4,a4,552 # ffffffe000206028 <task>
ffffffe000200e08:	00379793          	slli	a5,a5,0x3
ffffffe000200e0c:	00f707b3          	add	a5,a4,a5
ffffffe000200e10:	0007b783          	ld	a5,0(a5)
ffffffe000200e14:	00078513          	mv	a0,a5
ffffffe000200e18:	ccdff0ef          	jal	ffffffe000200ae4 <switch_to>

}
ffffffe000200e1c:	00000013          	nop
ffffffe000200e20:	02813083          	ld	ra,40(sp)
ffffffe000200e24:	02013403          	ld	s0,32(sp)
ffffffe000200e28:	03010113          	addi	sp,sp,48
ffffffe000200e2c:	00008067          	ret

ffffffe000200e30 <__bubble_sort>:

void __bubble_sort(struct pid_counter* arr, uint64_t len) {
ffffffe000200e30:	fc010113          	addi	sp,sp,-64
ffffffe000200e34:	02813c23          	sd	s0,56(sp)
ffffffe000200e38:	04010413          	addi	s0,sp,64
ffffffe000200e3c:	fca43423          	sd	a0,-56(s0)
ffffffe000200e40:	fcb43023          	sd	a1,-64(s0)
    uint64_t i, j;
    struct pid_counter tmp;
    for (i = 1; i <= len; i++) {
ffffffe000200e44:	00100793          	li	a5,1
ffffffe000200e48:	fef43423          	sd	a5,-24(s0)
ffffffe000200e4c:	0dc0006f          	j	ffffffe000200f28 <__bubble_sort+0xf8>
        for (j = 1; j <= len; j++) {
ffffffe000200e50:	00100793          	li	a5,1
ffffffe000200e54:	fef43023          	sd	a5,-32(s0)
ffffffe000200e58:	0b80006f          	j	ffffffe000200f10 <__bubble_sort+0xe0>
            if (arr[j].counter < arr[j+1].counter) {
ffffffe000200e5c:	fe043783          	ld	a5,-32(s0)
ffffffe000200e60:	00479793          	slli	a5,a5,0x4
ffffffe000200e64:	fc843703          	ld	a4,-56(s0)
ffffffe000200e68:	00f707b3          	add	a5,a4,a5
ffffffe000200e6c:	0087b703          	ld	a4,8(a5)
ffffffe000200e70:	fe043783          	ld	a5,-32(s0)
ffffffe000200e74:	00178793          	addi	a5,a5,1
ffffffe000200e78:	00479793          	slli	a5,a5,0x4
ffffffe000200e7c:	fc843683          	ld	a3,-56(s0)
ffffffe000200e80:	00f687b3          	add	a5,a3,a5
ffffffe000200e84:	0087b783          	ld	a5,8(a5)
ffffffe000200e88:	06f77e63          	bgeu	a4,a5,ffffffe000200f04 <__bubble_sort+0xd4>
                tmp = arr[j];
ffffffe000200e8c:	fe043783          	ld	a5,-32(s0)
ffffffe000200e90:	00479793          	slli	a5,a5,0x4
ffffffe000200e94:	fc843703          	ld	a4,-56(s0)
ffffffe000200e98:	00f707b3          	add	a5,a4,a5
ffffffe000200e9c:	0007b703          	ld	a4,0(a5)
ffffffe000200ea0:	fce43823          	sd	a4,-48(s0)
ffffffe000200ea4:	0087b783          	ld	a5,8(a5)
ffffffe000200ea8:	fcf43c23          	sd	a5,-40(s0)
                arr[j]= arr[j+1];
ffffffe000200eac:	fe043783          	ld	a5,-32(s0)
ffffffe000200eb0:	00178793          	addi	a5,a5,1
ffffffe000200eb4:	00479793          	slli	a5,a5,0x4
ffffffe000200eb8:	fc843703          	ld	a4,-56(s0)
ffffffe000200ebc:	00f70733          	add	a4,a4,a5
ffffffe000200ec0:	fe043783          	ld	a5,-32(s0)
ffffffe000200ec4:	00479793          	slli	a5,a5,0x4
ffffffe000200ec8:	fc843683          	ld	a3,-56(s0)
ffffffe000200ecc:	00f687b3          	add	a5,a3,a5
ffffffe000200ed0:	00073683          	ld	a3,0(a4)
ffffffe000200ed4:	00d7b023          	sd	a3,0(a5)
ffffffe000200ed8:	00873703          	ld	a4,8(a4)
ffffffe000200edc:	00e7b423          	sd	a4,8(a5)
                arr[j+1] = tmp;
ffffffe000200ee0:	fe043783          	ld	a5,-32(s0)
ffffffe000200ee4:	00178793          	addi	a5,a5,1
ffffffe000200ee8:	00479793          	slli	a5,a5,0x4
ffffffe000200eec:	fc843703          	ld	a4,-56(s0)
ffffffe000200ef0:	00f707b3          	add	a5,a4,a5
ffffffe000200ef4:	fd043703          	ld	a4,-48(s0)
ffffffe000200ef8:	00e7b023          	sd	a4,0(a5)
ffffffe000200efc:	fd843703          	ld	a4,-40(s0)
ffffffe000200f00:	00e7b423          	sd	a4,8(a5)
        for (j = 1; j <= len; j++) {
ffffffe000200f04:	fe043783          	ld	a5,-32(s0)
ffffffe000200f08:	00178793          	addi	a5,a5,1
ffffffe000200f0c:	fef43023          	sd	a5,-32(s0)
ffffffe000200f10:	fe043703          	ld	a4,-32(s0)
ffffffe000200f14:	fc043783          	ld	a5,-64(s0)
ffffffe000200f18:	f4e7f2e3          	bgeu	a5,a4,ffffffe000200e5c <__bubble_sort+0x2c>
    for (i = 1; i <= len; i++) {
ffffffe000200f1c:	fe843783          	ld	a5,-24(s0)
ffffffe000200f20:	00178793          	addi	a5,a5,1
ffffffe000200f24:	fef43423          	sd	a5,-24(s0)
ffffffe000200f28:	fe843703          	ld	a4,-24(s0)
ffffffe000200f2c:	fc043783          	ld	a5,-64(s0)
ffffffe000200f30:	f2e7f0e3          	bgeu	a5,a4,ffffffe000200e50 <__bubble_sort+0x20>
            }
        }
    }
}
ffffffe000200f34:	00000013          	nop
ffffffe000200f38:	00000013          	nop
ffffffe000200f3c:	03813403          	ld	s0,56(sp)
ffffffe000200f40:	04010113          	addi	sp,sp,64
ffffffe000200f44:	00008067          	ret

ffffffe000200f48 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe000200f48:	f9010113          	addi	sp,sp,-112
ffffffe000200f4c:	06813423          	sd	s0,104(sp)
ffffffe000200f50:	07010413          	addi	s0,sp,112
ffffffe000200f54:	fca43423          	sd	a0,-56(s0)
ffffffe000200f58:	fcb43023          	sd	a1,-64(s0)
ffffffe000200f5c:	fac43c23          	sd	a2,-72(s0)
ffffffe000200f60:	fad43823          	sd	a3,-80(s0)
ffffffe000200f64:	fae43423          	sd	a4,-88(s0)
ffffffe000200f68:	faf43023          	sd	a5,-96(s0)
ffffffe000200f6c:	f9043c23          	sd	a6,-104(s0)
ffffffe000200f70:	f9143823          	sd	a7,-112(s0)
	
	struct sbiret ret;
    __asm__ volatile(
ffffffe000200f74:	fc843783          	ld	a5,-56(s0)
ffffffe000200f78:	fc043703          	ld	a4,-64(s0)
ffffffe000200f7c:	fb843683          	ld	a3,-72(s0)
ffffffe000200f80:	fb043603          	ld	a2,-80(s0)
ffffffe000200f84:	fa843583          	ld	a1,-88(s0)
ffffffe000200f88:	fa043503          	ld	a0,-96(s0)
ffffffe000200f8c:	f9843803          	ld	a6,-104(s0)
ffffffe000200f90:	f9043883          	ld	a7,-112(s0)
ffffffe000200f94:	00078893          	mv	a7,a5
ffffffe000200f98:	00070813          	mv	a6,a4
ffffffe000200f9c:	00068513          	mv	a0,a3
ffffffe000200fa0:	00060593          	mv	a1,a2
ffffffe000200fa4:	00058613          	mv	a2,a1
ffffffe000200fa8:	00050693          	mv	a3,a0
ffffffe000200fac:	00080713          	mv	a4,a6
ffffffe000200fb0:	00088793          	mv	a5,a7
ffffffe000200fb4:	00000073          	ecall
ffffffe000200fb8:	00050713          	mv	a4,a0
ffffffe000200fbc:	00058793          	mv	a5,a1
ffffffe000200fc0:	fce43823          	sd	a4,-48(s0)
ffffffe000200fc4:	fcf43c23          	sd	a5,-40(s0)
		"mv %[ret_error], a0\n"
		"mv %[ret_value], a1\n"
		: [ret_error] "=r" (ret.error), [ret_value] "=r" (ret.value)
		: [eid] "r" (eid), [fid] "r" (fid), [arg0] "r" (arg0), [arg1] "r" (arg1), [arg2] "r" (arg2), [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
	 );
	return ret;
ffffffe000200fc8:	fd043783          	ld	a5,-48(s0)
ffffffe000200fcc:	fef43023          	sd	a5,-32(s0)
ffffffe000200fd0:	fd843783          	ld	a5,-40(s0)
ffffffe000200fd4:	fef43423          	sd	a5,-24(s0)
ffffffe000200fd8:	fe043703          	ld	a4,-32(s0)
ffffffe000200fdc:	fe843783          	ld	a5,-24(s0)
ffffffe000200fe0:	00070313          	mv	t1,a4
ffffffe000200fe4:	00078393          	mv	t2,a5
ffffffe000200fe8:	00030713          	mv	a4,t1
ffffffe000200fec:	00038793          	mv	a5,t2
}
ffffffe000200ff0:	00070513          	mv	a0,a4
ffffffe000200ff4:	00078593          	mv	a1,a5
ffffffe000200ff8:	06813403          	ld	s0,104(sp)
ffffffe000200ffc:	07010113          	addi	sp,sp,112
ffffffe000201000:	00008067          	ret

ffffffe000201004 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe000201004:	fc010113          	addi	sp,sp,-64
ffffffe000201008:	02113c23          	sd	ra,56(sp)
ffffffe00020100c:	02813823          	sd	s0,48(sp)
ffffffe000201010:	03213423          	sd	s2,40(sp)
ffffffe000201014:	03313023          	sd	s3,32(sp)
ffffffe000201018:	04010413          	addi	s0,sp,64
ffffffe00020101c:	00050793          	mv	a5,a0
ffffffe000201020:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e, 2, byte, 0, 0, 0, 0, 0);
ffffffe000201024:	fcf44603          	lbu	a2,-49(s0)
ffffffe000201028:	00000893          	li	a7,0
ffffffe00020102c:	00000813          	li	a6,0
ffffffe000201030:	00000793          	li	a5,0
ffffffe000201034:	00000713          	li	a4,0
ffffffe000201038:	00000693          	li	a3,0
ffffffe00020103c:	00200593          	li	a1,2
ffffffe000201040:	44424537          	lui	a0,0x44424
ffffffe000201044:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000201048:	f01ff0ef          	jal	ffffffe000200f48 <sbi_ecall>
ffffffe00020104c:	00050713          	mv	a4,a0
ffffffe000201050:	00058793          	mv	a5,a1
ffffffe000201054:	fce43823          	sd	a4,-48(s0)
ffffffe000201058:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020105c:	fd043703          	ld	a4,-48(s0)
ffffffe000201060:	fd843783          	ld	a5,-40(s0)
ffffffe000201064:	00070913          	mv	s2,a4
ffffffe000201068:	00078993          	mv	s3,a5
ffffffe00020106c:	00090713          	mv	a4,s2
ffffffe000201070:	00098793          	mv	a5,s3
}
ffffffe000201074:	00070513          	mv	a0,a4
ffffffe000201078:	00078593          	mv	a1,a5
ffffffe00020107c:	03813083          	ld	ra,56(sp)
ffffffe000201080:	03013403          	ld	s0,48(sp)
ffffffe000201084:	02813903          	ld	s2,40(sp)
ffffffe000201088:	02013983          	ld	s3,32(sp)
ffffffe00020108c:	04010113          	addi	sp,sp,64
ffffffe000201090:	00008067          	ret

ffffffe000201094 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe000201094:	fc010113          	addi	sp,sp,-64
ffffffe000201098:	02113c23          	sd	ra,56(sp)
ffffffe00020109c:	02813823          	sd	s0,48(sp)
ffffffe0002010a0:	03213423          	sd	s2,40(sp)
ffffffe0002010a4:	03313023          	sd	s3,32(sp)
ffffffe0002010a8:	04010413          	addi	s0,sp,64
ffffffe0002010ac:	00050793          	mv	a5,a0
ffffffe0002010b0:	00058713          	mv	a4,a1
ffffffe0002010b4:	fcf42623          	sw	a5,-52(s0)
ffffffe0002010b8:	00070793          	mv	a5,a4
ffffffe0002010bc:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0, reset_type, reset_reason, 0, 0, 0, 0);
ffffffe0002010c0:	fcc46603          	lwu	a2,-52(s0)
ffffffe0002010c4:	fc846683          	lwu	a3,-56(s0)
ffffffe0002010c8:	00000893          	li	a7,0
ffffffe0002010cc:	00000813          	li	a6,0
ffffffe0002010d0:	00000793          	li	a5,0
ffffffe0002010d4:	00000713          	li	a4,0
ffffffe0002010d8:	00000593          	li	a1,0
ffffffe0002010dc:	53525537          	lui	a0,0x53525
ffffffe0002010e0:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe0002010e4:	e65ff0ef          	jal	ffffffe000200f48 <sbi_ecall>
ffffffe0002010e8:	00050713          	mv	a4,a0
ffffffe0002010ec:	00058793          	mv	a5,a1
ffffffe0002010f0:	fce43823          	sd	a4,-48(s0)
ffffffe0002010f4:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002010f8:	fd043703          	ld	a4,-48(s0)
ffffffe0002010fc:	fd843783          	ld	a5,-40(s0)
ffffffe000201100:	00070913          	mv	s2,a4
ffffffe000201104:	00078993          	mv	s3,a5
ffffffe000201108:	00090713          	mv	a4,s2
ffffffe00020110c:	00098793          	mv	a5,s3
}
ffffffe000201110:	00070513          	mv	a0,a4
ffffffe000201114:	00078593          	mv	a1,a5
ffffffe000201118:	03813083          	ld	ra,56(sp)
ffffffe00020111c:	03013403          	ld	s0,48(sp)
ffffffe000201120:	02813903          	ld	s2,40(sp)
ffffffe000201124:	02013983          	ld	s3,32(sp)
ffffffe000201128:	04010113          	addi	sp,sp,64
ffffffe00020112c:	00008067          	ret

ffffffe000201130 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value) {
ffffffe000201130:	fc010113          	addi	sp,sp,-64
ffffffe000201134:	02113c23          	sd	ra,56(sp)
ffffffe000201138:	02813823          	sd	s0,48(sp)
ffffffe00020113c:	03213423          	sd	s2,40(sp)
ffffffe000201140:	03313023          	sd	s3,32(sp)
ffffffe000201144:	04010413          	addi	s0,sp,64
ffffffe000201148:	fca43423          	sd	a0,-56(s0)
	return sbi_ecall(0x54494d45, 0, stime_value, 0, 0, 0, 0, 0);
ffffffe00020114c:	00000893          	li	a7,0
ffffffe000201150:	00000813          	li	a6,0
ffffffe000201154:	00000793          	li	a5,0
ffffffe000201158:	00000713          	li	a4,0
ffffffe00020115c:	00000693          	li	a3,0
ffffffe000201160:	fc843603          	ld	a2,-56(s0)
ffffffe000201164:	00000593          	li	a1,0
ffffffe000201168:	54495537          	lui	a0,0x54495
ffffffe00020116c:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe000201170:	dd9ff0ef          	jal	ffffffe000200f48 <sbi_ecall>
ffffffe000201174:	00050713          	mv	a4,a0
ffffffe000201178:	00058793          	mv	a5,a1
ffffffe00020117c:	fce43823          	sd	a4,-48(s0)
ffffffe000201180:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201184:	fd043703          	ld	a4,-48(s0)
ffffffe000201188:	fd843783          	ld	a5,-40(s0)
ffffffe00020118c:	00070913          	mv	s2,a4
ffffffe000201190:	00078993          	mv	s3,a5
ffffffe000201194:	00090713          	mv	a4,s2
ffffffe000201198:	00098793          	mv	a5,s3
}
ffffffe00020119c:	00070513          	mv	a0,a4
ffffffe0002011a0:	00078593          	mv	a1,a5
ffffffe0002011a4:	03813083          	ld	ra,56(sp)
ffffffe0002011a8:	03013403          	ld	s0,48(sp)
ffffffe0002011ac:	02813903          	ld	s2,40(sp)
ffffffe0002011b0:	02013983          	ld	s3,32(sp)
ffffffe0002011b4:	04010113          	addi	sp,sp,64
ffffffe0002011b8:	00008067          	ret

ffffffe0002011bc <sbi_debug_console_write>:

struct sbiret sbi_debug_console_write(unsigned long num_bytes,
									  unsigned long base_addr_lo,
									  unsigned long base_addr_hi) {
ffffffe0002011bc:	fb010113          	addi	sp,sp,-80
ffffffe0002011c0:	04113423          	sd	ra,72(sp)
ffffffe0002011c4:	04813023          	sd	s0,64(sp)
ffffffe0002011c8:	03213c23          	sd	s2,56(sp)
ffffffe0002011cc:	03313823          	sd	s3,48(sp)
ffffffe0002011d0:	05010413          	addi	s0,sp,80
ffffffe0002011d4:	fca43423          	sd	a0,-56(s0)
ffffffe0002011d8:	fcb43023          	sd	a1,-64(s0)
ffffffe0002011dc:	fac43c23          	sd	a2,-72(s0)
	return sbi_ecall(0x4442434e, 0, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
ffffffe0002011e0:	00000893          	li	a7,0
ffffffe0002011e4:	00000813          	li	a6,0
ffffffe0002011e8:	00000793          	li	a5,0
ffffffe0002011ec:	fb843703          	ld	a4,-72(s0)
ffffffe0002011f0:	fc043683          	ld	a3,-64(s0)
ffffffe0002011f4:	fc843603          	ld	a2,-56(s0)
ffffffe0002011f8:	00000593          	li	a1,0
ffffffe0002011fc:	44424537          	lui	a0,0x44424
ffffffe000201200:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000201204:	d45ff0ef          	jal	ffffffe000200f48 <sbi_ecall>
ffffffe000201208:	00050713          	mv	a4,a0
ffffffe00020120c:	00058793          	mv	a5,a1
ffffffe000201210:	fce43823          	sd	a4,-48(s0)
ffffffe000201214:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201218:	fd043703          	ld	a4,-48(s0)
ffffffe00020121c:	fd843783          	ld	a5,-40(s0)
ffffffe000201220:	00070913          	mv	s2,a4
ffffffe000201224:	00078993          	mv	s3,a5
ffffffe000201228:	00090713          	mv	a4,s2
ffffffe00020122c:	00098793          	mv	a5,s3
}
ffffffe000201230:	00070513          	mv	a0,a4
ffffffe000201234:	00078593          	mv	a1,a5
ffffffe000201238:	04813083          	ld	ra,72(sp)
ffffffe00020123c:	04013403          	ld	s0,64(sp)
ffffffe000201240:	03813903          	ld	s2,56(sp)
ffffffe000201244:	03013983          	ld	s3,48(sp)
ffffffe000201248:	05010113          	addi	sp,sp,80
ffffffe00020124c:	00008067          	ret

ffffffe000201250 <sbi_debug_console_read>:

struct sbiret sbi_debug_console_read(unsigned long num_bytes,
									 unsigned long base_addr_lo,
									 unsigned long base_addr_hi) {
ffffffe000201250:	fb010113          	addi	sp,sp,-80
ffffffe000201254:	04113423          	sd	ra,72(sp)
ffffffe000201258:	04813023          	sd	s0,64(sp)
ffffffe00020125c:	03213c23          	sd	s2,56(sp)
ffffffe000201260:	03313823          	sd	s3,48(sp)
ffffffe000201264:	05010413          	addi	s0,sp,80
ffffffe000201268:	fca43423          	sd	a0,-56(s0)
ffffffe00020126c:	fcb43023          	sd	a1,-64(s0)
ffffffe000201270:	fac43c23          	sd	a2,-72(s0)
	return sbi_ecall(0x4442434e, 1, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
ffffffe000201274:	00000893          	li	a7,0
ffffffe000201278:	00000813          	li	a6,0
ffffffe00020127c:	00000793          	li	a5,0
ffffffe000201280:	fb843703          	ld	a4,-72(s0)
ffffffe000201284:	fc043683          	ld	a3,-64(s0)
ffffffe000201288:	fc843603          	ld	a2,-56(s0)
ffffffe00020128c:	00100593          	li	a1,1
ffffffe000201290:	44424537          	lui	a0,0x44424
ffffffe000201294:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000201298:	cb1ff0ef          	jal	ffffffe000200f48 <sbi_ecall>
ffffffe00020129c:	00050713          	mv	a4,a0
ffffffe0002012a0:	00058793          	mv	a5,a1
ffffffe0002012a4:	fce43823          	sd	a4,-48(s0)
ffffffe0002012a8:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002012ac:	fd043703          	ld	a4,-48(s0)
ffffffe0002012b0:	fd843783          	ld	a5,-40(s0)
ffffffe0002012b4:	00070913          	mv	s2,a4
ffffffe0002012b8:	00078993          	mv	s3,a5
ffffffe0002012bc:	00090713          	mv	a4,s2
ffffffe0002012c0:	00098793          	mv	a5,s3
ffffffe0002012c4:	00070513          	mv	a0,a4
ffffffe0002012c8:	00078593          	mv	a1,a5
ffffffe0002012cc:	04813083          	ld	ra,72(sp)
ffffffe0002012d0:	04013403          	ld	s0,64(sp)
ffffffe0002012d4:	03813903          	ld	s2,56(sp)
ffffffe0002012d8:	03013983          	ld	s3,48(sp)
ffffffe0002012dc:	05010113          	addi	sp,sp,80
ffffffe0002012e0:	00008067          	ret

ffffffe0002012e4 <trap_handler>:
#include "clock.h"
#include "trap.h"

extern void do_timer();

void trap_handler(uint64_t scause, uint64_t sepc) {
ffffffe0002012e4:	fd010113          	addi	sp,sp,-48
ffffffe0002012e8:	02113423          	sd	ra,40(sp)
ffffffe0002012ec:	02813023          	sd	s0,32(sp)
ffffffe0002012f0:	03010413          	addi	s0,sp,48
ffffffe0002012f4:	fca43c23          	sd	a0,-40(s0)
ffffffe0002012f8:	fcb43823          	sd	a1,-48(s0)
    // 如果是 interrupt 判断是否是 timer interrupt
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试

    int is_interrupt = (scause >> 63) & 1;
ffffffe0002012fc:	fd843783          	ld	a5,-40(s0)
ffffffe000201300:	03f7d793          	srli	a5,a5,0x3f
ffffffe000201304:	fef42623          	sw	a5,-20(s0)
    
    if (is_interrupt) {
ffffffe000201308:	fec42783          	lw	a5,-20(s0)
ffffffe00020130c:	0007879b          	sext.w	a5,a5
ffffffe000201310:	02078c63          	beqz	a5,ffffffe000201348 <trap_handler+0x64>
        if (scause == 0x8000000000000005) {
ffffffe000201314:	fd843703          	ld	a4,-40(s0)
ffffffe000201318:	fff00793          	li	a5,-1
ffffffe00020131c:	03f79793          	slli	a5,a5,0x3f
ffffffe000201320:	00578793          	addi	a5,a5,5
ffffffe000201324:	00f71863          	bne	a4,a5,ffffffe000201334 <trap_handler+0x50>
            // printk("[S] Supervisor Mode Timer Interrupt\n");
            
            clock_set_next_event();
ffffffe000201328:	f61fe0ef          	jal	ffffffe000200288 <clock_set_next_event>
            do_timer();
ffffffe00020132c:	829ff0ef          	jal	ffffffe000200b54 <do_timer>
            printk("[S] Supervisor Mode Store/AMO page fault\n");
        } else {
            printk("[S] Unhandled interrupt/exception: scause=0x%lx\n", scause);
        }
    }
ffffffe000201330:	0b40006f          	j	ffffffe0002013e4 <trap_handler+0x100>
            printk("[S] Unhandled interrupt/exception: scause=0x%lx\n", scause);
ffffffe000201334:	fd843583          	ld	a1,-40(s0)
ffffffe000201338:	00002517          	auipc	a0,0x2
ffffffe00020133c:	17050513          	addi	a0,a0,368 # ffffffe0002034a8 <_srodata+0x4a8>
ffffffe000201340:	468010ef          	jal	ffffffe0002027a8 <printk>
ffffffe000201344:	0a00006f          	j	ffffffe0002013e4 <trap_handler+0x100>
        if (scause == 0x0000000000000007) {
ffffffe000201348:	fd843703          	ld	a4,-40(s0)
ffffffe00020134c:	00700793          	li	a5,7
ffffffe000201350:	00f71a63          	bne	a4,a5,ffffffe000201364 <trap_handler+0x80>
            printk("[S] Supervisor Mode Store/AMO Access Fault\n");
ffffffe000201354:	00002517          	auipc	a0,0x2
ffffffe000201358:	18c50513          	addi	a0,a0,396 # ffffffe0002034e0 <_srodata+0x4e0>
ffffffe00020135c:	44c010ef          	jal	ffffffe0002027a8 <printk>
ffffffe000201360:	0840006f          	j	ffffffe0002013e4 <trap_handler+0x100>
        } else if (scause == 0x0000000000000005) {
ffffffe000201364:	fd843703          	ld	a4,-40(s0)
ffffffe000201368:	00500793          	li	a5,5
ffffffe00020136c:	00f71a63          	bne	a4,a5,ffffffe000201380 <trap_handler+0x9c>
            printk("[S] Supervisor Mode Load Access Fault\n");
ffffffe000201370:	00002517          	auipc	a0,0x2
ffffffe000201374:	1a050513          	addi	a0,a0,416 # ffffffe000203510 <_srodata+0x510>
ffffffe000201378:	430010ef          	jal	ffffffe0002027a8 <printk>
ffffffe00020137c:	0680006f          	j	ffffffe0002013e4 <trap_handler+0x100>
        } else if (scause == 0x0000000000000001) {
ffffffe000201380:	fd843703          	ld	a4,-40(s0)
ffffffe000201384:	00100793          	li	a5,1
ffffffe000201388:	00f71a63          	bne	a4,a5,ffffffe00020139c <trap_handler+0xb8>
            printk("[S] Supervisor Mode Instruction Access Fault\n");
ffffffe00020138c:	00002517          	auipc	a0,0x2
ffffffe000201390:	1ac50513          	addi	a0,a0,428 # ffffffe000203538 <_srodata+0x538>
ffffffe000201394:	414010ef          	jal	ffffffe0002027a8 <printk>
ffffffe000201398:	04c0006f          	j	ffffffe0002013e4 <trap_handler+0x100>
        } else if (scause == 0x000000000000000c) {
ffffffe00020139c:	fd843703          	ld	a4,-40(s0)
ffffffe0002013a0:	00c00793          	li	a5,12
ffffffe0002013a4:	00f71a63          	bne	a4,a5,ffffffe0002013b8 <trap_handler+0xd4>
            printk("[S] Supervisor Mode Instruction Page Fault\n");
ffffffe0002013a8:	00002517          	auipc	a0,0x2
ffffffe0002013ac:	1c050513          	addi	a0,a0,448 # ffffffe000203568 <_srodata+0x568>
ffffffe0002013b0:	3f8010ef          	jal	ffffffe0002027a8 <printk>
ffffffe0002013b4:	0300006f          	j	ffffffe0002013e4 <trap_handler+0x100>
        } else if (scause == 0x000000000000000f) {
ffffffe0002013b8:	fd843703          	ld	a4,-40(s0)
ffffffe0002013bc:	00f00793          	li	a5,15
ffffffe0002013c0:	00f71a63          	bne	a4,a5,ffffffe0002013d4 <trap_handler+0xf0>
            printk("[S] Supervisor Mode Store/AMO page fault\n");
ffffffe0002013c4:	00002517          	auipc	a0,0x2
ffffffe0002013c8:	1d450513          	addi	a0,a0,468 # ffffffe000203598 <_srodata+0x598>
ffffffe0002013cc:	3dc010ef          	jal	ffffffe0002027a8 <printk>
ffffffe0002013d0:	0140006f          	j	ffffffe0002013e4 <trap_handler+0x100>
            printk("[S] Unhandled interrupt/exception: scause=0x%lx\n", scause);
ffffffe0002013d4:	fd843583          	ld	a1,-40(s0)
ffffffe0002013d8:	00002517          	auipc	a0,0x2
ffffffe0002013dc:	0d050513          	addi	a0,a0,208 # ffffffe0002034a8 <_srodata+0x4a8>
ffffffe0002013e0:	3c8010ef          	jal	ffffffe0002027a8 <printk>
ffffffe0002013e4:	00000013          	nop
ffffffe0002013e8:	02813083          	ld	ra,40(sp)
ffffffe0002013ec:	02013403          	ld	s0,32(sp)
ffffffe0002013f0:	03010113          	addi	sp,sp,48
ffffffe0002013f4:	00008067          	ret

ffffffe0002013f8 <setup_vm>:
/* early_pgtbl: 用于 setup_vm 进行 1GB 的 映射。 */
uint64_t  early_pgtbl[512] __attribute__((__aligned__(0x1000))); // uint64_t is 8 bytes, 4KB all together in a page
/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t  swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
ffffffe0002013f8:	fd010113          	addi	sp,sp,-48
ffffffe0002013fc:	02113423          	sd	ra,40(sp)
ffffffe000201400:	02813023          	sd	s0,32(sp)
ffffffe000201404:	03010413          	addi	s0,sp,48
     * the physical are considered as the offset, and the 9 bits in the middle are used as index
     * 
     * In the pte, only PPN[2](26 bits) is needed, thus turn the phyaddr[55:30] to pte[53:28]
    */

    uint64_t pte_flags = 0x1 | 0x2 | 0x4 | 0x8; // V | R | W | X
ffffffe000201408:	00f00793          	li	a5,15
ffffffe00020140c:	fef43423          	sd	a5,-24(s0)
    uint64_t table_index;
    uint64_t PHY_PPN_2 = (PHY_START >> 30) & 0x3ffffffUL;
ffffffe000201410:	00200793          	li	a5,2
ffffffe000201414:	fef43023          	sd	a5,-32(s0)
    uint64_t PTE_PPN_2 = (PHY_PPN_2 << 28) & 0x3ffffff0000000UL;
ffffffe000201418:	fe043783          	ld	a5,-32(s0)
ffffffe00020141c:	01c79713          	slli	a4,a5,0x1c
ffffffe000201420:	040007b7          	lui	a5,0x4000
ffffffe000201424:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000201428:	01c79793          	slli	a5,a5,0x1c
ffffffe00020142c:	00f777b3          	and	a5,a4,a5
ffffffe000201430:	fcf43c23          	sd	a5,-40(s0)


    // table_index = (PHY_START >> 30) & (0x1ffUL);        // GET 9-bit index
    // early_pgtbl[table_index] = PTE_PPN_2 | pte_flags; // set page table entry

    table_index = (VM_START >> 30) & (0x1ffUL);        // GET 9-bit index
ffffffe000201434:	18000793          	li	a5,384
ffffffe000201438:	fcf43823          	sd	a5,-48(s0)
    early_pgtbl[table_index] = PTE_PPN_2 | pte_flags; // set page table entry
ffffffe00020143c:	fd843703          	ld	a4,-40(s0)
ffffffe000201440:	fe843783          	ld	a5,-24(s0)
ffffffe000201444:	00f76733          	or	a4,a4,a5
ffffffe000201448:	00006697          	auipc	a3,0x6
ffffffe00020144c:	bb868693          	addi	a3,a3,-1096 # ffffffe000207000 <early_pgtbl>
ffffffe000201450:	fd043783          	ld	a5,-48(s0)
ffffffe000201454:	00379793          	slli	a5,a5,0x3
ffffffe000201458:	00f687b3          	add	a5,a3,a5
ffffffe00020145c:	00e7b023          	sd	a4,0(a5)

    printk(BOLD FG_COLOR(255, 95, 00)"...setup_vm done!\n" CLEAR);
ffffffe000201460:	00002517          	auipc	a0,0x2
ffffffe000201464:	16850513          	addi	a0,a0,360 # ffffffe0002035c8 <_srodata+0x5c8>
ffffffe000201468:	340010ef          	jal	ffffffe0002027a8 <printk>
    //                 (PHY_START >> 30) & (0x1ffUL), (((PHY_START >> 30) & 0x3ffffff) << 28) | pte_flags);

    // printk(RED "Set direct mapping: index = %#llx, tbl_entry = %#llx\n" CLEAR, 
    //                 (VM_START >> 30) & (0x1ffUL), (((PHY_START >> 30) & 0x3ffffff) << 28) | pte_flags);

}
ffffffe00020146c:	00000013          	nop
ffffffe000201470:	02813083          	ld	ra,40(sp)
ffffffe000201474:	02013403          	ld	s0,32(sp)
ffffffe000201478:	03010113          	addi	sp,sp,48
ffffffe00020147c:	00008067          	ret

ffffffe000201480 <setup_vm_final>:

void setup_vm_final() {
ffffffe000201480:	fd010113          	addi	sp,sp,-48
ffffffe000201484:	02113423          	sd	ra,40(sp)
ffffffe000201488:	02813023          	sd	s0,32(sp)
ffffffe00020148c:	03010413          	addi	s0,sp,48

    // No OpenSBI mapping required
    // Log("_stext = %#llx, _srodata = %#llx, sun = ", _stext, _srodata, (uint64_t)_srodata - (uint64_t)_stext);

    // mapping kernel text X|-|R|V
    printk(FG_COLOR(255, 95, 95) "Mapping kernel text section, NR_pages = %d ... \n" CLEAR, ((_srodata - _stext) >> 12)); // 3 page
ffffffe000201490:	00002717          	auipc	a4,0x2
ffffffe000201494:	b7070713          	addi	a4,a4,-1168 # ffffffe000203000 <_srodata>
ffffffe000201498:	fffff797          	auipc	a5,0xfffff
ffffffe00020149c:	b6878793          	addi	a5,a5,-1176 # ffffffe000200000 <_skernel>
ffffffe0002014a0:	40f707b3          	sub	a5,a4,a5
ffffffe0002014a4:	40c7d793          	srai	a5,a5,0xc
ffffffe0002014a8:	00078593          	mv	a1,a5
ffffffe0002014ac:	00002517          	auipc	a0,0x2
ffffffe0002014b0:	14c50513          	addi	a0,a0,332 # ffffffe0002035f8 <_srodata+0x5f8>
ffffffe0002014b4:	2f4010ef          	jal	ffffffe0002027a8 <printk>
    create_mapping(swapper_pg_dir, (uint64_t)_stext, (uint64_t)_stext - PA2VA_OFFSET, 
ffffffe0002014b8:	fffff597          	auipc	a1,0xfffff
ffffffe0002014bc:	b4858593          	addi	a1,a1,-1208 # ffffffe000200000 <_skernel>
ffffffe0002014c0:	fffff717          	auipc	a4,0xfffff
ffffffe0002014c4:	b4070713          	addi	a4,a4,-1216 # ffffffe000200000 <_skernel>
ffffffe0002014c8:	04100793          	li	a5,65
ffffffe0002014cc:	01f79793          	slli	a5,a5,0x1f
ffffffe0002014d0:	00f70633          	add	a2,a4,a5
                    (uint64_t)_srodata - (uint64_t)_stext, 0xb); // 4'b1011
ffffffe0002014d4:	00002717          	auipc	a4,0x2
ffffffe0002014d8:	b2c70713          	addi	a4,a4,-1236 # ffffffe000203000 <_srodata>
ffffffe0002014dc:	fffff797          	auipc	a5,0xfffff
ffffffe0002014e0:	b2478793          	addi	a5,a5,-1244 # ffffffe000200000 <_skernel>
    create_mapping(swapper_pg_dir, (uint64_t)_stext, (uint64_t)_stext - PA2VA_OFFSET, 
ffffffe0002014e4:	40f707b3          	sub	a5,a4,a5
ffffffe0002014e8:	00b00713          	li	a4,11
ffffffe0002014ec:	00078693          	mv	a3,a5
ffffffe0002014f0:	00007517          	auipc	a0,0x7
ffffffe0002014f4:	b1050513          	addi	a0,a0,-1264 # ffffffe000208000 <swapper_pg_dir>
ffffffe0002014f8:	174000ef          	jal	ffffffe00020166c <create_mapping>
    printk(FG_COLOR(255, 95, 95) "...mapping kernel text section done!\n" CLEAR);
ffffffe0002014fc:	00002517          	auipc	a0,0x2
ffffffe000201500:	14450513          	addi	a0,a0,324 # ffffffe000203640 <_srodata+0x640>
ffffffe000201504:	2a4010ef          	jal	ffffffe0002027a8 <printk>


    // mapping kernel rodata -|-|R|V
    printk(FG_COLOR(255, 95, 135) "Mapping kernel rodata, NR_pages = %d ...\n" CLEAR, ((_sdata - _srodata) >> 12)); // 1 page
ffffffe000201508:	00003717          	auipc	a4,0x3
ffffffe00020150c:	af870713          	addi	a4,a4,-1288 # ffffffe000204000 <TIMECLOCK>
ffffffe000201510:	00002797          	auipc	a5,0x2
ffffffe000201514:	af078793          	addi	a5,a5,-1296 # ffffffe000203000 <_srodata>
ffffffe000201518:	40f707b3          	sub	a5,a4,a5
ffffffe00020151c:	40c7d793          	srai	a5,a5,0xc
ffffffe000201520:	00078593          	mv	a1,a5
ffffffe000201524:	00002517          	auipc	a0,0x2
ffffffe000201528:	15c50513          	addi	a0,a0,348 # ffffffe000203680 <_srodata+0x680>
ffffffe00020152c:	27c010ef          	jal	ffffffe0002027a8 <printk>
    create_mapping(swapper_pg_dir, (uint64_t)_srodata, (uint64_t)_srodata - PA2VA_OFFSET, 
ffffffe000201530:	00002597          	auipc	a1,0x2
ffffffe000201534:	ad058593          	addi	a1,a1,-1328 # ffffffe000203000 <_srodata>
ffffffe000201538:	00002717          	auipc	a4,0x2
ffffffe00020153c:	ac870713          	addi	a4,a4,-1336 # ffffffe000203000 <_srodata>
ffffffe000201540:	04100793          	li	a5,65
ffffffe000201544:	01f79793          	slli	a5,a5,0x1f
ffffffe000201548:	00f70633          	add	a2,a4,a5
                    (uint64_t)_sdata - (uint64_t)_srodata, 0x3); // 4'b0011
ffffffe00020154c:	00003717          	auipc	a4,0x3
ffffffe000201550:	ab470713          	addi	a4,a4,-1356 # ffffffe000204000 <TIMECLOCK>
ffffffe000201554:	00002797          	auipc	a5,0x2
ffffffe000201558:	aac78793          	addi	a5,a5,-1364 # ffffffe000203000 <_srodata>
    create_mapping(swapper_pg_dir, (uint64_t)_srodata, (uint64_t)_srodata - PA2VA_OFFSET, 
ffffffe00020155c:	40f707b3          	sub	a5,a4,a5
ffffffe000201560:	00300713          	li	a4,3
ffffffe000201564:	00078693          	mv	a3,a5
ffffffe000201568:	00007517          	auipc	a0,0x7
ffffffe00020156c:	a9850513          	addi	a0,a0,-1384 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201570:	0fc000ef          	jal	ffffffe00020166c <create_mapping>
    printk(FG_COLOR(255, 95, 135) "...mapping kernel rodata section done!\n" CLEAR);
ffffffe000201574:	00002517          	auipc	a0,0x2
ffffffe000201578:	14c50513          	addi	a0,a0,332 # ffffffe0002036c0 <_srodata+0x6c0>
ffffffe00020157c:	22c010ef          	jal	ffffffe0002027a8 <printk>

    // mapping other memory -|W|R|V
    printk(FG_COLOR(255, 95, 175) "Mapping kernel other data, NR_pages = %d ...\n" CLEAR, (PHY_SIZE - ((uint64_t)_sdata - (uint64_t)_stext) >> 12)); // 32764 pages
ffffffe000201580:	fffff717          	auipc	a4,0xfffff
ffffffe000201584:	a8070713          	addi	a4,a4,-1408 # ffffffe000200000 <_skernel>
ffffffe000201588:	080007b7          	lui	a5,0x8000
ffffffe00020158c:	00f70733          	add	a4,a4,a5
ffffffe000201590:	00003797          	auipc	a5,0x3
ffffffe000201594:	a7078793          	addi	a5,a5,-1424 # ffffffe000204000 <TIMECLOCK>
ffffffe000201598:	40f707b3          	sub	a5,a4,a5
ffffffe00020159c:	00c7d793          	srli	a5,a5,0xc
ffffffe0002015a0:	00078593          	mv	a1,a5
ffffffe0002015a4:	00002517          	auipc	a0,0x2
ffffffe0002015a8:	15c50513          	addi	a0,a0,348 # ffffffe000203700 <_srodata+0x700>
ffffffe0002015ac:	1fc010ef          	jal	ffffffe0002027a8 <printk>
    create_mapping(swapper_pg_dir, (uint64_t)_sdata, (uint64_t)_sdata - PA2VA_OFFSET, 
ffffffe0002015b0:	00003597          	auipc	a1,0x3
ffffffe0002015b4:	a5058593          	addi	a1,a1,-1456 # ffffffe000204000 <TIMECLOCK>
ffffffe0002015b8:	00003717          	auipc	a4,0x3
ffffffe0002015bc:	a4870713          	addi	a4,a4,-1464 # ffffffe000204000 <TIMECLOCK>
ffffffe0002015c0:	04100793          	li	a5,65
ffffffe0002015c4:	01f79793          	slli	a5,a5,0x1f
ffffffe0002015c8:	00f70633          	add	a2,a4,a5
                    PHY_SIZE - ((uint64_t)_sdata - (uint64_t)_stext), 0x7); // 4'b0111
ffffffe0002015cc:	fffff717          	auipc	a4,0xfffff
ffffffe0002015d0:	a3470713          	addi	a4,a4,-1484 # ffffffe000200000 <_skernel>
ffffffe0002015d4:	080007b7          	lui	a5,0x8000
ffffffe0002015d8:	00f70733          	add	a4,a4,a5
ffffffe0002015dc:	00003797          	auipc	a5,0x3
ffffffe0002015e0:	a2478793          	addi	a5,a5,-1500 # ffffffe000204000 <TIMECLOCK>
    create_mapping(swapper_pg_dir, (uint64_t)_sdata, (uint64_t)_sdata - PA2VA_OFFSET, 
ffffffe0002015e4:	40f707b3          	sub	a5,a4,a5
ffffffe0002015e8:	00700713          	li	a4,7
ffffffe0002015ec:	00078693          	mv	a3,a5
ffffffe0002015f0:	00007517          	auipc	a0,0x7
ffffffe0002015f4:	a1050513          	addi	a0,a0,-1520 # ffffffe000208000 <swapper_pg_dir>
ffffffe0002015f8:	074000ef          	jal	ffffffe00020166c <create_mapping>
    printk(FG_COLOR(255, 97, 215) "...mapping kernel other data done!\n" CLEAR);
ffffffe0002015fc:	00002517          	auipc	a0,0x2
ffffffe000201600:	14c50513          	addi	a0,a0,332 # ffffffe000203748 <_srodata+0x748>
ffffffe000201604:	1a4010ef          	jal	ffffffe0002027a8 <printk>

    // set satp with swapper_pg_dir
    uint64_t phy_swapper_pg_dir = (uint64_t)swapper_pg_dir - PA2VA_OFFSET;
ffffffe000201608:	00007717          	auipc	a4,0x7
ffffffe00020160c:	9f870713          	addi	a4,a4,-1544 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201610:	04100793          	li	a5,65
ffffffe000201614:	01f79793          	slli	a5,a5,0x1f
ffffffe000201618:	00f707b3          	add	a5,a4,a5
ffffffe00020161c:	fef43423          	sd	a5,-24(s0)
    uint64_t satp_value = (phy_swapper_pg_dir >> 12) + 0x8000000000000000;
ffffffe000201620:	fe843783          	ld	a5,-24(s0)
ffffffe000201624:	00c7d713          	srli	a4,a5,0xc
ffffffe000201628:	fff00793          	li	a5,-1
ffffffe00020162c:	03f79793          	slli	a5,a5,0x3f
ffffffe000201630:	00f707b3          	add	a5,a4,a5
ffffffe000201634:	fef43023          	sd	a5,-32(s0)
    csr_write(satp, satp_value);
ffffffe000201638:	fe043783          	ld	a5,-32(s0)
ffffffe00020163c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201640:	fd843783          	ld	a5,-40(s0)
ffffffe000201644:	18079073          	csrw	satp,a5

    // printk(YELLOW "Set satp = %#llx\n, addr of swapper = %#llx ,virtual addr = %#llx\n" CLEAR, satp_value, (uint64_t)phy_swapper_pg_dir, (uint64_t)swapper_pg_dir);

    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe000201648:	12000073          	sfence.vma

    // flush icache
    // asm volatile("fence.i");

    printk(FG_COLOR(255, 95, 255) "...setup_vm_final done!\n" CLEAR);
ffffffe00020164c:	00002517          	auipc	a0,0x2
ffffffe000201650:	13c50513          	addi	a0,a0,316 # ffffffe000203788 <_srodata+0x788>
ffffffe000201654:	154010ef          	jal	ffffffe0002027a8 <printk>

    return;
ffffffe000201658:	00000013          	nop
}
ffffffe00020165c:	02813083          	ld	ra,40(sp)
ffffffe000201660:	02013403          	ld	s0,32(sp)
ffffffe000201664:	03010113          	addi	sp,sp,48
ffffffe000201668:	00008067          	ret

ffffffe00020166c <create_mapping>:

void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe00020166c:	f6010113          	addi	sp,sp,-160
ffffffe000201670:	08113c23          	sd	ra,152(sp)
ffffffe000201674:	08813823          	sd	s0,144(sp)
ffffffe000201678:	0a010413          	addi	s0,sp,160
ffffffe00020167c:	f8a43423          	sd	a0,-120(s0)
ffffffe000201680:	f8b43023          	sd	a1,-128(s0)
ffffffe000201684:	f6c43c23          	sd	a2,-136(s0)
ffffffe000201688:	f6d43823          	sd	a3,-144(s0)
ffffffe00020168c:	f6e43423          	sd	a4,-152(s0)
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/

    uint64_t num_pages = sz >> 12;
ffffffe000201690:	f7043783          	ld	a5,-144(s0)
ffffffe000201694:	00c7d793          	srli	a5,a5,0xc
ffffffe000201698:	fef43423          	sd	a5,-24(s0)
    if (sz % 0x1000 != 0)  num_pages++;
ffffffe00020169c:	f7043703          	ld	a4,-144(s0)
ffffffe0002016a0:	000017b7          	lui	a5,0x1
ffffffe0002016a4:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe0002016a8:	00f777b3          	and	a5,a4,a5
ffffffe0002016ac:	00078863          	beqz	a5,ffffffe0002016bc <create_mapping+0x50>
ffffffe0002016b0:	fe843783          	ld	a5,-24(s0)
ffffffe0002016b4:	00178793          	addi	a5,a5,1
ffffffe0002016b8:	fef43423          	sd	a5,-24(s0)
    // Log("va = %#llx, pa = %#llx", va, pa);
    // printk();
    
    for (uint64_t i = 0; i < num_pages; i++) {
ffffffe0002016bc:	fe043023          	sd	zero,-32(s0)
ffffffe0002016c0:	1a40006f          	j	ffffffe000201864 <create_mapping+0x1f8>
        // Log("va = %#llx, pa = %#llx", va, pa);
        // Log("VPN_2 = %#llx, VPN_1 = %#llx, VPN_0 = %#llx", VPN_2, VPN_1, VPN_0);
        uint64_t VPN_2 = (va >> 30) & 0x1ffUL;
ffffffe0002016c4:	f8043783          	ld	a5,-128(s0)
ffffffe0002016c8:	01e7d793          	srli	a5,a5,0x1e
ffffffe0002016cc:	1ff7f793          	andi	a5,a5,511
ffffffe0002016d0:	fcf43c23          	sd	a5,-40(s0)
        uint64_t VPN_1 = (va >> 21) & 0x1ffUL;
ffffffe0002016d4:	f8043783          	ld	a5,-128(s0)
ffffffe0002016d8:	0157d793          	srli	a5,a5,0x15
ffffffe0002016dc:	1ff7f793          	andi	a5,a5,511
ffffffe0002016e0:	fcf43823          	sd	a5,-48(s0)
        uint64_t VPN_0 = (va >> 12) & 0x1ffUL;
ffffffe0002016e4:	f8043783          	ld	a5,-128(s0)
ffffffe0002016e8:	00c7d793          	srli	a5,a5,0xc
ffffffe0002016ec:	1ff7f793          	andi	a5,a5,511
ffffffe0002016f0:	fcf43423          	sd	a5,-56(s0)

        uintptr_t* pmd;
        uintptr_t* pte;

        // Log("pgtbl[VPN_2] = %#llx", pgtbl[VPN_2]);
        if ((pgtbl[VPN_2] & 0x1) == 0) {
ffffffe0002016f4:	fd843783          	ld	a5,-40(s0)
ffffffe0002016f8:	00379793          	slli	a5,a5,0x3
ffffffe0002016fc:	f8843703          	ld	a4,-120(s0)
ffffffe000201700:	00f707b3          	add	a5,a4,a5
ffffffe000201704:	0007b783          	ld	a5,0(a5)
ffffffe000201708:	0017f793          	andi	a5,a5,1
ffffffe00020170c:	04079263          	bnez	a5,ffffffe000201750 <create_mapping+0xe4>
            uint64_t* new_pmd_va = (uint64_t*)kalloc(); // allocate a page for pmd
ffffffe000201710:	bc1fe0ef          	jal	ffffffe0002002d0 <kalloc>
ffffffe000201714:	fca43023          	sd	a0,-64(s0)
            uint64_t new_pmd_pa = (uint64_t)new_pmd_va - PA2VA_OFFSET;
ffffffe000201718:	fc043703          	ld	a4,-64(s0)
ffffffe00020171c:	04100793          	li	a5,65
ffffffe000201720:	01f79793          	slli	a5,a5,0x1f
ffffffe000201724:	00f707b3          	add	a5,a4,a5
ffffffe000201728:	faf43c23          	sd	a5,-72(s0)
            // Log("new_pmd_va = %#llx, new_pmd_pa = %#llx", new_pmd_va, new_pmd_pa);
            pgtbl[VPN_2] = (((new_pmd_pa) >> 12) << 10) | 0x1;
ffffffe00020172c:	fb843783          	ld	a5,-72(s0)
ffffffe000201730:	00c7d793          	srli	a5,a5,0xc
ffffffe000201734:	00a79713          	slli	a4,a5,0xa
ffffffe000201738:	fd843783          	ld	a5,-40(s0)
ffffffe00020173c:	00379793          	slli	a5,a5,0x3
ffffffe000201740:	f8843683          	ld	a3,-120(s0)
ffffffe000201744:	00f687b3          	add	a5,a3,a5
ffffffe000201748:	00176713          	ori	a4,a4,1
ffffffe00020174c:	00e7b023          	sd	a4,0(a5)
        }
        pmd = (uint64_t*)(((pgtbl[VPN_2] >> 10) << 12) + PA2VA_OFFSET); // need to use virtual addr to find the table
ffffffe000201750:	fd843783          	ld	a5,-40(s0)
ffffffe000201754:	00379793          	slli	a5,a5,0x3
ffffffe000201758:	f8843703          	ld	a4,-120(s0)
ffffffe00020175c:	00f707b3          	add	a5,a4,a5
ffffffe000201760:	0007b783          	ld	a5,0(a5)
ffffffe000201764:	00a7d793          	srli	a5,a5,0xa
ffffffe000201768:	00c79713          	slli	a4,a5,0xc
ffffffe00020176c:	fbf00793          	li	a5,-65
ffffffe000201770:	01f79793          	slli	a5,a5,0x1f
ffffffe000201774:	00f707b3          	add	a5,a4,a5
ffffffe000201778:	faf43823          	sd	a5,-80(s0)

        // Log("pmd = %#llx", pmd);
        // Log("pmd[VPN_1] = %#llx", pmd[VPN_1]);
        if ((pmd[VPN_1] & 0x1) == 0) {
ffffffe00020177c:	fd043783          	ld	a5,-48(s0)
ffffffe000201780:	00379793          	slli	a5,a5,0x3
ffffffe000201784:	fb043703          	ld	a4,-80(s0)
ffffffe000201788:	00f707b3          	add	a5,a4,a5
ffffffe00020178c:	0007b783          	ld	a5,0(a5)
ffffffe000201790:	0017f793          	andi	a5,a5,1
ffffffe000201794:	04079263          	bnez	a5,ffffffe0002017d8 <create_mapping+0x16c>
            uint64_t* new_pte_va = (uint64_t*)kalloc(); // allocate a page for pte
ffffffe000201798:	b39fe0ef          	jal	ffffffe0002002d0 <kalloc>
ffffffe00020179c:	faa43423          	sd	a0,-88(s0)
            uint64_t new_pte_pa = (uint64_t)new_pte_va - PA2VA_OFFSET;
ffffffe0002017a0:	fa843703          	ld	a4,-88(s0)
ffffffe0002017a4:	04100793          	li	a5,65
ffffffe0002017a8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002017ac:	00f707b3          	add	a5,a4,a5
ffffffe0002017b0:	faf43023          	sd	a5,-96(s0)
            pmd[VPN_1] = ((new_pte_pa >> 12) << 10) | 0x1;
ffffffe0002017b4:	fa043783          	ld	a5,-96(s0)
ffffffe0002017b8:	00c7d793          	srli	a5,a5,0xc
ffffffe0002017bc:	00a79713          	slli	a4,a5,0xa
ffffffe0002017c0:	fd043783          	ld	a5,-48(s0)
ffffffe0002017c4:	00379793          	slli	a5,a5,0x3
ffffffe0002017c8:	fb043683          	ld	a3,-80(s0)
ffffffe0002017cc:	00f687b3          	add	a5,a3,a5
ffffffe0002017d0:	00176713          	ori	a4,a4,1
ffffffe0002017d4:	00e7b023          	sd	a4,0(a5)
        }
        pte = (uint64_t*)(((pmd[VPN_1] >> 10) << 12) + PA2VA_OFFSET);
ffffffe0002017d8:	fd043783          	ld	a5,-48(s0)
ffffffe0002017dc:	00379793          	slli	a5,a5,0x3
ffffffe0002017e0:	fb043703          	ld	a4,-80(s0)
ffffffe0002017e4:	00f707b3          	add	a5,a4,a5
ffffffe0002017e8:	0007b783          	ld	a5,0(a5)
ffffffe0002017ec:	00a7d793          	srli	a5,a5,0xa
ffffffe0002017f0:	00c79713          	slli	a4,a5,0xc
ffffffe0002017f4:	fbf00793          	li	a5,-65
ffffffe0002017f8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002017fc:	00f707b3          	add	a5,a4,a5
ffffffe000201800:	f8f43c23          	sd	a5,-104(s0)

        // Log("pte = %#llx", pte);
        pte[VPN_0] = (((pa >> 12) << 10) | perm) & 0x3fffffffffffffUL; // set pte entry
ffffffe000201804:	f7843783          	ld	a5,-136(s0)
ffffffe000201808:	00c7d793          	srli	a5,a5,0xc
ffffffe00020180c:	00a79713          	slli	a4,a5,0xa
ffffffe000201810:	f6843783          	ld	a5,-152(s0)
ffffffe000201814:	00f766b3          	or	a3,a4,a5
ffffffe000201818:	fc843783          	ld	a5,-56(s0)
ffffffe00020181c:	00379793          	slli	a5,a5,0x3
ffffffe000201820:	f9843703          	ld	a4,-104(s0)
ffffffe000201824:	00f707b3          	add	a5,a4,a5
ffffffe000201828:	fff00713          	li	a4,-1
ffffffe00020182c:	00a75713          	srli	a4,a4,0xa
ffffffe000201830:	00e6f733          	and	a4,a3,a4
ffffffe000201834:	00e7b023          	sd	a4,0(a5)
        
        va += PGSIZE;
ffffffe000201838:	f8043703          	ld	a4,-128(s0)
ffffffe00020183c:	000017b7          	lui	a5,0x1
ffffffe000201840:	00f707b3          	add	a5,a4,a5
ffffffe000201844:	f8f43023          	sd	a5,-128(s0)
        pa += PGSIZE;
ffffffe000201848:	f7843703          	ld	a4,-136(s0)
ffffffe00020184c:	000017b7          	lui	a5,0x1
ffffffe000201850:	00f707b3          	add	a5,a4,a5
ffffffe000201854:	f6f43c23          	sd	a5,-136(s0)
    for (uint64_t i = 0; i < num_pages; i++) {
ffffffe000201858:	fe043783          	ld	a5,-32(s0)
ffffffe00020185c:	00178793          	addi	a5,a5,1 # 1001 <PGSIZE+0x1>
ffffffe000201860:	fef43023          	sd	a5,-32(s0)
ffffffe000201864:	fe043703          	ld	a4,-32(s0)
ffffffe000201868:	fe843783          	ld	a5,-24(s0)
ffffffe00020186c:	e4f76ce3          	bltu	a4,a5,ffffffe0002016c4 <create_mapping+0x58>
    }

    return;
ffffffe000201870:	00000013          	nop
ffffffe000201874:	09813083          	ld	ra,152(sp)
ffffffe000201878:	09013403          	ld	s0,144(sp)
ffffffe00020187c:	0a010113          	addi	sp,sp,160
ffffffe000201880:	00008067          	ret

ffffffe000201884 <start_kernel>:

extern void test();
extern char _stext[];
extern char _srodata[];

int start_kernel() {
ffffffe000201884:	ff010113          	addi	sp,sp,-16
ffffffe000201888:	00113423          	sd	ra,8(sp)
ffffffe00020188c:	00813023          	sd	s0,0(sp)
ffffffe000201890:	01010413          	addi	s0,sp,16
    printk(FG_COLOR(175, 175, 255) "2024" CLEAR);
ffffffe000201894:	00002517          	auipc	a0,0x2
ffffffe000201898:	f2450513          	addi	a0,a0,-220 # ffffffe0002037b8 <_srodata+0x7b8>
ffffffe00020189c:	70d000ef          	jal	ffffffe0002027a8 <printk>
    printk(FG_COLOR(215, 175, 255) " ZJU Operating System\n" CLEAR);
ffffffe0002018a0:	00002517          	auipc	a0,0x2
ffffffe0002018a4:	f3850513          	addi	a0,a0,-200 # ffffffe0002037d8 <_srodata+0x7d8>
ffffffe0002018a8:	701000ef          	jal	ffffffe0002027a8 <printk>
    printk(BOLD FG_COLOR(255, 135, 255) "---------------------------------------\n\n" CLEAR);
ffffffe0002018ac:	00002517          	auipc	a0,0x2
ffffffe0002018b0:	f5c50513          	addi	a0,a0,-164 # ffffffe000203808 <_srodata+0x808>
ffffffe0002018b4:	6f5000ef          	jal	ffffffe0002027a8 <printk>
    // check rodata section: execute property
    // void (*func)() = (void*)_srodata;
    // func();
   

    test();
ffffffe0002018b8:	01c000ef          	jal	ffffffe0002018d4 <test>
    return 0;
ffffffe0002018bc:	00000793          	li	a5,0
}
ffffffe0002018c0:	00078513          	mv	a0,a5
ffffffe0002018c4:	00813083          	ld	ra,8(sp)
ffffffe0002018c8:	00013403          	ld	s0,0(sp)
ffffffe0002018cc:	01010113          	addi	sp,sp,16
ffffffe0002018d0:	00008067          	ret

ffffffe0002018d4 <test>:
#include "sbi.h"
#include "printk.h"
extern void dummy();

void test() {
ffffffe0002018d4:	fe010113          	addi	sp,sp,-32
ffffffe0002018d8:	00813c23          	sd	s0,24(sp)
ffffffe0002018dc:	02010413          	addi	s0,sp,32
    int i = 0;
ffffffe0002018e0:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
ffffffe0002018e4:	fec42783          	lw	a5,-20(s0)
ffffffe0002018e8:	0017879b          	addiw	a5,a5,1
ffffffe0002018ec:	fef42623          	sw	a5,-20(s0)
ffffffe0002018f0:	fec42783          	lw	a5,-20(s0)
ffffffe0002018f4:	00078713          	mv	a4,a5
ffffffe0002018f8:	05f5e7b7          	lui	a5,0x5f5e
ffffffe0002018fc:	1007879b          	addiw	a5,a5,256 # 5f5e100 <OPENSBI_SIZE+0x5d5e100>
ffffffe000201900:	02f767bb          	remw	a5,a4,a5
ffffffe000201904:	0007879b          	sext.w	a5,a5
ffffffe000201908:	fc079ee3          	bnez	a5,ffffffe0002018e4 <test+0x10>
            // printk("kernel is running!\n");
            i = 0;
ffffffe00020190c:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
ffffffe000201910:	fd5ff06f          	j	ffffffe0002018e4 <test+0x10>

ffffffe000201914 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe000201914:	fe010113          	addi	sp,sp,-32
ffffffe000201918:	00113c23          	sd	ra,24(sp)
ffffffe00020191c:	00813823          	sd	s0,16(sp)
ffffffe000201920:	02010413          	addi	s0,sp,32
ffffffe000201924:	00050793          	mv	a5,a0
ffffffe000201928:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe00020192c:	fec42783          	lw	a5,-20(s0)
ffffffe000201930:	0ff7f793          	zext.b	a5,a5
ffffffe000201934:	00078513          	mv	a0,a5
ffffffe000201938:	eccff0ef          	jal	ffffffe000201004 <sbi_debug_console_write_byte>
    return (char)c;
ffffffe00020193c:	fec42783          	lw	a5,-20(s0)
ffffffe000201940:	0ff7f793          	zext.b	a5,a5
ffffffe000201944:	0007879b          	sext.w	a5,a5
}
ffffffe000201948:	00078513          	mv	a0,a5
ffffffe00020194c:	01813083          	ld	ra,24(sp)
ffffffe000201950:	01013403          	ld	s0,16(sp)
ffffffe000201954:	02010113          	addi	sp,sp,32
ffffffe000201958:	00008067          	ret

ffffffe00020195c <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe00020195c:	fe010113          	addi	sp,sp,-32
ffffffe000201960:	00813c23          	sd	s0,24(sp)
ffffffe000201964:	02010413          	addi	s0,sp,32
ffffffe000201968:	00050793          	mv	a5,a0
ffffffe00020196c:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000201970:	fec42783          	lw	a5,-20(s0)
ffffffe000201974:	0007871b          	sext.w	a4,a5
ffffffe000201978:	02000793          	li	a5,32
ffffffe00020197c:	02f70263          	beq	a4,a5,ffffffe0002019a0 <isspace+0x44>
ffffffe000201980:	fec42783          	lw	a5,-20(s0)
ffffffe000201984:	0007871b          	sext.w	a4,a5
ffffffe000201988:	00800793          	li	a5,8
ffffffe00020198c:	00e7de63          	bge	a5,a4,ffffffe0002019a8 <isspace+0x4c>
ffffffe000201990:	fec42783          	lw	a5,-20(s0)
ffffffe000201994:	0007871b          	sext.w	a4,a5
ffffffe000201998:	00d00793          	li	a5,13
ffffffe00020199c:	00e7c663          	blt	a5,a4,ffffffe0002019a8 <isspace+0x4c>
ffffffe0002019a0:	00100793          	li	a5,1
ffffffe0002019a4:	0080006f          	j	ffffffe0002019ac <isspace+0x50>
ffffffe0002019a8:	00000793          	li	a5,0
}
ffffffe0002019ac:	00078513          	mv	a0,a5
ffffffe0002019b0:	01813403          	ld	s0,24(sp)
ffffffe0002019b4:	02010113          	addi	sp,sp,32
ffffffe0002019b8:	00008067          	ret

ffffffe0002019bc <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe0002019bc:	fb010113          	addi	sp,sp,-80
ffffffe0002019c0:	04113423          	sd	ra,72(sp)
ffffffe0002019c4:	04813023          	sd	s0,64(sp)
ffffffe0002019c8:	05010413          	addi	s0,sp,80
ffffffe0002019cc:	fca43423          	sd	a0,-56(s0)
ffffffe0002019d0:	fcb43023          	sd	a1,-64(s0)
ffffffe0002019d4:	00060793          	mv	a5,a2
ffffffe0002019d8:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe0002019dc:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe0002019e0:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe0002019e4:	fc843783          	ld	a5,-56(s0)
ffffffe0002019e8:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe0002019ec:	0100006f          	j	ffffffe0002019fc <strtol+0x40>
        p++;
ffffffe0002019f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002019f4:	00178793          	addi	a5,a5,1
ffffffe0002019f8:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe0002019fc:	fd843783          	ld	a5,-40(s0)
ffffffe000201a00:	0007c783          	lbu	a5,0(a5)
ffffffe000201a04:	0007879b          	sext.w	a5,a5
ffffffe000201a08:	00078513          	mv	a0,a5
ffffffe000201a0c:	f51ff0ef          	jal	ffffffe00020195c <isspace>
ffffffe000201a10:	00050793          	mv	a5,a0
ffffffe000201a14:	fc079ee3          	bnez	a5,ffffffe0002019f0 <strtol+0x34>
    }

    if (*p == '-') {
ffffffe000201a18:	fd843783          	ld	a5,-40(s0)
ffffffe000201a1c:	0007c783          	lbu	a5,0(a5)
ffffffe000201a20:	00078713          	mv	a4,a5
ffffffe000201a24:	02d00793          	li	a5,45
ffffffe000201a28:	00f71e63          	bne	a4,a5,ffffffe000201a44 <strtol+0x88>
        neg = true;
ffffffe000201a2c:	00100793          	li	a5,1
ffffffe000201a30:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe000201a34:	fd843783          	ld	a5,-40(s0)
ffffffe000201a38:	00178793          	addi	a5,a5,1
ffffffe000201a3c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201a40:	0240006f          	j	ffffffe000201a64 <strtol+0xa8>
    } else if (*p == '+') {
ffffffe000201a44:	fd843783          	ld	a5,-40(s0)
ffffffe000201a48:	0007c783          	lbu	a5,0(a5)
ffffffe000201a4c:	00078713          	mv	a4,a5
ffffffe000201a50:	02b00793          	li	a5,43
ffffffe000201a54:	00f71863          	bne	a4,a5,ffffffe000201a64 <strtol+0xa8>
        p++;
ffffffe000201a58:	fd843783          	ld	a5,-40(s0)
ffffffe000201a5c:	00178793          	addi	a5,a5,1
ffffffe000201a60:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe000201a64:	fbc42783          	lw	a5,-68(s0)
ffffffe000201a68:	0007879b          	sext.w	a5,a5
ffffffe000201a6c:	06079c63          	bnez	a5,ffffffe000201ae4 <strtol+0x128>
        if (*p == '0') {
ffffffe000201a70:	fd843783          	ld	a5,-40(s0)
ffffffe000201a74:	0007c783          	lbu	a5,0(a5)
ffffffe000201a78:	00078713          	mv	a4,a5
ffffffe000201a7c:	03000793          	li	a5,48
ffffffe000201a80:	04f71e63          	bne	a4,a5,ffffffe000201adc <strtol+0x120>
            p++;
ffffffe000201a84:	fd843783          	ld	a5,-40(s0)
ffffffe000201a88:	00178793          	addi	a5,a5,1
ffffffe000201a8c:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe000201a90:	fd843783          	ld	a5,-40(s0)
ffffffe000201a94:	0007c783          	lbu	a5,0(a5)
ffffffe000201a98:	00078713          	mv	a4,a5
ffffffe000201a9c:	07800793          	li	a5,120
ffffffe000201aa0:	00f70c63          	beq	a4,a5,ffffffe000201ab8 <strtol+0xfc>
ffffffe000201aa4:	fd843783          	ld	a5,-40(s0)
ffffffe000201aa8:	0007c783          	lbu	a5,0(a5)
ffffffe000201aac:	00078713          	mv	a4,a5
ffffffe000201ab0:	05800793          	li	a5,88
ffffffe000201ab4:	00f71e63          	bne	a4,a5,ffffffe000201ad0 <strtol+0x114>
                base = 16;
ffffffe000201ab8:	01000793          	li	a5,16
ffffffe000201abc:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe000201ac0:	fd843783          	ld	a5,-40(s0)
ffffffe000201ac4:	00178793          	addi	a5,a5,1
ffffffe000201ac8:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201acc:	0180006f          	j	ffffffe000201ae4 <strtol+0x128>
            } else {
                base = 8;
ffffffe000201ad0:	00800793          	li	a5,8
ffffffe000201ad4:	faf42e23          	sw	a5,-68(s0)
ffffffe000201ad8:	00c0006f          	j	ffffffe000201ae4 <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe000201adc:	00a00793          	li	a5,10
ffffffe000201ae0:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe000201ae4:	fd843783          	ld	a5,-40(s0)
ffffffe000201ae8:	0007c783          	lbu	a5,0(a5)
ffffffe000201aec:	00078713          	mv	a4,a5
ffffffe000201af0:	02f00793          	li	a5,47
ffffffe000201af4:	02e7f863          	bgeu	a5,a4,ffffffe000201b24 <strtol+0x168>
ffffffe000201af8:	fd843783          	ld	a5,-40(s0)
ffffffe000201afc:	0007c783          	lbu	a5,0(a5)
ffffffe000201b00:	00078713          	mv	a4,a5
ffffffe000201b04:	03900793          	li	a5,57
ffffffe000201b08:	00e7ee63          	bltu	a5,a4,ffffffe000201b24 <strtol+0x168>
            digit = *p - '0';
ffffffe000201b0c:	fd843783          	ld	a5,-40(s0)
ffffffe000201b10:	0007c783          	lbu	a5,0(a5)
ffffffe000201b14:	0007879b          	sext.w	a5,a5
ffffffe000201b18:	fd07879b          	addiw	a5,a5,-48
ffffffe000201b1c:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201b20:	0800006f          	j	ffffffe000201ba0 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe000201b24:	fd843783          	ld	a5,-40(s0)
ffffffe000201b28:	0007c783          	lbu	a5,0(a5)
ffffffe000201b2c:	00078713          	mv	a4,a5
ffffffe000201b30:	06000793          	li	a5,96
ffffffe000201b34:	02e7f863          	bgeu	a5,a4,ffffffe000201b64 <strtol+0x1a8>
ffffffe000201b38:	fd843783          	ld	a5,-40(s0)
ffffffe000201b3c:	0007c783          	lbu	a5,0(a5)
ffffffe000201b40:	00078713          	mv	a4,a5
ffffffe000201b44:	07a00793          	li	a5,122
ffffffe000201b48:	00e7ee63          	bltu	a5,a4,ffffffe000201b64 <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe000201b4c:	fd843783          	ld	a5,-40(s0)
ffffffe000201b50:	0007c783          	lbu	a5,0(a5)
ffffffe000201b54:	0007879b          	sext.w	a5,a5
ffffffe000201b58:	fa97879b          	addiw	a5,a5,-87
ffffffe000201b5c:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201b60:	0400006f          	j	ffffffe000201ba0 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe000201b64:	fd843783          	ld	a5,-40(s0)
ffffffe000201b68:	0007c783          	lbu	a5,0(a5)
ffffffe000201b6c:	00078713          	mv	a4,a5
ffffffe000201b70:	04000793          	li	a5,64
ffffffe000201b74:	06e7f863          	bgeu	a5,a4,ffffffe000201be4 <strtol+0x228>
ffffffe000201b78:	fd843783          	ld	a5,-40(s0)
ffffffe000201b7c:	0007c783          	lbu	a5,0(a5)
ffffffe000201b80:	00078713          	mv	a4,a5
ffffffe000201b84:	05a00793          	li	a5,90
ffffffe000201b88:	04e7ee63          	bltu	a5,a4,ffffffe000201be4 <strtol+0x228>
            digit = *p - ('A' - 10);
ffffffe000201b8c:	fd843783          	ld	a5,-40(s0)
ffffffe000201b90:	0007c783          	lbu	a5,0(a5)
ffffffe000201b94:	0007879b          	sext.w	a5,a5
ffffffe000201b98:	fc97879b          	addiw	a5,a5,-55
ffffffe000201b9c:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe000201ba0:	fd442783          	lw	a5,-44(s0)
ffffffe000201ba4:	00078713          	mv	a4,a5
ffffffe000201ba8:	fbc42783          	lw	a5,-68(s0)
ffffffe000201bac:	0007071b          	sext.w	a4,a4
ffffffe000201bb0:	0007879b          	sext.w	a5,a5
ffffffe000201bb4:	02f75663          	bge	a4,a5,ffffffe000201be0 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
ffffffe000201bb8:	fbc42703          	lw	a4,-68(s0)
ffffffe000201bbc:	fe843783          	ld	a5,-24(s0)
ffffffe000201bc0:	02f70733          	mul	a4,a4,a5
ffffffe000201bc4:	fd442783          	lw	a5,-44(s0)
ffffffe000201bc8:	00f707b3          	add	a5,a4,a5
ffffffe000201bcc:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe000201bd0:	fd843783          	ld	a5,-40(s0)
ffffffe000201bd4:	00178793          	addi	a5,a5,1
ffffffe000201bd8:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe000201bdc:	f09ff06f          	j	ffffffe000201ae4 <strtol+0x128>
            break;
ffffffe000201be0:	00000013          	nop
    }

    if (endptr) {
ffffffe000201be4:	fc043783          	ld	a5,-64(s0)
ffffffe000201be8:	00078863          	beqz	a5,ffffffe000201bf8 <strtol+0x23c>
        *endptr = (char *)p;
ffffffe000201bec:	fc043783          	ld	a5,-64(s0)
ffffffe000201bf0:	fd843703          	ld	a4,-40(s0)
ffffffe000201bf4:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe000201bf8:	fe744783          	lbu	a5,-25(s0)
ffffffe000201bfc:	0ff7f793          	zext.b	a5,a5
ffffffe000201c00:	00078863          	beqz	a5,ffffffe000201c10 <strtol+0x254>
ffffffe000201c04:	fe843783          	ld	a5,-24(s0)
ffffffe000201c08:	40f007b3          	neg	a5,a5
ffffffe000201c0c:	0080006f          	j	ffffffe000201c14 <strtol+0x258>
ffffffe000201c10:	fe843783          	ld	a5,-24(s0)
}
ffffffe000201c14:	00078513          	mv	a0,a5
ffffffe000201c18:	04813083          	ld	ra,72(sp)
ffffffe000201c1c:	04013403          	ld	s0,64(sp)
ffffffe000201c20:	05010113          	addi	sp,sp,80
ffffffe000201c24:	00008067          	ret

ffffffe000201c28 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe000201c28:	fd010113          	addi	sp,sp,-48
ffffffe000201c2c:	02113423          	sd	ra,40(sp)
ffffffe000201c30:	02813023          	sd	s0,32(sp)
ffffffe000201c34:	03010413          	addi	s0,sp,48
ffffffe000201c38:	fca43c23          	sd	a0,-40(s0)
ffffffe000201c3c:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe000201c40:	fd043783          	ld	a5,-48(s0)
ffffffe000201c44:	00079863          	bnez	a5,ffffffe000201c54 <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe000201c48:	00002797          	auipc	a5,0x2
ffffffe000201c4c:	c0878793          	addi	a5,a5,-1016 # ffffffe000203850 <_srodata+0x850>
ffffffe000201c50:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe000201c54:	fd043783          	ld	a5,-48(s0)
ffffffe000201c58:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe000201c5c:	0240006f          	j	ffffffe000201c80 <puts_wo_nl+0x58>
        putch(*p++);
ffffffe000201c60:	fe843783          	ld	a5,-24(s0)
ffffffe000201c64:	00178713          	addi	a4,a5,1
ffffffe000201c68:	fee43423          	sd	a4,-24(s0)
ffffffe000201c6c:	0007c783          	lbu	a5,0(a5)
ffffffe000201c70:	0007871b          	sext.w	a4,a5
ffffffe000201c74:	fd843783          	ld	a5,-40(s0)
ffffffe000201c78:	00070513          	mv	a0,a4
ffffffe000201c7c:	000780e7          	jalr	a5
    while (*p) {
ffffffe000201c80:	fe843783          	ld	a5,-24(s0)
ffffffe000201c84:	0007c783          	lbu	a5,0(a5)
ffffffe000201c88:	fc079ce3          	bnez	a5,ffffffe000201c60 <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe000201c8c:	fe843703          	ld	a4,-24(s0)
ffffffe000201c90:	fd043783          	ld	a5,-48(s0)
ffffffe000201c94:	40f707b3          	sub	a5,a4,a5
ffffffe000201c98:	0007879b          	sext.w	a5,a5
}
ffffffe000201c9c:	00078513          	mv	a0,a5
ffffffe000201ca0:	02813083          	ld	ra,40(sp)
ffffffe000201ca4:	02013403          	ld	s0,32(sp)
ffffffe000201ca8:	03010113          	addi	sp,sp,48
ffffffe000201cac:	00008067          	ret

ffffffe000201cb0 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe000201cb0:	f9010113          	addi	sp,sp,-112
ffffffe000201cb4:	06113423          	sd	ra,104(sp)
ffffffe000201cb8:	06813023          	sd	s0,96(sp)
ffffffe000201cbc:	07010413          	addi	s0,sp,112
ffffffe000201cc0:	faa43423          	sd	a0,-88(s0)
ffffffe000201cc4:	fab43023          	sd	a1,-96(s0)
ffffffe000201cc8:	00060793          	mv	a5,a2
ffffffe000201ccc:	f8d43823          	sd	a3,-112(s0)
ffffffe000201cd0:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe000201cd4:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201cd8:	0ff7f793          	zext.b	a5,a5
ffffffe000201cdc:	02078663          	beqz	a5,ffffffe000201d08 <print_dec_int+0x58>
ffffffe000201ce0:	fa043703          	ld	a4,-96(s0)
ffffffe000201ce4:	fff00793          	li	a5,-1
ffffffe000201ce8:	03f79793          	slli	a5,a5,0x3f
ffffffe000201cec:	00f71e63          	bne	a4,a5,ffffffe000201d08 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe000201cf0:	00002597          	auipc	a1,0x2
ffffffe000201cf4:	b6858593          	addi	a1,a1,-1176 # ffffffe000203858 <_srodata+0x858>
ffffffe000201cf8:	fa843503          	ld	a0,-88(s0)
ffffffe000201cfc:	f2dff0ef          	jal	ffffffe000201c28 <puts_wo_nl>
ffffffe000201d00:	00050793          	mv	a5,a0
ffffffe000201d04:	2a00006f          	j	ffffffe000201fa4 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe000201d08:	f9043783          	ld	a5,-112(s0)
ffffffe000201d0c:	00c7a783          	lw	a5,12(a5)
ffffffe000201d10:	00079a63          	bnez	a5,ffffffe000201d24 <print_dec_int+0x74>
ffffffe000201d14:	fa043783          	ld	a5,-96(s0)
ffffffe000201d18:	00079663          	bnez	a5,ffffffe000201d24 <print_dec_int+0x74>
        return 0;
ffffffe000201d1c:	00000793          	li	a5,0
ffffffe000201d20:	2840006f          	j	ffffffe000201fa4 <print_dec_int+0x2f4>
    }

    bool neg = false;
ffffffe000201d24:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe000201d28:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201d2c:	0ff7f793          	zext.b	a5,a5
ffffffe000201d30:	02078063          	beqz	a5,ffffffe000201d50 <print_dec_int+0xa0>
ffffffe000201d34:	fa043783          	ld	a5,-96(s0)
ffffffe000201d38:	0007dc63          	bgez	a5,ffffffe000201d50 <print_dec_int+0xa0>
        neg = true;
ffffffe000201d3c:	00100793          	li	a5,1
ffffffe000201d40:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe000201d44:	fa043783          	ld	a5,-96(s0)
ffffffe000201d48:	40f007b3          	neg	a5,a5
ffffffe000201d4c:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe000201d50:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe000201d54:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201d58:	0ff7f793          	zext.b	a5,a5
ffffffe000201d5c:	02078863          	beqz	a5,ffffffe000201d8c <print_dec_int+0xdc>
ffffffe000201d60:	fef44783          	lbu	a5,-17(s0)
ffffffe000201d64:	0ff7f793          	zext.b	a5,a5
ffffffe000201d68:	00079e63          	bnez	a5,ffffffe000201d84 <print_dec_int+0xd4>
ffffffe000201d6c:	f9043783          	ld	a5,-112(s0)
ffffffe000201d70:	0057c783          	lbu	a5,5(a5)
ffffffe000201d74:	00079863          	bnez	a5,ffffffe000201d84 <print_dec_int+0xd4>
ffffffe000201d78:	f9043783          	ld	a5,-112(s0)
ffffffe000201d7c:	0047c783          	lbu	a5,4(a5)
ffffffe000201d80:	00078663          	beqz	a5,ffffffe000201d8c <print_dec_int+0xdc>
ffffffe000201d84:	00100793          	li	a5,1
ffffffe000201d88:	0080006f          	j	ffffffe000201d90 <print_dec_int+0xe0>
ffffffe000201d8c:	00000793          	li	a5,0
ffffffe000201d90:	fcf40ba3          	sb	a5,-41(s0)
ffffffe000201d94:	fd744783          	lbu	a5,-41(s0)
ffffffe000201d98:	0017f793          	andi	a5,a5,1
ffffffe000201d9c:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe000201da0:	fa043703          	ld	a4,-96(s0)
ffffffe000201da4:	00a00793          	li	a5,10
ffffffe000201da8:	02f777b3          	remu	a5,a4,a5
ffffffe000201dac:	0ff7f713          	zext.b	a4,a5
ffffffe000201db0:	fe842783          	lw	a5,-24(s0)
ffffffe000201db4:	0017869b          	addiw	a3,a5,1
ffffffe000201db8:	fed42423          	sw	a3,-24(s0)
ffffffe000201dbc:	0307071b          	addiw	a4,a4,48
ffffffe000201dc0:	0ff77713          	zext.b	a4,a4
ffffffe000201dc4:	ff078793          	addi	a5,a5,-16
ffffffe000201dc8:	008787b3          	add	a5,a5,s0
ffffffe000201dcc:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe000201dd0:	fa043703          	ld	a4,-96(s0)
ffffffe000201dd4:	00a00793          	li	a5,10
ffffffe000201dd8:	02f757b3          	divu	a5,a4,a5
ffffffe000201ddc:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe000201de0:	fa043783          	ld	a5,-96(s0)
ffffffe000201de4:	fa079ee3          	bnez	a5,ffffffe000201da0 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe000201de8:	f9043783          	ld	a5,-112(s0)
ffffffe000201dec:	00c7a783          	lw	a5,12(a5)
ffffffe000201df0:	00078713          	mv	a4,a5
ffffffe000201df4:	fff00793          	li	a5,-1
ffffffe000201df8:	02f71063          	bne	a4,a5,ffffffe000201e18 <print_dec_int+0x168>
ffffffe000201dfc:	f9043783          	ld	a5,-112(s0)
ffffffe000201e00:	0037c783          	lbu	a5,3(a5)
ffffffe000201e04:	00078a63          	beqz	a5,ffffffe000201e18 <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe000201e08:	f9043783          	ld	a5,-112(s0)
ffffffe000201e0c:	0087a703          	lw	a4,8(a5)
ffffffe000201e10:	f9043783          	ld	a5,-112(s0)
ffffffe000201e14:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe000201e18:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000201e1c:	f9043783          	ld	a5,-112(s0)
ffffffe000201e20:	0087a703          	lw	a4,8(a5)
ffffffe000201e24:	fe842783          	lw	a5,-24(s0)
ffffffe000201e28:	fcf42823          	sw	a5,-48(s0)
ffffffe000201e2c:	f9043783          	ld	a5,-112(s0)
ffffffe000201e30:	00c7a783          	lw	a5,12(a5)
ffffffe000201e34:	fcf42623          	sw	a5,-52(s0)
ffffffe000201e38:	fd042783          	lw	a5,-48(s0)
ffffffe000201e3c:	00078593          	mv	a1,a5
ffffffe000201e40:	fcc42783          	lw	a5,-52(s0)
ffffffe000201e44:	00078613          	mv	a2,a5
ffffffe000201e48:	0006069b          	sext.w	a3,a2
ffffffe000201e4c:	0005879b          	sext.w	a5,a1
ffffffe000201e50:	00f6d463          	bge	a3,a5,ffffffe000201e58 <print_dec_int+0x1a8>
ffffffe000201e54:	00058613          	mv	a2,a1
ffffffe000201e58:	0006079b          	sext.w	a5,a2
ffffffe000201e5c:	40f707bb          	subw	a5,a4,a5
ffffffe000201e60:	0007871b          	sext.w	a4,a5
ffffffe000201e64:	fd744783          	lbu	a5,-41(s0)
ffffffe000201e68:	0007879b          	sext.w	a5,a5
ffffffe000201e6c:	40f707bb          	subw	a5,a4,a5
ffffffe000201e70:	fef42023          	sw	a5,-32(s0)
ffffffe000201e74:	0280006f          	j	ffffffe000201e9c <print_dec_int+0x1ec>
        putch(' ');
ffffffe000201e78:	fa843783          	ld	a5,-88(s0)
ffffffe000201e7c:	02000513          	li	a0,32
ffffffe000201e80:	000780e7          	jalr	a5
        ++written;
ffffffe000201e84:	fe442783          	lw	a5,-28(s0)
ffffffe000201e88:	0017879b          	addiw	a5,a5,1
ffffffe000201e8c:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000201e90:	fe042783          	lw	a5,-32(s0)
ffffffe000201e94:	fff7879b          	addiw	a5,a5,-1
ffffffe000201e98:	fef42023          	sw	a5,-32(s0)
ffffffe000201e9c:	fe042783          	lw	a5,-32(s0)
ffffffe000201ea0:	0007879b          	sext.w	a5,a5
ffffffe000201ea4:	fcf04ae3          	bgtz	a5,ffffffe000201e78 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
ffffffe000201ea8:	fd744783          	lbu	a5,-41(s0)
ffffffe000201eac:	0ff7f793          	zext.b	a5,a5
ffffffe000201eb0:	04078463          	beqz	a5,ffffffe000201ef8 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe000201eb4:	fef44783          	lbu	a5,-17(s0)
ffffffe000201eb8:	0ff7f793          	zext.b	a5,a5
ffffffe000201ebc:	00078663          	beqz	a5,ffffffe000201ec8 <print_dec_int+0x218>
ffffffe000201ec0:	02d00793          	li	a5,45
ffffffe000201ec4:	01c0006f          	j	ffffffe000201ee0 <print_dec_int+0x230>
ffffffe000201ec8:	f9043783          	ld	a5,-112(s0)
ffffffe000201ecc:	0057c783          	lbu	a5,5(a5)
ffffffe000201ed0:	00078663          	beqz	a5,ffffffe000201edc <print_dec_int+0x22c>
ffffffe000201ed4:	02b00793          	li	a5,43
ffffffe000201ed8:	0080006f          	j	ffffffe000201ee0 <print_dec_int+0x230>
ffffffe000201edc:	02000793          	li	a5,32
ffffffe000201ee0:	fa843703          	ld	a4,-88(s0)
ffffffe000201ee4:	00078513          	mv	a0,a5
ffffffe000201ee8:	000700e7          	jalr	a4
        ++written;
ffffffe000201eec:	fe442783          	lw	a5,-28(s0)
ffffffe000201ef0:	0017879b          	addiw	a5,a5,1
ffffffe000201ef4:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000201ef8:	fe842783          	lw	a5,-24(s0)
ffffffe000201efc:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201f00:	0280006f          	j	ffffffe000201f28 <print_dec_int+0x278>
        putch('0');
ffffffe000201f04:	fa843783          	ld	a5,-88(s0)
ffffffe000201f08:	03000513          	li	a0,48
ffffffe000201f0c:	000780e7          	jalr	a5
        ++written;
ffffffe000201f10:	fe442783          	lw	a5,-28(s0)
ffffffe000201f14:	0017879b          	addiw	a5,a5,1
ffffffe000201f18:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000201f1c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201f20:	0017879b          	addiw	a5,a5,1
ffffffe000201f24:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201f28:	f9043783          	ld	a5,-112(s0)
ffffffe000201f2c:	00c7a703          	lw	a4,12(a5)
ffffffe000201f30:	fd744783          	lbu	a5,-41(s0)
ffffffe000201f34:	0007879b          	sext.w	a5,a5
ffffffe000201f38:	40f707bb          	subw	a5,a4,a5
ffffffe000201f3c:	0007871b          	sext.w	a4,a5
ffffffe000201f40:	fdc42783          	lw	a5,-36(s0)
ffffffe000201f44:	0007879b          	sext.w	a5,a5
ffffffe000201f48:	fae7cee3          	blt	a5,a4,ffffffe000201f04 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000201f4c:	fe842783          	lw	a5,-24(s0)
ffffffe000201f50:	fff7879b          	addiw	a5,a5,-1
ffffffe000201f54:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201f58:	03c0006f          	j	ffffffe000201f94 <print_dec_int+0x2e4>
        putch(buf[i]);
ffffffe000201f5c:	fd842783          	lw	a5,-40(s0)
ffffffe000201f60:	ff078793          	addi	a5,a5,-16
ffffffe000201f64:	008787b3          	add	a5,a5,s0
ffffffe000201f68:	fc87c783          	lbu	a5,-56(a5)
ffffffe000201f6c:	0007871b          	sext.w	a4,a5
ffffffe000201f70:	fa843783          	ld	a5,-88(s0)
ffffffe000201f74:	00070513          	mv	a0,a4
ffffffe000201f78:	000780e7          	jalr	a5
        ++written;
ffffffe000201f7c:	fe442783          	lw	a5,-28(s0)
ffffffe000201f80:	0017879b          	addiw	a5,a5,1
ffffffe000201f84:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000201f88:	fd842783          	lw	a5,-40(s0)
ffffffe000201f8c:	fff7879b          	addiw	a5,a5,-1
ffffffe000201f90:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201f94:	fd842783          	lw	a5,-40(s0)
ffffffe000201f98:	0007879b          	sext.w	a5,a5
ffffffe000201f9c:	fc07d0e3          	bgez	a5,ffffffe000201f5c <print_dec_int+0x2ac>
    }

    return written;
ffffffe000201fa0:	fe442783          	lw	a5,-28(s0)
}
ffffffe000201fa4:	00078513          	mv	a0,a5
ffffffe000201fa8:	06813083          	ld	ra,104(sp)
ffffffe000201fac:	06013403          	ld	s0,96(sp)
ffffffe000201fb0:	07010113          	addi	sp,sp,112
ffffffe000201fb4:	00008067          	ret

ffffffe000201fb8 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe000201fb8:	f4010113          	addi	sp,sp,-192
ffffffe000201fbc:	0a113c23          	sd	ra,184(sp)
ffffffe000201fc0:	0a813823          	sd	s0,176(sp)
ffffffe000201fc4:	0c010413          	addi	s0,sp,192
ffffffe000201fc8:	f4a43c23          	sd	a0,-168(s0)
ffffffe000201fcc:	f4b43823          	sd	a1,-176(s0)
ffffffe000201fd0:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe000201fd4:	f8043023          	sd	zero,-128(s0)
ffffffe000201fd8:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe000201fdc:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe000201fe0:	7a40006f          	j	ffffffe000202784 <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe000201fe4:	f8044783          	lbu	a5,-128(s0)
ffffffe000201fe8:	72078e63          	beqz	a5,ffffffe000202724 <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe000201fec:	f5043783          	ld	a5,-176(s0)
ffffffe000201ff0:	0007c783          	lbu	a5,0(a5)
ffffffe000201ff4:	00078713          	mv	a4,a5
ffffffe000201ff8:	02300793          	li	a5,35
ffffffe000201ffc:	00f71863          	bne	a4,a5,ffffffe00020200c <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe000202000:	00100793          	li	a5,1
ffffffe000202004:	f8f40123          	sb	a5,-126(s0)
ffffffe000202008:	7700006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe00020200c:	f5043783          	ld	a5,-176(s0)
ffffffe000202010:	0007c783          	lbu	a5,0(a5)
ffffffe000202014:	00078713          	mv	a4,a5
ffffffe000202018:	03000793          	li	a5,48
ffffffe00020201c:	00f71863          	bne	a4,a5,ffffffe00020202c <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe000202020:	00100793          	li	a5,1
ffffffe000202024:	f8f401a3          	sb	a5,-125(s0)
ffffffe000202028:	7500006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe00020202c:	f5043783          	ld	a5,-176(s0)
ffffffe000202030:	0007c783          	lbu	a5,0(a5)
ffffffe000202034:	00078713          	mv	a4,a5
ffffffe000202038:	06c00793          	li	a5,108
ffffffe00020203c:	04f70063          	beq	a4,a5,ffffffe00020207c <vprintfmt+0xc4>
ffffffe000202040:	f5043783          	ld	a5,-176(s0)
ffffffe000202044:	0007c783          	lbu	a5,0(a5)
ffffffe000202048:	00078713          	mv	a4,a5
ffffffe00020204c:	07a00793          	li	a5,122
ffffffe000202050:	02f70663          	beq	a4,a5,ffffffe00020207c <vprintfmt+0xc4>
ffffffe000202054:	f5043783          	ld	a5,-176(s0)
ffffffe000202058:	0007c783          	lbu	a5,0(a5)
ffffffe00020205c:	00078713          	mv	a4,a5
ffffffe000202060:	07400793          	li	a5,116
ffffffe000202064:	00f70c63          	beq	a4,a5,ffffffe00020207c <vprintfmt+0xc4>
ffffffe000202068:	f5043783          	ld	a5,-176(s0)
ffffffe00020206c:	0007c783          	lbu	a5,0(a5)
ffffffe000202070:	00078713          	mv	a4,a5
ffffffe000202074:	06a00793          	li	a5,106
ffffffe000202078:	00f71863          	bne	a4,a5,ffffffe000202088 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe00020207c:	00100793          	li	a5,1
ffffffe000202080:	f8f400a3          	sb	a5,-127(s0)
ffffffe000202084:	6f40006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe000202088:	f5043783          	ld	a5,-176(s0)
ffffffe00020208c:	0007c783          	lbu	a5,0(a5)
ffffffe000202090:	00078713          	mv	a4,a5
ffffffe000202094:	02b00793          	li	a5,43
ffffffe000202098:	00f71863          	bne	a4,a5,ffffffe0002020a8 <vprintfmt+0xf0>
                flags.sign = true;
ffffffe00020209c:	00100793          	li	a5,1
ffffffe0002020a0:	f8f402a3          	sb	a5,-123(s0)
ffffffe0002020a4:	6d40006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe0002020a8:	f5043783          	ld	a5,-176(s0)
ffffffe0002020ac:	0007c783          	lbu	a5,0(a5)
ffffffe0002020b0:	00078713          	mv	a4,a5
ffffffe0002020b4:	02000793          	li	a5,32
ffffffe0002020b8:	00f71863          	bne	a4,a5,ffffffe0002020c8 <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe0002020bc:	00100793          	li	a5,1
ffffffe0002020c0:	f8f40223          	sb	a5,-124(s0)
ffffffe0002020c4:	6b40006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe0002020c8:	f5043783          	ld	a5,-176(s0)
ffffffe0002020cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002020d0:	00078713          	mv	a4,a5
ffffffe0002020d4:	02a00793          	li	a5,42
ffffffe0002020d8:	00f71e63          	bne	a4,a5,ffffffe0002020f4 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe0002020dc:	f4843783          	ld	a5,-184(s0)
ffffffe0002020e0:	00878713          	addi	a4,a5,8
ffffffe0002020e4:	f4e43423          	sd	a4,-184(s0)
ffffffe0002020e8:	0007a783          	lw	a5,0(a5)
ffffffe0002020ec:	f8f42423          	sw	a5,-120(s0)
ffffffe0002020f0:	6880006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe0002020f4:	f5043783          	ld	a5,-176(s0)
ffffffe0002020f8:	0007c783          	lbu	a5,0(a5)
ffffffe0002020fc:	00078713          	mv	a4,a5
ffffffe000202100:	03000793          	li	a5,48
ffffffe000202104:	04e7f663          	bgeu	a5,a4,ffffffe000202150 <vprintfmt+0x198>
ffffffe000202108:	f5043783          	ld	a5,-176(s0)
ffffffe00020210c:	0007c783          	lbu	a5,0(a5)
ffffffe000202110:	00078713          	mv	a4,a5
ffffffe000202114:	03900793          	li	a5,57
ffffffe000202118:	02e7ec63          	bltu	a5,a4,ffffffe000202150 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe00020211c:	f5043783          	ld	a5,-176(s0)
ffffffe000202120:	f5040713          	addi	a4,s0,-176
ffffffe000202124:	00a00613          	li	a2,10
ffffffe000202128:	00070593          	mv	a1,a4
ffffffe00020212c:	00078513          	mv	a0,a5
ffffffe000202130:	88dff0ef          	jal	ffffffe0002019bc <strtol>
ffffffe000202134:	00050793          	mv	a5,a0
ffffffe000202138:	0007879b          	sext.w	a5,a5
ffffffe00020213c:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe000202140:	f5043783          	ld	a5,-176(s0)
ffffffe000202144:	fff78793          	addi	a5,a5,-1
ffffffe000202148:	f4f43823          	sd	a5,-176(s0)
ffffffe00020214c:	62c0006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe000202150:	f5043783          	ld	a5,-176(s0)
ffffffe000202154:	0007c783          	lbu	a5,0(a5)
ffffffe000202158:	00078713          	mv	a4,a5
ffffffe00020215c:	02e00793          	li	a5,46
ffffffe000202160:	06f71863          	bne	a4,a5,ffffffe0002021d0 <vprintfmt+0x218>
                fmt++;
ffffffe000202164:	f5043783          	ld	a5,-176(s0)
ffffffe000202168:	00178793          	addi	a5,a5,1
ffffffe00020216c:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe000202170:	f5043783          	ld	a5,-176(s0)
ffffffe000202174:	0007c783          	lbu	a5,0(a5)
ffffffe000202178:	00078713          	mv	a4,a5
ffffffe00020217c:	02a00793          	li	a5,42
ffffffe000202180:	00f71e63          	bne	a4,a5,ffffffe00020219c <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe000202184:	f4843783          	ld	a5,-184(s0)
ffffffe000202188:	00878713          	addi	a4,a5,8
ffffffe00020218c:	f4e43423          	sd	a4,-184(s0)
ffffffe000202190:	0007a783          	lw	a5,0(a5)
ffffffe000202194:	f8f42623          	sw	a5,-116(s0)
ffffffe000202198:	5e00006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe00020219c:	f5043783          	ld	a5,-176(s0)
ffffffe0002021a0:	f5040713          	addi	a4,s0,-176
ffffffe0002021a4:	00a00613          	li	a2,10
ffffffe0002021a8:	00070593          	mv	a1,a4
ffffffe0002021ac:	00078513          	mv	a0,a5
ffffffe0002021b0:	80dff0ef          	jal	ffffffe0002019bc <strtol>
ffffffe0002021b4:	00050793          	mv	a5,a0
ffffffe0002021b8:	0007879b          	sext.w	a5,a5
ffffffe0002021bc:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe0002021c0:	f5043783          	ld	a5,-176(s0)
ffffffe0002021c4:	fff78793          	addi	a5,a5,-1
ffffffe0002021c8:	f4f43823          	sd	a5,-176(s0)
ffffffe0002021cc:	5ac0006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe0002021d0:	f5043783          	ld	a5,-176(s0)
ffffffe0002021d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002021d8:	00078713          	mv	a4,a5
ffffffe0002021dc:	07800793          	li	a5,120
ffffffe0002021e0:	02f70663          	beq	a4,a5,ffffffe00020220c <vprintfmt+0x254>
ffffffe0002021e4:	f5043783          	ld	a5,-176(s0)
ffffffe0002021e8:	0007c783          	lbu	a5,0(a5)
ffffffe0002021ec:	00078713          	mv	a4,a5
ffffffe0002021f0:	05800793          	li	a5,88
ffffffe0002021f4:	00f70c63          	beq	a4,a5,ffffffe00020220c <vprintfmt+0x254>
ffffffe0002021f8:	f5043783          	ld	a5,-176(s0)
ffffffe0002021fc:	0007c783          	lbu	a5,0(a5)
ffffffe000202200:	00078713          	mv	a4,a5
ffffffe000202204:	07000793          	li	a5,112
ffffffe000202208:	30f71263          	bne	a4,a5,ffffffe00020250c <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe00020220c:	f5043783          	ld	a5,-176(s0)
ffffffe000202210:	0007c783          	lbu	a5,0(a5)
ffffffe000202214:	00078713          	mv	a4,a5
ffffffe000202218:	07000793          	li	a5,112
ffffffe00020221c:	00f70663          	beq	a4,a5,ffffffe000202228 <vprintfmt+0x270>
ffffffe000202220:	f8144783          	lbu	a5,-127(s0)
ffffffe000202224:	00078663          	beqz	a5,ffffffe000202230 <vprintfmt+0x278>
ffffffe000202228:	00100793          	li	a5,1
ffffffe00020222c:	0080006f          	j	ffffffe000202234 <vprintfmt+0x27c>
ffffffe000202230:	00000793          	li	a5,0
ffffffe000202234:	faf403a3          	sb	a5,-89(s0)
ffffffe000202238:	fa744783          	lbu	a5,-89(s0)
ffffffe00020223c:	0017f793          	andi	a5,a5,1
ffffffe000202240:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe000202244:	fa744783          	lbu	a5,-89(s0)
ffffffe000202248:	0ff7f793          	zext.b	a5,a5
ffffffe00020224c:	00078c63          	beqz	a5,ffffffe000202264 <vprintfmt+0x2ac>
ffffffe000202250:	f4843783          	ld	a5,-184(s0)
ffffffe000202254:	00878713          	addi	a4,a5,8
ffffffe000202258:	f4e43423          	sd	a4,-184(s0)
ffffffe00020225c:	0007b783          	ld	a5,0(a5)
ffffffe000202260:	01c0006f          	j	ffffffe00020227c <vprintfmt+0x2c4>
ffffffe000202264:	f4843783          	ld	a5,-184(s0)
ffffffe000202268:	00878713          	addi	a4,a5,8
ffffffe00020226c:	f4e43423          	sd	a4,-184(s0)
ffffffe000202270:	0007a783          	lw	a5,0(a5)
ffffffe000202274:	02079793          	slli	a5,a5,0x20
ffffffe000202278:	0207d793          	srli	a5,a5,0x20
ffffffe00020227c:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe000202280:	f8c42783          	lw	a5,-116(s0)
ffffffe000202284:	02079463          	bnez	a5,ffffffe0002022ac <vprintfmt+0x2f4>
ffffffe000202288:	fe043783          	ld	a5,-32(s0)
ffffffe00020228c:	02079063          	bnez	a5,ffffffe0002022ac <vprintfmt+0x2f4>
ffffffe000202290:	f5043783          	ld	a5,-176(s0)
ffffffe000202294:	0007c783          	lbu	a5,0(a5)
ffffffe000202298:	00078713          	mv	a4,a5
ffffffe00020229c:	07000793          	li	a5,112
ffffffe0002022a0:	00f70663          	beq	a4,a5,ffffffe0002022ac <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe0002022a4:	f8040023          	sb	zero,-128(s0)
ffffffe0002022a8:	4d00006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe0002022ac:	f5043783          	ld	a5,-176(s0)
ffffffe0002022b0:	0007c783          	lbu	a5,0(a5)
ffffffe0002022b4:	00078713          	mv	a4,a5
ffffffe0002022b8:	07000793          	li	a5,112
ffffffe0002022bc:	00f70a63          	beq	a4,a5,ffffffe0002022d0 <vprintfmt+0x318>
ffffffe0002022c0:	f8244783          	lbu	a5,-126(s0)
ffffffe0002022c4:	00078a63          	beqz	a5,ffffffe0002022d8 <vprintfmt+0x320>
ffffffe0002022c8:	fe043783          	ld	a5,-32(s0)
ffffffe0002022cc:	00078663          	beqz	a5,ffffffe0002022d8 <vprintfmt+0x320>
ffffffe0002022d0:	00100793          	li	a5,1
ffffffe0002022d4:	0080006f          	j	ffffffe0002022dc <vprintfmt+0x324>
ffffffe0002022d8:	00000793          	li	a5,0
ffffffe0002022dc:	faf40323          	sb	a5,-90(s0)
ffffffe0002022e0:	fa644783          	lbu	a5,-90(s0)
ffffffe0002022e4:	0017f793          	andi	a5,a5,1
ffffffe0002022e8:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe0002022ec:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe0002022f0:	f5043783          	ld	a5,-176(s0)
ffffffe0002022f4:	0007c783          	lbu	a5,0(a5)
ffffffe0002022f8:	00078713          	mv	a4,a5
ffffffe0002022fc:	05800793          	li	a5,88
ffffffe000202300:	00f71863          	bne	a4,a5,ffffffe000202310 <vprintfmt+0x358>
ffffffe000202304:	00001797          	auipc	a5,0x1
ffffffe000202308:	56c78793          	addi	a5,a5,1388 # ffffffe000203870 <upperxdigits.1>
ffffffe00020230c:	00c0006f          	j	ffffffe000202318 <vprintfmt+0x360>
ffffffe000202310:	00001797          	auipc	a5,0x1
ffffffe000202314:	57878793          	addi	a5,a5,1400 # ffffffe000203888 <lowerxdigits.0>
ffffffe000202318:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe00020231c:	fe043783          	ld	a5,-32(s0)
ffffffe000202320:	00f7f793          	andi	a5,a5,15
ffffffe000202324:	f9843703          	ld	a4,-104(s0)
ffffffe000202328:	00f70733          	add	a4,a4,a5
ffffffe00020232c:	fdc42783          	lw	a5,-36(s0)
ffffffe000202330:	0017869b          	addiw	a3,a5,1
ffffffe000202334:	fcd42e23          	sw	a3,-36(s0)
ffffffe000202338:	00074703          	lbu	a4,0(a4)
ffffffe00020233c:	ff078793          	addi	a5,a5,-16
ffffffe000202340:	008787b3          	add	a5,a5,s0
ffffffe000202344:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe000202348:	fe043783          	ld	a5,-32(s0)
ffffffe00020234c:	0047d793          	srli	a5,a5,0x4
ffffffe000202350:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe000202354:	fe043783          	ld	a5,-32(s0)
ffffffe000202358:	fc0792e3          	bnez	a5,ffffffe00020231c <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe00020235c:	f8c42783          	lw	a5,-116(s0)
ffffffe000202360:	00078713          	mv	a4,a5
ffffffe000202364:	fff00793          	li	a5,-1
ffffffe000202368:	02f71663          	bne	a4,a5,ffffffe000202394 <vprintfmt+0x3dc>
ffffffe00020236c:	f8344783          	lbu	a5,-125(s0)
ffffffe000202370:	02078263          	beqz	a5,ffffffe000202394 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe000202374:	f8842703          	lw	a4,-120(s0)
ffffffe000202378:	fa644783          	lbu	a5,-90(s0)
ffffffe00020237c:	0007879b          	sext.w	a5,a5
ffffffe000202380:	0017979b          	slliw	a5,a5,0x1
ffffffe000202384:	0007879b          	sext.w	a5,a5
ffffffe000202388:	40f707bb          	subw	a5,a4,a5
ffffffe00020238c:	0007879b          	sext.w	a5,a5
ffffffe000202390:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000202394:	f8842703          	lw	a4,-120(s0)
ffffffe000202398:	fa644783          	lbu	a5,-90(s0)
ffffffe00020239c:	0007879b          	sext.w	a5,a5
ffffffe0002023a0:	0017979b          	slliw	a5,a5,0x1
ffffffe0002023a4:	0007879b          	sext.w	a5,a5
ffffffe0002023a8:	40f707bb          	subw	a5,a4,a5
ffffffe0002023ac:	0007871b          	sext.w	a4,a5
ffffffe0002023b0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002023b4:	f8f42a23          	sw	a5,-108(s0)
ffffffe0002023b8:	f8c42783          	lw	a5,-116(s0)
ffffffe0002023bc:	f8f42823          	sw	a5,-112(s0)
ffffffe0002023c0:	f9442783          	lw	a5,-108(s0)
ffffffe0002023c4:	00078593          	mv	a1,a5
ffffffe0002023c8:	f9042783          	lw	a5,-112(s0)
ffffffe0002023cc:	00078613          	mv	a2,a5
ffffffe0002023d0:	0006069b          	sext.w	a3,a2
ffffffe0002023d4:	0005879b          	sext.w	a5,a1
ffffffe0002023d8:	00f6d463          	bge	a3,a5,ffffffe0002023e0 <vprintfmt+0x428>
ffffffe0002023dc:	00058613          	mv	a2,a1
ffffffe0002023e0:	0006079b          	sext.w	a5,a2
ffffffe0002023e4:	40f707bb          	subw	a5,a4,a5
ffffffe0002023e8:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002023ec:	0280006f          	j	ffffffe000202414 <vprintfmt+0x45c>
                    putch(' ');
ffffffe0002023f0:	f5843783          	ld	a5,-168(s0)
ffffffe0002023f4:	02000513          	li	a0,32
ffffffe0002023f8:	000780e7          	jalr	a5
                    ++written;
ffffffe0002023fc:	fec42783          	lw	a5,-20(s0)
ffffffe000202400:	0017879b          	addiw	a5,a5,1
ffffffe000202404:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000202408:	fd842783          	lw	a5,-40(s0)
ffffffe00020240c:	fff7879b          	addiw	a5,a5,-1
ffffffe000202410:	fcf42c23          	sw	a5,-40(s0)
ffffffe000202414:	fd842783          	lw	a5,-40(s0)
ffffffe000202418:	0007879b          	sext.w	a5,a5
ffffffe00020241c:	fcf04ae3          	bgtz	a5,ffffffe0002023f0 <vprintfmt+0x438>
                }

                if (prefix) {
ffffffe000202420:	fa644783          	lbu	a5,-90(s0)
ffffffe000202424:	0ff7f793          	zext.b	a5,a5
ffffffe000202428:	04078463          	beqz	a5,ffffffe000202470 <vprintfmt+0x4b8>
                    putch('0');
ffffffe00020242c:	f5843783          	ld	a5,-168(s0)
ffffffe000202430:	03000513          	li	a0,48
ffffffe000202434:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000202438:	f5043783          	ld	a5,-176(s0)
ffffffe00020243c:	0007c783          	lbu	a5,0(a5)
ffffffe000202440:	00078713          	mv	a4,a5
ffffffe000202444:	05800793          	li	a5,88
ffffffe000202448:	00f71663          	bne	a4,a5,ffffffe000202454 <vprintfmt+0x49c>
ffffffe00020244c:	05800793          	li	a5,88
ffffffe000202450:	0080006f          	j	ffffffe000202458 <vprintfmt+0x4a0>
ffffffe000202454:	07800793          	li	a5,120
ffffffe000202458:	f5843703          	ld	a4,-168(s0)
ffffffe00020245c:	00078513          	mv	a0,a5
ffffffe000202460:	000700e7          	jalr	a4
                    written += 2;
ffffffe000202464:	fec42783          	lw	a5,-20(s0)
ffffffe000202468:	0027879b          	addiw	a5,a5,2
ffffffe00020246c:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000202470:	fdc42783          	lw	a5,-36(s0)
ffffffe000202474:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202478:	0280006f          	j	ffffffe0002024a0 <vprintfmt+0x4e8>
                    putch('0');
ffffffe00020247c:	f5843783          	ld	a5,-168(s0)
ffffffe000202480:	03000513          	li	a0,48
ffffffe000202484:	000780e7          	jalr	a5
                    ++written;
ffffffe000202488:	fec42783          	lw	a5,-20(s0)
ffffffe00020248c:	0017879b          	addiw	a5,a5,1
ffffffe000202490:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000202494:	fd442783          	lw	a5,-44(s0)
ffffffe000202498:	0017879b          	addiw	a5,a5,1
ffffffe00020249c:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002024a0:	f8c42703          	lw	a4,-116(s0)
ffffffe0002024a4:	fd442783          	lw	a5,-44(s0)
ffffffe0002024a8:	0007879b          	sext.w	a5,a5
ffffffe0002024ac:	fce7c8e3          	blt	a5,a4,ffffffe00020247c <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe0002024b0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002024b4:	fff7879b          	addiw	a5,a5,-1
ffffffe0002024b8:	fcf42823          	sw	a5,-48(s0)
ffffffe0002024bc:	03c0006f          	j	ffffffe0002024f8 <vprintfmt+0x540>
                    putch(buf[i]);
ffffffe0002024c0:	fd042783          	lw	a5,-48(s0)
ffffffe0002024c4:	ff078793          	addi	a5,a5,-16
ffffffe0002024c8:	008787b3          	add	a5,a5,s0
ffffffe0002024cc:	f807c783          	lbu	a5,-128(a5)
ffffffe0002024d0:	0007871b          	sext.w	a4,a5
ffffffe0002024d4:	f5843783          	ld	a5,-168(s0)
ffffffe0002024d8:	00070513          	mv	a0,a4
ffffffe0002024dc:	000780e7          	jalr	a5
                    ++written;
ffffffe0002024e0:	fec42783          	lw	a5,-20(s0)
ffffffe0002024e4:	0017879b          	addiw	a5,a5,1
ffffffe0002024e8:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe0002024ec:	fd042783          	lw	a5,-48(s0)
ffffffe0002024f0:	fff7879b          	addiw	a5,a5,-1
ffffffe0002024f4:	fcf42823          	sw	a5,-48(s0)
ffffffe0002024f8:	fd042783          	lw	a5,-48(s0)
ffffffe0002024fc:	0007879b          	sext.w	a5,a5
ffffffe000202500:	fc07d0e3          	bgez	a5,ffffffe0002024c0 <vprintfmt+0x508>
                }

                flags.in_format = false;
ffffffe000202504:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000202508:	2700006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe00020250c:	f5043783          	ld	a5,-176(s0)
ffffffe000202510:	0007c783          	lbu	a5,0(a5)
ffffffe000202514:	00078713          	mv	a4,a5
ffffffe000202518:	06400793          	li	a5,100
ffffffe00020251c:	02f70663          	beq	a4,a5,ffffffe000202548 <vprintfmt+0x590>
ffffffe000202520:	f5043783          	ld	a5,-176(s0)
ffffffe000202524:	0007c783          	lbu	a5,0(a5)
ffffffe000202528:	00078713          	mv	a4,a5
ffffffe00020252c:	06900793          	li	a5,105
ffffffe000202530:	00f70c63          	beq	a4,a5,ffffffe000202548 <vprintfmt+0x590>
ffffffe000202534:	f5043783          	ld	a5,-176(s0)
ffffffe000202538:	0007c783          	lbu	a5,0(a5)
ffffffe00020253c:	00078713          	mv	a4,a5
ffffffe000202540:	07500793          	li	a5,117
ffffffe000202544:	08f71063          	bne	a4,a5,ffffffe0002025c4 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000202548:	f8144783          	lbu	a5,-127(s0)
ffffffe00020254c:	00078c63          	beqz	a5,ffffffe000202564 <vprintfmt+0x5ac>
ffffffe000202550:	f4843783          	ld	a5,-184(s0)
ffffffe000202554:	00878713          	addi	a4,a5,8
ffffffe000202558:	f4e43423          	sd	a4,-184(s0)
ffffffe00020255c:	0007b783          	ld	a5,0(a5)
ffffffe000202560:	0140006f          	j	ffffffe000202574 <vprintfmt+0x5bc>
ffffffe000202564:	f4843783          	ld	a5,-184(s0)
ffffffe000202568:	00878713          	addi	a4,a5,8
ffffffe00020256c:	f4e43423          	sd	a4,-184(s0)
ffffffe000202570:	0007a783          	lw	a5,0(a5)
ffffffe000202574:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe000202578:	fa843583          	ld	a1,-88(s0)
ffffffe00020257c:	f5043783          	ld	a5,-176(s0)
ffffffe000202580:	0007c783          	lbu	a5,0(a5)
ffffffe000202584:	0007871b          	sext.w	a4,a5
ffffffe000202588:	07500793          	li	a5,117
ffffffe00020258c:	40f707b3          	sub	a5,a4,a5
ffffffe000202590:	00f037b3          	snez	a5,a5
ffffffe000202594:	0ff7f793          	zext.b	a5,a5
ffffffe000202598:	f8040713          	addi	a4,s0,-128
ffffffe00020259c:	00070693          	mv	a3,a4
ffffffe0002025a0:	00078613          	mv	a2,a5
ffffffe0002025a4:	f5843503          	ld	a0,-168(s0)
ffffffe0002025a8:	f08ff0ef          	jal	ffffffe000201cb0 <print_dec_int>
ffffffe0002025ac:	00050793          	mv	a5,a0
ffffffe0002025b0:	fec42703          	lw	a4,-20(s0)
ffffffe0002025b4:	00f707bb          	addw	a5,a4,a5
ffffffe0002025b8:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002025bc:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe0002025c0:	1b80006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe0002025c4:	f5043783          	ld	a5,-176(s0)
ffffffe0002025c8:	0007c783          	lbu	a5,0(a5)
ffffffe0002025cc:	00078713          	mv	a4,a5
ffffffe0002025d0:	06e00793          	li	a5,110
ffffffe0002025d4:	04f71c63          	bne	a4,a5,ffffffe00020262c <vprintfmt+0x674>
                if (flags.longflag) {
ffffffe0002025d8:	f8144783          	lbu	a5,-127(s0)
ffffffe0002025dc:	02078463          	beqz	a5,ffffffe000202604 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
ffffffe0002025e0:	f4843783          	ld	a5,-184(s0)
ffffffe0002025e4:	00878713          	addi	a4,a5,8
ffffffe0002025e8:	f4e43423          	sd	a4,-184(s0)
ffffffe0002025ec:	0007b783          	ld	a5,0(a5)
ffffffe0002025f0:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe0002025f4:	fec42703          	lw	a4,-20(s0)
ffffffe0002025f8:	fb043783          	ld	a5,-80(s0)
ffffffe0002025fc:	00e7b023          	sd	a4,0(a5)
ffffffe000202600:	0240006f          	j	ffffffe000202624 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe000202604:	f4843783          	ld	a5,-184(s0)
ffffffe000202608:	00878713          	addi	a4,a5,8
ffffffe00020260c:	f4e43423          	sd	a4,-184(s0)
ffffffe000202610:	0007b783          	ld	a5,0(a5)
ffffffe000202614:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe000202618:	fb843783          	ld	a5,-72(s0)
ffffffe00020261c:	fec42703          	lw	a4,-20(s0)
ffffffe000202620:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe000202624:	f8040023          	sb	zero,-128(s0)
ffffffe000202628:	1500006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe00020262c:	f5043783          	ld	a5,-176(s0)
ffffffe000202630:	0007c783          	lbu	a5,0(a5)
ffffffe000202634:	00078713          	mv	a4,a5
ffffffe000202638:	07300793          	li	a5,115
ffffffe00020263c:	02f71e63          	bne	a4,a5,ffffffe000202678 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe000202640:	f4843783          	ld	a5,-184(s0)
ffffffe000202644:	00878713          	addi	a4,a5,8
ffffffe000202648:	f4e43423          	sd	a4,-184(s0)
ffffffe00020264c:	0007b783          	ld	a5,0(a5)
ffffffe000202650:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe000202654:	fc043583          	ld	a1,-64(s0)
ffffffe000202658:	f5843503          	ld	a0,-168(s0)
ffffffe00020265c:	dccff0ef          	jal	ffffffe000201c28 <puts_wo_nl>
ffffffe000202660:	00050793          	mv	a5,a0
ffffffe000202664:	fec42703          	lw	a4,-20(s0)
ffffffe000202668:	00f707bb          	addw	a5,a4,a5
ffffffe00020266c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202670:	f8040023          	sb	zero,-128(s0)
ffffffe000202674:	1040006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe000202678:	f5043783          	ld	a5,-176(s0)
ffffffe00020267c:	0007c783          	lbu	a5,0(a5)
ffffffe000202680:	00078713          	mv	a4,a5
ffffffe000202684:	06300793          	li	a5,99
ffffffe000202688:	02f71e63          	bne	a4,a5,ffffffe0002026c4 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe00020268c:	f4843783          	ld	a5,-184(s0)
ffffffe000202690:	00878713          	addi	a4,a5,8
ffffffe000202694:	f4e43423          	sd	a4,-184(s0)
ffffffe000202698:	0007a783          	lw	a5,0(a5)
ffffffe00020269c:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe0002026a0:	fcc42703          	lw	a4,-52(s0)
ffffffe0002026a4:	f5843783          	ld	a5,-168(s0)
ffffffe0002026a8:	00070513          	mv	a0,a4
ffffffe0002026ac:	000780e7          	jalr	a5
                ++written;
ffffffe0002026b0:	fec42783          	lw	a5,-20(s0)
ffffffe0002026b4:	0017879b          	addiw	a5,a5,1
ffffffe0002026b8:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002026bc:	f8040023          	sb	zero,-128(s0)
ffffffe0002026c0:	0b80006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe0002026c4:	f5043783          	ld	a5,-176(s0)
ffffffe0002026c8:	0007c783          	lbu	a5,0(a5)
ffffffe0002026cc:	00078713          	mv	a4,a5
ffffffe0002026d0:	02500793          	li	a5,37
ffffffe0002026d4:	02f71263          	bne	a4,a5,ffffffe0002026f8 <vprintfmt+0x740>
                putch('%');
ffffffe0002026d8:	f5843783          	ld	a5,-168(s0)
ffffffe0002026dc:	02500513          	li	a0,37
ffffffe0002026e0:	000780e7          	jalr	a5
                ++written;
ffffffe0002026e4:	fec42783          	lw	a5,-20(s0)
ffffffe0002026e8:	0017879b          	addiw	a5,a5,1
ffffffe0002026ec:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002026f0:	f8040023          	sb	zero,-128(s0)
ffffffe0002026f4:	0840006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe0002026f8:	f5043783          	ld	a5,-176(s0)
ffffffe0002026fc:	0007c783          	lbu	a5,0(a5)
ffffffe000202700:	0007871b          	sext.w	a4,a5
ffffffe000202704:	f5843783          	ld	a5,-168(s0)
ffffffe000202708:	00070513          	mv	a0,a4
ffffffe00020270c:	000780e7          	jalr	a5
                ++written;
ffffffe000202710:	fec42783          	lw	a5,-20(s0)
ffffffe000202714:	0017879b          	addiw	a5,a5,1
ffffffe000202718:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe00020271c:	f8040023          	sb	zero,-128(s0)
ffffffe000202720:	0580006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe000202724:	f5043783          	ld	a5,-176(s0)
ffffffe000202728:	0007c783          	lbu	a5,0(a5)
ffffffe00020272c:	00078713          	mv	a4,a5
ffffffe000202730:	02500793          	li	a5,37
ffffffe000202734:	02f71063          	bne	a4,a5,ffffffe000202754 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe000202738:	f8043023          	sd	zero,-128(s0)
ffffffe00020273c:	f8043423          	sd	zero,-120(s0)
ffffffe000202740:	00100793          	li	a5,1
ffffffe000202744:	f8f40023          	sb	a5,-128(s0)
ffffffe000202748:	fff00793          	li	a5,-1
ffffffe00020274c:	f8f42623          	sw	a5,-116(s0)
ffffffe000202750:	0280006f          	j	ffffffe000202778 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe000202754:	f5043783          	ld	a5,-176(s0)
ffffffe000202758:	0007c783          	lbu	a5,0(a5)
ffffffe00020275c:	0007871b          	sext.w	a4,a5
ffffffe000202760:	f5843783          	ld	a5,-168(s0)
ffffffe000202764:	00070513          	mv	a0,a4
ffffffe000202768:	000780e7          	jalr	a5
            ++written;
ffffffe00020276c:	fec42783          	lw	a5,-20(s0)
ffffffe000202770:	0017879b          	addiw	a5,a5,1
ffffffe000202774:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe000202778:	f5043783          	ld	a5,-176(s0)
ffffffe00020277c:	00178793          	addi	a5,a5,1
ffffffe000202780:	f4f43823          	sd	a5,-176(s0)
ffffffe000202784:	f5043783          	ld	a5,-176(s0)
ffffffe000202788:	0007c783          	lbu	a5,0(a5)
ffffffe00020278c:	84079ce3          	bnez	a5,ffffffe000201fe4 <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000202790:	fec42783          	lw	a5,-20(s0)
}
ffffffe000202794:	00078513          	mv	a0,a5
ffffffe000202798:	0b813083          	ld	ra,184(sp)
ffffffe00020279c:	0b013403          	ld	s0,176(sp)
ffffffe0002027a0:	0c010113          	addi	sp,sp,192
ffffffe0002027a4:	00008067          	ret

ffffffe0002027a8 <printk>:

int printk(const char* s, ...) {
ffffffe0002027a8:	f9010113          	addi	sp,sp,-112
ffffffe0002027ac:	02113423          	sd	ra,40(sp)
ffffffe0002027b0:	02813023          	sd	s0,32(sp)
ffffffe0002027b4:	03010413          	addi	s0,sp,48
ffffffe0002027b8:	fca43c23          	sd	a0,-40(s0)
ffffffe0002027bc:	00b43423          	sd	a1,8(s0)
ffffffe0002027c0:	00c43823          	sd	a2,16(s0)
ffffffe0002027c4:	00d43c23          	sd	a3,24(s0)
ffffffe0002027c8:	02e43023          	sd	a4,32(s0)
ffffffe0002027cc:	02f43423          	sd	a5,40(s0)
ffffffe0002027d0:	03043823          	sd	a6,48(s0)
ffffffe0002027d4:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe0002027d8:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe0002027dc:	04040793          	addi	a5,s0,64
ffffffe0002027e0:	fcf43823          	sd	a5,-48(s0)
ffffffe0002027e4:	fd043783          	ld	a5,-48(s0)
ffffffe0002027e8:	fc878793          	addi	a5,a5,-56
ffffffe0002027ec:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe0002027f0:	fe043783          	ld	a5,-32(s0)
ffffffe0002027f4:	00078613          	mv	a2,a5
ffffffe0002027f8:	fd843583          	ld	a1,-40(s0)
ffffffe0002027fc:	fffff517          	auipc	a0,0xfffff
ffffffe000202800:	11850513          	addi	a0,a0,280 # ffffffe000201914 <putc>
ffffffe000202804:	fb4ff0ef          	jal	ffffffe000201fb8 <vprintfmt>
ffffffe000202808:	00050793          	mv	a5,a0
ffffffe00020280c:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe000202810:	fec42783          	lw	a5,-20(s0)
}
ffffffe000202814:	00078513          	mv	a0,a5
ffffffe000202818:	02813083          	ld	ra,40(sp)
ffffffe00020281c:	02013403          	ld	s0,32(sp)
ffffffe000202820:	07010113          	addi	sp,sp,112
ffffffe000202824:	00008067          	ret

ffffffe000202828 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe000202828:	fe010113          	addi	sp,sp,-32
ffffffe00020282c:	00813c23          	sd	s0,24(sp)
ffffffe000202830:	02010413          	addi	s0,sp,32
ffffffe000202834:	00050793          	mv	a5,a0
ffffffe000202838:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe00020283c:	fec42783          	lw	a5,-20(s0)
ffffffe000202840:	fff7879b          	addiw	a5,a5,-1
ffffffe000202844:	0007879b          	sext.w	a5,a5
ffffffe000202848:	02079713          	slli	a4,a5,0x20
ffffffe00020284c:	02075713          	srli	a4,a4,0x20
ffffffe000202850:	00003797          	auipc	a5,0x3
ffffffe000202854:	7d078793          	addi	a5,a5,2000 # ffffffe000206020 <seed>
ffffffe000202858:	00e7b023          	sd	a4,0(a5)
}
ffffffe00020285c:	00000013          	nop
ffffffe000202860:	01813403          	ld	s0,24(sp)
ffffffe000202864:	02010113          	addi	sp,sp,32
ffffffe000202868:	00008067          	ret

ffffffe00020286c <rand>:

int rand(void) {
ffffffe00020286c:	ff010113          	addi	sp,sp,-16
ffffffe000202870:	00813423          	sd	s0,8(sp)
ffffffe000202874:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe000202878:	00003797          	auipc	a5,0x3
ffffffe00020287c:	7a878793          	addi	a5,a5,1960 # ffffffe000206020 <seed>
ffffffe000202880:	0007b703          	ld	a4,0(a5)
ffffffe000202884:	00001797          	auipc	a5,0x1
ffffffe000202888:	01c78793          	addi	a5,a5,28 # ffffffe0002038a0 <lowerxdigits.0+0x18>
ffffffe00020288c:	0007b783          	ld	a5,0(a5)
ffffffe000202890:	02f707b3          	mul	a5,a4,a5
ffffffe000202894:	00178713          	addi	a4,a5,1
ffffffe000202898:	00003797          	auipc	a5,0x3
ffffffe00020289c:	78878793          	addi	a5,a5,1928 # ffffffe000206020 <seed>
ffffffe0002028a0:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe0002028a4:	00003797          	auipc	a5,0x3
ffffffe0002028a8:	77c78793          	addi	a5,a5,1916 # ffffffe000206020 <seed>
ffffffe0002028ac:	0007b783          	ld	a5,0(a5)
ffffffe0002028b0:	0217d793          	srli	a5,a5,0x21
ffffffe0002028b4:	0007879b          	sext.w	a5,a5
}
ffffffe0002028b8:	00078513          	mv	a0,a5
ffffffe0002028bc:	00813403          	ld	s0,8(sp)
ffffffe0002028c0:	01010113          	addi	sp,sp,16
ffffffe0002028c4:	00008067          	ret

ffffffe0002028c8 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe0002028c8:	fc010113          	addi	sp,sp,-64
ffffffe0002028cc:	02813c23          	sd	s0,56(sp)
ffffffe0002028d0:	04010413          	addi	s0,sp,64
ffffffe0002028d4:	fca43c23          	sd	a0,-40(s0)
ffffffe0002028d8:	00058793          	mv	a5,a1
ffffffe0002028dc:	fcc43423          	sd	a2,-56(s0)
ffffffe0002028e0:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe0002028e4:	fd843783          	ld	a5,-40(s0)
ffffffe0002028e8:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe0002028ec:	fe043423          	sd	zero,-24(s0)
ffffffe0002028f0:	0280006f          	j	ffffffe000202918 <memset+0x50>
        s[i] = c;
ffffffe0002028f4:	fe043703          	ld	a4,-32(s0)
ffffffe0002028f8:	fe843783          	ld	a5,-24(s0)
ffffffe0002028fc:	00f707b3          	add	a5,a4,a5
ffffffe000202900:	fd442703          	lw	a4,-44(s0)
ffffffe000202904:	0ff77713          	zext.b	a4,a4
ffffffe000202908:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe00020290c:	fe843783          	ld	a5,-24(s0)
ffffffe000202910:	00178793          	addi	a5,a5,1
ffffffe000202914:	fef43423          	sd	a5,-24(s0)
ffffffe000202918:	fe843703          	ld	a4,-24(s0)
ffffffe00020291c:	fc843783          	ld	a5,-56(s0)
ffffffe000202920:	fcf76ae3          	bltu	a4,a5,ffffffe0002028f4 <memset+0x2c>
    }
    return dest;
ffffffe000202924:	fd843783          	ld	a5,-40(s0)
}
ffffffe000202928:	00078513          	mv	a0,a5
ffffffe00020292c:	03813403          	ld	s0,56(sp)
ffffffe000202930:	04010113          	addi	sp,sp,64
ffffffe000202934:	00008067          	ret
