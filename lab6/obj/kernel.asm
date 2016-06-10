
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:
.text
.globl kern_entry
kern_entry:
    # reload temperate gdt (second time) to remap all physical memory
    # virtual_addr 0~4G=linear_addr&physical_addr -KERNBASE~4G-KERNBASE 
    lgdt REALLOC(__gdtdesc)
c0100000:	0f 01 15 18 c0 12 00 	lgdtl  0x12c018
    movl $KERNEL_DS, %eax
c0100007:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010000c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010000e:	8e c0                	mov    %eax,%es
    movw %ax, %ss
c0100010:	8e d0                	mov    %eax,%ss

    ljmp $KERNEL_CS, $relocated
c0100012:	ea 19 00 10 c0 08 00 	ljmp   $0x8,$0xc0100019

c0100019 <relocated>:

relocated:

    # set ebp, esp
    movl $0x0, %ebp
c0100019:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010001e:	bc 00 c0 12 c0       	mov    $0xc012c000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c0100023:	e8 02 00 00 00       	call   c010002a <kern_init>

c0100028 <spin>:

# should never get here
spin:
    jmp spin
c0100028:	eb fe                	jmp    c0100028 <spin>

c010002a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c010002a:	55                   	push   %ebp
c010002b:	89 e5                	mov    %esp,%ebp
c010002d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100030:	ba 78 0f 1b c0       	mov    $0xc01b0f78,%edx
c0100035:	b8 d4 dd 1a c0       	mov    $0xc01addd4,%eax
c010003a:	29 c2                	sub    %eax,%edx
c010003c:	89 d0                	mov    %edx,%eax
c010003e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100042:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100049:	00 
c010004a:	c7 04 24 d4 dd 1a c0 	movl   $0xc01addd4,(%esp)
c0100051:	e8 c8 c1 00 00       	call   c010c21e <memset>

    cons_init();                // init the console
c0100056:	e8 85 16 00 00       	call   c01016e0 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c010005b:	c7 45 f4 c0 c3 10 c0 	movl   $0xc010c3c0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100062:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100065:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100069:	c7 04 24 dc c3 10 c0 	movl   $0xc010c3dc,(%esp)
c0100070:	e8 e3 02 00 00       	call   c0100358 <cprintf>

    print_kerninfo();
c0100075:	e8 0a 09 00 00       	call   c0100984 <print_kerninfo>

    grade_backtrace();
c010007a:	e8 a2 00 00 00       	call   c0100121 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010007f:	e8 1c 56 00 00       	call   c01056a0 <pmm_init>

    pic_init();                 // init interrupt controller
c0100084:	e8 35 20 00 00       	call   c01020be <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100089:	e8 ad 21 00 00       	call   c010223b <idt_init>

    vmm_init();                 // init virtual memory management
c010008e:	e8 0c 86 00 00       	call   c010869f <vmm_init>
    sched_init();               // init scheduler
c0100093:	e8 24 b3 00 00       	call   c010b3bc <sched_init>
    proc_init();                // init process table
c0100098:	e8 ad ac 00 00       	call   c010ad4a <proc_init>
    
    ide_init();                 // init ide devices
c010009d:	e8 6f 17 00 00       	call   c0101811 <ide_init>
    swap_init();                // init swap
c01000a2:	e8 d4 6c 00 00       	call   c0106d7b <swap_init>

    clock_init();               // init clock interrupt
c01000a7:	e8 ea 0d 00 00       	call   c0100e96 <clock_init>
    intr_enable();              // enable irq interrupt
c01000ac:	e8 7b 1f 00 00       	call   c010202c <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b1:	e8 53 ae 00 00       	call   c010af09 <cpu_idle>

c01000b6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b6:	55                   	push   %ebp
c01000b7:	89 e5                	mov    %esp,%ebp
c01000b9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000c3:	00 
c01000c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000cb:	00 
c01000cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000d3:	e8 f0 0c 00 00       	call   c0100dc8 <mon_backtrace>
}
c01000d8:	c9                   	leave  
c01000d9:	c3                   	ret    

c01000da <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000da:	55                   	push   %ebp
c01000db:	89 e5                	mov    %esp,%ebp
c01000dd:	53                   	push   %ebx
c01000de:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000e7:	8d 55 08             	lea    0x8(%ebp),%edx
c01000ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01000ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000f5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000f9:	89 04 24             	mov    %eax,(%esp)
c01000fc:	e8 b5 ff ff ff       	call   c01000b6 <grade_backtrace2>
}
c0100101:	83 c4 14             	add    $0x14,%esp
c0100104:	5b                   	pop    %ebx
c0100105:	5d                   	pop    %ebp
c0100106:	c3                   	ret    

c0100107 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100107:	55                   	push   %ebp
c0100108:	89 e5                	mov    %esp,%ebp
c010010a:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010010d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100110:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100114:	8b 45 08             	mov    0x8(%ebp),%eax
c0100117:	89 04 24             	mov    %eax,(%esp)
c010011a:	e8 bb ff ff ff       	call   c01000da <grade_backtrace1>
}
c010011f:	c9                   	leave  
c0100120:	c3                   	ret    

c0100121 <grade_backtrace>:

void
grade_backtrace(void) {
c0100121:	55                   	push   %ebp
c0100122:	89 e5                	mov    %esp,%ebp
c0100124:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100127:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c010012c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100133:	ff 
c0100134:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100138:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010013f:	e8 c3 ff ff ff       	call   c0100107 <grade_backtrace0>
}
c0100144:	c9                   	leave  
c0100145:	c3                   	ret    

c0100146 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100146:	55                   	push   %ebp
c0100147:	89 e5                	mov    %esp,%ebp
c0100149:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010014c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010014f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100152:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100155:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100158:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010015c:	0f b7 c0             	movzwl %ax,%eax
c010015f:	83 e0 03             	and    $0x3,%eax
c0100162:	89 c2                	mov    %eax,%edx
c0100164:	a1 e0 dd 1a c0       	mov    0xc01adde0,%eax
c0100169:	89 54 24 08          	mov    %edx,0x8(%esp)
c010016d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100171:	c7 04 24 e1 c3 10 c0 	movl   $0xc010c3e1,(%esp)
c0100178:	e8 db 01 00 00       	call   c0100358 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010017d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100181:	0f b7 d0             	movzwl %ax,%edx
c0100184:	a1 e0 dd 1a c0       	mov    0xc01adde0,%eax
c0100189:	89 54 24 08          	mov    %edx,0x8(%esp)
c010018d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100191:	c7 04 24 ef c3 10 c0 	movl   $0xc010c3ef,(%esp)
c0100198:	e8 bb 01 00 00       	call   c0100358 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010019d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a1:	0f b7 d0             	movzwl %ax,%edx
c01001a4:	a1 e0 dd 1a c0       	mov    0xc01adde0,%eax
c01001a9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b1:	c7 04 24 fd c3 10 c0 	movl   $0xc010c3fd,(%esp)
c01001b8:	e8 9b 01 00 00       	call   c0100358 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001bd:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c1:	0f b7 d0             	movzwl %ax,%edx
c01001c4:	a1 e0 dd 1a c0       	mov    0xc01adde0,%eax
c01001c9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d1:	c7 04 24 0b c4 10 c0 	movl   $0xc010c40b,(%esp)
c01001d8:	e8 7b 01 00 00       	call   c0100358 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001dd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e1:	0f b7 d0             	movzwl %ax,%edx
c01001e4:	a1 e0 dd 1a c0       	mov    0xc01adde0,%eax
c01001e9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ed:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f1:	c7 04 24 19 c4 10 c0 	movl   $0xc010c419,(%esp)
c01001f8:	e8 5b 01 00 00       	call   c0100358 <cprintf>
    round ++;
c01001fd:	a1 e0 dd 1a c0       	mov    0xc01adde0,%eax
c0100202:	83 c0 01             	add    $0x1,%eax
c0100205:	a3 e0 dd 1a c0       	mov    %eax,0xc01adde0
}
c010020a:	c9                   	leave  
c010020b:	c3                   	ret    

c010020c <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c010020c:	55                   	push   %ebp
c010020d:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010020f:	5d                   	pop    %ebp
c0100210:	c3                   	ret    

c0100211 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100211:	55                   	push   %ebp
c0100212:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100214:	5d                   	pop    %ebp
c0100215:	c3                   	ret    

c0100216 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100216:	55                   	push   %ebp
c0100217:	89 e5                	mov    %esp,%ebp
c0100219:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010021c:	e8 25 ff ff ff       	call   c0100146 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100221:	c7 04 24 28 c4 10 c0 	movl   $0xc010c428,(%esp)
c0100228:	e8 2b 01 00 00       	call   c0100358 <cprintf>
    lab1_switch_to_user();
c010022d:	e8 da ff ff ff       	call   c010020c <lab1_switch_to_user>
    lab1_print_cur_status();
c0100232:	e8 0f ff ff ff       	call   c0100146 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100237:	c7 04 24 48 c4 10 c0 	movl   $0xc010c448,(%esp)
c010023e:	e8 15 01 00 00       	call   c0100358 <cprintf>
    lab1_switch_to_kernel();
c0100243:	e8 c9 ff ff ff       	call   c0100211 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100248:	e8 f9 fe ff ff       	call   c0100146 <lab1_print_cur_status>
}
c010024d:	c9                   	leave  
c010024e:	c3                   	ret    

c010024f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010024f:	55                   	push   %ebp
c0100250:	89 e5                	mov    %esp,%ebp
c0100252:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100255:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100259:	74 13                	je     c010026e <readline+0x1f>
        cprintf("%s", prompt);
c010025b:	8b 45 08             	mov    0x8(%ebp),%eax
c010025e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100262:	c7 04 24 67 c4 10 c0 	movl   $0xc010c467,(%esp)
c0100269:	e8 ea 00 00 00       	call   c0100358 <cprintf>
    }
    int i = 0, c;
c010026e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100275:	e8 66 01 00 00       	call   c01003e0 <getchar>
c010027a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010027d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100281:	79 07                	jns    c010028a <readline+0x3b>
            return NULL;
c0100283:	b8 00 00 00 00       	mov    $0x0,%eax
c0100288:	eb 79                	jmp    c0100303 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010028a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010028e:	7e 28                	jle    c01002b8 <readline+0x69>
c0100290:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100297:	7f 1f                	jg     c01002b8 <readline+0x69>
            cputchar(c);
c0100299:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010029c:	89 04 24             	mov    %eax,(%esp)
c010029f:	e8 da 00 00 00       	call   c010037e <cputchar>
            buf[i ++] = c;
c01002a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002a7:	8d 50 01             	lea    0x1(%eax),%edx
c01002aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002b0:	88 90 00 de 1a c0    	mov    %dl,-0x3fe52200(%eax)
c01002b6:	eb 46                	jmp    c01002fe <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002b8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002bc:	75 17                	jne    c01002d5 <readline+0x86>
c01002be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002c2:	7e 11                	jle    c01002d5 <readline+0x86>
            cputchar(c);
c01002c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002c7:	89 04 24             	mov    %eax,(%esp)
c01002ca:	e8 af 00 00 00       	call   c010037e <cputchar>
            i --;
c01002cf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002d3:	eb 29                	jmp    c01002fe <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002d5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d9:	74 06                	je     c01002e1 <readline+0x92>
c01002db:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002df:	75 1d                	jne    c01002fe <readline+0xaf>
            cputchar(c);
c01002e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002e4:	89 04 24             	mov    %eax,(%esp)
c01002e7:	e8 92 00 00 00       	call   c010037e <cputchar>
            buf[i] = '\0';
c01002ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002ef:	05 00 de 1a c0       	add    $0xc01ade00,%eax
c01002f4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002f7:	b8 00 de 1a c0       	mov    $0xc01ade00,%eax
c01002fc:	eb 05                	jmp    c0100303 <readline+0xb4>
        }
    }
c01002fe:	e9 72 ff ff ff       	jmp    c0100275 <readline+0x26>
}
c0100303:	c9                   	leave  
c0100304:	c3                   	ret    

c0100305 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100305:	55                   	push   %ebp
c0100306:	89 e5                	mov    %esp,%ebp
c0100308:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010030b:	8b 45 08             	mov    0x8(%ebp),%eax
c010030e:	89 04 24             	mov    %eax,(%esp)
c0100311:	e8 f6 13 00 00       	call   c010170c <cons_putc>
    (*cnt) ++;
c0100316:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100319:	8b 00                	mov    (%eax),%eax
c010031b:	8d 50 01             	lea    0x1(%eax),%edx
c010031e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100321:	89 10                	mov    %edx,(%eax)
}
c0100323:	c9                   	leave  
c0100324:	c3                   	ret    

c0100325 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100325:	55                   	push   %ebp
c0100326:	89 e5                	mov    %esp,%ebp
c0100328:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010032b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100332:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100335:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100339:	8b 45 08             	mov    0x8(%ebp),%eax
c010033c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100340:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100343:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100347:	c7 04 24 05 03 10 c0 	movl   $0xc0100305,(%esp)
c010034e:	e8 0c b6 00 00       	call   c010b95f <vprintfmt>
    return cnt;
c0100353:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100356:	c9                   	leave  
c0100357:	c3                   	ret    

c0100358 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100358:	55                   	push   %ebp
c0100359:	89 e5                	mov    %esp,%ebp
c010035b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010035e:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100361:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100364:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100367:	89 44 24 04          	mov    %eax,0x4(%esp)
c010036b:	8b 45 08             	mov    0x8(%ebp),%eax
c010036e:	89 04 24             	mov    %eax,(%esp)
c0100371:	e8 af ff ff ff       	call   c0100325 <vcprintf>
c0100376:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100379:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010037c:	c9                   	leave  
c010037d:	c3                   	ret    

c010037e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010037e:	55                   	push   %ebp
c010037f:	89 e5                	mov    %esp,%ebp
c0100381:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100384:	8b 45 08             	mov    0x8(%ebp),%eax
c0100387:	89 04 24             	mov    %eax,(%esp)
c010038a:	e8 7d 13 00 00       	call   c010170c <cons_putc>
}
c010038f:	c9                   	leave  
c0100390:	c3                   	ret    

c0100391 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100391:	55                   	push   %ebp
c0100392:	89 e5                	mov    %esp,%ebp
c0100394:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100397:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010039e:	eb 13                	jmp    c01003b3 <cputs+0x22>
        cputch(c, &cnt);
c01003a0:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003a4:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003a7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003ab:	89 04 24             	mov    %eax,(%esp)
c01003ae:	e8 52 ff ff ff       	call   c0100305 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b6:	8d 50 01             	lea    0x1(%eax),%edx
c01003b9:	89 55 08             	mov    %edx,0x8(%ebp)
c01003bc:	0f b6 00             	movzbl (%eax),%eax
c01003bf:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003c2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c6:	75 d8                	jne    c01003a0 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003cb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003cf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d6:	e8 2a ff ff ff       	call   c0100305 <cputch>
    return cnt;
c01003db:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003de:	c9                   	leave  
c01003df:	c3                   	ret    

c01003e0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003e0:	55                   	push   %ebp
c01003e1:	89 e5                	mov    %esp,%ebp
c01003e3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003e6:	e8 5d 13 00 00       	call   c0101748 <cons_getc>
c01003eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f2:	74 f2                	je     c01003e6 <getchar+0x6>
        /* do nothing */;
    return c;
c01003f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003f7:	c9                   	leave  
c01003f8:	c3                   	ret    

c01003f9 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003f9:	55                   	push   %ebp
c01003fa:	89 e5                	mov    %esp,%ebp
c01003fc:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100402:	8b 00                	mov    (%eax),%eax
c0100404:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100407:	8b 45 10             	mov    0x10(%ebp),%eax
c010040a:	8b 00                	mov    (%eax),%eax
c010040c:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010040f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100416:	e9 d2 00 00 00       	jmp    c01004ed <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010041b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010041e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100421:	01 d0                	add    %edx,%eax
c0100423:	89 c2                	mov    %eax,%edx
c0100425:	c1 ea 1f             	shr    $0x1f,%edx
c0100428:	01 d0                	add    %edx,%eax
c010042a:	d1 f8                	sar    %eax
c010042c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010042f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100432:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100435:	eb 04                	jmp    c010043b <stab_binsearch+0x42>
            m --;
c0100437:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010043b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010043e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100441:	7c 1f                	jl     c0100462 <stab_binsearch+0x69>
c0100443:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100446:	89 d0                	mov    %edx,%eax
c0100448:	01 c0                	add    %eax,%eax
c010044a:	01 d0                	add    %edx,%eax
c010044c:	c1 e0 02             	shl    $0x2,%eax
c010044f:	89 c2                	mov    %eax,%edx
c0100451:	8b 45 08             	mov    0x8(%ebp),%eax
c0100454:	01 d0                	add    %edx,%eax
c0100456:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010045a:	0f b6 c0             	movzbl %al,%eax
c010045d:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100460:	75 d5                	jne    c0100437 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100462:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100465:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100468:	7d 0b                	jge    c0100475 <stab_binsearch+0x7c>
            l = true_m + 1;
c010046a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010046d:	83 c0 01             	add    $0x1,%eax
c0100470:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100473:	eb 78                	jmp    c01004ed <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100475:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010047c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010047f:	89 d0                	mov    %edx,%eax
c0100481:	01 c0                	add    %eax,%eax
c0100483:	01 d0                	add    %edx,%eax
c0100485:	c1 e0 02             	shl    $0x2,%eax
c0100488:	89 c2                	mov    %eax,%edx
c010048a:	8b 45 08             	mov    0x8(%ebp),%eax
c010048d:	01 d0                	add    %edx,%eax
c010048f:	8b 40 08             	mov    0x8(%eax),%eax
c0100492:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100495:	73 13                	jae    c01004aa <stab_binsearch+0xb1>
            *region_left = m;
c0100497:	8b 45 0c             	mov    0xc(%ebp),%eax
c010049a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010049f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004a2:	83 c0 01             	add    $0x1,%eax
c01004a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004a8:	eb 43                	jmp    c01004ed <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c01004aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004ad:	89 d0                	mov    %edx,%eax
c01004af:	01 c0                	add    %eax,%eax
c01004b1:	01 d0                	add    %edx,%eax
c01004b3:	c1 e0 02             	shl    $0x2,%eax
c01004b6:	89 c2                	mov    %eax,%edx
c01004b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01004bb:	01 d0                	add    %edx,%eax
c01004bd:	8b 40 08             	mov    0x8(%eax),%eax
c01004c0:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004c3:	76 16                	jbe    c01004db <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004cb:	8b 45 10             	mov    0x10(%ebp),%eax
c01004ce:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d3:	83 e8 01             	sub    $0x1,%eax
c01004d6:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004d9:	eb 12                	jmp    c01004ed <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004de:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e1:	89 10                	mov    %edx,(%eax)
            l = m;
c01004e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004e9:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004f3:	0f 8e 22 ff ff ff    	jle    c010041b <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004fd:	75 0f                	jne    c010050e <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100502:	8b 00                	mov    (%eax),%eax
c0100504:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100507:	8b 45 10             	mov    0x10(%ebp),%eax
c010050a:	89 10                	mov    %edx,(%eax)
c010050c:	eb 3f                	jmp    c010054d <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c010050e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100511:	8b 00                	mov    (%eax),%eax
c0100513:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100516:	eb 04                	jmp    c010051c <stab_binsearch+0x123>
c0100518:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010051c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051f:	8b 00                	mov    (%eax),%eax
c0100521:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100524:	7d 1f                	jge    c0100545 <stab_binsearch+0x14c>
c0100526:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100529:	89 d0                	mov    %edx,%eax
c010052b:	01 c0                	add    %eax,%eax
c010052d:	01 d0                	add    %edx,%eax
c010052f:	c1 e0 02             	shl    $0x2,%eax
c0100532:	89 c2                	mov    %eax,%edx
c0100534:	8b 45 08             	mov    0x8(%ebp),%eax
c0100537:	01 d0                	add    %edx,%eax
c0100539:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010053d:	0f b6 c0             	movzbl %al,%eax
c0100540:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100543:	75 d3                	jne    c0100518 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100545:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100548:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010054b:	89 10                	mov    %edx,(%eax)
    }
}
c010054d:	c9                   	leave  
c010054e:	c3                   	ret    

c010054f <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010054f:	55                   	push   %ebp
c0100550:	89 e5                	mov    %esp,%ebp
c0100552:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100555:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100558:	c7 00 6c c4 10 c0    	movl   $0xc010c46c,(%eax)
    info->eip_line = 0;
c010055e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100561:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100568:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056b:	c7 40 08 6c c4 10 c0 	movl   $0xc010c46c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100572:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100575:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010057c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100582:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100585:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100588:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    // find the relevant set of stabs
    if (addr >= KERNBASE) {
c010058f:	81 7d 08 ff ff ff bf 	cmpl   $0xbfffffff,0x8(%ebp)
c0100596:	76 21                	jbe    c01005b9 <debuginfo_eip+0x6a>
        stabs = __STAB_BEGIN__;
c0100598:	c7 45 f4 e0 eb 10 c0 	movl   $0xc010ebe0,-0xc(%ebp)
        stab_end = __STAB_END__;
c010059f:	c7 45 f0 c8 3b 12 c0 	movl   $0xc0123bc8,-0x10(%ebp)
        stabstr = __STABSTR_BEGIN__;
c01005a6:	c7 45 ec c9 3b 12 c0 	movl   $0xc0123bc9,-0x14(%ebp)
        stabstr_end = __STABSTR_END__;
c01005ad:	c7 45 e8 f0 9c 12 c0 	movl   $0xc0129cf0,-0x18(%ebp)
c01005b4:	e9 ea 00 00 00       	jmp    c01006a3 <debuginfo_eip+0x154>
    }
    else {
        // user-program linker script, tools/user.ld puts the information about the
        // program's stabs (included __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__,
        // and __STABSTR_END__) in a structure located at virtual address USTAB.
        const struct userstabdata *usd = (struct userstabdata *)USTAB;
c01005b9:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

        // make sure that debugger (current process) can access this memory
        struct mm_struct *mm;
        if (current == NULL || (mm = current->mm) == NULL) {
c01005c0:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c01005c5:	85 c0                	test   %eax,%eax
c01005c7:	74 11                	je     c01005da <debuginfo_eip+0x8b>
c01005c9:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c01005ce:	8b 40 18             	mov    0x18(%eax),%eax
c01005d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01005d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01005d8:	75 0a                	jne    c01005e4 <debuginfo_eip+0x95>
            return -1;
c01005da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005df:	e9 9e 03 00 00       	jmp    c0100982 <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)usd, sizeof(struct userstabdata), 0)) {
c01005e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01005e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01005ee:	00 
c01005ef:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01005f6:	00 
c01005f7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01005fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01005fe:	89 04 24             	mov    %eax,(%esp)
c0100601:	e8 e3 89 00 00       	call   c0108fe9 <user_mem_check>
c0100606:	85 c0                	test   %eax,%eax
c0100608:	75 0a                	jne    c0100614 <debuginfo_eip+0xc5>
            return -1;
c010060a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010060f:	e9 6e 03 00 00       	jmp    c0100982 <debuginfo_eip+0x433>
        }

        stabs = usd->stabs;
c0100614:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100617:	8b 00                	mov    (%eax),%eax
c0100619:	89 45 f4             	mov    %eax,-0xc(%ebp)
        stab_end = usd->stab_end;
c010061c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010061f:	8b 40 04             	mov    0x4(%eax),%eax
c0100622:	89 45 f0             	mov    %eax,-0x10(%ebp)
        stabstr = usd->stabstr;
c0100625:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100628:	8b 40 08             	mov    0x8(%eax),%eax
c010062b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        stabstr_end = usd->stabstr_end;
c010062e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100631:	8b 40 0c             	mov    0xc(%eax),%eax
c0100634:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // make sure the STABS and string table memory is valid
        if (!user_mem_check(mm, (uintptr_t)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, 0)) {
c0100637:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010063a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010063d:	29 c2                	sub    %eax,%edx
c010063f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100642:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100649:	00 
c010064a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010064e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100652:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100655:	89 04 24             	mov    %eax,(%esp)
c0100658:	e8 8c 89 00 00       	call   c0108fe9 <user_mem_check>
c010065d:	85 c0                	test   %eax,%eax
c010065f:	75 0a                	jne    c010066b <debuginfo_eip+0x11c>
            return -1;
c0100661:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100666:	e9 17 03 00 00       	jmp    c0100982 <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)stabstr, stabstr_end - stabstr, 0)) {
c010066b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010066e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100671:	29 c2                	sub    %eax,%edx
c0100673:	89 d0                	mov    %edx,%eax
c0100675:	89 c2                	mov    %eax,%edx
c0100677:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010067a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100681:	00 
c0100682:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100686:	89 44 24 04          	mov    %eax,0x4(%esp)
c010068a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010068d:	89 04 24             	mov    %eax,(%esp)
c0100690:	e8 54 89 00 00       	call   c0108fe9 <user_mem_check>
c0100695:	85 c0                	test   %eax,%eax
c0100697:	75 0a                	jne    c01006a3 <debuginfo_eip+0x154>
            return -1;
c0100699:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010069e:	e9 df 02 00 00       	jmp    c0100982 <debuginfo_eip+0x433>
        }
    }

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01006a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006a6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01006a9:	76 0d                	jbe    c01006b8 <debuginfo_eip+0x169>
c01006ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006ae:	83 e8 01             	sub    $0x1,%eax
c01006b1:	0f b6 00             	movzbl (%eax),%eax
c01006b4:	84 c0                	test   %al,%al
c01006b6:	74 0a                	je     c01006c2 <debuginfo_eip+0x173>
        return -1;
c01006b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006bd:	e9 c0 02 00 00       	jmp    c0100982 <debuginfo_eip+0x433>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01006c2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01006c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006cf:	29 c2                	sub    %eax,%edx
c01006d1:	89 d0                	mov    %edx,%eax
c01006d3:	c1 f8 02             	sar    $0x2,%eax
c01006d6:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006dc:	83 e8 01             	sub    $0x1,%eax
c01006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01006e5:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006e9:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006f0:	00 
c01006f1:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006f8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100702:	89 04 24             	mov    %eax,(%esp)
c0100705:	e8 ef fc ff ff       	call   c01003f9 <stab_binsearch>
    if (lfile == 0)
c010070a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010070d:	85 c0                	test   %eax,%eax
c010070f:	75 0a                	jne    c010071b <debuginfo_eip+0x1cc>
        return -1;
c0100711:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100716:	e9 67 02 00 00       	jmp    c0100982 <debuginfo_eip+0x433>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010071b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010071e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100721:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100724:	89 45 d0             	mov    %eax,-0x30(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100727:	8b 45 08             	mov    0x8(%ebp),%eax
c010072a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010072e:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100735:	00 
c0100736:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100739:	89 44 24 08          	mov    %eax,0x8(%esp)
c010073d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100740:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100744:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100747:	89 04 24             	mov    %eax,(%esp)
c010074a:	e8 aa fc ff ff       	call   c01003f9 <stab_binsearch>

    if (lfun <= rfun) {
c010074f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100752:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100755:	39 c2                	cmp    %eax,%edx
c0100757:	7f 7c                	jg     c01007d5 <debuginfo_eip+0x286>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100759:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010075c:	89 c2                	mov    %eax,%edx
c010075e:	89 d0                	mov    %edx,%eax
c0100760:	01 c0                	add    %eax,%eax
c0100762:	01 d0                	add    %edx,%eax
c0100764:	c1 e0 02             	shl    $0x2,%eax
c0100767:	89 c2                	mov    %eax,%edx
c0100769:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010076c:	01 d0                	add    %edx,%eax
c010076e:	8b 10                	mov    (%eax),%edx
c0100770:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100773:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100776:	29 c1                	sub    %eax,%ecx
c0100778:	89 c8                	mov    %ecx,%eax
c010077a:	39 c2                	cmp    %eax,%edx
c010077c:	73 22                	jae    c01007a0 <debuginfo_eip+0x251>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010077e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100781:	89 c2                	mov    %eax,%edx
c0100783:	89 d0                	mov    %edx,%eax
c0100785:	01 c0                	add    %eax,%eax
c0100787:	01 d0                	add    %edx,%eax
c0100789:	c1 e0 02             	shl    $0x2,%eax
c010078c:	89 c2                	mov    %eax,%edx
c010078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100791:	01 d0                	add    %edx,%eax
c0100793:	8b 10                	mov    (%eax),%edx
c0100795:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100798:	01 c2                	add    %eax,%edx
c010079a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010079d:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01007a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007a3:	89 c2                	mov    %eax,%edx
c01007a5:	89 d0                	mov    %edx,%eax
c01007a7:	01 c0                	add    %eax,%eax
c01007a9:	01 d0                	add    %edx,%eax
c01007ab:	c1 e0 02             	shl    $0x2,%eax
c01007ae:	89 c2                	mov    %eax,%edx
c01007b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007b3:	01 d0                	add    %edx,%eax
c01007b5:	8b 50 08             	mov    0x8(%eax),%edx
c01007b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007bb:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01007be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c1:	8b 40 10             	mov    0x10(%eax),%eax
c01007c4:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01007c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007ca:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfun;
c01007cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007d0:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01007d3:	eb 15                	jmp    c01007ea <debuginfo_eip+0x29b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d8:	8b 55 08             	mov    0x8(%ebp),%edx
c01007db:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007de:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007e1:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfile;
c01007e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007e7:	89 45 c8             	mov    %eax,-0x38(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ed:	8b 40 08             	mov    0x8(%eax),%eax
c01007f0:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007f7:	00 
c01007f8:	89 04 24             	mov    %eax,(%esp)
c01007fb:	e8 92 b8 00 00       	call   c010c092 <strfind>
c0100800:	89 c2                	mov    %eax,%edx
c0100802:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100805:	8b 40 08             	mov    0x8(%eax),%eax
c0100808:	29 c2                	sub    %eax,%edx
c010080a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010080d:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100810:	8b 45 08             	mov    0x8(%ebp),%eax
c0100813:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100817:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010081e:	00 
c010081f:	8d 45 c8             	lea    -0x38(%ebp),%eax
c0100822:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100826:	8d 45 cc             	lea    -0x34(%ebp),%eax
c0100829:	89 44 24 04          	mov    %eax,0x4(%esp)
c010082d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100830:	89 04 24             	mov    %eax,(%esp)
c0100833:	e8 c1 fb ff ff       	call   c01003f9 <stab_binsearch>
    if (lline <= rline) {
c0100838:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010083b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010083e:	39 c2                	cmp    %eax,%edx
c0100840:	7f 24                	jg     c0100866 <debuginfo_eip+0x317>
        info->eip_line = stabs[rline].n_desc;
c0100842:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100845:	89 c2                	mov    %eax,%edx
c0100847:	89 d0                	mov    %edx,%eax
c0100849:	01 c0                	add    %eax,%eax
c010084b:	01 d0                	add    %edx,%eax
c010084d:	c1 e0 02             	shl    $0x2,%eax
c0100850:	89 c2                	mov    %eax,%edx
c0100852:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100855:	01 d0                	add    %edx,%eax
c0100857:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010085b:	0f b7 d0             	movzwl %ax,%edx
c010085e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100861:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100864:	eb 13                	jmp    c0100879 <debuginfo_eip+0x32a>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100866:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010086b:	e9 12 01 00 00       	jmp    c0100982 <debuginfo_eip+0x433>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100870:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100873:	83 e8 01             	sub    $0x1,%eax
c0100876:	89 45 cc             	mov    %eax,-0x34(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100879:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010087c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010087f:	39 c2                	cmp    %eax,%edx
c0100881:	7c 56                	jl     c01008d9 <debuginfo_eip+0x38a>
           && stabs[lline].n_type != N_SOL
c0100883:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100886:	89 c2                	mov    %eax,%edx
c0100888:	89 d0                	mov    %edx,%eax
c010088a:	01 c0                	add    %eax,%eax
c010088c:	01 d0                	add    %edx,%eax
c010088e:	c1 e0 02             	shl    $0x2,%eax
c0100891:	89 c2                	mov    %eax,%edx
c0100893:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100896:	01 d0                	add    %edx,%eax
c0100898:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010089c:	3c 84                	cmp    $0x84,%al
c010089e:	74 39                	je     c01008d9 <debuginfo_eip+0x38a>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01008a0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008a3:	89 c2                	mov    %eax,%edx
c01008a5:	89 d0                	mov    %edx,%eax
c01008a7:	01 c0                	add    %eax,%eax
c01008a9:	01 d0                	add    %edx,%eax
c01008ab:	c1 e0 02             	shl    $0x2,%eax
c01008ae:	89 c2                	mov    %eax,%edx
c01008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008b3:	01 d0                	add    %edx,%eax
c01008b5:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008b9:	3c 64                	cmp    $0x64,%al
c01008bb:	75 b3                	jne    c0100870 <debuginfo_eip+0x321>
c01008bd:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008c0:	89 c2                	mov    %eax,%edx
c01008c2:	89 d0                	mov    %edx,%eax
c01008c4:	01 c0                	add    %eax,%eax
c01008c6:	01 d0                	add    %edx,%eax
c01008c8:	c1 e0 02             	shl    $0x2,%eax
c01008cb:	89 c2                	mov    %eax,%edx
c01008cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008d0:	01 d0                	add    %edx,%eax
c01008d2:	8b 40 08             	mov    0x8(%eax),%eax
c01008d5:	85 c0                	test   %eax,%eax
c01008d7:	74 97                	je     c0100870 <debuginfo_eip+0x321>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008d9:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01008dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008df:	39 c2                	cmp    %eax,%edx
c01008e1:	7c 46                	jl     c0100929 <debuginfo_eip+0x3da>
c01008e3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008e6:	89 c2                	mov    %eax,%edx
c01008e8:	89 d0                	mov    %edx,%eax
c01008ea:	01 c0                	add    %eax,%eax
c01008ec:	01 d0                	add    %edx,%eax
c01008ee:	c1 e0 02             	shl    $0x2,%eax
c01008f1:	89 c2                	mov    %eax,%edx
c01008f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008f6:	01 d0                	add    %edx,%eax
c01008f8:	8b 10                	mov    (%eax),%edx
c01008fa:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100900:	29 c1                	sub    %eax,%ecx
c0100902:	89 c8                	mov    %ecx,%eax
c0100904:	39 c2                	cmp    %eax,%edx
c0100906:	73 21                	jae    c0100929 <debuginfo_eip+0x3da>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100908:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010090b:	89 c2                	mov    %eax,%edx
c010090d:	89 d0                	mov    %edx,%eax
c010090f:	01 c0                	add    %eax,%eax
c0100911:	01 d0                	add    %edx,%eax
c0100913:	c1 e0 02             	shl    $0x2,%eax
c0100916:	89 c2                	mov    %eax,%edx
c0100918:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010091b:	01 d0                	add    %edx,%eax
c010091d:	8b 10                	mov    (%eax),%edx
c010091f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100922:	01 c2                	add    %eax,%edx
c0100924:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100927:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100929:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010092c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010092f:	39 c2                	cmp    %eax,%edx
c0100931:	7d 4a                	jge    c010097d <debuginfo_eip+0x42e>
        for (lline = lfun + 1;
c0100933:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100936:	83 c0 01             	add    $0x1,%eax
c0100939:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010093c:	eb 18                	jmp    c0100956 <debuginfo_eip+0x407>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c010093e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100941:	8b 40 14             	mov    0x14(%eax),%eax
c0100944:	8d 50 01             	lea    0x1(%eax),%edx
c0100947:	8b 45 0c             	mov    0xc(%ebp),%eax
c010094a:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c010094d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100950:	83 c0 01             	add    $0x1,%eax
c0100953:	89 45 cc             	mov    %eax,-0x34(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100956:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100959:	8b 45 d0             	mov    -0x30(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c010095c:	39 c2                	cmp    %eax,%edx
c010095e:	7d 1d                	jge    c010097d <debuginfo_eip+0x42e>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100960:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100963:	89 c2                	mov    %eax,%edx
c0100965:	89 d0                	mov    %edx,%eax
c0100967:	01 c0                	add    %eax,%eax
c0100969:	01 d0                	add    %edx,%eax
c010096b:	c1 e0 02             	shl    $0x2,%eax
c010096e:	89 c2                	mov    %eax,%edx
c0100970:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100973:	01 d0                	add    %edx,%eax
c0100975:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100979:	3c a0                	cmp    $0xa0,%al
c010097b:	74 c1                	je     c010093e <debuginfo_eip+0x3ef>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c010097d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100982:	c9                   	leave  
c0100983:	c3                   	ret    

c0100984 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100984:	55                   	push   %ebp
c0100985:	89 e5                	mov    %esp,%ebp
c0100987:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010098a:	c7 04 24 76 c4 10 c0 	movl   $0xc010c476,(%esp)
c0100991:	e8 c2 f9 ff ff       	call   c0100358 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100996:	c7 44 24 04 2a 00 10 	movl   $0xc010002a,0x4(%esp)
c010099d:	c0 
c010099e:	c7 04 24 8f c4 10 c0 	movl   $0xc010c48f,(%esp)
c01009a5:	e8 ae f9 ff ff       	call   c0100358 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01009aa:	c7 44 24 04 a7 c3 10 	movl   $0xc010c3a7,0x4(%esp)
c01009b1:	c0 
c01009b2:	c7 04 24 a7 c4 10 c0 	movl   $0xc010c4a7,(%esp)
c01009b9:	e8 9a f9 ff ff       	call   c0100358 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01009be:	c7 44 24 04 d4 dd 1a 	movl   $0xc01addd4,0x4(%esp)
c01009c5:	c0 
c01009c6:	c7 04 24 bf c4 10 c0 	movl   $0xc010c4bf,(%esp)
c01009cd:	e8 86 f9 ff ff       	call   c0100358 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009d2:	c7 44 24 04 78 0f 1b 	movl   $0xc01b0f78,0x4(%esp)
c01009d9:	c0 
c01009da:	c7 04 24 d7 c4 10 c0 	movl   $0xc010c4d7,(%esp)
c01009e1:	e8 72 f9 ff ff       	call   c0100358 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009e6:	b8 78 0f 1b c0       	mov    $0xc01b0f78,%eax
c01009eb:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009f1:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c01009f6:	29 c2                	sub    %eax,%edx
c01009f8:	89 d0                	mov    %edx,%eax
c01009fa:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100a00:	85 c0                	test   %eax,%eax
c0100a02:	0f 48 c2             	cmovs  %edx,%eax
c0100a05:	c1 f8 0a             	sar    $0xa,%eax
c0100a08:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a0c:	c7 04 24 f0 c4 10 c0 	movl   $0xc010c4f0,(%esp)
c0100a13:	e8 40 f9 ff ff       	call   c0100358 <cprintf>
}
c0100a18:	c9                   	leave  
c0100a19:	c3                   	ret    

c0100a1a <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100a1a:	55                   	push   %ebp
c0100a1b:	89 e5                	mov    %esp,%ebp
c0100a1d:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100a23:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100a26:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a2d:	89 04 24             	mov    %eax,(%esp)
c0100a30:	e8 1a fb ff ff       	call   c010054f <debuginfo_eip>
c0100a35:	85 c0                	test   %eax,%eax
c0100a37:	74 15                	je     c0100a4e <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a39:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a40:	c7 04 24 1a c5 10 c0 	movl   $0xc010c51a,(%esp)
c0100a47:	e8 0c f9 ff ff       	call   c0100358 <cprintf>
c0100a4c:	eb 6d                	jmp    c0100abb <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a4e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a55:	eb 1c                	jmp    c0100a73 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0100a57:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a5d:	01 d0                	add    %edx,%eax
c0100a5f:	0f b6 00             	movzbl (%eax),%eax
c0100a62:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a68:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a6b:	01 ca                	add    %ecx,%edx
c0100a6d:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a6f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a73:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a76:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a79:	7f dc                	jg     c0100a57 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a7b:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a84:	01 d0                	add    %edx,%eax
c0100a86:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a89:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a8c:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a8f:	89 d1                	mov    %edx,%ecx
c0100a91:	29 c1                	sub    %eax,%ecx
c0100a93:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a96:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a99:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a9d:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100aa3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100aa7:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100aab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100aaf:	c7 04 24 36 c5 10 c0 	movl   $0xc010c536,(%esp)
c0100ab6:	e8 9d f8 ff ff       	call   c0100358 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100abb:	c9                   	leave  
c0100abc:	c3                   	ret    

c0100abd <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100abd:	55                   	push   %ebp
c0100abe:	89 e5                	mov    %esp,%ebp
c0100ac0:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100ac3:	8b 45 04             	mov    0x4(%ebp),%eax
c0100ac6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100ac9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100acc:	c9                   	leave  
c0100acd:	c3                   	ret    

c0100ace <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100ace:	55                   	push   %ebp
c0100acf:	89 e5                	mov    %esp,%ebp
c0100ad1:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100ad4:	89 e8                	mov    %ebp,%eax
c0100ad6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100ad9:	8b 45 e0             	mov    -0x20(%ebp),%eax
     *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
     *    (3.5) popup a calling stackframe
     *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
     *                   the calling funciton's ebp = ss:[ebp]
     */
    uint32_t ebp = read_ebp();
c0100adc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
c0100adf:	e8 d9 ff ff ff       	call   c0100abd <read_eip>
c0100ae4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i;
    int j;
    uint32_t *args;
    for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++) {
c0100ae7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100aee:	e9 88 00 00 00       	jmp    c0100b7b <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100af6:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100afd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b01:	c7 04 24 48 c5 10 c0 	movl   $0xc010c548,(%esp)
c0100b08:	e8 4b f8 ff ff       	call   c0100358 <cprintf>
        args = (uint32_t *)ebp + 2;
c0100b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b10:	83 c0 08             	add    $0x8,%eax
c0100b13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for(j = 0; j < 4; j++)
c0100b16:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100b1d:	eb 25                	jmp    c0100b44 <print_stackframe+0x76>
            cprintf("0x%08x ",args[j]);
c0100b1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b22:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b2c:	01 d0                	add    %edx,%eax
c0100b2e:	8b 00                	mov    (%eax),%eax
c0100b30:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b34:	c7 04 24 64 c5 10 c0 	movl   $0xc010c564,(%esp)
c0100b3b:	e8 18 f8 ff ff       	call   c0100358 <cprintf>
    int j;
    uint32_t *args;
    for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        args = (uint32_t *)ebp + 2;
        for(j = 0; j < 4; j++)
c0100b40:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100b44:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b48:	7e d5                	jle    c0100b1f <print_stackframe+0x51>
            cprintf("0x%08x ",args[j]);
        cprintf("\n");
c0100b4a:	c7 04 24 6c c5 10 c0 	movl   $0xc010c56c,(%esp)
c0100b51:	e8 02 f8 ff ff       	call   c0100358 <cprintf>
        print_debuginfo(eip-1);
c0100b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b59:	83 e8 01             	sub    $0x1,%eax
c0100b5c:	89 04 24             	mov    %eax,(%esp)
c0100b5f:	e8 b6 fe ff ff       	call   c0100a1a <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b67:	83 c0 04             	add    $0x4,%eax
c0100b6a:	8b 00                	mov    (%eax),%eax
c0100b6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b72:	8b 00                	mov    (%eax),%eax
c0100b74:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t ebp = read_ebp();
    uint32_t eip = read_eip();
    int i;
    int j;
    uint32_t *args;
    for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++) {
c0100b77:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100b7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b7f:	74 0a                	je     c0100b8b <print_stackframe+0xbd>
c0100b81:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b85:	0f 8e 68 ff ff ff    	jle    c0100af3 <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip-1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0100b8b:	c9                   	leave  
c0100b8c:	c3                   	ret    

c0100b8d <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b8d:	55                   	push   %ebp
c0100b8e:	89 e5                	mov    %esp,%ebp
c0100b90:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b93:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b9a:	eb 0c                	jmp    c0100ba8 <parse+0x1b>
            *buf ++ = '\0';
c0100b9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b9f:	8d 50 01             	lea    0x1(%eax),%edx
c0100ba2:	89 55 08             	mov    %edx,0x8(%ebp)
c0100ba5:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ba8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bab:	0f b6 00             	movzbl (%eax),%eax
c0100bae:	84 c0                	test   %al,%al
c0100bb0:	74 1d                	je     c0100bcf <parse+0x42>
c0100bb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb5:	0f b6 00             	movzbl (%eax),%eax
c0100bb8:	0f be c0             	movsbl %al,%eax
c0100bbb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bbf:	c7 04 24 f0 c5 10 c0 	movl   $0xc010c5f0,(%esp)
c0100bc6:	e8 94 b4 00 00       	call   c010c05f <strchr>
c0100bcb:	85 c0                	test   %eax,%eax
c0100bcd:	75 cd                	jne    c0100b9c <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100bcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd2:	0f b6 00             	movzbl (%eax),%eax
c0100bd5:	84 c0                	test   %al,%al
c0100bd7:	75 02                	jne    c0100bdb <parse+0x4e>
            break;
c0100bd9:	eb 67                	jmp    c0100c42 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100bdb:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100bdf:	75 14                	jne    c0100bf5 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100be1:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100be8:	00 
c0100be9:	c7 04 24 f5 c5 10 c0 	movl   $0xc010c5f5,(%esp)
c0100bf0:	e8 63 f7 ff ff       	call   c0100358 <cprintf>
        }
        argv[argc ++] = buf;
c0100bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bf8:	8d 50 01             	lea    0x1(%eax),%edx
c0100bfb:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bfe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100c05:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c08:	01 c2                	add    %eax,%edx
c0100c0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c0d:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c0f:	eb 04                	jmp    c0100c15 <parse+0x88>
            buf ++;
c0100c11:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c15:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c18:	0f b6 00             	movzbl (%eax),%eax
c0100c1b:	84 c0                	test   %al,%al
c0100c1d:	74 1d                	je     c0100c3c <parse+0xaf>
c0100c1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c22:	0f b6 00             	movzbl (%eax),%eax
c0100c25:	0f be c0             	movsbl %al,%eax
c0100c28:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c2c:	c7 04 24 f0 c5 10 c0 	movl   $0xc010c5f0,(%esp)
c0100c33:	e8 27 b4 00 00       	call   c010c05f <strchr>
c0100c38:	85 c0                	test   %eax,%eax
c0100c3a:	74 d5                	je     c0100c11 <parse+0x84>
            buf ++;
        }
    }
c0100c3c:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c3d:	e9 66 ff ff ff       	jmp    c0100ba8 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c45:	c9                   	leave  
c0100c46:	c3                   	ret    

c0100c47 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c47:	55                   	push   %ebp
c0100c48:	89 e5                	mov    %esp,%ebp
c0100c4a:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c4d:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c50:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c54:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c57:	89 04 24             	mov    %eax,(%esp)
c0100c5a:	e8 2e ff ff ff       	call   c0100b8d <parse>
c0100c5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c62:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c66:	75 0a                	jne    c0100c72 <runcmd+0x2b>
        return 0;
c0100c68:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c6d:	e9 85 00 00 00       	jmp    c0100cf7 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c79:	eb 5c                	jmp    c0100cd7 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c7b:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c81:	89 d0                	mov    %edx,%eax
c0100c83:	01 c0                	add    %eax,%eax
c0100c85:	01 d0                	add    %edx,%eax
c0100c87:	c1 e0 02             	shl    $0x2,%eax
c0100c8a:	05 20 c0 12 c0       	add    $0xc012c020,%eax
c0100c8f:	8b 00                	mov    (%eax),%eax
c0100c91:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c95:	89 04 24             	mov    %eax,(%esp)
c0100c98:	e8 23 b3 00 00       	call   c010bfc0 <strcmp>
c0100c9d:	85 c0                	test   %eax,%eax
c0100c9f:	75 32                	jne    c0100cd3 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100ca1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100ca4:	89 d0                	mov    %edx,%eax
c0100ca6:	01 c0                	add    %eax,%eax
c0100ca8:	01 d0                	add    %edx,%eax
c0100caa:	c1 e0 02             	shl    $0x2,%eax
c0100cad:	05 20 c0 12 c0       	add    $0xc012c020,%eax
c0100cb2:	8b 40 08             	mov    0x8(%eax),%eax
c0100cb5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100cb8:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100cbe:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100cc2:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100cc5:	83 c2 04             	add    $0x4,%edx
c0100cc8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100ccc:	89 0c 24             	mov    %ecx,(%esp)
c0100ccf:	ff d0                	call   *%eax
c0100cd1:	eb 24                	jmp    c0100cf7 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cd3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cda:	83 f8 02             	cmp    $0x2,%eax
c0100cdd:	76 9c                	jbe    c0100c7b <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cdf:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100ce2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ce6:	c7 04 24 13 c6 10 c0 	movl   $0xc010c613,(%esp)
c0100ced:	e8 66 f6 ff ff       	call   c0100358 <cprintf>
    return 0;
c0100cf2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cf7:	c9                   	leave  
c0100cf8:	c3                   	ret    

c0100cf9 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cf9:	55                   	push   %ebp
c0100cfa:	89 e5                	mov    %esp,%ebp
c0100cfc:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cff:	c7 04 24 2c c6 10 c0 	movl   $0xc010c62c,(%esp)
c0100d06:	e8 4d f6 ff ff       	call   c0100358 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100d0b:	c7 04 24 54 c6 10 c0 	movl   $0xc010c654,(%esp)
c0100d12:	e8 41 f6 ff ff       	call   c0100358 <cprintf>

    if (tf != NULL) {
c0100d17:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d1b:	74 0b                	je     c0100d28 <kmonitor+0x2f>
        print_trapframe(tf);
c0100d1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d20:	89 04 24             	mov    %eax,(%esp)
c0100d23:	e8 c7 16 00 00       	call   c01023ef <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d28:	c7 04 24 79 c6 10 c0 	movl   $0xc010c679,(%esp)
c0100d2f:	e8 1b f5 ff ff       	call   c010024f <readline>
c0100d34:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d3b:	74 18                	je     c0100d55 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100d3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d40:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d47:	89 04 24             	mov    %eax,(%esp)
c0100d4a:	e8 f8 fe ff ff       	call   c0100c47 <runcmd>
c0100d4f:	85 c0                	test   %eax,%eax
c0100d51:	79 02                	jns    c0100d55 <kmonitor+0x5c>
                break;
c0100d53:	eb 02                	jmp    c0100d57 <kmonitor+0x5e>
            }
        }
    }
c0100d55:	eb d1                	jmp    c0100d28 <kmonitor+0x2f>
}
c0100d57:	c9                   	leave  
c0100d58:	c3                   	ret    

c0100d59 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d59:	55                   	push   %ebp
c0100d5a:	89 e5                	mov    %esp,%ebp
c0100d5c:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d66:	eb 3f                	jmp    c0100da7 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d68:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d6b:	89 d0                	mov    %edx,%eax
c0100d6d:	01 c0                	add    %eax,%eax
c0100d6f:	01 d0                	add    %edx,%eax
c0100d71:	c1 e0 02             	shl    $0x2,%eax
c0100d74:	05 20 c0 12 c0       	add    $0xc012c020,%eax
c0100d79:	8b 48 04             	mov    0x4(%eax),%ecx
c0100d7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d7f:	89 d0                	mov    %edx,%eax
c0100d81:	01 c0                	add    %eax,%eax
c0100d83:	01 d0                	add    %edx,%eax
c0100d85:	c1 e0 02             	shl    $0x2,%eax
c0100d88:	05 20 c0 12 c0       	add    $0xc012c020,%eax
c0100d8d:	8b 00                	mov    (%eax),%eax
c0100d8f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d93:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d97:	c7 04 24 7d c6 10 c0 	movl   $0xc010c67d,(%esp)
c0100d9e:	e8 b5 f5 ff ff       	call   c0100358 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100da3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100daa:	83 f8 02             	cmp    $0x2,%eax
c0100dad:	76 b9                	jbe    c0100d68 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100daf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100db4:	c9                   	leave  
c0100db5:	c3                   	ret    

c0100db6 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100db6:	55                   	push   %ebp
c0100db7:	89 e5                	mov    %esp,%ebp
c0100db9:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100dbc:	e8 c3 fb ff ff       	call   c0100984 <print_kerninfo>
    return 0;
c0100dc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dc6:	c9                   	leave  
c0100dc7:	c3                   	ret    

c0100dc8 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100dc8:	55                   	push   %ebp
c0100dc9:	89 e5                	mov    %esp,%ebp
c0100dcb:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100dce:	e8 fb fc ff ff       	call   c0100ace <print_stackframe>
    return 0;
c0100dd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dd8:	c9                   	leave  
c0100dd9:	c3                   	ret    

c0100dda <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100dda:	55                   	push   %ebp
c0100ddb:	89 e5                	mov    %esp,%ebp
c0100ddd:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100de0:	a1 00 e2 1a c0       	mov    0xc01ae200,%eax
c0100de5:	85 c0                	test   %eax,%eax
c0100de7:	74 02                	je     c0100deb <__panic+0x11>
        goto panic_dead;
c0100de9:	eb 48                	jmp    c0100e33 <__panic+0x59>
    }
    is_panic = 1;
c0100deb:	c7 05 00 e2 1a c0 01 	movl   $0x1,0xc01ae200
c0100df2:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100df5:	8d 45 14             	lea    0x14(%ebp),%eax
c0100df8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100dfe:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100e02:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e05:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e09:	c7 04 24 86 c6 10 c0 	movl   $0xc010c686,(%esp)
c0100e10:	e8 43 f5 ff ff       	call   c0100358 <cprintf>
    vcprintf(fmt, ap);
c0100e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e18:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e1c:	8b 45 10             	mov    0x10(%ebp),%eax
c0100e1f:	89 04 24             	mov    %eax,(%esp)
c0100e22:	e8 fe f4 ff ff       	call   c0100325 <vcprintf>
    cprintf("\n");
c0100e27:	c7 04 24 a2 c6 10 c0 	movl   $0xc010c6a2,(%esp)
c0100e2e:	e8 25 f5 ff ff       	call   c0100358 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
c0100e33:	e8 fa 11 00 00       	call   c0102032 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100e38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e3f:	e8 b5 fe ff ff       	call   c0100cf9 <kmonitor>
    }
c0100e44:	eb f2                	jmp    c0100e38 <__panic+0x5e>

c0100e46 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100e46:	55                   	push   %ebp
c0100e47:	89 e5                	mov    %esp,%ebp
c0100e49:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100e4c:	8d 45 14             	lea    0x14(%ebp),%eax
c0100e4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100e52:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e55:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100e59:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e60:	c7 04 24 a4 c6 10 c0 	movl   $0xc010c6a4,(%esp)
c0100e67:	e8 ec f4 ff ff       	call   c0100358 <cprintf>
    vcprintf(fmt, ap);
c0100e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e73:	8b 45 10             	mov    0x10(%ebp),%eax
c0100e76:	89 04 24             	mov    %eax,(%esp)
c0100e79:	e8 a7 f4 ff ff       	call   c0100325 <vcprintf>
    cprintf("\n");
c0100e7e:	c7 04 24 a2 c6 10 c0 	movl   $0xc010c6a2,(%esp)
c0100e85:	e8 ce f4 ff ff       	call   c0100358 <cprintf>
    va_end(ap);
}
c0100e8a:	c9                   	leave  
c0100e8b:	c3                   	ret    

c0100e8c <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100e8c:	55                   	push   %ebp
c0100e8d:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100e8f:	a1 00 e2 1a c0       	mov    0xc01ae200,%eax
}
c0100e94:	5d                   	pop    %ebp
c0100e95:	c3                   	ret    

c0100e96 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100e96:	55                   	push   %ebp
c0100e97:	89 e5                	mov    %esp,%ebp
c0100e99:	83 ec 28             	sub    $0x28,%esp
c0100e9c:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100ea2:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ea6:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100eaa:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100eae:	ee                   	out    %al,(%dx)
c0100eaf:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100eb5:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100eb9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ebd:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ec1:	ee                   	out    %al,(%dx)
c0100ec2:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100ec8:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100ecc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100ed0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100ed4:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100ed5:	c7 05 78 0e 1b c0 00 	movl   $0x0,0xc01b0e78
c0100edc:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100edf:	c7 04 24 c2 c6 10 c0 	movl   $0xc010c6c2,(%esp)
c0100ee6:	e8 6d f4 ff ff       	call   c0100358 <cprintf>
    pic_enable(IRQ_TIMER);
c0100eeb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100ef2:	e8 99 11 00 00       	call   c0102090 <pic_enable>
}
c0100ef7:	c9                   	leave  
c0100ef8:	c3                   	ret    

c0100ef9 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0100ef9:	55                   	push   %ebp
c0100efa:	89 e5                	mov    %esp,%ebp
c0100efc:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100eff:	9c                   	pushf  
c0100f00:	58                   	pop    %eax
c0100f01:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100f07:	25 00 02 00 00       	and    $0x200,%eax
c0100f0c:	85 c0                	test   %eax,%eax
c0100f0e:	74 0c                	je     c0100f1c <__intr_save+0x23>
        intr_disable();
c0100f10:	e8 1d 11 00 00       	call   c0102032 <intr_disable>
        return 1;
c0100f15:	b8 01 00 00 00       	mov    $0x1,%eax
c0100f1a:	eb 05                	jmp    c0100f21 <__intr_save+0x28>
    }
    return 0;
c0100f1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100f21:	c9                   	leave  
c0100f22:	c3                   	ret    

c0100f23 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100f23:	55                   	push   %ebp
c0100f24:	89 e5                	mov    %esp,%ebp
c0100f26:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100f29:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100f2d:	74 05                	je     c0100f34 <__intr_restore+0x11>
        intr_enable();
c0100f2f:	e8 f8 10 00 00       	call   c010202c <intr_enable>
    }
}
c0100f34:	c9                   	leave  
c0100f35:	c3                   	ret    

c0100f36 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100f36:	55                   	push   %ebp
c0100f37:	89 e5                	mov    %esp,%ebp
c0100f39:	83 ec 10             	sub    $0x10,%esp
c0100f3c:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f42:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100f46:	89 c2                	mov    %eax,%edx
c0100f48:	ec                   	in     (%dx),%al
c0100f49:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100f4c:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100f52:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100f56:	89 c2                	mov    %eax,%edx
c0100f58:	ec                   	in     (%dx),%al
c0100f59:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100f5c:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100f62:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f66:	89 c2                	mov    %eax,%edx
c0100f68:	ec                   	in     (%dx),%al
c0100f69:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100f6c:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100f72:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f76:	89 c2                	mov    %eax,%edx
c0100f78:	ec                   	in     (%dx),%al
c0100f79:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100f7c:	c9                   	leave  
c0100f7d:	c3                   	ret    

c0100f7e <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100f7e:	55                   	push   %ebp
c0100f7f:	89 e5                	mov    %esp,%ebp
c0100f81:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100f84:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100f8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f8e:	0f b7 00             	movzwl (%eax),%eax
c0100f91:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100f95:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f98:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100f9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fa0:	0f b7 00             	movzwl (%eax),%eax
c0100fa3:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100fa7:	74 12                	je     c0100fbb <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100fa9:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100fb0:	66 c7 05 26 e2 1a c0 	movw   $0x3b4,0xc01ae226
c0100fb7:	b4 03 
c0100fb9:	eb 13                	jmp    c0100fce <cga_init+0x50>
    } else {
        *cp = was;
c0100fbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fbe:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100fc2:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100fc5:	66 c7 05 26 e2 1a c0 	movw   $0x3d4,0xc01ae226
c0100fcc:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100fce:	0f b7 05 26 e2 1a c0 	movzwl 0xc01ae226,%eax
c0100fd5:	0f b7 c0             	movzwl %ax,%eax
c0100fd8:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100fdc:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fe0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fe4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100fe8:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100fe9:	0f b7 05 26 e2 1a c0 	movzwl 0xc01ae226,%eax
c0100ff0:	83 c0 01             	add    $0x1,%eax
c0100ff3:	0f b7 c0             	movzwl %ax,%eax
c0100ff6:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ffa:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100ffe:	89 c2                	mov    %eax,%edx
c0101000:	ec                   	in     (%dx),%al
c0101001:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101004:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101008:	0f b6 c0             	movzbl %al,%eax
c010100b:	c1 e0 08             	shl    $0x8,%eax
c010100e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0101011:	0f b7 05 26 e2 1a c0 	movzwl 0xc01ae226,%eax
c0101018:	0f b7 c0             	movzwl %ax,%eax
c010101b:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c010101f:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101023:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101027:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010102b:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c010102c:	0f b7 05 26 e2 1a c0 	movzwl 0xc01ae226,%eax
c0101033:	83 c0 01             	add    $0x1,%eax
c0101036:	0f b7 c0             	movzwl %ax,%eax
c0101039:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010103d:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0101041:	89 c2                	mov    %eax,%edx
c0101043:	ec                   	in     (%dx),%al
c0101044:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0101047:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010104b:	0f b6 c0             	movzbl %al,%eax
c010104e:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0101051:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101054:	a3 20 e2 1a c0       	mov    %eax,0xc01ae220
    crt_pos = pos;
c0101059:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010105c:	66 a3 24 e2 1a c0    	mov    %ax,0xc01ae224
}
c0101062:	c9                   	leave  
c0101063:	c3                   	ret    

c0101064 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0101064:	55                   	push   %ebp
c0101065:	89 e5                	mov    %esp,%ebp
c0101067:	83 ec 48             	sub    $0x48,%esp
c010106a:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0101070:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101074:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101078:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010107c:	ee                   	out    %al,(%dx)
c010107d:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0101083:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0101087:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010108b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010108f:	ee                   	out    %al,(%dx)
c0101090:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0101096:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c010109a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010109e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010a2:	ee                   	out    %al,(%dx)
c01010a3:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c01010a9:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c01010ad:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01010b1:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01010b5:	ee                   	out    %al,(%dx)
c01010b6:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c01010bc:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c01010c0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01010c4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01010c8:	ee                   	out    %al,(%dx)
c01010c9:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c01010cf:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c01010d3:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01010d7:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01010db:	ee                   	out    %al,(%dx)
c01010dc:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c01010e2:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c01010e6:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01010ea:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01010ee:	ee                   	out    %al,(%dx)
c01010ef:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01010f5:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c01010f9:	89 c2                	mov    %eax,%edx
c01010fb:	ec                   	in     (%dx),%al
c01010fc:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c01010ff:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101103:	3c ff                	cmp    $0xff,%al
c0101105:	0f 95 c0             	setne  %al
c0101108:	0f b6 c0             	movzbl %al,%eax
c010110b:	a3 28 e2 1a c0       	mov    %eax,0xc01ae228
c0101110:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101116:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c010111a:	89 c2                	mov    %eax,%edx
c010111c:	ec                   	in     (%dx),%al
c010111d:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101120:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0101126:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c010112a:	89 c2                	mov    %eax,%edx
c010112c:	ec                   	in     (%dx),%al
c010112d:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101130:	a1 28 e2 1a c0       	mov    0xc01ae228,%eax
c0101135:	85 c0                	test   %eax,%eax
c0101137:	74 0c                	je     c0101145 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101139:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101140:	e8 4b 0f 00 00       	call   c0102090 <pic_enable>
    }
}
c0101145:	c9                   	leave  
c0101146:	c3                   	ret    

c0101147 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101147:	55                   	push   %ebp
c0101148:	89 e5                	mov    %esp,%ebp
c010114a:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010114d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101154:	eb 09                	jmp    c010115f <lpt_putc_sub+0x18>
        delay();
c0101156:	e8 db fd ff ff       	call   c0100f36 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010115b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010115f:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101165:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101169:	89 c2                	mov    %eax,%edx
c010116b:	ec                   	in     (%dx),%al
c010116c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010116f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101173:	84 c0                	test   %al,%al
c0101175:	78 09                	js     c0101180 <lpt_putc_sub+0x39>
c0101177:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010117e:	7e d6                	jle    c0101156 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0101180:	8b 45 08             	mov    0x8(%ebp),%eax
c0101183:	0f b6 c0             	movzbl %al,%eax
c0101186:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c010118c:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010118f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101193:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101197:	ee                   	out    %al,(%dx)
c0101198:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c010119e:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01011a2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01011a6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011aa:	ee                   	out    %al,(%dx)
c01011ab:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01011b1:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01011b5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01011b9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01011bd:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01011be:	c9                   	leave  
c01011bf:	c3                   	ret    

c01011c0 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01011c0:	55                   	push   %ebp
c01011c1:	89 e5                	mov    %esp,%ebp
c01011c3:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01011c6:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01011ca:	74 0d                	je     c01011d9 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01011cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01011cf:	89 04 24             	mov    %eax,(%esp)
c01011d2:	e8 70 ff ff ff       	call   c0101147 <lpt_putc_sub>
c01011d7:	eb 24                	jmp    c01011fd <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01011d9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01011e0:	e8 62 ff ff ff       	call   c0101147 <lpt_putc_sub>
        lpt_putc_sub(' ');
c01011e5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01011ec:	e8 56 ff ff ff       	call   c0101147 <lpt_putc_sub>
        lpt_putc_sub('\b');
c01011f1:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01011f8:	e8 4a ff ff ff       	call   c0101147 <lpt_putc_sub>
    }
}
c01011fd:	c9                   	leave  
c01011fe:	c3                   	ret    

c01011ff <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01011ff:	55                   	push   %ebp
c0101200:	89 e5                	mov    %esp,%ebp
c0101202:	53                   	push   %ebx
c0101203:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101206:	8b 45 08             	mov    0x8(%ebp),%eax
c0101209:	b0 00                	mov    $0x0,%al
c010120b:	85 c0                	test   %eax,%eax
c010120d:	75 07                	jne    c0101216 <cga_putc+0x17>
        c |= 0x0700;
c010120f:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101216:	8b 45 08             	mov    0x8(%ebp),%eax
c0101219:	0f b6 c0             	movzbl %al,%eax
c010121c:	83 f8 0a             	cmp    $0xa,%eax
c010121f:	74 4c                	je     c010126d <cga_putc+0x6e>
c0101221:	83 f8 0d             	cmp    $0xd,%eax
c0101224:	74 57                	je     c010127d <cga_putc+0x7e>
c0101226:	83 f8 08             	cmp    $0x8,%eax
c0101229:	0f 85 88 00 00 00    	jne    c01012b7 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c010122f:	0f b7 05 24 e2 1a c0 	movzwl 0xc01ae224,%eax
c0101236:	66 85 c0             	test   %ax,%ax
c0101239:	74 30                	je     c010126b <cga_putc+0x6c>
            crt_pos --;
c010123b:	0f b7 05 24 e2 1a c0 	movzwl 0xc01ae224,%eax
c0101242:	83 e8 01             	sub    $0x1,%eax
c0101245:	66 a3 24 e2 1a c0    	mov    %ax,0xc01ae224
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c010124b:	a1 20 e2 1a c0       	mov    0xc01ae220,%eax
c0101250:	0f b7 15 24 e2 1a c0 	movzwl 0xc01ae224,%edx
c0101257:	0f b7 d2             	movzwl %dx,%edx
c010125a:	01 d2                	add    %edx,%edx
c010125c:	01 c2                	add    %eax,%edx
c010125e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101261:	b0 00                	mov    $0x0,%al
c0101263:	83 c8 20             	or     $0x20,%eax
c0101266:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101269:	eb 72                	jmp    c01012dd <cga_putc+0xde>
c010126b:	eb 70                	jmp    c01012dd <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c010126d:	0f b7 05 24 e2 1a c0 	movzwl 0xc01ae224,%eax
c0101274:	83 c0 50             	add    $0x50,%eax
c0101277:	66 a3 24 e2 1a c0    	mov    %ax,0xc01ae224
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c010127d:	0f b7 1d 24 e2 1a c0 	movzwl 0xc01ae224,%ebx
c0101284:	0f b7 0d 24 e2 1a c0 	movzwl 0xc01ae224,%ecx
c010128b:	0f b7 c1             	movzwl %cx,%eax
c010128e:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c0101294:	c1 e8 10             	shr    $0x10,%eax
c0101297:	89 c2                	mov    %eax,%edx
c0101299:	66 c1 ea 06          	shr    $0x6,%dx
c010129d:	89 d0                	mov    %edx,%eax
c010129f:	c1 e0 02             	shl    $0x2,%eax
c01012a2:	01 d0                	add    %edx,%eax
c01012a4:	c1 e0 04             	shl    $0x4,%eax
c01012a7:	29 c1                	sub    %eax,%ecx
c01012a9:	89 ca                	mov    %ecx,%edx
c01012ab:	89 d8                	mov    %ebx,%eax
c01012ad:	29 d0                	sub    %edx,%eax
c01012af:	66 a3 24 e2 1a c0    	mov    %ax,0xc01ae224
        break;
c01012b5:	eb 26                	jmp    c01012dd <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01012b7:	8b 0d 20 e2 1a c0    	mov    0xc01ae220,%ecx
c01012bd:	0f b7 05 24 e2 1a c0 	movzwl 0xc01ae224,%eax
c01012c4:	8d 50 01             	lea    0x1(%eax),%edx
c01012c7:	66 89 15 24 e2 1a c0 	mov    %dx,0xc01ae224
c01012ce:	0f b7 c0             	movzwl %ax,%eax
c01012d1:	01 c0                	add    %eax,%eax
c01012d3:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01012d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01012d9:	66 89 02             	mov    %ax,(%edx)
        break;
c01012dc:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01012dd:	0f b7 05 24 e2 1a c0 	movzwl 0xc01ae224,%eax
c01012e4:	66 3d cf 07          	cmp    $0x7cf,%ax
c01012e8:	76 5b                	jbe    c0101345 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01012ea:	a1 20 e2 1a c0       	mov    0xc01ae220,%eax
c01012ef:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01012f5:	a1 20 e2 1a c0       	mov    0xc01ae220,%eax
c01012fa:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101301:	00 
c0101302:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101306:	89 04 24             	mov    %eax,(%esp)
c0101309:	e8 4f af 00 00       	call   c010c25d <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010130e:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101315:	eb 15                	jmp    c010132c <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101317:	a1 20 e2 1a c0       	mov    0xc01ae220,%eax
c010131c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010131f:	01 d2                	add    %edx,%edx
c0101321:	01 d0                	add    %edx,%eax
c0101323:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101328:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010132c:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101333:	7e e2                	jle    c0101317 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101335:	0f b7 05 24 e2 1a c0 	movzwl 0xc01ae224,%eax
c010133c:	83 e8 50             	sub    $0x50,%eax
c010133f:	66 a3 24 e2 1a c0    	mov    %ax,0xc01ae224
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101345:	0f b7 05 26 e2 1a c0 	movzwl 0xc01ae226,%eax
c010134c:	0f b7 c0             	movzwl %ax,%eax
c010134f:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101353:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101357:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010135b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010135f:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101360:	0f b7 05 24 e2 1a c0 	movzwl 0xc01ae224,%eax
c0101367:	66 c1 e8 08          	shr    $0x8,%ax
c010136b:	0f b6 c0             	movzbl %al,%eax
c010136e:	0f b7 15 26 e2 1a c0 	movzwl 0xc01ae226,%edx
c0101375:	83 c2 01             	add    $0x1,%edx
c0101378:	0f b7 d2             	movzwl %dx,%edx
c010137b:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c010137f:	88 45 ed             	mov    %al,-0x13(%ebp)
c0101382:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101386:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010138a:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c010138b:	0f b7 05 26 e2 1a c0 	movzwl 0xc01ae226,%eax
c0101392:	0f b7 c0             	movzwl %ax,%eax
c0101395:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101399:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c010139d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01013a1:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01013a5:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01013a6:	0f b7 05 24 e2 1a c0 	movzwl 0xc01ae224,%eax
c01013ad:	0f b6 c0             	movzbl %al,%eax
c01013b0:	0f b7 15 26 e2 1a c0 	movzwl 0xc01ae226,%edx
c01013b7:	83 c2 01             	add    $0x1,%edx
c01013ba:	0f b7 d2             	movzwl %dx,%edx
c01013bd:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01013c1:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01013c4:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01013c8:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01013cc:	ee                   	out    %al,(%dx)
}
c01013cd:	83 c4 34             	add    $0x34,%esp
c01013d0:	5b                   	pop    %ebx
c01013d1:	5d                   	pop    %ebp
c01013d2:	c3                   	ret    

c01013d3 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01013d3:	55                   	push   %ebp
c01013d4:	89 e5                	mov    %esp,%ebp
c01013d6:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01013d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01013e0:	eb 09                	jmp    c01013eb <serial_putc_sub+0x18>
        delay();
c01013e2:	e8 4f fb ff ff       	call   c0100f36 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01013e7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01013eb:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013f1:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013f5:	89 c2                	mov    %eax,%edx
c01013f7:	ec                   	in     (%dx),%al
c01013f8:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013fb:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01013ff:	0f b6 c0             	movzbl %al,%eax
c0101402:	83 e0 20             	and    $0x20,%eax
c0101405:	85 c0                	test   %eax,%eax
c0101407:	75 09                	jne    c0101412 <serial_putc_sub+0x3f>
c0101409:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101410:	7e d0                	jle    c01013e2 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101412:	8b 45 08             	mov    0x8(%ebp),%eax
c0101415:	0f b6 c0             	movzbl %al,%eax
c0101418:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010141e:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101421:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101425:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101429:	ee                   	out    %al,(%dx)
}
c010142a:	c9                   	leave  
c010142b:	c3                   	ret    

c010142c <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c010142c:	55                   	push   %ebp
c010142d:	89 e5                	mov    %esp,%ebp
c010142f:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101432:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101436:	74 0d                	je     c0101445 <serial_putc+0x19>
        serial_putc_sub(c);
c0101438:	8b 45 08             	mov    0x8(%ebp),%eax
c010143b:	89 04 24             	mov    %eax,(%esp)
c010143e:	e8 90 ff ff ff       	call   c01013d3 <serial_putc_sub>
c0101443:	eb 24                	jmp    c0101469 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101445:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010144c:	e8 82 ff ff ff       	call   c01013d3 <serial_putc_sub>
        serial_putc_sub(' ');
c0101451:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101458:	e8 76 ff ff ff       	call   c01013d3 <serial_putc_sub>
        serial_putc_sub('\b');
c010145d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101464:	e8 6a ff ff ff       	call   c01013d3 <serial_putc_sub>
    }
}
c0101469:	c9                   	leave  
c010146a:	c3                   	ret    

c010146b <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010146b:	55                   	push   %ebp
c010146c:	89 e5                	mov    %esp,%ebp
c010146e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101471:	eb 33                	jmp    c01014a6 <cons_intr+0x3b>
        if (c != 0) {
c0101473:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101477:	74 2d                	je     c01014a6 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101479:	a1 44 e4 1a c0       	mov    0xc01ae444,%eax
c010147e:	8d 50 01             	lea    0x1(%eax),%edx
c0101481:	89 15 44 e4 1a c0    	mov    %edx,0xc01ae444
c0101487:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010148a:	88 90 40 e2 1a c0    	mov    %dl,-0x3fe51dc0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101490:	a1 44 e4 1a c0       	mov    0xc01ae444,%eax
c0101495:	3d 00 02 00 00       	cmp    $0x200,%eax
c010149a:	75 0a                	jne    c01014a6 <cons_intr+0x3b>
                cons.wpos = 0;
c010149c:	c7 05 44 e4 1a c0 00 	movl   $0x0,0xc01ae444
c01014a3:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01014a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01014a9:	ff d0                	call   *%eax
c01014ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01014ae:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01014b2:	75 bf                	jne    c0101473 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01014b4:	c9                   	leave  
c01014b5:	c3                   	ret    

c01014b6 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01014b6:	55                   	push   %ebp
c01014b7:	89 e5                	mov    %esp,%ebp
c01014b9:	83 ec 10             	sub    $0x10,%esp
c01014bc:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014c2:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01014c6:	89 c2                	mov    %eax,%edx
c01014c8:	ec                   	in     (%dx),%al
c01014c9:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01014cc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01014d0:	0f b6 c0             	movzbl %al,%eax
c01014d3:	83 e0 01             	and    $0x1,%eax
c01014d6:	85 c0                	test   %eax,%eax
c01014d8:	75 07                	jne    c01014e1 <serial_proc_data+0x2b>
        return -1;
c01014da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014df:	eb 2a                	jmp    c010150b <serial_proc_data+0x55>
c01014e1:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014e7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01014eb:	89 c2                	mov    %eax,%edx
c01014ed:	ec                   	in     (%dx),%al
c01014ee:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01014f1:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01014f5:	0f b6 c0             	movzbl %al,%eax
c01014f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01014fb:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01014ff:	75 07                	jne    c0101508 <serial_proc_data+0x52>
        c = '\b';
c0101501:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101508:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010150b:	c9                   	leave  
c010150c:	c3                   	ret    

c010150d <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c010150d:	55                   	push   %ebp
c010150e:	89 e5                	mov    %esp,%ebp
c0101510:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101513:	a1 28 e2 1a c0       	mov    0xc01ae228,%eax
c0101518:	85 c0                	test   %eax,%eax
c010151a:	74 0c                	je     c0101528 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c010151c:	c7 04 24 b6 14 10 c0 	movl   $0xc01014b6,(%esp)
c0101523:	e8 43 ff ff ff       	call   c010146b <cons_intr>
    }
}
c0101528:	c9                   	leave  
c0101529:	c3                   	ret    

c010152a <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c010152a:	55                   	push   %ebp
c010152b:	89 e5                	mov    %esp,%ebp
c010152d:	83 ec 38             	sub    $0x38,%esp
c0101530:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101536:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010153a:	89 c2                	mov    %eax,%edx
c010153c:	ec                   	in     (%dx),%al
c010153d:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101540:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101544:	0f b6 c0             	movzbl %al,%eax
c0101547:	83 e0 01             	and    $0x1,%eax
c010154a:	85 c0                	test   %eax,%eax
c010154c:	75 0a                	jne    c0101558 <kbd_proc_data+0x2e>
        return -1;
c010154e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101553:	e9 59 01 00 00       	jmp    c01016b1 <kbd_proc_data+0x187>
c0101558:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010155e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101562:	89 c2                	mov    %eax,%edx
c0101564:	ec                   	in     (%dx),%al
c0101565:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101568:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c010156c:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c010156f:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101573:	75 17                	jne    c010158c <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101575:	a1 48 e4 1a c0       	mov    0xc01ae448,%eax
c010157a:	83 c8 40             	or     $0x40,%eax
c010157d:	a3 48 e4 1a c0       	mov    %eax,0xc01ae448
        return 0;
c0101582:	b8 00 00 00 00       	mov    $0x0,%eax
c0101587:	e9 25 01 00 00       	jmp    c01016b1 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c010158c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101590:	84 c0                	test   %al,%al
c0101592:	79 47                	jns    c01015db <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101594:	a1 48 e4 1a c0       	mov    0xc01ae448,%eax
c0101599:	83 e0 40             	and    $0x40,%eax
c010159c:	85 c0                	test   %eax,%eax
c010159e:	75 09                	jne    c01015a9 <kbd_proc_data+0x7f>
c01015a0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015a4:	83 e0 7f             	and    $0x7f,%eax
c01015a7:	eb 04                	jmp    c01015ad <kbd_proc_data+0x83>
c01015a9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015ad:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01015b0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015b4:	0f b6 80 60 c0 12 c0 	movzbl -0x3fed3fa0(%eax),%eax
c01015bb:	83 c8 40             	or     $0x40,%eax
c01015be:	0f b6 c0             	movzbl %al,%eax
c01015c1:	f7 d0                	not    %eax
c01015c3:	89 c2                	mov    %eax,%edx
c01015c5:	a1 48 e4 1a c0       	mov    0xc01ae448,%eax
c01015ca:	21 d0                	and    %edx,%eax
c01015cc:	a3 48 e4 1a c0       	mov    %eax,0xc01ae448
        return 0;
c01015d1:	b8 00 00 00 00       	mov    $0x0,%eax
c01015d6:	e9 d6 00 00 00       	jmp    c01016b1 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01015db:	a1 48 e4 1a c0       	mov    0xc01ae448,%eax
c01015e0:	83 e0 40             	and    $0x40,%eax
c01015e3:	85 c0                	test   %eax,%eax
c01015e5:	74 11                	je     c01015f8 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01015e7:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01015eb:	a1 48 e4 1a c0       	mov    0xc01ae448,%eax
c01015f0:	83 e0 bf             	and    $0xffffffbf,%eax
c01015f3:	a3 48 e4 1a c0       	mov    %eax,0xc01ae448
    }

    shift |= shiftcode[data];
c01015f8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015fc:	0f b6 80 60 c0 12 c0 	movzbl -0x3fed3fa0(%eax),%eax
c0101603:	0f b6 d0             	movzbl %al,%edx
c0101606:	a1 48 e4 1a c0       	mov    0xc01ae448,%eax
c010160b:	09 d0                	or     %edx,%eax
c010160d:	a3 48 e4 1a c0       	mov    %eax,0xc01ae448
    shift ^= togglecode[data];
c0101612:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101616:	0f b6 80 60 c1 12 c0 	movzbl -0x3fed3ea0(%eax),%eax
c010161d:	0f b6 d0             	movzbl %al,%edx
c0101620:	a1 48 e4 1a c0       	mov    0xc01ae448,%eax
c0101625:	31 d0                	xor    %edx,%eax
c0101627:	a3 48 e4 1a c0       	mov    %eax,0xc01ae448

    c = charcode[shift & (CTL | SHIFT)][data];
c010162c:	a1 48 e4 1a c0       	mov    0xc01ae448,%eax
c0101631:	83 e0 03             	and    $0x3,%eax
c0101634:	8b 14 85 60 c5 12 c0 	mov    -0x3fed3aa0(,%eax,4),%edx
c010163b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010163f:	01 d0                	add    %edx,%eax
c0101641:	0f b6 00             	movzbl (%eax),%eax
c0101644:	0f b6 c0             	movzbl %al,%eax
c0101647:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c010164a:	a1 48 e4 1a c0       	mov    0xc01ae448,%eax
c010164f:	83 e0 08             	and    $0x8,%eax
c0101652:	85 c0                	test   %eax,%eax
c0101654:	74 22                	je     c0101678 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101656:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c010165a:	7e 0c                	jle    c0101668 <kbd_proc_data+0x13e>
c010165c:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101660:	7f 06                	jg     c0101668 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101662:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101666:	eb 10                	jmp    c0101678 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101668:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c010166c:	7e 0a                	jle    c0101678 <kbd_proc_data+0x14e>
c010166e:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101672:	7f 04                	jg     c0101678 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101674:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101678:	a1 48 e4 1a c0       	mov    0xc01ae448,%eax
c010167d:	f7 d0                	not    %eax
c010167f:	83 e0 06             	and    $0x6,%eax
c0101682:	85 c0                	test   %eax,%eax
c0101684:	75 28                	jne    c01016ae <kbd_proc_data+0x184>
c0101686:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c010168d:	75 1f                	jne    c01016ae <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c010168f:	c7 04 24 dd c6 10 c0 	movl   $0xc010c6dd,(%esp)
c0101696:	e8 bd ec ff ff       	call   c0100358 <cprintf>
c010169b:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01016a1:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016a5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01016a9:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01016ad:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01016ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016b1:	c9                   	leave  
c01016b2:	c3                   	ret    

c01016b3 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01016b3:	55                   	push   %ebp
c01016b4:	89 e5                	mov    %esp,%ebp
c01016b6:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01016b9:	c7 04 24 2a 15 10 c0 	movl   $0xc010152a,(%esp)
c01016c0:	e8 a6 fd ff ff       	call   c010146b <cons_intr>
}
c01016c5:	c9                   	leave  
c01016c6:	c3                   	ret    

c01016c7 <kbd_init>:

static void
kbd_init(void) {
c01016c7:	55                   	push   %ebp
c01016c8:	89 e5                	mov    %esp,%ebp
c01016ca:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01016cd:	e8 e1 ff ff ff       	call   c01016b3 <kbd_intr>
    pic_enable(IRQ_KBD);
c01016d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01016d9:	e8 b2 09 00 00       	call   c0102090 <pic_enable>
}
c01016de:	c9                   	leave  
c01016df:	c3                   	ret    

c01016e0 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01016e0:	55                   	push   %ebp
c01016e1:	89 e5                	mov    %esp,%ebp
c01016e3:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01016e6:	e8 93 f8 ff ff       	call   c0100f7e <cga_init>
    serial_init();
c01016eb:	e8 74 f9 ff ff       	call   c0101064 <serial_init>
    kbd_init();
c01016f0:	e8 d2 ff ff ff       	call   c01016c7 <kbd_init>
    if (!serial_exists) {
c01016f5:	a1 28 e2 1a c0       	mov    0xc01ae228,%eax
c01016fa:	85 c0                	test   %eax,%eax
c01016fc:	75 0c                	jne    c010170a <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c01016fe:	c7 04 24 e9 c6 10 c0 	movl   $0xc010c6e9,(%esp)
c0101705:	e8 4e ec ff ff       	call   c0100358 <cprintf>
    }
}
c010170a:	c9                   	leave  
c010170b:	c3                   	ret    

c010170c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010170c:	55                   	push   %ebp
c010170d:	89 e5                	mov    %esp,%ebp
c010170f:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101712:	e8 e2 f7 ff ff       	call   c0100ef9 <__intr_save>
c0101717:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010171a:	8b 45 08             	mov    0x8(%ebp),%eax
c010171d:	89 04 24             	mov    %eax,(%esp)
c0101720:	e8 9b fa ff ff       	call   c01011c0 <lpt_putc>
        cga_putc(c);
c0101725:	8b 45 08             	mov    0x8(%ebp),%eax
c0101728:	89 04 24             	mov    %eax,(%esp)
c010172b:	e8 cf fa ff ff       	call   c01011ff <cga_putc>
        serial_putc(c);
c0101730:	8b 45 08             	mov    0x8(%ebp),%eax
c0101733:	89 04 24             	mov    %eax,(%esp)
c0101736:	e8 f1 fc ff ff       	call   c010142c <serial_putc>
    }
    local_intr_restore(intr_flag);
c010173b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010173e:	89 04 24             	mov    %eax,(%esp)
c0101741:	e8 dd f7 ff ff       	call   c0100f23 <__intr_restore>
}
c0101746:	c9                   	leave  
c0101747:	c3                   	ret    

c0101748 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101748:	55                   	push   %ebp
c0101749:	89 e5                	mov    %esp,%ebp
c010174b:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c010174e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101755:	e8 9f f7 ff ff       	call   c0100ef9 <__intr_save>
c010175a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c010175d:	e8 ab fd ff ff       	call   c010150d <serial_intr>
        kbd_intr();
c0101762:	e8 4c ff ff ff       	call   c01016b3 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101767:	8b 15 40 e4 1a c0    	mov    0xc01ae440,%edx
c010176d:	a1 44 e4 1a c0       	mov    0xc01ae444,%eax
c0101772:	39 c2                	cmp    %eax,%edx
c0101774:	74 31                	je     c01017a7 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101776:	a1 40 e4 1a c0       	mov    0xc01ae440,%eax
c010177b:	8d 50 01             	lea    0x1(%eax),%edx
c010177e:	89 15 40 e4 1a c0    	mov    %edx,0xc01ae440
c0101784:	0f b6 80 40 e2 1a c0 	movzbl -0x3fe51dc0(%eax),%eax
c010178b:	0f b6 c0             	movzbl %al,%eax
c010178e:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101791:	a1 40 e4 1a c0       	mov    0xc01ae440,%eax
c0101796:	3d 00 02 00 00       	cmp    $0x200,%eax
c010179b:	75 0a                	jne    c01017a7 <cons_getc+0x5f>
                cons.rpos = 0;
c010179d:	c7 05 40 e4 1a c0 00 	movl   $0x0,0xc01ae440
c01017a4:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01017a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01017aa:	89 04 24             	mov    %eax,(%esp)
c01017ad:	e8 71 f7 ff ff       	call   c0100f23 <__intr_restore>
    return c;
c01017b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01017b5:	c9                   	leave  
c01017b6:	c3                   	ret    

c01017b7 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c01017b7:	55                   	push   %ebp
c01017b8:	89 e5                	mov    %esp,%ebp
c01017ba:	83 ec 14             	sub    $0x14,%esp
c01017bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01017c0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c01017c4:	90                   	nop
c01017c5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01017c9:	83 c0 07             	add    $0x7,%eax
c01017cc:	0f b7 c0             	movzwl %ax,%eax
c01017cf:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017d3:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01017d7:	89 c2                	mov    %eax,%edx
c01017d9:	ec                   	in     (%dx),%al
c01017da:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01017dd:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01017e1:	0f b6 c0             	movzbl %al,%eax
c01017e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01017e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017ea:	25 80 00 00 00       	and    $0x80,%eax
c01017ef:	85 c0                	test   %eax,%eax
c01017f1:	75 d2                	jne    c01017c5 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c01017f3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01017f7:	74 11                	je     c010180a <ide_wait_ready+0x53>
c01017f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017fc:	83 e0 21             	and    $0x21,%eax
c01017ff:	85 c0                	test   %eax,%eax
c0101801:	74 07                	je     c010180a <ide_wait_ready+0x53>
        return -1;
c0101803:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101808:	eb 05                	jmp    c010180f <ide_wait_ready+0x58>
    }
    return 0;
c010180a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010180f:	c9                   	leave  
c0101810:	c3                   	ret    

c0101811 <ide_init>:

void
ide_init(void) {
c0101811:	55                   	push   %ebp
c0101812:	89 e5                	mov    %esp,%ebp
c0101814:	57                   	push   %edi
c0101815:	53                   	push   %ebx
c0101816:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c010181c:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0101822:	e9 d6 02 00 00       	jmp    c0101afd <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0101827:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010182b:	c1 e0 03             	shl    $0x3,%eax
c010182e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101835:	29 c2                	sub    %eax,%edx
c0101837:	8d 82 60 e4 1a c0    	lea    -0x3fe51ba0(%edx),%eax
c010183d:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0101840:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101844:	66 d1 e8             	shr    %ax
c0101847:	0f b7 c0             	movzwl %ax,%eax
c010184a:	0f b7 04 85 08 c7 10 	movzwl -0x3fef38f8(,%eax,4),%eax
c0101851:	c0 
c0101852:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0101856:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010185a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101861:	00 
c0101862:	89 04 24             	mov    %eax,(%esp)
c0101865:	e8 4d ff ff ff       	call   c01017b7 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c010186a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010186e:	83 e0 01             	and    $0x1,%eax
c0101871:	c1 e0 04             	shl    $0x4,%eax
c0101874:	83 c8 e0             	or     $0xffffffe0,%eax
c0101877:	0f b6 c0             	movzbl %al,%eax
c010187a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010187e:	83 c2 06             	add    $0x6,%edx
c0101881:	0f b7 d2             	movzwl %dx,%edx
c0101884:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c0101888:	88 45 d1             	mov    %al,-0x2f(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010188b:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010188f:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101893:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0101894:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101898:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010189f:	00 
c01018a0:	89 04 24             	mov    %eax,(%esp)
c01018a3:	e8 0f ff ff ff       	call   c01017b7 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c01018a8:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018ac:	83 c0 07             	add    $0x7,%eax
c01018af:	0f b7 c0             	movzwl %ax,%eax
c01018b2:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c01018b6:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c01018ba:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01018be:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01018c2:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01018c3:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01018ce:	00 
c01018cf:	89 04 24             	mov    %eax,(%esp)
c01018d2:	e8 e0 fe ff ff       	call   c01017b7 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c01018d7:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018db:	83 c0 07             	add    $0x7,%eax
c01018de:	0f b7 c0             	movzwl %ax,%eax
c01018e1:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01018e5:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c01018e9:	89 c2                	mov    %eax,%edx
c01018eb:	ec                   	in     (%dx),%al
c01018ec:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c01018ef:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01018f3:	84 c0                	test   %al,%al
c01018f5:	0f 84 f7 01 00 00    	je     c0101af2 <ide_init+0x2e1>
c01018fb:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018ff:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101906:	00 
c0101907:	89 04 24             	mov    %eax,(%esp)
c010190a:	e8 a8 fe ff ff       	call   c01017b7 <ide_wait_ready>
c010190f:	85 c0                	test   %eax,%eax
c0101911:	0f 85 db 01 00 00    	jne    c0101af2 <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0101917:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010191b:	c1 e0 03             	shl    $0x3,%eax
c010191e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101925:	29 c2                	sub    %eax,%edx
c0101927:	8d 82 60 e4 1a c0    	lea    -0x3fe51ba0(%edx),%eax
c010192d:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0101930:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101934:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0101937:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c010193d:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0101940:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101947:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010194a:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c010194d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0101950:	89 cb                	mov    %ecx,%ebx
c0101952:	89 df                	mov    %ebx,%edi
c0101954:	89 c1                	mov    %eax,%ecx
c0101956:	fc                   	cld    
c0101957:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101959:	89 c8                	mov    %ecx,%eax
c010195b:	89 fb                	mov    %edi,%ebx
c010195d:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0101960:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0101963:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101969:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c010196c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010196f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0101975:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0101978:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010197b:	25 00 00 00 04       	and    $0x4000000,%eax
c0101980:	85 c0                	test   %eax,%eax
c0101982:	74 0e                	je     c0101992 <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0101984:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101987:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c010198d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0101990:	eb 09                	jmp    c010199b <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0101992:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101995:	8b 40 78             	mov    0x78(%eax),%eax
c0101998:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c010199b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010199f:	c1 e0 03             	shl    $0x3,%eax
c01019a2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019a9:	29 c2                	sub    %eax,%edx
c01019ab:	81 c2 60 e4 1a c0    	add    $0xc01ae460,%edx
c01019b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01019b4:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c01019b7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019bb:	c1 e0 03             	shl    $0x3,%eax
c01019be:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019c5:	29 c2                	sub    %eax,%edx
c01019c7:	81 c2 60 e4 1a c0    	add    $0xc01ae460,%edx
c01019cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01019d0:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01019d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019d6:	83 c0 62             	add    $0x62,%eax
c01019d9:	0f b7 00             	movzwl (%eax),%eax
c01019dc:	0f b7 c0             	movzwl %ax,%eax
c01019df:	25 00 02 00 00       	and    $0x200,%eax
c01019e4:	85 c0                	test   %eax,%eax
c01019e6:	75 24                	jne    c0101a0c <ide_init+0x1fb>
c01019e8:	c7 44 24 0c 10 c7 10 	movl   $0xc010c710,0xc(%esp)
c01019ef:	c0 
c01019f0:	c7 44 24 08 53 c7 10 	movl   $0xc010c753,0x8(%esp)
c01019f7:	c0 
c01019f8:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01019ff:	00 
c0101a00:	c7 04 24 68 c7 10 c0 	movl   $0xc010c768,(%esp)
c0101a07:	e8 ce f3 ff ff       	call   c0100dda <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101a0c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a10:	c1 e0 03             	shl    $0x3,%eax
c0101a13:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101a1a:	29 c2                	sub    %eax,%edx
c0101a1c:	8d 82 60 e4 1a c0    	lea    -0x3fe51ba0(%edx),%eax
c0101a22:	83 c0 0c             	add    $0xc,%eax
c0101a25:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101a28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a2b:	83 c0 36             	add    $0x36,%eax
c0101a2e:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101a31:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101a38:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101a3f:	eb 34                	jmp    c0101a75 <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101a41:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a44:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a47:	01 c2                	add    %eax,%edx
c0101a49:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a4c:	8d 48 01             	lea    0x1(%eax),%ecx
c0101a4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101a52:	01 c8                	add    %ecx,%eax
c0101a54:	0f b6 00             	movzbl (%eax),%eax
c0101a57:	88 02                	mov    %al,(%edx)
c0101a59:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a5c:	8d 50 01             	lea    0x1(%eax),%edx
c0101a5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101a62:	01 c2                	add    %eax,%edx
c0101a64:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a67:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0101a6a:	01 c8                	add    %ecx,%eax
c0101a6c:	0f b6 00             	movzbl (%eax),%eax
c0101a6f:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c0101a71:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101a75:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a78:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101a7b:	72 c4                	jb     c0101a41 <ide_init+0x230>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0101a7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a80:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a83:	01 d0                	add    %edx,%eax
c0101a85:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101a88:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a8b:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101a8e:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101a91:	85 c0                	test   %eax,%eax
c0101a93:	74 0f                	je     c0101aa4 <ide_init+0x293>
c0101a95:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a98:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a9b:	01 d0                	add    %edx,%eax
c0101a9d:	0f b6 00             	movzbl (%eax),%eax
c0101aa0:	3c 20                	cmp    $0x20,%al
c0101aa2:	74 d9                	je     c0101a7d <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101aa4:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101aa8:	c1 e0 03             	shl    $0x3,%eax
c0101aab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101ab2:	29 c2                	sub    %eax,%edx
c0101ab4:	8d 82 60 e4 1a c0    	lea    -0x3fe51ba0(%edx),%eax
c0101aba:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101abd:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101ac1:	c1 e0 03             	shl    $0x3,%eax
c0101ac4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101acb:	29 c2                	sub    %eax,%edx
c0101acd:	8d 82 60 e4 1a c0    	lea    -0x3fe51ba0(%edx),%eax
c0101ad3:	8b 50 08             	mov    0x8(%eax),%edx
c0101ad6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101ada:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101ade:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae6:	c7 04 24 7a c7 10 c0 	movl   $0xc010c77a,(%esp)
c0101aed:	e8 66 e8 ff ff       	call   c0100358 <cprintf>

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101af2:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101af6:	83 c0 01             	add    $0x1,%eax
c0101af9:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101afd:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101b02:	0f 86 1f fd ff ff    	jbe    c0101827 <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101b08:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101b0f:	e8 7c 05 00 00       	call   c0102090 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101b14:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101b1b:	e8 70 05 00 00       	call   c0102090 <pic_enable>
}
c0101b20:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101b26:	5b                   	pop    %ebx
c0101b27:	5f                   	pop    %edi
c0101b28:	5d                   	pop    %ebp
c0101b29:	c3                   	ret    

c0101b2a <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101b2a:	55                   	push   %ebp
c0101b2b:	89 e5                	mov    %esp,%ebp
c0101b2d:	83 ec 04             	sub    $0x4,%esp
c0101b30:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b33:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101b37:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0101b3c:	77 24                	ja     c0101b62 <ide_device_valid+0x38>
c0101b3e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b42:	c1 e0 03             	shl    $0x3,%eax
c0101b45:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101b4c:	29 c2                	sub    %eax,%edx
c0101b4e:	8d 82 60 e4 1a c0    	lea    -0x3fe51ba0(%edx),%eax
c0101b54:	0f b6 00             	movzbl (%eax),%eax
c0101b57:	84 c0                	test   %al,%al
c0101b59:	74 07                	je     c0101b62 <ide_device_valid+0x38>
c0101b5b:	b8 01 00 00 00       	mov    $0x1,%eax
c0101b60:	eb 05                	jmp    c0101b67 <ide_device_valid+0x3d>
c0101b62:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101b67:	c9                   	leave  
c0101b68:	c3                   	ret    

c0101b69 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101b69:	55                   	push   %ebp
c0101b6a:	89 e5                	mov    %esp,%ebp
c0101b6c:	83 ec 08             	sub    $0x8,%esp
c0101b6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b72:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101b76:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b7a:	89 04 24             	mov    %eax,(%esp)
c0101b7d:	e8 a8 ff ff ff       	call   c0101b2a <ide_device_valid>
c0101b82:	85 c0                	test   %eax,%eax
c0101b84:	74 1b                	je     c0101ba1 <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101b86:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b8a:	c1 e0 03             	shl    $0x3,%eax
c0101b8d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101b94:	29 c2                	sub    %eax,%edx
c0101b96:	8d 82 60 e4 1a c0    	lea    -0x3fe51ba0(%edx),%eax
c0101b9c:	8b 40 08             	mov    0x8(%eax),%eax
c0101b9f:	eb 05                	jmp    c0101ba6 <ide_device_size+0x3d>
    }
    return 0;
c0101ba1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101ba6:	c9                   	leave  
c0101ba7:	c3                   	ret    

c0101ba8 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101ba8:	55                   	push   %ebp
c0101ba9:	89 e5                	mov    %esp,%ebp
c0101bab:	57                   	push   %edi
c0101bac:	53                   	push   %ebx
c0101bad:	83 ec 50             	sub    $0x50,%esp
c0101bb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bb3:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101bb7:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101bbe:	77 24                	ja     c0101be4 <ide_read_secs+0x3c>
c0101bc0:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101bc5:	77 1d                	ja     c0101be4 <ide_read_secs+0x3c>
c0101bc7:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bcb:	c1 e0 03             	shl    $0x3,%eax
c0101bce:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101bd5:	29 c2                	sub    %eax,%edx
c0101bd7:	8d 82 60 e4 1a c0    	lea    -0x3fe51ba0(%edx),%eax
c0101bdd:	0f b6 00             	movzbl (%eax),%eax
c0101be0:	84 c0                	test   %al,%al
c0101be2:	75 24                	jne    c0101c08 <ide_read_secs+0x60>
c0101be4:	c7 44 24 0c 98 c7 10 	movl   $0xc010c798,0xc(%esp)
c0101beb:	c0 
c0101bec:	c7 44 24 08 53 c7 10 	movl   $0xc010c753,0x8(%esp)
c0101bf3:	c0 
c0101bf4:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101bfb:	00 
c0101bfc:	c7 04 24 68 c7 10 c0 	movl   $0xc010c768,(%esp)
c0101c03:	e8 d2 f1 ff ff       	call   c0100dda <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101c08:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101c0f:	77 0f                	ja     c0101c20 <ide_read_secs+0x78>
c0101c11:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c14:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101c17:	01 d0                	add    %edx,%eax
c0101c19:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101c1e:	76 24                	jbe    c0101c44 <ide_read_secs+0x9c>
c0101c20:	c7 44 24 0c c0 c7 10 	movl   $0xc010c7c0,0xc(%esp)
c0101c27:	c0 
c0101c28:	c7 44 24 08 53 c7 10 	movl   $0xc010c753,0x8(%esp)
c0101c2f:	c0 
c0101c30:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101c37:	00 
c0101c38:	c7 04 24 68 c7 10 c0 	movl   $0xc010c768,(%esp)
c0101c3f:	e8 96 f1 ff ff       	call   c0100dda <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101c44:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c48:	66 d1 e8             	shr    %ax
c0101c4b:	0f b7 c0             	movzwl %ax,%eax
c0101c4e:	0f b7 04 85 08 c7 10 	movzwl -0x3fef38f8(,%eax,4),%eax
c0101c55:	c0 
c0101c56:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101c5a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c5e:	66 d1 e8             	shr    %ax
c0101c61:	0f b7 c0             	movzwl %ax,%eax
c0101c64:	0f b7 04 85 0a c7 10 	movzwl -0x3fef38f6(,%eax,4),%eax
c0101c6b:	c0 
c0101c6c:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101c70:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101c74:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101c7b:	00 
c0101c7c:	89 04 24             	mov    %eax,(%esp)
c0101c7f:	e8 33 fb ff ff       	call   c01017b7 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101c84:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101c88:	83 c0 02             	add    $0x2,%eax
c0101c8b:	0f b7 c0             	movzwl %ax,%eax
c0101c8e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101c92:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c96:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101c9a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101c9e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101c9f:	8b 45 14             	mov    0x14(%ebp),%eax
c0101ca2:	0f b6 c0             	movzbl %al,%eax
c0101ca5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ca9:	83 c2 02             	add    $0x2,%edx
c0101cac:	0f b7 d2             	movzwl %dx,%edx
c0101caf:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101cb3:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101cb6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101cba:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101cbe:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cc2:	0f b6 c0             	movzbl %al,%eax
c0101cc5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cc9:	83 c2 03             	add    $0x3,%edx
c0101ccc:	0f b7 d2             	movzwl %dx,%edx
c0101ccf:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101cd3:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101cd6:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101cda:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101cde:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101cdf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ce2:	c1 e8 08             	shr    $0x8,%eax
c0101ce5:	0f b6 c0             	movzbl %al,%eax
c0101ce8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cec:	83 c2 04             	add    $0x4,%edx
c0101cef:	0f b7 d2             	movzwl %dx,%edx
c0101cf2:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101cf6:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101cf9:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101cfd:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101d01:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101d02:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d05:	c1 e8 10             	shr    $0x10,%eax
c0101d08:	0f b6 c0             	movzbl %al,%eax
c0101d0b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d0f:	83 c2 05             	add    $0x5,%edx
c0101d12:	0f b7 d2             	movzwl %dx,%edx
c0101d15:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101d19:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101d1c:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101d20:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101d24:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101d25:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101d29:	83 e0 01             	and    $0x1,%eax
c0101d2c:	c1 e0 04             	shl    $0x4,%eax
c0101d2f:	89 c2                	mov    %eax,%edx
c0101d31:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d34:	c1 e8 18             	shr    $0x18,%eax
c0101d37:	83 e0 0f             	and    $0xf,%eax
c0101d3a:	09 d0                	or     %edx,%eax
c0101d3c:	83 c8 e0             	or     $0xffffffe0,%eax
c0101d3f:	0f b6 c0             	movzbl %al,%eax
c0101d42:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d46:	83 c2 06             	add    $0x6,%edx
c0101d49:	0f b7 d2             	movzwl %dx,%edx
c0101d4c:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101d50:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101d53:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101d57:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101d5b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101d5c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d60:	83 c0 07             	add    $0x7,%eax
c0101d63:	0f b7 c0             	movzwl %ax,%eax
c0101d66:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101d6a:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101d6e:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101d72:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101d76:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101d77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101d7e:	eb 5a                	jmp    c0101dda <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101d80:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d84:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101d8b:	00 
c0101d8c:	89 04 24             	mov    %eax,(%esp)
c0101d8f:	e8 23 fa ff ff       	call   c01017b7 <ide_wait_ready>
c0101d94:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101d97:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101d9b:	74 02                	je     c0101d9f <ide_read_secs+0x1f7>
            goto out;
c0101d9d:	eb 41                	jmp    c0101de0 <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101d9f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101da3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101da6:	8b 45 10             	mov    0x10(%ebp),%eax
c0101da9:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101dac:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101db3:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101db6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101db9:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101dbc:	89 cb                	mov    %ecx,%ebx
c0101dbe:	89 df                	mov    %ebx,%edi
c0101dc0:	89 c1                	mov    %eax,%ecx
c0101dc2:	fc                   	cld    
c0101dc3:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101dc5:	89 c8                	mov    %ecx,%eax
c0101dc7:	89 fb                	mov    %edi,%ebx
c0101dc9:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101dcc:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101dcf:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101dd3:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101dda:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101dde:	75 a0                	jne    c0101d80 <ide_read_secs+0x1d8>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101de3:	83 c4 50             	add    $0x50,%esp
c0101de6:	5b                   	pop    %ebx
c0101de7:	5f                   	pop    %edi
c0101de8:	5d                   	pop    %ebp
c0101de9:	c3                   	ret    

c0101dea <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101dea:	55                   	push   %ebp
c0101deb:	89 e5                	mov    %esp,%ebp
c0101ded:	56                   	push   %esi
c0101dee:	53                   	push   %ebx
c0101def:	83 ec 50             	sub    $0x50,%esp
c0101df2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101df5:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101df9:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101e00:	77 24                	ja     c0101e26 <ide_write_secs+0x3c>
c0101e02:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101e07:	77 1d                	ja     c0101e26 <ide_write_secs+0x3c>
c0101e09:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e0d:	c1 e0 03             	shl    $0x3,%eax
c0101e10:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101e17:	29 c2                	sub    %eax,%edx
c0101e19:	8d 82 60 e4 1a c0    	lea    -0x3fe51ba0(%edx),%eax
c0101e1f:	0f b6 00             	movzbl (%eax),%eax
c0101e22:	84 c0                	test   %al,%al
c0101e24:	75 24                	jne    c0101e4a <ide_write_secs+0x60>
c0101e26:	c7 44 24 0c 98 c7 10 	movl   $0xc010c798,0xc(%esp)
c0101e2d:	c0 
c0101e2e:	c7 44 24 08 53 c7 10 	movl   $0xc010c753,0x8(%esp)
c0101e35:	c0 
c0101e36:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101e3d:	00 
c0101e3e:	c7 04 24 68 c7 10 c0 	movl   $0xc010c768,(%esp)
c0101e45:	e8 90 ef ff ff       	call   c0100dda <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101e4a:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101e51:	77 0f                	ja     c0101e62 <ide_write_secs+0x78>
c0101e53:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e56:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101e59:	01 d0                	add    %edx,%eax
c0101e5b:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101e60:	76 24                	jbe    c0101e86 <ide_write_secs+0x9c>
c0101e62:	c7 44 24 0c c0 c7 10 	movl   $0xc010c7c0,0xc(%esp)
c0101e69:	c0 
c0101e6a:	c7 44 24 08 53 c7 10 	movl   $0xc010c753,0x8(%esp)
c0101e71:	c0 
c0101e72:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101e79:	00 
c0101e7a:	c7 04 24 68 c7 10 c0 	movl   $0xc010c768,(%esp)
c0101e81:	e8 54 ef ff ff       	call   c0100dda <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101e86:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e8a:	66 d1 e8             	shr    %ax
c0101e8d:	0f b7 c0             	movzwl %ax,%eax
c0101e90:	0f b7 04 85 08 c7 10 	movzwl -0x3fef38f8(,%eax,4),%eax
c0101e97:	c0 
c0101e98:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101e9c:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101ea0:	66 d1 e8             	shr    %ax
c0101ea3:	0f b7 c0             	movzwl %ax,%eax
c0101ea6:	0f b7 04 85 0a c7 10 	movzwl -0x3fef38f6(,%eax,4),%eax
c0101ead:	c0 
c0101eae:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101eb2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101eb6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101ebd:	00 
c0101ebe:	89 04 24             	mov    %eax,(%esp)
c0101ec1:	e8 f1 f8 ff ff       	call   c01017b7 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101ec6:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101eca:	83 c0 02             	add    $0x2,%eax
c0101ecd:	0f b7 c0             	movzwl %ax,%eax
c0101ed0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101ed4:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ed8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101edc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101ee0:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101ee1:	8b 45 14             	mov    0x14(%ebp),%eax
c0101ee4:	0f b6 c0             	movzbl %al,%eax
c0101ee7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101eeb:	83 c2 02             	add    $0x2,%edx
c0101eee:	0f b7 d2             	movzwl %dx,%edx
c0101ef1:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101ef5:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101ef8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101efc:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101f00:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101f01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f04:	0f b6 c0             	movzbl %al,%eax
c0101f07:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f0b:	83 c2 03             	add    $0x3,%edx
c0101f0e:	0f b7 d2             	movzwl %dx,%edx
c0101f11:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101f15:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101f18:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101f1c:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101f20:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101f21:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f24:	c1 e8 08             	shr    $0x8,%eax
c0101f27:	0f b6 c0             	movzbl %al,%eax
c0101f2a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f2e:	83 c2 04             	add    $0x4,%edx
c0101f31:	0f b7 d2             	movzwl %dx,%edx
c0101f34:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101f38:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101f3b:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101f3f:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101f43:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101f44:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f47:	c1 e8 10             	shr    $0x10,%eax
c0101f4a:	0f b6 c0             	movzbl %al,%eax
c0101f4d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f51:	83 c2 05             	add    $0x5,%edx
c0101f54:	0f b7 d2             	movzwl %dx,%edx
c0101f57:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101f5b:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101f5e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101f62:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101f66:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101f67:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101f6b:	83 e0 01             	and    $0x1,%eax
c0101f6e:	c1 e0 04             	shl    $0x4,%eax
c0101f71:	89 c2                	mov    %eax,%edx
c0101f73:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f76:	c1 e8 18             	shr    $0x18,%eax
c0101f79:	83 e0 0f             	and    $0xf,%eax
c0101f7c:	09 d0                	or     %edx,%eax
c0101f7e:	83 c8 e0             	or     $0xffffffe0,%eax
c0101f81:	0f b6 c0             	movzbl %al,%eax
c0101f84:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f88:	83 c2 06             	add    $0x6,%edx
c0101f8b:	0f b7 d2             	movzwl %dx,%edx
c0101f8e:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101f92:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101f95:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101f99:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101f9d:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101f9e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101fa2:	83 c0 07             	add    $0x7,%eax
c0101fa5:	0f b7 c0             	movzwl %ax,%eax
c0101fa8:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101fac:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c0101fb0:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101fb4:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101fb8:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101fb9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101fc0:	eb 5a                	jmp    c010201c <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101fc2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101fc6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101fcd:	00 
c0101fce:	89 04 24             	mov    %eax,(%esp)
c0101fd1:	e8 e1 f7 ff ff       	call   c01017b7 <ide_wait_ready>
c0101fd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101fd9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101fdd:	74 02                	je     c0101fe1 <ide_write_secs+0x1f7>
            goto out;
c0101fdf:	eb 41                	jmp    c0102022 <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101fe1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101fe5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101fe8:	8b 45 10             	mov    0x10(%ebp),%eax
c0101feb:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101fee:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c0101ff5:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101ff8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101ffb:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101ffe:	89 cb                	mov    %ecx,%ebx
c0102000:	89 de                	mov    %ebx,%esi
c0102002:	89 c1                	mov    %eax,%ecx
c0102004:	fc                   	cld    
c0102005:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0102007:	89 c8                	mov    %ecx,%eax
c0102009:	89 f3                	mov    %esi,%ebx
c010200b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c010200e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0102011:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0102015:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c010201c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0102020:	75 a0                	jne    c0101fc2 <ide_write_secs+0x1d8>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0102022:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102025:	83 c4 50             	add    $0x50,%esp
c0102028:	5b                   	pop    %ebx
c0102029:	5e                   	pop    %esi
c010202a:	5d                   	pop    %ebp
c010202b:	c3                   	ret    

c010202c <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010202c:	55                   	push   %ebp
c010202d:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c010202f:	fb                   	sti    
    sti();
}
c0102030:	5d                   	pop    %ebp
c0102031:	c3                   	ret    

c0102032 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0102032:	55                   	push   %ebp
c0102033:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c0102035:	fa                   	cli    
    cli();
}
c0102036:	5d                   	pop    %ebp
c0102037:	c3                   	ret    

c0102038 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0102038:	55                   	push   %ebp
c0102039:	89 e5                	mov    %esp,%ebp
c010203b:	83 ec 14             	sub    $0x14,%esp
c010203e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102041:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0102045:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102049:	66 a3 70 c5 12 c0    	mov    %ax,0xc012c570
    if (did_init) {
c010204f:	a1 40 e5 1a c0       	mov    0xc01ae540,%eax
c0102054:	85 c0                	test   %eax,%eax
c0102056:	74 36                	je     c010208e <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0102058:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010205c:	0f b6 c0             	movzbl %al,%eax
c010205f:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0102065:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102068:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010206c:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102070:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0102071:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102075:	66 c1 e8 08          	shr    $0x8,%ax
c0102079:	0f b6 c0             	movzbl %al,%eax
c010207c:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0102082:	88 45 f9             	mov    %al,-0x7(%ebp)
c0102085:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102089:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010208d:	ee                   	out    %al,(%dx)
    }
}
c010208e:	c9                   	leave  
c010208f:	c3                   	ret    

c0102090 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0102090:	55                   	push   %ebp
c0102091:	89 e5                	mov    %esp,%ebp
c0102093:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0102096:	8b 45 08             	mov    0x8(%ebp),%eax
c0102099:	ba 01 00 00 00       	mov    $0x1,%edx
c010209e:	89 c1                	mov    %eax,%ecx
c01020a0:	d3 e2                	shl    %cl,%edx
c01020a2:	89 d0                	mov    %edx,%eax
c01020a4:	f7 d0                	not    %eax
c01020a6:	89 c2                	mov    %eax,%edx
c01020a8:	0f b7 05 70 c5 12 c0 	movzwl 0xc012c570,%eax
c01020af:	21 d0                	and    %edx,%eax
c01020b1:	0f b7 c0             	movzwl %ax,%eax
c01020b4:	89 04 24             	mov    %eax,(%esp)
c01020b7:	e8 7c ff ff ff       	call   c0102038 <pic_setmask>
}
c01020bc:	c9                   	leave  
c01020bd:	c3                   	ret    

c01020be <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01020be:	55                   	push   %ebp
c01020bf:	89 e5                	mov    %esp,%ebp
c01020c1:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01020c4:	c7 05 40 e5 1a c0 01 	movl   $0x1,0xc01ae540
c01020cb:	00 00 00 
c01020ce:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01020d4:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c01020d8:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01020dc:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01020e0:	ee                   	out    %al,(%dx)
c01020e1:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c01020e7:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c01020eb:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01020ef:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01020f3:	ee                   	out    %al,(%dx)
c01020f4:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01020fa:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c01020fe:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102102:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102106:	ee                   	out    %al,(%dx)
c0102107:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c010210d:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c0102111:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102115:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102119:	ee                   	out    %al,(%dx)
c010211a:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c0102120:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c0102124:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102128:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010212c:	ee                   	out    %al,(%dx)
c010212d:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c0102133:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c0102137:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010213b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010213f:	ee                   	out    %al,(%dx)
c0102140:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0102146:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c010214a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010214e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102152:	ee                   	out    %al,(%dx)
c0102153:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0102159:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c010215d:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102161:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102165:	ee                   	out    %al,(%dx)
c0102166:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c010216c:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0102170:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102174:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102178:	ee                   	out    %al,(%dx)
c0102179:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c010217f:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0102183:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102187:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010218b:	ee                   	out    %al,(%dx)
c010218c:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0102192:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c0102196:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010219a:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010219e:	ee                   	out    %al,(%dx)
c010219f:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01021a5:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c01021a9:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01021ad:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01021b1:	ee                   	out    %al,(%dx)
c01021b2:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c01021b8:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c01021bc:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01021c0:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01021c4:	ee                   	out    %al,(%dx)
c01021c5:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01021cb:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01021cf:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01021d3:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01021d7:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01021d8:	0f b7 05 70 c5 12 c0 	movzwl 0xc012c570,%eax
c01021df:	66 83 f8 ff          	cmp    $0xffff,%ax
c01021e3:	74 12                	je     c01021f7 <pic_init+0x139>
        pic_setmask(irq_mask);
c01021e5:	0f b7 05 70 c5 12 c0 	movzwl 0xc012c570,%eax
c01021ec:	0f b7 c0             	movzwl %ax,%eax
c01021ef:	89 04 24             	mov    %eax,(%esp)
c01021f2:	e8 41 fe ff ff       	call   c0102038 <pic_setmask>
    }
}
c01021f7:	c9                   	leave  
c01021f8:	c3                   	ret    

c01021f9 <print_ticks>:
#include <sync.h>
#include <proc.h>

#define TICK_NUM 100

static void print_ticks() {
c01021f9:	55                   	push   %ebp
c01021fa:	89 e5                	mov    %esp,%ebp
c01021fc:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01021ff:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102206:	00 
c0102207:	c7 04 24 00 c8 10 c0 	movl   $0xc010c800,(%esp)
c010220e:	e8 45 e1 ff ff       	call   c0100358 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0102213:	c7 04 24 0a c8 10 c0 	movl   $0xc010c80a,(%esp)
c010221a:	e8 39 e1 ff ff       	call   c0100358 <cprintf>
    panic("EOT: kernel seems ok.");
c010221f:	c7 44 24 08 18 c8 10 	movl   $0xc010c818,0x8(%esp)
c0102226:	c0 
c0102227:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
c010222e:	00 
c010222f:	c7 04 24 2e c8 10 c0 	movl   $0xc010c82e,(%esp)
c0102236:	e8 9f eb ff ff       	call   c0100dda <__panic>

c010223b <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010223b:	55                   	push   %ebp
c010223c:	89 e5                	mov    %esp,%ebp
c010223e:	83 ec 10             	sub    $0x10,%esp
     /* LAB5 2012012617 */
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for(i = 0; i < 256; i++) {
c0102241:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102248:	e9 c3 00 00 00       	jmp    c0102310 <idt_init+0xd5>
        SETGATE(idt[i], 0, KERNEL_CS, __vectors[i], DPL_KERNEL);
c010224d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102250:	8b 04 85 00 c6 12 c0 	mov    -0x3fed3a00(,%eax,4),%eax
c0102257:	89 c2                	mov    %eax,%edx
c0102259:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010225c:	66 89 14 c5 60 e5 1a 	mov    %dx,-0x3fe51aa0(,%eax,8)
c0102263:	c0 
c0102264:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102267:	66 c7 04 c5 62 e5 1a 	movw   $0x8,-0x3fe51a9e(,%eax,8)
c010226e:	c0 08 00 
c0102271:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102274:	0f b6 14 c5 64 e5 1a 	movzbl -0x3fe51a9c(,%eax,8),%edx
c010227b:	c0 
c010227c:	83 e2 e0             	and    $0xffffffe0,%edx
c010227f:	88 14 c5 64 e5 1a c0 	mov    %dl,-0x3fe51a9c(,%eax,8)
c0102286:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102289:	0f b6 14 c5 64 e5 1a 	movzbl -0x3fe51a9c(,%eax,8),%edx
c0102290:	c0 
c0102291:	83 e2 1f             	and    $0x1f,%edx
c0102294:	88 14 c5 64 e5 1a c0 	mov    %dl,-0x3fe51a9c(,%eax,8)
c010229b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010229e:	0f b6 14 c5 65 e5 1a 	movzbl -0x3fe51a9b(,%eax,8),%edx
c01022a5:	c0 
c01022a6:	83 e2 f0             	and    $0xfffffff0,%edx
c01022a9:	83 ca 0e             	or     $0xe,%edx
c01022ac:	88 14 c5 65 e5 1a c0 	mov    %dl,-0x3fe51a9b(,%eax,8)
c01022b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022b6:	0f b6 14 c5 65 e5 1a 	movzbl -0x3fe51a9b(,%eax,8),%edx
c01022bd:	c0 
c01022be:	83 e2 ef             	and    $0xffffffef,%edx
c01022c1:	88 14 c5 65 e5 1a c0 	mov    %dl,-0x3fe51a9b(,%eax,8)
c01022c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022cb:	0f b6 14 c5 65 e5 1a 	movzbl -0x3fe51a9b(,%eax,8),%edx
c01022d2:	c0 
c01022d3:	83 e2 9f             	and    $0xffffff9f,%edx
c01022d6:	88 14 c5 65 e5 1a c0 	mov    %dl,-0x3fe51a9b(,%eax,8)
c01022dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022e0:	0f b6 14 c5 65 e5 1a 	movzbl -0x3fe51a9b(,%eax,8),%edx
c01022e7:	c0 
c01022e8:	83 ca 80             	or     $0xffffff80,%edx
c01022eb:	88 14 c5 65 e5 1a c0 	mov    %dl,-0x3fe51a9b(,%eax,8)
c01022f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022f5:	8b 04 85 00 c6 12 c0 	mov    -0x3fed3a00(,%eax,4),%eax
c01022fc:	c1 e8 10             	shr    $0x10,%eax
c01022ff:	89 c2                	mov    %eax,%edx
c0102301:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102304:	66 89 14 c5 66 e5 1a 	mov    %dx,-0x3fe51a9a(,%eax,8)
c010230b:	c0 
     /* LAB5 2012012617 */
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for(i = 0; i < 256; i++) {
c010230c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102310:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c0102317:	0f 8e 30 ff ff ff    	jle    c010224d <idt_init+0x12>
        SETGATE(idt[i], 0, KERNEL_CS, __vectors[i], DPL_KERNEL);
    }
    SETGATE(idt[T_SYSCALL], 1, KERNEL_CS, __vectors[T_SYSCALL], DPL_USER);
c010231d:	a1 00 c8 12 c0       	mov    0xc012c800,%eax
c0102322:	66 a3 60 e9 1a c0    	mov    %ax,0xc01ae960
c0102328:	66 c7 05 62 e9 1a c0 	movw   $0x8,0xc01ae962
c010232f:	08 00 
c0102331:	0f b6 05 64 e9 1a c0 	movzbl 0xc01ae964,%eax
c0102338:	83 e0 e0             	and    $0xffffffe0,%eax
c010233b:	a2 64 e9 1a c0       	mov    %al,0xc01ae964
c0102340:	0f b6 05 64 e9 1a c0 	movzbl 0xc01ae964,%eax
c0102347:	83 e0 1f             	and    $0x1f,%eax
c010234a:	a2 64 e9 1a c0       	mov    %al,0xc01ae964
c010234f:	0f b6 05 65 e9 1a c0 	movzbl 0xc01ae965,%eax
c0102356:	83 c8 0f             	or     $0xf,%eax
c0102359:	a2 65 e9 1a c0       	mov    %al,0xc01ae965
c010235e:	0f b6 05 65 e9 1a c0 	movzbl 0xc01ae965,%eax
c0102365:	83 e0 ef             	and    $0xffffffef,%eax
c0102368:	a2 65 e9 1a c0       	mov    %al,0xc01ae965
c010236d:	0f b6 05 65 e9 1a c0 	movzbl 0xc01ae965,%eax
c0102374:	83 c8 60             	or     $0x60,%eax
c0102377:	a2 65 e9 1a c0       	mov    %al,0xc01ae965
c010237c:	0f b6 05 65 e9 1a c0 	movzbl 0xc01ae965,%eax
c0102383:	83 c8 80             	or     $0xffffff80,%eax
c0102386:	a2 65 e9 1a c0       	mov    %al,0xc01ae965
c010238b:	a1 00 c8 12 c0       	mov    0xc012c800,%eax
c0102390:	c1 e8 10             	shr    $0x10,%eax
c0102393:	66 a3 66 e9 1a c0    	mov    %ax,0xc01ae966
c0102399:	c7 45 f8 80 c5 12 c0 	movl   $0xc012c580,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01023a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01023a3:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
c01023a6:	c9                   	leave  
c01023a7:	c3                   	ret    

c01023a8 <trapname>:

static const char *
trapname(int trapno) {
c01023a8:	55                   	push   %ebp
c01023a9:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01023ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01023ae:	83 f8 13             	cmp    $0x13,%eax
c01023b1:	77 0c                	ja     c01023bf <trapname+0x17>
        return excnames[trapno];
c01023b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01023b6:	8b 04 85 a0 cc 10 c0 	mov    -0x3fef3360(,%eax,4),%eax
c01023bd:	eb 18                	jmp    c01023d7 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01023bf:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01023c3:	7e 0d                	jle    c01023d2 <trapname+0x2a>
c01023c5:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01023c9:	7f 07                	jg     c01023d2 <trapname+0x2a>
        return "Hardware Interrupt";
c01023cb:	b8 3f c8 10 c0       	mov    $0xc010c83f,%eax
c01023d0:	eb 05                	jmp    c01023d7 <trapname+0x2f>
    }
    return "(unknown trap)";
c01023d2:	b8 52 c8 10 c0       	mov    $0xc010c852,%eax
}
c01023d7:	5d                   	pop    %ebp
c01023d8:	c3                   	ret    

c01023d9 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01023d9:	55                   	push   %ebp
c01023da:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01023dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01023df:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023e3:	66 83 f8 08          	cmp    $0x8,%ax
c01023e7:	0f 94 c0             	sete   %al
c01023ea:	0f b6 c0             	movzbl %al,%eax
}
c01023ed:	5d                   	pop    %ebp
c01023ee:	c3                   	ret    

c01023ef <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01023ef:	55                   	push   %ebp
c01023f0:	89 e5                	mov    %esp,%ebp
c01023f2:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01023f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023fc:	c7 04 24 93 c8 10 c0 	movl   $0xc010c893,(%esp)
c0102403:	e8 50 df ff ff       	call   c0100358 <cprintf>
    print_regs(&tf->tf_regs);
c0102408:	8b 45 08             	mov    0x8(%ebp),%eax
c010240b:	89 04 24             	mov    %eax,(%esp)
c010240e:	e8 a1 01 00 00       	call   c01025b4 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102413:	8b 45 08             	mov    0x8(%ebp),%eax
c0102416:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010241a:	0f b7 c0             	movzwl %ax,%eax
c010241d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102421:	c7 04 24 a4 c8 10 c0 	movl   $0xc010c8a4,(%esp)
c0102428:	e8 2b df ff ff       	call   c0100358 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c010242d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102430:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102434:	0f b7 c0             	movzwl %ax,%eax
c0102437:	89 44 24 04          	mov    %eax,0x4(%esp)
c010243b:	c7 04 24 b7 c8 10 c0 	movl   $0xc010c8b7,(%esp)
c0102442:	e8 11 df ff ff       	call   c0100358 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102447:	8b 45 08             	mov    0x8(%ebp),%eax
c010244a:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c010244e:	0f b7 c0             	movzwl %ax,%eax
c0102451:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102455:	c7 04 24 ca c8 10 c0 	movl   $0xc010c8ca,(%esp)
c010245c:	e8 f7 de ff ff       	call   c0100358 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102461:	8b 45 08             	mov    0x8(%ebp),%eax
c0102464:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102468:	0f b7 c0             	movzwl %ax,%eax
c010246b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010246f:	c7 04 24 dd c8 10 c0 	movl   $0xc010c8dd,(%esp)
c0102476:	e8 dd de ff ff       	call   c0100358 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c010247b:	8b 45 08             	mov    0x8(%ebp),%eax
c010247e:	8b 40 30             	mov    0x30(%eax),%eax
c0102481:	89 04 24             	mov    %eax,(%esp)
c0102484:	e8 1f ff ff ff       	call   c01023a8 <trapname>
c0102489:	8b 55 08             	mov    0x8(%ebp),%edx
c010248c:	8b 52 30             	mov    0x30(%edx),%edx
c010248f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102493:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102497:	c7 04 24 f0 c8 10 c0 	movl   $0xc010c8f0,(%esp)
c010249e:	e8 b5 de ff ff       	call   c0100358 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01024a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a6:	8b 40 34             	mov    0x34(%eax),%eax
c01024a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ad:	c7 04 24 02 c9 10 c0 	movl   $0xc010c902,(%esp)
c01024b4:	e8 9f de ff ff       	call   c0100358 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01024b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01024bc:	8b 40 38             	mov    0x38(%eax),%eax
c01024bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024c3:	c7 04 24 11 c9 10 c0 	movl   $0xc010c911,(%esp)
c01024ca:	e8 89 de ff ff       	call   c0100358 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01024cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01024d6:	0f b7 c0             	movzwl %ax,%eax
c01024d9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024dd:	c7 04 24 20 c9 10 c0 	movl   $0xc010c920,(%esp)
c01024e4:	e8 6f de ff ff       	call   c0100358 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01024e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ec:	8b 40 40             	mov    0x40(%eax),%eax
c01024ef:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024f3:	c7 04 24 33 c9 10 c0 	movl   $0xc010c933,(%esp)
c01024fa:	e8 59 de ff ff       	call   c0100358 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01024ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102506:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c010250d:	eb 3e                	jmp    c010254d <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c010250f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102512:	8b 50 40             	mov    0x40(%eax),%edx
c0102515:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102518:	21 d0                	and    %edx,%eax
c010251a:	85 c0                	test   %eax,%eax
c010251c:	74 28                	je     c0102546 <print_trapframe+0x157>
c010251e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102521:	8b 04 85 a0 c5 12 c0 	mov    -0x3fed3a60(,%eax,4),%eax
c0102528:	85 c0                	test   %eax,%eax
c010252a:	74 1a                	je     c0102546 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c010252c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010252f:	8b 04 85 a0 c5 12 c0 	mov    -0x3fed3a60(,%eax,4),%eax
c0102536:	89 44 24 04          	mov    %eax,0x4(%esp)
c010253a:	c7 04 24 42 c9 10 c0 	movl   $0xc010c942,(%esp)
c0102541:	e8 12 de ff ff       	call   c0100358 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102546:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010254a:	d1 65 f0             	shll   -0x10(%ebp)
c010254d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102550:	83 f8 17             	cmp    $0x17,%eax
c0102553:	76 ba                	jbe    c010250f <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102555:	8b 45 08             	mov    0x8(%ebp),%eax
c0102558:	8b 40 40             	mov    0x40(%eax),%eax
c010255b:	25 00 30 00 00       	and    $0x3000,%eax
c0102560:	c1 e8 0c             	shr    $0xc,%eax
c0102563:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102567:	c7 04 24 46 c9 10 c0 	movl   $0xc010c946,(%esp)
c010256e:	e8 e5 dd ff ff       	call   c0100358 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102573:	8b 45 08             	mov    0x8(%ebp),%eax
c0102576:	89 04 24             	mov    %eax,(%esp)
c0102579:	e8 5b fe ff ff       	call   c01023d9 <trap_in_kernel>
c010257e:	85 c0                	test   %eax,%eax
c0102580:	75 30                	jne    c01025b2 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102582:	8b 45 08             	mov    0x8(%ebp),%eax
c0102585:	8b 40 44             	mov    0x44(%eax),%eax
c0102588:	89 44 24 04          	mov    %eax,0x4(%esp)
c010258c:	c7 04 24 4f c9 10 c0 	movl   $0xc010c94f,(%esp)
c0102593:	e8 c0 dd ff ff       	call   c0100358 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0102598:	8b 45 08             	mov    0x8(%ebp),%eax
c010259b:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010259f:	0f b7 c0             	movzwl %ax,%eax
c01025a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025a6:	c7 04 24 5e c9 10 c0 	movl   $0xc010c95e,(%esp)
c01025ad:	e8 a6 dd ff ff       	call   c0100358 <cprintf>
    }
}
c01025b2:	c9                   	leave  
c01025b3:	c3                   	ret    

c01025b4 <print_regs>:

void
print_regs(struct pushregs *regs) {
c01025b4:	55                   	push   %ebp
c01025b5:	89 e5                	mov    %esp,%ebp
c01025b7:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01025ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01025bd:	8b 00                	mov    (%eax),%eax
c01025bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025c3:	c7 04 24 71 c9 10 c0 	movl   $0xc010c971,(%esp)
c01025ca:	e8 89 dd ff ff       	call   c0100358 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01025cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01025d2:	8b 40 04             	mov    0x4(%eax),%eax
c01025d5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025d9:	c7 04 24 80 c9 10 c0 	movl   $0xc010c980,(%esp)
c01025e0:	e8 73 dd ff ff       	call   c0100358 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01025e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e8:	8b 40 08             	mov    0x8(%eax),%eax
c01025eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025ef:	c7 04 24 8f c9 10 c0 	movl   $0xc010c98f,(%esp)
c01025f6:	e8 5d dd ff ff       	call   c0100358 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01025fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01025fe:	8b 40 0c             	mov    0xc(%eax),%eax
c0102601:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102605:	c7 04 24 9e c9 10 c0 	movl   $0xc010c99e,(%esp)
c010260c:	e8 47 dd ff ff       	call   c0100358 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102611:	8b 45 08             	mov    0x8(%ebp),%eax
c0102614:	8b 40 10             	mov    0x10(%eax),%eax
c0102617:	89 44 24 04          	mov    %eax,0x4(%esp)
c010261b:	c7 04 24 ad c9 10 c0 	movl   $0xc010c9ad,(%esp)
c0102622:	e8 31 dd ff ff       	call   c0100358 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0102627:	8b 45 08             	mov    0x8(%ebp),%eax
c010262a:	8b 40 14             	mov    0x14(%eax),%eax
c010262d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102631:	c7 04 24 bc c9 10 c0 	movl   $0xc010c9bc,(%esp)
c0102638:	e8 1b dd ff ff       	call   c0100358 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c010263d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102640:	8b 40 18             	mov    0x18(%eax),%eax
c0102643:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102647:	c7 04 24 cb c9 10 c0 	movl   $0xc010c9cb,(%esp)
c010264e:	e8 05 dd ff ff       	call   c0100358 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102653:	8b 45 08             	mov    0x8(%ebp),%eax
c0102656:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102659:	89 44 24 04          	mov    %eax,0x4(%esp)
c010265d:	c7 04 24 da c9 10 c0 	movl   $0xc010c9da,(%esp)
c0102664:	e8 ef dc ff ff       	call   c0100358 <cprintf>
}
c0102669:	c9                   	leave  
c010266a:	c3                   	ret    

c010266b <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c010266b:	55                   	push   %ebp
c010266c:	89 e5                	mov    %esp,%ebp
c010266e:	53                   	push   %ebx
c010266f:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102672:	8b 45 08             	mov    0x8(%ebp),%eax
c0102675:	8b 40 34             	mov    0x34(%eax),%eax
c0102678:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010267b:	85 c0                	test   %eax,%eax
c010267d:	74 07                	je     c0102686 <print_pgfault+0x1b>
c010267f:	b9 e9 c9 10 c0       	mov    $0xc010c9e9,%ecx
c0102684:	eb 05                	jmp    c010268b <print_pgfault+0x20>
c0102686:	b9 fa c9 10 c0       	mov    $0xc010c9fa,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c010268b:	8b 45 08             	mov    0x8(%ebp),%eax
c010268e:	8b 40 34             	mov    0x34(%eax),%eax
c0102691:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102694:	85 c0                	test   %eax,%eax
c0102696:	74 07                	je     c010269f <print_pgfault+0x34>
c0102698:	ba 57 00 00 00       	mov    $0x57,%edx
c010269d:	eb 05                	jmp    c01026a4 <print_pgfault+0x39>
c010269f:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c01026a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01026a7:	8b 40 34             	mov    0x34(%eax),%eax
c01026aa:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026ad:	85 c0                	test   %eax,%eax
c01026af:	74 07                	je     c01026b8 <print_pgfault+0x4d>
c01026b1:	b8 55 00 00 00       	mov    $0x55,%eax
c01026b6:	eb 05                	jmp    c01026bd <print_pgfault+0x52>
c01026b8:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01026bd:	0f 20 d3             	mov    %cr2,%ebx
c01026c0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01026c3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01026c6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01026ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01026ce:	89 44 24 08          	mov    %eax,0x8(%esp)
c01026d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01026d6:	c7 04 24 08 ca 10 c0 	movl   $0xc010ca08,(%esp)
c01026dd:	e8 76 dc ff ff       	call   c0100358 <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c01026e2:	83 c4 34             	add    $0x34,%esp
c01026e5:	5b                   	pop    %ebx
c01026e6:	5d                   	pop    %ebp
c01026e7:	c3                   	ret    

c01026e8 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01026e8:	55                   	push   %ebp
c01026e9:	89 e5                	mov    %esp,%ebp
c01026eb:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
c01026ee:	a1 6c 0f 1b c0       	mov    0xc01b0f6c,%eax
c01026f3:	85 c0                	test   %eax,%eax
c01026f5:	74 0b                	je     c0102702 <pgfault_handler+0x1a>
            print_pgfault(tf);
c01026f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01026fa:	89 04 24             	mov    %eax,(%esp)
c01026fd:	e8 69 ff ff ff       	call   c010266b <print_pgfault>
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
c0102702:	a1 6c 0f 1b c0       	mov    0xc01b0f6c,%eax
c0102707:	85 c0                	test   %eax,%eax
c0102709:	74 3d                	je     c0102748 <pgfault_handler+0x60>
        assert(current == idleproc);
c010270b:	8b 15 28 ee 1a c0    	mov    0xc01aee28,%edx
c0102711:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c0102716:	39 c2                	cmp    %eax,%edx
c0102718:	74 24                	je     c010273e <pgfault_handler+0x56>
c010271a:	c7 44 24 0c 2b ca 10 	movl   $0xc010ca2b,0xc(%esp)
c0102721:	c0 
c0102722:	c7 44 24 08 3f ca 10 	movl   $0xc010ca3f,0x8(%esp)
c0102729:	c0 
c010272a:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
c0102731:	00 
c0102732:	c7 04 24 2e c8 10 c0 	movl   $0xc010c82e,(%esp)
c0102739:	e8 9c e6 ff ff       	call   c0100dda <__panic>
        mm = check_mm_struct;
c010273e:	a1 6c 0f 1b c0       	mov    0xc01b0f6c,%eax
c0102743:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102746:	eb 46                	jmp    c010278e <pgfault_handler+0xa6>
    }
    else {
        if (current == NULL) {
c0102748:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010274d:	85 c0                	test   %eax,%eax
c010274f:	75 32                	jne    c0102783 <pgfault_handler+0x9b>
            print_trapframe(tf);
c0102751:	8b 45 08             	mov    0x8(%ebp),%eax
c0102754:	89 04 24             	mov    %eax,(%esp)
c0102757:	e8 93 fc ff ff       	call   c01023ef <print_trapframe>
            print_pgfault(tf);
c010275c:	8b 45 08             	mov    0x8(%ebp),%eax
c010275f:	89 04 24             	mov    %eax,(%esp)
c0102762:	e8 04 ff ff ff       	call   c010266b <print_pgfault>
            panic("unhandled page fault.\n");
c0102767:	c7 44 24 08 54 ca 10 	movl   $0xc010ca54,0x8(%esp)
c010276e:	c0 
c010276f:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c0102776:	00 
c0102777:	c7 04 24 2e c8 10 c0 	movl   $0xc010c82e,(%esp)
c010277e:	e8 57 e6 ff ff       	call   c0100dda <__panic>
        }
        mm = current->mm;
c0102783:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c0102788:	8b 40 18             	mov    0x18(%eax),%eax
c010278b:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c010278e:	0f 20 d0             	mov    %cr2,%eax
c0102791:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr2;
c0102794:	8b 45 f0             	mov    -0x10(%ebp),%eax
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
c0102797:	89 c2                	mov    %eax,%edx
c0102799:	8b 45 08             	mov    0x8(%ebp),%eax
c010279c:	8b 40 34             	mov    0x34(%eax),%eax
c010279f:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01027aa:	89 04 24             	mov    %eax,(%esp)
c01027ad:	e8 fe 65 00 00       	call   c0108db0 <do_pgfault>
}
c01027b2:	c9                   	leave  
c01027b3:	c3                   	ret    

c01027b4 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01027b4:	55                   	push   %ebp
c01027b5:	89 e5                	mov    %esp,%ebp
c01027b7:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret=0;
c01027ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    switch (tf->tf_trapno) {
c01027c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01027c4:	8b 40 30             	mov    0x30(%eax),%eax
c01027c7:	83 f8 2f             	cmp    $0x2f,%eax
c01027ca:	77 38                	ja     c0102804 <trap_dispatch+0x50>
c01027cc:	83 f8 2e             	cmp    $0x2e,%eax
c01027cf:	0f 83 e2 01 00 00    	jae    c01029b7 <trap_dispatch+0x203>
c01027d5:	83 f8 20             	cmp    $0x20,%eax
c01027d8:	0f 84 07 01 00 00    	je     c01028e5 <trap_dispatch+0x131>
c01027de:	83 f8 20             	cmp    $0x20,%eax
c01027e1:	77 0a                	ja     c01027ed <trap_dispatch+0x39>
c01027e3:	83 f8 0e             	cmp    $0xe,%eax
c01027e6:	74 3e                	je     c0102826 <trap_dispatch+0x72>
c01027e8:	e9 82 01 00 00       	jmp    c010296f <trap_dispatch+0x1bb>
c01027ed:	83 f8 21             	cmp    $0x21,%eax
c01027f0:	0f 84 37 01 00 00    	je     c010292d <trap_dispatch+0x179>
c01027f6:	83 f8 24             	cmp    $0x24,%eax
c01027f9:	0f 84 05 01 00 00    	je     c0102904 <trap_dispatch+0x150>
c01027ff:	e9 6b 01 00 00       	jmp    c010296f <trap_dispatch+0x1bb>
c0102804:	83 f8 78             	cmp    $0x78,%eax
c0102807:	0f 82 62 01 00 00    	jb     c010296f <trap_dispatch+0x1bb>
c010280d:	83 f8 79             	cmp    $0x79,%eax
c0102810:	0f 86 3d 01 00 00    	jbe    c0102953 <trap_dispatch+0x19f>
c0102816:	3d 80 00 00 00       	cmp    $0x80,%eax
c010281b:	0f 84 ba 00 00 00    	je     c01028db <trap_dispatch+0x127>
c0102821:	e9 49 01 00 00       	jmp    c010296f <trap_dispatch+0x1bb>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0102826:	8b 45 08             	mov    0x8(%ebp),%eax
c0102829:	89 04 24             	mov    %eax,(%esp)
c010282c:	e8 b7 fe ff ff       	call   c01026e8 <pgfault_handler>
c0102831:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102834:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102838:	0f 84 98 00 00 00    	je     c01028d6 <trap_dispatch+0x122>
            print_trapframe(tf);
c010283e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102841:	89 04 24             	mov    %eax,(%esp)
c0102844:	e8 a6 fb ff ff       	call   c01023ef <print_trapframe>
            if (current == NULL) {
c0102849:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010284e:	85 c0                	test   %eax,%eax
c0102850:	75 23                	jne    c0102875 <trap_dispatch+0xc1>
                panic("handle pgfault failed. ret=%d\n", ret);
c0102852:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102855:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102859:	c7 44 24 08 6c ca 10 	movl   $0xc010ca6c,0x8(%esp)
c0102860:	c0 
c0102861:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0102868:	00 
c0102869:	c7 04 24 2e c8 10 c0 	movl   $0xc010c82e,(%esp)
c0102870:	e8 65 e5 ff ff       	call   c0100dda <__panic>
            }
            else {
                if (trap_in_kernel(tf)) {
c0102875:	8b 45 08             	mov    0x8(%ebp),%eax
c0102878:	89 04 24             	mov    %eax,(%esp)
c010287b:	e8 59 fb ff ff       	call   c01023d9 <trap_in_kernel>
c0102880:	85 c0                	test   %eax,%eax
c0102882:	74 23                	je     c01028a7 <trap_dispatch+0xf3>
                    panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
c0102884:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102887:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010288b:	c7 44 24 08 8c ca 10 	movl   $0xc010ca8c,0x8(%esp)
c0102892:	c0 
c0102893:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c010289a:	00 
c010289b:	c7 04 24 2e c8 10 c0 	movl   $0xc010c82e,(%esp)
c01028a2:	e8 33 e5 ff ff       	call   c0100dda <__panic>
                }
                cprintf("killed by kernel.\n");
c01028a7:	c7 04 24 ba ca 10 c0 	movl   $0xc010caba,(%esp)
c01028ae:	e8 a5 da ff ff       	call   c0100358 <cprintf>
                panic("handle user mode pgfault failed. ret=%d\n", ret); 
c01028b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028ba:	c7 44 24 08 d0 ca 10 	movl   $0xc010cad0,0x8(%esp)
c01028c1:	c0 
c01028c2:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c01028c9:	00 
c01028ca:	c7 04 24 2e c8 10 c0 	movl   $0xc010c82e,(%esp)
c01028d1:	e8 04 e5 ff ff       	call   c0100dda <__panic>
                do_exit(-E_KILLED);
            }
        }
        break;
c01028d6:	e9 dd 00 00 00       	jmp    c01029b8 <trap_dispatch+0x204>
    case T_SYSCALL:
        syscall();
c01028db:	e8 c9 8d 00 00       	call   c010b6a9 <syscall>
        break;
c01028e0:	e9 d3 00 00 00       	jmp    c01029b8 <trap_dispatch+0x204>
        /* LAB6 2012012617 */
        /* you should upate you lab5 code
         * IMPORTANT FUNCTIONS:
	     * sched_class_proc_tick
         */
        ticks++;
c01028e5:	a1 78 0e 1b c0       	mov    0xc01b0e78,%eax
c01028ea:	83 c0 01             	add    $0x1,%eax
c01028ed:	a3 78 0e 1b c0       	mov    %eax,0xc01b0e78
        sched_class_proc_tick(current);
c01028f2:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c01028f7:	89 04 24             	mov    %eax,(%esp)
c01028fa:	e8 85 8a 00 00       	call   c010b384 <sched_class_proc_tick>
        break;
c01028ff:	e9 b4 00 00 00       	jmp    c01029b8 <trap_dispatch+0x204>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102904:	e8 3f ee ff ff       	call   c0101748 <cons_getc>
c0102909:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c010290c:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102910:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102914:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102918:	89 44 24 04          	mov    %eax,0x4(%esp)
c010291c:	c7 04 24 f9 ca 10 c0 	movl   $0xc010caf9,(%esp)
c0102923:	e8 30 da ff ff       	call   c0100358 <cprintf>
        break;
c0102928:	e9 8b 00 00 00       	jmp    c01029b8 <trap_dispatch+0x204>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c010292d:	e8 16 ee ff ff       	call   c0101748 <cons_getc>
c0102932:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0102935:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102939:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c010293d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102941:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102945:	c7 04 24 0b cb 10 c0 	movl   $0xc010cb0b,(%esp)
c010294c:	e8 07 da ff ff       	call   c0100358 <cprintf>
        break;
c0102951:	eb 65                	jmp    c01029b8 <trap_dispatch+0x204>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0102953:	c7 44 24 08 1a cb 10 	movl   $0xc010cb1a,0x8(%esp)
c010295a:	c0 
c010295b:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c0102962:	00 
c0102963:	c7 04 24 2e c8 10 c0 	movl   $0xc010c82e,(%esp)
c010296a:	e8 6b e4 ff ff       	call   c0100dda <__panic>
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        print_trapframe(tf);
c010296f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102972:	89 04 24             	mov    %eax,(%esp)
c0102975:	e8 75 fa ff ff       	call   c01023ef <print_trapframe>
        if (current != NULL) {
c010297a:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010297f:	85 c0                	test   %eax,%eax
c0102981:	74 18                	je     c010299b <trap_dispatch+0x1e7>
            cprintf("unhandled trap.\n");
c0102983:	c7 04 24 2a cb 10 c0 	movl   $0xc010cb2a,(%esp)
c010298a:	e8 c9 d9 ff ff       	call   c0100358 <cprintf>
            do_exit(-E_KILLED);
c010298f:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102996:	e8 1c 76 00 00       	call   c0109fb7 <do_exit>
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");
c010299b:	c7 44 24 08 3b cb 10 	movl   $0xc010cb3b,0x8(%esp)
c01029a2:	c0 
c01029a3:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01029aa:	00 
c01029ab:	c7 04 24 2e c8 10 c0 	movl   $0xc010c82e,(%esp)
c01029b2:	e8 23 e4 ff ff       	call   c0100dda <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c01029b7:	90                   	nop
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");

    }
}
c01029b8:	c9                   	leave  
c01029b9:	c3                   	ret    

c01029ba <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01029ba:	55                   	push   %ebp
c01029bb:	89 e5                	mov    %esp,%ebp
c01029bd:	83 ec 28             	sub    $0x28,%esp
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL) {
c01029c0:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c01029c5:	85 c0                	test   %eax,%eax
c01029c7:	75 0d                	jne    c01029d6 <trap+0x1c>
        trap_dispatch(tf);
c01029c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01029cc:	89 04 24             	mov    %eax,(%esp)
c01029cf:	e8 e0 fd ff ff       	call   c01027b4 <trap_dispatch>
c01029d4:	eb 6c                	jmp    c0102a42 <trap+0x88>
    }
    else {
        // keep a trapframe chain in stack
        struct trapframe *otf = current->tf;
c01029d6:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c01029db:	8b 40 3c             	mov    0x3c(%eax),%eax
c01029de:	89 45 f4             	mov    %eax,-0xc(%ebp)
        current->tf = tf;
c01029e1:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c01029e6:	8b 55 08             	mov    0x8(%ebp),%edx
c01029e9:	89 50 3c             	mov    %edx,0x3c(%eax)
    
        bool in_kernel = trap_in_kernel(tf);
c01029ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01029ef:	89 04 24             	mov    %eax,(%esp)
c01029f2:	e8 e2 f9 ff ff       	call   c01023d9 <trap_in_kernel>
c01029f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
        trap_dispatch(tf);
c01029fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01029fd:	89 04 24             	mov    %eax,(%esp)
c0102a00:	e8 af fd ff ff       	call   c01027b4 <trap_dispatch>
    
        current->tf = otf;
c0102a05:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c0102a0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102a0d:	89 50 3c             	mov    %edx,0x3c(%eax)
        if (!in_kernel) {
c0102a10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102a14:	75 2c                	jne    c0102a42 <trap+0x88>
            if (current->flags & PF_EXITING) {
c0102a16:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c0102a1b:	8b 40 44             	mov    0x44(%eax),%eax
c0102a1e:	83 e0 01             	and    $0x1,%eax
c0102a21:	85 c0                	test   %eax,%eax
c0102a23:	74 0c                	je     c0102a31 <trap+0x77>
                do_exit(-E_KILLED);
c0102a25:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102a2c:	e8 86 75 00 00       	call   c0109fb7 <do_exit>
            }
            if (current->need_resched) {
c0102a31:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c0102a36:	8b 40 10             	mov    0x10(%eax),%eax
c0102a39:	85 c0                	test   %eax,%eax
c0102a3b:	74 05                	je     c0102a42 <trap+0x88>
                schedule();
c0102a3d:	e8 80 8a 00 00       	call   c010b4c2 <schedule>
            }
        }
    }
}
c0102a42:	c9                   	leave  
c0102a43:	c3                   	ret    

c0102a44 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102a44:	1e                   	push   %ds
    pushl %es
c0102a45:	06                   	push   %es
    pushl %fs
c0102a46:	0f a0                	push   %fs
    pushl %gs
c0102a48:	0f a8                	push   %gs
    pushal
c0102a4a:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102a4b:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102a50:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102a52:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102a54:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102a55:	e8 60 ff ff ff       	call   c01029ba <trap>

    # pop the pushed stack pointer
    popl %esp
c0102a5a:	5c                   	pop    %esp

c0102a5b <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102a5b:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102a5c:	0f a9                	pop    %gs
    popl %fs
c0102a5e:	0f a1                	pop    %fs
    popl %es
c0102a60:	07                   	pop    %es
    popl %ds
c0102a61:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102a62:	83 c4 08             	add    $0x8,%esp
    iret
c0102a65:	cf                   	iret   

c0102a66 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0102a66:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0102a6a:	e9 ec ff ff ff       	jmp    c0102a5b <__trapret>

c0102a6f <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102a6f:	6a 00                	push   $0x0
  pushl $0
c0102a71:	6a 00                	push   $0x0
  jmp __alltraps
c0102a73:	e9 cc ff ff ff       	jmp    c0102a44 <__alltraps>

c0102a78 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102a78:	6a 00                	push   $0x0
  pushl $1
c0102a7a:	6a 01                	push   $0x1
  jmp __alltraps
c0102a7c:	e9 c3 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102a81 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102a81:	6a 00                	push   $0x0
  pushl $2
c0102a83:	6a 02                	push   $0x2
  jmp __alltraps
c0102a85:	e9 ba ff ff ff       	jmp    c0102a44 <__alltraps>

c0102a8a <vector3>:
.globl vector3
vector3:
  pushl $0
c0102a8a:	6a 00                	push   $0x0
  pushl $3
c0102a8c:	6a 03                	push   $0x3
  jmp __alltraps
c0102a8e:	e9 b1 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102a93 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102a93:	6a 00                	push   $0x0
  pushl $4
c0102a95:	6a 04                	push   $0x4
  jmp __alltraps
c0102a97:	e9 a8 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102a9c <vector5>:
.globl vector5
vector5:
  pushl $0
c0102a9c:	6a 00                	push   $0x0
  pushl $5
c0102a9e:	6a 05                	push   $0x5
  jmp __alltraps
c0102aa0:	e9 9f ff ff ff       	jmp    c0102a44 <__alltraps>

c0102aa5 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102aa5:	6a 00                	push   $0x0
  pushl $6
c0102aa7:	6a 06                	push   $0x6
  jmp __alltraps
c0102aa9:	e9 96 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102aae <vector7>:
.globl vector7
vector7:
  pushl $0
c0102aae:	6a 00                	push   $0x0
  pushl $7
c0102ab0:	6a 07                	push   $0x7
  jmp __alltraps
c0102ab2:	e9 8d ff ff ff       	jmp    c0102a44 <__alltraps>

c0102ab7 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102ab7:	6a 08                	push   $0x8
  jmp __alltraps
c0102ab9:	e9 86 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102abe <vector9>:
.globl vector9
vector9:
  pushl $9
c0102abe:	6a 09                	push   $0x9
  jmp __alltraps
c0102ac0:	e9 7f ff ff ff       	jmp    c0102a44 <__alltraps>

c0102ac5 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102ac5:	6a 0a                	push   $0xa
  jmp __alltraps
c0102ac7:	e9 78 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102acc <vector11>:
.globl vector11
vector11:
  pushl $11
c0102acc:	6a 0b                	push   $0xb
  jmp __alltraps
c0102ace:	e9 71 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102ad3 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102ad3:	6a 0c                	push   $0xc
  jmp __alltraps
c0102ad5:	e9 6a ff ff ff       	jmp    c0102a44 <__alltraps>

c0102ada <vector13>:
.globl vector13
vector13:
  pushl $13
c0102ada:	6a 0d                	push   $0xd
  jmp __alltraps
c0102adc:	e9 63 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102ae1 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102ae1:	6a 0e                	push   $0xe
  jmp __alltraps
c0102ae3:	e9 5c ff ff ff       	jmp    c0102a44 <__alltraps>

c0102ae8 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102ae8:	6a 00                	push   $0x0
  pushl $15
c0102aea:	6a 0f                	push   $0xf
  jmp __alltraps
c0102aec:	e9 53 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102af1 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102af1:	6a 00                	push   $0x0
  pushl $16
c0102af3:	6a 10                	push   $0x10
  jmp __alltraps
c0102af5:	e9 4a ff ff ff       	jmp    c0102a44 <__alltraps>

c0102afa <vector17>:
.globl vector17
vector17:
  pushl $17
c0102afa:	6a 11                	push   $0x11
  jmp __alltraps
c0102afc:	e9 43 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102b01 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102b01:	6a 00                	push   $0x0
  pushl $18
c0102b03:	6a 12                	push   $0x12
  jmp __alltraps
c0102b05:	e9 3a ff ff ff       	jmp    c0102a44 <__alltraps>

c0102b0a <vector19>:
.globl vector19
vector19:
  pushl $0
c0102b0a:	6a 00                	push   $0x0
  pushl $19
c0102b0c:	6a 13                	push   $0x13
  jmp __alltraps
c0102b0e:	e9 31 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102b13 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102b13:	6a 00                	push   $0x0
  pushl $20
c0102b15:	6a 14                	push   $0x14
  jmp __alltraps
c0102b17:	e9 28 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102b1c <vector21>:
.globl vector21
vector21:
  pushl $0
c0102b1c:	6a 00                	push   $0x0
  pushl $21
c0102b1e:	6a 15                	push   $0x15
  jmp __alltraps
c0102b20:	e9 1f ff ff ff       	jmp    c0102a44 <__alltraps>

c0102b25 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102b25:	6a 00                	push   $0x0
  pushl $22
c0102b27:	6a 16                	push   $0x16
  jmp __alltraps
c0102b29:	e9 16 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102b2e <vector23>:
.globl vector23
vector23:
  pushl $0
c0102b2e:	6a 00                	push   $0x0
  pushl $23
c0102b30:	6a 17                	push   $0x17
  jmp __alltraps
c0102b32:	e9 0d ff ff ff       	jmp    c0102a44 <__alltraps>

c0102b37 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102b37:	6a 00                	push   $0x0
  pushl $24
c0102b39:	6a 18                	push   $0x18
  jmp __alltraps
c0102b3b:	e9 04 ff ff ff       	jmp    c0102a44 <__alltraps>

c0102b40 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102b40:	6a 00                	push   $0x0
  pushl $25
c0102b42:	6a 19                	push   $0x19
  jmp __alltraps
c0102b44:	e9 fb fe ff ff       	jmp    c0102a44 <__alltraps>

c0102b49 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102b49:	6a 00                	push   $0x0
  pushl $26
c0102b4b:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102b4d:	e9 f2 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102b52 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102b52:	6a 00                	push   $0x0
  pushl $27
c0102b54:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102b56:	e9 e9 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102b5b <vector28>:
.globl vector28
vector28:
  pushl $0
c0102b5b:	6a 00                	push   $0x0
  pushl $28
c0102b5d:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102b5f:	e9 e0 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102b64 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102b64:	6a 00                	push   $0x0
  pushl $29
c0102b66:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102b68:	e9 d7 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102b6d <vector30>:
.globl vector30
vector30:
  pushl $0
c0102b6d:	6a 00                	push   $0x0
  pushl $30
c0102b6f:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102b71:	e9 ce fe ff ff       	jmp    c0102a44 <__alltraps>

c0102b76 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102b76:	6a 00                	push   $0x0
  pushl $31
c0102b78:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102b7a:	e9 c5 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102b7f <vector32>:
.globl vector32
vector32:
  pushl $0
c0102b7f:	6a 00                	push   $0x0
  pushl $32
c0102b81:	6a 20                	push   $0x20
  jmp __alltraps
c0102b83:	e9 bc fe ff ff       	jmp    c0102a44 <__alltraps>

c0102b88 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102b88:	6a 00                	push   $0x0
  pushl $33
c0102b8a:	6a 21                	push   $0x21
  jmp __alltraps
c0102b8c:	e9 b3 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102b91 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102b91:	6a 00                	push   $0x0
  pushl $34
c0102b93:	6a 22                	push   $0x22
  jmp __alltraps
c0102b95:	e9 aa fe ff ff       	jmp    c0102a44 <__alltraps>

c0102b9a <vector35>:
.globl vector35
vector35:
  pushl $0
c0102b9a:	6a 00                	push   $0x0
  pushl $35
c0102b9c:	6a 23                	push   $0x23
  jmp __alltraps
c0102b9e:	e9 a1 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102ba3 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102ba3:	6a 00                	push   $0x0
  pushl $36
c0102ba5:	6a 24                	push   $0x24
  jmp __alltraps
c0102ba7:	e9 98 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102bac <vector37>:
.globl vector37
vector37:
  pushl $0
c0102bac:	6a 00                	push   $0x0
  pushl $37
c0102bae:	6a 25                	push   $0x25
  jmp __alltraps
c0102bb0:	e9 8f fe ff ff       	jmp    c0102a44 <__alltraps>

c0102bb5 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102bb5:	6a 00                	push   $0x0
  pushl $38
c0102bb7:	6a 26                	push   $0x26
  jmp __alltraps
c0102bb9:	e9 86 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102bbe <vector39>:
.globl vector39
vector39:
  pushl $0
c0102bbe:	6a 00                	push   $0x0
  pushl $39
c0102bc0:	6a 27                	push   $0x27
  jmp __alltraps
c0102bc2:	e9 7d fe ff ff       	jmp    c0102a44 <__alltraps>

c0102bc7 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102bc7:	6a 00                	push   $0x0
  pushl $40
c0102bc9:	6a 28                	push   $0x28
  jmp __alltraps
c0102bcb:	e9 74 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102bd0 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102bd0:	6a 00                	push   $0x0
  pushl $41
c0102bd2:	6a 29                	push   $0x29
  jmp __alltraps
c0102bd4:	e9 6b fe ff ff       	jmp    c0102a44 <__alltraps>

c0102bd9 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102bd9:	6a 00                	push   $0x0
  pushl $42
c0102bdb:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102bdd:	e9 62 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102be2 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102be2:	6a 00                	push   $0x0
  pushl $43
c0102be4:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102be6:	e9 59 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102beb <vector44>:
.globl vector44
vector44:
  pushl $0
c0102beb:	6a 00                	push   $0x0
  pushl $44
c0102bed:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102bef:	e9 50 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102bf4 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102bf4:	6a 00                	push   $0x0
  pushl $45
c0102bf6:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102bf8:	e9 47 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102bfd <vector46>:
.globl vector46
vector46:
  pushl $0
c0102bfd:	6a 00                	push   $0x0
  pushl $46
c0102bff:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102c01:	e9 3e fe ff ff       	jmp    c0102a44 <__alltraps>

c0102c06 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102c06:	6a 00                	push   $0x0
  pushl $47
c0102c08:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102c0a:	e9 35 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102c0f <vector48>:
.globl vector48
vector48:
  pushl $0
c0102c0f:	6a 00                	push   $0x0
  pushl $48
c0102c11:	6a 30                	push   $0x30
  jmp __alltraps
c0102c13:	e9 2c fe ff ff       	jmp    c0102a44 <__alltraps>

c0102c18 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102c18:	6a 00                	push   $0x0
  pushl $49
c0102c1a:	6a 31                	push   $0x31
  jmp __alltraps
c0102c1c:	e9 23 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102c21 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102c21:	6a 00                	push   $0x0
  pushl $50
c0102c23:	6a 32                	push   $0x32
  jmp __alltraps
c0102c25:	e9 1a fe ff ff       	jmp    c0102a44 <__alltraps>

c0102c2a <vector51>:
.globl vector51
vector51:
  pushl $0
c0102c2a:	6a 00                	push   $0x0
  pushl $51
c0102c2c:	6a 33                	push   $0x33
  jmp __alltraps
c0102c2e:	e9 11 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102c33 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102c33:	6a 00                	push   $0x0
  pushl $52
c0102c35:	6a 34                	push   $0x34
  jmp __alltraps
c0102c37:	e9 08 fe ff ff       	jmp    c0102a44 <__alltraps>

c0102c3c <vector53>:
.globl vector53
vector53:
  pushl $0
c0102c3c:	6a 00                	push   $0x0
  pushl $53
c0102c3e:	6a 35                	push   $0x35
  jmp __alltraps
c0102c40:	e9 ff fd ff ff       	jmp    c0102a44 <__alltraps>

c0102c45 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102c45:	6a 00                	push   $0x0
  pushl $54
c0102c47:	6a 36                	push   $0x36
  jmp __alltraps
c0102c49:	e9 f6 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102c4e <vector55>:
.globl vector55
vector55:
  pushl $0
c0102c4e:	6a 00                	push   $0x0
  pushl $55
c0102c50:	6a 37                	push   $0x37
  jmp __alltraps
c0102c52:	e9 ed fd ff ff       	jmp    c0102a44 <__alltraps>

c0102c57 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102c57:	6a 00                	push   $0x0
  pushl $56
c0102c59:	6a 38                	push   $0x38
  jmp __alltraps
c0102c5b:	e9 e4 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102c60 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102c60:	6a 00                	push   $0x0
  pushl $57
c0102c62:	6a 39                	push   $0x39
  jmp __alltraps
c0102c64:	e9 db fd ff ff       	jmp    c0102a44 <__alltraps>

c0102c69 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102c69:	6a 00                	push   $0x0
  pushl $58
c0102c6b:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102c6d:	e9 d2 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102c72 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102c72:	6a 00                	push   $0x0
  pushl $59
c0102c74:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102c76:	e9 c9 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102c7b <vector60>:
.globl vector60
vector60:
  pushl $0
c0102c7b:	6a 00                	push   $0x0
  pushl $60
c0102c7d:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102c7f:	e9 c0 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102c84 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102c84:	6a 00                	push   $0x0
  pushl $61
c0102c86:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102c88:	e9 b7 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102c8d <vector62>:
.globl vector62
vector62:
  pushl $0
c0102c8d:	6a 00                	push   $0x0
  pushl $62
c0102c8f:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102c91:	e9 ae fd ff ff       	jmp    c0102a44 <__alltraps>

c0102c96 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102c96:	6a 00                	push   $0x0
  pushl $63
c0102c98:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102c9a:	e9 a5 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102c9f <vector64>:
.globl vector64
vector64:
  pushl $0
c0102c9f:	6a 00                	push   $0x0
  pushl $64
c0102ca1:	6a 40                	push   $0x40
  jmp __alltraps
c0102ca3:	e9 9c fd ff ff       	jmp    c0102a44 <__alltraps>

c0102ca8 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102ca8:	6a 00                	push   $0x0
  pushl $65
c0102caa:	6a 41                	push   $0x41
  jmp __alltraps
c0102cac:	e9 93 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102cb1 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102cb1:	6a 00                	push   $0x0
  pushl $66
c0102cb3:	6a 42                	push   $0x42
  jmp __alltraps
c0102cb5:	e9 8a fd ff ff       	jmp    c0102a44 <__alltraps>

c0102cba <vector67>:
.globl vector67
vector67:
  pushl $0
c0102cba:	6a 00                	push   $0x0
  pushl $67
c0102cbc:	6a 43                	push   $0x43
  jmp __alltraps
c0102cbe:	e9 81 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102cc3 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102cc3:	6a 00                	push   $0x0
  pushl $68
c0102cc5:	6a 44                	push   $0x44
  jmp __alltraps
c0102cc7:	e9 78 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102ccc <vector69>:
.globl vector69
vector69:
  pushl $0
c0102ccc:	6a 00                	push   $0x0
  pushl $69
c0102cce:	6a 45                	push   $0x45
  jmp __alltraps
c0102cd0:	e9 6f fd ff ff       	jmp    c0102a44 <__alltraps>

c0102cd5 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102cd5:	6a 00                	push   $0x0
  pushl $70
c0102cd7:	6a 46                	push   $0x46
  jmp __alltraps
c0102cd9:	e9 66 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102cde <vector71>:
.globl vector71
vector71:
  pushl $0
c0102cde:	6a 00                	push   $0x0
  pushl $71
c0102ce0:	6a 47                	push   $0x47
  jmp __alltraps
c0102ce2:	e9 5d fd ff ff       	jmp    c0102a44 <__alltraps>

c0102ce7 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102ce7:	6a 00                	push   $0x0
  pushl $72
c0102ce9:	6a 48                	push   $0x48
  jmp __alltraps
c0102ceb:	e9 54 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102cf0 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102cf0:	6a 00                	push   $0x0
  pushl $73
c0102cf2:	6a 49                	push   $0x49
  jmp __alltraps
c0102cf4:	e9 4b fd ff ff       	jmp    c0102a44 <__alltraps>

c0102cf9 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102cf9:	6a 00                	push   $0x0
  pushl $74
c0102cfb:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102cfd:	e9 42 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102d02 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102d02:	6a 00                	push   $0x0
  pushl $75
c0102d04:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102d06:	e9 39 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102d0b <vector76>:
.globl vector76
vector76:
  pushl $0
c0102d0b:	6a 00                	push   $0x0
  pushl $76
c0102d0d:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102d0f:	e9 30 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102d14 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102d14:	6a 00                	push   $0x0
  pushl $77
c0102d16:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102d18:	e9 27 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102d1d <vector78>:
.globl vector78
vector78:
  pushl $0
c0102d1d:	6a 00                	push   $0x0
  pushl $78
c0102d1f:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102d21:	e9 1e fd ff ff       	jmp    c0102a44 <__alltraps>

c0102d26 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102d26:	6a 00                	push   $0x0
  pushl $79
c0102d28:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102d2a:	e9 15 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102d2f <vector80>:
.globl vector80
vector80:
  pushl $0
c0102d2f:	6a 00                	push   $0x0
  pushl $80
c0102d31:	6a 50                	push   $0x50
  jmp __alltraps
c0102d33:	e9 0c fd ff ff       	jmp    c0102a44 <__alltraps>

c0102d38 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102d38:	6a 00                	push   $0x0
  pushl $81
c0102d3a:	6a 51                	push   $0x51
  jmp __alltraps
c0102d3c:	e9 03 fd ff ff       	jmp    c0102a44 <__alltraps>

c0102d41 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102d41:	6a 00                	push   $0x0
  pushl $82
c0102d43:	6a 52                	push   $0x52
  jmp __alltraps
c0102d45:	e9 fa fc ff ff       	jmp    c0102a44 <__alltraps>

c0102d4a <vector83>:
.globl vector83
vector83:
  pushl $0
c0102d4a:	6a 00                	push   $0x0
  pushl $83
c0102d4c:	6a 53                	push   $0x53
  jmp __alltraps
c0102d4e:	e9 f1 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102d53 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102d53:	6a 00                	push   $0x0
  pushl $84
c0102d55:	6a 54                	push   $0x54
  jmp __alltraps
c0102d57:	e9 e8 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102d5c <vector85>:
.globl vector85
vector85:
  pushl $0
c0102d5c:	6a 00                	push   $0x0
  pushl $85
c0102d5e:	6a 55                	push   $0x55
  jmp __alltraps
c0102d60:	e9 df fc ff ff       	jmp    c0102a44 <__alltraps>

c0102d65 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102d65:	6a 00                	push   $0x0
  pushl $86
c0102d67:	6a 56                	push   $0x56
  jmp __alltraps
c0102d69:	e9 d6 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102d6e <vector87>:
.globl vector87
vector87:
  pushl $0
c0102d6e:	6a 00                	push   $0x0
  pushl $87
c0102d70:	6a 57                	push   $0x57
  jmp __alltraps
c0102d72:	e9 cd fc ff ff       	jmp    c0102a44 <__alltraps>

c0102d77 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102d77:	6a 00                	push   $0x0
  pushl $88
c0102d79:	6a 58                	push   $0x58
  jmp __alltraps
c0102d7b:	e9 c4 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102d80 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102d80:	6a 00                	push   $0x0
  pushl $89
c0102d82:	6a 59                	push   $0x59
  jmp __alltraps
c0102d84:	e9 bb fc ff ff       	jmp    c0102a44 <__alltraps>

c0102d89 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102d89:	6a 00                	push   $0x0
  pushl $90
c0102d8b:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102d8d:	e9 b2 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102d92 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102d92:	6a 00                	push   $0x0
  pushl $91
c0102d94:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102d96:	e9 a9 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102d9b <vector92>:
.globl vector92
vector92:
  pushl $0
c0102d9b:	6a 00                	push   $0x0
  pushl $92
c0102d9d:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102d9f:	e9 a0 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102da4 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102da4:	6a 00                	push   $0x0
  pushl $93
c0102da6:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102da8:	e9 97 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102dad <vector94>:
.globl vector94
vector94:
  pushl $0
c0102dad:	6a 00                	push   $0x0
  pushl $94
c0102daf:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102db1:	e9 8e fc ff ff       	jmp    c0102a44 <__alltraps>

c0102db6 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102db6:	6a 00                	push   $0x0
  pushl $95
c0102db8:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102dba:	e9 85 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102dbf <vector96>:
.globl vector96
vector96:
  pushl $0
c0102dbf:	6a 00                	push   $0x0
  pushl $96
c0102dc1:	6a 60                	push   $0x60
  jmp __alltraps
c0102dc3:	e9 7c fc ff ff       	jmp    c0102a44 <__alltraps>

c0102dc8 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102dc8:	6a 00                	push   $0x0
  pushl $97
c0102dca:	6a 61                	push   $0x61
  jmp __alltraps
c0102dcc:	e9 73 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102dd1 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102dd1:	6a 00                	push   $0x0
  pushl $98
c0102dd3:	6a 62                	push   $0x62
  jmp __alltraps
c0102dd5:	e9 6a fc ff ff       	jmp    c0102a44 <__alltraps>

c0102dda <vector99>:
.globl vector99
vector99:
  pushl $0
c0102dda:	6a 00                	push   $0x0
  pushl $99
c0102ddc:	6a 63                	push   $0x63
  jmp __alltraps
c0102dde:	e9 61 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102de3 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102de3:	6a 00                	push   $0x0
  pushl $100
c0102de5:	6a 64                	push   $0x64
  jmp __alltraps
c0102de7:	e9 58 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102dec <vector101>:
.globl vector101
vector101:
  pushl $0
c0102dec:	6a 00                	push   $0x0
  pushl $101
c0102dee:	6a 65                	push   $0x65
  jmp __alltraps
c0102df0:	e9 4f fc ff ff       	jmp    c0102a44 <__alltraps>

c0102df5 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102df5:	6a 00                	push   $0x0
  pushl $102
c0102df7:	6a 66                	push   $0x66
  jmp __alltraps
c0102df9:	e9 46 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102dfe <vector103>:
.globl vector103
vector103:
  pushl $0
c0102dfe:	6a 00                	push   $0x0
  pushl $103
c0102e00:	6a 67                	push   $0x67
  jmp __alltraps
c0102e02:	e9 3d fc ff ff       	jmp    c0102a44 <__alltraps>

c0102e07 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102e07:	6a 00                	push   $0x0
  pushl $104
c0102e09:	6a 68                	push   $0x68
  jmp __alltraps
c0102e0b:	e9 34 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102e10 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102e10:	6a 00                	push   $0x0
  pushl $105
c0102e12:	6a 69                	push   $0x69
  jmp __alltraps
c0102e14:	e9 2b fc ff ff       	jmp    c0102a44 <__alltraps>

c0102e19 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102e19:	6a 00                	push   $0x0
  pushl $106
c0102e1b:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102e1d:	e9 22 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102e22 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102e22:	6a 00                	push   $0x0
  pushl $107
c0102e24:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102e26:	e9 19 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102e2b <vector108>:
.globl vector108
vector108:
  pushl $0
c0102e2b:	6a 00                	push   $0x0
  pushl $108
c0102e2d:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102e2f:	e9 10 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102e34 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102e34:	6a 00                	push   $0x0
  pushl $109
c0102e36:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102e38:	e9 07 fc ff ff       	jmp    c0102a44 <__alltraps>

c0102e3d <vector110>:
.globl vector110
vector110:
  pushl $0
c0102e3d:	6a 00                	push   $0x0
  pushl $110
c0102e3f:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102e41:	e9 fe fb ff ff       	jmp    c0102a44 <__alltraps>

c0102e46 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102e46:	6a 00                	push   $0x0
  pushl $111
c0102e48:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102e4a:	e9 f5 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102e4f <vector112>:
.globl vector112
vector112:
  pushl $0
c0102e4f:	6a 00                	push   $0x0
  pushl $112
c0102e51:	6a 70                	push   $0x70
  jmp __alltraps
c0102e53:	e9 ec fb ff ff       	jmp    c0102a44 <__alltraps>

c0102e58 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102e58:	6a 00                	push   $0x0
  pushl $113
c0102e5a:	6a 71                	push   $0x71
  jmp __alltraps
c0102e5c:	e9 e3 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102e61 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102e61:	6a 00                	push   $0x0
  pushl $114
c0102e63:	6a 72                	push   $0x72
  jmp __alltraps
c0102e65:	e9 da fb ff ff       	jmp    c0102a44 <__alltraps>

c0102e6a <vector115>:
.globl vector115
vector115:
  pushl $0
c0102e6a:	6a 00                	push   $0x0
  pushl $115
c0102e6c:	6a 73                	push   $0x73
  jmp __alltraps
c0102e6e:	e9 d1 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102e73 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102e73:	6a 00                	push   $0x0
  pushl $116
c0102e75:	6a 74                	push   $0x74
  jmp __alltraps
c0102e77:	e9 c8 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102e7c <vector117>:
.globl vector117
vector117:
  pushl $0
c0102e7c:	6a 00                	push   $0x0
  pushl $117
c0102e7e:	6a 75                	push   $0x75
  jmp __alltraps
c0102e80:	e9 bf fb ff ff       	jmp    c0102a44 <__alltraps>

c0102e85 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102e85:	6a 00                	push   $0x0
  pushl $118
c0102e87:	6a 76                	push   $0x76
  jmp __alltraps
c0102e89:	e9 b6 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102e8e <vector119>:
.globl vector119
vector119:
  pushl $0
c0102e8e:	6a 00                	push   $0x0
  pushl $119
c0102e90:	6a 77                	push   $0x77
  jmp __alltraps
c0102e92:	e9 ad fb ff ff       	jmp    c0102a44 <__alltraps>

c0102e97 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102e97:	6a 00                	push   $0x0
  pushl $120
c0102e99:	6a 78                	push   $0x78
  jmp __alltraps
c0102e9b:	e9 a4 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102ea0 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102ea0:	6a 00                	push   $0x0
  pushl $121
c0102ea2:	6a 79                	push   $0x79
  jmp __alltraps
c0102ea4:	e9 9b fb ff ff       	jmp    c0102a44 <__alltraps>

c0102ea9 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102ea9:	6a 00                	push   $0x0
  pushl $122
c0102eab:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102ead:	e9 92 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102eb2 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102eb2:	6a 00                	push   $0x0
  pushl $123
c0102eb4:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102eb6:	e9 89 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102ebb <vector124>:
.globl vector124
vector124:
  pushl $0
c0102ebb:	6a 00                	push   $0x0
  pushl $124
c0102ebd:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102ebf:	e9 80 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102ec4 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102ec4:	6a 00                	push   $0x0
  pushl $125
c0102ec6:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102ec8:	e9 77 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102ecd <vector126>:
.globl vector126
vector126:
  pushl $0
c0102ecd:	6a 00                	push   $0x0
  pushl $126
c0102ecf:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102ed1:	e9 6e fb ff ff       	jmp    c0102a44 <__alltraps>

c0102ed6 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102ed6:	6a 00                	push   $0x0
  pushl $127
c0102ed8:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102eda:	e9 65 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102edf <vector128>:
.globl vector128
vector128:
  pushl $0
c0102edf:	6a 00                	push   $0x0
  pushl $128
c0102ee1:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102ee6:	e9 59 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102eeb <vector129>:
.globl vector129
vector129:
  pushl $0
c0102eeb:	6a 00                	push   $0x0
  pushl $129
c0102eed:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102ef2:	e9 4d fb ff ff       	jmp    c0102a44 <__alltraps>

c0102ef7 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102ef7:	6a 00                	push   $0x0
  pushl $130
c0102ef9:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102efe:	e9 41 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102f03 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102f03:	6a 00                	push   $0x0
  pushl $131
c0102f05:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102f0a:	e9 35 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102f0f <vector132>:
.globl vector132
vector132:
  pushl $0
c0102f0f:	6a 00                	push   $0x0
  pushl $132
c0102f11:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102f16:	e9 29 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102f1b <vector133>:
.globl vector133
vector133:
  pushl $0
c0102f1b:	6a 00                	push   $0x0
  pushl $133
c0102f1d:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102f22:	e9 1d fb ff ff       	jmp    c0102a44 <__alltraps>

c0102f27 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102f27:	6a 00                	push   $0x0
  pushl $134
c0102f29:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102f2e:	e9 11 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102f33 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102f33:	6a 00                	push   $0x0
  pushl $135
c0102f35:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102f3a:	e9 05 fb ff ff       	jmp    c0102a44 <__alltraps>

c0102f3f <vector136>:
.globl vector136
vector136:
  pushl $0
c0102f3f:	6a 00                	push   $0x0
  pushl $136
c0102f41:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102f46:	e9 f9 fa ff ff       	jmp    c0102a44 <__alltraps>

c0102f4b <vector137>:
.globl vector137
vector137:
  pushl $0
c0102f4b:	6a 00                	push   $0x0
  pushl $137
c0102f4d:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102f52:	e9 ed fa ff ff       	jmp    c0102a44 <__alltraps>

c0102f57 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102f57:	6a 00                	push   $0x0
  pushl $138
c0102f59:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102f5e:	e9 e1 fa ff ff       	jmp    c0102a44 <__alltraps>

c0102f63 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102f63:	6a 00                	push   $0x0
  pushl $139
c0102f65:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102f6a:	e9 d5 fa ff ff       	jmp    c0102a44 <__alltraps>

c0102f6f <vector140>:
.globl vector140
vector140:
  pushl $0
c0102f6f:	6a 00                	push   $0x0
  pushl $140
c0102f71:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102f76:	e9 c9 fa ff ff       	jmp    c0102a44 <__alltraps>

c0102f7b <vector141>:
.globl vector141
vector141:
  pushl $0
c0102f7b:	6a 00                	push   $0x0
  pushl $141
c0102f7d:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102f82:	e9 bd fa ff ff       	jmp    c0102a44 <__alltraps>

c0102f87 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102f87:	6a 00                	push   $0x0
  pushl $142
c0102f89:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102f8e:	e9 b1 fa ff ff       	jmp    c0102a44 <__alltraps>

c0102f93 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102f93:	6a 00                	push   $0x0
  pushl $143
c0102f95:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102f9a:	e9 a5 fa ff ff       	jmp    c0102a44 <__alltraps>

c0102f9f <vector144>:
.globl vector144
vector144:
  pushl $0
c0102f9f:	6a 00                	push   $0x0
  pushl $144
c0102fa1:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102fa6:	e9 99 fa ff ff       	jmp    c0102a44 <__alltraps>

c0102fab <vector145>:
.globl vector145
vector145:
  pushl $0
c0102fab:	6a 00                	push   $0x0
  pushl $145
c0102fad:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102fb2:	e9 8d fa ff ff       	jmp    c0102a44 <__alltraps>

c0102fb7 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102fb7:	6a 00                	push   $0x0
  pushl $146
c0102fb9:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102fbe:	e9 81 fa ff ff       	jmp    c0102a44 <__alltraps>

c0102fc3 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102fc3:	6a 00                	push   $0x0
  pushl $147
c0102fc5:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102fca:	e9 75 fa ff ff       	jmp    c0102a44 <__alltraps>

c0102fcf <vector148>:
.globl vector148
vector148:
  pushl $0
c0102fcf:	6a 00                	push   $0x0
  pushl $148
c0102fd1:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102fd6:	e9 69 fa ff ff       	jmp    c0102a44 <__alltraps>

c0102fdb <vector149>:
.globl vector149
vector149:
  pushl $0
c0102fdb:	6a 00                	push   $0x0
  pushl $149
c0102fdd:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102fe2:	e9 5d fa ff ff       	jmp    c0102a44 <__alltraps>

c0102fe7 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102fe7:	6a 00                	push   $0x0
  pushl $150
c0102fe9:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102fee:	e9 51 fa ff ff       	jmp    c0102a44 <__alltraps>

c0102ff3 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102ff3:	6a 00                	push   $0x0
  pushl $151
c0102ff5:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102ffa:	e9 45 fa ff ff       	jmp    c0102a44 <__alltraps>

c0102fff <vector152>:
.globl vector152
vector152:
  pushl $0
c0102fff:	6a 00                	push   $0x0
  pushl $152
c0103001:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0103006:	e9 39 fa ff ff       	jmp    c0102a44 <__alltraps>

c010300b <vector153>:
.globl vector153
vector153:
  pushl $0
c010300b:	6a 00                	push   $0x0
  pushl $153
c010300d:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0103012:	e9 2d fa ff ff       	jmp    c0102a44 <__alltraps>

c0103017 <vector154>:
.globl vector154
vector154:
  pushl $0
c0103017:	6a 00                	push   $0x0
  pushl $154
c0103019:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010301e:	e9 21 fa ff ff       	jmp    c0102a44 <__alltraps>

c0103023 <vector155>:
.globl vector155
vector155:
  pushl $0
c0103023:	6a 00                	push   $0x0
  pushl $155
c0103025:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c010302a:	e9 15 fa ff ff       	jmp    c0102a44 <__alltraps>

c010302f <vector156>:
.globl vector156
vector156:
  pushl $0
c010302f:	6a 00                	push   $0x0
  pushl $156
c0103031:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0103036:	e9 09 fa ff ff       	jmp    c0102a44 <__alltraps>

c010303b <vector157>:
.globl vector157
vector157:
  pushl $0
c010303b:	6a 00                	push   $0x0
  pushl $157
c010303d:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0103042:	e9 fd f9 ff ff       	jmp    c0102a44 <__alltraps>

c0103047 <vector158>:
.globl vector158
vector158:
  pushl $0
c0103047:	6a 00                	push   $0x0
  pushl $158
c0103049:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010304e:	e9 f1 f9 ff ff       	jmp    c0102a44 <__alltraps>

c0103053 <vector159>:
.globl vector159
vector159:
  pushl $0
c0103053:	6a 00                	push   $0x0
  pushl $159
c0103055:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010305a:	e9 e5 f9 ff ff       	jmp    c0102a44 <__alltraps>

c010305f <vector160>:
.globl vector160
vector160:
  pushl $0
c010305f:	6a 00                	push   $0x0
  pushl $160
c0103061:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0103066:	e9 d9 f9 ff ff       	jmp    c0102a44 <__alltraps>

c010306b <vector161>:
.globl vector161
vector161:
  pushl $0
c010306b:	6a 00                	push   $0x0
  pushl $161
c010306d:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0103072:	e9 cd f9 ff ff       	jmp    c0102a44 <__alltraps>

c0103077 <vector162>:
.globl vector162
vector162:
  pushl $0
c0103077:	6a 00                	push   $0x0
  pushl $162
c0103079:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c010307e:	e9 c1 f9 ff ff       	jmp    c0102a44 <__alltraps>

c0103083 <vector163>:
.globl vector163
vector163:
  pushl $0
c0103083:	6a 00                	push   $0x0
  pushl $163
c0103085:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c010308a:	e9 b5 f9 ff ff       	jmp    c0102a44 <__alltraps>

c010308f <vector164>:
.globl vector164
vector164:
  pushl $0
c010308f:	6a 00                	push   $0x0
  pushl $164
c0103091:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0103096:	e9 a9 f9 ff ff       	jmp    c0102a44 <__alltraps>

c010309b <vector165>:
.globl vector165
vector165:
  pushl $0
c010309b:	6a 00                	push   $0x0
  pushl $165
c010309d:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01030a2:	e9 9d f9 ff ff       	jmp    c0102a44 <__alltraps>

c01030a7 <vector166>:
.globl vector166
vector166:
  pushl $0
c01030a7:	6a 00                	push   $0x0
  pushl $166
c01030a9:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01030ae:	e9 91 f9 ff ff       	jmp    c0102a44 <__alltraps>

c01030b3 <vector167>:
.globl vector167
vector167:
  pushl $0
c01030b3:	6a 00                	push   $0x0
  pushl $167
c01030b5:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01030ba:	e9 85 f9 ff ff       	jmp    c0102a44 <__alltraps>

c01030bf <vector168>:
.globl vector168
vector168:
  pushl $0
c01030bf:	6a 00                	push   $0x0
  pushl $168
c01030c1:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01030c6:	e9 79 f9 ff ff       	jmp    c0102a44 <__alltraps>

c01030cb <vector169>:
.globl vector169
vector169:
  pushl $0
c01030cb:	6a 00                	push   $0x0
  pushl $169
c01030cd:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01030d2:	e9 6d f9 ff ff       	jmp    c0102a44 <__alltraps>

c01030d7 <vector170>:
.globl vector170
vector170:
  pushl $0
c01030d7:	6a 00                	push   $0x0
  pushl $170
c01030d9:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01030de:	e9 61 f9 ff ff       	jmp    c0102a44 <__alltraps>

c01030e3 <vector171>:
.globl vector171
vector171:
  pushl $0
c01030e3:	6a 00                	push   $0x0
  pushl $171
c01030e5:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01030ea:	e9 55 f9 ff ff       	jmp    c0102a44 <__alltraps>

c01030ef <vector172>:
.globl vector172
vector172:
  pushl $0
c01030ef:	6a 00                	push   $0x0
  pushl $172
c01030f1:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01030f6:	e9 49 f9 ff ff       	jmp    c0102a44 <__alltraps>

c01030fb <vector173>:
.globl vector173
vector173:
  pushl $0
c01030fb:	6a 00                	push   $0x0
  pushl $173
c01030fd:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0103102:	e9 3d f9 ff ff       	jmp    c0102a44 <__alltraps>

c0103107 <vector174>:
.globl vector174
vector174:
  pushl $0
c0103107:	6a 00                	push   $0x0
  pushl $174
c0103109:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010310e:	e9 31 f9 ff ff       	jmp    c0102a44 <__alltraps>

c0103113 <vector175>:
.globl vector175
vector175:
  pushl $0
c0103113:	6a 00                	push   $0x0
  pushl $175
c0103115:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c010311a:	e9 25 f9 ff ff       	jmp    c0102a44 <__alltraps>

c010311f <vector176>:
.globl vector176
vector176:
  pushl $0
c010311f:	6a 00                	push   $0x0
  pushl $176
c0103121:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0103126:	e9 19 f9 ff ff       	jmp    c0102a44 <__alltraps>

c010312b <vector177>:
.globl vector177
vector177:
  pushl $0
c010312b:	6a 00                	push   $0x0
  pushl $177
c010312d:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0103132:	e9 0d f9 ff ff       	jmp    c0102a44 <__alltraps>

c0103137 <vector178>:
.globl vector178
vector178:
  pushl $0
c0103137:	6a 00                	push   $0x0
  pushl $178
c0103139:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010313e:	e9 01 f9 ff ff       	jmp    c0102a44 <__alltraps>

c0103143 <vector179>:
.globl vector179
vector179:
  pushl $0
c0103143:	6a 00                	push   $0x0
  pushl $179
c0103145:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c010314a:	e9 f5 f8 ff ff       	jmp    c0102a44 <__alltraps>

c010314f <vector180>:
.globl vector180
vector180:
  pushl $0
c010314f:	6a 00                	push   $0x0
  pushl $180
c0103151:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0103156:	e9 e9 f8 ff ff       	jmp    c0102a44 <__alltraps>

c010315b <vector181>:
.globl vector181
vector181:
  pushl $0
c010315b:	6a 00                	push   $0x0
  pushl $181
c010315d:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0103162:	e9 dd f8 ff ff       	jmp    c0102a44 <__alltraps>

c0103167 <vector182>:
.globl vector182
vector182:
  pushl $0
c0103167:	6a 00                	push   $0x0
  pushl $182
c0103169:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c010316e:	e9 d1 f8 ff ff       	jmp    c0102a44 <__alltraps>

c0103173 <vector183>:
.globl vector183
vector183:
  pushl $0
c0103173:	6a 00                	push   $0x0
  pushl $183
c0103175:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c010317a:	e9 c5 f8 ff ff       	jmp    c0102a44 <__alltraps>

c010317f <vector184>:
.globl vector184
vector184:
  pushl $0
c010317f:	6a 00                	push   $0x0
  pushl $184
c0103181:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0103186:	e9 b9 f8 ff ff       	jmp    c0102a44 <__alltraps>

c010318b <vector185>:
.globl vector185
vector185:
  pushl $0
c010318b:	6a 00                	push   $0x0
  pushl $185
c010318d:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0103192:	e9 ad f8 ff ff       	jmp    c0102a44 <__alltraps>

c0103197 <vector186>:
.globl vector186
vector186:
  pushl $0
c0103197:	6a 00                	push   $0x0
  pushl $186
c0103199:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010319e:	e9 a1 f8 ff ff       	jmp    c0102a44 <__alltraps>

c01031a3 <vector187>:
.globl vector187
vector187:
  pushl $0
c01031a3:	6a 00                	push   $0x0
  pushl $187
c01031a5:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01031aa:	e9 95 f8 ff ff       	jmp    c0102a44 <__alltraps>

c01031af <vector188>:
.globl vector188
vector188:
  pushl $0
c01031af:	6a 00                	push   $0x0
  pushl $188
c01031b1:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01031b6:	e9 89 f8 ff ff       	jmp    c0102a44 <__alltraps>

c01031bb <vector189>:
.globl vector189
vector189:
  pushl $0
c01031bb:	6a 00                	push   $0x0
  pushl $189
c01031bd:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01031c2:	e9 7d f8 ff ff       	jmp    c0102a44 <__alltraps>

c01031c7 <vector190>:
.globl vector190
vector190:
  pushl $0
c01031c7:	6a 00                	push   $0x0
  pushl $190
c01031c9:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01031ce:	e9 71 f8 ff ff       	jmp    c0102a44 <__alltraps>

c01031d3 <vector191>:
.globl vector191
vector191:
  pushl $0
c01031d3:	6a 00                	push   $0x0
  pushl $191
c01031d5:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01031da:	e9 65 f8 ff ff       	jmp    c0102a44 <__alltraps>

c01031df <vector192>:
.globl vector192
vector192:
  pushl $0
c01031df:	6a 00                	push   $0x0
  pushl $192
c01031e1:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01031e6:	e9 59 f8 ff ff       	jmp    c0102a44 <__alltraps>

c01031eb <vector193>:
.globl vector193
vector193:
  pushl $0
c01031eb:	6a 00                	push   $0x0
  pushl $193
c01031ed:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01031f2:	e9 4d f8 ff ff       	jmp    c0102a44 <__alltraps>

c01031f7 <vector194>:
.globl vector194
vector194:
  pushl $0
c01031f7:	6a 00                	push   $0x0
  pushl $194
c01031f9:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01031fe:	e9 41 f8 ff ff       	jmp    c0102a44 <__alltraps>

c0103203 <vector195>:
.globl vector195
vector195:
  pushl $0
c0103203:	6a 00                	push   $0x0
  pushl $195
c0103205:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c010320a:	e9 35 f8 ff ff       	jmp    c0102a44 <__alltraps>

c010320f <vector196>:
.globl vector196
vector196:
  pushl $0
c010320f:	6a 00                	push   $0x0
  pushl $196
c0103211:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103216:	e9 29 f8 ff ff       	jmp    c0102a44 <__alltraps>

c010321b <vector197>:
.globl vector197
vector197:
  pushl $0
c010321b:	6a 00                	push   $0x0
  pushl $197
c010321d:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0103222:	e9 1d f8 ff ff       	jmp    c0102a44 <__alltraps>

c0103227 <vector198>:
.globl vector198
vector198:
  pushl $0
c0103227:	6a 00                	push   $0x0
  pushl $198
c0103229:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010322e:	e9 11 f8 ff ff       	jmp    c0102a44 <__alltraps>

c0103233 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103233:	6a 00                	push   $0x0
  pushl $199
c0103235:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010323a:	e9 05 f8 ff ff       	jmp    c0102a44 <__alltraps>

c010323f <vector200>:
.globl vector200
vector200:
  pushl $0
c010323f:	6a 00                	push   $0x0
  pushl $200
c0103241:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103246:	e9 f9 f7 ff ff       	jmp    c0102a44 <__alltraps>

c010324b <vector201>:
.globl vector201
vector201:
  pushl $0
c010324b:	6a 00                	push   $0x0
  pushl $201
c010324d:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0103252:	e9 ed f7 ff ff       	jmp    c0102a44 <__alltraps>

c0103257 <vector202>:
.globl vector202
vector202:
  pushl $0
c0103257:	6a 00                	push   $0x0
  pushl $202
c0103259:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010325e:	e9 e1 f7 ff ff       	jmp    c0102a44 <__alltraps>

c0103263 <vector203>:
.globl vector203
vector203:
  pushl $0
c0103263:	6a 00                	push   $0x0
  pushl $203
c0103265:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c010326a:	e9 d5 f7 ff ff       	jmp    c0102a44 <__alltraps>

c010326f <vector204>:
.globl vector204
vector204:
  pushl $0
c010326f:	6a 00                	push   $0x0
  pushl $204
c0103271:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0103276:	e9 c9 f7 ff ff       	jmp    c0102a44 <__alltraps>

c010327b <vector205>:
.globl vector205
vector205:
  pushl $0
c010327b:	6a 00                	push   $0x0
  pushl $205
c010327d:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0103282:	e9 bd f7 ff ff       	jmp    c0102a44 <__alltraps>

c0103287 <vector206>:
.globl vector206
vector206:
  pushl $0
c0103287:	6a 00                	push   $0x0
  pushl $206
c0103289:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010328e:	e9 b1 f7 ff ff       	jmp    c0102a44 <__alltraps>

c0103293 <vector207>:
.globl vector207
vector207:
  pushl $0
c0103293:	6a 00                	push   $0x0
  pushl $207
c0103295:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c010329a:	e9 a5 f7 ff ff       	jmp    c0102a44 <__alltraps>

c010329f <vector208>:
.globl vector208
vector208:
  pushl $0
c010329f:	6a 00                	push   $0x0
  pushl $208
c01032a1:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01032a6:	e9 99 f7 ff ff       	jmp    c0102a44 <__alltraps>

c01032ab <vector209>:
.globl vector209
vector209:
  pushl $0
c01032ab:	6a 00                	push   $0x0
  pushl $209
c01032ad:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01032b2:	e9 8d f7 ff ff       	jmp    c0102a44 <__alltraps>

c01032b7 <vector210>:
.globl vector210
vector210:
  pushl $0
c01032b7:	6a 00                	push   $0x0
  pushl $210
c01032b9:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01032be:	e9 81 f7 ff ff       	jmp    c0102a44 <__alltraps>

c01032c3 <vector211>:
.globl vector211
vector211:
  pushl $0
c01032c3:	6a 00                	push   $0x0
  pushl $211
c01032c5:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01032ca:	e9 75 f7 ff ff       	jmp    c0102a44 <__alltraps>

c01032cf <vector212>:
.globl vector212
vector212:
  pushl $0
c01032cf:	6a 00                	push   $0x0
  pushl $212
c01032d1:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01032d6:	e9 69 f7 ff ff       	jmp    c0102a44 <__alltraps>

c01032db <vector213>:
.globl vector213
vector213:
  pushl $0
c01032db:	6a 00                	push   $0x0
  pushl $213
c01032dd:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01032e2:	e9 5d f7 ff ff       	jmp    c0102a44 <__alltraps>

c01032e7 <vector214>:
.globl vector214
vector214:
  pushl $0
c01032e7:	6a 00                	push   $0x0
  pushl $214
c01032e9:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01032ee:	e9 51 f7 ff ff       	jmp    c0102a44 <__alltraps>

c01032f3 <vector215>:
.globl vector215
vector215:
  pushl $0
c01032f3:	6a 00                	push   $0x0
  pushl $215
c01032f5:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01032fa:	e9 45 f7 ff ff       	jmp    c0102a44 <__alltraps>

c01032ff <vector216>:
.globl vector216
vector216:
  pushl $0
c01032ff:	6a 00                	push   $0x0
  pushl $216
c0103301:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103306:	e9 39 f7 ff ff       	jmp    c0102a44 <__alltraps>

c010330b <vector217>:
.globl vector217
vector217:
  pushl $0
c010330b:	6a 00                	push   $0x0
  pushl $217
c010330d:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103312:	e9 2d f7 ff ff       	jmp    c0102a44 <__alltraps>

c0103317 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103317:	6a 00                	push   $0x0
  pushl $218
c0103319:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010331e:	e9 21 f7 ff ff       	jmp    c0102a44 <__alltraps>

c0103323 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103323:	6a 00                	push   $0x0
  pushl $219
c0103325:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c010332a:	e9 15 f7 ff ff       	jmp    c0102a44 <__alltraps>

c010332f <vector220>:
.globl vector220
vector220:
  pushl $0
c010332f:	6a 00                	push   $0x0
  pushl $220
c0103331:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103336:	e9 09 f7 ff ff       	jmp    c0102a44 <__alltraps>

c010333b <vector221>:
.globl vector221
vector221:
  pushl $0
c010333b:	6a 00                	push   $0x0
  pushl $221
c010333d:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103342:	e9 fd f6 ff ff       	jmp    c0102a44 <__alltraps>

c0103347 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103347:	6a 00                	push   $0x0
  pushl $222
c0103349:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010334e:	e9 f1 f6 ff ff       	jmp    c0102a44 <__alltraps>

c0103353 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103353:	6a 00                	push   $0x0
  pushl $223
c0103355:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010335a:	e9 e5 f6 ff ff       	jmp    c0102a44 <__alltraps>

c010335f <vector224>:
.globl vector224
vector224:
  pushl $0
c010335f:	6a 00                	push   $0x0
  pushl $224
c0103361:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0103366:	e9 d9 f6 ff ff       	jmp    c0102a44 <__alltraps>

c010336b <vector225>:
.globl vector225
vector225:
  pushl $0
c010336b:	6a 00                	push   $0x0
  pushl $225
c010336d:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103372:	e9 cd f6 ff ff       	jmp    c0102a44 <__alltraps>

c0103377 <vector226>:
.globl vector226
vector226:
  pushl $0
c0103377:	6a 00                	push   $0x0
  pushl $226
c0103379:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010337e:	e9 c1 f6 ff ff       	jmp    c0102a44 <__alltraps>

c0103383 <vector227>:
.globl vector227
vector227:
  pushl $0
c0103383:	6a 00                	push   $0x0
  pushl $227
c0103385:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010338a:	e9 b5 f6 ff ff       	jmp    c0102a44 <__alltraps>

c010338f <vector228>:
.globl vector228
vector228:
  pushl $0
c010338f:	6a 00                	push   $0x0
  pushl $228
c0103391:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0103396:	e9 a9 f6 ff ff       	jmp    c0102a44 <__alltraps>

c010339b <vector229>:
.globl vector229
vector229:
  pushl $0
c010339b:	6a 00                	push   $0x0
  pushl $229
c010339d:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01033a2:	e9 9d f6 ff ff       	jmp    c0102a44 <__alltraps>

c01033a7 <vector230>:
.globl vector230
vector230:
  pushl $0
c01033a7:	6a 00                	push   $0x0
  pushl $230
c01033a9:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01033ae:	e9 91 f6 ff ff       	jmp    c0102a44 <__alltraps>

c01033b3 <vector231>:
.globl vector231
vector231:
  pushl $0
c01033b3:	6a 00                	push   $0x0
  pushl $231
c01033b5:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01033ba:	e9 85 f6 ff ff       	jmp    c0102a44 <__alltraps>

c01033bf <vector232>:
.globl vector232
vector232:
  pushl $0
c01033bf:	6a 00                	push   $0x0
  pushl $232
c01033c1:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01033c6:	e9 79 f6 ff ff       	jmp    c0102a44 <__alltraps>

c01033cb <vector233>:
.globl vector233
vector233:
  pushl $0
c01033cb:	6a 00                	push   $0x0
  pushl $233
c01033cd:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01033d2:	e9 6d f6 ff ff       	jmp    c0102a44 <__alltraps>

c01033d7 <vector234>:
.globl vector234
vector234:
  pushl $0
c01033d7:	6a 00                	push   $0x0
  pushl $234
c01033d9:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01033de:	e9 61 f6 ff ff       	jmp    c0102a44 <__alltraps>

c01033e3 <vector235>:
.globl vector235
vector235:
  pushl $0
c01033e3:	6a 00                	push   $0x0
  pushl $235
c01033e5:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01033ea:	e9 55 f6 ff ff       	jmp    c0102a44 <__alltraps>

c01033ef <vector236>:
.globl vector236
vector236:
  pushl $0
c01033ef:	6a 00                	push   $0x0
  pushl $236
c01033f1:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01033f6:	e9 49 f6 ff ff       	jmp    c0102a44 <__alltraps>

c01033fb <vector237>:
.globl vector237
vector237:
  pushl $0
c01033fb:	6a 00                	push   $0x0
  pushl $237
c01033fd:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103402:	e9 3d f6 ff ff       	jmp    c0102a44 <__alltraps>

c0103407 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103407:	6a 00                	push   $0x0
  pushl $238
c0103409:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010340e:	e9 31 f6 ff ff       	jmp    c0102a44 <__alltraps>

c0103413 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103413:	6a 00                	push   $0x0
  pushl $239
c0103415:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010341a:	e9 25 f6 ff ff       	jmp    c0102a44 <__alltraps>

c010341f <vector240>:
.globl vector240
vector240:
  pushl $0
c010341f:	6a 00                	push   $0x0
  pushl $240
c0103421:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103426:	e9 19 f6 ff ff       	jmp    c0102a44 <__alltraps>

c010342b <vector241>:
.globl vector241
vector241:
  pushl $0
c010342b:	6a 00                	push   $0x0
  pushl $241
c010342d:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103432:	e9 0d f6 ff ff       	jmp    c0102a44 <__alltraps>

c0103437 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103437:	6a 00                	push   $0x0
  pushl $242
c0103439:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010343e:	e9 01 f6 ff ff       	jmp    c0102a44 <__alltraps>

c0103443 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103443:	6a 00                	push   $0x0
  pushl $243
c0103445:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010344a:	e9 f5 f5 ff ff       	jmp    c0102a44 <__alltraps>

c010344f <vector244>:
.globl vector244
vector244:
  pushl $0
c010344f:	6a 00                	push   $0x0
  pushl $244
c0103451:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103456:	e9 e9 f5 ff ff       	jmp    c0102a44 <__alltraps>

c010345b <vector245>:
.globl vector245
vector245:
  pushl $0
c010345b:	6a 00                	push   $0x0
  pushl $245
c010345d:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103462:	e9 dd f5 ff ff       	jmp    c0102a44 <__alltraps>

c0103467 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103467:	6a 00                	push   $0x0
  pushl $246
c0103469:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010346e:	e9 d1 f5 ff ff       	jmp    c0102a44 <__alltraps>

c0103473 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103473:	6a 00                	push   $0x0
  pushl $247
c0103475:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010347a:	e9 c5 f5 ff ff       	jmp    c0102a44 <__alltraps>

c010347f <vector248>:
.globl vector248
vector248:
  pushl $0
c010347f:	6a 00                	push   $0x0
  pushl $248
c0103481:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0103486:	e9 b9 f5 ff ff       	jmp    c0102a44 <__alltraps>

c010348b <vector249>:
.globl vector249
vector249:
  pushl $0
c010348b:	6a 00                	push   $0x0
  pushl $249
c010348d:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0103492:	e9 ad f5 ff ff       	jmp    c0102a44 <__alltraps>

c0103497 <vector250>:
.globl vector250
vector250:
  pushl $0
c0103497:	6a 00                	push   $0x0
  pushl $250
c0103499:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010349e:	e9 a1 f5 ff ff       	jmp    c0102a44 <__alltraps>

c01034a3 <vector251>:
.globl vector251
vector251:
  pushl $0
c01034a3:	6a 00                	push   $0x0
  pushl $251
c01034a5:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01034aa:	e9 95 f5 ff ff       	jmp    c0102a44 <__alltraps>

c01034af <vector252>:
.globl vector252
vector252:
  pushl $0
c01034af:	6a 00                	push   $0x0
  pushl $252
c01034b1:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01034b6:	e9 89 f5 ff ff       	jmp    c0102a44 <__alltraps>

c01034bb <vector253>:
.globl vector253
vector253:
  pushl $0
c01034bb:	6a 00                	push   $0x0
  pushl $253
c01034bd:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01034c2:	e9 7d f5 ff ff       	jmp    c0102a44 <__alltraps>

c01034c7 <vector254>:
.globl vector254
vector254:
  pushl $0
c01034c7:	6a 00                	push   $0x0
  pushl $254
c01034c9:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01034ce:	e9 71 f5 ff ff       	jmp    c0102a44 <__alltraps>

c01034d3 <vector255>:
.globl vector255
vector255:
  pushl $0
c01034d3:	6a 00                	push   $0x0
  pushl $255
c01034d5:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01034da:	e9 65 f5 ff ff       	jmp    c0102a44 <__alltraps>

c01034df <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01034df:	55                   	push   %ebp
c01034e0:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01034e2:	8b 55 08             	mov    0x8(%ebp),%edx
c01034e5:	a1 90 0e 1b c0       	mov    0xc01b0e90,%eax
c01034ea:	29 c2                	sub    %eax,%edx
c01034ec:	89 d0                	mov    %edx,%eax
c01034ee:	c1 f8 05             	sar    $0x5,%eax
}
c01034f1:	5d                   	pop    %ebp
c01034f2:	c3                   	ret    

c01034f3 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01034f3:	55                   	push   %ebp
c01034f4:	89 e5                	mov    %esp,%ebp
c01034f6:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01034f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01034fc:	89 04 24             	mov    %eax,(%esp)
c01034ff:	e8 db ff ff ff       	call   c01034df <page2ppn>
c0103504:	c1 e0 0c             	shl    $0xc,%eax
}
c0103507:	c9                   	leave  
c0103508:	c3                   	ret    

c0103509 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103509:	55                   	push   %ebp
c010350a:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010350c:	8b 45 08             	mov    0x8(%ebp),%eax
c010350f:	8b 00                	mov    (%eax),%eax
}
c0103511:	5d                   	pop    %ebp
c0103512:	c3                   	ret    

c0103513 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103513:	55                   	push   %ebp
c0103514:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103516:	8b 45 08             	mov    0x8(%ebp),%eax
c0103519:	8b 55 0c             	mov    0xc(%ebp),%edx
c010351c:	89 10                	mov    %edx,(%eax)
}
c010351e:	5d                   	pop    %ebp
c010351f:	c3                   	ret    

c0103520 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0103520:	55                   	push   %ebp
c0103521:	89 e5                	mov    %esp,%ebp
c0103523:	83 ec 10             	sub    $0x10,%esp
c0103526:	c7 45 fc 7c 0e 1b c0 	movl   $0xc01b0e7c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010352d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103530:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103533:	89 50 04             	mov    %edx,0x4(%eax)
c0103536:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103539:	8b 50 04             	mov    0x4(%eax),%edx
c010353c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010353f:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0103541:	c7 05 84 0e 1b c0 00 	movl   $0x0,0xc01b0e84
c0103548:	00 00 00 
}
c010354b:	c9                   	leave  
c010354c:	c3                   	ret    

c010354d <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010354d:	55                   	push   %ebp
c010354e:	89 e5                	mov    %esp,%ebp
c0103550:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0103553:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103557:	75 24                	jne    c010357d <default_init_memmap+0x30>
c0103559:	c7 44 24 0c f0 cc 10 	movl   $0xc010ccf0,0xc(%esp)
c0103560:	c0 
c0103561:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103568:	c0 
c0103569:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
c0103570:	00 
c0103571:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103578:	e8 5d d8 ff ff       	call   c0100dda <__panic>
    struct Page *p = base;
c010357d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103580:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0103583:	e9 dc 00 00 00       	jmp    c0103664 <default_init_memmap+0x117>
        assert(PageReserved(p));
c0103588:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010358b:	83 c0 04             	add    $0x4,%eax
c010358e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0103595:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103598:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010359b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010359e:	0f a3 10             	bt     %edx,(%eax)
c01035a1:	19 c0                	sbb    %eax,%eax
c01035a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01035a6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01035aa:	0f 95 c0             	setne  %al
c01035ad:	0f b6 c0             	movzbl %al,%eax
c01035b0:	85 c0                	test   %eax,%eax
c01035b2:	75 24                	jne    c01035d8 <default_init_memmap+0x8b>
c01035b4:	c7 44 24 0c 21 cd 10 	movl   $0xc010cd21,0xc(%esp)
c01035bb:	c0 
c01035bc:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c01035c3:	c0 
c01035c4:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c01035cb:	00 
c01035cc:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c01035d3:	e8 02 d8 ff ff       	call   c0100dda <__panic>
        p->flags = 0;
c01035d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035db:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
c01035e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035e5:	83 c0 04             	add    $0x4,%eax
c01035e8:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01035ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01035f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01035f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01035f8:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c01035fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035fe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
c0103605:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010360c:	00 
c010360d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103610:	89 04 24             	mov    %eax,(%esp)
c0103613:	e8 fb fe ff ff       	call   c0103513 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
c0103618:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010361b:	83 c0 0c             	add    $0xc,%eax
c010361e:	c7 45 dc 7c 0e 1b c0 	movl   $0xc01b0e7c,-0x24(%ebp)
c0103625:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0103628:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010362b:	8b 00                	mov    (%eax),%eax
c010362d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103630:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103633:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103636:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103639:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010363c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010363f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103642:	89 10                	mov    %edx,(%eax)
c0103644:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103647:	8b 10                	mov    (%eax),%edx
c0103649:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010364c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010364f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103652:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103655:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103658:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010365b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010365e:	89 10                	mov    %edx,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0103660:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103664:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103667:	c1 e0 05             	shl    $0x5,%eax
c010366a:	89 c2                	mov    %eax,%edx
c010366c:	8b 45 08             	mov    0x8(%ebp),%eax
c010366f:	01 d0                	add    %edx,%eax
c0103671:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103674:	0f 85 0e ff ff ff    	jne    c0103588 <default_init_memmap+0x3b>
        p->property = 0;
        set_page_ref(p, 0);
        list_add_before(&free_list, &(p->page_link));
    }

    nr_free += n;
c010367a:	8b 15 84 0e 1b c0    	mov    0xc01b0e84,%edx
c0103680:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103683:	01 d0                	add    %edx,%eax
c0103685:	a3 84 0e 1b c0       	mov    %eax,0xc01b0e84
    //first block
    base->property = n;
c010368a:	8b 45 08             	mov    0x8(%ebp),%eax
c010368d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103690:	89 50 08             	mov    %edx,0x8(%eax)
}
c0103693:	c9                   	leave  
c0103694:	c3                   	ret    

c0103695 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0103695:	55                   	push   %ebp
c0103696:	89 e5                	mov    %esp,%ebp
c0103698:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c010369b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010369f:	75 24                	jne    c01036c5 <default_alloc_pages+0x30>
c01036a1:	c7 44 24 0c f0 cc 10 	movl   $0xc010ccf0,0xc(%esp)
c01036a8:	c0 
c01036a9:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c01036b0:	c0 
c01036b1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c01036b8:	00 
c01036b9:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c01036c0:	e8 15 d7 ff ff       	call   c0100dda <__panic>
    if (n > nr_free) {
c01036c5:	a1 84 0e 1b c0       	mov    0xc01b0e84,%eax
c01036ca:	3b 45 08             	cmp    0x8(%ebp),%eax
c01036cd:	73 0a                	jae    c01036d9 <default_alloc_pages+0x44>
        return NULL;
c01036cf:	b8 00 00 00 00       	mov    $0x0,%eax
c01036d4:	e9 37 01 00 00       	jmp    c0103810 <default_alloc_pages+0x17b>
    }
    list_entry_t *le, *len;
    le = &free_list;
c01036d9:	c7 45 f4 7c 0e 1b c0 	movl   $0xc01b0e7c,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {
c01036e0:	e9 0a 01 00 00       	jmp    c01037ef <default_alloc_pages+0x15a>
      struct Page *p = le2page(le, page_link);
c01036e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036e8:	83 e8 0c             	sub    $0xc,%eax
c01036eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){
c01036ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036f1:	8b 40 08             	mov    0x8(%eax),%eax
c01036f4:	3b 45 08             	cmp    0x8(%ebp),%eax
c01036f7:	0f 82 f2 00 00 00    	jb     c01037ef <default_alloc_pages+0x15a>
        int i;
        for(i=0;i<n;i++){
c01036fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0103704:	eb 7c                	jmp    c0103782 <default_alloc_pages+0xed>
c0103706:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103709:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010370c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010370f:	8b 40 04             	mov    0x4(%eax),%eax
          len = list_next(le);
c0103712:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *pp = le2page(le, page_link);
c0103715:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103718:	83 e8 0c             	sub    $0xc,%eax
c010371b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(pp);
c010371e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103721:	83 c0 04             	add    $0x4,%eax
c0103724:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010372b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010372e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103731:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103734:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(pp);
c0103737:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010373a:	83 c0 04             	add    $0x4,%eax
c010373d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0103744:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103747:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010374a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010374d:	0f b3 10             	btr    %edx,(%eax)
c0103750:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103753:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103756:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103759:	8b 40 04             	mov    0x4(%eax),%eax
c010375c:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010375f:	8b 12                	mov    (%edx),%edx
c0103761:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0103764:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103767:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010376a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010376d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103770:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103773:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103776:	89 10                	mov    %edx,(%eax)
          list_del(le);
          le = len;
c0103778:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010377b:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {
      struct Page *p = le2page(le, page_link);
      if(p->property >= n){
        int i;
        for(i=0;i<n;i++){
c010377e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c0103782:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103785:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103788:	0f 82 78 ff ff ff    	jb     c0103706 <default_alloc_pages+0x71>
          SetPageReserved(pp);
          ClearPageProperty(pp);
          list_del(le);
          le = len;
        }
        if(p->property>n){
c010378e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103791:	8b 40 08             	mov    0x8(%eax),%eax
c0103794:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103797:	76 12                	jbe    c01037ab <default_alloc_pages+0x116>
          (le2page(le,page_link))->property = p->property - n;
c0103799:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010379c:	8d 50 f4             	lea    -0xc(%eax),%edx
c010379f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037a2:	8b 40 08             	mov    0x8(%eax),%eax
c01037a5:	2b 45 08             	sub    0x8(%ebp),%eax
c01037a8:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
c01037ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037ae:	83 c0 04             	add    $0x4,%eax
c01037b1:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01037b8:	89 45 bc             	mov    %eax,-0x44(%ebp)
c01037bb:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01037be:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01037c1:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
c01037c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037c7:	83 c0 04             	add    $0x4,%eax
c01037ca:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
c01037d1:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01037d4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01037d7:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01037da:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n;
c01037dd:	a1 84 0e 1b c0       	mov    0xc01b0e84,%eax
c01037e2:	2b 45 08             	sub    0x8(%ebp),%eax
c01037e5:	a3 84 0e 1b c0       	mov    %eax,0xc01b0e84
        return p;
c01037ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037ed:	eb 21                	jmp    c0103810 <default_alloc_pages+0x17b>
c01037ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037f2:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01037f5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01037f8:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    list_entry_t *le, *len;
    le = &free_list;

    while((le=list_next(le)) != &free_list) {
c01037fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01037fe:	81 7d f4 7c 0e 1b c0 	cmpl   $0xc01b0e7c,-0xc(%ebp)
c0103805:	0f 85 da fe ff ff    	jne    c01036e5 <default_alloc_pages+0x50>
        SetPageReserved(p);
        nr_free -= n;
        return p;
      }
    }
    return NULL;
c010380b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103810:	c9                   	leave  
c0103811:	c3                   	ret    

c0103812 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0103812:	55                   	push   %ebp
c0103813:	89 e5                	mov    %esp,%ebp
c0103815:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0103818:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010381c:	75 24                	jne    c0103842 <default_free_pages+0x30>
c010381e:	c7 44 24 0c f0 cc 10 	movl   $0xc010ccf0,0xc(%esp)
c0103825:	c0 
c0103826:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c010382d:	c0 
c010382e:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
c0103835:	00 
c0103836:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c010383d:	e8 98 d5 ff ff       	call   c0100dda <__panic>
    assert(PageReserved(base));
c0103842:	8b 45 08             	mov    0x8(%ebp),%eax
c0103845:	83 c0 04             	add    $0x4,%eax
c0103848:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010384f:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103852:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103855:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103858:	0f a3 10             	bt     %edx,(%eax)
c010385b:	19 c0                	sbb    %eax,%eax
c010385d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0103860:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103864:	0f 95 c0             	setne  %al
c0103867:	0f b6 c0             	movzbl %al,%eax
c010386a:	85 c0                	test   %eax,%eax
c010386c:	75 24                	jne    c0103892 <default_free_pages+0x80>
c010386e:	c7 44 24 0c 31 cd 10 	movl   $0xc010cd31,0xc(%esp)
c0103875:	c0 
c0103876:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c010387d:	c0 
c010387e:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
c0103885:	00 
c0103886:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c010388d:	e8 48 d5 ff ff       	call   c0100dda <__panic>

    list_entry_t *le = &free_list;
c0103892:	c7 45 f4 7c 0e 1b c0 	movl   $0xc01b0e7c,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c0103899:	eb 13                	jmp    c01038ae <default_free_pages+0x9c>
      p = le2page(le, page_link);
c010389b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010389e:	83 e8 0c             	sub    $0xc,%eax
c01038a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){
c01038a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038a7:	3b 45 08             	cmp    0x8(%ebp),%eax
c01038aa:	76 02                	jbe    c01038ae <default_free_pages+0x9c>
        break;
c01038ac:	eb 18                	jmp    c01038c6 <default_free_pages+0xb4>
c01038ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01038b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01038b7:	8b 40 04             	mov    0x4(%eax),%eax
    assert(n > 0);
    assert(PageReserved(base));

    list_entry_t *le = &free_list;
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c01038ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01038bd:	81 7d f4 7c 0e 1b c0 	cmpl   $0xc01b0e7c,-0xc(%ebp)
c01038c4:	75 d5                	jne    c010389b <default_free_pages+0x89>
      if(p>base){
        break;
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
c01038c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01038c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01038cc:	eb 4b                	jmp    c0103919 <default_free_pages+0x107>
      list_add_before(le, &(p->page_link));
c01038ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038d1:	8d 50 0c             	lea    0xc(%eax),%edx
c01038d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038d7:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01038da:	89 55 d8             	mov    %edx,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01038dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01038e0:	8b 00                	mov    (%eax),%eax
c01038e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01038e5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01038e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01038eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01038ee:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01038f1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01038f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01038f7:	89 10                	mov    %edx,(%eax)
c01038f9:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01038fc:	8b 10                	mov    (%eax),%edx
c01038fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103901:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103904:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103907:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010390a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010390d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103910:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103913:	89 10                	mov    %edx,(%eax)
      if(p>base){
        break;
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
c0103915:	83 45 f0 20          	addl   $0x20,-0x10(%ebp)
c0103919:	8b 45 0c             	mov    0xc(%ebp),%eax
c010391c:	c1 e0 05             	shl    $0x5,%eax
c010391f:	89 c2                	mov    %eax,%edx
c0103921:	8b 45 08             	mov    0x8(%ebp),%eax
c0103924:	01 d0                	add    %edx,%eax
c0103926:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103929:	77 a3                	ja     c01038ce <default_free_pages+0xbc>
      list_add_before(le, &(p->page_link));
    }
    base->flags = 0;
c010392b:	8b 45 08             	mov    0x8(%ebp),%eax
c010392e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
c0103935:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010393c:	00 
c010393d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103940:	89 04 24             	mov    %eax,(%esp)
c0103943:	e8 cb fb ff ff       	call   c0103513 <set_page_ref>
    ClearPageProperty(base);
c0103948:	8b 45 08             	mov    0x8(%ebp),%eax
c010394b:	83 c0 04             	add    $0x4,%eax
c010394e:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0103955:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103958:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010395b:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010395e:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
c0103961:	8b 45 08             	mov    0x8(%ebp),%eax
c0103964:	83 c0 04             	add    $0x4,%eax
c0103967:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010396e:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103971:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103974:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103977:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;
c010397a:	8b 45 08             	mov    0x8(%ebp),%eax
c010397d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103980:	89 50 08             	mov    %edx,0x8(%eax)
    
    p = le2page(le,page_link) ;
c0103983:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103986:	83 e8 0c             	sub    $0xc,%eax
c0103989:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if( base+n == p ){
c010398c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010398f:	c1 e0 05             	shl    $0x5,%eax
c0103992:	89 c2                	mov    %eax,%edx
c0103994:	8b 45 08             	mov    0x8(%ebp),%eax
c0103997:	01 d0                	add    %edx,%eax
c0103999:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010399c:	75 1e                	jne    c01039bc <default_free_pages+0x1aa>
      base->property += p->property;
c010399e:	8b 45 08             	mov    0x8(%ebp),%eax
c01039a1:	8b 50 08             	mov    0x8(%eax),%edx
c01039a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039a7:	8b 40 08             	mov    0x8(%eax),%eax
c01039aa:	01 c2                	add    %eax,%edx
c01039ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01039af:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
c01039b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039b5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    le = list_prev(&(base->page_link));
c01039bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01039bf:	83 c0 0c             	add    $0xc,%eax
c01039c2:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c01039c5:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01039c8:	8b 00                	mov    (%eax),%eax
c01039ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c01039cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039d0:	83 e8 0c             	sub    $0xc,%eax
c01039d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
c01039d6:	81 7d f4 7c 0e 1b c0 	cmpl   $0xc01b0e7c,-0xc(%ebp)
c01039dd:	74 57                	je     c0103a36 <default_free_pages+0x224>
c01039df:	8b 45 08             	mov    0x8(%ebp),%eax
c01039e2:	83 e8 20             	sub    $0x20,%eax
c01039e5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01039e8:	75 4c                	jne    c0103a36 <default_free_pages+0x224>
      while(le!=&free_list){
c01039ea:	eb 41                	jmp    c0103a2d <default_free_pages+0x21b>
        if(p->property){
c01039ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039ef:	8b 40 08             	mov    0x8(%eax),%eax
c01039f2:	85 c0                	test   %eax,%eax
c01039f4:	74 20                	je     c0103a16 <default_free_pages+0x204>
          p->property += base->property;
c01039f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039f9:	8b 50 08             	mov    0x8(%eax),%edx
c01039fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01039ff:	8b 40 08             	mov    0x8(%eax),%eax
c0103a02:	01 c2                	add    %eax,%edx
c0103a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a07:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c0103a0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a0d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
c0103a14:	eb 20                	jmp    c0103a36 <default_free_pages+0x224>
c0103a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a19:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0103a1c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103a1f:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
c0103a21:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
c0103a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a27:	83 e8 0c             	sub    $0xc,%eax
c0103a2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      p->property = 0;
    }
    le = list_prev(&(base->page_link));
    p = le2page(le, page_link);
    if(le!=&free_list && p==base-1){
      while(le!=&free_list){
c0103a2d:	81 7d f4 7c 0e 1b c0 	cmpl   $0xc01b0e7c,-0xc(%ebp)
c0103a34:	75 b6                	jne    c01039ec <default_free_pages+0x1da>
        }
        le = list_prev(le);
        p = le2page(le,page_link);
      }
    }
    nr_free += n;
c0103a36:	8b 15 84 0e 1b c0    	mov    0xc01b0e84,%edx
c0103a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a3f:	01 d0                	add    %edx,%eax
c0103a41:	a3 84 0e 1b c0       	mov    %eax,0xc01b0e84
    return ;
c0103a46:	90                   	nop
}
c0103a47:	c9                   	leave  
c0103a48:	c3                   	ret    

c0103a49 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103a49:	55                   	push   %ebp
c0103a4a:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103a4c:	a1 84 0e 1b c0       	mov    0xc01b0e84,%eax
}
c0103a51:	5d                   	pop    %ebp
c0103a52:	c3                   	ret    

c0103a53 <basic_check>:

static void
basic_check(void) {
c0103a53:	55                   	push   %ebp
c0103a54:	89 e5                	mov    %esp,%ebp
c0103a56:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103a59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a69:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103a6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a73:	e8 f5 15 00 00       	call   c010506d <alloc_pages>
c0103a78:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a7b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103a7f:	75 24                	jne    c0103aa5 <basic_check+0x52>
c0103a81:	c7 44 24 0c 44 cd 10 	movl   $0xc010cd44,0xc(%esp)
c0103a88:	c0 
c0103a89:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103a90:	c0 
c0103a91:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
c0103a98:	00 
c0103a99:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103aa0:	e8 35 d3 ff ff       	call   c0100dda <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103aa5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103aac:	e8 bc 15 00 00       	call   c010506d <alloc_pages>
c0103ab1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ab4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103ab8:	75 24                	jne    c0103ade <basic_check+0x8b>
c0103aba:	c7 44 24 0c 60 cd 10 	movl   $0xc010cd60,0xc(%esp)
c0103ac1:	c0 
c0103ac2:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103ac9:	c0 
c0103aca:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
c0103ad1:	00 
c0103ad2:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103ad9:	e8 fc d2 ff ff       	call   c0100dda <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103ade:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ae5:	e8 83 15 00 00       	call   c010506d <alloc_pages>
c0103aea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103aed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103af1:	75 24                	jne    c0103b17 <basic_check+0xc4>
c0103af3:	c7 44 24 0c 7c cd 10 	movl   $0xc010cd7c,0xc(%esp)
c0103afa:	c0 
c0103afb:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103b02:	c0 
c0103b03:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
c0103b0a:	00 
c0103b0b:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103b12:	e8 c3 d2 ff ff       	call   c0100dda <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103b17:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b1a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103b1d:	74 10                	je     c0103b2f <basic_check+0xdc>
c0103b1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b22:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103b25:	74 08                	je     c0103b2f <basic_check+0xdc>
c0103b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b2a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103b2d:	75 24                	jne    c0103b53 <basic_check+0x100>
c0103b2f:	c7 44 24 0c 98 cd 10 	movl   $0xc010cd98,0xc(%esp)
c0103b36:	c0 
c0103b37:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103b3e:	c0 
c0103b3f:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
c0103b46:	00 
c0103b47:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103b4e:	e8 87 d2 ff ff       	call   c0100dda <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103b53:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b56:	89 04 24             	mov    %eax,(%esp)
c0103b59:	e8 ab f9 ff ff       	call   c0103509 <page_ref>
c0103b5e:	85 c0                	test   %eax,%eax
c0103b60:	75 1e                	jne    c0103b80 <basic_check+0x12d>
c0103b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b65:	89 04 24             	mov    %eax,(%esp)
c0103b68:	e8 9c f9 ff ff       	call   c0103509 <page_ref>
c0103b6d:	85 c0                	test   %eax,%eax
c0103b6f:	75 0f                	jne    c0103b80 <basic_check+0x12d>
c0103b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b74:	89 04 24             	mov    %eax,(%esp)
c0103b77:	e8 8d f9 ff ff       	call   c0103509 <page_ref>
c0103b7c:	85 c0                	test   %eax,%eax
c0103b7e:	74 24                	je     c0103ba4 <basic_check+0x151>
c0103b80:	c7 44 24 0c bc cd 10 	movl   $0xc010cdbc,0xc(%esp)
c0103b87:	c0 
c0103b88:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103b8f:	c0 
c0103b90:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c0103b97:	00 
c0103b98:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103b9f:	e8 36 d2 ff ff       	call   c0100dda <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103ba4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ba7:	89 04 24             	mov    %eax,(%esp)
c0103baa:	e8 44 f9 ff ff       	call   c01034f3 <page2pa>
c0103baf:	8b 15 80 ed 1a c0    	mov    0xc01aed80,%edx
c0103bb5:	c1 e2 0c             	shl    $0xc,%edx
c0103bb8:	39 d0                	cmp    %edx,%eax
c0103bba:	72 24                	jb     c0103be0 <basic_check+0x18d>
c0103bbc:	c7 44 24 0c f8 cd 10 	movl   $0xc010cdf8,0xc(%esp)
c0103bc3:	c0 
c0103bc4:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103bcb:	c0 
c0103bcc:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
c0103bd3:	00 
c0103bd4:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103bdb:	e8 fa d1 ff ff       	call   c0100dda <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103be3:	89 04 24             	mov    %eax,(%esp)
c0103be6:	e8 08 f9 ff ff       	call   c01034f3 <page2pa>
c0103beb:	8b 15 80 ed 1a c0    	mov    0xc01aed80,%edx
c0103bf1:	c1 e2 0c             	shl    $0xc,%edx
c0103bf4:	39 d0                	cmp    %edx,%eax
c0103bf6:	72 24                	jb     c0103c1c <basic_check+0x1c9>
c0103bf8:	c7 44 24 0c 15 ce 10 	movl   $0xc010ce15,0xc(%esp)
c0103bff:	c0 
c0103c00:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103c07:	c0 
c0103c08:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c0103c0f:	00 
c0103c10:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103c17:	e8 be d1 ff ff       	call   c0100dda <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c1f:	89 04 24             	mov    %eax,(%esp)
c0103c22:	e8 cc f8 ff ff       	call   c01034f3 <page2pa>
c0103c27:	8b 15 80 ed 1a c0    	mov    0xc01aed80,%edx
c0103c2d:	c1 e2 0c             	shl    $0xc,%edx
c0103c30:	39 d0                	cmp    %edx,%eax
c0103c32:	72 24                	jb     c0103c58 <basic_check+0x205>
c0103c34:	c7 44 24 0c 32 ce 10 	movl   $0xc010ce32,0xc(%esp)
c0103c3b:	c0 
c0103c3c:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103c43:	c0 
c0103c44:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0103c4b:	00 
c0103c4c:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103c53:	e8 82 d1 ff ff       	call   c0100dda <__panic>

    list_entry_t free_list_store = free_list;
c0103c58:	a1 7c 0e 1b c0       	mov    0xc01b0e7c,%eax
c0103c5d:	8b 15 80 0e 1b c0    	mov    0xc01b0e80,%edx
c0103c63:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103c66:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103c69:	c7 45 e0 7c 0e 1b c0 	movl   $0xc01b0e7c,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103c70:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c73:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103c76:	89 50 04             	mov    %edx,0x4(%eax)
c0103c79:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c7c:	8b 50 04             	mov    0x4(%eax),%edx
c0103c7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c82:	89 10                	mov    %edx,(%eax)
c0103c84:	c7 45 dc 7c 0e 1b c0 	movl   $0xc01b0e7c,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103c8b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c8e:	8b 40 04             	mov    0x4(%eax),%eax
c0103c91:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103c94:	0f 94 c0             	sete   %al
c0103c97:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103c9a:	85 c0                	test   %eax,%eax
c0103c9c:	75 24                	jne    c0103cc2 <basic_check+0x26f>
c0103c9e:	c7 44 24 0c 4f ce 10 	movl   $0xc010ce4f,0xc(%esp)
c0103ca5:	c0 
c0103ca6:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103cad:	c0 
c0103cae:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0103cb5:	00 
c0103cb6:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103cbd:	e8 18 d1 ff ff       	call   c0100dda <__panic>

    unsigned int nr_free_store = nr_free;
c0103cc2:	a1 84 0e 1b c0       	mov    0xc01b0e84,%eax
c0103cc7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103cca:	c7 05 84 0e 1b c0 00 	movl   $0x0,0xc01b0e84
c0103cd1:	00 00 00 

    assert(alloc_page() == NULL);
c0103cd4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103cdb:	e8 8d 13 00 00       	call   c010506d <alloc_pages>
c0103ce0:	85 c0                	test   %eax,%eax
c0103ce2:	74 24                	je     c0103d08 <basic_check+0x2b5>
c0103ce4:	c7 44 24 0c 66 ce 10 	movl   $0xc010ce66,0xc(%esp)
c0103ceb:	c0 
c0103cec:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103cf3:	c0 
c0103cf4:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0103cfb:	00 
c0103cfc:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103d03:	e8 d2 d0 ff ff       	call   c0100dda <__panic>

    free_page(p0);
c0103d08:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d0f:	00 
c0103d10:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d13:	89 04 24             	mov    %eax,(%esp)
c0103d16:	e8 bd 13 00 00       	call   c01050d8 <free_pages>
    free_page(p1);
c0103d1b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d22:	00 
c0103d23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d26:	89 04 24             	mov    %eax,(%esp)
c0103d29:	e8 aa 13 00 00       	call   c01050d8 <free_pages>
    free_page(p2);
c0103d2e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d35:	00 
c0103d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d39:	89 04 24             	mov    %eax,(%esp)
c0103d3c:	e8 97 13 00 00       	call   c01050d8 <free_pages>
    assert(nr_free == 3);
c0103d41:	a1 84 0e 1b c0       	mov    0xc01b0e84,%eax
c0103d46:	83 f8 03             	cmp    $0x3,%eax
c0103d49:	74 24                	je     c0103d6f <basic_check+0x31c>
c0103d4b:	c7 44 24 0c 7b ce 10 	movl   $0xc010ce7b,0xc(%esp)
c0103d52:	c0 
c0103d53:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103d5a:	c0 
c0103d5b:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0103d62:	00 
c0103d63:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103d6a:	e8 6b d0 ff ff       	call   c0100dda <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103d6f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d76:	e8 f2 12 00 00       	call   c010506d <alloc_pages>
c0103d7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103d7e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103d82:	75 24                	jne    c0103da8 <basic_check+0x355>
c0103d84:	c7 44 24 0c 44 cd 10 	movl   $0xc010cd44,0xc(%esp)
c0103d8b:	c0 
c0103d8c:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103d93:	c0 
c0103d94:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0103d9b:	00 
c0103d9c:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103da3:	e8 32 d0 ff ff       	call   c0100dda <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103da8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103daf:	e8 b9 12 00 00       	call   c010506d <alloc_pages>
c0103db4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103db7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103dbb:	75 24                	jne    c0103de1 <basic_check+0x38e>
c0103dbd:	c7 44 24 0c 60 cd 10 	movl   $0xc010cd60,0xc(%esp)
c0103dc4:	c0 
c0103dc5:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103dcc:	c0 
c0103dcd:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0103dd4:	00 
c0103dd5:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103ddc:	e8 f9 cf ff ff       	call   c0100dda <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103de1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103de8:	e8 80 12 00 00       	call   c010506d <alloc_pages>
c0103ded:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103df0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103df4:	75 24                	jne    c0103e1a <basic_check+0x3c7>
c0103df6:	c7 44 24 0c 7c cd 10 	movl   $0xc010cd7c,0xc(%esp)
c0103dfd:	c0 
c0103dfe:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103e05:	c0 
c0103e06:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0103e0d:	00 
c0103e0e:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103e15:	e8 c0 cf ff ff       	call   c0100dda <__panic>

    assert(alloc_page() == NULL);
c0103e1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e21:	e8 47 12 00 00       	call   c010506d <alloc_pages>
c0103e26:	85 c0                	test   %eax,%eax
c0103e28:	74 24                	je     c0103e4e <basic_check+0x3fb>
c0103e2a:	c7 44 24 0c 66 ce 10 	movl   $0xc010ce66,0xc(%esp)
c0103e31:	c0 
c0103e32:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103e39:	c0 
c0103e3a:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0103e41:	00 
c0103e42:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103e49:	e8 8c cf ff ff       	call   c0100dda <__panic>

    free_page(p0);
c0103e4e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e55:	00 
c0103e56:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e59:	89 04 24             	mov    %eax,(%esp)
c0103e5c:	e8 77 12 00 00       	call   c01050d8 <free_pages>
c0103e61:	c7 45 d8 7c 0e 1b c0 	movl   $0xc01b0e7c,-0x28(%ebp)
c0103e68:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103e6b:	8b 40 04             	mov    0x4(%eax),%eax
c0103e6e:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103e71:	0f 94 c0             	sete   %al
c0103e74:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103e77:	85 c0                	test   %eax,%eax
c0103e79:	74 24                	je     c0103e9f <basic_check+0x44c>
c0103e7b:	c7 44 24 0c 88 ce 10 	movl   $0xc010ce88,0xc(%esp)
c0103e82:	c0 
c0103e83:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103e8a:	c0 
c0103e8b:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0103e92:	00 
c0103e93:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103e9a:	e8 3b cf ff ff       	call   c0100dda <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103e9f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ea6:	e8 c2 11 00 00       	call   c010506d <alloc_pages>
c0103eab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103eb1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103eb4:	74 24                	je     c0103eda <basic_check+0x487>
c0103eb6:	c7 44 24 0c a0 ce 10 	movl   $0xc010cea0,0xc(%esp)
c0103ebd:	c0 
c0103ebe:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103ec5:	c0 
c0103ec6:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103ecd:	00 
c0103ece:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103ed5:	e8 00 cf ff ff       	call   c0100dda <__panic>
    assert(alloc_page() == NULL);
c0103eda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ee1:	e8 87 11 00 00       	call   c010506d <alloc_pages>
c0103ee6:	85 c0                	test   %eax,%eax
c0103ee8:	74 24                	je     c0103f0e <basic_check+0x4bb>
c0103eea:	c7 44 24 0c 66 ce 10 	movl   $0xc010ce66,0xc(%esp)
c0103ef1:	c0 
c0103ef2:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103ef9:	c0 
c0103efa:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0103f01:	00 
c0103f02:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103f09:	e8 cc ce ff ff       	call   c0100dda <__panic>

    assert(nr_free == 0);
c0103f0e:	a1 84 0e 1b c0       	mov    0xc01b0e84,%eax
c0103f13:	85 c0                	test   %eax,%eax
c0103f15:	74 24                	je     c0103f3b <basic_check+0x4e8>
c0103f17:	c7 44 24 0c b9 ce 10 	movl   $0xc010ceb9,0xc(%esp)
c0103f1e:	c0 
c0103f1f:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103f26:	c0 
c0103f27:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0103f2e:	00 
c0103f2f:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0103f36:	e8 9f ce ff ff       	call   c0100dda <__panic>
    free_list = free_list_store;
c0103f3b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103f3e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103f41:	a3 7c 0e 1b c0       	mov    %eax,0xc01b0e7c
c0103f46:	89 15 80 0e 1b c0    	mov    %edx,0xc01b0e80
    nr_free = nr_free_store;
c0103f4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f4f:	a3 84 0e 1b c0       	mov    %eax,0xc01b0e84

    free_page(p);
c0103f54:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f5b:	00 
c0103f5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f5f:	89 04 24             	mov    %eax,(%esp)
c0103f62:	e8 71 11 00 00       	call   c01050d8 <free_pages>
    free_page(p1);
c0103f67:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f6e:	00 
c0103f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f72:	89 04 24             	mov    %eax,(%esp)
c0103f75:	e8 5e 11 00 00       	call   c01050d8 <free_pages>
    free_page(p2);
c0103f7a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f81:	00 
c0103f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f85:	89 04 24             	mov    %eax,(%esp)
c0103f88:	e8 4b 11 00 00       	call   c01050d8 <free_pages>
}
c0103f8d:	c9                   	leave  
c0103f8e:	c3                   	ret    

c0103f8f <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103f8f:	55                   	push   %ebp
c0103f90:	89 e5                	mov    %esp,%ebp
c0103f92:	53                   	push   %ebx
c0103f93:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0103f99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103fa0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103fa7:	c7 45 ec 7c 0e 1b c0 	movl   $0xc01b0e7c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103fae:	eb 6b                	jmp    c010401b <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0103fb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103fb3:	83 e8 0c             	sub    $0xc,%eax
c0103fb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0103fb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103fbc:	83 c0 04             	add    $0x4,%eax
c0103fbf:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103fc6:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103fc9:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103fcc:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103fcf:	0f a3 10             	bt     %edx,(%eax)
c0103fd2:	19 c0                	sbb    %eax,%eax
c0103fd4:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103fd7:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103fdb:	0f 95 c0             	setne  %al
c0103fde:	0f b6 c0             	movzbl %al,%eax
c0103fe1:	85 c0                	test   %eax,%eax
c0103fe3:	75 24                	jne    c0104009 <default_check+0x7a>
c0103fe5:	c7 44 24 0c c6 ce 10 	movl   $0xc010cec6,0xc(%esp)
c0103fec:	c0 
c0103fed:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0103ff4:	c0 
c0103ff5:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0103ffc:	00 
c0103ffd:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0104004:	e8 d1 cd ff ff       	call   c0100dda <__panic>
        count ++, total += p->property;
c0104009:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010400d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104010:	8b 50 08             	mov    0x8(%eax),%edx
c0104013:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104016:	01 d0                	add    %edx,%eax
c0104018:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010401b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010401e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104021:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104024:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104027:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010402a:	81 7d ec 7c 0e 1b c0 	cmpl   $0xc01b0e7c,-0x14(%ebp)
c0104031:	0f 85 79 ff ff ff    	jne    c0103fb0 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0104037:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c010403a:	e8 cb 10 00 00       	call   c010510a <nr_free_pages>
c010403f:	39 c3                	cmp    %eax,%ebx
c0104041:	74 24                	je     c0104067 <default_check+0xd8>
c0104043:	c7 44 24 0c d6 ce 10 	movl   $0xc010ced6,0xc(%esp)
c010404a:	c0 
c010404b:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0104052:	c0 
c0104053:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c010405a:	00 
c010405b:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0104062:	e8 73 cd ff ff       	call   c0100dda <__panic>

    basic_check();
c0104067:	e8 e7 f9 ff ff       	call   c0103a53 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010406c:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104073:	e8 f5 0f 00 00       	call   c010506d <alloc_pages>
c0104078:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c010407b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010407f:	75 24                	jne    c01040a5 <default_check+0x116>
c0104081:	c7 44 24 0c ef ce 10 	movl   $0xc010ceef,0xc(%esp)
c0104088:	c0 
c0104089:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0104090:	c0 
c0104091:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0104098:	00 
c0104099:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c01040a0:	e8 35 cd ff ff       	call   c0100dda <__panic>
    assert(!PageProperty(p0));
c01040a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040a8:	83 c0 04             	add    $0x4,%eax
c01040ab:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01040b2:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01040b5:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01040b8:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01040bb:	0f a3 10             	bt     %edx,(%eax)
c01040be:	19 c0                	sbb    %eax,%eax
c01040c0:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01040c3:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01040c7:	0f 95 c0             	setne  %al
c01040ca:	0f b6 c0             	movzbl %al,%eax
c01040cd:	85 c0                	test   %eax,%eax
c01040cf:	74 24                	je     c01040f5 <default_check+0x166>
c01040d1:	c7 44 24 0c fa ce 10 	movl   $0xc010cefa,0xc(%esp)
c01040d8:	c0 
c01040d9:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c01040e0:	c0 
c01040e1:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c01040e8:	00 
c01040e9:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c01040f0:	e8 e5 cc ff ff       	call   c0100dda <__panic>

    list_entry_t free_list_store = free_list;
c01040f5:	a1 7c 0e 1b c0       	mov    0xc01b0e7c,%eax
c01040fa:	8b 15 80 0e 1b c0    	mov    0xc01b0e80,%edx
c0104100:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104103:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104106:	c7 45 b4 7c 0e 1b c0 	movl   $0xc01b0e7c,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010410d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104110:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104113:	89 50 04             	mov    %edx,0x4(%eax)
c0104116:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104119:	8b 50 04             	mov    0x4(%eax),%edx
c010411c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010411f:	89 10                	mov    %edx,(%eax)
c0104121:	c7 45 b0 7c 0e 1b c0 	movl   $0xc01b0e7c,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104128:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010412b:	8b 40 04             	mov    0x4(%eax),%eax
c010412e:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0104131:	0f 94 c0             	sete   %al
c0104134:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104137:	85 c0                	test   %eax,%eax
c0104139:	75 24                	jne    c010415f <default_check+0x1d0>
c010413b:	c7 44 24 0c 4f ce 10 	movl   $0xc010ce4f,0xc(%esp)
c0104142:	c0 
c0104143:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c010414a:	c0 
c010414b:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0104152:	00 
c0104153:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c010415a:	e8 7b cc ff ff       	call   c0100dda <__panic>
    assert(alloc_page() == NULL);
c010415f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104166:	e8 02 0f 00 00       	call   c010506d <alloc_pages>
c010416b:	85 c0                	test   %eax,%eax
c010416d:	74 24                	je     c0104193 <default_check+0x204>
c010416f:	c7 44 24 0c 66 ce 10 	movl   $0xc010ce66,0xc(%esp)
c0104176:	c0 
c0104177:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c010417e:	c0 
c010417f:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0104186:	00 
c0104187:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c010418e:	e8 47 cc ff ff       	call   c0100dda <__panic>

    unsigned int nr_free_store = nr_free;
c0104193:	a1 84 0e 1b c0       	mov    0xc01b0e84,%eax
c0104198:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c010419b:	c7 05 84 0e 1b c0 00 	movl   $0x0,0xc01b0e84
c01041a2:	00 00 00 

    free_pages(p0 + 2, 3);
c01041a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041a8:	83 c0 40             	add    $0x40,%eax
c01041ab:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01041b2:	00 
c01041b3:	89 04 24             	mov    %eax,(%esp)
c01041b6:	e8 1d 0f 00 00       	call   c01050d8 <free_pages>
    assert(alloc_pages(4) == NULL);
c01041bb:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01041c2:	e8 a6 0e 00 00       	call   c010506d <alloc_pages>
c01041c7:	85 c0                	test   %eax,%eax
c01041c9:	74 24                	je     c01041ef <default_check+0x260>
c01041cb:	c7 44 24 0c 0c cf 10 	movl   $0xc010cf0c,0xc(%esp)
c01041d2:	c0 
c01041d3:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c01041da:	c0 
c01041db:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01041e2:	00 
c01041e3:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c01041ea:	e8 eb cb ff ff       	call   c0100dda <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01041ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041f2:	83 c0 40             	add    $0x40,%eax
c01041f5:	83 c0 04             	add    $0x4,%eax
c01041f8:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01041ff:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104202:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104205:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104208:	0f a3 10             	bt     %edx,(%eax)
c010420b:	19 c0                	sbb    %eax,%eax
c010420d:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104210:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104214:	0f 95 c0             	setne  %al
c0104217:	0f b6 c0             	movzbl %al,%eax
c010421a:	85 c0                	test   %eax,%eax
c010421c:	74 0e                	je     c010422c <default_check+0x29d>
c010421e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104221:	83 c0 40             	add    $0x40,%eax
c0104224:	8b 40 08             	mov    0x8(%eax),%eax
c0104227:	83 f8 03             	cmp    $0x3,%eax
c010422a:	74 24                	je     c0104250 <default_check+0x2c1>
c010422c:	c7 44 24 0c 24 cf 10 	movl   $0xc010cf24,0xc(%esp)
c0104233:	c0 
c0104234:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c010423b:	c0 
c010423c:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0104243:	00 
c0104244:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c010424b:	e8 8a cb ff ff       	call   c0100dda <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104250:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104257:	e8 11 0e 00 00       	call   c010506d <alloc_pages>
c010425c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010425f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104263:	75 24                	jne    c0104289 <default_check+0x2fa>
c0104265:	c7 44 24 0c 50 cf 10 	movl   $0xc010cf50,0xc(%esp)
c010426c:	c0 
c010426d:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0104274:	c0 
c0104275:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c010427c:	00 
c010427d:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0104284:	e8 51 cb ff ff       	call   c0100dda <__panic>
    assert(alloc_page() == NULL);
c0104289:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104290:	e8 d8 0d 00 00       	call   c010506d <alloc_pages>
c0104295:	85 c0                	test   %eax,%eax
c0104297:	74 24                	je     c01042bd <default_check+0x32e>
c0104299:	c7 44 24 0c 66 ce 10 	movl   $0xc010ce66,0xc(%esp)
c01042a0:	c0 
c01042a1:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c01042a8:	c0 
c01042a9:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c01042b0:	00 
c01042b1:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c01042b8:	e8 1d cb ff ff       	call   c0100dda <__panic>
    assert(p0 + 2 == p1);
c01042bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042c0:	83 c0 40             	add    $0x40,%eax
c01042c3:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01042c6:	74 24                	je     c01042ec <default_check+0x35d>
c01042c8:	c7 44 24 0c 6e cf 10 	movl   $0xc010cf6e,0xc(%esp)
c01042cf:	c0 
c01042d0:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c01042d7:	c0 
c01042d8:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c01042df:	00 
c01042e0:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c01042e7:	e8 ee ca ff ff       	call   c0100dda <__panic>

    p2 = p0 + 1;
c01042ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042ef:	83 c0 20             	add    $0x20,%eax
c01042f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c01042f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01042fc:	00 
c01042fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104300:	89 04 24             	mov    %eax,(%esp)
c0104303:	e8 d0 0d 00 00       	call   c01050d8 <free_pages>
    free_pages(p1, 3);
c0104308:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010430f:	00 
c0104310:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104313:	89 04 24             	mov    %eax,(%esp)
c0104316:	e8 bd 0d 00 00       	call   c01050d8 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010431b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010431e:	83 c0 04             	add    $0x4,%eax
c0104321:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0104328:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010432b:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010432e:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104331:	0f a3 10             	bt     %edx,(%eax)
c0104334:	19 c0                	sbb    %eax,%eax
c0104336:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0104339:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010433d:	0f 95 c0             	setne  %al
c0104340:	0f b6 c0             	movzbl %al,%eax
c0104343:	85 c0                	test   %eax,%eax
c0104345:	74 0b                	je     c0104352 <default_check+0x3c3>
c0104347:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010434a:	8b 40 08             	mov    0x8(%eax),%eax
c010434d:	83 f8 01             	cmp    $0x1,%eax
c0104350:	74 24                	je     c0104376 <default_check+0x3e7>
c0104352:	c7 44 24 0c 7c cf 10 	movl   $0xc010cf7c,0xc(%esp)
c0104359:	c0 
c010435a:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c0104361:	c0 
c0104362:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0104369:	00 
c010436a:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c0104371:	e8 64 ca ff ff       	call   c0100dda <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104376:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104379:	83 c0 04             	add    $0x4,%eax
c010437c:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0104383:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104386:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104389:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010438c:	0f a3 10             	bt     %edx,(%eax)
c010438f:	19 c0                	sbb    %eax,%eax
c0104391:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0104394:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0104398:	0f 95 c0             	setne  %al
c010439b:	0f b6 c0             	movzbl %al,%eax
c010439e:	85 c0                	test   %eax,%eax
c01043a0:	74 0b                	je     c01043ad <default_check+0x41e>
c01043a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043a5:	8b 40 08             	mov    0x8(%eax),%eax
c01043a8:	83 f8 03             	cmp    $0x3,%eax
c01043ab:	74 24                	je     c01043d1 <default_check+0x442>
c01043ad:	c7 44 24 0c a4 cf 10 	movl   $0xc010cfa4,0xc(%esp)
c01043b4:	c0 
c01043b5:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c01043bc:	c0 
c01043bd:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c01043c4:	00 
c01043c5:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c01043cc:	e8 09 ca ff ff       	call   c0100dda <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01043d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01043d8:	e8 90 0c 00 00       	call   c010506d <alloc_pages>
c01043dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01043e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01043e3:	83 e8 20             	sub    $0x20,%eax
c01043e6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01043e9:	74 24                	je     c010440f <default_check+0x480>
c01043eb:	c7 44 24 0c ca cf 10 	movl   $0xc010cfca,0xc(%esp)
c01043f2:	c0 
c01043f3:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c01043fa:	c0 
c01043fb:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c0104402:	00 
c0104403:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c010440a:	e8 cb c9 ff ff       	call   c0100dda <__panic>
    free_page(p0);
c010440f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104416:	00 
c0104417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010441a:	89 04 24             	mov    %eax,(%esp)
c010441d:	e8 b6 0c 00 00       	call   c01050d8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0104422:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0104429:	e8 3f 0c 00 00       	call   c010506d <alloc_pages>
c010442e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104431:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104434:	83 c0 20             	add    $0x20,%eax
c0104437:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010443a:	74 24                	je     c0104460 <default_check+0x4d1>
c010443c:	c7 44 24 0c e8 cf 10 	movl   $0xc010cfe8,0xc(%esp)
c0104443:	c0 
c0104444:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c010444b:	c0 
c010444c:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c0104453:	00 
c0104454:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c010445b:	e8 7a c9 ff ff       	call   c0100dda <__panic>

    free_pages(p0, 2);
c0104460:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0104467:	00 
c0104468:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010446b:	89 04 24             	mov    %eax,(%esp)
c010446e:	e8 65 0c 00 00       	call   c01050d8 <free_pages>
    free_page(p2);
c0104473:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010447a:	00 
c010447b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010447e:	89 04 24             	mov    %eax,(%esp)
c0104481:	e8 52 0c 00 00       	call   c01050d8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0104486:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010448d:	e8 db 0b 00 00       	call   c010506d <alloc_pages>
c0104492:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104495:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104499:	75 24                	jne    c01044bf <default_check+0x530>
c010449b:	c7 44 24 0c 08 d0 10 	movl   $0xc010d008,0xc(%esp)
c01044a2:	c0 
c01044a3:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c01044aa:	c0 
c01044ab:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c01044b2:	00 
c01044b3:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c01044ba:	e8 1b c9 ff ff       	call   c0100dda <__panic>
    assert(alloc_page() == NULL);
c01044bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01044c6:	e8 a2 0b 00 00       	call   c010506d <alloc_pages>
c01044cb:	85 c0                	test   %eax,%eax
c01044cd:	74 24                	je     c01044f3 <default_check+0x564>
c01044cf:	c7 44 24 0c 66 ce 10 	movl   $0xc010ce66,0xc(%esp)
c01044d6:	c0 
c01044d7:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c01044de:	c0 
c01044df:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c01044e6:	00 
c01044e7:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c01044ee:	e8 e7 c8 ff ff       	call   c0100dda <__panic>

    assert(nr_free == 0);
c01044f3:	a1 84 0e 1b c0       	mov    0xc01b0e84,%eax
c01044f8:	85 c0                	test   %eax,%eax
c01044fa:	74 24                	je     c0104520 <default_check+0x591>
c01044fc:	c7 44 24 0c b9 ce 10 	movl   $0xc010ceb9,0xc(%esp)
c0104503:	c0 
c0104504:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c010450b:	c0 
c010450c:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0104513:	00 
c0104514:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c010451b:	e8 ba c8 ff ff       	call   c0100dda <__panic>
    nr_free = nr_free_store;
c0104520:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104523:	a3 84 0e 1b c0       	mov    %eax,0xc01b0e84

    free_list = free_list_store;
c0104528:	8b 45 80             	mov    -0x80(%ebp),%eax
c010452b:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010452e:	a3 7c 0e 1b c0       	mov    %eax,0xc01b0e7c
c0104533:	89 15 80 0e 1b c0    	mov    %edx,0xc01b0e80
    free_pages(p0, 5);
c0104539:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0104540:	00 
c0104541:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104544:	89 04 24             	mov    %eax,(%esp)
c0104547:	e8 8c 0b 00 00       	call   c01050d8 <free_pages>

    le = &free_list;
c010454c:	c7 45 ec 7c 0e 1b c0 	movl   $0xc01b0e7c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104553:	eb 1d                	jmp    c0104572 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c0104555:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104558:	83 e8 0c             	sub    $0xc,%eax
c010455b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c010455e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104562:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104565:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104568:	8b 40 08             	mov    0x8(%eax),%eax
c010456b:	29 c2                	sub    %eax,%edx
c010456d:	89 d0                	mov    %edx,%eax
c010456f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104572:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104575:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104578:	8b 45 88             	mov    -0x78(%ebp),%eax
c010457b:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010457e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104581:	81 7d ec 7c 0e 1b c0 	cmpl   $0xc01b0e7c,-0x14(%ebp)
c0104588:	75 cb                	jne    c0104555 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c010458a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010458e:	74 24                	je     c01045b4 <default_check+0x625>
c0104590:	c7 44 24 0c 26 d0 10 	movl   $0xc010d026,0xc(%esp)
c0104597:	c0 
c0104598:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c010459f:	c0 
c01045a0:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c01045a7:	00 
c01045a8:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c01045af:	e8 26 c8 ff ff       	call   c0100dda <__panic>
    assert(total == 0);
c01045b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01045b8:	74 24                	je     c01045de <default_check+0x64f>
c01045ba:	c7 44 24 0c 31 d0 10 	movl   $0xc010d031,0xc(%esp)
c01045c1:	c0 
c01045c2:	c7 44 24 08 f6 cc 10 	movl   $0xc010ccf6,0x8(%esp)
c01045c9:	c0 
c01045ca:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c01045d1:	00 
c01045d2:	c7 04 24 0b cd 10 c0 	movl   $0xc010cd0b,(%esp)
c01045d9:	e8 fc c7 ff ff       	call   c0100dda <__panic>
}
c01045de:	81 c4 94 00 00 00    	add    $0x94,%esp
c01045e4:	5b                   	pop    %ebx
c01045e5:	5d                   	pop    %ebp
c01045e6:	c3                   	ret    

c01045e7 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c01045e7:	55                   	push   %ebp
c01045e8:	89 e5                	mov    %esp,%ebp
c01045ea:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01045ed:	9c                   	pushf  
c01045ee:	58                   	pop    %eax
c01045ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01045f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01045f5:	25 00 02 00 00       	and    $0x200,%eax
c01045fa:	85 c0                	test   %eax,%eax
c01045fc:	74 0c                	je     c010460a <__intr_save+0x23>
        intr_disable();
c01045fe:	e8 2f da ff ff       	call   c0102032 <intr_disable>
        return 1;
c0104603:	b8 01 00 00 00       	mov    $0x1,%eax
c0104608:	eb 05                	jmp    c010460f <__intr_save+0x28>
    }
    return 0;
c010460a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010460f:	c9                   	leave  
c0104610:	c3                   	ret    

c0104611 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0104611:	55                   	push   %ebp
c0104612:	89 e5                	mov    %esp,%ebp
c0104614:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104617:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010461b:	74 05                	je     c0104622 <__intr_restore+0x11>
        intr_enable();
c010461d:	e8 0a da ff ff       	call   c010202c <intr_enable>
    }
}
c0104622:	c9                   	leave  
c0104623:	c3                   	ret    

c0104624 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104624:	55                   	push   %ebp
c0104625:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104627:	8b 55 08             	mov    0x8(%ebp),%edx
c010462a:	a1 90 0e 1b c0       	mov    0xc01b0e90,%eax
c010462f:	29 c2                	sub    %eax,%edx
c0104631:	89 d0                	mov    %edx,%eax
c0104633:	c1 f8 05             	sar    $0x5,%eax
}
c0104636:	5d                   	pop    %ebp
c0104637:	c3                   	ret    

c0104638 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104638:	55                   	push   %ebp
c0104639:	89 e5                	mov    %esp,%ebp
c010463b:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010463e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104641:	89 04 24             	mov    %eax,(%esp)
c0104644:	e8 db ff ff ff       	call   c0104624 <page2ppn>
c0104649:	c1 e0 0c             	shl    $0xc,%eax
}
c010464c:	c9                   	leave  
c010464d:	c3                   	ret    

c010464e <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010464e:	55                   	push   %ebp
c010464f:	89 e5                	mov    %esp,%ebp
c0104651:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104654:	8b 45 08             	mov    0x8(%ebp),%eax
c0104657:	c1 e8 0c             	shr    $0xc,%eax
c010465a:	89 c2                	mov    %eax,%edx
c010465c:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c0104661:	39 c2                	cmp    %eax,%edx
c0104663:	72 1c                	jb     c0104681 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104665:	c7 44 24 08 6c d0 10 	movl   $0xc010d06c,0x8(%esp)
c010466c:	c0 
c010466d:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104674:	00 
c0104675:	c7 04 24 8b d0 10 c0 	movl   $0xc010d08b,(%esp)
c010467c:	e8 59 c7 ff ff       	call   c0100dda <__panic>
    }
    return &pages[PPN(pa)];
c0104681:	a1 90 0e 1b c0       	mov    0xc01b0e90,%eax
c0104686:	8b 55 08             	mov    0x8(%ebp),%edx
c0104689:	c1 ea 0c             	shr    $0xc,%edx
c010468c:	c1 e2 05             	shl    $0x5,%edx
c010468f:	01 d0                	add    %edx,%eax
}
c0104691:	c9                   	leave  
c0104692:	c3                   	ret    

c0104693 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0104693:	55                   	push   %ebp
c0104694:	89 e5                	mov    %esp,%ebp
c0104696:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104699:	8b 45 08             	mov    0x8(%ebp),%eax
c010469c:	89 04 24             	mov    %eax,(%esp)
c010469f:	e8 94 ff ff ff       	call   c0104638 <page2pa>
c01046a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046aa:	c1 e8 0c             	shr    $0xc,%eax
c01046ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01046b0:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c01046b5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01046b8:	72 23                	jb     c01046dd <page2kva+0x4a>
c01046ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01046c1:	c7 44 24 08 9c d0 10 	movl   $0xc010d09c,0x8(%esp)
c01046c8:	c0 
c01046c9:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01046d0:	00 
c01046d1:	c7 04 24 8b d0 10 c0 	movl   $0xc010d08b,(%esp)
c01046d8:	e8 fd c6 ff ff       	call   c0100dda <__panic>
c01046dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046e0:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01046e5:	c9                   	leave  
c01046e6:	c3                   	ret    

c01046e7 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01046e7:	55                   	push   %ebp
c01046e8:	89 e5                	mov    %esp,%ebp
c01046ea:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01046ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01046f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046f3:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01046fa:	77 23                	ja     c010471f <kva2page+0x38>
c01046fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104703:	c7 44 24 08 c0 d0 10 	movl   $0xc010d0c0,0x8(%esp)
c010470a:	c0 
c010470b:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0104712:	00 
c0104713:	c7 04 24 8b d0 10 c0 	movl   $0xc010d08b,(%esp)
c010471a:	e8 bb c6 ff ff       	call   c0100dda <__panic>
c010471f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104722:	05 00 00 00 40       	add    $0x40000000,%eax
c0104727:	89 04 24             	mov    %eax,(%esp)
c010472a:	e8 1f ff ff ff       	call   c010464e <pa2page>
}
c010472f:	c9                   	leave  
c0104730:	c3                   	ret    

c0104731 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0104731:	55                   	push   %ebp
c0104732:	89 e5                	mov    %esp,%ebp
c0104734:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c0104737:	8b 45 0c             	mov    0xc(%ebp),%eax
c010473a:	ba 01 00 00 00       	mov    $0x1,%edx
c010473f:	89 c1                	mov    %eax,%ecx
c0104741:	d3 e2                	shl    %cl,%edx
c0104743:	89 d0                	mov    %edx,%eax
c0104745:	89 04 24             	mov    %eax,(%esp)
c0104748:	e8 20 09 00 00       	call   c010506d <alloc_pages>
c010474d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0104750:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104754:	75 07                	jne    c010475d <__slob_get_free_pages+0x2c>
    return NULL;
c0104756:	b8 00 00 00 00       	mov    $0x0,%eax
c010475b:	eb 0b                	jmp    c0104768 <__slob_get_free_pages+0x37>
  return page2kva(page);
c010475d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104760:	89 04 24             	mov    %eax,(%esp)
c0104763:	e8 2b ff ff ff       	call   c0104693 <page2kva>
}
c0104768:	c9                   	leave  
c0104769:	c3                   	ret    

c010476a <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c010476a:	55                   	push   %ebp
c010476b:	89 e5                	mov    %esp,%ebp
c010476d:	53                   	push   %ebx
c010476e:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c0104771:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104774:	ba 01 00 00 00       	mov    $0x1,%edx
c0104779:	89 c1                	mov    %eax,%ecx
c010477b:	d3 e2                	shl    %cl,%edx
c010477d:	89 d0                	mov    %edx,%eax
c010477f:	89 c3                	mov    %eax,%ebx
c0104781:	8b 45 08             	mov    0x8(%ebp),%eax
c0104784:	89 04 24             	mov    %eax,(%esp)
c0104787:	e8 5b ff ff ff       	call   c01046e7 <kva2page>
c010478c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104790:	89 04 24             	mov    %eax,(%esp)
c0104793:	e8 40 09 00 00       	call   c01050d8 <free_pages>
}
c0104798:	83 c4 14             	add    $0x14,%esp
c010479b:	5b                   	pop    %ebx
c010479c:	5d                   	pop    %ebp
c010479d:	c3                   	ret    

c010479e <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c010479e:	55                   	push   %ebp
c010479f:	89 e5                	mov    %esp,%ebp
c01047a1:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c01047a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01047a7:	83 c0 08             	add    $0x8,%eax
c01047aa:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c01047af:	76 24                	jbe    c01047d5 <slob_alloc+0x37>
c01047b1:	c7 44 24 0c e4 d0 10 	movl   $0xc010d0e4,0xc(%esp)
c01047b8:	c0 
c01047b9:	c7 44 24 08 03 d1 10 	movl   $0xc010d103,0x8(%esp)
c01047c0:	c0 
c01047c1:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01047c8:	00 
c01047c9:	c7 04 24 18 d1 10 c0 	movl   $0xc010d118,(%esp)
c01047d0:	e8 05 c6 ff ff       	call   c0100dda <__panic>

	slob_t *prev, *cur, *aligned = 0;
c01047d5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c01047dc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01047e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01047e6:	83 c0 07             	add    $0x7,%eax
c01047e9:	c1 e8 03             	shr    $0x3,%eax
c01047ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c01047ef:	e8 f3 fd ff ff       	call   c01045e7 <__intr_save>
c01047f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c01047f7:	a1 08 ca 12 c0       	mov    0xc012ca08,%eax
c01047fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01047ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104802:	8b 40 04             	mov    0x4(%eax),%eax
c0104805:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104808:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010480c:	74 25                	je     c0104833 <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c010480e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104811:	8b 45 10             	mov    0x10(%ebp),%eax
c0104814:	01 d0                	add    %edx,%eax
c0104816:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104819:	8b 45 10             	mov    0x10(%ebp),%eax
c010481c:	f7 d8                	neg    %eax
c010481e:	21 d0                	and    %edx,%eax
c0104820:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0104823:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104826:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104829:	29 c2                	sub    %eax,%edx
c010482b:	89 d0                	mov    %edx,%eax
c010482d:	c1 f8 03             	sar    $0x3,%eax
c0104830:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0104833:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104836:	8b 00                	mov    (%eax),%eax
c0104838:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010483b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c010483e:	01 ca                	add    %ecx,%edx
c0104840:	39 d0                	cmp    %edx,%eax
c0104842:	0f 8c aa 00 00 00    	jl     c01048f2 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c0104848:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010484c:	74 38                	je     c0104886 <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c010484e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104851:	8b 00                	mov    (%eax),%eax
c0104853:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0104856:	89 c2                	mov    %eax,%edx
c0104858:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010485b:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c010485d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104860:	8b 50 04             	mov    0x4(%eax),%edx
c0104863:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104866:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0104869:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010486c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010486f:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0104872:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104875:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104878:	89 10                	mov    %edx,(%eax)
				prev = cur;
c010487a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010487d:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0104880:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104883:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0104886:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104889:	8b 00                	mov    (%eax),%eax
c010488b:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010488e:	75 0e                	jne    c010489e <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c0104890:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104893:	8b 50 04             	mov    0x4(%eax),%edx
c0104896:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104899:	89 50 04             	mov    %edx,0x4(%eax)
c010489c:	eb 3c                	jmp    c01048da <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c010489e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048a1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01048a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048ab:	01 c2                	add    %eax,%edx
c01048ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048b0:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c01048b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048b6:	8b 40 04             	mov    0x4(%eax),%eax
c01048b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01048bc:	8b 12                	mov    (%edx),%edx
c01048be:	2b 55 e0             	sub    -0x20(%ebp),%edx
c01048c1:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c01048c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048c6:	8b 40 04             	mov    0x4(%eax),%eax
c01048c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01048cc:	8b 52 04             	mov    0x4(%edx),%edx
c01048cf:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c01048d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01048d8:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c01048da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048dd:	a3 08 ca 12 c0       	mov    %eax,0xc012ca08
			spin_unlock_irqrestore(&slob_lock, flags);
c01048e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048e5:	89 04 24             	mov    %eax,(%esp)
c01048e8:	e8 24 fd ff ff       	call   c0104611 <__intr_restore>
			return cur;
c01048ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048f0:	eb 7f                	jmp    c0104971 <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c01048f2:	a1 08 ca 12 c0       	mov    0xc012ca08,%eax
c01048f7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01048fa:	75 61                	jne    c010495d <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c01048fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048ff:	89 04 24             	mov    %eax,(%esp)
c0104902:	e8 0a fd ff ff       	call   c0104611 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0104907:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c010490e:	75 07                	jne    c0104917 <slob_alloc+0x179>
				return 0;
c0104910:	b8 00 00 00 00       	mov    $0x0,%eax
c0104915:	eb 5a                	jmp    c0104971 <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0104917:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010491e:	00 
c010491f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104922:	89 04 24             	mov    %eax,(%esp)
c0104925:	e8 07 fe ff ff       	call   c0104731 <__slob_get_free_pages>
c010492a:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c010492d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104931:	75 07                	jne    c010493a <slob_alloc+0x19c>
				return 0;
c0104933:	b8 00 00 00 00       	mov    $0x0,%eax
c0104938:	eb 37                	jmp    c0104971 <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c010493a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104941:	00 
c0104942:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104945:	89 04 24             	mov    %eax,(%esp)
c0104948:	e8 26 00 00 00       	call   c0104973 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c010494d:	e8 95 fc ff ff       	call   c01045e7 <__intr_save>
c0104952:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0104955:	a1 08 ca 12 c0       	mov    0xc012ca08,%eax
c010495a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c010495d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104960:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104963:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104966:	8b 40 04             	mov    0x4(%eax),%eax
c0104969:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c010496c:	e9 97 fe ff ff       	jmp    c0104808 <slob_alloc+0x6a>
}
c0104971:	c9                   	leave  
c0104972:	c3                   	ret    

c0104973 <slob_free>:

static void slob_free(void *block, int size)
{
c0104973:	55                   	push   %ebp
c0104974:	89 e5                	mov    %esp,%ebp
c0104976:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0104979:	8b 45 08             	mov    0x8(%ebp),%eax
c010497c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c010497f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104983:	75 05                	jne    c010498a <slob_free+0x17>
		return;
c0104985:	e9 ff 00 00 00       	jmp    c0104a89 <slob_free+0x116>

	if (size)
c010498a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010498e:	74 10                	je     c01049a0 <slob_free+0x2d>
		b->units = SLOB_UNITS(size);
c0104990:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104993:	83 c0 07             	add    $0x7,%eax
c0104996:	c1 e8 03             	shr    $0x3,%eax
c0104999:	89 c2                	mov    %eax,%edx
c010499b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010499e:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c01049a0:	e8 42 fc ff ff       	call   c01045e7 <__intr_save>
c01049a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01049a8:	a1 08 ca 12 c0       	mov    0xc012ca08,%eax
c01049ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01049b0:	eb 27                	jmp    c01049d9 <slob_free+0x66>
		if (cur >= cur->next && (b > cur || b < cur->next))
c01049b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049b5:	8b 40 04             	mov    0x4(%eax),%eax
c01049b8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01049bb:	77 13                	ja     c01049d0 <slob_free+0x5d>
c01049bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049c0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01049c3:	77 27                	ja     c01049ec <slob_free+0x79>
c01049c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049c8:	8b 40 04             	mov    0x4(%eax),%eax
c01049cb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01049ce:	77 1c                	ja     c01049ec <slob_free+0x79>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01049d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049d3:	8b 40 04             	mov    0x4(%eax),%eax
c01049d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01049d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049dc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01049df:	76 d1                	jbe    c01049b2 <slob_free+0x3f>
c01049e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049e4:	8b 40 04             	mov    0x4(%eax),%eax
c01049e7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01049ea:	76 c6                	jbe    c01049b2 <slob_free+0x3f>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c01049ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049ef:	8b 00                	mov    (%eax),%eax
c01049f1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01049f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049fb:	01 c2                	add    %eax,%edx
c01049fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a00:	8b 40 04             	mov    0x4(%eax),%eax
c0104a03:	39 c2                	cmp    %eax,%edx
c0104a05:	75 25                	jne    c0104a2c <slob_free+0xb9>
		b->units += cur->next->units;
c0104a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a0a:	8b 10                	mov    (%eax),%edx
c0104a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a0f:	8b 40 04             	mov    0x4(%eax),%eax
c0104a12:	8b 00                	mov    (%eax),%eax
c0104a14:	01 c2                	add    %eax,%edx
c0104a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a19:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0104a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a1e:	8b 40 04             	mov    0x4(%eax),%eax
c0104a21:	8b 50 04             	mov    0x4(%eax),%edx
c0104a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a27:	89 50 04             	mov    %edx,0x4(%eax)
c0104a2a:	eb 0c                	jmp    c0104a38 <slob_free+0xc5>
	} else
		b->next = cur->next;
c0104a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a2f:	8b 50 04             	mov    0x4(%eax),%edx
c0104a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a35:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0104a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a3b:	8b 00                	mov    (%eax),%eax
c0104a3d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a47:	01 d0                	add    %edx,%eax
c0104a49:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104a4c:	75 1f                	jne    c0104a6d <slob_free+0xfa>
		cur->units += b->units;
c0104a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a51:	8b 10                	mov    (%eax),%edx
c0104a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a56:	8b 00                	mov    (%eax),%eax
c0104a58:	01 c2                	add    %eax,%edx
c0104a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a5d:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0104a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a62:	8b 50 04             	mov    0x4(%eax),%edx
c0104a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a68:	89 50 04             	mov    %edx,0x4(%eax)
c0104a6b:	eb 09                	jmp    c0104a76 <slob_free+0x103>
	} else
		cur->next = b;
c0104a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a70:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104a73:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0104a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a79:	a3 08 ca 12 c0       	mov    %eax,0xc012ca08

	spin_unlock_irqrestore(&slob_lock, flags);
c0104a7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a81:	89 04 24             	mov    %eax,(%esp)
c0104a84:	e8 88 fb ff ff       	call   c0104611 <__intr_restore>
}
c0104a89:	c9                   	leave  
c0104a8a:	c3                   	ret    

c0104a8b <check_slab>:



void check_slab(void) {
c0104a8b:	55                   	push   %ebp
c0104a8c:	89 e5                	mov    %esp,%ebp
c0104a8e:	83 ec 18             	sub    $0x18,%esp
  cprintf("check_slab() success\n");
c0104a91:	c7 04 24 2a d1 10 c0 	movl   $0xc010d12a,(%esp)
c0104a98:	e8 bb b8 ff ff       	call   c0100358 <cprintf>
}
c0104a9d:	c9                   	leave  
c0104a9e:	c3                   	ret    

c0104a9f <slab_init>:
void
slab_init(void) {
c0104a9f:	55                   	push   %ebp
c0104aa0:	89 e5                	mov    %esp,%ebp
c0104aa2:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0104aa5:	c7 04 24 40 d1 10 c0 	movl   $0xc010d140,(%esp)
c0104aac:	e8 a7 b8 ff ff       	call   c0100358 <cprintf>
  check_slab();
c0104ab1:	e8 d5 ff ff ff       	call   c0104a8b <check_slab>
}
c0104ab6:	c9                   	leave  
c0104ab7:	c3                   	ret    

c0104ab8 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0104ab8:	55                   	push   %ebp
c0104ab9:	89 e5                	mov    %esp,%ebp
c0104abb:	83 ec 18             	sub    $0x18,%esp
    slab_init();
c0104abe:	e8 dc ff ff ff       	call   c0104a9f <slab_init>
    cprintf("kmalloc_init() succeeded!\n");
c0104ac3:	c7 04 24 54 d1 10 c0 	movl   $0xc010d154,(%esp)
c0104aca:	e8 89 b8 ff ff       	call   c0100358 <cprintf>
}
c0104acf:	c9                   	leave  
c0104ad0:	c3                   	ret    

c0104ad1 <slab_allocated>:

size_t
slab_allocated(void) {
c0104ad1:	55                   	push   %ebp
c0104ad2:	89 e5                	mov    %esp,%ebp
  return 0;
c0104ad4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104ad9:	5d                   	pop    %ebp
c0104ada:	c3                   	ret    

c0104adb <kallocated>:

size_t
kallocated(void) {
c0104adb:	55                   	push   %ebp
c0104adc:	89 e5                	mov    %esp,%ebp
   return slab_allocated();
c0104ade:	e8 ee ff ff ff       	call   c0104ad1 <slab_allocated>
}
c0104ae3:	5d                   	pop    %ebp
c0104ae4:	c3                   	ret    

c0104ae5 <find_order>:

static int find_order(int size)
{
c0104ae5:	55                   	push   %ebp
c0104ae6:	89 e5                	mov    %esp,%ebp
c0104ae8:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0104aeb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104af2:	eb 07                	jmp    c0104afb <find_order+0x16>
		order++;
c0104af4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c0104af8:	d1 7d 08             	sarl   0x8(%ebp)
c0104afb:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104b02:	7f f0                	jg     c0104af4 <find_order+0xf>
		order++;
	return order;
c0104b04:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104b07:	c9                   	leave  
c0104b08:	c3                   	ret    

c0104b09 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0104b09:	55                   	push   %ebp
c0104b0a:	89 e5                	mov    %esp,%ebp
c0104b0c:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0104b0f:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0104b16:	77 38                	ja     c0104b50 <__kmalloc+0x47>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0104b18:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b1b:	8d 50 08             	lea    0x8(%eax),%edx
c0104b1e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b25:	00 
c0104b26:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b2d:	89 14 24             	mov    %edx,(%esp)
c0104b30:	e8 69 fc ff ff       	call   c010479e <slob_alloc>
c0104b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0104b38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104b3c:	74 08                	je     c0104b46 <__kmalloc+0x3d>
c0104b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b41:	83 c0 08             	add    $0x8,%eax
c0104b44:	eb 05                	jmp    c0104b4b <__kmalloc+0x42>
c0104b46:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b4b:	e9 a6 00 00 00       	jmp    c0104bf6 <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0104b50:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b57:	00 
c0104b58:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b5f:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0104b66:	e8 33 fc ff ff       	call   c010479e <slob_alloc>
c0104b6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0104b6e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b72:	75 07                	jne    c0104b7b <__kmalloc+0x72>
		return 0;
c0104b74:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b79:	eb 7b                	jmp    c0104bf6 <__kmalloc+0xed>

	bb->order = find_order(size);
c0104b7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b7e:	89 04 24             	mov    %eax,(%esp)
c0104b81:	e8 5f ff ff ff       	call   c0104ae5 <find_order>
c0104b86:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104b89:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104b8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b8e:	8b 00                	mov    (%eax),%eax
c0104b90:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b94:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b97:	89 04 24             	mov    %eax,(%esp)
c0104b9a:	e8 92 fb ff ff       	call   c0104731 <__slob_get_free_pages>
c0104b9f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104ba2:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0104ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ba8:	8b 40 04             	mov    0x4(%eax),%eax
c0104bab:	85 c0                	test   %eax,%eax
c0104bad:	74 2f                	je     c0104bde <__kmalloc+0xd5>
		spin_lock_irqsave(&block_lock, flags);
c0104baf:	e8 33 fa ff ff       	call   c01045e7 <__intr_save>
c0104bb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c0104bb7:	8b 15 64 ed 1a c0    	mov    0xc01aed64,%edx
c0104bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bc0:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104bc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bc6:	a3 64 ed 1a c0       	mov    %eax,0xc01aed64
		spin_unlock_irqrestore(&block_lock, flags);
c0104bcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bce:	89 04 24             	mov    %eax,(%esp)
c0104bd1:	e8 3b fa ff ff       	call   c0104611 <__intr_restore>
		return bb->pages;
c0104bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bd9:	8b 40 04             	mov    0x4(%eax),%eax
c0104bdc:	eb 18                	jmp    c0104bf6 <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c0104bde:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104be5:	00 
c0104be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104be9:	89 04 24             	mov    %eax,(%esp)
c0104bec:	e8 82 fd ff ff       	call   c0104973 <slob_free>
	return 0;
c0104bf1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104bf6:	c9                   	leave  
c0104bf7:	c3                   	ret    

c0104bf8 <kmalloc>:

void *
kmalloc(size_t size)
{
c0104bf8:	55                   	push   %ebp
c0104bf9:	89 e5                	mov    %esp,%ebp
c0104bfb:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0104bfe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104c05:	00 
c0104c06:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c09:	89 04 24             	mov    %eax,(%esp)
c0104c0c:	e8 f8 fe ff ff       	call   c0104b09 <__kmalloc>
}
c0104c11:	c9                   	leave  
c0104c12:	c3                   	ret    

c0104c13 <kfree>:


void kfree(void *block)
{
c0104c13:	55                   	push   %ebp
c0104c14:	89 e5                	mov    %esp,%ebp
c0104c16:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0104c19:	c7 45 f0 64 ed 1a c0 	movl   $0xc01aed64,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104c20:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104c24:	75 05                	jne    c0104c2b <kfree+0x18>
		return;
c0104c26:	e9 a2 00 00 00       	jmp    c0104ccd <kfree+0xba>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104c2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c2e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104c33:	85 c0                	test   %eax,%eax
c0104c35:	75 7f                	jne    c0104cb6 <kfree+0xa3>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0104c37:	e8 ab f9 ff ff       	call   c01045e7 <__intr_save>
c0104c3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104c3f:	a1 64 ed 1a c0       	mov    0xc01aed64,%eax
c0104c44:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c47:	eb 5c                	jmp    c0104ca5 <kfree+0x92>
			if (bb->pages == block) {
c0104c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c4c:	8b 40 04             	mov    0x4(%eax),%eax
c0104c4f:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104c52:	75 3f                	jne    c0104c93 <kfree+0x80>
				*last = bb->next;
c0104c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c57:	8b 50 08             	mov    0x8(%eax),%edx
c0104c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c5d:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0104c5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c62:	89 04 24             	mov    %eax,(%esp)
c0104c65:	e8 a7 f9 ff ff       	call   c0104611 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0104c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c6d:	8b 10                	mov    (%eax),%edx
c0104c6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c72:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104c76:	89 04 24             	mov    %eax,(%esp)
c0104c79:	e8 ec fa ff ff       	call   c010476a <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0104c7e:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104c85:	00 
c0104c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c89:	89 04 24             	mov    %eax,(%esp)
c0104c8c:	e8 e2 fc ff ff       	call   c0104973 <slob_free>
				return;
c0104c91:	eb 3a                	jmp    c0104ccd <kfree+0xba>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c96:	83 c0 08             	add    $0x8,%eax
c0104c99:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c9f:	8b 40 08             	mov    0x8(%eax),%eax
c0104ca2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104ca5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104ca9:	75 9e                	jne    c0104c49 <kfree+0x36>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0104cab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104cae:	89 04 24             	mov    %eax,(%esp)
c0104cb1:	e8 5b f9 ff ff       	call   c0104611 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0104cb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cb9:	83 e8 08             	sub    $0x8,%eax
c0104cbc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104cc3:	00 
c0104cc4:	89 04 24             	mov    %eax,(%esp)
c0104cc7:	e8 a7 fc ff ff       	call   c0104973 <slob_free>
	return;
c0104ccc:	90                   	nop
}
c0104ccd:	c9                   	leave  
c0104cce:	c3                   	ret    

c0104ccf <ksize>:


unsigned int ksize(const void *block)
{
c0104ccf:	55                   	push   %ebp
c0104cd0:	89 e5                	mov    %esp,%ebp
c0104cd2:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0104cd5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104cd9:	75 07                	jne    c0104ce2 <ksize+0x13>
		return 0;
c0104cdb:	b8 00 00 00 00       	mov    $0x0,%eax
c0104ce0:	eb 6b                	jmp    c0104d4d <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104ce2:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ce5:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104cea:	85 c0                	test   %eax,%eax
c0104cec:	75 54                	jne    c0104d42 <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0104cee:	e8 f4 f8 ff ff       	call   c01045e7 <__intr_save>
c0104cf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0104cf6:	a1 64 ed 1a c0       	mov    0xc01aed64,%eax
c0104cfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104cfe:	eb 31                	jmp    c0104d31 <ksize+0x62>
			if (bb->pages == block) {
c0104d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d03:	8b 40 04             	mov    0x4(%eax),%eax
c0104d06:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104d09:	75 1d                	jne    c0104d28 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0104d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d0e:	89 04 24             	mov    %eax,(%esp)
c0104d11:	e8 fb f8 ff ff       	call   c0104611 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0104d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d19:	8b 00                	mov    (%eax),%eax
c0104d1b:	ba 00 10 00 00       	mov    $0x1000,%edx
c0104d20:	89 c1                	mov    %eax,%ecx
c0104d22:	d3 e2                	shl    %cl,%edx
c0104d24:	89 d0                	mov    %edx,%eax
c0104d26:	eb 25                	jmp    c0104d4d <ksize+0x7e>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c0104d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d2b:	8b 40 08             	mov    0x8(%eax),%eax
c0104d2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104d31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104d35:	75 c9                	jne    c0104d00 <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0104d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d3a:	89 04 24             	mov    %eax,(%esp)
c0104d3d:	e8 cf f8 ff ff       	call   c0104611 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0104d42:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d45:	83 e8 08             	sub    $0x8,%eax
c0104d48:	8b 00                	mov    (%eax),%eax
c0104d4a:	c1 e0 03             	shl    $0x3,%eax
}
c0104d4d:	c9                   	leave  
c0104d4e:	c3                   	ret    

c0104d4f <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104d4f:	55                   	push   %ebp
c0104d50:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104d52:	8b 55 08             	mov    0x8(%ebp),%edx
c0104d55:	a1 90 0e 1b c0       	mov    0xc01b0e90,%eax
c0104d5a:	29 c2                	sub    %eax,%edx
c0104d5c:	89 d0                	mov    %edx,%eax
c0104d5e:	c1 f8 05             	sar    $0x5,%eax
}
c0104d61:	5d                   	pop    %ebp
c0104d62:	c3                   	ret    

c0104d63 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104d63:	55                   	push   %ebp
c0104d64:	89 e5                	mov    %esp,%ebp
c0104d66:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104d69:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d6c:	89 04 24             	mov    %eax,(%esp)
c0104d6f:	e8 db ff ff ff       	call   c0104d4f <page2ppn>
c0104d74:	c1 e0 0c             	shl    $0xc,%eax
}
c0104d77:	c9                   	leave  
c0104d78:	c3                   	ret    

c0104d79 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104d79:	55                   	push   %ebp
c0104d7a:	89 e5                	mov    %esp,%ebp
c0104d7c:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104d7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d82:	c1 e8 0c             	shr    $0xc,%eax
c0104d85:	89 c2                	mov    %eax,%edx
c0104d87:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c0104d8c:	39 c2                	cmp    %eax,%edx
c0104d8e:	72 1c                	jb     c0104dac <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104d90:	c7 44 24 08 70 d1 10 	movl   $0xc010d170,0x8(%esp)
c0104d97:	c0 
c0104d98:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104d9f:	00 
c0104da0:	c7 04 24 8f d1 10 c0 	movl   $0xc010d18f,(%esp)
c0104da7:	e8 2e c0 ff ff       	call   c0100dda <__panic>
    }
    return &pages[PPN(pa)];
c0104dac:	a1 90 0e 1b c0       	mov    0xc01b0e90,%eax
c0104db1:	8b 55 08             	mov    0x8(%ebp),%edx
c0104db4:	c1 ea 0c             	shr    $0xc,%edx
c0104db7:	c1 e2 05             	shl    $0x5,%edx
c0104dba:	01 d0                	add    %edx,%eax
}
c0104dbc:	c9                   	leave  
c0104dbd:	c3                   	ret    

c0104dbe <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0104dbe:	55                   	push   %ebp
c0104dbf:	89 e5                	mov    %esp,%ebp
c0104dc1:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104dc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dc7:	89 04 24             	mov    %eax,(%esp)
c0104dca:	e8 94 ff ff ff       	call   c0104d63 <page2pa>
c0104dcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dd5:	c1 e8 0c             	shr    $0xc,%eax
c0104dd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ddb:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c0104de0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104de3:	72 23                	jb     c0104e08 <page2kva+0x4a>
c0104de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104de8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104dec:	c7 44 24 08 a0 d1 10 	movl   $0xc010d1a0,0x8(%esp)
c0104df3:	c0 
c0104df4:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0104dfb:	00 
c0104dfc:	c7 04 24 8f d1 10 c0 	movl   $0xc010d18f,(%esp)
c0104e03:	e8 d2 bf ff ff       	call   c0100dda <__panic>
c0104e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e0b:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104e10:	c9                   	leave  
c0104e11:	c3                   	ret    

c0104e12 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0104e12:	55                   	push   %ebp
c0104e13:	89 e5                	mov    %esp,%ebp
c0104e15:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104e18:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e1b:	83 e0 01             	and    $0x1,%eax
c0104e1e:	85 c0                	test   %eax,%eax
c0104e20:	75 1c                	jne    c0104e3e <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104e22:	c7 44 24 08 c4 d1 10 	movl   $0xc010d1c4,0x8(%esp)
c0104e29:	c0 
c0104e2a:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0104e31:	00 
c0104e32:	c7 04 24 8f d1 10 c0 	movl   $0xc010d18f,(%esp)
c0104e39:	e8 9c bf ff ff       	call   c0100dda <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0104e3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e41:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e46:	89 04 24             	mov    %eax,(%esp)
c0104e49:	e8 2b ff ff ff       	call   c0104d79 <pa2page>
}
c0104e4e:	c9                   	leave  
c0104e4f:	c3                   	ret    

c0104e50 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0104e50:	55                   	push   %ebp
c0104e51:	89 e5                	mov    %esp,%ebp
c0104e53:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0104e56:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e59:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e5e:	89 04 24             	mov    %eax,(%esp)
c0104e61:	e8 13 ff ff ff       	call   c0104d79 <pa2page>
}
c0104e66:	c9                   	leave  
c0104e67:	c3                   	ret    

c0104e68 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0104e68:	55                   	push   %ebp
c0104e69:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104e6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e6e:	8b 00                	mov    (%eax),%eax
}
c0104e70:	5d                   	pop    %ebp
c0104e71:	c3                   	ret    

c0104e72 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0104e72:	55                   	push   %ebp
c0104e73:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104e75:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e78:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104e7b:	89 10                	mov    %edx,(%eax)
}
c0104e7d:	5d                   	pop    %ebp
c0104e7e:	c3                   	ret    

c0104e7f <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0104e7f:	55                   	push   %ebp
c0104e80:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0104e82:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e85:	8b 00                	mov    (%eax),%eax
c0104e87:	8d 50 01             	lea    0x1(%eax),%edx
c0104e8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e8d:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104e8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e92:	8b 00                	mov    (%eax),%eax
}
c0104e94:	5d                   	pop    %ebp
c0104e95:	c3                   	ret    

c0104e96 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0104e96:	55                   	push   %ebp
c0104e97:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104e99:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e9c:	8b 00                	mov    (%eax),%eax
c0104e9e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104ea1:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ea4:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104ea6:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ea9:	8b 00                	mov    (%eax),%eax
}
c0104eab:	5d                   	pop    %ebp
c0104eac:	c3                   	ret    

c0104ead <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0104ead:	55                   	push   %ebp
c0104eae:	89 e5                	mov    %esp,%ebp
c0104eb0:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104eb3:	9c                   	pushf  
c0104eb4:	58                   	pop    %eax
c0104eb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104ebb:	25 00 02 00 00       	and    $0x200,%eax
c0104ec0:	85 c0                	test   %eax,%eax
c0104ec2:	74 0c                	je     c0104ed0 <__intr_save+0x23>
        intr_disable();
c0104ec4:	e8 69 d1 ff ff       	call   c0102032 <intr_disable>
        return 1;
c0104ec9:	b8 01 00 00 00       	mov    $0x1,%eax
c0104ece:	eb 05                	jmp    c0104ed5 <__intr_save+0x28>
    }
    return 0;
c0104ed0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104ed5:	c9                   	leave  
c0104ed6:	c3                   	ret    

c0104ed7 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0104ed7:	55                   	push   %ebp
c0104ed8:	89 e5                	mov    %esp,%ebp
c0104eda:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104edd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104ee1:	74 05                	je     c0104ee8 <__intr_restore+0x11>
        intr_enable();
c0104ee3:	e8 44 d1 ff ff       	call   c010202c <intr_enable>
    }
}
c0104ee8:	c9                   	leave  
c0104ee9:	c3                   	ret    

c0104eea <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0104eea:	55                   	push   %ebp
c0104eeb:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0104eed:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ef0:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0104ef3:	b8 23 00 00 00       	mov    $0x23,%eax
c0104ef8:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0104efa:	b8 23 00 00 00       	mov    $0x23,%eax
c0104eff:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0104f01:	b8 10 00 00 00       	mov    $0x10,%eax
c0104f06:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0104f08:	b8 10 00 00 00       	mov    $0x10,%eax
c0104f0d:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0104f0f:	b8 10 00 00 00       	mov    $0x10,%eax
c0104f14:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0104f16:	ea 1d 4f 10 c0 08 00 	ljmp   $0x8,$0xc0104f1d
}
c0104f1d:	5d                   	pop    %ebp
c0104f1e:	c3                   	ret    

c0104f1f <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104f1f:	55                   	push   %ebp
c0104f20:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0104f22:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f25:	a3 a4 ed 1a c0       	mov    %eax,0xc01aeda4
}
c0104f2a:	5d                   	pop    %ebp
c0104f2b:	c3                   	ret    

c0104f2c <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0104f2c:	55                   	push   %ebp
c0104f2d:	89 e5                	mov    %esp,%ebp
c0104f2f:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104f32:	b8 00 c0 12 c0       	mov    $0xc012c000,%eax
c0104f37:	89 04 24             	mov    %eax,(%esp)
c0104f3a:	e8 e0 ff ff ff       	call   c0104f1f <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104f3f:	66 c7 05 a8 ed 1a c0 	movw   $0x10,0xc01aeda8
c0104f46:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104f48:	66 c7 05 48 ca 12 c0 	movw   $0x68,0xc012ca48
c0104f4f:	68 00 
c0104f51:	b8 a0 ed 1a c0       	mov    $0xc01aeda0,%eax
c0104f56:	66 a3 4a ca 12 c0    	mov    %ax,0xc012ca4a
c0104f5c:	b8 a0 ed 1a c0       	mov    $0xc01aeda0,%eax
c0104f61:	c1 e8 10             	shr    $0x10,%eax
c0104f64:	a2 4c ca 12 c0       	mov    %al,0xc012ca4c
c0104f69:	0f b6 05 4d ca 12 c0 	movzbl 0xc012ca4d,%eax
c0104f70:	83 e0 f0             	and    $0xfffffff0,%eax
c0104f73:	83 c8 09             	or     $0x9,%eax
c0104f76:	a2 4d ca 12 c0       	mov    %al,0xc012ca4d
c0104f7b:	0f b6 05 4d ca 12 c0 	movzbl 0xc012ca4d,%eax
c0104f82:	83 e0 ef             	and    $0xffffffef,%eax
c0104f85:	a2 4d ca 12 c0       	mov    %al,0xc012ca4d
c0104f8a:	0f b6 05 4d ca 12 c0 	movzbl 0xc012ca4d,%eax
c0104f91:	83 e0 9f             	and    $0xffffff9f,%eax
c0104f94:	a2 4d ca 12 c0       	mov    %al,0xc012ca4d
c0104f99:	0f b6 05 4d ca 12 c0 	movzbl 0xc012ca4d,%eax
c0104fa0:	83 c8 80             	or     $0xffffff80,%eax
c0104fa3:	a2 4d ca 12 c0       	mov    %al,0xc012ca4d
c0104fa8:	0f b6 05 4e ca 12 c0 	movzbl 0xc012ca4e,%eax
c0104faf:	83 e0 f0             	and    $0xfffffff0,%eax
c0104fb2:	a2 4e ca 12 c0       	mov    %al,0xc012ca4e
c0104fb7:	0f b6 05 4e ca 12 c0 	movzbl 0xc012ca4e,%eax
c0104fbe:	83 e0 ef             	and    $0xffffffef,%eax
c0104fc1:	a2 4e ca 12 c0       	mov    %al,0xc012ca4e
c0104fc6:	0f b6 05 4e ca 12 c0 	movzbl 0xc012ca4e,%eax
c0104fcd:	83 e0 df             	and    $0xffffffdf,%eax
c0104fd0:	a2 4e ca 12 c0       	mov    %al,0xc012ca4e
c0104fd5:	0f b6 05 4e ca 12 c0 	movzbl 0xc012ca4e,%eax
c0104fdc:	83 c8 40             	or     $0x40,%eax
c0104fdf:	a2 4e ca 12 c0       	mov    %al,0xc012ca4e
c0104fe4:	0f b6 05 4e ca 12 c0 	movzbl 0xc012ca4e,%eax
c0104feb:	83 e0 7f             	and    $0x7f,%eax
c0104fee:	a2 4e ca 12 c0       	mov    %al,0xc012ca4e
c0104ff3:	b8 a0 ed 1a c0       	mov    $0xc01aeda0,%eax
c0104ff8:	c1 e8 18             	shr    $0x18,%eax
c0104ffb:	a2 4f ca 12 c0       	mov    %al,0xc012ca4f

    // reload all segment registers
    lgdt(&gdt_pd);
c0105000:	c7 04 24 50 ca 12 c0 	movl   $0xc012ca50,(%esp)
c0105007:	e8 de fe ff ff       	call   c0104eea <lgdt>
c010500c:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0105012:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0105016:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0105019:	c9                   	leave  
c010501a:	c3                   	ret    

c010501b <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c010501b:	55                   	push   %ebp
c010501c:	89 e5                	mov    %esp,%ebp
c010501e:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0105021:	c7 05 88 0e 1b c0 50 	movl   $0xc010d050,0xc01b0e88
c0105028:	d0 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c010502b:	a1 88 0e 1b c0       	mov    0xc01b0e88,%eax
c0105030:	8b 00                	mov    (%eax),%eax
c0105032:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105036:	c7 04 24 f0 d1 10 c0 	movl   $0xc010d1f0,(%esp)
c010503d:	e8 16 b3 ff ff       	call   c0100358 <cprintf>
    pmm_manager->init();
c0105042:	a1 88 0e 1b c0       	mov    0xc01b0e88,%eax
c0105047:	8b 40 04             	mov    0x4(%eax),%eax
c010504a:	ff d0                	call   *%eax
}
c010504c:	c9                   	leave  
c010504d:	c3                   	ret    

c010504e <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c010504e:	55                   	push   %ebp
c010504f:	89 e5                	mov    %esp,%ebp
c0105051:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0105054:	a1 88 0e 1b c0       	mov    0xc01b0e88,%eax
c0105059:	8b 40 08             	mov    0x8(%eax),%eax
c010505c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010505f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105063:	8b 55 08             	mov    0x8(%ebp),%edx
c0105066:	89 14 24             	mov    %edx,(%esp)
c0105069:	ff d0                	call   *%eax
}
c010506b:	c9                   	leave  
c010506c:	c3                   	ret    

c010506d <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c010506d:	55                   	push   %ebp
c010506e:	89 e5                	mov    %esp,%ebp
c0105070:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0105073:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c010507a:	e8 2e fe ff ff       	call   c0104ead <__intr_save>
c010507f:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0105082:	a1 88 0e 1b c0       	mov    0xc01b0e88,%eax
c0105087:	8b 40 0c             	mov    0xc(%eax),%eax
c010508a:	8b 55 08             	mov    0x8(%ebp),%edx
c010508d:	89 14 24             	mov    %edx,(%esp)
c0105090:	ff d0                	call   *%eax
c0105092:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0105095:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105098:	89 04 24             	mov    %eax,(%esp)
c010509b:	e8 37 fe ff ff       	call   c0104ed7 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c01050a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01050a4:	75 2d                	jne    c01050d3 <alloc_pages+0x66>
c01050a6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01050aa:	77 27                	ja     c01050d3 <alloc_pages+0x66>
c01050ac:	a1 0c ee 1a c0       	mov    0xc01aee0c,%eax
c01050b1:	85 c0                	test   %eax,%eax
c01050b3:	74 1e                	je     c01050d3 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c01050b5:	8b 55 08             	mov    0x8(%ebp),%edx
c01050b8:	a1 6c 0f 1b c0       	mov    0xc01b0f6c,%eax
c01050bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01050c4:	00 
c01050c5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01050c9:	89 04 24             	mov    %eax,(%esp)
c01050cc:	e8 b6 1d 00 00       	call   c0106e87 <swap_out>
    }
c01050d1:	eb a7                	jmp    c010507a <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01050d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01050d6:	c9                   	leave  
c01050d7:	c3                   	ret    

c01050d8 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01050d8:	55                   	push   %ebp
c01050d9:	89 e5                	mov    %esp,%ebp
c01050db:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01050de:	e8 ca fd ff ff       	call   c0104ead <__intr_save>
c01050e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01050e6:	a1 88 0e 1b c0       	mov    0xc01b0e88,%eax
c01050eb:	8b 40 10             	mov    0x10(%eax),%eax
c01050ee:	8b 55 0c             	mov    0xc(%ebp),%edx
c01050f1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01050f5:	8b 55 08             	mov    0x8(%ebp),%edx
c01050f8:	89 14 24             	mov    %edx,(%esp)
c01050fb:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01050fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105100:	89 04 24             	mov    %eax,(%esp)
c0105103:	e8 cf fd ff ff       	call   c0104ed7 <__intr_restore>
}
c0105108:	c9                   	leave  
c0105109:	c3                   	ret    

c010510a <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c010510a:	55                   	push   %ebp
c010510b:	89 e5                	mov    %esp,%ebp
c010510d:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0105110:	e8 98 fd ff ff       	call   c0104ead <__intr_save>
c0105115:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0105118:	a1 88 0e 1b c0       	mov    0xc01b0e88,%eax
c010511d:	8b 40 14             	mov    0x14(%eax),%eax
c0105120:	ff d0                	call   *%eax
c0105122:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0105125:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105128:	89 04 24             	mov    %eax,(%esp)
c010512b:	e8 a7 fd ff ff       	call   c0104ed7 <__intr_restore>
    return ret;
c0105130:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0105133:	c9                   	leave  
c0105134:	c3                   	ret    

c0105135 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0105135:	55                   	push   %ebp
c0105136:	89 e5                	mov    %esp,%ebp
c0105138:	57                   	push   %edi
c0105139:	56                   	push   %esi
c010513a:	53                   	push   %ebx
c010513b:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0105141:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0105148:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c010514f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0105156:	c7 04 24 07 d2 10 c0 	movl   $0xc010d207,(%esp)
c010515d:	e8 f6 b1 ff ff       	call   c0100358 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0105162:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105169:	e9 15 01 00 00       	jmp    c0105283 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010516e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105171:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105174:	89 d0                	mov    %edx,%eax
c0105176:	c1 e0 02             	shl    $0x2,%eax
c0105179:	01 d0                	add    %edx,%eax
c010517b:	c1 e0 02             	shl    $0x2,%eax
c010517e:	01 c8                	add    %ecx,%eax
c0105180:	8b 50 08             	mov    0x8(%eax),%edx
c0105183:	8b 40 04             	mov    0x4(%eax),%eax
c0105186:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0105189:	89 55 bc             	mov    %edx,-0x44(%ebp)
c010518c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010518f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105192:	89 d0                	mov    %edx,%eax
c0105194:	c1 e0 02             	shl    $0x2,%eax
c0105197:	01 d0                	add    %edx,%eax
c0105199:	c1 e0 02             	shl    $0x2,%eax
c010519c:	01 c8                	add    %ecx,%eax
c010519e:	8b 48 0c             	mov    0xc(%eax),%ecx
c01051a1:	8b 58 10             	mov    0x10(%eax),%ebx
c01051a4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01051a7:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01051aa:	01 c8                	add    %ecx,%eax
c01051ac:	11 da                	adc    %ebx,%edx
c01051ae:	89 45 b0             	mov    %eax,-0x50(%ebp)
c01051b1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01051b4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01051b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01051ba:	89 d0                	mov    %edx,%eax
c01051bc:	c1 e0 02             	shl    $0x2,%eax
c01051bf:	01 d0                	add    %edx,%eax
c01051c1:	c1 e0 02             	shl    $0x2,%eax
c01051c4:	01 c8                	add    %ecx,%eax
c01051c6:	83 c0 14             	add    $0x14,%eax
c01051c9:	8b 00                	mov    (%eax),%eax
c01051cb:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c01051d1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01051d4:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01051d7:	83 c0 ff             	add    $0xffffffff,%eax
c01051da:	83 d2 ff             	adc    $0xffffffff,%edx
c01051dd:	89 c6                	mov    %eax,%esi
c01051df:	89 d7                	mov    %edx,%edi
c01051e1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01051e4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01051e7:	89 d0                	mov    %edx,%eax
c01051e9:	c1 e0 02             	shl    $0x2,%eax
c01051ec:	01 d0                	add    %edx,%eax
c01051ee:	c1 e0 02             	shl    $0x2,%eax
c01051f1:	01 c8                	add    %ecx,%eax
c01051f3:	8b 48 0c             	mov    0xc(%eax),%ecx
c01051f6:	8b 58 10             	mov    0x10(%eax),%ebx
c01051f9:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01051ff:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0105203:	89 74 24 14          	mov    %esi,0x14(%esp)
c0105207:	89 7c 24 18          	mov    %edi,0x18(%esp)
c010520b:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010520e:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0105211:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105215:	89 54 24 10          	mov    %edx,0x10(%esp)
c0105219:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010521d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0105221:	c7 04 24 14 d2 10 c0 	movl   $0xc010d214,(%esp)
c0105228:	e8 2b b1 ff ff       	call   c0100358 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c010522d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105230:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105233:	89 d0                	mov    %edx,%eax
c0105235:	c1 e0 02             	shl    $0x2,%eax
c0105238:	01 d0                	add    %edx,%eax
c010523a:	c1 e0 02             	shl    $0x2,%eax
c010523d:	01 c8                	add    %ecx,%eax
c010523f:	83 c0 14             	add    $0x14,%eax
c0105242:	8b 00                	mov    (%eax),%eax
c0105244:	83 f8 01             	cmp    $0x1,%eax
c0105247:	75 36                	jne    c010527f <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0105249:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010524c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010524f:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0105252:	77 2b                	ja     c010527f <page_init+0x14a>
c0105254:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0105257:	72 05                	jb     c010525e <page_init+0x129>
c0105259:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c010525c:	73 21                	jae    c010527f <page_init+0x14a>
c010525e:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105262:	77 1b                	ja     c010527f <page_init+0x14a>
c0105264:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105268:	72 09                	jb     c0105273 <page_init+0x13e>
c010526a:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0105271:	77 0c                	ja     c010527f <page_init+0x14a>
                maxpa = end;
c0105273:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105276:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0105279:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010527c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c010527f:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0105283:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105286:	8b 00                	mov    (%eax),%eax
c0105288:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010528b:	0f 8f dd fe ff ff    	jg     c010516e <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0105291:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105295:	72 1d                	jb     c01052b4 <page_init+0x17f>
c0105297:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010529b:	77 09                	ja     c01052a6 <page_init+0x171>
c010529d:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c01052a4:	76 0e                	jbe    c01052b4 <page_init+0x17f>
        maxpa = KMEMSIZE;
c01052a6:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01052ad:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c01052b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01052b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01052ba:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01052be:	c1 ea 0c             	shr    $0xc,%edx
c01052c1:	a3 80 ed 1a c0       	mov    %eax,0xc01aed80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01052c6:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c01052cd:	b8 78 0f 1b c0       	mov    $0xc01b0f78,%eax
c01052d2:	8d 50 ff             	lea    -0x1(%eax),%edx
c01052d5:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01052d8:	01 d0                	add    %edx,%eax
c01052da:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01052dd:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01052e0:	ba 00 00 00 00       	mov    $0x0,%edx
c01052e5:	f7 75 ac             	divl   -0x54(%ebp)
c01052e8:	89 d0                	mov    %edx,%eax
c01052ea:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01052ed:	29 c2                	sub    %eax,%edx
c01052ef:	89 d0                	mov    %edx,%eax
c01052f1:	a3 90 0e 1b c0       	mov    %eax,0xc01b0e90

    for (i = 0; i < npage; i ++) {
c01052f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01052fd:	eb 27                	jmp    c0105326 <page_init+0x1f1>
        SetPageReserved(pages + i);
c01052ff:	a1 90 0e 1b c0       	mov    0xc01b0e90,%eax
c0105304:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105307:	c1 e2 05             	shl    $0x5,%edx
c010530a:	01 d0                	add    %edx,%eax
c010530c:	83 c0 04             	add    $0x4,%eax
c010530f:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0105316:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105319:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010531c:	8b 55 90             	mov    -0x70(%ebp),%edx
c010531f:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0105322:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0105326:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105329:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c010532e:	39 c2                	cmp    %eax,%edx
c0105330:	72 cd                	jb     c01052ff <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0105332:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c0105337:	c1 e0 05             	shl    $0x5,%eax
c010533a:	89 c2                	mov    %eax,%edx
c010533c:	a1 90 0e 1b c0       	mov    0xc01b0e90,%eax
c0105341:	01 d0                	add    %edx,%eax
c0105343:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0105346:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c010534d:	77 23                	ja     c0105372 <page_init+0x23d>
c010534f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105352:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105356:	c7 44 24 08 44 d2 10 	movl   $0xc010d244,0x8(%esp)
c010535d:	c0 
c010535e:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0105365:	00 
c0105366:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010536d:	e8 68 ba ff ff       	call   c0100dda <__panic>
c0105372:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105375:	05 00 00 00 40       	add    $0x40000000,%eax
c010537a:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010537d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105384:	e9 74 01 00 00       	jmp    c01054fd <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0105389:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010538c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010538f:	89 d0                	mov    %edx,%eax
c0105391:	c1 e0 02             	shl    $0x2,%eax
c0105394:	01 d0                	add    %edx,%eax
c0105396:	c1 e0 02             	shl    $0x2,%eax
c0105399:	01 c8                	add    %ecx,%eax
c010539b:	8b 50 08             	mov    0x8(%eax),%edx
c010539e:	8b 40 04             	mov    0x4(%eax),%eax
c01053a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01053a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01053a7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01053aa:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053ad:	89 d0                	mov    %edx,%eax
c01053af:	c1 e0 02             	shl    $0x2,%eax
c01053b2:	01 d0                	add    %edx,%eax
c01053b4:	c1 e0 02             	shl    $0x2,%eax
c01053b7:	01 c8                	add    %ecx,%eax
c01053b9:	8b 48 0c             	mov    0xc(%eax),%ecx
c01053bc:	8b 58 10             	mov    0x10(%eax),%ebx
c01053bf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01053c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01053c5:	01 c8                	add    %ecx,%eax
c01053c7:	11 da                	adc    %ebx,%edx
c01053c9:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01053cc:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01053cf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01053d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053d5:	89 d0                	mov    %edx,%eax
c01053d7:	c1 e0 02             	shl    $0x2,%eax
c01053da:	01 d0                	add    %edx,%eax
c01053dc:	c1 e0 02             	shl    $0x2,%eax
c01053df:	01 c8                	add    %ecx,%eax
c01053e1:	83 c0 14             	add    $0x14,%eax
c01053e4:	8b 00                	mov    (%eax),%eax
c01053e6:	83 f8 01             	cmp    $0x1,%eax
c01053e9:	0f 85 0a 01 00 00    	jne    c01054f9 <page_init+0x3c4>
            if (begin < freemem) {
c01053ef:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01053f2:	ba 00 00 00 00       	mov    $0x0,%edx
c01053f7:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01053fa:	72 17                	jb     c0105413 <page_init+0x2de>
c01053fc:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01053ff:	77 05                	ja     c0105406 <page_init+0x2d1>
c0105401:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105404:	76 0d                	jbe    c0105413 <page_init+0x2de>
                begin = freemem;
c0105406:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0105409:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010540c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0105413:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0105417:	72 1d                	jb     c0105436 <page_init+0x301>
c0105419:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010541d:	77 09                	ja     c0105428 <page_init+0x2f3>
c010541f:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0105426:	76 0e                	jbe    c0105436 <page_init+0x301>
                end = KMEMSIZE;
c0105428:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c010542f:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0105436:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105439:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010543c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010543f:	0f 87 b4 00 00 00    	ja     c01054f9 <page_init+0x3c4>
c0105445:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0105448:	72 09                	jb     c0105453 <page_init+0x31e>
c010544a:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010544d:	0f 83 a6 00 00 00    	jae    c01054f9 <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c0105453:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c010545a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010545d:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105460:	01 d0                	add    %edx,%eax
c0105462:	83 e8 01             	sub    $0x1,%eax
c0105465:	89 45 98             	mov    %eax,-0x68(%ebp)
c0105468:	8b 45 98             	mov    -0x68(%ebp),%eax
c010546b:	ba 00 00 00 00       	mov    $0x0,%edx
c0105470:	f7 75 9c             	divl   -0x64(%ebp)
c0105473:	89 d0                	mov    %edx,%eax
c0105475:	8b 55 98             	mov    -0x68(%ebp),%edx
c0105478:	29 c2                	sub    %eax,%edx
c010547a:	89 d0                	mov    %edx,%eax
c010547c:	ba 00 00 00 00       	mov    $0x0,%edx
c0105481:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105484:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0105487:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010548a:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010548d:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0105490:	ba 00 00 00 00       	mov    $0x0,%edx
c0105495:	89 c7                	mov    %eax,%edi
c0105497:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c010549d:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01054a0:	89 d0                	mov    %edx,%eax
c01054a2:	83 e0 00             	and    $0x0,%eax
c01054a5:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01054a8:	8b 45 80             	mov    -0x80(%ebp),%eax
c01054ab:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01054ae:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01054b1:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01054b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01054b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01054ba:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01054bd:	77 3a                	ja     c01054f9 <page_init+0x3c4>
c01054bf:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01054c2:	72 05                	jb     c01054c9 <page_init+0x394>
c01054c4:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01054c7:	73 30                	jae    c01054f9 <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01054c9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01054cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c01054cf:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01054d2:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01054d5:	29 c8                	sub    %ecx,%eax
c01054d7:	19 da                	sbb    %ebx,%edx
c01054d9:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01054dd:	c1 ea 0c             	shr    $0xc,%edx
c01054e0:	89 c3                	mov    %eax,%ebx
c01054e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01054e5:	89 04 24             	mov    %eax,(%esp)
c01054e8:	e8 8c f8 ff ff       	call   c0104d79 <pa2page>
c01054ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01054f1:	89 04 24             	mov    %eax,(%esp)
c01054f4:	e8 55 fb ff ff       	call   c010504e <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01054f9:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01054fd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105500:	8b 00                	mov    (%eax),%eax
c0105502:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0105505:	0f 8f 7e fe ff ff    	jg     c0105389 <page_init+0x254>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c010550b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0105511:	5b                   	pop    %ebx
c0105512:	5e                   	pop    %esi
c0105513:	5f                   	pop    %edi
c0105514:	5d                   	pop    %ebp
c0105515:	c3                   	ret    

c0105516 <enable_paging>:

static void
enable_paging(void) {
c0105516:	55                   	push   %ebp
c0105517:	89 e5                	mov    %esp,%ebp
c0105519:	83 ec 10             	sub    $0x10,%esp
    lcr3(boot_cr3);
c010551c:	a1 8c 0e 1b c0       	mov    0xc01b0e8c,%eax
c0105521:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0105524:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105527:	0f 22 d8             	mov    %eax,%cr3
}

static inline uintptr_t
rcr0(void) {
    uintptr_t cr0;
    asm volatile ("mov %%cr0, %0" : "=r" (cr0) :: "memory");
c010552a:	0f 20 c0             	mov    %cr0,%eax
c010552d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr0;
c0105530:	8b 45 f4             	mov    -0xc(%ebp),%eax

    // turn on paging
    uint32_t cr0 = rcr0();
c0105533:	89 45 fc             	mov    %eax,-0x4(%ebp)
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
c0105536:	81 4d fc 2f 00 05 80 	orl    $0x8005002f,-0x4(%ebp)
    cr0 &= ~(CR0_TS | CR0_EM);
c010553d:	83 65 fc f3          	andl   $0xfffffff3,-0x4(%ebp)
c0105541:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105544:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile ("pushl %0; popfl" :: "r" (eflags));
}

static inline void
lcr0(uintptr_t cr0) {
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
c0105547:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010554a:	0f 22 c0             	mov    %eax,%cr0
    lcr0(cr0);
}
c010554d:	c9                   	leave  
c010554e:	c3                   	ret    

c010554f <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010554f:	55                   	push   %ebp
c0105550:	89 e5                	mov    %esp,%ebp
c0105552:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0105555:	8b 45 14             	mov    0x14(%ebp),%eax
c0105558:	8b 55 0c             	mov    0xc(%ebp),%edx
c010555b:	31 d0                	xor    %edx,%eax
c010555d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105562:	85 c0                	test   %eax,%eax
c0105564:	74 24                	je     c010558a <boot_map_segment+0x3b>
c0105566:	c7 44 24 0c 76 d2 10 	movl   $0xc010d276,0xc(%esp)
c010556d:	c0 
c010556e:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0105575:	c0 
c0105576:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c010557d:	00 
c010557e:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0105585:	e8 50 b8 ff ff       	call   c0100dda <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010558a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0105591:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105594:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105599:	89 c2                	mov    %eax,%edx
c010559b:	8b 45 10             	mov    0x10(%ebp),%eax
c010559e:	01 c2                	add    %eax,%edx
c01055a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01055a3:	01 d0                	add    %edx,%eax
c01055a5:	83 e8 01             	sub    $0x1,%eax
c01055a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01055ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055ae:	ba 00 00 00 00       	mov    $0x0,%edx
c01055b3:	f7 75 f0             	divl   -0x10(%ebp)
c01055b6:	89 d0                	mov    %edx,%eax
c01055b8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01055bb:	29 c2                	sub    %eax,%edx
c01055bd:	89 d0                	mov    %edx,%eax
c01055bf:	c1 e8 0c             	shr    $0xc,%eax
c01055c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01055c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01055cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01055ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01055d3:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01055d6:	8b 45 14             	mov    0x14(%ebp),%eax
c01055d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01055dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01055e4:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01055e7:	eb 6b                	jmp    c0105654 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01055e9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01055f0:	00 
c01055f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01055f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01055fb:	89 04 24             	mov    %eax,(%esp)
c01055fe:	e8 d1 01 00 00       	call   c01057d4 <get_pte>
c0105603:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0105606:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010560a:	75 24                	jne    c0105630 <boot_map_segment+0xe1>
c010560c:	c7 44 24 0c a2 d2 10 	movl   $0xc010d2a2,0xc(%esp)
c0105613:	c0 
c0105614:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c010561b:	c0 
c010561c:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0105623:	00 
c0105624:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010562b:	e8 aa b7 ff ff       	call   c0100dda <__panic>
        *ptep = pa | PTE_P | perm;
c0105630:	8b 45 18             	mov    0x18(%ebp),%eax
c0105633:	8b 55 14             	mov    0x14(%ebp),%edx
c0105636:	09 d0                	or     %edx,%eax
c0105638:	83 c8 01             	or     $0x1,%eax
c010563b:	89 c2                	mov    %eax,%edx
c010563d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105640:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0105642:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105646:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010564d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0105654:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105658:	75 8f                	jne    c01055e9 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c010565a:	c9                   	leave  
c010565b:	c3                   	ret    

c010565c <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010565c:	55                   	push   %ebp
c010565d:	89 e5                	mov    %esp,%ebp
c010565f:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0105662:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105669:	e8 ff f9 ff ff       	call   c010506d <alloc_pages>
c010566e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0105671:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105675:	75 1c                	jne    c0105693 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0105677:	c7 44 24 08 af d2 10 	movl   $0xc010d2af,0x8(%esp)
c010567e:	c0 
c010567f:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0105686:	00 
c0105687:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010568e:	e8 47 b7 ff ff       	call   c0100dda <__panic>
    }
    return page2kva(p);
c0105693:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105696:	89 04 24             	mov    %eax,(%esp)
c0105699:	e8 20 f7 ff ff       	call   c0104dbe <page2kva>
}
c010569e:	c9                   	leave  
c010569f:	c3                   	ret    

c01056a0 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01056a0:	55                   	push   %ebp
c01056a1:	89 e5                	mov    %esp,%ebp
c01056a3:	83 ec 38             	sub    $0x38,%esp
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01056a6:	e8 70 f9 ff ff       	call   c010501b <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01056ab:	e8 85 fa ff ff       	call   c0105135 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01056b0:	e8 77 09 00 00       	call   c010602c <check_alloc_page>

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    boot_pgdir = boot_alloc_page();
c01056b5:	e8 a2 ff ff ff       	call   c010565c <boot_alloc_page>
c01056ba:	a3 84 ed 1a c0       	mov    %eax,0xc01aed84
    memset(boot_pgdir, 0, PGSIZE);
c01056bf:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c01056c4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01056cb:	00 
c01056cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01056d3:	00 
c01056d4:	89 04 24             	mov    %eax,(%esp)
c01056d7:	e8 42 6b 00 00       	call   c010c21e <memset>
    boot_cr3 = PADDR(boot_pgdir);
c01056dc:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c01056e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01056e4:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01056eb:	77 23                	ja     c0105710 <pmm_init+0x70>
c01056ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01056f4:	c7 44 24 08 44 d2 10 	movl   $0xc010d244,0x8(%esp)
c01056fb:	c0 
c01056fc:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c0105703:	00 
c0105704:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010570b:	e8 ca b6 ff ff       	call   c0100dda <__panic>
c0105710:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105713:	05 00 00 00 40       	add    $0x40000000,%eax
c0105718:	a3 8c 0e 1b c0       	mov    %eax,0xc01b0e8c

    check_pgdir();
c010571d:	e8 28 09 00 00       	call   c010604a <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0105722:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0105727:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c010572d:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0105732:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105735:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010573c:	77 23                	ja     c0105761 <pmm_init+0xc1>
c010573e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105741:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105745:	c7 44 24 08 44 d2 10 	movl   $0xc010d244,0x8(%esp)
c010574c:	c0 
c010574d:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
c0105754:	00 
c0105755:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010575c:	e8 79 b6 ff ff       	call   c0100dda <__panic>
c0105761:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105764:	05 00 00 00 40       	add    $0x40000000,%eax
c0105769:	83 c8 03             	or     $0x3,%eax
c010576c:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    //linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    //But shouldn't use this map until enable_paging() & gdt_init() finished.
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c010576e:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0105773:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010577a:	00 
c010577b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105782:	00 
c0105783:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c010578a:	38 
c010578b:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0105792:	c0 
c0105793:	89 04 24             	mov    %eax,(%esp)
c0105796:	e8 b4 fd ff ff       	call   c010554f <boot_map_segment>

    //temporary map: 
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M     
    boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
c010579b:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c01057a0:	8b 15 84 ed 1a c0    	mov    0xc01aed84,%edx
c01057a6:	8b 92 00 0c 00 00    	mov    0xc00(%edx),%edx
c01057ac:	89 10                	mov    %edx,(%eax)

    enable_paging();
c01057ae:	e8 63 fd ff ff       	call   c0105516 <enable_paging>

    //reload gdt(third time,the last time) to map all physical memory
    //virtual_addr 0~4G=liear_addr 0~4G
    //then set kernel stack(ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01057b3:	e8 74 f7 ff ff       	call   c0104f2c <gdt_init>

    //disable the map of virtual_addr 0~4M
    boot_pgdir[0] = 0;
c01057b8:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c01057bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01057c3:	e8 1d 0f 00 00       	call   c01066e5 <check_boot_pgdir>

    print_pgdir();
c01057c8:	e8 a5 13 00 00       	call   c0106b72 <print_pgdir>
    
    kmalloc_init();
c01057cd:	e8 e6 f2 ff ff       	call   c0104ab8 <kmalloc_init>

}
c01057d2:	c9                   	leave  
c01057d3:	c3                   	ret    

c01057d4 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01057d4:	55                   	push   %ebp
c01057d5:	89 e5                	mov    %esp,%ebp
c01057d7:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c01057da:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057dd:	c1 e8 16             	shr    $0x16,%eax
c01057e0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01057e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01057ea:	01 d0                	add    %edx,%eax
c01057ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (!(*pdep & PTE_P)) {
c01057ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057f2:	8b 00                	mov    (%eax),%eax
c01057f4:	83 e0 01             	and    $0x1,%eax
c01057f7:	85 c0                	test   %eax,%eax
c01057f9:	0f 85 c4 00 00 00    	jne    c01058c3 <get_pte+0xef>
        if (!create)
c01057ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105803:	75 0a                	jne    c010580f <get_pte+0x3b>
            return NULL;
c0105805:	b8 00 00 00 00       	mov    $0x0,%eax
c010580a:	e9 10 01 00 00       	jmp    c010591f <get_pte+0x14b>
        struct Page* page;
        if (create && (page = alloc_pages(1)) == NULL)
c010580f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105813:	74 1f                	je     c0105834 <get_pte+0x60>
c0105815:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010581c:	e8 4c f8 ff ff       	call   c010506d <alloc_pages>
c0105821:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105824:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105828:	75 0a                	jne    c0105834 <get_pte+0x60>
            return NULL;
c010582a:	b8 00 00 00 00       	mov    $0x0,%eax
c010582f:	e9 eb 00 00 00       	jmp    c010591f <get_pte+0x14b>
        set_page_ref(page, 1);
c0105834:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010583b:	00 
c010583c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010583f:	89 04 24             	mov    %eax,(%esp)
c0105842:	e8 2b f6 ff ff       	call   c0104e72 <set_page_ref>
        uintptr_t phia = page2pa(page);
c0105847:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010584a:	89 04 24             	mov    %eax,(%esp)
c010584d:	e8 11 f5 ff ff       	call   c0104d63 <page2pa>
c0105852:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(phia), 0, PGSIZE);
c0105855:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105858:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010585b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010585e:	c1 e8 0c             	shr    $0xc,%eax
c0105861:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105864:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c0105869:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010586c:	72 23                	jb     c0105891 <get_pte+0xbd>
c010586e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105871:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105875:	c7 44 24 08 a0 d1 10 	movl   $0xc010d1a0,0x8(%esp)
c010587c:	c0 
c010587d:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
c0105884:	00 
c0105885:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010588c:	e8 49 b5 ff ff       	call   c0100dda <__panic>
c0105891:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105894:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105899:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01058a0:	00 
c01058a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01058a8:	00 
c01058a9:	89 04 24             	mov    %eax,(%esp)
c01058ac:	e8 6d 69 00 00       	call   c010c21e <memset>
        *pdep = PDE_ADDR(phia) | PTE_U | PTE_W | PTE_P;
c01058b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01058b9:	83 c8 07             	or     $0x7,%eax
c01058bc:	89 c2                	mov    %eax,%edx
c01058be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058c1:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c01058c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058c6:	8b 00                	mov    (%eax),%eax
c01058c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01058cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01058d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058d3:	c1 e8 0c             	shr    $0xc,%eax
c01058d6:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01058d9:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c01058de:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01058e1:	72 23                	jb     c0105906 <get_pte+0x132>
c01058e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01058ea:	c7 44 24 08 a0 d1 10 	movl   $0xc010d1a0,0x8(%esp)
c01058f1:	c0 
c01058f2:	c7 44 24 04 9b 01 00 	movl   $0x19b,0x4(%esp)
c01058f9:	00 
c01058fa:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0105901:	e8 d4 b4 ff ff       	call   c0100dda <__panic>
c0105906:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105909:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010590e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105911:	c1 ea 0c             	shr    $0xc,%edx
c0105914:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c010591a:	c1 e2 02             	shl    $0x2,%edx
c010591d:	01 d0                	add    %edx,%eax
}
c010591f:	c9                   	leave  
c0105920:	c3                   	ret    

c0105921 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0105921:	55                   	push   %ebp
c0105922:	89 e5                	mov    %esp,%ebp
c0105924:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105927:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010592e:	00 
c010592f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105932:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105936:	8b 45 08             	mov    0x8(%ebp),%eax
c0105939:	89 04 24             	mov    %eax,(%esp)
c010593c:	e8 93 fe ff ff       	call   c01057d4 <get_pte>
c0105941:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0105944:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105948:	74 08                	je     c0105952 <get_page+0x31>
        *ptep_store = ptep;
c010594a:	8b 45 10             	mov    0x10(%ebp),%eax
c010594d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105950:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0105952:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105956:	74 1b                	je     c0105973 <get_page+0x52>
c0105958:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010595b:	8b 00                	mov    (%eax),%eax
c010595d:	83 e0 01             	and    $0x1,%eax
c0105960:	85 c0                	test   %eax,%eax
c0105962:	74 0f                	je     c0105973 <get_page+0x52>
        return pte2page(*ptep);
c0105964:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105967:	8b 00                	mov    (%eax),%eax
c0105969:	89 04 24             	mov    %eax,(%esp)
c010596c:	e8 a1 f4 ff ff       	call   c0104e12 <pte2page>
c0105971:	eb 05                	jmp    c0105978 <get_page+0x57>
    }
    return NULL;
c0105973:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105978:	c9                   	leave  
c0105979:	c3                   	ret    

c010597a <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010597a:	55                   	push   %ebp
c010597b:	89 e5                	mov    %esp,%ebp
c010597d:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0105980:	8b 45 10             	mov    0x10(%ebp),%eax
c0105983:	8b 00                	mov    (%eax),%eax
c0105985:	83 e0 01             	and    $0x1,%eax
c0105988:	85 c0                	test   %eax,%eax
c010598a:	74 52                	je     c01059de <page_remove_pte+0x64>
        struct Page *page = pte2page(*ptep);
c010598c:	8b 45 10             	mov    0x10(%ebp),%eax
c010598f:	8b 00                	mov    (%eax),%eax
c0105991:	89 04 24             	mov    %eax,(%esp)
c0105994:	e8 79 f4 ff ff       	call   c0104e12 <pte2page>
c0105999:	89 45 f4             	mov    %eax,-0xc(%ebp)
        page_ref_dec(page);
c010599c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010599f:	89 04 24             	mov    %eax,(%esp)
c01059a2:	e8 ef f4 ff ff       	call   c0104e96 <page_ref_dec>
        if(page->ref == 0) {
c01059a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059aa:	8b 00                	mov    (%eax),%eax
c01059ac:	85 c0                	test   %eax,%eax
c01059ae:	75 13                	jne    c01059c3 <page_remove_pte+0x49>
            free_page(page);
c01059b0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01059b7:	00 
c01059b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059bb:	89 04 24             	mov    %eax,(%esp)
c01059be:	e8 15 f7 ff ff       	call   c01050d8 <free_pages>
        }
        *ptep = 0;
c01059c3:	8b 45 10             	mov    0x10(%ebp),%eax
c01059c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c01059cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01059d6:	89 04 24             	mov    %eax,(%esp)
c01059d9:	e8 1d 05 00 00       	call   c0105efb <tlb_invalidate>
    }
}
c01059de:	c9                   	leave  
c01059df:	c3                   	ret    

c01059e0 <unmap_range>:

void
unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c01059e0:	55                   	push   %ebp
c01059e1:	89 e5                	mov    %esp,%ebp
c01059e3:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c01059e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059e9:	25 ff 0f 00 00       	and    $0xfff,%eax
c01059ee:	85 c0                	test   %eax,%eax
c01059f0:	75 0c                	jne    c01059fe <unmap_range+0x1e>
c01059f2:	8b 45 10             	mov    0x10(%ebp),%eax
c01059f5:	25 ff 0f 00 00       	and    $0xfff,%eax
c01059fa:	85 c0                	test   %eax,%eax
c01059fc:	74 24                	je     c0105a22 <unmap_range+0x42>
c01059fe:	c7 44 24 0c c8 d2 10 	movl   $0xc010d2c8,0xc(%esp)
c0105a05:	c0 
c0105a06:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0105a0d:	c0 
c0105a0e:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
c0105a15:	00 
c0105a16:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0105a1d:	e8 b8 b3 ff ff       	call   c0100dda <__panic>
    assert(USER_ACCESS(start, end));
c0105a22:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105a29:	76 11                	jbe    c0105a3c <unmap_range+0x5c>
c0105a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a2e:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105a31:	73 09                	jae    c0105a3c <unmap_range+0x5c>
c0105a33:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105a3a:	76 24                	jbe    c0105a60 <unmap_range+0x80>
c0105a3c:	c7 44 24 0c f1 d2 10 	movl   $0xc010d2f1,0xc(%esp)
c0105a43:	c0 
c0105a44:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0105a4b:	c0 
c0105a4c:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
c0105a53:	00 
c0105a54:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0105a5b:	e8 7a b3 ff ff       	call   c0100dda <__panic>

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
c0105a60:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105a67:	00 
c0105a68:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a72:	89 04 24             	mov    %eax,(%esp)
c0105a75:	e8 5a fd ff ff       	call   c01057d4 <get_pte>
c0105a7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105a7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105a81:	75 18                	jne    c0105a9b <unmap_range+0xbb>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105a83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a86:	05 00 00 40 00       	add    $0x400000,%eax
c0105a8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a91:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105a96:	89 45 0c             	mov    %eax,0xc(%ebp)
            continue ;
c0105a99:	eb 29                	jmp    c0105ac4 <unmap_range+0xe4>
        }
        if (*ptep != 0) {
c0105a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a9e:	8b 00                	mov    (%eax),%eax
c0105aa0:	85 c0                	test   %eax,%eax
c0105aa2:	74 19                	je     c0105abd <unmap_range+0xdd>
            page_remove_pte(pgdir, start, ptep);
c0105aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105aa7:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105aab:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aae:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ab2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ab5:	89 04 24             	mov    %eax,(%esp)
c0105ab8:	e8 bd fe ff ff       	call   c010597a <page_remove_pte>
        }
        start += PGSIZE;
c0105abd:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105ac4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105ac8:	74 08                	je     c0105ad2 <unmap_range+0xf2>
c0105aca:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105acd:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105ad0:	72 8e                	jb     c0105a60 <unmap_range+0x80>
}
c0105ad2:	c9                   	leave  
c0105ad3:	c3                   	ret    

c0105ad4 <exit_range>:

void
exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0105ad4:	55                   	push   %ebp
c0105ad5:	89 e5                	mov    %esp,%ebp
c0105ad7:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105ada:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105add:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105ae2:	85 c0                	test   %eax,%eax
c0105ae4:	75 0c                	jne    c0105af2 <exit_range+0x1e>
c0105ae6:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ae9:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105aee:	85 c0                	test   %eax,%eax
c0105af0:	74 24                	je     c0105b16 <exit_range+0x42>
c0105af2:	c7 44 24 0c c8 d2 10 	movl   $0xc010d2c8,0xc(%esp)
c0105af9:	c0 
c0105afa:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0105b01:	c0 
c0105b02:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0105b09:	00 
c0105b0a:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0105b11:	e8 c4 b2 ff ff       	call   c0100dda <__panic>
    assert(USER_ACCESS(start, end));
c0105b16:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105b1d:	76 11                	jbe    c0105b30 <exit_range+0x5c>
c0105b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b22:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105b25:	73 09                	jae    c0105b30 <exit_range+0x5c>
c0105b27:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105b2e:	76 24                	jbe    c0105b54 <exit_range+0x80>
c0105b30:	c7 44 24 0c f1 d2 10 	movl   $0xc010d2f1,0xc(%esp)
c0105b37:	c0 
c0105b38:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0105b3f:	c0 
c0105b40:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c0105b47:	00 
c0105b48:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0105b4f:	e8 86 b2 ff ff       	call   c0100dda <__panic>

    start = ROUNDDOWN(start, PTSIZE);
c0105b54:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b57:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b5d:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105b62:	89 45 0c             	mov    %eax,0xc(%ebp)
    do {
        int pde_idx = PDX(start);
c0105b65:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b68:	c1 e8 16             	shr    $0x16,%eax
c0105b6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (pgdir[pde_idx] & PTE_P) {
c0105b6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b71:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105b78:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b7b:	01 d0                	add    %edx,%eax
c0105b7d:	8b 00                	mov    (%eax),%eax
c0105b7f:	83 e0 01             	and    $0x1,%eax
c0105b82:	85 c0                	test   %eax,%eax
c0105b84:	74 3e                	je     c0105bc4 <exit_range+0xf0>
            free_page(pde2page(pgdir[pde_idx]));
c0105b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b89:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105b90:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b93:	01 d0                	add    %edx,%eax
c0105b95:	8b 00                	mov    (%eax),%eax
c0105b97:	89 04 24             	mov    %eax,(%esp)
c0105b9a:	e8 b1 f2 ff ff       	call   c0104e50 <pde2page>
c0105b9f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105ba6:	00 
c0105ba7:	89 04 24             	mov    %eax,(%esp)
c0105baa:	e8 29 f5 ff ff       	call   c01050d8 <free_pages>
            pgdir[pde_idx] = 0;
c0105baf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bb2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105bb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bbc:	01 d0                	add    %edx,%eax
c0105bbe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        start += PTSIZE;
c0105bc4:	81 45 0c 00 00 40 00 	addl   $0x400000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105bcb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105bcf:	74 08                	je     c0105bd9 <exit_range+0x105>
c0105bd1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bd4:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105bd7:	72 8c                	jb     c0105b65 <exit_range+0x91>
}
c0105bd9:	c9                   	leave  
c0105bda:	c3                   	ret    

c0105bdb <copy_range>:
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
c0105bdb:	55                   	push   %ebp
c0105bdc:	89 e5                	mov    %esp,%ebp
c0105bde:	83 ec 48             	sub    $0x48,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105be1:	8b 45 10             	mov    0x10(%ebp),%eax
c0105be4:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105be9:	85 c0                	test   %eax,%eax
c0105beb:	75 0c                	jne    c0105bf9 <copy_range+0x1e>
c0105bed:	8b 45 14             	mov    0x14(%ebp),%eax
c0105bf0:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105bf5:	85 c0                	test   %eax,%eax
c0105bf7:	74 24                	je     c0105c1d <copy_range+0x42>
c0105bf9:	c7 44 24 0c c8 d2 10 	movl   $0xc010d2c8,0xc(%esp)
c0105c00:	c0 
c0105c01:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0105c08:	c0 
c0105c09:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0105c10:	00 
c0105c11:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0105c18:	e8 bd b1 ff ff       	call   c0100dda <__panic>
    assert(USER_ACCESS(start, end));
c0105c1d:	81 7d 10 ff ff 1f 00 	cmpl   $0x1fffff,0x10(%ebp)
c0105c24:	76 11                	jbe    c0105c37 <copy_range+0x5c>
c0105c26:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c29:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105c2c:	73 09                	jae    c0105c37 <copy_range+0x5c>
c0105c2e:	81 7d 14 00 00 00 b0 	cmpl   $0xb0000000,0x14(%ebp)
c0105c35:	76 24                	jbe    c0105c5b <copy_range+0x80>
c0105c37:	c7 44 24 0c f1 d2 10 	movl   $0xc010d2f1,0xc(%esp)
c0105c3e:	c0 
c0105c3f:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0105c46:	c0 
c0105c47:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0105c4e:	00 
c0105c4f:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0105c56:	e8 7f b1 ff ff       	call   c0100dda <__panic>
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
c0105c5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105c62:	00 
c0105c63:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c6d:	89 04 24             	mov    %eax,(%esp)
c0105c70:	e8 5f fb ff ff       	call   c01057d4 <get_pte>
c0105c75:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105c78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105c7c:	75 1b                	jne    c0105c99 <copy_range+0xbe>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105c7e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c81:	05 00 00 40 00       	add    $0x400000,%eax
c0105c86:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c8c:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105c91:	89 45 10             	mov    %eax,0x10(%ebp)
            continue ;
c0105c94:	e9 4c 01 00 00       	jmp    c0105de5 <copy_range+0x20a>
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
c0105c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c9c:	8b 00                	mov    (%eax),%eax
c0105c9e:	83 e0 01             	and    $0x1,%eax
c0105ca1:	85 c0                	test   %eax,%eax
c0105ca3:	0f 84 35 01 00 00    	je     c0105dde <copy_range+0x203>
            if ((nptep = get_pte(to, start, 1)) == NULL) {
c0105ca9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105cb0:	00 
c0105cb1:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cbb:	89 04 24             	mov    %eax,(%esp)
c0105cbe:	e8 11 fb ff ff       	call   c01057d4 <get_pte>
c0105cc3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105cc6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105cca:	75 0a                	jne    c0105cd6 <copy_range+0xfb>
                return -E_NO_MEM;
c0105ccc:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105cd1:	e9 26 01 00 00       	jmp    c0105dfc <copy_range+0x221>
            }
        uint32_t perm = (*ptep & PTE_USER);
c0105cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cd9:	8b 00                	mov    (%eax),%eax
c0105cdb:	83 e0 07             	and    $0x7,%eax
c0105cde:	89 45 e8             	mov    %eax,-0x18(%ebp)
        //get page from ptep
        struct Page *page = pte2page(*ptep);
c0105ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ce4:	8b 00                	mov    (%eax),%eax
c0105ce6:	89 04 24             	mov    %eax,(%esp)
c0105ce9:	e8 24 f1 ff ff       	call   c0104e12 <pte2page>
c0105cee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        // alloc a page for process B
        struct Page *npage=alloc_page();
c0105cf1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105cf8:	e8 70 f3 ff ff       	call   c010506d <alloc_pages>
c0105cfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(page!=NULL);
c0105d00:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105d04:	75 24                	jne    c0105d2a <copy_range+0x14f>
c0105d06:	c7 44 24 0c 09 d3 10 	movl   $0xc010d309,0xc(%esp)
c0105d0d:	c0 
c0105d0e:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0105d15:	c0 
c0105d16:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0105d1d:	00 
c0105d1e:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0105d25:	e8 b0 b0 ff ff       	call   c0100dda <__panic>
        assert(npage!=NULL);
c0105d2a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105d2e:	75 24                	jne    c0105d54 <copy_range+0x179>
c0105d30:	c7 44 24 0c 14 d3 10 	movl   $0xc010d314,0xc(%esp)
c0105d37:	c0 
c0105d38:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0105d3f:	c0 
c0105d40:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0105d47:	00 
c0105d48:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0105d4f:	e8 86 b0 ff ff       	call   c0100dda <__panic>
        int ret=0;
c0105d54:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
         * (1) find src_kvaddr: the kernel virtual address of page
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
            void * src_kvaddr = page2kva(page);
c0105d5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d5e:	89 04 24             	mov    %eax,(%esp)
c0105d61:	e8 58 f0 ff ff       	call   c0104dbe <page2kva>
c0105d66:	89 45 d8             	mov    %eax,-0x28(%ebp)
            void * dst_kvaddr = page2kva(npage);
c0105d69:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d6c:	89 04 24             	mov    %eax,(%esp)
c0105d6f:	e8 4a f0 ff ff       	call   c0104dbe <page2kva>
c0105d74:	89 45 d4             	mov    %eax,-0x2c(%ebp)
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
c0105d77:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105d7e:	00 
c0105d7f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105d82:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105d89:	89 04 24             	mov    %eax,(%esp)
c0105d8c:	e8 6f 65 00 00       	call   c010c300 <memcpy>
        ret = page_insert(to, npage, start, perm);
c0105d91:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d94:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105d98:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d9b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105d9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105da2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105da6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105da9:	89 04 24             	mov    %eax,(%esp)
c0105dac:	e8 91 00 00 00       	call   c0105e42 <page_insert>
c0105db1:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(ret == 0);
c0105db4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105db8:	74 24                	je     c0105dde <copy_range+0x203>
c0105dba:	c7 44 24 0c 20 d3 10 	movl   $0xc010d320,0xc(%esp)
c0105dc1:	c0 
c0105dc2:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0105dc9:	c0 
c0105dca:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0105dd1:	00 
c0105dd2:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0105dd9:	e8 fc af ff ff       	call   c0100dda <__panic>
        }
        start += PGSIZE;
c0105dde:	81 45 10 00 10 00 00 	addl   $0x1000,0x10(%ebp)
    } while (start != 0 && start < end);
c0105de5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105de9:	74 0c                	je     c0105df7 <copy_range+0x21c>
c0105deb:	8b 45 10             	mov    0x10(%ebp),%eax
c0105dee:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105df1:	0f 82 64 fe ff ff    	jb     c0105c5b <copy_range+0x80>
    return 0;
c0105df7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105dfc:	c9                   	leave  
c0105dfd:	c3                   	ret    

c0105dfe <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105dfe:	55                   	push   %ebp
c0105dff:	89 e5                	mov    %esp,%ebp
c0105e01:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105e04:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105e0b:	00 
c0105e0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e13:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e16:	89 04 24             	mov    %eax,(%esp)
c0105e19:	e8 b6 f9 ff ff       	call   c01057d4 <get_pte>
c0105e1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0105e21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105e25:	74 19                	je     c0105e40 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0105e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e2a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e35:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e38:	89 04 24             	mov    %eax,(%esp)
c0105e3b:	e8 3a fb ff ff       	call   c010597a <page_remove_pte>
    }
}
c0105e40:	c9                   	leave  
c0105e41:	c3                   	ret    

c0105e42 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0105e42:	55                   	push   %ebp
c0105e43:	89 e5                	mov    %esp,%ebp
c0105e45:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0105e48:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105e4f:	00 
c0105e50:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e57:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e5a:	89 04 24             	mov    %eax,(%esp)
c0105e5d:	e8 72 f9 ff ff       	call   c01057d4 <get_pte>
c0105e62:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0105e65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105e69:	75 0a                	jne    c0105e75 <page_insert+0x33>
        return -E_NO_MEM;
c0105e6b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105e70:	e9 84 00 00 00       	jmp    c0105ef9 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0105e75:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e78:	89 04 24             	mov    %eax,(%esp)
c0105e7b:	e8 ff ef ff ff       	call   c0104e7f <page_ref_inc>
    if (*ptep & PTE_P) {
c0105e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e83:	8b 00                	mov    (%eax),%eax
c0105e85:	83 e0 01             	and    $0x1,%eax
c0105e88:	85 c0                	test   %eax,%eax
c0105e8a:	74 3e                	je     c0105eca <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0105e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e8f:	8b 00                	mov    (%eax),%eax
c0105e91:	89 04 24             	mov    %eax,(%esp)
c0105e94:	e8 79 ef ff ff       	call   c0104e12 <pte2page>
c0105e99:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0105e9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e9f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105ea2:	75 0d                	jne    c0105eb1 <page_insert+0x6f>
            page_ref_dec(page);
c0105ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ea7:	89 04 24             	mov    %eax,(%esp)
c0105eaa:	e8 e7 ef ff ff       	call   c0104e96 <page_ref_dec>
c0105eaf:	eb 19                	jmp    c0105eca <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0105eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105eb4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105eb8:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ebb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ebf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ec2:	89 04 24             	mov    %eax,(%esp)
c0105ec5:	e8 b0 fa ff ff       	call   c010597a <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105eca:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ecd:	89 04 24             	mov    %eax,(%esp)
c0105ed0:	e8 8e ee ff ff       	call   c0104d63 <page2pa>
c0105ed5:	0b 45 14             	or     0x14(%ebp),%eax
c0105ed8:	83 c8 01             	or     $0x1,%eax
c0105edb:	89 c2                	mov    %eax,%edx
c0105edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ee0:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0105ee2:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ee5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ee9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eec:	89 04 24             	mov    %eax,(%esp)
c0105eef:	e8 07 00 00 00       	call   c0105efb <tlb_invalidate>
    return 0;
c0105ef4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ef9:	c9                   	leave  
c0105efa:	c3                   	ret    

c0105efb <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0105efb:	55                   	push   %ebp
c0105efc:	89 e5                	mov    %esp,%ebp
c0105efe:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0105f01:	0f 20 d8             	mov    %cr3,%eax
c0105f04:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0105f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0105f0a:	89 c2                	mov    %eax,%edx
c0105f0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105f12:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105f19:	77 23                	ja     c0105f3e <tlb_invalidate+0x43>
c0105f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105f22:	c7 44 24 08 44 d2 10 	movl   $0xc010d244,0x8(%esp)
c0105f29:	c0 
c0105f2a:	c7 44 24 04 58 02 00 	movl   $0x258,0x4(%esp)
c0105f31:	00 
c0105f32:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0105f39:	e8 9c ae ff ff       	call   c0100dda <__panic>
c0105f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f41:	05 00 00 00 40       	add    $0x40000000,%eax
c0105f46:	39 c2                	cmp    %eax,%edx
c0105f48:	75 0c                	jne    c0105f56 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0105f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0105f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f53:	0f 01 38             	invlpg (%eax)
    }
}
c0105f56:	c9                   	leave  
c0105f57:	c3                   	ret    

c0105f58 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0105f58:	55                   	push   %ebp
c0105f59:	89 e5                	mov    %esp,%ebp
c0105f5b:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0105f5e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105f65:	e8 03 f1 ff ff       	call   c010506d <alloc_pages>
c0105f6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0105f6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105f71:	0f 84 b0 00 00 00    	je     c0106027 <pgdir_alloc_page+0xcf>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0105f77:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f81:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f88:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f8f:	89 04 24             	mov    %eax,(%esp)
c0105f92:	e8 ab fe ff ff       	call   c0105e42 <page_insert>
c0105f97:	85 c0                	test   %eax,%eax
c0105f99:	74 1a                	je     c0105fb5 <pgdir_alloc_page+0x5d>
            free_page(page);
c0105f9b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105fa2:	00 
c0105fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fa6:	89 04 24             	mov    %eax,(%esp)
c0105fa9:	e8 2a f1 ff ff       	call   c01050d8 <free_pages>
            return NULL;
c0105fae:	b8 00 00 00 00       	mov    $0x0,%eax
c0105fb3:	eb 75                	jmp    c010602a <pgdir_alloc_page+0xd2>
        }
        if (swap_init_ok){
c0105fb5:	a1 0c ee 1a c0       	mov    0xc01aee0c,%eax
c0105fba:	85 c0                	test   %eax,%eax
c0105fbc:	74 69                	je     c0106027 <pgdir_alloc_page+0xcf>
            if(check_mm_struct!=NULL) {
c0105fbe:	a1 6c 0f 1b c0       	mov    0xc01b0f6c,%eax
c0105fc3:	85 c0                	test   %eax,%eax
c0105fc5:	74 60                	je     c0106027 <pgdir_alloc_page+0xcf>
                swap_map_swappable(check_mm_struct, la, page, 0);
c0105fc7:	a1 6c 0f 1b c0       	mov    0xc01b0f6c,%eax
c0105fcc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105fd3:	00 
c0105fd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105fd7:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105fde:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105fe2:	89 04 24             	mov    %eax,(%esp)
c0105fe5:	e8 51 0e 00 00       	call   c0106e3b <swap_map_swappable>
                page->pra_vaddr=la;
c0105fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fed:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105ff0:	89 50 1c             	mov    %edx,0x1c(%eax)
                assert(page_ref(page) == 1);
c0105ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ff6:	89 04 24             	mov    %eax,(%esp)
c0105ff9:	e8 6a ee ff ff       	call   c0104e68 <page_ref>
c0105ffe:	83 f8 01             	cmp    $0x1,%eax
c0106001:	74 24                	je     c0106027 <pgdir_alloc_page+0xcf>
c0106003:	c7 44 24 0c 29 d3 10 	movl   $0xc010d329,0xc(%esp)
c010600a:	c0 
c010600b:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106012:	c0 
c0106013:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
c010601a:	00 
c010601b:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106022:	e8 b3 ad ff ff       	call   c0100dda <__panic>
            }
        }

    }

    return page;
c0106027:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010602a:	c9                   	leave  
c010602b:	c3                   	ret    

c010602c <check_alloc_page>:

static void
check_alloc_page(void) {
c010602c:	55                   	push   %ebp
c010602d:	89 e5                	mov    %esp,%ebp
c010602f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0106032:	a1 88 0e 1b c0       	mov    0xc01b0e88,%eax
c0106037:	8b 40 18             	mov    0x18(%eax),%eax
c010603a:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c010603c:	c7 04 24 40 d3 10 c0 	movl   $0xc010d340,(%esp)
c0106043:	e8 10 a3 ff ff       	call   c0100358 <cprintf>
}
c0106048:	c9                   	leave  
c0106049:	c3                   	ret    

c010604a <check_pgdir>:

static void
check_pgdir(void) {
c010604a:	55                   	push   %ebp
c010604b:	89 e5                	mov    %esp,%ebp
c010604d:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0106050:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c0106055:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010605a:	76 24                	jbe    c0106080 <check_pgdir+0x36>
c010605c:	c7 44 24 0c 5f d3 10 	movl   $0xc010d35f,0xc(%esp)
c0106063:	c0 
c0106064:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c010606b:	c0 
c010606c:	c7 44 24 04 84 02 00 	movl   $0x284,0x4(%esp)
c0106073:	00 
c0106074:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010607b:	e8 5a ad ff ff       	call   c0100dda <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0106080:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0106085:	85 c0                	test   %eax,%eax
c0106087:	74 0e                	je     c0106097 <check_pgdir+0x4d>
c0106089:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c010608e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106093:	85 c0                	test   %eax,%eax
c0106095:	74 24                	je     c01060bb <check_pgdir+0x71>
c0106097:	c7 44 24 0c 7c d3 10 	movl   $0xc010d37c,0xc(%esp)
c010609e:	c0 
c010609f:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01060a6:	c0 
c01060a7:	c7 44 24 04 85 02 00 	movl   $0x285,0x4(%esp)
c01060ae:	00 
c01060af:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01060b6:	e8 1f ad ff ff       	call   c0100dda <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01060bb:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c01060c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01060c7:	00 
c01060c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01060cf:	00 
c01060d0:	89 04 24             	mov    %eax,(%esp)
c01060d3:	e8 49 f8 ff ff       	call   c0105921 <get_page>
c01060d8:	85 c0                	test   %eax,%eax
c01060da:	74 24                	je     c0106100 <check_pgdir+0xb6>
c01060dc:	c7 44 24 0c b4 d3 10 	movl   $0xc010d3b4,0xc(%esp)
c01060e3:	c0 
c01060e4:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01060eb:	c0 
c01060ec:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
c01060f3:	00 
c01060f4:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01060fb:	e8 da ac ff ff       	call   c0100dda <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0106100:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106107:	e8 61 ef ff ff       	call   c010506d <alloc_pages>
c010610c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c010610f:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0106114:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010611b:	00 
c010611c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106123:	00 
c0106124:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106127:	89 54 24 04          	mov    %edx,0x4(%esp)
c010612b:	89 04 24             	mov    %eax,(%esp)
c010612e:	e8 0f fd ff ff       	call   c0105e42 <page_insert>
c0106133:	85 c0                	test   %eax,%eax
c0106135:	74 24                	je     c010615b <check_pgdir+0x111>
c0106137:	c7 44 24 0c dc d3 10 	movl   $0xc010d3dc,0xc(%esp)
c010613e:	c0 
c010613f:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106146:	c0 
c0106147:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
c010614e:	00 
c010614f:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106156:	e8 7f ac ff ff       	call   c0100dda <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c010615b:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0106160:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106167:	00 
c0106168:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010616f:	00 
c0106170:	89 04 24             	mov    %eax,(%esp)
c0106173:	e8 5c f6 ff ff       	call   c01057d4 <get_pte>
c0106178:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010617b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010617f:	75 24                	jne    c01061a5 <check_pgdir+0x15b>
c0106181:	c7 44 24 0c 08 d4 10 	movl   $0xc010d408,0xc(%esp)
c0106188:	c0 
c0106189:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106190:	c0 
c0106191:	c7 44 24 04 8d 02 00 	movl   $0x28d,0x4(%esp)
c0106198:	00 
c0106199:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01061a0:	e8 35 ac ff ff       	call   c0100dda <__panic>
    assert(pte2page(*ptep) == p1);
c01061a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061a8:	8b 00                	mov    (%eax),%eax
c01061aa:	89 04 24             	mov    %eax,(%esp)
c01061ad:	e8 60 ec ff ff       	call   c0104e12 <pte2page>
c01061b2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01061b5:	74 24                	je     c01061db <check_pgdir+0x191>
c01061b7:	c7 44 24 0c 35 d4 10 	movl   $0xc010d435,0xc(%esp)
c01061be:	c0 
c01061bf:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01061c6:	c0 
c01061c7:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
c01061ce:	00 
c01061cf:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01061d6:	e8 ff ab ff ff       	call   c0100dda <__panic>
    assert(page_ref(p1) == 1);
c01061db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061de:	89 04 24             	mov    %eax,(%esp)
c01061e1:	e8 82 ec ff ff       	call   c0104e68 <page_ref>
c01061e6:	83 f8 01             	cmp    $0x1,%eax
c01061e9:	74 24                	je     c010620f <check_pgdir+0x1c5>
c01061eb:	c7 44 24 0c 4b d4 10 	movl   $0xc010d44b,0xc(%esp)
c01061f2:	c0 
c01061f3:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01061fa:	c0 
c01061fb:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
c0106202:	00 
c0106203:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010620a:	e8 cb ab ff ff       	call   c0100dda <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c010620f:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0106214:	8b 00                	mov    (%eax),%eax
c0106216:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010621b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010621e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106221:	c1 e8 0c             	shr    $0xc,%eax
c0106224:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106227:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c010622c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010622f:	72 23                	jb     c0106254 <check_pgdir+0x20a>
c0106231:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106234:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106238:	c7 44 24 08 a0 d1 10 	movl   $0xc010d1a0,0x8(%esp)
c010623f:	c0 
c0106240:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
c0106247:	00 
c0106248:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010624f:	e8 86 ab ff ff       	call   c0100dda <__panic>
c0106254:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106257:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010625c:	83 c0 04             	add    $0x4,%eax
c010625f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0106262:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0106267:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010626e:	00 
c010626f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106276:	00 
c0106277:	89 04 24             	mov    %eax,(%esp)
c010627a:	e8 55 f5 ff ff       	call   c01057d4 <get_pte>
c010627f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0106282:	74 24                	je     c01062a8 <check_pgdir+0x25e>
c0106284:	c7 44 24 0c 60 d4 10 	movl   $0xc010d460,0xc(%esp)
c010628b:	c0 
c010628c:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106293:	c0 
c0106294:	c7 44 24 04 92 02 00 	movl   $0x292,0x4(%esp)
c010629b:	00 
c010629c:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01062a3:	e8 32 ab ff ff       	call   c0100dda <__panic>

    p2 = alloc_page();
c01062a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01062af:	e8 b9 ed ff ff       	call   c010506d <alloc_pages>
c01062b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01062b7:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c01062bc:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01062c3:	00 
c01062c4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01062cb:	00 
c01062cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01062cf:	89 54 24 04          	mov    %edx,0x4(%esp)
c01062d3:	89 04 24             	mov    %eax,(%esp)
c01062d6:	e8 67 fb ff ff       	call   c0105e42 <page_insert>
c01062db:	85 c0                	test   %eax,%eax
c01062dd:	74 24                	je     c0106303 <check_pgdir+0x2b9>
c01062df:	c7 44 24 0c 88 d4 10 	movl   $0xc010d488,0xc(%esp)
c01062e6:	c0 
c01062e7:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01062ee:	c0 
c01062ef:	c7 44 24 04 95 02 00 	movl   $0x295,0x4(%esp)
c01062f6:	00 
c01062f7:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01062fe:	e8 d7 aa ff ff       	call   c0100dda <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0106303:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0106308:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010630f:	00 
c0106310:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106317:	00 
c0106318:	89 04 24             	mov    %eax,(%esp)
c010631b:	e8 b4 f4 ff ff       	call   c01057d4 <get_pte>
c0106320:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106323:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106327:	75 24                	jne    c010634d <check_pgdir+0x303>
c0106329:	c7 44 24 0c c0 d4 10 	movl   $0xc010d4c0,0xc(%esp)
c0106330:	c0 
c0106331:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106338:	c0 
c0106339:	c7 44 24 04 96 02 00 	movl   $0x296,0x4(%esp)
c0106340:	00 
c0106341:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106348:	e8 8d aa ff ff       	call   c0100dda <__panic>
    assert(*ptep & PTE_U);
c010634d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106350:	8b 00                	mov    (%eax),%eax
c0106352:	83 e0 04             	and    $0x4,%eax
c0106355:	85 c0                	test   %eax,%eax
c0106357:	75 24                	jne    c010637d <check_pgdir+0x333>
c0106359:	c7 44 24 0c f0 d4 10 	movl   $0xc010d4f0,0xc(%esp)
c0106360:	c0 
c0106361:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106368:	c0 
c0106369:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
c0106370:	00 
c0106371:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106378:	e8 5d aa ff ff       	call   c0100dda <__panic>
    assert(*ptep & PTE_W);
c010637d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106380:	8b 00                	mov    (%eax),%eax
c0106382:	83 e0 02             	and    $0x2,%eax
c0106385:	85 c0                	test   %eax,%eax
c0106387:	75 24                	jne    c01063ad <check_pgdir+0x363>
c0106389:	c7 44 24 0c fe d4 10 	movl   $0xc010d4fe,0xc(%esp)
c0106390:	c0 
c0106391:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106398:	c0 
c0106399:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
c01063a0:	00 
c01063a1:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01063a8:	e8 2d aa ff ff       	call   c0100dda <__panic>
    assert(boot_pgdir[0] & PTE_U);
c01063ad:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c01063b2:	8b 00                	mov    (%eax),%eax
c01063b4:	83 e0 04             	and    $0x4,%eax
c01063b7:	85 c0                	test   %eax,%eax
c01063b9:	75 24                	jne    c01063df <check_pgdir+0x395>
c01063bb:	c7 44 24 0c 0c d5 10 	movl   $0xc010d50c,0xc(%esp)
c01063c2:	c0 
c01063c3:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01063ca:	c0 
c01063cb:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
c01063d2:	00 
c01063d3:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01063da:	e8 fb a9 ff ff       	call   c0100dda <__panic>
    assert(page_ref(p2) == 1);
c01063df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01063e2:	89 04 24             	mov    %eax,(%esp)
c01063e5:	e8 7e ea ff ff       	call   c0104e68 <page_ref>
c01063ea:	83 f8 01             	cmp    $0x1,%eax
c01063ed:	74 24                	je     c0106413 <check_pgdir+0x3c9>
c01063ef:	c7 44 24 0c 22 d5 10 	movl   $0xc010d522,0xc(%esp)
c01063f6:	c0 
c01063f7:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01063fe:	c0 
c01063ff:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
c0106406:	00 
c0106407:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010640e:	e8 c7 a9 ff ff       	call   c0100dda <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0106413:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0106418:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010641f:	00 
c0106420:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0106427:	00 
c0106428:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010642b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010642f:	89 04 24             	mov    %eax,(%esp)
c0106432:	e8 0b fa ff ff       	call   c0105e42 <page_insert>
c0106437:	85 c0                	test   %eax,%eax
c0106439:	74 24                	je     c010645f <check_pgdir+0x415>
c010643b:	c7 44 24 0c 34 d5 10 	movl   $0xc010d534,0xc(%esp)
c0106442:	c0 
c0106443:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c010644a:	c0 
c010644b:	c7 44 24 04 9c 02 00 	movl   $0x29c,0x4(%esp)
c0106452:	00 
c0106453:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010645a:	e8 7b a9 ff ff       	call   c0100dda <__panic>
    assert(page_ref(p1) == 2);
c010645f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106462:	89 04 24             	mov    %eax,(%esp)
c0106465:	e8 fe e9 ff ff       	call   c0104e68 <page_ref>
c010646a:	83 f8 02             	cmp    $0x2,%eax
c010646d:	74 24                	je     c0106493 <check_pgdir+0x449>
c010646f:	c7 44 24 0c 60 d5 10 	movl   $0xc010d560,0xc(%esp)
c0106476:	c0 
c0106477:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c010647e:	c0 
c010647f:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
c0106486:	00 
c0106487:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010648e:	e8 47 a9 ff ff       	call   c0100dda <__panic>
    assert(page_ref(p2) == 0);
c0106493:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106496:	89 04 24             	mov    %eax,(%esp)
c0106499:	e8 ca e9 ff ff       	call   c0104e68 <page_ref>
c010649e:	85 c0                	test   %eax,%eax
c01064a0:	74 24                	je     c01064c6 <check_pgdir+0x47c>
c01064a2:	c7 44 24 0c 72 d5 10 	movl   $0xc010d572,0xc(%esp)
c01064a9:	c0 
c01064aa:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01064b1:	c0 
c01064b2:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
c01064b9:	00 
c01064ba:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01064c1:	e8 14 a9 ff ff       	call   c0100dda <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01064c6:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c01064cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01064d2:	00 
c01064d3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01064da:	00 
c01064db:	89 04 24             	mov    %eax,(%esp)
c01064de:	e8 f1 f2 ff ff       	call   c01057d4 <get_pte>
c01064e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01064e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01064ea:	75 24                	jne    c0106510 <check_pgdir+0x4c6>
c01064ec:	c7 44 24 0c c0 d4 10 	movl   $0xc010d4c0,0xc(%esp)
c01064f3:	c0 
c01064f4:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01064fb:	c0 
c01064fc:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
c0106503:	00 
c0106504:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010650b:	e8 ca a8 ff ff       	call   c0100dda <__panic>
    assert(pte2page(*ptep) == p1);
c0106510:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106513:	8b 00                	mov    (%eax),%eax
c0106515:	89 04 24             	mov    %eax,(%esp)
c0106518:	e8 f5 e8 ff ff       	call   c0104e12 <pte2page>
c010651d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106520:	74 24                	je     c0106546 <check_pgdir+0x4fc>
c0106522:	c7 44 24 0c 35 d4 10 	movl   $0xc010d435,0xc(%esp)
c0106529:	c0 
c010652a:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106531:	c0 
c0106532:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
c0106539:	00 
c010653a:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106541:	e8 94 a8 ff ff       	call   c0100dda <__panic>
    assert((*ptep & PTE_U) == 0);
c0106546:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106549:	8b 00                	mov    (%eax),%eax
c010654b:	83 e0 04             	and    $0x4,%eax
c010654e:	85 c0                	test   %eax,%eax
c0106550:	74 24                	je     c0106576 <check_pgdir+0x52c>
c0106552:	c7 44 24 0c 84 d5 10 	movl   $0xc010d584,0xc(%esp)
c0106559:	c0 
c010655a:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106561:	c0 
c0106562:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
c0106569:	00 
c010656a:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106571:	e8 64 a8 ff ff       	call   c0100dda <__panic>

    page_remove(boot_pgdir, 0x0);
c0106576:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c010657b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106582:	00 
c0106583:	89 04 24             	mov    %eax,(%esp)
c0106586:	e8 73 f8 ff ff       	call   c0105dfe <page_remove>
    assert(page_ref(p1) == 1);
c010658b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010658e:	89 04 24             	mov    %eax,(%esp)
c0106591:	e8 d2 e8 ff ff       	call   c0104e68 <page_ref>
c0106596:	83 f8 01             	cmp    $0x1,%eax
c0106599:	74 24                	je     c01065bf <check_pgdir+0x575>
c010659b:	c7 44 24 0c 4b d4 10 	movl   $0xc010d44b,0xc(%esp)
c01065a2:	c0 
c01065a3:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01065aa:	c0 
c01065ab:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
c01065b2:	00 
c01065b3:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01065ba:	e8 1b a8 ff ff       	call   c0100dda <__panic>
    assert(page_ref(p2) == 0);
c01065bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01065c2:	89 04 24             	mov    %eax,(%esp)
c01065c5:	e8 9e e8 ff ff       	call   c0104e68 <page_ref>
c01065ca:	85 c0                	test   %eax,%eax
c01065cc:	74 24                	je     c01065f2 <check_pgdir+0x5a8>
c01065ce:	c7 44 24 0c 72 d5 10 	movl   $0xc010d572,0xc(%esp)
c01065d5:	c0 
c01065d6:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01065dd:	c0 
c01065de:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
c01065e5:	00 
c01065e6:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01065ed:	e8 e8 a7 ff ff       	call   c0100dda <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01065f2:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c01065f7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01065fe:	00 
c01065ff:	89 04 24             	mov    %eax,(%esp)
c0106602:	e8 f7 f7 ff ff       	call   c0105dfe <page_remove>
    assert(page_ref(p1) == 0);
c0106607:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010660a:	89 04 24             	mov    %eax,(%esp)
c010660d:	e8 56 e8 ff ff       	call   c0104e68 <page_ref>
c0106612:	85 c0                	test   %eax,%eax
c0106614:	74 24                	je     c010663a <check_pgdir+0x5f0>
c0106616:	c7 44 24 0c 99 d5 10 	movl   $0xc010d599,0xc(%esp)
c010661d:	c0 
c010661e:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106625:	c0 
c0106626:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
c010662d:	00 
c010662e:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106635:	e8 a0 a7 ff ff       	call   c0100dda <__panic>
    assert(page_ref(p2) == 0);
c010663a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010663d:	89 04 24             	mov    %eax,(%esp)
c0106640:	e8 23 e8 ff ff       	call   c0104e68 <page_ref>
c0106645:	85 c0                	test   %eax,%eax
c0106647:	74 24                	je     c010666d <check_pgdir+0x623>
c0106649:	c7 44 24 0c 72 d5 10 	movl   $0xc010d572,0xc(%esp)
c0106650:	c0 
c0106651:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106658:	c0 
c0106659:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
c0106660:	00 
c0106661:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106668:	e8 6d a7 ff ff       	call   c0100dda <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c010666d:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0106672:	8b 00                	mov    (%eax),%eax
c0106674:	89 04 24             	mov    %eax,(%esp)
c0106677:	e8 d4 e7 ff ff       	call   c0104e50 <pde2page>
c010667c:	89 04 24             	mov    %eax,(%esp)
c010667f:	e8 e4 e7 ff ff       	call   c0104e68 <page_ref>
c0106684:	83 f8 01             	cmp    $0x1,%eax
c0106687:	74 24                	je     c01066ad <check_pgdir+0x663>
c0106689:	c7 44 24 0c ac d5 10 	movl   $0xc010d5ac,0xc(%esp)
c0106690:	c0 
c0106691:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106698:	c0 
c0106699:	c7 44 24 04 ab 02 00 	movl   $0x2ab,0x4(%esp)
c01066a0:	00 
c01066a1:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01066a8:	e8 2d a7 ff ff       	call   c0100dda <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01066ad:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c01066b2:	8b 00                	mov    (%eax),%eax
c01066b4:	89 04 24             	mov    %eax,(%esp)
c01066b7:	e8 94 e7 ff ff       	call   c0104e50 <pde2page>
c01066bc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01066c3:	00 
c01066c4:	89 04 24             	mov    %eax,(%esp)
c01066c7:	e8 0c ea ff ff       	call   c01050d8 <free_pages>
    boot_pgdir[0] = 0;
c01066cc:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c01066d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01066d7:	c7 04 24 d3 d5 10 c0 	movl   $0xc010d5d3,(%esp)
c01066de:	e8 75 9c ff ff       	call   c0100358 <cprintf>
}
c01066e3:	c9                   	leave  
c01066e4:	c3                   	ret    

c01066e5 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01066e5:	55                   	push   %ebp
c01066e6:	89 e5                	mov    %esp,%ebp
c01066e8:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01066eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01066f2:	e9 ca 00 00 00       	jmp    c01067c1 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c01066f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01066fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01066fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106700:	c1 e8 0c             	shr    $0xc,%eax
c0106703:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106706:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c010670b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010670e:	72 23                	jb     c0106733 <check_boot_pgdir+0x4e>
c0106710:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106713:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106717:	c7 44 24 08 a0 d1 10 	movl   $0xc010d1a0,0x8(%esp)
c010671e:	c0 
c010671f:	c7 44 24 04 b7 02 00 	movl   $0x2b7,0x4(%esp)
c0106726:	00 
c0106727:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010672e:	e8 a7 a6 ff ff       	call   c0100dda <__panic>
c0106733:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106736:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010673b:	89 c2                	mov    %eax,%edx
c010673d:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0106742:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106749:	00 
c010674a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010674e:	89 04 24             	mov    %eax,(%esp)
c0106751:	e8 7e f0 ff ff       	call   c01057d4 <get_pte>
c0106756:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106759:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010675d:	75 24                	jne    c0106783 <check_boot_pgdir+0x9e>
c010675f:	c7 44 24 0c f0 d5 10 	movl   $0xc010d5f0,0xc(%esp)
c0106766:	c0 
c0106767:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c010676e:	c0 
c010676f:	c7 44 24 04 b7 02 00 	movl   $0x2b7,0x4(%esp)
c0106776:	00 
c0106777:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010677e:	e8 57 a6 ff ff       	call   c0100dda <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0106783:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106786:	8b 00                	mov    (%eax),%eax
c0106788:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010678d:	89 c2                	mov    %eax,%edx
c010678f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106792:	39 c2                	cmp    %eax,%edx
c0106794:	74 24                	je     c01067ba <check_boot_pgdir+0xd5>
c0106796:	c7 44 24 0c 2d d6 10 	movl   $0xc010d62d,0xc(%esp)
c010679d:	c0 
c010679e:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01067a5:	c0 
c01067a6:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
c01067ad:	00 
c01067ae:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01067b5:	e8 20 a6 ff ff       	call   c0100dda <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01067ba:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01067c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01067c4:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c01067c9:	39 c2                	cmp    %eax,%edx
c01067cb:	0f 82 26 ff ff ff    	jb     c01066f7 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01067d1:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c01067d6:	05 ac 0f 00 00       	add    $0xfac,%eax
c01067db:	8b 00                	mov    (%eax),%eax
c01067dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01067e2:	89 c2                	mov    %eax,%edx
c01067e4:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c01067e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01067ec:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c01067f3:	77 23                	ja     c0106818 <check_boot_pgdir+0x133>
c01067f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01067f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01067fc:	c7 44 24 08 44 d2 10 	movl   $0xc010d244,0x8(%esp)
c0106803:	c0 
c0106804:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
c010680b:	00 
c010680c:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106813:	e8 c2 a5 ff ff       	call   c0100dda <__panic>
c0106818:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010681b:	05 00 00 00 40       	add    $0x40000000,%eax
c0106820:	39 c2                	cmp    %eax,%edx
c0106822:	74 24                	je     c0106848 <check_boot_pgdir+0x163>
c0106824:	c7 44 24 0c 44 d6 10 	movl   $0xc010d644,0xc(%esp)
c010682b:	c0 
c010682c:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106833:	c0 
c0106834:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
c010683b:	00 
c010683c:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106843:	e8 92 a5 ff ff       	call   c0100dda <__panic>

    assert(boot_pgdir[0] == 0);
c0106848:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c010684d:	8b 00                	mov    (%eax),%eax
c010684f:	85 c0                	test   %eax,%eax
c0106851:	74 24                	je     c0106877 <check_boot_pgdir+0x192>
c0106853:	c7 44 24 0c 78 d6 10 	movl   $0xc010d678,0xc(%esp)
c010685a:	c0 
c010685b:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106862:	c0 
c0106863:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
c010686a:	00 
c010686b:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106872:	e8 63 a5 ff ff       	call   c0100dda <__panic>

    struct Page *p;
    p = alloc_page();
c0106877:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010687e:	e8 ea e7 ff ff       	call   c010506d <alloc_pages>
c0106883:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0106886:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c010688b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106892:	00 
c0106893:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c010689a:	00 
c010689b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010689e:	89 54 24 04          	mov    %edx,0x4(%esp)
c01068a2:	89 04 24             	mov    %eax,(%esp)
c01068a5:	e8 98 f5 ff ff       	call   c0105e42 <page_insert>
c01068aa:	85 c0                	test   %eax,%eax
c01068ac:	74 24                	je     c01068d2 <check_boot_pgdir+0x1ed>
c01068ae:	c7 44 24 0c 8c d6 10 	movl   $0xc010d68c,0xc(%esp)
c01068b5:	c0 
c01068b6:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01068bd:	c0 
c01068be:	c7 44 24 04 c1 02 00 	movl   $0x2c1,0x4(%esp)
c01068c5:	00 
c01068c6:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01068cd:	e8 08 a5 ff ff       	call   c0100dda <__panic>
    assert(page_ref(p) == 1);
c01068d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01068d5:	89 04 24             	mov    %eax,(%esp)
c01068d8:	e8 8b e5 ff ff       	call   c0104e68 <page_ref>
c01068dd:	83 f8 01             	cmp    $0x1,%eax
c01068e0:	74 24                	je     c0106906 <check_boot_pgdir+0x221>
c01068e2:	c7 44 24 0c ba d6 10 	movl   $0xc010d6ba,0xc(%esp)
c01068e9:	c0 
c01068ea:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01068f1:	c0 
c01068f2:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
c01068f9:	00 
c01068fa:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106901:	e8 d4 a4 ff ff       	call   c0100dda <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0106906:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c010690b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106912:	00 
c0106913:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c010691a:	00 
c010691b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010691e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106922:	89 04 24             	mov    %eax,(%esp)
c0106925:	e8 18 f5 ff ff       	call   c0105e42 <page_insert>
c010692a:	85 c0                	test   %eax,%eax
c010692c:	74 24                	je     c0106952 <check_boot_pgdir+0x26d>
c010692e:	c7 44 24 0c cc d6 10 	movl   $0xc010d6cc,0xc(%esp)
c0106935:	c0 
c0106936:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c010693d:	c0 
c010693e:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
c0106945:	00 
c0106946:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c010694d:	e8 88 a4 ff ff       	call   c0100dda <__panic>
    assert(page_ref(p) == 2);
c0106952:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106955:	89 04 24             	mov    %eax,(%esp)
c0106958:	e8 0b e5 ff ff       	call   c0104e68 <page_ref>
c010695d:	83 f8 02             	cmp    $0x2,%eax
c0106960:	74 24                	je     c0106986 <check_boot_pgdir+0x2a1>
c0106962:	c7 44 24 0c 03 d7 10 	movl   $0xc010d703,0xc(%esp)
c0106969:	c0 
c010696a:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106971:	c0 
c0106972:	c7 44 24 04 c4 02 00 	movl   $0x2c4,0x4(%esp)
c0106979:	00 
c010697a:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106981:	e8 54 a4 ff ff       	call   c0100dda <__panic>

    const char *str = "ucore: Hello world!!";
c0106986:	c7 45 dc 14 d7 10 c0 	movl   $0xc010d714,-0x24(%ebp)
    strcpy((void *)0x100, str);
c010698d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106990:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106994:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010699b:	e8 a7 55 00 00       	call   c010bf47 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01069a0:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01069a7:	00 
c01069a8:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01069af:	e8 0c 56 00 00       	call   c010bfc0 <strcmp>
c01069b4:	85 c0                	test   %eax,%eax
c01069b6:	74 24                	je     c01069dc <check_boot_pgdir+0x2f7>
c01069b8:	c7 44 24 0c 2c d7 10 	movl   $0xc010d72c,0xc(%esp)
c01069bf:	c0 
c01069c0:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c01069c7:	c0 
c01069c8:	c7 44 24 04 c8 02 00 	movl   $0x2c8,0x4(%esp)
c01069cf:	00 
c01069d0:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c01069d7:	e8 fe a3 ff ff       	call   c0100dda <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01069dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01069df:	89 04 24             	mov    %eax,(%esp)
c01069e2:	e8 d7 e3 ff ff       	call   c0104dbe <page2kva>
c01069e7:	05 00 01 00 00       	add    $0x100,%eax
c01069ec:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01069ef:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01069f6:	e8 f4 54 00 00       	call   c010beef <strlen>
c01069fb:	85 c0                	test   %eax,%eax
c01069fd:	74 24                	je     c0106a23 <check_boot_pgdir+0x33e>
c01069ff:	c7 44 24 0c 64 d7 10 	movl   $0xc010d764,0xc(%esp)
c0106a06:	c0 
c0106a07:	c7 44 24 08 8d d2 10 	movl   $0xc010d28d,0x8(%esp)
c0106a0e:	c0 
c0106a0f:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
c0106a16:	00 
c0106a17:	c7 04 24 68 d2 10 c0 	movl   $0xc010d268,(%esp)
c0106a1e:	e8 b7 a3 ff ff       	call   c0100dda <__panic>

    free_page(p);
c0106a23:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106a2a:	00 
c0106a2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106a2e:	89 04 24             	mov    %eax,(%esp)
c0106a31:	e8 a2 e6 ff ff       	call   c01050d8 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0106a36:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0106a3b:	8b 00                	mov    (%eax),%eax
c0106a3d:	89 04 24             	mov    %eax,(%esp)
c0106a40:	e8 0b e4 ff ff       	call   c0104e50 <pde2page>
c0106a45:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106a4c:	00 
c0106a4d:	89 04 24             	mov    %eax,(%esp)
c0106a50:	e8 83 e6 ff ff       	call   c01050d8 <free_pages>
    boot_pgdir[0] = 0;
c0106a55:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0106a5a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0106a60:	c7 04 24 88 d7 10 c0 	movl   $0xc010d788,(%esp)
c0106a67:	e8 ec 98 ff ff       	call   c0100358 <cprintf>
}
c0106a6c:	c9                   	leave  
c0106a6d:	c3                   	ret    

c0106a6e <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0106a6e:	55                   	push   %ebp
c0106a6f:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0106a71:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a74:	83 e0 04             	and    $0x4,%eax
c0106a77:	85 c0                	test   %eax,%eax
c0106a79:	74 07                	je     c0106a82 <perm2str+0x14>
c0106a7b:	b8 75 00 00 00       	mov    $0x75,%eax
c0106a80:	eb 05                	jmp    c0106a87 <perm2str+0x19>
c0106a82:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0106a87:	a2 08 ee 1a c0       	mov    %al,0xc01aee08
    str[1] = 'r';
c0106a8c:	c6 05 09 ee 1a c0 72 	movb   $0x72,0xc01aee09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0106a93:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a96:	83 e0 02             	and    $0x2,%eax
c0106a99:	85 c0                	test   %eax,%eax
c0106a9b:	74 07                	je     c0106aa4 <perm2str+0x36>
c0106a9d:	b8 77 00 00 00       	mov    $0x77,%eax
c0106aa2:	eb 05                	jmp    c0106aa9 <perm2str+0x3b>
c0106aa4:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0106aa9:	a2 0a ee 1a c0       	mov    %al,0xc01aee0a
    str[3] = '\0';
c0106aae:	c6 05 0b ee 1a c0 00 	movb   $0x0,0xc01aee0b
    return str;
c0106ab5:	b8 08 ee 1a c0       	mov    $0xc01aee08,%eax
}
c0106aba:	5d                   	pop    %ebp
c0106abb:	c3                   	ret    

c0106abc <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0106abc:	55                   	push   %ebp
c0106abd:	89 e5                	mov    %esp,%ebp
c0106abf:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0106ac2:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ac5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106ac8:	72 0a                	jb     c0106ad4 <get_pgtable_items+0x18>
        return 0;
c0106aca:	b8 00 00 00 00       	mov    $0x0,%eax
c0106acf:	e9 9c 00 00 00       	jmp    c0106b70 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0106ad4:	eb 04                	jmp    c0106ada <get_pgtable_items+0x1e>
        start ++;
c0106ad6:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0106ada:	8b 45 10             	mov    0x10(%ebp),%eax
c0106add:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106ae0:	73 18                	jae    c0106afa <get_pgtable_items+0x3e>
c0106ae2:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ae5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106aec:	8b 45 14             	mov    0x14(%ebp),%eax
c0106aef:	01 d0                	add    %edx,%eax
c0106af1:	8b 00                	mov    (%eax),%eax
c0106af3:	83 e0 01             	and    $0x1,%eax
c0106af6:	85 c0                	test   %eax,%eax
c0106af8:	74 dc                	je     c0106ad6 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0106afa:	8b 45 10             	mov    0x10(%ebp),%eax
c0106afd:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106b00:	73 69                	jae    c0106b6b <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0106b02:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0106b06:	74 08                	je     c0106b10 <get_pgtable_items+0x54>
            *left_store = start;
c0106b08:	8b 45 18             	mov    0x18(%ebp),%eax
c0106b0b:	8b 55 10             	mov    0x10(%ebp),%edx
c0106b0e:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0106b10:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b13:	8d 50 01             	lea    0x1(%eax),%edx
c0106b16:	89 55 10             	mov    %edx,0x10(%ebp)
c0106b19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106b20:	8b 45 14             	mov    0x14(%ebp),%eax
c0106b23:	01 d0                	add    %edx,%eax
c0106b25:	8b 00                	mov    (%eax),%eax
c0106b27:	83 e0 07             	and    $0x7,%eax
c0106b2a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106b2d:	eb 04                	jmp    c0106b33 <get_pgtable_items+0x77>
            start ++;
c0106b2f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106b33:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b36:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106b39:	73 1d                	jae    c0106b58 <get_pgtable_items+0x9c>
c0106b3b:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b3e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106b45:	8b 45 14             	mov    0x14(%ebp),%eax
c0106b48:	01 d0                	add    %edx,%eax
c0106b4a:	8b 00                	mov    (%eax),%eax
c0106b4c:	83 e0 07             	and    $0x7,%eax
c0106b4f:	89 c2                	mov    %eax,%edx
c0106b51:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106b54:	39 c2                	cmp    %eax,%edx
c0106b56:	74 d7                	je     c0106b2f <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0106b58:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106b5c:	74 08                	je     c0106b66 <get_pgtable_items+0xaa>
            *right_store = start;
c0106b5e:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106b61:	8b 55 10             	mov    0x10(%ebp),%edx
c0106b64:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0106b66:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106b69:	eb 05                	jmp    c0106b70 <get_pgtable_items+0xb4>
    }
    return 0;
c0106b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106b70:	c9                   	leave  
c0106b71:	c3                   	ret    

c0106b72 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0106b72:	55                   	push   %ebp
c0106b73:	89 e5                	mov    %esp,%ebp
c0106b75:	57                   	push   %edi
c0106b76:	56                   	push   %esi
c0106b77:	53                   	push   %ebx
c0106b78:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0106b7b:	c7 04 24 a8 d7 10 c0 	movl   $0xc010d7a8,(%esp)
c0106b82:	e8 d1 97 ff ff       	call   c0100358 <cprintf>
    size_t left, right = 0, perm;
c0106b87:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106b8e:	e9 fa 00 00 00       	jmp    c0106c8d <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106b93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b96:	89 04 24             	mov    %eax,(%esp)
c0106b99:	e8 d0 fe ff ff       	call   c0106a6e <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0106b9e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106ba1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106ba4:	29 d1                	sub    %edx,%ecx
c0106ba6:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106ba8:	89 d6                	mov    %edx,%esi
c0106baa:	c1 e6 16             	shl    $0x16,%esi
c0106bad:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106bb0:	89 d3                	mov    %edx,%ebx
c0106bb2:	c1 e3 16             	shl    $0x16,%ebx
c0106bb5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106bb8:	89 d1                	mov    %edx,%ecx
c0106bba:	c1 e1 16             	shl    $0x16,%ecx
c0106bbd:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0106bc0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106bc3:	29 d7                	sub    %edx,%edi
c0106bc5:	89 fa                	mov    %edi,%edx
c0106bc7:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106bcb:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106bcf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106bd3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106bd7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106bdb:	c7 04 24 d9 d7 10 c0 	movl   $0xc010d7d9,(%esp)
c0106be2:	e8 71 97 ff ff       	call   c0100358 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0106be7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106bea:	c1 e0 0a             	shl    $0xa,%eax
c0106bed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106bf0:	eb 54                	jmp    c0106c46 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106bf2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106bf5:	89 04 24             	mov    %eax,(%esp)
c0106bf8:	e8 71 fe ff ff       	call   c0106a6e <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0106bfd:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0106c00:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106c03:	29 d1                	sub    %edx,%ecx
c0106c05:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106c07:	89 d6                	mov    %edx,%esi
c0106c09:	c1 e6 0c             	shl    $0xc,%esi
c0106c0c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106c0f:	89 d3                	mov    %edx,%ebx
c0106c11:	c1 e3 0c             	shl    $0xc,%ebx
c0106c14:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106c17:	c1 e2 0c             	shl    $0xc,%edx
c0106c1a:	89 d1                	mov    %edx,%ecx
c0106c1c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0106c1f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106c22:	29 d7                	sub    %edx,%edi
c0106c24:	89 fa                	mov    %edi,%edx
c0106c26:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106c2a:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106c2e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106c32:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106c36:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106c3a:	c7 04 24 f8 d7 10 c0 	movl   $0xc010d7f8,(%esp)
c0106c41:	e8 12 97 ff ff       	call   c0100358 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106c46:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0106c4b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106c4e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106c51:	89 ce                	mov    %ecx,%esi
c0106c53:	c1 e6 0a             	shl    $0xa,%esi
c0106c56:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0106c59:	89 cb                	mov    %ecx,%ebx
c0106c5b:	c1 e3 0a             	shl    $0xa,%ebx
c0106c5e:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0106c61:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0106c65:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0106c68:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0106c6c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106c70:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106c74:	89 74 24 04          	mov    %esi,0x4(%esp)
c0106c78:	89 1c 24             	mov    %ebx,(%esp)
c0106c7b:	e8 3c fe ff ff       	call   c0106abc <get_pgtable_items>
c0106c80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106c83:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106c87:	0f 85 65 ff ff ff    	jne    c0106bf2 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106c8d:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0106c92:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106c95:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0106c98:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0106c9c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0106c9f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0106ca3:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106ca7:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106cab:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0106cb2:	00 
c0106cb3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0106cba:	e8 fd fd ff ff       	call   c0106abc <get_pgtable_items>
c0106cbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106cc2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106cc6:	0f 85 c7 fe ff ff    	jne    c0106b93 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106ccc:	c7 04 24 1c d8 10 c0 	movl   $0xc010d81c,(%esp)
c0106cd3:	e8 80 96 ff ff       	call   c0100358 <cprintf>
}
c0106cd8:	83 c4 4c             	add    $0x4c,%esp
c0106cdb:	5b                   	pop    %ebx
c0106cdc:	5e                   	pop    %esi
c0106cdd:	5f                   	pop    %edi
c0106cde:	5d                   	pop    %ebp
c0106cdf:	c3                   	ret    

c0106ce0 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0106ce0:	55                   	push   %ebp
c0106ce1:	89 e5                	mov    %esp,%ebp
c0106ce3:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0106ce6:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ce9:	c1 e8 0c             	shr    $0xc,%eax
c0106cec:	89 c2                	mov    %eax,%edx
c0106cee:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c0106cf3:	39 c2                	cmp    %eax,%edx
c0106cf5:	72 1c                	jb     c0106d13 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0106cf7:	c7 44 24 08 50 d8 10 	movl   $0xc010d850,0x8(%esp)
c0106cfe:	c0 
c0106cff:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0106d06:	00 
c0106d07:	c7 04 24 6f d8 10 c0 	movl   $0xc010d86f,(%esp)
c0106d0e:	e8 c7 a0 ff ff       	call   c0100dda <__panic>
    }
    return &pages[PPN(pa)];
c0106d13:	a1 90 0e 1b c0       	mov    0xc01b0e90,%eax
c0106d18:	8b 55 08             	mov    0x8(%ebp),%edx
c0106d1b:	c1 ea 0c             	shr    $0xc,%edx
c0106d1e:	c1 e2 05             	shl    $0x5,%edx
c0106d21:	01 d0                	add    %edx,%eax
}
c0106d23:	c9                   	leave  
c0106d24:	c3                   	ret    

c0106d25 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0106d25:	55                   	push   %ebp
c0106d26:	89 e5                	mov    %esp,%ebp
c0106d28:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0106d2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d2e:	83 e0 01             	and    $0x1,%eax
c0106d31:	85 c0                	test   %eax,%eax
c0106d33:	75 1c                	jne    c0106d51 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0106d35:	c7 44 24 08 80 d8 10 	movl   $0xc010d880,0x8(%esp)
c0106d3c:	c0 
c0106d3d:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0106d44:	00 
c0106d45:	c7 04 24 6f d8 10 c0 	movl   $0xc010d86f,(%esp)
c0106d4c:	e8 89 a0 ff ff       	call   c0100dda <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0106d51:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d54:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106d59:	89 04 24             	mov    %eax,(%esp)
c0106d5c:	e8 7f ff ff ff       	call   c0106ce0 <pa2page>
}
c0106d61:	c9                   	leave  
c0106d62:	c3                   	ret    

c0106d63 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0106d63:	55                   	push   %ebp
c0106d64:	89 e5                	mov    %esp,%ebp
c0106d66:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0106d69:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106d71:	89 04 24             	mov    %eax,(%esp)
c0106d74:	e8 67 ff ff ff       	call   c0106ce0 <pa2page>
}
c0106d79:	c9                   	leave  
c0106d7a:	c3                   	ret    

c0106d7b <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106d7b:	55                   	push   %ebp
c0106d7c:	89 e5                	mov    %esp,%ebp
c0106d7e:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0106d81:	e8 04 24 00 00       	call   c010918a <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0106d86:	a1 3c 0f 1b c0       	mov    0xc01b0f3c,%eax
c0106d8b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106d90:	76 0c                	jbe    c0106d9e <swap_init+0x23>
c0106d92:	a1 3c 0f 1b c0       	mov    0xc01b0f3c,%eax
c0106d97:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106d9c:	76 25                	jbe    c0106dc3 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106d9e:	a1 3c 0f 1b c0       	mov    0xc01b0f3c,%eax
c0106da3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106da7:	c7 44 24 08 a1 d8 10 	movl   $0xc010d8a1,0x8(%esp)
c0106dae:	c0 
c0106daf:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
c0106db6:	00 
c0106db7:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c0106dbe:	e8 17 a0 ff ff       	call   c0100dda <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106dc3:	c7 05 14 ee 1a c0 60 	movl   $0xc012ca60,0xc01aee14
c0106dca:	ca 12 c0 
     int r = sm->init();
c0106dcd:	a1 14 ee 1a c0       	mov    0xc01aee14,%eax
c0106dd2:	8b 40 04             	mov    0x4(%eax),%eax
c0106dd5:	ff d0                	call   *%eax
c0106dd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106dda:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106dde:	75 26                	jne    c0106e06 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0106de0:	c7 05 0c ee 1a c0 01 	movl   $0x1,0xc01aee0c
c0106de7:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106dea:	a1 14 ee 1a c0       	mov    0xc01aee14,%eax
c0106def:	8b 00                	mov    (%eax),%eax
c0106df1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106df5:	c7 04 24 cb d8 10 c0 	movl   $0xc010d8cb,(%esp)
c0106dfc:	e8 57 95 ff ff       	call   c0100358 <cprintf>
          check_swap();
c0106e01:	e8 a4 04 00 00       	call   c01072aa <check_swap>
     }

     return r;
c0106e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106e09:	c9                   	leave  
c0106e0a:	c3                   	ret    

c0106e0b <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0106e0b:	55                   	push   %ebp
c0106e0c:	89 e5                	mov    %esp,%ebp
c0106e0e:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0106e11:	a1 14 ee 1a c0       	mov    0xc01aee14,%eax
c0106e16:	8b 40 08             	mov    0x8(%eax),%eax
c0106e19:	8b 55 08             	mov    0x8(%ebp),%edx
c0106e1c:	89 14 24             	mov    %edx,(%esp)
c0106e1f:	ff d0                	call   *%eax
}
c0106e21:	c9                   	leave  
c0106e22:	c3                   	ret    

c0106e23 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0106e23:	55                   	push   %ebp
c0106e24:	89 e5                	mov    %esp,%ebp
c0106e26:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0106e29:	a1 14 ee 1a c0       	mov    0xc01aee14,%eax
c0106e2e:	8b 40 0c             	mov    0xc(%eax),%eax
c0106e31:	8b 55 08             	mov    0x8(%ebp),%edx
c0106e34:	89 14 24             	mov    %edx,(%esp)
c0106e37:	ff d0                	call   *%eax
}
c0106e39:	c9                   	leave  
c0106e3a:	c3                   	ret    

c0106e3b <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106e3b:	55                   	push   %ebp
c0106e3c:	89 e5                	mov    %esp,%ebp
c0106e3e:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0106e41:	a1 14 ee 1a c0       	mov    0xc01aee14,%eax
c0106e46:	8b 40 10             	mov    0x10(%eax),%eax
c0106e49:	8b 55 14             	mov    0x14(%ebp),%edx
c0106e4c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106e50:	8b 55 10             	mov    0x10(%ebp),%edx
c0106e53:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106e57:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106e5a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106e5e:	8b 55 08             	mov    0x8(%ebp),%edx
c0106e61:	89 14 24             	mov    %edx,(%esp)
c0106e64:	ff d0                	call   *%eax
}
c0106e66:	c9                   	leave  
c0106e67:	c3                   	ret    

c0106e68 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0106e68:	55                   	push   %ebp
c0106e69:	89 e5                	mov    %esp,%ebp
c0106e6b:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0106e6e:	a1 14 ee 1a c0       	mov    0xc01aee14,%eax
c0106e73:	8b 40 14             	mov    0x14(%eax),%eax
c0106e76:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106e79:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106e7d:	8b 55 08             	mov    0x8(%ebp),%edx
c0106e80:	89 14 24             	mov    %edx,(%esp)
c0106e83:	ff d0                	call   *%eax
}
c0106e85:	c9                   	leave  
c0106e86:	c3                   	ret    

c0106e87 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0106e87:	55                   	push   %ebp
c0106e88:	89 e5                	mov    %esp,%ebp
c0106e8a:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0106e8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106e94:	e9 5a 01 00 00       	jmp    c0106ff3 <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106e99:	a1 14 ee 1a c0       	mov    0xc01aee14,%eax
c0106e9e:	8b 40 18             	mov    0x18(%eax),%eax
c0106ea1:	8b 55 10             	mov    0x10(%ebp),%edx
c0106ea4:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106ea8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0106eab:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106eaf:	8b 55 08             	mov    0x8(%ebp),%edx
c0106eb2:	89 14 24             	mov    %edx,(%esp)
c0106eb5:	ff d0                	call   *%eax
c0106eb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0106eba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106ebe:	74 18                	je     c0106ed8 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0106ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ec3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ec7:	c7 04 24 e0 d8 10 c0 	movl   $0xc010d8e0,(%esp)
c0106ece:	e8 85 94 ff ff       	call   c0100358 <cprintf>
c0106ed3:	e9 27 01 00 00       	jmp    c0106fff <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0106ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106edb:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106ede:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0106ee1:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ee4:	8b 40 0c             	mov    0xc(%eax),%eax
c0106ee7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106eee:	00 
c0106eef:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106ef2:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106ef6:	89 04 24             	mov    %eax,(%esp)
c0106ef9:	e8 d6 e8 ff ff       	call   c01057d4 <get_pte>
c0106efe:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0106f01:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f04:	8b 00                	mov    (%eax),%eax
c0106f06:	83 e0 01             	and    $0x1,%eax
c0106f09:	85 c0                	test   %eax,%eax
c0106f0b:	75 24                	jne    c0106f31 <swap_out+0xaa>
c0106f0d:	c7 44 24 0c 0d d9 10 	movl   $0xc010d90d,0xc(%esp)
c0106f14:	c0 
c0106f15:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c0106f1c:	c0 
c0106f1d:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0106f24:	00 
c0106f25:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c0106f2c:	e8 a9 9e ff ff       	call   c0100dda <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0106f31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f34:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106f37:	8b 52 1c             	mov    0x1c(%edx),%edx
c0106f3a:	c1 ea 0c             	shr    $0xc,%edx
c0106f3d:	83 c2 01             	add    $0x1,%edx
c0106f40:	c1 e2 08             	shl    $0x8,%edx
c0106f43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f47:	89 14 24             	mov    %edx,(%esp)
c0106f4a:	e8 f5 22 00 00       	call   c0109244 <swapfs_write>
c0106f4f:	85 c0                	test   %eax,%eax
c0106f51:	74 34                	je     c0106f87 <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c0106f53:	c7 04 24 37 d9 10 c0 	movl   $0xc010d937,(%esp)
c0106f5a:	e8 f9 93 ff ff       	call   c0100358 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0106f5f:	a1 14 ee 1a c0       	mov    0xc01aee14,%eax
c0106f64:	8b 40 10             	mov    0x10(%eax),%eax
c0106f67:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106f6a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106f71:	00 
c0106f72:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106f76:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106f79:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106f7d:	8b 55 08             	mov    0x8(%ebp),%edx
c0106f80:	89 14 24             	mov    %edx,(%esp)
c0106f83:	ff d0                	call   *%eax
c0106f85:	eb 68                	jmp    c0106fef <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0106f87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f8a:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106f8d:	c1 e8 0c             	shr    $0xc,%eax
c0106f90:	83 c0 01             	add    $0x1,%eax
c0106f93:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106f97:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f9a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106fa5:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0106fac:	e8 a7 93 ff ff       	call   c0100358 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0106fb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106fb4:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106fb7:	c1 e8 0c             	shr    $0xc,%eax
c0106fba:	83 c0 01             	add    $0x1,%eax
c0106fbd:	c1 e0 08             	shl    $0x8,%eax
c0106fc0:	89 c2                	mov    %eax,%edx
c0106fc2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106fc5:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106fc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106fca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106fd1:	00 
c0106fd2:	89 04 24             	mov    %eax,(%esp)
c0106fd5:	e8 fe e0 ff ff       	call   c01050d8 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106fda:	8b 45 08             	mov    0x8(%ebp),%eax
c0106fdd:	8b 40 0c             	mov    0xc(%eax),%eax
c0106fe0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106fe3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106fe7:	89 04 24             	mov    %eax,(%esp)
c0106fea:	e8 0c ef ff ff       	call   c0105efb <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0106fef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ff6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106ff9:	0f 85 9a fe ff ff    	jne    c0106e99 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0106fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107002:	c9                   	leave  
c0107003:	c3                   	ret    

c0107004 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0107004:	55                   	push   %ebp
c0107005:	89 e5                	mov    %esp,%ebp
c0107007:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c010700a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107011:	e8 57 e0 ff ff       	call   c010506d <alloc_pages>
c0107016:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0107019:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010701d:	75 24                	jne    c0107043 <swap_in+0x3f>
c010701f:	c7 44 24 0c 90 d9 10 	movl   $0xc010d990,0xc(%esp)
c0107026:	c0 
c0107027:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c010702e:	c0 
c010702f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0107036:	00 
c0107037:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c010703e:	e8 97 9d ff ff       	call   c0100dda <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0107043:	8b 45 08             	mov    0x8(%ebp),%eax
c0107046:	8b 40 0c             	mov    0xc(%eax),%eax
c0107049:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107050:	00 
c0107051:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107054:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107058:	89 04 24             	mov    %eax,(%esp)
c010705b:	e8 74 e7 ff ff       	call   c01057d4 <get_pte>
c0107060:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0107063:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107066:	8b 00                	mov    (%eax),%eax
c0107068:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010706b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010706f:	89 04 24             	mov    %eax,(%esp)
c0107072:	e8 5b 21 00 00       	call   c01091d2 <swapfs_read>
c0107077:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010707a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010707e:	74 2a                	je     c01070aa <swap_in+0xa6>
     {
        assert(r!=0);
c0107080:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107084:	75 24                	jne    c01070aa <swap_in+0xa6>
c0107086:	c7 44 24 0c 9d d9 10 	movl   $0xc010d99d,0xc(%esp)
c010708d:	c0 
c010708e:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c0107095:	c0 
c0107096:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c010709d:	00 
c010709e:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c01070a5:	e8 30 9d ff ff       	call   c0100dda <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c01070aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01070ad:	8b 00                	mov    (%eax),%eax
c01070af:	c1 e8 08             	shr    $0x8,%eax
c01070b2:	89 c2                	mov    %eax,%edx
c01070b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01070b7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01070bb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01070bf:	c7 04 24 a4 d9 10 c0 	movl   $0xc010d9a4,(%esp)
c01070c6:	e8 8d 92 ff ff       	call   c0100358 <cprintf>
     *ptr_result=result;
c01070cb:	8b 45 10             	mov    0x10(%ebp),%eax
c01070ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01070d1:	89 10                	mov    %edx,(%eax)
     return 0;
c01070d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01070d8:	c9                   	leave  
c01070d9:	c3                   	ret    

c01070da <check_content_set>:



static inline void
check_content_set(void)
{
c01070da:	55                   	push   %ebp
c01070db:	89 e5                	mov    %esp,%ebp
c01070dd:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c01070e0:	b8 00 10 00 00       	mov    $0x1000,%eax
c01070e5:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01070e8:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c01070ed:	83 f8 01             	cmp    $0x1,%eax
c01070f0:	74 24                	je     c0107116 <check_content_set+0x3c>
c01070f2:	c7 44 24 0c e2 d9 10 	movl   $0xc010d9e2,0xc(%esp)
c01070f9:	c0 
c01070fa:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c0107101:	c0 
c0107102:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0107109:	00 
c010710a:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c0107111:	e8 c4 9c ff ff       	call   c0100dda <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0107116:	b8 10 10 00 00       	mov    $0x1010,%eax
c010711b:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c010711e:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107123:	83 f8 01             	cmp    $0x1,%eax
c0107126:	74 24                	je     c010714c <check_content_set+0x72>
c0107128:	c7 44 24 0c e2 d9 10 	movl   $0xc010d9e2,0xc(%esp)
c010712f:	c0 
c0107130:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c0107137:	c0 
c0107138:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c010713f:	00 
c0107140:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c0107147:	e8 8e 9c ff ff       	call   c0100dda <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c010714c:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107151:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0107154:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107159:	83 f8 02             	cmp    $0x2,%eax
c010715c:	74 24                	je     c0107182 <check_content_set+0xa8>
c010715e:	c7 44 24 0c f1 d9 10 	movl   $0xc010d9f1,0xc(%esp)
c0107165:	c0 
c0107166:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c010716d:	c0 
c010716e:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0107175:	00 
c0107176:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c010717d:	e8 58 9c ff ff       	call   c0100dda <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0107182:	b8 10 20 00 00       	mov    $0x2010,%eax
c0107187:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c010718a:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c010718f:	83 f8 02             	cmp    $0x2,%eax
c0107192:	74 24                	je     c01071b8 <check_content_set+0xde>
c0107194:	c7 44 24 0c f1 d9 10 	movl   $0xc010d9f1,0xc(%esp)
c010719b:	c0 
c010719c:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c01071a3:	c0 
c01071a4:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c01071ab:	00 
c01071ac:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c01071b3:	e8 22 9c ff ff       	call   c0100dda <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c01071b8:	b8 00 30 00 00       	mov    $0x3000,%eax
c01071bd:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01071c0:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c01071c5:	83 f8 03             	cmp    $0x3,%eax
c01071c8:	74 24                	je     c01071ee <check_content_set+0x114>
c01071ca:	c7 44 24 0c 00 da 10 	movl   $0xc010da00,0xc(%esp)
c01071d1:	c0 
c01071d2:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c01071d9:	c0 
c01071da:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c01071e1:	00 
c01071e2:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c01071e9:	e8 ec 9b ff ff       	call   c0100dda <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c01071ee:	b8 10 30 00 00       	mov    $0x3010,%eax
c01071f3:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01071f6:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c01071fb:	83 f8 03             	cmp    $0x3,%eax
c01071fe:	74 24                	je     c0107224 <check_content_set+0x14a>
c0107200:	c7 44 24 0c 00 da 10 	movl   $0xc010da00,0xc(%esp)
c0107207:	c0 
c0107208:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c010720f:	c0 
c0107210:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0107217:	00 
c0107218:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c010721f:	e8 b6 9b ff ff       	call   c0100dda <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0107224:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107229:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c010722c:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107231:	83 f8 04             	cmp    $0x4,%eax
c0107234:	74 24                	je     c010725a <check_content_set+0x180>
c0107236:	c7 44 24 0c 0f da 10 	movl   $0xc010da0f,0xc(%esp)
c010723d:	c0 
c010723e:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c0107245:	c0 
c0107246:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c010724d:	00 
c010724e:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c0107255:	e8 80 9b ff ff       	call   c0100dda <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c010725a:	b8 10 40 00 00       	mov    $0x4010,%eax
c010725f:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0107262:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107267:	83 f8 04             	cmp    $0x4,%eax
c010726a:	74 24                	je     c0107290 <check_content_set+0x1b6>
c010726c:	c7 44 24 0c 0f da 10 	movl   $0xc010da0f,0xc(%esp)
c0107273:	c0 
c0107274:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c010727b:	c0 
c010727c:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0107283:	00 
c0107284:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c010728b:	e8 4a 9b ff ff       	call   c0100dda <__panic>
}
c0107290:	c9                   	leave  
c0107291:	c3                   	ret    

c0107292 <check_content_access>:

static inline int
check_content_access(void)
{
c0107292:	55                   	push   %ebp
c0107293:	89 e5                	mov    %esp,%ebp
c0107295:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0107298:	a1 14 ee 1a c0       	mov    0xc01aee14,%eax
c010729d:	8b 40 1c             	mov    0x1c(%eax),%eax
c01072a0:	ff d0                	call   *%eax
c01072a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c01072a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01072a8:	c9                   	leave  
c01072a9:	c3                   	ret    

c01072aa <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c01072aa:	55                   	push   %ebp
c01072ab:	89 e5                	mov    %esp,%ebp
c01072ad:	53                   	push   %ebx
c01072ae:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c01072b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01072b8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c01072bf:	c7 45 e8 7c 0e 1b c0 	movl   $0xc01b0e7c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01072c6:	eb 6b                	jmp    c0107333 <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c01072c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01072cb:	83 e8 0c             	sub    $0xc,%eax
c01072ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c01072d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01072d4:	83 c0 04             	add    $0x4,%eax
c01072d7:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c01072de:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01072e1:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01072e4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01072e7:	0f a3 10             	bt     %edx,(%eax)
c01072ea:	19 c0                	sbb    %eax,%eax
c01072ec:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c01072ef:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01072f3:	0f 95 c0             	setne  %al
c01072f6:	0f b6 c0             	movzbl %al,%eax
c01072f9:	85 c0                	test   %eax,%eax
c01072fb:	75 24                	jne    c0107321 <check_swap+0x77>
c01072fd:	c7 44 24 0c 1e da 10 	movl   $0xc010da1e,0xc(%esp)
c0107304:	c0 
c0107305:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c010730c:	c0 
c010730d:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c0107314:	00 
c0107315:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c010731c:	e8 b9 9a ff ff       	call   c0100dda <__panic>
        count ++, total += p->property;
c0107321:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107325:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107328:	8b 50 08             	mov    0x8(%eax),%edx
c010732b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010732e:	01 d0                	add    %edx,%eax
c0107330:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107333:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107336:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107339:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010733c:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c010733f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107342:	81 7d e8 7c 0e 1b c0 	cmpl   $0xc01b0e7c,-0x18(%ebp)
c0107349:	0f 85 79 ff ff ff    	jne    c01072c8 <check_swap+0x1e>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c010734f:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0107352:	e8 b3 dd ff ff       	call   c010510a <nr_free_pages>
c0107357:	39 c3                	cmp    %eax,%ebx
c0107359:	74 24                	je     c010737f <check_swap+0xd5>
c010735b:	c7 44 24 0c 2e da 10 	movl   $0xc010da2e,0xc(%esp)
c0107362:	c0 
c0107363:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c010736a:	c0 
c010736b:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0107372:	00 
c0107373:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c010737a:	e8 5b 9a ff ff       	call   c0100dda <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c010737f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107382:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107386:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107389:	89 44 24 04          	mov    %eax,0x4(%esp)
c010738d:	c7 04 24 48 da 10 c0 	movl   $0xc010da48,(%esp)
c0107394:	e8 bf 8f ff ff       	call   c0100358 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0107399:	e8 6e 0b 00 00       	call   c0107f0c <mm_create>
c010739e:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c01073a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01073a5:	75 24                	jne    c01073cb <check_swap+0x121>
c01073a7:	c7 44 24 0c 6e da 10 	movl   $0xc010da6e,0xc(%esp)
c01073ae:	c0 
c01073af:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c01073b6:	c0 
c01073b7:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c01073be:	00 
c01073bf:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c01073c6:	e8 0f 9a ff ff       	call   c0100dda <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c01073cb:	a1 6c 0f 1b c0       	mov    0xc01b0f6c,%eax
c01073d0:	85 c0                	test   %eax,%eax
c01073d2:	74 24                	je     c01073f8 <check_swap+0x14e>
c01073d4:	c7 44 24 0c 79 da 10 	movl   $0xc010da79,0xc(%esp)
c01073db:	c0 
c01073dc:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c01073e3:	c0 
c01073e4:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c01073eb:	00 
c01073ec:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c01073f3:	e8 e2 99 ff ff       	call   c0100dda <__panic>

     check_mm_struct = mm;
c01073f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01073fb:	a3 6c 0f 1b c0       	mov    %eax,0xc01b0f6c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0107400:	8b 15 84 ed 1a c0    	mov    0xc01aed84,%edx
c0107406:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107409:	89 50 0c             	mov    %edx,0xc(%eax)
c010740c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010740f:	8b 40 0c             	mov    0xc(%eax),%eax
c0107412:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c0107415:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107418:	8b 00                	mov    (%eax),%eax
c010741a:	85 c0                	test   %eax,%eax
c010741c:	74 24                	je     c0107442 <check_swap+0x198>
c010741e:	c7 44 24 0c 91 da 10 	movl   $0xc010da91,0xc(%esp)
c0107425:	c0 
c0107426:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c010742d:	c0 
c010742e:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0107435:	00 
c0107436:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c010743d:	e8 98 99 ff ff       	call   c0100dda <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0107442:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0107449:	00 
c010744a:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0107451:	00 
c0107452:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0107459:	e8 47 0b 00 00       	call   c0107fa5 <vma_create>
c010745e:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c0107461:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0107465:	75 24                	jne    c010748b <check_swap+0x1e1>
c0107467:	c7 44 24 0c 9f da 10 	movl   $0xc010da9f,0xc(%esp)
c010746e:	c0 
c010746f:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c0107476:	c0 
c0107477:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c010747e:	00 
c010747f:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c0107486:	e8 4f 99 ff ff       	call   c0100dda <__panic>

     insert_vma_struct(mm, vma);
c010748b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010748e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107492:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107495:	89 04 24             	mov    %eax,(%esp)
c0107498:	e8 98 0c 00 00       	call   c0108135 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c010749d:	c7 04 24 ac da 10 c0 	movl   $0xc010daac,(%esp)
c01074a4:	e8 af 8e ff ff       	call   c0100358 <cprintf>
     pte_t *temp_ptep=NULL;
c01074a9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c01074b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01074b3:	8b 40 0c             	mov    0xc(%eax),%eax
c01074b6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01074bd:	00 
c01074be:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01074c5:	00 
c01074c6:	89 04 24             	mov    %eax,(%esp)
c01074c9:	e8 06 e3 ff ff       	call   c01057d4 <get_pte>
c01074ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c01074d1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c01074d5:	75 24                	jne    c01074fb <check_swap+0x251>
c01074d7:	c7 44 24 0c e0 da 10 	movl   $0xc010dae0,0xc(%esp)
c01074de:	c0 
c01074df:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c01074e6:	c0 
c01074e7:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c01074ee:	00 
c01074ef:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c01074f6:	e8 df 98 ff ff       	call   c0100dda <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c01074fb:	c7 04 24 f4 da 10 c0 	movl   $0xc010daf4,(%esp)
c0107502:	e8 51 8e ff ff       	call   c0100358 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107507:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010750e:	e9 a3 00 00 00       	jmp    c01075b6 <check_swap+0x30c>
          check_rp[i] = alloc_page();
c0107513:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010751a:	e8 4e db ff ff       	call   c010506d <alloc_pages>
c010751f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107522:	89 04 95 a0 0e 1b c0 	mov    %eax,-0x3fe4f160(,%edx,4)
          assert(check_rp[i] != NULL );
c0107529:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010752c:	8b 04 85 a0 0e 1b c0 	mov    -0x3fe4f160(,%eax,4),%eax
c0107533:	85 c0                	test   %eax,%eax
c0107535:	75 24                	jne    c010755b <check_swap+0x2b1>
c0107537:	c7 44 24 0c 18 db 10 	movl   $0xc010db18,0xc(%esp)
c010753e:	c0 
c010753f:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c0107546:	c0 
c0107547:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c010754e:	00 
c010754f:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c0107556:	e8 7f 98 ff ff       	call   c0100dda <__panic>
          assert(!PageProperty(check_rp[i]));
c010755b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010755e:	8b 04 85 a0 0e 1b c0 	mov    -0x3fe4f160(,%eax,4),%eax
c0107565:	83 c0 04             	add    $0x4,%eax
c0107568:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c010756f:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107572:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107575:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0107578:	0f a3 10             	bt     %edx,(%eax)
c010757b:	19 c0                	sbb    %eax,%eax
c010757d:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0107580:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0107584:	0f 95 c0             	setne  %al
c0107587:	0f b6 c0             	movzbl %al,%eax
c010758a:	85 c0                	test   %eax,%eax
c010758c:	74 24                	je     c01075b2 <check_swap+0x308>
c010758e:	c7 44 24 0c 2c db 10 	movl   $0xc010db2c,0xc(%esp)
c0107595:	c0 
c0107596:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c010759d:	c0 
c010759e:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01075a5:	00 
c01075a6:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c01075ad:	e8 28 98 ff ff       	call   c0100dda <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01075b2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01075b6:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01075ba:	0f 8e 53 ff ff ff    	jle    c0107513 <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c01075c0:	a1 7c 0e 1b c0       	mov    0xc01b0e7c,%eax
c01075c5:	8b 15 80 0e 1b c0    	mov    0xc01b0e80,%edx
c01075cb:	89 45 98             	mov    %eax,-0x68(%ebp)
c01075ce:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01075d1:	c7 45 a8 7c 0e 1b c0 	movl   $0xc01b0e7c,-0x58(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01075d8:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01075db:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01075de:	89 50 04             	mov    %edx,0x4(%eax)
c01075e1:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01075e4:	8b 50 04             	mov    0x4(%eax),%edx
c01075e7:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01075ea:	89 10                	mov    %edx,(%eax)
c01075ec:	c7 45 a4 7c 0e 1b c0 	movl   $0xc01b0e7c,-0x5c(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01075f3:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01075f6:	8b 40 04             	mov    0x4(%eax),%eax
c01075f9:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c01075fc:	0f 94 c0             	sete   %al
c01075ff:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0107602:	85 c0                	test   %eax,%eax
c0107604:	75 24                	jne    c010762a <check_swap+0x380>
c0107606:	c7 44 24 0c 47 db 10 	movl   $0xc010db47,0xc(%esp)
c010760d:	c0 
c010760e:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c0107615:	c0 
c0107616:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c010761d:	00 
c010761e:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c0107625:	e8 b0 97 ff ff       	call   c0100dda <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c010762a:	a1 84 0e 1b c0       	mov    0xc01b0e84,%eax
c010762f:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c0107632:	c7 05 84 0e 1b c0 00 	movl   $0x0,0xc01b0e84
c0107639:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010763c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107643:	eb 1e                	jmp    c0107663 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c0107645:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107648:	8b 04 85 a0 0e 1b c0 	mov    -0x3fe4f160(,%eax,4),%eax
c010764f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107656:	00 
c0107657:	89 04 24             	mov    %eax,(%esp)
c010765a:	e8 79 da ff ff       	call   c01050d8 <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010765f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107663:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107667:	7e dc                	jle    c0107645 <check_swap+0x39b>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0107669:	a1 84 0e 1b c0       	mov    0xc01b0e84,%eax
c010766e:	83 f8 04             	cmp    $0x4,%eax
c0107671:	74 24                	je     c0107697 <check_swap+0x3ed>
c0107673:	c7 44 24 0c 60 db 10 	movl   $0xc010db60,0xc(%esp)
c010767a:	c0 
c010767b:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c0107682:	c0 
c0107683:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c010768a:	00 
c010768b:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c0107692:	e8 43 97 ff ff       	call   c0100dda <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0107697:	c7 04 24 84 db 10 c0 	movl   $0xc010db84,(%esp)
c010769e:	e8 b5 8c ff ff       	call   c0100358 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c01076a3:	c7 05 18 ee 1a c0 00 	movl   $0x0,0xc01aee18
c01076aa:	00 00 00 
     
     check_content_set();
c01076ad:	e8 28 fa ff ff       	call   c01070da <check_content_set>
     assert( nr_free == 0);         
c01076b2:	a1 84 0e 1b c0       	mov    0xc01b0e84,%eax
c01076b7:	85 c0                	test   %eax,%eax
c01076b9:	74 24                	je     c01076df <check_swap+0x435>
c01076bb:	c7 44 24 0c ab db 10 	movl   $0xc010dbab,0xc(%esp)
c01076c2:	c0 
c01076c3:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c01076ca:	c0 
c01076cb:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c01076d2:	00 
c01076d3:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c01076da:	e8 fb 96 ff ff       	call   c0100dda <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01076df:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01076e6:	eb 26                	jmp    c010770e <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c01076e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01076eb:	c7 04 85 c0 0e 1b c0 	movl   $0xffffffff,-0x3fe4f140(,%eax,4)
c01076f2:	ff ff ff ff 
c01076f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01076f9:	8b 14 85 c0 0e 1b c0 	mov    -0x3fe4f140(,%eax,4),%edx
c0107700:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107703:	89 14 85 00 0f 1b c0 	mov    %edx,-0x3fe4f100(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010770a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010770e:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0107712:	7e d4                	jle    c01076e8 <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107714:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010771b:	e9 eb 00 00 00       	jmp    c010780b <check_swap+0x561>
         check_ptep[i]=0;
c0107720:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107723:	c7 04 85 54 0f 1b c0 	movl   $0x0,-0x3fe4f0ac(,%eax,4)
c010772a:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c010772e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107731:	83 c0 01             	add    $0x1,%eax
c0107734:	c1 e0 0c             	shl    $0xc,%eax
c0107737:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010773e:	00 
c010773f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107743:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107746:	89 04 24             	mov    %eax,(%esp)
c0107749:	e8 86 e0 ff ff       	call   c01057d4 <get_pte>
c010774e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107751:	89 04 95 54 0f 1b c0 	mov    %eax,-0x3fe4f0ac(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0107758:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010775b:	8b 04 85 54 0f 1b c0 	mov    -0x3fe4f0ac(,%eax,4),%eax
c0107762:	85 c0                	test   %eax,%eax
c0107764:	75 24                	jne    c010778a <check_swap+0x4e0>
c0107766:	c7 44 24 0c b8 db 10 	movl   $0xc010dbb8,0xc(%esp)
c010776d:	c0 
c010776e:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c0107775:	c0 
c0107776:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c010777d:	00 
c010777e:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c0107785:	e8 50 96 ff ff       	call   c0100dda <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c010778a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010778d:	8b 04 85 54 0f 1b c0 	mov    -0x3fe4f0ac(,%eax,4),%eax
c0107794:	8b 00                	mov    (%eax),%eax
c0107796:	89 04 24             	mov    %eax,(%esp)
c0107799:	e8 87 f5 ff ff       	call   c0106d25 <pte2page>
c010779e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01077a1:	8b 14 95 a0 0e 1b c0 	mov    -0x3fe4f160(,%edx,4),%edx
c01077a8:	39 d0                	cmp    %edx,%eax
c01077aa:	74 24                	je     c01077d0 <check_swap+0x526>
c01077ac:	c7 44 24 0c d0 db 10 	movl   $0xc010dbd0,0xc(%esp)
c01077b3:	c0 
c01077b4:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c01077bb:	c0 
c01077bc:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c01077c3:	00 
c01077c4:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c01077cb:	e8 0a 96 ff ff       	call   c0100dda <__panic>
         assert((*check_ptep[i] & PTE_P));          
c01077d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01077d3:	8b 04 85 54 0f 1b c0 	mov    -0x3fe4f0ac(,%eax,4),%eax
c01077da:	8b 00                	mov    (%eax),%eax
c01077dc:	83 e0 01             	and    $0x1,%eax
c01077df:	85 c0                	test   %eax,%eax
c01077e1:	75 24                	jne    c0107807 <check_swap+0x55d>
c01077e3:	c7 44 24 0c f8 db 10 	movl   $0xc010dbf8,0xc(%esp)
c01077ea:	c0 
c01077eb:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c01077f2:	c0 
c01077f3:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c01077fa:	00 
c01077fb:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c0107802:	e8 d3 95 ff ff       	call   c0100dda <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107807:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010780b:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010780f:	0f 8e 0b ff ff ff    	jle    c0107720 <check_swap+0x476>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c0107815:	c7 04 24 14 dc 10 c0 	movl   $0xc010dc14,(%esp)
c010781c:	e8 37 8b ff ff       	call   c0100358 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0107821:	e8 6c fa ff ff       	call   c0107292 <check_content_access>
c0107826:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c0107829:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010782d:	74 24                	je     c0107853 <check_swap+0x5a9>
c010782f:	c7 44 24 0c 3a dc 10 	movl   $0xc010dc3a,0xc(%esp)
c0107836:	c0 
c0107837:	c7 44 24 08 22 d9 10 	movl   $0xc010d922,0x8(%esp)
c010783e:	c0 
c010783f:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0107846:	00 
c0107847:	c7 04 24 bc d8 10 c0 	movl   $0xc010d8bc,(%esp)
c010784e:	e8 87 95 ff ff       	call   c0100dda <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107853:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010785a:	eb 1e                	jmp    c010787a <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c010785c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010785f:	8b 04 85 a0 0e 1b c0 	mov    -0x3fe4f160(,%eax,4),%eax
c0107866:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010786d:	00 
c010786e:	89 04 24             	mov    %eax,(%esp)
c0107871:	e8 62 d8 ff ff       	call   c01050d8 <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107876:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010787a:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010787e:	7e dc                	jle    c010785c <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
    free_page(pde2page(pgdir[0]));
c0107880:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107883:	8b 00                	mov    (%eax),%eax
c0107885:	89 04 24             	mov    %eax,(%esp)
c0107888:	e8 d6 f4 ff ff       	call   c0106d63 <pde2page>
c010788d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107894:	00 
c0107895:	89 04 24             	mov    %eax,(%esp)
c0107898:	e8 3b d8 ff ff       	call   c01050d8 <free_pages>
     pgdir[0] = 0;
c010789d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01078a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     mm->pgdir = NULL;
c01078a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01078a9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     mm_destroy(mm);
c01078b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01078b3:	89 04 24             	mov    %eax,(%esp)
c01078b6:	e8 aa 09 00 00       	call   c0108265 <mm_destroy>
     check_mm_struct = NULL;
c01078bb:	c7 05 6c 0f 1b c0 00 	movl   $0x0,0xc01b0f6c
c01078c2:	00 00 00 
     
     nr_free = nr_free_store;
c01078c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01078c8:	a3 84 0e 1b c0       	mov    %eax,0xc01b0e84
     free_list = free_list_store;
c01078cd:	8b 45 98             	mov    -0x68(%ebp),%eax
c01078d0:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01078d3:	a3 7c 0e 1b c0       	mov    %eax,0xc01b0e7c
c01078d8:	89 15 80 0e 1b c0    	mov    %edx,0xc01b0e80

     
     le = &free_list;
c01078de:	c7 45 e8 7c 0e 1b c0 	movl   $0xc01b0e7c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01078e5:	eb 1d                	jmp    c0107904 <check_swap+0x65a>
         struct Page *p = le2page(le, page_link);
c01078e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01078ea:	83 e8 0c             	sub    $0xc,%eax
c01078ed:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c01078f0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01078f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01078f7:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01078fa:	8b 40 08             	mov    0x8(%eax),%eax
c01078fd:	29 c2                	sub    %eax,%edx
c01078ff:	89 d0                	mov    %edx,%eax
c0107901:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107904:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107907:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010790a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010790d:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0107910:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107913:	81 7d e8 7c 0e 1b c0 	cmpl   $0xc01b0e7c,-0x18(%ebp)
c010791a:	75 cb                	jne    c01078e7 <check_swap+0x63d>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c010791c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010791f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107923:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107926:	89 44 24 04          	mov    %eax,0x4(%esp)
c010792a:	c7 04 24 41 dc 10 c0 	movl   $0xc010dc41,(%esp)
c0107931:	e8 22 8a ff ff       	call   c0100358 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0107936:	c7 04 24 5b dc 10 c0 	movl   $0xc010dc5b,(%esp)
c010793d:	e8 16 8a ff ff       	call   c0100358 <cprintf>
}
c0107942:	83 c4 74             	add    $0x74,%esp
c0107945:	5b                   	pop    %ebx
c0107946:	5d                   	pop    %ebp
c0107947:	c3                   	ret    

c0107948 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0107948:	55                   	push   %ebp
c0107949:	89 e5                	mov    %esp,%ebp
c010794b:	83 ec 10             	sub    $0x10,%esp
c010794e:	c7 45 fc 64 0f 1b c0 	movl   $0xc01b0f64,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107955:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107958:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010795b:	89 50 04             	mov    %edx,0x4(%eax)
c010795e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107961:	8b 50 04             	mov    0x4(%eax),%edx
c0107964:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107967:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0107969:	8b 45 08             	mov    0x8(%ebp),%eax
c010796c:	c7 40 14 64 0f 1b c0 	movl   $0xc01b0f64,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0107973:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107978:	c9                   	leave  
c0107979:	c3                   	ret    

c010797a <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c010797a:	55                   	push   %ebp
c010797b:	89 e5                	mov    %esp,%ebp
c010797d:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107980:	8b 45 08             	mov    0x8(%ebp),%eax
c0107983:	8b 40 14             	mov    0x14(%eax),%eax
c0107986:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0107989:	8b 45 10             	mov    0x10(%ebp),%eax
c010798c:	83 c0 14             	add    $0x14,%eax
c010798f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0107992:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107996:	74 06                	je     c010799e <_fifo_map_swappable+0x24>
c0107998:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010799c:	75 24                	jne    c01079c2 <_fifo_map_swappable+0x48>
c010799e:	c7 44 24 0c 74 dc 10 	movl   $0xc010dc74,0xc(%esp)
c01079a5:	c0 
c01079a6:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c01079ad:	c0 
c01079ae:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c01079b5:	00 
c01079b6:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c01079bd:	e8 18 94 ff ff       	call   c0100dda <__panic>
c01079c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01079c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01079ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079d1:	8b 00                	mov    (%eax),%eax
c01079d3:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01079d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01079d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01079dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079df:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01079e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01079e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01079e8:	89 10                	mov    %edx,(%eax)
c01079ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01079ed:	8b 10                	mov    (%eax),%edx
c01079ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01079f2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01079f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01079f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01079fb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01079fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107a01:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107a04:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: 2012012617*/
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
	list_add_before(head, entry);
	return 0;
c0107a06:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107a0b:	c9                   	leave  
c0107a0c:	c3                   	ret    

c0107a0d <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0107a0d:	55                   	push   %ebp
c0107a0e:	89 e5                	mov    %esp,%ebp
c0107a10:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107a13:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a16:	8b 40 14             	mov    0x14(%eax),%eax
c0107a19:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0107a1c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a20:	75 24                	jne    c0107a46 <_fifo_swap_out_victim+0x39>
c0107a22:	c7 44 24 0c bb dc 10 	movl   $0xc010dcbb,0xc(%esp)
c0107a29:	c0 
c0107a2a:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107a31:	c0 
c0107a32:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0107a39:	00 
c0107a3a:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107a41:	e8 94 93 ff ff       	call   c0100dda <__panic>
     assert(in_tick==0);
c0107a46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107a4a:	74 24                	je     c0107a70 <_fifo_swap_out_victim+0x63>
c0107a4c:	c7 44 24 0c c8 dc 10 	movl   $0xc010dcc8,0xc(%esp)
c0107a53:	c0 
c0107a54:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107a5b:	c0 
c0107a5c:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0107a63:	00 
c0107a64:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107a6b:	e8 6a 93 ff ff       	call   c0100dda <__panic>
c0107a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a73:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107a76:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a79:	8b 40 04             	mov    0x4(%eax),%eax
     /* Select the victim */
     /*LAB3 EXERCISE 2: 2012012617*/
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
     list_entry_t *le = list_next(head);
c0107a7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0107a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a82:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107a85:	75 24                	jne    c0107aab <_fifo_swap_out_victim+0x9e>
c0107a87:	c7 44 24 0c d3 dc 10 	movl   $0xc010dcd3,0xc(%esp)
c0107a8e:	c0 
c0107a8f:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107a96:	c0 
c0107a97:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c0107a9e:	00 
c0107a9f:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107aa6:	e8 2f 93 ff ff       	call   c0100dda <__panic>
     struct Page *p = le2page(le, pra_page_link);
c0107aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107aae:	83 e8 14             	sub    $0x14,%eax
c0107ab1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ab7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0107aba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107abd:	8b 40 04             	mov    0x4(%eax),%eax
c0107ac0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107ac3:	8b 12                	mov    (%edx),%edx
c0107ac5:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0107ac8:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0107acb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107ace:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107ad1:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107ad4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ad7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107ada:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c0107adc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107ae0:	75 24                	jne    c0107b06 <_fifo_swap_out_victim+0xf9>
c0107ae2:	c7 44 24 0c dc dc 10 	movl   $0xc010dcdc,0xc(%esp)
c0107ae9:	c0 
c0107aea:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107af1:	c0 
c0107af2:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
c0107af9:	00 
c0107afa:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107b01:	e8 d4 92 ff ff       	call   c0100dda <__panic>
     *ptr_page = p;
c0107b06:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b09:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107b0c:	89 10                	mov    %edx,(%eax)
     return 0;
c0107b0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107b13:	c9                   	leave  
c0107b14:	c3                   	ret    

c0107b15 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0107b15:	55                   	push   %ebp
c0107b16:	89 e5                	mov    %esp,%ebp
c0107b18:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107b1b:	c7 04 24 e8 dc 10 c0 	movl   $0xc010dce8,(%esp)
c0107b22:	e8 31 88 ff ff       	call   c0100358 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107b27:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107b2c:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0107b2f:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107b34:	83 f8 04             	cmp    $0x4,%eax
c0107b37:	74 24                	je     c0107b5d <_fifo_check_swap+0x48>
c0107b39:	c7 44 24 0c 0e dd 10 	movl   $0xc010dd0e,0xc(%esp)
c0107b40:	c0 
c0107b41:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107b48:	c0 
c0107b49:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
c0107b50:	00 
c0107b51:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107b58:	e8 7d 92 ff ff       	call   c0100dda <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107b5d:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107b64:	e8 ef 87 ff ff       	call   c0100358 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107b69:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107b6e:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0107b71:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107b76:	83 f8 04             	cmp    $0x4,%eax
c0107b79:	74 24                	je     c0107b9f <_fifo_check_swap+0x8a>
c0107b7b:	c7 44 24 0c 0e dd 10 	movl   $0xc010dd0e,0xc(%esp)
c0107b82:	c0 
c0107b83:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107b8a:	c0 
c0107b8b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
c0107b92:	00 
c0107b93:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107b9a:	e8 3b 92 ff ff       	call   c0100dda <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107b9f:	c7 04 24 48 dd 10 c0 	movl   $0xc010dd48,(%esp)
c0107ba6:	e8 ad 87 ff ff       	call   c0100358 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107bab:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107bb0:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0107bb3:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107bb8:	83 f8 04             	cmp    $0x4,%eax
c0107bbb:	74 24                	je     c0107be1 <_fifo_check_swap+0xcc>
c0107bbd:	c7 44 24 0c 0e dd 10 	movl   $0xc010dd0e,0xc(%esp)
c0107bc4:	c0 
c0107bc5:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107bcc:	c0 
c0107bcd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0107bd4:	00 
c0107bd5:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107bdc:	e8 f9 91 ff ff       	call   c0100dda <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107be1:	c7 04 24 70 dd 10 c0 	movl   $0xc010dd70,(%esp)
c0107be8:	e8 6b 87 ff ff       	call   c0100358 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107bed:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107bf2:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0107bf5:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107bfa:	83 f8 04             	cmp    $0x4,%eax
c0107bfd:	74 24                	je     c0107c23 <_fifo_check_swap+0x10e>
c0107bff:	c7 44 24 0c 0e dd 10 	movl   $0xc010dd0e,0xc(%esp)
c0107c06:	c0 
c0107c07:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107c0e:	c0 
c0107c0f:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
c0107c16:	00 
c0107c17:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107c1e:	e8 b7 91 ff ff       	call   c0100dda <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107c23:	c7 04 24 98 dd 10 c0 	movl   $0xc010dd98,(%esp)
c0107c2a:	e8 29 87 ff ff       	call   c0100358 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107c2f:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107c34:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0107c37:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107c3c:	83 f8 05             	cmp    $0x5,%eax
c0107c3f:	74 24                	je     c0107c65 <_fifo_check_swap+0x150>
c0107c41:	c7 44 24 0c be dd 10 	movl   $0xc010ddbe,0xc(%esp)
c0107c48:	c0 
c0107c49:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107c50:	c0 
c0107c51:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
c0107c58:	00 
c0107c59:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107c60:	e8 75 91 ff ff       	call   c0100dda <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107c65:	c7 04 24 70 dd 10 c0 	movl   $0xc010dd70,(%esp)
c0107c6c:	e8 e7 86 ff ff       	call   c0100358 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107c71:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107c76:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0107c79:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107c7e:	83 f8 05             	cmp    $0x5,%eax
c0107c81:	74 24                	je     c0107ca7 <_fifo_check_swap+0x192>
c0107c83:	c7 44 24 0c be dd 10 	movl   $0xc010ddbe,0xc(%esp)
c0107c8a:	c0 
c0107c8b:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107c92:	c0 
c0107c93:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c0107c9a:	00 
c0107c9b:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107ca2:	e8 33 91 ff ff       	call   c0100dda <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107ca7:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107cae:	e8 a5 86 ff ff       	call   c0100358 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107cb3:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107cb8:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0107cbb:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107cc0:	83 f8 06             	cmp    $0x6,%eax
c0107cc3:	74 24                	je     c0107ce9 <_fifo_check_swap+0x1d4>
c0107cc5:	c7 44 24 0c cd dd 10 	movl   $0xc010ddcd,0xc(%esp)
c0107ccc:	c0 
c0107ccd:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107cd4:	c0 
c0107cd5:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0107cdc:	00 
c0107cdd:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107ce4:	e8 f1 90 ff ff       	call   c0100dda <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107ce9:	c7 04 24 70 dd 10 c0 	movl   $0xc010dd70,(%esp)
c0107cf0:	e8 63 86 ff ff       	call   c0100358 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107cf5:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107cfa:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0107cfd:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107d02:	83 f8 07             	cmp    $0x7,%eax
c0107d05:	74 24                	je     c0107d2b <_fifo_check_swap+0x216>
c0107d07:	c7 44 24 0c dc dd 10 	movl   $0xc010dddc,0xc(%esp)
c0107d0e:	c0 
c0107d0f:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107d16:	c0 
c0107d17:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0107d1e:	00 
c0107d1f:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107d26:	e8 af 90 ff ff       	call   c0100dda <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107d2b:	c7 04 24 e8 dc 10 c0 	movl   $0xc010dce8,(%esp)
c0107d32:	e8 21 86 ff ff       	call   c0100358 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107d37:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107d3c:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0107d3f:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107d44:	83 f8 08             	cmp    $0x8,%eax
c0107d47:	74 24                	je     c0107d6d <_fifo_check_swap+0x258>
c0107d49:	c7 44 24 0c eb dd 10 	movl   $0xc010ddeb,0xc(%esp)
c0107d50:	c0 
c0107d51:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107d58:	c0 
c0107d59:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0107d60:	00 
c0107d61:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107d68:	e8 6d 90 ff ff       	call   c0100dda <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107d6d:	c7 04 24 48 dd 10 c0 	movl   $0xc010dd48,(%esp)
c0107d74:	e8 df 85 ff ff       	call   c0100358 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107d79:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107d7e:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0107d81:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107d86:	83 f8 09             	cmp    $0x9,%eax
c0107d89:	74 24                	je     c0107daf <_fifo_check_swap+0x29a>
c0107d8b:	c7 44 24 0c fa dd 10 	movl   $0xc010ddfa,0xc(%esp)
c0107d92:	c0 
c0107d93:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107d9a:	c0 
c0107d9b:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c0107da2:	00 
c0107da3:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107daa:	e8 2b 90 ff ff       	call   c0100dda <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107daf:	c7 04 24 98 dd 10 c0 	movl   $0xc010dd98,(%esp)
c0107db6:	e8 9d 85 ff ff       	call   c0100358 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107dbb:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107dc0:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0107dc3:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107dc8:	83 f8 0a             	cmp    $0xa,%eax
c0107dcb:	74 24                	je     c0107df1 <_fifo_check_swap+0x2dc>
c0107dcd:	c7 44 24 0c 09 de 10 	movl   $0xc010de09,0xc(%esp)
c0107dd4:	c0 
c0107dd5:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107ddc:	c0 
c0107ddd:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c0107de4:	00 
c0107de5:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107dec:	e8 e9 8f ff ff       	call   c0100dda <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107df1:	c7 04 24 20 dd 10 c0 	movl   $0xc010dd20,(%esp)
c0107df8:	e8 5b 85 ff ff       	call   c0100358 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0107dfd:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107e02:	0f b6 00             	movzbl (%eax),%eax
c0107e05:	3c 0a                	cmp    $0xa,%al
c0107e07:	74 24                	je     c0107e2d <_fifo_check_swap+0x318>
c0107e09:	c7 44 24 0c 1c de 10 	movl   $0xc010de1c,0xc(%esp)
c0107e10:	c0 
c0107e11:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107e18:	c0 
c0107e19:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0107e20:	00 
c0107e21:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107e28:	e8 ad 8f ff ff       	call   c0100dda <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0107e2d:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107e32:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0107e35:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0107e3a:	83 f8 0b             	cmp    $0xb,%eax
c0107e3d:	74 24                	je     c0107e63 <_fifo_check_swap+0x34e>
c0107e3f:	c7 44 24 0c 3d de 10 	movl   $0xc010de3d,0xc(%esp)
c0107e46:	c0 
c0107e47:	c7 44 24 08 92 dc 10 	movl   $0xc010dc92,0x8(%esp)
c0107e4e:	c0 
c0107e4f:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c0107e56:	00 
c0107e57:	c7 04 24 a7 dc 10 c0 	movl   $0xc010dca7,(%esp)
c0107e5e:	e8 77 8f ff ff       	call   c0100dda <__panic>
    return 0;
c0107e63:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107e68:	c9                   	leave  
c0107e69:	c3                   	ret    

c0107e6a <_fifo_init>:


static int
_fifo_init(void)
{
c0107e6a:	55                   	push   %ebp
c0107e6b:	89 e5                	mov    %esp,%ebp
    return 0;
c0107e6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107e72:	5d                   	pop    %ebp
c0107e73:	c3                   	ret    

c0107e74 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0107e74:	55                   	push   %ebp
c0107e75:	89 e5                	mov    %esp,%ebp
    return 0;
c0107e77:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107e7c:	5d                   	pop    %ebp
c0107e7d:	c3                   	ret    

c0107e7e <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0107e7e:	55                   	push   %ebp
c0107e7f:	89 e5                	mov    %esp,%ebp
c0107e81:	b8 00 00 00 00       	mov    $0x0,%eax
c0107e86:	5d                   	pop    %ebp
c0107e87:	c3                   	ret    

c0107e88 <lock_init>:
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
c0107e88:	55                   	push   %ebp
c0107e89:	89 e5                	mov    %esp,%ebp
    *lock = 0;
c0107e8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
c0107e94:	5d                   	pop    %ebp
c0107e95:	c3                   	ret    

c0107e96 <mm_count>:
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm) {
c0107e96:	55                   	push   %ebp
c0107e97:	89 e5                	mov    %esp,%ebp
    return mm->mm_count;
c0107e99:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e9c:	8b 40 18             	mov    0x18(%eax),%eax
}
c0107e9f:	5d                   	pop    %ebp
c0107ea0:	c3                   	ret    

c0107ea1 <set_mm_count>:

static inline void
set_mm_count(struct mm_struct *mm, int val) {
c0107ea1:	55                   	push   %ebp
c0107ea2:	89 e5                	mov    %esp,%ebp
    mm->mm_count = val;
c0107ea4:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ea7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107eaa:	89 50 18             	mov    %edx,0x18(%eax)
}
c0107ead:	5d                   	pop    %ebp
c0107eae:	c3                   	ret    

c0107eaf <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0107eaf:	55                   	push   %ebp
c0107eb0:	89 e5                	mov    %esp,%ebp
c0107eb2:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0107eb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0107eb8:	c1 e8 0c             	shr    $0xc,%eax
c0107ebb:	89 c2                	mov    %eax,%edx
c0107ebd:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c0107ec2:	39 c2                	cmp    %eax,%edx
c0107ec4:	72 1c                	jb     c0107ee2 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0107ec6:	c7 44 24 08 60 de 10 	movl   $0xc010de60,0x8(%esp)
c0107ecd:	c0 
c0107ece:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0107ed5:	00 
c0107ed6:	c7 04 24 7f de 10 c0 	movl   $0xc010de7f,(%esp)
c0107edd:	e8 f8 8e ff ff       	call   c0100dda <__panic>
    }
    return &pages[PPN(pa)];
c0107ee2:	a1 90 0e 1b c0       	mov    0xc01b0e90,%eax
c0107ee7:	8b 55 08             	mov    0x8(%ebp),%edx
c0107eea:	c1 ea 0c             	shr    $0xc,%edx
c0107eed:	c1 e2 05             	shl    $0x5,%edx
c0107ef0:	01 d0                	add    %edx,%eax
}
c0107ef2:	c9                   	leave  
c0107ef3:	c3                   	ret    

c0107ef4 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0107ef4:	55                   	push   %ebp
c0107ef5:	89 e5                	mov    %esp,%ebp
c0107ef7:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0107efa:	8b 45 08             	mov    0x8(%ebp),%eax
c0107efd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107f02:	89 04 24             	mov    %eax,(%esp)
c0107f05:	e8 a5 ff ff ff       	call   c0107eaf <pa2page>
}
c0107f0a:	c9                   	leave  
c0107f0b:	c3                   	ret    

c0107f0c <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0107f0c:	55                   	push   %ebp
c0107f0d:	89 e5                	mov    %esp,%ebp
c0107f0f:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0107f12:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0107f19:	e8 da cc ff ff       	call   c0104bf8 <kmalloc>
c0107f1e:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0107f21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107f25:	74 79                	je     c0107fa0 <mm_create+0x94>
        list_init(&(mm->mmap_list));
c0107f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f30:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107f33:	89 50 04             	mov    %edx,0x4(%eax)
c0107f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f39:	8b 50 04             	mov    0x4(%eax),%edx
c0107f3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f3f:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0107f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f44:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0107f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f4e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0107f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f58:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0107f5f:	a1 0c ee 1a c0       	mov    0xc01aee0c,%eax
c0107f64:	85 c0                	test   %eax,%eax
c0107f66:	74 0d                	je     c0107f75 <mm_create+0x69>
c0107f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f6b:	89 04 24             	mov    %eax,(%esp)
c0107f6e:	e8 98 ee ff ff       	call   c0106e0b <swap_init_mm>
c0107f73:	eb 0a                	jmp    c0107f7f <mm_create+0x73>
        else mm->sm_priv = NULL;
c0107f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f78:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        
        set_mm_count(mm, 0);
c0107f7f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107f86:	00 
c0107f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f8a:	89 04 24             	mov    %eax,(%esp)
c0107f8d:	e8 0f ff ff ff       	call   c0107ea1 <set_mm_count>
        lock_init(&(mm->mm_lock));
c0107f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f95:	83 c0 1c             	add    $0x1c,%eax
c0107f98:	89 04 24             	mov    %eax,(%esp)
c0107f9b:	e8 e8 fe ff ff       	call   c0107e88 <lock_init>
    }    
    return mm;
c0107fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107fa3:	c9                   	leave  
c0107fa4:	c3                   	ret    

c0107fa5 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0107fa5:	55                   	push   %ebp
c0107fa6:	89 e5                	mov    %esp,%ebp
c0107fa8:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0107fab:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0107fb2:	e8 41 cc ff ff       	call   c0104bf8 <kmalloc>
c0107fb7:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0107fba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107fbe:	74 1b                	je     c0107fdb <vma_create+0x36>
        vma->vm_start = vm_start;
c0107fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fc3:	8b 55 08             	mov    0x8(%ebp),%edx
c0107fc6:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0107fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fcc:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107fcf:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0107fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fd5:	8b 55 10             	mov    0x10(%ebp),%edx
c0107fd8:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0107fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107fde:	c9                   	leave  
c0107fdf:	c3                   	ret    

c0107fe0 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0107fe0:	55                   	push   %ebp
c0107fe1:	89 e5                	mov    %esp,%ebp
c0107fe3:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0107fe6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0107fed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107ff1:	0f 84 95 00 00 00    	je     c010808c <find_vma+0xac>
        vma = mm->mmap_cache;
c0107ff7:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ffa:	8b 40 08             	mov    0x8(%eax),%eax
c0107ffd:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0108000:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108004:	74 16                	je     c010801c <find_vma+0x3c>
c0108006:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108009:	8b 40 04             	mov    0x4(%eax),%eax
c010800c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010800f:	77 0b                	ja     c010801c <find_vma+0x3c>
c0108011:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108014:	8b 40 08             	mov    0x8(%eax),%eax
c0108017:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010801a:	77 61                	ja     c010807d <find_vma+0x9d>
                bool found = 0;
c010801c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0108023:	8b 45 08             	mov    0x8(%ebp),%eax
c0108026:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108029:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010802c:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c010802f:	eb 28                	jmp    c0108059 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0108031:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108034:	83 e8 10             	sub    $0x10,%eax
c0108037:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c010803a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010803d:	8b 40 04             	mov    0x4(%eax),%eax
c0108040:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108043:	77 14                	ja     c0108059 <find_vma+0x79>
c0108045:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108048:	8b 40 08             	mov    0x8(%eax),%eax
c010804b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010804e:	76 09                	jbe    c0108059 <find_vma+0x79>
                        found = 1;
c0108050:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0108057:	eb 17                	jmp    c0108070 <find_vma+0x90>
c0108059:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010805c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010805f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108062:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c0108065:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108068:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010806b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010806e:	75 c1                	jne    c0108031 <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c0108070:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0108074:	75 07                	jne    c010807d <find_vma+0x9d>
                    vma = NULL;
c0108076:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c010807d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108081:	74 09                	je     c010808c <find_vma+0xac>
            mm->mmap_cache = vma;
c0108083:	8b 45 08             	mov    0x8(%ebp),%eax
c0108086:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0108089:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c010808c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010808f:	c9                   	leave  
c0108090:	c3                   	ret    

c0108091 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0108091:	55                   	push   %ebp
c0108092:	89 e5                	mov    %esp,%ebp
c0108094:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0108097:	8b 45 08             	mov    0x8(%ebp),%eax
c010809a:	8b 50 04             	mov    0x4(%eax),%edx
c010809d:	8b 45 08             	mov    0x8(%ebp),%eax
c01080a0:	8b 40 08             	mov    0x8(%eax),%eax
c01080a3:	39 c2                	cmp    %eax,%edx
c01080a5:	72 24                	jb     c01080cb <check_vma_overlap+0x3a>
c01080a7:	c7 44 24 0c 8d de 10 	movl   $0xc010de8d,0xc(%esp)
c01080ae:	c0 
c01080af:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c01080b6:	c0 
c01080b7:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01080be:	00 
c01080bf:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c01080c6:	e8 0f 8d ff ff       	call   c0100dda <__panic>
    assert(prev->vm_end <= next->vm_start);
c01080cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01080ce:	8b 50 08             	mov    0x8(%eax),%edx
c01080d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080d4:	8b 40 04             	mov    0x4(%eax),%eax
c01080d7:	39 c2                	cmp    %eax,%edx
c01080d9:	76 24                	jbe    c01080ff <check_vma_overlap+0x6e>
c01080db:	c7 44 24 0c d0 de 10 	movl   $0xc010ded0,0xc(%esp)
c01080e2:	c0 
c01080e3:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c01080ea:	c0 
c01080eb:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c01080f2:	00 
c01080f3:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c01080fa:	e8 db 8c ff ff       	call   c0100dda <__panic>
    assert(next->vm_start < next->vm_end);
c01080ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108102:	8b 50 04             	mov    0x4(%eax),%edx
c0108105:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108108:	8b 40 08             	mov    0x8(%eax),%eax
c010810b:	39 c2                	cmp    %eax,%edx
c010810d:	72 24                	jb     c0108133 <check_vma_overlap+0xa2>
c010810f:	c7 44 24 0c ef de 10 	movl   $0xc010deef,0xc(%esp)
c0108116:	c0 
c0108117:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c010811e:	c0 
c010811f:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0108126:	00 
c0108127:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c010812e:	e8 a7 8c ff ff       	call   c0100dda <__panic>
}
c0108133:	c9                   	leave  
c0108134:	c3                   	ret    

c0108135 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0108135:	55                   	push   %ebp
c0108136:	89 e5                	mov    %esp,%ebp
c0108138:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c010813b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010813e:	8b 50 04             	mov    0x4(%eax),%edx
c0108141:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108144:	8b 40 08             	mov    0x8(%eax),%eax
c0108147:	39 c2                	cmp    %eax,%edx
c0108149:	72 24                	jb     c010816f <insert_vma_struct+0x3a>
c010814b:	c7 44 24 0c 0d df 10 	movl   $0xc010df0d,0xc(%esp)
c0108152:	c0 
c0108153:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c010815a:	c0 
c010815b:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0108162:	00 
c0108163:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c010816a:	e8 6b 8c ff ff       	call   c0100dda <__panic>
    list_entry_t *list = &(mm->mmap_list);
c010816f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108172:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0108175:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108178:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c010817b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010817e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0108181:	eb 21                	jmp    c01081a4 <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0108183:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108186:	83 e8 10             	sub    $0x10,%eax
c0108189:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c010818c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010818f:	8b 50 04             	mov    0x4(%eax),%edx
c0108192:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108195:	8b 40 04             	mov    0x4(%eax),%eax
c0108198:	39 c2                	cmp    %eax,%edx
c010819a:	76 02                	jbe    c010819e <insert_vma_struct+0x69>
                break;
c010819c:	eb 1d                	jmp    c01081bb <insert_vma_struct+0x86>
            }
            le_prev = le;
c010819e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01081a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01081aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01081ad:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c01081b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01081b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081b6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01081b9:	75 c8                	jne    c0108183 <insert_vma_struct+0x4e>
c01081bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081be:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01081c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01081c4:	8b 40 04             	mov    0x4(%eax),%eax
                break;
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c01081c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c01081ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081cd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01081d0:	74 15                	je     c01081e7 <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c01081d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081d5:	8d 50 f0             	lea    -0x10(%eax),%edx
c01081d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081df:	89 14 24             	mov    %edx,(%esp)
c01081e2:	e8 aa fe ff ff       	call   c0108091 <check_vma_overlap>
    }
    if (le_next != list) {
c01081e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01081ea:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01081ed:	74 15                	je     c0108204 <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c01081ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01081f2:	83 e8 10             	sub    $0x10,%eax
c01081f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081fc:	89 04 24             	mov    %eax,(%esp)
c01081ff:	e8 8d fe ff ff       	call   c0108091 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0108204:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108207:	8b 55 08             	mov    0x8(%ebp),%edx
c010820a:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c010820c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010820f:	8d 50 10             	lea    0x10(%eax),%edx
c0108212:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108215:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108218:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010821b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010821e:	8b 40 04             	mov    0x4(%eax),%eax
c0108221:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108224:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0108227:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010822a:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010822d:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0108230:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108233:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108236:	89 10                	mov    %edx,(%eax)
c0108238:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010823b:	8b 10                	mov    (%eax),%edx
c010823d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108240:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108243:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108246:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0108249:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010824c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010824f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0108252:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c0108254:	8b 45 08             	mov    0x8(%ebp),%eax
c0108257:	8b 40 10             	mov    0x10(%eax),%eax
c010825a:	8d 50 01             	lea    0x1(%eax),%edx
c010825d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108260:	89 50 10             	mov    %edx,0x10(%eax)
}
c0108263:	c9                   	leave  
c0108264:	c3                   	ret    

c0108265 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0108265:	55                   	push   %ebp
c0108266:	89 e5                	mov    %esp,%ebp
c0108268:	83 ec 38             	sub    $0x38,%esp
    assert(mm_count(mm) == 0);
c010826b:	8b 45 08             	mov    0x8(%ebp),%eax
c010826e:	89 04 24             	mov    %eax,(%esp)
c0108271:	e8 20 fc ff ff       	call   c0107e96 <mm_count>
c0108276:	85 c0                	test   %eax,%eax
c0108278:	74 24                	je     c010829e <mm_destroy+0x39>
c010827a:	c7 44 24 0c 29 df 10 	movl   $0xc010df29,0xc(%esp)
c0108281:	c0 
c0108282:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108289:	c0 
c010828a:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0108291:	00 
c0108292:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108299:	e8 3c 8b ff ff       	call   c0100dda <__panic>

    list_entry_t *list = &(mm->mmap_list), *le;
c010829e:	8b 45 08             	mov    0x8(%ebp),%eax
c01082a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01082a4:	eb 36                	jmp    c01082dc <mm_destroy+0x77>
c01082a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01082a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01082ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01082af:	8b 40 04             	mov    0x4(%eax),%eax
c01082b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01082b5:	8b 12                	mov    (%edx),%edx
c01082b7:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01082ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01082bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01082c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01082c3:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01082c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01082c9:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01082cc:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c01082ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01082d1:	83 e8 10             	sub    $0x10,%eax
c01082d4:	89 04 24             	mov    %eax,(%esp)
c01082d7:	e8 37 c9 ff ff       	call   c0104c13 <kfree>
c01082dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082df:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01082e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01082e5:	8b 40 04             	mov    0x4(%eax),%eax
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c01082e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01082eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01082ee:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01082f1:	75 b3                	jne    c01082a6 <mm_destroy+0x41>
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
    }
    kfree(mm); //kfree mm
c01082f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01082f6:	89 04 24             	mov    %eax,(%esp)
c01082f9:	e8 15 c9 ff ff       	call   c0104c13 <kfree>
    mm=NULL;
c01082fe:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0108305:	c9                   	leave  
c0108306:	c3                   	ret    

c0108307 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
c0108307:	55                   	push   %ebp
c0108308:	89 e5                	mov    %esp,%ebp
c010830a:	83 ec 38             	sub    $0x38,%esp
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
c010830d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108310:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108313:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108316:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010831b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010831e:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
c0108325:	8b 45 10             	mov    0x10(%ebp),%eax
c0108328:	8b 55 0c             	mov    0xc(%ebp),%edx
c010832b:	01 c2                	add    %eax,%edx
c010832d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108330:	01 d0                	add    %edx,%eax
c0108332:	83 e8 01             	sub    $0x1,%eax
c0108335:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108338:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010833b:	ba 00 00 00 00       	mov    $0x0,%edx
c0108340:	f7 75 e8             	divl   -0x18(%ebp)
c0108343:	89 d0                	mov    %edx,%eax
c0108345:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108348:	29 c2                	sub    %eax,%edx
c010834a:	89 d0                	mov    %edx,%eax
c010834c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!USER_ACCESS(start, end)) {
c010834f:	81 7d ec ff ff 1f 00 	cmpl   $0x1fffff,-0x14(%ebp)
c0108356:	76 11                	jbe    c0108369 <mm_map+0x62>
c0108358:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010835b:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010835e:	73 09                	jae    c0108369 <mm_map+0x62>
c0108360:	81 7d e0 00 00 00 b0 	cmpl   $0xb0000000,-0x20(%ebp)
c0108367:	76 0a                	jbe    c0108373 <mm_map+0x6c>
        return -E_INVAL;
c0108369:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010836e:	e9 ae 00 00 00       	jmp    c0108421 <mm_map+0x11a>
    }

    assert(mm != NULL);
c0108373:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108377:	75 24                	jne    c010839d <mm_map+0x96>
c0108379:	c7 44 24 0c 3b df 10 	movl   $0xc010df3b,0xc(%esp)
c0108380:	c0 
c0108381:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108388:	c0 
c0108389:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c0108390:	00 
c0108391:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108398:	e8 3d 8a ff ff       	call   c0100dda <__panic>

    int ret = -E_INVAL;
c010839d:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
c01083a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01083a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01083ae:	89 04 24             	mov    %eax,(%esp)
c01083b1:	e8 2a fc ff ff       	call   c0107fe0 <find_vma>
c01083b6:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01083b9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01083bd:	74 0d                	je     c01083cc <mm_map+0xc5>
c01083bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01083c2:	8b 40 04             	mov    0x4(%eax),%eax
c01083c5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01083c8:	73 02                	jae    c01083cc <mm_map+0xc5>
        goto out;
c01083ca:	eb 52                	jmp    c010841e <mm_map+0x117>
    }
    ret = -E_NO_MEM;
c01083cc:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
c01083d3:	8b 45 14             	mov    0x14(%ebp),%eax
c01083d6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01083da:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01083dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01083e4:	89 04 24             	mov    %eax,(%esp)
c01083e7:	e8 b9 fb ff ff       	call   c0107fa5 <vma_create>
c01083ec:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01083ef:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01083f3:	75 02                	jne    c01083f7 <mm_map+0xf0>
        goto out;
c01083f5:	eb 27                	jmp    c010841e <mm_map+0x117>
    }
    insert_vma_struct(mm, vma);
c01083f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01083fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0108401:	89 04 24             	mov    %eax,(%esp)
c0108404:	e8 2c fd ff ff       	call   c0108135 <insert_vma_struct>
    if (vma_store != NULL) {
c0108409:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c010840d:	74 08                	je     c0108417 <mm_map+0x110>
        *vma_store = vma;
c010840f:	8b 45 18             	mov    0x18(%ebp),%eax
c0108412:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108415:	89 10                	mov    %edx,(%eax)
    }
    ret = 0;
c0108417:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

out:
    return ret;
c010841e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108421:	c9                   	leave  
c0108422:	c3                   	ret    

c0108423 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
c0108423:	55                   	push   %ebp
c0108424:	89 e5                	mov    %esp,%ebp
c0108426:	56                   	push   %esi
c0108427:	53                   	push   %ebx
c0108428:	83 ec 40             	sub    $0x40,%esp
    assert(to != NULL && from != NULL);
c010842b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010842f:	74 06                	je     c0108437 <dup_mmap+0x14>
c0108431:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108435:	75 24                	jne    c010845b <dup_mmap+0x38>
c0108437:	c7 44 24 0c 46 df 10 	movl   $0xc010df46,0xc(%esp)
c010843e:	c0 
c010843f:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108446:	c0 
c0108447:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c010844e:	00 
c010844f:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108456:	e8 7f 89 ff ff       	call   c0100dda <__panic>
    list_entry_t *list = &(from->mmap_list), *le = list;
c010845b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010845e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108461:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108464:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_prev(le)) != list) {
c0108467:	e9 92 00 00 00       	jmp    c01084fe <dup_mmap+0xdb>
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
c010846c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010846f:	83 e8 10             	sub    $0x10,%eax
c0108472:	89 45 ec             	mov    %eax,-0x14(%ebp)
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
c0108475:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108478:	8b 48 0c             	mov    0xc(%eax),%ecx
c010847b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010847e:	8b 50 08             	mov    0x8(%eax),%edx
c0108481:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108484:	8b 40 04             	mov    0x4(%eax),%eax
c0108487:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010848b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010848f:	89 04 24             	mov    %eax,(%esp)
c0108492:	e8 0e fb ff ff       	call   c0107fa5 <vma_create>
c0108497:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (nvma == NULL) {
c010849a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010849e:	75 07                	jne    c01084a7 <dup_mmap+0x84>
            return -E_NO_MEM;
c01084a0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01084a5:	eb 76                	jmp    c010851d <dup_mmap+0xfa>
        }

        insert_vma_struct(to, nvma);
c01084a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01084aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01084b1:	89 04 24             	mov    %eax,(%esp)
c01084b4:	e8 7c fc ff ff       	call   c0108135 <insert_vma_struct>

        bool share = 0;
c01084b9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
c01084c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084c3:	8b 58 08             	mov    0x8(%eax),%ebx
c01084c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084c9:	8b 48 04             	mov    0x4(%eax),%ecx
c01084cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084cf:	8b 50 0c             	mov    0xc(%eax),%edx
c01084d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01084d5:	8b 40 0c             	mov    0xc(%eax),%eax
c01084d8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c01084db:	89 74 24 10          	mov    %esi,0x10(%esp)
c01084df:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01084e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01084e7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01084eb:	89 04 24             	mov    %eax,(%esp)
c01084ee:	e8 e8 d6 ff ff       	call   c0105bdb <copy_range>
c01084f3:	85 c0                	test   %eax,%eax
c01084f5:	74 07                	je     c01084fe <dup_mmap+0xdb>
            return -E_NO_MEM;
c01084f7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01084fc:	eb 1f                	jmp    c010851d <dup_mmap+0xfa>
c01084fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108501:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c0108504:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108507:	8b 00                	mov    (%eax),%eax

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
    assert(to != NULL && from != NULL);
    list_entry_t *list = &(from->mmap_list), *le = list;
    while ((le = list_prev(le)) != list) {
c0108509:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010850c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010850f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108512:	0f 85 54 ff ff ff    	jne    c010846c <dup_mmap+0x49>
        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
            return -E_NO_MEM;
        }
    }
    return 0;
c0108518:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010851d:	83 c4 40             	add    $0x40,%esp
c0108520:	5b                   	pop    %ebx
c0108521:	5e                   	pop    %esi
c0108522:	5d                   	pop    %ebp
c0108523:	c3                   	ret    

c0108524 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
c0108524:	55                   	push   %ebp
c0108525:	89 e5                	mov    %esp,%ebp
c0108527:	83 ec 38             	sub    $0x38,%esp
    assert(mm != NULL && mm_count(mm) == 0);
c010852a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010852e:	74 0f                	je     c010853f <exit_mmap+0x1b>
c0108530:	8b 45 08             	mov    0x8(%ebp),%eax
c0108533:	89 04 24             	mov    %eax,(%esp)
c0108536:	e8 5b f9 ff ff       	call   c0107e96 <mm_count>
c010853b:	85 c0                	test   %eax,%eax
c010853d:	74 24                	je     c0108563 <exit_mmap+0x3f>
c010853f:	c7 44 24 0c 64 df 10 	movl   $0xc010df64,0xc(%esp)
c0108546:	c0 
c0108547:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c010854e:	c0 
c010854f:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0108556:	00 
c0108557:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c010855e:	e8 77 88 ff ff       	call   c0100dda <__panic>
    pde_t *pgdir = mm->pgdir;
c0108563:	8b 45 08             	mov    0x8(%ebp),%eax
c0108566:	8b 40 0c             	mov    0xc(%eax),%eax
c0108569:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *list = &(mm->mmap_list), *le = list;
c010856c:	8b 45 08             	mov    0x8(%ebp),%eax
c010856f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108572:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108575:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(le)) != list) {
c0108578:	eb 28                	jmp    c01085a2 <exit_mmap+0x7e>
        struct vma_struct *vma = le2vma(le, list_link);
c010857a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010857d:	83 e8 10             	sub    $0x10,%eax
c0108580:	89 45 e8             	mov    %eax,-0x18(%ebp)
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
c0108583:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108586:	8b 50 08             	mov    0x8(%eax),%edx
c0108589:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010858c:	8b 40 04             	mov    0x4(%eax),%eax
c010858f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108593:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108597:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010859a:	89 04 24             	mov    %eax,(%esp)
c010859d:	e8 3e d4 ff ff       	call   c01059e0 <unmap_range>
c01085a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01085a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085ab:	8b 40 04             	mov    0x4(%eax),%eax
void
exit_mmap(struct mm_struct *mm) {
    assert(mm != NULL && mm_count(mm) == 0);
    pde_t *pgdir = mm->pgdir;
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
c01085ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01085b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085b4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01085b7:	75 c1                	jne    c010857a <exit_mmap+0x56>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    while ((le = list_next(le)) != list) {
c01085b9:	eb 28                	jmp    c01085e3 <exit_mmap+0xbf>
        struct vma_struct *vma = le2vma(le, list_link);
c01085bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085be:	83 e8 10             	sub    $0x10,%eax
c01085c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        exit_range(pgdir, vma->vm_start, vma->vm_end);
c01085c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01085c7:	8b 50 08             	mov    0x8(%eax),%edx
c01085ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01085cd:	8b 40 04             	mov    0x4(%eax),%eax
c01085d0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01085d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01085d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085db:	89 04 24             	mov    %eax,(%esp)
c01085de:	e8 f1 d4 ff ff       	call   c0105ad4 <exit_range>
c01085e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085e6:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01085e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01085ec:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    while ((le = list_next(le)) != list) {
c01085ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01085f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085f5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01085f8:	75 c1                	jne    c01085bb <exit_mmap+0x97>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
    }
}
c01085fa:	c9                   	leave  
c01085fb:	c3                   	ret    

c01085fc <copy_from_user>:

bool
copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable) {
c01085fc:	55                   	push   %ebp
c01085fd:	89 e5                	mov    %esp,%ebp
c01085ff:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)src, len, writable)) {
c0108602:	8b 45 10             	mov    0x10(%ebp),%eax
c0108605:	8b 55 18             	mov    0x18(%ebp),%edx
c0108608:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010860c:	8b 55 14             	mov    0x14(%ebp),%edx
c010860f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108613:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108617:	8b 45 08             	mov    0x8(%ebp),%eax
c010861a:	89 04 24             	mov    %eax,(%esp)
c010861d:	e8 c7 09 00 00       	call   c0108fe9 <user_mem_check>
c0108622:	85 c0                	test   %eax,%eax
c0108624:	75 07                	jne    c010862d <copy_from_user+0x31>
        return 0;
c0108626:	b8 00 00 00 00       	mov    $0x0,%eax
c010862b:	eb 1e                	jmp    c010864b <copy_from_user+0x4f>
    }
    memcpy(dst, src, len);
c010862d:	8b 45 14             	mov    0x14(%ebp),%eax
c0108630:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108634:	8b 45 10             	mov    0x10(%ebp),%eax
c0108637:	89 44 24 04          	mov    %eax,0x4(%esp)
c010863b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010863e:	89 04 24             	mov    %eax,(%esp)
c0108641:	e8 ba 3c 00 00       	call   c010c300 <memcpy>
    return 1;
c0108646:	b8 01 00 00 00       	mov    $0x1,%eax
}
c010864b:	c9                   	leave  
c010864c:	c3                   	ret    

c010864d <copy_to_user>:

bool
copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len) {
c010864d:	55                   	push   %ebp
c010864e:	89 e5                	mov    %esp,%ebp
c0108650:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1)) {
c0108653:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108656:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010865d:	00 
c010865e:	8b 55 14             	mov    0x14(%ebp),%edx
c0108661:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108665:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108669:	8b 45 08             	mov    0x8(%ebp),%eax
c010866c:	89 04 24             	mov    %eax,(%esp)
c010866f:	e8 75 09 00 00       	call   c0108fe9 <user_mem_check>
c0108674:	85 c0                	test   %eax,%eax
c0108676:	75 07                	jne    c010867f <copy_to_user+0x32>
        return 0;
c0108678:	b8 00 00 00 00       	mov    $0x0,%eax
c010867d:	eb 1e                	jmp    c010869d <copy_to_user+0x50>
    }
    memcpy(dst, src, len);
c010867f:	8b 45 14             	mov    0x14(%ebp),%eax
c0108682:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108686:	8b 45 10             	mov    0x10(%ebp),%eax
c0108689:	89 44 24 04          	mov    %eax,0x4(%esp)
c010868d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108690:	89 04 24             	mov    %eax,(%esp)
c0108693:	e8 68 3c 00 00       	call   c010c300 <memcpy>
    return 1;
c0108698:	b8 01 00 00 00       	mov    $0x1,%eax
}
c010869d:	c9                   	leave  
c010869e:	c3                   	ret    

c010869f <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c010869f:	55                   	push   %ebp
c01086a0:	89 e5                	mov    %esp,%ebp
c01086a2:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01086a5:	e8 02 00 00 00       	call   c01086ac <check_vmm>
}
c01086aa:	c9                   	leave  
c01086ab:	c3                   	ret    

c01086ac <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01086ac:	55                   	push   %ebp
c01086ad:	89 e5                	mov    %esp,%ebp
c01086af:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01086b2:	e8 53 ca ff ff       	call   c010510a <nr_free_pages>
c01086b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c01086ba:	e8 13 00 00 00       	call   c01086d2 <check_vma_struct>
    check_pgfault();
c01086bf:	e8 a7 04 00 00       	call   c0108b6b <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c01086c4:	c7 04 24 84 df 10 c0 	movl   $0xc010df84,(%esp)
c01086cb:	e8 88 7c ff ff       	call   c0100358 <cprintf>
}
c01086d0:	c9                   	leave  
c01086d1:	c3                   	ret    

c01086d2 <check_vma_struct>:

static void
check_vma_struct(void) {
c01086d2:	55                   	push   %ebp
c01086d3:	89 e5                	mov    %esp,%ebp
c01086d5:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01086d8:	e8 2d ca ff ff       	call   c010510a <nr_free_pages>
c01086dd:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c01086e0:	e8 27 f8 ff ff       	call   c0107f0c <mm_create>
c01086e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c01086e8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01086ec:	75 24                	jne    c0108712 <check_vma_struct+0x40>
c01086ee:	c7 44 24 0c 3b df 10 	movl   $0xc010df3b,0xc(%esp)
c01086f5:	c0 
c01086f6:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c01086fd:	c0 
c01086fe:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0108705:	00 
c0108706:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c010870d:	e8 c8 86 ff ff       	call   c0100dda <__panic>

    int step1 = 10, step2 = step1 * 10;
c0108712:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0108719:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010871c:	89 d0                	mov    %edx,%eax
c010871e:	c1 e0 02             	shl    $0x2,%eax
c0108721:	01 d0                	add    %edx,%eax
c0108723:	01 c0                	add    %eax,%eax
c0108725:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0108728:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010872b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010872e:	eb 70                	jmp    c01087a0 <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0108730:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108733:	89 d0                	mov    %edx,%eax
c0108735:	c1 e0 02             	shl    $0x2,%eax
c0108738:	01 d0                	add    %edx,%eax
c010873a:	83 c0 02             	add    $0x2,%eax
c010873d:	89 c1                	mov    %eax,%ecx
c010873f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108742:	89 d0                	mov    %edx,%eax
c0108744:	c1 e0 02             	shl    $0x2,%eax
c0108747:	01 d0                	add    %edx,%eax
c0108749:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108750:	00 
c0108751:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0108755:	89 04 24             	mov    %eax,(%esp)
c0108758:	e8 48 f8 ff ff       	call   c0107fa5 <vma_create>
c010875d:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0108760:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108764:	75 24                	jne    c010878a <check_vma_struct+0xb8>
c0108766:	c7 44 24 0c 9c df 10 	movl   $0xc010df9c,0xc(%esp)
c010876d:	c0 
c010876e:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108775:	c0 
c0108776:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c010877d:	00 
c010877e:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108785:	e8 50 86 ff ff       	call   c0100dda <__panic>
        insert_vma_struct(mm, vma);
c010878a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010878d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108791:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108794:	89 04 24             	mov    %eax,(%esp)
c0108797:	e8 99 f9 ff ff       	call   c0108135 <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c010879c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01087a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01087a4:	7f 8a                	jg     c0108730 <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01087a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01087a9:	83 c0 01             	add    $0x1,%eax
c01087ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01087af:	eb 70                	jmp    c0108821 <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01087b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01087b4:	89 d0                	mov    %edx,%eax
c01087b6:	c1 e0 02             	shl    $0x2,%eax
c01087b9:	01 d0                	add    %edx,%eax
c01087bb:	83 c0 02             	add    $0x2,%eax
c01087be:	89 c1                	mov    %eax,%ecx
c01087c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01087c3:	89 d0                	mov    %edx,%eax
c01087c5:	c1 e0 02             	shl    $0x2,%eax
c01087c8:	01 d0                	add    %edx,%eax
c01087ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01087d1:	00 
c01087d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01087d6:	89 04 24             	mov    %eax,(%esp)
c01087d9:	e8 c7 f7 ff ff       	call   c0107fa5 <vma_create>
c01087de:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c01087e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01087e5:	75 24                	jne    c010880b <check_vma_struct+0x139>
c01087e7:	c7 44 24 0c 9c df 10 	movl   $0xc010df9c,0xc(%esp)
c01087ee:	c0 
c01087ef:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c01087f6:	c0 
c01087f7:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c01087fe:	00 
c01087ff:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108806:	e8 cf 85 ff ff       	call   c0100dda <__panic>
        insert_vma_struct(mm, vma);
c010880b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010880e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108812:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108815:	89 04 24             	mov    %eax,(%esp)
c0108818:	e8 18 f9 ff ff       	call   c0108135 <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c010881d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108821:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108824:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108827:	7e 88                	jle    c01087b1 <check_vma_struct+0xdf>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0108829:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010882c:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010882f:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0108832:	8b 40 04             	mov    0x4(%eax),%eax
c0108835:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0108838:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c010883f:	e9 97 00 00 00       	jmp    c01088db <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c0108844:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108847:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010884a:	75 24                	jne    c0108870 <check_vma_struct+0x19e>
c010884c:	c7 44 24 0c a8 df 10 	movl   $0xc010dfa8,0xc(%esp)
c0108853:	c0 
c0108854:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c010885b:	c0 
c010885c:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0108863:	00 
c0108864:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c010886b:	e8 6a 85 ff ff       	call   c0100dda <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0108870:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108873:	83 e8 10             	sub    $0x10,%eax
c0108876:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0108879:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010887c:	8b 48 04             	mov    0x4(%eax),%ecx
c010887f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108882:	89 d0                	mov    %edx,%eax
c0108884:	c1 e0 02             	shl    $0x2,%eax
c0108887:	01 d0                	add    %edx,%eax
c0108889:	39 c1                	cmp    %eax,%ecx
c010888b:	75 17                	jne    c01088a4 <check_vma_struct+0x1d2>
c010888d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108890:	8b 48 08             	mov    0x8(%eax),%ecx
c0108893:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108896:	89 d0                	mov    %edx,%eax
c0108898:	c1 e0 02             	shl    $0x2,%eax
c010889b:	01 d0                	add    %edx,%eax
c010889d:	83 c0 02             	add    $0x2,%eax
c01088a0:	39 c1                	cmp    %eax,%ecx
c01088a2:	74 24                	je     c01088c8 <check_vma_struct+0x1f6>
c01088a4:	c7 44 24 0c c0 df 10 	movl   $0xc010dfc0,0xc(%esp)
c01088ab:	c0 
c01088ac:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c01088b3:	c0 
c01088b4:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c01088bb:	00 
c01088bc:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c01088c3:	e8 12 85 ff ff       	call   c0100dda <__panic>
c01088c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088cb:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01088ce:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01088d1:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01088d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c01088d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01088db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088de:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01088e1:	0f 8e 5d ff ff ff    	jle    c0108844 <check_vma_struct+0x172>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c01088e7:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c01088ee:	e9 cd 01 00 00       	jmp    c0108ac0 <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c01088f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01088fd:	89 04 24             	mov    %eax,(%esp)
c0108900:	e8 db f6 ff ff       	call   c0107fe0 <find_vma>
c0108905:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0108908:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010890c:	75 24                	jne    c0108932 <check_vma_struct+0x260>
c010890e:	c7 44 24 0c f5 df 10 	movl   $0xc010dff5,0xc(%esp)
c0108915:	c0 
c0108916:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c010891d:	c0 
c010891e:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0108925:	00 
c0108926:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c010892d:	e8 a8 84 ff ff       	call   c0100dda <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0108932:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108935:	83 c0 01             	add    $0x1,%eax
c0108938:	89 44 24 04          	mov    %eax,0x4(%esp)
c010893c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010893f:	89 04 24             	mov    %eax,(%esp)
c0108942:	e8 99 f6 ff ff       	call   c0107fe0 <find_vma>
c0108947:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c010894a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010894e:	75 24                	jne    c0108974 <check_vma_struct+0x2a2>
c0108950:	c7 44 24 0c 02 e0 10 	movl   $0xc010e002,0xc(%esp)
c0108957:	c0 
c0108958:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c010895f:	c0 
c0108960:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0108967:	00 
c0108968:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c010896f:	e8 66 84 ff ff       	call   c0100dda <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0108974:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108977:	83 c0 02             	add    $0x2,%eax
c010897a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010897e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108981:	89 04 24             	mov    %eax,(%esp)
c0108984:	e8 57 f6 ff ff       	call   c0107fe0 <find_vma>
c0108989:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c010898c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0108990:	74 24                	je     c01089b6 <check_vma_struct+0x2e4>
c0108992:	c7 44 24 0c 0f e0 10 	movl   $0xc010e00f,0xc(%esp)
c0108999:	c0 
c010899a:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c01089a1:	c0 
c01089a2:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01089a9:	00 
c01089aa:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c01089b1:	e8 24 84 ff ff       	call   c0100dda <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c01089b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089b9:	83 c0 03             	add    $0x3,%eax
c01089bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01089c3:	89 04 24             	mov    %eax,(%esp)
c01089c6:	e8 15 f6 ff ff       	call   c0107fe0 <find_vma>
c01089cb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c01089ce:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c01089d2:	74 24                	je     c01089f8 <check_vma_struct+0x326>
c01089d4:	c7 44 24 0c 1c e0 10 	movl   $0xc010e01c,0xc(%esp)
c01089db:	c0 
c01089dc:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c01089e3:	c0 
c01089e4:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c01089eb:	00 
c01089ec:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c01089f3:	e8 e2 83 ff ff       	call   c0100dda <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c01089f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089fb:	83 c0 04             	add    $0x4,%eax
c01089fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a02:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108a05:	89 04 24             	mov    %eax,(%esp)
c0108a08:	e8 d3 f5 ff ff       	call   c0107fe0 <find_vma>
c0108a0d:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c0108a10:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0108a14:	74 24                	je     c0108a3a <check_vma_struct+0x368>
c0108a16:	c7 44 24 0c 29 e0 10 	movl   $0xc010e029,0xc(%esp)
c0108a1d:	c0 
c0108a1e:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108a25:	c0 
c0108a26:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0108a2d:	00 
c0108a2e:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108a35:	e8 a0 83 ff ff       	call   c0100dda <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0108a3a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108a3d:	8b 50 04             	mov    0x4(%eax),%edx
c0108a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a43:	39 c2                	cmp    %eax,%edx
c0108a45:	75 10                	jne    c0108a57 <check_vma_struct+0x385>
c0108a47:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108a4a:	8b 50 08             	mov    0x8(%eax),%edx
c0108a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a50:	83 c0 02             	add    $0x2,%eax
c0108a53:	39 c2                	cmp    %eax,%edx
c0108a55:	74 24                	je     c0108a7b <check_vma_struct+0x3a9>
c0108a57:	c7 44 24 0c 38 e0 10 	movl   $0xc010e038,0xc(%esp)
c0108a5e:	c0 
c0108a5f:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108a66:	c0 
c0108a67:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0108a6e:	00 
c0108a6f:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108a76:	e8 5f 83 ff ff       	call   c0100dda <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0108a7b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108a7e:	8b 50 04             	mov    0x4(%eax),%edx
c0108a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a84:	39 c2                	cmp    %eax,%edx
c0108a86:	75 10                	jne    c0108a98 <check_vma_struct+0x3c6>
c0108a88:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108a8b:	8b 50 08             	mov    0x8(%eax),%edx
c0108a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a91:	83 c0 02             	add    $0x2,%eax
c0108a94:	39 c2                	cmp    %eax,%edx
c0108a96:	74 24                	je     c0108abc <check_vma_struct+0x3ea>
c0108a98:	c7 44 24 0c 68 e0 10 	movl   $0xc010e068,0xc(%esp)
c0108a9f:	c0 
c0108aa0:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108aa7:	c0 
c0108aa8:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0108aaf:	00 
c0108ab0:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108ab7:	e8 1e 83 ff ff       	call   c0100dda <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0108abc:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0108ac0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108ac3:	89 d0                	mov    %edx,%eax
c0108ac5:	c1 e0 02             	shl    $0x2,%eax
c0108ac8:	01 d0                	add    %edx,%eax
c0108aca:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108acd:	0f 8d 20 fe ff ff    	jge    c01088f3 <check_vma_struct+0x221>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0108ad3:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0108ada:	eb 70                	jmp    c0108b4c <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0108adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108adf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ae3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ae6:	89 04 24             	mov    %eax,(%esp)
c0108ae9:	e8 f2 f4 ff ff       	call   c0107fe0 <find_vma>
c0108aee:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c0108af1:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108af5:	74 27                	je     c0108b1e <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0108af7:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108afa:	8b 50 08             	mov    0x8(%eax),%edx
c0108afd:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108b00:	8b 40 04             	mov    0x4(%eax),%eax
c0108b03:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108b07:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b12:	c7 04 24 98 e0 10 c0 	movl   $0xc010e098,(%esp)
c0108b19:	e8 3a 78 ff ff       	call   c0100358 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0108b1e:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108b22:	74 24                	je     c0108b48 <check_vma_struct+0x476>
c0108b24:	c7 44 24 0c bd e0 10 	movl   $0xc010e0bd,0xc(%esp)
c0108b2b:	c0 
c0108b2c:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108b33:	c0 
c0108b34:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0108b3b:	00 
c0108b3c:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108b43:	e8 92 82 ff ff       	call   c0100dda <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0108b48:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0108b4c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108b50:	79 8a                	jns    c0108adc <check_vma_struct+0x40a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c0108b52:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b55:	89 04 24             	mov    %eax,(%esp)
c0108b58:	e8 08 f7 ff ff       	call   c0108265 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c0108b5d:	c7 04 24 d4 e0 10 c0 	movl   $0xc010e0d4,(%esp)
c0108b64:	e8 ef 77 ff ff       	call   c0100358 <cprintf>
}
c0108b69:	c9                   	leave  
c0108b6a:	c3                   	ret    

c0108b6b <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0108b6b:	55                   	push   %ebp
c0108b6c:	89 e5                	mov    %esp,%ebp
c0108b6e:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108b71:	e8 94 c5 ff ff       	call   c010510a <nr_free_pages>
c0108b76:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0108b79:	e8 8e f3 ff ff       	call   c0107f0c <mm_create>
c0108b7e:	a3 6c 0f 1b c0       	mov    %eax,0xc01b0f6c
    assert(check_mm_struct != NULL);
c0108b83:	a1 6c 0f 1b c0       	mov    0xc01b0f6c,%eax
c0108b88:	85 c0                	test   %eax,%eax
c0108b8a:	75 24                	jne    c0108bb0 <check_pgfault+0x45>
c0108b8c:	c7 44 24 0c f3 e0 10 	movl   $0xc010e0f3,0xc(%esp)
c0108b93:	c0 
c0108b94:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108b9b:	c0 
c0108b9c:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c0108ba3:	00 
c0108ba4:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108bab:	e8 2a 82 ff ff       	call   c0100dda <__panic>

    struct mm_struct *mm = check_mm_struct;
c0108bb0:	a1 6c 0f 1b c0       	mov    0xc01b0f6c,%eax
c0108bb5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0108bb8:	8b 15 84 ed 1a c0    	mov    0xc01aed84,%edx
c0108bbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108bc1:	89 50 0c             	mov    %edx,0xc(%eax)
c0108bc4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108bc7:	8b 40 0c             	mov    0xc(%eax),%eax
c0108bca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0108bcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108bd0:	8b 00                	mov    (%eax),%eax
c0108bd2:	85 c0                	test   %eax,%eax
c0108bd4:	74 24                	je     c0108bfa <check_pgfault+0x8f>
c0108bd6:	c7 44 24 0c 0b e1 10 	movl   $0xc010e10b,0xc(%esp)
c0108bdd:	c0 
c0108bde:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108be5:	c0 
c0108be6:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
c0108bed:	00 
c0108bee:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108bf5:	e8 e0 81 ff ff       	call   c0100dda <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0108bfa:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0108c01:	00 
c0108c02:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0108c09:	00 
c0108c0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0108c11:	e8 8f f3 ff ff       	call   c0107fa5 <vma_create>
c0108c16:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0108c19:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108c1d:	75 24                	jne    c0108c43 <check_pgfault+0xd8>
c0108c1f:	c7 44 24 0c 9c df 10 	movl   $0xc010df9c,0xc(%esp)
c0108c26:	c0 
c0108c27:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108c2e:	c0 
c0108c2f:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0108c36:	00 
c0108c37:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108c3e:	e8 97 81 ff ff       	call   c0100dda <__panic>

    insert_vma_struct(mm, vma);
c0108c43:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108c46:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c4d:	89 04 24             	mov    %eax,(%esp)
c0108c50:	e8 e0 f4 ff ff       	call   c0108135 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0108c55:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0108c5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c63:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c66:	89 04 24             	mov    %eax,(%esp)
c0108c69:	e8 72 f3 ff ff       	call   c0107fe0 <find_vma>
c0108c6e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108c71:	74 24                	je     c0108c97 <check_pgfault+0x12c>
c0108c73:	c7 44 24 0c 19 e1 10 	movl   $0xc010e119,0xc(%esp)
c0108c7a:	c0 
c0108c7b:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108c82:	c0 
c0108c83:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
c0108c8a:	00 
c0108c8b:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108c92:	e8 43 81 ff ff       	call   c0100dda <__panic>

    int i, sum = 0;
c0108c97:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0108c9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108ca5:	eb 17                	jmp    c0108cbe <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c0108ca7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108caa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108cad:	01 d0                	add    %edx,%eax
c0108caf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108cb2:	88 10                	mov    %dl,(%eax)
        sum += i;
c0108cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108cb7:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0108cba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108cbe:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108cc2:	7e e3                	jle    c0108ca7 <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0108cc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108ccb:	eb 15                	jmp    c0108ce2 <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c0108ccd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108cd0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108cd3:	01 d0                	add    %edx,%eax
c0108cd5:	0f b6 00             	movzbl (%eax),%eax
c0108cd8:	0f be c0             	movsbl %al,%eax
c0108cdb:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0108cde:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108ce2:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108ce6:	7e e5                	jle    c0108ccd <check_pgfault+0x162>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0108ce8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108cec:	74 24                	je     c0108d12 <check_pgfault+0x1a7>
c0108cee:	c7 44 24 0c 33 e1 10 	movl   $0xc010e133,0xc(%esp)
c0108cf5:	c0 
c0108cf6:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108cfd:	c0 
c0108cfe:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c0108d05:	00 
c0108d06:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108d0d:	e8 c8 80 ff ff       	call   c0100dda <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0108d12:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108d15:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108d18:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108d1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108d20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108d24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d27:	89 04 24             	mov    %eax,(%esp)
c0108d2a:	e8 cf d0 ff ff       	call   c0105dfe <page_remove>
    free_page(pde2page(pgdir[0]));
c0108d2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d32:	8b 00                	mov    (%eax),%eax
c0108d34:	89 04 24             	mov    %eax,(%esp)
c0108d37:	e8 b8 f1 ff ff       	call   c0107ef4 <pde2page>
c0108d3c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108d43:	00 
c0108d44:	89 04 24             	mov    %eax,(%esp)
c0108d47:	e8 8c c3 ff ff       	call   c01050d8 <free_pages>
    pgdir[0] = 0;
c0108d4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d4f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0108d55:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d58:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0108d5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d62:	89 04 24             	mov    %eax,(%esp)
c0108d65:	e8 fb f4 ff ff       	call   c0108265 <mm_destroy>
    check_mm_struct = NULL;
c0108d6a:	c7 05 6c 0f 1b c0 00 	movl   $0x0,0xc01b0f6c
c0108d71:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0108d74:	e8 91 c3 ff ff       	call   c010510a <nr_free_pages>
c0108d79:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108d7c:	74 24                	je     c0108da2 <check_pgfault+0x237>
c0108d7e:	c7 44 24 0c 3c e1 10 	movl   $0xc010e13c,0xc(%esp)
c0108d85:	c0 
c0108d86:	c7 44 24 08 ab de 10 	movl   $0xc010deab,0x8(%esp)
c0108d8d:	c0 
c0108d8e:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c0108d95:	00 
c0108d96:	c7 04 24 c0 de 10 c0 	movl   $0xc010dec0,(%esp)
c0108d9d:	e8 38 80 ff ff       	call   c0100dda <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0108da2:	c7 04 24 63 e1 10 c0 	movl   $0xc010e163,(%esp)
c0108da9:	e8 aa 75 ff ff       	call   c0100358 <cprintf>
}
c0108dae:	c9                   	leave  
c0108daf:	c3                   	ret    

c0108db0 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0108db0:	55                   	push   %ebp
c0108db1:	89 e5                	mov    %esp,%ebp
c0108db3:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0108db6:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0108dbd:	8b 45 10             	mov    0x10(%ebp),%eax
c0108dc0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108dc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dc7:	89 04 24             	mov    %eax,(%esp)
c0108dca:	e8 11 f2 ff ff       	call   c0107fe0 <find_vma>
c0108dcf:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0108dd2:	a1 18 ee 1a c0       	mov    0xc01aee18,%eax
c0108dd7:	83 c0 01             	add    $0x1,%eax
c0108dda:	a3 18 ee 1a c0       	mov    %eax,0xc01aee18
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0108ddf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0108de3:	74 0b                	je     c0108df0 <do_pgfault+0x40>
c0108de5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108de8:	8b 40 04             	mov    0x4(%eax),%eax
c0108deb:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108dee:	76 18                	jbe    c0108e08 <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0108df0:	8b 45 10             	mov    0x10(%ebp),%eax
c0108df3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108df7:	c7 04 24 80 e1 10 c0 	movl   $0xc010e180,(%esp)
c0108dfe:	e8 55 75 ff ff       	call   c0100358 <cprintf>
        goto failed;
c0108e03:	e9 dc 01 00 00       	jmp    c0108fe4 <do_pgfault+0x234>
    }
    //check the error_code
    switch (error_code & 3) {
c0108e08:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e0b:	83 e0 03             	and    $0x3,%eax
c0108e0e:	85 c0                	test   %eax,%eax
c0108e10:	74 36                	je     c0108e48 <do_pgfault+0x98>
c0108e12:	83 f8 01             	cmp    $0x1,%eax
c0108e15:	74 20                	je     c0108e37 <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0108e17:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e1a:	8b 40 0c             	mov    0xc(%eax),%eax
c0108e1d:	83 e0 02             	and    $0x2,%eax
c0108e20:	85 c0                	test   %eax,%eax
c0108e22:	75 11                	jne    c0108e35 <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0108e24:	c7 04 24 b0 e1 10 c0 	movl   $0xc010e1b0,(%esp)
c0108e2b:	e8 28 75 ff ff       	call   c0100358 <cprintf>
            goto failed;
c0108e30:	e9 af 01 00 00       	jmp    c0108fe4 <do_pgfault+0x234>
        }
        break;
c0108e35:	eb 2f                	jmp    c0108e66 <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0108e37:	c7 04 24 10 e2 10 c0 	movl   $0xc010e210,(%esp)
c0108e3e:	e8 15 75 ff ff       	call   c0100358 <cprintf>
        goto failed;
c0108e43:	e9 9c 01 00 00       	jmp    c0108fe4 <do_pgfault+0x234>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0108e48:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e4b:	8b 40 0c             	mov    0xc(%eax),%eax
c0108e4e:	83 e0 05             	and    $0x5,%eax
c0108e51:	85 c0                	test   %eax,%eax
c0108e53:	75 11                	jne    c0108e66 <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0108e55:	c7 04 24 48 e2 10 c0 	movl   $0xc010e248,(%esp)
c0108e5c:	e8 f7 74 ff ff       	call   c0100358 <cprintf>
            goto failed;
c0108e61:	e9 7e 01 00 00       	jmp    c0108fe4 <do_pgfault+0x234>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0108e66:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0108e6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e70:	8b 40 0c             	mov    0xc(%eax),%eax
c0108e73:	83 e0 02             	and    $0x2,%eax
c0108e76:	85 c0                	test   %eax,%eax
c0108e78:	74 04                	je     c0108e7e <do_pgfault+0xce>
        perm |= PTE_W;
c0108e7a:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0108e7e:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e81:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108e84:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e87:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108e8c:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0108e8f:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0108e96:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
    ptep = get_pte(mm->pgdir, addr, 1);
c0108e9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ea0:	8b 40 0c             	mov    0xc(%eax),%eax
c0108ea3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108eaa:	00 
c0108eab:	8b 55 10             	mov    0x10(%ebp),%edx
c0108eae:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108eb2:	89 04 24             	mov    %eax,(%esp)
c0108eb5:	e8 1a c9 ff ff       	call   c01057d4 <get_pte>
c0108eba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (ptep == NULL) {
c0108ebd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108ec1:	75 11                	jne    c0108ed4 <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c0108ec3:	c7 04 24 ab e2 10 c0 	movl   $0xc010e2ab,(%esp)
c0108eca:	e8 89 74 ff ff       	call   c0100358 <cprintf>
        goto failed;
c0108ecf:	e9 10 01 00 00       	jmp    c0108fe4 <do_pgfault+0x234>
    }

    if (*ptep == 0) {
c0108ed4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108ed7:	8b 00                	mov    (%eax),%eax
c0108ed9:	85 c0                	test   %eax,%eax
c0108edb:	75 3b                	jne    c0108f18 <do_pgfault+0x168>
        struct Page* page = pgdir_alloc_page(mm->pgdir, addr, perm);
c0108edd:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ee0:	8b 40 0c             	mov    0xc(%eax),%eax
c0108ee3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108ee6:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108eea:	8b 55 10             	mov    0x10(%ebp),%edx
c0108eed:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108ef1:	89 04 24             	mov    %eax,(%esp)
c0108ef4:	e8 5f d0 ff ff       	call   c0105f58 <pgdir_alloc_page>
c0108ef9:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if (page == NULL) {
c0108efc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108f00:	75 11                	jne    c0108f13 <do_pgfault+0x163>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0108f02:	c7 04 24 cc e2 10 c0 	movl   $0xc010e2cc,(%esp)
c0108f09:	e8 4a 74 ff ff       	call   c0100358 <cprintf>
            goto failed;
c0108f0e:	e9 d1 00 00 00       	jmp    c0108fe4 <do_pgfault+0x234>
c0108f13:	e9 c5 00 00 00       	jmp    c0108fdd <do_pgfault+0x22d>
        }
    }

    else {
        if(swap_init_ok) {
c0108f18:	a1 0c ee 1a c0       	mov    0xc01aee0c,%eax
c0108f1d:	85 c0                	test   %eax,%eax
c0108f1f:	0f 84 a1 00 00 00    	je     c0108fc6 <do_pgfault+0x216>
            struct Page *page = NULL;
c0108f25:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
            ret = swap_in(mm, addr, &page);
c0108f2c:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0108f2f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108f33:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f36:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f3d:	89 04 24             	mov    %eax,(%esp)
c0108f40:	e8 bf e0 ff ff       	call   c0107004 <swap_in>
c0108f45:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (ret != 0) {
c0108f48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108f4c:	74 11                	je     c0108f5f <do_pgfault+0x1af>
                cprintf("swap_in in do_pgfault failed\n");
c0108f4e:	c7 04 24 f3 e2 10 c0 	movl   $0xc010e2f3,(%esp)
c0108f55:	e8 fe 73 ff ff       	call   c0100358 <cprintf>
                goto failed;
c0108f5a:	e9 85 00 00 00       	jmp    c0108fe4 <do_pgfault+0x234>
            }
            ret = page_insert(mm->pgdir, page, addr, perm);
c0108f5f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108f62:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f65:	8b 40 0c             	mov    0xc(%eax),%eax
c0108f68:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108f6b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0108f6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0108f72:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108f76:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108f7a:	89 04 24             	mov    %eax,(%esp)
c0108f7d:	e8 c0 ce ff ff       	call   c0105e42 <page_insert>
c0108f82:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (ret != 0) {
c0108f85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108f89:	74 0f                	je     c0108f9a <do_pgfault+0x1ea>
                cprintf("page_insert in do_pgfault failed\n");
c0108f8b:	c7 04 24 14 e3 10 c0 	movl   $0xc010e314,(%esp)
c0108f92:	e8 c1 73 ff ff       	call   c0100358 <cprintf>
                goto failed;
c0108f97:	90                   	nop
c0108f98:	eb 4a                	jmp    c0108fe4 <do_pgfault+0x234>
            }
            swap_map_swappable(mm, addr, page, 1);
c0108f9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108f9d:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0108fa4:	00 
c0108fa5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108fa9:	8b 45 10             	mov    0x10(%ebp),%eax
c0108fac:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108fb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fb3:	89 04 24             	mov    %eax,(%esp)
c0108fb6:	e8 80 de ff ff       	call   c0106e3b <swap_map_swappable>
            page->pra_vaddr = addr;
c0108fbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108fbe:	8b 55 10             	mov    0x10(%ebp),%edx
c0108fc1:	89 50 1c             	mov    %edx,0x1c(%eax)
c0108fc4:	eb 17                	jmp    c0108fdd <do_pgfault+0x22d>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0108fc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108fc9:	8b 00                	mov    (%eax),%eax
c0108fcb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108fcf:	c7 04 24 38 e3 10 c0 	movl   $0xc010e338,(%esp)
c0108fd6:	e8 7d 73 ff ff       	call   c0100358 <cprintf>
            goto failed;
c0108fdb:	eb 07                	jmp    c0108fe4 <do_pgfault+0x234>
        }
   }
   ret = 0;
c0108fdd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0108fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108fe7:	c9                   	leave  
c0108fe8:	c3                   	ret    

c0108fe9 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
c0108fe9:	55                   	push   %ebp
c0108fea:	89 e5                	mov    %esp,%ebp
c0108fec:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0108fef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108ff3:	0f 84 e0 00 00 00    	je     c01090d9 <user_mem_check+0xf0>
        if (!USER_ACCESS(addr, addr + len)) {
c0108ff9:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0109000:	76 1c                	jbe    c010901e <user_mem_check+0x35>
c0109002:	8b 45 10             	mov    0x10(%ebp),%eax
c0109005:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109008:	01 d0                	add    %edx,%eax
c010900a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010900d:	76 0f                	jbe    c010901e <user_mem_check+0x35>
c010900f:	8b 45 10             	mov    0x10(%ebp),%eax
c0109012:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109015:	01 d0                	add    %edx,%eax
c0109017:	3d 00 00 00 b0       	cmp    $0xb0000000,%eax
c010901c:	76 0a                	jbe    c0109028 <user_mem_check+0x3f>
            return 0;
c010901e:	b8 00 00 00 00       	mov    $0x0,%eax
c0109023:	e9 e2 00 00 00       	jmp    c010910a <user_mem_check+0x121>
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
c0109028:	8b 45 0c             	mov    0xc(%ebp),%eax
c010902b:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010902e:	8b 45 10             	mov    0x10(%ebp),%eax
c0109031:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109034:	01 d0                	add    %edx,%eax
c0109036:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (start < end) {
c0109039:	e9 88 00 00 00       	jmp    c01090c6 <user_mem_check+0xdd>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
c010903e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109041:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109045:	8b 45 08             	mov    0x8(%ebp),%eax
c0109048:	89 04 24             	mov    %eax,(%esp)
c010904b:	e8 90 ef ff ff       	call   c0107fe0 <find_vma>
c0109050:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109053:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109057:	74 0b                	je     c0109064 <user_mem_check+0x7b>
c0109059:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010905c:	8b 40 04             	mov    0x4(%eax),%eax
c010905f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0109062:	76 0a                	jbe    c010906e <user_mem_check+0x85>
                return 0;
c0109064:	b8 00 00 00 00       	mov    $0x0,%eax
c0109069:	e9 9c 00 00 00       	jmp    c010910a <user_mem_check+0x121>
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
c010906e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109071:	8b 50 0c             	mov    0xc(%eax),%edx
c0109074:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0109078:	74 07                	je     c0109081 <user_mem_check+0x98>
c010907a:	b8 02 00 00 00       	mov    $0x2,%eax
c010907f:	eb 05                	jmp    c0109086 <user_mem_check+0x9d>
c0109081:	b8 01 00 00 00       	mov    $0x1,%eax
c0109086:	21 d0                	and    %edx,%eax
c0109088:	85 c0                	test   %eax,%eax
c010908a:	75 07                	jne    c0109093 <user_mem_check+0xaa>
                return 0;
c010908c:	b8 00 00 00 00       	mov    $0x0,%eax
c0109091:	eb 77                	jmp    c010910a <user_mem_check+0x121>
            }
            if (write && (vma->vm_flags & VM_STACK)) {
c0109093:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0109097:	74 24                	je     c01090bd <user_mem_check+0xd4>
c0109099:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010909c:	8b 40 0c             	mov    0xc(%eax),%eax
c010909f:	83 e0 08             	and    $0x8,%eax
c01090a2:	85 c0                	test   %eax,%eax
c01090a4:	74 17                	je     c01090bd <user_mem_check+0xd4>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
c01090a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090a9:	8b 40 04             	mov    0x4(%eax),%eax
c01090ac:	05 00 10 00 00       	add    $0x1000,%eax
c01090b1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01090b4:	76 07                	jbe    c01090bd <user_mem_check+0xd4>
                    return 0;
c01090b6:	b8 00 00 00 00       	mov    $0x0,%eax
c01090bb:	eb 4d                	jmp    c010910a <user_mem_check+0x121>
                }
            }
            start = vma->vm_end;
c01090bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090c0:	8b 40 08             	mov    0x8(%eax),%eax
c01090c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!USER_ACCESS(addr, addr + len)) {
            return 0;
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
        while (start < end) {
c01090c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01090c9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01090cc:	0f 82 6c ff ff ff    	jb     c010903e <user_mem_check+0x55>
                    return 0;
                }
            }
            start = vma->vm_end;
        }
        return 1;
c01090d2:	b8 01 00 00 00       	mov    $0x1,%eax
c01090d7:	eb 31                	jmp    c010910a <user_mem_check+0x121>
    }
    return KERN_ACCESS(addr, addr + len);
c01090d9:	81 7d 0c ff ff ff bf 	cmpl   $0xbfffffff,0xc(%ebp)
c01090e0:	76 23                	jbe    c0109105 <user_mem_check+0x11c>
c01090e2:	8b 45 10             	mov    0x10(%ebp),%eax
c01090e5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01090e8:	01 d0                	add    %edx,%eax
c01090ea:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01090ed:	76 16                	jbe    c0109105 <user_mem_check+0x11c>
c01090ef:	8b 45 10             	mov    0x10(%ebp),%eax
c01090f2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01090f5:	01 d0                	add    %edx,%eax
c01090f7:	3d 00 00 00 f8       	cmp    $0xf8000000,%eax
c01090fc:	77 07                	ja     c0109105 <user_mem_check+0x11c>
c01090fe:	b8 01 00 00 00       	mov    $0x1,%eax
c0109103:	eb 05                	jmp    c010910a <user_mem_check+0x121>
c0109105:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010910a:	c9                   	leave  
c010910b:	c3                   	ret    

c010910c <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010910c:	55                   	push   %ebp
c010910d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010910f:	8b 55 08             	mov    0x8(%ebp),%edx
c0109112:	a1 90 0e 1b c0       	mov    0xc01b0e90,%eax
c0109117:	29 c2                	sub    %eax,%edx
c0109119:	89 d0                	mov    %edx,%eax
c010911b:	c1 f8 05             	sar    $0x5,%eax
}
c010911e:	5d                   	pop    %ebp
c010911f:	c3                   	ret    

c0109120 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0109120:	55                   	push   %ebp
c0109121:	89 e5                	mov    %esp,%ebp
c0109123:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0109126:	8b 45 08             	mov    0x8(%ebp),%eax
c0109129:	89 04 24             	mov    %eax,(%esp)
c010912c:	e8 db ff ff ff       	call   c010910c <page2ppn>
c0109131:	c1 e0 0c             	shl    $0xc,%eax
}
c0109134:	c9                   	leave  
c0109135:	c3                   	ret    

c0109136 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0109136:	55                   	push   %ebp
c0109137:	89 e5                	mov    %esp,%ebp
c0109139:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010913c:	8b 45 08             	mov    0x8(%ebp),%eax
c010913f:	89 04 24             	mov    %eax,(%esp)
c0109142:	e8 d9 ff ff ff       	call   c0109120 <page2pa>
c0109147:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010914a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010914d:	c1 e8 0c             	shr    $0xc,%eax
c0109150:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109153:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c0109158:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010915b:	72 23                	jb     c0109180 <page2kva+0x4a>
c010915d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109160:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109164:	c7 44 24 08 60 e3 10 	movl   $0xc010e360,0x8(%esp)
c010916b:	c0 
c010916c:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0109173:	00 
c0109174:	c7 04 24 83 e3 10 c0 	movl   $0xc010e383,(%esp)
c010917b:	e8 5a 7c ff ff       	call   c0100dda <__panic>
c0109180:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109183:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0109188:	c9                   	leave  
c0109189:	c3                   	ret    

c010918a <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c010918a:	55                   	push   %ebp
c010918b:	89 e5                	mov    %esp,%ebp
c010918d:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0109190:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109197:	e8 8e 89 ff ff       	call   c0101b2a <ide_device_valid>
c010919c:	85 c0                	test   %eax,%eax
c010919e:	75 1c                	jne    c01091bc <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c01091a0:	c7 44 24 08 91 e3 10 	movl   $0xc010e391,0x8(%esp)
c01091a7:	c0 
c01091a8:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c01091af:	00 
c01091b0:	c7 04 24 ab e3 10 c0 	movl   $0xc010e3ab,(%esp)
c01091b7:	e8 1e 7c ff ff       	call   c0100dda <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01091bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01091c3:	e8 a1 89 ff ff       	call   c0101b69 <ide_device_size>
c01091c8:	c1 e8 03             	shr    $0x3,%eax
c01091cb:	a3 3c 0f 1b c0       	mov    %eax,0xc01b0f3c
}
c01091d0:	c9                   	leave  
c01091d1:	c3                   	ret    

c01091d2 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01091d2:	55                   	push   %ebp
c01091d3:	89 e5                	mov    %esp,%ebp
c01091d5:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01091d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01091db:	89 04 24             	mov    %eax,(%esp)
c01091de:	e8 53 ff ff ff       	call   c0109136 <page2kva>
c01091e3:	8b 55 08             	mov    0x8(%ebp),%edx
c01091e6:	c1 ea 08             	shr    $0x8,%edx
c01091e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01091ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01091f0:	74 0b                	je     c01091fd <swapfs_read+0x2b>
c01091f2:	8b 15 3c 0f 1b c0    	mov    0xc01b0f3c,%edx
c01091f8:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01091fb:	72 23                	jb     c0109220 <swapfs_read+0x4e>
c01091fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0109200:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109204:	c7 44 24 08 bc e3 10 	movl   $0xc010e3bc,0x8(%esp)
c010920b:	c0 
c010920c:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0109213:	00 
c0109214:	c7 04 24 ab e3 10 c0 	movl   $0xc010e3ab,(%esp)
c010921b:	e8 ba 7b ff ff       	call   c0100dda <__panic>
c0109220:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109223:	c1 e2 03             	shl    $0x3,%edx
c0109226:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010922d:	00 
c010922e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109232:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109236:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010923d:	e8 66 89 ff ff       	call   c0101ba8 <ide_read_secs>
}
c0109242:	c9                   	leave  
c0109243:	c3                   	ret    

c0109244 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0109244:	55                   	push   %ebp
c0109245:	89 e5                	mov    %esp,%ebp
c0109247:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010924a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010924d:	89 04 24             	mov    %eax,(%esp)
c0109250:	e8 e1 fe ff ff       	call   c0109136 <page2kva>
c0109255:	8b 55 08             	mov    0x8(%ebp),%edx
c0109258:	c1 ea 08             	shr    $0x8,%edx
c010925b:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010925e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109262:	74 0b                	je     c010926f <swapfs_write+0x2b>
c0109264:	8b 15 3c 0f 1b c0    	mov    0xc01b0f3c,%edx
c010926a:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010926d:	72 23                	jb     c0109292 <swapfs_write+0x4e>
c010926f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109272:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109276:	c7 44 24 08 bc e3 10 	movl   $0xc010e3bc,0x8(%esp)
c010927d:	c0 
c010927e:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0109285:	00 
c0109286:	c7 04 24 ab e3 10 c0 	movl   $0xc010e3ab,(%esp)
c010928d:	e8 48 7b ff ff       	call   c0100dda <__panic>
c0109292:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109295:	c1 e2 03             	shl    $0x3,%edx
c0109298:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010929f:	00 
c01092a0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01092a4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01092a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01092af:	e8 36 8b ff ff       	call   c0101dea <ide_write_secs>
}
c01092b4:	c9                   	leave  
c01092b5:	c3                   	ret    

c01092b6 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c01092b6:	52                   	push   %edx
    call *%ebx              # call fn
c01092b7:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c01092b9:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c01092ba:	e8 f8 0c 00 00       	call   c0109fb7 <do_exit>

c01092bf <test_and_set_bit>:
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
c01092bf:	55                   	push   %ebp
c01092c0:	89 e5                	mov    %esp,%ebp
c01092c2:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01092c5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01092c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01092cb:	0f ab 02             	bts    %eax,(%edx)
c01092ce:	19 c0                	sbb    %eax,%eax
c01092d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01092d3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01092d7:	0f 95 c0             	setne  %al
c01092da:	0f b6 c0             	movzbl %al,%eax
}
c01092dd:	c9                   	leave  
c01092de:	c3                   	ret    

c01092df <test_and_clear_bit>:
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
c01092df:	55                   	push   %ebp
c01092e0:	89 e5                	mov    %esp,%ebp
c01092e2:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01092e5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01092e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01092eb:	0f b3 02             	btr    %eax,(%edx)
c01092ee:	19 c0                	sbb    %eax,%eax
c01092f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01092f3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01092f7:	0f 95 c0             	setne  %al
c01092fa:	0f b6 c0             	movzbl %al,%eax
}
c01092fd:	c9                   	leave  
c01092fe:	c3                   	ret    

c01092ff <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c01092ff:	55                   	push   %ebp
c0109300:	89 e5                	mov    %esp,%ebp
c0109302:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0109305:	9c                   	pushf  
c0109306:	58                   	pop    %eax
c0109307:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010930a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010930d:	25 00 02 00 00       	and    $0x200,%eax
c0109312:	85 c0                	test   %eax,%eax
c0109314:	74 0c                	je     c0109322 <__intr_save+0x23>
        intr_disable();
c0109316:	e8 17 8d ff ff       	call   c0102032 <intr_disable>
        return 1;
c010931b:	b8 01 00 00 00       	mov    $0x1,%eax
c0109320:	eb 05                	jmp    c0109327 <__intr_save+0x28>
    }
    return 0;
c0109322:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109327:	c9                   	leave  
c0109328:	c3                   	ret    

c0109329 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0109329:	55                   	push   %ebp
c010932a:	89 e5                	mov    %esp,%ebp
c010932c:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010932f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109333:	74 05                	je     c010933a <__intr_restore+0x11>
        intr_enable();
c0109335:	e8 f2 8c ff ff       	call   c010202c <intr_enable>
    }
}
c010933a:	c9                   	leave  
c010933b:	c3                   	ret    

c010933c <try_lock>:
lock_init(lock_t *lock) {
    *lock = 0;
}

static inline bool
try_lock(lock_t *lock) {
c010933c:	55                   	push   %ebp
c010933d:	89 e5                	mov    %esp,%ebp
c010933f:	83 ec 08             	sub    $0x8,%esp
    return !test_and_set_bit(0, lock);
c0109342:	8b 45 08             	mov    0x8(%ebp),%eax
c0109345:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109349:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0109350:	e8 6a ff ff ff       	call   c01092bf <test_and_set_bit>
c0109355:	85 c0                	test   %eax,%eax
c0109357:	0f 94 c0             	sete   %al
c010935a:	0f b6 c0             	movzbl %al,%eax
}
c010935d:	c9                   	leave  
c010935e:	c3                   	ret    

c010935f <lock>:

static inline void
lock(lock_t *lock) {
c010935f:	55                   	push   %ebp
c0109360:	89 e5                	mov    %esp,%ebp
c0109362:	83 ec 18             	sub    $0x18,%esp
    while (!try_lock(lock)) {
c0109365:	eb 05                	jmp    c010936c <lock+0xd>
        schedule();
c0109367:	e8 56 21 00 00       	call   c010b4c2 <schedule>
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
c010936c:	8b 45 08             	mov    0x8(%ebp),%eax
c010936f:	89 04 24             	mov    %eax,(%esp)
c0109372:	e8 c5 ff ff ff       	call   c010933c <try_lock>
c0109377:	85 c0                	test   %eax,%eax
c0109379:	74 ec                	je     c0109367 <lock+0x8>
        schedule();
    }
}
c010937b:	c9                   	leave  
c010937c:	c3                   	ret    

c010937d <unlock>:

static inline void
unlock(lock_t *lock) {
c010937d:	55                   	push   %ebp
c010937e:	89 e5                	mov    %esp,%ebp
c0109380:	83 ec 18             	sub    $0x18,%esp
    if (!test_and_clear_bit(0, lock)) {
c0109383:	8b 45 08             	mov    0x8(%ebp),%eax
c0109386:	89 44 24 04          	mov    %eax,0x4(%esp)
c010938a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0109391:	e8 49 ff ff ff       	call   c01092df <test_and_clear_bit>
c0109396:	85 c0                	test   %eax,%eax
c0109398:	75 1c                	jne    c01093b6 <unlock+0x39>
        panic("Unlock failed.\n");
c010939a:	c7 44 24 08 dc e3 10 	movl   $0xc010e3dc,0x8(%esp)
c01093a1:	c0 
c01093a2:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
c01093a9:	00 
c01093aa:	c7 04 24 ec e3 10 c0 	movl   $0xc010e3ec,(%esp)
c01093b1:	e8 24 7a ff ff       	call   c0100dda <__panic>
    }
}
c01093b6:	c9                   	leave  
c01093b7:	c3                   	ret    

c01093b8 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01093b8:	55                   	push   %ebp
c01093b9:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01093bb:	8b 55 08             	mov    0x8(%ebp),%edx
c01093be:	a1 90 0e 1b c0       	mov    0xc01b0e90,%eax
c01093c3:	29 c2                	sub    %eax,%edx
c01093c5:	89 d0                	mov    %edx,%eax
c01093c7:	c1 f8 05             	sar    $0x5,%eax
}
c01093ca:	5d                   	pop    %ebp
c01093cb:	c3                   	ret    

c01093cc <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01093cc:	55                   	push   %ebp
c01093cd:	89 e5                	mov    %esp,%ebp
c01093cf:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01093d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01093d5:	89 04 24             	mov    %eax,(%esp)
c01093d8:	e8 db ff ff ff       	call   c01093b8 <page2ppn>
c01093dd:	c1 e0 0c             	shl    $0xc,%eax
}
c01093e0:	c9                   	leave  
c01093e1:	c3                   	ret    

c01093e2 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01093e2:	55                   	push   %ebp
c01093e3:	89 e5                	mov    %esp,%ebp
c01093e5:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01093e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01093eb:	c1 e8 0c             	shr    $0xc,%eax
c01093ee:	89 c2                	mov    %eax,%edx
c01093f0:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c01093f5:	39 c2                	cmp    %eax,%edx
c01093f7:	72 1c                	jb     c0109415 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01093f9:	c7 44 24 08 00 e4 10 	movl   $0xc010e400,0x8(%esp)
c0109400:	c0 
c0109401:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0109408:	00 
c0109409:	c7 04 24 1f e4 10 c0 	movl   $0xc010e41f,(%esp)
c0109410:	e8 c5 79 ff ff       	call   c0100dda <__panic>
    }
    return &pages[PPN(pa)];
c0109415:	a1 90 0e 1b c0       	mov    0xc01b0e90,%eax
c010941a:	8b 55 08             	mov    0x8(%ebp),%edx
c010941d:	c1 ea 0c             	shr    $0xc,%edx
c0109420:	c1 e2 05             	shl    $0x5,%edx
c0109423:	01 d0                	add    %edx,%eax
}
c0109425:	c9                   	leave  
c0109426:	c3                   	ret    

c0109427 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0109427:	55                   	push   %ebp
c0109428:	89 e5                	mov    %esp,%ebp
c010942a:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010942d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109430:	89 04 24             	mov    %eax,(%esp)
c0109433:	e8 94 ff ff ff       	call   c01093cc <page2pa>
c0109438:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010943b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010943e:	c1 e8 0c             	shr    $0xc,%eax
c0109441:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109444:	a1 80 ed 1a c0       	mov    0xc01aed80,%eax
c0109449:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010944c:	72 23                	jb     c0109471 <page2kva+0x4a>
c010944e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109451:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109455:	c7 44 24 08 30 e4 10 	movl   $0xc010e430,0x8(%esp)
c010945c:	c0 
c010945d:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0109464:	00 
c0109465:	c7 04 24 1f e4 10 c0 	movl   $0xc010e41f,(%esp)
c010946c:	e8 69 79 ff ff       	call   c0100dda <__panic>
c0109471:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109474:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0109479:	c9                   	leave  
c010947a:	c3                   	ret    

c010947b <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c010947b:	55                   	push   %ebp
c010947c:	89 e5                	mov    %esp,%ebp
c010947e:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0109481:	8b 45 08             	mov    0x8(%ebp),%eax
c0109484:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109487:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010948e:	77 23                	ja     c01094b3 <kva2page+0x38>
c0109490:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109493:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109497:	c7 44 24 08 54 e4 10 	movl   $0xc010e454,0x8(%esp)
c010949e:	c0 
c010949f:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01094a6:	00 
c01094a7:	c7 04 24 1f e4 10 c0 	movl   $0xc010e41f,(%esp)
c01094ae:	e8 27 79 ff ff       	call   c0100dda <__panic>
c01094b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094b6:	05 00 00 00 40       	add    $0x40000000,%eax
c01094bb:	89 04 24             	mov    %eax,(%esp)
c01094be:	e8 1f ff ff ff       	call   c01093e2 <pa2page>
}
c01094c3:	c9                   	leave  
c01094c4:	c3                   	ret    

c01094c5 <mm_count_inc>:

static inline int
mm_count_inc(struct mm_struct *mm) {
c01094c5:	55                   	push   %ebp
c01094c6:	89 e5                	mov    %esp,%ebp
    mm->mm_count += 1;
c01094c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01094cb:	8b 40 18             	mov    0x18(%eax),%eax
c01094ce:	8d 50 01             	lea    0x1(%eax),%edx
c01094d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01094d4:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01094d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01094da:	8b 40 18             	mov    0x18(%eax),%eax
}
c01094dd:	5d                   	pop    %ebp
c01094de:	c3                   	ret    

c01094df <mm_count_dec>:

static inline int
mm_count_dec(struct mm_struct *mm) {
c01094df:	55                   	push   %ebp
c01094e0:	89 e5                	mov    %esp,%ebp
    mm->mm_count -= 1;
c01094e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01094e5:	8b 40 18             	mov    0x18(%eax),%eax
c01094e8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01094eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01094ee:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01094f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01094f4:	8b 40 18             	mov    0x18(%eax),%eax
}
c01094f7:	5d                   	pop    %ebp
c01094f8:	c3                   	ret    

c01094f9 <lock_mm>:

static inline void
lock_mm(struct mm_struct *mm) {
c01094f9:	55                   	push   %ebp
c01094fa:	89 e5                	mov    %esp,%ebp
c01094fc:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c01094ff:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109503:	74 0e                	je     c0109513 <lock_mm+0x1a>
        lock(&(mm->mm_lock));
c0109505:	8b 45 08             	mov    0x8(%ebp),%eax
c0109508:	83 c0 1c             	add    $0x1c,%eax
c010950b:	89 04 24             	mov    %eax,(%esp)
c010950e:	e8 4c fe ff ff       	call   c010935f <lock>
    }
}
c0109513:	c9                   	leave  
c0109514:	c3                   	ret    

c0109515 <unlock_mm>:

static inline void
unlock_mm(struct mm_struct *mm) {
c0109515:	55                   	push   %ebp
c0109516:	89 e5                	mov    %esp,%ebp
c0109518:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c010951b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010951f:	74 0e                	je     c010952f <unlock_mm+0x1a>
        unlock(&(mm->mm_lock));
c0109521:	8b 45 08             	mov    0x8(%ebp),%eax
c0109524:	83 c0 1c             	add    $0x1c,%eax
c0109527:	89 04 24             	mov    %eax,(%esp)
c010952a:	e8 4e fe ff ff       	call   c010937d <unlock>
    }
}
c010952f:	c9                   	leave  
c0109530:	c3                   	ret    

c0109531 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c0109531:	55                   	push   %ebp
c0109532:	89 e5                	mov    %esp,%ebp
c0109534:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0109537:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
c010953e:	e8 b5 b6 ff ff       	call   c0104bf8 <kmalloc>
c0109543:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0109546:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010954a:	0f 84 4c 01 00 00    	je     c010969c <alloc_proc+0x16b>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
c0109550:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109553:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c0109559:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010955c:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c0109563:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109566:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c010956d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109570:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c0109577:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010957a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c0109581:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109584:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c010958b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010958e:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c0109595:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109598:	83 c0 1c             	add    $0x1c,%eax
c010959b:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c01095a2:	00 
c01095a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01095aa:	00 
c01095ab:	89 04 24             	mov    %eax,(%esp)
c01095ae:	e8 6b 2c 00 00       	call   c010c21e <memset>
        proc->tf = NULL;
c01095b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095b6:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c01095bd:	8b 15 8c 0e 1b c0    	mov    0xc01b0e8c,%edx
c01095c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095c6:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c01095c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095cc:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c01095d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095d6:	83 c0 48             	add    $0x48,%eax
c01095d9:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01095e0:	00 
c01095e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01095e8:	00 
c01095e9:	89 04 24             	mov    %eax,(%esp)
c01095ec:	e8 2d 2c 00 00       	call   c010c21e <memset>
    /*
     * below fields(add in LAB5) in proc_struct need to be initialized	
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
	 */
        proc->wait_state = 0;
c01095f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095f4:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
        proc->cptr = proc->yptr = proc->optr = NULL;
c01095fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095fe:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
c0109605:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109608:	8b 50 78             	mov    0x78(%eax),%edx
c010960b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010960e:	89 50 74             	mov    %edx,0x74(%eax)
c0109611:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109614:	8b 50 74             	mov    0x74(%eax),%edx
c0109617:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010961a:	89 50 70             	mov    %edx,0x70(%eax)
     *     int time_slice;                             // time slice for occupying the CPU
     *     skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
     *     uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process
     *     uint32_t lab6_priority;                     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t)
     */
        proc->rq = NULL;
c010961d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109620:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
        list_init(&(proc->run_link));
c0109627:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010962a:	83 e8 80             	sub    $0xffffff80,%eax
c010962d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0109630:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109633:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109636:	89 50 04             	mov    %edx,0x4(%eax)
c0109639:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010963c:	8b 50 04             	mov    0x4(%eax),%edx
c010963f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109642:	89 10                	mov    %edx,(%eax)
        proc->time_slice = 0;
c0109644:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109647:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
c010964e:	00 00 00 
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
c0109651:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109654:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
c010965b:	00 00 00 
c010965e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109661:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
c0109667:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010966a:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
c0109670:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109673:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
c0109679:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010967c:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
        proc->lab6_stride = 0;
c0109682:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109685:	c7 80 98 00 00 00 00 	movl   $0x0,0x98(%eax)
c010968c:	00 00 00 
        proc->lab6_priority = 0;
c010968f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109692:	c7 80 9c 00 00 00 00 	movl   $0x0,0x9c(%eax)
c0109699:	00 00 00 
    }
    return proc;
c010969c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010969f:	c9                   	leave  
c01096a0:	c3                   	ret    

c01096a1 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c01096a1:	55                   	push   %ebp
c01096a2:	89 e5                	mov    %esp,%ebp
c01096a4:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c01096a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01096aa:	83 c0 48             	add    $0x48,%eax
c01096ad:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01096b4:	00 
c01096b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01096bc:	00 
c01096bd:	89 04 24             	mov    %eax,(%esp)
c01096c0:	e8 59 2b 00 00       	call   c010c21e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c01096c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01096c8:	8d 50 48             	lea    0x48(%eax),%edx
c01096cb:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01096d2:	00 
c01096d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01096d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01096da:	89 14 24             	mov    %edx,(%esp)
c01096dd:	e8 1e 2c 00 00       	call   c010c300 <memcpy>
}
c01096e2:	c9                   	leave  
c01096e3:	c3                   	ret    

c01096e4 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c01096e4:	55                   	push   %ebp
c01096e5:	89 e5                	mov    %esp,%ebp
c01096e7:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c01096ea:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01096f1:	00 
c01096f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01096f9:	00 
c01096fa:	c7 04 24 44 0e 1b c0 	movl   $0xc01b0e44,(%esp)
c0109701:	e8 18 2b 00 00       	call   c010c21e <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0109706:	8b 45 08             	mov    0x8(%ebp),%eax
c0109709:	83 c0 48             	add    $0x48,%eax
c010970c:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109713:	00 
c0109714:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109718:	c7 04 24 44 0e 1b c0 	movl   $0xc01b0e44,(%esp)
c010971f:	e8 dc 2b 00 00       	call   c010c300 <memcpy>
}
c0109724:	c9                   	leave  
c0109725:	c3                   	ret    

c0109726 <set_links>:

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
c0109726:	55                   	push   %ebp
c0109727:	89 e5                	mov    %esp,%ebp
c0109729:	83 ec 20             	sub    $0x20,%esp
    list_add(&proc_list, &(proc->list_link));
c010972c:	8b 45 08             	mov    0x8(%ebp),%eax
c010972f:	83 c0 58             	add    $0x58,%eax
c0109732:	c7 45 fc 70 0f 1b c0 	movl   $0xc01b0f70,-0x4(%ebp)
c0109739:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010973c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010973f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109742:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109745:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0109748:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010974b:	8b 40 04             	mov    0x4(%eax),%eax
c010974e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109751:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109754:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109757:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010975a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010975d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109760:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109763:	89 10                	mov    %edx,(%eax)
c0109765:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109768:	8b 10                	mov    (%eax),%edx
c010976a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010976d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109770:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109773:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109776:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109779:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010977c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010977f:	89 10                	mov    %edx,(%eax)
    proc->yptr = NULL;
c0109781:	8b 45 08             	mov    0x8(%ebp),%eax
c0109784:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    if ((proc->optr = proc->parent->cptr) != NULL) {
c010978b:	8b 45 08             	mov    0x8(%ebp),%eax
c010978e:	8b 40 14             	mov    0x14(%eax),%eax
c0109791:	8b 50 70             	mov    0x70(%eax),%edx
c0109794:	8b 45 08             	mov    0x8(%ebp),%eax
c0109797:	89 50 78             	mov    %edx,0x78(%eax)
c010979a:	8b 45 08             	mov    0x8(%ebp),%eax
c010979d:	8b 40 78             	mov    0x78(%eax),%eax
c01097a0:	85 c0                	test   %eax,%eax
c01097a2:	74 0c                	je     c01097b0 <set_links+0x8a>
        proc->optr->yptr = proc;
c01097a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01097a7:	8b 40 78             	mov    0x78(%eax),%eax
c01097aa:	8b 55 08             	mov    0x8(%ebp),%edx
c01097ad:	89 50 74             	mov    %edx,0x74(%eax)
    }
    proc->parent->cptr = proc;
c01097b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01097b3:	8b 40 14             	mov    0x14(%eax),%eax
c01097b6:	8b 55 08             	mov    0x8(%ebp),%edx
c01097b9:	89 50 70             	mov    %edx,0x70(%eax)
    nr_process ++;
c01097bc:	a1 40 0e 1b c0       	mov    0xc01b0e40,%eax
c01097c1:	83 c0 01             	add    $0x1,%eax
c01097c4:	a3 40 0e 1b c0       	mov    %eax,0xc01b0e40
}
c01097c9:	c9                   	leave  
c01097ca:	c3                   	ret    

c01097cb <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
c01097cb:	55                   	push   %ebp
c01097cc:	89 e5                	mov    %esp,%ebp
c01097ce:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c01097d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01097d4:	83 c0 58             	add    $0x58,%eax
c01097d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01097da:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01097dd:	8b 40 04             	mov    0x4(%eax),%eax
c01097e0:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01097e3:	8b 12                	mov    (%edx),%edx
c01097e5:	89 55 f8             	mov    %edx,-0x8(%ebp)
c01097e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01097eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01097ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01097f1:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01097f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097f7:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01097fa:	89 10                	mov    %edx,(%eax)
    if (proc->optr != NULL) {
c01097fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01097ff:	8b 40 78             	mov    0x78(%eax),%eax
c0109802:	85 c0                	test   %eax,%eax
c0109804:	74 0f                	je     c0109815 <remove_links+0x4a>
        proc->optr->yptr = proc->yptr;
c0109806:	8b 45 08             	mov    0x8(%ebp),%eax
c0109809:	8b 40 78             	mov    0x78(%eax),%eax
c010980c:	8b 55 08             	mov    0x8(%ebp),%edx
c010980f:	8b 52 74             	mov    0x74(%edx),%edx
c0109812:	89 50 74             	mov    %edx,0x74(%eax)
    }
    if (proc->yptr != NULL) {
c0109815:	8b 45 08             	mov    0x8(%ebp),%eax
c0109818:	8b 40 74             	mov    0x74(%eax),%eax
c010981b:	85 c0                	test   %eax,%eax
c010981d:	74 11                	je     c0109830 <remove_links+0x65>
        proc->yptr->optr = proc->optr;
c010981f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109822:	8b 40 74             	mov    0x74(%eax),%eax
c0109825:	8b 55 08             	mov    0x8(%ebp),%edx
c0109828:	8b 52 78             	mov    0x78(%edx),%edx
c010982b:	89 50 78             	mov    %edx,0x78(%eax)
c010982e:	eb 0f                	jmp    c010983f <remove_links+0x74>
    }
    else {
       proc->parent->cptr = proc->optr;
c0109830:	8b 45 08             	mov    0x8(%ebp),%eax
c0109833:	8b 40 14             	mov    0x14(%eax),%eax
c0109836:	8b 55 08             	mov    0x8(%ebp),%edx
c0109839:	8b 52 78             	mov    0x78(%edx),%edx
c010983c:	89 50 70             	mov    %edx,0x70(%eax)
    }
    nr_process --;
c010983f:	a1 40 0e 1b c0       	mov    0xc01b0e40,%eax
c0109844:	83 e8 01             	sub    $0x1,%eax
c0109847:	a3 40 0e 1b c0       	mov    %eax,0xc01b0e40
}
c010984c:	c9                   	leave  
c010984d:	c3                   	ret    

c010984e <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c010984e:	55                   	push   %ebp
c010984f:	89 e5                	mov    %esp,%ebp
c0109851:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0109854:	c7 45 f8 70 0f 1b c0 	movl   $0xc01b0f70,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c010985b:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
c0109860:	83 c0 01             	add    $0x1,%eax
c0109863:	a3 80 ca 12 c0       	mov    %eax,0xc012ca80
c0109868:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
c010986d:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109872:	7e 0c                	jle    c0109880 <get_pid+0x32>
        last_pid = 1;
c0109874:	c7 05 80 ca 12 c0 01 	movl   $0x1,0xc012ca80
c010987b:	00 00 00 
        goto inside;
c010987e:	eb 13                	jmp    c0109893 <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c0109880:	8b 15 80 ca 12 c0    	mov    0xc012ca80,%edx
c0109886:	a1 84 ca 12 c0       	mov    0xc012ca84,%eax
c010988b:	39 c2                	cmp    %eax,%edx
c010988d:	0f 8c ac 00 00 00    	jl     c010993f <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c0109893:	c7 05 84 ca 12 c0 00 	movl   $0x2000,0xc012ca84
c010989a:	20 00 00 
    repeat:
        le = list;
c010989d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01098a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c01098a3:	eb 7f                	jmp    c0109924 <get_pid+0xd6>
            proc = le2proc(le, list_link);
c01098a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01098a8:	83 e8 58             	sub    $0x58,%eax
c01098ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c01098ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098b1:	8b 50 04             	mov    0x4(%eax),%edx
c01098b4:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
c01098b9:	39 c2                	cmp    %eax,%edx
c01098bb:	75 3e                	jne    c01098fb <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c01098bd:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
c01098c2:	83 c0 01             	add    $0x1,%eax
c01098c5:	a3 80 ca 12 c0       	mov    %eax,0xc012ca80
c01098ca:	8b 15 80 ca 12 c0    	mov    0xc012ca80,%edx
c01098d0:	a1 84 ca 12 c0       	mov    0xc012ca84,%eax
c01098d5:	39 c2                	cmp    %eax,%edx
c01098d7:	7c 4b                	jl     c0109924 <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c01098d9:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
c01098de:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01098e3:	7e 0a                	jle    c01098ef <get_pid+0xa1>
                        last_pid = 1;
c01098e5:	c7 05 80 ca 12 c0 01 	movl   $0x1,0xc012ca80
c01098ec:	00 00 00 
                    }
                    next_safe = MAX_PID;
c01098ef:	c7 05 84 ca 12 c0 00 	movl   $0x2000,0xc012ca84
c01098f6:	20 00 00 
                    goto repeat;
c01098f9:	eb a2                	jmp    c010989d <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c01098fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098fe:	8b 50 04             	mov    0x4(%eax),%edx
c0109901:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
c0109906:	39 c2                	cmp    %eax,%edx
c0109908:	7e 1a                	jle    c0109924 <get_pid+0xd6>
c010990a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010990d:	8b 50 04             	mov    0x4(%eax),%edx
c0109910:	a1 84 ca 12 c0       	mov    0xc012ca84,%eax
c0109915:	39 c2                	cmp    %eax,%edx
c0109917:	7d 0b                	jge    c0109924 <get_pid+0xd6>
                next_safe = proc->pid;
c0109919:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010991c:	8b 40 04             	mov    0x4(%eax),%eax
c010991f:	a3 84 ca 12 c0       	mov    %eax,0xc012ca84
c0109924:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109927:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010992a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010992d:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c0109930:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109933:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109936:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109939:	0f 85 66 ff ff ff    	jne    c01098a5 <get_pid+0x57>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c010993f:	a1 80 ca 12 c0       	mov    0xc012ca80,%eax
}
c0109944:	c9                   	leave  
c0109945:	c3                   	ret    

c0109946 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0109946:	55                   	push   %ebp
c0109947:	89 e5                	mov    %esp,%ebp
c0109949:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c010994c:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c0109951:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109954:	74 63                	je     c01099b9 <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0109956:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010995b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010995e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109961:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0109964:	e8 96 f9 ff ff       	call   c01092ff <__intr_save>
c0109969:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c010996c:	8b 45 08             	mov    0x8(%ebp),%eax
c010996f:	a3 28 ee 1a c0       	mov    %eax,0xc01aee28
            load_esp0(next->kstack + KSTACKSIZE);
c0109974:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109977:	8b 40 0c             	mov    0xc(%eax),%eax
c010997a:	05 00 20 00 00       	add    $0x2000,%eax
c010997f:	89 04 24             	mov    %eax,(%esp)
c0109982:	e8 98 b5 ff ff       	call   c0104f1f <load_esp0>
            lcr3(next->cr3);
c0109987:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010998a:	8b 40 40             	mov    0x40(%eax),%eax
c010998d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109990:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109993:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c0109996:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109999:	8d 50 1c             	lea    0x1c(%eax),%edx
c010999c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010999f:	83 c0 1c             	add    $0x1c,%eax
c01099a2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01099a6:	89 04 24             	mov    %eax,(%esp)
c01099a9:	e8 a0 15 00 00       	call   c010af4e <switch_to>
        }
        local_intr_restore(intr_flag);
c01099ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01099b1:	89 04 24             	mov    %eax,(%esp)
c01099b4:	e8 70 f9 ff ff       	call   c0109329 <__intr_restore>
    }
}
c01099b9:	c9                   	leave  
c01099ba:	c3                   	ret    

c01099bb <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c01099bb:	55                   	push   %ebp
c01099bc:	89 e5                	mov    %esp,%ebp
c01099be:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c01099c1:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c01099c6:	8b 40 3c             	mov    0x3c(%eax),%eax
c01099c9:	89 04 24             	mov    %eax,(%esp)
c01099cc:	e8 95 90 ff ff       	call   c0102a66 <forkrets>
}
c01099d1:	c9                   	leave  
c01099d2:	c3                   	ret    

c01099d3 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c01099d3:	55                   	push   %ebp
c01099d4:	89 e5                	mov    %esp,%ebp
c01099d6:	53                   	push   %ebx
c01099d7:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c01099da:	8b 45 08             	mov    0x8(%ebp),%eax
c01099dd:	8d 58 60             	lea    0x60(%eax),%ebx
c01099e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01099e3:	8b 40 04             	mov    0x4(%eax),%eax
c01099e6:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c01099ed:	00 
c01099ee:	89 04 24             	mov    %eax,(%esp)
c01099f1:	e8 7b 1d 00 00       	call   c010b771 <hash32>
c01099f6:	c1 e0 03             	shl    $0x3,%eax
c01099f9:	05 40 ee 1a c0       	add    $0xc01aee40,%eax
c01099fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109a01:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0109a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a07:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0109a10:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a13:	8b 40 04             	mov    0x4(%eax),%eax
c0109a16:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109a19:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109a1c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109a1f:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109a22:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0109a25:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109a28:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109a2b:	89 10                	mov    %edx,(%eax)
c0109a2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109a30:	8b 10                	mov    (%eax),%edx
c0109a32:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109a35:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109a38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109a3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109a3e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109a41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109a44:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109a47:	89 10                	mov    %edx,(%eax)
}
c0109a49:	83 c4 34             	add    $0x34,%esp
c0109a4c:	5b                   	pop    %ebx
c0109a4d:	5d                   	pop    %ebp
c0109a4e:	c3                   	ret    

c0109a4f <unhash_proc>:

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc) {
c0109a4f:	55                   	push   %ebp
c0109a50:	89 e5                	mov    %esp,%ebp
c0109a52:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->hash_link));
c0109a55:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a58:	83 c0 60             	add    $0x60,%eax
c0109a5b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0109a5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109a61:	8b 40 04             	mov    0x4(%eax),%eax
c0109a64:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109a67:	8b 12                	mov    (%edx),%edx
c0109a69:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109a6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0109a6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109a72:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109a75:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a7b:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109a7e:	89 10                	mov    %edx,(%eax)
}
c0109a80:	c9                   	leave  
c0109a81:	c3                   	ret    

c0109a82 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109a82:	55                   	push   %ebp
c0109a83:	89 e5                	mov    %esp,%ebp
c0109a85:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0109a88:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109a8c:	7e 5f                	jle    c0109aed <find_proc+0x6b>
c0109a8e:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109a95:	7f 56                	jg     c0109aed <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109a97:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a9a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109aa1:	00 
c0109aa2:	89 04 24             	mov    %eax,(%esp)
c0109aa5:	e8 c7 1c 00 00       	call   c010b771 <hash32>
c0109aaa:	c1 e0 03             	shl    $0x3,%eax
c0109aad:	05 40 ee 1a c0       	add    $0xc01aee40,%eax
c0109ab2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ab8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0109abb:	eb 19                	jmp    c0109ad6 <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0109abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ac0:	83 e8 60             	sub    $0x60,%eax
c0109ac3:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109ac6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ac9:	8b 40 04             	mov    0x4(%eax),%eax
c0109acc:	3b 45 08             	cmp    0x8(%ebp),%eax
c0109acf:	75 05                	jne    c0109ad6 <find_proc+0x54>
                return proc;
c0109ad1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ad4:	eb 1c                	jmp    c0109af2 <find_proc+0x70>
c0109ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ad9:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0109adc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109adf:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
c0109ae2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ae8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0109aeb:	75 d0                	jne    c0109abd <find_proc+0x3b>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c0109aed:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109af2:	c9                   	leave  
c0109af3:	c3                   	ret    

c0109af4 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0109af4:	55                   	push   %ebp
c0109af5:	89 e5                	mov    %esp,%ebp
c0109af7:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0109afa:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0109b01:	00 
c0109b02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109b09:	00 
c0109b0a:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109b0d:	89 04 24             	mov    %eax,(%esp)
c0109b10:	e8 09 27 00 00       	call   c010c21e <memset>
    tf.tf_cs = KERNEL_CS;
c0109b15:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109b1b:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109b21:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109b25:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109b29:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109b2d:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109b31:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b34:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109b37:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109b3a:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109b3d:	b8 b6 92 10 c0       	mov    $0xc01092b6,%eax
c0109b42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109b45:	8b 45 10             	mov    0x10(%ebp),%eax
c0109b48:	80 cc 01             	or     $0x1,%ah
c0109b4b:	89 c2                	mov    %eax,%edx
c0109b4d:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109b50:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109b54:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109b5b:	00 
c0109b5c:	89 14 24             	mov    %edx,(%esp)
c0109b5f:	e8 25 03 00 00       	call   c0109e89 <do_fork>
}
c0109b64:	c9                   	leave  
c0109b65:	c3                   	ret    

c0109b66 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109b66:	55                   	push   %ebp
c0109b67:	89 e5                	mov    %esp,%ebp
c0109b69:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109b6c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0109b73:	e8 f5 b4 ff ff       	call   c010506d <alloc_pages>
c0109b78:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109b7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109b7f:	74 1a                	je     c0109b9b <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0109b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b84:	89 04 24             	mov    %eax,(%esp)
c0109b87:	e8 9b f8 ff ff       	call   c0109427 <page2kva>
c0109b8c:	89 c2                	mov    %eax,%edx
c0109b8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b91:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109b94:	b8 00 00 00 00       	mov    $0x0,%eax
c0109b99:	eb 05                	jmp    c0109ba0 <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0109b9b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109ba0:	c9                   	leave  
c0109ba1:	c3                   	ret    

c0109ba2 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109ba2:	55                   	push   %ebp
c0109ba3:	89 e5                	mov    %esp,%ebp
c0109ba5:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0109ba8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bab:	8b 40 0c             	mov    0xc(%eax),%eax
c0109bae:	89 04 24             	mov    %eax,(%esp)
c0109bb1:	e8 c5 f8 ff ff       	call   c010947b <kva2page>
c0109bb6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109bbd:	00 
c0109bbe:	89 04 24             	mov    %eax,(%esp)
c0109bc1:	e8 12 b5 ff ff       	call   c01050d8 <free_pages>
}
c0109bc6:	c9                   	leave  
c0109bc7:	c3                   	ret    

c0109bc8 <setup_pgdir>:

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm) {
c0109bc8:	55                   	push   %ebp
c0109bc9:	89 e5                	mov    %esp,%ebp
c0109bcb:	83 ec 28             	sub    $0x28,%esp
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
c0109bce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109bd5:	e8 93 b4 ff ff       	call   c010506d <alloc_pages>
c0109bda:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109bdd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109be1:	75 0a                	jne    c0109bed <setup_pgdir+0x25>
        return -E_NO_MEM;
c0109be3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0109be8:	e9 80 00 00 00       	jmp    c0109c6d <setup_pgdir+0xa5>
    }
    pde_t *pgdir = page2kva(page);
c0109bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bf0:	89 04 24             	mov    %eax,(%esp)
c0109bf3:	e8 2f f8 ff ff       	call   c0109427 <page2kva>
c0109bf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memcpy(pgdir, boot_pgdir, PGSIZE);
c0109bfb:	a1 84 ed 1a c0       	mov    0xc01aed84,%eax
c0109c00:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0109c07:	00 
c0109c08:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c0f:	89 04 24             	mov    %eax,(%esp)
c0109c12:	e8 e9 26 00 00       	call   c010c300 <memcpy>
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
c0109c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c1a:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0109c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c23:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109c26:	81 7d ec ff ff ff bf 	cmpl   $0xbfffffff,-0x14(%ebp)
c0109c2d:	77 23                	ja     c0109c52 <setup_pgdir+0x8a>
c0109c2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c32:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109c36:	c7 44 24 08 54 e4 10 	movl   $0xc010e454,0x8(%esp)
c0109c3d:	c0 
c0109c3e:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c0109c45:	00 
c0109c46:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c0109c4d:	e8 88 71 ff ff       	call   c0100dda <__panic>
c0109c52:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c55:	05 00 00 00 40       	add    $0x40000000,%eax
c0109c5a:	83 c8 03             	or     $0x3,%eax
c0109c5d:	89 02                	mov    %eax,(%edx)
    mm->pgdir = pgdir;
c0109c5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c62:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109c65:	89 50 0c             	mov    %edx,0xc(%eax)
    return 0;
c0109c68:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109c6d:	c9                   	leave  
c0109c6e:	c3                   	ret    

c0109c6f <put_pgdir>:

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm) {
c0109c6f:	55                   	push   %ebp
c0109c70:	89 e5                	mov    %esp,%ebp
c0109c72:	83 ec 18             	sub    $0x18,%esp
    free_page(kva2page(mm->pgdir));
c0109c75:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c78:	8b 40 0c             	mov    0xc(%eax),%eax
c0109c7b:	89 04 24             	mov    %eax,(%esp)
c0109c7e:	e8 f8 f7 ff ff       	call   c010947b <kva2page>
c0109c83:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109c8a:	00 
c0109c8b:	89 04 24             	mov    %eax,(%esp)
c0109c8e:	e8 45 b4 ff ff       	call   c01050d8 <free_pages>
}
c0109c93:	c9                   	leave  
c0109c94:	c3                   	ret    

c0109c95 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109c95:	55                   	push   %ebp
c0109c96:	89 e5                	mov    %esp,%ebp
c0109c98:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm, *oldmm = current->mm;
c0109c9b:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c0109ca0:	8b 40 18             	mov    0x18(%eax),%eax
c0109ca3:	89 45 ec             	mov    %eax,-0x14(%ebp)

    /* current is a kernel thread */
    if (oldmm == NULL) {
c0109ca6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109caa:	75 0a                	jne    c0109cb6 <copy_mm+0x21>
        return 0;
c0109cac:	b8 00 00 00 00       	mov    $0x0,%eax
c0109cb1:	e9 f9 00 00 00       	jmp    c0109daf <copy_mm+0x11a>
    }
    if (clone_flags & CLONE_VM) {
c0109cb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cb9:	25 00 01 00 00       	and    $0x100,%eax
c0109cbe:	85 c0                	test   %eax,%eax
c0109cc0:	74 08                	je     c0109cca <copy_mm+0x35>
        mm = oldmm;
c0109cc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109cc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto good_mm;
c0109cc8:	eb 78                	jmp    c0109d42 <copy_mm+0xad>
    }

    int ret = -E_NO_MEM;
c0109cca:	c7 45 f0 fc ff ff ff 	movl   $0xfffffffc,-0x10(%ebp)
    if ((mm = mm_create()) == NULL) {
c0109cd1:	e8 36 e2 ff ff       	call   c0107f0c <mm_create>
c0109cd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109cd9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109cdd:	75 05                	jne    c0109ce4 <copy_mm+0x4f>
        goto bad_mm;
c0109cdf:	e9 c8 00 00 00       	jmp    c0109dac <copy_mm+0x117>
    }
    if (setup_pgdir(mm) != 0) {
c0109ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ce7:	89 04 24             	mov    %eax,(%esp)
c0109cea:	e8 d9 fe ff ff       	call   c0109bc8 <setup_pgdir>
c0109cef:	85 c0                	test   %eax,%eax
c0109cf1:	74 05                	je     c0109cf8 <copy_mm+0x63>
        goto bad_pgdir_cleanup_mm;
c0109cf3:	e9 a9 00 00 00       	jmp    c0109da1 <copy_mm+0x10c>
    }

    lock_mm(oldmm);
c0109cf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109cfb:	89 04 24             	mov    %eax,(%esp)
c0109cfe:	e8 f6 f7 ff ff       	call   c01094f9 <lock_mm>
    {
        ret = dup_mmap(mm, oldmm);
c0109d03:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d06:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d0d:	89 04 24             	mov    %eax,(%esp)
c0109d10:	e8 0e e7 ff ff       	call   c0108423 <dup_mmap>
c0109d15:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    unlock_mm(oldmm);
c0109d18:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d1b:	89 04 24             	mov    %eax,(%esp)
c0109d1e:	e8 f2 f7 ff ff       	call   c0109515 <unlock_mm>

    if (ret != 0) {
c0109d23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109d27:	74 19                	je     c0109d42 <copy_mm+0xad>
        goto bad_dup_cleanup_mmap;
c0109d29:	90                   	nop
    mm_count_inc(mm);
    proc->mm = mm;
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
c0109d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d2d:	89 04 24             	mov    %eax,(%esp)
c0109d30:	e8 ef e7 ff ff       	call   c0108524 <exit_mmap>
    put_pgdir(mm);
c0109d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d38:	89 04 24             	mov    %eax,(%esp)
c0109d3b:	e8 2f ff ff ff       	call   c0109c6f <put_pgdir>
c0109d40:	eb 5f                	jmp    c0109da1 <copy_mm+0x10c>
    if (ret != 0) {
        goto bad_dup_cleanup_mmap;
    }

good_mm:
    mm_count_inc(mm);
c0109d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d45:	89 04 24             	mov    %eax,(%esp)
c0109d48:	e8 78 f7 ff ff       	call   c01094c5 <mm_count_inc>
    proc->mm = mm;
c0109d4d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d50:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109d53:	89 50 18             	mov    %edx,0x18(%eax)
    proc->cr3 = PADDR(mm->pgdir);
c0109d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d59:	8b 40 0c             	mov    0xc(%eax),%eax
c0109d5c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109d5f:	81 7d e8 ff ff ff bf 	cmpl   $0xbfffffff,-0x18(%ebp)
c0109d66:	77 23                	ja     c0109d8b <copy_mm+0xf6>
c0109d68:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109d6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109d6f:	c7 44 24 08 54 e4 10 	movl   $0xc010e454,0x8(%esp)
c0109d76:	c0 
c0109d77:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
c0109d7e:	00 
c0109d7f:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c0109d86:	e8 4f 70 ff ff       	call   c0100dda <__panic>
c0109d8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109d8e:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109d94:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d97:	89 50 40             	mov    %edx,0x40(%eax)
    return 0;
c0109d9a:	b8 00 00 00 00       	mov    $0x0,%eax
c0109d9f:	eb 0e                	jmp    c0109daf <copy_mm+0x11a>
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c0109da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109da4:	89 04 24             	mov    %eax,(%esp)
c0109da7:	e8 b9 e4 ff ff       	call   c0108265 <mm_destroy>
bad_mm:
    return ret;
c0109dac:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0109daf:	c9                   	leave  
c0109db0:	c3                   	ret    

c0109db1 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0109db1:	55                   	push   %ebp
c0109db2:	89 e5                	mov    %esp,%ebp
c0109db4:	57                   	push   %edi
c0109db5:	56                   	push   %esi
c0109db6:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0109db7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dba:	8b 40 0c             	mov    0xc(%eax),%eax
c0109dbd:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0109dc2:	89 c2                	mov    %eax,%edx
c0109dc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dc7:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0109dca:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dcd:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109dd0:	8b 55 10             	mov    0x10(%ebp),%edx
c0109dd3:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0109dd8:	89 c1                	mov    %eax,%ecx
c0109dda:	83 e1 01             	and    $0x1,%ecx
c0109ddd:	85 c9                	test   %ecx,%ecx
c0109ddf:	74 0e                	je     c0109def <copy_thread+0x3e>
c0109de1:	0f b6 0a             	movzbl (%edx),%ecx
c0109de4:	88 08                	mov    %cl,(%eax)
c0109de6:	83 c0 01             	add    $0x1,%eax
c0109de9:	83 c2 01             	add    $0x1,%edx
c0109dec:	83 eb 01             	sub    $0x1,%ebx
c0109def:	89 c1                	mov    %eax,%ecx
c0109df1:	83 e1 02             	and    $0x2,%ecx
c0109df4:	85 c9                	test   %ecx,%ecx
c0109df6:	74 0f                	je     c0109e07 <copy_thread+0x56>
c0109df8:	0f b7 0a             	movzwl (%edx),%ecx
c0109dfb:	66 89 08             	mov    %cx,(%eax)
c0109dfe:	83 c0 02             	add    $0x2,%eax
c0109e01:	83 c2 02             	add    $0x2,%edx
c0109e04:	83 eb 02             	sub    $0x2,%ebx
c0109e07:	89 d9                	mov    %ebx,%ecx
c0109e09:	c1 e9 02             	shr    $0x2,%ecx
c0109e0c:	89 c7                	mov    %eax,%edi
c0109e0e:	89 d6                	mov    %edx,%esi
c0109e10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109e12:	89 f2                	mov    %esi,%edx
c0109e14:	89 f8                	mov    %edi,%eax
c0109e16:	b9 00 00 00 00       	mov    $0x0,%ecx
c0109e1b:	89 de                	mov    %ebx,%esi
c0109e1d:	83 e6 02             	and    $0x2,%esi
c0109e20:	85 f6                	test   %esi,%esi
c0109e22:	74 0b                	je     c0109e2f <copy_thread+0x7e>
c0109e24:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0109e28:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0109e2c:	83 c1 02             	add    $0x2,%ecx
c0109e2f:	83 e3 01             	and    $0x1,%ebx
c0109e32:	85 db                	test   %ebx,%ebx
c0109e34:	74 07                	je     c0109e3d <copy_thread+0x8c>
c0109e36:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0109e3a:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0109e3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e40:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109e43:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0109e4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e4d:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109e50:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109e53:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0109e56:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e59:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109e5c:	8b 55 08             	mov    0x8(%ebp),%edx
c0109e5f:	8b 52 3c             	mov    0x3c(%edx),%edx
c0109e62:	8b 52 40             	mov    0x40(%edx),%edx
c0109e65:	80 ce 02             	or     $0x2,%dh
c0109e68:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0109e6b:	ba bb 99 10 c0       	mov    $0xc01099bb,%edx
c0109e70:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e73:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0109e76:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e79:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109e7c:	89 c2                	mov    %eax,%edx
c0109e7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e81:	89 50 20             	mov    %edx,0x20(%eax)
}
c0109e84:	5b                   	pop    %ebx
c0109e85:	5e                   	pop    %esi
c0109e86:	5f                   	pop    %edi
c0109e87:	5d                   	pop    %ebp
c0109e88:	c3                   	ret    

c0109e89 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0109e89:	55                   	push   %ebp
c0109e8a:	89 e5                	mov    %esp,%ebp
c0109e8c:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_NO_FREE_PROC;
c0109e8f:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0109e96:	a1 40 0e 1b c0       	mov    0xc01b0e40,%eax
c0109e9b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0109ea0:	7e 05                	jle    c0109ea7 <do_fork+0x1e>
        goto fork_out;
c0109ea2:	e9 fc 00 00 00       	jmp    c0109fa3 <do_fork+0x11a>
    }
    ret = -E_NO_MEM;
c0109ea7:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process 
    *    -------------------
	*    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
	*    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
    */
    proc = alloc_proc();
c0109eae:	e8 7e f6 ff ff       	call   c0109531 <alloc_proc>
c0109eb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (proc == NULL)
c0109eb6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109eba:	75 05                	jne    c0109ec1 <do_fork+0x38>
        goto fork_out;
c0109ebc:	e9 e2 00 00 00       	jmp    c0109fa3 <do_fork+0x11a>

    int ret2;
    ret2 = setup_kstack(proc);
c0109ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ec4:	89 04 24             	mov    %eax,(%esp)
c0109ec7:	e8 9a fc ff ff       	call   c0109b66 <setup_kstack>
c0109ecc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (ret2 != 0)
c0109ecf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109ed3:	74 05                	je     c0109eda <do_fork+0x51>
        goto bad_fork_cleanup_proc;
c0109ed5:	e9 ce 00 00 00       	jmp    c0109fa8 <do_fork+0x11f>

    ret2 = copy_mm(clone_flags, proc);
c0109eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109edd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ee1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ee4:	89 04 24             	mov    %eax,(%esp)
c0109ee7:	e8 a9 fd ff ff       	call   c0109c95 <copy_mm>
c0109eec:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (ret2 != 0)
c0109eef:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109ef3:	74 11                	je     c0109f06 <do_fork+0x7d>
        goto bad_fork_cleanup_kstack;
c0109ef5:	90                   	nop
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c0109ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ef9:	89 04 24             	mov    %eax,(%esp)
c0109efc:	e8 a1 fc ff ff       	call   c0109ba2 <put_kstack>
c0109f01:	e9 a2 00 00 00       	jmp    c0109fa8 <do_fork+0x11f>

    ret2 = copy_mm(clone_flags, proc);
    if (ret2 != 0)
        goto bad_fork_cleanup_kstack;

    copy_thread(proc, stack, tf);
c0109f06:	8b 45 10             	mov    0x10(%ebp),%eax
c0109f09:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109f14:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f17:	89 04 24             	mov    %eax,(%esp)
c0109f1a:	e8 92 fe ff ff       	call   c0109db1 <copy_thread>

    bool intr_flag;
    local_intr_save(intr_flag);
c0109f1f:	e8 db f3 ff ff       	call   c01092ff <__intr_save>
c0109f24:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        proc->pid = get_pid();
c0109f27:	e8 22 f9 ff ff       	call   c010984e <get_pid>
c0109f2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109f2f:	89 42 04             	mov    %eax,0x4(%edx)
        proc->parent = current;
c0109f32:	8b 15 28 ee 1a c0    	mov    0xc01aee28,%edx
c0109f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f3b:	89 50 14             	mov    %edx,0x14(%eax)
        assert(current->wait_state == 0);
c0109f3e:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c0109f43:	8b 40 6c             	mov    0x6c(%eax),%eax
c0109f46:	85 c0                	test   %eax,%eax
c0109f48:	74 24                	je     c0109f6e <do_fork+0xe5>
c0109f4a:	c7 44 24 0c 8c e4 10 	movl   $0xc010e48c,0xc(%esp)
c0109f51:	c0 
c0109f52:	c7 44 24 08 a5 e4 10 	movl   $0xc010e4a5,0x8(%esp)
c0109f59:	c0 
c0109f5a:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
c0109f61:	00 
c0109f62:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c0109f69:	e8 6c 6e ff ff       	call   c0100dda <__panic>

        set_links(proc);
c0109f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f71:	89 04 24             	mov    %eax,(%esp)
c0109f74:	e8 ad f7 ff ff       	call   c0109726 <set_links>
        hash_proc(proc);
c0109f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f7c:	89 04 24             	mov    %eax,(%esp)
c0109f7f:	e8 4f fa ff ff       	call   c01099d3 <hash_proc>
    }
    local_intr_restore(intr_flag);
c0109f84:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109f87:	89 04 24             	mov    %eax,(%esp)
c0109f8a:	e8 9a f3 ff ff       	call   c0109329 <__intr_restore>

    wakeup_proc(proc);
c0109f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f92:	89 04 24             	mov    %eax,(%esp)
c0109f95:	e8 8f 14 00 00       	call   c010b429 <wakeup_proc>

    ret = proc->pid;
c0109f9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f9d:	8b 40 04             	mov    0x4(%eax),%eax
c0109fa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
fork_out:
    return ret;
c0109fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fa6:	eb 0d                	jmp    c0109fb5 <do_fork+0x12c>

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
c0109fa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109fab:	89 04 24             	mov    %eax,(%esp)
c0109fae:	e8 60 ac ff ff       	call   c0104c13 <kfree>
    goto fork_out;
c0109fb3:	eb ee                	jmp    c0109fa3 <do_fork+0x11a>
}
c0109fb5:	c9                   	leave  
c0109fb6:	c3                   	ret    

c0109fb7 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c0109fb7:	55                   	push   %ebp
c0109fb8:	89 e5                	mov    %esp,%ebp
c0109fba:	83 ec 28             	sub    $0x28,%esp
    if (current == idleproc) {
c0109fbd:	8b 15 28 ee 1a c0    	mov    0xc01aee28,%edx
c0109fc3:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c0109fc8:	39 c2                	cmp    %eax,%edx
c0109fca:	75 1c                	jne    c0109fe8 <do_exit+0x31>
        panic("idleproc exit.\n");
c0109fcc:	c7 44 24 08 ba e4 10 	movl   $0xc010e4ba,0x8(%esp)
c0109fd3:	c0 
c0109fd4:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c0109fdb:	00 
c0109fdc:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c0109fe3:	e8 f2 6d ff ff       	call   c0100dda <__panic>
    }
    if (current == initproc) {
c0109fe8:	8b 15 28 ee 1a c0    	mov    0xc01aee28,%edx
c0109fee:	a1 24 ee 1a c0       	mov    0xc01aee24,%eax
c0109ff3:	39 c2                	cmp    %eax,%edx
c0109ff5:	75 1c                	jne    c010a013 <do_exit+0x5c>
        panic("initproc exit.\n");
c0109ff7:	c7 44 24 08 ca e4 10 	movl   $0xc010e4ca,0x8(%esp)
c0109ffe:	c0 
c0109fff:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c010a006:	00 
c010a007:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010a00e:	e8 c7 6d ff ff       	call   c0100dda <__panic>
    }
    
    struct mm_struct *mm = current->mm;
c010a013:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a018:	8b 40 18             	mov    0x18(%eax),%eax
c010a01b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (mm != NULL) {
c010a01e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a022:	74 4a                	je     c010a06e <do_exit+0xb7>
        lcr3(boot_cr3);
c010a024:	a1 8c 0e 1b c0       	mov    0xc01b0e8c,%eax
c010a029:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a02c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a02f:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a032:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a035:	89 04 24             	mov    %eax,(%esp)
c010a038:	e8 a2 f4 ff ff       	call   c01094df <mm_count_dec>
c010a03d:	85 c0                	test   %eax,%eax
c010a03f:	75 21                	jne    c010a062 <do_exit+0xab>
            exit_mmap(mm);
c010a041:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a044:	89 04 24             	mov    %eax,(%esp)
c010a047:	e8 d8 e4 ff ff       	call   c0108524 <exit_mmap>
            put_pgdir(mm);
c010a04c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a04f:	89 04 24             	mov    %eax,(%esp)
c010a052:	e8 18 fc ff ff       	call   c0109c6f <put_pgdir>
            mm_destroy(mm);
c010a057:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a05a:	89 04 24             	mov    %eax,(%esp)
c010a05d:	e8 03 e2 ff ff       	call   c0108265 <mm_destroy>
        }
        current->mm = NULL;
c010a062:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a067:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    current->state = PROC_ZOMBIE;
c010a06e:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a073:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
    current->exit_code = error_code;
c010a079:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a07e:	8b 55 08             	mov    0x8(%ebp),%edx
c010a081:	89 50 68             	mov    %edx,0x68(%eax)
    
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c010a084:	e8 76 f2 ff ff       	call   c01092ff <__intr_save>
c010a089:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        proc = current->parent;
c010a08c:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a091:	8b 40 14             	mov    0x14(%eax),%eax
c010a094:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (proc->wait_state == WT_CHILD) {
c010a097:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a09a:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a09d:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a0a2:	75 10                	jne    c010a0b4 <do_exit+0xfd>
            wakeup_proc(proc);
c010a0a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a0a7:	89 04 24             	mov    %eax,(%esp)
c010a0aa:	e8 7a 13 00 00       	call   c010b429 <wakeup_proc>
        }
        while (current->cptr != NULL) {
c010a0af:	e9 8b 00 00 00       	jmp    c010a13f <do_exit+0x188>
c010a0b4:	e9 86 00 00 00       	jmp    c010a13f <do_exit+0x188>
            proc = current->cptr;
c010a0b9:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a0be:	8b 40 70             	mov    0x70(%eax),%eax
c010a0c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
            current->cptr = proc->optr;
c010a0c4:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a0c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a0cc:	8b 52 78             	mov    0x78(%edx),%edx
c010a0cf:	89 50 70             	mov    %edx,0x70(%eax)
    
            proc->yptr = NULL;
c010a0d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a0d5:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
            if ((proc->optr = initproc->cptr) != NULL) {
c010a0dc:	a1 24 ee 1a c0       	mov    0xc01aee24,%eax
c010a0e1:	8b 50 70             	mov    0x70(%eax),%edx
c010a0e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a0e7:	89 50 78             	mov    %edx,0x78(%eax)
c010a0ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a0ed:	8b 40 78             	mov    0x78(%eax),%eax
c010a0f0:	85 c0                	test   %eax,%eax
c010a0f2:	74 0e                	je     c010a102 <do_exit+0x14b>
                initproc->cptr->yptr = proc;
c010a0f4:	a1 24 ee 1a c0       	mov    0xc01aee24,%eax
c010a0f9:	8b 40 70             	mov    0x70(%eax),%eax
c010a0fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a0ff:	89 50 74             	mov    %edx,0x74(%eax)
            }
            proc->parent = initproc;
c010a102:	8b 15 24 ee 1a c0    	mov    0xc01aee24,%edx
c010a108:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a10b:	89 50 14             	mov    %edx,0x14(%eax)
            initproc->cptr = proc;
c010a10e:	a1 24 ee 1a c0       	mov    0xc01aee24,%eax
c010a113:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a116:	89 50 70             	mov    %edx,0x70(%eax)
            if (proc->state == PROC_ZOMBIE) {
c010a119:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a11c:	8b 00                	mov    (%eax),%eax
c010a11e:	83 f8 03             	cmp    $0x3,%eax
c010a121:	75 1c                	jne    c010a13f <do_exit+0x188>
                if (initproc->wait_state == WT_CHILD) {
c010a123:	a1 24 ee 1a c0       	mov    0xc01aee24,%eax
c010a128:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a12b:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a130:	75 0d                	jne    c010a13f <do_exit+0x188>
                    wakeup_proc(initproc);
c010a132:	a1 24 ee 1a c0       	mov    0xc01aee24,%eax
c010a137:	89 04 24             	mov    %eax,(%esp)
c010a13a:	e8 ea 12 00 00       	call   c010b429 <wakeup_proc>
    {
        proc = current->parent;
        if (proc->wait_state == WT_CHILD) {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL) {
c010a13f:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a144:	8b 40 70             	mov    0x70(%eax),%eax
c010a147:	85 c0                	test   %eax,%eax
c010a149:	0f 85 6a ff ff ff    	jne    c010a0b9 <do_exit+0x102>
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
c010a14f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a152:	89 04 24             	mov    %eax,(%esp)
c010a155:	e8 cf f1 ff ff       	call   c0109329 <__intr_restore>
    
    schedule();
c010a15a:	e8 63 13 00 00       	call   c010b4c2 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c010a15f:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a164:	8b 40 04             	mov    0x4(%eax),%eax
c010a167:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a16b:	c7 44 24 08 dc e4 10 	movl   $0xc010e4dc,0x8(%esp)
c010a172:	c0 
c010a173:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c010a17a:	00 
c010a17b:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010a182:	e8 53 6c ff ff       	call   c0100dda <__panic>

c010a187 <load_icode>:
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {
c010a187:	55                   	push   %ebp
c010a188:	89 e5                	mov    %esp,%ebp
c010a18a:	83 ec 78             	sub    $0x78,%esp
    if (current->mm != NULL) {
c010a18d:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a192:	8b 40 18             	mov    0x18(%eax),%eax
c010a195:	85 c0                	test   %eax,%eax
c010a197:	74 1c                	je     c010a1b5 <load_icode+0x2e>
        panic("load_icode: current->mm must be empty.\n");
c010a199:	c7 44 24 08 fc e4 10 	movl   $0xc010e4fc,0x8(%esp)
c010a1a0:	c0 
c010a1a1:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c010a1a8:	00 
c010a1a9:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010a1b0:	e8 25 6c ff ff       	call   c0100dda <__panic>
    }

    int ret = -E_NO_MEM;
c010a1b5:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
c010a1bc:	e8 4b dd ff ff       	call   c0107f0c <mm_create>
c010a1c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a1c4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010a1c8:	75 06                	jne    c010a1d0 <load_icode+0x49>
        goto bad_mm;
c010a1ca:	90                   	nop
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
c010a1cb:	e9 ef 05 00 00       	jmp    c010a7bf <load_icode+0x638>
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
c010a1d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a1d3:	89 04 24             	mov    %eax,(%esp)
c010a1d6:	e8 ed f9 ff ff       	call   c0109bc8 <setup_pgdir>
c010a1db:	85 c0                	test   %eax,%eax
c010a1dd:	74 05                	je     c010a1e4 <load_icode+0x5d>
        goto bad_pgdir_cleanup_mm;
c010a1df:	e9 f6 05 00 00       	jmp    c010a7da <load_icode+0x653>
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
c010a1e4:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
c010a1ea:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a1ed:	8b 50 1c             	mov    0x1c(%eax),%edx
c010a1f0:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1f3:	01 d0                	add    %edx,%eax
c010a1f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
c010a1f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a1fb:	8b 00                	mov    (%eax),%eax
c010a1fd:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
c010a202:	74 0c                	je     c010a210 <load_icode+0x89>
        ret = -E_INVAL_ELF;
c010a204:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
        goto bad_elf_cleanup_pgdir;
c010a20b:	e9 bf 05 00 00       	jmp    c010a7cf <load_icode+0x648>
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
c010a210:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a213:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010a217:	0f b7 c0             	movzwl %ax,%eax
c010a21a:	c1 e0 05             	shl    $0x5,%eax
c010a21d:	89 c2                	mov    %eax,%edx
c010a21f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a222:	01 d0                	add    %edx,%eax
c010a224:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; ph < ph_end; ph ++) {
c010a227:	e9 13 03 00 00       	jmp    c010a53f <load_icode+0x3b8>
    //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
c010a22c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a22f:	8b 00                	mov    (%eax),%eax
c010a231:	83 f8 01             	cmp    $0x1,%eax
c010a234:	74 05                	je     c010a23b <load_icode+0xb4>
            continue ;
c010a236:	e9 00 03 00 00       	jmp    c010a53b <load_icode+0x3b4>
        }
        if (ph->p_filesz > ph->p_memsz) {
c010a23b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a23e:	8b 50 10             	mov    0x10(%eax),%edx
c010a241:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a244:	8b 40 14             	mov    0x14(%eax),%eax
c010a247:	39 c2                	cmp    %eax,%edx
c010a249:	76 0c                	jbe    c010a257 <load_icode+0xd0>
            ret = -E_INVAL_ELF;
c010a24b:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
            goto bad_cleanup_mmap;
c010a252:	e9 6d 05 00 00       	jmp    c010a7c4 <load_icode+0x63d>
        }
        if (ph->p_filesz == 0) {
c010a257:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a25a:	8b 40 10             	mov    0x10(%eax),%eax
c010a25d:	85 c0                	test   %eax,%eax
c010a25f:	75 05                	jne    c010a266 <load_icode+0xdf>
            continue ;
c010a261:	e9 d5 02 00 00       	jmp    c010a53b <load_icode+0x3b4>
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U;
c010a266:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010a26d:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
c010a274:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a277:	8b 40 18             	mov    0x18(%eax),%eax
c010a27a:	83 e0 01             	and    $0x1,%eax
c010a27d:	85 c0                	test   %eax,%eax
c010a27f:	74 04                	je     c010a285 <load_icode+0xfe>
c010a281:	83 4d e8 04          	orl    $0x4,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
c010a285:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a288:	8b 40 18             	mov    0x18(%eax),%eax
c010a28b:	83 e0 02             	and    $0x2,%eax
c010a28e:	85 c0                	test   %eax,%eax
c010a290:	74 04                	je     c010a296 <load_icode+0x10f>
c010a292:	83 4d e8 02          	orl    $0x2,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
c010a296:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a299:	8b 40 18             	mov    0x18(%eax),%eax
c010a29c:	83 e0 04             	and    $0x4,%eax
c010a29f:	85 c0                	test   %eax,%eax
c010a2a1:	74 04                	je     c010a2a7 <load_icode+0x120>
c010a2a3:	83 4d e8 01          	orl    $0x1,-0x18(%ebp)
        if (vm_flags & VM_WRITE) perm |= PTE_W;
c010a2a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a2aa:	83 e0 02             	and    $0x2,%eax
c010a2ad:	85 c0                	test   %eax,%eax
c010a2af:	74 04                	je     c010a2b5 <load_icode+0x12e>
c010a2b1:	83 4d e4 02          	orl    $0x2,-0x1c(%ebp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
c010a2b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2b8:	8b 50 14             	mov    0x14(%eax),%edx
c010a2bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2be:	8b 40 08             	mov    0x8(%eax),%eax
c010a2c1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a2c8:	00 
c010a2c9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010a2cc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010a2d0:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a2d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a2d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a2db:	89 04 24             	mov    %eax,(%esp)
c010a2de:	e8 24 e0 ff ff       	call   c0108307 <mm_map>
c010a2e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a2e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a2ea:	74 05                	je     c010a2f1 <load_icode+0x16a>
            goto bad_cleanup_mmap;
c010a2ec:	e9 d3 04 00 00       	jmp    c010a7c4 <load_icode+0x63d>
        }
        unsigned char *from = binary + ph->p_offset;
c010a2f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2f4:	8b 50 04             	mov    0x4(%eax),%edx
c010a2f7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a2fa:	01 d0                	add    %edx,%eax
c010a2fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
c010a2ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a302:	8b 40 08             	mov    0x8(%eax),%eax
c010a305:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a308:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a30b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010a30e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a311:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010a316:	89 45 d4             	mov    %eax,-0x2c(%ebp)

        ret = -E_NO_MEM;
c010a319:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
c010a320:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a323:	8b 50 08             	mov    0x8(%eax),%edx
c010a326:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a329:	8b 40 10             	mov    0x10(%eax),%eax
c010a32c:	01 d0                	add    %edx,%eax
c010a32e:	89 45 c0             	mov    %eax,-0x40(%ebp)
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a331:	e9 90 00 00 00       	jmp    c010a3c6 <load_icode+0x23f>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a336:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a339:	8b 40 0c             	mov    0xc(%eax),%eax
c010a33c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a33f:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a343:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a346:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a34a:	89 04 24             	mov    %eax,(%esp)
c010a34d:	e8 06 bc ff ff       	call   c0105f58 <pgdir_alloc_page>
c010a352:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a355:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a359:	75 05                	jne    c010a360 <load_icode+0x1d9>
                goto bad_cleanup_mmap;
c010a35b:	e9 64 04 00 00       	jmp    c010a7c4 <load_icode+0x63d>
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a360:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a363:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a366:	29 c2                	sub    %eax,%edx
c010a368:	89 d0                	mov    %edx,%eax
c010a36a:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a36d:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a372:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a375:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a378:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a37f:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a382:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a385:	73 0d                	jae    c010a394 <load_icode+0x20d>
                size -= la - end;
c010a387:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a38a:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a38d:	29 c2                	sub    %eax,%edx
c010a38f:	89 d0                	mov    %edx,%eax
c010a391:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memcpy(page2kva(page) + off, from, size);
c010a394:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a397:	89 04 24             	mov    %eax,(%esp)
c010a39a:	e8 88 f0 ff ff       	call   c0109427 <page2kva>
c010a39f:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a3a2:	01 c2                	add    %eax,%edx
c010a3a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a3a7:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a3ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a3ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a3b2:	89 14 24             	mov    %edx,(%esp)
c010a3b5:	e8 46 1f 00 00       	call   c010c300 <memcpy>
            start += size, from += size;
c010a3ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a3bd:	01 45 d8             	add    %eax,-0x28(%ebp)
c010a3c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a3c3:	01 45 e0             	add    %eax,-0x20(%ebp)
        ret = -E_NO_MEM;

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a3c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a3c9:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a3cc:	0f 82 64 ff ff ff    	jb     c010a336 <load_icode+0x1af>
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }

      //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
c010a3d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3d5:	8b 50 08             	mov    0x8(%eax),%edx
c010a3d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3db:	8b 40 14             	mov    0x14(%eax),%eax
c010a3de:	01 d0                	add    %edx,%eax
c010a3e0:	89 45 c0             	mov    %eax,-0x40(%ebp)
        if (start < la) {
c010a3e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a3e6:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a3e9:	0f 83 b0 00 00 00    	jae    c010a49f <load_icode+0x318>
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
c010a3ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a3f2:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a3f5:	75 05                	jne    c010a3fc <load_icode+0x275>
                continue ;
c010a3f7:	e9 3f 01 00 00       	jmp    c010a53b <load_icode+0x3b4>
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
c010a3fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a3ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a402:	29 c2                	sub    %eax,%edx
c010a404:	89 d0                	mov    %edx,%eax
c010a406:	05 00 10 00 00       	add    $0x1000,%eax
c010a40b:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a40e:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a413:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a416:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (end < la) {
c010a419:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a41c:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a41f:	73 0d                	jae    c010a42e <load_icode+0x2a7>
                size -= la - end;
c010a421:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a424:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a427:	29 c2                	sub    %eax,%edx
c010a429:	89 d0                	mov    %edx,%eax
c010a42b:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a42e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a431:	89 04 24             	mov    %eax,(%esp)
c010a434:	e8 ee ef ff ff       	call   c0109427 <page2kva>
c010a439:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a43c:	01 c2                	add    %eax,%edx
c010a43e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a441:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a445:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a44c:	00 
c010a44d:	89 14 24             	mov    %edx,(%esp)
c010a450:	e8 c9 1d 00 00       	call   c010c21e <memset>
            start += size;
c010a455:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a458:	01 45 d8             	add    %eax,-0x28(%ebp)
            assert((end < la && start == end) || (end >= la && start == la));
c010a45b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a45e:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a461:	73 08                	jae    c010a46b <load_icode+0x2e4>
c010a463:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a466:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a469:	74 34                	je     c010a49f <load_icode+0x318>
c010a46b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a46e:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a471:	72 08                	jb     c010a47b <load_icode+0x2f4>
c010a473:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a476:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a479:	74 24                	je     c010a49f <load_icode+0x318>
c010a47b:	c7 44 24 0c 24 e5 10 	movl   $0xc010e524,0xc(%esp)
c010a482:	c0 
c010a483:	c7 44 24 08 a5 e4 10 	movl   $0xc010e4a5,0x8(%esp)
c010a48a:	c0 
c010a48b:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
c010a492:	00 
c010a493:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010a49a:	e8 3b 69 ff ff       	call   c0100dda <__panic>
        }
        while (start < end) {
c010a49f:	e9 8b 00 00 00       	jmp    c010a52f <load_icode+0x3a8>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a4a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a4a7:	8b 40 0c             	mov    0xc(%eax),%eax
c010a4aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a4ad:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a4b1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a4b4:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a4b8:	89 04 24             	mov    %eax,(%esp)
c010a4bb:	e8 98 ba ff ff       	call   c0105f58 <pgdir_alloc_page>
c010a4c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a4c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a4c7:	75 05                	jne    c010a4ce <load_icode+0x347>
                goto bad_cleanup_mmap;
c010a4c9:	e9 f6 02 00 00       	jmp    c010a7c4 <load_icode+0x63d>
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a4ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a4d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a4d4:	29 c2                	sub    %eax,%edx
c010a4d6:	89 d0                	mov    %edx,%eax
c010a4d8:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a4db:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a4e0:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a4e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a4e6:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a4ed:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a4f0:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a4f3:	73 0d                	jae    c010a502 <load_icode+0x37b>
                size -= la - end;
c010a4f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a4f8:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a4fb:	29 c2                	sub    %eax,%edx
c010a4fd:	89 d0                	mov    %edx,%eax
c010a4ff:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a502:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a505:	89 04 24             	mov    %eax,(%esp)
c010a508:	e8 1a ef ff ff       	call   c0109427 <page2kva>
c010a50d:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a510:	01 c2                	add    %eax,%edx
c010a512:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a515:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a519:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a520:	00 
c010a521:	89 14 24             	mov    %edx,(%esp)
c010a524:	e8 f5 1c 00 00       	call   c010c21e <memset>
            start += size;
c010a529:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a52c:	01 45 d8             	add    %eax,-0x28(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
c010a52f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a532:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a535:	0f 82 69 ff ff ff    	jb     c010a4a4 <load_icode+0x31d>
        goto bad_elf_cleanup_pgdir;
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
    for (; ph < ph_end; ph ++) {
c010a53b:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c010a53f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a542:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010a545:	0f 82 e1 fc ff ff    	jb     c010a22c <load_icode+0xa5>
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
c010a54b:	c7 45 e8 0b 00 00 00 	movl   $0xb,-0x18(%ebp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
c010a552:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a559:	00 
c010a55a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a55d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a561:	c7 44 24 08 00 00 10 	movl   $0x100000,0x8(%esp)
c010a568:	00 
c010a569:	c7 44 24 04 00 00 f0 	movl   $0xaff00000,0x4(%esp)
c010a570:	af 
c010a571:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a574:	89 04 24             	mov    %eax,(%esp)
c010a577:	e8 8b dd ff ff       	call   c0108307 <mm_map>
c010a57c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a57f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a583:	74 05                	je     c010a58a <load_icode+0x403>
        goto bad_cleanup_mmap;
c010a585:	e9 3a 02 00 00       	jmp    c010a7c4 <load_icode+0x63d>
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
c010a58a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a58d:	8b 40 0c             	mov    0xc(%eax),%eax
c010a590:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a597:	00 
c010a598:	c7 44 24 04 00 f0 ff 	movl   $0xaffff000,0x4(%esp)
c010a59f:	af 
c010a5a0:	89 04 24             	mov    %eax,(%esp)
c010a5a3:	e8 b0 b9 ff ff       	call   c0105f58 <pgdir_alloc_page>
c010a5a8:	85 c0                	test   %eax,%eax
c010a5aa:	75 24                	jne    c010a5d0 <load_icode+0x449>
c010a5ac:	c7 44 24 0c 60 e5 10 	movl   $0xc010e560,0xc(%esp)
c010a5b3:	c0 
c010a5b4:	c7 44 24 08 a5 e4 10 	movl   $0xc010e4a5,0x8(%esp)
c010a5bb:	c0 
c010a5bc:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
c010a5c3:	00 
c010a5c4:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010a5cb:	e8 0a 68 ff ff       	call   c0100dda <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
c010a5d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a5d3:	8b 40 0c             	mov    0xc(%eax),%eax
c010a5d6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a5dd:	00 
c010a5de:	c7 44 24 04 00 e0 ff 	movl   $0xafffe000,0x4(%esp)
c010a5e5:	af 
c010a5e6:	89 04 24             	mov    %eax,(%esp)
c010a5e9:	e8 6a b9 ff ff       	call   c0105f58 <pgdir_alloc_page>
c010a5ee:	85 c0                	test   %eax,%eax
c010a5f0:	75 24                	jne    c010a616 <load_icode+0x48f>
c010a5f2:	c7 44 24 0c a4 e5 10 	movl   $0xc010e5a4,0xc(%esp)
c010a5f9:	c0 
c010a5fa:	c7 44 24 08 a5 e4 10 	movl   $0xc010e4a5,0x8(%esp)
c010a601:	c0 
c010a602:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
c010a609:	00 
c010a60a:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010a611:	e8 c4 67 ff ff       	call   c0100dda <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
c010a616:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a619:	8b 40 0c             	mov    0xc(%eax),%eax
c010a61c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a623:	00 
c010a624:	c7 44 24 04 00 d0 ff 	movl   $0xafffd000,0x4(%esp)
c010a62b:	af 
c010a62c:	89 04 24             	mov    %eax,(%esp)
c010a62f:	e8 24 b9 ff ff       	call   c0105f58 <pgdir_alloc_page>
c010a634:	85 c0                	test   %eax,%eax
c010a636:	75 24                	jne    c010a65c <load_icode+0x4d5>
c010a638:	c7 44 24 0c e8 e5 10 	movl   $0xc010e5e8,0xc(%esp)
c010a63f:	c0 
c010a640:	c7 44 24 08 a5 e4 10 	movl   $0xc010e4a5,0x8(%esp)
c010a647:	c0 
c010a648:	c7 44 24 04 83 02 00 	movl   $0x283,0x4(%esp)
c010a64f:	00 
c010a650:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010a657:	e8 7e 67 ff ff       	call   c0100dda <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
c010a65c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a65f:	8b 40 0c             	mov    0xc(%eax),%eax
c010a662:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a669:	00 
c010a66a:	c7 44 24 04 00 c0 ff 	movl   $0xafffc000,0x4(%esp)
c010a671:	af 
c010a672:	89 04 24             	mov    %eax,(%esp)
c010a675:	e8 de b8 ff ff       	call   c0105f58 <pgdir_alloc_page>
c010a67a:	85 c0                	test   %eax,%eax
c010a67c:	75 24                	jne    c010a6a2 <load_icode+0x51b>
c010a67e:	c7 44 24 0c 2c e6 10 	movl   $0xc010e62c,0xc(%esp)
c010a685:	c0 
c010a686:	c7 44 24 08 a5 e4 10 	movl   $0xc010e4a5,0x8(%esp)
c010a68d:	c0 
c010a68e:	c7 44 24 04 84 02 00 	movl   $0x284,0x4(%esp)
c010a695:	00 
c010a696:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010a69d:	e8 38 67 ff ff       	call   c0100dda <__panic>
    
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
c010a6a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a6a5:	89 04 24             	mov    %eax,(%esp)
c010a6a8:	e8 18 ee ff ff       	call   c01094c5 <mm_count_inc>
    current->mm = mm;
c010a6ad:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a6b2:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a6b5:	89 50 18             	mov    %edx,0x18(%eax)
    current->cr3 = PADDR(mm->pgdir);
c010a6b8:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a6bd:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a6c0:	8b 52 0c             	mov    0xc(%edx),%edx
c010a6c3:	89 55 b8             	mov    %edx,-0x48(%ebp)
c010a6c6:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c010a6cd:	77 23                	ja     c010a6f2 <load_icode+0x56b>
c010a6cf:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010a6d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a6d6:	c7 44 24 08 54 e4 10 	movl   $0xc010e454,0x8(%esp)
c010a6dd:	c0 
c010a6de:	c7 44 24 04 89 02 00 	movl   $0x289,0x4(%esp)
c010a6e5:	00 
c010a6e6:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010a6ed:	e8 e8 66 ff ff       	call   c0100dda <__panic>
c010a6f2:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010a6f5:	81 c2 00 00 00 40    	add    $0x40000000,%edx
c010a6fb:	89 50 40             	mov    %edx,0x40(%eax)
    lcr3(PADDR(mm->pgdir));
c010a6fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a701:	8b 40 0c             	mov    0xc(%eax),%eax
c010a704:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010a707:	81 7d b4 ff ff ff bf 	cmpl   $0xbfffffff,-0x4c(%ebp)
c010a70e:	77 23                	ja     c010a733 <load_icode+0x5ac>
c010a710:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a713:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a717:	c7 44 24 08 54 e4 10 	movl   $0xc010e454,0x8(%esp)
c010a71e:	c0 
c010a71f:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
c010a726:	00 
c010a727:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010a72e:	e8 a7 66 ff ff       	call   c0100dda <__panic>
c010a733:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a736:	05 00 00 00 40       	add    $0x40000000,%eax
c010a73b:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010a73e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010a741:	0f 22 d8             	mov    %eax,%cr3

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
c010a744:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a749:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a74c:	89 45 b0             	mov    %eax,-0x50(%ebp)
    memset(tf, 0, sizeof(struct trapframe));
c010a74f:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c010a756:	00 
c010a757:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a75e:	00 
c010a75f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a762:	89 04 24             	mov    %eax,(%esp)
c010a765:	e8 b4 1a 00 00       	call   c010c21e <memset>
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    tf->tf_cs = USER_CS;
c010a76a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a76d:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
c010a773:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a776:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c010a77c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a77f:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c010a783:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a786:	66 89 50 28          	mov    %dx,0x28(%eax)
c010a78a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a78d:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010a791:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a794:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    tf->tf_esp = USTACKTOP;
c010a798:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a79b:	c7 40 44 00 00 00 b0 	movl   $0xb0000000,0x44(%eax)
    tf->tf_eip = elf->e_entry;
c010a7a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a7a5:	8b 50 18             	mov    0x18(%eax),%edx
c010a7a8:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a7ab:	89 50 38             	mov    %edx,0x38(%eax)
    tf->tf_eflags = FL_IF;
c010a7ae:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a7b1:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    ret = 0;
c010a7b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
out:
    return ret;
c010a7bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a7c2:	eb 23                	jmp    c010a7e7 <load_icode+0x660>
bad_cleanup_mmap:
    exit_mmap(mm);
c010a7c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a7c7:	89 04 24             	mov    %eax,(%esp)
c010a7ca:	e8 55 dd ff ff       	call   c0108524 <exit_mmap>
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
c010a7cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a7d2:	89 04 24             	mov    %eax,(%esp)
c010a7d5:	e8 95 f4 ff ff       	call   c0109c6f <put_pgdir>
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c010a7da:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a7dd:	89 04 24             	mov    %eax,(%esp)
c010a7e0:	e8 80 da ff ff       	call   c0108265 <mm_destroy>
bad_mm:
    goto out;
c010a7e5:	eb d8                	jmp    c010a7bf <load_icode+0x638>
}
c010a7e7:	c9                   	leave  
c010a7e8:	c3                   	ret    

c010a7e9 <do_execve>:

// do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
c010a7e9:	55                   	push   %ebp
c010a7ea:	89 e5                	mov    %esp,%ebp
c010a7ec:	83 ec 38             	sub    $0x38,%esp
    struct mm_struct *mm = current->mm;
c010a7ef:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a7f4:	8b 40 18             	mov    0x18(%eax),%eax
c010a7f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
c010a7fa:	8b 45 08             	mov    0x8(%ebp),%eax
c010a7fd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010a804:	00 
c010a805:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a808:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a80c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a810:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a813:	89 04 24             	mov    %eax,(%esp)
c010a816:	e8 ce e7 ff ff       	call   c0108fe9 <user_mem_check>
c010a81b:	85 c0                	test   %eax,%eax
c010a81d:	75 0a                	jne    c010a829 <do_execve+0x40>
        return -E_INVAL;
c010a81f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a824:	e9 f4 00 00 00       	jmp    c010a91d <do_execve+0x134>
    }
    if (len > PROC_NAME_LEN) {
c010a829:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
c010a82d:	76 07                	jbe    c010a836 <do_execve+0x4d>
        len = PROC_NAME_LEN;
c010a82f:	c7 45 0c 0f 00 00 00 	movl   $0xf,0xc(%ebp)
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
c010a836:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010a83d:	00 
c010a83e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a845:	00 
c010a846:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a849:	89 04 24             	mov    %eax,(%esp)
c010a84c:	e8 cd 19 00 00       	call   c010c21e <memset>
    memcpy(local_name, name, len);
c010a851:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a854:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a858:	8b 45 08             	mov    0x8(%ebp),%eax
c010a85b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a85f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a862:	89 04 24             	mov    %eax,(%esp)
c010a865:	e8 96 1a 00 00       	call   c010c300 <memcpy>

    if (mm != NULL) {
c010a86a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a86e:	74 4a                	je     c010a8ba <do_execve+0xd1>
        lcr3(boot_cr3);
c010a870:	a1 8c 0e 1b c0       	mov    0xc01b0e8c,%eax
c010a875:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a878:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a87b:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a87e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a881:	89 04 24             	mov    %eax,(%esp)
c010a884:	e8 56 ec ff ff       	call   c01094df <mm_count_dec>
c010a889:	85 c0                	test   %eax,%eax
c010a88b:	75 21                	jne    c010a8ae <do_execve+0xc5>
            exit_mmap(mm);
c010a88d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a890:	89 04 24             	mov    %eax,(%esp)
c010a893:	e8 8c dc ff ff       	call   c0108524 <exit_mmap>
            put_pgdir(mm);
c010a898:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a89b:	89 04 24             	mov    %eax,(%esp)
c010a89e:	e8 cc f3 ff ff       	call   c0109c6f <put_pgdir>
            mm_destroy(mm);
c010a8a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a8a6:	89 04 24             	mov    %eax,(%esp)
c010a8a9:	e8 b7 d9 ff ff       	call   c0108265 <mm_destroy>
        }
        current->mm = NULL;
c010a8ae:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a8b3:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
c010a8ba:	8b 45 14             	mov    0x14(%ebp),%eax
c010a8bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a8c1:	8b 45 10             	mov    0x10(%ebp),%eax
c010a8c4:	89 04 24             	mov    %eax,(%esp)
c010a8c7:	e8 bb f8 ff ff       	call   c010a187 <load_icode>
c010a8cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a8cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a8d3:	74 2f                	je     c010a904 <do_execve+0x11b>
        goto execve_exit;
c010a8d5:	90                   	nop
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
c010a8d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a8d9:	89 04 24             	mov    %eax,(%esp)
c010a8dc:	e8 d6 f6 ff ff       	call   c0109fb7 <do_exit>
    panic("already exit: %e.\n", ret);
c010a8e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a8e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a8e8:	c7 44 24 08 6f e6 10 	movl   $0xc010e66f,0x8(%esp)
c010a8ef:	c0 
c010a8f0:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
c010a8f7:	00 
c010a8f8:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010a8ff:	e8 d6 64 ff ff       	call   c0100dda <__panic>
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
        goto execve_exit;
    }
    set_proc_name(current, local_name);
c010a904:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a909:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010a90c:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a910:	89 04 24             	mov    %eax,(%esp)
c010a913:	e8 89 ed ff ff       	call   c01096a1 <set_proc_name>
    return 0;
c010a918:	b8 00 00 00 00       	mov    $0x0,%eax

execve_exit:
    do_exit(ret);
    panic("already exit: %e.\n", ret);
}
c010a91d:	c9                   	leave  
c010a91e:	c3                   	ret    

c010a91f <do_yield>:

// do_yield - ask the scheduler to reschedule
int
do_yield(void) {
c010a91f:	55                   	push   %ebp
c010a920:	89 e5                	mov    %esp,%ebp
    current->need_resched = 1;
c010a922:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a927:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    return 0;
c010a92e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a933:	5d                   	pop    %ebp
c010a934:	c3                   	ret    

c010a935 <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
c010a935:	55                   	push   %ebp
c010a936:	89 e5                	mov    %esp,%ebp
c010a938:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = current->mm;
c010a93b:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a940:	8b 40 18             	mov    0x18(%eax),%eax
c010a943:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (code_store != NULL) {
c010a946:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a94a:	74 30                	je     c010a97c <do_wait+0x47>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
c010a94c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a94f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010a956:	00 
c010a957:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
c010a95e:	00 
c010a95f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a963:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a966:	89 04 24             	mov    %eax,(%esp)
c010a969:	e8 7b e6 ff ff       	call   c0108fe9 <user_mem_check>
c010a96e:	85 c0                	test   %eax,%eax
c010a970:	75 0a                	jne    c010a97c <do_wait+0x47>
            return -E_INVAL;
c010a972:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a977:	e9 4b 01 00 00       	jmp    c010aac7 <do_wait+0x192>
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
c010a97c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if (pid != 0) {
c010a983:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a987:	74 39                	je     c010a9c2 <do_wait+0x8d>
        proc = find_proc(pid);
c010a989:	8b 45 08             	mov    0x8(%ebp),%eax
c010a98c:	89 04 24             	mov    %eax,(%esp)
c010a98f:	e8 ee f0 ff ff       	call   c0109a82 <find_proc>
c010a994:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (proc != NULL && proc->parent == current) {
c010a997:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a99b:	74 54                	je     c010a9f1 <do_wait+0xbc>
c010a99d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9a0:	8b 50 14             	mov    0x14(%eax),%edx
c010a9a3:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a9a8:	39 c2                	cmp    %eax,%edx
c010a9aa:	75 45                	jne    c010a9f1 <do_wait+0xbc>
            haskid = 1;
c010a9ac:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010a9b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9b6:	8b 00                	mov    (%eax),%eax
c010a9b8:	83 f8 03             	cmp    $0x3,%eax
c010a9bb:	75 34                	jne    c010a9f1 <do_wait+0xbc>
                goto found;
c010a9bd:	e9 80 00 00 00       	jmp    c010aa42 <do_wait+0x10d>
            }
        }
    }
    else {
        proc = current->cptr;
c010a9c2:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a9c7:	8b 40 70             	mov    0x70(%eax),%eax
c010a9ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (; proc != NULL; proc = proc->optr) {
c010a9cd:	eb 1c                	jmp    c010a9eb <do_wait+0xb6>
            haskid = 1;
c010a9cf:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010a9d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9d9:	8b 00                	mov    (%eax),%eax
c010a9db:	83 f8 03             	cmp    $0x3,%eax
c010a9de:	75 02                	jne    c010a9e2 <do_wait+0xad>
                goto found;
c010a9e0:	eb 60                	jmp    c010aa42 <do_wait+0x10d>
            }
        }
    }
    else {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
c010a9e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9e5:	8b 40 78             	mov    0x78(%eax),%eax
c010a9e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a9eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a9ef:	75 de                	jne    c010a9cf <do_wait+0x9a>
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    if (haskid) {
c010a9f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a9f5:	74 41                	je     c010aa38 <do_wait+0x103>
        current->state = PROC_SLEEPING;
c010a9f7:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010a9fc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010aa02:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010aa07:	c7 40 6c 01 00 00 80 	movl   $0x80000001,0x6c(%eax)
        schedule();
c010aa0e:	e8 af 0a 00 00       	call   c010b4c2 <schedule>
        if (current->flags & PF_EXITING) {
c010aa13:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010aa18:	8b 40 44             	mov    0x44(%eax),%eax
c010aa1b:	83 e0 01             	and    $0x1,%eax
c010aa1e:	85 c0                	test   %eax,%eax
c010aa20:	74 11                	je     c010aa33 <do_wait+0xfe>
            do_exit(-E_KILLED);
c010aa22:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c010aa29:	e8 89 f5 ff ff       	call   c0109fb7 <do_exit>
        }
        goto repeat;
c010aa2e:	e9 49 ff ff ff       	jmp    c010a97c <do_wait+0x47>
c010aa33:	e9 44 ff ff ff       	jmp    c010a97c <do_wait+0x47>
    }
    return -E_BAD_PROC;
c010aa38:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c010aa3d:	e9 85 00 00 00       	jmp    c010aac7 <do_wait+0x192>

found:
    if (proc == idleproc || proc == initproc) {
c010aa42:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c010aa47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010aa4a:	74 0a                	je     c010aa56 <do_wait+0x121>
c010aa4c:	a1 24 ee 1a c0       	mov    0xc01aee24,%eax
c010aa51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010aa54:	75 1c                	jne    c010aa72 <do_wait+0x13d>
        panic("wait idleproc or initproc.\n");
c010aa56:	c7 44 24 08 82 e6 10 	movl   $0xc010e682,0x8(%esp)
c010aa5d:	c0 
c010aa5e:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
c010aa65:	00 
c010aa66:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010aa6d:	e8 68 63 ff ff       	call   c0100dda <__panic>
    }
    if (code_store != NULL) {
c010aa72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010aa76:	74 0b                	je     c010aa83 <do_wait+0x14e>
        *code_store = proc->exit_code;
c010aa78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa7b:	8b 50 68             	mov    0x68(%eax),%edx
c010aa7e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aa81:	89 10                	mov    %edx,(%eax)
    }
    local_intr_save(intr_flag);
c010aa83:	e8 77 e8 ff ff       	call   c01092ff <__intr_save>
c010aa88:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        unhash_proc(proc);
c010aa8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa8e:	89 04 24             	mov    %eax,(%esp)
c010aa91:	e8 b9 ef ff ff       	call   c0109a4f <unhash_proc>
        remove_links(proc);
c010aa96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa99:	89 04 24             	mov    %eax,(%esp)
c010aa9c:	e8 2a ed ff ff       	call   c01097cb <remove_links>
    }
    local_intr_restore(intr_flag);
c010aaa1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010aaa4:	89 04 24             	mov    %eax,(%esp)
c010aaa7:	e8 7d e8 ff ff       	call   c0109329 <__intr_restore>
    put_kstack(proc);
c010aaac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aaaf:	89 04 24             	mov    %eax,(%esp)
c010aab2:	e8 eb f0 ff ff       	call   c0109ba2 <put_kstack>
    kfree(proc);
c010aab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aaba:	89 04 24             	mov    %eax,(%esp)
c010aabd:	e8 51 a1 ff ff       	call   c0104c13 <kfree>
    return 0;
c010aac2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aac7:	c9                   	leave  
c010aac8:	c3                   	ret    

c010aac9 <do_kill>:

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int
do_kill(int pid) {
c010aac9:	55                   	push   %ebp
c010aaca:	89 e5                	mov    %esp,%ebp
c010aacc:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
c010aacf:	8b 45 08             	mov    0x8(%ebp),%eax
c010aad2:	89 04 24             	mov    %eax,(%esp)
c010aad5:	e8 a8 ef ff ff       	call   c0109a82 <find_proc>
c010aada:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010aadd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010aae1:	74 41                	je     c010ab24 <do_kill+0x5b>
        if (!(proc->flags & PF_EXITING)) {
c010aae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aae6:	8b 40 44             	mov    0x44(%eax),%eax
c010aae9:	83 e0 01             	and    $0x1,%eax
c010aaec:	85 c0                	test   %eax,%eax
c010aaee:	75 2d                	jne    c010ab1d <do_kill+0x54>
            proc->flags |= PF_EXITING;
c010aaf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aaf3:	8b 40 44             	mov    0x44(%eax),%eax
c010aaf6:	83 c8 01             	or     $0x1,%eax
c010aaf9:	89 c2                	mov    %eax,%edx
c010aafb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aafe:	89 50 44             	mov    %edx,0x44(%eax)
            if (proc->wait_state & WT_INTERRUPTED) {
c010ab01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab04:	8b 40 6c             	mov    0x6c(%eax),%eax
c010ab07:	85 c0                	test   %eax,%eax
c010ab09:	79 0b                	jns    c010ab16 <do_kill+0x4d>
                wakeup_proc(proc);
c010ab0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab0e:	89 04 24             	mov    %eax,(%esp)
c010ab11:	e8 13 09 00 00       	call   c010b429 <wakeup_proc>
            }
            return 0;
c010ab16:	b8 00 00 00 00       	mov    $0x0,%eax
c010ab1b:	eb 0c                	jmp    c010ab29 <do_kill+0x60>
        }
        return -E_KILLED;
c010ab1d:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
c010ab22:	eb 05                	jmp    c010ab29 <do_kill+0x60>
    }
    return -E_INVAL;
c010ab24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
c010ab29:	c9                   	leave  
c010ab2a:	c3                   	ret    

c010ab2b <kernel_execve>:

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
c010ab2b:	55                   	push   %ebp
c010ab2c:	89 e5                	mov    %esp,%ebp
c010ab2e:	57                   	push   %edi
c010ab2f:	56                   	push   %esi
c010ab30:	53                   	push   %ebx
c010ab31:	83 ec 2c             	sub    $0x2c,%esp
    int ret, len = strlen(name);
c010ab34:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab37:	89 04 24             	mov    %eax,(%esp)
c010ab3a:	e8 b0 13 00 00       	call   c010beef <strlen>
c010ab3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile (
c010ab42:	b8 04 00 00 00       	mov    $0x4,%eax
c010ab47:	8b 55 08             	mov    0x8(%ebp),%edx
c010ab4a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c010ab4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010ab50:	8b 75 10             	mov    0x10(%ebp),%esi
c010ab53:	89 f7                	mov    %esi,%edi
c010ab55:	cd 80                	int    $0x80
c010ab57:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL), "0" (SYS_exec), "d" (name), "c" (len), "b" (binary), "D" (size)
        : "memory");
    return ret;
c010ab5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
c010ab5d:	83 c4 2c             	add    $0x2c,%esp
c010ab60:	5b                   	pop    %ebx
c010ab61:	5e                   	pop    %esi
c010ab62:	5f                   	pop    %edi
c010ab63:	5d                   	pop    %ebp
c010ab64:	c3                   	ret    

c010ab65 <user_main>:

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
c010ab65:	55                   	push   %ebp
c010ab66:	89 e5                	mov    %esp,%ebp
c010ab68:	83 ec 18             	sub    $0x18,%esp
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
c010ab6b:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010ab70:	8b 40 04             	mov    0x4(%eax),%eax
c010ab73:	c7 44 24 08 9e e6 10 	movl   $0xc010e69e,0x8(%esp)
c010ab7a:	c0 
c010ab7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ab7f:	c7 04 24 a8 e6 10 c0 	movl   $0xc010e6a8,(%esp)
c010ab86:	e8 cd 57 ff ff       	call   c0100358 <cprintf>
c010ab8b:	b8 c7 79 00 00       	mov    $0x79c7,%eax
c010ab90:	89 44 24 08          	mov    %eax,0x8(%esp)
c010ab94:	c7 44 24 04 11 05 18 	movl   $0xc0180511,0x4(%esp)
c010ab9b:	c0 
c010ab9c:	c7 04 24 9e e6 10 c0 	movl   $0xc010e69e,(%esp)
c010aba3:	e8 83 ff ff ff       	call   c010ab2b <kernel_execve>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
c010aba8:	c7 44 24 08 cf e6 10 	movl   $0xc010e6cf,0x8(%esp)
c010abaf:	c0 
c010abb0:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
c010abb7:	00 
c010abb8:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010abbf:	e8 16 62 ff ff       	call   c0100dda <__panic>

c010abc4 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010abc4:	55                   	push   %ebp
c010abc5:	89 e5                	mov    %esp,%ebp
c010abc7:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010abca:	e8 3b a5 ff ff       	call   c010510a <nr_free_pages>
c010abcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t kernel_allocated_store = kallocated();
c010abd2:	e8 04 9f ff ff       	call   c0104adb <kallocated>
c010abd7:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int pid = kernel_thread(user_main, NULL, 0);
c010abda:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010abe1:	00 
c010abe2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010abe9:	00 
c010abea:	c7 04 24 65 ab 10 c0 	movl   $0xc010ab65,(%esp)
c010abf1:	e8 fe ee ff ff       	call   c0109af4 <kernel_thread>
c010abf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c010abf9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010abfd:	7f 1c                	jg     c010ac1b <init_main+0x57>
        panic("create user_main failed.\n");
c010abff:	c7 44 24 08 e9 e6 10 	movl   $0xc010e6e9,0x8(%esp)
c010ac06:	c0 
c010ac07:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
c010ac0e:	00 
c010ac0f:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010ac16:	e8 bf 61 ff ff       	call   c0100dda <__panic>
    }

    while (do_wait(0, NULL) == 0) {
c010ac1b:	eb 05                	jmp    c010ac22 <init_main+0x5e>
        schedule();
c010ac1d:	e8 a0 08 00 00       	call   c010b4c2 <schedule>
    int pid = kernel_thread(user_main, NULL, 0);
    if (pid <= 0) {
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
c010ac22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ac29:	00 
c010ac2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010ac31:	e8 ff fc ff ff       	call   c010a935 <do_wait>
c010ac36:	85 c0                	test   %eax,%eax
c010ac38:	74 e3                	je     c010ac1d <init_main+0x59>
        schedule();
    }

    cprintf("all user-mode processes have quit.\n");
c010ac3a:	c7 04 24 04 e7 10 c0 	movl   $0xc010e704,(%esp)
c010ac41:	e8 12 57 ff ff       	call   c0100358 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
c010ac46:	a1 24 ee 1a c0       	mov    0xc01aee24,%eax
c010ac4b:	8b 40 70             	mov    0x70(%eax),%eax
c010ac4e:	85 c0                	test   %eax,%eax
c010ac50:	75 18                	jne    c010ac6a <init_main+0xa6>
c010ac52:	a1 24 ee 1a c0       	mov    0xc01aee24,%eax
c010ac57:	8b 40 74             	mov    0x74(%eax),%eax
c010ac5a:	85 c0                	test   %eax,%eax
c010ac5c:	75 0c                	jne    c010ac6a <init_main+0xa6>
c010ac5e:	a1 24 ee 1a c0       	mov    0xc01aee24,%eax
c010ac63:	8b 40 78             	mov    0x78(%eax),%eax
c010ac66:	85 c0                	test   %eax,%eax
c010ac68:	74 24                	je     c010ac8e <init_main+0xca>
c010ac6a:	c7 44 24 0c 28 e7 10 	movl   $0xc010e728,0xc(%esp)
c010ac71:	c0 
c010ac72:	c7 44 24 08 a5 e4 10 	movl   $0xc010e4a5,0x8(%esp)
c010ac79:	c0 
c010ac7a:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
c010ac81:	00 
c010ac82:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010ac89:	e8 4c 61 ff ff       	call   c0100dda <__panic>
    assert(nr_process == 2);
c010ac8e:	a1 40 0e 1b c0       	mov    0xc01b0e40,%eax
c010ac93:	83 f8 02             	cmp    $0x2,%eax
c010ac96:	74 24                	je     c010acbc <init_main+0xf8>
c010ac98:	c7 44 24 0c 73 e7 10 	movl   $0xc010e773,0xc(%esp)
c010ac9f:	c0 
c010aca0:	c7 44 24 08 a5 e4 10 	movl   $0xc010e4a5,0x8(%esp)
c010aca7:	c0 
c010aca8:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
c010acaf:	00 
c010acb0:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010acb7:	e8 1e 61 ff ff       	call   c0100dda <__panic>
c010acbc:	c7 45 e8 70 0f 1b c0 	movl   $0xc01b0f70,-0x18(%ebp)
c010acc3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010acc6:	8b 40 04             	mov    0x4(%eax),%eax
    assert(list_next(&proc_list) == &(initproc->list_link));
c010acc9:	8b 15 24 ee 1a c0    	mov    0xc01aee24,%edx
c010accf:	83 c2 58             	add    $0x58,%edx
c010acd2:	39 d0                	cmp    %edx,%eax
c010acd4:	74 24                	je     c010acfa <init_main+0x136>
c010acd6:	c7 44 24 0c 84 e7 10 	movl   $0xc010e784,0xc(%esp)
c010acdd:	c0 
c010acde:	c7 44 24 08 a5 e4 10 	movl   $0xc010e4a5,0x8(%esp)
c010ace5:	c0 
c010ace6:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
c010aced:	00 
c010acee:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010acf5:	e8 e0 60 ff ff       	call   c0100dda <__panic>
c010acfa:	c7 45 e4 70 0f 1b c0 	movl   $0xc01b0f70,-0x1c(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c010ad01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010ad04:	8b 00                	mov    (%eax),%eax
    assert(list_prev(&proc_list) == &(initproc->list_link));
c010ad06:	8b 15 24 ee 1a c0    	mov    0xc01aee24,%edx
c010ad0c:	83 c2 58             	add    $0x58,%edx
c010ad0f:	39 d0                	cmp    %edx,%eax
c010ad11:	74 24                	je     c010ad37 <init_main+0x173>
c010ad13:	c7 44 24 0c b4 e7 10 	movl   $0xc010e7b4,0xc(%esp)
c010ad1a:	c0 
c010ad1b:	c7 44 24 08 a5 e4 10 	movl   $0xc010e4a5,0x8(%esp)
c010ad22:	c0 
c010ad23:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
c010ad2a:	00 
c010ad2b:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010ad32:	e8 a3 60 ff ff       	call   c0100dda <__panic>

    cprintf("init check memory pass.\n");
c010ad37:	c7 04 24 e4 e7 10 c0 	movl   $0xc010e7e4,(%esp)
c010ad3e:	e8 15 56 ff ff       	call   c0100358 <cprintf>
    return 0;
c010ad43:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010ad48:	c9                   	leave  
c010ad49:	c3                   	ret    

c010ad4a <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c010ad4a:	55                   	push   %ebp
c010ad4b:	89 e5                	mov    %esp,%ebp
c010ad4d:	83 ec 28             	sub    $0x28,%esp
c010ad50:	c7 45 ec 70 0f 1b c0 	movl   $0xc01b0f70,-0x14(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010ad57:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ad5a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010ad5d:	89 50 04             	mov    %edx,0x4(%eax)
c010ad60:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ad63:	8b 50 04             	mov    0x4(%eax),%edx
c010ad66:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ad69:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010ad6b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010ad72:	eb 26                	jmp    c010ad9a <proc_init+0x50>
        list_init(hash_list + i);
c010ad74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ad77:	c1 e0 03             	shl    $0x3,%eax
c010ad7a:	05 40 ee 1a c0       	add    $0xc01aee40,%eax
c010ad7f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010ad82:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad85:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010ad88:	89 50 04             	mov    %edx,0x4(%eax)
c010ad8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad8e:	8b 50 04             	mov    0x4(%eax),%edx
c010ad91:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad94:	89 10                	mov    %edx,(%eax)
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010ad96:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010ad9a:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010ada1:	7e d1                	jle    c010ad74 <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010ada3:	e8 89 e7 ff ff       	call   c0109531 <alloc_proc>
c010ada8:	a3 20 ee 1a c0       	mov    %eax,0xc01aee20
c010adad:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c010adb2:	85 c0                	test   %eax,%eax
c010adb4:	75 1c                	jne    c010add2 <proc_init+0x88>
        panic("cannot alloc idleproc.\n");
c010adb6:	c7 44 24 08 fd e7 10 	movl   $0xc010e7fd,0x8(%esp)
c010adbd:	c0 
c010adbe:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
c010adc5:	00 
c010adc6:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010adcd:	e8 08 60 ff ff       	call   c0100dda <__panic>
    }

    idleproc->pid = 0;
c010add2:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c010add7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010adde:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c010ade3:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010ade9:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c010adee:	ba 00 a0 12 c0       	mov    $0xc012a000,%edx
c010adf3:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010adf6:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c010adfb:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010ae02:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c010ae07:	c7 44 24 04 15 e8 10 	movl   $0xc010e815,0x4(%esp)
c010ae0e:	c0 
c010ae0f:	89 04 24             	mov    %eax,(%esp)
c010ae12:	e8 8a e8 ff ff       	call   c01096a1 <set_proc_name>
    nr_process ++;
c010ae17:	a1 40 0e 1b c0       	mov    0xc01b0e40,%eax
c010ae1c:	83 c0 01             	add    $0x1,%eax
c010ae1f:	a3 40 0e 1b c0       	mov    %eax,0xc01b0e40

    current = idleproc;
c010ae24:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c010ae29:	a3 28 ee 1a c0       	mov    %eax,0xc01aee28

    int pid = kernel_thread(init_main, NULL, 0);
c010ae2e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010ae35:	00 
c010ae36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ae3d:	00 
c010ae3e:	c7 04 24 c4 ab 10 c0 	movl   $0xc010abc4,(%esp)
c010ae45:	e8 aa ec ff ff       	call   c0109af4 <kernel_thread>
c010ae4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010ae4d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010ae51:	7f 1c                	jg     c010ae6f <proc_init+0x125>
        panic("create init_main failed.\n");
c010ae53:	c7 44 24 08 1a e8 10 	movl   $0xc010e81a,0x8(%esp)
c010ae5a:	c0 
c010ae5b:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
c010ae62:	00 
c010ae63:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010ae6a:	e8 6b 5f ff ff       	call   c0100dda <__panic>
    }

    initproc = find_proc(pid);
c010ae6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ae72:	89 04 24             	mov    %eax,(%esp)
c010ae75:	e8 08 ec ff ff       	call   c0109a82 <find_proc>
c010ae7a:	a3 24 ee 1a c0       	mov    %eax,0xc01aee24
    set_proc_name(initproc, "init");
c010ae7f:	a1 24 ee 1a c0       	mov    0xc01aee24,%eax
c010ae84:	c7 44 24 04 34 e8 10 	movl   $0xc010e834,0x4(%esp)
c010ae8b:	c0 
c010ae8c:	89 04 24             	mov    %eax,(%esp)
c010ae8f:	e8 0d e8 ff ff       	call   c01096a1 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010ae94:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c010ae99:	85 c0                	test   %eax,%eax
c010ae9b:	74 0c                	je     c010aea9 <proc_init+0x15f>
c010ae9d:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c010aea2:	8b 40 04             	mov    0x4(%eax),%eax
c010aea5:	85 c0                	test   %eax,%eax
c010aea7:	74 24                	je     c010aecd <proc_init+0x183>
c010aea9:	c7 44 24 0c 3c e8 10 	movl   $0xc010e83c,0xc(%esp)
c010aeb0:	c0 
c010aeb1:	c7 44 24 08 a5 e4 10 	movl   $0xc010e4a5,0x8(%esp)
c010aeb8:	c0 
c010aeb9:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
c010aec0:	00 
c010aec1:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010aec8:	e8 0d 5f ff ff       	call   c0100dda <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010aecd:	a1 24 ee 1a c0       	mov    0xc01aee24,%eax
c010aed2:	85 c0                	test   %eax,%eax
c010aed4:	74 0d                	je     c010aee3 <proc_init+0x199>
c010aed6:	a1 24 ee 1a c0       	mov    0xc01aee24,%eax
c010aedb:	8b 40 04             	mov    0x4(%eax),%eax
c010aede:	83 f8 01             	cmp    $0x1,%eax
c010aee1:	74 24                	je     c010af07 <proc_init+0x1bd>
c010aee3:	c7 44 24 0c 64 e8 10 	movl   $0xc010e864,0xc(%esp)
c010aeea:	c0 
c010aeeb:	c7 44 24 08 a5 e4 10 	movl   $0xc010e4a5,0x8(%esp)
c010aef2:	c0 
c010aef3:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
c010aefa:	00 
c010aefb:	c7 04 24 78 e4 10 c0 	movl   $0xc010e478,(%esp)
c010af02:	e8 d3 5e ff ff       	call   c0100dda <__panic>
}
c010af07:	c9                   	leave  
c010af08:	c3                   	ret    

c010af09 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010af09:	55                   	push   %ebp
c010af0a:	89 e5                	mov    %esp,%ebp
c010af0c:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010af0f:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010af14:	8b 40 10             	mov    0x10(%eax),%eax
c010af17:	85 c0                	test   %eax,%eax
c010af19:	74 07                	je     c010af22 <cpu_idle+0x19>
            schedule();
c010af1b:	e8 a2 05 00 00       	call   c010b4c2 <schedule>
        }
    }
c010af20:	eb ed                	jmp    c010af0f <cpu_idle+0x6>
c010af22:	eb eb                	jmp    c010af0f <cpu_idle+0x6>

c010af24 <lab6_set_priority>:
}

//FOR LAB6, set the process's priority (bigger value will get more CPU time) 
void
lab6_set_priority(uint32_t priority)
{
c010af24:	55                   	push   %ebp
c010af25:	89 e5                	mov    %esp,%ebp
    if (priority == 0)
c010af27:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010af2b:	75 11                	jne    c010af3e <lab6_set_priority+0x1a>
        current->lab6_priority = 1;
c010af2d:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010af32:	c7 80 9c 00 00 00 01 	movl   $0x1,0x9c(%eax)
c010af39:	00 00 00 
c010af3c:	eb 0e                	jmp    c010af4c <lab6_set_priority+0x28>
    else current->lab6_priority = priority;
c010af3e:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010af43:	8b 55 08             	mov    0x8(%ebp),%edx
c010af46:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
}
c010af4c:	5d                   	pop    %ebp
c010af4d:	c3                   	ret    

c010af4e <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c010af4e:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010af52:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010af54:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c010af57:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c010af5a:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c010af5d:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c010af60:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010af63:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c010af66:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c010af69:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c010af6d:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c010af70:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010af73:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c010af76:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c010af79:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c010af7c:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c010af7f:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010af82:	ff 30                	pushl  (%eax)

    ret
c010af84:	c3                   	ret    

c010af85 <skew_heap_merge>:
}

static inline skew_heap_entry_t *
skew_heap_merge(skew_heap_entry_t *a, skew_heap_entry_t *b,
                compare_f comp)
{
c010af85:	55                   	push   %ebp
c010af86:	89 e5                	mov    %esp,%ebp
c010af88:	83 ec 28             	sub    $0x28,%esp
     if (a == NULL) return b;
c010af8b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010af8f:	75 08                	jne    c010af99 <skew_heap_merge+0x14>
c010af91:	8b 45 0c             	mov    0xc(%ebp),%eax
c010af94:	e9 bd 00 00 00       	jmp    c010b056 <skew_heap_merge+0xd1>
     else if (b == NULL) return a;
c010af99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010af9d:	75 08                	jne    c010afa7 <skew_heap_merge+0x22>
c010af9f:	8b 45 08             	mov    0x8(%ebp),%eax
c010afa2:	e9 af 00 00 00       	jmp    c010b056 <skew_heap_merge+0xd1>
     
     skew_heap_entry_t *l, *r;
     if (comp(a, b) == -1)
c010afa7:	8b 45 0c             	mov    0xc(%ebp),%eax
c010afaa:	89 44 24 04          	mov    %eax,0x4(%esp)
c010afae:	8b 45 08             	mov    0x8(%ebp),%eax
c010afb1:	89 04 24             	mov    %eax,(%esp)
c010afb4:	8b 45 10             	mov    0x10(%ebp),%eax
c010afb7:	ff d0                	call   *%eax
c010afb9:	83 f8 ff             	cmp    $0xffffffff,%eax
c010afbc:	75 4d                	jne    c010b00b <skew_heap_merge+0x86>
     {
          r = a->left;
c010afbe:	8b 45 08             	mov    0x8(%ebp),%eax
c010afc1:	8b 40 04             	mov    0x4(%eax),%eax
c010afc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
          l = skew_heap_merge(a->right, b, comp);
c010afc7:	8b 45 08             	mov    0x8(%ebp),%eax
c010afca:	8b 40 08             	mov    0x8(%eax),%eax
c010afcd:	8b 55 10             	mov    0x10(%ebp),%edx
c010afd0:	89 54 24 08          	mov    %edx,0x8(%esp)
c010afd4:	8b 55 0c             	mov    0xc(%ebp),%edx
c010afd7:	89 54 24 04          	mov    %edx,0x4(%esp)
c010afdb:	89 04 24             	mov    %eax,(%esp)
c010afde:	e8 a2 ff ff ff       	call   c010af85 <skew_heap_merge>
c010afe3:	89 45 f0             	mov    %eax,-0x10(%ebp)
          
          a->left = l;
c010afe6:	8b 45 08             	mov    0x8(%ebp),%eax
c010afe9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010afec:	89 50 04             	mov    %edx,0x4(%eax)
          a->right = r;
c010afef:	8b 45 08             	mov    0x8(%ebp),%eax
c010aff2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010aff5:	89 50 08             	mov    %edx,0x8(%eax)
          if (l) l->parent = a;
c010aff8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010affc:	74 08                	je     c010b006 <skew_heap_merge+0x81>
c010affe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b001:	8b 55 08             	mov    0x8(%ebp),%edx
c010b004:	89 10                	mov    %edx,(%eax)

          return a;
c010b006:	8b 45 08             	mov    0x8(%ebp),%eax
c010b009:	eb 4b                	jmp    c010b056 <skew_heap_merge+0xd1>
     }
     else
     {
          r = b->left;
c010b00b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b00e:	8b 40 04             	mov    0x4(%eax),%eax
c010b011:	89 45 f4             	mov    %eax,-0xc(%ebp)
          l = skew_heap_merge(a, b->right, comp);
c010b014:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b017:	8b 40 08             	mov    0x8(%eax),%eax
c010b01a:	8b 55 10             	mov    0x10(%ebp),%edx
c010b01d:	89 54 24 08          	mov    %edx,0x8(%esp)
c010b021:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b025:	8b 45 08             	mov    0x8(%ebp),%eax
c010b028:	89 04 24             	mov    %eax,(%esp)
c010b02b:	e8 55 ff ff ff       	call   c010af85 <skew_heap_merge>
c010b030:	89 45 f0             	mov    %eax,-0x10(%ebp)
          
          b->left = l;
c010b033:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b036:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b039:	89 50 04             	mov    %edx,0x4(%eax)
          b->right = r;
c010b03c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b03f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b042:	89 50 08             	mov    %edx,0x8(%eax)
          if (l) l->parent = b;
c010b045:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b049:	74 08                	je     c010b053 <skew_heap_merge+0xce>
c010b04b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b04e:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b051:	89 10                	mov    %edx,(%eax)

          return b;
c010b053:	8b 45 0c             	mov    0xc(%ebp),%eax
     }
}
c010b056:	c9                   	leave  
c010b057:	c3                   	ret    

c010b058 <proc_stride_comp_f>:

/* The compare function for two skew_heap_node_t's and the
 * corresponding procs*/
static int
proc_stride_comp_f(void *a, void *b)
{
c010b058:	55                   	push   %ebp
c010b059:	89 e5                	mov    %esp,%ebp
c010b05b:	83 ec 10             	sub    $0x10,%esp
     struct proc_struct *p = le2proc(a, lab6_run_pool);
c010b05e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b061:	2d 8c 00 00 00       	sub    $0x8c,%eax
c010b066:	89 45 fc             	mov    %eax,-0x4(%ebp)
     struct proc_struct *q = le2proc(b, lab6_run_pool);
c010b069:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b06c:	2d 8c 00 00 00       	sub    $0x8c,%eax
c010b071:	89 45 f8             	mov    %eax,-0x8(%ebp)
     int32_t c = p->lab6_stride - q->lab6_stride;
c010b074:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b077:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
c010b07d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b080:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
c010b086:	29 c2                	sub    %eax,%edx
c010b088:	89 d0                	mov    %edx,%eax
c010b08a:	89 45 f4             	mov    %eax,-0xc(%ebp)
     if (c > 0) return 1;
c010b08d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b091:	7e 07                	jle    c010b09a <proc_stride_comp_f+0x42>
c010b093:	b8 01 00 00 00       	mov    $0x1,%eax
c010b098:	eb 12                	jmp    c010b0ac <proc_stride_comp_f+0x54>
     else if (c == 0) return 0;
c010b09a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b09e:	75 07                	jne    c010b0a7 <proc_stride_comp_f+0x4f>
c010b0a0:	b8 00 00 00 00       	mov    $0x0,%eax
c010b0a5:	eb 05                	jmp    c010b0ac <proc_stride_comp_f+0x54>
     else return -1;
c010b0a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
c010b0ac:	c9                   	leave  
c010b0ad:	c3                   	ret    

c010b0ae <stride_init>:
 *   - max_time_slice: no need here, the variable would be assigned by the caller.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static void
stride_init(struct run_queue *rq) {
c010b0ae:	55                   	push   %ebp
c010b0af:	89 e5                	mov    %esp,%ebp
c010b0b1:	83 ec 10             	sub    $0x10,%esp
     /* LAB6: 2012012617
      * (1) init the ready process list: rq->run_list
      * (2) init the run pool: rq->lab6_run_pool
      * (3) set number of process: rq->proc_num to 0       
      */
     list_init(&(rq->run_list));
c010b0b4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010b0ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b0bd:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010b0c0:	89 50 04             	mov    %edx,0x4(%eax)
c010b0c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b0c6:	8b 50 04             	mov    0x4(%eax),%edx
c010b0c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b0cc:	89 10                	mov    %edx,(%eax)
     rq->lab6_run_pool = NULL;
c010b0ce:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0d1:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
     rq->proc_num = 0;
c010b0d8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0db:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
c010b0e2:	c9                   	leave  
c010b0e3:	c3                   	ret    

c010b0e4 <stride_enqueue>:
 * 
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static void
stride_enqueue(struct run_queue *rq, struct proc_struct *proc) {
c010b0e4:	55                   	push   %ebp
c010b0e5:	89 e5                	mov    %esp,%ebp
c010b0e7:	83 ec 28             	sub    $0x28,%esp
      *         list_add_before: insert  a entry into the last of list   
      * (2) recalculate proc->time_slice
      * (3) set proc->rq pointer to rq
      * (4) increase rq->proc_num
      */
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
c010b0ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b0ed:	8d 90 8c 00 00 00    	lea    0x8c(%eax),%edx
c010b0f3:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0f6:	8b 40 10             	mov    0x10(%eax),%eax
c010b0f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b0fc:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b0ff:	c7 45 ec 58 b0 10 c0 	movl   $0xc010b058,-0x14(%ebp)
c010b106:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b109:	89 45 e8             	mov    %eax,-0x18(%ebp)
     compare_f comp) __attribute__((always_inline));

static inline void
skew_heap_init(skew_heap_entry_t *a)
{
     a->left = a->right = a->parent = NULL;
c010b10c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b10f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010b115:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b118:	8b 10                	mov    (%eax),%edx
c010b11a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b11d:	89 50 08             	mov    %edx,0x8(%eax)
c010b120:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b123:	8b 50 08             	mov    0x8(%eax),%edx
c010b126:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b129:	89 50 04             	mov    %edx,0x4(%eax)
static inline skew_heap_entry_t *
skew_heap_insert(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_init(b);
     return skew_heap_merge(a, b, comp);
c010b12c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b12f:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b133:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b136:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b13a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b13d:	89 04 24             	mov    %eax,(%esp)
c010b140:	e8 40 fe ff ff       	call   c010af85 <skew_heap_merge>
c010b145:	89 c2                	mov    %eax,%edx
c010b147:	8b 45 08             	mov    0x8(%ebp),%eax
c010b14a:	89 50 10             	mov    %edx,0x10(%eax)
     proc->time_slice = rq->max_time_slice;
c010b14d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b150:	8b 50 0c             	mov    0xc(%eax),%edx
c010b153:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b156:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
     proc->rq = rq;
c010b15c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b15f:	8b 55 08             	mov    0x8(%ebp),%edx
c010b162:	89 50 7c             	mov    %edx,0x7c(%eax)
     ++(rq->proc_num);
c010b165:	8b 45 08             	mov    0x8(%ebp),%eax
c010b168:	8b 40 08             	mov    0x8(%eax),%eax
c010b16b:	8d 50 01             	lea    0x1(%eax),%edx
c010b16e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b171:	89 50 08             	mov    %edx,0x8(%eax)
}
c010b174:	c9                   	leave  
c010b175:	c3                   	ret    

c010b176 <stride_dequeue>:
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static void
stride_dequeue(struct run_queue *rq, struct proc_struct *proc) {
c010b176:	55                   	push   %ebp
c010b177:	89 e5                	mov    %esp,%ebp
c010b179:	83 ec 38             	sub    $0x38,%esp
      * (1) remove the proc from rq correctly
      * NOTICE: you can use skew_heap or list. Important functions
      *         skew_heap_remove: remove a entry from skew_heap
      *         list_del_init: remove a entry from the  list
      */
     rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, &proc->lab6_run_pool, proc_stride_comp_f);
c010b17c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b17f:	8d 90 8c 00 00 00    	lea    0x8c(%eax),%edx
c010b185:	8b 45 08             	mov    0x8(%ebp),%eax
c010b188:	8b 40 10             	mov    0x10(%eax),%eax
c010b18b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b18e:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b191:	c7 45 ec 58 b0 10 c0 	movl   $0xc010b058,-0x14(%ebp)

static inline skew_heap_entry_t *
skew_heap_remove(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_entry_t *p   = b->parent;
c010b198:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b19b:	8b 00                	mov    (%eax),%eax
c010b19d:	89 45 e8             	mov    %eax,-0x18(%ebp)
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
c010b1a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1a3:	8b 50 08             	mov    0x8(%eax),%edx
c010b1a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1a9:	8b 40 04             	mov    0x4(%eax),%eax
c010b1ac:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010b1af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010b1b3:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b1b7:	89 04 24             	mov    %eax,(%esp)
c010b1ba:	e8 c6 fd ff ff       	call   c010af85 <skew_heap_merge>
c010b1bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     if (rep) rep->parent = p;
c010b1c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010b1c6:	74 08                	je     c010b1d0 <stride_dequeue+0x5a>
c010b1c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b1cb:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b1ce:	89 10                	mov    %edx,(%eax)
     
     if (p)
c010b1d0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b1d4:	74 24                	je     c010b1fa <stride_dequeue+0x84>
     {
          if (p->left == b)
c010b1d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b1d9:	8b 40 04             	mov    0x4(%eax),%eax
c010b1dc:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b1df:	75 0b                	jne    c010b1ec <stride_dequeue+0x76>
               p->left = rep;
c010b1e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b1e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b1e7:	89 50 04             	mov    %edx,0x4(%eax)
c010b1ea:	eb 09                	jmp    c010b1f5 <stride_dequeue+0x7f>
          else p->right = rep;
c010b1ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b1ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b1f2:	89 50 08             	mov    %edx,0x8(%eax)
          return a;
c010b1f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1f8:	eb 03                	jmp    c010b1fd <stride_dequeue+0x87>
     }
     else return rep;
c010b1fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b1fd:	89 c2                	mov    %eax,%edx
c010b1ff:	8b 45 08             	mov    0x8(%ebp),%eax
c010b202:	89 50 10             	mov    %edx,0x10(%eax)
     proc->rq = NULL;
c010b205:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b208:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
     --(rq->proc_num);
c010b20f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b212:	8b 40 08             	mov    0x8(%eax),%eax
c010b215:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b218:	8b 45 08             	mov    0x8(%ebp),%eax
c010b21b:	89 50 08             	mov    %edx,0x8(%eax)
}
c010b21e:	c9                   	leave  
c010b21f:	c3                   	ret    

c010b220 <stride_pick_next>:
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static struct proc_struct *
stride_pick_next(struct run_queue *rq) {
c010b220:	55                   	push   %ebp
c010b221:	89 e5                	mov    %esp,%ebp
c010b223:	53                   	push   %ebx
c010b224:	83 ec 10             	sub    $0x10,%esp
             (1.1) If using skew_heap, we can use le2proc get the p from rq->lab6_run_poll
             (1.2) If using list, we have to search list to find the p with minimum stride value
      * (2) update p;s stride value: p->lab6_stride
      * (3) return p
      */
     if (rq->lab6_run_pool == NULL)
c010b227:	8b 45 08             	mov    0x8(%ebp),%eax
c010b22a:	8b 40 10             	mov    0x10(%eax),%eax
c010b22d:	85 c0                	test   %eax,%eax
c010b22f:	75 07                	jne    c010b238 <stride_pick_next+0x18>
          return NULL;
c010b231:	b8 00 00 00 00       	mov    $0x0,%eax
c010b236:	eb 62                	jmp    c010b29a <stride_pick_next+0x7a>
     struct proc_struct *p = le2proc(rq->lab6_run_pool, lab6_run_pool);
c010b238:	8b 45 08             	mov    0x8(%ebp),%eax
c010b23b:	8b 40 10             	mov    0x10(%eax),%eax
c010b23e:	2d 8c 00 00 00       	sub    $0x8c,%eax
c010b243:	89 45 f8             	mov    %eax,-0x8(%ebp)
     if (p->lab6_priority == 0)
c010b246:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b249:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
c010b24f:	85 c0                	test   %eax,%eax
c010b251:	75 1a                	jne    c010b26d <stride_pick_next+0x4d>
          p->lab6_stride += BIG_STRIDE;
c010b253:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b256:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
c010b25c:	8d 90 ff ff ff 7f    	lea    0x7fffffff(%eax),%edx
c010b262:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b265:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
c010b26b:	eb 2a                	jmp    c010b297 <stride_pick_next+0x77>
     else
          p->lab6_stride += BIG_STRIDE / p->lab6_priority;
c010b26d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b270:	8b 88 98 00 00 00    	mov    0x98(%eax),%ecx
c010b276:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b279:	8b 98 9c 00 00 00    	mov    0x9c(%eax),%ebx
c010b27f:	b8 ff ff ff 7f       	mov    $0x7fffffff,%eax
c010b284:	ba 00 00 00 00       	mov    $0x0,%edx
c010b289:	f7 f3                	div    %ebx
c010b28b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c010b28e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b291:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
     return p;
c010b297:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010b29a:	83 c4 10             	add    $0x10,%esp
c010b29d:	5b                   	pop    %ebx
c010b29e:	5d                   	pop    %ebp
c010b29f:	c3                   	ret    

c010b2a0 <stride_proc_tick>:
 * denotes the time slices left for current
 * process. proc->need_resched is the flag variable for process
 * switching.
 */
static void
stride_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
c010b2a0:	55                   	push   %ebp
c010b2a1:	89 e5                	mov    %esp,%ebp
     /* LAB6: 2012012617 */
     if (proc->time_slice > 0) {
c010b2a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b2a6:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b2ac:	85 c0                	test   %eax,%eax
c010b2ae:	7e 15                	jle    c010b2c5 <stride_proc_tick+0x25>
          --(proc->time_slice);
c010b2b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b2b3:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b2b9:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b2bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b2bf:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
     }
     if (proc->time_slice == 0) {
c010b2c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b2c8:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b2ce:	85 c0                	test   %eax,%eax
c010b2d0:	75 0a                	jne    c010b2dc <stride_proc_tick+0x3c>
          proc->need_resched = 1;
c010b2d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b2d5:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
     }
}
c010b2dc:	5d                   	pop    %ebp
c010b2dd:	c3                   	ret    

c010b2de <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c010b2de:	55                   	push   %ebp
c010b2df:	89 e5                	mov    %esp,%ebp
c010b2e1:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010b2e4:	9c                   	pushf  
c010b2e5:	58                   	pop    %eax
c010b2e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010b2e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010b2ec:	25 00 02 00 00       	and    $0x200,%eax
c010b2f1:	85 c0                	test   %eax,%eax
c010b2f3:	74 0c                	je     c010b301 <__intr_save+0x23>
        intr_disable();
c010b2f5:	e8 38 6d ff ff       	call   c0102032 <intr_disable>
        return 1;
c010b2fa:	b8 01 00 00 00       	mov    $0x1,%eax
c010b2ff:	eb 05                	jmp    c010b306 <__intr_save+0x28>
    }
    return 0;
c010b301:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b306:	c9                   	leave  
c010b307:	c3                   	ret    

c010b308 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010b308:	55                   	push   %ebp
c010b309:	89 e5                	mov    %esp,%ebp
c010b30b:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010b30e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b312:	74 05                	je     c010b319 <__intr_restore+0x11>
        intr_enable();
c010b314:	e8 13 6d ff ff       	call   c010202c <intr_enable>
    }
}
c010b319:	c9                   	leave  
c010b31a:	c3                   	ret    

c010b31b <sched_class_enqueue>:
static struct sched_class *sched_class;

static struct run_queue *rq;

static inline void
sched_class_enqueue(struct proc_struct *proc) {
c010b31b:	55                   	push   %ebp
c010b31c:	89 e5                	mov    %esp,%ebp
c010b31e:	83 ec 18             	sub    $0x18,%esp
    if (proc != idleproc) {
c010b321:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c010b326:	39 45 08             	cmp    %eax,0x8(%ebp)
c010b329:	74 1a                	je     c010b345 <sched_class_enqueue+0x2a>
        sched_class->enqueue(rq, proc);
c010b32b:	a1 5c 0e 1b c0       	mov    0xc01b0e5c,%eax
c010b330:	8b 40 08             	mov    0x8(%eax),%eax
c010b333:	8b 15 60 0e 1b c0    	mov    0xc01b0e60,%edx
c010b339:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010b33c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010b340:	89 14 24             	mov    %edx,(%esp)
c010b343:	ff d0                	call   *%eax
    }
}
c010b345:	c9                   	leave  
c010b346:	c3                   	ret    

c010b347 <sched_class_dequeue>:

static inline void
sched_class_dequeue(struct proc_struct *proc) {
c010b347:	55                   	push   %ebp
c010b348:	89 e5                	mov    %esp,%ebp
c010b34a:	83 ec 18             	sub    $0x18,%esp
    sched_class->dequeue(rq, proc);
c010b34d:	a1 5c 0e 1b c0       	mov    0xc01b0e5c,%eax
c010b352:	8b 40 0c             	mov    0xc(%eax),%eax
c010b355:	8b 15 60 0e 1b c0    	mov    0xc01b0e60,%edx
c010b35b:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010b35e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010b362:	89 14 24             	mov    %edx,(%esp)
c010b365:	ff d0                	call   *%eax
}
c010b367:	c9                   	leave  
c010b368:	c3                   	ret    

c010b369 <sched_class_pick_next>:

static inline struct proc_struct *
sched_class_pick_next(void) {
c010b369:	55                   	push   %ebp
c010b36a:	89 e5                	mov    %esp,%ebp
c010b36c:	83 ec 18             	sub    $0x18,%esp
    return sched_class->pick_next(rq);
c010b36f:	a1 5c 0e 1b c0       	mov    0xc01b0e5c,%eax
c010b374:	8b 40 10             	mov    0x10(%eax),%eax
c010b377:	8b 15 60 0e 1b c0    	mov    0xc01b0e60,%edx
c010b37d:	89 14 24             	mov    %edx,(%esp)
c010b380:	ff d0                	call   *%eax
}
c010b382:	c9                   	leave  
c010b383:	c3                   	ret    

c010b384 <sched_class_proc_tick>:

void
sched_class_proc_tick(struct proc_struct *proc) {
c010b384:	55                   	push   %ebp
c010b385:	89 e5                	mov    %esp,%ebp
c010b387:	83 ec 18             	sub    $0x18,%esp
    if (proc != idleproc) {
c010b38a:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c010b38f:	39 45 08             	cmp    %eax,0x8(%ebp)
c010b392:	74 1c                	je     c010b3b0 <sched_class_proc_tick+0x2c>
        sched_class->proc_tick(rq, proc);
c010b394:	a1 5c 0e 1b c0       	mov    0xc01b0e5c,%eax
c010b399:	8b 40 14             	mov    0x14(%eax),%eax
c010b39c:	8b 15 60 0e 1b c0    	mov    0xc01b0e60,%edx
c010b3a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010b3a5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010b3a9:	89 14 24             	mov    %edx,(%esp)
c010b3ac:	ff d0                	call   *%eax
c010b3ae:	eb 0a                	jmp    c010b3ba <sched_class_proc_tick+0x36>
    }
    else {
        proc->need_resched = 1;
c010b3b0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3b3:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    }
}
c010b3ba:	c9                   	leave  
c010b3bb:	c3                   	ret    

c010b3bc <sched_init>:

static struct run_queue __rq;

void
sched_init(void) {
c010b3bc:	55                   	push   %ebp
c010b3bd:	89 e5                	mov    %esp,%ebp
c010b3bf:	83 ec 28             	sub    $0x28,%esp
c010b3c2:	c7 45 f4 54 0e 1b c0 	movl   $0xc01b0e54,-0xc(%ebp)
c010b3c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b3cf:	89 50 04             	mov    %edx,0x4(%eax)
c010b3d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3d5:	8b 50 04             	mov    0x4(%eax),%edx
c010b3d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3db:	89 10                	mov    %edx,(%eax)
    list_init(&timer_list);

    sched_class = &default_sched_class;
c010b3dd:	c7 05 5c 0e 1b c0 88 	movl   $0xc012ca88,0xc01b0e5c
c010b3e4:	ca 12 c0 

    rq = &__rq;
c010b3e7:	c7 05 60 0e 1b c0 64 	movl   $0xc01b0e64,0xc01b0e60
c010b3ee:	0e 1b c0 
    rq->max_time_slice = MAX_TIME_SLICE;
c010b3f1:	a1 60 0e 1b c0       	mov    0xc01b0e60,%eax
c010b3f6:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
    sched_class->init(rq);
c010b3fd:	a1 5c 0e 1b c0       	mov    0xc01b0e5c,%eax
c010b402:	8b 40 04             	mov    0x4(%eax),%eax
c010b405:	8b 15 60 0e 1b c0    	mov    0xc01b0e60,%edx
c010b40b:	89 14 24             	mov    %edx,(%esp)
c010b40e:	ff d0                	call   *%eax

    cprintf("sched class: %s\n", sched_class->name);
c010b410:	a1 5c 0e 1b c0       	mov    0xc01b0e5c,%eax
c010b415:	8b 00                	mov    (%eax),%eax
c010b417:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b41b:	c7 04 24 9c e8 10 c0 	movl   $0xc010e89c,(%esp)
c010b422:	e8 31 4f ff ff       	call   c0100358 <cprintf>
}
c010b427:	c9                   	leave  
c010b428:	c3                   	ret    

c010b429 <wakeup_proc>:

void
wakeup_proc(struct proc_struct *proc) {
c010b429:	55                   	push   %ebp
c010b42a:	89 e5                	mov    %esp,%ebp
c010b42c:	83 ec 28             	sub    $0x28,%esp
    assert(proc->state != PROC_ZOMBIE);
c010b42f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b432:	8b 00                	mov    (%eax),%eax
c010b434:	83 f8 03             	cmp    $0x3,%eax
c010b437:	75 24                	jne    c010b45d <wakeup_proc+0x34>
c010b439:	c7 44 24 0c ad e8 10 	movl   $0xc010e8ad,0xc(%esp)
c010b440:	c0 
c010b441:	c7 44 24 08 c8 e8 10 	movl   $0xc010e8c8,0x8(%esp)
c010b448:	c0 
c010b449:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
c010b450:	00 
c010b451:	c7 04 24 dd e8 10 c0 	movl   $0xc010e8dd,(%esp)
c010b458:	e8 7d 59 ff ff       	call   c0100dda <__panic>
    bool intr_flag;
    local_intr_save(intr_flag);
c010b45d:	e8 7c fe ff ff       	call   c010b2de <__intr_save>
c010b462:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        if (proc->state != PROC_RUNNABLE) {
c010b465:	8b 45 08             	mov    0x8(%ebp),%eax
c010b468:	8b 00                	mov    (%eax),%eax
c010b46a:	83 f8 02             	cmp    $0x2,%eax
c010b46d:	74 2a                	je     c010b499 <wakeup_proc+0x70>
            proc->state = PROC_RUNNABLE;
c010b46f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b472:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
            proc->wait_state = 0;
c010b478:	8b 45 08             	mov    0x8(%ebp),%eax
c010b47b:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
            if (proc != current) {
c010b482:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010b487:	39 45 08             	cmp    %eax,0x8(%ebp)
c010b48a:	74 29                	je     c010b4b5 <wakeup_proc+0x8c>
                sched_class_enqueue(proc);
c010b48c:	8b 45 08             	mov    0x8(%ebp),%eax
c010b48f:	89 04 24             	mov    %eax,(%esp)
c010b492:	e8 84 fe ff ff       	call   c010b31b <sched_class_enqueue>
c010b497:	eb 1c                	jmp    c010b4b5 <wakeup_proc+0x8c>
            }
        }
        else {
            warn("wakeup runnable process.\n");
c010b499:	c7 44 24 08 f3 e8 10 	movl   $0xc010e8f3,0x8(%esp)
c010b4a0:	c0 
c010b4a1:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c010b4a8:	00 
c010b4a9:	c7 04 24 dd e8 10 c0 	movl   $0xc010e8dd,(%esp)
c010b4b0:	e8 91 59 ff ff       	call   c0100e46 <__warn>
        }
    }
    local_intr_restore(intr_flag);
c010b4b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4b8:	89 04 24             	mov    %eax,(%esp)
c010b4bb:	e8 48 fe ff ff       	call   c010b308 <__intr_restore>
}
c010b4c0:	c9                   	leave  
c010b4c1:	c3                   	ret    

c010b4c2 <schedule>:

void
schedule(void) {
c010b4c2:	55                   	push   %ebp
c010b4c3:	89 e5                	mov    %esp,%ebp
c010b4c5:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
c010b4c8:	e8 11 fe ff ff       	call   c010b2de <__intr_save>
c010b4cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        current->need_resched = 0;
c010b4d0:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010b4d5:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        if (current->state == PROC_RUNNABLE) {
c010b4dc:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010b4e1:	8b 00                	mov    (%eax),%eax
c010b4e3:	83 f8 02             	cmp    $0x2,%eax
c010b4e6:	75 0d                	jne    c010b4f5 <schedule+0x33>
            sched_class_enqueue(current);
c010b4e8:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010b4ed:	89 04 24             	mov    %eax,(%esp)
c010b4f0:	e8 26 fe ff ff       	call   c010b31b <sched_class_enqueue>
        }
        if ((next = sched_class_pick_next()) != NULL) {
c010b4f5:	e8 6f fe ff ff       	call   c010b369 <sched_class_pick_next>
c010b4fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b4fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b501:	74 0b                	je     c010b50e <schedule+0x4c>
            sched_class_dequeue(next);
c010b503:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b506:	89 04 24             	mov    %eax,(%esp)
c010b509:	e8 39 fe ff ff       	call   c010b347 <sched_class_dequeue>
        }
        if (next == NULL) {
c010b50e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b512:	75 08                	jne    c010b51c <schedule+0x5a>
            next = idleproc;
c010b514:	a1 20 ee 1a c0       	mov    0xc01aee20,%eax
c010b519:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        next->runs ++;
c010b51c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b51f:	8b 40 08             	mov    0x8(%eax),%eax
c010b522:	8d 50 01             	lea    0x1(%eax),%edx
c010b525:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b528:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010b52b:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010b530:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010b533:	74 0b                	je     c010b540 <schedule+0x7e>
            proc_run(next);
c010b535:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b538:	89 04 24             	mov    %eax,(%esp)
c010b53b:	e8 06 e4 ff ff       	call   c0109946 <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010b540:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b543:	89 04 24             	mov    %eax,(%esp)
c010b546:	e8 bd fd ff ff       	call   c010b308 <__intr_restore>
}
c010b54b:	c9                   	leave  
c010b54c:	c3                   	ret    

c010b54d <sys_exit>:
#include <pmm.h>
#include <assert.h>
#include <clock.h>

static int
sys_exit(uint32_t arg[]) {
c010b54d:	55                   	push   %ebp
c010b54e:	89 e5                	mov    %esp,%ebp
c010b550:	83 ec 28             	sub    $0x28,%esp
    int error_code = (int)arg[0];
c010b553:	8b 45 08             	mov    0x8(%ebp),%eax
c010b556:	8b 00                	mov    (%eax),%eax
c010b558:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_exit(error_code);
c010b55b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b55e:	89 04 24             	mov    %eax,(%esp)
c010b561:	e8 51 ea ff ff       	call   c0109fb7 <do_exit>
}
c010b566:	c9                   	leave  
c010b567:	c3                   	ret    

c010b568 <sys_fork>:

static int
sys_fork(uint32_t arg[]) {
c010b568:	55                   	push   %ebp
c010b569:	89 e5                	mov    %esp,%ebp
c010b56b:	83 ec 28             	sub    $0x28,%esp
    struct trapframe *tf = current->tf;
c010b56e:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010b573:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b576:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uintptr_t stack = tf->tf_esp;
c010b579:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b57c:	8b 40 44             	mov    0x44(%eax),%eax
c010b57f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_fork(0, stack, tf);
c010b582:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b585:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b589:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b58c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b590:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010b597:	e8 ed e8 ff ff       	call   c0109e89 <do_fork>
}
c010b59c:	c9                   	leave  
c010b59d:	c3                   	ret    

c010b59e <sys_wait>:

static int
sys_wait(uint32_t arg[]) {
c010b59e:	55                   	push   %ebp
c010b59f:	89 e5                	mov    %esp,%ebp
c010b5a1:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b5a4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5a7:	8b 00                	mov    (%eax),%eax
c010b5a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int *store = (int *)arg[1];
c010b5ac:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5af:	83 c0 04             	add    $0x4,%eax
c010b5b2:	8b 00                	mov    (%eax),%eax
c010b5b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_wait(pid, store);
c010b5b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b5ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b5be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5c1:	89 04 24             	mov    %eax,(%esp)
c010b5c4:	e8 6c f3 ff ff       	call   c010a935 <do_wait>
}
c010b5c9:	c9                   	leave  
c010b5ca:	c3                   	ret    

c010b5cb <sys_exec>:

static int
sys_exec(uint32_t arg[]) {
c010b5cb:	55                   	push   %ebp
c010b5cc:	89 e5                	mov    %esp,%ebp
c010b5ce:	83 ec 28             	sub    $0x28,%esp
    const char *name = (const char *)arg[0];
c010b5d1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5d4:	8b 00                	mov    (%eax),%eax
c010b5d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t len = (size_t)arg[1];
c010b5d9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5dc:	8b 40 04             	mov    0x4(%eax),%eax
c010b5df:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned char *binary = (unsigned char *)arg[2];
c010b5e2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5e5:	83 c0 08             	add    $0x8,%eax
c010b5e8:	8b 00                	mov    (%eax),%eax
c010b5ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t size = (size_t)arg[3];
c010b5ed:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5f0:	8b 40 0c             	mov    0xc(%eax),%eax
c010b5f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return do_execve(name, len, binary, size);
c010b5f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b5f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b5fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b600:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b604:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b607:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b60b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b60e:	89 04 24             	mov    %eax,(%esp)
c010b611:	e8 d3 f1 ff ff       	call   c010a7e9 <do_execve>
}
c010b616:	c9                   	leave  
c010b617:	c3                   	ret    

c010b618 <sys_yield>:

static int
sys_yield(uint32_t arg[]) {
c010b618:	55                   	push   %ebp
c010b619:	89 e5                	mov    %esp,%ebp
c010b61b:	83 ec 08             	sub    $0x8,%esp
    return do_yield();
c010b61e:	e8 fc f2 ff ff       	call   c010a91f <do_yield>
}
c010b623:	c9                   	leave  
c010b624:	c3                   	ret    

c010b625 <sys_kill>:

static int
sys_kill(uint32_t arg[]) {
c010b625:	55                   	push   %ebp
c010b626:	89 e5                	mov    %esp,%ebp
c010b628:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b62b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b62e:	8b 00                	mov    (%eax),%eax
c010b630:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_kill(pid);
c010b633:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b636:	89 04 24             	mov    %eax,(%esp)
c010b639:	e8 8b f4 ff ff       	call   c010aac9 <do_kill>
}
c010b63e:	c9                   	leave  
c010b63f:	c3                   	ret    

c010b640 <sys_getpid>:

static int
sys_getpid(uint32_t arg[]) {
c010b640:	55                   	push   %ebp
c010b641:	89 e5                	mov    %esp,%ebp
    return current->pid;
c010b643:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010b648:	8b 40 04             	mov    0x4(%eax),%eax
}
c010b64b:	5d                   	pop    %ebp
c010b64c:	c3                   	ret    

c010b64d <sys_putc>:

static int
sys_putc(uint32_t arg[]) {
c010b64d:	55                   	push   %ebp
c010b64e:	89 e5                	mov    %esp,%ebp
c010b650:	83 ec 28             	sub    $0x28,%esp
    int c = (int)arg[0];
c010b653:	8b 45 08             	mov    0x8(%ebp),%eax
c010b656:	8b 00                	mov    (%eax),%eax
c010b658:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cputchar(c);
c010b65b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b65e:	89 04 24             	mov    %eax,(%esp)
c010b661:	e8 18 4d ff ff       	call   c010037e <cputchar>
    return 0;
c010b666:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b66b:	c9                   	leave  
c010b66c:	c3                   	ret    

c010b66d <sys_pgdir>:

static int
sys_pgdir(uint32_t arg[]) {
c010b66d:	55                   	push   %ebp
c010b66e:	89 e5                	mov    %esp,%ebp
c010b670:	83 ec 08             	sub    $0x8,%esp
    print_pgdir();
c010b673:	e8 fa b4 ff ff       	call   c0106b72 <print_pgdir>
    return 0;
c010b678:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b67d:	c9                   	leave  
c010b67e:	c3                   	ret    

c010b67f <sys_gettime>:

static int
sys_gettime(uint32_t arg[]) {
c010b67f:	55                   	push   %ebp
c010b680:	89 e5                	mov    %esp,%ebp
    return (int)ticks;
c010b682:	a1 78 0e 1b c0       	mov    0xc01b0e78,%eax
}
c010b687:	5d                   	pop    %ebp
c010b688:	c3                   	ret    

c010b689 <sys_lab6_set_priority>:
static int
sys_lab6_set_priority(uint32_t arg[])
{
c010b689:	55                   	push   %ebp
c010b68a:	89 e5                	mov    %esp,%ebp
c010b68c:	83 ec 28             	sub    $0x28,%esp
    uint32_t priority = (uint32_t)arg[0];
c010b68f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b692:	8b 00                	mov    (%eax),%eax
c010b694:	89 45 f4             	mov    %eax,-0xc(%ebp)
    lab6_set_priority(priority);
c010b697:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b69a:	89 04 24             	mov    %eax,(%esp)
c010b69d:	e8 82 f8 ff ff       	call   c010af24 <lab6_set_priority>
    return 0;
c010b6a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b6a7:	c9                   	leave  
c010b6a8:	c3                   	ret    

c010b6a9 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
c010b6a9:	55                   	push   %ebp
c010b6aa:	89 e5                	mov    %esp,%ebp
c010b6ac:	83 ec 48             	sub    $0x48,%esp
    struct trapframe *tf = current->tf;
c010b6af:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010b6b4:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b6b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t arg[5];
    int num = tf->tf_regs.reg_eax;
c010b6ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b6bd:	8b 40 1c             	mov    0x1c(%eax),%eax
c010b6c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num >= 0 && num < NUM_SYSCALLS) {
c010b6c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b6c7:	78 60                	js     c010b729 <syscall+0x80>
c010b6c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b6cc:	3d ff 00 00 00       	cmp    $0xff,%eax
c010b6d1:	77 56                	ja     c010b729 <syscall+0x80>
        if (syscalls[num] != NULL) {
c010b6d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b6d6:	8b 04 85 a0 ca 12 c0 	mov    -0x3fed3560(,%eax,4),%eax
c010b6dd:	85 c0                	test   %eax,%eax
c010b6df:	74 48                	je     c010b729 <syscall+0x80>
            arg[0] = tf->tf_regs.reg_edx;
c010b6e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b6e4:	8b 40 14             	mov    0x14(%eax),%eax
c010b6e7:	89 45 dc             	mov    %eax,-0x24(%ebp)
            arg[1] = tf->tf_regs.reg_ecx;
c010b6ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b6ed:	8b 40 18             	mov    0x18(%eax),%eax
c010b6f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
            arg[2] = tf->tf_regs.reg_ebx;
c010b6f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b6f6:	8b 40 10             	mov    0x10(%eax),%eax
c010b6f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            arg[3] = tf->tf_regs.reg_edi;
c010b6fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b6ff:	8b 00                	mov    (%eax),%eax
c010b701:	89 45 e8             	mov    %eax,-0x18(%ebp)
            arg[4] = tf->tf_regs.reg_esi;
c010b704:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b707:	8b 40 04             	mov    0x4(%eax),%eax
c010b70a:	89 45 ec             	mov    %eax,-0x14(%ebp)
            tf->tf_regs.reg_eax = syscalls[num](arg);
c010b70d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b710:	8b 04 85 a0 ca 12 c0 	mov    -0x3fed3560(,%eax,4),%eax
c010b717:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010b71a:	89 14 24             	mov    %edx,(%esp)
c010b71d:	ff d0                	call   *%eax
c010b71f:	89 c2                	mov    %eax,%edx
c010b721:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b724:	89 50 1c             	mov    %edx,0x1c(%eax)
            return ;
c010b727:	eb 46                	jmp    c010b76f <syscall+0xc6>
        }
    }
    print_trapframe(tf);
c010b729:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b72c:	89 04 24             	mov    %eax,(%esp)
c010b72f:	e8 bb 6c ff ff       	call   c01023ef <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
c010b734:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010b739:	8d 50 48             	lea    0x48(%eax),%edx
c010b73c:	a1 28 ee 1a c0       	mov    0xc01aee28,%eax
c010b741:	8b 40 04             	mov    0x4(%eax),%eax
c010b744:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b748:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b74c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b74f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b753:	c7 44 24 08 10 e9 10 	movl   $0xc010e910,0x8(%esp)
c010b75a:	c0 
c010b75b:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c010b762:	00 
c010b763:	c7 04 24 3c e9 10 c0 	movl   $0xc010e93c,(%esp)
c010b76a:	e8 6b 56 ff ff       	call   c0100dda <__panic>
            num, current->pid, current->name);
}
c010b76f:	c9                   	leave  
c010b770:	c3                   	ret    

c010b771 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010b771:	55                   	push   %ebp
c010b772:	89 e5                	mov    %esp,%ebp
c010b774:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010b777:	8b 45 08             	mov    0x8(%ebp),%eax
c010b77a:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010b780:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010b783:	b8 20 00 00 00       	mov    $0x20,%eax
c010b788:	2b 45 0c             	sub    0xc(%ebp),%eax
c010b78b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010b78e:	89 c1                	mov    %eax,%ecx
c010b790:	d3 ea                	shr    %cl,%edx
c010b792:	89 d0                	mov    %edx,%eax
}
c010b794:	c9                   	leave  
c010b795:	c3                   	ret    

c010b796 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010b796:	55                   	push   %ebp
c010b797:	89 e5                	mov    %esp,%ebp
c010b799:	83 ec 58             	sub    $0x58,%esp
c010b79c:	8b 45 10             	mov    0x10(%ebp),%eax
c010b79f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010b7a2:	8b 45 14             	mov    0x14(%ebp),%eax
c010b7a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010b7a8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010b7ab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010b7ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b7b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010b7b4:	8b 45 18             	mov    0x18(%ebp),%eax
c010b7b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b7ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b7bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b7c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b7c3:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b7c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b7c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b7cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b7d0:	74 1c                	je     c010b7ee <printnum+0x58>
c010b7d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b7d5:	ba 00 00 00 00       	mov    $0x0,%edx
c010b7da:	f7 75 e4             	divl   -0x1c(%ebp)
c010b7dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010b7e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b7e3:	ba 00 00 00 00       	mov    $0x0,%edx
c010b7e8:	f7 75 e4             	divl   -0x1c(%ebp)
c010b7eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b7ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b7f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b7f4:	f7 75 e4             	divl   -0x1c(%ebp)
c010b7f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b7fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010b7fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b800:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b803:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b806:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010b809:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b80c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010b80f:	8b 45 18             	mov    0x18(%ebp),%eax
c010b812:	ba 00 00 00 00       	mov    $0x0,%edx
c010b817:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010b81a:	77 56                	ja     c010b872 <printnum+0xdc>
c010b81c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010b81f:	72 05                	jb     c010b826 <printnum+0x90>
c010b821:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010b824:	77 4c                	ja     c010b872 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010b826:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010b829:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b82c:	8b 45 20             	mov    0x20(%ebp),%eax
c010b82f:	89 44 24 18          	mov    %eax,0x18(%esp)
c010b833:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b837:	8b 45 18             	mov    0x18(%ebp),%eax
c010b83a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b83e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b841:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b844:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b848:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010b84c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b84f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b853:	8b 45 08             	mov    0x8(%ebp),%eax
c010b856:	89 04 24             	mov    %eax,(%esp)
c010b859:	e8 38 ff ff ff       	call   c010b796 <printnum>
c010b85e:	eb 1c                	jmp    c010b87c <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010b860:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b863:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b867:	8b 45 20             	mov    0x20(%ebp),%eax
c010b86a:	89 04 24             	mov    %eax,(%esp)
c010b86d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b870:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010b872:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010b876:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010b87a:	7f e4                	jg     c010b860 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010b87c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b87f:	05 64 ea 10 c0       	add    $0xc010ea64,%eax
c010b884:	0f b6 00             	movzbl (%eax),%eax
c010b887:	0f be c0             	movsbl %al,%eax
c010b88a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b88d:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b891:	89 04 24             	mov    %eax,(%esp)
c010b894:	8b 45 08             	mov    0x8(%ebp),%eax
c010b897:	ff d0                	call   *%eax
}
c010b899:	c9                   	leave  
c010b89a:	c3                   	ret    

c010b89b <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010b89b:	55                   	push   %ebp
c010b89c:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b89e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b8a2:	7e 14                	jle    c010b8b8 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010b8a4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8a7:	8b 00                	mov    (%eax),%eax
c010b8a9:	8d 48 08             	lea    0x8(%eax),%ecx
c010b8ac:	8b 55 08             	mov    0x8(%ebp),%edx
c010b8af:	89 0a                	mov    %ecx,(%edx)
c010b8b1:	8b 50 04             	mov    0x4(%eax),%edx
c010b8b4:	8b 00                	mov    (%eax),%eax
c010b8b6:	eb 30                	jmp    c010b8e8 <getuint+0x4d>
    }
    else if (lflag) {
c010b8b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b8bc:	74 16                	je     c010b8d4 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010b8be:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8c1:	8b 00                	mov    (%eax),%eax
c010b8c3:	8d 48 04             	lea    0x4(%eax),%ecx
c010b8c6:	8b 55 08             	mov    0x8(%ebp),%edx
c010b8c9:	89 0a                	mov    %ecx,(%edx)
c010b8cb:	8b 00                	mov    (%eax),%eax
c010b8cd:	ba 00 00 00 00       	mov    $0x0,%edx
c010b8d2:	eb 14                	jmp    c010b8e8 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010b8d4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8d7:	8b 00                	mov    (%eax),%eax
c010b8d9:	8d 48 04             	lea    0x4(%eax),%ecx
c010b8dc:	8b 55 08             	mov    0x8(%ebp),%edx
c010b8df:	89 0a                	mov    %ecx,(%edx)
c010b8e1:	8b 00                	mov    (%eax),%eax
c010b8e3:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010b8e8:	5d                   	pop    %ebp
c010b8e9:	c3                   	ret    

c010b8ea <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010b8ea:	55                   	push   %ebp
c010b8eb:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b8ed:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b8f1:	7e 14                	jle    c010b907 <getint+0x1d>
        return va_arg(*ap, long long);
c010b8f3:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8f6:	8b 00                	mov    (%eax),%eax
c010b8f8:	8d 48 08             	lea    0x8(%eax),%ecx
c010b8fb:	8b 55 08             	mov    0x8(%ebp),%edx
c010b8fe:	89 0a                	mov    %ecx,(%edx)
c010b900:	8b 50 04             	mov    0x4(%eax),%edx
c010b903:	8b 00                	mov    (%eax),%eax
c010b905:	eb 28                	jmp    c010b92f <getint+0x45>
    }
    else if (lflag) {
c010b907:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b90b:	74 12                	je     c010b91f <getint+0x35>
        return va_arg(*ap, long);
c010b90d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b910:	8b 00                	mov    (%eax),%eax
c010b912:	8d 48 04             	lea    0x4(%eax),%ecx
c010b915:	8b 55 08             	mov    0x8(%ebp),%edx
c010b918:	89 0a                	mov    %ecx,(%edx)
c010b91a:	8b 00                	mov    (%eax),%eax
c010b91c:	99                   	cltd   
c010b91d:	eb 10                	jmp    c010b92f <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010b91f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b922:	8b 00                	mov    (%eax),%eax
c010b924:	8d 48 04             	lea    0x4(%eax),%ecx
c010b927:	8b 55 08             	mov    0x8(%ebp),%edx
c010b92a:	89 0a                	mov    %ecx,(%edx)
c010b92c:	8b 00                	mov    (%eax),%eax
c010b92e:	99                   	cltd   
    }
}
c010b92f:	5d                   	pop    %ebp
c010b930:	c3                   	ret    

c010b931 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010b931:	55                   	push   %ebp
c010b932:	89 e5                	mov    %esp,%ebp
c010b934:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010b937:	8d 45 14             	lea    0x14(%ebp),%eax
c010b93a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010b93d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b940:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b944:	8b 45 10             	mov    0x10(%ebp),%eax
c010b947:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b94b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b94e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b952:	8b 45 08             	mov    0x8(%ebp),%eax
c010b955:	89 04 24             	mov    %eax,(%esp)
c010b958:	e8 02 00 00 00       	call   c010b95f <vprintfmt>
    va_end(ap);
}
c010b95d:	c9                   	leave  
c010b95e:	c3                   	ret    

c010b95f <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010b95f:	55                   	push   %ebp
c010b960:	89 e5                	mov    %esp,%ebp
c010b962:	56                   	push   %esi
c010b963:	53                   	push   %ebx
c010b964:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b967:	eb 18                	jmp    c010b981 <vprintfmt+0x22>
            if (ch == '\0') {
c010b969:	85 db                	test   %ebx,%ebx
c010b96b:	75 05                	jne    c010b972 <vprintfmt+0x13>
                return;
c010b96d:	e9 d1 03 00 00       	jmp    c010bd43 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c010b972:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b975:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b979:	89 1c 24             	mov    %ebx,(%esp)
c010b97c:	8b 45 08             	mov    0x8(%ebp),%eax
c010b97f:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b981:	8b 45 10             	mov    0x10(%ebp),%eax
c010b984:	8d 50 01             	lea    0x1(%eax),%edx
c010b987:	89 55 10             	mov    %edx,0x10(%ebp)
c010b98a:	0f b6 00             	movzbl (%eax),%eax
c010b98d:	0f b6 d8             	movzbl %al,%ebx
c010b990:	83 fb 25             	cmp    $0x25,%ebx
c010b993:	75 d4                	jne    c010b969 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010b995:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010b999:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010b9a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b9a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010b9a6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010b9ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b9b0:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010b9b3:	8b 45 10             	mov    0x10(%ebp),%eax
c010b9b6:	8d 50 01             	lea    0x1(%eax),%edx
c010b9b9:	89 55 10             	mov    %edx,0x10(%ebp)
c010b9bc:	0f b6 00             	movzbl (%eax),%eax
c010b9bf:	0f b6 d8             	movzbl %al,%ebx
c010b9c2:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010b9c5:	83 f8 55             	cmp    $0x55,%eax
c010b9c8:	0f 87 44 03 00 00    	ja     c010bd12 <vprintfmt+0x3b3>
c010b9ce:	8b 04 85 88 ea 10 c0 	mov    -0x3fef1578(,%eax,4),%eax
c010b9d5:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010b9d7:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010b9db:	eb d6                	jmp    c010b9b3 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010b9dd:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010b9e1:	eb d0                	jmp    c010b9b3 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010b9e3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010b9ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b9ed:	89 d0                	mov    %edx,%eax
c010b9ef:	c1 e0 02             	shl    $0x2,%eax
c010b9f2:	01 d0                	add    %edx,%eax
c010b9f4:	01 c0                	add    %eax,%eax
c010b9f6:	01 d8                	add    %ebx,%eax
c010b9f8:	83 e8 30             	sub    $0x30,%eax
c010b9fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010b9fe:	8b 45 10             	mov    0x10(%ebp),%eax
c010ba01:	0f b6 00             	movzbl (%eax),%eax
c010ba04:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010ba07:	83 fb 2f             	cmp    $0x2f,%ebx
c010ba0a:	7e 0b                	jle    c010ba17 <vprintfmt+0xb8>
c010ba0c:	83 fb 39             	cmp    $0x39,%ebx
c010ba0f:	7f 06                	jg     c010ba17 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010ba11:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c010ba15:	eb d3                	jmp    c010b9ea <vprintfmt+0x8b>
            goto process_precision;
c010ba17:	eb 33                	jmp    c010ba4c <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c010ba19:	8b 45 14             	mov    0x14(%ebp),%eax
c010ba1c:	8d 50 04             	lea    0x4(%eax),%edx
c010ba1f:	89 55 14             	mov    %edx,0x14(%ebp)
c010ba22:	8b 00                	mov    (%eax),%eax
c010ba24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010ba27:	eb 23                	jmp    c010ba4c <vprintfmt+0xed>

        case '.':
            if (width < 0)
c010ba29:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010ba2d:	79 0c                	jns    c010ba3b <vprintfmt+0xdc>
                width = 0;
c010ba2f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010ba36:	e9 78 ff ff ff       	jmp    c010b9b3 <vprintfmt+0x54>
c010ba3b:	e9 73 ff ff ff       	jmp    c010b9b3 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010ba40:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010ba47:	e9 67 ff ff ff       	jmp    c010b9b3 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010ba4c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010ba50:	79 12                	jns    c010ba64 <vprintfmt+0x105>
                width = precision, precision = -1;
c010ba52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010ba55:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010ba58:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010ba5f:	e9 4f ff ff ff       	jmp    c010b9b3 <vprintfmt+0x54>
c010ba64:	e9 4a ff ff ff       	jmp    c010b9b3 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010ba69:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010ba6d:	e9 41 ff ff ff       	jmp    c010b9b3 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010ba72:	8b 45 14             	mov    0x14(%ebp),%eax
c010ba75:	8d 50 04             	lea    0x4(%eax),%edx
c010ba78:	89 55 14             	mov    %edx,0x14(%ebp)
c010ba7b:	8b 00                	mov    (%eax),%eax
c010ba7d:	8b 55 0c             	mov    0xc(%ebp),%edx
c010ba80:	89 54 24 04          	mov    %edx,0x4(%esp)
c010ba84:	89 04 24             	mov    %eax,(%esp)
c010ba87:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba8a:	ff d0                	call   *%eax
            break;
c010ba8c:	e9 ac 02 00 00       	jmp    c010bd3d <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010ba91:	8b 45 14             	mov    0x14(%ebp),%eax
c010ba94:	8d 50 04             	lea    0x4(%eax),%edx
c010ba97:	89 55 14             	mov    %edx,0x14(%ebp)
c010ba9a:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010ba9c:	85 db                	test   %ebx,%ebx
c010ba9e:	79 02                	jns    c010baa2 <vprintfmt+0x143>
                err = -err;
c010baa0:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010baa2:	83 fb 18             	cmp    $0x18,%ebx
c010baa5:	7f 0b                	jg     c010bab2 <vprintfmt+0x153>
c010baa7:	8b 34 9d 00 ea 10 c0 	mov    -0x3fef1600(,%ebx,4),%esi
c010baae:	85 f6                	test   %esi,%esi
c010bab0:	75 23                	jne    c010bad5 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c010bab2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010bab6:	c7 44 24 08 75 ea 10 	movl   $0xc010ea75,0x8(%esp)
c010babd:	c0 
c010babe:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bac1:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bac5:	8b 45 08             	mov    0x8(%ebp),%eax
c010bac8:	89 04 24             	mov    %eax,(%esp)
c010bacb:	e8 61 fe ff ff       	call   c010b931 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010bad0:	e9 68 02 00 00       	jmp    c010bd3d <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010bad5:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010bad9:	c7 44 24 08 7e ea 10 	movl   $0xc010ea7e,0x8(%esp)
c010bae0:	c0 
c010bae1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bae4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bae8:	8b 45 08             	mov    0x8(%ebp),%eax
c010baeb:	89 04 24             	mov    %eax,(%esp)
c010baee:	e8 3e fe ff ff       	call   c010b931 <printfmt>
            }
            break;
c010baf3:	e9 45 02 00 00       	jmp    c010bd3d <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010baf8:	8b 45 14             	mov    0x14(%ebp),%eax
c010bafb:	8d 50 04             	lea    0x4(%eax),%edx
c010bafe:	89 55 14             	mov    %edx,0x14(%ebp)
c010bb01:	8b 30                	mov    (%eax),%esi
c010bb03:	85 f6                	test   %esi,%esi
c010bb05:	75 05                	jne    c010bb0c <vprintfmt+0x1ad>
                p = "(null)";
c010bb07:	be 81 ea 10 c0       	mov    $0xc010ea81,%esi
            }
            if (width > 0 && padc != '-') {
c010bb0c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bb10:	7e 3e                	jle    c010bb50 <vprintfmt+0x1f1>
c010bb12:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010bb16:	74 38                	je     c010bb50 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010bb18:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010bb1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bb1e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bb22:	89 34 24             	mov    %esi,(%esp)
c010bb25:	e8 ed 03 00 00       	call   c010bf17 <strnlen>
c010bb2a:	29 c3                	sub    %eax,%ebx
c010bb2c:	89 d8                	mov    %ebx,%eax
c010bb2e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bb31:	eb 17                	jmp    c010bb4a <vprintfmt+0x1eb>
                    putch(padc, putdat);
c010bb33:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010bb37:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bb3a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010bb3e:	89 04 24             	mov    %eax,(%esp)
c010bb41:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb44:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c010bb46:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010bb4a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bb4e:	7f e3                	jg     c010bb33 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010bb50:	eb 38                	jmp    c010bb8a <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c010bb52:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010bb56:	74 1f                	je     c010bb77 <vprintfmt+0x218>
c010bb58:	83 fb 1f             	cmp    $0x1f,%ebx
c010bb5b:	7e 05                	jle    c010bb62 <vprintfmt+0x203>
c010bb5d:	83 fb 7e             	cmp    $0x7e,%ebx
c010bb60:	7e 15                	jle    c010bb77 <vprintfmt+0x218>
                    putch('?', putdat);
c010bb62:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb65:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bb69:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010bb70:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb73:	ff d0                	call   *%eax
c010bb75:	eb 0f                	jmp    c010bb86 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c010bb77:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb7a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bb7e:	89 1c 24             	mov    %ebx,(%esp)
c010bb81:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb84:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010bb86:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010bb8a:	89 f0                	mov    %esi,%eax
c010bb8c:	8d 70 01             	lea    0x1(%eax),%esi
c010bb8f:	0f b6 00             	movzbl (%eax),%eax
c010bb92:	0f be d8             	movsbl %al,%ebx
c010bb95:	85 db                	test   %ebx,%ebx
c010bb97:	74 10                	je     c010bba9 <vprintfmt+0x24a>
c010bb99:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010bb9d:	78 b3                	js     c010bb52 <vprintfmt+0x1f3>
c010bb9f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010bba3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010bba7:	79 a9                	jns    c010bb52 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010bba9:	eb 17                	jmp    c010bbc2 <vprintfmt+0x263>
                putch(' ', putdat);
c010bbab:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bbae:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bbb2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010bbb9:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbbc:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010bbbe:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010bbc2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bbc6:	7f e3                	jg     c010bbab <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c010bbc8:	e9 70 01 00 00       	jmp    c010bd3d <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010bbcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bbd0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bbd4:	8d 45 14             	lea    0x14(%ebp),%eax
c010bbd7:	89 04 24             	mov    %eax,(%esp)
c010bbda:	e8 0b fd ff ff       	call   c010b8ea <getint>
c010bbdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bbe2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010bbe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bbe8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bbeb:	85 d2                	test   %edx,%edx
c010bbed:	79 26                	jns    c010bc15 <vprintfmt+0x2b6>
                putch('-', putdat);
c010bbef:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bbf2:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bbf6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010bbfd:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc00:	ff d0                	call   *%eax
                num = -(long long)num;
c010bc02:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bc05:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bc08:	f7 d8                	neg    %eax
c010bc0a:	83 d2 00             	adc    $0x0,%edx
c010bc0d:	f7 da                	neg    %edx
c010bc0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bc12:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010bc15:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010bc1c:	e9 a8 00 00 00       	jmp    c010bcc9 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010bc21:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bc24:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc28:	8d 45 14             	lea    0x14(%ebp),%eax
c010bc2b:	89 04 24             	mov    %eax,(%esp)
c010bc2e:	e8 68 fc ff ff       	call   c010b89b <getuint>
c010bc33:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bc36:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010bc39:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010bc40:	e9 84 00 00 00       	jmp    c010bcc9 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010bc45:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bc48:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc4c:	8d 45 14             	lea    0x14(%ebp),%eax
c010bc4f:	89 04 24             	mov    %eax,(%esp)
c010bc52:	e8 44 fc ff ff       	call   c010b89b <getuint>
c010bc57:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bc5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010bc5d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010bc64:	eb 63                	jmp    c010bcc9 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c010bc66:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc69:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc6d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010bc74:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc77:	ff d0                	call   *%eax
            putch('x', putdat);
c010bc79:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc7c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc80:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010bc87:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc8a:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010bc8c:	8b 45 14             	mov    0x14(%ebp),%eax
c010bc8f:	8d 50 04             	lea    0x4(%eax),%edx
c010bc92:	89 55 14             	mov    %edx,0x14(%ebp)
c010bc95:	8b 00                	mov    (%eax),%eax
c010bc97:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bc9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010bca1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010bca8:	eb 1f                	jmp    c010bcc9 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010bcaa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bcad:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bcb1:	8d 45 14             	lea    0x14(%ebp),%eax
c010bcb4:	89 04 24             	mov    %eax,(%esp)
c010bcb7:	e8 df fb ff ff       	call   c010b89b <getuint>
c010bcbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bcbf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010bcc2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010bcc9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010bccd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bcd0:	89 54 24 18          	mov    %edx,0x18(%esp)
c010bcd4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010bcd7:	89 54 24 14          	mov    %edx,0x14(%esp)
c010bcdb:	89 44 24 10          	mov    %eax,0x10(%esp)
c010bcdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bce2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bce5:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bce9:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010bced:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bcf0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bcf4:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcf7:	89 04 24             	mov    %eax,(%esp)
c010bcfa:	e8 97 fa ff ff       	call   c010b796 <printnum>
            break;
c010bcff:	eb 3c                	jmp    c010bd3d <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010bd01:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd04:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd08:	89 1c 24             	mov    %ebx,(%esp)
c010bd0b:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd0e:	ff d0                	call   *%eax
            break;
c010bd10:	eb 2b                	jmp    c010bd3d <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010bd12:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd15:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd19:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010bd20:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd23:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010bd25:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010bd29:	eb 04                	jmp    c010bd2f <vprintfmt+0x3d0>
c010bd2b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010bd2f:	8b 45 10             	mov    0x10(%ebp),%eax
c010bd32:	83 e8 01             	sub    $0x1,%eax
c010bd35:	0f b6 00             	movzbl (%eax),%eax
c010bd38:	3c 25                	cmp    $0x25,%al
c010bd3a:	75 ef                	jne    c010bd2b <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c010bd3c:	90                   	nop
        }
    }
c010bd3d:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010bd3e:	e9 3e fc ff ff       	jmp    c010b981 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c010bd43:	83 c4 40             	add    $0x40,%esp
c010bd46:	5b                   	pop    %ebx
c010bd47:	5e                   	pop    %esi
c010bd48:	5d                   	pop    %ebp
c010bd49:	c3                   	ret    

c010bd4a <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010bd4a:	55                   	push   %ebp
c010bd4b:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010bd4d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd50:	8b 40 08             	mov    0x8(%eax),%eax
c010bd53:	8d 50 01             	lea    0x1(%eax),%edx
c010bd56:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd59:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010bd5c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd5f:	8b 10                	mov    (%eax),%edx
c010bd61:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd64:	8b 40 04             	mov    0x4(%eax),%eax
c010bd67:	39 c2                	cmp    %eax,%edx
c010bd69:	73 12                	jae    c010bd7d <sprintputch+0x33>
        *b->buf ++ = ch;
c010bd6b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd6e:	8b 00                	mov    (%eax),%eax
c010bd70:	8d 48 01             	lea    0x1(%eax),%ecx
c010bd73:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bd76:	89 0a                	mov    %ecx,(%edx)
c010bd78:	8b 55 08             	mov    0x8(%ebp),%edx
c010bd7b:	88 10                	mov    %dl,(%eax)
    }
}
c010bd7d:	5d                   	pop    %ebp
c010bd7e:	c3                   	ret    

c010bd7f <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010bd7f:	55                   	push   %ebp
c010bd80:	89 e5                	mov    %esp,%ebp
c010bd82:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010bd85:	8d 45 14             	lea    0x14(%ebp),%eax
c010bd88:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010bd8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bd8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bd92:	8b 45 10             	mov    0x10(%ebp),%eax
c010bd95:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bd99:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd9c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bda0:	8b 45 08             	mov    0x8(%ebp),%eax
c010bda3:	89 04 24             	mov    %eax,(%esp)
c010bda6:	e8 08 00 00 00       	call   c010bdb3 <vsnprintf>
c010bdab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010bdae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010bdb1:	c9                   	leave  
c010bdb2:	c3                   	ret    

c010bdb3 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010bdb3:	55                   	push   %ebp
c010bdb4:	89 e5                	mov    %esp,%ebp
c010bdb6:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010bdb9:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdbc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bdbf:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bdc2:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bdc5:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdc8:	01 d0                	add    %edx,%eax
c010bdca:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bdcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010bdd4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010bdd8:	74 0a                	je     c010bde4 <vsnprintf+0x31>
c010bdda:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bde0:	39 c2                	cmp    %eax,%edx
c010bde2:	76 07                	jbe    c010bdeb <vsnprintf+0x38>
        return -E_INVAL;
c010bde4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010bde9:	eb 2a                	jmp    c010be15 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010bdeb:	8b 45 14             	mov    0x14(%ebp),%eax
c010bdee:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bdf2:	8b 45 10             	mov    0x10(%ebp),%eax
c010bdf5:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bdf9:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010bdfc:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be00:	c7 04 24 4a bd 10 c0 	movl   $0xc010bd4a,(%esp)
c010be07:	e8 53 fb ff ff       	call   c010b95f <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010be0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010be0f:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010be12:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010be15:	c9                   	leave  
c010be16:	c3                   	ret    

c010be17 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010be17:	55                   	push   %ebp
c010be18:	89 e5                	mov    %esp,%ebp
c010be1a:	57                   	push   %edi
c010be1b:	56                   	push   %esi
c010be1c:	53                   	push   %ebx
c010be1d:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010be20:	a1 a0 ce 12 c0       	mov    0xc012cea0,%eax
c010be25:	8b 15 a4 ce 12 c0    	mov    0xc012cea4,%edx
c010be2b:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010be31:	6b f0 05             	imul   $0x5,%eax,%esi
c010be34:	01 f7                	add    %esi,%edi
c010be36:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c010be3b:	f7 e6                	mul    %esi
c010be3d:	8d 34 17             	lea    (%edi,%edx,1),%esi
c010be40:	89 f2                	mov    %esi,%edx
c010be42:	83 c0 0b             	add    $0xb,%eax
c010be45:	83 d2 00             	adc    $0x0,%edx
c010be48:	89 c7                	mov    %eax,%edi
c010be4a:	83 e7 ff             	and    $0xffffffff,%edi
c010be4d:	89 f9                	mov    %edi,%ecx
c010be4f:	0f b7 da             	movzwl %dx,%ebx
c010be52:	89 0d a0 ce 12 c0    	mov    %ecx,0xc012cea0
c010be58:	89 1d a4 ce 12 c0    	mov    %ebx,0xc012cea4
    unsigned long long result = (next >> 12);
c010be5e:	a1 a0 ce 12 c0       	mov    0xc012cea0,%eax
c010be63:	8b 15 a4 ce 12 c0    	mov    0xc012cea4,%edx
c010be69:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010be6d:	c1 ea 0c             	shr    $0xc,%edx
c010be70:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010be73:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010be76:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010be7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010be80:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010be83:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010be86:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010be89:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010be8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010be8f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010be93:	74 1c                	je     c010beb1 <rand+0x9a>
c010be95:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010be98:	ba 00 00 00 00       	mov    $0x0,%edx
c010be9d:	f7 75 dc             	divl   -0x24(%ebp)
c010bea0:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010bea3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bea6:	ba 00 00 00 00       	mov    $0x0,%edx
c010beab:	f7 75 dc             	divl   -0x24(%ebp)
c010beae:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010beb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010beb4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010beb7:	f7 75 dc             	divl   -0x24(%ebp)
c010beba:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010bebd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010bec0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010bec3:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010bec6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bec9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010becc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010becf:	83 c4 24             	add    $0x24,%esp
c010bed2:	5b                   	pop    %ebx
c010bed3:	5e                   	pop    %esi
c010bed4:	5f                   	pop    %edi
c010bed5:	5d                   	pop    %ebp
c010bed6:	c3                   	ret    

c010bed7 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010bed7:	55                   	push   %ebp
c010bed8:	89 e5                	mov    %esp,%ebp
    next = seed;
c010beda:	8b 45 08             	mov    0x8(%ebp),%eax
c010bedd:	ba 00 00 00 00       	mov    $0x0,%edx
c010bee2:	a3 a0 ce 12 c0       	mov    %eax,0xc012cea0
c010bee7:	89 15 a4 ce 12 c0    	mov    %edx,0xc012cea4
}
c010beed:	5d                   	pop    %ebp
c010beee:	c3                   	ret    

c010beef <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010beef:	55                   	push   %ebp
c010bef0:	89 e5                	mov    %esp,%ebp
c010bef2:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010bef5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010befc:	eb 04                	jmp    c010bf02 <strlen+0x13>
        cnt ++;
c010befe:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c010bf02:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf05:	8d 50 01             	lea    0x1(%eax),%edx
c010bf08:	89 55 08             	mov    %edx,0x8(%ebp)
c010bf0b:	0f b6 00             	movzbl (%eax),%eax
c010bf0e:	84 c0                	test   %al,%al
c010bf10:	75 ec                	jne    c010befe <strlen+0xf>
        cnt ++;
    }
    return cnt;
c010bf12:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010bf15:	c9                   	leave  
c010bf16:	c3                   	ret    

c010bf17 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010bf17:	55                   	push   %ebp
c010bf18:	89 e5                	mov    %esp,%ebp
c010bf1a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010bf1d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010bf24:	eb 04                	jmp    c010bf2a <strnlen+0x13>
        cnt ++;
c010bf26:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010bf2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bf2d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010bf30:	73 10                	jae    c010bf42 <strnlen+0x2b>
c010bf32:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf35:	8d 50 01             	lea    0x1(%eax),%edx
c010bf38:	89 55 08             	mov    %edx,0x8(%ebp)
c010bf3b:	0f b6 00             	movzbl (%eax),%eax
c010bf3e:	84 c0                	test   %al,%al
c010bf40:	75 e4                	jne    c010bf26 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c010bf42:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010bf45:	c9                   	leave  
c010bf46:	c3                   	ret    

c010bf47 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010bf47:	55                   	push   %ebp
c010bf48:	89 e5                	mov    %esp,%ebp
c010bf4a:	57                   	push   %edi
c010bf4b:	56                   	push   %esi
c010bf4c:	83 ec 20             	sub    $0x20,%esp
c010bf4f:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf52:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bf55:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf58:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010bf5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010bf5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bf61:	89 d1                	mov    %edx,%ecx
c010bf63:	89 c2                	mov    %eax,%edx
c010bf65:	89 ce                	mov    %ecx,%esi
c010bf67:	89 d7                	mov    %edx,%edi
c010bf69:	ac                   	lods   %ds:(%esi),%al
c010bf6a:	aa                   	stos   %al,%es:(%edi)
c010bf6b:	84 c0                	test   %al,%al
c010bf6d:	75 fa                	jne    c010bf69 <strcpy+0x22>
c010bf6f:	89 fa                	mov    %edi,%edx
c010bf71:	89 f1                	mov    %esi,%ecx
c010bf73:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010bf76:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010bf79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010bf7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010bf7f:	83 c4 20             	add    $0x20,%esp
c010bf82:	5e                   	pop    %esi
c010bf83:	5f                   	pop    %edi
c010bf84:	5d                   	pop    %ebp
c010bf85:	c3                   	ret    

c010bf86 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010bf86:	55                   	push   %ebp
c010bf87:	89 e5                	mov    %esp,%ebp
c010bf89:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010bf8c:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf8f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010bf92:	eb 21                	jmp    c010bfb5 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c010bf94:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf97:	0f b6 10             	movzbl (%eax),%edx
c010bf9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bf9d:	88 10                	mov    %dl,(%eax)
c010bf9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bfa2:	0f b6 00             	movzbl (%eax),%eax
c010bfa5:	84 c0                	test   %al,%al
c010bfa7:	74 04                	je     c010bfad <strncpy+0x27>
            src ++;
c010bfa9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010bfad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010bfb1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c010bfb5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bfb9:	75 d9                	jne    c010bf94 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010bfbb:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010bfbe:	c9                   	leave  
c010bfbf:	c3                   	ret    

c010bfc0 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010bfc0:	55                   	push   %ebp
c010bfc1:	89 e5                	mov    %esp,%ebp
c010bfc3:	57                   	push   %edi
c010bfc4:	56                   	push   %esi
c010bfc5:	83 ec 20             	sub    $0x20,%esp
c010bfc8:	8b 45 08             	mov    0x8(%ebp),%eax
c010bfcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bfce:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bfd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c010bfd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bfd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bfda:	89 d1                	mov    %edx,%ecx
c010bfdc:	89 c2                	mov    %eax,%edx
c010bfde:	89 ce                	mov    %ecx,%esi
c010bfe0:	89 d7                	mov    %edx,%edi
c010bfe2:	ac                   	lods   %ds:(%esi),%al
c010bfe3:	ae                   	scas   %es:(%edi),%al
c010bfe4:	75 08                	jne    c010bfee <strcmp+0x2e>
c010bfe6:	84 c0                	test   %al,%al
c010bfe8:	75 f8                	jne    c010bfe2 <strcmp+0x22>
c010bfea:	31 c0                	xor    %eax,%eax
c010bfec:	eb 04                	jmp    c010bff2 <strcmp+0x32>
c010bfee:	19 c0                	sbb    %eax,%eax
c010bff0:	0c 01                	or     $0x1,%al
c010bff2:	89 fa                	mov    %edi,%edx
c010bff4:	89 f1                	mov    %esi,%ecx
c010bff6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bff9:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010bffc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c010bfff:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010c002:	83 c4 20             	add    $0x20,%esp
c010c005:	5e                   	pop    %esi
c010c006:	5f                   	pop    %edi
c010c007:	5d                   	pop    %ebp
c010c008:	c3                   	ret    

c010c009 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010c009:	55                   	push   %ebp
c010c00a:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010c00c:	eb 0c                	jmp    c010c01a <strncmp+0x11>
        n --, s1 ++, s2 ++;
c010c00e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010c012:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010c016:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010c01a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c01e:	74 1a                	je     c010c03a <strncmp+0x31>
c010c020:	8b 45 08             	mov    0x8(%ebp),%eax
c010c023:	0f b6 00             	movzbl (%eax),%eax
c010c026:	84 c0                	test   %al,%al
c010c028:	74 10                	je     c010c03a <strncmp+0x31>
c010c02a:	8b 45 08             	mov    0x8(%ebp),%eax
c010c02d:	0f b6 10             	movzbl (%eax),%edx
c010c030:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c033:	0f b6 00             	movzbl (%eax),%eax
c010c036:	38 c2                	cmp    %al,%dl
c010c038:	74 d4                	je     c010c00e <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010c03a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c03e:	74 18                	je     c010c058 <strncmp+0x4f>
c010c040:	8b 45 08             	mov    0x8(%ebp),%eax
c010c043:	0f b6 00             	movzbl (%eax),%eax
c010c046:	0f b6 d0             	movzbl %al,%edx
c010c049:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c04c:	0f b6 00             	movzbl (%eax),%eax
c010c04f:	0f b6 c0             	movzbl %al,%eax
c010c052:	29 c2                	sub    %eax,%edx
c010c054:	89 d0                	mov    %edx,%eax
c010c056:	eb 05                	jmp    c010c05d <strncmp+0x54>
c010c058:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010c05d:	5d                   	pop    %ebp
c010c05e:	c3                   	ret    

c010c05f <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010c05f:	55                   	push   %ebp
c010c060:	89 e5                	mov    %esp,%ebp
c010c062:	83 ec 04             	sub    $0x4,%esp
c010c065:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c068:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010c06b:	eb 14                	jmp    c010c081 <strchr+0x22>
        if (*s == c) {
c010c06d:	8b 45 08             	mov    0x8(%ebp),%eax
c010c070:	0f b6 00             	movzbl (%eax),%eax
c010c073:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010c076:	75 05                	jne    c010c07d <strchr+0x1e>
            return (char *)s;
c010c078:	8b 45 08             	mov    0x8(%ebp),%eax
c010c07b:	eb 13                	jmp    c010c090 <strchr+0x31>
        }
        s ++;
c010c07d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c010c081:	8b 45 08             	mov    0x8(%ebp),%eax
c010c084:	0f b6 00             	movzbl (%eax),%eax
c010c087:	84 c0                	test   %al,%al
c010c089:	75 e2                	jne    c010c06d <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c010c08b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010c090:	c9                   	leave  
c010c091:	c3                   	ret    

c010c092 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010c092:	55                   	push   %ebp
c010c093:	89 e5                	mov    %esp,%ebp
c010c095:	83 ec 04             	sub    $0x4,%esp
c010c098:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c09b:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010c09e:	eb 11                	jmp    c010c0b1 <strfind+0x1f>
        if (*s == c) {
c010c0a0:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0a3:	0f b6 00             	movzbl (%eax),%eax
c010c0a6:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010c0a9:	75 02                	jne    c010c0ad <strfind+0x1b>
            break;
c010c0ab:	eb 0e                	jmp    c010c0bb <strfind+0x29>
        }
        s ++;
c010c0ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c010c0b1:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0b4:	0f b6 00             	movzbl (%eax),%eax
c010c0b7:	84 c0                	test   %al,%al
c010c0b9:	75 e5                	jne    c010c0a0 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c010c0bb:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010c0be:	c9                   	leave  
c010c0bf:	c3                   	ret    

c010c0c0 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010c0c0:	55                   	push   %ebp
c010c0c1:	89 e5                	mov    %esp,%ebp
c010c0c3:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010c0c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010c0cd:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010c0d4:	eb 04                	jmp    c010c0da <strtol+0x1a>
        s ++;
c010c0d6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010c0da:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0dd:	0f b6 00             	movzbl (%eax),%eax
c010c0e0:	3c 20                	cmp    $0x20,%al
c010c0e2:	74 f2                	je     c010c0d6 <strtol+0x16>
c010c0e4:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0e7:	0f b6 00             	movzbl (%eax),%eax
c010c0ea:	3c 09                	cmp    $0x9,%al
c010c0ec:	74 e8                	je     c010c0d6 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c010c0ee:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0f1:	0f b6 00             	movzbl (%eax),%eax
c010c0f4:	3c 2b                	cmp    $0x2b,%al
c010c0f6:	75 06                	jne    c010c0fe <strtol+0x3e>
        s ++;
c010c0f8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010c0fc:	eb 15                	jmp    c010c113 <strtol+0x53>
    }
    else if (*s == '-') {
c010c0fe:	8b 45 08             	mov    0x8(%ebp),%eax
c010c101:	0f b6 00             	movzbl (%eax),%eax
c010c104:	3c 2d                	cmp    $0x2d,%al
c010c106:	75 0b                	jne    c010c113 <strtol+0x53>
        s ++, neg = 1;
c010c108:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010c10c:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010c113:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c117:	74 06                	je     c010c11f <strtol+0x5f>
c010c119:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010c11d:	75 24                	jne    c010c143 <strtol+0x83>
c010c11f:	8b 45 08             	mov    0x8(%ebp),%eax
c010c122:	0f b6 00             	movzbl (%eax),%eax
c010c125:	3c 30                	cmp    $0x30,%al
c010c127:	75 1a                	jne    c010c143 <strtol+0x83>
c010c129:	8b 45 08             	mov    0x8(%ebp),%eax
c010c12c:	83 c0 01             	add    $0x1,%eax
c010c12f:	0f b6 00             	movzbl (%eax),%eax
c010c132:	3c 78                	cmp    $0x78,%al
c010c134:	75 0d                	jne    c010c143 <strtol+0x83>
        s += 2, base = 16;
c010c136:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010c13a:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010c141:	eb 2a                	jmp    c010c16d <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c010c143:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c147:	75 17                	jne    c010c160 <strtol+0xa0>
c010c149:	8b 45 08             	mov    0x8(%ebp),%eax
c010c14c:	0f b6 00             	movzbl (%eax),%eax
c010c14f:	3c 30                	cmp    $0x30,%al
c010c151:	75 0d                	jne    c010c160 <strtol+0xa0>
        s ++, base = 8;
c010c153:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010c157:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010c15e:	eb 0d                	jmp    c010c16d <strtol+0xad>
    }
    else if (base == 0) {
c010c160:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c164:	75 07                	jne    c010c16d <strtol+0xad>
        base = 10;
c010c166:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010c16d:	8b 45 08             	mov    0x8(%ebp),%eax
c010c170:	0f b6 00             	movzbl (%eax),%eax
c010c173:	3c 2f                	cmp    $0x2f,%al
c010c175:	7e 1b                	jle    c010c192 <strtol+0xd2>
c010c177:	8b 45 08             	mov    0x8(%ebp),%eax
c010c17a:	0f b6 00             	movzbl (%eax),%eax
c010c17d:	3c 39                	cmp    $0x39,%al
c010c17f:	7f 11                	jg     c010c192 <strtol+0xd2>
            dig = *s - '0';
c010c181:	8b 45 08             	mov    0x8(%ebp),%eax
c010c184:	0f b6 00             	movzbl (%eax),%eax
c010c187:	0f be c0             	movsbl %al,%eax
c010c18a:	83 e8 30             	sub    $0x30,%eax
c010c18d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c190:	eb 48                	jmp    c010c1da <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010c192:	8b 45 08             	mov    0x8(%ebp),%eax
c010c195:	0f b6 00             	movzbl (%eax),%eax
c010c198:	3c 60                	cmp    $0x60,%al
c010c19a:	7e 1b                	jle    c010c1b7 <strtol+0xf7>
c010c19c:	8b 45 08             	mov    0x8(%ebp),%eax
c010c19f:	0f b6 00             	movzbl (%eax),%eax
c010c1a2:	3c 7a                	cmp    $0x7a,%al
c010c1a4:	7f 11                	jg     c010c1b7 <strtol+0xf7>
            dig = *s - 'a' + 10;
c010c1a6:	8b 45 08             	mov    0x8(%ebp),%eax
c010c1a9:	0f b6 00             	movzbl (%eax),%eax
c010c1ac:	0f be c0             	movsbl %al,%eax
c010c1af:	83 e8 57             	sub    $0x57,%eax
c010c1b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c1b5:	eb 23                	jmp    c010c1da <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010c1b7:	8b 45 08             	mov    0x8(%ebp),%eax
c010c1ba:	0f b6 00             	movzbl (%eax),%eax
c010c1bd:	3c 40                	cmp    $0x40,%al
c010c1bf:	7e 3d                	jle    c010c1fe <strtol+0x13e>
c010c1c1:	8b 45 08             	mov    0x8(%ebp),%eax
c010c1c4:	0f b6 00             	movzbl (%eax),%eax
c010c1c7:	3c 5a                	cmp    $0x5a,%al
c010c1c9:	7f 33                	jg     c010c1fe <strtol+0x13e>
            dig = *s - 'A' + 10;
c010c1cb:	8b 45 08             	mov    0x8(%ebp),%eax
c010c1ce:	0f b6 00             	movzbl (%eax),%eax
c010c1d1:	0f be c0             	movsbl %al,%eax
c010c1d4:	83 e8 37             	sub    $0x37,%eax
c010c1d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010c1da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010c1dd:	3b 45 10             	cmp    0x10(%ebp),%eax
c010c1e0:	7c 02                	jl     c010c1e4 <strtol+0x124>
            break;
c010c1e2:	eb 1a                	jmp    c010c1fe <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c010c1e4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010c1e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c1eb:	0f af 45 10          	imul   0x10(%ebp),%eax
c010c1ef:	89 c2                	mov    %eax,%edx
c010c1f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010c1f4:	01 d0                	add    %edx,%eax
c010c1f6:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010c1f9:	e9 6f ff ff ff       	jmp    c010c16d <strtol+0xad>

    if (endptr) {
c010c1fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010c202:	74 08                	je     c010c20c <strtol+0x14c>
        *endptr = (char *) s;
c010c204:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c207:	8b 55 08             	mov    0x8(%ebp),%edx
c010c20a:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010c20c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010c210:	74 07                	je     c010c219 <strtol+0x159>
c010c212:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c215:	f7 d8                	neg    %eax
c010c217:	eb 03                	jmp    c010c21c <strtol+0x15c>
c010c219:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010c21c:	c9                   	leave  
c010c21d:	c3                   	ret    

c010c21e <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010c21e:	55                   	push   %ebp
c010c21f:	89 e5                	mov    %esp,%ebp
c010c221:	57                   	push   %edi
c010c222:	83 ec 24             	sub    $0x24,%esp
c010c225:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c228:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010c22b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010c22f:	8b 55 08             	mov    0x8(%ebp),%edx
c010c232:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010c235:	88 45 f7             	mov    %al,-0x9(%ebp)
c010c238:	8b 45 10             	mov    0x10(%ebp),%eax
c010c23b:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010c23e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010c241:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010c245:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010c248:	89 d7                	mov    %edx,%edi
c010c24a:	f3 aa                	rep stos %al,%es:(%edi)
c010c24c:	89 fa                	mov    %edi,%edx
c010c24e:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010c251:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010c254:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010c257:	83 c4 24             	add    $0x24,%esp
c010c25a:	5f                   	pop    %edi
c010c25b:	5d                   	pop    %ebp
c010c25c:	c3                   	ret    

c010c25d <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010c25d:	55                   	push   %ebp
c010c25e:	89 e5                	mov    %esp,%ebp
c010c260:	57                   	push   %edi
c010c261:	56                   	push   %esi
c010c262:	53                   	push   %ebx
c010c263:	83 ec 30             	sub    $0x30,%esp
c010c266:	8b 45 08             	mov    0x8(%ebp),%eax
c010c269:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c26c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c26f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c272:	8b 45 10             	mov    0x10(%ebp),%eax
c010c275:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010c278:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c27b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010c27e:	73 42                	jae    c010c2c2 <memmove+0x65>
c010c280:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c283:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010c286:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c289:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010c28c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c28f:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010c292:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010c295:	c1 e8 02             	shr    $0x2,%eax
c010c298:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010c29a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010c29d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c2a0:	89 d7                	mov    %edx,%edi
c010c2a2:	89 c6                	mov    %eax,%esi
c010c2a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010c2a6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010c2a9:	83 e1 03             	and    $0x3,%ecx
c010c2ac:	74 02                	je     c010c2b0 <memmove+0x53>
c010c2ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010c2b0:	89 f0                	mov    %esi,%eax
c010c2b2:	89 fa                	mov    %edi,%edx
c010c2b4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010c2b7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010c2ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010c2bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010c2c0:	eb 36                	jmp    c010c2f8 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010c2c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c2c5:	8d 50 ff             	lea    -0x1(%eax),%edx
c010c2c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c2cb:	01 c2                	add    %eax,%edx
c010c2cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c2d0:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010c2d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c2d6:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010c2d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c2dc:	89 c1                	mov    %eax,%ecx
c010c2de:	89 d8                	mov    %ebx,%eax
c010c2e0:	89 d6                	mov    %edx,%esi
c010c2e2:	89 c7                	mov    %eax,%edi
c010c2e4:	fd                   	std    
c010c2e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010c2e7:	fc                   	cld    
c010c2e8:	89 f8                	mov    %edi,%eax
c010c2ea:	89 f2                	mov    %esi,%edx
c010c2ec:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010c2ef:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010c2f2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c010c2f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010c2f8:	83 c4 30             	add    $0x30,%esp
c010c2fb:	5b                   	pop    %ebx
c010c2fc:	5e                   	pop    %esi
c010c2fd:	5f                   	pop    %edi
c010c2fe:	5d                   	pop    %ebp
c010c2ff:	c3                   	ret    

c010c300 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010c300:	55                   	push   %ebp
c010c301:	89 e5                	mov    %esp,%ebp
c010c303:	57                   	push   %edi
c010c304:	56                   	push   %esi
c010c305:	83 ec 20             	sub    $0x20,%esp
c010c308:	8b 45 08             	mov    0x8(%ebp),%eax
c010c30b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c30e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c311:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c314:	8b 45 10             	mov    0x10(%ebp),%eax
c010c317:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010c31a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c31d:	c1 e8 02             	shr    $0x2,%eax
c010c320:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010c322:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c325:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c328:	89 d7                	mov    %edx,%edi
c010c32a:	89 c6                	mov    %eax,%esi
c010c32c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010c32e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010c331:	83 e1 03             	and    $0x3,%ecx
c010c334:	74 02                	je     c010c338 <memcpy+0x38>
c010c336:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010c338:	89 f0                	mov    %esi,%eax
c010c33a:	89 fa                	mov    %edi,%edx
c010c33c:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010c33f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010c342:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010c345:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010c348:	83 c4 20             	add    $0x20,%esp
c010c34b:	5e                   	pop    %esi
c010c34c:	5f                   	pop    %edi
c010c34d:	5d                   	pop    %ebp
c010c34e:	c3                   	ret    

c010c34f <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010c34f:	55                   	push   %ebp
c010c350:	89 e5                	mov    %esp,%ebp
c010c352:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010c355:	8b 45 08             	mov    0x8(%ebp),%eax
c010c358:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010c35b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c35e:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010c361:	eb 30                	jmp    c010c393 <memcmp+0x44>
        if (*s1 != *s2) {
c010c363:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c366:	0f b6 10             	movzbl (%eax),%edx
c010c369:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c36c:	0f b6 00             	movzbl (%eax),%eax
c010c36f:	38 c2                	cmp    %al,%dl
c010c371:	74 18                	je     c010c38b <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010c373:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c376:	0f b6 00             	movzbl (%eax),%eax
c010c379:	0f b6 d0             	movzbl %al,%edx
c010c37c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c37f:	0f b6 00             	movzbl (%eax),%eax
c010c382:	0f b6 c0             	movzbl %al,%eax
c010c385:	29 c2                	sub    %eax,%edx
c010c387:	89 d0                	mov    %edx,%eax
c010c389:	eb 1a                	jmp    c010c3a5 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010c38b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010c38f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c010c393:	8b 45 10             	mov    0x10(%ebp),%eax
c010c396:	8d 50 ff             	lea    -0x1(%eax),%edx
c010c399:	89 55 10             	mov    %edx,0x10(%ebp)
c010c39c:	85 c0                	test   %eax,%eax
c010c39e:	75 c3                	jne    c010c363 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c010c3a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010c3a5:	c9                   	leave  
c010c3a6:	c3                   	ret    
