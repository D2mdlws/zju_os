
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_skernel>:
    
    # ------------------
    # - your code here -
    # ------------------

    la sp, boot_stack           # set stack pointer
    80200000:	00003117          	auipc	sp,0x3
    80200004:	01013103          	ld	sp,16(sp) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>

    # ----------------------
    # - set stvec = _traps -
    # ----------------------

    la t0, _traps;
    80200008:	00003297          	auipc	t0,0x3
    8020000c:	0102b283          	ld	t0,16(t0) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
    csrw stvec, t0 
    80200010:	10529073          	csrw	stvec,t0

    # ---------------------
    # - set sie[STIE] = 1 -
    # ---------------------

    add t0,x0,0x20
    80200014:	02000293          	li	t0,32
    csrs sie, t0 
    80200018:	1042a073          	csrs	sie,t0

    # ----------------------------
    # - set first time interrupt -
    # ----------------------------

    li t1, 10000000           # 10MHz
    8020001c:	00989337          	lui	t1,0x989
    80200020:	6803031b          	addiw	t1,t1,1664 # 989680 <_skernel-0x7f876980>
    rdtime t0
    80200024:	c01022f3          	rdtime	t0
    add t0, t0, t1
    80200028:	006282b3          	add	t0,t0,t1
    addi a0, t0, 0
    8020002c:	00028513          	mv	a0,t0
    call sbi_set_timer
    80200030:	394000ef          	jal	802003c4 <sbi_set_timer>

    # ----------------------------
    # - set sstatus[SIE] = 1 -
    # ----------------------------

    li t1, 0x2
    80200034:	00200313          	li	t1,2
    csrs sstatus, t1
    80200038:	10032073          	csrs	sstatus,t1

    call start_kernel
    8020003c:	5cc000ef          	jal	80200608 <start_kernel>

0000000080200040 <_traps>:
    .globl _traps 
_traps:

    # 1. save 32 registers and sepc to stack

    addi sp, sp, -33*8
    80200040:	ef810113          	addi	sp,sp,-264

    sd x0, 0*8(sp)
    80200044:	00013023          	sd	zero,0(sp)
    sd x1, 1*8(sp)
    80200048:	00113423          	sd	ra,8(sp)
    sd x2, 2*8(sp)
    8020004c:	00213823          	sd	sp,16(sp)
    sd x3, 3*8(sp)
    80200050:	00313c23          	sd	gp,24(sp)
    sd x4, 4*8(sp)
    80200054:	02413023          	sd	tp,32(sp)
    sd x5, 5*8(sp)
    80200058:	02513423          	sd	t0,40(sp)
    sd x6, 6*8(sp)
    8020005c:	02613823          	sd	t1,48(sp)
    sd x7, 7*8(sp)
    80200060:	02713c23          	sd	t2,56(sp)
    sd x8, 8*8(sp)
    80200064:	04813023          	sd	s0,64(sp)
    sd x9, 9*8(sp)
    80200068:	04913423          	sd	s1,72(sp)
    sd x10, 10*8(sp)
    8020006c:	04a13823          	sd	a0,80(sp)
    sd x11, 11*8(sp)
    80200070:	04b13c23          	sd	a1,88(sp)
    sd x12, 12*8(sp)
    80200074:	06c13023          	sd	a2,96(sp)
    sd x13, 13*8(sp)
    80200078:	06d13423          	sd	a3,104(sp)
    sd x14, 14*8(sp)
    8020007c:	06e13823          	sd	a4,112(sp)
    sd x15, 15*8(sp)
    80200080:	06f13c23          	sd	a5,120(sp)
    sd x16, 16*8(sp)
    80200084:	09013023          	sd	a6,128(sp)
    sd x17, 17*8(sp)
    80200088:	09113423          	sd	a7,136(sp)
    sd x18, 18*8(sp)
    8020008c:	09213823          	sd	s2,144(sp)
    sd x19, 19*8(sp)
    80200090:	09313c23          	sd	s3,152(sp)
    sd x20, 20*8(sp)
    80200094:	0b413023          	sd	s4,160(sp)
    sd x21, 21*8(sp)
    80200098:	0b513423          	sd	s5,168(sp)
    sd x22, 22*8(sp)
    8020009c:	0b613823          	sd	s6,176(sp)
    sd x23, 23*8(sp)
    802000a0:	0b713c23          	sd	s7,184(sp)
    sd x24, 24*8(sp)
    802000a4:	0d813023          	sd	s8,192(sp)
    sd x25, 25*8(sp)
    802000a8:	0d913423          	sd	s9,200(sp)
    sd x26, 26*8(sp)
    802000ac:	0da13823          	sd	s10,208(sp)
    sd x27, 27*8(sp)
    802000b0:	0db13c23          	sd	s11,216(sp)
    sd x28, 28*8(sp)
    802000b4:	0fc13023          	sd	t3,224(sp)
    sd x29, 29*8(sp)
    802000b8:	0fd13423          	sd	t4,232(sp)
    sd x30, 30*8(sp)
    802000bc:	0fe13823          	sd	t5,240(sp)
    sd x31, 31*8(sp)
    802000c0:	0ff13c23          	sd	t6,248(sp)

    csrr t0, sepc
    802000c4:	141022f3          	csrr	t0,sepc
    sd t0, 32*8(sp)
    802000c8:	10513023          	sd	t0,256(sp)

    # 2. call trap_handler

    csrr t1, scause
    802000cc:	14202373          	csrr	t1,scause
    mv a0, t1
    802000d0:	00030513          	mv	a0,t1
    mv a1, t0
    802000d4:	00028593          	mv	a1,t0
    call trap_handler
    802000d8:	4a0000ef          	jal	80200578 <trap_handler>

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack

    ld x0, 0*8(sp)
    802000dc:	00013003          	ld	zero,0(sp)
    ld x1, 1*8(sp)
    802000e0:	00813083          	ld	ra,8(sp)
    ld x3, 3*8(sp)
    802000e4:	01813183          	ld	gp,24(sp)
    ld x4, 4*8(sp)
    802000e8:	02013203          	ld	tp,32(sp)
    ld x5, 5*8(sp)
    802000ec:	02813283          	ld	t0,40(sp)
    ld x6, 6*8(sp)
    802000f0:	03013303          	ld	t1,48(sp)
    ld x7, 7*8(sp)
    802000f4:	03813383          	ld	t2,56(sp)
    ld x8, 8*8(sp)
    802000f8:	04013403          	ld	s0,64(sp)
    ld x9, 9*8(sp)
    802000fc:	04813483          	ld	s1,72(sp)
    ld x10, 10*8(sp)
    80200100:	05013503          	ld	a0,80(sp)
    ld x11, 11*8(sp)
    80200104:	05813583          	ld	a1,88(sp)
    ld x12, 12*8(sp)
    80200108:	06013603          	ld	a2,96(sp)
    ld x13, 13*8(sp)
    8020010c:	06813683          	ld	a3,104(sp)
    ld x14, 14*8(sp)
    80200110:	07013703          	ld	a4,112(sp)
    ld x15, 15*8(sp)
    80200114:	07813783          	ld	a5,120(sp)
    ld x16, 16*8(sp)
    80200118:	08013803          	ld	a6,128(sp)
    ld x17, 17*8(sp)
    8020011c:	08813883          	ld	a7,136(sp)
    ld x18, 18*8(sp)
    80200120:	09013903          	ld	s2,144(sp)
    ld x19, 19*8(sp)
    80200124:	09813983          	ld	s3,152(sp)
    ld x20, 20*8(sp)
    80200128:	0a013a03          	ld	s4,160(sp)
    ld x21, 21*8(sp)
    8020012c:	0a813a83          	ld	s5,168(sp)
    ld x22, 22*8(sp)
    80200130:	0b013b03          	ld	s6,176(sp)
    ld x23, 23*8(sp)
    80200134:	0b813b83          	ld	s7,184(sp)
    ld x24, 24*8(sp)    
    80200138:	0c013c03          	ld	s8,192(sp)
    ld x25, 25*8(sp)
    8020013c:	0c813c83          	ld	s9,200(sp)
    ld x26, 26*8(sp)
    80200140:	0d013d03          	ld	s10,208(sp)
    ld x27, 27*8(sp)
    80200144:	0d813d83          	ld	s11,216(sp)
    ld x28, 28*8(sp)
    80200148:	0e013e03          	ld	t3,224(sp)
    ld x29, 29*8(sp)
    8020014c:	0e813e83          	ld	t4,232(sp)
    ld x30, 30*8(sp)
    80200150:	0f013f03          	ld	t5,240(sp)
    ld x31, 31*8(sp)
    80200154:	0f813f83          	ld	t6,248(sp)
    ld t0, 32*8(sp)
    80200158:	10013283          	ld	t0,256(sp)
    csrw sepc, t0
    8020015c:	14129073          	csrw	sepc,t0
    ld x2, 2*8(sp)
    80200160:	01013103          	ld	sp,16(sp)

    addi sp, sp, 33*8
    80200164:	10810113          	addi	sp,sp,264

    # 4. return from trap

    sret
    80200168:	10200073          	sret

000000008020016c <get_cycles>:
#include "clock.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
    8020016c:	fe010113          	addi	sp,sp,-32
    80200170:	00813c23          	sd	s0,24(sp)
    80200174:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    uint64_t time;
    __asm__ volatile(
    80200178:	c01027f3          	rdtime	a5
    8020017c:	fef43423          	sd	a5,-24(s0)
        "rdtime %[time]"
        : [time] "=r" (time)
    );
    return time;
    80200180:	fe843783          	ld	a5,-24(s0)
}
    80200184:	00078513          	mv	a0,a5
    80200188:	01813403          	ld	s0,24(sp)
    8020018c:	02010113          	addi	sp,sp,32
    80200190:	00008067          	ret

0000000080200194 <clock_set_next_event>:

void clock_set_next_event() {
    80200194:	fe010113          	addi	sp,sp,-32
    80200198:	00113c23          	sd	ra,24(sp)
    8020019c:	00813823          	sd	s0,16(sp)
    802001a0:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
    802001a4:	fc9ff0ef          	jal	8020016c <get_cycles>
    802001a8:	00050713          	mv	a4,a0
    802001ac:	00003797          	auipc	a5,0x3
    802001b0:	e5478793          	addi	a5,a5,-428 # 80203000 <TIMECLOCK>
    802001b4:	0007b783          	ld	a5,0(a5)
    802001b8:	00f707b3          	add	a5,a4,a5
    802001bc:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
    802001c0:	fe843503          	ld	a0,-24(s0)
    802001c4:	200000ef          	jal	802003c4 <sbi_set_timer>
    802001c8:	00000013          	nop
    802001cc:	01813083          	ld	ra,24(sp)
    802001d0:	01013403          	ld	s0,16(sp)
    802001d4:	02010113          	addi	sp,sp,32
    802001d8:	00008067          	ret

00000000802001dc <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    802001dc:	f9010113          	addi	sp,sp,-112
    802001e0:	06813423          	sd	s0,104(sp)
    802001e4:	07010413          	addi	s0,sp,112
    802001e8:	fca43423          	sd	a0,-56(s0)
    802001ec:	fcb43023          	sd	a1,-64(s0)
    802001f0:	fac43c23          	sd	a2,-72(s0)
    802001f4:	fad43823          	sd	a3,-80(s0)
    802001f8:	fae43423          	sd	a4,-88(s0)
    802001fc:	faf43023          	sd	a5,-96(s0)
    80200200:	f9043c23          	sd	a6,-104(s0)
    80200204:	f9143823          	sd	a7,-112(s0)
	
	struct sbiret ret;
    __asm__ volatile(
    80200208:	fc843783          	ld	a5,-56(s0)
    8020020c:	fc043703          	ld	a4,-64(s0)
    80200210:	fb843683          	ld	a3,-72(s0)
    80200214:	fb043603          	ld	a2,-80(s0)
    80200218:	fa843583          	ld	a1,-88(s0)
    8020021c:	fa043503          	ld	a0,-96(s0)
    80200220:	f9843803          	ld	a6,-104(s0)
    80200224:	f9043883          	ld	a7,-112(s0)
    80200228:	00078893          	mv	a7,a5
    8020022c:	00070813          	mv	a6,a4
    80200230:	00068513          	mv	a0,a3
    80200234:	00060593          	mv	a1,a2
    80200238:	00058613          	mv	a2,a1
    8020023c:	00050693          	mv	a3,a0
    80200240:	00080713          	mv	a4,a6
    80200244:	00088793          	mv	a5,a7
    80200248:	00000073          	ecall
    8020024c:	00050713          	mv	a4,a0
    80200250:	00058793          	mv	a5,a1
    80200254:	fce43823          	sd	a4,-48(s0)
    80200258:	fcf43c23          	sd	a5,-40(s0)
		"mv %[ret_error], a0\n"
		"mv %[ret_value], a1\n"
		: [ret_error] "=r" (ret.error), [ret_value] "=r" (ret.value)
		: [eid] "r" (eid), [fid] "r" (fid), [arg0] "r" (arg0), [arg1] "r" (arg1), [arg2] "r" (arg2), [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
	 );
	return ret;
    8020025c:	fd043783          	ld	a5,-48(s0)
    80200260:	fef43023          	sd	a5,-32(s0)
    80200264:	fd843783          	ld	a5,-40(s0)
    80200268:	fef43423          	sd	a5,-24(s0)
    8020026c:	fe043703          	ld	a4,-32(s0)
    80200270:	fe843783          	ld	a5,-24(s0)
    80200274:	00070313          	mv	t1,a4
    80200278:	00078393          	mv	t2,a5
    8020027c:	00030713          	mv	a4,t1
    80200280:	00038793          	mv	a5,t2
}
    80200284:	00070513          	mv	a0,a4
    80200288:	00078593          	mv	a1,a5
    8020028c:	06813403          	ld	s0,104(sp)
    80200290:	07010113          	addi	sp,sp,112
    80200294:	00008067          	ret

0000000080200298 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    80200298:	fc010113          	addi	sp,sp,-64
    8020029c:	02113c23          	sd	ra,56(sp)
    802002a0:	02813823          	sd	s0,48(sp)
    802002a4:	03213423          	sd	s2,40(sp)
    802002a8:	03313023          	sd	s3,32(sp)
    802002ac:	04010413          	addi	s0,sp,64
    802002b0:	00050793          	mv	a5,a0
    802002b4:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e, 2, byte, 0, 0, 0, 0, 0);
    802002b8:	fcf44603          	lbu	a2,-49(s0)
    802002bc:	00000893          	li	a7,0
    802002c0:	00000813          	li	a6,0
    802002c4:	00000793          	li	a5,0
    802002c8:	00000713          	li	a4,0
    802002cc:	00000693          	li	a3,0
    802002d0:	00200593          	li	a1,2
    802002d4:	44424537          	lui	a0,0x44424
    802002d8:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    802002dc:	f01ff0ef          	jal	802001dc <sbi_ecall>
    802002e0:	00050713          	mv	a4,a0
    802002e4:	00058793          	mv	a5,a1
    802002e8:	fce43823          	sd	a4,-48(s0)
    802002ec:	fcf43c23          	sd	a5,-40(s0)
    802002f0:	fd043703          	ld	a4,-48(s0)
    802002f4:	fd843783          	ld	a5,-40(s0)
    802002f8:	00070913          	mv	s2,a4
    802002fc:	00078993          	mv	s3,a5
    80200300:	00090713          	mv	a4,s2
    80200304:	00098793          	mv	a5,s3
}
    80200308:	00070513          	mv	a0,a4
    8020030c:	00078593          	mv	a1,a5
    80200310:	03813083          	ld	ra,56(sp)
    80200314:	03013403          	ld	s0,48(sp)
    80200318:	02813903          	ld	s2,40(sp)
    8020031c:	02013983          	ld	s3,32(sp)
    80200320:	04010113          	addi	sp,sp,64
    80200324:	00008067          	ret

0000000080200328 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    80200328:	fc010113          	addi	sp,sp,-64
    8020032c:	02113c23          	sd	ra,56(sp)
    80200330:	02813823          	sd	s0,48(sp)
    80200334:	03213423          	sd	s2,40(sp)
    80200338:	03313023          	sd	s3,32(sp)
    8020033c:	04010413          	addi	s0,sp,64
    80200340:	00050793          	mv	a5,a0
    80200344:	00058713          	mv	a4,a1
    80200348:	fcf42623          	sw	a5,-52(s0)
    8020034c:	00070793          	mv	a5,a4
    80200350:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0, reset_type, reset_reason, 0, 0, 0, 0);
    80200354:	fcc46603          	lwu	a2,-52(s0)
    80200358:	fc846683          	lwu	a3,-56(s0)
    8020035c:	00000893          	li	a7,0
    80200360:	00000813          	li	a6,0
    80200364:	00000793          	li	a5,0
    80200368:	00000713          	li	a4,0
    8020036c:	00000593          	li	a1,0
    80200370:	53525537          	lui	a0,0x53525
    80200374:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    80200378:	e65ff0ef          	jal	802001dc <sbi_ecall>
    8020037c:	00050713          	mv	a4,a0
    80200380:	00058793          	mv	a5,a1
    80200384:	fce43823          	sd	a4,-48(s0)
    80200388:	fcf43c23          	sd	a5,-40(s0)
    8020038c:	fd043703          	ld	a4,-48(s0)
    80200390:	fd843783          	ld	a5,-40(s0)
    80200394:	00070913          	mv	s2,a4
    80200398:	00078993          	mv	s3,a5
    8020039c:	00090713          	mv	a4,s2
    802003a0:	00098793          	mv	a5,s3
}
    802003a4:	00070513          	mv	a0,a4
    802003a8:	00078593          	mv	a1,a5
    802003ac:	03813083          	ld	ra,56(sp)
    802003b0:	03013403          	ld	s0,48(sp)
    802003b4:	02813903          	ld	s2,40(sp)
    802003b8:	02013983          	ld	s3,32(sp)
    802003bc:	04010113          	addi	sp,sp,64
    802003c0:	00008067          	ret

00000000802003c4 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value) {
    802003c4:	fc010113          	addi	sp,sp,-64
    802003c8:	02113c23          	sd	ra,56(sp)
    802003cc:	02813823          	sd	s0,48(sp)
    802003d0:	03213423          	sd	s2,40(sp)
    802003d4:	03313023          	sd	s3,32(sp)
    802003d8:	04010413          	addi	s0,sp,64
    802003dc:	fca43423          	sd	a0,-56(s0)
	return sbi_ecall(0x54494d45, 0, stime_value, 0, 0, 0, 0, 0);
    802003e0:	00000893          	li	a7,0
    802003e4:	00000813          	li	a6,0
    802003e8:	00000793          	li	a5,0
    802003ec:	00000713          	li	a4,0
    802003f0:	00000693          	li	a3,0
    802003f4:	fc843603          	ld	a2,-56(s0)
    802003f8:	00000593          	li	a1,0
    802003fc:	54495537          	lui	a0,0x54495
    80200400:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    80200404:	dd9ff0ef          	jal	802001dc <sbi_ecall>
    80200408:	00050713          	mv	a4,a0
    8020040c:	00058793          	mv	a5,a1
    80200410:	fce43823          	sd	a4,-48(s0)
    80200414:	fcf43c23          	sd	a5,-40(s0)
    80200418:	fd043703          	ld	a4,-48(s0)
    8020041c:	fd843783          	ld	a5,-40(s0)
    80200420:	00070913          	mv	s2,a4
    80200424:	00078993          	mv	s3,a5
    80200428:	00090713          	mv	a4,s2
    8020042c:	00098793          	mv	a5,s3
}
    80200430:	00070513          	mv	a0,a4
    80200434:	00078593          	mv	a1,a5
    80200438:	03813083          	ld	ra,56(sp)
    8020043c:	03013403          	ld	s0,48(sp)
    80200440:	02813903          	ld	s2,40(sp)
    80200444:	02013983          	ld	s3,32(sp)
    80200448:	04010113          	addi	sp,sp,64
    8020044c:	00008067          	ret

0000000080200450 <sbi_debug_console_write>:

struct sbiret sbi_debug_console_write(unsigned long num_bytes,
									  unsigned long base_addr_lo,
									  unsigned long base_addr_hi) {
    80200450:	fb010113          	addi	sp,sp,-80
    80200454:	04113423          	sd	ra,72(sp)
    80200458:	04813023          	sd	s0,64(sp)
    8020045c:	03213c23          	sd	s2,56(sp)
    80200460:	03313823          	sd	s3,48(sp)
    80200464:	05010413          	addi	s0,sp,80
    80200468:	fca43423          	sd	a0,-56(s0)
    8020046c:	fcb43023          	sd	a1,-64(s0)
    80200470:	fac43c23          	sd	a2,-72(s0)
	return sbi_ecall(0x4442434e, 0, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
    80200474:	00000893          	li	a7,0
    80200478:	00000813          	li	a6,0
    8020047c:	00000793          	li	a5,0
    80200480:	fb843703          	ld	a4,-72(s0)
    80200484:	fc043683          	ld	a3,-64(s0)
    80200488:	fc843603          	ld	a2,-56(s0)
    8020048c:	00000593          	li	a1,0
    80200490:	44424537          	lui	a0,0x44424
    80200494:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    80200498:	d45ff0ef          	jal	802001dc <sbi_ecall>
    8020049c:	00050713          	mv	a4,a0
    802004a0:	00058793          	mv	a5,a1
    802004a4:	fce43823          	sd	a4,-48(s0)
    802004a8:	fcf43c23          	sd	a5,-40(s0)
    802004ac:	fd043703          	ld	a4,-48(s0)
    802004b0:	fd843783          	ld	a5,-40(s0)
    802004b4:	00070913          	mv	s2,a4
    802004b8:	00078993          	mv	s3,a5
    802004bc:	00090713          	mv	a4,s2
    802004c0:	00098793          	mv	a5,s3
}
    802004c4:	00070513          	mv	a0,a4
    802004c8:	00078593          	mv	a1,a5
    802004cc:	04813083          	ld	ra,72(sp)
    802004d0:	04013403          	ld	s0,64(sp)
    802004d4:	03813903          	ld	s2,56(sp)
    802004d8:	03013983          	ld	s3,48(sp)
    802004dc:	05010113          	addi	sp,sp,80
    802004e0:	00008067          	ret

00000000802004e4 <sbi_debug_console_read>:

struct sbiret sbi_debug_console_read(unsigned long num_bytes,
									 unsigned long base_addr_lo,
									 unsigned long base_addr_hi) {
    802004e4:	fb010113          	addi	sp,sp,-80
    802004e8:	04113423          	sd	ra,72(sp)
    802004ec:	04813023          	sd	s0,64(sp)
    802004f0:	03213c23          	sd	s2,56(sp)
    802004f4:	03313823          	sd	s3,48(sp)
    802004f8:	05010413          	addi	s0,sp,80
    802004fc:	fca43423          	sd	a0,-56(s0)
    80200500:	fcb43023          	sd	a1,-64(s0)
    80200504:	fac43c23          	sd	a2,-72(s0)
	return sbi_ecall(0x4442434e, 1, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
    80200508:	00000893          	li	a7,0
    8020050c:	00000813          	li	a6,0
    80200510:	00000793          	li	a5,0
    80200514:	fb843703          	ld	a4,-72(s0)
    80200518:	fc043683          	ld	a3,-64(s0)
    8020051c:	fc843603          	ld	a2,-56(s0)
    80200520:	00100593          	li	a1,1
    80200524:	44424537          	lui	a0,0x44424
    80200528:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    8020052c:	cb1ff0ef          	jal	802001dc <sbi_ecall>
    80200530:	00050713          	mv	a4,a0
    80200534:	00058793          	mv	a5,a1
    80200538:	fce43823          	sd	a4,-48(s0)
    8020053c:	fcf43c23          	sd	a5,-40(s0)
    80200540:	fd043703          	ld	a4,-48(s0)
    80200544:	fd843783          	ld	a5,-40(s0)
    80200548:	00070913          	mv	s2,a4
    8020054c:	00078993          	mv	s3,a5
    80200550:	00090713          	mv	a4,s2
    80200554:	00098793          	mv	a5,s3
    80200558:	00070513          	mv	a0,a4
    8020055c:	00078593          	mv	a1,a5
    80200560:	04813083          	ld	ra,72(sp)
    80200564:	04013403          	ld	s0,64(sp)
    80200568:	03813903          	ld	s2,56(sp)
    8020056c:	03013983          	ld	s3,48(sp)
    80200570:	05010113          	addi	sp,sp,80
    80200574:	00008067          	ret

0000000080200578 <trap_handler>:
#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "trap.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
    80200578:	fd010113          	addi	sp,sp,-48
    8020057c:	02113423          	sd	ra,40(sp)
    80200580:	02813023          	sd	s0,32(sp)
    80200584:	03010413          	addi	s0,sp,48
    80200588:	fca43c23          	sd	a0,-40(s0)
    8020058c:	fcb43823          	sd	a1,-48(s0)
    // 如果是 interrupt 判断是否是 timer interrupt
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试

    int is_interrupt = (scause >> 63) & 1;
    80200590:	fd843783          	ld	a5,-40(s0)
    80200594:	03f7d793          	srli	a5,a5,0x3f
    80200598:	fef42623          	sw	a5,-20(s0)
    
    if (is_interrupt) {
    8020059c:	fec42783          	lw	a5,-20(s0)
    802005a0:	0007879b          	sext.w	a5,a5
    802005a4:	04078063          	beqz	a5,802005e4 <trap_handler+0x6c>
        if (scause == 0x8000000000000005) {
    802005a8:	fd843703          	ld	a4,-40(s0)
    802005ac:	fff00793          	li	a5,-1
    802005b0:	03f79793          	slli	a5,a5,0x3f
    802005b4:	00578793          	addi	a5,a5,5
    802005b8:	00f71c63          	bne	a4,a5,802005d0 <trap_handler+0x58>
            printk("[S] Supervisor Mode Timer Interrupt\n");
    802005bc:	00002517          	auipc	a0,0x2
    802005c0:	a4450513          	addi	a0,a0,-1468 # 80202000 <_srodata>
    802005c4:	7c5000ef          	jal	80201588 <printk>
            clock_set_next_event();
    802005c8:	bcdff0ef          	jal	80200194 <clock_set_next_event>
        }
    }
    else {
        printk("[S] Unhandled interrupt/exception: scause=0x%lx\n", scause);
    }
    802005cc:	0280006f          	j	802005f4 <trap_handler+0x7c>
            printk("[S] Unhandled interrupt/exception: scause=0x%lx\n", scause);
    802005d0:	fd843583          	ld	a1,-40(s0)
    802005d4:	00002517          	auipc	a0,0x2
    802005d8:	a5450513          	addi	a0,a0,-1452 # 80202028 <_srodata+0x28>
    802005dc:	7ad000ef          	jal	80201588 <printk>
    802005e0:	0140006f          	j	802005f4 <trap_handler+0x7c>
        printk("[S] Unhandled interrupt/exception: scause=0x%lx\n", scause);
    802005e4:	fd843583          	ld	a1,-40(s0)
    802005e8:	00002517          	auipc	a0,0x2
    802005ec:	a4050513          	addi	a0,a0,-1472 # 80202028 <_srodata+0x28>
    802005f0:	799000ef          	jal	80201588 <printk>
    802005f4:	00000013          	nop
    802005f8:	02813083          	ld	ra,40(sp)
    802005fc:	02013403          	ld	s0,32(sp)
    80200600:	03010113          	addi	sp,sp,48
    80200604:	00008067          	ret

0000000080200608 <start_kernel>:
#include "printk.h"
#include "defs.h"

extern void test();

int start_kernel() {
    80200608:	fc010113          	addi	sp,sp,-64
    8020060c:	02113c23          	sd	ra,56(sp)
    80200610:	02813823          	sd	s0,48(sp)
    80200614:	04010413          	addi	s0,sp,64
    printk("2024");
    80200618:	00002517          	auipc	a0,0x2
    8020061c:	a4850513          	addi	a0,a0,-1464 # 80202060 <_srodata+0x60>
    80200620:	769000ef          	jal	80201588 <printk>
    printk(" ZJU Operating System\n");
    80200624:	00002517          	auipc	a0,0x2
    80200628:	a4450513          	addi	a0,a0,-1468 # 80202068 <_srodata+0x68>
    8020062c:	75d000ef          	jal	80201588 <printk>
    uint64_t sstatus = csr_read(sstatus);
    80200630:	fe843783          	ld	a5,-24(s0)
    80200634:	100027f3          	csrr	a5,sstatus
    80200638:	fef43023          	sd	a5,-32(s0)
    8020063c:	fe043783          	ld	a5,-32(s0)
    80200640:	fef43423          	sd	a5,-24(s0)
    printk("sstatus: %#llx\n", sstatus);
    80200644:	fe843583          	ld	a1,-24(s0)
    80200648:	00002517          	auipc	a0,0x2
    8020064c:	a3850513          	addi	a0,a0,-1480 # 80202080 <_srodata+0x80>
    80200650:	739000ef          	jal	80201588 <printk>

    csr_write(sscratch, (uint64_t)0xffffffffffffffff);
    80200654:	fff00793          	li	a5,-1
    80200658:	fcf43c23          	sd	a5,-40(s0)
    8020065c:	fd843783          	ld	a5,-40(s0)
    80200660:	14079073          	csrw	sscratch,a5
    uint64_t sscratch = csr_read(sscratch);
    80200664:	fd043783          	ld	a5,-48(s0)
    80200668:	140027f3          	csrr	a5,sscratch
    8020066c:	fcf43423          	sd	a5,-56(s0)
    80200670:	fc843783          	ld	a5,-56(s0)
    80200674:	fcf43823          	sd	a5,-48(s0)
    printk("scratch: %#llx\n", sscratch);
    80200678:	fd043583          	ld	a1,-48(s0)
    8020067c:	00002517          	auipc	a0,0x2
    80200680:	a1450513          	addi	a0,a0,-1516 # 80202090 <_srodata+0x90>
    80200684:	705000ef          	jal	80201588 <printk>

    test();
    80200688:	01c000ef          	jal	802006a4 <test>
    return 0;
    8020068c:	00000793          	li	a5,0
}
    80200690:	00078513          	mv	a0,a5
    80200694:	03813083          	ld	ra,56(sp)
    80200698:	03013403          	ld	s0,48(sp)
    8020069c:	04010113          	addi	sp,sp,64
    802006a0:	00008067          	ret

00000000802006a4 <test>:
#include "sbi.h"
#include "printk.h"

void test() {
    802006a4:	fe010113          	addi	sp,sp,-32
    802006a8:	00113c23          	sd	ra,24(sp)
    802006ac:	00813823          	sd	s0,16(sp)
    802006b0:	02010413          	addi	s0,sp,32
    int i = 0;
    802006b4:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
    802006b8:	fec42783          	lw	a5,-20(s0)
    802006bc:	0017879b          	addiw	a5,a5,1
    802006c0:	fef42623          	sw	a5,-20(s0)
    802006c4:	fec42783          	lw	a5,-20(s0)
    802006c8:	00078713          	mv	a4,a5
    802006cc:	05f5e7b7          	lui	a5,0x5f5e
    802006d0:	1007879b          	addiw	a5,a5,256 # 5f5e100 <_skernel-0x7a2a1f00>
    802006d4:	02f767bb          	remw	a5,a4,a5
    802006d8:	0007879b          	sext.w	a5,a5
    802006dc:	fc079ee3          	bnez	a5,802006b8 <test+0x14>
            printk("kernel is running!\n");
    802006e0:	00002517          	auipc	a0,0x2
    802006e4:	9c050513          	addi	a0,a0,-1600 # 802020a0 <_srodata+0xa0>
    802006e8:	6a1000ef          	jal	80201588 <printk>
            i = 0;
    802006ec:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
    802006f0:	fc9ff06f          	j	802006b8 <test+0x14>

00000000802006f4 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    802006f4:	fe010113          	addi	sp,sp,-32
    802006f8:	00113c23          	sd	ra,24(sp)
    802006fc:	00813823          	sd	s0,16(sp)
    80200700:	02010413          	addi	s0,sp,32
    80200704:	00050793          	mv	a5,a0
    80200708:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    8020070c:	fec42783          	lw	a5,-20(s0)
    80200710:	0ff7f793          	zext.b	a5,a5
    80200714:	00078513          	mv	a0,a5
    80200718:	b81ff0ef          	jal	80200298 <sbi_debug_console_write_byte>
    return (char)c;
    8020071c:	fec42783          	lw	a5,-20(s0)
    80200720:	0ff7f793          	zext.b	a5,a5
    80200724:	0007879b          	sext.w	a5,a5
}
    80200728:	00078513          	mv	a0,a5
    8020072c:	01813083          	ld	ra,24(sp)
    80200730:	01013403          	ld	s0,16(sp)
    80200734:	02010113          	addi	sp,sp,32
    80200738:	00008067          	ret

000000008020073c <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    8020073c:	fe010113          	addi	sp,sp,-32
    80200740:	00813c23          	sd	s0,24(sp)
    80200744:	02010413          	addi	s0,sp,32
    80200748:	00050793          	mv	a5,a0
    8020074c:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    80200750:	fec42783          	lw	a5,-20(s0)
    80200754:	0007871b          	sext.w	a4,a5
    80200758:	02000793          	li	a5,32
    8020075c:	02f70263          	beq	a4,a5,80200780 <isspace+0x44>
    80200760:	fec42783          	lw	a5,-20(s0)
    80200764:	0007871b          	sext.w	a4,a5
    80200768:	00800793          	li	a5,8
    8020076c:	00e7de63          	bge	a5,a4,80200788 <isspace+0x4c>
    80200770:	fec42783          	lw	a5,-20(s0)
    80200774:	0007871b          	sext.w	a4,a5
    80200778:	00d00793          	li	a5,13
    8020077c:	00e7c663          	blt	a5,a4,80200788 <isspace+0x4c>
    80200780:	00100793          	li	a5,1
    80200784:	0080006f          	j	8020078c <isspace+0x50>
    80200788:	00000793          	li	a5,0
}
    8020078c:	00078513          	mv	a0,a5
    80200790:	01813403          	ld	s0,24(sp)
    80200794:	02010113          	addi	sp,sp,32
    80200798:	00008067          	ret

000000008020079c <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    8020079c:	fb010113          	addi	sp,sp,-80
    802007a0:	04113423          	sd	ra,72(sp)
    802007a4:	04813023          	sd	s0,64(sp)
    802007a8:	05010413          	addi	s0,sp,80
    802007ac:	fca43423          	sd	a0,-56(s0)
    802007b0:	fcb43023          	sd	a1,-64(s0)
    802007b4:	00060793          	mv	a5,a2
    802007b8:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    802007bc:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    802007c0:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    802007c4:	fc843783          	ld	a5,-56(s0)
    802007c8:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    802007cc:	0100006f          	j	802007dc <strtol+0x40>
        p++;
    802007d0:	fd843783          	ld	a5,-40(s0)
    802007d4:	00178793          	addi	a5,a5,1
    802007d8:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    802007dc:	fd843783          	ld	a5,-40(s0)
    802007e0:	0007c783          	lbu	a5,0(a5)
    802007e4:	0007879b          	sext.w	a5,a5
    802007e8:	00078513          	mv	a0,a5
    802007ec:	f51ff0ef          	jal	8020073c <isspace>
    802007f0:	00050793          	mv	a5,a0
    802007f4:	fc079ee3          	bnez	a5,802007d0 <strtol+0x34>
    }

    if (*p == '-') {
    802007f8:	fd843783          	ld	a5,-40(s0)
    802007fc:	0007c783          	lbu	a5,0(a5)
    80200800:	00078713          	mv	a4,a5
    80200804:	02d00793          	li	a5,45
    80200808:	00f71e63          	bne	a4,a5,80200824 <strtol+0x88>
        neg = true;
    8020080c:	00100793          	li	a5,1
    80200810:	fef403a3          	sb	a5,-25(s0)
        p++;
    80200814:	fd843783          	ld	a5,-40(s0)
    80200818:	00178793          	addi	a5,a5,1
    8020081c:	fcf43c23          	sd	a5,-40(s0)
    80200820:	0240006f          	j	80200844 <strtol+0xa8>
    } else if (*p == '+') {
    80200824:	fd843783          	ld	a5,-40(s0)
    80200828:	0007c783          	lbu	a5,0(a5)
    8020082c:	00078713          	mv	a4,a5
    80200830:	02b00793          	li	a5,43
    80200834:	00f71863          	bne	a4,a5,80200844 <strtol+0xa8>
        p++;
    80200838:	fd843783          	ld	a5,-40(s0)
    8020083c:	00178793          	addi	a5,a5,1
    80200840:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    80200844:	fbc42783          	lw	a5,-68(s0)
    80200848:	0007879b          	sext.w	a5,a5
    8020084c:	06079c63          	bnez	a5,802008c4 <strtol+0x128>
        if (*p == '0') {
    80200850:	fd843783          	ld	a5,-40(s0)
    80200854:	0007c783          	lbu	a5,0(a5)
    80200858:	00078713          	mv	a4,a5
    8020085c:	03000793          	li	a5,48
    80200860:	04f71e63          	bne	a4,a5,802008bc <strtol+0x120>
            p++;
    80200864:	fd843783          	ld	a5,-40(s0)
    80200868:	00178793          	addi	a5,a5,1
    8020086c:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    80200870:	fd843783          	ld	a5,-40(s0)
    80200874:	0007c783          	lbu	a5,0(a5)
    80200878:	00078713          	mv	a4,a5
    8020087c:	07800793          	li	a5,120
    80200880:	00f70c63          	beq	a4,a5,80200898 <strtol+0xfc>
    80200884:	fd843783          	ld	a5,-40(s0)
    80200888:	0007c783          	lbu	a5,0(a5)
    8020088c:	00078713          	mv	a4,a5
    80200890:	05800793          	li	a5,88
    80200894:	00f71e63          	bne	a4,a5,802008b0 <strtol+0x114>
                base = 16;
    80200898:	01000793          	li	a5,16
    8020089c:	faf42e23          	sw	a5,-68(s0)
                p++;
    802008a0:	fd843783          	ld	a5,-40(s0)
    802008a4:	00178793          	addi	a5,a5,1
    802008a8:	fcf43c23          	sd	a5,-40(s0)
    802008ac:	0180006f          	j	802008c4 <strtol+0x128>
            } else {
                base = 8;
    802008b0:	00800793          	li	a5,8
    802008b4:	faf42e23          	sw	a5,-68(s0)
    802008b8:	00c0006f          	j	802008c4 <strtol+0x128>
            }
        } else {
            base = 10;
    802008bc:	00a00793          	li	a5,10
    802008c0:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    802008c4:	fd843783          	ld	a5,-40(s0)
    802008c8:	0007c783          	lbu	a5,0(a5)
    802008cc:	00078713          	mv	a4,a5
    802008d0:	02f00793          	li	a5,47
    802008d4:	02e7f863          	bgeu	a5,a4,80200904 <strtol+0x168>
    802008d8:	fd843783          	ld	a5,-40(s0)
    802008dc:	0007c783          	lbu	a5,0(a5)
    802008e0:	00078713          	mv	a4,a5
    802008e4:	03900793          	li	a5,57
    802008e8:	00e7ee63          	bltu	a5,a4,80200904 <strtol+0x168>
            digit = *p - '0';
    802008ec:	fd843783          	ld	a5,-40(s0)
    802008f0:	0007c783          	lbu	a5,0(a5)
    802008f4:	0007879b          	sext.w	a5,a5
    802008f8:	fd07879b          	addiw	a5,a5,-48
    802008fc:	fcf42a23          	sw	a5,-44(s0)
    80200900:	0800006f          	j	80200980 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    80200904:	fd843783          	ld	a5,-40(s0)
    80200908:	0007c783          	lbu	a5,0(a5)
    8020090c:	00078713          	mv	a4,a5
    80200910:	06000793          	li	a5,96
    80200914:	02e7f863          	bgeu	a5,a4,80200944 <strtol+0x1a8>
    80200918:	fd843783          	ld	a5,-40(s0)
    8020091c:	0007c783          	lbu	a5,0(a5)
    80200920:	00078713          	mv	a4,a5
    80200924:	07a00793          	li	a5,122
    80200928:	00e7ee63          	bltu	a5,a4,80200944 <strtol+0x1a8>
            digit = *p - ('a' - 10);
    8020092c:	fd843783          	ld	a5,-40(s0)
    80200930:	0007c783          	lbu	a5,0(a5)
    80200934:	0007879b          	sext.w	a5,a5
    80200938:	fa97879b          	addiw	a5,a5,-87
    8020093c:	fcf42a23          	sw	a5,-44(s0)
    80200940:	0400006f          	j	80200980 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    80200944:	fd843783          	ld	a5,-40(s0)
    80200948:	0007c783          	lbu	a5,0(a5)
    8020094c:	00078713          	mv	a4,a5
    80200950:	04000793          	li	a5,64
    80200954:	06e7f863          	bgeu	a5,a4,802009c4 <strtol+0x228>
    80200958:	fd843783          	ld	a5,-40(s0)
    8020095c:	0007c783          	lbu	a5,0(a5)
    80200960:	00078713          	mv	a4,a5
    80200964:	05a00793          	li	a5,90
    80200968:	04e7ee63          	bltu	a5,a4,802009c4 <strtol+0x228>
            digit = *p - ('A' - 10);
    8020096c:	fd843783          	ld	a5,-40(s0)
    80200970:	0007c783          	lbu	a5,0(a5)
    80200974:	0007879b          	sext.w	a5,a5
    80200978:	fc97879b          	addiw	a5,a5,-55
    8020097c:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    80200980:	fd442783          	lw	a5,-44(s0)
    80200984:	00078713          	mv	a4,a5
    80200988:	fbc42783          	lw	a5,-68(s0)
    8020098c:	0007071b          	sext.w	a4,a4
    80200990:	0007879b          	sext.w	a5,a5
    80200994:	02f75663          	bge	a4,a5,802009c0 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
    80200998:	fbc42703          	lw	a4,-68(s0)
    8020099c:	fe843783          	ld	a5,-24(s0)
    802009a0:	02f70733          	mul	a4,a4,a5
    802009a4:	fd442783          	lw	a5,-44(s0)
    802009a8:	00f707b3          	add	a5,a4,a5
    802009ac:	fef43423          	sd	a5,-24(s0)
        p++;
    802009b0:	fd843783          	ld	a5,-40(s0)
    802009b4:	00178793          	addi	a5,a5,1
    802009b8:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    802009bc:	f09ff06f          	j	802008c4 <strtol+0x128>
            break;
    802009c0:	00000013          	nop
    }

    if (endptr) {
    802009c4:	fc043783          	ld	a5,-64(s0)
    802009c8:	00078863          	beqz	a5,802009d8 <strtol+0x23c>
        *endptr = (char *)p;
    802009cc:	fc043783          	ld	a5,-64(s0)
    802009d0:	fd843703          	ld	a4,-40(s0)
    802009d4:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    802009d8:	fe744783          	lbu	a5,-25(s0)
    802009dc:	0ff7f793          	zext.b	a5,a5
    802009e0:	00078863          	beqz	a5,802009f0 <strtol+0x254>
    802009e4:	fe843783          	ld	a5,-24(s0)
    802009e8:	40f007b3          	neg	a5,a5
    802009ec:	0080006f          	j	802009f4 <strtol+0x258>
    802009f0:	fe843783          	ld	a5,-24(s0)
}
    802009f4:	00078513          	mv	a0,a5
    802009f8:	04813083          	ld	ra,72(sp)
    802009fc:	04013403          	ld	s0,64(sp)
    80200a00:	05010113          	addi	sp,sp,80
    80200a04:	00008067          	ret

0000000080200a08 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    80200a08:	fd010113          	addi	sp,sp,-48
    80200a0c:	02113423          	sd	ra,40(sp)
    80200a10:	02813023          	sd	s0,32(sp)
    80200a14:	03010413          	addi	s0,sp,48
    80200a18:	fca43c23          	sd	a0,-40(s0)
    80200a1c:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    80200a20:	fd043783          	ld	a5,-48(s0)
    80200a24:	00079863          	bnez	a5,80200a34 <puts_wo_nl+0x2c>
        s = "(null)";
    80200a28:	00001797          	auipc	a5,0x1
    80200a2c:	69078793          	addi	a5,a5,1680 # 802020b8 <_srodata+0xb8>
    80200a30:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    80200a34:	fd043783          	ld	a5,-48(s0)
    80200a38:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    80200a3c:	0240006f          	j	80200a60 <puts_wo_nl+0x58>
        putch(*p++);
    80200a40:	fe843783          	ld	a5,-24(s0)
    80200a44:	00178713          	addi	a4,a5,1
    80200a48:	fee43423          	sd	a4,-24(s0)
    80200a4c:	0007c783          	lbu	a5,0(a5)
    80200a50:	0007871b          	sext.w	a4,a5
    80200a54:	fd843783          	ld	a5,-40(s0)
    80200a58:	00070513          	mv	a0,a4
    80200a5c:	000780e7          	jalr	a5
    while (*p) {
    80200a60:	fe843783          	ld	a5,-24(s0)
    80200a64:	0007c783          	lbu	a5,0(a5)
    80200a68:	fc079ce3          	bnez	a5,80200a40 <puts_wo_nl+0x38>
    }
    return p - s;
    80200a6c:	fe843703          	ld	a4,-24(s0)
    80200a70:	fd043783          	ld	a5,-48(s0)
    80200a74:	40f707b3          	sub	a5,a4,a5
    80200a78:	0007879b          	sext.w	a5,a5
}
    80200a7c:	00078513          	mv	a0,a5
    80200a80:	02813083          	ld	ra,40(sp)
    80200a84:	02013403          	ld	s0,32(sp)
    80200a88:	03010113          	addi	sp,sp,48
    80200a8c:	00008067          	ret

0000000080200a90 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    80200a90:	f9010113          	addi	sp,sp,-112
    80200a94:	06113423          	sd	ra,104(sp)
    80200a98:	06813023          	sd	s0,96(sp)
    80200a9c:	07010413          	addi	s0,sp,112
    80200aa0:	faa43423          	sd	a0,-88(s0)
    80200aa4:	fab43023          	sd	a1,-96(s0)
    80200aa8:	00060793          	mv	a5,a2
    80200aac:	f8d43823          	sd	a3,-112(s0)
    80200ab0:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    80200ab4:	f9f44783          	lbu	a5,-97(s0)
    80200ab8:	0ff7f793          	zext.b	a5,a5
    80200abc:	02078663          	beqz	a5,80200ae8 <print_dec_int+0x58>
    80200ac0:	fa043703          	ld	a4,-96(s0)
    80200ac4:	fff00793          	li	a5,-1
    80200ac8:	03f79793          	slli	a5,a5,0x3f
    80200acc:	00f71e63          	bne	a4,a5,80200ae8 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    80200ad0:	00001597          	auipc	a1,0x1
    80200ad4:	5f058593          	addi	a1,a1,1520 # 802020c0 <_srodata+0xc0>
    80200ad8:	fa843503          	ld	a0,-88(s0)
    80200adc:	f2dff0ef          	jal	80200a08 <puts_wo_nl>
    80200ae0:	00050793          	mv	a5,a0
    80200ae4:	2a00006f          	j	80200d84 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
    80200ae8:	f9043783          	ld	a5,-112(s0)
    80200aec:	00c7a783          	lw	a5,12(a5)
    80200af0:	00079a63          	bnez	a5,80200b04 <print_dec_int+0x74>
    80200af4:	fa043783          	ld	a5,-96(s0)
    80200af8:	00079663          	bnez	a5,80200b04 <print_dec_int+0x74>
        return 0;
    80200afc:	00000793          	li	a5,0
    80200b00:	2840006f          	j	80200d84 <print_dec_int+0x2f4>
    }

    bool neg = false;
    80200b04:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    80200b08:	f9f44783          	lbu	a5,-97(s0)
    80200b0c:	0ff7f793          	zext.b	a5,a5
    80200b10:	02078063          	beqz	a5,80200b30 <print_dec_int+0xa0>
    80200b14:	fa043783          	ld	a5,-96(s0)
    80200b18:	0007dc63          	bgez	a5,80200b30 <print_dec_int+0xa0>
        neg = true;
    80200b1c:	00100793          	li	a5,1
    80200b20:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    80200b24:	fa043783          	ld	a5,-96(s0)
    80200b28:	40f007b3          	neg	a5,a5
    80200b2c:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    80200b30:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    80200b34:	f9f44783          	lbu	a5,-97(s0)
    80200b38:	0ff7f793          	zext.b	a5,a5
    80200b3c:	02078863          	beqz	a5,80200b6c <print_dec_int+0xdc>
    80200b40:	fef44783          	lbu	a5,-17(s0)
    80200b44:	0ff7f793          	zext.b	a5,a5
    80200b48:	00079e63          	bnez	a5,80200b64 <print_dec_int+0xd4>
    80200b4c:	f9043783          	ld	a5,-112(s0)
    80200b50:	0057c783          	lbu	a5,5(a5)
    80200b54:	00079863          	bnez	a5,80200b64 <print_dec_int+0xd4>
    80200b58:	f9043783          	ld	a5,-112(s0)
    80200b5c:	0047c783          	lbu	a5,4(a5)
    80200b60:	00078663          	beqz	a5,80200b6c <print_dec_int+0xdc>
    80200b64:	00100793          	li	a5,1
    80200b68:	0080006f          	j	80200b70 <print_dec_int+0xe0>
    80200b6c:	00000793          	li	a5,0
    80200b70:	fcf40ba3          	sb	a5,-41(s0)
    80200b74:	fd744783          	lbu	a5,-41(s0)
    80200b78:	0017f793          	andi	a5,a5,1
    80200b7c:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    80200b80:	fa043703          	ld	a4,-96(s0)
    80200b84:	00a00793          	li	a5,10
    80200b88:	02f777b3          	remu	a5,a4,a5
    80200b8c:	0ff7f713          	zext.b	a4,a5
    80200b90:	fe842783          	lw	a5,-24(s0)
    80200b94:	0017869b          	addiw	a3,a5,1
    80200b98:	fed42423          	sw	a3,-24(s0)
    80200b9c:	0307071b          	addiw	a4,a4,48
    80200ba0:	0ff77713          	zext.b	a4,a4
    80200ba4:	ff078793          	addi	a5,a5,-16
    80200ba8:	008787b3          	add	a5,a5,s0
    80200bac:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    80200bb0:	fa043703          	ld	a4,-96(s0)
    80200bb4:	00a00793          	li	a5,10
    80200bb8:	02f757b3          	divu	a5,a4,a5
    80200bbc:	faf43023          	sd	a5,-96(s0)
    } while (num);
    80200bc0:	fa043783          	ld	a5,-96(s0)
    80200bc4:	fa079ee3          	bnez	a5,80200b80 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    80200bc8:	f9043783          	ld	a5,-112(s0)
    80200bcc:	00c7a783          	lw	a5,12(a5)
    80200bd0:	00078713          	mv	a4,a5
    80200bd4:	fff00793          	li	a5,-1
    80200bd8:	02f71063          	bne	a4,a5,80200bf8 <print_dec_int+0x168>
    80200bdc:	f9043783          	ld	a5,-112(s0)
    80200be0:	0037c783          	lbu	a5,3(a5)
    80200be4:	00078a63          	beqz	a5,80200bf8 <print_dec_int+0x168>
        flags->prec = flags->width;
    80200be8:	f9043783          	ld	a5,-112(s0)
    80200bec:	0087a703          	lw	a4,8(a5)
    80200bf0:	f9043783          	ld	a5,-112(s0)
    80200bf4:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    80200bf8:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200bfc:	f9043783          	ld	a5,-112(s0)
    80200c00:	0087a703          	lw	a4,8(a5)
    80200c04:	fe842783          	lw	a5,-24(s0)
    80200c08:	fcf42823          	sw	a5,-48(s0)
    80200c0c:	f9043783          	ld	a5,-112(s0)
    80200c10:	00c7a783          	lw	a5,12(a5)
    80200c14:	fcf42623          	sw	a5,-52(s0)
    80200c18:	fd042783          	lw	a5,-48(s0)
    80200c1c:	00078593          	mv	a1,a5
    80200c20:	fcc42783          	lw	a5,-52(s0)
    80200c24:	00078613          	mv	a2,a5
    80200c28:	0006069b          	sext.w	a3,a2
    80200c2c:	0005879b          	sext.w	a5,a1
    80200c30:	00f6d463          	bge	a3,a5,80200c38 <print_dec_int+0x1a8>
    80200c34:	00058613          	mv	a2,a1
    80200c38:	0006079b          	sext.w	a5,a2
    80200c3c:	40f707bb          	subw	a5,a4,a5
    80200c40:	0007871b          	sext.w	a4,a5
    80200c44:	fd744783          	lbu	a5,-41(s0)
    80200c48:	0007879b          	sext.w	a5,a5
    80200c4c:	40f707bb          	subw	a5,a4,a5
    80200c50:	fef42023          	sw	a5,-32(s0)
    80200c54:	0280006f          	j	80200c7c <print_dec_int+0x1ec>
        putch(' ');
    80200c58:	fa843783          	ld	a5,-88(s0)
    80200c5c:	02000513          	li	a0,32
    80200c60:	000780e7          	jalr	a5
        ++written;
    80200c64:	fe442783          	lw	a5,-28(s0)
    80200c68:	0017879b          	addiw	a5,a5,1
    80200c6c:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200c70:	fe042783          	lw	a5,-32(s0)
    80200c74:	fff7879b          	addiw	a5,a5,-1
    80200c78:	fef42023          	sw	a5,-32(s0)
    80200c7c:	fe042783          	lw	a5,-32(s0)
    80200c80:	0007879b          	sext.w	a5,a5
    80200c84:	fcf04ae3          	bgtz	a5,80200c58 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
    80200c88:	fd744783          	lbu	a5,-41(s0)
    80200c8c:	0ff7f793          	zext.b	a5,a5
    80200c90:	04078463          	beqz	a5,80200cd8 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    80200c94:	fef44783          	lbu	a5,-17(s0)
    80200c98:	0ff7f793          	zext.b	a5,a5
    80200c9c:	00078663          	beqz	a5,80200ca8 <print_dec_int+0x218>
    80200ca0:	02d00793          	li	a5,45
    80200ca4:	01c0006f          	j	80200cc0 <print_dec_int+0x230>
    80200ca8:	f9043783          	ld	a5,-112(s0)
    80200cac:	0057c783          	lbu	a5,5(a5)
    80200cb0:	00078663          	beqz	a5,80200cbc <print_dec_int+0x22c>
    80200cb4:	02b00793          	li	a5,43
    80200cb8:	0080006f          	j	80200cc0 <print_dec_int+0x230>
    80200cbc:	02000793          	li	a5,32
    80200cc0:	fa843703          	ld	a4,-88(s0)
    80200cc4:	00078513          	mv	a0,a5
    80200cc8:	000700e7          	jalr	a4
        ++written;
    80200ccc:	fe442783          	lw	a5,-28(s0)
    80200cd0:	0017879b          	addiw	a5,a5,1
    80200cd4:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200cd8:	fe842783          	lw	a5,-24(s0)
    80200cdc:	fcf42e23          	sw	a5,-36(s0)
    80200ce0:	0280006f          	j	80200d08 <print_dec_int+0x278>
        putch('0');
    80200ce4:	fa843783          	ld	a5,-88(s0)
    80200ce8:	03000513          	li	a0,48
    80200cec:	000780e7          	jalr	a5
        ++written;
    80200cf0:	fe442783          	lw	a5,-28(s0)
    80200cf4:	0017879b          	addiw	a5,a5,1
    80200cf8:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200cfc:	fdc42783          	lw	a5,-36(s0)
    80200d00:	0017879b          	addiw	a5,a5,1
    80200d04:	fcf42e23          	sw	a5,-36(s0)
    80200d08:	f9043783          	ld	a5,-112(s0)
    80200d0c:	00c7a703          	lw	a4,12(a5)
    80200d10:	fd744783          	lbu	a5,-41(s0)
    80200d14:	0007879b          	sext.w	a5,a5
    80200d18:	40f707bb          	subw	a5,a4,a5
    80200d1c:	0007871b          	sext.w	a4,a5
    80200d20:	fdc42783          	lw	a5,-36(s0)
    80200d24:	0007879b          	sext.w	a5,a5
    80200d28:	fae7cee3          	blt	a5,a4,80200ce4 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80200d2c:	fe842783          	lw	a5,-24(s0)
    80200d30:	fff7879b          	addiw	a5,a5,-1
    80200d34:	fcf42c23          	sw	a5,-40(s0)
    80200d38:	03c0006f          	j	80200d74 <print_dec_int+0x2e4>
        putch(buf[i]);
    80200d3c:	fd842783          	lw	a5,-40(s0)
    80200d40:	ff078793          	addi	a5,a5,-16
    80200d44:	008787b3          	add	a5,a5,s0
    80200d48:	fc87c783          	lbu	a5,-56(a5)
    80200d4c:	0007871b          	sext.w	a4,a5
    80200d50:	fa843783          	ld	a5,-88(s0)
    80200d54:	00070513          	mv	a0,a4
    80200d58:	000780e7          	jalr	a5
        ++written;
    80200d5c:	fe442783          	lw	a5,-28(s0)
    80200d60:	0017879b          	addiw	a5,a5,1
    80200d64:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    80200d68:	fd842783          	lw	a5,-40(s0)
    80200d6c:	fff7879b          	addiw	a5,a5,-1
    80200d70:	fcf42c23          	sw	a5,-40(s0)
    80200d74:	fd842783          	lw	a5,-40(s0)
    80200d78:	0007879b          	sext.w	a5,a5
    80200d7c:	fc07d0e3          	bgez	a5,80200d3c <print_dec_int+0x2ac>
    }

    return written;
    80200d80:	fe442783          	lw	a5,-28(s0)
}
    80200d84:	00078513          	mv	a0,a5
    80200d88:	06813083          	ld	ra,104(sp)
    80200d8c:	06013403          	ld	s0,96(sp)
    80200d90:	07010113          	addi	sp,sp,112
    80200d94:	00008067          	ret

0000000080200d98 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    80200d98:	f4010113          	addi	sp,sp,-192
    80200d9c:	0a113c23          	sd	ra,184(sp)
    80200da0:	0a813823          	sd	s0,176(sp)
    80200da4:	0c010413          	addi	s0,sp,192
    80200da8:	f4a43c23          	sd	a0,-168(s0)
    80200dac:	f4b43823          	sd	a1,-176(s0)
    80200db0:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    80200db4:	f8043023          	sd	zero,-128(s0)
    80200db8:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    80200dbc:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    80200dc0:	7a40006f          	j	80201564 <vprintfmt+0x7cc>
        if (flags.in_format) {
    80200dc4:	f8044783          	lbu	a5,-128(s0)
    80200dc8:	72078e63          	beqz	a5,80201504 <vprintfmt+0x76c>
            if (*fmt == '#') {
    80200dcc:	f5043783          	ld	a5,-176(s0)
    80200dd0:	0007c783          	lbu	a5,0(a5)
    80200dd4:	00078713          	mv	a4,a5
    80200dd8:	02300793          	li	a5,35
    80200ddc:	00f71863          	bne	a4,a5,80200dec <vprintfmt+0x54>
                flags.sharpflag = true;
    80200de0:	00100793          	li	a5,1
    80200de4:	f8f40123          	sb	a5,-126(s0)
    80200de8:	7700006f          	j	80201558 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    80200dec:	f5043783          	ld	a5,-176(s0)
    80200df0:	0007c783          	lbu	a5,0(a5)
    80200df4:	00078713          	mv	a4,a5
    80200df8:	03000793          	li	a5,48
    80200dfc:	00f71863          	bne	a4,a5,80200e0c <vprintfmt+0x74>
                flags.zeroflag = true;
    80200e00:	00100793          	li	a5,1
    80200e04:	f8f401a3          	sb	a5,-125(s0)
    80200e08:	7500006f          	j	80201558 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    80200e0c:	f5043783          	ld	a5,-176(s0)
    80200e10:	0007c783          	lbu	a5,0(a5)
    80200e14:	00078713          	mv	a4,a5
    80200e18:	06c00793          	li	a5,108
    80200e1c:	04f70063          	beq	a4,a5,80200e5c <vprintfmt+0xc4>
    80200e20:	f5043783          	ld	a5,-176(s0)
    80200e24:	0007c783          	lbu	a5,0(a5)
    80200e28:	00078713          	mv	a4,a5
    80200e2c:	07a00793          	li	a5,122
    80200e30:	02f70663          	beq	a4,a5,80200e5c <vprintfmt+0xc4>
    80200e34:	f5043783          	ld	a5,-176(s0)
    80200e38:	0007c783          	lbu	a5,0(a5)
    80200e3c:	00078713          	mv	a4,a5
    80200e40:	07400793          	li	a5,116
    80200e44:	00f70c63          	beq	a4,a5,80200e5c <vprintfmt+0xc4>
    80200e48:	f5043783          	ld	a5,-176(s0)
    80200e4c:	0007c783          	lbu	a5,0(a5)
    80200e50:	00078713          	mv	a4,a5
    80200e54:	06a00793          	li	a5,106
    80200e58:	00f71863          	bne	a4,a5,80200e68 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80200e5c:	00100793          	li	a5,1
    80200e60:	f8f400a3          	sb	a5,-127(s0)
    80200e64:	6f40006f          	j	80201558 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    80200e68:	f5043783          	ld	a5,-176(s0)
    80200e6c:	0007c783          	lbu	a5,0(a5)
    80200e70:	00078713          	mv	a4,a5
    80200e74:	02b00793          	li	a5,43
    80200e78:	00f71863          	bne	a4,a5,80200e88 <vprintfmt+0xf0>
                flags.sign = true;
    80200e7c:	00100793          	li	a5,1
    80200e80:	f8f402a3          	sb	a5,-123(s0)
    80200e84:	6d40006f          	j	80201558 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    80200e88:	f5043783          	ld	a5,-176(s0)
    80200e8c:	0007c783          	lbu	a5,0(a5)
    80200e90:	00078713          	mv	a4,a5
    80200e94:	02000793          	li	a5,32
    80200e98:	00f71863          	bne	a4,a5,80200ea8 <vprintfmt+0x110>
                flags.spaceflag = true;
    80200e9c:	00100793          	li	a5,1
    80200ea0:	f8f40223          	sb	a5,-124(s0)
    80200ea4:	6b40006f          	j	80201558 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    80200ea8:	f5043783          	ld	a5,-176(s0)
    80200eac:	0007c783          	lbu	a5,0(a5)
    80200eb0:	00078713          	mv	a4,a5
    80200eb4:	02a00793          	li	a5,42
    80200eb8:	00f71e63          	bne	a4,a5,80200ed4 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    80200ebc:	f4843783          	ld	a5,-184(s0)
    80200ec0:	00878713          	addi	a4,a5,8
    80200ec4:	f4e43423          	sd	a4,-184(s0)
    80200ec8:	0007a783          	lw	a5,0(a5)
    80200ecc:	f8f42423          	sw	a5,-120(s0)
    80200ed0:	6880006f          	j	80201558 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    80200ed4:	f5043783          	ld	a5,-176(s0)
    80200ed8:	0007c783          	lbu	a5,0(a5)
    80200edc:	00078713          	mv	a4,a5
    80200ee0:	03000793          	li	a5,48
    80200ee4:	04e7f663          	bgeu	a5,a4,80200f30 <vprintfmt+0x198>
    80200ee8:	f5043783          	ld	a5,-176(s0)
    80200eec:	0007c783          	lbu	a5,0(a5)
    80200ef0:	00078713          	mv	a4,a5
    80200ef4:	03900793          	li	a5,57
    80200ef8:	02e7ec63          	bltu	a5,a4,80200f30 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    80200efc:	f5043783          	ld	a5,-176(s0)
    80200f00:	f5040713          	addi	a4,s0,-176
    80200f04:	00a00613          	li	a2,10
    80200f08:	00070593          	mv	a1,a4
    80200f0c:	00078513          	mv	a0,a5
    80200f10:	88dff0ef          	jal	8020079c <strtol>
    80200f14:	00050793          	mv	a5,a0
    80200f18:	0007879b          	sext.w	a5,a5
    80200f1c:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    80200f20:	f5043783          	ld	a5,-176(s0)
    80200f24:	fff78793          	addi	a5,a5,-1
    80200f28:	f4f43823          	sd	a5,-176(s0)
    80200f2c:	62c0006f          	j	80201558 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80200f30:	f5043783          	ld	a5,-176(s0)
    80200f34:	0007c783          	lbu	a5,0(a5)
    80200f38:	00078713          	mv	a4,a5
    80200f3c:	02e00793          	li	a5,46
    80200f40:	06f71863          	bne	a4,a5,80200fb0 <vprintfmt+0x218>
                fmt++;
    80200f44:	f5043783          	ld	a5,-176(s0)
    80200f48:	00178793          	addi	a5,a5,1
    80200f4c:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80200f50:	f5043783          	ld	a5,-176(s0)
    80200f54:	0007c783          	lbu	a5,0(a5)
    80200f58:	00078713          	mv	a4,a5
    80200f5c:	02a00793          	li	a5,42
    80200f60:	00f71e63          	bne	a4,a5,80200f7c <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80200f64:	f4843783          	ld	a5,-184(s0)
    80200f68:	00878713          	addi	a4,a5,8
    80200f6c:	f4e43423          	sd	a4,-184(s0)
    80200f70:	0007a783          	lw	a5,0(a5)
    80200f74:	f8f42623          	sw	a5,-116(s0)
    80200f78:	5e00006f          	j	80201558 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    80200f7c:	f5043783          	ld	a5,-176(s0)
    80200f80:	f5040713          	addi	a4,s0,-176
    80200f84:	00a00613          	li	a2,10
    80200f88:	00070593          	mv	a1,a4
    80200f8c:	00078513          	mv	a0,a5
    80200f90:	80dff0ef          	jal	8020079c <strtol>
    80200f94:	00050793          	mv	a5,a0
    80200f98:	0007879b          	sext.w	a5,a5
    80200f9c:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    80200fa0:	f5043783          	ld	a5,-176(s0)
    80200fa4:	fff78793          	addi	a5,a5,-1
    80200fa8:	f4f43823          	sd	a5,-176(s0)
    80200fac:	5ac0006f          	j	80201558 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80200fb0:	f5043783          	ld	a5,-176(s0)
    80200fb4:	0007c783          	lbu	a5,0(a5)
    80200fb8:	00078713          	mv	a4,a5
    80200fbc:	07800793          	li	a5,120
    80200fc0:	02f70663          	beq	a4,a5,80200fec <vprintfmt+0x254>
    80200fc4:	f5043783          	ld	a5,-176(s0)
    80200fc8:	0007c783          	lbu	a5,0(a5)
    80200fcc:	00078713          	mv	a4,a5
    80200fd0:	05800793          	li	a5,88
    80200fd4:	00f70c63          	beq	a4,a5,80200fec <vprintfmt+0x254>
    80200fd8:	f5043783          	ld	a5,-176(s0)
    80200fdc:	0007c783          	lbu	a5,0(a5)
    80200fe0:	00078713          	mv	a4,a5
    80200fe4:	07000793          	li	a5,112
    80200fe8:	30f71263          	bne	a4,a5,802012ec <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
    80200fec:	f5043783          	ld	a5,-176(s0)
    80200ff0:	0007c783          	lbu	a5,0(a5)
    80200ff4:	00078713          	mv	a4,a5
    80200ff8:	07000793          	li	a5,112
    80200ffc:	00f70663          	beq	a4,a5,80201008 <vprintfmt+0x270>
    80201000:	f8144783          	lbu	a5,-127(s0)
    80201004:	00078663          	beqz	a5,80201010 <vprintfmt+0x278>
    80201008:	00100793          	li	a5,1
    8020100c:	0080006f          	j	80201014 <vprintfmt+0x27c>
    80201010:	00000793          	li	a5,0
    80201014:	faf403a3          	sb	a5,-89(s0)
    80201018:	fa744783          	lbu	a5,-89(s0)
    8020101c:	0017f793          	andi	a5,a5,1
    80201020:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    80201024:	fa744783          	lbu	a5,-89(s0)
    80201028:	0ff7f793          	zext.b	a5,a5
    8020102c:	00078c63          	beqz	a5,80201044 <vprintfmt+0x2ac>
    80201030:	f4843783          	ld	a5,-184(s0)
    80201034:	00878713          	addi	a4,a5,8
    80201038:	f4e43423          	sd	a4,-184(s0)
    8020103c:	0007b783          	ld	a5,0(a5)
    80201040:	01c0006f          	j	8020105c <vprintfmt+0x2c4>
    80201044:	f4843783          	ld	a5,-184(s0)
    80201048:	00878713          	addi	a4,a5,8
    8020104c:	f4e43423          	sd	a4,-184(s0)
    80201050:	0007a783          	lw	a5,0(a5)
    80201054:	02079793          	slli	a5,a5,0x20
    80201058:	0207d793          	srli	a5,a5,0x20
    8020105c:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80201060:	f8c42783          	lw	a5,-116(s0)
    80201064:	02079463          	bnez	a5,8020108c <vprintfmt+0x2f4>
    80201068:	fe043783          	ld	a5,-32(s0)
    8020106c:	02079063          	bnez	a5,8020108c <vprintfmt+0x2f4>
    80201070:	f5043783          	ld	a5,-176(s0)
    80201074:	0007c783          	lbu	a5,0(a5)
    80201078:	00078713          	mv	a4,a5
    8020107c:	07000793          	li	a5,112
    80201080:	00f70663          	beq	a4,a5,8020108c <vprintfmt+0x2f4>
                    flags.in_format = false;
    80201084:	f8040023          	sb	zero,-128(s0)
    80201088:	4d00006f          	j	80201558 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    8020108c:	f5043783          	ld	a5,-176(s0)
    80201090:	0007c783          	lbu	a5,0(a5)
    80201094:	00078713          	mv	a4,a5
    80201098:	07000793          	li	a5,112
    8020109c:	00f70a63          	beq	a4,a5,802010b0 <vprintfmt+0x318>
    802010a0:	f8244783          	lbu	a5,-126(s0)
    802010a4:	00078a63          	beqz	a5,802010b8 <vprintfmt+0x320>
    802010a8:	fe043783          	ld	a5,-32(s0)
    802010ac:	00078663          	beqz	a5,802010b8 <vprintfmt+0x320>
    802010b0:	00100793          	li	a5,1
    802010b4:	0080006f          	j	802010bc <vprintfmt+0x324>
    802010b8:	00000793          	li	a5,0
    802010bc:	faf40323          	sb	a5,-90(s0)
    802010c0:	fa644783          	lbu	a5,-90(s0)
    802010c4:	0017f793          	andi	a5,a5,1
    802010c8:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    802010cc:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    802010d0:	f5043783          	ld	a5,-176(s0)
    802010d4:	0007c783          	lbu	a5,0(a5)
    802010d8:	00078713          	mv	a4,a5
    802010dc:	05800793          	li	a5,88
    802010e0:	00f71863          	bne	a4,a5,802010f0 <vprintfmt+0x358>
    802010e4:	00001797          	auipc	a5,0x1
    802010e8:	ff478793          	addi	a5,a5,-12 # 802020d8 <upperxdigits.1>
    802010ec:	00c0006f          	j	802010f8 <vprintfmt+0x360>
    802010f0:	00001797          	auipc	a5,0x1
    802010f4:	00078793          	mv	a5,a5
    802010f8:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    802010fc:	fe043783          	ld	a5,-32(s0)
    80201100:	00f7f793          	andi	a5,a5,15
    80201104:	f9843703          	ld	a4,-104(s0)
    80201108:	00f70733          	add	a4,a4,a5
    8020110c:	fdc42783          	lw	a5,-36(s0)
    80201110:	0017869b          	addiw	a3,a5,1 # ffffffff802020f1 <_ebss+0xfffffffeffffd0f1>
    80201114:	fcd42e23          	sw	a3,-36(s0)
    80201118:	00074703          	lbu	a4,0(a4)
    8020111c:	ff078793          	addi	a5,a5,-16
    80201120:	008787b3          	add	a5,a5,s0
    80201124:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    80201128:	fe043783          	ld	a5,-32(s0)
    8020112c:	0047d793          	srli	a5,a5,0x4
    80201130:	fef43023          	sd	a5,-32(s0)
                } while (num);
    80201134:	fe043783          	ld	a5,-32(s0)
    80201138:	fc0792e3          	bnez	a5,802010fc <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    8020113c:	f8c42783          	lw	a5,-116(s0)
    80201140:	00078713          	mv	a4,a5
    80201144:	fff00793          	li	a5,-1
    80201148:	02f71663          	bne	a4,a5,80201174 <vprintfmt+0x3dc>
    8020114c:	f8344783          	lbu	a5,-125(s0)
    80201150:	02078263          	beqz	a5,80201174 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    80201154:	f8842703          	lw	a4,-120(s0)
    80201158:	fa644783          	lbu	a5,-90(s0)
    8020115c:	0007879b          	sext.w	a5,a5
    80201160:	0017979b          	slliw	a5,a5,0x1
    80201164:	0007879b          	sext.w	a5,a5
    80201168:	40f707bb          	subw	a5,a4,a5
    8020116c:	0007879b          	sext.w	a5,a5
    80201170:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201174:	f8842703          	lw	a4,-120(s0)
    80201178:	fa644783          	lbu	a5,-90(s0)
    8020117c:	0007879b          	sext.w	a5,a5
    80201180:	0017979b          	slliw	a5,a5,0x1
    80201184:	0007879b          	sext.w	a5,a5
    80201188:	40f707bb          	subw	a5,a4,a5
    8020118c:	0007871b          	sext.w	a4,a5
    80201190:	fdc42783          	lw	a5,-36(s0)
    80201194:	f8f42a23          	sw	a5,-108(s0)
    80201198:	f8c42783          	lw	a5,-116(s0)
    8020119c:	f8f42823          	sw	a5,-112(s0)
    802011a0:	f9442783          	lw	a5,-108(s0)
    802011a4:	00078593          	mv	a1,a5
    802011a8:	f9042783          	lw	a5,-112(s0)
    802011ac:	00078613          	mv	a2,a5
    802011b0:	0006069b          	sext.w	a3,a2
    802011b4:	0005879b          	sext.w	a5,a1
    802011b8:	00f6d463          	bge	a3,a5,802011c0 <vprintfmt+0x428>
    802011bc:	00058613          	mv	a2,a1
    802011c0:	0006079b          	sext.w	a5,a2
    802011c4:	40f707bb          	subw	a5,a4,a5
    802011c8:	fcf42c23          	sw	a5,-40(s0)
    802011cc:	0280006f          	j	802011f4 <vprintfmt+0x45c>
                    putch(' ');
    802011d0:	f5843783          	ld	a5,-168(s0)
    802011d4:	02000513          	li	a0,32
    802011d8:	000780e7          	jalr	a5
                    ++written;
    802011dc:	fec42783          	lw	a5,-20(s0)
    802011e0:	0017879b          	addiw	a5,a5,1
    802011e4:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    802011e8:	fd842783          	lw	a5,-40(s0)
    802011ec:	fff7879b          	addiw	a5,a5,-1
    802011f0:	fcf42c23          	sw	a5,-40(s0)
    802011f4:	fd842783          	lw	a5,-40(s0)
    802011f8:	0007879b          	sext.w	a5,a5
    802011fc:	fcf04ae3          	bgtz	a5,802011d0 <vprintfmt+0x438>
                }

                if (prefix) {
    80201200:	fa644783          	lbu	a5,-90(s0)
    80201204:	0ff7f793          	zext.b	a5,a5
    80201208:	04078463          	beqz	a5,80201250 <vprintfmt+0x4b8>
                    putch('0');
    8020120c:	f5843783          	ld	a5,-168(s0)
    80201210:	03000513          	li	a0,48
    80201214:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    80201218:	f5043783          	ld	a5,-176(s0)
    8020121c:	0007c783          	lbu	a5,0(a5)
    80201220:	00078713          	mv	a4,a5
    80201224:	05800793          	li	a5,88
    80201228:	00f71663          	bne	a4,a5,80201234 <vprintfmt+0x49c>
    8020122c:	05800793          	li	a5,88
    80201230:	0080006f          	j	80201238 <vprintfmt+0x4a0>
    80201234:	07800793          	li	a5,120
    80201238:	f5843703          	ld	a4,-168(s0)
    8020123c:	00078513          	mv	a0,a5
    80201240:	000700e7          	jalr	a4
                    written += 2;
    80201244:	fec42783          	lw	a5,-20(s0)
    80201248:	0027879b          	addiw	a5,a5,2
    8020124c:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    80201250:	fdc42783          	lw	a5,-36(s0)
    80201254:	fcf42a23          	sw	a5,-44(s0)
    80201258:	0280006f          	j	80201280 <vprintfmt+0x4e8>
                    putch('0');
    8020125c:	f5843783          	ld	a5,-168(s0)
    80201260:	03000513          	li	a0,48
    80201264:	000780e7          	jalr	a5
                    ++written;
    80201268:	fec42783          	lw	a5,-20(s0)
    8020126c:	0017879b          	addiw	a5,a5,1
    80201270:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    80201274:	fd442783          	lw	a5,-44(s0)
    80201278:	0017879b          	addiw	a5,a5,1
    8020127c:	fcf42a23          	sw	a5,-44(s0)
    80201280:	f8c42703          	lw	a4,-116(s0)
    80201284:	fd442783          	lw	a5,-44(s0)
    80201288:	0007879b          	sext.w	a5,a5
    8020128c:	fce7c8e3          	blt	a5,a4,8020125c <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    80201290:	fdc42783          	lw	a5,-36(s0)
    80201294:	fff7879b          	addiw	a5,a5,-1
    80201298:	fcf42823          	sw	a5,-48(s0)
    8020129c:	03c0006f          	j	802012d8 <vprintfmt+0x540>
                    putch(buf[i]);
    802012a0:	fd042783          	lw	a5,-48(s0)
    802012a4:	ff078793          	addi	a5,a5,-16
    802012a8:	008787b3          	add	a5,a5,s0
    802012ac:	f807c783          	lbu	a5,-128(a5)
    802012b0:	0007871b          	sext.w	a4,a5
    802012b4:	f5843783          	ld	a5,-168(s0)
    802012b8:	00070513          	mv	a0,a4
    802012bc:	000780e7          	jalr	a5
                    ++written;
    802012c0:	fec42783          	lw	a5,-20(s0)
    802012c4:	0017879b          	addiw	a5,a5,1
    802012c8:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    802012cc:	fd042783          	lw	a5,-48(s0)
    802012d0:	fff7879b          	addiw	a5,a5,-1
    802012d4:	fcf42823          	sw	a5,-48(s0)
    802012d8:	fd042783          	lw	a5,-48(s0)
    802012dc:	0007879b          	sext.w	a5,a5
    802012e0:	fc07d0e3          	bgez	a5,802012a0 <vprintfmt+0x508>
                }

                flags.in_format = false;
    802012e4:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    802012e8:	2700006f          	j	80201558 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    802012ec:	f5043783          	ld	a5,-176(s0)
    802012f0:	0007c783          	lbu	a5,0(a5)
    802012f4:	00078713          	mv	a4,a5
    802012f8:	06400793          	li	a5,100
    802012fc:	02f70663          	beq	a4,a5,80201328 <vprintfmt+0x590>
    80201300:	f5043783          	ld	a5,-176(s0)
    80201304:	0007c783          	lbu	a5,0(a5)
    80201308:	00078713          	mv	a4,a5
    8020130c:	06900793          	li	a5,105
    80201310:	00f70c63          	beq	a4,a5,80201328 <vprintfmt+0x590>
    80201314:	f5043783          	ld	a5,-176(s0)
    80201318:	0007c783          	lbu	a5,0(a5)
    8020131c:	00078713          	mv	a4,a5
    80201320:	07500793          	li	a5,117
    80201324:	08f71063          	bne	a4,a5,802013a4 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    80201328:	f8144783          	lbu	a5,-127(s0)
    8020132c:	00078c63          	beqz	a5,80201344 <vprintfmt+0x5ac>
    80201330:	f4843783          	ld	a5,-184(s0)
    80201334:	00878713          	addi	a4,a5,8
    80201338:	f4e43423          	sd	a4,-184(s0)
    8020133c:	0007b783          	ld	a5,0(a5)
    80201340:	0140006f          	j	80201354 <vprintfmt+0x5bc>
    80201344:	f4843783          	ld	a5,-184(s0)
    80201348:	00878713          	addi	a4,a5,8
    8020134c:	f4e43423          	sd	a4,-184(s0)
    80201350:	0007a783          	lw	a5,0(a5)
    80201354:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    80201358:	fa843583          	ld	a1,-88(s0)
    8020135c:	f5043783          	ld	a5,-176(s0)
    80201360:	0007c783          	lbu	a5,0(a5)
    80201364:	0007871b          	sext.w	a4,a5
    80201368:	07500793          	li	a5,117
    8020136c:	40f707b3          	sub	a5,a4,a5
    80201370:	00f037b3          	snez	a5,a5
    80201374:	0ff7f793          	zext.b	a5,a5
    80201378:	f8040713          	addi	a4,s0,-128
    8020137c:	00070693          	mv	a3,a4
    80201380:	00078613          	mv	a2,a5
    80201384:	f5843503          	ld	a0,-168(s0)
    80201388:	f08ff0ef          	jal	80200a90 <print_dec_int>
    8020138c:	00050793          	mv	a5,a0
    80201390:	fec42703          	lw	a4,-20(s0)
    80201394:	00f707bb          	addw	a5,a4,a5
    80201398:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    8020139c:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    802013a0:	1b80006f          	j	80201558 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    802013a4:	f5043783          	ld	a5,-176(s0)
    802013a8:	0007c783          	lbu	a5,0(a5)
    802013ac:	00078713          	mv	a4,a5
    802013b0:	06e00793          	li	a5,110
    802013b4:	04f71c63          	bne	a4,a5,8020140c <vprintfmt+0x674>
                if (flags.longflag) {
    802013b8:	f8144783          	lbu	a5,-127(s0)
    802013bc:	02078463          	beqz	a5,802013e4 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
    802013c0:	f4843783          	ld	a5,-184(s0)
    802013c4:	00878713          	addi	a4,a5,8
    802013c8:	f4e43423          	sd	a4,-184(s0)
    802013cc:	0007b783          	ld	a5,0(a5)
    802013d0:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    802013d4:	fec42703          	lw	a4,-20(s0)
    802013d8:	fb043783          	ld	a5,-80(s0)
    802013dc:	00e7b023          	sd	a4,0(a5)
    802013e0:	0240006f          	j	80201404 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
    802013e4:	f4843783          	ld	a5,-184(s0)
    802013e8:	00878713          	addi	a4,a5,8
    802013ec:	f4e43423          	sd	a4,-184(s0)
    802013f0:	0007b783          	ld	a5,0(a5)
    802013f4:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    802013f8:	fb843783          	ld	a5,-72(s0)
    802013fc:	fec42703          	lw	a4,-20(s0)
    80201400:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    80201404:	f8040023          	sb	zero,-128(s0)
    80201408:	1500006f          	j	80201558 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    8020140c:	f5043783          	ld	a5,-176(s0)
    80201410:	0007c783          	lbu	a5,0(a5)
    80201414:	00078713          	mv	a4,a5
    80201418:	07300793          	li	a5,115
    8020141c:	02f71e63          	bne	a4,a5,80201458 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    80201420:	f4843783          	ld	a5,-184(s0)
    80201424:	00878713          	addi	a4,a5,8
    80201428:	f4e43423          	sd	a4,-184(s0)
    8020142c:	0007b783          	ld	a5,0(a5)
    80201430:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    80201434:	fc043583          	ld	a1,-64(s0)
    80201438:	f5843503          	ld	a0,-168(s0)
    8020143c:	dccff0ef          	jal	80200a08 <puts_wo_nl>
    80201440:	00050793          	mv	a5,a0
    80201444:	fec42703          	lw	a4,-20(s0)
    80201448:	00f707bb          	addw	a5,a4,a5
    8020144c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201450:	f8040023          	sb	zero,-128(s0)
    80201454:	1040006f          	j	80201558 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    80201458:	f5043783          	ld	a5,-176(s0)
    8020145c:	0007c783          	lbu	a5,0(a5)
    80201460:	00078713          	mv	a4,a5
    80201464:	06300793          	li	a5,99
    80201468:	02f71e63          	bne	a4,a5,802014a4 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    8020146c:	f4843783          	ld	a5,-184(s0)
    80201470:	00878713          	addi	a4,a5,8
    80201474:	f4e43423          	sd	a4,-184(s0)
    80201478:	0007a783          	lw	a5,0(a5)
    8020147c:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    80201480:	fcc42703          	lw	a4,-52(s0)
    80201484:	f5843783          	ld	a5,-168(s0)
    80201488:	00070513          	mv	a0,a4
    8020148c:	000780e7          	jalr	a5
                ++written;
    80201490:	fec42783          	lw	a5,-20(s0)
    80201494:	0017879b          	addiw	a5,a5,1
    80201498:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    8020149c:	f8040023          	sb	zero,-128(s0)
    802014a0:	0b80006f          	j	80201558 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    802014a4:	f5043783          	ld	a5,-176(s0)
    802014a8:	0007c783          	lbu	a5,0(a5)
    802014ac:	00078713          	mv	a4,a5
    802014b0:	02500793          	li	a5,37
    802014b4:	02f71263          	bne	a4,a5,802014d8 <vprintfmt+0x740>
                putch('%');
    802014b8:	f5843783          	ld	a5,-168(s0)
    802014bc:	02500513          	li	a0,37
    802014c0:	000780e7          	jalr	a5
                ++written;
    802014c4:	fec42783          	lw	a5,-20(s0)
    802014c8:	0017879b          	addiw	a5,a5,1
    802014cc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802014d0:	f8040023          	sb	zero,-128(s0)
    802014d4:	0840006f          	j	80201558 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    802014d8:	f5043783          	ld	a5,-176(s0)
    802014dc:	0007c783          	lbu	a5,0(a5)
    802014e0:	0007871b          	sext.w	a4,a5
    802014e4:	f5843783          	ld	a5,-168(s0)
    802014e8:	00070513          	mv	a0,a4
    802014ec:	000780e7          	jalr	a5
                ++written;
    802014f0:	fec42783          	lw	a5,-20(s0)
    802014f4:	0017879b          	addiw	a5,a5,1
    802014f8:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802014fc:	f8040023          	sb	zero,-128(s0)
    80201500:	0580006f          	j	80201558 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    80201504:	f5043783          	ld	a5,-176(s0)
    80201508:	0007c783          	lbu	a5,0(a5)
    8020150c:	00078713          	mv	a4,a5
    80201510:	02500793          	li	a5,37
    80201514:	02f71063          	bne	a4,a5,80201534 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    80201518:	f8043023          	sd	zero,-128(s0)
    8020151c:	f8043423          	sd	zero,-120(s0)
    80201520:	00100793          	li	a5,1
    80201524:	f8f40023          	sb	a5,-128(s0)
    80201528:	fff00793          	li	a5,-1
    8020152c:	f8f42623          	sw	a5,-116(s0)
    80201530:	0280006f          	j	80201558 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    80201534:	f5043783          	ld	a5,-176(s0)
    80201538:	0007c783          	lbu	a5,0(a5)
    8020153c:	0007871b          	sext.w	a4,a5
    80201540:	f5843783          	ld	a5,-168(s0)
    80201544:	00070513          	mv	a0,a4
    80201548:	000780e7          	jalr	a5
            ++written;
    8020154c:	fec42783          	lw	a5,-20(s0)
    80201550:	0017879b          	addiw	a5,a5,1
    80201554:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    80201558:	f5043783          	ld	a5,-176(s0)
    8020155c:	00178793          	addi	a5,a5,1
    80201560:	f4f43823          	sd	a5,-176(s0)
    80201564:	f5043783          	ld	a5,-176(s0)
    80201568:	0007c783          	lbu	a5,0(a5)
    8020156c:	84079ce3          	bnez	a5,80200dc4 <vprintfmt+0x2c>
        }
    }

    return written;
    80201570:	fec42783          	lw	a5,-20(s0)
}
    80201574:	00078513          	mv	a0,a5
    80201578:	0b813083          	ld	ra,184(sp)
    8020157c:	0b013403          	ld	s0,176(sp)
    80201580:	0c010113          	addi	sp,sp,192
    80201584:	00008067          	ret

0000000080201588 <printk>:

int printk(const char* s, ...) {
    80201588:	f9010113          	addi	sp,sp,-112
    8020158c:	02113423          	sd	ra,40(sp)
    80201590:	02813023          	sd	s0,32(sp)
    80201594:	03010413          	addi	s0,sp,48
    80201598:	fca43c23          	sd	a0,-40(s0)
    8020159c:	00b43423          	sd	a1,8(s0)
    802015a0:	00c43823          	sd	a2,16(s0)
    802015a4:	00d43c23          	sd	a3,24(s0)
    802015a8:	02e43023          	sd	a4,32(s0)
    802015ac:	02f43423          	sd	a5,40(s0)
    802015b0:	03043823          	sd	a6,48(s0)
    802015b4:	03143c23          	sd	a7,56(s0)
    int res = 0;
    802015b8:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    802015bc:	04040793          	addi	a5,s0,64
    802015c0:	fcf43823          	sd	a5,-48(s0)
    802015c4:	fd043783          	ld	a5,-48(s0)
    802015c8:	fc878793          	addi	a5,a5,-56
    802015cc:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    802015d0:	fe043783          	ld	a5,-32(s0)
    802015d4:	00078613          	mv	a2,a5
    802015d8:	fd843583          	ld	a1,-40(s0)
    802015dc:	fffff517          	auipc	a0,0xfffff
    802015e0:	11850513          	addi	a0,a0,280 # 802006f4 <putc>
    802015e4:	fb4ff0ef          	jal	80200d98 <vprintfmt>
    802015e8:	00050793          	mv	a5,a0
    802015ec:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    802015f0:	fec42783          	lw	a5,-20(s0)
}
    802015f4:	00078513          	mv	a0,a5
    802015f8:	02813083          	ld	ra,40(sp)
    802015fc:	02013403          	ld	s0,32(sp)
    80201600:	07010113          	addi	sp,sp,112
    80201604:	00008067          	ret
