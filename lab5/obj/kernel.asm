
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:
.text
.globl kern_entry
kern_entry:
    # reload temperate gdt (second time) to remap all physical memory
    # virtual_addr 0~4G=linear_addr&physical_addr -KERNBASE~4G-KERNBASE 
    lgdt REALLOC(__gdtdesc)
c0100000:	0f 01 15 18 a0 12 00 	lgdtl  0x12a018
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
c010001e:	bc 00 a0 12 c0       	mov    $0xc012a000,%esp
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
c0100030:	ba b8 f0 19 c0       	mov    $0xc019f0b8,%edx
c0100035:	b8 2a bf 19 c0       	mov    $0xc019bf2a,%eax
c010003a:	29 c2                	sub    %eax,%edx
c010003c:	89 d0                	mov    %edx,%eax
c010003e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100042:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100049:	00 
c010004a:	c7 04 24 2a bf 19 c0 	movl   $0xc019bf2a,(%esp)
c0100051:	e8 ac bc 00 00       	call   c010bd02 <memset>

    cons_init();                // init the console
c0100056:	e8 80 16 00 00       	call   c01016db <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c010005b:	c7 45 f4 a0 be 10 c0 	movl   $0xc010bea0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100062:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100065:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100069:	c7 04 24 bc be 10 c0 	movl   $0xc010bebc,(%esp)
c0100070:	e8 de 02 00 00       	call   c0100353 <cprintf>

    print_kerninfo();
c0100075:	e8 05 09 00 00       	call   c010097f <print_kerninfo>

    grade_backtrace();
c010007a:	e8 9d 00 00 00       	call   c010011c <grade_backtrace>

    pmm_init();                 // init physical memory management
c010007f:	e8 16 56 00 00       	call   c010569a <pmm_init>

    pic_init();                 // init interrupt controller
c0100084:	e8 30 20 00 00       	call   c01020b9 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100089:	e8 a8 21 00 00       	call   c0102236 <idt_init>

    vmm_init();                 // init virtual memory management
c010008e:	e8 06 86 00 00       	call   c0108699 <vmm_init>
    proc_init();                // init process table
c0100093:	e8 2d ac 00 00       	call   c010acc5 <proc_init>
    
    ide_init();                 // init ide devices
c0100098:	e8 6f 17 00 00       	call   c010180c <ide_init>
    swap_init();                // init swap
c010009d:	e8 d3 6c 00 00       	call   c0106d75 <swap_init>

    clock_init();               // init clock interrupt
c01000a2:	e8 ea 0d 00 00       	call   c0100e91 <clock_init>
    intr_enable();              // enable irq interrupt
c01000a7:	e8 7b 1f 00 00       	call   c0102027 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000ac:	e8 d3 ad 00 00       	call   c010ae84 <cpu_idle>

c01000b1 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b1:	55                   	push   %ebp
c01000b2:	89 e5                	mov    %esp,%ebp
c01000b4:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000be:	00 
c01000bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000c6:	00 
c01000c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000ce:	e8 f0 0c 00 00       	call   c0100dc3 <mon_backtrace>
}
c01000d3:	c9                   	leave  
c01000d4:	c3                   	ret    

c01000d5 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d5:	55                   	push   %ebp
c01000d6:	89 e5                	mov    %esp,%ebp
c01000d8:	53                   	push   %ebx
c01000d9:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000dc:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000e2:	8d 55 08             	lea    0x8(%ebp),%edx
c01000e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01000e8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000ec:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000f0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000f4:	89 04 24             	mov    %eax,(%esp)
c01000f7:	e8 b5 ff ff ff       	call   c01000b1 <grade_backtrace2>
}
c01000fc:	83 c4 14             	add    $0x14,%esp
c01000ff:	5b                   	pop    %ebx
c0100100:	5d                   	pop    %ebp
c0100101:	c3                   	ret    

c0100102 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100102:	55                   	push   %ebp
c0100103:	89 e5                	mov    %esp,%ebp
c0100105:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100108:	8b 45 10             	mov    0x10(%ebp),%eax
c010010b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010010f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100112:	89 04 24             	mov    %eax,(%esp)
c0100115:	e8 bb ff ff ff       	call   c01000d5 <grade_backtrace1>
}
c010011a:	c9                   	leave  
c010011b:	c3                   	ret    

c010011c <grade_backtrace>:

void
grade_backtrace(void) {
c010011c:	55                   	push   %ebp
c010011d:	89 e5                	mov    %esp,%ebp
c010011f:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100122:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c0100127:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010012e:	ff 
c010012f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100133:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010013a:	e8 c3 ff ff ff       	call   c0100102 <grade_backtrace0>
}
c010013f:	c9                   	leave  
c0100140:	c3                   	ret    

c0100141 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100141:	55                   	push   %ebp
c0100142:	89 e5                	mov    %esp,%ebp
c0100144:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100147:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010014a:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010014d:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100150:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100153:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100157:	0f b7 c0             	movzwl %ax,%eax
c010015a:	83 e0 03             	and    $0x3,%eax
c010015d:	89 c2                	mov    %eax,%edx
c010015f:	a1 40 bf 19 c0       	mov    0xc019bf40,%eax
c0100164:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100168:	89 44 24 04          	mov    %eax,0x4(%esp)
c010016c:	c7 04 24 c1 be 10 c0 	movl   $0xc010bec1,(%esp)
c0100173:	e8 db 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100178:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010017c:	0f b7 d0             	movzwl %ax,%edx
c010017f:	a1 40 bf 19 c0       	mov    0xc019bf40,%eax
c0100184:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100188:	89 44 24 04          	mov    %eax,0x4(%esp)
c010018c:	c7 04 24 cf be 10 c0 	movl   $0xc010becf,(%esp)
c0100193:	e8 bb 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100198:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c010019c:	0f b7 d0             	movzwl %ax,%edx
c010019f:	a1 40 bf 19 c0       	mov    0xc019bf40,%eax
c01001a4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ac:	c7 04 24 dd be 10 c0 	movl   $0xc010bedd,(%esp)
c01001b3:	e8 9b 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001bc:	0f b7 d0             	movzwl %ax,%edx
c01001bf:	a1 40 bf 19 c0       	mov    0xc019bf40,%eax
c01001c4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001cc:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c01001d3:	e8 7b 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d8:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001dc:	0f b7 d0             	movzwl %ax,%edx
c01001df:	a1 40 bf 19 c0       	mov    0xc019bf40,%eax
c01001e4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ec:	c7 04 24 f9 be 10 c0 	movl   $0xc010bef9,(%esp)
c01001f3:	e8 5b 01 00 00       	call   c0100353 <cprintf>
    round ++;
c01001f8:	a1 40 bf 19 c0       	mov    0xc019bf40,%eax
c01001fd:	83 c0 01             	add    $0x1,%eax
c0100200:	a3 40 bf 19 c0       	mov    %eax,0xc019bf40
}
c0100205:	c9                   	leave  
c0100206:	c3                   	ret    

c0100207 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100207:	55                   	push   %ebp
c0100208:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010020a:	5d                   	pop    %ebp
c010020b:	c3                   	ret    

c010020c <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010020c:	55                   	push   %ebp
c010020d:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c010020f:	5d                   	pop    %ebp
c0100210:	c3                   	ret    

c0100211 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100211:	55                   	push   %ebp
c0100212:	89 e5                	mov    %esp,%ebp
c0100214:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100217:	e8 25 ff ff ff       	call   c0100141 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010021c:	c7 04 24 08 bf 10 c0 	movl   $0xc010bf08,(%esp)
c0100223:	e8 2b 01 00 00       	call   c0100353 <cprintf>
    lab1_switch_to_user();
c0100228:	e8 da ff ff ff       	call   c0100207 <lab1_switch_to_user>
    lab1_print_cur_status();
c010022d:	e8 0f ff ff ff       	call   c0100141 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100232:	c7 04 24 28 bf 10 c0 	movl   $0xc010bf28,(%esp)
c0100239:	e8 15 01 00 00       	call   c0100353 <cprintf>
    lab1_switch_to_kernel();
c010023e:	e8 c9 ff ff ff       	call   c010020c <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100243:	e8 f9 fe ff ff       	call   c0100141 <lab1_print_cur_status>
}
c0100248:	c9                   	leave  
c0100249:	c3                   	ret    

c010024a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010024a:	55                   	push   %ebp
c010024b:	89 e5                	mov    %esp,%ebp
c010024d:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100250:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100254:	74 13                	je     c0100269 <readline+0x1f>
        cprintf("%s", prompt);
c0100256:	8b 45 08             	mov    0x8(%ebp),%eax
c0100259:	89 44 24 04          	mov    %eax,0x4(%esp)
c010025d:	c7 04 24 47 bf 10 c0 	movl   $0xc010bf47,(%esp)
c0100264:	e8 ea 00 00 00       	call   c0100353 <cprintf>
    }
    int i = 0, c;
c0100269:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100270:	e8 66 01 00 00       	call   c01003db <getchar>
c0100275:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100278:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010027c:	79 07                	jns    c0100285 <readline+0x3b>
            return NULL;
c010027e:	b8 00 00 00 00       	mov    $0x0,%eax
c0100283:	eb 79                	jmp    c01002fe <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100285:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100289:	7e 28                	jle    c01002b3 <readline+0x69>
c010028b:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100292:	7f 1f                	jg     c01002b3 <readline+0x69>
            cputchar(c);
c0100294:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100297:	89 04 24             	mov    %eax,(%esp)
c010029a:	e8 da 00 00 00       	call   c0100379 <cputchar>
            buf[i ++] = c;
c010029f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002a2:	8d 50 01             	lea    0x1(%eax),%edx
c01002a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002ab:	88 90 60 bf 19 c0    	mov    %dl,-0x3fe640a0(%eax)
c01002b1:	eb 46                	jmp    c01002f9 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002b3:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002b7:	75 17                	jne    c01002d0 <readline+0x86>
c01002b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002bd:	7e 11                	jle    c01002d0 <readline+0x86>
            cputchar(c);
c01002bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002c2:	89 04 24             	mov    %eax,(%esp)
c01002c5:	e8 af 00 00 00       	call   c0100379 <cputchar>
            i --;
c01002ca:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002ce:	eb 29                	jmp    c01002f9 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002d0:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d4:	74 06                	je     c01002dc <readline+0x92>
c01002d6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002da:	75 1d                	jne    c01002f9 <readline+0xaf>
            cputchar(c);
c01002dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002df:	89 04 24             	mov    %eax,(%esp)
c01002e2:	e8 92 00 00 00       	call   c0100379 <cputchar>
            buf[i] = '\0';
c01002e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002ea:	05 60 bf 19 c0       	add    $0xc019bf60,%eax
c01002ef:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002f2:	b8 60 bf 19 c0       	mov    $0xc019bf60,%eax
c01002f7:	eb 05                	jmp    c01002fe <readline+0xb4>
        }
    }
c01002f9:	e9 72 ff ff ff       	jmp    c0100270 <readline+0x26>
}
c01002fe:	c9                   	leave  
c01002ff:	c3                   	ret    

c0100300 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100300:	55                   	push   %ebp
c0100301:	89 e5                	mov    %esp,%ebp
c0100303:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100306:	8b 45 08             	mov    0x8(%ebp),%eax
c0100309:	89 04 24             	mov    %eax,(%esp)
c010030c:	e8 f6 13 00 00       	call   c0101707 <cons_putc>
    (*cnt) ++;
c0100311:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100314:	8b 00                	mov    (%eax),%eax
c0100316:	8d 50 01             	lea    0x1(%eax),%edx
c0100319:	8b 45 0c             	mov    0xc(%ebp),%eax
c010031c:	89 10                	mov    %edx,(%eax)
}
c010031e:	c9                   	leave  
c010031f:	c3                   	ret    

c0100320 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100320:	55                   	push   %ebp
c0100321:	89 e5                	mov    %esp,%ebp
c0100323:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100326:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010032d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100330:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100334:	8b 45 08             	mov    0x8(%ebp),%eax
c0100337:	89 44 24 08          	mov    %eax,0x8(%esp)
c010033b:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010033e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100342:	c7 04 24 00 03 10 c0 	movl   $0xc0100300,(%esp)
c0100349:	e8 f5 b0 00 00       	call   c010b443 <vprintfmt>
    return cnt;
c010034e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100351:	c9                   	leave  
c0100352:	c3                   	ret    

c0100353 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100353:	55                   	push   %ebp
c0100354:	89 e5                	mov    %esp,%ebp
c0100356:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100359:	8d 45 0c             	lea    0xc(%ebp),%eax
c010035c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010035f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100362:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100366:	8b 45 08             	mov    0x8(%ebp),%eax
c0100369:	89 04 24             	mov    %eax,(%esp)
c010036c:	e8 af ff ff ff       	call   c0100320 <vcprintf>
c0100371:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100374:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100377:	c9                   	leave  
c0100378:	c3                   	ret    

c0100379 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c0100379:	55                   	push   %ebp
c010037a:	89 e5                	mov    %esp,%ebp
c010037c:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010037f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100382:	89 04 24             	mov    %eax,(%esp)
c0100385:	e8 7d 13 00 00       	call   c0101707 <cons_putc>
}
c010038a:	c9                   	leave  
c010038b:	c3                   	ret    

c010038c <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c010038c:	55                   	push   %ebp
c010038d:	89 e5                	mov    %esp,%ebp
c010038f:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100392:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c0100399:	eb 13                	jmp    c01003ae <cputs+0x22>
        cputch(c, &cnt);
c010039b:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c010039f:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003a2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003a6:	89 04 24             	mov    %eax,(%esp)
c01003a9:	e8 52 ff ff ff       	call   c0100300 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b1:	8d 50 01             	lea    0x1(%eax),%edx
c01003b4:	89 55 08             	mov    %edx,0x8(%ebp)
c01003b7:	0f b6 00             	movzbl (%eax),%eax
c01003ba:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003bd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c1:	75 d8                	jne    c010039b <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003ca:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d1:	e8 2a ff ff ff       	call   c0100300 <cputch>
    return cnt;
c01003d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003d9:	c9                   	leave  
c01003da:	c3                   	ret    

c01003db <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003db:	55                   	push   %ebp
c01003dc:	89 e5                	mov    %esp,%ebp
c01003de:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003e1:	e8 5d 13 00 00       	call   c0101743 <cons_getc>
c01003e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003ed:	74 f2                	je     c01003e1 <getchar+0x6>
        /* do nothing */;
    return c;
c01003ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003f2:	c9                   	leave  
c01003f3:	c3                   	ret    

c01003f4 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003f4:	55                   	push   %ebp
c01003f5:	89 e5                	mov    %esp,%ebp
c01003f7:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003fd:	8b 00                	mov    (%eax),%eax
c01003ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100402:	8b 45 10             	mov    0x10(%ebp),%eax
c0100405:	8b 00                	mov    (%eax),%eax
c0100407:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010040a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100411:	e9 d2 00 00 00       	jmp    c01004e8 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c0100416:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100419:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010041c:	01 d0                	add    %edx,%eax
c010041e:	89 c2                	mov    %eax,%edx
c0100420:	c1 ea 1f             	shr    $0x1f,%edx
c0100423:	01 d0                	add    %edx,%eax
c0100425:	d1 f8                	sar    %eax
c0100427:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010042a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010042d:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100430:	eb 04                	jmp    c0100436 <stab_binsearch+0x42>
            m --;
c0100432:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100436:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100439:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010043c:	7c 1f                	jl     c010045d <stab_binsearch+0x69>
c010043e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100441:	89 d0                	mov    %edx,%eax
c0100443:	01 c0                	add    %eax,%eax
c0100445:	01 d0                	add    %edx,%eax
c0100447:	c1 e0 02             	shl    $0x2,%eax
c010044a:	89 c2                	mov    %eax,%edx
c010044c:	8b 45 08             	mov    0x8(%ebp),%eax
c010044f:	01 d0                	add    %edx,%eax
c0100451:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100455:	0f b6 c0             	movzbl %al,%eax
c0100458:	3b 45 14             	cmp    0x14(%ebp),%eax
c010045b:	75 d5                	jne    c0100432 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c010045d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100460:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100463:	7d 0b                	jge    c0100470 <stab_binsearch+0x7c>
            l = true_m + 1;
c0100465:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100468:	83 c0 01             	add    $0x1,%eax
c010046b:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010046e:	eb 78                	jmp    c01004e8 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100470:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100477:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010047a:	89 d0                	mov    %edx,%eax
c010047c:	01 c0                	add    %eax,%eax
c010047e:	01 d0                	add    %edx,%eax
c0100480:	c1 e0 02             	shl    $0x2,%eax
c0100483:	89 c2                	mov    %eax,%edx
c0100485:	8b 45 08             	mov    0x8(%ebp),%eax
c0100488:	01 d0                	add    %edx,%eax
c010048a:	8b 40 08             	mov    0x8(%eax),%eax
c010048d:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100490:	73 13                	jae    c01004a5 <stab_binsearch+0xb1>
            *region_left = m;
c0100492:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100495:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100498:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010049a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010049d:	83 c0 01             	add    $0x1,%eax
c01004a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004a3:	eb 43                	jmp    c01004e8 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c01004a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a8:	89 d0                	mov    %edx,%eax
c01004aa:	01 c0                	add    %eax,%eax
c01004ac:	01 d0                	add    %edx,%eax
c01004ae:	c1 e0 02             	shl    $0x2,%eax
c01004b1:	89 c2                	mov    %eax,%edx
c01004b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01004b6:	01 d0                	add    %edx,%eax
c01004b8:	8b 40 08             	mov    0x8(%eax),%eax
c01004bb:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004be:	76 16                	jbe    c01004d6 <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c3:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01004c9:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ce:	83 e8 01             	sub    $0x1,%eax
c01004d1:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004d4:	eb 12                	jmp    c01004e8 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004dc:	89 10                	mov    %edx,(%eax)
            l = m;
c01004de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004e4:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004eb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004ee:	0f 8e 22 ff ff ff    	jle    c0100416 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004f8:	75 0f                	jne    c0100509 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004fd:	8b 00                	mov    (%eax),%eax
c01004ff:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100502:	8b 45 10             	mov    0x10(%ebp),%eax
c0100505:	89 10                	mov    %edx,(%eax)
c0100507:	eb 3f                	jmp    c0100548 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c0100509:	8b 45 10             	mov    0x10(%ebp),%eax
c010050c:	8b 00                	mov    (%eax),%eax
c010050e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100511:	eb 04                	jmp    c0100517 <stab_binsearch+0x123>
c0100513:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c0100517:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051a:	8b 00                	mov    (%eax),%eax
c010051c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010051f:	7d 1f                	jge    c0100540 <stab_binsearch+0x14c>
c0100521:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100524:	89 d0                	mov    %edx,%eax
c0100526:	01 c0                	add    %eax,%eax
c0100528:	01 d0                	add    %edx,%eax
c010052a:	c1 e0 02             	shl    $0x2,%eax
c010052d:	89 c2                	mov    %eax,%edx
c010052f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100532:	01 d0                	add    %edx,%eax
c0100534:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100538:	0f b6 c0             	movzbl %al,%eax
c010053b:	3b 45 14             	cmp    0x14(%ebp),%eax
c010053e:	75 d3                	jne    c0100513 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100540:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100543:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100546:	89 10                	mov    %edx,(%eax)
    }
}
c0100548:	c9                   	leave  
c0100549:	c3                   	ret    

c010054a <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010054a:	55                   	push   %ebp
c010054b:	89 e5                	mov    %esp,%ebp
c010054d:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100550:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100553:	c7 00 4c bf 10 c0    	movl   $0xc010bf4c,(%eax)
    info->eip_line = 0;
c0100559:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100563:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100566:	c7 40 08 4c bf 10 c0 	movl   $0xc010bf4c,0x8(%eax)
    info->eip_fn_namelen = 9;
c010056d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100570:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100577:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057a:	8b 55 08             	mov    0x8(%ebp),%edx
c010057d:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100580:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100583:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    // find the relevant set of stabs
    if (addr >= KERNBASE) {
c010058a:	81 7d 08 ff ff ff bf 	cmpl   $0xbfffffff,0x8(%ebp)
c0100591:	76 21                	jbe    c01005b4 <debuginfo_eip+0x6a>
        stabs = __STAB_BEGIN__;
c0100593:	c7 45 f4 80 e6 10 c0 	movl   $0xc010e680,-0xc(%ebp)
        stab_end = __STAB_END__;
c010059a:	c7 45 f0 10 2b 12 c0 	movl   $0xc0122b10,-0x10(%ebp)
        stabstr = __STABSTR_BEGIN__;
c01005a1:	c7 45 ec 11 2b 12 c0 	movl   $0xc0122b11,-0x14(%ebp)
        stabstr_end = __STABSTR_END__;
c01005a8:	c7 45 e8 2a 78 12 c0 	movl   $0xc012782a,-0x18(%ebp)
c01005af:	e9 ea 00 00 00       	jmp    c010069e <debuginfo_eip+0x154>
    }
    else {
        // user-program linker script, tools/user.ld puts the information about the
        // program's stabs (included __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__,
        // and __STABSTR_END__) in a structure located at virtual address USTAB.
        const struct userstabdata *usd = (struct userstabdata *)USTAB;
c01005b4:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

        // make sure that debugger (current process) can access this memory
        struct mm_struct *mm;
        if (current == NULL || (mm = current->mm) == NULL) {
c01005bb:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c01005c0:	85 c0                	test   %eax,%eax
c01005c2:	74 11                	je     c01005d5 <debuginfo_eip+0x8b>
c01005c4:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c01005c9:	8b 40 18             	mov    0x18(%eax),%eax
c01005cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01005cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01005d3:	75 0a                	jne    c01005df <debuginfo_eip+0x95>
            return -1;
c01005d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005da:	e9 9e 03 00 00       	jmp    c010097d <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)usd, sizeof(struct userstabdata), 0)) {
c01005df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01005e2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01005e9:	00 
c01005ea:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01005f1:	00 
c01005f2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01005f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01005f9:	89 04 24             	mov    %eax,(%esp)
c01005fc:	e8 e2 89 00 00       	call   c0108fe3 <user_mem_check>
c0100601:	85 c0                	test   %eax,%eax
c0100603:	75 0a                	jne    c010060f <debuginfo_eip+0xc5>
            return -1;
c0100605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010060a:	e9 6e 03 00 00       	jmp    c010097d <debuginfo_eip+0x433>
        }

        stabs = usd->stabs;
c010060f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100612:	8b 00                	mov    (%eax),%eax
c0100614:	89 45 f4             	mov    %eax,-0xc(%ebp)
        stab_end = usd->stab_end;
c0100617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010061a:	8b 40 04             	mov    0x4(%eax),%eax
c010061d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        stabstr = usd->stabstr;
c0100620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100623:	8b 40 08             	mov    0x8(%eax),%eax
c0100626:	89 45 ec             	mov    %eax,-0x14(%ebp)
        stabstr_end = usd->stabstr_end;
c0100629:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010062c:	8b 40 0c             	mov    0xc(%eax),%eax
c010062f:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // make sure the STABS and string table memory is valid
        if (!user_mem_check(mm, (uintptr_t)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, 0)) {
c0100632:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100635:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100638:	29 c2                	sub    %eax,%edx
c010063a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010063d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100644:	00 
c0100645:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100649:	89 44 24 04          	mov    %eax,0x4(%esp)
c010064d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100650:	89 04 24             	mov    %eax,(%esp)
c0100653:	e8 8b 89 00 00       	call   c0108fe3 <user_mem_check>
c0100658:	85 c0                	test   %eax,%eax
c010065a:	75 0a                	jne    c0100666 <debuginfo_eip+0x11c>
            return -1;
c010065c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100661:	e9 17 03 00 00       	jmp    c010097d <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)stabstr, stabstr_end - stabstr, 0)) {
c0100666:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100669:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010066c:	29 c2                	sub    %eax,%edx
c010066e:	89 d0                	mov    %edx,%eax
c0100670:	89 c2                	mov    %eax,%edx
c0100672:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100675:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010067c:	00 
c010067d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100681:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100685:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100688:	89 04 24             	mov    %eax,(%esp)
c010068b:	e8 53 89 00 00       	call   c0108fe3 <user_mem_check>
c0100690:	85 c0                	test   %eax,%eax
c0100692:	75 0a                	jne    c010069e <debuginfo_eip+0x154>
            return -1;
c0100694:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100699:	e9 df 02 00 00       	jmp    c010097d <debuginfo_eip+0x433>
        }
    }

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010069e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006a1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01006a4:	76 0d                	jbe    c01006b3 <debuginfo_eip+0x169>
c01006a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006a9:	83 e8 01             	sub    $0x1,%eax
c01006ac:	0f b6 00             	movzbl (%eax),%eax
c01006af:	84 c0                	test   %al,%al
c01006b1:	74 0a                	je     c01006bd <debuginfo_eip+0x173>
        return -1;
c01006b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006b8:	e9 c0 02 00 00       	jmp    c010097d <debuginfo_eip+0x433>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01006bd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01006c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ca:	29 c2                	sub    %eax,%edx
c01006cc:	89 d0                	mov    %edx,%eax
c01006ce:	c1 f8 02             	sar    $0x2,%eax
c01006d1:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006d7:	83 e8 01             	sub    $0x1,%eax
c01006da:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01006e0:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006e4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006eb:	00 
c01006ec:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006ef:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006f3:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006fd:	89 04 24             	mov    %eax,(%esp)
c0100700:	e8 ef fc ff ff       	call   c01003f4 <stab_binsearch>
    if (lfile == 0)
c0100705:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100708:	85 c0                	test   %eax,%eax
c010070a:	75 0a                	jne    c0100716 <debuginfo_eip+0x1cc>
        return -1;
c010070c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100711:	e9 67 02 00 00       	jmp    c010097d <debuginfo_eip+0x433>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100716:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100719:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010071c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010071f:	89 45 d0             	mov    %eax,-0x30(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100722:	8b 45 08             	mov    0x8(%ebp),%eax
c0100725:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100729:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100730:	00 
c0100731:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100734:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100738:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010073b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010073f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100742:	89 04 24             	mov    %eax,(%esp)
c0100745:	e8 aa fc ff ff       	call   c01003f4 <stab_binsearch>

    if (lfun <= rfun) {
c010074a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010074d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100750:	39 c2                	cmp    %eax,%edx
c0100752:	7f 7c                	jg     c01007d0 <debuginfo_eip+0x286>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100754:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100757:	89 c2                	mov    %eax,%edx
c0100759:	89 d0                	mov    %edx,%eax
c010075b:	01 c0                	add    %eax,%eax
c010075d:	01 d0                	add    %edx,%eax
c010075f:	c1 e0 02             	shl    $0x2,%eax
c0100762:	89 c2                	mov    %eax,%edx
c0100764:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100767:	01 d0                	add    %edx,%eax
c0100769:	8b 10                	mov    (%eax),%edx
c010076b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010076e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100771:	29 c1                	sub    %eax,%ecx
c0100773:	89 c8                	mov    %ecx,%eax
c0100775:	39 c2                	cmp    %eax,%edx
c0100777:	73 22                	jae    c010079b <debuginfo_eip+0x251>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100779:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077c:	89 c2                	mov    %eax,%edx
c010077e:	89 d0                	mov    %edx,%eax
c0100780:	01 c0                	add    %eax,%eax
c0100782:	01 d0                	add    %edx,%eax
c0100784:	c1 e0 02             	shl    $0x2,%eax
c0100787:	89 c2                	mov    %eax,%edx
c0100789:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010078c:	01 d0                	add    %edx,%eax
c010078e:	8b 10                	mov    (%eax),%edx
c0100790:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100793:	01 c2                	add    %eax,%edx
c0100795:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100798:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010079b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010079e:	89 c2                	mov    %eax,%edx
c01007a0:	89 d0                	mov    %edx,%eax
c01007a2:	01 c0                	add    %eax,%eax
c01007a4:	01 d0                	add    %edx,%eax
c01007a6:	c1 e0 02             	shl    $0x2,%eax
c01007a9:	89 c2                	mov    %eax,%edx
c01007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ae:	01 d0                	add    %edx,%eax
c01007b0:	8b 50 08             	mov    0x8(%eax),%edx
c01007b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b6:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01007b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007bc:	8b 40 10             	mov    0x10(%eax),%eax
c01007bf:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01007c2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007c5:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfun;
c01007c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01007ce:	eb 15                	jmp    c01007e5 <debuginfo_eip+0x29b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d3:	8b 55 08             	mov    0x8(%ebp),%edx
c01007d6:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007dc:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfile;
c01007df:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007e2:	89 45 c8             	mov    %eax,-0x38(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007e8:	8b 40 08             	mov    0x8(%eax),%eax
c01007eb:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007f2:	00 
c01007f3:	89 04 24             	mov    %eax,(%esp)
c01007f6:	e8 7b b3 00 00       	call   c010bb76 <strfind>
c01007fb:	89 c2                	mov    %eax,%edx
c01007fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100800:	8b 40 08             	mov    0x8(%eax),%eax
c0100803:	29 c2                	sub    %eax,%edx
c0100805:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100808:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010080b:	8b 45 08             	mov    0x8(%ebp),%eax
c010080e:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100812:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100819:	00 
c010081a:	8d 45 c8             	lea    -0x38(%ebp),%eax
c010081d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100821:	8d 45 cc             	lea    -0x34(%ebp),%eax
c0100824:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100828:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010082b:	89 04 24             	mov    %eax,(%esp)
c010082e:	e8 c1 fb ff ff       	call   c01003f4 <stab_binsearch>
    if (lline <= rline) {
c0100833:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100836:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100839:	39 c2                	cmp    %eax,%edx
c010083b:	7f 24                	jg     c0100861 <debuginfo_eip+0x317>
        info->eip_line = stabs[rline].n_desc;
c010083d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100840:	89 c2                	mov    %eax,%edx
c0100842:	89 d0                	mov    %edx,%eax
c0100844:	01 c0                	add    %eax,%eax
c0100846:	01 d0                	add    %edx,%eax
c0100848:	c1 e0 02             	shl    $0x2,%eax
c010084b:	89 c2                	mov    %eax,%edx
c010084d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100850:	01 d0                	add    %edx,%eax
c0100852:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100856:	0f b7 d0             	movzwl %ax,%edx
c0100859:	8b 45 0c             	mov    0xc(%ebp),%eax
c010085c:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010085f:	eb 13                	jmp    c0100874 <debuginfo_eip+0x32a>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100861:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100866:	e9 12 01 00 00       	jmp    c010097d <debuginfo_eip+0x433>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010086b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010086e:	83 e8 01             	sub    $0x1,%eax
c0100871:	89 45 cc             	mov    %eax,-0x34(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100874:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100877:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010087a:	39 c2                	cmp    %eax,%edx
c010087c:	7c 56                	jl     c01008d4 <debuginfo_eip+0x38a>
           && stabs[lline].n_type != N_SOL
c010087e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100881:	89 c2                	mov    %eax,%edx
c0100883:	89 d0                	mov    %edx,%eax
c0100885:	01 c0                	add    %eax,%eax
c0100887:	01 d0                	add    %edx,%eax
c0100889:	c1 e0 02             	shl    $0x2,%eax
c010088c:	89 c2                	mov    %eax,%edx
c010088e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100891:	01 d0                	add    %edx,%eax
c0100893:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100897:	3c 84                	cmp    $0x84,%al
c0100899:	74 39                	je     c01008d4 <debuginfo_eip+0x38a>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010089b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010089e:	89 c2                	mov    %eax,%edx
c01008a0:	89 d0                	mov    %edx,%eax
c01008a2:	01 c0                	add    %eax,%eax
c01008a4:	01 d0                	add    %edx,%eax
c01008a6:	c1 e0 02             	shl    $0x2,%eax
c01008a9:	89 c2                	mov    %eax,%edx
c01008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ae:	01 d0                	add    %edx,%eax
c01008b0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008b4:	3c 64                	cmp    $0x64,%al
c01008b6:	75 b3                	jne    c010086b <debuginfo_eip+0x321>
c01008b8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008bb:	89 c2                	mov    %eax,%edx
c01008bd:	89 d0                	mov    %edx,%eax
c01008bf:	01 c0                	add    %eax,%eax
c01008c1:	01 d0                	add    %edx,%eax
c01008c3:	c1 e0 02             	shl    $0x2,%eax
c01008c6:	89 c2                	mov    %eax,%edx
c01008c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008cb:	01 d0                	add    %edx,%eax
c01008cd:	8b 40 08             	mov    0x8(%eax),%eax
c01008d0:	85 c0                	test   %eax,%eax
c01008d2:	74 97                	je     c010086b <debuginfo_eip+0x321>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008d4:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01008d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008da:	39 c2                	cmp    %eax,%edx
c01008dc:	7c 46                	jl     c0100924 <debuginfo_eip+0x3da>
c01008de:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008e1:	89 c2                	mov    %eax,%edx
c01008e3:	89 d0                	mov    %edx,%eax
c01008e5:	01 c0                	add    %eax,%eax
c01008e7:	01 d0                	add    %edx,%eax
c01008e9:	c1 e0 02             	shl    $0x2,%eax
c01008ec:	89 c2                	mov    %eax,%edx
c01008ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008f1:	01 d0                	add    %edx,%eax
c01008f3:	8b 10                	mov    (%eax),%edx
c01008f5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008fb:	29 c1                	sub    %eax,%ecx
c01008fd:	89 c8                	mov    %ecx,%eax
c01008ff:	39 c2                	cmp    %eax,%edx
c0100901:	73 21                	jae    c0100924 <debuginfo_eip+0x3da>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100903:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100906:	89 c2                	mov    %eax,%edx
c0100908:	89 d0                	mov    %edx,%eax
c010090a:	01 c0                	add    %eax,%eax
c010090c:	01 d0                	add    %edx,%eax
c010090e:	c1 e0 02             	shl    $0x2,%eax
c0100911:	89 c2                	mov    %eax,%edx
c0100913:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100916:	01 d0                	add    %edx,%eax
c0100918:	8b 10                	mov    (%eax),%edx
c010091a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010091d:	01 c2                	add    %eax,%edx
c010091f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100922:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100924:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100927:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010092a:	39 c2                	cmp    %eax,%edx
c010092c:	7d 4a                	jge    c0100978 <debuginfo_eip+0x42e>
        for (lline = lfun + 1;
c010092e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100931:	83 c0 01             	add    $0x1,%eax
c0100934:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0100937:	eb 18                	jmp    c0100951 <debuginfo_eip+0x407>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100939:	8b 45 0c             	mov    0xc(%ebp),%eax
c010093c:	8b 40 14             	mov    0x14(%eax),%eax
c010093f:	8d 50 01             	lea    0x1(%eax),%edx
c0100942:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100945:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100948:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010094b:	83 c0 01             	add    $0x1,%eax
c010094e:	89 45 cc             	mov    %eax,-0x34(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100951:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100954:	8b 45 d0             	mov    -0x30(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100957:	39 c2                	cmp    %eax,%edx
c0100959:	7d 1d                	jge    c0100978 <debuginfo_eip+0x42e>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010095b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010095e:	89 c2                	mov    %eax,%edx
c0100960:	89 d0                	mov    %edx,%eax
c0100962:	01 c0                	add    %eax,%eax
c0100964:	01 d0                	add    %edx,%eax
c0100966:	c1 e0 02             	shl    $0x2,%eax
c0100969:	89 c2                	mov    %eax,%edx
c010096b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010096e:	01 d0                	add    %edx,%eax
c0100970:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100974:	3c a0                	cmp    $0xa0,%al
c0100976:	74 c1                	je     c0100939 <debuginfo_eip+0x3ef>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100978:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010097d:	c9                   	leave  
c010097e:	c3                   	ret    

c010097f <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010097f:	55                   	push   %ebp
c0100980:	89 e5                	mov    %esp,%ebp
c0100982:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100985:	c7 04 24 56 bf 10 c0 	movl   $0xc010bf56,(%esp)
c010098c:	e8 c2 f9 ff ff       	call   c0100353 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100991:	c7 44 24 04 2a 00 10 	movl   $0xc010002a,0x4(%esp)
c0100998:	c0 
c0100999:	c7 04 24 6f bf 10 c0 	movl   $0xc010bf6f,(%esp)
c01009a0:	e8 ae f9 ff ff       	call   c0100353 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01009a5:	c7 44 24 04 8b be 10 	movl   $0xc010be8b,0x4(%esp)
c01009ac:	c0 
c01009ad:	c7 04 24 87 bf 10 c0 	movl   $0xc010bf87,(%esp)
c01009b4:	e8 9a f9 ff ff       	call   c0100353 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01009b9:	c7 44 24 04 2a bf 19 	movl   $0xc019bf2a,0x4(%esp)
c01009c0:	c0 
c01009c1:	c7 04 24 9f bf 10 c0 	movl   $0xc010bf9f,(%esp)
c01009c8:	e8 86 f9 ff ff       	call   c0100353 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009cd:	c7 44 24 04 b8 f0 19 	movl   $0xc019f0b8,0x4(%esp)
c01009d4:	c0 
c01009d5:	c7 04 24 b7 bf 10 c0 	movl   $0xc010bfb7,(%esp)
c01009dc:	e8 72 f9 ff ff       	call   c0100353 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009e1:	b8 b8 f0 19 c0       	mov    $0xc019f0b8,%eax
c01009e6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009ec:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c01009f1:	29 c2                	sub    %eax,%edx
c01009f3:	89 d0                	mov    %edx,%eax
c01009f5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009fb:	85 c0                	test   %eax,%eax
c01009fd:	0f 48 c2             	cmovs  %edx,%eax
c0100a00:	c1 f8 0a             	sar    $0xa,%eax
c0100a03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a07:	c7 04 24 d0 bf 10 c0 	movl   $0xc010bfd0,(%esp)
c0100a0e:	e8 40 f9 ff ff       	call   c0100353 <cprintf>
}
c0100a13:	c9                   	leave  
c0100a14:	c3                   	ret    

c0100a15 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100a15:	55                   	push   %ebp
c0100a16:	89 e5                	mov    %esp,%ebp
c0100a18:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100a1e:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100a21:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a25:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a28:	89 04 24             	mov    %eax,(%esp)
c0100a2b:	e8 1a fb ff ff       	call   c010054a <debuginfo_eip>
c0100a30:	85 c0                	test   %eax,%eax
c0100a32:	74 15                	je     c0100a49 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a34:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a3b:	c7 04 24 fa bf 10 c0 	movl   $0xc010bffa,(%esp)
c0100a42:	e8 0c f9 ff ff       	call   c0100353 <cprintf>
c0100a47:	eb 6d                	jmp    c0100ab6 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a50:	eb 1c                	jmp    c0100a6e <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0100a52:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a58:	01 d0                	add    %edx,%eax
c0100a5a:	0f b6 00             	movzbl (%eax),%eax
c0100a5d:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a63:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a66:	01 ca                	add    %ecx,%edx
c0100a68:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a6a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a71:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a74:	7f dc                	jg     c0100a52 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a76:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a7f:	01 d0                	add    %edx,%eax
c0100a81:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a84:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a87:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a8a:	89 d1                	mov    %edx,%ecx
c0100a8c:	29 c1                	sub    %eax,%ecx
c0100a8e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a91:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a94:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a98:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a9e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100aa2:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100aaa:	c7 04 24 16 c0 10 c0 	movl   $0xc010c016,(%esp)
c0100ab1:	e8 9d f8 ff ff       	call   c0100353 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100ab6:	c9                   	leave  
c0100ab7:	c3                   	ret    

c0100ab8 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100ab8:	55                   	push   %ebp
c0100ab9:	89 e5                	mov    %esp,%ebp
c0100abb:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100abe:	8b 45 04             	mov    0x4(%ebp),%eax
c0100ac1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100ac4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100ac7:	c9                   	leave  
c0100ac8:	c3                   	ret    

c0100ac9 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100ac9:	55                   	push   %ebp
c0100aca:	89 e5                	mov    %esp,%ebp
c0100acc:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100acf:	89 e8                	mov    %ebp,%eax
c0100ad1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100ad4:	8b 45 e0             	mov    -0x20(%ebp),%eax
     *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
     *    (3.5) popup a calling stackframe
     *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
     *                   the calling funciton's ebp = ss:[ebp]
     */
    uint32_t ebp = read_ebp();
c0100ad7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
c0100ada:	e8 d9 ff ff ff       	call   c0100ab8 <read_eip>
c0100adf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i;
    int j;
    uint32_t *args;
    for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++) {
c0100ae2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100ae9:	e9 88 00 00 00       	jmp    c0100b76 <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100af1:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100af8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100afc:	c7 04 24 28 c0 10 c0 	movl   $0xc010c028,(%esp)
c0100b03:	e8 4b f8 ff ff       	call   c0100353 <cprintf>
        args = (uint32_t *)ebp + 2;
c0100b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b0b:	83 c0 08             	add    $0x8,%eax
c0100b0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for(j = 0; j < 4; j++)
c0100b11:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100b18:	eb 25                	jmp    c0100b3f <print_stackframe+0x76>
            cprintf("0x%08x ",args[j]);
c0100b1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b1d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b27:	01 d0                	add    %edx,%eax
c0100b29:	8b 00                	mov    (%eax),%eax
c0100b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b2f:	c7 04 24 44 c0 10 c0 	movl   $0xc010c044,(%esp)
c0100b36:	e8 18 f8 ff ff       	call   c0100353 <cprintf>
    int j;
    uint32_t *args;
    for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        args = (uint32_t *)ebp + 2;
        for(j = 0; j < 4; j++)
c0100b3b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100b3f:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b43:	7e d5                	jle    c0100b1a <print_stackframe+0x51>
            cprintf("0x%08x ",args[j]);
        cprintf("\n");
c0100b45:	c7 04 24 4c c0 10 c0 	movl   $0xc010c04c,(%esp)
c0100b4c:	e8 02 f8 ff ff       	call   c0100353 <cprintf>
        print_debuginfo(eip-1);
c0100b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b54:	83 e8 01             	sub    $0x1,%eax
c0100b57:	89 04 24             	mov    %eax,(%esp)
c0100b5a:	e8 b6 fe ff ff       	call   c0100a15 <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b62:	83 c0 04             	add    $0x4,%eax
c0100b65:	8b 00                	mov    (%eax),%eax
c0100b67:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b6d:	8b 00                	mov    (%eax),%eax
c0100b6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t ebp = read_ebp();
    uint32_t eip = read_eip();
    int i;
    int j;
    uint32_t *args;
    for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++) {
c0100b72:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100b76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b7a:	74 0a                	je     c0100b86 <print_stackframe+0xbd>
c0100b7c:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b80:	0f 8e 68 ff ff ff    	jle    c0100aee <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip-1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0100b86:	c9                   	leave  
c0100b87:	c3                   	ret    

c0100b88 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b88:	55                   	push   %ebp
c0100b89:	89 e5                	mov    %esp,%ebp
c0100b8b:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b95:	eb 0c                	jmp    c0100ba3 <parse+0x1b>
            *buf ++ = '\0';
c0100b97:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b9a:	8d 50 01             	lea    0x1(%eax),%edx
c0100b9d:	89 55 08             	mov    %edx,0x8(%ebp)
c0100ba0:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ba3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ba6:	0f b6 00             	movzbl (%eax),%eax
c0100ba9:	84 c0                	test   %al,%al
c0100bab:	74 1d                	je     c0100bca <parse+0x42>
c0100bad:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb0:	0f b6 00             	movzbl (%eax),%eax
c0100bb3:	0f be c0             	movsbl %al,%eax
c0100bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bba:	c7 04 24 d0 c0 10 c0 	movl   $0xc010c0d0,(%esp)
c0100bc1:	e8 7d af 00 00       	call   c010bb43 <strchr>
c0100bc6:	85 c0                	test   %eax,%eax
c0100bc8:	75 cd                	jne    c0100b97 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100bca:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bcd:	0f b6 00             	movzbl (%eax),%eax
c0100bd0:	84 c0                	test   %al,%al
c0100bd2:	75 02                	jne    c0100bd6 <parse+0x4e>
            break;
c0100bd4:	eb 67                	jmp    c0100c3d <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100bd6:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100bda:	75 14                	jne    c0100bf0 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bdc:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100be3:	00 
c0100be4:	c7 04 24 d5 c0 10 c0 	movl   $0xc010c0d5,(%esp)
c0100beb:	e8 63 f7 ff ff       	call   c0100353 <cprintf>
        }
        argv[argc ++] = buf;
c0100bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bf3:	8d 50 01             	lea    0x1(%eax),%edx
c0100bf6:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bf9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100c00:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c03:	01 c2                	add    %eax,%edx
c0100c05:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c08:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c0a:	eb 04                	jmp    c0100c10 <parse+0x88>
            buf ++;
c0100c0c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c10:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c13:	0f b6 00             	movzbl (%eax),%eax
c0100c16:	84 c0                	test   %al,%al
c0100c18:	74 1d                	je     c0100c37 <parse+0xaf>
c0100c1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c1d:	0f b6 00             	movzbl (%eax),%eax
c0100c20:	0f be c0             	movsbl %al,%eax
c0100c23:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c27:	c7 04 24 d0 c0 10 c0 	movl   $0xc010c0d0,(%esp)
c0100c2e:	e8 10 af 00 00       	call   c010bb43 <strchr>
c0100c33:	85 c0                	test   %eax,%eax
c0100c35:	74 d5                	je     c0100c0c <parse+0x84>
            buf ++;
        }
    }
c0100c37:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c38:	e9 66 ff ff ff       	jmp    c0100ba3 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c40:	c9                   	leave  
c0100c41:	c3                   	ret    

c0100c42 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c42:	55                   	push   %ebp
c0100c43:	89 e5                	mov    %esp,%ebp
c0100c45:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c48:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c4b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c52:	89 04 24             	mov    %eax,(%esp)
c0100c55:	e8 2e ff ff ff       	call   c0100b88 <parse>
c0100c5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c61:	75 0a                	jne    c0100c6d <runcmd+0x2b>
        return 0;
c0100c63:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c68:	e9 85 00 00 00       	jmp    c0100cf2 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c6d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c74:	eb 5c                	jmp    c0100cd2 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c76:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c79:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c7c:	89 d0                	mov    %edx,%eax
c0100c7e:	01 c0                	add    %eax,%eax
c0100c80:	01 d0                	add    %edx,%eax
c0100c82:	c1 e0 02             	shl    $0x2,%eax
c0100c85:	05 20 a0 12 c0       	add    $0xc012a020,%eax
c0100c8a:	8b 00                	mov    (%eax),%eax
c0100c8c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c90:	89 04 24             	mov    %eax,(%esp)
c0100c93:	e8 0c ae 00 00       	call   c010baa4 <strcmp>
c0100c98:	85 c0                	test   %eax,%eax
c0100c9a:	75 32                	jne    c0100cce <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c9f:	89 d0                	mov    %edx,%eax
c0100ca1:	01 c0                	add    %eax,%eax
c0100ca3:	01 d0                	add    %edx,%eax
c0100ca5:	c1 e0 02             	shl    $0x2,%eax
c0100ca8:	05 20 a0 12 c0       	add    $0xc012a020,%eax
c0100cad:	8b 40 08             	mov    0x8(%eax),%eax
c0100cb0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100cb3:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100cb6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100cb9:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100cbd:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100cc0:	83 c2 04             	add    $0x4,%edx
c0100cc3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100cc7:	89 0c 24             	mov    %ecx,(%esp)
c0100cca:	ff d0                	call   *%eax
c0100ccc:	eb 24                	jmp    c0100cf2 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cd5:	83 f8 02             	cmp    $0x2,%eax
c0100cd8:	76 9c                	jbe    c0100c76 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cda:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ce1:	c7 04 24 f3 c0 10 c0 	movl   $0xc010c0f3,(%esp)
c0100ce8:	e8 66 f6 ff ff       	call   c0100353 <cprintf>
    return 0;
c0100ced:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cf2:	c9                   	leave  
c0100cf3:	c3                   	ret    

c0100cf4 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cf4:	55                   	push   %ebp
c0100cf5:	89 e5                	mov    %esp,%ebp
c0100cf7:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cfa:	c7 04 24 0c c1 10 c0 	movl   $0xc010c10c,(%esp)
c0100d01:	e8 4d f6 ff ff       	call   c0100353 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100d06:	c7 04 24 34 c1 10 c0 	movl   $0xc010c134,(%esp)
c0100d0d:	e8 41 f6 ff ff       	call   c0100353 <cprintf>

    if (tf != NULL) {
c0100d12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d16:	74 0b                	je     c0100d23 <kmonitor+0x2f>
        print_trapframe(tf);
c0100d18:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d1b:	89 04 24             	mov    %eax,(%esp)
c0100d1e:	e8 c7 16 00 00       	call   c01023ea <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d23:	c7 04 24 59 c1 10 c0 	movl   $0xc010c159,(%esp)
c0100d2a:	e8 1b f5 ff ff       	call   c010024a <readline>
c0100d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d36:	74 18                	je     c0100d50 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100d38:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d42:	89 04 24             	mov    %eax,(%esp)
c0100d45:	e8 f8 fe ff ff       	call   c0100c42 <runcmd>
c0100d4a:	85 c0                	test   %eax,%eax
c0100d4c:	79 02                	jns    c0100d50 <kmonitor+0x5c>
                break;
c0100d4e:	eb 02                	jmp    c0100d52 <kmonitor+0x5e>
            }
        }
    }
c0100d50:	eb d1                	jmp    c0100d23 <kmonitor+0x2f>
}
c0100d52:	c9                   	leave  
c0100d53:	c3                   	ret    

c0100d54 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d54:	55                   	push   %ebp
c0100d55:	89 e5                	mov    %esp,%ebp
c0100d57:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d61:	eb 3f                	jmp    c0100da2 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d63:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d66:	89 d0                	mov    %edx,%eax
c0100d68:	01 c0                	add    %eax,%eax
c0100d6a:	01 d0                	add    %edx,%eax
c0100d6c:	c1 e0 02             	shl    $0x2,%eax
c0100d6f:	05 20 a0 12 c0       	add    $0xc012a020,%eax
c0100d74:	8b 48 04             	mov    0x4(%eax),%ecx
c0100d77:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d7a:	89 d0                	mov    %edx,%eax
c0100d7c:	01 c0                	add    %eax,%eax
c0100d7e:	01 d0                	add    %edx,%eax
c0100d80:	c1 e0 02             	shl    $0x2,%eax
c0100d83:	05 20 a0 12 c0       	add    $0xc012a020,%eax
c0100d88:	8b 00                	mov    (%eax),%eax
c0100d8a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d92:	c7 04 24 5d c1 10 c0 	movl   $0xc010c15d,(%esp)
c0100d99:	e8 b5 f5 ff ff       	call   c0100353 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d9e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100da5:	83 f8 02             	cmp    $0x2,%eax
c0100da8:	76 b9                	jbe    c0100d63 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100daa:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100daf:	c9                   	leave  
c0100db0:	c3                   	ret    

c0100db1 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100db1:	55                   	push   %ebp
c0100db2:	89 e5                	mov    %esp,%ebp
c0100db4:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100db7:	e8 c3 fb ff ff       	call   c010097f <print_kerninfo>
    return 0;
c0100dbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dc1:	c9                   	leave  
c0100dc2:	c3                   	ret    

c0100dc3 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100dc3:	55                   	push   %ebp
c0100dc4:	89 e5                	mov    %esp,%ebp
c0100dc6:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100dc9:	e8 fb fc ff ff       	call   c0100ac9 <print_stackframe>
    return 0;
c0100dce:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dd3:	c9                   	leave  
c0100dd4:	c3                   	ret    

c0100dd5 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100dd5:	55                   	push   %ebp
c0100dd6:	89 e5                	mov    %esp,%ebp
c0100dd8:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100ddb:	a1 60 c3 19 c0       	mov    0xc019c360,%eax
c0100de0:	85 c0                	test   %eax,%eax
c0100de2:	74 02                	je     c0100de6 <__panic+0x11>
        goto panic_dead;
c0100de4:	eb 48                	jmp    c0100e2e <__panic+0x59>
    }
    is_panic = 1;
c0100de6:	c7 05 60 c3 19 c0 01 	movl   $0x1,0xc019c360
c0100ded:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100df0:	8d 45 14             	lea    0x14(%ebp),%eax
c0100df3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100df6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100df9:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100dfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e04:	c7 04 24 66 c1 10 c0 	movl   $0xc010c166,(%esp)
c0100e0b:	e8 43 f5 ff ff       	call   c0100353 <cprintf>
    vcprintf(fmt, ap);
c0100e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e13:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e17:	8b 45 10             	mov    0x10(%ebp),%eax
c0100e1a:	89 04 24             	mov    %eax,(%esp)
c0100e1d:	e8 fe f4 ff ff       	call   c0100320 <vcprintf>
    cprintf("\n");
c0100e22:	c7 04 24 82 c1 10 c0 	movl   $0xc010c182,(%esp)
c0100e29:	e8 25 f5 ff ff       	call   c0100353 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
c0100e2e:	e8 fa 11 00 00       	call   c010202d <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100e33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e3a:	e8 b5 fe ff ff       	call   c0100cf4 <kmonitor>
    }
c0100e3f:	eb f2                	jmp    c0100e33 <__panic+0x5e>

c0100e41 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100e41:	55                   	push   %ebp
c0100e42:	89 e5                	mov    %esp,%ebp
c0100e44:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100e47:	8d 45 14             	lea    0x14(%ebp),%eax
c0100e4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e50:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100e54:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e5b:	c7 04 24 84 c1 10 c0 	movl   $0xc010c184,(%esp)
c0100e62:	e8 ec f4 ff ff       	call   c0100353 <cprintf>
    vcprintf(fmt, ap);
c0100e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e6e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100e71:	89 04 24             	mov    %eax,(%esp)
c0100e74:	e8 a7 f4 ff ff       	call   c0100320 <vcprintf>
    cprintf("\n");
c0100e79:	c7 04 24 82 c1 10 c0 	movl   $0xc010c182,(%esp)
c0100e80:	e8 ce f4 ff ff       	call   c0100353 <cprintf>
    va_end(ap);
}
c0100e85:	c9                   	leave  
c0100e86:	c3                   	ret    

c0100e87 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100e87:	55                   	push   %ebp
c0100e88:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100e8a:	a1 60 c3 19 c0       	mov    0xc019c360,%eax
}
c0100e8f:	5d                   	pop    %ebp
c0100e90:	c3                   	ret    

c0100e91 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100e91:	55                   	push   %ebp
c0100e92:	89 e5                	mov    %esp,%ebp
c0100e94:	83 ec 28             	sub    $0x28,%esp
c0100e97:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100e9d:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ea1:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100ea5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100ea9:	ee                   	out    %al,(%dx)
c0100eaa:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100eb0:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100eb4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100eb8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ebc:	ee                   	out    %al,(%dx)
c0100ebd:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100ec3:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100ec7:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100ecb:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100ecf:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100ed0:	c7 05 b4 ef 19 c0 00 	movl   $0x0,0xc019efb4
c0100ed7:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100eda:	c7 04 24 a2 c1 10 c0 	movl   $0xc010c1a2,(%esp)
c0100ee1:	e8 6d f4 ff ff       	call   c0100353 <cprintf>
    pic_enable(IRQ_TIMER);
c0100ee6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100eed:	e8 99 11 00 00       	call   c010208b <pic_enable>
}
c0100ef2:	c9                   	leave  
c0100ef3:	c3                   	ret    

c0100ef4 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0100ef4:	55                   	push   %ebp
c0100ef5:	89 e5                	mov    %esp,%ebp
c0100ef7:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100efa:	9c                   	pushf  
c0100efb:	58                   	pop    %eax
c0100efc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100f02:	25 00 02 00 00       	and    $0x200,%eax
c0100f07:	85 c0                	test   %eax,%eax
c0100f09:	74 0c                	je     c0100f17 <__intr_save+0x23>
        intr_disable();
c0100f0b:	e8 1d 11 00 00       	call   c010202d <intr_disable>
        return 1;
c0100f10:	b8 01 00 00 00       	mov    $0x1,%eax
c0100f15:	eb 05                	jmp    c0100f1c <__intr_save+0x28>
    }
    return 0;
c0100f17:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100f1c:	c9                   	leave  
c0100f1d:	c3                   	ret    

c0100f1e <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100f1e:	55                   	push   %ebp
c0100f1f:	89 e5                	mov    %esp,%ebp
c0100f21:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100f24:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100f28:	74 05                	je     c0100f2f <__intr_restore+0x11>
        intr_enable();
c0100f2a:	e8 f8 10 00 00       	call   c0102027 <intr_enable>
    }
}
c0100f2f:	c9                   	leave  
c0100f30:	c3                   	ret    

c0100f31 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100f31:	55                   	push   %ebp
c0100f32:	89 e5                	mov    %esp,%ebp
c0100f34:	83 ec 10             	sub    $0x10,%esp
c0100f37:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f3d:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100f41:	89 c2                	mov    %eax,%edx
c0100f43:	ec                   	in     (%dx),%al
c0100f44:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100f47:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100f4d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100f51:	89 c2                	mov    %eax,%edx
c0100f53:	ec                   	in     (%dx),%al
c0100f54:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100f57:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100f5d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f61:	89 c2                	mov    %eax,%edx
c0100f63:	ec                   	in     (%dx),%al
c0100f64:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100f67:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100f6d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f71:	89 c2                	mov    %eax,%edx
c0100f73:	ec                   	in     (%dx),%al
c0100f74:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100f77:	c9                   	leave  
c0100f78:	c3                   	ret    

c0100f79 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100f79:	55                   	push   %ebp
c0100f7a:	89 e5                	mov    %esp,%ebp
c0100f7c:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100f7f:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100f86:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f89:	0f b7 00             	movzwl (%eax),%eax
c0100f8c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100f90:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f93:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100f98:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f9b:	0f b7 00             	movzwl (%eax),%eax
c0100f9e:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100fa2:	74 12                	je     c0100fb6 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100fa4:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100fab:	66 c7 05 86 c3 19 c0 	movw   $0x3b4,0xc019c386
c0100fb2:	b4 03 
c0100fb4:	eb 13                	jmp    c0100fc9 <cga_init+0x50>
    } else {
        *cp = was;
c0100fb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fb9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100fbd:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100fc0:	66 c7 05 86 c3 19 c0 	movw   $0x3d4,0xc019c386
c0100fc7:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100fc9:	0f b7 05 86 c3 19 c0 	movzwl 0xc019c386,%eax
c0100fd0:	0f b7 c0             	movzwl %ax,%eax
c0100fd3:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100fd7:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fdb:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fdf:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100fe3:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100fe4:	0f b7 05 86 c3 19 c0 	movzwl 0xc019c386,%eax
c0100feb:	83 c0 01             	add    $0x1,%eax
c0100fee:	0f b7 c0             	movzwl %ax,%eax
c0100ff1:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ff5:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100ff9:	89 c2                	mov    %eax,%edx
c0100ffb:	ec                   	in     (%dx),%al
c0100ffc:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100fff:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101003:	0f b6 c0             	movzbl %al,%eax
c0101006:	c1 e0 08             	shl    $0x8,%eax
c0101009:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c010100c:	0f b7 05 86 c3 19 c0 	movzwl 0xc019c386,%eax
c0101013:	0f b7 c0             	movzwl %ax,%eax
c0101016:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c010101a:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010101e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101022:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101026:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0101027:	0f b7 05 86 c3 19 c0 	movzwl 0xc019c386,%eax
c010102e:	83 c0 01             	add    $0x1,%eax
c0101031:	0f b7 c0             	movzwl %ax,%eax
c0101034:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101038:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c010103c:	89 c2                	mov    %eax,%edx
c010103e:	ec                   	in     (%dx),%al
c010103f:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0101042:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101046:	0f b6 c0             	movzbl %al,%eax
c0101049:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c010104c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010104f:	a3 80 c3 19 c0       	mov    %eax,0xc019c380
    crt_pos = pos;
c0101054:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101057:	66 a3 84 c3 19 c0    	mov    %ax,0xc019c384
}
c010105d:	c9                   	leave  
c010105e:	c3                   	ret    

c010105f <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c010105f:	55                   	push   %ebp
c0101060:	89 e5                	mov    %esp,%ebp
c0101062:	83 ec 48             	sub    $0x48,%esp
c0101065:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c010106b:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010106f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101073:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101077:	ee                   	out    %al,(%dx)
c0101078:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c010107e:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0101082:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101086:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010108a:	ee                   	out    %al,(%dx)
c010108b:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0101091:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0101095:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101099:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010109d:	ee                   	out    %al,(%dx)
c010109e:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c01010a4:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c01010a8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01010ac:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01010b0:	ee                   	out    %al,(%dx)
c01010b1:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c01010b7:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c01010bb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01010bf:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01010c3:	ee                   	out    %al,(%dx)
c01010c4:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c01010ca:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c01010ce:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01010d2:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01010d6:	ee                   	out    %al,(%dx)
c01010d7:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c01010dd:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c01010e1:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01010e5:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01010e9:	ee                   	out    %al,(%dx)
c01010ea:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01010f0:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c01010f4:	89 c2                	mov    %eax,%edx
c01010f6:	ec                   	in     (%dx),%al
c01010f7:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c01010fa:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c01010fe:	3c ff                	cmp    $0xff,%al
c0101100:	0f 95 c0             	setne  %al
c0101103:	0f b6 c0             	movzbl %al,%eax
c0101106:	a3 88 c3 19 c0       	mov    %eax,0xc019c388
c010110b:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101111:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101115:	89 c2                	mov    %eax,%edx
c0101117:	ec                   	in     (%dx),%al
c0101118:	88 45 d5             	mov    %al,-0x2b(%ebp)
c010111b:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0101121:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101125:	89 c2                	mov    %eax,%edx
c0101127:	ec                   	in     (%dx),%al
c0101128:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010112b:	a1 88 c3 19 c0       	mov    0xc019c388,%eax
c0101130:	85 c0                	test   %eax,%eax
c0101132:	74 0c                	je     c0101140 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101134:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010113b:	e8 4b 0f 00 00       	call   c010208b <pic_enable>
    }
}
c0101140:	c9                   	leave  
c0101141:	c3                   	ret    

c0101142 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101142:	55                   	push   %ebp
c0101143:	89 e5                	mov    %esp,%ebp
c0101145:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101148:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010114f:	eb 09                	jmp    c010115a <lpt_putc_sub+0x18>
        delay();
c0101151:	e8 db fd ff ff       	call   c0100f31 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101156:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010115a:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101160:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101164:	89 c2                	mov    %eax,%edx
c0101166:	ec                   	in     (%dx),%al
c0101167:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010116a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010116e:	84 c0                	test   %al,%al
c0101170:	78 09                	js     c010117b <lpt_putc_sub+0x39>
c0101172:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101179:	7e d6                	jle    c0101151 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c010117b:	8b 45 08             	mov    0x8(%ebp),%eax
c010117e:	0f b6 c0             	movzbl %al,%eax
c0101181:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0101187:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010118a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010118e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101192:	ee                   	out    %al,(%dx)
c0101193:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101199:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c010119d:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01011a1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011a5:	ee                   	out    %al,(%dx)
c01011a6:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01011ac:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01011b0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01011b4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01011b8:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01011b9:	c9                   	leave  
c01011ba:	c3                   	ret    

c01011bb <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01011bb:	55                   	push   %ebp
c01011bc:	89 e5                	mov    %esp,%ebp
c01011be:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01011c1:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01011c5:	74 0d                	je     c01011d4 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01011c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01011ca:	89 04 24             	mov    %eax,(%esp)
c01011cd:	e8 70 ff ff ff       	call   c0101142 <lpt_putc_sub>
c01011d2:	eb 24                	jmp    c01011f8 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01011d4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01011db:	e8 62 ff ff ff       	call   c0101142 <lpt_putc_sub>
        lpt_putc_sub(' ');
c01011e0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01011e7:	e8 56 ff ff ff       	call   c0101142 <lpt_putc_sub>
        lpt_putc_sub('\b');
c01011ec:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01011f3:	e8 4a ff ff ff       	call   c0101142 <lpt_putc_sub>
    }
}
c01011f8:	c9                   	leave  
c01011f9:	c3                   	ret    

c01011fa <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01011fa:	55                   	push   %ebp
c01011fb:	89 e5                	mov    %esp,%ebp
c01011fd:	53                   	push   %ebx
c01011fe:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101201:	8b 45 08             	mov    0x8(%ebp),%eax
c0101204:	b0 00                	mov    $0x0,%al
c0101206:	85 c0                	test   %eax,%eax
c0101208:	75 07                	jne    c0101211 <cga_putc+0x17>
        c |= 0x0700;
c010120a:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101211:	8b 45 08             	mov    0x8(%ebp),%eax
c0101214:	0f b6 c0             	movzbl %al,%eax
c0101217:	83 f8 0a             	cmp    $0xa,%eax
c010121a:	74 4c                	je     c0101268 <cga_putc+0x6e>
c010121c:	83 f8 0d             	cmp    $0xd,%eax
c010121f:	74 57                	je     c0101278 <cga_putc+0x7e>
c0101221:	83 f8 08             	cmp    $0x8,%eax
c0101224:	0f 85 88 00 00 00    	jne    c01012b2 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c010122a:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c0101231:	66 85 c0             	test   %ax,%ax
c0101234:	74 30                	je     c0101266 <cga_putc+0x6c>
            crt_pos --;
c0101236:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c010123d:	83 e8 01             	sub    $0x1,%eax
c0101240:	66 a3 84 c3 19 c0    	mov    %ax,0xc019c384
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101246:	a1 80 c3 19 c0       	mov    0xc019c380,%eax
c010124b:	0f b7 15 84 c3 19 c0 	movzwl 0xc019c384,%edx
c0101252:	0f b7 d2             	movzwl %dx,%edx
c0101255:	01 d2                	add    %edx,%edx
c0101257:	01 c2                	add    %eax,%edx
c0101259:	8b 45 08             	mov    0x8(%ebp),%eax
c010125c:	b0 00                	mov    $0x0,%al
c010125e:	83 c8 20             	or     $0x20,%eax
c0101261:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101264:	eb 72                	jmp    c01012d8 <cga_putc+0xde>
c0101266:	eb 70                	jmp    c01012d8 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101268:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c010126f:	83 c0 50             	add    $0x50,%eax
c0101272:	66 a3 84 c3 19 c0    	mov    %ax,0xc019c384
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101278:	0f b7 1d 84 c3 19 c0 	movzwl 0xc019c384,%ebx
c010127f:	0f b7 0d 84 c3 19 c0 	movzwl 0xc019c384,%ecx
c0101286:	0f b7 c1             	movzwl %cx,%eax
c0101289:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c010128f:	c1 e8 10             	shr    $0x10,%eax
c0101292:	89 c2                	mov    %eax,%edx
c0101294:	66 c1 ea 06          	shr    $0x6,%dx
c0101298:	89 d0                	mov    %edx,%eax
c010129a:	c1 e0 02             	shl    $0x2,%eax
c010129d:	01 d0                	add    %edx,%eax
c010129f:	c1 e0 04             	shl    $0x4,%eax
c01012a2:	29 c1                	sub    %eax,%ecx
c01012a4:	89 ca                	mov    %ecx,%edx
c01012a6:	89 d8                	mov    %ebx,%eax
c01012a8:	29 d0                	sub    %edx,%eax
c01012aa:	66 a3 84 c3 19 c0    	mov    %ax,0xc019c384
        break;
c01012b0:	eb 26                	jmp    c01012d8 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01012b2:	8b 0d 80 c3 19 c0    	mov    0xc019c380,%ecx
c01012b8:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c01012bf:	8d 50 01             	lea    0x1(%eax),%edx
c01012c2:	66 89 15 84 c3 19 c0 	mov    %dx,0xc019c384
c01012c9:	0f b7 c0             	movzwl %ax,%eax
c01012cc:	01 c0                	add    %eax,%eax
c01012ce:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01012d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01012d4:	66 89 02             	mov    %ax,(%edx)
        break;
c01012d7:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01012d8:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c01012df:	66 3d cf 07          	cmp    $0x7cf,%ax
c01012e3:	76 5b                	jbe    c0101340 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01012e5:	a1 80 c3 19 c0       	mov    0xc019c380,%eax
c01012ea:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01012f0:	a1 80 c3 19 c0       	mov    0xc019c380,%eax
c01012f5:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c01012fc:	00 
c01012fd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101301:	89 04 24             	mov    %eax,(%esp)
c0101304:	e8 38 aa 00 00       	call   c010bd41 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101309:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101310:	eb 15                	jmp    c0101327 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101312:	a1 80 c3 19 c0       	mov    0xc019c380,%eax
c0101317:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010131a:	01 d2                	add    %edx,%edx
c010131c:	01 d0                	add    %edx,%eax
c010131e:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101323:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101327:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010132e:	7e e2                	jle    c0101312 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101330:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c0101337:	83 e8 50             	sub    $0x50,%eax
c010133a:	66 a3 84 c3 19 c0    	mov    %ax,0xc019c384
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101340:	0f b7 05 86 c3 19 c0 	movzwl 0xc019c386,%eax
c0101347:	0f b7 c0             	movzwl %ax,%eax
c010134a:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010134e:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101352:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101356:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010135a:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c010135b:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c0101362:	66 c1 e8 08          	shr    $0x8,%ax
c0101366:	0f b6 c0             	movzbl %al,%eax
c0101369:	0f b7 15 86 c3 19 c0 	movzwl 0xc019c386,%edx
c0101370:	83 c2 01             	add    $0x1,%edx
c0101373:	0f b7 d2             	movzwl %dx,%edx
c0101376:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c010137a:	88 45 ed             	mov    %al,-0x13(%ebp)
c010137d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101381:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101385:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101386:	0f b7 05 86 c3 19 c0 	movzwl 0xc019c386,%eax
c010138d:	0f b7 c0             	movzwl %ax,%eax
c0101390:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101394:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c0101398:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010139c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01013a0:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01013a1:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c01013a8:	0f b6 c0             	movzbl %al,%eax
c01013ab:	0f b7 15 86 c3 19 c0 	movzwl 0xc019c386,%edx
c01013b2:	83 c2 01             	add    $0x1,%edx
c01013b5:	0f b7 d2             	movzwl %dx,%edx
c01013b8:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01013bc:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01013bf:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01013c3:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01013c7:	ee                   	out    %al,(%dx)
}
c01013c8:	83 c4 34             	add    $0x34,%esp
c01013cb:	5b                   	pop    %ebx
c01013cc:	5d                   	pop    %ebp
c01013cd:	c3                   	ret    

c01013ce <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01013ce:	55                   	push   %ebp
c01013cf:	89 e5                	mov    %esp,%ebp
c01013d1:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01013d4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01013db:	eb 09                	jmp    c01013e6 <serial_putc_sub+0x18>
        delay();
c01013dd:	e8 4f fb ff ff       	call   c0100f31 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01013e2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01013e6:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013ec:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013f0:	89 c2                	mov    %eax,%edx
c01013f2:	ec                   	in     (%dx),%al
c01013f3:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013f6:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01013fa:	0f b6 c0             	movzbl %al,%eax
c01013fd:	83 e0 20             	and    $0x20,%eax
c0101400:	85 c0                	test   %eax,%eax
c0101402:	75 09                	jne    c010140d <serial_putc_sub+0x3f>
c0101404:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010140b:	7e d0                	jle    c01013dd <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c010140d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101410:	0f b6 c0             	movzbl %al,%eax
c0101413:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101419:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010141c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101420:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101424:	ee                   	out    %al,(%dx)
}
c0101425:	c9                   	leave  
c0101426:	c3                   	ret    

c0101427 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101427:	55                   	push   %ebp
c0101428:	89 e5                	mov    %esp,%ebp
c010142a:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010142d:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101431:	74 0d                	je     c0101440 <serial_putc+0x19>
        serial_putc_sub(c);
c0101433:	8b 45 08             	mov    0x8(%ebp),%eax
c0101436:	89 04 24             	mov    %eax,(%esp)
c0101439:	e8 90 ff ff ff       	call   c01013ce <serial_putc_sub>
c010143e:	eb 24                	jmp    c0101464 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101440:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101447:	e8 82 ff ff ff       	call   c01013ce <serial_putc_sub>
        serial_putc_sub(' ');
c010144c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101453:	e8 76 ff ff ff       	call   c01013ce <serial_putc_sub>
        serial_putc_sub('\b');
c0101458:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010145f:	e8 6a ff ff ff       	call   c01013ce <serial_putc_sub>
    }
}
c0101464:	c9                   	leave  
c0101465:	c3                   	ret    

c0101466 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101466:	55                   	push   %ebp
c0101467:	89 e5                	mov    %esp,%ebp
c0101469:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010146c:	eb 33                	jmp    c01014a1 <cons_intr+0x3b>
        if (c != 0) {
c010146e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101472:	74 2d                	je     c01014a1 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101474:	a1 a4 c5 19 c0       	mov    0xc019c5a4,%eax
c0101479:	8d 50 01             	lea    0x1(%eax),%edx
c010147c:	89 15 a4 c5 19 c0    	mov    %edx,0xc019c5a4
c0101482:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101485:	88 90 a0 c3 19 c0    	mov    %dl,-0x3fe63c60(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c010148b:	a1 a4 c5 19 c0       	mov    0xc019c5a4,%eax
c0101490:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101495:	75 0a                	jne    c01014a1 <cons_intr+0x3b>
                cons.wpos = 0;
c0101497:	c7 05 a4 c5 19 c0 00 	movl   $0x0,0xc019c5a4
c010149e:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01014a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01014a4:	ff d0                	call   *%eax
c01014a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01014a9:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01014ad:	75 bf                	jne    c010146e <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01014af:	c9                   	leave  
c01014b0:	c3                   	ret    

c01014b1 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01014b1:	55                   	push   %ebp
c01014b2:	89 e5                	mov    %esp,%ebp
c01014b4:	83 ec 10             	sub    $0x10,%esp
c01014b7:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014bd:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01014c1:	89 c2                	mov    %eax,%edx
c01014c3:	ec                   	in     (%dx),%al
c01014c4:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01014c7:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01014cb:	0f b6 c0             	movzbl %al,%eax
c01014ce:	83 e0 01             	and    $0x1,%eax
c01014d1:	85 c0                	test   %eax,%eax
c01014d3:	75 07                	jne    c01014dc <serial_proc_data+0x2b>
        return -1;
c01014d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014da:	eb 2a                	jmp    c0101506 <serial_proc_data+0x55>
c01014dc:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014e2:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01014e6:	89 c2                	mov    %eax,%edx
c01014e8:	ec                   	in     (%dx),%al
c01014e9:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01014ec:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01014f0:	0f b6 c0             	movzbl %al,%eax
c01014f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01014f6:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01014fa:	75 07                	jne    c0101503 <serial_proc_data+0x52>
        c = '\b';
c01014fc:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101503:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101506:	c9                   	leave  
c0101507:	c3                   	ret    

c0101508 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101508:	55                   	push   %ebp
c0101509:	89 e5                	mov    %esp,%ebp
c010150b:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010150e:	a1 88 c3 19 c0       	mov    0xc019c388,%eax
c0101513:	85 c0                	test   %eax,%eax
c0101515:	74 0c                	je     c0101523 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101517:	c7 04 24 b1 14 10 c0 	movl   $0xc01014b1,(%esp)
c010151e:	e8 43 ff ff ff       	call   c0101466 <cons_intr>
    }
}
c0101523:	c9                   	leave  
c0101524:	c3                   	ret    

c0101525 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101525:	55                   	push   %ebp
c0101526:	89 e5                	mov    %esp,%ebp
c0101528:	83 ec 38             	sub    $0x38,%esp
c010152b:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101531:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101535:	89 c2                	mov    %eax,%edx
c0101537:	ec                   	in     (%dx),%al
c0101538:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c010153b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010153f:	0f b6 c0             	movzbl %al,%eax
c0101542:	83 e0 01             	and    $0x1,%eax
c0101545:	85 c0                	test   %eax,%eax
c0101547:	75 0a                	jne    c0101553 <kbd_proc_data+0x2e>
        return -1;
c0101549:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010154e:	e9 59 01 00 00       	jmp    c01016ac <kbd_proc_data+0x187>
c0101553:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101559:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010155d:	89 c2                	mov    %eax,%edx
c010155f:	ec                   	in     (%dx),%al
c0101560:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101563:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101567:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c010156a:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010156e:	75 17                	jne    c0101587 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101570:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c0101575:	83 c8 40             	or     $0x40,%eax
c0101578:	a3 a8 c5 19 c0       	mov    %eax,0xc019c5a8
        return 0;
c010157d:	b8 00 00 00 00       	mov    $0x0,%eax
c0101582:	e9 25 01 00 00       	jmp    c01016ac <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101587:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010158b:	84 c0                	test   %al,%al
c010158d:	79 47                	jns    c01015d6 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010158f:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c0101594:	83 e0 40             	and    $0x40,%eax
c0101597:	85 c0                	test   %eax,%eax
c0101599:	75 09                	jne    c01015a4 <kbd_proc_data+0x7f>
c010159b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010159f:	83 e0 7f             	and    $0x7f,%eax
c01015a2:	eb 04                	jmp    c01015a8 <kbd_proc_data+0x83>
c01015a4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015a8:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01015ab:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015af:	0f b6 80 60 a0 12 c0 	movzbl -0x3fed5fa0(%eax),%eax
c01015b6:	83 c8 40             	or     $0x40,%eax
c01015b9:	0f b6 c0             	movzbl %al,%eax
c01015bc:	f7 d0                	not    %eax
c01015be:	89 c2                	mov    %eax,%edx
c01015c0:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c01015c5:	21 d0                	and    %edx,%eax
c01015c7:	a3 a8 c5 19 c0       	mov    %eax,0xc019c5a8
        return 0;
c01015cc:	b8 00 00 00 00       	mov    $0x0,%eax
c01015d1:	e9 d6 00 00 00       	jmp    c01016ac <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01015d6:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c01015db:	83 e0 40             	and    $0x40,%eax
c01015de:	85 c0                	test   %eax,%eax
c01015e0:	74 11                	je     c01015f3 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01015e2:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01015e6:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c01015eb:	83 e0 bf             	and    $0xffffffbf,%eax
c01015ee:	a3 a8 c5 19 c0       	mov    %eax,0xc019c5a8
    }

    shift |= shiftcode[data];
c01015f3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015f7:	0f b6 80 60 a0 12 c0 	movzbl -0x3fed5fa0(%eax),%eax
c01015fe:	0f b6 d0             	movzbl %al,%edx
c0101601:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c0101606:	09 d0                	or     %edx,%eax
c0101608:	a3 a8 c5 19 c0       	mov    %eax,0xc019c5a8
    shift ^= togglecode[data];
c010160d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101611:	0f b6 80 60 a1 12 c0 	movzbl -0x3fed5ea0(%eax),%eax
c0101618:	0f b6 d0             	movzbl %al,%edx
c010161b:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c0101620:	31 d0                	xor    %edx,%eax
c0101622:	a3 a8 c5 19 c0       	mov    %eax,0xc019c5a8

    c = charcode[shift & (CTL | SHIFT)][data];
c0101627:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c010162c:	83 e0 03             	and    $0x3,%eax
c010162f:	8b 14 85 60 a5 12 c0 	mov    -0x3fed5aa0(,%eax,4),%edx
c0101636:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010163a:	01 d0                	add    %edx,%eax
c010163c:	0f b6 00             	movzbl (%eax),%eax
c010163f:	0f b6 c0             	movzbl %al,%eax
c0101642:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101645:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c010164a:	83 e0 08             	and    $0x8,%eax
c010164d:	85 c0                	test   %eax,%eax
c010164f:	74 22                	je     c0101673 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101651:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101655:	7e 0c                	jle    c0101663 <kbd_proc_data+0x13e>
c0101657:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c010165b:	7f 06                	jg     c0101663 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010165d:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101661:	eb 10                	jmp    c0101673 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101663:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101667:	7e 0a                	jle    c0101673 <kbd_proc_data+0x14e>
c0101669:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010166d:	7f 04                	jg     c0101673 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010166f:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101673:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c0101678:	f7 d0                	not    %eax
c010167a:	83 e0 06             	and    $0x6,%eax
c010167d:	85 c0                	test   %eax,%eax
c010167f:	75 28                	jne    c01016a9 <kbd_proc_data+0x184>
c0101681:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101688:	75 1f                	jne    c01016a9 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c010168a:	c7 04 24 bd c1 10 c0 	movl   $0xc010c1bd,(%esp)
c0101691:	e8 bd ec ff ff       	call   c0100353 <cprintf>
c0101696:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c010169c:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016a0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01016a4:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01016a8:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01016a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016ac:	c9                   	leave  
c01016ad:	c3                   	ret    

c01016ae <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01016ae:	55                   	push   %ebp
c01016af:	89 e5                	mov    %esp,%ebp
c01016b1:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01016b4:	c7 04 24 25 15 10 c0 	movl   $0xc0101525,(%esp)
c01016bb:	e8 a6 fd ff ff       	call   c0101466 <cons_intr>
}
c01016c0:	c9                   	leave  
c01016c1:	c3                   	ret    

c01016c2 <kbd_init>:

static void
kbd_init(void) {
c01016c2:	55                   	push   %ebp
c01016c3:	89 e5                	mov    %esp,%ebp
c01016c5:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01016c8:	e8 e1 ff ff ff       	call   c01016ae <kbd_intr>
    pic_enable(IRQ_KBD);
c01016cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01016d4:	e8 b2 09 00 00       	call   c010208b <pic_enable>
}
c01016d9:	c9                   	leave  
c01016da:	c3                   	ret    

c01016db <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01016db:	55                   	push   %ebp
c01016dc:	89 e5                	mov    %esp,%ebp
c01016de:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01016e1:	e8 93 f8 ff ff       	call   c0100f79 <cga_init>
    serial_init();
c01016e6:	e8 74 f9 ff ff       	call   c010105f <serial_init>
    kbd_init();
c01016eb:	e8 d2 ff ff ff       	call   c01016c2 <kbd_init>
    if (!serial_exists) {
c01016f0:	a1 88 c3 19 c0       	mov    0xc019c388,%eax
c01016f5:	85 c0                	test   %eax,%eax
c01016f7:	75 0c                	jne    c0101705 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c01016f9:	c7 04 24 c9 c1 10 c0 	movl   $0xc010c1c9,(%esp)
c0101700:	e8 4e ec ff ff       	call   c0100353 <cprintf>
    }
}
c0101705:	c9                   	leave  
c0101706:	c3                   	ret    

c0101707 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101707:	55                   	push   %ebp
c0101708:	89 e5                	mov    %esp,%ebp
c010170a:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010170d:	e8 e2 f7 ff ff       	call   c0100ef4 <__intr_save>
c0101712:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101715:	8b 45 08             	mov    0x8(%ebp),%eax
c0101718:	89 04 24             	mov    %eax,(%esp)
c010171b:	e8 9b fa ff ff       	call   c01011bb <lpt_putc>
        cga_putc(c);
c0101720:	8b 45 08             	mov    0x8(%ebp),%eax
c0101723:	89 04 24             	mov    %eax,(%esp)
c0101726:	e8 cf fa ff ff       	call   c01011fa <cga_putc>
        serial_putc(c);
c010172b:	8b 45 08             	mov    0x8(%ebp),%eax
c010172e:	89 04 24             	mov    %eax,(%esp)
c0101731:	e8 f1 fc ff ff       	call   c0101427 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101736:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101739:	89 04 24             	mov    %eax,(%esp)
c010173c:	e8 dd f7 ff ff       	call   c0100f1e <__intr_restore>
}
c0101741:	c9                   	leave  
c0101742:	c3                   	ret    

c0101743 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101743:	55                   	push   %ebp
c0101744:	89 e5                	mov    %esp,%ebp
c0101746:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101749:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101750:	e8 9f f7 ff ff       	call   c0100ef4 <__intr_save>
c0101755:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101758:	e8 ab fd ff ff       	call   c0101508 <serial_intr>
        kbd_intr();
c010175d:	e8 4c ff ff ff       	call   c01016ae <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101762:	8b 15 a0 c5 19 c0    	mov    0xc019c5a0,%edx
c0101768:	a1 a4 c5 19 c0       	mov    0xc019c5a4,%eax
c010176d:	39 c2                	cmp    %eax,%edx
c010176f:	74 31                	je     c01017a2 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101771:	a1 a0 c5 19 c0       	mov    0xc019c5a0,%eax
c0101776:	8d 50 01             	lea    0x1(%eax),%edx
c0101779:	89 15 a0 c5 19 c0    	mov    %edx,0xc019c5a0
c010177f:	0f b6 80 a0 c3 19 c0 	movzbl -0x3fe63c60(%eax),%eax
c0101786:	0f b6 c0             	movzbl %al,%eax
c0101789:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010178c:	a1 a0 c5 19 c0       	mov    0xc019c5a0,%eax
c0101791:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101796:	75 0a                	jne    c01017a2 <cons_getc+0x5f>
                cons.rpos = 0;
c0101798:	c7 05 a0 c5 19 c0 00 	movl   $0x0,0xc019c5a0
c010179f:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01017a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01017a5:	89 04 24             	mov    %eax,(%esp)
c01017a8:	e8 71 f7 ff ff       	call   c0100f1e <__intr_restore>
    return c;
c01017ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01017b0:	c9                   	leave  
c01017b1:	c3                   	ret    

c01017b2 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c01017b2:	55                   	push   %ebp
c01017b3:	89 e5                	mov    %esp,%ebp
c01017b5:	83 ec 14             	sub    $0x14,%esp
c01017b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01017bb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c01017bf:	90                   	nop
c01017c0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01017c4:	83 c0 07             	add    $0x7,%eax
c01017c7:	0f b7 c0             	movzwl %ax,%eax
c01017ca:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017ce:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01017d2:	89 c2                	mov    %eax,%edx
c01017d4:	ec                   	in     (%dx),%al
c01017d5:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01017d8:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01017dc:	0f b6 c0             	movzbl %al,%eax
c01017df:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01017e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017e5:	25 80 00 00 00       	and    $0x80,%eax
c01017ea:	85 c0                	test   %eax,%eax
c01017ec:	75 d2                	jne    c01017c0 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c01017ee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01017f2:	74 11                	je     c0101805 <ide_wait_ready+0x53>
c01017f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017f7:	83 e0 21             	and    $0x21,%eax
c01017fa:	85 c0                	test   %eax,%eax
c01017fc:	74 07                	je     c0101805 <ide_wait_ready+0x53>
        return -1;
c01017fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101803:	eb 05                	jmp    c010180a <ide_wait_ready+0x58>
    }
    return 0;
c0101805:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010180a:	c9                   	leave  
c010180b:	c3                   	ret    

c010180c <ide_init>:

void
ide_init(void) {
c010180c:	55                   	push   %ebp
c010180d:	89 e5                	mov    %esp,%ebp
c010180f:	57                   	push   %edi
c0101810:	53                   	push   %ebx
c0101811:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101817:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c010181d:	e9 d6 02 00 00       	jmp    c0101af8 <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0101822:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101826:	c1 e0 03             	shl    $0x3,%eax
c0101829:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101830:	29 c2                	sub    %eax,%edx
c0101832:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101838:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c010183b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010183f:	66 d1 e8             	shr    %ax
c0101842:	0f b7 c0             	movzwl %ax,%eax
c0101845:	0f b7 04 85 e8 c1 10 	movzwl -0x3fef3e18(,%eax,4),%eax
c010184c:	c0 
c010184d:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0101851:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101855:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010185c:	00 
c010185d:	89 04 24             	mov    %eax,(%esp)
c0101860:	e8 4d ff ff ff       	call   c01017b2 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0101865:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101869:	83 e0 01             	and    $0x1,%eax
c010186c:	c1 e0 04             	shl    $0x4,%eax
c010186f:	83 c8 e0             	or     $0xffffffe0,%eax
c0101872:	0f b6 c0             	movzbl %al,%eax
c0101875:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101879:	83 c2 06             	add    $0x6,%edx
c010187c:	0f b7 d2             	movzwl %dx,%edx
c010187f:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c0101883:	88 45 d1             	mov    %al,-0x2f(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101886:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010188a:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010188e:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c010188f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101893:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010189a:	00 
c010189b:	89 04 24             	mov    %eax,(%esp)
c010189e:	e8 0f ff ff ff       	call   c01017b2 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c01018a3:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018a7:	83 c0 07             	add    $0x7,%eax
c01018aa:	0f b7 c0             	movzwl %ax,%eax
c01018ad:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c01018b1:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c01018b5:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01018b9:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01018bd:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01018be:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01018c9:	00 
c01018ca:	89 04 24             	mov    %eax,(%esp)
c01018cd:	e8 e0 fe ff ff       	call   c01017b2 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c01018d2:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018d6:	83 c0 07             	add    $0x7,%eax
c01018d9:	0f b7 c0             	movzwl %ax,%eax
c01018dc:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01018e0:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c01018e4:	89 c2                	mov    %eax,%edx
c01018e6:	ec                   	in     (%dx),%al
c01018e7:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c01018ea:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01018ee:	84 c0                	test   %al,%al
c01018f0:	0f 84 f7 01 00 00    	je     c0101aed <ide_init+0x2e1>
c01018f6:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101901:	00 
c0101902:	89 04 24             	mov    %eax,(%esp)
c0101905:	e8 a8 fe ff ff       	call   c01017b2 <ide_wait_ready>
c010190a:	85 c0                	test   %eax,%eax
c010190c:	0f 85 db 01 00 00    	jne    c0101aed <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0101912:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101916:	c1 e0 03             	shl    $0x3,%eax
c0101919:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101920:	29 c2                	sub    %eax,%edx
c0101922:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101928:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c010192b:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010192f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0101932:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101938:	89 45 c0             	mov    %eax,-0x40(%ebp)
c010193b:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101942:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0101945:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0101948:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010194b:	89 cb                	mov    %ecx,%ebx
c010194d:	89 df                	mov    %ebx,%edi
c010194f:	89 c1                	mov    %eax,%ecx
c0101951:	fc                   	cld    
c0101952:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101954:	89 c8                	mov    %ecx,%eax
c0101956:	89 fb                	mov    %edi,%ebx
c0101958:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c010195b:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c010195e:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101964:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0101967:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010196a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0101970:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0101973:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101976:	25 00 00 00 04       	and    $0x4000000,%eax
c010197b:	85 c0                	test   %eax,%eax
c010197d:	74 0e                	je     c010198d <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c010197f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101982:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0101988:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010198b:	eb 09                	jmp    c0101996 <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c010198d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101990:	8b 40 78             	mov    0x78(%eax),%eax
c0101993:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0101996:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010199a:	c1 e0 03             	shl    $0x3,%eax
c010199d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019a4:	29 c2                	sub    %eax,%edx
c01019a6:	81 c2 c0 c5 19 c0    	add    $0xc019c5c0,%edx
c01019ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01019af:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c01019b2:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019b6:	c1 e0 03             	shl    $0x3,%eax
c01019b9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019c0:	29 c2                	sub    %eax,%edx
c01019c2:	81 c2 c0 c5 19 c0    	add    $0xc019c5c0,%edx
c01019c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01019cb:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01019ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019d1:	83 c0 62             	add    $0x62,%eax
c01019d4:	0f b7 00             	movzwl (%eax),%eax
c01019d7:	0f b7 c0             	movzwl %ax,%eax
c01019da:	25 00 02 00 00       	and    $0x200,%eax
c01019df:	85 c0                	test   %eax,%eax
c01019e1:	75 24                	jne    c0101a07 <ide_init+0x1fb>
c01019e3:	c7 44 24 0c f0 c1 10 	movl   $0xc010c1f0,0xc(%esp)
c01019ea:	c0 
c01019eb:	c7 44 24 08 33 c2 10 	movl   $0xc010c233,0x8(%esp)
c01019f2:	c0 
c01019f3:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01019fa:	00 
c01019fb:	c7 04 24 48 c2 10 c0 	movl   $0xc010c248,(%esp)
c0101a02:	e8 ce f3 ff ff       	call   c0100dd5 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101a07:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a0b:	c1 e0 03             	shl    $0x3,%eax
c0101a0e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101a15:	29 c2                	sub    %eax,%edx
c0101a17:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101a1d:	83 c0 0c             	add    $0xc,%eax
c0101a20:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101a23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a26:	83 c0 36             	add    $0x36,%eax
c0101a29:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101a2c:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101a33:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101a3a:	eb 34                	jmp    c0101a70 <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101a3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a3f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a42:	01 c2                	add    %eax,%edx
c0101a44:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a47:	8d 48 01             	lea    0x1(%eax),%ecx
c0101a4a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101a4d:	01 c8                	add    %ecx,%eax
c0101a4f:	0f b6 00             	movzbl (%eax),%eax
c0101a52:	88 02                	mov    %al,(%edx)
c0101a54:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a57:	8d 50 01             	lea    0x1(%eax),%edx
c0101a5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101a5d:	01 c2                	add    %eax,%edx
c0101a5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a62:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0101a65:	01 c8                	add    %ecx,%eax
c0101a67:	0f b6 00             	movzbl (%eax),%eax
c0101a6a:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c0101a6c:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101a70:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a73:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101a76:	72 c4                	jb     c0101a3c <ide_init+0x230>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0101a78:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a7b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a7e:	01 d0                	add    %edx,%eax
c0101a80:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101a83:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a86:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101a89:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101a8c:	85 c0                	test   %eax,%eax
c0101a8e:	74 0f                	je     c0101a9f <ide_init+0x293>
c0101a90:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a93:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a96:	01 d0                	add    %edx,%eax
c0101a98:	0f b6 00             	movzbl (%eax),%eax
c0101a9b:	3c 20                	cmp    $0x20,%al
c0101a9d:	74 d9                	je     c0101a78 <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101a9f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101aa3:	c1 e0 03             	shl    $0x3,%eax
c0101aa6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101aad:	29 c2                	sub    %eax,%edx
c0101aaf:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101ab5:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101ab8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101abc:	c1 e0 03             	shl    $0x3,%eax
c0101abf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101ac6:	29 c2                	sub    %eax,%edx
c0101ac8:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101ace:	8b 50 08             	mov    0x8(%eax),%edx
c0101ad1:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101ad5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101ad9:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101add:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae1:	c7 04 24 5a c2 10 c0 	movl   $0xc010c25a,(%esp)
c0101ae8:	e8 66 e8 ff ff       	call   c0100353 <cprintf>

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101aed:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101af1:	83 c0 01             	add    $0x1,%eax
c0101af4:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101af8:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101afd:	0f 86 1f fd ff ff    	jbe    c0101822 <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101b03:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101b0a:	e8 7c 05 00 00       	call   c010208b <pic_enable>
    pic_enable(IRQ_IDE2);
c0101b0f:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101b16:	e8 70 05 00 00       	call   c010208b <pic_enable>
}
c0101b1b:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101b21:	5b                   	pop    %ebx
c0101b22:	5f                   	pop    %edi
c0101b23:	5d                   	pop    %ebp
c0101b24:	c3                   	ret    

c0101b25 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101b25:	55                   	push   %ebp
c0101b26:	89 e5                	mov    %esp,%ebp
c0101b28:	83 ec 04             	sub    $0x4,%esp
c0101b2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b2e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101b32:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0101b37:	77 24                	ja     c0101b5d <ide_device_valid+0x38>
c0101b39:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b3d:	c1 e0 03             	shl    $0x3,%eax
c0101b40:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101b47:	29 c2                	sub    %eax,%edx
c0101b49:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101b4f:	0f b6 00             	movzbl (%eax),%eax
c0101b52:	84 c0                	test   %al,%al
c0101b54:	74 07                	je     c0101b5d <ide_device_valid+0x38>
c0101b56:	b8 01 00 00 00       	mov    $0x1,%eax
c0101b5b:	eb 05                	jmp    c0101b62 <ide_device_valid+0x3d>
c0101b5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101b62:	c9                   	leave  
c0101b63:	c3                   	ret    

c0101b64 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101b64:	55                   	push   %ebp
c0101b65:	89 e5                	mov    %esp,%ebp
c0101b67:	83 ec 08             	sub    $0x8,%esp
c0101b6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b6d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101b71:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b75:	89 04 24             	mov    %eax,(%esp)
c0101b78:	e8 a8 ff ff ff       	call   c0101b25 <ide_device_valid>
c0101b7d:	85 c0                	test   %eax,%eax
c0101b7f:	74 1b                	je     c0101b9c <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101b81:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b85:	c1 e0 03             	shl    $0x3,%eax
c0101b88:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101b8f:	29 c2                	sub    %eax,%edx
c0101b91:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101b97:	8b 40 08             	mov    0x8(%eax),%eax
c0101b9a:	eb 05                	jmp    c0101ba1 <ide_device_size+0x3d>
    }
    return 0;
c0101b9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101ba1:	c9                   	leave  
c0101ba2:	c3                   	ret    

c0101ba3 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101ba3:	55                   	push   %ebp
c0101ba4:	89 e5                	mov    %esp,%ebp
c0101ba6:	57                   	push   %edi
c0101ba7:	53                   	push   %ebx
c0101ba8:	83 ec 50             	sub    $0x50,%esp
c0101bab:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bae:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101bb2:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101bb9:	77 24                	ja     c0101bdf <ide_read_secs+0x3c>
c0101bbb:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101bc0:	77 1d                	ja     c0101bdf <ide_read_secs+0x3c>
c0101bc2:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bc6:	c1 e0 03             	shl    $0x3,%eax
c0101bc9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101bd0:	29 c2                	sub    %eax,%edx
c0101bd2:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101bd8:	0f b6 00             	movzbl (%eax),%eax
c0101bdb:	84 c0                	test   %al,%al
c0101bdd:	75 24                	jne    c0101c03 <ide_read_secs+0x60>
c0101bdf:	c7 44 24 0c 78 c2 10 	movl   $0xc010c278,0xc(%esp)
c0101be6:	c0 
c0101be7:	c7 44 24 08 33 c2 10 	movl   $0xc010c233,0x8(%esp)
c0101bee:	c0 
c0101bef:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101bf6:	00 
c0101bf7:	c7 04 24 48 c2 10 c0 	movl   $0xc010c248,(%esp)
c0101bfe:	e8 d2 f1 ff ff       	call   c0100dd5 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101c03:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101c0a:	77 0f                	ja     c0101c1b <ide_read_secs+0x78>
c0101c0c:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c0f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101c12:	01 d0                	add    %edx,%eax
c0101c14:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101c19:	76 24                	jbe    c0101c3f <ide_read_secs+0x9c>
c0101c1b:	c7 44 24 0c a0 c2 10 	movl   $0xc010c2a0,0xc(%esp)
c0101c22:	c0 
c0101c23:	c7 44 24 08 33 c2 10 	movl   $0xc010c233,0x8(%esp)
c0101c2a:	c0 
c0101c2b:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101c32:	00 
c0101c33:	c7 04 24 48 c2 10 c0 	movl   $0xc010c248,(%esp)
c0101c3a:	e8 96 f1 ff ff       	call   c0100dd5 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101c3f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c43:	66 d1 e8             	shr    %ax
c0101c46:	0f b7 c0             	movzwl %ax,%eax
c0101c49:	0f b7 04 85 e8 c1 10 	movzwl -0x3fef3e18(,%eax,4),%eax
c0101c50:	c0 
c0101c51:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101c55:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c59:	66 d1 e8             	shr    %ax
c0101c5c:	0f b7 c0             	movzwl %ax,%eax
c0101c5f:	0f b7 04 85 ea c1 10 	movzwl -0x3fef3e16(,%eax,4),%eax
c0101c66:	c0 
c0101c67:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101c6b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101c6f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101c76:	00 
c0101c77:	89 04 24             	mov    %eax,(%esp)
c0101c7a:	e8 33 fb ff ff       	call   c01017b2 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101c7f:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101c83:	83 c0 02             	add    $0x2,%eax
c0101c86:	0f b7 c0             	movzwl %ax,%eax
c0101c89:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101c8d:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c91:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101c95:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101c99:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101c9a:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c9d:	0f b6 c0             	movzbl %al,%eax
c0101ca0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ca4:	83 c2 02             	add    $0x2,%edx
c0101ca7:	0f b7 d2             	movzwl %dx,%edx
c0101caa:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101cae:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101cb1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101cb5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101cb9:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101cba:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cbd:	0f b6 c0             	movzbl %al,%eax
c0101cc0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cc4:	83 c2 03             	add    $0x3,%edx
c0101cc7:	0f b7 d2             	movzwl %dx,%edx
c0101cca:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101cce:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101cd1:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101cd5:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101cd9:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101cda:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cdd:	c1 e8 08             	shr    $0x8,%eax
c0101ce0:	0f b6 c0             	movzbl %al,%eax
c0101ce3:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ce7:	83 c2 04             	add    $0x4,%edx
c0101cea:	0f b7 d2             	movzwl %dx,%edx
c0101ced:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101cf1:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101cf4:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101cf8:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101cfc:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d00:	c1 e8 10             	shr    $0x10,%eax
c0101d03:	0f b6 c0             	movzbl %al,%eax
c0101d06:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d0a:	83 c2 05             	add    $0x5,%edx
c0101d0d:	0f b7 d2             	movzwl %dx,%edx
c0101d10:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101d14:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101d17:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101d1b:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101d1f:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101d20:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101d24:	83 e0 01             	and    $0x1,%eax
c0101d27:	c1 e0 04             	shl    $0x4,%eax
c0101d2a:	89 c2                	mov    %eax,%edx
c0101d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d2f:	c1 e8 18             	shr    $0x18,%eax
c0101d32:	83 e0 0f             	and    $0xf,%eax
c0101d35:	09 d0                	or     %edx,%eax
c0101d37:	83 c8 e0             	or     $0xffffffe0,%eax
c0101d3a:	0f b6 c0             	movzbl %al,%eax
c0101d3d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d41:	83 c2 06             	add    $0x6,%edx
c0101d44:	0f b7 d2             	movzwl %dx,%edx
c0101d47:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101d4b:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101d4e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101d52:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101d56:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101d57:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d5b:	83 c0 07             	add    $0x7,%eax
c0101d5e:	0f b7 c0             	movzwl %ax,%eax
c0101d61:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101d65:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101d69:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101d6d:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101d71:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101d72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101d79:	eb 5a                	jmp    c0101dd5 <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101d7b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d7f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101d86:	00 
c0101d87:	89 04 24             	mov    %eax,(%esp)
c0101d8a:	e8 23 fa ff ff       	call   c01017b2 <ide_wait_ready>
c0101d8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101d92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101d96:	74 02                	je     c0101d9a <ide_read_secs+0x1f7>
            goto out;
c0101d98:	eb 41                	jmp    c0101ddb <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101d9a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d9e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101da1:	8b 45 10             	mov    0x10(%ebp),%eax
c0101da4:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101da7:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101dae:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101db1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101db4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101db7:	89 cb                	mov    %ecx,%ebx
c0101db9:	89 df                	mov    %ebx,%edi
c0101dbb:	89 c1                	mov    %eax,%ecx
c0101dbd:	fc                   	cld    
c0101dbe:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101dc0:	89 c8                	mov    %ecx,%eax
c0101dc2:	89 fb                	mov    %edi,%ebx
c0101dc4:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101dc7:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101dca:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101dce:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101dd5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101dd9:	75 a0                	jne    c0101d7b <ide_read_secs+0x1d8>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101dde:	83 c4 50             	add    $0x50,%esp
c0101de1:	5b                   	pop    %ebx
c0101de2:	5f                   	pop    %edi
c0101de3:	5d                   	pop    %ebp
c0101de4:	c3                   	ret    

c0101de5 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101de5:	55                   	push   %ebp
c0101de6:	89 e5                	mov    %esp,%ebp
c0101de8:	56                   	push   %esi
c0101de9:	53                   	push   %ebx
c0101dea:	83 ec 50             	sub    $0x50,%esp
c0101ded:	8b 45 08             	mov    0x8(%ebp),%eax
c0101df0:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101df4:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101dfb:	77 24                	ja     c0101e21 <ide_write_secs+0x3c>
c0101dfd:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101e02:	77 1d                	ja     c0101e21 <ide_write_secs+0x3c>
c0101e04:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e08:	c1 e0 03             	shl    $0x3,%eax
c0101e0b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101e12:	29 c2                	sub    %eax,%edx
c0101e14:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101e1a:	0f b6 00             	movzbl (%eax),%eax
c0101e1d:	84 c0                	test   %al,%al
c0101e1f:	75 24                	jne    c0101e45 <ide_write_secs+0x60>
c0101e21:	c7 44 24 0c 78 c2 10 	movl   $0xc010c278,0xc(%esp)
c0101e28:	c0 
c0101e29:	c7 44 24 08 33 c2 10 	movl   $0xc010c233,0x8(%esp)
c0101e30:	c0 
c0101e31:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101e38:	00 
c0101e39:	c7 04 24 48 c2 10 c0 	movl   $0xc010c248,(%esp)
c0101e40:	e8 90 ef ff ff       	call   c0100dd5 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101e45:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101e4c:	77 0f                	ja     c0101e5d <ide_write_secs+0x78>
c0101e4e:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e51:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101e54:	01 d0                	add    %edx,%eax
c0101e56:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101e5b:	76 24                	jbe    c0101e81 <ide_write_secs+0x9c>
c0101e5d:	c7 44 24 0c a0 c2 10 	movl   $0xc010c2a0,0xc(%esp)
c0101e64:	c0 
c0101e65:	c7 44 24 08 33 c2 10 	movl   $0xc010c233,0x8(%esp)
c0101e6c:	c0 
c0101e6d:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101e74:	00 
c0101e75:	c7 04 24 48 c2 10 c0 	movl   $0xc010c248,(%esp)
c0101e7c:	e8 54 ef ff ff       	call   c0100dd5 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101e81:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e85:	66 d1 e8             	shr    %ax
c0101e88:	0f b7 c0             	movzwl %ax,%eax
c0101e8b:	0f b7 04 85 e8 c1 10 	movzwl -0x3fef3e18(,%eax,4),%eax
c0101e92:	c0 
c0101e93:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101e97:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e9b:	66 d1 e8             	shr    %ax
c0101e9e:	0f b7 c0             	movzwl %ax,%eax
c0101ea1:	0f b7 04 85 ea c1 10 	movzwl -0x3fef3e16(,%eax,4),%eax
c0101ea8:	c0 
c0101ea9:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101ead:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101eb1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101eb8:	00 
c0101eb9:	89 04 24             	mov    %eax,(%esp)
c0101ebc:	e8 f1 f8 ff ff       	call   c01017b2 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101ec1:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101ec5:	83 c0 02             	add    $0x2,%eax
c0101ec8:	0f b7 c0             	movzwl %ax,%eax
c0101ecb:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101ecf:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ed3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101ed7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101edb:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101edc:	8b 45 14             	mov    0x14(%ebp),%eax
c0101edf:	0f b6 c0             	movzbl %al,%eax
c0101ee2:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ee6:	83 c2 02             	add    $0x2,%edx
c0101ee9:	0f b7 d2             	movzwl %dx,%edx
c0101eec:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101ef0:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101ef3:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101ef7:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101efb:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101efc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101eff:	0f b6 c0             	movzbl %al,%eax
c0101f02:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f06:	83 c2 03             	add    $0x3,%edx
c0101f09:	0f b7 d2             	movzwl %dx,%edx
c0101f0c:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101f10:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101f13:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101f17:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101f1b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101f1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f1f:	c1 e8 08             	shr    $0x8,%eax
c0101f22:	0f b6 c0             	movzbl %al,%eax
c0101f25:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f29:	83 c2 04             	add    $0x4,%edx
c0101f2c:	0f b7 d2             	movzwl %dx,%edx
c0101f2f:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101f33:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101f36:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101f3a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101f3e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f42:	c1 e8 10             	shr    $0x10,%eax
c0101f45:	0f b6 c0             	movzbl %al,%eax
c0101f48:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f4c:	83 c2 05             	add    $0x5,%edx
c0101f4f:	0f b7 d2             	movzwl %dx,%edx
c0101f52:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101f56:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101f59:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101f5d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101f61:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101f62:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101f66:	83 e0 01             	and    $0x1,%eax
c0101f69:	c1 e0 04             	shl    $0x4,%eax
c0101f6c:	89 c2                	mov    %eax,%edx
c0101f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f71:	c1 e8 18             	shr    $0x18,%eax
c0101f74:	83 e0 0f             	and    $0xf,%eax
c0101f77:	09 d0                	or     %edx,%eax
c0101f79:	83 c8 e0             	or     $0xffffffe0,%eax
c0101f7c:	0f b6 c0             	movzbl %al,%eax
c0101f7f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f83:	83 c2 06             	add    $0x6,%edx
c0101f86:	0f b7 d2             	movzwl %dx,%edx
c0101f89:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101f8d:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101f90:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101f94:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101f98:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101f99:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f9d:	83 c0 07             	add    $0x7,%eax
c0101fa0:	0f b7 c0             	movzwl %ax,%eax
c0101fa3:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101fa7:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c0101fab:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101faf:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101fb3:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101fb4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101fbb:	eb 5a                	jmp    c0102017 <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101fbd:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101fc1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101fc8:	00 
c0101fc9:	89 04 24             	mov    %eax,(%esp)
c0101fcc:	e8 e1 f7 ff ff       	call   c01017b2 <ide_wait_ready>
c0101fd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101fd4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101fd8:	74 02                	je     c0101fdc <ide_write_secs+0x1f7>
            goto out;
c0101fda:	eb 41                	jmp    c010201d <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101fdc:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101fe0:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101fe3:	8b 45 10             	mov    0x10(%ebp),%eax
c0101fe6:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101fe9:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c0101ff0:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101ff3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101ff6:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101ff9:	89 cb                	mov    %ecx,%ebx
c0101ffb:	89 de                	mov    %ebx,%esi
c0101ffd:	89 c1                	mov    %eax,%ecx
c0101fff:	fc                   	cld    
c0102000:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0102002:	89 c8                	mov    %ecx,%eax
c0102004:	89 f3                	mov    %esi,%ebx
c0102006:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0102009:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010200c:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0102010:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0102017:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c010201b:	75 a0                	jne    c0101fbd <ide_write_secs+0x1d8>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c010201d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102020:	83 c4 50             	add    $0x50,%esp
c0102023:	5b                   	pop    %ebx
c0102024:	5e                   	pop    %esi
c0102025:	5d                   	pop    %ebp
c0102026:	c3                   	ret    

c0102027 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0102027:	55                   	push   %ebp
c0102028:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c010202a:	fb                   	sti    
    sti();
}
c010202b:	5d                   	pop    %ebp
c010202c:	c3                   	ret    

c010202d <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010202d:	55                   	push   %ebp
c010202e:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c0102030:	fa                   	cli    
    cli();
}
c0102031:	5d                   	pop    %ebp
c0102032:	c3                   	ret    

c0102033 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0102033:	55                   	push   %ebp
c0102034:	89 e5                	mov    %esp,%ebp
c0102036:	83 ec 14             	sub    $0x14,%esp
c0102039:	8b 45 08             	mov    0x8(%ebp),%eax
c010203c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0102040:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102044:	66 a3 70 a5 12 c0    	mov    %ax,0xc012a570
    if (did_init) {
c010204a:	a1 a0 c6 19 c0       	mov    0xc019c6a0,%eax
c010204f:	85 c0                	test   %eax,%eax
c0102051:	74 36                	je     c0102089 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0102053:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102057:	0f b6 c0             	movzbl %al,%eax
c010205a:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0102060:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102063:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102067:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010206b:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c010206c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102070:	66 c1 e8 08          	shr    $0x8,%ax
c0102074:	0f b6 c0             	movzbl %al,%eax
c0102077:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010207d:	88 45 f9             	mov    %al,-0x7(%ebp)
c0102080:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102084:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102088:	ee                   	out    %al,(%dx)
    }
}
c0102089:	c9                   	leave  
c010208a:	c3                   	ret    

c010208b <pic_enable>:

void
pic_enable(unsigned int irq) {
c010208b:	55                   	push   %ebp
c010208c:	89 e5                	mov    %esp,%ebp
c010208e:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0102091:	8b 45 08             	mov    0x8(%ebp),%eax
c0102094:	ba 01 00 00 00       	mov    $0x1,%edx
c0102099:	89 c1                	mov    %eax,%ecx
c010209b:	d3 e2                	shl    %cl,%edx
c010209d:	89 d0                	mov    %edx,%eax
c010209f:	f7 d0                	not    %eax
c01020a1:	89 c2                	mov    %eax,%edx
c01020a3:	0f b7 05 70 a5 12 c0 	movzwl 0xc012a570,%eax
c01020aa:	21 d0                	and    %edx,%eax
c01020ac:	0f b7 c0             	movzwl %ax,%eax
c01020af:	89 04 24             	mov    %eax,(%esp)
c01020b2:	e8 7c ff ff ff       	call   c0102033 <pic_setmask>
}
c01020b7:	c9                   	leave  
c01020b8:	c3                   	ret    

c01020b9 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01020b9:	55                   	push   %ebp
c01020ba:	89 e5                	mov    %esp,%ebp
c01020bc:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01020bf:	c7 05 a0 c6 19 c0 01 	movl   $0x1,0xc019c6a0
c01020c6:	00 00 00 
c01020c9:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01020cf:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c01020d3:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01020d7:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01020db:	ee                   	out    %al,(%dx)
c01020dc:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c01020e2:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c01020e6:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01020ea:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01020ee:	ee                   	out    %al,(%dx)
c01020ef:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01020f5:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c01020f9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01020fd:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102101:	ee                   	out    %al,(%dx)
c0102102:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c0102108:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c010210c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102110:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102114:	ee                   	out    %al,(%dx)
c0102115:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c010211b:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c010211f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102123:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102127:	ee                   	out    %al,(%dx)
c0102128:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c010212e:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c0102132:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102136:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010213a:	ee                   	out    %al,(%dx)
c010213b:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0102141:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c0102145:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102149:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010214d:	ee                   	out    %al,(%dx)
c010214e:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0102154:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c0102158:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010215c:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102160:	ee                   	out    %al,(%dx)
c0102161:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0102167:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c010216b:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010216f:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102173:	ee                   	out    %al,(%dx)
c0102174:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c010217a:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c010217e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102182:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0102186:	ee                   	out    %al,(%dx)
c0102187:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c010218d:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c0102191:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0102195:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0102199:	ee                   	out    %al,(%dx)
c010219a:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01021a0:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c01021a4:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01021a8:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01021ac:	ee                   	out    %al,(%dx)
c01021ad:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c01021b3:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c01021b7:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01021bb:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01021bf:	ee                   	out    %al,(%dx)
c01021c0:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01021c6:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01021ca:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01021ce:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01021d2:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01021d3:	0f b7 05 70 a5 12 c0 	movzwl 0xc012a570,%eax
c01021da:	66 83 f8 ff          	cmp    $0xffff,%ax
c01021de:	74 12                	je     c01021f2 <pic_init+0x139>
        pic_setmask(irq_mask);
c01021e0:	0f b7 05 70 a5 12 c0 	movzwl 0xc012a570,%eax
c01021e7:	0f b7 c0             	movzwl %ax,%eax
c01021ea:	89 04 24             	mov    %eax,(%esp)
c01021ed:	e8 41 fe ff ff       	call   c0102033 <pic_setmask>
    }
}
c01021f2:	c9                   	leave  
c01021f3:	c3                   	ret    

c01021f4 <print_ticks>:
#include <sched.h>
#include <sync.h>

#define TICK_NUM 100

static void print_ticks() {
c01021f4:	55                   	push   %ebp
c01021f5:	89 e5                	mov    %esp,%ebp
c01021f7:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01021fa:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102201:	00 
c0102202:	c7 04 24 e0 c2 10 c0 	movl   $0xc010c2e0,(%esp)
c0102209:	e8 45 e1 ff ff       	call   c0100353 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c010220e:	c7 04 24 ea c2 10 c0 	movl   $0xc010c2ea,(%esp)
c0102215:	e8 39 e1 ff ff       	call   c0100353 <cprintf>
    panic("EOT: kernel seems ok.");
c010221a:	c7 44 24 08 f8 c2 10 	movl   $0xc010c2f8,0x8(%esp)
c0102221:	c0 
c0102222:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0102229:	00 
c010222a:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c0102231:	e8 9f eb ff ff       	call   c0100dd5 <__panic>

c0102236 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102236:	55                   	push   %ebp
c0102237:	89 e5                	mov    %esp,%ebp
c0102239:	83 ec 10             	sub    $0x10,%esp
     /* LAB5 2012012617 */
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for(i = 0; i < 256; i++) {
c010223c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102243:	e9 c3 00 00 00       	jmp    c010230b <idt_init+0xd5>
        SETGATE(idt[i], 0, KERNEL_CS, __vectors[i], DPL_KERNEL);
c0102248:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010224b:	8b 04 85 00 a6 12 c0 	mov    -0x3fed5a00(,%eax,4),%eax
c0102252:	89 c2                	mov    %eax,%edx
c0102254:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102257:	66 89 14 c5 c0 c6 19 	mov    %dx,-0x3fe63940(,%eax,8)
c010225e:	c0 
c010225f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102262:	66 c7 04 c5 c2 c6 19 	movw   $0x8,-0x3fe6393e(,%eax,8)
c0102269:	c0 08 00 
c010226c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010226f:	0f b6 14 c5 c4 c6 19 	movzbl -0x3fe6393c(,%eax,8),%edx
c0102276:	c0 
c0102277:	83 e2 e0             	and    $0xffffffe0,%edx
c010227a:	88 14 c5 c4 c6 19 c0 	mov    %dl,-0x3fe6393c(,%eax,8)
c0102281:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102284:	0f b6 14 c5 c4 c6 19 	movzbl -0x3fe6393c(,%eax,8),%edx
c010228b:	c0 
c010228c:	83 e2 1f             	and    $0x1f,%edx
c010228f:	88 14 c5 c4 c6 19 c0 	mov    %dl,-0x3fe6393c(,%eax,8)
c0102296:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102299:	0f b6 14 c5 c5 c6 19 	movzbl -0x3fe6393b(,%eax,8),%edx
c01022a0:	c0 
c01022a1:	83 e2 f0             	and    $0xfffffff0,%edx
c01022a4:	83 ca 0e             	or     $0xe,%edx
c01022a7:	88 14 c5 c5 c6 19 c0 	mov    %dl,-0x3fe6393b(,%eax,8)
c01022ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022b1:	0f b6 14 c5 c5 c6 19 	movzbl -0x3fe6393b(,%eax,8),%edx
c01022b8:	c0 
c01022b9:	83 e2 ef             	and    $0xffffffef,%edx
c01022bc:	88 14 c5 c5 c6 19 c0 	mov    %dl,-0x3fe6393b(,%eax,8)
c01022c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022c6:	0f b6 14 c5 c5 c6 19 	movzbl -0x3fe6393b(,%eax,8),%edx
c01022cd:	c0 
c01022ce:	83 e2 9f             	and    $0xffffff9f,%edx
c01022d1:	88 14 c5 c5 c6 19 c0 	mov    %dl,-0x3fe6393b(,%eax,8)
c01022d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022db:	0f b6 14 c5 c5 c6 19 	movzbl -0x3fe6393b(,%eax,8),%edx
c01022e2:	c0 
c01022e3:	83 ca 80             	or     $0xffffff80,%edx
c01022e6:	88 14 c5 c5 c6 19 c0 	mov    %dl,-0x3fe6393b(,%eax,8)
c01022ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022f0:	8b 04 85 00 a6 12 c0 	mov    -0x3fed5a00(,%eax,4),%eax
c01022f7:	c1 e8 10             	shr    $0x10,%eax
c01022fa:	89 c2                	mov    %eax,%edx
c01022fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022ff:	66 89 14 c5 c6 c6 19 	mov    %dx,-0x3fe6393a(,%eax,8)
c0102306:	c0 
     /* LAB5 2012012617 */
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for(i = 0; i < 256; i++) {
c0102307:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010230b:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c0102312:	0f 8e 30 ff ff ff    	jle    c0102248 <idt_init+0x12>
        SETGATE(idt[i], 0, KERNEL_CS, __vectors[i], DPL_KERNEL);
    }
    SETGATE(idt[T_SYSCALL], 1, KERNEL_CS, __vectors[T_SYSCALL], DPL_USER);
c0102318:	a1 00 a8 12 c0       	mov    0xc012a800,%eax
c010231d:	66 a3 c0 ca 19 c0    	mov    %ax,0xc019cac0
c0102323:	66 c7 05 c2 ca 19 c0 	movw   $0x8,0xc019cac2
c010232a:	08 00 
c010232c:	0f b6 05 c4 ca 19 c0 	movzbl 0xc019cac4,%eax
c0102333:	83 e0 e0             	and    $0xffffffe0,%eax
c0102336:	a2 c4 ca 19 c0       	mov    %al,0xc019cac4
c010233b:	0f b6 05 c4 ca 19 c0 	movzbl 0xc019cac4,%eax
c0102342:	83 e0 1f             	and    $0x1f,%eax
c0102345:	a2 c4 ca 19 c0       	mov    %al,0xc019cac4
c010234a:	0f b6 05 c5 ca 19 c0 	movzbl 0xc019cac5,%eax
c0102351:	83 c8 0f             	or     $0xf,%eax
c0102354:	a2 c5 ca 19 c0       	mov    %al,0xc019cac5
c0102359:	0f b6 05 c5 ca 19 c0 	movzbl 0xc019cac5,%eax
c0102360:	83 e0 ef             	and    $0xffffffef,%eax
c0102363:	a2 c5 ca 19 c0       	mov    %al,0xc019cac5
c0102368:	0f b6 05 c5 ca 19 c0 	movzbl 0xc019cac5,%eax
c010236f:	83 c8 60             	or     $0x60,%eax
c0102372:	a2 c5 ca 19 c0       	mov    %al,0xc019cac5
c0102377:	0f b6 05 c5 ca 19 c0 	movzbl 0xc019cac5,%eax
c010237e:	83 c8 80             	or     $0xffffff80,%eax
c0102381:	a2 c5 ca 19 c0       	mov    %al,0xc019cac5
c0102386:	a1 00 a8 12 c0       	mov    0xc012a800,%eax
c010238b:	c1 e8 10             	shr    $0x10,%eax
c010238e:	66 a3 c6 ca 19 c0    	mov    %ax,0xc019cac6
c0102394:	c7 45 f8 80 a5 12 c0 	movl   $0xc012a580,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010239b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010239e:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
c01023a1:	c9                   	leave  
c01023a2:	c3                   	ret    

c01023a3 <trapname>:

static const char *
trapname(int trapno) {
c01023a3:	55                   	push   %ebp
c01023a4:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01023a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01023a9:	83 f8 13             	cmp    $0x13,%eax
c01023ac:	77 0c                	ja     c01023ba <trapname+0x17>
        return excnames[trapno];
c01023ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01023b1:	8b 04 85 80 c7 10 c0 	mov    -0x3fef3880(,%eax,4),%eax
c01023b8:	eb 18                	jmp    c01023d2 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01023ba:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01023be:	7e 0d                	jle    c01023cd <trapname+0x2a>
c01023c0:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01023c4:	7f 07                	jg     c01023cd <trapname+0x2a>
        return "Hardware Interrupt";
c01023c6:	b8 1f c3 10 c0       	mov    $0xc010c31f,%eax
c01023cb:	eb 05                	jmp    c01023d2 <trapname+0x2f>
    }
    return "(unknown trap)";
c01023cd:	b8 32 c3 10 c0       	mov    $0xc010c332,%eax
}
c01023d2:	5d                   	pop    %ebp
c01023d3:	c3                   	ret    

c01023d4 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01023d4:	55                   	push   %ebp
c01023d5:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01023d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01023da:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023de:	66 83 f8 08          	cmp    $0x8,%ax
c01023e2:	0f 94 c0             	sete   %al
c01023e5:	0f b6 c0             	movzbl %al,%eax
}
c01023e8:	5d                   	pop    %ebp
c01023e9:	c3                   	ret    

c01023ea <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01023ea:	55                   	push   %ebp
c01023eb:	89 e5                	mov    %esp,%ebp
c01023ed:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01023f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023f7:	c7 04 24 73 c3 10 c0 	movl   $0xc010c373,(%esp)
c01023fe:	e8 50 df ff ff       	call   c0100353 <cprintf>
    print_regs(&tf->tf_regs);
c0102403:	8b 45 08             	mov    0x8(%ebp),%eax
c0102406:	89 04 24             	mov    %eax,(%esp)
c0102409:	e8 a1 01 00 00       	call   c01025af <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c010240e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102411:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0102415:	0f b7 c0             	movzwl %ax,%eax
c0102418:	89 44 24 04          	mov    %eax,0x4(%esp)
c010241c:	c7 04 24 84 c3 10 c0 	movl   $0xc010c384,(%esp)
c0102423:	e8 2b df ff ff       	call   c0100353 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0102428:	8b 45 08             	mov    0x8(%ebp),%eax
c010242b:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c010242f:	0f b7 c0             	movzwl %ax,%eax
c0102432:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102436:	c7 04 24 97 c3 10 c0 	movl   $0xc010c397,(%esp)
c010243d:	e8 11 df ff ff       	call   c0100353 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102442:	8b 45 08             	mov    0x8(%ebp),%eax
c0102445:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102449:	0f b7 c0             	movzwl %ax,%eax
c010244c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102450:	c7 04 24 aa c3 10 c0 	movl   $0xc010c3aa,(%esp)
c0102457:	e8 f7 de ff ff       	call   c0100353 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010245c:	8b 45 08             	mov    0x8(%ebp),%eax
c010245f:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102463:	0f b7 c0             	movzwl %ax,%eax
c0102466:	89 44 24 04          	mov    %eax,0x4(%esp)
c010246a:	c7 04 24 bd c3 10 c0 	movl   $0xc010c3bd,(%esp)
c0102471:	e8 dd de ff ff       	call   c0100353 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102476:	8b 45 08             	mov    0x8(%ebp),%eax
c0102479:	8b 40 30             	mov    0x30(%eax),%eax
c010247c:	89 04 24             	mov    %eax,(%esp)
c010247f:	e8 1f ff ff ff       	call   c01023a3 <trapname>
c0102484:	8b 55 08             	mov    0x8(%ebp),%edx
c0102487:	8b 52 30             	mov    0x30(%edx),%edx
c010248a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010248e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102492:	c7 04 24 d0 c3 10 c0 	movl   $0xc010c3d0,(%esp)
c0102499:	e8 b5 de ff ff       	call   c0100353 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c010249e:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a1:	8b 40 34             	mov    0x34(%eax),%eax
c01024a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024a8:	c7 04 24 e2 c3 10 c0 	movl   $0xc010c3e2,(%esp)
c01024af:	e8 9f de ff ff       	call   c0100353 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01024b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01024b7:	8b 40 38             	mov    0x38(%eax),%eax
c01024ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024be:	c7 04 24 f1 c3 10 c0 	movl   $0xc010c3f1,(%esp)
c01024c5:	e8 89 de ff ff       	call   c0100353 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01024ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01024cd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01024d1:	0f b7 c0             	movzwl %ax,%eax
c01024d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024d8:	c7 04 24 00 c4 10 c0 	movl   $0xc010c400,(%esp)
c01024df:	e8 6f de ff ff       	call   c0100353 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01024e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01024e7:	8b 40 40             	mov    0x40(%eax),%eax
c01024ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ee:	c7 04 24 13 c4 10 c0 	movl   $0xc010c413,(%esp)
c01024f5:	e8 59 de ff ff       	call   c0100353 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01024fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102501:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102508:	eb 3e                	jmp    c0102548 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c010250a:	8b 45 08             	mov    0x8(%ebp),%eax
c010250d:	8b 50 40             	mov    0x40(%eax),%edx
c0102510:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102513:	21 d0                	and    %edx,%eax
c0102515:	85 c0                	test   %eax,%eax
c0102517:	74 28                	je     c0102541 <print_trapframe+0x157>
c0102519:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010251c:	8b 04 85 a0 a5 12 c0 	mov    -0x3fed5a60(,%eax,4),%eax
c0102523:	85 c0                	test   %eax,%eax
c0102525:	74 1a                	je     c0102541 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0102527:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010252a:	8b 04 85 a0 a5 12 c0 	mov    -0x3fed5a60(,%eax,4),%eax
c0102531:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102535:	c7 04 24 22 c4 10 c0 	movl   $0xc010c422,(%esp)
c010253c:	e8 12 de ff ff       	call   c0100353 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102541:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102545:	d1 65 f0             	shll   -0x10(%ebp)
c0102548:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010254b:	83 f8 17             	cmp    $0x17,%eax
c010254e:	76 ba                	jbe    c010250a <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102550:	8b 45 08             	mov    0x8(%ebp),%eax
c0102553:	8b 40 40             	mov    0x40(%eax),%eax
c0102556:	25 00 30 00 00       	and    $0x3000,%eax
c010255b:	c1 e8 0c             	shr    $0xc,%eax
c010255e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102562:	c7 04 24 26 c4 10 c0 	movl   $0xc010c426,(%esp)
c0102569:	e8 e5 dd ff ff       	call   c0100353 <cprintf>

    if (!trap_in_kernel(tf)) {
c010256e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102571:	89 04 24             	mov    %eax,(%esp)
c0102574:	e8 5b fe ff ff       	call   c01023d4 <trap_in_kernel>
c0102579:	85 c0                	test   %eax,%eax
c010257b:	75 30                	jne    c01025ad <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c010257d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102580:	8b 40 44             	mov    0x44(%eax),%eax
c0102583:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102587:	c7 04 24 2f c4 10 c0 	movl   $0xc010c42f,(%esp)
c010258e:	e8 c0 dd ff ff       	call   c0100353 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0102593:	8b 45 08             	mov    0x8(%ebp),%eax
c0102596:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010259a:	0f b7 c0             	movzwl %ax,%eax
c010259d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025a1:	c7 04 24 3e c4 10 c0 	movl   $0xc010c43e,(%esp)
c01025a8:	e8 a6 dd ff ff       	call   c0100353 <cprintf>
    }
}
c01025ad:	c9                   	leave  
c01025ae:	c3                   	ret    

c01025af <print_regs>:

void
print_regs(struct pushregs *regs) {
c01025af:	55                   	push   %ebp
c01025b0:	89 e5                	mov    %esp,%ebp
c01025b2:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01025b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01025b8:	8b 00                	mov    (%eax),%eax
c01025ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025be:	c7 04 24 51 c4 10 c0 	movl   $0xc010c451,(%esp)
c01025c5:	e8 89 dd ff ff       	call   c0100353 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01025ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01025cd:	8b 40 04             	mov    0x4(%eax),%eax
c01025d0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025d4:	c7 04 24 60 c4 10 c0 	movl   $0xc010c460,(%esp)
c01025db:	e8 73 dd ff ff       	call   c0100353 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01025e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e3:	8b 40 08             	mov    0x8(%eax),%eax
c01025e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025ea:	c7 04 24 6f c4 10 c0 	movl   $0xc010c46f,(%esp)
c01025f1:	e8 5d dd ff ff       	call   c0100353 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01025f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01025f9:	8b 40 0c             	mov    0xc(%eax),%eax
c01025fc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102600:	c7 04 24 7e c4 10 c0 	movl   $0xc010c47e,(%esp)
c0102607:	e8 47 dd ff ff       	call   c0100353 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c010260c:	8b 45 08             	mov    0x8(%ebp),%eax
c010260f:	8b 40 10             	mov    0x10(%eax),%eax
c0102612:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102616:	c7 04 24 8d c4 10 c0 	movl   $0xc010c48d,(%esp)
c010261d:	e8 31 dd ff ff       	call   c0100353 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0102622:	8b 45 08             	mov    0x8(%ebp),%eax
c0102625:	8b 40 14             	mov    0x14(%eax),%eax
c0102628:	89 44 24 04          	mov    %eax,0x4(%esp)
c010262c:	c7 04 24 9c c4 10 c0 	movl   $0xc010c49c,(%esp)
c0102633:	e8 1b dd ff ff       	call   c0100353 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102638:	8b 45 08             	mov    0x8(%ebp),%eax
c010263b:	8b 40 18             	mov    0x18(%eax),%eax
c010263e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102642:	c7 04 24 ab c4 10 c0 	movl   $0xc010c4ab,(%esp)
c0102649:	e8 05 dd ff ff       	call   c0100353 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c010264e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102651:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102654:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102658:	c7 04 24 ba c4 10 c0 	movl   $0xc010c4ba,(%esp)
c010265f:	e8 ef dc ff ff       	call   c0100353 <cprintf>
}
c0102664:	c9                   	leave  
c0102665:	c3                   	ret    

c0102666 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102666:	55                   	push   %ebp
c0102667:	89 e5                	mov    %esp,%ebp
c0102669:	53                   	push   %ebx
c010266a:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c010266d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102670:	8b 40 34             	mov    0x34(%eax),%eax
c0102673:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102676:	85 c0                	test   %eax,%eax
c0102678:	74 07                	je     c0102681 <print_pgfault+0x1b>
c010267a:	b9 c9 c4 10 c0       	mov    $0xc010c4c9,%ecx
c010267f:	eb 05                	jmp    c0102686 <print_pgfault+0x20>
c0102681:	b9 da c4 10 c0       	mov    $0xc010c4da,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c0102686:	8b 45 08             	mov    0x8(%ebp),%eax
c0102689:	8b 40 34             	mov    0x34(%eax),%eax
c010268c:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010268f:	85 c0                	test   %eax,%eax
c0102691:	74 07                	je     c010269a <print_pgfault+0x34>
c0102693:	ba 57 00 00 00       	mov    $0x57,%edx
c0102698:	eb 05                	jmp    c010269f <print_pgfault+0x39>
c010269a:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c010269f:	8b 45 08             	mov    0x8(%ebp),%eax
c01026a2:	8b 40 34             	mov    0x34(%eax),%eax
c01026a5:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026a8:	85 c0                	test   %eax,%eax
c01026aa:	74 07                	je     c01026b3 <print_pgfault+0x4d>
c01026ac:	b8 55 00 00 00       	mov    $0x55,%eax
c01026b1:	eb 05                	jmp    c01026b8 <print_pgfault+0x52>
c01026b3:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01026b8:	0f 20 d3             	mov    %cr2,%ebx
c01026bb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01026be:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01026c1:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01026c5:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01026c9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01026cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01026d1:	c7 04 24 e8 c4 10 c0 	movl   $0xc010c4e8,(%esp)
c01026d8:	e8 76 dc ff ff       	call   c0100353 <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c01026dd:	83 c4 34             	add    $0x34,%esp
c01026e0:	5b                   	pop    %ebx
c01026e1:	5d                   	pop    %ebp
c01026e2:	c3                   	ret    

c01026e3 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01026e3:	55                   	push   %ebp
c01026e4:	89 e5                	mov    %esp,%ebp
c01026e6:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
c01026e9:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c01026ee:	85 c0                	test   %eax,%eax
c01026f0:	74 0b                	je     c01026fd <pgfault_handler+0x1a>
            print_pgfault(tf);
c01026f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01026f5:	89 04 24             	mov    %eax,(%esp)
c01026f8:	e8 69 ff ff ff       	call   c0102666 <print_pgfault>
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
c01026fd:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c0102702:	85 c0                	test   %eax,%eax
c0102704:	74 3d                	je     c0102743 <pgfault_handler+0x60>
        assert(current == idleproc);
c0102706:	8b 15 88 cf 19 c0    	mov    0xc019cf88,%edx
c010270c:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c0102711:	39 c2                	cmp    %eax,%edx
c0102713:	74 24                	je     c0102739 <pgfault_handler+0x56>
c0102715:	c7 44 24 0c 0b c5 10 	movl   $0xc010c50b,0xc(%esp)
c010271c:	c0 
c010271d:	c7 44 24 08 1f c5 10 	movl   $0xc010c51f,0x8(%esp)
c0102724:	c0 
c0102725:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
c010272c:	00 
c010272d:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c0102734:	e8 9c e6 ff ff       	call   c0100dd5 <__panic>
        mm = check_mm_struct;
c0102739:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c010273e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102741:	eb 46                	jmp    c0102789 <pgfault_handler+0xa6>
    }
    else {
        if (current == NULL) {
c0102743:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102748:	85 c0                	test   %eax,%eax
c010274a:	75 32                	jne    c010277e <pgfault_handler+0x9b>
            print_trapframe(tf);
c010274c:	8b 45 08             	mov    0x8(%ebp),%eax
c010274f:	89 04 24             	mov    %eax,(%esp)
c0102752:	e8 93 fc ff ff       	call   c01023ea <print_trapframe>
            print_pgfault(tf);
c0102757:	8b 45 08             	mov    0x8(%ebp),%eax
c010275a:	89 04 24             	mov    %eax,(%esp)
c010275d:	e8 04 ff ff ff       	call   c0102666 <print_pgfault>
            panic("unhandled page fault.\n");
c0102762:	c7 44 24 08 34 c5 10 	movl   $0xc010c534,0x8(%esp)
c0102769:	c0 
c010276a:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0102771:	00 
c0102772:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c0102779:	e8 57 e6 ff ff       	call   c0100dd5 <__panic>
        }
        mm = current->mm;
c010277e:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102783:	8b 40 18             	mov    0x18(%eax),%eax
c0102786:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102789:	0f 20 d0             	mov    %cr2,%eax
c010278c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr2;
c010278f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
c0102792:	89 c2                	mov    %eax,%edx
c0102794:	8b 45 08             	mov    0x8(%ebp),%eax
c0102797:	8b 40 34             	mov    0x34(%eax),%eax
c010279a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010279e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01027a5:	89 04 24             	mov    %eax,(%esp)
c01027a8:	e8 fd 65 00 00       	call   c0108daa <do_pgfault>
}
c01027ad:	c9                   	leave  
c01027ae:	c3                   	ret    

c01027af <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01027af:	55                   	push   %ebp
c01027b0:	89 e5                	mov    %esp,%ebp
c01027b2:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret=0;
c01027b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    switch (tf->tf_trapno) {
c01027bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01027bf:	8b 40 30             	mov    0x30(%eax),%eax
c01027c2:	83 f8 2f             	cmp    $0x2f,%eax
c01027c5:	77 38                	ja     c01027ff <trap_dispatch+0x50>
c01027c7:	83 f8 2e             	cmp    $0x2e,%eax
c01027ca:	0f 83 fa 01 00 00    	jae    c01029ca <trap_dispatch+0x21b>
c01027d0:	83 f8 20             	cmp    $0x20,%eax
c01027d3:	0f 84 07 01 00 00    	je     c01028e0 <trap_dispatch+0x131>
c01027d9:	83 f8 20             	cmp    $0x20,%eax
c01027dc:	77 0a                	ja     c01027e8 <trap_dispatch+0x39>
c01027de:	83 f8 0e             	cmp    $0xe,%eax
c01027e1:	74 3e                	je     c0102821 <trap_dispatch+0x72>
c01027e3:	e9 9a 01 00 00       	jmp    c0102982 <trap_dispatch+0x1d3>
c01027e8:	83 f8 21             	cmp    $0x21,%eax
c01027eb:	0f 84 4f 01 00 00    	je     c0102940 <trap_dispatch+0x191>
c01027f1:	83 f8 24             	cmp    $0x24,%eax
c01027f4:	0f 84 1d 01 00 00    	je     c0102917 <trap_dispatch+0x168>
c01027fa:	e9 83 01 00 00       	jmp    c0102982 <trap_dispatch+0x1d3>
c01027ff:	83 f8 78             	cmp    $0x78,%eax
c0102802:	0f 82 7a 01 00 00    	jb     c0102982 <trap_dispatch+0x1d3>
c0102808:	83 f8 79             	cmp    $0x79,%eax
c010280b:	0f 86 55 01 00 00    	jbe    c0102966 <trap_dispatch+0x1b7>
c0102811:	3d 80 00 00 00       	cmp    $0x80,%eax
c0102816:	0f 84 ba 00 00 00    	je     c01028d6 <trap_dispatch+0x127>
c010281c:	e9 61 01 00 00       	jmp    c0102982 <trap_dispatch+0x1d3>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0102821:	8b 45 08             	mov    0x8(%ebp),%eax
c0102824:	89 04 24             	mov    %eax,(%esp)
c0102827:	e8 b7 fe ff ff       	call   c01026e3 <pgfault_handler>
c010282c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010282f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102833:	0f 84 98 00 00 00    	je     c01028d1 <trap_dispatch+0x122>
            print_trapframe(tf);
c0102839:	8b 45 08             	mov    0x8(%ebp),%eax
c010283c:	89 04 24             	mov    %eax,(%esp)
c010283f:	e8 a6 fb ff ff       	call   c01023ea <print_trapframe>
            if (current == NULL) {
c0102844:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102849:	85 c0                	test   %eax,%eax
c010284b:	75 23                	jne    c0102870 <trap_dispatch+0xc1>
                panic("handle pgfault failed. ret=%d\n", ret);
c010284d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102850:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102854:	c7 44 24 08 4c c5 10 	movl   $0xc010c54c,0x8(%esp)
c010285b:	c0 
c010285c:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0102863:	00 
c0102864:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c010286b:	e8 65 e5 ff ff       	call   c0100dd5 <__panic>
            }
            else {
                if (trap_in_kernel(tf)) {
c0102870:	8b 45 08             	mov    0x8(%ebp),%eax
c0102873:	89 04 24             	mov    %eax,(%esp)
c0102876:	e8 59 fb ff ff       	call   c01023d4 <trap_in_kernel>
c010287b:	85 c0                	test   %eax,%eax
c010287d:	74 23                	je     c01028a2 <trap_dispatch+0xf3>
                    panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
c010287f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102882:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102886:	c7 44 24 08 6c c5 10 	movl   $0xc010c56c,0x8(%esp)
c010288d:	c0 
c010288e:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0102895:	00 
c0102896:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c010289d:	e8 33 e5 ff ff       	call   c0100dd5 <__panic>
                }
                cprintf("killed by kernel.\n");
c01028a2:	c7 04 24 9a c5 10 c0 	movl   $0xc010c59a,(%esp)
c01028a9:	e8 a5 da ff ff       	call   c0100353 <cprintf>
                panic("handle user mode pgfault failed. ret=%d\n", ret); 
c01028ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028b5:	c7 44 24 08 b0 c5 10 	movl   $0xc010c5b0,0x8(%esp)
c01028bc:	c0 
c01028bd:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c01028c4:	00 
c01028c5:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c01028cc:	e8 04 e5 ff ff       	call   c0100dd5 <__panic>
                do_exit(-E_KILLED);
            }
        }
        break;
c01028d1:	e9 f5 00 00 00       	jmp    c01029cb <trap_dispatch+0x21c>
    case T_SYSCALL:
        syscall();
c01028d6:	e8 b4 88 00 00       	call   c010b18f <syscall>
        break;
c01028db:	e9 eb 00 00 00       	jmp    c01029cb <trap_dispatch+0x21c>
         */
        /* LAB5 2012012617 */
        /* you should upate you lab1 code (just add ONE or TWO lines of code):
         *    Every TICK_NUM cycle, you should set current process's current->need_resched = 1
         */
        ticks++;
c01028e0:	a1 b4 ef 19 c0       	mov    0xc019efb4,%eax
c01028e5:	83 c0 01             	add    $0x1,%eax
c01028e8:	a3 b4 ef 19 c0       	mov    %eax,0xc019efb4
        if(ticks == TICK_NUM) {
c01028ed:	a1 b4 ef 19 c0       	mov    0xc019efb4,%eax
c01028f2:	83 f8 64             	cmp    $0x64,%eax
c01028f5:	75 1b                	jne    c0102912 <trap_dispatch+0x163>
            ticks = 0;
c01028f7:	c7 05 b4 ef 19 c0 00 	movl   $0x0,0xc019efb4
c01028fe:	00 00 00 
            current->need_resched = 1;
c0102901:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102906:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
        }
        break;
c010290d:	e9 b9 00 00 00       	jmp    c01029cb <trap_dispatch+0x21c>
c0102912:	e9 b4 00 00 00       	jmp    c01029cb <trap_dispatch+0x21c>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102917:	e8 27 ee ff ff       	call   c0101743 <cons_getc>
c010291c:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c010291f:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102923:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102927:	89 54 24 08          	mov    %edx,0x8(%esp)
c010292b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010292f:	c7 04 24 d9 c5 10 c0 	movl   $0xc010c5d9,(%esp)
c0102936:	e8 18 da ff ff       	call   c0100353 <cprintf>
        break;
c010293b:	e9 8b 00 00 00       	jmp    c01029cb <trap_dispatch+0x21c>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0102940:	e8 fe ed ff ff       	call   c0101743 <cons_getc>
c0102945:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0102948:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c010294c:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102950:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102954:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102958:	c7 04 24 eb c5 10 c0 	movl   $0xc010c5eb,(%esp)
c010295f:	e8 ef d9 ff ff       	call   c0100353 <cprintf>
        break;
c0102964:	eb 65                	jmp    c01029cb <trap_dispatch+0x21c>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0102966:	c7 44 24 08 fa c5 10 	movl   $0xc010c5fa,0x8(%esp)
c010296d:	c0 
c010296e:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0102975:	00 
c0102976:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c010297d:	e8 53 e4 ff ff       	call   c0100dd5 <__panic>
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        print_trapframe(tf);
c0102982:	8b 45 08             	mov    0x8(%ebp),%eax
c0102985:	89 04 24             	mov    %eax,(%esp)
c0102988:	e8 5d fa ff ff       	call   c01023ea <print_trapframe>
        if (current != NULL) {
c010298d:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102992:	85 c0                	test   %eax,%eax
c0102994:	74 18                	je     c01029ae <trap_dispatch+0x1ff>
            cprintf("unhandled trap.\n");
c0102996:	c7 04 24 0a c6 10 c0 	movl   $0xc010c60a,(%esp)
c010299d:	e8 b1 d9 ff ff       	call   c0100353 <cprintf>
            do_exit(-E_KILLED);
c01029a2:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c01029a9:	e8 84 75 00 00       	call   c0109f32 <do_exit>
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");
c01029ae:	c7 44 24 08 1b c6 10 	movl   $0xc010c61b,0x8(%esp)
c01029b5:	c0 
c01029b6:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c01029bd:	00 
c01029be:	c7 04 24 0e c3 10 c0 	movl   $0xc010c30e,(%esp)
c01029c5:	e8 0b e4 ff ff       	call   c0100dd5 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c01029ca:	90                   	nop
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");

    }
}
c01029cb:	c9                   	leave  
c01029cc:	c3                   	ret    

c01029cd <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01029cd:	55                   	push   %ebp
c01029ce:	89 e5                	mov    %esp,%ebp
c01029d0:	83 ec 28             	sub    $0x28,%esp
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL) {
c01029d3:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c01029d8:	85 c0                	test   %eax,%eax
c01029da:	75 0d                	jne    c01029e9 <trap+0x1c>
        trap_dispatch(tf);
c01029dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01029df:	89 04 24             	mov    %eax,(%esp)
c01029e2:	e8 c8 fd ff ff       	call   c01027af <trap_dispatch>
c01029e7:	eb 6c                	jmp    c0102a55 <trap+0x88>
    }
    else {
        // keep a trapframe chain in stack
        struct trapframe *otf = current->tf;
c01029e9:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c01029ee:	8b 40 3c             	mov    0x3c(%eax),%eax
c01029f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        current->tf = tf;
c01029f4:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c01029f9:	8b 55 08             	mov    0x8(%ebp),%edx
c01029fc:	89 50 3c             	mov    %edx,0x3c(%eax)
    
        bool in_kernel = trap_in_kernel(tf);
c01029ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a02:	89 04 24             	mov    %eax,(%esp)
c0102a05:	e8 ca f9 ff ff       	call   c01023d4 <trap_in_kernel>
c0102a0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
        trap_dispatch(tf);
c0102a0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a10:	89 04 24             	mov    %eax,(%esp)
c0102a13:	e8 97 fd ff ff       	call   c01027af <trap_dispatch>
    
        current->tf = otf;
c0102a18:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102a1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102a20:	89 50 3c             	mov    %edx,0x3c(%eax)
        if (!in_kernel) {
c0102a23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102a27:	75 2c                	jne    c0102a55 <trap+0x88>
            if (current->flags & PF_EXITING) {
c0102a29:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102a2e:	8b 40 44             	mov    0x44(%eax),%eax
c0102a31:	83 e0 01             	and    $0x1,%eax
c0102a34:	85 c0                	test   %eax,%eax
c0102a36:	74 0c                	je     c0102a44 <trap+0x77>
                do_exit(-E_KILLED);
c0102a38:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102a3f:	e8 ee 74 00 00       	call   c0109f32 <do_exit>
            }
            if (current->need_resched) {
c0102a44:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102a49:	8b 40 10             	mov    0x10(%eax),%eax
c0102a4c:	85 c0                	test   %eax,%eax
c0102a4e:	74 05                	je     c0102a55 <trap+0x88>
                schedule();
c0102a50:	e8 42 85 00 00       	call   c010af97 <schedule>
            }
        }
    }
}
c0102a55:	c9                   	leave  
c0102a56:	c3                   	ret    

c0102a57 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102a57:	1e                   	push   %ds
    pushl %es
c0102a58:	06                   	push   %es
    pushl %fs
c0102a59:	0f a0                	push   %fs
    pushl %gs
c0102a5b:	0f a8                	push   %gs
    pushal
c0102a5d:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102a5e:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102a63:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102a65:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102a67:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102a68:	e8 60 ff ff ff       	call   c01029cd <trap>

    # pop the pushed stack pointer
    popl %esp
c0102a6d:	5c                   	pop    %esp

c0102a6e <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102a6e:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102a6f:	0f a9                	pop    %gs
    popl %fs
c0102a71:	0f a1                	pop    %fs
    popl %es
c0102a73:	07                   	pop    %es
    popl %ds
c0102a74:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102a75:	83 c4 08             	add    $0x8,%esp
    iret
c0102a78:	cf                   	iret   

c0102a79 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0102a79:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0102a7d:	e9 ec ff ff ff       	jmp    c0102a6e <__trapret>

c0102a82 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102a82:	6a 00                	push   $0x0
  pushl $0
c0102a84:	6a 00                	push   $0x0
  jmp __alltraps
c0102a86:	e9 cc ff ff ff       	jmp    c0102a57 <__alltraps>

c0102a8b <vector1>:
.globl vector1
vector1:
  pushl $0
c0102a8b:	6a 00                	push   $0x0
  pushl $1
c0102a8d:	6a 01                	push   $0x1
  jmp __alltraps
c0102a8f:	e9 c3 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102a94 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102a94:	6a 00                	push   $0x0
  pushl $2
c0102a96:	6a 02                	push   $0x2
  jmp __alltraps
c0102a98:	e9 ba ff ff ff       	jmp    c0102a57 <__alltraps>

c0102a9d <vector3>:
.globl vector3
vector3:
  pushl $0
c0102a9d:	6a 00                	push   $0x0
  pushl $3
c0102a9f:	6a 03                	push   $0x3
  jmp __alltraps
c0102aa1:	e9 b1 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102aa6 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102aa6:	6a 00                	push   $0x0
  pushl $4
c0102aa8:	6a 04                	push   $0x4
  jmp __alltraps
c0102aaa:	e9 a8 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102aaf <vector5>:
.globl vector5
vector5:
  pushl $0
c0102aaf:	6a 00                	push   $0x0
  pushl $5
c0102ab1:	6a 05                	push   $0x5
  jmp __alltraps
c0102ab3:	e9 9f ff ff ff       	jmp    c0102a57 <__alltraps>

c0102ab8 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102ab8:	6a 00                	push   $0x0
  pushl $6
c0102aba:	6a 06                	push   $0x6
  jmp __alltraps
c0102abc:	e9 96 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102ac1 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102ac1:	6a 00                	push   $0x0
  pushl $7
c0102ac3:	6a 07                	push   $0x7
  jmp __alltraps
c0102ac5:	e9 8d ff ff ff       	jmp    c0102a57 <__alltraps>

c0102aca <vector8>:
.globl vector8
vector8:
  pushl $8
c0102aca:	6a 08                	push   $0x8
  jmp __alltraps
c0102acc:	e9 86 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102ad1 <vector9>:
.globl vector9
vector9:
  pushl $9
c0102ad1:	6a 09                	push   $0x9
  jmp __alltraps
c0102ad3:	e9 7f ff ff ff       	jmp    c0102a57 <__alltraps>

c0102ad8 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102ad8:	6a 0a                	push   $0xa
  jmp __alltraps
c0102ada:	e9 78 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102adf <vector11>:
.globl vector11
vector11:
  pushl $11
c0102adf:	6a 0b                	push   $0xb
  jmp __alltraps
c0102ae1:	e9 71 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102ae6 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102ae6:	6a 0c                	push   $0xc
  jmp __alltraps
c0102ae8:	e9 6a ff ff ff       	jmp    c0102a57 <__alltraps>

c0102aed <vector13>:
.globl vector13
vector13:
  pushl $13
c0102aed:	6a 0d                	push   $0xd
  jmp __alltraps
c0102aef:	e9 63 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102af4 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102af4:	6a 0e                	push   $0xe
  jmp __alltraps
c0102af6:	e9 5c ff ff ff       	jmp    c0102a57 <__alltraps>

c0102afb <vector15>:
.globl vector15
vector15:
  pushl $0
c0102afb:	6a 00                	push   $0x0
  pushl $15
c0102afd:	6a 0f                	push   $0xf
  jmp __alltraps
c0102aff:	e9 53 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102b04 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102b04:	6a 00                	push   $0x0
  pushl $16
c0102b06:	6a 10                	push   $0x10
  jmp __alltraps
c0102b08:	e9 4a ff ff ff       	jmp    c0102a57 <__alltraps>

c0102b0d <vector17>:
.globl vector17
vector17:
  pushl $17
c0102b0d:	6a 11                	push   $0x11
  jmp __alltraps
c0102b0f:	e9 43 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102b14 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102b14:	6a 00                	push   $0x0
  pushl $18
c0102b16:	6a 12                	push   $0x12
  jmp __alltraps
c0102b18:	e9 3a ff ff ff       	jmp    c0102a57 <__alltraps>

c0102b1d <vector19>:
.globl vector19
vector19:
  pushl $0
c0102b1d:	6a 00                	push   $0x0
  pushl $19
c0102b1f:	6a 13                	push   $0x13
  jmp __alltraps
c0102b21:	e9 31 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102b26 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102b26:	6a 00                	push   $0x0
  pushl $20
c0102b28:	6a 14                	push   $0x14
  jmp __alltraps
c0102b2a:	e9 28 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102b2f <vector21>:
.globl vector21
vector21:
  pushl $0
c0102b2f:	6a 00                	push   $0x0
  pushl $21
c0102b31:	6a 15                	push   $0x15
  jmp __alltraps
c0102b33:	e9 1f ff ff ff       	jmp    c0102a57 <__alltraps>

c0102b38 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102b38:	6a 00                	push   $0x0
  pushl $22
c0102b3a:	6a 16                	push   $0x16
  jmp __alltraps
c0102b3c:	e9 16 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102b41 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102b41:	6a 00                	push   $0x0
  pushl $23
c0102b43:	6a 17                	push   $0x17
  jmp __alltraps
c0102b45:	e9 0d ff ff ff       	jmp    c0102a57 <__alltraps>

c0102b4a <vector24>:
.globl vector24
vector24:
  pushl $0
c0102b4a:	6a 00                	push   $0x0
  pushl $24
c0102b4c:	6a 18                	push   $0x18
  jmp __alltraps
c0102b4e:	e9 04 ff ff ff       	jmp    c0102a57 <__alltraps>

c0102b53 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102b53:	6a 00                	push   $0x0
  pushl $25
c0102b55:	6a 19                	push   $0x19
  jmp __alltraps
c0102b57:	e9 fb fe ff ff       	jmp    c0102a57 <__alltraps>

c0102b5c <vector26>:
.globl vector26
vector26:
  pushl $0
c0102b5c:	6a 00                	push   $0x0
  pushl $26
c0102b5e:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102b60:	e9 f2 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102b65 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102b65:	6a 00                	push   $0x0
  pushl $27
c0102b67:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102b69:	e9 e9 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102b6e <vector28>:
.globl vector28
vector28:
  pushl $0
c0102b6e:	6a 00                	push   $0x0
  pushl $28
c0102b70:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102b72:	e9 e0 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102b77 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102b77:	6a 00                	push   $0x0
  pushl $29
c0102b79:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102b7b:	e9 d7 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102b80 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102b80:	6a 00                	push   $0x0
  pushl $30
c0102b82:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102b84:	e9 ce fe ff ff       	jmp    c0102a57 <__alltraps>

c0102b89 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102b89:	6a 00                	push   $0x0
  pushl $31
c0102b8b:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102b8d:	e9 c5 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102b92 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102b92:	6a 00                	push   $0x0
  pushl $32
c0102b94:	6a 20                	push   $0x20
  jmp __alltraps
c0102b96:	e9 bc fe ff ff       	jmp    c0102a57 <__alltraps>

c0102b9b <vector33>:
.globl vector33
vector33:
  pushl $0
c0102b9b:	6a 00                	push   $0x0
  pushl $33
c0102b9d:	6a 21                	push   $0x21
  jmp __alltraps
c0102b9f:	e9 b3 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102ba4 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102ba4:	6a 00                	push   $0x0
  pushl $34
c0102ba6:	6a 22                	push   $0x22
  jmp __alltraps
c0102ba8:	e9 aa fe ff ff       	jmp    c0102a57 <__alltraps>

c0102bad <vector35>:
.globl vector35
vector35:
  pushl $0
c0102bad:	6a 00                	push   $0x0
  pushl $35
c0102baf:	6a 23                	push   $0x23
  jmp __alltraps
c0102bb1:	e9 a1 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102bb6 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102bb6:	6a 00                	push   $0x0
  pushl $36
c0102bb8:	6a 24                	push   $0x24
  jmp __alltraps
c0102bba:	e9 98 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102bbf <vector37>:
.globl vector37
vector37:
  pushl $0
c0102bbf:	6a 00                	push   $0x0
  pushl $37
c0102bc1:	6a 25                	push   $0x25
  jmp __alltraps
c0102bc3:	e9 8f fe ff ff       	jmp    c0102a57 <__alltraps>

c0102bc8 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102bc8:	6a 00                	push   $0x0
  pushl $38
c0102bca:	6a 26                	push   $0x26
  jmp __alltraps
c0102bcc:	e9 86 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102bd1 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102bd1:	6a 00                	push   $0x0
  pushl $39
c0102bd3:	6a 27                	push   $0x27
  jmp __alltraps
c0102bd5:	e9 7d fe ff ff       	jmp    c0102a57 <__alltraps>

c0102bda <vector40>:
.globl vector40
vector40:
  pushl $0
c0102bda:	6a 00                	push   $0x0
  pushl $40
c0102bdc:	6a 28                	push   $0x28
  jmp __alltraps
c0102bde:	e9 74 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102be3 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102be3:	6a 00                	push   $0x0
  pushl $41
c0102be5:	6a 29                	push   $0x29
  jmp __alltraps
c0102be7:	e9 6b fe ff ff       	jmp    c0102a57 <__alltraps>

c0102bec <vector42>:
.globl vector42
vector42:
  pushl $0
c0102bec:	6a 00                	push   $0x0
  pushl $42
c0102bee:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102bf0:	e9 62 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102bf5 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102bf5:	6a 00                	push   $0x0
  pushl $43
c0102bf7:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102bf9:	e9 59 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102bfe <vector44>:
.globl vector44
vector44:
  pushl $0
c0102bfe:	6a 00                	push   $0x0
  pushl $44
c0102c00:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102c02:	e9 50 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102c07 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102c07:	6a 00                	push   $0x0
  pushl $45
c0102c09:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102c0b:	e9 47 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102c10 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102c10:	6a 00                	push   $0x0
  pushl $46
c0102c12:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102c14:	e9 3e fe ff ff       	jmp    c0102a57 <__alltraps>

c0102c19 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102c19:	6a 00                	push   $0x0
  pushl $47
c0102c1b:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102c1d:	e9 35 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102c22 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102c22:	6a 00                	push   $0x0
  pushl $48
c0102c24:	6a 30                	push   $0x30
  jmp __alltraps
c0102c26:	e9 2c fe ff ff       	jmp    c0102a57 <__alltraps>

c0102c2b <vector49>:
.globl vector49
vector49:
  pushl $0
c0102c2b:	6a 00                	push   $0x0
  pushl $49
c0102c2d:	6a 31                	push   $0x31
  jmp __alltraps
c0102c2f:	e9 23 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102c34 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102c34:	6a 00                	push   $0x0
  pushl $50
c0102c36:	6a 32                	push   $0x32
  jmp __alltraps
c0102c38:	e9 1a fe ff ff       	jmp    c0102a57 <__alltraps>

c0102c3d <vector51>:
.globl vector51
vector51:
  pushl $0
c0102c3d:	6a 00                	push   $0x0
  pushl $51
c0102c3f:	6a 33                	push   $0x33
  jmp __alltraps
c0102c41:	e9 11 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102c46 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102c46:	6a 00                	push   $0x0
  pushl $52
c0102c48:	6a 34                	push   $0x34
  jmp __alltraps
c0102c4a:	e9 08 fe ff ff       	jmp    c0102a57 <__alltraps>

c0102c4f <vector53>:
.globl vector53
vector53:
  pushl $0
c0102c4f:	6a 00                	push   $0x0
  pushl $53
c0102c51:	6a 35                	push   $0x35
  jmp __alltraps
c0102c53:	e9 ff fd ff ff       	jmp    c0102a57 <__alltraps>

c0102c58 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102c58:	6a 00                	push   $0x0
  pushl $54
c0102c5a:	6a 36                	push   $0x36
  jmp __alltraps
c0102c5c:	e9 f6 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102c61 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102c61:	6a 00                	push   $0x0
  pushl $55
c0102c63:	6a 37                	push   $0x37
  jmp __alltraps
c0102c65:	e9 ed fd ff ff       	jmp    c0102a57 <__alltraps>

c0102c6a <vector56>:
.globl vector56
vector56:
  pushl $0
c0102c6a:	6a 00                	push   $0x0
  pushl $56
c0102c6c:	6a 38                	push   $0x38
  jmp __alltraps
c0102c6e:	e9 e4 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102c73 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102c73:	6a 00                	push   $0x0
  pushl $57
c0102c75:	6a 39                	push   $0x39
  jmp __alltraps
c0102c77:	e9 db fd ff ff       	jmp    c0102a57 <__alltraps>

c0102c7c <vector58>:
.globl vector58
vector58:
  pushl $0
c0102c7c:	6a 00                	push   $0x0
  pushl $58
c0102c7e:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102c80:	e9 d2 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102c85 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102c85:	6a 00                	push   $0x0
  pushl $59
c0102c87:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102c89:	e9 c9 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102c8e <vector60>:
.globl vector60
vector60:
  pushl $0
c0102c8e:	6a 00                	push   $0x0
  pushl $60
c0102c90:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102c92:	e9 c0 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102c97 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102c97:	6a 00                	push   $0x0
  pushl $61
c0102c99:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102c9b:	e9 b7 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102ca0 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102ca0:	6a 00                	push   $0x0
  pushl $62
c0102ca2:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102ca4:	e9 ae fd ff ff       	jmp    c0102a57 <__alltraps>

c0102ca9 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102ca9:	6a 00                	push   $0x0
  pushl $63
c0102cab:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102cad:	e9 a5 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102cb2 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102cb2:	6a 00                	push   $0x0
  pushl $64
c0102cb4:	6a 40                	push   $0x40
  jmp __alltraps
c0102cb6:	e9 9c fd ff ff       	jmp    c0102a57 <__alltraps>

c0102cbb <vector65>:
.globl vector65
vector65:
  pushl $0
c0102cbb:	6a 00                	push   $0x0
  pushl $65
c0102cbd:	6a 41                	push   $0x41
  jmp __alltraps
c0102cbf:	e9 93 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102cc4 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102cc4:	6a 00                	push   $0x0
  pushl $66
c0102cc6:	6a 42                	push   $0x42
  jmp __alltraps
c0102cc8:	e9 8a fd ff ff       	jmp    c0102a57 <__alltraps>

c0102ccd <vector67>:
.globl vector67
vector67:
  pushl $0
c0102ccd:	6a 00                	push   $0x0
  pushl $67
c0102ccf:	6a 43                	push   $0x43
  jmp __alltraps
c0102cd1:	e9 81 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102cd6 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102cd6:	6a 00                	push   $0x0
  pushl $68
c0102cd8:	6a 44                	push   $0x44
  jmp __alltraps
c0102cda:	e9 78 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102cdf <vector69>:
.globl vector69
vector69:
  pushl $0
c0102cdf:	6a 00                	push   $0x0
  pushl $69
c0102ce1:	6a 45                	push   $0x45
  jmp __alltraps
c0102ce3:	e9 6f fd ff ff       	jmp    c0102a57 <__alltraps>

c0102ce8 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102ce8:	6a 00                	push   $0x0
  pushl $70
c0102cea:	6a 46                	push   $0x46
  jmp __alltraps
c0102cec:	e9 66 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102cf1 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102cf1:	6a 00                	push   $0x0
  pushl $71
c0102cf3:	6a 47                	push   $0x47
  jmp __alltraps
c0102cf5:	e9 5d fd ff ff       	jmp    c0102a57 <__alltraps>

c0102cfa <vector72>:
.globl vector72
vector72:
  pushl $0
c0102cfa:	6a 00                	push   $0x0
  pushl $72
c0102cfc:	6a 48                	push   $0x48
  jmp __alltraps
c0102cfe:	e9 54 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102d03 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102d03:	6a 00                	push   $0x0
  pushl $73
c0102d05:	6a 49                	push   $0x49
  jmp __alltraps
c0102d07:	e9 4b fd ff ff       	jmp    c0102a57 <__alltraps>

c0102d0c <vector74>:
.globl vector74
vector74:
  pushl $0
c0102d0c:	6a 00                	push   $0x0
  pushl $74
c0102d0e:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102d10:	e9 42 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102d15 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102d15:	6a 00                	push   $0x0
  pushl $75
c0102d17:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102d19:	e9 39 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102d1e <vector76>:
.globl vector76
vector76:
  pushl $0
c0102d1e:	6a 00                	push   $0x0
  pushl $76
c0102d20:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102d22:	e9 30 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102d27 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102d27:	6a 00                	push   $0x0
  pushl $77
c0102d29:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102d2b:	e9 27 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102d30 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102d30:	6a 00                	push   $0x0
  pushl $78
c0102d32:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102d34:	e9 1e fd ff ff       	jmp    c0102a57 <__alltraps>

c0102d39 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102d39:	6a 00                	push   $0x0
  pushl $79
c0102d3b:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102d3d:	e9 15 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102d42 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102d42:	6a 00                	push   $0x0
  pushl $80
c0102d44:	6a 50                	push   $0x50
  jmp __alltraps
c0102d46:	e9 0c fd ff ff       	jmp    c0102a57 <__alltraps>

c0102d4b <vector81>:
.globl vector81
vector81:
  pushl $0
c0102d4b:	6a 00                	push   $0x0
  pushl $81
c0102d4d:	6a 51                	push   $0x51
  jmp __alltraps
c0102d4f:	e9 03 fd ff ff       	jmp    c0102a57 <__alltraps>

c0102d54 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102d54:	6a 00                	push   $0x0
  pushl $82
c0102d56:	6a 52                	push   $0x52
  jmp __alltraps
c0102d58:	e9 fa fc ff ff       	jmp    c0102a57 <__alltraps>

c0102d5d <vector83>:
.globl vector83
vector83:
  pushl $0
c0102d5d:	6a 00                	push   $0x0
  pushl $83
c0102d5f:	6a 53                	push   $0x53
  jmp __alltraps
c0102d61:	e9 f1 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102d66 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102d66:	6a 00                	push   $0x0
  pushl $84
c0102d68:	6a 54                	push   $0x54
  jmp __alltraps
c0102d6a:	e9 e8 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102d6f <vector85>:
.globl vector85
vector85:
  pushl $0
c0102d6f:	6a 00                	push   $0x0
  pushl $85
c0102d71:	6a 55                	push   $0x55
  jmp __alltraps
c0102d73:	e9 df fc ff ff       	jmp    c0102a57 <__alltraps>

c0102d78 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102d78:	6a 00                	push   $0x0
  pushl $86
c0102d7a:	6a 56                	push   $0x56
  jmp __alltraps
c0102d7c:	e9 d6 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102d81 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102d81:	6a 00                	push   $0x0
  pushl $87
c0102d83:	6a 57                	push   $0x57
  jmp __alltraps
c0102d85:	e9 cd fc ff ff       	jmp    c0102a57 <__alltraps>

c0102d8a <vector88>:
.globl vector88
vector88:
  pushl $0
c0102d8a:	6a 00                	push   $0x0
  pushl $88
c0102d8c:	6a 58                	push   $0x58
  jmp __alltraps
c0102d8e:	e9 c4 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102d93 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102d93:	6a 00                	push   $0x0
  pushl $89
c0102d95:	6a 59                	push   $0x59
  jmp __alltraps
c0102d97:	e9 bb fc ff ff       	jmp    c0102a57 <__alltraps>

c0102d9c <vector90>:
.globl vector90
vector90:
  pushl $0
c0102d9c:	6a 00                	push   $0x0
  pushl $90
c0102d9e:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102da0:	e9 b2 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102da5 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102da5:	6a 00                	push   $0x0
  pushl $91
c0102da7:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102da9:	e9 a9 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102dae <vector92>:
.globl vector92
vector92:
  pushl $0
c0102dae:	6a 00                	push   $0x0
  pushl $92
c0102db0:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102db2:	e9 a0 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102db7 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102db7:	6a 00                	push   $0x0
  pushl $93
c0102db9:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102dbb:	e9 97 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102dc0 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102dc0:	6a 00                	push   $0x0
  pushl $94
c0102dc2:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102dc4:	e9 8e fc ff ff       	jmp    c0102a57 <__alltraps>

c0102dc9 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102dc9:	6a 00                	push   $0x0
  pushl $95
c0102dcb:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102dcd:	e9 85 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102dd2 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102dd2:	6a 00                	push   $0x0
  pushl $96
c0102dd4:	6a 60                	push   $0x60
  jmp __alltraps
c0102dd6:	e9 7c fc ff ff       	jmp    c0102a57 <__alltraps>

c0102ddb <vector97>:
.globl vector97
vector97:
  pushl $0
c0102ddb:	6a 00                	push   $0x0
  pushl $97
c0102ddd:	6a 61                	push   $0x61
  jmp __alltraps
c0102ddf:	e9 73 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102de4 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102de4:	6a 00                	push   $0x0
  pushl $98
c0102de6:	6a 62                	push   $0x62
  jmp __alltraps
c0102de8:	e9 6a fc ff ff       	jmp    c0102a57 <__alltraps>

c0102ded <vector99>:
.globl vector99
vector99:
  pushl $0
c0102ded:	6a 00                	push   $0x0
  pushl $99
c0102def:	6a 63                	push   $0x63
  jmp __alltraps
c0102df1:	e9 61 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102df6 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102df6:	6a 00                	push   $0x0
  pushl $100
c0102df8:	6a 64                	push   $0x64
  jmp __alltraps
c0102dfa:	e9 58 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102dff <vector101>:
.globl vector101
vector101:
  pushl $0
c0102dff:	6a 00                	push   $0x0
  pushl $101
c0102e01:	6a 65                	push   $0x65
  jmp __alltraps
c0102e03:	e9 4f fc ff ff       	jmp    c0102a57 <__alltraps>

c0102e08 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102e08:	6a 00                	push   $0x0
  pushl $102
c0102e0a:	6a 66                	push   $0x66
  jmp __alltraps
c0102e0c:	e9 46 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102e11 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102e11:	6a 00                	push   $0x0
  pushl $103
c0102e13:	6a 67                	push   $0x67
  jmp __alltraps
c0102e15:	e9 3d fc ff ff       	jmp    c0102a57 <__alltraps>

c0102e1a <vector104>:
.globl vector104
vector104:
  pushl $0
c0102e1a:	6a 00                	push   $0x0
  pushl $104
c0102e1c:	6a 68                	push   $0x68
  jmp __alltraps
c0102e1e:	e9 34 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102e23 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102e23:	6a 00                	push   $0x0
  pushl $105
c0102e25:	6a 69                	push   $0x69
  jmp __alltraps
c0102e27:	e9 2b fc ff ff       	jmp    c0102a57 <__alltraps>

c0102e2c <vector106>:
.globl vector106
vector106:
  pushl $0
c0102e2c:	6a 00                	push   $0x0
  pushl $106
c0102e2e:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102e30:	e9 22 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102e35 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102e35:	6a 00                	push   $0x0
  pushl $107
c0102e37:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102e39:	e9 19 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102e3e <vector108>:
.globl vector108
vector108:
  pushl $0
c0102e3e:	6a 00                	push   $0x0
  pushl $108
c0102e40:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102e42:	e9 10 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102e47 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102e47:	6a 00                	push   $0x0
  pushl $109
c0102e49:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102e4b:	e9 07 fc ff ff       	jmp    c0102a57 <__alltraps>

c0102e50 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102e50:	6a 00                	push   $0x0
  pushl $110
c0102e52:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102e54:	e9 fe fb ff ff       	jmp    c0102a57 <__alltraps>

c0102e59 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102e59:	6a 00                	push   $0x0
  pushl $111
c0102e5b:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102e5d:	e9 f5 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102e62 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102e62:	6a 00                	push   $0x0
  pushl $112
c0102e64:	6a 70                	push   $0x70
  jmp __alltraps
c0102e66:	e9 ec fb ff ff       	jmp    c0102a57 <__alltraps>

c0102e6b <vector113>:
.globl vector113
vector113:
  pushl $0
c0102e6b:	6a 00                	push   $0x0
  pushl $113
c0102e6d:	6a 71                	push   $0x71
  jmp __alltraps
c0102e6f:	e9 e3 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102e74 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102e74:	6a 00                	push   $0x0
  pushl $114
c0102e76:	6a 72                	push   $0x72
  jmp __alltraps
c0102e78:	e9 da fb ff ff       	jmp    c0102a57 <__alltraps>

c0102e7d <vector115>:
.globl vector115
vector115:
  pushl $0
c0102e7d:	6a 00                	push   $0x0
  pushl $115
c0102e7f:	6a 73                	push   $0x73
  jmp __alltraps
c0102e81:	e9 d1 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102e86 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102e86:	6a 00                	push   $0x0
  pushl $116
c0102e88:	6a 74                	push   $0x74
  jmp __alltraps
c0102e8a:	e9 c8 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102e8f <vector117>:
.globl vector117
vector117:
  pushl $0
c0102e8f:	6a 00                	push   $0x0
  pushl $117
c0102e91:	6a 75                	push   $0x75
  jmp __alltraps
c0102e93:	e9 bf fb ff ff       	jmp    c0102a57 <__alltraps>

c0102e98 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102e98:	6a 00                	push   $0x0
  pushl $118
c0102e9a:	6a 76                	push   $0x76
  jmp __alltraps
c0102e9c:	e9 b6 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102ea1 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102ea1:	6a 00                	push   $0x0
  pushl $119
c0102ea3:	6a 77                	push   $0x77
  jmp __alltraps
c0102ea5:	e9 ad fb ff ff       	jmp    c0102a57 <__alltraps>

c0102eaa <vector120>:
.globl vector120
vector120:
  pushl $0
c0102eaa:	6a 00                	push   $0x0
  pushl $120
c0102eac:	6a 78                	push   $0x78
  jmp __alltraps
c0102eae:	e9 a4 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102eb3 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102eb3:	6a 00                	push   $0x0
  pushl $121
c0102eb5:	6a 79                	push   $0x79
  jmp __alltraps
c0102eb7:	e9 9b fb ff ff       	jmp    c0102a57 <__alltraps>

c0102ebc <vector122>:
.globl vector122
vector122:
  pushl $0
c0102ebc:	6a 00                	push   $0x0
  pushl $122
c0102ebe:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102ec0:	e9 92 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102ec5 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102ec5:	6a 00                	push   $0x0
  pushl $123
c0102ec7:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102ec9:	e9 89 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102ece <vector124>:
.globl vector124
vector124:
  pushl $0
c0102ece:	6a 00                	push   $0x0
  pushl $124
c0102ed0:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102ed2:	e9 80 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102ed7 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102ed7:	6a 00                	push   $0x0
  pushl $125
c0102ed9:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102edb:	e9 77 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102ee0 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102ee0:	6a 00                	push   $0x0
  pushl $126
c0102ee2:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102ee4:	e9 6e fb ff ff       	jmp    c0102a57 <__alltraps>

c0102ee9 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102ee9:	6a 00                	push   $0x0
  pushl $127
c0102eeb:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102eed:	e9 65 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102ef2 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102ef2:	6a 00                	push   $0x0
  pushl $128
c0102ef4:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102ef9:	e9 59 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102efe <vector129>:
.globl vector129
vector129:
  pushl $0
c0102efe:	6a 00                	push   $0x0
  pushl $129
c0102f00:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102f05:	e9 4d fb ff ff       	jmp    c0102a57 <__alltraps>

c0102f0a <vector130>:
.globl vector130
vector130:
  pushl $0
c0102f0a:	6a 00                	push   $0x0
  pushl $130
c0102f0c:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102f11:	e9 41 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102f16 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102f16:	6a 00                	push   $0x0
  pushl $131
c0102f18:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102f1d:	e9 35 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102f22 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102f22:	6a 00                	push   $0x0
  pushl $132
c0102f24:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102f29:	e9 29 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102f2e <vector133>:
.globl vector133
vector133:
  pushl $0
c0102f2e:	6a 00                	push   $0x0
  pushl $133
c0102f30:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102f35:	e9 1d fb ff ff       	jmp    c0102a57 <__alltraps>

c0102f3a <vector134>:
.globl vector134
vector134:
  pushl $0
c0102f3a:	6a 00                	push   $0x0
  pushl $134
c0102f3c:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102f41:	e9 11 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102f46 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102f46:	6a 00                	push   $0x0
  pushl $135
c0102f48:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102f4d:	e9 05 fb ff ff       	jmp    c0102a57 <__alltraps>

c0102f52 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102f52:	6a 00                	push   $0x0
  pushl $136
c0102f54:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102f59:	e9 f9 fa ff ff       	jmp    c0102a57 <__alltraps>

c0102f5e <vector137>:
.globl vector137
vector137:
  pushl $0
c0102f5e:	6a 00                	push   $0x0
  pushl $137
c0102f60:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102f65:	e9 ed fa ff ff       	jmp    c0102a57 <__alltraps>

c0102f6a <vector138>:
.globl vector138
vector138:
  pushl $0
c0102f6a:	6a 00                	push   $0x0
  pushl $138
c0102f6c:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102f71:	e9 e1 fa ff ff       	jmp    c0102a57 <__alltraps>

c0102f76 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102f76:	6a 00                	push   $0x0
  pushl $139
c0102f78:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102f7d:	e9 d5 fa ff ff       	jmp    c0102a57 <__alltraps>

c0102f82 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102f82:	6a 00                	push   $0x0
  pushl $140
c0102f84:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102f89:	e9 c9 fa ff ff       	jmp    c0102a57 <__alltraps>

c0102f8e <vector141>:
.globl vector141
vector141:
  pushl $0
c0102f8e:	6a 00                	push   $0x0
  pushl $141
c0102f90:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102f95:	e9 bd fa ff ff       	jmp    c0102a57 <__alltraps>

c0102f9a <vector142>:
.globl vector142
vector142:
  pushl $0
c0102f9a:	6a 00                	push   $0x0
  pushl $142
c0102f9c:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102fa1:	e9 b1 fa ff ff       	jmp    c0102a57 <__alltraps>

c0102fa6 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102fa6:	6a 00                	push   $0x0
  pushl $143
c0102fa8:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102fad:	e9 a5 fa ff ff       	jmp    c0102a57 <__alltraps>

c0102fb2 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102fb2:	6a 00                	push   $0x0
  pushl $144
c0102fb4:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102fb9:	e9 99 fa ff ff       	jmp    c0102a57 <__alltraps>

c0102fbe <vector145>:
.globl vector145
vector145:
  pushl $0
c0102fbe:	6a 00                	push   $0x0
  pushl $145
c0102fc0:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102fc5:	e9 8d fa ff ff       	jmp    c0102a57 <__alltraps>

c0102fca <vector146>:
.globl vector146
vector146:
  pushl $0
c0102fca:	6a 00                	push   $0x0
  pushl $146
c0102fcc:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102fd1:	e9 81 fa ff ff       	jmp    c0102a57 <__alltraps>

c0102fd6 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102fd6:	6a 00                	push   $0x0
  pushl $147
c0102fd8:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102fdd:	e9 75 fa ff ff       	jmp    c0102a57 <__alltraps>

c0102fe2 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102fe2:	6a 00                	push   $0x0
  pushl $148
c0102fe4:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102fe9:	e9 69 fa ff ff       	jmp    c0102a57 <__alltraps>

c0102fee <vector149>:
.globl vector149
vector149:
  pushl $0
c0102fee:	6a 00                	push   $0x0
  pushl $149
c0102ff0:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102ff5:	e9 5d fa ff ff       	jmp    c0102a57 <__alltraps>

c0102ffa <vector150>:
.globl vector150
vector150:
  pushl $0
c0102ffa:	6a 00                	push   $0x0
  pushl $150
c0102ffc:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0103001:	e9 51 fa ff ff       	jmp    c0102a57 <__alltraps>

c0103006 <vector151>:
.globl vector151
vector151:
  pushl $0
c0103006:	6a 00                	push   $0x0
  pushl $151
c0103008:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c010300d:	e9 45 fa ff ff       	jmp    c0102a57 <__alltraps>

c0103012 <vector152>:
.globl vector152
vector152:
  pushl $0
c0103012:	6a 00                	push   $0x0
  pushl $152
c0103014:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0103019:	e9 39 fa ff ff       	jmp    c0102a57 <__alltraps>

c010301e <vector153>:
.globl vector153
vector153:
  pushl $0
c010301e:	6a 00                	push   $0x0
  pushl $153
c0103020:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0103025:	e9 2d fa ff ff       	jmp    c0102a57 <__alltraps>

c010302a <vector154>:
.globl vector154
vector154:
  pushl $0
c010302a:	6a 00                	push   $0x0
  pushl $154
c010302c:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0103031:	e9 21 fa ff ff       	jmp    c0102a57 <__alltraps>

c0103036 <vector155>:
.globl vector155
vector155:
  pushl $0
c0103036:	6a 00                	push   $0x0
  pushl $155
c0103038:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c010303d:	e9 15 fa ff ff       	jmp    c0102a57 <__alltraps>

c0103042 <vector156>:
.globl vector156
vector156:
  pushl $0
c0103042:	6a 00                	push   $0x0
  pushl $156
c0103044:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0103049:	e9 09 fa ff ff       	jmp    c0102a57 <__alltraps>

c010304e <vector157>:
.globl vector157
vector157:
  pushl $0
c010304e:	6a 00                	push   $0x0
  pushl $157
c0103050:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0103055:	e9 fd f9 ff ff       	jmp    c0102a57 <__alltraps>

c010305a <vector158>:
.globl vector158
vector158:
  pushl $0
c010305a:	6a 00                	push   $0x0
  pushl $158
c010305c:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0103061:	e9 f1 f9 ff ff       	jmp    c0102a57 <__alltraps>

c0103066 <vector159>:
.globl vector159
vector159:
  pushl $0
c0103066:	6a 00                	push   $0x0
  pushl $159
c0103068:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010306d:	e9 e5 f9 ff ff       	jmp    c0102a57 <__alltraps>

c0103072 <vector160>:
.globl vector160
vector160:
  pushl $0
c0103072:	6a 00                	push   $0x0
  pushl $160
c0103074:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0103079:	e9 d9 f9 ff ff       	jmp    c0102a57 <__alltraps>

c010307e <vector161>:
.globl vector161
vector161:
  pushl $0
c010307e:	6a 00                	push   $0x0
  pushl $161
c0103080:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0103085:	e9 cd f9 ff ff       	jmp    c0102a57 <__alltraps>

c010308a <vector162>:
.globl vector162
vector162:
  pushl $0
c010308a:	6a 00                	push   $0x0
  pushl $162
c010308c:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0103091:	e9 c1 f9 ff ff       	jmp    c0102a57 <__alltraps>

c0103096 <vector163>:
.globl vector163
vector163:
  pushl $0
c0103096:	6a 00                	push   $0x0
  pushl $163
c0103098:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c010309d:	e9 b5 f9 ff ff       	jmp    c0102a57 <__alltraps>

c01030a2 <vector164>:
.globl vector164
vector164:
  pushl $0
c01030a2:	6a 00                	push   $0x0
  pushl $164
c01030a4:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01030a9:	e9 a9 f9 ff ff       	jmp    c0102a57 <__alltraps>

c01030ae <vector165>:
.globl vector165
vector165:
  pushl $0
c01030ae:	6a 00                	push   $0x0
  pushl $165
c01030b0:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01030b5:	e9 9d f9 ff ff       	jmp    c0102a57 <__alltraps>

c01030ba <vector166>:
.globl vector166
vector166:
  pushl $0
c01030ba:	6a 00                	push   $0x0
  pushl $166
c01030bc:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01030c1:	e9 91 f9 ff ff       	jmp    c0102a57 <__alltraps>

c01030c6 <vector167>:
.globl vector167
vector167:
  pushl $0
c01030c6:	6a 00                	push   $0x0
  pushl $167
c01030c8:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01030cd:	e9 85 f9 ff ff       	jmp    c0102a57 <__alltraps>

c01030d2 <vector168>:
.globl vector168
vector168:
  pushl $0
c01030d2:	6a 00                	push   $0x0
  pushl $168
c01030d4:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01030d9:	e9 79 f9 ff ff       	jmp    c0102a57 <__alltraps>

c01030de <vector169>:
.globl vector169
vector169:
  pushl $0
c01030de:	6a 00                	push   $0x0
  pushl $169
c01030e0:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01030e5:	e9 6d f9 ff ff       	jmp    c0102a57 <__alltraps>

c01030ea <vector170>:
.globl vector170
vector170:
  pushl $0
c01030ea:	6a 00                	push   $0x0
  pushl $170
c01030ec:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01030f1:	e9 61 f9 ff ff       	jmp    c0102a57 <__alltraps>

c01030f6 <vector171>:
.globl vector171
vector171:
  pushl $0
c01030f6:	6a 00                	push   $0x0
  pushl $171
c01030f8:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01030fd:	e9 55 f9 ff ff       	jmp    c0102a57 <__alltraps>

c0103102 <vector172>:
.globl vector172
vector172:
  pushl $0
c0103102:	6a 00                	push   $0x0
  pushl $172
c0103104:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0103109:	e9 49 f9 ff ff       	jmp    c0102a57 <__alltraps>

c010310e <vector173>:
.globl vector173
vector173:
  pushl $0
c010310e:	6a 00                	push   $0x0
  pushl $173
c0103110:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0103115:	e9 3d f9 ff ff       	jmp    c0102a57 <__alltraps>

c010311a <vector174>:
.globl vector174
vector174:
  pushl $0
c010311a:	6a 00                	push   $0x0
  pushl $174
c010311c:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0103121:	e9 31 f9 ff ff       	jmp    c0102a57 <__alltraps>

c0103126 <vector175>:
.globl vector175
vector175:
  pushl $0
c0103126:	6a 00                	push   $0x0
  pushl $175
c0103128:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c010312d:	e9 25 f9 ff ff       	jmp    c0102a57 <__alltraps>

c0103132 <vector176>:
.globl vector176
vector176:
  pushl $0
c0103132:	6a 00                	push   $0x0
  pushl $176
c0103134:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0103139:	e9 19 f9 ff ff       	jmp    c0102a57 <__alltraps>

c010313e <vector177>:
.globl vector177
vector177:
  pushl $0
c010313e:	6a 00                	push   $0x0
  pushl $177
c0103140:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0103145:	e9 0d f9 ff ff       	jmp    c0102a57 <__alltraps>

c010314a <vector178>:
.globl vector178
vector178:
  pushl $0
c010314a:	6a 00                	push   $0x0
  pushl $178
c010314c:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0103151:	e9 01 f9 ff ff       	jmp    c0102a57 <__alltraps>

c0103156 <vector179>:
.globl vector179
vector179:
  pushl $0
c0103156:	6a 00                	push   $0x0
  pushl $179
c0103158:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c010315d:	e9 f5 f8 ff ff       	jmp    c0102a57 <__alltraps>

c0103162 <vector180>:
.globl vector180
vector180:
  pushl $0
c0103162:	6a 00                	push   $0x0
  pushl $180
c0103164:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0103169:	e9 e9 f8 ff ff       	jmp    c0102a57 <__alltraps>

c010316e <vector181>:
.globl vector181
vector181:
  pushl $0
c010316e:	6a 00                	push   $0x0
  pushl $181
c0103170:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0103175:	e9 dd f8 ff ff       	jmp    c0102a57 <__alltraps>

c010317a <vector182>:
.globl vector182
vector182:
  pushl $0
c010317a:	6a 00                	push   $0x0
  pushl $182
c010317c:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0103181:	e9 d1 f8 ff ff       	jmp    c0102a57 <__alltraps>

c0103186 <vector183>:
.globl vector183
vector183:
  pushl $0
c0103186:	6a 00                	push   $0x0
  pushl $183
c0103188:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c010318d:	e9 c5 f8 ff ff       	jmp    c0102a57 <__alltraps>

c0103192 <vector184>:
.globl vector184
vector184:
  pushl $0
c0103192:	6a 00                	push   $0x0
  pushl $184
c0103194:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0103199:	e9 b9 f8 ff ff       	jmp    c0102a57 <__alltraps>

c010319e <vector185>:
.globl vector185
vector185:
  pushl $0
c010319e:	6a 00                	push   $0x0
  pushl $185
c01031a0:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01031a5:	e9 ad f8 ff ff       	jmp    c0102a57 <__alltraps>

c01031aa <vector186>:
.globl vector186
vector186:
  pushl $0
c01031aa:	6a 00                	push   $0x0
  pushl $186
c01031ac:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01031b1:	e9 a1 f8 ff ff       	jmp    c0102a57 <__alltraps>

c01031b6 <vector187>:
.globl vector187
vector187:
  pushl $0
c01031b6:	6a 00                	push   $0x0
  pushl $187
c01031b8:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01031bd:	e9 95 f8 ff ff       	jmp    c0102a57 <__alltraps>

c01031c2 <vector188>:
.globl vector188
vector188:
  pushl $0
c01031c2:	6a 00                	push   $0x0
  pushl $188
c01031c4:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01031c9:	e9 89 f8 ff ff       	jmp    c0102a57 <__alltraps>

c01031ce <vector189>:
.globl vector189
vector189:
  pushl $0
c01031ce:	6a 00                	push   $0x0
  pushl $189
c01031d0:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01031d5:	e9 7d f8 ff ff       	jmp    c0102a57 <__alltraps>

c01031da <vector190>:
.globl vector190
vector190:
  pushl $0
c01031da:	6a 00                	push   $0x0
  pushl $190
c01031dc:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01031e1:	e9 71 f8 ff ff       	jmp    c0102a57 <__alltraps>

c01031e6 <vector191>:
.globl vector191
vector191:
  pushl $0
c01031e6:	6a 00                	push   $0x0
  pushl $191
c01031e8:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01031ed:	e9 65 f8 ff ff       	jmp    c0102a57 <__alltraps>

c01031f2 <vector192>:
.globl vector192
vector192:
  pushl $0
c01031f2:	6a 00                	push   $0x0
  pushl $192
c01031f4:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01031f9:	e9 59 f8 ff ff       	jmp    c0102a57 <__alltraps>

c01031fe <vector193>:
.globl vector193
vector193:
  pushl $0
c01031fe:	6a 00                	push   $0x0
  pushl $193
c0103200:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0103205:	e9 4d f8 ff ff       	jmp    c0102a57 <__alltraps>

c010320a <vector194>:
.globl vector194
vector194:
  pushl $0
c010320a:	6a 00                	push   $0x0
  pushl $194
c010320c:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0103211:	e9 41 f8 ff ff       	jmp    c0102a57 <__alltraps>

c0103216 <vector195>:
.globl vector195
vector195:
  pushl $0
c0103216:	6a 00                	push   $0x0
  pushl $195
c0103218:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c010321d:	e9 35 f8 ff ff       	jmp    c0102a57 <__alltraps>

c0103222 <vector196>:
.globl vector196
vector196:
  pushl $0
c0103222:	6a 00                	push   $0x0
  pushl $196
c0103224:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103229:	e9 29 f8 ff ff       	jmp    c0102a57 <__alltraps>

c010322e <vector197>:
.globl vector197
vector197:
  pushl $0
c010322e:	6a 00                	push   $0x0
  pushl $197
c0103230:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0103235:	e9 1d f8 ff ff       	jmp    c0102a57 <__alltraps>

c010323a <vector198>:
.globl vector198
vector198:
  pushl $0
c010323a:	6a 00                	push   $0x0
  pushl $198
c010323c:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0103241:	e9 11 f8 ff ff       	jmp    c0102a57 <__alltraps>

c0103246 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103246:	6a 00                	push   $0x0
  pushl $199
c0103248:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010324d:	e9 05 f8 ff ff       	jmp    c0102a57 <__alltraps>

c0103252 <vector200>:
.globl vector200
vector200:
  pushl $0
c0103252:	6a 00                	push   $0x0
  pushl $200
c0103254:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103259:	e9 f9 f7 ff ff       	jmp    c0102a57 <__alltraps>

c010325e <vector201>:
.globl vector201
vector201:
  pushl $0
c010325e:	6a 00                	push   $0x0
  pushl $201
c0103260:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0103265:	e9 ed f7 ff ff       	jmp    c0102a57 <__alltraps>

c010326a <vector202>:
.globl vector202
vector202:
  pushl $0
c010326a:	6a 00                	push   $0x0
  pushl $202
c010326c:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0103271:	e9 e1 f7 ff ff       	jmp    c0102a57 <__alltraps>

c0103276 <vector203>:
.globl vector203
vector203:
  pushl $0
c0103276:	6a 00                	push   $0x0
  pushl $203
c0103278:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c010327d:	e9 d5 f7 ff ff       	jmp    c0102a57 <__alltraps>

c0103282 <vector204>:
.globl vector204
vector204:
  pushl $0
c0103282:	6a 00                	push   $0x0
  pushl $204
c0103284:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0103289:	e9 c9 f7 ff ff       	jmp    c0102a57 <__alltraps>

c010328e <vector205>:
.globl vector205
vector205:
  pushl $0
c010328e:	6a 00                	push   $0x0
  pushl $205
c0103290:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0103295:	e9 bd f7 ff ff       	jmp    c0102a57 <__alltraps>

c010329a <vector206>:
.globl vector206
vector206:
  pushl $0
c010329a:	6a 00                	push   $0x0
  pushl $206
c010329c:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01032a1:	e9 b1 f7 ff ff       	jmp    c0102a57 <__alltraps>

c01032a6 <vector207>:
.globl vector207
vector207:
  pushl $0
c01032a6:	6a 00                	push   $0x0
  pushl $207
c01032a8:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01032ad:	e9 a5 f7 ff ff       	jmp    c0102a57 <__alltraps>

c01032b2 <vector208>:
.globl vector208
vector208:
  pushl $0
c01032b2:	6a 00                	push   $0x0
  pushl $208
c01032b4:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01032b9:	e9 99 f7 ff ff       	jmp    c0102a57 <__alltraps>

c01032be <vector209>:
.globl vector209
vector209:
  pushl $0
c01032be:	6a 00                	push   $0x0
  pushl $209
c01032c0:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01032c5:	e9 8d f7 ff ff       	jmp    c0102a57 <__alltraps>

c01032ca <vector210>:
.globl vector210
vector210:
  pushl $0
c01032ca:	6a 00                	push   $0x0
  pushl $210
c01032cc:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01032d1:	e9 81 f7 ff ff       	jmp    c0102a57 <__alltraps>

c01032d6 <vector211>:
.globl vector211
vector211:
  pushl $0
c01032d6:	6a 00                	push   $0x0
  pushl $211
c01032d8:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01032dd:	e9 75 f7 ff ff       	jmp    c0102a57 <__alltraps>

c01032e2 <vector212>:
.globl vector212
vector212:
  pushl $0
c01032e2:	6a 00                	push   $0x0
  pushl $212
c01032e4:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01032e9:	e9 69 f7 ff ff       	jmp    c0102a57 <__alltraps>

c01032ee <vector213>:
.globl vector213
vector213:
  pushl $0
c01032ee:	6a 00                	push   $0x0
  pushl $213
c01032f0:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01032f5:	e9 5d f7 ff ff       	jmp    c0102a57 <__alltraps>

c01032fa <vector214>:
.globl vector214
vector214:
  pushl $0
c01032fa:	6a 00                	push   $0x0
  pushl $214
c01032fc:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0103301:	e9 51 f7 ff ff       	jmp    c0102a57 <__alltraps>

c0103306 <vector215>:
.globl vector215
vector215:
  pushl $0
c0103306:	6a 00                	push   $0x0
  pushl $215
c0103308:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010330d:	e9 45 f7 ff ff       	jmp    c0102a57 <__alltraps>

c0103312 <vector216>:
.globl vector216
vector216:
  pushl $0
c0103312:	6a 00                	push   $0x0
  pushl $216
c0103314:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103319:	e9 39 f7 ff ff       	jmp    c0102a57 <__alltraps>

c010331e <vector217>:
.globl vector217
vector217:
  pushl $0
c010331e:	6a 00                	push   $0x0
  pushl $217
c0103320:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103325:	e9 2d f7 ff ff       	jmp    c0102a57 <__alltraps>

c010332a <vector218>:
.globl vector218
vector218:
  pushl $0
c010332a:	6a 00                	push   $0x0
  pushl $218
c010332c:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0103331:	e9 21 f7 ff ff       	jmp    c0102a57 <__alltraps>

c0103336 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103336:	6a 00                	push   $0x0
  pushl $219
c0103338:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c010333d:	e9 15 f7 ff ff       	jmp    c0102a57 <__alltraps>

c0103342 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103342:	6a 00                	push   $0x0
  pushl $220
c0103344:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103349:	e9 09 f7 ff ff       	jmp    c0102a57 <__alltraps>

c010334e <vector221>:
.globl vector221
vector221:
  pushl $0
c010334e:	6a 00                	push   $0x0
  pushl $221
c0103350:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103355:	e9 fd f6 ff ff       	jmp    c0102a57 <__alltraps>

c010335a <vector222>:
.globl vector222
vector222:
  pushl $0
c010335a:	6a 00                	push   $0x0
  pushl $222
c010335c:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103361:	e9 f1 f6 ff ff       	jmp    c0102a57 <__alltraps>

c0103366 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103366:	6a 00                	push   $0x0
  pushl $223
c0103368:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010336d:	e9 e5 f6 ff ff       	jmp    c0102a57 <__alltraps>

c0103372 <vector224>:
.globl vector224
vector224:
  pushl $0
c0103372:	6a 00                	push   $0x0
  pushl $224
c0103374:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0103379:	e9 d9 f6 ff ff       	jmp    c0102a57 <__alltraps>

c010337e <vector225>:
.globl vector225
vector225:
  pushl $0
c010337e:	6a 00                	push   $0x0
  pushl $225
c0103380:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103385:	e9 cd f6 ff ff       	jmp    c0102a57 <__alltraps>

c010338a <vector226>:
.globl vector226
vector226:
  pushl $0
c010338a:	6a 00                	push   $0x0
  pushl $226
c010338c:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0103391:	e9 c1 f6 ff ff       	jmp    c0102a57 <__alltraps>

c0103396 <vector227>:
.globl vector227
vector227:
  pushl $0
c0103396:	6a 00                	push   $0x0
  pushl $227
c0103398:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010339d:	e9 b5 f6 ff ff       	jmp    c0102a57 <__alltraps>

c01033a2 <vector228>:
.globl vector228
vector228:
  pushl $0
c01033a2:	6a 00                	push   $0x0
  pushl $228
c01033a4:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01033a9:	e9 a9 f6 ff ff       	jmp    c0102a57 <__alltraps>

c01033ae <vector229>:
.globl vector229
vector229:
  pushl $0
c01033ae:	6a 00                	push   $0x0
  pushl $229
c01033b0:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01033b5:	e9 9d f6 ff ff       	jmp    c0102a57 <__alltraps>

c01033ba <vector230>:
.globl vector230
vector230:
  pushl $0
c01033ba:	6a 00                	push   $0x0
  pushl $230
c01033bc:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01033c1:	e9 91 f6 ff ff       	jmp    c0102a57 <__alltraps>

c01033c6 <vector231>:
.globl vector231
vector231:
  pushl $0
c01033c6:	6a 00                	push   $0x0
  pushl $231
c01033c8:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01033cd:	e9 85 f6 ff ff       	jmp    c0102a57 <__alltraps>

c01033d2 <vector232>:
.globl vector232
vector232:
  pushl $0
c01033d2:	6a 00                	push   $0x0
  pushl $232
c01033d4:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01033d9:	e9 79 f6 ff ff       	jmp    c0102a57 <__alltraps>

c01033de <vector233>:
.globl vector233
vector233:
  pushl $0
c01033de:	6a 00                	push   $0x0
  pushl $233
c01033e0:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01033e5:	e9 6d f6 ff ff       	jmp    c0102a57 <__alltraps>

c01033ea <vector234>:
.globl vector234
vector234:
  pushl $0
c01033ea:	6a 00                	push   $0x0
  pushl $234
c01033ec:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01033f1:	e9 61 f6 ff ff       	jmp    c0102a57 <__alltraps>

c01033f6 <vector235>:
.globl vector235
vector235:
  pushl $0
c01033f6:	6a 00                	push   $0x0
  pushl $235
c01033f8:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01033fd:	e9 55 f6 ff ff       	jmp    c0102a57 <__alltraps>

c0103402 <vector236>:
.globl vector236
vector236:
  pushl $0
c0103402:	6a 00                	push   $0x0
  pushl $236
c0103404:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103409:	e9 49 f6 ff ff       	jmp    c0102a57 <__alltraps>

c010340e <vector237>:
.globl vector237
vector237:
  pushl $0
c010340e:	6a 00                	push   $0x0
  pushl $237
c0103410:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103415:	e9 3d f6 ff ff       	jmp    c0102a57 <__alltraps>

c010341a <vector238>:
.globl vector238
vector238:
  pushl $0
c010341a:	6a 00                	push   $0x0
  pushl $238
c010341c:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0103421:	e9 31 f6 ff ff       	jmp    c0102a57 <__alltraps>

c0103426 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103426:	6a 00                	push   $0x0
  pushl $239
c0103428:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010342d:	e9 25 f6 ff ff       	jmp    c0102a57 <__alltraps>

c0103432 <vector240>:
.globl vector240
vector240:
  pushl $0
c0103432:	6a 00                	push   $0x0
  pushl $240
c0103434:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103439:	e9 19 f6 ff ff       	jmp    c0102a57 <__alltraps>

c010343e <vector241>:
.globl vector241
vector241:
  pushl $0
c010343e:	6a 00                	push   $0x0
  pushl $241
c0103440:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103445:	e9 0d f6 ff ff       	jmp    c0102a57 <__alltraps>

c010344a <vector242>:
.globl vector242
vector242:
  pushl $0
c010344a:	6a 00                	push   $0x0
  pushl $242
c010344c:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103451:	e9 01 f6 ff ff       	jmp    c0102a57 <__alltraps>

c0103456 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103456:	6a 00                	push   $0x0
  pushl $243
c0103458:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010345d:	e9 f5 f5 ff ff       	jmp    c0102a57 <__alltraps>

c0103462 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103462:	6a 00                	push   $0x0
  pushl $244
c0103464:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103469:	e9 e9 f5 ff ff       	jmp    c0102a57 <__alltraps>

c010346e <vector245>:
.globl vector245
vector245:
  pushl $0
c010346e:	6a 00                	push   $0x0
  pushl $245
c0103470:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103475:	e9 dd f5 ff ff       	jmp    c0102a57 <__alltraps>

c010347a <vector246>:
.globl vector246
vector246:
  pushl $0
c010347a:	6a 00                	push   $0x0
  pushl $246
c010347c:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0103481:	e9 d1 f5 ff ff       	jmp    c0102a57 <__alltraps>

c0103486 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103486:	6a 00                	push   $0x0
  pushl $247
c0103488:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010348d:	e9 c5 f5 ff ff       	jmp    c0102a57 <__alltraps>

c0103492 <vector248>:
.globl vector248
vector248:
  pushl $0
c0103492:	6a 00                	push   $0x0
  pushl $248
c0103494:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0103499:	e9 b9 f5 ff ff       	jmp    c0102a57 <__alltraps>

c010349e <vector249>:
.globl vector249
vector249:
  pushl $0
c010349e:	6a 00                	push   $0x0
  pushl $249
c01034a0:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01034a5:	e9 ad f5 ff ff       	jmp    c0102a57 <__alltraps>

c01034aa <vector250>:
.globl vector250
vector250:
  pushl $0
c01034aa:	6a 00                	push   $0x0
  pushl $250
c01034ac:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01034b1:	e9 a1 f5 ff ff       	jmp    c0102a57 <__alltraps>

c01034b6 <vector251>:
.globl vector251
vector251:
  pushl $0
c01034b6:	6a 00                	push   $0x0
  pushl $251
c01034b8:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01034bd:	e9 95 f5 ff ff       	jmp    c0102a57 <__alltraps>

c01034c2 <vector252>:
.globl vector252
vector252:
  pushl $0
c01034c2:	6a 00                	push   $0x0
  pushl $252
c01034c4:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01034c9:	e9 89 f5 ff ff       	jmp    c0102a57 <__alltraps>

c01034ce <vector253>:
.globl vector253
vector253:
  pushl $0
c01034ce:	6a 00                	push   $0x0
  pushl $253
c01034d0:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01034d5:	e9 7d f5 ff ff       	jmp    c0102a57 <__alltraps>

c01034da <vector254>:
.globl vector254
vector254:
  pushl $0
c01034da:	6a 00                	push   $0x0
  pushl $254
c01034dc:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01034e1:	e9 71 f5 ff ff       	jmp    c0102a57 <__alltraps>

c01034e6 <vector255>:
.globl vector255
vector255:
  pushl $0
c01034e6:	6a 00                	push   $0x0
  pushl $255
c01034e8:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01034ed:	e9 65 f5 ff ff       	jmp    c0102a57 <__alltraps>

c01034f2 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01034f2:	55                   	push   %ebp
c01034f3:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01034f5:	8b 55 08             	mov    0x8(%ebp),%edx
c01034f8:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c01034fd:	29 c2                	sub    %eax,%edx
c01034ff:	89 d0                	mov    %edx,%eax
c0103501:	c1 f8 05             	sar    $0x5,%eax
}
c0103504:	5d                   	pop    %ebp
c0103505:	c3                   	ret    

c0103506 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103506:	55                   	push   %ebp
c0103507:	89 e5                	mov    %esp,%ebp
c0103509:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010350c:	8b 45 08             	mov    0x8(%ebp),%eax
c010350f:	89 04 24             	mov    %eax,(%esp)
c0103512:	e8 db ff ff ff       	call   c01034f2 <page2ppn>
c0103517:	c1 e0 0c             	shl    $0xc,%eax
}
c010351a:	c9                   	leave  
c010351b:	c3                   	ret    

c010351c <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c010351c:	55                   	push   %ebp
c010351d:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010351f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103522:	8b 00                	mov    (%eax),%eax
}
c0103524:	5d                   	pop    %ebp
c0103525:	c3                   	ret    

c0103526 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103526:	55                   	push   %ebp
c0103527:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103529:	8b 45 08             	mov    0x8(%ebp),%eax
c010352c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010352f:	89 10                	mov    %edx,(%eax)
}
c0103531:	5d                   	pop    %ebp
c0103532:	c3                   	ret    

c0103533 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0103533:	55                   	push   %ebp
c0103534:	89 e5                	mov    %esp,%ebp
c0103536:	83 ec 10             	sub    $0x10,%esp
c0103539:	c7 45 fc b8 ef 19 c0 	movl   $0xc019efb8,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103540:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103543:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103546:	89 50 04             	mov    %edx,0x4(%eax)
c0103549:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010354c:	8b 50 04             	mov    0x4(%eax),%edx
c010354f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103552:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0103554:	c7 05 c0 ef 19 c0 00 	movl   $0x0,0xc019efc0
c010355b:	00 00 00 
}
c010355e:	c9                   	leave  
c010355f:	c3                   	ret    

c0103560 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0103560:	55                   	push   %ebp
c0103561:	89 e5                	mov    %esp,%ebp
c0103563:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0103566:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010356a:	75 24                	jne    c0103590 <default_init_memmap+0x30>
c010356c:	c7 44 24 0c d0 c7 10 	movl   $0xc010c7d0,0xc(%esp)
c0103573:	c0 
c0103574:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c010357b:	c0 
c010357c:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
c0103583:	00 
c0103584:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c010358b:	e8 45 d8 ff ff       	call   c0100dd5 <__panic>
    struct Page *p = base;
c0103590:	8b 45 08             	mov    0x8(%ebp),%eax
c0103593:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0103596:	e9 dc 00 00 00       	jmp    c0103677 <default_init_memmap+0x117>
        assert(PageReserved(p));
c010359b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010359e:	83 c0 04             	add    $0x4,%eax
c01035a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01035a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01035ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01035ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01035b1:	0f a3 10             	bt     %edx,(%eax)
c01035b4:	19 c0                	sbb    %eax,%eax
c01035b6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01035b9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01035bd:	0f 95 c0             	setne  %al
c01035c0:	0f b6 c0             	movzbl %al,%eax
c01035c3:	85 c0                	test   %eax,%eax
c01035c5:	75 24                	jne    c01035eb <default_init_memmap+0x8b>
c01035c7:	c7 44 24 0c 01 c8 10 	movl   $0xc010c801,0xc(%esp)
c01035ce:	c0 
c01035cf:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c01035d6:	c0 
c01035d7:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c01035de:	00 
c01035df:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c01035e6:	e8 ea d7 ff ff       	call   c0100dd5 <__panic>
        p->flags = 0;
c01035eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035ee:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
c01035f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035f8:	83 c0 04             	add    $0x4,%eax
c01035fb:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0103602:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103605:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103608:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010360b:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c010360e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103611:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
c0103618:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010361f:	00 
c0103620:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103623:	89 04 24             	mov    %eax,(%esp)
c0103626:	e8 fb fe ff ff       	call   c0103526 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
c010362b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010362e:	83 c0 0c             	add    $0xc,%eax
c0103631:	c7 45 dc b8 ef 19 c0 	movl   $0xc019efb8,-0x24(%ebp)
c0103638:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010363b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010363e:	8b 00                	mov    (%eax),%eax
c0103640:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103643:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103646:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103649:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010364c:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010364f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103652:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103655:	89 10                	mov    %edx,(%eax)
c0103657:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010365a:	8b 10                	mov    (%eax),%edx
c010365c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010365f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103662:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103665:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103668:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010366b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010366e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103671:	89 10                	mov    %edx,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0103673:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103677:	8b 45 0c             	mov    0xc(%ebp),%eax
c010367a:	c1 e0 05             	shl    $0x5,%eax
c010367d:	89 c2                	mov    %eax,%edx
c010367f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103682:	01 d0                	add    %edx,%eax
c0103684:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103687:	0f 85 0e ff ff ff    	jne    c010359b <default_init_memmap+0x3b>
        p->property = 0;
        set_page_ref(p, 0);
        list_add_before(&free_list, &(p->page_link));
    }

    nr_free += n;
c010368d:	8b 15 c0 ef 19 c0    	mov    0xc019efc0,%edx
c0103693:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103696:	01 d0                	add    %edx,%eax
c0103698:	a3 c0 ef 19 c0       	mov    %eax,0xc019efc0
    //first block
    base->property = n;
c010369d:	8b 45 08             	mov    0x8(%ebp),%eax
c01036a0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01036a3:	89 50 08             	mov    %edx,0x8(%eax)
}
c01036a6:	c9                   	leave  
c01036a7:	c3                   	ret    

c01036a8 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01036a8:	55                   	push   %ebp
c01036a9:	89 e5                	mov    %esp,%ebp
c01036ab:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01036ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01036b2:	75 24                	jne    c01036d8 <default_alloc_pages+0x30>
c01036b4:	c7 44 24 0c d0 c7 10 	movl   $0xc010c7d0,0xc(%esp)
c01036bb:	c0 
c01036bc:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c01036c3:	c0 
c01036c4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c01036cb:	00 
c01036cc:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c01036d3:	e8 fd d6 ff ff       	call   c0100dd5 <__panic>
    if (n > nr_free) {
c01036d8:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c01036dd:	3b 45 08             	cmp    0x8(%ebp),%eax
c01036e0:	73 0a                	jae    c01036ec <default_alloc_pages+0x44>
        return NULL;
c01036e2:	b8 00 00 00 00       	mov    $0x0,%eax
c01036e7:	e9 37 01 00 00       	jmp    c0103823 <default_alloc_pages+0x17b>
    }
    list_entry_t *le, *len;
    le = &free_list;
c01036ec:	c7 45 f4 b8 ef 19 c0 	movl   $0xc019efb8,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {
c01036f3:	e9 0a 01 00 00       	jmp    c0103802 <default_alloc_pages+0x15a>
      struct Page *p = le2page(le, page_link);
c01036f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036fb:	83 e8 0c             	sub    $0xc,%eax
c01036fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){
c0103701:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103704:	8b 40 08             	mov    0x8(%eax),%eax
c0103707:	3b 45 08             	cmp    0x8(%ebp),%eax
c010370a:	0f 82 f2 00 00 00    	jb     c0103802 <default_alloc_pages+0x15a>
        int i;
        for(i=0;i<n;i++){
c0103710:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0103717:	eb 7c                	jmp    c0103795 <default_alloc_pages+0xed>
c0103719:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010371c:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010371f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103722:	8b 40 04             	mov    0x4(%eax),%eax
          len = list_next(le);
c0103725:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *pp = le2page(le, page_link);
c0103728:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010372b:	83 e8 0c             	sub    $0xc,%eax
c010372e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(pp);
c0103731:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103734:	83 c0 04             	add    $0x4,%eax
c0103737:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010373e:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103741:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103744:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103747:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(pp);
c010374a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010374d:	83 c0 04             	add    $0x4,%eax
c0103750:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0103757:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010375a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010375d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103760:	0f b3 10             	btr    %edx,(%eax)
c0103763:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103766:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103769:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010376c:	8b 40 04             	mov    0x4(%eax),%eax
c010376f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103772:	8b 12                	mov    (%edx),%edx
c0103774:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0103777:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010377a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010377d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103780:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103783:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103786:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103789:	89 10                	mov    %edx,(%eax)
          list_del(le);
          le = len;
c010378b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010378e:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {
      struct Page *p = le2page(le, page_link);
      if(p->property >= n){
        int i;
        for(i=0;i<n;i++){
c0103791:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c0103795:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103798:	3b 45 08             	cmp    0x8(%ebp),%eax
c010379b:	0f 82 78 ff ff ff    	jb     c0103719 <default_alloc_pages+0x71>
          SetPageReserved(pp);
          ClearPageProperty(pp);
          list_del(le);
          le = len;
        }
        if(p->property>n){
c01037a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037a4:	8b 40 08             	mov    0x8(%eax),%eax
c01037a7:	3b 45 08             	cmp    0x8(%ebp),%eax
c01037aa:	76 12                	jbe    c01037be <default_alloc_pages+0x116>
          (le2page(le,page_link))->property = p->property - n;
c01037ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037af:	8d 50 f4             	lea    -0xc(%eax),%edx
c01037b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037b5:	8b 40 08             	mov    0x8(%eax),%eax
c01037b8:	2b 45 08             	sub    0x8(%ebp),%eax
c01037bb:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
c01037be:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037c1:	83 c0 04             	add    $0x4,%eax
c01037c4:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01037cb:	89 45 bc             	mov    %eax,-0x44(%ebp)
c01037ce:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01037d1:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01037d4:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
c01037d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037da:	83 c0 04             	add    $0x4,%eax
c01037dd:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
c01037e4:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01037e7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01037ea:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01037ed:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n;
c01037f0:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c01037f5:	2b 45 08             	sub    0x8(%ebp),%eax
c01037f8:	a3 c0 ef 19 c0       	mov    %eax,0xc019efc0
        return p;
c01037fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103800:	eb 21                	jmp    c0103823 <default_alloc_pages+0x17b>
c0103802:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103805:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103808:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010380b:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    list_entry_t *le, *len;
    le = &free_list;

    while((le=list_next(le)) != &free_list) {
c010380e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103811:	81 7d f4 b8 ef 19 c0 	cmpl   $0xc019efb8,-0xc(%ebp)
c0103818:	0f 85 da fe ff ff    	jne    c01036f8 <default_alloc_pages+0x50>
        SetPageReserved(p);
        nr_free -= n;
        return p;
      }
    }
    return NULL;
c010381e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103823:	c9                   	leave  
c0103824:	c3                   	ret    

c0103825 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0103825:	55                   	push   %ebp
c0103826:	89 e5                	mov    %esp,%ebp
c0103828:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c010382b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010382f:	75 24                	jne    c0103855 <default_free_pages+0x30>
c0103831:	c7 44 24 0c d0 c7 10 	movl   $0xc010c7d0,0xc(%esp)
c0103838:	c0 
c0103839:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103840:	c0 
c0103841:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
c0103848:	00 
c0103849:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103850:	e8 80 d5 ff ff       	call   c0100dd5 <__panic>
    assert(PageReserved(base));
c0103855:	8b 45 08             	mov    0x8(%ebp),%eax
c0103858:	83 c0 04             	add    $0x4,%eax
c010385b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0103862:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103865:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103868:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010386b:	0f a3 10             	bt     %edx,(%eax)
c010386e:	19 c0                	sbb    %eax,%eax
c0103870:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0103873:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103877:	0f 95 c0             	setne  %al
c010387a:	0f b6 c0             	movzbl %al,%eax
c010387d:	85 c0                	test   %eax,%eax
c010387f:	75 24                	jne    c01038a5 <default_free_pages+0x80>
c0103881:	c7 44 24 0c 11 c8 10 	movl   $0xc010c811,0xc(%esp)
c0103888:	c0 
c0103889:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103890:	c0 
c0103891:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
c0103898:	00 
c0103899:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c01038a0:	e8 30 d5 ff ff       	call   c0100dd5 <__panic>

    list_entry_t *le = &free_list;
c01038a5:	c7 45 f4 b8 ef 19 c0 	movl   $0xc019efb8,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c01038ac:	eb 13                	jmp    c01038c1 <default_free_pages+0x9c>
      p = le2page(le, page_link);
c01038ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038b1:	83 e8 0c             	sub    $0xc,%eax
c01038b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){
c01038b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038ba:	3b 45 08             	cmp    0x8(%ebp),%eax
c01038bd:	76 02                	jbe    c01038c1 <default_free_pages+0x9c>
        break;
c01038bf:	eb 18                	jmp    c01038d9 <default_free_pages+0xb4>
c01038c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01038c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01038ca:	8b 40 04             	mov    0x4(%eax),%eax
    assert(n > 0);
    assert(PageReserved(base));

    list_entry_t *le = &free_list;
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c01038cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01038d0:	81 7d f4 b8 ef 19 c0 	cmpl   $0xc019efb8,-0xc(%ebp)
c01038d7:	75 d5                	jne    c01038ae <default_free_pages+0x89>
      if(p>base){
        break;
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
c01038d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01038dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01038df:	eb 4b                	jmp    c010392c <default_free_pages+0x107>
      list_add_before(le, &(p->page_link));
c01038e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038e4:	8d 50 0c             	lea    0xc(%eax),%edx
c01038e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038ea:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01038ed:	89 55 d8             	mov    %edx,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01038f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01038f3:	8b 00                	mov    (%eax),%eax
c01038f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01038f8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01038fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01038fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103901:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103904:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103907:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010390a:	89 10                	mov    %edx,(%eax)
c010390c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010390f:	8b 10                	mov    (%eax),%edx
c0103911:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103914:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103917:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010391a:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010391d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103920:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103923:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103926:	89 10                	mov    %edx,(%eax)
      if(p>base){
        break;
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
c0103928:	83 45 f0 20          	addl   $0x20,-0x10(%ebp)
c010392c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010392f:	c1 e0 05             	shl    $0x5,%eax
c0103932:	89 c2                	mov    %eax,%edx
c0103934:	8b 45 08             	mov    0x8(%ebp),%eax
c0103937:	01 d0                	add    %edx,%eax
c0103939:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010393c:	77 a3                	ja     c01038e1 <default_free_pages+0xbc>
      list_add_before(le, &(p->page_link));
    }
    base->flags = 0;
c010393e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103941:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
c0103948:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010394f:	00 
c0103950:	8b 45 08             	mov    0x8(%ebp),%eax
c0103953:	89 04 24             	mov    %eax,(%esp)
c0103956:	e8 cb fb ff ff       	call   c0103526 <set_page_ref>
    ClearPageProperty(base);
c010395b:	8b 45 08             	mov    0x8(%ebp),%eax
c010395e:	83 c0 04             	add    $0x4,%eax
c0103961:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0103968:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010396b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010396e:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103971:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
c0103974:	8b 45 08             	mov    0x8(%ebp),%eax
c0103977:	83 c0 04             	add    $0x4,%eax
c010397a:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0103981:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103984:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103987:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010398a:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;
c010398d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103990:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103993:	89 50 08             	mov    %edx,0x8(%eax)
    
    p = le2page(le,page_link) ;
c0103996:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103999:	83 e8 0c             	sub    $0xc,%eax
c010399c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if( base+n == p ){
c010399f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039a2:	c1 e0 05             	shl    $0x5,%eax
c01039a5:	89 c2                	mov    %eax,%edx
c01039a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01039aa:	01 d0                	add    %edx,%eax
c01039ac:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01039af:	75 1e                	jne    c01039cf <default_free_pages+0x1aa>
      base->property += p->property;
c01039b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01039b4:	8b 50 08             	mov    0x8(%eax),%edx
c01039b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039ba:	8b 40 08             	mov    0x8(%eax),%eax
c01039bd:	01 c2                	add    %eax,%edx
c01039bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01039c2:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
c01039c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039c8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    le = list_prev(&(base->page_link));
c01039cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01039d2:	83 c0 0c             	add    $0xc,%eax
c01039d5:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c01039d8:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01039db:	8b 00                	mov    (%eax),%eax
c01039dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c01039e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039e3:	83 e8 0c             	sub    $0xc,%eax
c01039e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
c01039e9:	81 7d f4 b8 ef 19 c0 	cmpl   $0xc019efb8,-0xc(%ebp)
c01039f0:	74 57                	je     c0103a49 <default_free_pages+0x224>
c01039f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01039f5:	83 e8 20             	sub    $0x20,%eax
c01039f8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01039fb:	75 4c                	jne    c0103a49 <default_free_pages+0x224>
      while(le!=&free_list){
c01039fd:	eb 41                	jmp    c0103a40 <default_free_pages+0x21b>
        if(p->property){
c01039ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a02:	8b 40 08             	mov    0x8(%eax),%eax
c0103a05:	85 c0                	test   %eax,%eax
c0103a07:	74 20                	je     c0103a29 <default_free_pages+0x204>
          p->property += base->property;
c0103a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a0c:	8b 50 08             	mov    0x8(%eax),%edx
c0103a0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a12:	8b 40 08             	mov    0x8(%eax),%eax
c0103a15:	01 c2                	add    %eax,%edx
c0103a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a1a:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c0103a1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a20:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
c0103a27:	eb 20                	jmp    c0103a49 <default_free_pages+0x224>
c0103a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a2c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0103a2f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103a32:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
c0103a34:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
c0103a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a3a:	83 e8 0c             	sub    $0xc,%eax
c0103a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      p->property = 0;
    }
    le = list_prev(&(base->page_link));
    p = le2page(le, page_link);
    if(le!=&free_list && p==base-1){
      while(le!=&free_list){
c0103a40:	81 7d f4 b8 ef 19 c0 	cmpl   $0xc019efb8,-0xc(%ebp)
c0103a47:	75 b6                	jne    c01039ff <default_free_pages+0x1da>
        }
        le = list_prev(le);
        p = le2page(le,page_link);
      }
    }
    nr_free += n;
c0103a49:	8b 15 c0 ef 19 c0    	mov    0xc019efc0,%edx
c0103a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a52:	01 d0                	add    %edx,%eax
c0103a54:	a3 c0 ef 19 c0       	mov    %eax,0xc019efc0
    return ;
c0103a59:	90                   	nop
}
c0103a5a:	c9                   	leave  
c0103a5b:	c3                   	ret    

c0103a5c <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103a5c:	55                   	push   %ebp
c0103a5d:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103a5f:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
}
c0103a64:	5d                   	pop    %ebp
c0103a65:	c3                   	ret    

c0103a66 <basic_check>:

static void
basic_check(void) {
c0103a66:	55                   	push   %ebp
c0103a67:	89 e5                	mov    %esp,%ebp
c0103a69:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103a6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a76:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103a7f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a86:	e8 dc 15 00 00       	call   c0105067 <alloc_pages>
c0103a8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a8e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103a92:	75 24                	jne    c0103ab8 <basic_check+0x52>
c0103a94:	c7 44 24 0c 24 c8 10 	movl   $0xc010c824,0xc(%esp)
c0103a9b:	c0 
c0103a9c:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103aa3:	c0 
c0103aa4:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
c0103aab:	00 
c0103aac:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103ab3:	e8 1d d3 ff ff       	call   c0100dd5 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103ab8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103abf:	e8 a3 15 00 00       	call   c0105067 <alloc_pages>
c0103ac4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ac7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103acb:	75 24                	jne    c0103af1 <basic_check+0x8b>
c0103acd:	c7 44 24 0c 40 c8 10 	movl   $0xc010c840,0xc(%esp)
c0103ad4:	c0 
c0103ad5:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103adc:	c0 
c0103add:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
c0103ae4:	00 
c0103ae5:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103aec:	e8 e4 d2 ff ff       	call   c0100dd5 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103af1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103af8:	e8 6a 15 00 00       	call   c0105067 <alloc_pages>
c0103afd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103b00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103b04:	75 24                	jne    c0103b2a <basic_check+0xc4>
c0103b06:	c7 44 24 0c 5c c8 10 	movl   $0xc010c85c,0xc(%esp)
c0103b0d:	c0 
c0103b0e:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103b15:	c0 
c0103b16:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
c0103b1d:	00 
c0103b1e:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103b25:	e8 ab d2 ff ff       	call   c0100dd5 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103b2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b2d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103b30:	74 10                	je     c0103b42 <basic_check+0xdc>
c0103b32:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b35:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103b38:	74 08                	je     c0103b42 <basic_check+0xdc>
c0103b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b3d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103b40:	75 24                	jne    c0103b66 <basic_check+0x100>
c0103b42:	c7 44 24 0c 78 c8 10 	movl   $0xc010c878,0xc(%esp)
c0103b49:	c0 
c0103b4a:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103b51:	c0 
c0103b52:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
c0103b59:	00 
c0103b5a:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103b61:	e8 6f d2 ff ff       	call   c0100dd5 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103b66:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b69:	89 04 24             	mov    %eax,(%esp)
c0103b6c:	e8 ab f9 ff ff       	call   c010351c <page_ref>
c0103b71:	85 c0                	test   %eax,%eax
c0103b73:	75 1e                	jne    c0103b93 <basic_check+0x12d>
c0103b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b78:	89 04 24             	mov    %eax,(%esp)
c0103b7b:	e8 9c f9 ff ff       	call   c010351c <page_ref>
c0103b80:	85 c0                	test   %eax,%eax
c0103b82:	75 0f                	jne    c0103b93 <basic_check+0x12d>
c0103b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b87:	89 04 24             	mov    %eax,(%esp)
c0103b8a:	e8 8d f9 ff ff       	call   c010351c <page_ref>
c0103b8f:	85 c0                	test   %eax,%eax
c0103b91:	74 24                	je     c0103bb7 <basic_check+0x151>
c0103b93:	c7 44 24 0c 9c c8 10 	movl   $0xc010c89c,0xc(%esp)
c0103b9a:	c0 
c0103b9b:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103ba2:	c0 
c0103ba3:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c0103baa:	00 
c0103bab:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103bb2:	e8 1e d2 ff ff       	call   c0100dd5 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103bb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103bba:	89 04 24             	mov    %eax,(%esp)
c0103bbd:	e8 44 f9 ff ff       	call   c0103506 <page2pa>
c0103bc2:	8b 15 e0 ce 19 c0    	mov    0xc019cee0,%edx
c0103bc8:	c1 e2 0c             	shl    $0xc,%edx
c0103bcb:	39 d0                	cmp    %edx,%eax
c0103bcd:	72 24                	jb     c0103bf3 <basic_check+0x18d>
c0103bcf:	c7 44 24 0c d8 c8 10 	movl   $0xc010c8d8,0xc(%esp)
c0103bd6:	c0 
c0103bd7:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103bde:	c0 
c0103bdf:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
c0103be6:	00 
c0103be7:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103bee:	e8 e2 d1 ff ff       	call   c0100dd5 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103bf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bf6:	89 04 24             	mov    %eax,(%esp)
c0103bf9:	e8 08 f9 ff ff       	call   c0103506 <page2pa>
c0103bfe:	8b 15 e0 ce 19 c0    	mov    0xc019cee0,%edx
c0103c04:	c1 e2 0c             	shl    $0xc,%edx
c0103c07:	39 d0                	cmp    %edx,%eax
c0103c09:	72 24                	jb     c0103c2f <basic_check+0x1c9>
c0103c0b:	c7 44 24 0c f5 c8 10 	movl   $0xc010c8f5,0xc(%esp)
c0103c12:	c0 
c0103c13:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103c1a:	c0 
c0103c1b:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c0103c22:	00 
c0103c23:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103c2a:	e8 a6 d1 ff ff       	call   c0100dd5 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c32:	89 04 24             	mov    %eax,(%esp)
c0103c35:	e8 cc f8 ff ff       	call   c0103506 <page2pa>
c0103c3a:	8b 15 e0 ce 19 c0    	mov    0xc019cee0,%edx
c0103c40:	c1 e2 0c             	shl    $0xc,%edx
c0103c43:	39 d0                	cmp    %edx,%eax
c0103c45:	72 24                	jb     c0103c6b <basic_check+0x205>
c0103c47:	c7 44 24 0c 12 c9 10 	movl   $0xc010c912,0xc(%esp)
c0103c4e:	c0 
c0103c4f:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103c56:	c0 
c0103c57:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0103c5e:	00 
c0103c5f:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103c66:	e8 6a d1 ff ff       	call   c0100dd5 <__panic>

    list_entry_t free_list_store = free_list;
c0103c6b:	a1 b8 ef 19 c0       	mov    0xc019efb8,%eax
c0103c70:	8b 15 bc ef 19 c0    	mov    0xc019efbc,%edx
c0103c76:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103c79:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103c7c:	c7 45 e0 b8 ef 19 c0 	movl   $0xc019efb8,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103c83:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c86:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103c89:	89 50 04             	mov    %edx,0x4(%eax)
c0103c8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c8f:	8b 50 04             	mov    0x4(%eax),%edx
c0103c92:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c95:	89 10                	mov    %edx,(%eax)
c0103c97:	c7 45 dc b8 ef 19 c0 	movl   $0xc019efb8,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103c9e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ca1:	8b 40 04             	mov    0x4(%eax),%eax
c0103ca4:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103ca7:	0f 94 c0             	sete   %al
c0103caa:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103cad:	85 c0                	test   %eax,%eax
c0103caf:	75 24                	jne    c0103cd5 <basic_check+0x26f>
c0103cb1:	c7 44 24 0c 2f c9 10 	movl   $0xc010c92f,0xc(%esp)
c0103cb8:	c0 
c0103cb9:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103cc0:	c0 
c0103cc1:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0103cc8:	00 
c0103cc9:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103cd0:	e8 00 d1 ff ff       	call   c0100dd5 <__panic>

    unsigned int nr_free_store = nr_free;
c0103cd5:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c0103cda:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103cdd:	c7 05 c0 ef 19 c0 00 	movl   $0x0,0xc019efc0
c0103ce4:	00 00 00 

    assert(alloc_page() == NULL);
c0103ce7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103cee:	e8 74 13 00 00       	call   c0105067 <alloc_pages>
c0103cf3:	85 c0                	test   %eax,%eax
c0103cf5:	74 24                	je     c0103d1b <basic_check+0x2b5>
c0103cf7:	c7 44 24 0c 46 c9 10 	movl   $0xc010c946,0xc(%esp)
c0103cfe:	c0 
c0103cff:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103d06:	c0 
c0103d07:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0103d0e:	00 
c0103d0f:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103d16:	e8 ba d0 ff ff       	call   c0100dd5 <__panic>

    free_page(p0);
c0103d1b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d22:	00 
c0103d23:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d26:	89 04 24             	mov    %eax,(%esp)
c0103d29:	e8 a4 13 00 00       	call   c01050d2 <free_pages>
    free_page(p1);
c0103d2e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d35:	00 
c0103d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d39:	89 04 24             	mov    %eax,(%esp)
c0103d3c:	e8 91 13 00 00       	call   c01050d2 <free_pages>
    free_page(p2);
c0103d41:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d48:	00 
c0103d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d4c:	89 04 24             	mov    %eax,(%esp)
c0103d4f:	e8 7e 13 00 00       	call   c01050d2 <free_pages>
    assert(nr_free == 3);
c0103d54:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c0103d59:	83 f8 03             	cmp    $0x3,%eax
c0103d5c:	74 24                	je     c0103d82 <basic_check+0x31c>
c0103d5e:	c7 44 24 0c 5b c9 10 	movl   $0xc010c95b,0xc(%esp)
c0103d65:	c0 
c0103d66:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103d6d:	c0 
c0103d6e:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0103d75:	00 
c0103d76:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103d7d:	e8 53 d0 ff ff       	call   c0100dd5 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103d82:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d89:	e8 d9 12 00 00       	call   c0105067 <alloc_pages>
c0103d8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103d91:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103d95:	75 24                	jne    c0103dbb <basic_check+0x355>
c0103d97:	c7 44 24 0c 24 c8 10 	movl   $0xc010c824,0xc(%esp)
c0103d9e:	c0 
c0103d9f:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103da6:	c0 
c0103da7:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0103dae:	00 
c0103daf:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103db6:	e8 1a d0 ff ff       	call   c0100dd5 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103dbb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103dc2:	e8 a0 12 00 00       	call   c0105067 <alloc_pages>
c0103dc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103dca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103dce:	75 24                	jne    c0103df4 <basic_check+0x38e>
c0103dd0:	c7 44 24 0c 40 c8 10 	movl   $0xc010c840,0xc(%esp)
c0103dd7:	c0 
c0103dd8:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103ddf:	c0 
c0103de0:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0103de7:	00 
c0103de8:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103def:	e8 e1 cf ff ff       	call   c0100dd5 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103df4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103dfb:	e8 67 12 00 00       	call   c0105067 <alloc_pages>
c0103e00:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103e03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103e07:	75 24                	jne    c0103e2d <basic_check+0x3c7>
c0103e09:	c7 44 24 0c 5c c8 10 	movl   $0xc010c85c,0xc(%esp)
c0103e10:	c0 
c0103e11:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103e18:	c0 
c0103e19:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0103e20:	00 
c0103e21:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103e28:	e8 a8 cf ff ff       	call   c0100dd5 <__panic>

    assert(alloc_page() == NULL);
c0103e2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e34:	e8 2e 12 00 00       	call   c0105067 <alloc_pages>
c0103e39:	85 c0                	test   %eax,%eax
c0103e3b:	74 24                	je     c0103e61 <basic_check+0x3fb>
c0103e3d:	c7 44 24 0c 46 c9 10 	movl   $0xc010c946,0xc(%esp)
c0103e44:	c0 
c0103e45:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103e4c:	c0 
c0103e4d:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0103e54:	00 
c0103e55:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103e5c:	e8 74 cf ff ff       	call   c0100dd5 <__panic>

    free_page(p0);
c0103e61:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e68:	00 
c0103e69:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e6c:	89 04 24             	mov    %eax,(%esp)
c0103e6f:	e8 5e 12 00 00       	call   c01050d2 <free_pages>
c0103e74:	c7 45 d8 b8 ef 19 c0 	movl   $0xc019efb8,-0x28(%ebp)
c0103e7b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103e7e:	8b 40 04             	mov    0x4(%eax),%eax
c0103e81:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103e84:	0f 94 c0             	sete   %al
c0103e87:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103e8a:	85 c0                	test   %eax,%eax
c0103e8c:	74 24                	je     c0103eb2 <basic_check+0x44c>
c0103e8e:	c7 44 24 0c 68 c9 10 	movl   $0xc010c968,0xc(%esp)
c0103e95:	c0 
c0103e96:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103e9d:	c0 
c0103e9e:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0103ea5:	00 
c0103ea6:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103ead:	e8 23 cf ff ff       	call   c0100dd5 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103eb2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103eb9:	e8 a9 11 00 00       	call   c0105067 <alloc_pages>
c0103ebe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103ec1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ec4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103ec7:	74 24                	je     c0103eed <basic_check+0x487>
c0103ec9:	c7 44 24 0c 80 c9 10 	movl   $0xc010c980,0xc(%esp)
c0103ed0:	c0 
c0103ed1:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103ed8:	c0 
c0103ed9:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103ee0:	00 
c0103ee1:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103ee8:	e8 e8 ce ff ff       	call   c0100dd5 <__panic>
    assert(alloc_page() == NULL);
c0103eed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ef4:	e8 6e 11 00 00       	call   c0105067 <alloc_pages>
c0103ef9:	85 c0                	test   %eax,%eax
c0103efb:	74 24                	je     c0103f21 <basic_check+0x4bb>
c0103efd:	c7 44 24 0c 46 c9 10 	movl   $0xc010c946,0xc(%esp)
c0103f04:	c0 
c0103f05:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103f0c:	c0 
c0103f0d:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0103f14:	00 
c0103f15:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103f1c:	e8 b4 ce ff ff       	call   c0100dd5 <__panic>

    assert(nr_free == 0);
c0103f21:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c0103f26:	85 c0                	test   %eax,%eax
c0103f28:	74 24                	je     c0103f4e <basic_check+0x4e8>
c0103f2a:	c7 44 24 0c 99 c9 10 	movl   $0xc010c999,0xc(%esp)
c0103f31:	c0 
c0103f32:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0103f39:	c0 
c0103f3a:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0103f41:	00 
c0103f42:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0103f49:	e8 87 ce ff ff       	call   c0100dd5 <__panic>
    free_list = free_list_store;
c0103f4e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103f51:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103f54:	a3 b8 ef 19 c0       	mov    %eax,0xc019efb8
c0103f59:	89 15 bc ef 19 c0    	mov    %edx,0xc019efbc
    nr_free = nr_free_store;
c0103f5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f62:	a3 c0 ef 19 c0       	mov    %eax,0xc019efc0

    free_page(p);
c0103f67:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f6e:	00 
c0103f6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f72:	89 04 24             	mov    %eax,(%esp)
c0103f75:	e8 58 11 00 00       	call   c01050d2 <free_pages>
    free_page(p1);
c0103f7a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f81:	00 
c0103f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f85:	89 04 24             	mov    %eax,(%esp)
c0103f88:	e8 45 11 00 00       	call   c01050d2 <free_pages>
    free_page(p2);
c0103f8d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f94:	00 
c0103f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f98:	89 04 24             	mov    %eax,(%esp)
c0103f9b:	e8 32 11 00 00       	call   c01050d2 <free_pages>
}
c0103fa0:	c9                   	leave  
c0103fa1:	c3                   	ret    

c0103fa2 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103fa2:	55                   	push   %ebp
c0103fa3:	89 e5                	mov    %esp,%ebp
c0103fa5:	53                   	push   %ebx
c0103fa6:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0103fac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103fb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103fba:	c7 45 ec b8 ef 19 c0 	movl   $0xc019efb8,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103fc1:	eb 6b                	jmp    c010402e <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0103fc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103fc6:	83 e8 0c             	sub    $0xc,%eax
c0103fc9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0103fcc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103fcf:	83 c0 04             	add    $0x4,%eax
c0103fd2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103fd9:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103fdc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103fdf:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103fe2:	0f a3 10             	bt     %edx,(%eax)
c0103fe5:	19 c0                	sbb    %eax,%eax
c0103fe7:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103fea:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103fee:	0f 95 c0             	setne  %al
c0103ff1:	0f b6 c0             	movzbl %al,%eax
c0103ff4:	85 c0                	test   %eax,%eax
c0103ff6:	75 24                	jne    c010401c <default_check+0x7a>
c0103ff8:	c7 44 24 0c a6 c9 10 	movl   $0xc010c9a6,0xc(%esp)
c0103fff:	c0 
c0104000:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0104007:	c0 
c0104008:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c010400f:	00 
c0104010:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0104017:	e8 b9 cd ff ff       	call   c0100dd5 <__panic>
        count ++, total += p->property;
c010401c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104020:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104023:	8b 50 08             	mov    0x8(%eax),%edx
c0104026:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104029:	01 d0                	add    %edx,%eax
c010402b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010402e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104031:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104034:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104037:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010403a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010403d:	81 7d ec b8 ef 19 c0 	cmpl   $0xc019efb8,-0x14(%ebp)
c0104044:	0f 85 79 ff ff ff    	jne    c0103fc3 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c010404a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c010404d:	e8 b2 10 00 00       	call   c0105104 <nr_free_pages>
c0104052:	39 c3                	cmp    %eax,%ebx
c0104054:	74 24                	je     c010407a <default_check+0xd8>
c0104056:	c7 44 24 0c b6 c9 10 	movl   $0xc010c9b6,0xc(%esp)
c010405d:	c0 
c010405e:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0104065:	c0 
c0104066:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c010406d:	00 
c010406e:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0104075:	e8 5b cd ff ff       	call   c0100dd5 <__panic>

    basic_check();
c010407a:	e8 e7 f9 ff ff       	call   c0103a66 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010407f:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104086:	e8 dc 0f 00 00       	call   c0105067 <alloc_pages>
c010408b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c010408e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104092:	75 24                	jne    c01040b8 <default_check+0x116>
c0104094:	c7 44 24 0c cf c9 10 	movl   $0xc010c9cf,0xc(%esp)
c010409b:	c0 
c010409c:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c01040a3:	c0 
c01040a4:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c01040ab:	00 
c01040ac:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c01040b3:	e8 1d cd ff ff       	call   c0100dd5 <__panic>
    assert(!PageProperty(p0));
c01040b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040bb:	83 c0 04             	add    $0x4,%eax
c01040be:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01040c5:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01040c8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01040cb:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01040ce:	0f a3 10             	bt     %edx,(%eax)
c01040d1:	19 c0                	sbb    %eax,%eax
c01040d3:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01040d6:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01040da:	0f 95 c0             	setne  %al
c01040dd:	0f b6 c0             	movzbl %al,%eax
c01040e0:	85 c0                	test   %eax,%eax
c01040e2:	74 24                	je     c0104108 <default_check+0x166>
c01040e4:	c7 44 24 0c da c9 10 	movl   $0xc010c9da,0xc(%esp)
c01040eb:	c0 
c01040ec:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c01040f3:	c0 
c01040f4:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c01040fb:	00 
c01040fc:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0104103:	e8 cd cc ff ff       	call   c0100dd5 <__panic>

    list_entry_t free_list_store = free_list;
c0104108:	a1 b8 ef 19 c0       	mov    0xc019efb8,%eax
c010410d:	8b 15 bc ef 19 c0    	mov    0xc019efbc,%edx
c0104113:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104116:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104119:	c7 45 b4 b8 ef 19 c0 	movl   $0xc019efb8,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104120:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104123:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104126:	89 50 04             	mov    %edx,0x4(%eax)
c0104129:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010412c:	8b 50 04             	mov    0x4(%eax),%edx
c010412f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104132:	89 10                	mov    %edx,(%eax)
c0104134:	c7 45 b0 b8 ef 19 c0 	movl   $0xc019efb8,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010413b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010413e:	8b 40 04             	mov    0x4(%eax),%eax
c0104141:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0104144:	0f 94 c0             	sete   %al
c0104147:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010414a:	85 c0                	test   %eax,%eax
c010414c:	75 24                	jne    c0104172 <default_check+0x1d0>
c010414e:	c7 44 24 0c 2f c9 10 	movl   $0xc010c92f,0xc(%esp)
c0104155:	c0 
c0104156:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c010415d:	c0 
c010415e:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0104165:	00 
c0104166:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c010416d:	e8 63 cc ff ff       	call   c0100dd5 <__panic>
    assert(alloc_page() == NULL);
c0104172:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104179:	e8 e9 0e 00 00       	call   c0105067 <alloc_pages>
c010417e:	85 c0                	test   %eax,%eax
c0104180:	74 24                	je     c01041a6 <default_check+0x204>
c0104182:	c7 44 24 0c 46 c9 10 	movl   $0xc010c946,0xc(%esp)
c0104189:	c0 
c010418a:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0104191:	c0 
c0104192:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0104199:	00 
c010419a:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c01041a1:	e8 2f cc ff ff       	call   c0100dd5 <__panic>

    unsigned int nr_free_store = nr_free;
c01041a6:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c01041ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01041ae:	c7 05 c0 ef 19 c0 00 	movl   $0x0,0xc019efc0
c01041b5:	00 00 00 

    free_pages(p0 + 2, 3);
c01041b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041bb:	83 c0 40             	add    $0x40,%eax
c01041be:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01041c5:	00 
c01041c6:	89 04 24             	mov    %eax,(%esp)
c01041c9:	e8 04 0f 00 00       	call   c01050d2 <free_pages>
    assert(alloc_pages(4) == NULL);
c01041ce:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01041d5:	e8 8d 0e 00 00       	call   c0105067 <alloc_pages>
c01041da:	85 c0                	test   %eax,%eax
c01041dc:	74 24                	je     c0104202 <default_check+0x260>
c01041de:	c7 44 24 0c ec c9 10 	movl   $0xc010c9ec,0xc(%esp)
c01041e5:	c0 
c01041e6:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c01041ed:	c0 
c01041ee:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01041f5:	00 
c01041f6:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c01041fd:	e8 d3 cb ff ff       	call   c0100dd5 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104202:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104205:	83 c0 40             	add    $0x40,%eax
c0104208:	83 c0 04             	add    $0x4,%eax
c010420b:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0104212:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104215:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104218:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010421b:	0f a3 10             	bt     %edx,(%eax)
c010421e:	19 c0                	sbb    %eax,%eax
c0104220:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104223:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104227:	0f 95 c0             	setne  %al
c010422a:	0f b6 c0             	movzbl %al,%eax
c010422d:	85 c0                	test   %eax,%eax
c010422f:	74 0e                	je     c010423f <default_check+0x29d>
c0104231:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104234:	83 c0 40             	add    $0x40,%eax
c0104237:	8b 40 08             	mov    0x8(%eax),%eax
c010423a:	83 f8 03             	cmp    $0x3,%eax
c010423d:	74 24                	je     c0104263 <default_check+0x2c1>
c010423f:	c7 44 24 0c 04 ca 10 	movl   $0xc010ca04,0xc(%esp)
c0104246:	c0 
c0104247:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c010424e:	c0 
c010424f:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0104256:	00 
c0104257:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c010425e:	e8 72 cb ff ff       	call   c0100dd5 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104263:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c010426a:	e8 f8 0d 00 00       	call   c0105067 <alloc_pages>
c010426f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104272:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104276:	75 24                	jne    c010429c <default_check+0x2fa>
c0104278:	c7 44 24 0c 30 ca 10 	movl   $0xc010ca30,0xc(%esp)
c010427f:	c0 
c0104280:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0104287:	c0 
c0104288:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c010428f:	00 
c0104290:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0104297:	e8 39 cb ff ff       	call   c0100dd5 <__panic>
    assert(alloc_page() == NULL);
c010429c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01042a3:	e8 bf 0d 00 00       	call   c0105067 <alloc_pages>
c01042a8:	85 c0                	test   %eax,%eax
c01042aa:	74 24                	je     c01042d0 <default_check+0x32e>
c01042ac:	c7 44 24 0c 46 c9 10 	movl   $0xc010c946,0xc(%esp)
c01042b3:	c0 
c01042b4:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c01042bb:	c0 
c01042bc:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c01042c3:	00 
c01042c4:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c01042cb:	e8 05 cb ff ff       	call   c0100dd5 <__panic>
    assert(p0 + 2 == p1);
c01042d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042d3:	83 c0 40             	add    $0x40,%eax
c01042d6:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01042d9:	74 24                	je     c01042ff <default_check+0x35d>
c01042db:	c7 44 24 0c 4e ca 10 	movl   $0xc010ca4e,0xc(%esp)
c01042e2:	c0 
c01042e3:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c01042ea:	c0 
c01042eb:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c01042f2:	00 
c01042f3:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c01042fa:	e8 d6 ca ff ff       	call   c0100dd5 <__panic>

    p2 = p0 + 1;
c01042ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104302:	83 c0 20             	add    $0x20,%eax
c0104305:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0104308:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010430f:	00 
c0104310:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104313:	89 04 24             	mov    %eax,(%esp)
c0104316:	e8 b7 0d 00 00       	call   c01050d2 <free_pages>
    free_pages(p1, 3);
c010431b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104322:	00 
c0104323:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104326:	89 04 24             	mov    %eax,(%esp)
c0104329:	e8 a4 0d 00 00       	call   c01050d2 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010432e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104331:	83 c0 04             	add    $0x4,%eax
c0104334:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c010433b:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010433e:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104341:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104344:	0f a3 10             	bt     %edx,(%eax)
c0104347:	19 c0                	sbb    %eax,%eax
c0104349:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010434c:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0104350:	0f 95 c0             	setne  %al
c0104353:	0f b6 c0             	movzbl %al,%eax
c0104356:	85 c0                	test   %eax,%eax
c0104358:	74 0b                	je     c0104365 <default_check+0x3c3>
c010435a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010435d:	8b 40 08             	mov    0x8(%eax),%eax
c0104360:	83 f8 01             	cmp    $0x1,%eax
c0104363:	74 24                	je     c0104389 <default_check+0x3e7>
c0104365:	c7 44 24 0c 5c ca 10 	movl   $0xc010ca5c,0xc(%esp)
c010436c:	c0 
c010436d:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c0104374:	c0 
c0104375:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c010437c:	00 
c010437d:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0104384:	e8 4c ca ff ff       	call   c0100dd5 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104389:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010438c:	83 c0 04             	add    $0x4,%eax
c010438f:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0104396:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104399:	8b 45 90             	mov    -0x70(%ebp),%eax
c010439c:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010439f:	0f a3 10             	bt     %edx,(%eax)
c01043a2:	19 c0                	sbb    %eax,%eax
c01043a4:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01043a7:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01043ab:	0f 95 c0             	setne  %al
c01043ae:	0f b6 c0             	movzbl %al,%eax
c01043b1:	85 c0                	test   %eax,%eax
c01043b3:	74 0b                	je     c01043c0 <default_check+0x41e>
c01043b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043b8:	8b 40 08             	mov    0x8(%eax),%eax
c01043bb:	83 f8 03             	cmp    $0x3,%eax
c01043be:	74 24                	je     c01043e4 <default_check+0x442>
c01043c0:	c7 44 24 0c 84 ca 10 	movl   $0xc010ca84,0xc(%esp)
c01043c7:	c0 
c01043c8:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c01043cf:	c0 
c01043d0:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c01043d7:	00 
c01043d8:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c01043df:	e8 f1 c9 ff ff       	call   c0100dd5 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01043e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01043eb:	e8 77 0c 00 00       	call   c0105067 <alloc_pages>
c01043f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01043f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01043f6:	83 e8 20             	sub    $0x20,%eax
c01043f9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01043fc:	74 24                	je     c0104422 <default_check+0x480>
c01043fe:	c7 44 24 0c aa ca 10 	movl   $0xc010caaa,0xc(%esp)
c0104405:	c0 
c0104406:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c010440d:	c0 
c010440e:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c0104415:	00 
c0104416:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c010441d:	e8 b3 c9 ff ff       	call   c0100dd5 <__panic>
    free_page(p0);
c0104422:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104429:	00 
c010442a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010442d:	89 04 24             	mov    %eax,(%esp)
c0104430:	e8 9d 0c 00 00       	call   c01050d2 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0104435:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010443c:	e8 26 0c 00 00       	call   c0105067 <alloc_pages>
c0104441:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104444:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104447:	83 c0 20             	add    $0x20,%eax
c010444a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010444d:	74 24                	je     c0104473 <default_check+0x4d1>
c010444f:	c7 44 24 0c c8 ca 10 	movl   $0xc010cac8,0xc(%esp)
c0104456:	c0 
c0104457:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c010445e:	c0 
c010445f:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c0104466:	00 
c0104467:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c010446e:	e8 62 c9 ff ff       	call   c0100dd5 <__panic>

    free_pages(p0, 2);
c0104473:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010447a:	00 
c010447b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010447e:	89 04 24             	mov    %eax,(%esp)
c0104481:	e8 4c 0c 00 00       	call   c01050d2 <free_pages>
    free_page(p2);
c0104486:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010448d:	00 
c010448e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104491:	89 04 24             	mov    %eax,(%esp)
c0104494:	e8 39 0c 00 00       	call   c01050d2 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0104499:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01044a0:	e8 c2 0b 00 00       	call   c0105067 <alloc_pages>
c01044a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01044a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01044ac:	75 24                	jne    c01044d2 <default_check+0x530>
c01044ae:	c7 44 24 0c e8 ca 10 	movl   $0xc010cae8,0xc(%esp)
c01044b5:	c0 
c01044b6:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c01044bd:	c0 
c01044be:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c01044c5:	00 
c01044c6:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c01044cd:	e8 03 c9 ff ff       	call   c0100dd5 <__panic>
    assert(alloc_page() == NULL);
c01044d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01044d9:	e8 89 0b 00 00       	call   c0105067 <alloc_pages>
c01044de:	85 c0                	test   %eax,%eax
c01044e0:	74 24                	je     c0104506 <default_check+0x564>
c01044e2:	c7 44 24 0c 46 c9 10 	movl   $0xc010c946,0xc(%esp)
c01044e9:	c0 
c01044ea:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c01044f1:	c0 
c01044f2:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c01044f9:	00 
c01044fa:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c0104501:	e8 cf c8 ff ff       	call   c0100dd5 <__panic>

    assert(nr_free == 0);
c0104506:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c010450b:	85 c0                	test   %eax,%eax
c010450d:	74 24                	je     c0104533 <default_check+0x591>
c010450f:	c7 44 24 0c 99 c9 10 	movl   $0xc010c999,0xc(%esp)
c0104516:	c0 
c0104517:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c010451e:	c0 
c010451f:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0104526:	00 
c0104527:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c010452e:	e8 a2 c8 ff ff       	call   c0100dd5 <__panic>
    nr_free = nr_free_store;
c0104533:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104536:	a3 c0 ef 19 c0       	mov    %eax,0xc019efc0

    free_list = free_list_store;
c010453b:	8b 45 80             	mov    -0x80(%ebp),%eax
c010453e:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104541:	a3 b8 ef 19 c0       	mov    %eax,0xc019efb8
c0104546:	89 15 bc ef 19 c0    	mov    %edx,0xc019efbc
    free_pages(p0, 5);
c010454c:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0104553:	00 
c0104554:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104557:	89 04 24             	mov    %eax,(%esp)
c010455a:	e8 73 0b 00 00       	call   c01050d2 <free_pages>

    le = &free_list;
c010455f:	c7 45 ec b8 ef 19 c0 	movl   $0xc019efb8,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104566:	eb 1d                	jmp    c0104585 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c0104568:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010456b:	83 e8 0c             	sub    $0xc,%eax
c010456e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0104571:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104575:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104578:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010457b:	8b 40 08             	mov    0x8(%eax),%eax
c010457e:	29 c2                	sub    %eax,%edx
c0104580:	89 d0                	mov    %edx,%eax
c0104582:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104585:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104588:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010458b:	8b 45 88             	mov    -0x78(%ebp),%eax
c010458e:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104591:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104594:	81 7d ec b8 ef 19 c0 	cmpl   $0xc019efb8,-0x14(%ebp)
c010459b:	75 cb                	jne    c0104568 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c010459d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01045a1:	74 24                	je     c01045c7 <default_check+0x625>
c01045a3:	c7 44 24 0c 06 cb 10 	movl   $0xc010cb06,0xc(%esp)
c01045aa:	c0 
c01045ab:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c01045b2:	c0 
c01045b3:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c01045ba:	00 
c01045bb:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c01045c2:	e8 0e c8 ff ff       	call   c0100dd5 <__panic>
    assert(total == 0);
c01045c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01045cb:	74 24                	je     c01045f1 <default_check+0x64f>
c01045cd:	c7 44 24 0c 11 cb 10 	movl   $0xc010cb11,0xc(%esp)
c01045d4:	c0 
c01045d5:	c7 44 24 08 d6 c7 10 	movl   $0xc010c7d6,0x8(%esp)
c01045dc:	c0 
c01045dd:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c01045e4:	00 
c01045e5:	c7 04 24 eb c7 10 c0 	movl   $0xc010c7eb,(%esp)
c01045ec:	e8 e4 c7 ff ff       	call   c0100dd5 <__panic>
}
c01045f1:	81 c4 94 00 00 00    	add    $0x94,%esp
c01045f7:	5b                   	pop    %ebx
c01045f8:	5d                   	pop    %ebp
c01045f9:	c3                   	ret    

c01045fa <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c01045fa:	55                   	push   %ebp
c01045fb:	89 e5                	mov    %esp,%ebp
c01045fd:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104600:	9c                   	pushf  
c0104601:	58                   	pop    %eax
c0104602:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104605:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104608:	25 00 02 00 00       	and    $0x200,%eax
c010460d:	85 c0                	test   %eax,%eax
c010460f:	74 0c                	je     c010461d <__intr_save+0x23>
        intr_disable();
c0104611:	e8 17 da ff ff       	call   c010202d <intr_disable>
        return 1;
c0104616:	b8 01 00 00 00       	mov    $0x1,%eax
c010461b:	eb 05                	jmp    c0104622 <__intr_save+0x28>
    }
    return 0;
c010461d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104622:	c9                   	leave  
c0104623:	c3                   	ret    

c0104624 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0104624:	55                   	push   %ebp
c0104625:	89 e5                	mov    %esp,%ebp
c0104627:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010462a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010462e:	74 05                	je     c0104635 <__intr_restore+0x11>
        intr_enable();
c0104630:	e8 f2 d9 ff ff       	call   c0102027 <intr_enable>
    }
}
c0104635:	c9                   	leave  
c0104636:	c3                   	ret    

c0104637 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104637:	55                   	push   %ebp
c0104638:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010463a:	8b 55 08             	mov    0x8(%ebp),%edx
c010463d:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0104642:	29 c2                	sub    %eax,%edx
c0104644:	89 d0                	mov    %edx,%eax
c0104646:	c1 f8 05             	sar    $0x5,%eax
}
c0104649:	5d                   	pop    %ebp
c010464a:	c3                   	ret    

c010464b <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010464b:	55                   	push   %ebp
c010464c:	89 e5                	mov    %esp,%ebp
c010464e:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104651:	8b 45 08             	mov    0x8(%ebp),%eax
c0104654:	89 04 24             	mov    %eax,(%esp)
c0104657:	e8 db ff ff ff       	call   c0104637 <page2ppn>
c010465c:	c1 e0 0c             	shl    $0xc,%eax
}
c010465f:	c9                   	leave  
c0104660:	c3                   	ret    

c0104661 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104661:	55                   	push   %ebp
c0104662:	89 e5                	mov    %esp,%ebp
c0104664:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104667:	8b 45 08             	mov    0x8(%ebp),%eax
c010466a:	c1 e8 0c             	shr    $0xc,%eax
c010466d:	89 c2                	mov    %eax,%edx
c010466f:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0104674:	39 c2                	cmp    %eax,%edx
c0104676:	72 1c                	jb     c0104694 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104678:	c7 44 24 08 4c cb 10 	movl   $0xc010cb4c,0x8(%esp)
c010467f:	c0 
c0104680:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104687:	00 
c0104688:	c7 04 24 6b cb 10 c0 	movl   $0xc010cb6b,(%esp)
c010468f:	e8 41 c7 ff ff       	call   c0100dd5 <__panic>
    }
    return &pages[PPN(pa)];
c0104694:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0104699:	8b 55 08             	mov    0x8(%ebp),%edx
c010469c:	c1 ea 0c             	shr    $0xc,%edx
c010469f:	c1 e2 05             	shl    $0x5,%edx
c01046a2:	01 d0                	add    %edx,%eax
}
c01046a4:	c9                   	leave  
c01046a5:	c3                   	ret    

c01046a6 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01046a6:	55                   	push   %ebp
c01046a7:	89 e5                	mov    %esp,%ebp
c01046a9:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01046ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01046af:	89 04 24             	mov    %eax,(%esp)
c01046b2:	e8 94 ff ff ff       	call   c010464b <page2pa>
c01046b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046bd:	c1 e8 0c             	shr    $0xc,%eax
c01046c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01046c3:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c01046c8:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01046cb:	72 23                	jb     c01046f0 <page2kva+0x4a>
c01046cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01046d4:	c7 44 24 08 7c cb 10 	movl   $0xc010cb7c,0x8(%esp)
c01046db:	c0 
c01046dc:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01046e3:	00 
c01046e4:	c7 04 24 6b cb 10 c0 	movl   $0xc010cb6b,(%esp)
c01046eb:	e8 e5 c6 ff ff       	call   c0100dd5 <__panic>
c01046f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046f3:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01046f8:	c9                   	leave  
c01046f9:	c3                   	ret    

c01046fa <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01046fa:	55                   	push   %ebp
c01046fb:	89 e5                	mov    %esp,%ebp
c01046fd:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0104700:	8b 45 08             	mov    0x8(%ebp),%eax
c0104703:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104706:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010470d:	77 23                	ja     c0104732 <kva2page+0x38>
c010470f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104712:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104716:	c7 44 24 08 a0 cb 10 	movl   $0xc010cba0,0x8(%esp)
c010471d:	c0 
c010471e:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0104725:	00 
c0104726:	c7 04 24 6b cb 10 c0 	movl   $0xc010cb6b,(%esp)
c010472d:	e8 a3 c6 ff ff       	call   c0100dd5 <__panic>
c0104732:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104735:	05 00 00 00 40       	add    $0x40000000,%eax
c010473a:	89 04 24             	mov    %eax,(%esp)
c010473d:	e8 1f ff ff ff       	call   c0104661 <pa2page>
}
c0104742:	c9                   	leave  
c0104743:	c3                   	ret    

c0104744 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0104744:	55                   	push   %ebp
c0104745:	89 e5                	mov    %esp,%ebp
c0104747:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c010474a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010474d:	ba 01 00 00 00       	mov    $0x1,%edx
c0104752:	89 c1                	mov    %eax,%ecx
c0104754:	d3 e2                	shl    %cl,%edx
c0104756:	89 d0                	mov    %edx,%eax
c0104758:	89 04 24             	mov    %eax,(%esp)
c010475b:	e8 07 09 00 00       	call   c0105067 <alloc_pages>
c0104760:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0104763:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104767:	75 07                	jne    c0104770 <__slob_get_free_pages+0x2c>
    return NULL;
c0104769:	b8 00 00 00 00       	mov    $0x0,%eax
c010476e:	eb 0b                	jmp    c010477b <__slob_get_free_pages+0x37>
  return page2kva(page);
c0104770:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104773:	89 04 24             	mov    %eax,(%esp)
c0104776:	e8 2b ff ff ff       	call   c01046a6 <page2kva>
}
c010477b:	c9                   	leave  
c010477c:	c3                   	ret    

c010477d <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c010477d:	55                   	push   %ebp
c010477e:	89 e5                	mov    %esp,%ebp
c0104780:	53                   	push   %ebx
c0104781:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c0104784:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104787:	ba 01 00 00 00       	mov    $0x1,%edx
c010478c:	89 c1                	mov    %eax,%ecx
c010478e:	d3 e2                	shl    %cl,%edx
c0104790:	89 d0                	mov    %edx,%eax
c0104792:	89 c3                	mov    %eax,%ebx
c0104794:	8b 45 08             	mov    0x8(%ebp),%eax
c0104797:	89 04 24             	mov    %eax,(%esp)
c010479a:	e8 5b ff ff ff       	call   c01046fa <kva2page>
c010479f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01047a3:	89 04 24             	mov    %eax,(%esp)
c01047a6:	e8 27 09 00 00       	call   c01050d2 <free_pages>
}
c01047ab:	83 c4 14             	add    $0x14,%esp
c01047ae:	5b                   	pop    %ebx
c01047af:	5d                   	pop    %ebp
c01047b0:	c3                   	ret    

c01047b1 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c01047b1:	55                   	push   %ebp
c01047b2:	89 e5                	mov    %esp,%ebp
c01047b4:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c01047b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01047ba:	83 c0 08             	add    $0x8,%eax
c01047bd:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c01047c2:	76 24                	jbe    c01047e8 <slob_alloc+0x37>
c01047c4:	c7 44 24 0c c4 cb 10 	movl   $0xc010cbc4,0xc(%esp)
c01047cb:	c0 
c01047cc:	c7 44 24 08 e3 cb 10 	movl   $0xc010cbe3,0x8(%esp)
c01047d3:	c0 
c01047d4:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01047db:	00 
c01047dc:	c7 04 24 f8 cb 10 c0 	movl   $0xc010cbf8,(%esp)
c01047e3:	e8 ed c5 ff ff       	call   c0100dd5 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c01047e8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c01047ef:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01047f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01047f9:	83 c0 07             	add    $0x7,%eax
c01047fc:	c1 e8 03             	shr    $0x3,%eax
c01047ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0104802:	e8 f3 fd ff ff       	call   c01045fa <__intr_save>
c0104807:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c010480a:	a1 08 aa 12 c0       	mov    0xc012aa08,%eax
c010480f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104812:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104815:	8b 40 04             	mov    0x4(%eax),%eax
c0104818:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c010481b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010481f:	74 25                	je     c0104846 <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c0104821:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104824:	8b 45 10             	mov    0x10(%ebp),%eax
c0104827:	01 d0                	add    %edx,%eax
c0104829:	8d 50 ff             	lea    -0x1(%eax),%edx
c010482c:	8b 45 10             	mov    0x10(%ebp),%eax
c010482f:	f7 d8                	neg    %eax
c0104831:	21 d0                	and    %edx,%eax
c0104833:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0104836:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104839:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010483c:	29 c2                	sub    %eax,%edx
c010483e:	89 d0                	mov    %edx,%eax
c0104840:	c1 f8 03             	sar    $0x3,%eax
c0104843:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0104846:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104849:	8b 00                	mov    (%eax),%eax
c010484b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010484e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0104851:	01 ca                	add    %ecx,%edx
c0104853:	39 d0                	cmp    %edx,%eax
c0104855:	0f 8c aa 00 00 00    	jl     c0104905 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c010485b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010485f:	74 38                	je     c0104899 <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c0104861:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104864:	8b 00                	mov    (%eax),%eax
c0104866:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0104869:	89 c2                	mov    %eax,%edx
c010486b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010486e:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0104870:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104873:	8b 50 04             	mov    0x4(%eax),%edx
c0104876:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104879:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c010487c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010487f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104882:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0104885:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104888:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010488b:	89 10                	mov    %edx,(%eax)
				prev = cur;
c010488d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104890:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0104893:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104896:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0104899:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010489c:	8b 00                	mov    (%eax),%eax
c010489e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01048a1:	75 0e                	jne    c01048b1 <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c01048a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048a6:	8b 50 04             	mov    0x4(%eax),%edx
c01048a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048ac:	89 50 04             	mov    %edx,0x4(%eax)
c01048af:	eb 3c                	jmp    c01048ed <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c01048b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048b4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01048bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048be:	01 c2                	add    %eax,%edx
c01048c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048c3:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c01048c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048c9:	8b 40 04             	mov    0x4(%eax),%eax
c01048cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01048cf:	8b 12                	mov    (%edx),%edx
c01048d1:	2b 55 e0             	sub    -0x20(%ebp),%edx
c01048d4:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c01048d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048d9:	8b 40 04             	mov    0x4(%eax),%eax
c01048dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01048df:	8b 52 04             	mov    0x4(%edx),%edx
c01048e2:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c01048e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01048eb:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c01048ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048f0:	a3 08 aa 12 c0       	mov    %eax,0xc012aa08
			spin_unlock_irqrestore(&slob_lock, flags);
c01048f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048f8:	89 04 24             	mov    %eax,(%esp)
c01048fb:	e8 24 fd ff ff       	call   c0104624 <__intr_restore>
			return cur;
c0104900:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104903:	eb 7f                	jmp    c0104984 <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c0104905:	a1 08 aa 12 c0       	mov    0xc012aa08,%eax
c010490a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010490d:	75 61                	jne    c0104970 <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c010490f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104912:	89 04 24             	mov    %eax,(%esp)
c0104915:	e8 0a fd ff ff       	call   c0104624 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c010491a:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104921:	75 07                	jne    c010492a <slob_alloc+0x179>
				return 0;
c0104923:	b8 00 00 00 00       	mov    $0x0,%eax
c0104928:	eb 5a                	jmp    c0104984 <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c010492a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104931:	00 
c0104932:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104935:	89 04 24             	mov    %eax,(%esp)
c0104938:	e8 07 fe ff ff       	call   c0104744 <__slob_get_free_pages>
c010493d:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0104940:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104944:	75 07                	jne    c010494d <slob_alloc+0x19c>
				return 0;
c0104946:	b8 00 00 00 00       	mov    $0x0,%eax
c010494b:	eb 37                	jmp    c0104984 <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c010494d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104954:	00 
c0104955:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104958:	89 04 24             	mov    %eax,(%esp)
c010495b:	e8 26 00 00 00       	call   c0104986 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0104960:	e8 95 fc ff ff       	call   c01045fa <__intr_save>
c0104965:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0104968:	a1 08 aa 12 c0       	mov    0xc012aa08,%eax
c010496d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104970:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104973:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104976:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104979:	8b 40 04             	mov    0x4(%eax),%eax
c010497c:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c010497f:	e9 97 fe ff ff       	jmp    c010481b <slob_alloc+0x6a>
}
c0104984:	c9                   	leave  
c0104985:	c3                   	ret    

c0104986 <slob_free>:

static void slob_free(void *block, int size)
{
c0104986:	55                   	push   %ebp
c0104987:	89 e5                	mov    %esp,%ebp
c0104989:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c010498c:	8b 45 08             	mov    0x8(%ebp),%eax
c010498f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104992:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104996:	75 05                	jne    c010499d <slob_free+0x17>
		return;
c0104998:	e9 ff 00 00 00       	jmp    c0104a9c <slob_free+0x116>

	if (size)
c010499d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01049a1:	74 10                	je     c01049b3 <slob_free+0x2d>
		b->units = SLOB_UNITS(size);
c01049a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01049a6:	83 c0 07             	add    $0x7,%eax
c01049a9:	c1 e8 03             	shr    $0x3,%eax
c01049ac:	89 c2                	mov    %eax,%edx
c01049ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049b1:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c01049b3:	e8 42 fc ff ff       	call   c01045fa <__intr_save>
c01049b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01049bb:	a1 08 aa 12 c0       	mov    0xc012aa08,%eax
c01049c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01049c3:	eb 27                	jmp    c01049ec <slob_free+0x66>
		if (cur >= cur->next && (b > cur || b < cur->next))
c01049c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049c8:	8b 40 04             	mov    0x4(%eax),%eax
c01049cb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01049ce:	77 13                	ja     c01049e3 <slob_free+0x5d>
c01049d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049d3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01049d6:	77 27                	ja     c01049ff <slob_free+0x79>
c01049d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049db:	8b 40 04             	mov    0x4(%eax),%eax
c01049de:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01049e1:	77 1c                	ja     c01049ff <slob_free+0x79>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01049e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049e6:	8b 40 04             	mov    0x4(%eax),%eax
c01049e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01049ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049ef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01049f2:	76 d1                	jbe    c01049c5 <slob_free+0x3f>
c01049f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049f7:	8b 40 04             	mov    0x4(%eax),%eax
c01049fa:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01049fd:	76 c6                	jbe    c01049c5 <slob_free+0x3f>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c01049ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a02:	8b 00                	mov    (%eax),%eax
c0104a04:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104a0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a0e:	01 c2                	add    %eax,%edx
c0104a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a13:	8b 40 04             	mov    0x4(%eax),%eax
c0104a16:	39 c2                	cmp    %eax,%edx
c0104a18:	75 25                	jne    c0104a3f <slob_free+0xb9>
		b->units += cur->next->units;
c0104a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a1d:	8b 10                	mov    (%eax),%edx
c0104a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a22:	8b 40 04             	mov    0x4(%eax),%eax
c0104a25:	8b 00                	mov    (%eax),%eax
c0104a27:	01 c2                	add    %eax,%edx
c0104a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a2c:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0104a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a31:	8b 40 04             	mov    0x4(%eax),%eax
c0104a34:	8b 50 04             	mov    0x4(%eax),%edx
c0104a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a3a:	89 50 04             	mov    %edx,0x4(%eax)
c0104a3d:	eb 0c                	jmp    c0104a4b <slob_free+0xc5>
	} else
		b->next = cur->next;
c0104a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a42:	8b 50 04             	mov    0x4(%eax),%edx
c0104a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a48:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0104a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a4e:	8b 00                	mov    (%eax),%eax
c0104a50:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a5a:	01 d0                	add    %edx,%eax
c0104a5c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104a5f:	75 1f                	jne    c0104a80 <slob_free+0xfa>
		cur->units += b->units;
c0104a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a64:	8b 10                	mov    (%eax),%edx
c0104a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a69:	8b 00                	mov    (%eax),%eax
c0104a6b:	01 c2                	add    %eax,%edx
c0104a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a70:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0104a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a75:	8b 50 04             	mov    0x4(%eax),%edx
c0104a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a7b:	89 50 04             	mov    %edx,0x4(%eax)
c0104a7e:	eb 09                	jmp    c0104a89 <slob_free+0x103>
	} else
		cur->next = b;
c0104a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a83:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104a86:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0104a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a8c:	a3 08 aa 12 c0       	mov    %eax,0xc012aa08

	spin_unlock_irqrestore(&slob_lock, flags);
c0104a91:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a94:	89 04 24             	mov    %eax,(%esp)
c0104a97:	e8 88 fb ff ff       	call   c0104624 <__intr_restore>
}
c0104a9c:	c9                   	leave  
c0104a9d:	c3                   	ret    

c0104a9e <slob_init>:



void
slob_init(void) {
c0104a9e:	55                   	push   %ebp
c0104a9f:	89 e5                	mov    %esp,%ebp
c0104aa1:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0104aa4:	c7 04 24 0a cc 10 c0 	movl   $0xc010cc0a,(%esp)
c0104aab:	e8 a3 b8 ff ff       	call   c0100353 <cprintf>
}
c0104ab0:	c9                   	leave  
c0104ab1:	c3                   	ret    

c0104ab2 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0104ab2:	55                   	push   %ebp
c0104ab3:	89 e5                	mov    %esp,%ebp
c0104ab5:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c0104ab8:	e8 e1 ff ff ff       	call   c0104a9e <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0104abd:	c7 04 24 1e cc 10 c0 	movl   $0xc010cc1e,(%esp)
c0104ac4:	e8 8a b8 ff ff       	call   c0100353 <cprintf>
}
c0104ac9:	c9                   	leave  
c0104aca:	c3                   	ret    

c0104acb <slob_allocated>:

size_t
slob_allocated(void) {
c0104acb:	55                   	push   %ebp
c0104acc:	89 e5                	mov    %esp,%ebp
  return 0;
c0104ace:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104ad3:	5d                   	pop    %ebp
c0104ad4:	c3                   	ret    

c0104ad5 <kallocated>:

size_t
kallocated(void) {
c0104ad5:	55                   	push   %ebp
c0104ad6:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0104ad8:	e8 ee ff ff ff       	call   c0104acb <slob_allocated>
}
c0104add:	5d                   	pop    %ebp
c0104ade:	c3                   	ret    

c0104adf <find_order>:

static int find_order(int size)
{
c0104adf:	55                   	push   %ebp
c0104ae0:	89 e5                	mov    %esp,%ebp
c0104ae2:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0104ae5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104aec:	eb 07                	jmp    c0104af5 <find_order+0x16>
		order++;
c0104aee:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c0104af2:	d1 7d 08             	sarl   0x8(%ebp)
c0104af5:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104afc:	7f f0                	jg     c0104aee <find_order+0xf>
		order++;
	return order;
c0104afe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104b01:	c9                   	leave  
c0104b02:	c3                   	ret    

c0104b03 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0104b03:	55                   	push   %ebp
c0104b04:	89 e5                	mov    %esp,%ebp
c0104b06:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0104b09:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0104b10:	77 38                	ja     c0104b4a <__kmalloc+0x47>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0104b12:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b15:	8d 50 08             	lea    0x8(%eax),%edx
c0104b18:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b1f:	00 
c0104b20:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b23:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b27:	89 14 24             	mov    %edx,(%esp)
c0104b2a:	e8 82 fc ff ff       	call   c01047b1 <slob_alloc>
c0104b2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0104b32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104b36:	74 08                	je     c0104b40 <__kmalloc+0x3d>
c0104b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b3b:	83 c0 08             	add    $0x8,%eax
c0104b3e:	eb 05                	jmp    c0104b45 <__kmalloc+0x42>
c0104b40:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b45:	e9 a6 00 00 00       	jmp    c0104bf0 <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0104b4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b51:	00 
c0104b52:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b55:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b59:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0104b60:	e8 4c fc ff ff       	call   c01047b1 <slob_alloc>
c0104b65:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0104b68:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b6c:	75 07                	jne    c0104b75 <__kmalloc+0x72>
		return 0;
c0104b6e:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b73:	eb 7b                	jmp    c0104bf0 <__kmalloc+0xed>

	bb->order = find_order(size);
c0104b75:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b78:	89 04 24             	mov    %eax,(%esp)
c0104b7b:	e8 5f ff ff ff       	call   c0104adf <find_order>
c0104b80:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104b83:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b88:	8b 00                	mov    (%eax),%eax
c0104b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b91:	89 04 24             	mov    %eax,(%esp)
c0104b94:	e8 ab fb ff ff       	call   c0104744 <__slob_get_free_pages>
c0104b99:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104b9c:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0104b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ba2:	8b 40 04             	mov    0x4(%eax),%eax
c0104ba5:	85 c0                	test   %eax,%eax
c0104ba7:	74 2f                	je     c0104bd8 <__kmalloc+0xd5>
		spin_lock_irqsave(&block_lock, flags);
c0104ba9:	e8 4c fa ff ff       	call   c01045fa <__intr_save>
c0104bae:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c0104bb1:	8b 15 c4 ce 19 c0    	mov    0xc019cec4,%edx
c0104bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bba:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bc0:	a3 c4 ce 19 c0       	mov    %eax,0xc019cec4
		spin_unlock_irqrestore(&block_lock, flags);
c0104bc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bc8:	89 04 24             	mov    %eax,(%esp)
c0104bcb:	e8 54 fa ff ff       	call   c0104624 <__intr_restore>
		return bb->pages;
c0104bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bd3:	8b 40 04             	mov    0x4(%eax),%eax
c0104bd6:	eb 18                	jmp    c0104bf0 <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c0104bd8:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104bdf:	00 
c0104be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104be3:	89 04 24             	mov    %eax,(%esp)
c0104be6:	e8 9b fd ff ff       	call   c0104986 <slob_free>
	return 0;
c0104beb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104bf0:	c9                   	leave  
c0104bf1:	c3                   	ret    

c0104bf2 <kmalloc>:

void *
kmalloc(size_t size)
{
c0104bf2:	55                   	push   %ebp
c0104bf3:	89 e5                	mov    %esp,%ebp
c0104bf5:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0104bf8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104bff:	00 
c0104c00:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c03:	89 04 24             	mov    %eax,(%esp)
c0104c06:	e8 f8 fe ff ff       	call   c0104b03 <__kmalloc>
}
c0104c0b:	c9                   	leave  
c0104c0c:	c3                   	ret    

c0104c0d <kfree>:


void kfree(void *block)
{
c0104c0d:	55                   	push   %ebp
c0104c0e:	89 e5                	mov    %esp,%ebp
c0104c10:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0104c13:	c7 45 f0 c4 ce 19 c0 	movl   $0xc019cec4,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104c1a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104c1e:	75 05                	jne    c0104c25 <kfree+0x18>
		return;
c0104c20:	e9 a2 00 00 00       	jmp    c0104cc7 <kfree+0xba>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104c25:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c28:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104c2d:	85 c0                	test   %eax,%eax
c0104c2f:	75 7f                	jne    c0104cb0 <kfree+0xa3>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0104c31:	e8 c4 f9 ff ff       	call   c01045fa <__intr_save>
c0104c36:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104c39:	a1 c4 ce 19 c0       	mov    0xc019cec4,%eax
c0104c3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c41:	eb 5c                	jmp    c0104c9f <kfree+0x92>
			if (bb->pages == block) {
c0104c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c46:	8b 40 04             	mov    0x4(%eax),%eax
c0104c49:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104c4c:	75 3f                	jne    c0104c8d <kfree+0x80>
				*last = bb->next;
c0104c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c51:	8b 50 08             	mov    0x8(%eax),%edx
c0104c54:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c57:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0104c59:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c5c:	89 04 24             	mov    %eax,(%esp)
c0104c5f:	e8 c0 f9 ff ff       	call   c0104624 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0104c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c67:	8b 10                	mov    (%eax),%edx
c0104c69:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c6c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104c70:	89 04 24             	mov    %eax,(%esp)
c0104c73:	e8 05 fb ff ff       	call   c010477d <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0104c78:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104c7f:	00 
c0104c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c83:	89 04 24             	mov    %eax,(%esp)
c0104c86:	e8 fb fc ff ff       	call   c0104986 <slob_free>
				return;
c0104c8b:	eb 3a                	jmp    c0104cc7 <kfree+0xba>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c90:	83 c0 08             	add    $0x8,%eax
c0104c93:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c99:	8b 40 08             	mov    0x8(%eax),%eax
c0104c9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104ca3:	75 9e                	jne    c0104c43 <kfree+0x36>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0104ca5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ca8:	89 04 24             	mov    %eax,(%esp)
c0104cab:	e8 74 f9 ff ff       	call   c0104624 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0104cb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cb3:	83 e8 08             	sub    $0x8,%eax
c0104cb6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104cbd:	00 
c0104cbe:	89 04 24             	mov    %eax,(%esp)
c0104cc1:	e8 c0 fc ff ff       	call   c0104986 <slob_free>
	return;
c0104cc6:	90                   	nop
}
c0104cc7:	c9                   	leave  
c0104cc8:	c3                   	ret    

c0104cc9 <ksize>:


unsigned int ksize(const void *block)
{
c0104cc9:	55                   	push   %ebp
c0104cca:	89 e5                	mov    %esp,%ebp
c0104ccc:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0104ccf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104cd3:	75 07                	jne    c0104cdc <ksize+0x13>
		return 0;
c0104cd5:	b8 00 00 00 00       	mov    $0x0,%eax
c0104cda:	eb 6b                	jmp    c0104d47 <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104cdc:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cdf:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104ce4:	85 c0                	test   %eax,%eax
c0104ce6:	75 54                	jne    c0104d3c <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0104ce8:	e8 0d f9 ff ff       	call   c01045fa <__intr_save>
c0104ced:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0104cf0:	a1 c4 ce 19 c0       	mov    0xc019cec4,%eax
c0104cf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104cf8:	eb 31                	jmp    c0104d2b <ksize+0x62>
			if (bb->pages == block) {
c0104cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cfd:	8b 40 04             	mov    0x4(%eax),%eax
c0104d00:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104d03:	75 1d                	jne    c0104d22 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0104d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d08:	89 04 24             	mov    %eax,(%esp)
c0104d0b:	e8 14 f9 ff ff       	call   c0104624 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0104d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d13:	8b 00                	mov    (%eax),%eax
c0104d15:	ba 00 10 00 00       	mov    $0x1000,%edx
c0104d1a:	89 c1                	mov    %eax,%ecx
c0104d1c:	d3 e2                	shl    %cl,%edx
c0104d1e:	89 d0                	mov    %edx,%eax
c0104d20:	eb 25                	jmp    c0104d47 <ksize+0x7e>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c0104d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d25:	8b 40 08             	mov    0x8(%eax),%eax
c0104d28:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104d2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104d2f:	75 c9                	jne    c0104cfa <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0104d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d34:	89 04 24             	mov    %eax,(%esp)
c0104d37:	e8 e8 f8 ff ff       	call   c0104624 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0104d3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d3f:	83 e8 08             	sub    $0x8,%eax
c0104d42:	8b 00                	mov    (%eax),%eax
c0104d44:	c1 e0 03             	shl    $0x3,%eax
}
c0104d47:	c9                   	leave  
c0104d48:	c3                   	ret    

c0104d49 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104d49:	55                   	push   %ebp
c0104d4a:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104d4c:	8b 55 08             	mov    0x8(%ebp),%edx
c0104d4f:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0104d54:	29 c2                	sub    %eax,%edx
c0104d56:	89 d0                	mov    %edx,%eax
c0104d58:	c1 f8 05             	sar    $0x5,%eax
}
c0104d5b:	5d                   	pop    %ebp
c0104d5c:	c3                   	ret    

c0104d5d <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104d5d:	55                   	push   %ebp
c0104d5e:	89 e5                	mov    %esp,%ebp
c0104d60:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104d63:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d66:	89 04 24             	mov    %eax,(%esp)
c0104d69:	e8 db ff ff ff       	call   c0104d49 <page2ppn>
c0104d6e:	c1 e0 0c             	shl    $0xc,%eax
}
c0104d71:	c9                   	leave  
c0104d72:	c3                   	ret    

c0104d73 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104d73:	55                   	push   %ebp
c0104d74:	89 e5                	mov    %esp,%ebp
c0104d76:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104d79:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d7c:	c1 e8 0c             	shr    $0xc,%eax
c0104d7f:	89 c2                	mov    %eax,%edx
c0104d81:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0104d86:	39 c2                	cmp    %eax,%edx
c0104d88:	72 1c                	jb     c0104da6 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104d8a:	c7 44 24 08 3c cc 10 	movl   $0xc010cc3c,0x8(%esp)
c0104d91:	c0 
c0104d92:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104d99:	00 
c0104d9a:	c7 04 24 5b cc 10 c0 	movl   $0xc010cc5b,(%esp)
c0104da1:	e8 2f c0 ff ff       	call   c0100dd5 <__panic>
    }
    return &pages[PPN(pa)];
c0104da6:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0104dab:	8b 55 08             	mov    0x8(%ebp),%edx
c0104dae:	c1 ea 0c             	shr    $0xc,%edx
c0104db1:	c1 e2 05             	shl    $0x5,%edx
c0104db4:	01 d0                	add    %edx,%eax
}
c0104db6:	c9                   	leave  
c0104db7:	c3                   	ret    

c0104db8 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0104db8:	55                   	push   %ebp
c0104db9:	89 e5                	mov    %esp,%ebp
c0104dbb:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104dbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dc1:	89 04 24             	mov    %eax,(%esp)
c0104dc4:	e8 94 ff ff ff       	call   c0104d5d <page2pa>
c0104dc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dcf:	c1 e8 0c             	shr    $0xc,%eax
c0104dd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104dd5:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0104dda:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104ddd:	72 23                	jb     c0104e02 <page2kva+0x4a>
c0104ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104de2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104de6:	c7 44 24 08 6c cc 10 	movl   $0xc010cc6c,0x8(%esp)
c0104ded:	c0 
c0104dee:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0104df5:	00 
c0104df6:	c7 04 24 5b cc 10 c0 	movl   $0xc010cc5b,(%esp)
c0104dfd:	e8 d3 bf ff ff       	call   c0100dd5 <__panic>
c0104e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e05:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104e0a:	c9                   	leave  
c0104e0b:	c3                   	ret    

c0104e0c <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0104e0c:	55                   	push   %ebp
c0104e0d:	89 e5                	mov    %esp,%ebp
c0104e0f:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104e12:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e15:	83 e0 01             	and    $0x1,%eax
c0104e18:	85 c0                	test   %eax,%eax
c0104e1a:	75 1c                	jne    c0104e38 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104e1c:	c7 44 24 08 90 cc 10 	movl   $0xc010cc90,0x8(%esp)
c0104e23:	c0 
c0104e24:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0104e2b:	00 
c0104e2c:	c7 04 24 5b cc 10 c0 	movl   $0xc010cc5b,(%esp)
c0104e33:	e8 9d bf ff ff       	call   c0100dd5 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0104e38:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e40:	89 04 24             	mov    %eax,(%esp)
c0104e43:	e8 2b ff ff ff       	call   c0104d73 <pa2page>
}
c0104e48:	c9                   	leave  
c0104e49:	c3                   	ret    

c0104e4a <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0104e4a:	55                   	push   %ebp
c0104e4b:	89 e5                	mov    %esp,%ebp
c0104e4d:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0104e50:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e58:	89 04 24             	mov    %eax,(%esp)
c0104e5b:	e8 13 ff ff ff       	call   c0104d73 <pa2page>
}
c0104e60:	c9                   	leave  
c0104e61:	c3                   	ret    

c0104e62 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0104e62:	55                   	push   %ebp
c0104e63:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104e65:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e68:	8b 00                	mov    (%eax),%eax
}
c0104e6a:	5d                   	pop    %ebp
c0104e6b:	c3                   	ret    

c0104e6c <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0104e6c:	55                   	push   %ebp
c0104e6d:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104e6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e72:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104e75:	89 10                	mov    %edx,(%eax)
}
c0104e77:	5d                   	pop    %ebp
c0104e78:	c3                   	ret    

c0104e79 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0104e79:	55                   	push   %ebp
c0104e7a:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0104e7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e7f:	8b 00                	mov    (%eax),%eax
c0104e81:	8d 50 01             	lea    0x1(%eax),%edx
c0104e84:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e87:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104e89:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e8c:	8b 00                	mov    (%eax),%eax
}
c0104e8e:	5d                   	pop    %ebp
c0104e8f:	c3                   	ret    

c0104e90 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0104e90:	55                   	push   %ebp
c0104e91:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104e93:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e96:	8b 00                	mov    (%eax),%eax
c0104e98:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104e9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e9e:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104ea0:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ea3:	8b 00                	mov    (%eax),%eax
}
c0104ea5:	5d                   	pop    %ebp
c0104ea6:	c3                   	ret    

c0104ea7 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0104ea7:	55                   	push   %ebp
c0104ea8:	89 e5                	mov    %esp,%ebp
c0104eaa:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104ead:	9c                   	pushf  
c0104eae:	58                   	pop    %eax
c0104eaf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104eb5:	25 00 02 00 00       	and    $0x200,%eax
c0104eba:	85 c0                	test   %eax,%eax
c0104ebc:	74 0c                	je     c0104eca <__intr_save+0x23>
        intr_disable();
c0104ebe:	e8 6a d1 ff ff       	call   c010202d <intr_disable>
        return 1;
c0104ec3:	b8 01 00 00 00       	mov    $0x1,%eax
c0104ec8:	eb 05                	jmp    c0104ecf <__intr_save+0x28>
    }
    return 0;
c0104eca:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104ecf:	c9                   	leave  
c0104ed0:	c3                   	ret    

c0104ed1 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0104ed1:	55                   	push   %ebp
c0104ed2:	89 e5                	mov    %esp,%ebp
c0104ed4:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104ed7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104edb:	74 05                	je     c0104ee2 <__intr_restore+0x11>
        intr_enable();
c0104edd:	e8 45 d1 ff ff       	call   c0102027 <intr_enable>
    }
}
c0104ee2:	c9                   	leave  
c0104ee3:	c3                   	ret    

c0104ee4 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0104ee4:	55                   	push   %ebp
c0104ee5:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0104ee7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104eea:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0104eed:	b8 23 00 00 00       	mov    $0x23,%eax
c0104ef2:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0104ef4:	b8 23 00 00 00       	mov    $0x23,%eax
c0104ef9:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0104efb:	b8 10 00 00 00       	mov    $0x10,%eax
c0104f00:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0104f02:	b8 10 00 00 00       	mov    $0x10,%eax
c0104f07:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0104f09:	b8 10 00 00 00       	mov    $0x10,%eax
c0104f0e:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0104f10:	ea 17 4f 10 c0 08 00 	ljmp   $0x8,$0xc0104f17
}
c0104f17:	5d                   	pop    %ebp
c0104f18:	c3                   	ret    

c0104f19 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104f19:	55                   	push   %ebp
c0104f1a:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0104f1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f1f:	a3 04 cf 19 c0       	mov    %eax,0xc019cf04
}
c0104f24:	5d                   	pop    %ebp
c0104f25:	c3                   	ret    

c0104f26 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0104f26:	55                   	push   %ebp
c0104f27:	89 e5                	mov    %esp,%ebp
c0104f29:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104f2c:	b8 00 a0 12 c0       	mov    $0xc012a000,%eax
c0104f31:	89 04 24             	mov    %eax,(%esp)
c0104f34:	e8 e0 ff ff ff       	call   c0104f19 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104f39:	66 c7 05 08 cf 19 c0 	movw   $0x10,0xc019cf08
c0104f40:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104f42:	66 c7 05 48 aa 12 c0 	movw   $0x68,0xc012aa48
c0104f49:	68 00 
c0104f4b:	b8 00 cf 19 c0       	mov    $0xc019cf00,%eax
c0104f50:	66 a3 4a aa 12 c0    	mov    %ax,0xc012aa4a
c0104f56:	b8 00 cf 19 c0       	mov    $0xc019cf00,%eax
c0104f5b:	c1 e8 10             	shr    $0x10,%eax
c0104f5e:	a2 4c aa 12 c0       	mov    %al,0xc012aa4c
c0104f63:	0f b6 05 4d aa 12 c0 	movzbl 0xc012aa4d,%eax
c0104f6a:	83 e0 f0             	and    $0xfffffff0,%eax
c0104f6d:	83 c8 09             	or     $0x9,%eax
c0104f70:	a2 4d aa 12 c0       	mov    %al,0xc012aa4d
c0104f75:	0f b6 05 4d aa 12 c0 	movzbl 0xc012aa4d,%eax
c0104f7c:	83 e0 ef             	and    $0xffffffef,%eax
c0104f7f:	a2 4d aa 12 c0       	mov    %al,0xc012aa4d
c0104f84:	0f b6 05 4d aa 12 c0 	movzbl 0xc012aa4d,%eax
c0104f8b:	83 e0 9f             	and    $0xffffff9f,%eax
c0104f8e:	a2 4d aa 12 c0       	mov    %al,0xc012aa4d
c0104f93:	0f b6 05 4d aa 12 c0 	movzbl 0xc012aa4d,%eax
c0104f9a:	83 c8 80             	or     $0xffffff80,%eax
c0104f9d:	a2 4d aa 12 c0       	mov    %al,0xc012aa4d
c0104fa2:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c0104fa9:	83 e0 f0             	and    $0xfffffff0,%eax
c0104fac:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c0104fb1:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c0104fb8:	83 e0 ef             	and    $0xffffffef,%eax
c0104fbb:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c0104fc0:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c0104fc7:	83 e0 df             	and    $0xffffffdf,%eax
c0104fca:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c0104fcf:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c0104fd6:	83 c8 40             	or     $0x40,%eax
c0104fd9:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c0104fde:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c0104fe5:	83 e0 7f             	and    $0x7f,%eax
c0104fe8:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c0104fed:	b8 00 cf 19 c0       	mov    $0xc019cf00,%eax
c0104ff2:	c1 e8 18             	shr    $0x18,%eax
c0104ff5:	a2 4f aa 12 c0       	mov    %al,0xc012aa4f

    // reload all segment registers
    lgdt(&gdt_pd);
c0104ffa:	c7 04 24 50 aa 12 c0 	movl   $0xc012aa50,(%esp)
c0105001:	e8 de fe ff ff       	call   c0104ee4 <lgdt>
c0105006:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c010500c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0105010:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0105013:	c9                   	leave  
c0105014:	c3                   	ret    

c0105015 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0105015:	55                   	push   %ebp
c0105016:	89 e5                	mov    %esp,%ebp
c0105018:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c010501b:	c7 05 c4 ef 19 c0 30 	movl   $0xc010cb30,0xc019efc4
c0105022:	cb 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0105025:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c010502a:	8b 00                	mov    (%eax),%eax
c010502c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105030:	c7 04 24 bc cc 10 c0 	movl   $0xc010ccbc,(%esp)
c0105037:	e8 17 b3 ff ff       	call   c0100353 <cprintf>
    pmm_manager->init();
c010503c:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c0105041:	8b 40 04             	mov    0x4(%eax),%eax
c0105044:	ff d0                	call   *%eax
}
c0105046:	c9                   	leave  
c0105047:	c3                   	ret    

c0105048 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0105048:	55                   	push   %ebp
c0105049:	89 e5                	mov    %esp,%ebp
c010504b:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c010504e:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c0105053:	8b 40 08             	mov    0x8(%eax),%eax
c0105056:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105059:	89 54 24 04          	mov    %edx,0x4(%esp)
c010505d:	8b 55 08             	mov    0x8(%ebp),%edx
c0105060:	89 14 24             	mov    %edx,(%esp)
c0105063:	ff d0                	call   *%eax
}
c0105065:	c9                   	leave  
c0105066:	c3                   	ret    

c0105067 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0105067:	55                   	push   %ebp
c0105068:	89 e5                	mov    %esp,%ebp
c010506a:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c010506d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0105074:	e8 2e fe ff ff       	call   c0104ea7 <__intr_save>
c0105079:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c010507c:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c0105081:	8b 40 0c             	mov    0xc(%eax),%eax
c0105084:	8b 55 08             	mov    0x8(%ebp),%edx
c0105087:	89 14 24             	mov    %edx,(%esp)
c010508a:	ff d0                	call   *%eax
c010508c:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c010508f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105092:	89 04 24             	mov    %eax,(%esp)
c0105095:	e8 37 fe ff ff       	call   c0104ed1 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c010509a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010509e:	75 2d                	jne    c01050cd <alloc_pages+0x66>
c01050a0:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01050a4:	77 27                	ja     c01050cd <alloc_pages+0x66>
c01050a6:	a1 6c cf 19 c0       	mov    0xc019cf6c,%eax
c01050ab:	85 c0                	test   %eax,%eax
c01050ad:	74 1e                	je     c01050cd <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c01050af:	8b 55 08             	mov    0x8(%ebp),%edx
c01050b2:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c01050b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01050be:	00 
c01050bf:	89 54 24 04          	mov    %edx,0x4(%esp)
c01050c3:	89 04 24             	mov    %eax,(%esp)
c01050c6:	e8 b6 1d 00 00       	call   c0106e81 <swap_out>
    }
c01050cb:	eb a7                	jmp    c0105074 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01050cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01050d0:	c9                   	leave  
c01050d1:	c3                   	ret    

c01050d2 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01050d2:	55                   	push   %ebp
c01050d3:	89 e5                	mov    %esp,%ebp
c01050d5:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01050d8:	e8 ca fd ff ff       	call   c0104ea7 <__intr_save>
c01050dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01050e0:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c01050e5:	8b 40 10             	mov    0x10(%eax),%eax
c01050e8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01050eb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01050ef:	8b 55 08             	mov    0x8(%ebp),%edx
c01050f2:	89 14 24             	mov    %edx,(%esp)
c01050f5:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01050f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050fa:	89 04 24             	mov    %eax,(%esp)
c01050fd:	e8 cf fd ff ff       	call   c0104ed1 <__intr_restore>
}
c0105102:	c9                   	leave  
c0105103:	c3                   	ret    

c0105104 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0105104:	55                   	push   %ebp
c0105105:	89 e5                	mov    %esp,%ebp
c0105107:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c010510a:	e8 98 fd ff ff       	call   c0104ea7 <__intr_save>
c010510f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0105112:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c0105117:	8b 40 14             	mov    0x14(%eax),%eax
c010511a:	ff d0                	call   *%eax
c010511c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c010511f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105122:	89 04 24             	mov    %eax,(%esp)
c0105125:	e8 a7 fd ff ff       	call   c0104ed1 <__intr_restore>
    return ret;
c010512a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010512d:	c9                   	leave  
c010512e:	c3                   	ret    

c010512f <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c010512f:	55                   	push   %ebp
c0105130:	89 e5                	mov    %esp,%ebp
c0105132:	57                   	push   %edi
c0105133:	56                   	push   %esi
c0105134:	53                   	push   %ebx
c0105135:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c010513b:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0105142:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0105149:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0105150:	c7 04 24 d3 cc 10 c0 	movl   $0xc010ccd3,(%esp)
c0105157:	e8 f7 b1 ff ff       	call   c0100353 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c010515c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105163:	e9 15 01 00 00       	jmp    c010527d <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0105168:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010516b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010516e:	89 d0                	mov    %edx,%eax
c0105170:	c1 e0 02             	shl    $0x2,%eax
c0105173:	01 d0                	add    %edx,%eax
c0105175:	c1 e0 02             	shl    $0x2,%eax
c0105178:	01 c8                	add    %ecx,%eax
c010517a:	8b 50 08             	mov    0x8(%eax),%edx
c010517d:	8b 40 04             	mov    0x4(%eax),%eax
c0105180:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0105183:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0105186:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105189:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010518c:	89 d0                	mov    %edx,%eax
c010518e:	c1 e0 02             	shl    $0x2,%eax
c0105191:	01 d0                	add    %edx,%eax
c0105193:	c1 e0 02             	shl    $0x2,%eax
c0105196:	01 c8                	add    %ecx,%eax
c0105198:	8b 48 0c             	mov    0xc(%eax),%ecx
c010519b:	8b 58 10             	mov    0x10(%eax),%ebx
c010519e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01051a1:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01051a4:	01 c8                	add    %ecx,%eax
c01051a6:	11 da                	adc    %ebx,%edx
c01051a8:	89 45 b0             	mov    %eax,-0x50(%ebp)
c01051ab:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01051ae:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01051b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01051b4:	89 d0                	mov    %edx,%eax
c01051b6:	c1 e0 02             	shl    $0x2,%eax
c01051b9:	01 d0                	add    %edx,%eax
c01051bb:	c1 e0 02             	shl    $0x2,%eax
c01051be:	01 c8                	add    %ecx,%eax
c01051c0:	83 c0 14             	add    $0x14,%eax
c01051c3:	8b 00                	mov    (%eax),%eax
c01051c5:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c01051cb:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01051ce:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01051d1:	83 c0 ff             	add    $0xffffffff,%eax
c01051d4:	83 d2 ff             	adc    $0xffffffff,%edx
c01051d7:	89 c6                	mov    %eax,%esi
c01051d9:	89 d7                	mov    %edx,%edi
c01051db:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01051de:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01051e1:	89 d0                	mov    %edx,%eax
c01051e3:	c1 e0 02             	shl    $0x2,%eax
c01051e6:	01 d0                	add    %edx,%eax
c01051e8:	c1 e0 02             	shl    $0x2,%eax
c01051eb:	01 c8                	add    %ecx,%eax
c01051ed:	8b 48 0c             	mov    0xc(%eax),%ecx
c01051f0:	8b 58 10             	mov    0x10(%eax),%ebx
c01051f3:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01051f9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c01051fd:	89 74 24 14          	mov    %esi,0x14(%esp)
c0105201:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0105205:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105208:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010520b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010520f:	89 54 24 10          	mov    %edx,0x10(%esp)
c0105213:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0105217:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c010521b:	c7 04 24 e0 cc 10 c0 	movl   $0xc010cce0,(%esp)
c0105222:	e8 2c b1 ff ff       	call   c0100353 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0105227:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010522a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010522d:	89 d0                	mov    %edx,%eax
c010522f:	c1 e0 02             	shl    $0x2,%eax
c0105232:	01 d0                	add    %edx,%eax
c0105234:	c1 e0 02             	shl    $0x2,%eax
c0105237:	01 c8                	add    %ecx,%eax
c0105239:	83 c0 14             	add    $0x14,%eax
c010523c:	8b 00                	mov    (%eax),%eax
c010523e:	83 f8 01             	cmp    $0x1,%eax
c0105241:	75 36                	jne    c0105279 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0105243:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105246:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105249:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c010524c:	77 2b                	ja     c0105279 <page_init+0x14a>
c010524e:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0105251:	72 05                	jb     c0105258 <page_init+0x129>
c0105253:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0105256:	73 21                	jae    c0105279 <page_init+0x14a>
c0105258:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010525c:	77 1b                	ja     c0105279 <page_init+0x14a>
c010525e:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105262:	72 09                	jb     c010526d <page_init+0x13e>
c0105264:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c010526b:	77 0c                	ja     c0105279 <page_init+0x14a>
                maxpa = end;
c010526d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105270:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0105273:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105276:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0105279:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c010527d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105280:	8b 00                	mov    (%eax),%eax
c0105282:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0105285:	0f 8f dd fe ff ff    	jg     c0105168 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c010528b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010528f:	72 1d                	jb     c01052ae <page_init+0x17f>
c0105291:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105295:	77 09                	ja     c01052a0 <page_init+0x171>
c0105297:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c010529e:	76 0e                	jbe    c01052ae <page_init+0x17f>
        maxpa = KMEMSIZE;
c01052a0:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01052a7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c01052ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01052b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01052b4:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01052b8:	c1 ea 0c             	shr    $0xc,%edx
c01052bb:	a3 e0 ce 19 c0       	mov    %eax,0xc019cee0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01052c0:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c01052c7:	b8 b8 f0 19 c0       	mov    $0xc019f0b8,%eax
c01052cc:	8d 50 ff             	lea    -0x1(%eax),%edx
c01052cf:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01052d2:	01 d0                	add    %edx,%eax
c01052d4:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01052d7:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01052da:	ba 00 00 00 00       	mov    $0x0,%edx
c01052df:	f7 75 ac             	divl   -0x54(%ebp)
c01052e2:	89 d0                	mov    %edx,%eax
c01052e4:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01052e7:	29 c2                	sub    %eax,%edx
c01052e9:	89 d0                	mov    %edx,%eax
c01052eb:	a3 cc ef 19 c0       	mov    %eax,0xc019efcc

    for (i = 0; i < npage; i ++) {
c01052f0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01052f7:	eb 27                	jmp    c0105320 <page_init+0x1f1>
        SetPageReserved(pages + i);
c01052f9:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c01052fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105301:	c1 e2 05             	shl    $0x5,%edx
c0105304:	01 d0                	add    %edx,%eax
c0105306:	83 c0 04             	add    $0x4,%eax
c0105309:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0105310:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105313:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0105316:	8b 55 90             	mov    -0x70(%ebp),%edx
c0105319:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c010531c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0105320:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105323:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0105328:	39 c2                	cmp    %eax,%edx
c010532a:	72 cd                	jb     c01052f9 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c010532c:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0105331:	c1 e0 05             	shl    $0x5,%eax
c0105334:	89 c2                	mov    %eax,%edx
c0105336:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c010533b:	01 d0                	add    %edx,%eax
c010533d:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0105340:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0105347:	77 23                	ja     c010536c <page_init+0x23d>
c0105349:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010534c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105350:	c7 44 24 08 10 cd 10 	movl   $0xc010cd10,0x8(%esp)
c0105357:	c0 
c0105358:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c010535f:	00 
c0105360:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105367:	e8 69 ba ff ff       	call   c0100dd5 <__panic>
c010536c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010536f:	05 00 00 00 40       	add    $0x40000000,%eax
c0105374:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0105377:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010537e:	e9 74 01 00 00       	jmp    c01054f7 <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0105383:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105386:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105389:	89 d0                	mov    %edx,%eax
c010538b:	c1 e0 02             	shl    $0x2,%eax
c010538e:	01 d0                	add    %edx,%eax
c0105390:	c1 e0 02             	shl    $0x2,%eax
c0105393:	01 c8                	add    %ecx,%eax
c0105395:	8b 50 08             	mov    0x8(%eax),%edx
c0105398:	8b 40 04             	mov    0x4(%eax),%eax
c010539b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010539e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01053a1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01053a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053a7:	89 d0                	mov    %edx,%eax
c01053a9:	c1 e0 02             	shl    $0x2,%eax
c01053ac:	01 d0                	add    %edx,%eax
c01053ae:	c1 e0 02             	shl    $0x2,%eax
c01053b1:	01 c8                	add    %ecx,%eax
c01053b3:	8b 48 0c             	mov    0xc(%eax),%ecx
c01053b6:	8b 58 10             	mov    0x10(%eax),%ebx
c01053b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01053bc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01053bf:	01 c8                	add    %ecx,%eax
c01053c1:	11 da                	adc    %ebx,%edx
c01053c3:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01053c6:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01053c9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01053cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053cf:	89 d0                	mov    %edx,%eax
c01053d1:	c1 e0 02             	shl    $0x2,%eax
c01053d4:	01 d0                	add    %edx,%eax
c01053d6:	c1 e0 02             	shl    $0x2,%eax
c01053d9:	01 c8                	add    %ecx,%eax
c01053db:	83 c0 14             	add    $0x14,%eax
c01053de:	8b 00                	mov    (%eax),%eax
c01053e0:	83 f8 01             	cmp    $0x1,%eax
c01053e3:	0f 85 0a 01 00 00    	jne    c01054f3 <page_init+0x3c4>
            if (begin < freemem) {
c01053e9:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01053ec:	ba 00 00 00 00       	mov    $0x0,%edx
c01053f1:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01053f4:	72 17                	jb     c010540d <page_init+0x2de>
c01053f6:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01053f9:	77 05                	ja     c0105400 <page_init+0x2d1>
c01053fb:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01053fe:	76 0d                	jbe    c010540d <page_init+0x2de>
                begin = freemem;
c0105400:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0105403:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105406:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c010540d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0105411:	72 1d                	jb     c0105430 <page_init+0x301>
c0105413:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0105417:	77 09                	ja     c0105422 <page_init+0x2f3>
c0105419:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0105420:	76 0e                	jbe    c0105430 <page_init+0x301>
                end = KMEMSIZE;
c0105422:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0105429:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0105430:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105433:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105436:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0105439:	0f 87 b4 00 00 00    	ja     c01054f3 <page_init+0x3c4>
c010543f:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0105442:	72 09                	jb     c010544d <page_init+0x31e>
c0105444:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105447:	0f 83 a6 00 00 00    	jae    c01054f3 <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c010544d:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0105454:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105457:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010545a:	01 d0                	add    %edx,%eax
c010545c:	83 e8 01             	sub    $0x1,%eax
c010545f:	89 45 98             	mov    %eax,-0x68(%ebp)
c0105462:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105465:	ba 00 00 00 00       	mov    $0x0,%edx
c010546a:	f7 75 9c             	divl   -0x64(%ebp)
c010546d:	89 d0                	mov    %edx,%eax
c010546f:	8b 55 98             	mov    -0x68(%ebp),%edx
c0105472:	29 c2                	sub    %eax,%edx
c0105474:	89 d0                	mov    %edx,%eax
c0105476:	ba 00 00 00 00       	mov    $0x0,%edx
c010547b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010547e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0105481:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105484:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0105487:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010548a:	ba 00 00 00 00       	mov    $0x0,%edx
c010548f:	89 c7                	mov    %eax,%edi
c0105491:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0105497:	89 7d 80             	mov    %edi,-0x80(%ebp)
c010549a:	89 d0                	mov    %edx,%eax
c010549c:	83 e0 00             	and    $0x0,%eax
c010549f:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01054a2:	8b 45 80             	mov    -0x80(%ebp),%eax
c01054a5:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01054a8:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01054ab:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01054ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01054b1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01054b4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01054b7:	77 3a                	ja     c01054f3 <page_init+0x3c4>
c01054b9:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01054bc:	72 05                	jb     c01054c3 <page_init+0x394>
c01054be:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01054c1:	73 30                	jae    c01054f3 <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01054c3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01054c6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c01054c9:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01054cc:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01054cf:	29 c8                	sub    %ecx,%eax
c01054d1:	19 da                	sbb    %ebx,%edx
c01054d3:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01054d7:	c1 ea 0c             	shr    $0xc,%edx
c01054da:	89 c3                	mov    %eax,%ebx
c01054dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01054df:	89 04 24             	mov    %eax,(%esp)
c01054e2:	e8 8c f8 ff ff       	call   c0104d73 <pa2page>
c01054e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01054eb:	89 04 24             	mov    %eax,(%esp)
c01054ee:	e8 55 fb ff ff       	call   c0105048 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01054f3:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01054f7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01054fa:	8b 00                	mov    (%eax),%eax
c01054fc:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01054ff:	0f 8f 7e fe ff ff    	jg     c0105383 <page_init+0x254>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0105505:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c010550b:	5b                   	pop    %ebx
c010550c:	5e                   	pop    %esi
c010550d:	5f                   	pop    %edi
c010550e:	5d                   	pop    %ebp
c010550f:	c3                   	ret    

c0105510 <enable_paging>:

static void
enable_paging(void) {
c0105510:	55                   	push   %ebp
c0105511:	89 e5                	mov    %esp,%ebp
c0105513:	83 ec 10             	sub    $0x10,%esp
    lcr3(boot_cr3);
c0105516:	a1 c8 ef 19 c0       	mov    0xc019efc8,%eax
c010551b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010551e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105521:	0f 22 d8             	mov    %eax,%cr3
}

static inline uintptr_t
rcr0(void) {
    uintptr_t cr0;
    asm volatile ("mov %%cr0, %0" : "=r" (cr0) :: "memory");
c0105524:	0f 20 c0             	mov    %cr0,%eax
c0105527:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr0;
c010552a:	8b 45 f4             	mov    -0xc(%ebp),%eax

    // turn on paging
    uint32_t cr0 = rcr0();
c010552d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
c0105530:	81 4d fc 2f 00 05 80 	orl    $0x8005002f,-0x4(%ebp)
    cr0 &= ~(CR0_TS | CR0_EM);
c0105537:	83 65 fc f3          	andl   $0xfffffff3,-0x4(%ebp)
c010553b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010553e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile ("pushl %0; popfl" :: "r" (eflags));
}

static inline void
lcr0(uintptr_t cr0) {
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
c0105541:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105544:	0f 22 c0             	mov    %eax,%cr0
    lcr0(cr0);
}
c0105547:	c9                   	leave  
c0105548:	c3                   	ret    

c0105549 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0105549:	55                   	push   %ebp
c010554a:	89 e5                	mov    %esp,%ebp
c010554c:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c010554f:	8b 45 14             	mov    0x14(%ebp),%eax
c0105552:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105555:	31 d0                	xor    %edx,%eax
c0105557:	25 ff 0f 00 00       	and    $0xfff,%eax
c010555c:	85 c0                	test   %eax,%eax
c010555e:	74 24                	je     c0105584 <boot_map_segment+0x3b>
c0105560:	c7 44 24 0c 42 cd 10 	movl   $0xc010cd42,0xc(%esp)
c0105567:	c0 
c0105568:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c010556f:	c0 
c0105570:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0105577:	00 
c0105578:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c010557f:	e8 51 b8 ff ff       	call   c0100dd5 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0105584:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010558b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010558e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105593:	89 c2                	mov    %eax,%edx
c0105595:	8b 45 10             	mov    0x10(%ebp),%eax
c0105598:	01 c2                	add    %eax,%edx
c010559a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010559d:	01 d0                	add    %edx,%eax
c010559f:	83 e8 01             	sub    $0x1,%eax
c01055a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01055a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055a8:	ba 00 00 00 00       	mov    $0x0,%edx
c01055ad:	f7 75 f0             	divl   -0x10(%ebp)
c01055b0:	89 d0                	mov    %edx,%eax
c01055b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01055b5:	29 c2                	sub    %eax,%edx
c01055b7:	89 d0                	mov    %edx,%eax
c01055b9:	c1 e8 0c             	shr    $0xc,%eax
c01055bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01055bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01055c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01055c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01055cd:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01055d0:	8b 45 14             	mov    0x14(%ebp),%eax
c01055d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01055d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01055de:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01055e1:	eb 6b                	jmp    c010564e <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01055e3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01055ea:	00 
c01055eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01055f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f5:	89 04 24             	mov    %eax,(%esp)
c01055f8:	e8 d1 01 00 00       	call   c01057ce <get_pte>
c01055fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0105600:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105604:	75 24                	jne    c010562a <boot_map_segment+0xe1>
c0105606:	c7 44 24 0c 6e cd 10 	movl   $0xc010cd6e,0xc(%esp)
c010560d:	c0 
c010560e:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0105615:	c0 
c0105616:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c010561d:	00 
c010561e:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105625:	e8 ab b7 ff ff       	call   c0100dd5 <__panic>
        *ptep = pa | PTE_P | perm;
c010562a:	8b 45 18             	mov    0x18(%ebp),%eax
c010562d:	8b 55 14             	mov    0x14(%ebp),%edx
c0105630:	09 d0                	or     %edx,%eax
c0105632:	83 c8 01             	or     $0x1,%eax
c0105635:	89 c2                	mov    %eax,%edx
c0105637:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010563a:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010563c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105640:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0105647:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c010564e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105652:	75 8f                	jne    c01055e3 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0105654:	c9                   	leave  
c0105655:	c3                   	ret    

c0105656 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0105656:	55                   	push   %ebp
c0105657:	89 e5                	mov    %esp,%ebp
c0105659:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c010565c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105663:	e8 ff f9 ff ff       	call   c0105067 <alloc_pages>
c0105668:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c010566b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010566f:	75 1c                	jne    c010568d <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0105671:	c7 44 24 08 7b cd 10 	movl   $0xc010cd7b,0x8(%esp)
c0105678:	c0 
c0105679:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0105680:	00 
c0105681:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105688:	e8 48 b7 ff ff       	call   c0100dd5 <__panic>
    }
    return page2kva(p);
c010568d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105690:	89 04 24             	mov    %eax,(%esp)
c0105693:	e8 20 f7 ff ff       	call   c0104db8 <page2kva>
}
c0105698:	c9                   	leave  
c0105699:	c3                   	ret    

c010569a <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010569a:	55                   	push   %ebp
c010569b:	89 e5                	mov    %esp,%ebp
c010569d:	83 ec 38             	sub    $0x38,%esp
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01056a0:	e8 70 f9 ff ff       	call   c0105015 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01056a5:	e8 85 fa ff ff       	call   c010512f <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01056aa:	e8 77 09 00 00       	call   c0106026 <check_alloc_page>

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    boot_pgdir = boot_alloc_page();
c01056af:	e8 a2 ff ff ff       	call   c0105656 <boot_alloc_page>
c01056b4:	a3 e4 ce 19 c0       	mov    %eax,0xc019cee4
    memset(boot_pgdir, 0, PGSIZE);
c01056b9:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01056be:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01056c5:	00 
c01056c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01056cd:	00 
c01056ce:	89 04 24             	mov    %eax,(%esp)
c01056d1:	e8 2c 66 00 00       	call   c010bd02 <memset>
    boot_cr3 = PADDR(boot_pgdir);
c01056d6:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01056db:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01056de:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01056e5:	77 23                	ja     c010570a <pmm_init+0x70>
c01056e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01056ee:	c7 44 24 08 10 cd 10 	movl   $0xc010cd10,0x8(%esp)
c01056f5:	c0 
c01056f6:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c01056fd:	00 
c01056fe:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105705:	e8 cb b6 ff ff       	call   c0100dd5 <__panic>
c010570a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010570d:	05 00 00 00 40       	add    $0x40000000,%eax
c0105712:	a3 c8 ef 19 c0       	mov    %eax,0xc019efc8

    check_pgdir();
c0105717:	e8 28 09 00 00       	call   c0106044 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c010571c:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0105721:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0105727:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010572c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010572f:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0105736:	77 23                	ja     c010575b <pmm_init+0xc1>
c0105738:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010573b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010573f:	c7 44 24 08 10 cd 10 	movl   $0xc010cd10,0x8(%esp)
c0105746:	c0 
c0105747:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
c010574e:	00 
c010574f:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105756:	e8 7a b6 ff ff       	call   c0100dd5 <__panic>
c010575b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010575e:	05 00 00 00 40       	add    $0x40000000,%eax
c0105763:	83 c8 03             	or     $0x3,%eax
c0105766:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    //linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    //But shouldn't use this map until enable_paging() & gdt_init() finished.
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0105768:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010576d:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0105774:	00 
c0105775:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010577c:	00 
c010577d:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0105784:	38 
c0105785:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c010578c:	c0 
c010578d:	89 04 24             	mov    %eax,(%esp)
c0105790:	e8 b4 fd ff ff       	call   c0105549 <boot_map_segment>

    //temporary map: 
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M     
    boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
c0105795:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010579a:	8b 15 e4 ce 19 c0    	mov    0xc019cee4,%edx
c01057a0:	8b 92 00 0c 00 00    	mov    0xc00(%edx),%edx
c01057a6:	89 10                	mov    %edx,(%eax)

    enable_paging();
c01057a8:	e8 63 fd ff ff       	call   c0105510 <enable_paging>

    //reload gdt(third time,the last time) to map all physical memory
    //virtual_addr 0~4G=liear_addr 0~4G
    //then set kernel stack(ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01057ad:	e8 74 f7 ff ff       	call   c0104f26 <gdt_init>

    //disable the map of virtual_addr 0~4M
    boot_pgdir[0] = 0;
c01057b2:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01057b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01057bd:	e8 1d 0f 00 00       	call   c01066df <check_boot_pgdir>

    print_pgdir();
c01057c2:	e8 a5 13 00 00       	call   c0106b6c <print_pgdir>
    
    kmalloc_init();
c01057c7:	e8 e6 f2 ff ff       	call   c0104ab2 <kmalloc_init>

}
c01057cc:	c9                   	leave  
c01057cd:	c3                   	ret    

c01057ce <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01057ce:	55                   	push   %ebp
c01057cf:	89 e5                	mov    %esp,%ebp
c01057d1:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c01057d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057d7:	c1 e8 16             	shr    $0x16,%eax
c01057da:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01057e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01057e4:	01 d0                	add    %edx,%eax
c01057e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (!(*pdep & PTE_P)) {
c01057e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057ec:	8b 00                	mov    (%eax),%eax
c01057ee:	83 e0 01             	and    $0x1,%eax
c01057f1:	85 c0                	test   %eax,%eax
c01057f3:	0f 85 c4 00 00 00    	jne    c01058bd <get_pte+0xef>
        if (!create)
c01057f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01057fd:	75 0a                	jne    c0105809 <get_pte+0x3b>
            return NULL;
c01057ff:	b8 00 00 00 00       	mov    $0x0,%eax
c0105804:	e9 10 01 00 00       	jmp    c0105919 <get_pte+0x14b>
        struct Page* page;
        if (create && (page = alloc_pages(1)) == NULL)
c0105809:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010580d:	74 1f                	je     c010582e <get_pte+0x60>
c010580f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105816:	e8 4c f8 ff ff       	call   c0105067 <alloc_pages>
c010581b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010581e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105822:	75 0a                	jne    c010582e <get_pte+0x60>
            return NULL;
c0105824:	b8 00 00 00 00       	mov    $0x0,%eax
c0105829:	e9 eb 00 00 00       	jmp    c0105919 <get_pte+0x14b>
        set_page_ref(page, 1);
c010582e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105835:	00 
c0105836:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105839:	89 04 24             	mov    %eax,(%esp)
c010583c:	e8 2b f6 ff ff       	call   c0104e6c <set_page_ref>
        uintptr_t phia = page2pa(page);
c0105841:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105844:	89 04 24             	mov    %eax,(%esp)
c0105847:	e8 11 f5 ff ff       	call   c0104d5d <page2pa>
c010584c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(phia), 0, PGSIZE);
c010584f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105852:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105855:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105858:	c1 e8 0c             	shr    $0xc,%eax
c010585b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010585e:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0105863:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0105866:	72 23                	jb     c010588b <get_pte+0xbd>
c0105868:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010586b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010586f:	c7 44 24 08 6c cc 10 	movl   $0xc010cc6c,0x8(%esp)
c0105876:	c0 
c0105877:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
c010587e:	00 
c010587f:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105886:	e8 4a b5 ff ff       	call   c0100dd5 <__panic>
c010588b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010588e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105893:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010589a:	00 
c010589b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01058a2:	00 
c01058a3:	89 04 24             	mov    %eax,(%esp)
c01058a6:	e8 57 64 00 00       	call   c010bd02 <memset>
        *pdep = PDE_ADDR(phia) | PTE_U | PTE_W | PTE_P;
c01058ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01058b3:	83 c8 07             	or     $0x7,%eax
c01058b6:	89 c2                	mov    %eax,%edx
c01058b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058bb:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c01058bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058c0:	8b 00                	mov    (%eax),%eax
c01058c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01058c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01058ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058cd:	c1 e8 0c             	shr    $0xc,%eax
c01058d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01058d3:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c01058d8:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01058db:	72 23                	jb     c0105900 <get_pte+0x132>
c01058dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01058e4:	c7 44 24 08 6c cc 10 	movl   $0xc010cc6c,0x8(%esp)
c01058eb:	c0 
c01058ec:	c7 44 24 04 9b 01 00 	movl   $0x19b,0x4(%esp)
c01058f3:	00 
c01058f4:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01058fb:	e8 d5 b4 ff ff       	call   c0100dd5 <__panic>
c0105900:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105903:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105908:	8b 55 0c             	mov    0xc(%ebp),%edx
c010590b:	c1 ea 0c             	shr    $0xc,%edx
c010590e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c0105914:	c1 e2 02             	shl    $0x2,%edx
c0105917:	01 d0                	add    %edx,%eax
}
c0105919:	c9                   	leave  
c010591a:	c3                   	ret    

c010591b <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010591b:	55                   	push   %ebp
c010591c:	89 e5                	mov    %esp,%ebp
c010591e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105921:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105928:	00 
c0105929:	8b 45 0c             	mov    0xc(%ebp),%eax
c010592c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105930:	8b 45 08             	mov    0x8(%ebp),%eax
c0105933:	89 04 24             	mov    %eax,(%esp)
c0105936:	e8 93 fe ff ff       	call   c01057ce <get_pte>
c010593b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010593e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105942:	74 08                	je     c010594c <get_page+0x31>
        *ptep_store = ptep;
c0105944:	8b 45 10             	mov    0x10(%ebp),%eax
c0105947:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010594a:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010594c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105950:	74 1b                	je     c010596d <get_page+0x52>
c0105952:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105955:	8b 00                	mov    (%eax),%eax
c0105957:	83 e0 01             	and    $0x1,%eax
c010595a:	85 c0                	test   %eax,%eax
c010595c:	74 0f                	je     c010596d <get_page+0x52>
        return pte2page(*ptep);
c010595e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105961:	8b 00                	mov    (%eax),%eax
c0105963:	89 04 24             	mov    %eax,(%esp)
c0105966:	e8 a1 f4 ff ff       	call   c0104e0c <pte2page>
c010596b:	eb 05                	jmp    c0105972 <get_page+0x57>
    }
    return NULL;
c010596d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105972:	c9                   	leave  
c0105973:	c3                   	ret    

c0105974 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0105974:	55                   	push   %ebp
c0105975:	89 e5                	mov    %esp,%ebp
c0105977:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c010597a:	8b 45 10             	mov    0x10(%ebp),%eax
c010597d:	8b 00                	mov    (%eax),%eax
c010597f:	83 e0 01             	and    $0x1,%eax
c0105982:	85 c0                	test   %eax,%eax
c0105984:	74 52                	je     c01059d8 <page_remove_pte+0x64>
        struct Page *page = pte2page(*ptep);
c0105986:	8b 45 10             	mov    0x10(%ebp),%eax
c0105989:	8b 00                	mov    (%eax),%eax
c010598b:	89 04 24             	mov    %eax,(%esp)
c010598e:	e8 79 f4 ff ff       	call   c0104e0c <pte2page>
c0105993:	89 45 f4             	mov    %eax,-0xc(%ebp)
        page_ref_dec(page);
c0105996:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105999:	89 04 24             	mov    %eax,(%esp)
c010599c:	e8 ef f4 ff ff       	call   c0104e90 <page_ref_dec>
        if(page->ref == 0) {
c01059a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059a4:	8b 00                	mov    (%eax),%eax
c01059a6:	85 c0                	test   %eax,%eax
c01059a8:	75 13                	jne    c01059bd <page_remove_pte+0x49>
            free_page(page);
c01059aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01059b1:	00 
c01059b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059b5:	89 04 24             	mov    %eax,(%esp)
c01059b8:	e8 15 f7 ff ff       	call   c01050d2 <free_pages>
        }
        *ptep = 0;
c01059bd:	8b 45 10             	mov    0x10(%ebp),%eax
c01059c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c01059c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059c9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01059d0:	89 04 24             	mov    %eax,(%esp)
c01059d3:	e8 1d 05 00 00       	call   c0105ef5 <tlb_invalidate>
    }
}
c01059d8:	c9                   	leave  
c01059d9:	c3                   	ret    

c01059da <unmap_range>:

void
unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c01059da:	55                   	push   %ebp
c01059db:	89 e5                	mov    %esp,%ebp
c01059dd:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c01059e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059e3:	25 ff 0f 00 00       	and    $0xfff,%eax
c01059e8:	85 c0                	test   %eax,%eax
c01059ea:	75 0c                	jne    c01059f8 <unmap_range+0x1e>
c01059ec:	8b 45 10             	mov    0x10(%ebp),%eax
c01059ef:	25 ff 0f 00 00       	and    $0xfff,%eax
c01059f4:	85 c0                	test   %eax,%eax
c01059f6:	74 24                	je     c0105a1c <unmap_range+0x42>
c01059f8:	c7 44 24 0c 94 cd 10 	movl   $0xc010cd94,0xc(%esp)
c01059ff:	c0 
c0105a00:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0105a07:	c0 
c0105a08:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
c0105a0f:	00 
c0105a10:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105a17:	e8 b9 b3 ff ff       	call   c0100dd5 <__panic>
    assert(USER_ACCESS(start, end));
c0105a1c:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105a23:	76 11                	jbe    c0105a36 <unmap_range+0x5c>
c0105a25:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a28:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105a2b:	73 09                	jae    c0105a36 <unmap_range+0x5c>
c0105a2d:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105a34:	76 24                	jbe    c0105a5a <unmap_range+0x80>
c0105a36:	c7 44 24 0c bd cd 10 	movl   $0xc010cdbd,0xc(%esp)
c0105a3d:	c0 
c0105a3e:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0105a45:	c0 
c0105a46:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
c0105a4d:	00 
c0105a4e:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105a55:	e8 7b b3 ff ff       	call   c0100dd5 <__panic>

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
c0105a5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105a61:	00 
c0105a62:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a65:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a69:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a6c:	89 04 24             	mov    %eax,(%esp)
c0105a6f:	e8 5a fd ff ff       	call   c01057ce <get_pte>
c0105a74:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105a77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105a7b:	75 18                	jne    c0105a95 <unmap_range+0xbb>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105a7d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a80:	05 00 00 40 00       	add    $0x400000,%eax
c0105a85:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a8b:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105a90:	89 45 0c             	mov    %eax,0xc(%ebp)
            continue ;
c0105a93:	eb 29                	jmp    c0105abe <unmap_range+0xe4>
        }
        if (*ptep != 0) {
c0105a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a98:	8b 00                	mov    (%eax),%eax
c0105a9a:	85 c0                	test   %eax,%eax
c0105a9c:	74 19                	je     c0105ab7 <unmap_range+0xdd>
            page_remove_pte(pgdir, start, ptep);
c0105a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105aa1:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aa8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105aac:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aaf:	89 04 24             	mov    %eax,(%esp)
c0105ab2:	e8 bd fe ff ff       	call   c0105974 <page_remove_pte>
        }
        start += PGSIZE;
c0105ab7:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105abe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105ac2:	74 08                	je     c0105acc <unmap_range+0xf2>
c0105ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ac7:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105aca:	72 8e                	jb     c0105a5a <unmap_range+0x80>
}
c0105acc:	c9                   	leave  
c0105acd:	c3                   	ret    

c0105ace <exit_range>:

void
exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0105ace:	55                   	push   %ebp
c0105acf:	89 e5                	mov    %esp,%ebp
c0105ad1:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105ad4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ad7:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105adc:	85 c0                	test   %eax,%eax
c0105ade:	75 0c                	jne    c0105aec <exit_range+0x1e>
c0105ae0:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ae3:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105ae8:	85 c0                	test   %eax,%eax
c0105aea:	74 24                	je     c0105b10 <exit_range+0x42>
c0105aec:	c7 44 24 0c 94 cd 10 	movl   $0xc010cd94,0xc(%esp)
c0105af3:	c0 
c0105af4:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0105afb:	c0 
c0105afc:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0105b03:	00 
c0105b04:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105b0b:	e8 c5 b2 ff ff       	call   c0100dd5 <__panic>
    assert(USER_ACCESS(start, end));
c0105b10:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105b17:	76 11                	jbe    c0105b2a <exit_range+0x5c>
c0105b19:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b1c:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105b1f:	73 09                	jae    c0105b2a <exit_range+0x5c>
c0105b21:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105b28:	76 24                	jbe    c0105b4e <exit_range+0x80>
c0105b2a:	c7 44 24 0c bd cd 10 	movl   $0xc010cdbd,0xc(%esp)
c0105b31:	c0 
c0105b32:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0105b39:	c0 
c0105b3a:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c0105b41:	00 
c0105b42:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105b49:	e8 87 b2 ff ff       	call   c0100dd5 <__panic>

    start = ROUNDDOWN(start, PTSIZE);
c0105b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b51:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b57:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105b5c:	89 45 0c             	mov    %eax,0xc(%ebp)
    do {
        int pde_idx = PDX(start);
c0105b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b62:	c1 e8 16             	shr    $0x16,%eax
c0105b65:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (pgdir[pde_idx] & PTE_P) {
c0105b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105b72:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b75:	01 d0                	add    %edx,%eax
c0105b77:	8b 00                	mov    (%eax),%eax
c0105b79:	83 e0 01             	and    $0x1,%eax
c0105b7c:	85 c0                	test   %eax,%eax
c0105b7e:	74 3e                	je     c0105bbe <exit_range+0xf0>
            free_page(pde2page(pgdir[pde_idx]));
c0105b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105b8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b8d:	01 d0                	add    %edx,%eax
c0105b8f:	8b 00                	mov    (%eax),%eax
c0105b91:	89 04 24             	mov    %eax,(%esp)
c0105b94:	e8 b1 f2 ff ff       	call   c0104e4a <pde2page>
c0105b99:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105ba0:	00 
c0105ba1:	89 04 24             	mov    %eax,(%esp)
c0105ba4:	e8 29 f5 ff ff       	call   c01050d2 <free_pages>
            pgdir[pde_idx] = 0;
c0105ba9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105bb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bb6:	01 d0                	add    %edx,%eax
c0105bb8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        start += PTSIZE;
c0105bbe:	81 45 0c 00 00 40 00 	addl   $0x400000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105bc5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105bc9:	74 08                	je     c0105bd3 <exit_range+0x105>
c0105bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bce:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105bd1:	72 8c                	jb     c0105b5f <exit_range+0x91>
}
c0105bd3:	c9                   	leave  
c0105bd4:	c3                   	ret    

c0105bd5 <copy_range>:
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
c0105bd5:	55                   	push   %ebp
c0105bd6:	89 e5                	mov    %esp,%ebp
c0105bd8:	83 ec 48             	sub    $0x48,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105bdb:	8b 45 10             	mov    0x10(%ebp),%eax
c0105bde:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105be3:	85 c0                	test   %eax,%eax
c0105be5:	75 0c                	jne    c0105bf3 <copy_range+0x1e>
c0105be7:	8b 45 14             	mov    0x14(%ebp),%eax
c0105bea:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105bef:	85 c0                	test   %eax,%eax
c0105bf1:	74 24                	je     c0105c17 <copy_range+0x42>
c0105bf3:	c7 44 24 0c 94 cd 10 	movl   $0xc010cd94,0xc(%esp)
c0105bfa:	c0 
c0105bfb:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0105c02:	c0 
c0105c03:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0105c0a:	00 
c0105c0b:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105c12:	e8 be b1 ff ff       	call   c0100dd5 <__panic>
    assert(USER_ACCESS(start, end));
c0105c17:	81 7d 10 ff ff 1f 00 	cmpl   $0x1fffff,0x10(%ebp)
c0105c1e:	76 11                	jbe    c0105c31 <copy_range+0x5c>
c0105c20:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c23:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105c26:	73 09                	jae    c0105c31 <copy_range+0x5c>
c0105c28:	81 7d 14 00 00 00 b0 	cmpl   $0xb0000000,0x14(%ebp)
c0105c2f:	76 24                	jbe    c0105c55 <copy_range+0x80>
c0105c31:	c7 44 24 0c bd cd 10 	movl   $0xc010cdbd,0xc(%esp)
c0105c38:	c0 
c0105c39:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0105c40:	c0 
c0105c41:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0105c48:	00 
c0105c49:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105c50:	e8 80 b1 ff ff       	call   c0100dd5 <__panic>
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
c0105c55:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105c5c:	00 
c0105c5d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c60:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c64:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c67:	89 04 24             	mov    %eax,(%esp)
c0105c6a:	e8 5f fb ff ff       	call   c01057ce <get_pte>
c0105c6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105c72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105c76:	75 1b                	jne    c0105c93 <copy_range+0xbe>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105c78:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c7b:	05 00 00 40 00       	add    $0x400000,%eax
c0105c80:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c86:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105c8b:	89 45 10             	mov    %eax,0x10(%ebp)
            continue ;
c0105c8e:	e9 4c 01 00 00       	jmp    c0105ddf <copy_range+0x20a>
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
c0105c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c96:	8b 00                	mov    (%eax),%eax
c0105c98:	83 e0 01             	and    $0x1,%eax
c0105c9b:	85 c0                	test   %eax,%eax
c0105c9d:	0f 84 35 01 00 00    	je     c0105dd8 <copy_range+0x203>
            if ((nptep = get_pte(to, start, 1)) == NULL) {
c0105ca3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105caa:	00 
c0105cab:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cae:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cb5:	89 04 24             	mov    %eax,(%esp)
c0105cb8:	e8 11 fb ff ff       	call   c01057ce <get_pte>
c0105cbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105cc0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105cc4:	75 0a                	jne    c0105cd0 <copy_range+0xfb>
                return -E_NO_MEM;
c0105cc6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105ccb:	e9 26 01 00 00       	jmp    c0105df6 <copy_range+0x221>
            }
        uint32_t perm = (*ptep & PTE_USER);
c0105cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cd3:	8b 00                	mov    (%eax),%eax
c0105cd5:	83 e0 07             	and    $0x7,%eax
c0105cd8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        //get page from ptep
        struct Page *page = pte2page(*ptep);
c0105cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cde:	8b 00                	mov    (%eax),%eax
c0105ce0:	89 04 24             	mov    %eax,(%esp)
c0105ce3:	e8 24 f1 ff ff       	call   c0104e0c <pte2page>
c0105ce8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        // alloc a page for process B
        struct Page *npage=alloc_page();
c0105ceb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105cf2:	e8 70 f3 ff ff       	call   c0105067 <alloc_pages>
c0105cf7:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(page!=NULL);
c0105cfa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105cfe:	75 24                	jne    c0105d24 <copy_range+0x14f>
c0105d00:	c7 44 24 0c d5 cd 10 	movl   $0xc010cdd5,0xc(%esp)
c0105d07:	c0 
c0105d08:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0105d0f:	c0 
c0105d10:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0105d17:	00 
c0105d18:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105d1f:	e8 b1 b0 ff ff       	call   c0100dd5 <__panic>
        assert(npage!=NULL);
c0105d24:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105d28:	75 24                	jne    c0105d4e <copy_range+0x179>
c0105d2a:	c7 44 24 0c e0 cd 10 	movl   $0xc010cde0,0xc(%esp)
c0105d31:	c0 
c0105d32:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0105d39:	c0 
c0105d3a:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0105d41:	00 
c0105d42:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105d49:	e8 87 b0 ff ff       	call   c0100dd5 <__panic>
        int ret=0;
c0105d4e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
         * (1) find src_kvaddr: the kernel virtual address of page
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
            void * src_kvaddr = page2kva(page);
c0105d55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d58:	89 04 24             	mov    %eax,(%esp)
c0105d5b:	e8 58 f0 ff ff       	call   c0104db8 <page2kva>
c0105d60:	89 45 d8             	mov    %eax,-0x28(%ebp)
            void * dst_kvaddr = page2kva(npage);
c0105d63:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d66:	89 04 24             	mov    %eax,(%esp)
c0105d69:	e8 4a f0 ff ff       	call   c0104db8 <page2kva>
c0105d6e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
c0105d71:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105d78:	00 
c0105d79:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105d7c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d80:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105d83:	89 04 24             	mov    %eax,(%esp)
c0105d86:	e8 59 60 00 00       	call   c010bde4 <memcpy>
        ret = page_insert(to, npage, start, perm);
c0105d8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105d92:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d95:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105d99:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d9c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105da0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105da3:	89 04 24             	mov    %eax,(%esp)
c0105da6:	e8 91 00 00 00       	call   c0105e3c <page_insert>
c0105dab:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(ret == 0);
c0105dae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105db2:	74 24                	je     c0105dd8 <copy_range+0x203>
c0105db4:	c7 44 24 0c ec cd 10 	movl   $0xc010cdec,0xc(%esp)
c0105dbb:	c0 
c0105dbc:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0105dc3:	c0 
c0105dc4:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0105dcb:	00 
c0105dcc:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105dd3:	e8 fd af ff ff       	call   c0100dd5 <__panic>
        }
        start += PGSIZE;
c0105dd8:	81 45 10 00 10 00 00 	addl   $0x1000,0x10(%ebp)
    } while (start != 0 && start < end);
c0105ddf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105de3:	74 0c                	je     c0105df1 <copy_range+0x21c>
c0105de5:	8b 45 10             	mov    0x10(%ebp),%eax
c0105de8:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105deb:	0f 82 64 fe ff ff    	jb     c0105c55 <copy_range+0x80>
    return 0;
c0105df1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105df6:	c9                   	leave  
c0105df7:	c3                   	ret    

c0105df8 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105df8:	55                   	push   %ebp
c0105df9:	89 e5                	mov    %esp,%ebp
c0105dfb:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105dfe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105e05:	00 
c0105e06:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e09:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e10:	89 04 24             	mov    %eax,(%esp)
c0105e13:	e8 b6 f9 ff ff       	call   c01057ce <get_pte>
c0105e18:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0105e1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105e1f:	74 19                	je     c0105e3a <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0105e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e24:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e28:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e2b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e32:	89 04 24             	mov    %eax,(%esp)
c0105e35:	e8 3a fb ff ff       	call   c0105974 <page_remove_pte>
    }
}
c0105e3a:	c9                   	leave  
c0105e3b:	c3                   	ret    

c0105e3c <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0105e3c:	55                   	push   %ebp
c0105e3d:	89 e5                	mov    %esp,%ebp
c0105e3f:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0105e42:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105e49:	00 
c0105e4a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e51:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e54:	89 04 24             	mov    %eax,(%esp)
c0105e57:	e8 72 f9 ff ff       	call   c01057ce <get_pte>
c0105e5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0105e5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105e63:	75 0a                	jne    c0105e6f <page_insert+0x33>
        return -E_NO_MEM;
c0105e65:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105e6a:	e9 84 00 00 00       	jmp    c0105ef3 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0105e6f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e72:	89 04 24             	mov    %eax,(%esp)
c0105e75:	e8 ff ef ff ff       	call   c0104e79 <page_ref_inc>
    if (*ptep & PTE_P) {
c0105e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e7d:	8b 00                	mov    (%eax),%eax
c0105e7f:	83 e0 01             	and    $0x1,%eax
c0105e82:	85 c0                	test   %eax,%eax
c0105e84:	74 3e                	je     c0105ec4 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0105e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e89:	8b 00                	mov    (%eax),%eax
c0105e8b:	89 04 24             	mov    %eax,(%esp)
c0105e8e:	e8 79 ef ff ff       	call   c0104e0c <pte2page>
c0105e93:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0105e96:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e99:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105e9c:	75 0d                	jne    c0105eab <page_insert+0x6f>
            page_ref_dec(page);
c0105e9e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ea1:	89 04 24             	mov    %eax,(%esp)
c0105ea4:	e8 e7 ef ff ff       	call   c0104e90 <page_ref_dec>
c0105ea9:	eb 19                	jmp    c0105ec4 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0105eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105eae:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105eb2:	8b 45 10             	mov    0x10(%ebp),%eax
c0105eb5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105eb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ebc:	89 04 24             	mov    %eax,(%esp)
c0105ebf:	e8 b0 fa ff ff       	call   c0105974 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ec7:	89 04 24             	mov    %eax,(%esp)
c0105eca:	e8 8e ee ff ff       	call   c0104d5d <page2pa>
c0105ecf:	0b 45 14             	or     0x14(%ebp),%eax
c0105ed2:	83 c8 01             	or     $0x1,%eax
c0105ed5:	89 c2                	mov    %eax,%edx
c0105ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105eda:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0105edc:	8b 45 10             	mov    0x10(%ebp),%eax
c0105edf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ee3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ee6:	89 04 24             	mov    %eax,(%esp)
c0105ee9:	e8 07 00 00 00       	call   c0105ef5 <tlb_invalidate>
    return 0;
c0105eee:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ef3:	c9                   	leave  
c0105ef4:	c3                   	ret    

c0105ef5 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0105ef5:	55                   	push   %ebp
c0105ef6:	89 e5                	mov    %esp,%ebp
c0105ef8:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0105efb:	0f 20 d8             	mov    %cr3,%eax
c0105efe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0105f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0105f04:	89 c2                	mov    %eax,%edx
c0105f06:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f09:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105f0c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105f13:	77 23                	ja     c0105f38 <tlb_invalidate+0x43>
c0105f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f18:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105f1c:	c7 44 24 08 10 cd 10 	movl   $0xc010cd10,0x8(%esp)
c0105f23:	c0 
c0105f24:	c7 44 24 04 58 02 00 	movl   $0x258,0x4(%esp)
c0105f2b:	00 
c0105f2c:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0105f33:	e8 9d ae ff ff       	call   c0100dd5 <__panic>
c0105f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f3b:	05 00 00 00 40       	add    $0x40000000,%eax
c0105f40:	39 c2                	cmp    %eax,%edx
c0105f42:	75 0c                	jne    c0105f50 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0105f44:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f47:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0105f4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f4d:	0f 01 38             	invlpg (%eax)
    }
}
c0105f50:	c9                   	leave  
c0105f51:	c3                   	ret    

c0105f52 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0105f52:	55                   	push   %ebp
c0105f53:	89 e5                	mov    %esp,%ebp
c0105f55:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0105f58:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105f5f:	e8 03 f1 ff ff       	call   c0105067 <alloc_pages>
c0105f64:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0105f67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105f6b:	0f 84 b0 00 00 00    	je     c0106021 <pgdir_alloc_page+0xcf>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0105f71:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f74:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105f78:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f7b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f82:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f86:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f89:	89 04 24             	mov    %eax,(%esp)
c0105f8c:	e8 ab fe ff ff       	call   c0105e3c <page_insert>
c0105f91:	85 c0                	test   %eax,%eax
c0105f93:	74 1a                	je     c0105faf <pgdir_alloc_page+0x5d>
            free_page(page);
c0105f95:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105f9c:	00 
c0105f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fa0:	89 04 24             	mov    %eax,(%esp)
c0105fa3:	e8 2a f1 ff ff       	call   c01050d2 <free_pages>
            return NULL;
c0105fa8:	b8 00 00 00 00       	mov    $0x0,%eax
c0105fad:	eb 75                	jmp    c0106024 <pgdir_alloc_page+0xd2>
        }
        if (swap_init_ok){
c0105faf:	a1 6c cf 19 c0       	mov    0xc019cf6c,%eax
c0105fb4:	85 c0                	test   %eax,%eax
c0105fb6:	74 69                	je     c0106021 <pgdir_alloc_page+0xcf>
            if(check_mm_struct!=NULL) {
c0105fb8:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c0105fbd:	85 c0                	test   %eax,%eax
c0105fbf:	74 60                	je     c0106021 <pgdir_alloc_page+0xcf>
                swap_map_swappable(check_mm_struct, la, page, 0);
c0105fc1:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c0105fc6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105fcd:	00 
c0105fce:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105fd1:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105fd5:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105fd8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105fdc:	89 04 24             	mov    %eax,(%esp)
c0105fdf:	e8 51 0e 00 00       	call   c0106e35 <swap_map_swappable>
                page->pra_vaddr=la;
c0105fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fe7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105fea:	89 50 1c             	mov    %edx,0x1c(%eax)
                assert(page_ref(page) == 1);
c0105fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ff0:	89 04 24             	mov    %eax,(%esp)
c0105ff3:	e8 6a ee ff ff       	call   c0104e62 <page_ref>
c0105ff8:	83 f8 01             	cmp    $0x1,%eax
c0105ffb:	74 24                	je     c0106021 <pgdir_alloc_page+0xcf>
c0105ffd:	c7 44 24 0c f5 cd 10 	movl   $0xc010cdf5,0xc(%esp)
c0106004:	c0 
c0106005:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c010600c:	c0 
c010600d:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
c0106014:	00 
c0106015:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c010601c:	e8 b4 ad ff ff       	call   c0100dd5 <__panic>
            }
        }

    }

    return page;
c0106021:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106024:	c9                   	leave  
c0106025:	c3                   	ret    

c0106026 <check_alloc_page>:

static void
check_alloc_page(void) {
c0106026:	55                   	push   %ebp
c0106027:	89 e5                	mov    %esp,%ebp
c0106029:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010602c:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c0106031:	8b 40 18             	mov    0x18(%eax),%eax
c0106034:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0106036:	c7 04 24 0c ce 10 c0 	movl   $0xc010ce0c,(%esp)
c010603d:	e8 11 a3 ff ff       	call   c0100353 <cprintf>
}
c0106042:	c9                   	leave  
c0106043:	c3                   	ret    

c0106044 <check_pgdir>:

static void
check_pgdir(void) {
c0106044:	55                   	push   %ebp
c0106045:	89 e5                	mov    %esp,%ebp
c0106047:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c010604a:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c010604f:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0106054:	76 24                	jbe    c010607a <check_pgdir+0x36>
c0106056:	c7 44 24 0c 2b ce 10 	movl   $0xc010ce2b,0xc(%esp)
c010605d:	c0 
c010605e:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0106065:	c0 
c0106066:	c7 44 24 04 84 02 00 	movl   $0x284,0x4(%esp)
c010606d:	00 
c010606e:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106075:	e8 5b ad ff ff       	call   c0100dd5 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010607a:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010607f:	85 c0                	test   %eax,%eax
c0106081:	74 0e                	je     c0106091 <check_pgdir+0x4d>
c0106083:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106088:	25 ff 0f 00 00       	and    $0xfff,%eax
c010608d:	85 c0                	test   %eax,%eax
c010608f:	74 24                	je     c01060b5 <check_pgdir+0x71>
c0106091:	c7 44 24 0c 48 ce 10 	movl   $0xc010ce48,0xc(%esp)
c0106098:	c0 
c0106099:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01060a0:	c0 
c01060a1:	c7 44 24 04 85 02 00 	movl   $0x285,0x4(%esp)
c01060a8:	00 
c01060a9:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01060b0:	e8 20 ad ff ff       	call   c0100dd5 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01060b5:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01060ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01060c1:	00 
c01060c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01060c9:	00 
c01060ca:	89 04 24             	mov    %eax,(%esp)
c01060cd:	e8 49 f8 ff ff       	call   c010591b <get_page>
c01060d2:	85 c0                	test   %eax,%eax
c01060d4:	74 24                	je     c01060fa <check_pgdir+0xb6>
c01060d6:	c7 44 24 0c 80 ce 10 	movl   $0xc010ce80,0xc(%esp)
c01060dd:	c0 
c01060de:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01060e5:	c0 
c01060e6:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
c01060ed:	00 
c01060ee:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01060f5:	e8 db ac ff ff       	call   c0100dd5 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01060fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106101:	e8 61 ef ff ff       	call   c0105067 <alloc_pages>
c0106106:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0106109:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010610e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106115:	00 
c0106116:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010611d:	00 
c010611e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106121:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106125:	89 04 24             	mov    %eax,(%esp)
c0106128:	e8 0f fd ff ff       	call   c0105e3c <page_insert>
c010612d:	85 c0                	test   %eax,%eax
c010612f:	74 24                	je     c0106155 <check_pgdir+0x111>
c0106131:	c7 44 24 0c a8 ce 10 	movl   $0xc010cea8,0xc(%esp)
c0106138:	c0 
c0106139:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0106140:	c0 
c0106141:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
c0106148:	00 
c0106149:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106150:	e8 80 ac ff ff       	call   c0100dd5 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0106155:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010615a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106161:	00 
c0106162:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106169:	00 
c010616a:	89 04 24             	mov    %eax,(%esp)
c010616d:	e8 5c f6 ff ff       	call   c01057ce <get_pte>
c0106172:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106175:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106179:	75 24                	jne    c010619f <check_pgdir+0x15b>
c010617b:	c7 44 24 0c d4 ce 10 	movl   $0xc010ced4,0xc(%esp)
c0106182:	c0 
c0106183:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c010618a:	c0 
c010618b:	c7 44 24 04 8d 02 00 	movl   $0x28d,0x4(%esp)
c0106192:	00 
c0106193:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c010619a:	e8 36 ac ff ff       	call   c0100dd5 <__panic>
    assert(pte2page(*ptep) == p1);
c010619f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061a2:	8b 00                	mov    (%eax),%eax
c01061a4:	89 04 24             	mov    %eax,(%esp)
c01061a7:	e8 60 ec ff ff       	call   c0104e0c <pte2page>
c01061ac:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01061af:	74 24                	je     c01061d5 <check_pgdir+0x191>
c01061b1:	c7 44 24 0c 01 cf 10 	movl   $0xc010cf01,0xc(%esp)
c01061b8:	c0 
c01061b9:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01061c0:	c0 
c01061c1:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
c01061c8:	00 
c01061c9:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01061d0:	e8 00 ac ff ff       	call   c0100dd5 <__panic>
    assert(page_ref(p1) == 1);
c01061d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061d8:	89 04 24             	mov    %eax,(%esp)
c01061db:	e8 82 ec ff ff       	call   c0104e62 <page_ref>
c01061e0:	83 f8 01             	cmp    $0x1,%eax
c01061e3:	74 24                	je     c0106209 <check_pgdir+0x1c5>
c01061e5:	c7 44 24 0c 17 cf 10 	movl   $0xc010cf17,0xc(%esp)
c01061ec:	c0 
c01061ed:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01061f4:	c0 
c01061f5:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
c01061fc:	00 
c01061fd:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106204:	e8 cc ab ff ff       	call   c0100dd5 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0106209:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010620e:	8b 00                	mov    (%eax),%eax
c0106210:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106215:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106218:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010621b:	c1 e8 0c             	shr    $0xc,%eax
c010621e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106221:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0106226:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0106229:	72 23                	jb     c010624e <check_pgdir+0x20a>
c010622b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010622e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106232:	c7 44 24 08 6c cc 10 	movl   $0xc010cc6c,0x8(%esp)
c0106239:	c0 
c010623a:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
c0106241:	00 
c0106242:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106249:	e8 87 ab ff ff       	call   c0100dd5 <__panic>
c010624e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106251:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106256:	83 c0 04             	add    $0x4,%eax
c0106259:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c010625c:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106261:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106268:	00 
c0106269:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106270:	00 
c0106271:	89 04 24             	mov    %eax,(%esp)
c0106274:	e8 55 f5 ff ff       	call   c01057ce <get_pte>
c0106279:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010627c:	74 24                	je     c01062a2 <check_pgdir+0x25e>
c010627e:	c7 44 24 0c 2c cf 10 	movl   $0xc010cf2c,0xc(%esp)
c0106285:	c0 
c0106286:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c010628d:	c0 
c010628e:	c7 44 24 04 92 02 00 	movl   $0x292,0x4(%esp)
c0106295:	00 
c0106296:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c010629d:	e8 33 ab ff ff       	call   c0100dd5 <__panic>

    p2 = alloc_page();
c01062a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01062a9:	e8 b9 ed ff ff       	call   c0105067 <alloc_pages>
c01062ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01062b1:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01062b6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01062bd:	00 
c01062be:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01062c5:	00 
c01062c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01062c9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01062cd:	89 04 24             	mov    %eax,(%esp)
c01062d0:	e8 67 fb ff ff       	call   c0105e3c <page_insert>
c01062d5:	85 c0                	test   %eax,%eax
c01062d7:	74 24                	je     c01062fd <check_pgdir+0x2b9>
c01062d9:	c7 44 24 0c 54 cf 10 	movl   $0xc010cf54,0xc(%esp)
c01062e0:	c0 
c01062e1:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01062e8:	c0 
c01062e9:	c7 44 24 04 95 02 00 	movl   $0x295,0x4(%esp)
c01062f0:	00 
c01062f1:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01062f8:	e8 d8 aa ff ff       	call   c0100dd5 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01062fd:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106302:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106309:	00 
c010630a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106311:	00 
c0106312:	89 04 24             	mov    %eax,(%esp)
c0106315:	e8 b4 f4 ff ff       	call   c01057ce <get_pte>
c010631a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010631d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106321:	75 24                	jne    c0106347 <check_pgdir+0x303>
c0106323:	c7 44 24 0c 8c cf 10 	movl   $0xc010cf8c,0xc(%esp)
c010632a:	c0 
c010632b:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0106332:	c0 
c0106333:	c7 44 24 04 96 02 00 	movl   $0x296,0x4(%esp)
c010633a:	00 
c010633b:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106342:	e8 8e aa ff ff       	call   c0100dd5 <__panic>
    assert(*ptep & PTE_U);
c0106347:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010634a:	8b 00                	mov    (%eax),%eax
c010634c:	83 e0 04             	and    $0x4,%eax
c010634f:	85 c0                	test   %eax,%eax
c0106351:	75 24                	jne    c0106377 <check_pgdir+0x333>
c0106353:	c7 44 24 0c bc cf 10 	movl   $0xc010cfbc,0xc(%esp)
c010635a:	c0 
c010635b:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0106362:	c0 
c0106363:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
c010636a:	00 
c010636b:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106372:	e8 5e aa ff ff       	call   c0100dd5 <__panic>
    assert(*ptep & PTE_W);
c0106377:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010637a:	8b 00                	mov    (%eax),%eax
c010637c:	83 e0 02             	and    $0x2,%eax
c010637f:	85 c0                	test   %eax,%eax
c0106381:	75 24                	jne    c01063a7 <check_pgdir+0x363>
c0106383:	c7 44 24 0c ca cf 10 	movl   $0xc010cfca,0xc(%esp)
c010638a:	c0 
c010638b:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0106392:	c0 
c0106393:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
c010639a:	00 
c010639b:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01063a2:	e8 2e aa ff ff       	call   c0100dd5 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c01063a7:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01063ac:	8b 00                	mov    (%eax),%eax
c01063ae:	83 e0 04             	and    $0x4,%eax
c01063b1:	85 c0                	test   %eax,%eax
c01063b3:	75 24                	jne    c01063d9 <check_pgdir+0x395>
c01063b5:	c7 44 24 0c d8 cf 10 	movl   $0xc010cfd8,0xc(%esp)
c01063bc:	c0 
c01063bd:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01063c4:	c0 
c01063c5:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
c01063cc:	00 
c01063cd:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01063d4:	e8 fc a9 ff ff       	call   c0100dd5 <__panic>
    assert(page_ref(p2) == 1);
c01063d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01063dc:	89 04 24             	mov    %eax,(%esp)
c01063df:	e8 7e ea ff ff       	call   c0104e62 <page_ref>
c01063e4:	83 f8 01             	cmp    $0x1,%eax
c01063e7:	74 24                	je     c010640d <check_pgdir+0x3c9>
c01063e9:	c7 44 24 0c ee cf 10 	movl   $0xc010cfee,0xc(%esp)
c01063f0:	c0 
c01063f1:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01063f8:	c0 
c01063f9:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
c0106400:	00 
c0106401:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106408:	e8 c8 a9 ff ff       	call   c0100dd5 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c010640d:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106412:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106419:	00 
c010641a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0106421:	00 
c0106422:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106425:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106429:	89 04 24             	mov    %eax,(%esp)
c010642c:	e8 0b fa ff ff       	call   c0105e3c <page_insert>
c0106431:	85 c0                	test   %eax,%eax
c0106433:	74 24                	je     c0106459 <check_pgdir+0x415>
c0106435:	c7 44 24 0c 00 d0 10 	movl   $0xc010d000,0xc(%esp)
c010643c:	c0 
c010643d:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0106444:	c0 
c0106445:	c7 44 24 04 9c 02 00 	movl   $0x29c,0x4(%esp)
c010644c:	00 
c010644d:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106454:	e8 7c a9 ff ff       	call   c0100dd5 <__panic>
    assert(page_ref(p1) == 2);
c0106459:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010645c:	89 04 24             	mov    %eax,(%esp)
c010645f:	e8 fe e9 ff ff       	call   c0104e62 <page_ref>
c0106464:	83 f8 02             	cmp    $0x2,%eax
c0106467:	74 24                	je     c010648d <check_pgdir+0x449>
c0106469:	c7 44 24 0c 2c d0 10 	movl   $0xc010d02c,0xc(%esp)
c0106470:	c0 
c0106471:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0106478:	c0 
c0106479:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
c0106480:	00 
c0106481:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106488:	e8 48 a9 ff ff       	call   c0100dd5 <__panic>
    assert(page_ref(p2) == 0);
c010648d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106490:	89 04 24             	mov    %eax,(%esp)
c0106493:	e8 ca e9 ff ff       	call   c0104e62 <page_ref>
c0106498:	85 c0                	test   %eax,%eax
c010649a:	74 24                	je     c01064c0 <check_pgdir+0x47c>
c010649c:	c7 44 24 0c 3e d0 10 	movl   $0xc010d03e,0xc(%esp)
c01064a3:	c0 
c01064a4:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01064ab:	c0 
c01064ac:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
c01064b3:	00 
c01064b4:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01064bb:	e8 15 a9 ff ff       	call   c0100dd5 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01064c0:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01064c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01064cc:	00 
c01064cd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01064d4:	00 
c01064d5:	89 04 24             	mov    %eax,(%esp)
c01064d8:	e8 f1 f2 ff ff       	call   c01057ce <get_pte>
c01064dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01064e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01064e4:	75 24                	jne    c010650a <check_pgdir+0x4c6>
c01064e6:	c7 44 24 0c 8c cf 10 	movl   $0xc010cf8c,0xc(%esp)
c01064ed:	c0 
c01064ee:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01064f5:	c0 
c01064f6:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
c01064fd:	00 
c01064fe:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106505:	e8 cb a8 ff ff       	call   c0100dd5 <__panic>
    assert(pte2page(*ptep) == p1);
c010650a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010650d:	8b 00                	mov    (%eax),%eax
c010650f:	89 04 24             	mov    %eax,(%esp)
c0106512:	e8 f5 e8 ff ff       	call   c0104e0c <pte2page>
c0106517:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010651a:	74 24                	je     c0106540 <check_pgdir+0x4fc>
c010651c:	c7 44 24 0c 01 cf 10 	movl   $0xc010cf01,0xc(%esp)
c0106523:	c0 
c0106524:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c010652b:	c0 
c010652c:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
c0106533:	00 
c0106534:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c010653b:	e8 95 a8 ff ff       	call   c0100dd5 <__panic>
    assert((*ptep & PTE_U) == 0);
c0106540:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106543:	8b 00                	mov    (%eax),%eax
c0106545:	83 e0 04             	and    $0x4,%eax
c0106548:	85 c0                	test   %eax,%eax
c010654a:	74 24                	je     c0106570 <check_pgdir+0x52c>
c010654c:	c7 44 24 0c 50 d0 10 	movl   $0xc010d050,0xc(%esp)
c0106553:	c0 
c0106554:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c010655b:	c0 
c010655c:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
c0106563:	00 
c0106564:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c010656b:	e8 65 a8 ff ff       	call   c0100dd5 <__panic>

    page_remove(boot_pgdir, 0x0);
c0106570:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106575:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010657c:	00 
c010657d:	89 04 24             	mov    %eax,(%esp)
c0106580:	e8 73 f8 ff ff       	call   c0105df8 <page_remove>
    assert(page_ref(p1) == 1);
c0106585:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106588:	89 04 24             	mov    %eax,(%esp)
c010658b:	e8 d2 e8 ff ff       	call   c0104e62 <page_ref>
c0106590:	83 f8 01             	cmp    $0x1,%eax
c0106593:	74 24                	je     c01065b9 <check_pgdir+0x575>
c0106595:	c7 44 24 0c 17 cf 10 	movl   $0xc010cf17,0xc(%esp)
c010659c:	c0 
c010659d:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01065a4:	c0 
c01065a5:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
c01065ac:	00 
c01065ad:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01065b4:	e8 1c a8 ff ff       	call   c0100dd5 <__panic>
    assert(page_ref(p2) == 0);
c01065b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01065bc:	89 04 24             	mov    %eax,(%esp)
c01065bf:	e8 9e e8 ff ff       	call   c0104e62 <page_ref>
c01065c4:	85 c0                	test   %eax,%eax
c01065c6:	74 24                	je     c01065ec <check_pgdir+0x5a8>
c01065c8:	c7 44 24 0c 3e d0 10 	movl   $0xc010d03e,0xc(%esp)
c01065cf:	c0 
c01065d0:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01065d7:	c0 
c01065d8:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
c01065df:	00 
c01065e0:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01065e7:	e8 e9 a7 ff ff       	call   c0100dd5 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01065ec:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01065f1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01065f8:	00 
c01065f9:	89 04 24             	mov    %eax,(%esp)
c01065fc:	e8 f7 f7 ff ff       	call   c0105df8 <page_remove>
    assert(page_ref(p1) == 0);
c0106601:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106604:	89 04 24             	mov    %eax,(%esp)
c0106607:	e8 56 e8 ff ff       	call   c0104e62 <page_ref>
c010660c:	85 c0                	test   %eax,%eax
c010660e:	74 24                	je     c0106634 <check_pgdir+0x5f0>
c0106610:	c7 44 24 0c 65 d0 10 	movl   $0xc010d065,0xc(%esp)
c0106617:	c0 
c0106618:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c010661f:	c0 
c0106620:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
c0106627:	00 
c0106628:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c010662f:	e8 a1 a7 ff ff       	call   c0100dd5 <__panic>
    assert(page_ref(p2) == 0);
c0106634:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106637:	89 04 24             	mov    %eax,(%esp)
c010663a:	e8 23 e8 ff ff       	call   c0104e62 <page_ref>
c010663f:	85 c0                	test   %eax,%eax
c0106641:	74 24                	je     c0106667 <check_pgdir+0x623>
c0106643:	c7 44 24 0c 3e d0 10 	movl   $0xc010d03e,0xc(%esp)
c010664a:	c0 
c010664b:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0106652:	c0 
c0106653:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
c010665a:	00 
c010665b:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106662:	e8 6e a7 ff ff       	call   c0100dd5 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0106667:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010666c:	8b 00                	mov    (%eax),%eax
c010666e:	89 04 24             	mov    %eax,(%esp)
c0106671:	e8 d4 e7 ff ff       	call   c0104e4a <pde2page>
c0106676:	89 04 24             	mov    %eax,(%esp)
c0106679:	e8 e4 e7 ff ff       	call   c0104e62 <page_ref>
c010667e:	83 f8 01             	cmp    $0x1,%eax
c0106681:	74 24                	je     c01066a7 <check_pgdir+0x663>
c0106683:	c7 44 24 0c 78 d0 10 	movl   $0xc010d078,0xc(%esp)
c010668a:	c0 
c010668b:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0106692:	c0 
c0106693:	c7 44 24 04 ab 02 00 	movl   $0x2ab,0x4(%esp)
c010669a:	00 
c010669b:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01066a2:	e8 2e a7 ff ff       	call   c0100dd5 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01066a7:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01066ac:	8b 00                	mov    (%eax),%eax
c01066ae:	89 04 24             	mov    %eax,(%esp)
c01066b1:	e8 94 e7 ff ff       	call   c0104e4a <pde2page>
c01066b6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01066bd:	00 
c01066be:	89 04 24             	mov    %eax,(%esp)
c01066c1:	e8 0c ea ff ff       	call   c01050d2 <free_pages>
    boot_pgdir[0] = 0;
c01066c6:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01066cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01066d1:	c7 04 24 9f d0 10 c0 	movl   $0xc010d09f,(%esp)
c01066d8:	e8 76 9c ff ff       	call   c0100353 <cprintf>
}
c01066dd:	c9                   	leave  
c01066de:	c3                   	ret    

c01066df <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01066df:	55                   	push   %ebp
c01066e0:	89 e5                	mov    %esp,%ebp
c01066e2:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01066e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01066ec:	e9 ca 00 00 00       	jmp    c01067bb <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c01066f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01066f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01066f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066fa:	c1 e8 0c             	shr    $0xc,%eax
c01066fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106700:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0106705:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0106708:	72 23                	jb     c010672d <check_boot_pgdir+0x4e>
c010670a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010670d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106711:	c7 44 24 08 6c cc 10 	movl   $0xc010cc6c,0x8(%esp)
c0106718:	c0 
c0106719:	c7 44 24 04 b7 02 00 	movl   $0x2b7,0x4(%esp)
c0106720:	00 
c0106721:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106728:	e8 a8 a6 ff ff       	call   c0100dd5 <__panic>
c010672d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106730:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106735:	89 c2                	mov    %eax,%edx
c0106737:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010673c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106743:	00 
c0106744:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106748:	89 04 24             	mov    %eax,(%esp)
c010674b:	e8 7e f0 ff ff       	call   c01057ce <get_pte>
c0106750:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106753:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106757:	75 24                	jne    c010677d <check_boot_pgdir+0x9e>
c0106759:	c7 44 24 0c bc d0 10 	movl   $0xc010d0bc,0xc(%esp)
c0106760:	c0 
c0106761:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0106768:	c0 
c0106769:	c7 44 24 04 b7 02 00 	movl   $0x2b7,0x4(%esp)
c0106770:	00 
c0106771:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106778:	e8 58 a6 ff ff       	call   c0100dd5 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c010677d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106780:	8b 00                	mov    (%eax),%eax
c0106782:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106787:	89 c2                	mov    %eax,%edx
c0106789:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010678c:	39 c2                	cmp    %eax,%edx
c010678e:	74 24                	je     c01067b4 <check_boot_pgdir+0xd5>
c0106790:	c7 44 24 0c f9 d0 10 	movl   $0xc010d0f9,0xc(%esp)
c0106797:	c0 
c0106798:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c010679f:	c0 
c01067a0:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
c01067a7:	00 
c01067a8:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01067af:	e8 21 a6 ff ff       	call   c0100dd5 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01067b4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01067bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01067be:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c01067c3:	39 c2                	cmp    %eax,%edx
c01067c5:	0f 82 26 ff ff ff    	jb     c01066f1 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01067cb:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01067d0:	05 ac 0f 00 00       	add    $0xfac,%eax
c01067d5:	8b 00                	mov    (%eax),%eax
c01067d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01067dc:	89 c2                	mov    %eax,%edx
c01067de:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01067e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01067e6:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c01067ed:	77 23                	ja     c0106812 <check_boot_pgdir+0x133>
c01067ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01067f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01067f6:	c7 44 24 08 10 cd 10 	movl   $0xc010cd10,0x8(%esp)
c01067fd:	c0 
c01067fe:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
c0106805:	00 
c0106806:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c010680d:	e8 c3 a5 ff ff       	call   c0100dd5 <__panic>
c0106812:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106815:	05 00 00 00 40       	add    $0x40000000,%eax
c010681a:	39 c2                	cmp    %eax,%edx
c010681c:	74 24                	je     c0106842 <check_boot_pgdir+0x163>
c010681e:	c7 44 24 0c 10 d1 10 	movl   $0xc010d110,0xc(%esp)
c0106825:	c0 
c0106826:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c010682d:	c0 
c010682e:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
c0106835:	00 
c0106836:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c010683d:	e8 93 a5 ff ff       	call   c0100dd5 <__panic>

    assert(boot_pgdir[0] == 0);
c0106842:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106847:	8b 00                	mov    (%eax),%eax
c0106849:	85 c0                	test   %eax,%eax
c010684b:	74 24                	je     c0106871 <check_boot_pgdir+0x192>
c010684d:	c7 44 24 0c 44 d1 10 	movl   $0xc010d144,0xc(%esp)
c0106854:	c0 
c0106855:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c010685c:	c0 
c010685d:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
c0106864:	00 
c0106865:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c010686c:	e8 64 a5 ff ff       	call   c0100dd5 <__panic>

    struct Page *p;
    p = alloc_page();
c0106871:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106878:	e8 ea e7 ff ff       	call   c0105067 <alloc_pages>
c010687d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0106880:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106885:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c010688c:	00 
c010688d:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0106894:	00 
c0106895:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106898:	89 54 24 04          	mov    %edx,0x4(%esp)
c010689c:	89 04 24             	mov    %eax,(%esp)
c010689f:	e8 98 f5 ff ff       	call   c0105e3c <page_insert>
c01068a4:	85 c0                	test   %eax,%eax
c01068a6:	74 24                	je     c01068cc <check_boot_pgdir+0x1ed>
c01068a8:	c7 44 24 0c 58 d1 10 	movl   $0xc010d158,0xc(%esp)
c01068af:	c0 
c01068b0:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01068b7:	c0 
c01068b8:	c7 44 24 04 c1 02 00 	movl   $0x2c1,0x4(%esp)
c01068bf:	00 
c01068c0:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01068c7:	e8 09 a5 ff ff       	call   c0100dd5 <__panic>
    assert(page_ref(p) == 1);
c01068cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01068cf:	89 04 24             	mov    %eax,(%esp)
c01068d2:	e8 8b e5 ff ff       	call   c0104e62 <page_ref>
c01068d7:	83 f8 01             	cmp    $0x1,%eax
c01068da:	74 24                	je     c0106900 <check_boot_pgdir+0x221>
c01068dc:	c7 44 24 0c 86 d1 10 	movl   $0xc010d186,0xc(%esp)
c01068e3:	c0 
c01068e4:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01068eb:	c0 
c01068ec:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
c01068f3:	00 
c01068f4:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01068fb:	e8 d5 a4 ff ff       	call   c0100dd5 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0106900:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106905:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c010690c:	00 
c010690d:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0106914:	00 
c0106915:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106918:	89 54 24 04          	mov    %edx,0x4(%esp)
c010691c:	89 04 24             	mov    %eax,(%esp)
c010691f:	e8 18 f5 ff ff       	call   c0105e3c <page_insert>
c0106924:	85 c0                	test   %eax,%eax
c0106926:	74 24                	je     c010694c <check_boot_pgdir+0x26d>
c0106928:	c7 44 24 0c 98 d1 10 	movl   $0xc010d198,0xc(%esp)
c010692f:	c0 
c0106930:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0106937:	c0 
c0106938:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
c010693f:	00 
c0106940:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106947:	e8 89 a4 ff ff       	call   c0100dd5 <__panic>
    assert(page_ref(p) == 2);
c010694c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010694f:	89 04 24             	mov    %eax,(%esp)
c0106952:	e8 0b e5 ff ff       	call   c0104e62 <page_ref>
c0106957:	83 f8 02             	cmp    $0x2,%eax
c010695a:	74 24                	je     c0106980 <check_boot_pgdir+0x2a1>
c010695c:	c7 44 24 0c cf d1 10 	movl   $0xc010d1cf,0xc(%esp)
c0106963:	c0 
c0106964:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c010696b:	c0 
c010696c:	c7 44 24 04 c4 02 00 	movl   $0x2c4,0x4(%esp)
c0106973:	00 
c0106974:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c010697b:	e8 55 a4 ff ff       	call   c0100dd5 <__panic>

    const char *str = "ucore: Hello world!!";
c0106980:	c7 45 dc e0 d1 10 c0 	movl   $0xc010d1e0,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0106987:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010698a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010698e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106995:	e8 91 50 00 00       	call   c010ba2b <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c010699a:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01069a1:	00 
c01069a2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01069a9:	e8 f6 50 00 00       	call   c010baa4 <strcmp>
c01069ae:	85 c0                	test   %eax,%eax
c01069b0:	74 24                	je     c01069d6 <check_boot_pgdir+0x2f7>
c01069b2:	c7 44 24 0c f8 d1 10 	movl   $0xc010d1f8,0xc(%esp)
c01069b9:	c0 
c01069ba:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c01069c1:	c0 
c01069c2:	c7 44 24 04 c8 02 00 	movl   $0x2c8,0x4(%esp)
c01069c9:	00 
c01069ca:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c01069d1:	e8 ff a3 ff ff       	call   c0100dd5 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01069d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01069d9:	89 04 24             	mov    %eax,(%esp)
c01069dc:	e8 d7 e3 ff ff       	call   c0104db8 <page2kva>
c01069e1:	05 00 01 00 00       	add    $0x100,%eax
c01069e6:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01069e9:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01069f0:	e8 de 4f 00 00       	call   c010b9d3 <strlen>
c01069f5:	85 c0                	test   %eax,%eax
c01069f7:	74 24                	je     c0106a1d <check_boot_pgdir+0x33e>
c01069f9:	c7 44 24 0c 30 d2 10 	movl   $0xc010d230,0xc(%esp)
c0106a00:	c0 
c0106a01:	c7 44 24 08 59 cd 10 	movl   $0xc010cd59,0x8(%esp)
c0106a08:	c0 
c0106a09:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
c0106a10:	00 
c0106a11:	c7 04 24 34 cd 10 c0 	movl   $0xc010cd34,(%esp)
c0106a18:	e8 b8 a3 ff ff       	call   c0100dd5 <__panic>

    free_page(p);
c0106a1d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106a24:	00 
c0106a25:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106a28:	89 04 24             	mov    %eax,(%esp)
c0106a2b:	e8 a2 e6 ff ff       	call   c01050d2 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0106a30:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106a35:	8b 00                	mov    (%eax),%eax
c0106a37:	89 04 24             	mov    %eax,(%esp)
c0106a3a:	e8 0b e4 ff ff       	call   c0104e4a <pde2page>
c0106a3f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106a46:	00 
c0106a47:	89 04 24             	mov    %eax,(%esp)
c0106a4a:	e8 83 e6 ff ff       	call   c01050d2 <free_pages>
    boot_pgdir[0] = 0;
c0106a4f:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106a54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0106a5a:	c7 04 24 54 d2 10 c0 	movl   $0xc010d254,(%esp)
c0106a61:	e8 ed 98 ff ff       	call   c0100353 <cprintf>
}
c0106a66:	c9                   	leave  
c0106a67:	c3                   	ret    

c0106a68 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0106a68:	55                   	push   %ebp
c0106a69:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0106a6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a6e:	83 e0 04             	and    $0x4,%eax
c0106a71:	85 c0                	test   %eax,%eax
c0106a73:	74 07                	je     c0106a7c <perm2str+0x14>
c0106a75:	b8 75 00 00 00       	mov    $0x75,%eax
c0106a7a:	eb 05                	jmp    c0106a81 <perm2str+0x19>
c0106a7c:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0106a81:	a2 68 cf 19 c0       	mov    %al,0xc019cf68
    str[1] = 'r';
c0106a86:	c6 05 69 cf 19 c0 72 	movb   $0x72,0xc019cf69
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0106a8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a90:	83 e0 02             	and    $0x2,%eax
c0106a93:	85 c0                	test   %eax,%eax
c0106a95:	74 07                	je     c0106a9e <perm2str+0x36>
c0106a97:	b8 77 00 00 00       	mov    $0x77,%eax
c0106a9c:	eb 05                	jmp    c0106aa3 <perm2str+0x3b>
c0106a9e:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0106aa3:	a2 6a cf 19 c0       	mov    %al,0xc019cf6a
    str[3] = '\0';
c0106aa8:	c6 05 6b cf 19 c0 00 	movb   $0x0,0xc019cf6b
    return str;
c0106aaf:	b8 68 cf 19 c0       	mov    $0xc019cf68,%eax
}
c0106ab4:	5d                   	pop    %ebp
c0106ab5:	c3                   	ret    

c0106ab6 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0106ab6:	55                   	push   %ebp
c0106ab7:	89 e5                	mov    %esp,%ebp
c0106ab9:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0106abc:	8b 45 10             	mov    0x10(%ebp),%eax
c0106abf:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106ac2:	72 0a                	jb     c0106ace <get_pgtable_items+0x18>
        return 0;
c0106ac4:	b8 00 00 00 00       	mov    $0x0,%eax
c0106ac9:	e9 9c 00 00 00       	jmp    c0106b6a <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0106ace:	eb 04                	jmp    c0106ad4 <get_pgtable_items+0x1e>
        start ++;
c0106ad0:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0106ad4:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ad7:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106ada:	73 18                	jae    c0106af4 <get_pgtable_items+0x3e>
c0106adc:	8b 45 10             	mov    0x10(%ebp),%eax
c0106adf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106ae6:	8b 45 14             	mov    0x14(%ebp),%eax
c0106ae9:	01 d0                	add    %edx,%eax
c0106aeb:	8b 00                	mov    (%eax),%eax
c0106aed:	83 e0 01             	and    $0x1,%eax
c0106af0:	85 c0                	test   %eax,%eax
c0106af2:	74 dc                	je     c0106ad0 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0106af4:	8b 45 10             	mov    0x10(%ebp),%eax
c0106af7:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106afa:	73 69                	jae    c0106b65 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0106afc:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0106b00:	74 08                	je     c0106b0a <get_pgtable_items+0x54>
            *left_store = start;
c0106b02:	8b 45 18             	mov    0x18(%ebp),%eax
c0106b05:	8b 55 10             	mov    0x10(%ebp),%edx
c0106b08:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0106b0a:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b0d:	8d 50 01             	lea    0x1(%eax),%edx
c0106b10:	89 55 10             	mov    %edx,0x10(%ebp)
c0106b13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106b1a:	8b 45 14             	mov    0x14(%ebp),%eax
c0106b1d:	01 d0                	add    %edx,%eax
c0106b1f:	8b 00                	mov    (%eax),%eax
c0106b21:	83 e0 07             	and    $0x7,%eax
c0106b24:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106b27:	eb 04                	jmp    c0106b2d <get_pgtable_items+0x77>
            start ++;
c0106b29:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106b2d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b30:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106b33:	73 1d                	jae    c0106b52 <get_pgtable_items+0x9c>
c0106b35:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b38:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106b3f:	8b 45 14             	mov    0x14(%ebp),%eax
c0106b42:	01 d0                	add    %edx,%eax
c0106b44:	8b 00                	mov    (%eax),%eax
c0106b46:	83 e0 07             	and    $0x7,%eax
c0106b49:	89 c2                	mov    %eax,%edx
c0106b4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106b4e:	39 c2                	cmp    %eax,%edx
c0106b50:	74 d7                	je     c0106b29 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0106b52:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106b56:	74 08                	je     c0106b60 <get_pgtable_items+0xaa>
            *right_store = start;
c0106b58:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106b5b:	8b 55 10             	mov    0x10(%ebp),%edx
c0106b5e:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0106b60:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106b63:	eb 05                	jmp    c0106b6a <get_pgtable_items+0xb4>
    }
    return 0;
c0106b65:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106b6a:	c9                   	leave  
c0106b6b:	c3                   	ret    

c0106b6c <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0106b6c:	55                   	push   %ebp
c0106b6d:	89 e5                	mov    %esp,%ebp
c0106b6f:	57                   	push   %edi
c0106b70:	56                   	push   %esi
c0106b71:	53                   	push   %ebx
c0106b72:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0106b75:	c7 04 24 74 d2 10 c0 	movl   $0xc010d274,(%esp)
c0106b7c:	e8 d2 97 ff ff       	call   c0100353 <cprintf>
    size_t left, right = 0, perm;
c0106b81:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106b88:	e9 fa 00 00 00       	jmp    c0106c87 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106b8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b90:	89 04 24             	mov    %eax,(%esp)
c0106b93:	e8 d0 fe ff ff       	call   c0106a68 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0106b98:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106b9b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106b9e:	29 d1                	sub    %edx,%ecx
c0106ba0:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106ba2:	89 d6                	mov    %edx,%esi
c0106ba4:	c1 e6 16             	shl    $0x16,%esi
c0106ba7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106baa:	89 d3                	mov    %edx,%ebx
c0106bac:	c1 e3 16             	shl    $0x16,%ebx
c0106baf:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106bb2:	89 d1                	mov    %edx,%ecx
c0106bb4:	c1 e1 16             	shl    $0x16,%ecx
c0106bb7:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0106bba:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106bbd:	29 d7                	sub    %edx,%edi
c0106bbf:	89 fa                	mov    %edi,%edx
c0106bc1:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106bc5:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106bc9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106bcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106bd1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106bd5:	c7 04 24 a5 d2 10 c0 	movl   $0xc010d2a5,(%esp)
c0106bdc:	e8 72 97 ff ff       	call   c0100353 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0106be1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106be4:	c1 e0 0a             	shl    $0xa,%eax
c0106be7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106bea:	eb 54                	jmp    c0106c40 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106bec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106bef:	89 04 24             	mov    %eax,(%esp)
c0106bf2:	e8 71 fe ff ff       	call   c0106a68 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0106bf7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0106bfa:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106bfd:	29 d1                	sub    %edx,%ecx
c0106bff:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106c01:	89 d6                	mov    %edx,%esi
c0106c03:	c1 e6 0c             	shl    $0xc,%esi
c0106c06:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106c09:	89 d3                	mov    %edx,%ebx
c0106c0b:	c1 e3 0c             	shl    $0xc,%ebx
c0106c0e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106c11:	c1 e2 0c             	shl    $0xc,%edx
c0106c14:	89 d1                	mov    %edx,%ecx
c0106c16:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0106c19:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106c1c:	29 d7                	sub    %edx,%edi
c0106c1e:	89 fa                	mov    %edi,%edx
c0106c20:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106c24:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106c28:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106c2c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106c30:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106c34:	c7 04 24 c4 d2 10 c0 	movl   $0xc010d2c4,(%esp)
c0106c3b:	e8 13 97 ff ff       	call   c0100353 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106c40:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0106c45:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106c48:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106c4b:	89 ce                	mov    %ecx,%esi
c0106c4d:	c1 e6 0a             	shl    $0xa,%esi
c0106c50:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0106c53:	89 cb                	mov    %ecx,%ebx
c0106c55:	c1 e3 0a             	shl    $0xa,%ebx
c0106c58:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0106c5b:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0106c5f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0106c62:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0106c66:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106c6a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106c6e:	89 74 24 04          	mov    %esi,0x4(%esp)
c0106c72:	89 1c 24             	mov    %ebx,(%esp)
c0106c75:	e8 3c fe ff ff       	call   c0106ab6 <get_pgtable_items>
c0106c7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106c7d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106c81:	0f 85 65 ff ff ff    	jne    c0106bec <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106c87:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0106c8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106c8f:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0106c92:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0106c96:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0106c99:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0106c9d:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106ca1:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106ca5:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0106cac:	00 
c0106cad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0106cb4:	e8 fd fd ff ff       	call   c0106ab6 <get_pgtable_items>
c0106cb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106cbc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106cc0:	0f 85 c7 fe ff ff    	jne    c0106b8d <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106cc6:	c7 04 24 e8 d2 10 c0 	movl   $0xc010d2e8,(%esp)
c0106ccd:	e8 81 96 ff ff       	call   c0100353 <cprintf>
}
c0106cd2:	83 c4 4c             	add    $0x4c,%esp
c0106cd5:	5b                   	pop    %ebx
c0106cd6:	5e                   	pop    %esi
c0106cd7:	5f                   	pop    %edi
c0106cd8:	5d                   	pop    %ebp
c0106cd9:	c3                   	ret    

c0106cda <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0106cda:	55                   	push   %ebp
c0106cdb:	89 e5                	mov    %esp,%ebp
c0106cdd:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0106ce0:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ce3:	c1 e8 0c             	shr    $0xc,%eax
c0106ce6:	89 c2                	mov    %eax,%edx
c0106ce8:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0106ced:	39 c2                	cmp    %eax,%edx
c0106cef:	72 1c                	jb     c0106d0d <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0106cf1:	c7 44 24 08 1c d3 10 	movl   $0xc010d31c,0x8(%esp)
c0106cf8:	c0 
c0106cf9:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0106d00:	00 
c0106d01:	c7 04 24 3b d3 10 c0 	movl   $0xc010d33b,(%esp)
c0106d08:	e8 c8 a0 ff ff       	call   c0100dd5 <__panic>
    }
    return &pages[PPN(pa)];
c0106d0d:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0106d12:	8b 55 08             	mov    0x8(%ebp),%edx
c0106d15:	c1 ea 0c             	shr    $0xc,%edx
c0106d18:	c1 e2 05             	shl    $0x5,%edx
c0106d1b:	01 d0                	add    %edx,%eax
}
c0106d1d:	c9                   	leave  
c0106d1e:	c3                   	ret    

c0106d1f <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0106d1f:	55                   	push   %ebp
c0106d20:	89 e5                	mov    %esp,%ebp
c0106d22:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0106d25:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d28:	83 e0 01             	and    $0x1,%eax
c0106d2b:	85 c0                	test   %eax,%eax
c0106d2d:	75 1c                	jne    c0106d4b <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0106d2f:	c7 44 24 08 4c d3 10 	movl   $0xc010d34c,0x8(%esp)
c0106d36:	c0 
c0106d37:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0106d3e:	00 
c0106d3f:	c7 04 24 3b d3 10 c0 	movl   $0xc010d33b,(%esp)
c0106d46:	e8 8a a0 ff ff       	call   c0100dd5 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0106d4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d4e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106d53:	89 04 24             	mov    %eax,(%esp)
c0106d56:	e8 7f ff ff ff       	call   c0106cda <pa2page>
}
c0106d5b:	c9                   	leave  
c0106d5c:	c3                   	ret    

c0106d5d <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0106d5d:	55                   	push   %ebp
c0106d5e:	89 e5                	mov    %esp,%ebp
c0106d60:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0106d63:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d66:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106d6b:	89 04 24             	mov    %eax,(%esp)
c0106d6e:	e8 67 ff ff ff       	call   c0106cda <pa2page>
}
c0106d73:	c9                   	leave  
c0106d74:	c3                   	ret    

c0106d75 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106d75:	55                   	push   %ebp
c0106d76:	89 e5                	mov    %esp,%ebp
c0106d78:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0106d7b:	e8 04 24 00 00       	call   c0109184 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0106d80:	a1 7c f0 19 c0       	mov    0xc019f07c,%eax
c0106d85:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106d8a:	76 0c                	jbe    c0106d98 <swap_init+0x23>
c0106d8c:	a1 7c f0 19 c0       	mov    0xc019f07c,%eax
c0106d91:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106d96:	76 25                	jbe    c0106dbd <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106d98:	a1 7c f0 19 c0       	mov    0xc019f07c,%eax
c0106d9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106da1:	c7 44 24 08 6d d3 10 	movl   $0xc010d36d,0x8(%esp)
c0106da8:	c0 
c0106da9:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
c0106db0:	00 
c0106db1:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c0106db8:	e8 18 a0 ff ff       	call   c0100dd5 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106dbd:	c7 05 74 cf 19 c0 60 	movl   $0xc012aa60,0xc019cf74
c0106dc4:	aa 12 c0 
     int r = sm->init();
c0106dc7:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106dcc:	8b 40 04             	mov    0x4(%eax),%eax
c0106dcf:	ff d0                	call   *%eax
c0106dd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106dd4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106dd8:	75 26                	jne    c0106e00 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0106dda:	c7 05 6c cf 19 c0 01 	movl   $0x1,0xc019cf6c
c0106de1:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106de4:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106de9:	8b 00                	mov    (%eax),%eax
c0106deb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106def:	c7 04 24 97 d3 10 c0 	movl   $0xc010d397,(%esp)
c0106df6:	e8 58 95 ff ff       	call   c0100353 <cprintf>
          check_swap();
c0106dfb:	e8 a4 04 00 00       	call   c01072a4 <check_swap>
     }

     return r;
c0106e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106e03:	c9                   	leave  
c0106e04:	c3                   	ret    

c0106e05 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0106e05:	55                   	push   %ebp
c0106e06:	89 e5                	mov    %esp,%ebp
c0106e08:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0106e0b:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106e10:	8b 40 08             	mov    0x8(%eax),%eax
c0106e13:	8b 55 08             	mov    0x8(%ebp),%edx
c0106e16:	89 14 24             	mov    %edx,(%esp)
c0106e19:	ff d0                	call   *%eax
}
c0106e1b:	c9                   	leave  
c0106e1c:	c3                   	ret    

c0106e1d <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0106e1d:	55                   	push   %ebp
c0106e1e:	89 e5                	mov    %esp,%ebp
c0106e20:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0106e23:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106e28:	8b 40 0c             	mov    0xc(%eax),%eax
c0106e2b:	8b 55 08             	mov    0x8(%ebp),%edx
c0106e2e:	89 14 24             	mov    %edx,(%esp)
c0106e31:	ff d0                	call   *%eax
}
c0106e33:	c9                   	leave  
c0106e34:	c3                   	ret    

c0106e35 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106e35:	55                   	push   %ebp
c0106e36:	89 e5                	mov    %esp,%ebp
c0106e38:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0106e3b:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106e40:	8b 40 10             	mov    0x10(%eax),%eax
c0106e43:	8b 55 14             	mov    0x14(%ebp),%edx
c0106e46:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106e4a:	8b 55 10             	mov    0x10(%ebp),%edx
c0106e4d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106e51:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106e54:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106e58:	8b 55 08             	mov    0x8(%ebp),%edx
c0106e5b:	89 14 24             	mov    %edx,(%esp)
c0106e5e:	ff d0                	call   *%eax
}
c0106e60:	c9                   	leave  
c0106e61:	c3                   	ret    

c0106e62 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0106e62:	55                   	push   %ebp
c0106e63:	89 e5                	mov    %esp,%ebp
c0106e65:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0106e68:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106e6d:	8b 40 14             	mov    0x14(%eax),%eax
c0106e70:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106e73:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106e77:	8b 55 08             	mov    0x8(%ebp),%edx
c0106e7a:	89 14 24             	mov    %edx,(%esp)
c0106e7d:	ff d0                	call   *%eax
}
c0106e7f:	c9                   	leave  
c0106e80:	c3                   	ret    

c0106e81 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0106e81:	55                   	push   %ebp
c0106e82:	89 e5                	mov    %esp,%ebp
c0106e84:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0106e87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106e8e:	e9 5a 01 00 00       	jmp    c0106fed <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106e93:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106e98:	8b 40 18             	mov    0x18(%eax),%eax
c0106e9b:	8b 55 10             	mov    0x10(%ebp),%edx
c0106e9e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106ea2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0106ea5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106ea9:	8b 55 08             	mov    0x8(%ebp),%edx
c0106eac:	89 14 24             	mov    %edx,(%esp)
c0106eaf:	ff d0                	call   *%eax
c0106eb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0106eb4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106eb8:	74 18                	je     c0106ed2 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0106eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ec1:	c7 04 24 ac d3 10 c0 	movl   $0xc010d3ac,(%esp)
c0106ec8:	e8 86 94 ff ff       	call   c0100353 <cprintf>
c0106ecd:	e9 27 01 00 00       	jmp    c0106ff9 <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0106ed2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ed5:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106ed8:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0106edb:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ede:	8b 40 0c             	mov    0xc(%eax),%eax
c0106ee1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106ee8:	00 
c0106ee9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106eec:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106ef0:	89 04 24             	mov    %eax,(%esp)
c0106ef3:	e8 d6 e8 ff ff       	call   c01057ce <get_pte>
c0106ef8:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0106efb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106efe:	8b 00                	mov    (%eax),%eax
c0106f00:	83 e0 01             	and    $0x1,%eax
c0106f03:	85 c0                	test   %eax,%eax
c0106f05:	75 24                	jne    c0106f2b <swap_out+0xaa>
c0106f07:	c7 44 24 0c d9 d3 10 	movl   $0xc010d3d9,0xc(%esp)
c0106f0e:	c0 
c0106f0f:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c0106f16:	c0 
c0106f17:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0106f1e:	00 
c0106f1f:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c0106f26:	e8 aa 9e ff ff       	call   c0100dd5 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0106f2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f2e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106f31:	8b 52 1c             	mov    0x1c(%edx),%edx
c0106f34:	c1 ea 0c             	shr    $0xc,%edx
c0106f37:	83 c2 01             	add    $0x1,%edx
c0106f3a:	c1 e2 08             	shl    $0x8,%edx
c0106f3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f41:	89 14 24             	mov    %edx,(%esp)
c0106f44:	e8 f5 22 00 00       	call   c010923e <swapfs_write>
c0106f49:	85 c0                	test   %eax,%eax
c0106f4b:	74 34                	je     c0106f81 <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c0106f4d:	c7 04 24 03 d4 10 c0 	movl   $0xc010d403,(%esp)
c0106f54:	e8 fa 93 ff ff       	call   c0100353 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0106f59:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106f5e:	8b 40 10             	mov    0x10(%eax),%eax
c0106f61:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106f64:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106f6b:	00 
c0106f6c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106f70:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106f73:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106f77:	8b 55 08             	mov    0x8(%ebp),%edx
c0106f7a:	89 14 24             	mov    %edx,(%esp)
c0106f7d:	ff d0                	call   *%eax
c0106f7f:	eb 68                	jmp    c0106fe9 <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0106f81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f84:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106f87:	c1 e8 0c             	shr    $0xc,%eax
c0106f8a:	83 c0 01             	add    $0x1,%eax
c0106f8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106f91:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f94:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f9f:	c7 04 24 1c d4 10 c0 	movl   $0xc010d41c,(%esp)
c0106fa6:	e8 a8 93 ff ff       	call   c0100353 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0106fab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106fae:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106fb1:	c1 e8 0c             	shr    $0xc,%eax
c0106fb4:	83 c0 01             	add    $0x1,%eax
c0106fb7:	c1 e0 08             	shl    $0x8,%eax
c0106fba:	89 c2                	mov    %eax,%edx
c0106fbc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106fbf:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106fc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106fc4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106fcb:	00 
c0106fcc:	89 04 24             	mov    %eax,(%esp)
c0106fcf:	e8 fe e0 ff ff       	call   c01050d2 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106fd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0106fd7:	8b 40 0c             	mov    0xc(%eax),%eax
c0106fda:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106fdd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106fe1:	89 04 24             	mov    %eax,(%esp)
c0106fe4:	e8 0c ef ff ff       	call   c0105ef5 <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0106fe9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ff0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106ff3:	0f 85 9a fe ff ff    	jne    c0106e93 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0106ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106ffc:	c9                   	leave  
c0106ffd:	c3                   	ret    

c0106ffe <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0106ffe:	55                   	push   %ebp
c0106fff:	89 e5                	mov    %esp,%ebp
c0107001:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0107004:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010700b:	e8 57 e0 ff ff       	call   c0105067 <alloc_pages>
c0107010:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0107013:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107017:	75 24                	jne    c010703d <swap_in+0x3f>
c0107019:	c7 44 24 0c 5c d4 10 	movl   $0xc010d45c,0xc(%esp)
c0107020:	c0 
c0107021:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c0107028:	c0 
c0107029:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0107030:	00 
c0107031:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c0107038:	e8 98 9d ff ff       	call   c0100dd5 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c010703d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107040:	8b 40 0c             	mov    0xc(%eax),%eax
c0107043:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010704a:	00 
c010704b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010704e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107052:	89 04 24             	mov    %eax,(%esp)
c0107055:	e8 74 e7 ff ff       	call   c01057ce <get_pte>
c010705a:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c010705d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107060:	8b 00                	mov    (%eax),%eax
c0107062:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107065:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107069:	89 04 24             	mov    %eax,(%esp)
c010706c:	e8 5b 21 00 00       	call   c01091cc <swapfs_read>
c0107071:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107074:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107078:	74 2a                	je     c01070a4 <swap_in+0xa6>
     {
        assert(r!=0);
c010707a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010707e:	75 24                	jne    c01070a4 <swap_in+0xa6>
c0107080:	c7 44 24 0c 69 d4 10 	movl   $0xc010d469,0xc(%esp)
c0107087:	c0 
c0107088:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c010708f:	c0 
c0107090:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c0107097:	00 
c0107098:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c010709f:	e8 31 9d ff ff       	call   c0100dd5 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c01070a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01070a7:	8b 00                	mov    (%eax),%eax
c01070a9:	c1 e8 08             	shr    $0x8,%eax
c01070ac:	89 c2                	mov    %eax,%edx
c01070ae:	8b 45 0c             	mov    0xc(%ebp),%eax
c01070b1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01070b5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01070b9:	c7 04 24 70 d4 10 c0 	movl   $0xc010d470,(%esp)
c01070c0:	e8 8e 92 ff ff       	call   c0100353 <cprintf>
     *ptr_result=result;
c01070c5:	8b 45 10             	mov    0x10(%ebp),%eax
c01070c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01070cb:	89 10                	mov    %edx,(%eax)
     return 0;
c01070cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01070d2:	c9                   	leave  
c01070d3:	c3                   	ret    

c01070d4 <check_content_set>:



static inline void
check_content_set(void)
{
c01070d4:	55                   	push   %ebp
c01070d5:	89 e5                	mov    %esp,%ebp
c01070d7:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c01070da:	b8 00 10 00 00       	mov    $0x1000,%eax
c01070df:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01070e2:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c01070e7:	83 f8 01             	cmp    $0x1,%eax
c01070ea:	74 24                	je     c0107110 <check_content_set+0x3c>
c01070ec:	c7 44 24 0c ae d4 10 	movl   $0xc010d4ae,0xc(%esp)
c01070f3:	c0 
c01070f4:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c01070fb:	c0 
c01070fc:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0107103:	00 
c0107104:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c010710b:	e8 c5 9c ff ff       	call   c0100dd5 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0107110:	b8 10 10 00 00       	mov    $0x1010,%eax
c0107115:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0107118:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c010711d:	83 f8 01             	cmp    $0x1,%eax
c0107120:	74 24                	je     c0107146 <check_content_set+0x72>
c0107122:	c7 44 24 0c ae d4 10 	movl   $0xc010d4ae,0xc(%esp)
c0107129:	c0 
c010712a:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c0107131:	c0 
c0107132:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0107139:	00 
c010713a:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c0107141:	e8 8f 9c ff ff       	call   c0100dd5 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0107146:	b8 00 20 00 00       	mov    $0x2000,%eax
c010714b:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c010714e:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107153:	83 f8 02             	cmp    $0x2,%eax
c0107156:	74 24                	je     c010717c <check_content_set+0xa8>
c0107158:	c7 44 24 0c bd d4 10 	movl   $0xc010d4bd,0xc(%esp)
c010715f:	c0 
c0107160:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c0107167:	c0 
c0107168:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c010716f:	00 
c0107170:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c0107177:	e8 59 9c ff ff       	call   c0100dd5 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c010717c:	b8 10 20 00 00       	mov    $0x2010,%eax
c0107181:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0107184:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107189:	83 f8 02             	cmp    $0x2,%eax
c010718c:	74 24                	je     c01071b2 <check_content_set+0xde>
c010718e:	c7 44 24 0c bd d4 10 	movl   $0xc010d4bd,0xc(%esp)
c0107195:	c0 
c0107196:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c010719d:	c0 
c010719e:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c01071a5:	00 
c01071a6:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c01071ad:	e8 23 9c ff ff       	call   c0100dd5 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c01071b2:	b8 00 30 00 00       	mov    $0x3000,%eax
c01071b7:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01071ba:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c01071bf:	83 f8 03             	cmp    $0x3,%eax
c01071c2:	74 24                	je     c01071e8 <check_content_set+0x114>
c01071c4:	c7 44 24 0c cc d4 10 	movl   $0xc010d4cc,0xc(%esp)
c01071cb:	c0 
c01071cc:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c01071d3:	c0 
c01071d4:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c01071db:	00 
c01071dc:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c01071e3:	e8 ed 9b ff ff       	call   c0100dd5 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c01071e8:	b8 10 30 00 00       	mov    $0x3010,%eax
c01071ed:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01071f0:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c01071f5:	83 f8 03             	cmp    $0x3,%eax
c01071f8:	74 24                	je     c010721e <check_content_set+0x14a>
c01071fa:	c7 44 24 0c cc d4 10 	movl   $0xc010d4cc,0xc(%esp)
c0107201:	c0 
c0107202:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c0107209:	c0 
c010720a:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0107211:	00 
c0107212:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c0107219:	e8 b7 9b ff ff       	call   c0100dd5 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c010721e:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107223:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0107226:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c010722b:	83 f8 04             	cmp    $0x4,%eax
c010722e:	74 24                	je     c0107254 <check_content_set+0x180>
c0107230:	c7 44 24 0c db d4 10 	movl   $0xc010d4db,0xc(%esp)
c0107237:	c0 
c0107238:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c010723f:	c0 
c0107240:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0107247:	00 
c0107248:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c010724f:	e8 81 9b ff ff       	call   c0100dd5 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0107254:	b8 10 40 00 00       	mov    $0x4010,%eax
c0107259:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c010725c:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107261:	83 f8 04             	cmp    $0x4,%eax
c0107264:	74 24                	je     c010728a <check_content_set+0x1b6>
c0107266:	c7 44 24 0c db d4 10 	movl   $0xc010d4db,0xc(%esp)
c010726d:	c0 
c010726e:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c0107275:	c0 
c0107276:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c010727d:	00 
c010727e:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c0107285:	e8 4b 9b ff ff       	call   c0100dd5 <__panic>
}
c010728a:	c9                   	leave  
c010728b:	c3                   	ret    

c010728c <check_content_access>:

static inline int
check_content_access(void)
{
c010728c:	55                   	push   %ebp
c010728d:	89 e5                	mov    %esp,%ebp
c010728f:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0107292:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0107297:	8b 40 1c             	mov    0x1c(%eax),%eax
c010729a:	ff d0                	call   *%eax
c010729c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c010729f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01072a2:	c9                   	leave  
c01072a3:	c3                   	ret    

c01072a4 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c01072a4:	55                   	push   %ebp
c01072a5:	89 e5                	mov    %esp,%ebp
c01072a7:	53                   	push   %ebx
c01072a8:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c01072ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01072b2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c01072b9:	c7 45 e8 b8 ef 19 c0 	movl   $0xc019efb8,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01072c0:	eb 6b                	jmp    c010732d <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c01072c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01072c5:	83 e8 0c             	sub    $0xc,%eax
c01072c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c01072cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01072ce:	83 c0 04             	add    $0x4,%eax
c01072d1:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c01072d8:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01072db:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01072de:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01072e1:	0f a3 10             	bt     %edx,(%eax)
c01072e4:	19 c0                	sbb    %eax,%eax
c01072e6:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c01072e9:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01072ed:	0f 95 c0             	setne  %al
c01072f0:	0f b6 c0             	movzbl %al,%eax
c01072f3:	85 c0                	test   %eax,%eax
c01072f5:	75 24                	jne    c010731b <check_swap+0x77>
c01072f7:	c7 44 24 0c ea d4 10 	movl   $0xc010d4ea,0xc(%esp)
c01072fe:	c0 
c01072ff:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c0107306:	c0 
c0107307:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c010730e:	00 
c010730f:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c0107316:	e8 ba 9a ff ff       	call   c0100dd5 <__panic>
        count ++, total += p->property;
c010731b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010731f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107322:	8b 50 08             	mov    0x8(%eax),%edx
c0107325:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107328:	01 d0                	add    %edx,%eax
c010732a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010732d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107330:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107333:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107336:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0107339:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010733c:	81 7d e8 b8 ef 19 c0 	cmpl   $0xc019efb8,-0x18(%ebp)
c0107343:	0f 85 79 ff ff ff    	jne    c01072c2 <check_swap+0x1e>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c0107349:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c010734c:	e8 b3 dd ff ff       	call   c0105104 <nr_free_pages>
c0107351:	39 c3                	cmp    %eax,%ebx
c0107353:	74 24                	je     c0107379 <check_swap+0xd5>
c0107355:	c7 44 24 0c fa d4 10 	movl   $0xc010d4fa,0xc(%esp)
c010735c:	c0 
c010735d:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c0107364:	c0 
c0107365:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c010736c:	00 
c010736d:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c0107374:	e8 5c 9a ff ff       	call   c0100dd5 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0107379:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010737c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107380:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107383:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107387:	c7 04 24 14 d5 10 c0 	movl   $0xc010d514,(%esp)
c010738e:	e8 c0 8f ff ff       	call   c0100353 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0107393:	e8 6e 0b 00 00       	call   c0107f06 <mm_create>
c0107398:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c010739b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010739f:	75 24                	jne    c01073c5 <check_swap+0x121>
c01073a1:	c7 44 24 0c 3a d5 10 	movl   $0xc010d53a,0xc(%esp)
c01073a8:	c0 
c01073a9:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c01073b0:	c0 
c01073b1:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c01073b8:	00 
c01073b9:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c01073c0:	e8 10 9a ff ff       	call   c0100dd5 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c01073c5:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c01073ca:	85 c0                	test   %eax,%eax
c01073cc:	74 24                	je     c01073f2 <check_swap+0x14e>
c01073ce:	c7 44 24 0c 45 d5 10 	movl   $0xc010d545,0xc(%esp)
c01073d5:	c0 
c01073d6:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c01073dd:	c0 
c01073de:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c01073e5:	00 
c01073e6:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c01073ed:	e8 e3 99 ff ff       	call   c0100dd5 <__panic>

     check_mm_struct = mm;
c01073f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01073f5:	a3 ac f0 19 c0       	mov    %eax,0xc019f0ac

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c01073fa:	8b 15 e4 ce 19 c0    	mov    0xc019cee4,%edx
c0107400:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107403:	89 50 0c             	mov    %edx,0xc(%eax)
c0107406:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107409:	8b 40 0c             	mov    0xc(%eax),%eax
c010740c:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c010740f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107412:	8b 00                	mov    (%eax),%eax
c0107414:	85 c0                	test   %eax,%eax
c0107416:	74 24                	je     c010743c <check_swap+0x198>
c0107418:	c7 44 24 0c 5d d5 10 	movl   $0xc010d55d,0xc(%esp)
c010741f:	c0 
c0107420:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c0107427:	c0 
c0107428:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c010742f:	00 
c0107430:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c0107437:	e8 99 99 ff ff       	call   c0100dd5 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c010743c:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0107443:	00 
c0107444:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c010744b:	00 
c010744c:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0107453:	e8 47 0b 00 00       	call   c0107f9f <vma_create>
c0107458:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c010745b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010745f:	75 24                	jne    c0107485 <check_swap+0x1e1>
c0107461:	c7 44 24 0c 6b d5 10 	movl   $0xc010d56b,0xc(%esp)
c0107468:	c0 
c0107469:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c0107470:	c0 
c0107471:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0107478:	00 
c0107479:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c0107480:	e8 50 99 ff ff       	call   c0100dd5 <__panic>

     insert_vma_struct(mm, vma);
c0107485:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107488:	89 44 24 04          	mov    %eax,0x4(%esp)
c010748c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010748f:	89 04 24             	mov    %eax,(%esp)
c0107492:	e8 98 0c 00 00       	call   c010812f <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0107497:	c7 04 24 78 d5 10 c0 	movl   $0xc010d578,(%esp)
c010749e:	e8 b0 8e ff ff       	call   c0100353 <cprintf>
     pte_t *temp_ptep=NULL;
c01074a3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c01074aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01074ad:	8b 40 0c             	mov    0xc(%eax),%eax
c01074b0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01074b7:	00 
c01074b8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01074bf:	00 
c01074c0:	89 04 24             	mov    %eax,(%esp)
c01074c3:	e8 06 e3 ff ff       	call   c01057ce <get_pte>
c01074c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c01074cb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c01074cf:	75 24                	jne    c01074f5 <check_swap+0x251>
c01074d1:	c7 44 24 0c ac d5 10 	movl   $0xc010d5ac,0xc(%esp)
c01074d8:	c0 
c01074d9:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c01074e0:	c0 
c01074e1:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c01074e8:	00 
c01074e9:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c01074f0:	e8 e0 98 ff ff       	call   c0100dd5 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c01074f5:	c7 04 24 c0 d5 10 c0 	movl   $0xc010d5c0,(%esp)
c01074fc:	e8 52 8e ff ff       	call   c0100353 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107501:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107508:	e9 a3 00 00 00       	jmp    c01075b0 <check_swap+0x30c>
          check_rp[i] = alloc_page();
c010750d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107514:	e8 4e db ff ff       	call   c0105067 <alloc_pages>
c0107519:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010751c:	89 04 95 e0 ef 19 c0 	mov    %eax,-0x3fe61020(,%edx,4)
          assert(check_rp[i] != NULL );
c0107523:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107526:	8b 04 85 e0 ef 19 c0 	mov    -0x3fe61020(,%eax,4),%eax
c010752d:	85 c0                	test   %eax,%eax
c010752f:	75 24                	jne    c0107555 <check_swap+0x2b1>
c0107531:	c7 44 24 0c e4 d5 10 	movl   $0xc010d5e4,0xc(%esp)
c0107538:	c0 
c0107539:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c0107540:	c0 
c0107541:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0107548:	00 
c0107549:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c0107550:	e8 80 98 ff ff       	call   c0100dd5 <__panic>
          assert(!PageProperty(check_rp[i]));
c0107555:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107558:	8b 04 85 e0 ef 19 c0 	mov    -0x3fe61020(,%eax,4),%eax
c010755f:	83 c0 04             	add    $0x4,%eax
c0107562:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0107569:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010756c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010756f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0107572:	0f a3 10             	bt     %edx,(%eax)
c0107575:	19 c0                	sbb    %eax,%eax
c0107577:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c010757a:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c010757e:	0f 95 c0             	setne  %al
c0107581:	0f b6 c0             	movzbl %al,%eax
c0107584:	85 c0                	test   %eax,%eax
c0107586:	74 24                	je     c01075ac <check_swap+0x308>
c0107588:	c7 44 24 0c f8 d5 10 	movl   $0xc010d5f8,0xc(%esp)
c010758f:	c0 
c0107590:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c0107597:	c0 
c0107598:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c010759f:	00 
c01075a0:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c01075a7:	e8 29 98 ff ff       	call   c0100dd5 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01075ac:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01075b0:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01075b4:	0f 8e 53 ff ff ff    	jle    c010750d <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c01075ba:	a1 b8 ef 19 c0       	mov    0xc019efb8,%eax
c01075bf:	8b 15 bc ef 19 c0    	mov    0xc019efbc,%edx
c01075c5:	89 45 98             	mov    %eax,-0x68(%ebp)
c01075c8:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01075cb:	c7 45 a8 b8 ef 19 c0 	movl   $0xc019efb8,-0x58(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01075d2:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01075d5:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01075d8:	89 50 04             	mov    %edx,0x4(%eax)
c01075db:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01075de:	8b 50 04             	mov    0x4(%eax),%edx
c01075e1:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01075e4:	89 10                	mov    %edx,(%eax)
c01075e6:	c7 45 a4 b8 ef 19 c0 	movl   $0xc019efb8,-0x5c(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01075ed:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01075f0:	8b 40 04             	mov    0x4(%eax),%eax
c01075f3:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c01075f6:	0f 94 c0             	sete   %al
c01075f9:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c01075fc:	85 c0                	test   %eax,%eax
c01075fe:	75 24                	jne    c0107624 <check_swap+0x380>
c0107600:	c7 44 24 0c 13 d6 10 	movl   $0xc010d613,0xc(%esp)
c0107607:	c0 
c0107608:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c010760f:	c0 
c0107610:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0107617:	00 
c0107618:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c010761f:	e8 b1 97 ff ff       	call   c0100dd5 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0107624:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c0107629:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c010762c:	c7 05 c0 ef 19 c0 00 	movl   $0x0,0xc019efc0
c0107633:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107636:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010763d:	eb 1e                	jmp    c010765d <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c010763f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107642:	8b 04 85 e0 ef 19 c0 	mov    -0x3fe61020(,%eax,4),%eax
c0107649:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107650:	00 
c0107651:	89 04 24             	mov    %eax,(%esp)
c0107654:	e8 79 da ff ff       	call   c01050d2 <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107659:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010765d:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107661:	7e dc                	jle    c010763f <check_swap+0x39b>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0107663:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c0107668:	83 f8 04             	cmp    $0x4,%eax
c010766b:	74 24                	je     c0107691 <check_swap+0x3ed>
c010766d:	c7 44 24 0c 2c d6 10 	movl   $0xc010d62c,0xc(%esp)
c0107674:	c0 
c0107675:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c010767c:	c0 
c010767d:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0107684:	00 
c0107685:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c010768c:	e8 44 97 ff ff       	call   c0100dd5 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0107691:	c7 04 24 50 d6 10 c0 	movl   $0xc010d650,(%esp)
c0107698:	e8 b6 8c ff ff       	call   c0100353 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c010769d:	c7 05 78 cf 19 c0 00 	movl   $0x0,0xc019cf78
c01076a4:	00 00 00 
     
     check_content_set();
c01076a7:	e8 28 fa ff ff       	call   c01070d4 <check_content_set>
     assert( nr_free == 0);         
c01076ac:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c01076b1:	85 c0                	test   %eax,%eax
c01076b3:	74 24                	je     c01076d9 <check_swap+0x435>
c01076b5:	c7 44 24 0c 77 d6 10 	movl   $0xc010d677,0xc(%esp)
c01076bc:	c0 
c01076bd:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c01076c4:	c0 
c01076c5:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c01076cc:	00 
c01076cd:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c01076d4:	e8 fc 96 ff ff       	call   c0100dd5 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01076d9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01076e0:	eb 26                	jmp    c0107708 <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c01076e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01076e5:	c7 04 85 00 f0 19 c0 	movl   $0xffffffff,-0x3fe61000(,%eax,4)
c01076ec:	ff ff ff ff 
c01076f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01076f3:	8b 14 85 00 f0 19 c0 	mov    -0x3fe61000(,%eax,4),%edx
c01076fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01076fd:	89 14 85 40 f0 19 c0 	mov    %edx,-0x3fe60fc0(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0107704:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107708:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c010770c:	7e d4                	jle    c01076e2 <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010770e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107715:	e9 eb 00 00 00       	jmp    c0107805 <check_swap+0x561>
         check_ptep[i]=0;
c010771a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010771d:	c7 04 85 94 f0 19 c0 	movl   $0x0,-0x3fe60f6c(,%eax,4)
c0107724:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0107728:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010772b:	83 c0 01             	add    $0x1,%eax
c010772e:	c1 e0 0c             	shl    $0xc,%eax
c0107731:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107738:	00 
c0107739:	89 44 24 04          	mov    %eax,0x4(%esp)
c010773d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107740:	89 04 24             	mov    %eax,(%esp)
c0107743:	e8 86 e0 ff ff       	call   c01057ce <get_pte>
c0107748:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010774b:	89 04 95 94 f0 19 c0 	mov    %eax,-0x3fe60f6c(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0107752:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107755:	8b 04 85 94 f0 19 c0 	mov    -0x3fe60f6c(,%eax,4),%eax
c010775c:	85 c0                	test   %eax,%eax
c010775e:	75 24                	jne    c0107784 <check_swap+0x4e0>
c0107760:	c7 44 24 0c 84 d6 10 	movl   $0xc010d684,0xc(%esp)
c0107767:	c0 
c0107768:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c010776f:	c0 
c0107770:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0107777:	00 
c0107778:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c010777f:	e8 51 96 ff ff       	call   c0100dd5 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0107784:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107787:	8b 04 85 94 f0 19 c0 	mov    -0x3fe60f6c(,%eax,4),%eax
c010778e:	8b 00                	mov    (%eax),%eax
c0107790:	89 04 24             	mov    %eax,(%esp)
c0107793:	e8 87 f5 ff ff       	call   c0106d1f <pte2page>
c0107798:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010779b:	8b 14 95 e0 ef 19 c0 	mov    -0x3fe61020(,%edx,4),%edx
c01077a2:	39 d0                	cmp    %edx,%eax
c01077a4:	74 24                	je     c01077ca <check_swap+0x526>
c01077a6:	c7 44 24 0c 9c d6 10 	movl   $0xc010d69c,0xc(%esp)
c01077ad:	c0 
c01077ae:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c01077b5:	c0 
c01077b6:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c01077bd:	00 
c01077be:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c01077c5:	e8 0b 96 ff ff       	call   c0100dd5 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c01077ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01077cd:	8b 04 85 94 f0 19 c0 	mov    -0x3fe60f6c(,%eax,4),%eax
c01077d4:	8b 00                	mov    (%eax),%eax
c01077d6:	83 e0 01             	and    $0x1,%eax
c01077d9:	85 c0                	test   %eax,%eax
c01077db:	75 24                	jne    c0107801 <check_swap+0x55d>
c01077dd:	c7 44 24 0c c4 d6 10 	movl   $0xc010d6c4,0xc(%esp)
c01077e4:	c0 
c01077e5:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c01077ec:	c0 
c01077ed:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c01077f4:	00 
c01077f5:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c01077fc:	e8 d4 95 ff ff       	call   c0100dd5 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107801:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107805:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107809:	0f 8e 0b ff ff ff    	jle    c010771a <check_swap+0x476>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c010780f:	c7 04 24 e0 d6 10 c0 	movl   $0xc010d6e0,(%esp)
c0107816:	e8 38 8b ff ff       	call   c0100353 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c010781b:	e8 6c fa ff ff       	call   c010728c <check_content_access>
c0107820:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c0107823:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107827:	74 24                	je     c010784d <check_swap+0x5a9>
c0107829:	c7 44 24 0c 06 d7 10 	movl   $0xc010d706,0xc(%esp)
c0107830:	c0 
c0107831:	c7 44 24 08 ee d3 10 	movl   $0xc010d3ee,0x8(%esp)
c0107838:	c0 
c0107839:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0107840:	00 
c0107841:	c7 04 24 88 d3 10 c0 	movl   $0xc010d388,(%esp)
c0107848:	e8 88 95 ff ff       	call   c0100dd5 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010784d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107854:	eb 1e                	jmp    c0107874 <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c0107856:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107859:	8b 04 85 e0 ef 19 c0 	mov    -0x3fe61020(,%eax,4),%eax
c0107860:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107867:	00 
c0107868:	89 04 24             	mov    %eax,(%esp)
c010786b:	e8 62 d8 ff ff       	call   c01050d2 <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107870:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107874:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107878:	7e dc                	jle    c0107856 <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
    free_page(pde2page(pgdir[0]));
c010787a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010787d:	8b 00                	mov    (%eax),%eax
c010787f:	89 04 24             	mov    %eax,(%esp)
c0107882:	e8 d6 f4 ff ff       	call   c0106d5d <pde2page>
c0107887:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010788e:	00 
c010788f:	89 04 24             	mov    %eax,(%esp)
c0107892:	e8 3b d8 ff ff       	call   c01050d2 <free_pages>
     pgdir[0] = 0;
c0107897:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010789a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     mm->pgdir = NULL;
c01078a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01078a3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     mm_destroy(mm);
c01078aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01078ad:	89 04 24             	mov    %eax,(%esp)
c01078b0:	e8 aa 09 00 00       	call   c010825f <mm_destroy>
     check_mm_struct = NULL;
c01078b5:	c7 05 ac f0 19 c0 00 	movl   $0x0,0xc019f0ac
c01078bc:	00 00 00 
     
     nr_free = nr_free_store;
c01078bf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01078c2:	a3 c0 ef 19 c0       	mov    %eax,0xc019efc0
     free_list = free_list_store;
c01078c7:	8b 45 98             	mov    -0x68(%ebp),%eax
c01078ca:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01078cd:	a3 b8 ef 19 c0       	mov    %eax,0xc019efb8
c01078d2:	89 15 bc ef 19 c0    	mov    %edx,0xc019efbc

     
     le = &free_list;
c01078d8:	c7 45 e8 b8 ef 19 c0 	movl   $0xc019efb8,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01078df:	eb 1d                	jmp    c01078fe <check_swap+0x65a>
         struct Page *p = le2page(le, page_link);
c01078e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01078e4:	83 e8 0c             	sub    $0xc,%eax
c01078e7:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c01078ea:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01078ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01078f1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01078f4:	8b 40 08             	mov    0x8(%eax),%eax
c01078f7:	29 c2                	sub    %eax,%edx
c01078f9:	89 d0                	mov    %edx,%eax
c01078fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01078fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107901:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107904:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107907:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c010790a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010790d:	81 7d e8 b8 ef 19 c0 	cmpl   $0xc019efb8,-0x18(%ebp)
c0107914:	75 cb                	jne    c01078e1 <check_swap+0x63d>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c0107916:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107919:	89 44 24 08          	mov    %eax,0x8(%esp)
c010791d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107920:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107924:	c7 04 24 0d d7 10 c0 	movl   $0xc010d70d,(%esp)
c010792b:	e8 23 8a ff ff       	call   c0100353 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0107930:	c7 04 24 27 d7 10 c0 	movl   $0xc010d727,(%esp)
c0107937:	e8 17 8a ff ff       	call   c0100353 <cprintf>
}
c010793c:	83 c4 74             	add    $0x74,%esp
c010793f:	5b                   	pop    %ebx
c0107940:	5d                   	pop    %ebp
c0107941:	c3                   	ret    

c0107942 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0107942:	55                   	push   %ebp
c0107943:	89 e5                	mov    %esp,%ebp
c0107945:	83 ec 10             	sub    $0x10,%esp
c0107948:	c7 45 fc a4 f0 19 c0 	movl   $0xc019f0a4,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010794f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107952:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107955:	89 50 04             	mov    %edx,0x4(%eax)
c0107958:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010795b:	8b 50 04             	mov    0x4(%eax),%edx
c010795e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107961:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0107963:	8b 45 08             	mov    0x8(%ebp),%eax
c0107966:	c7 40 14 a4 f0 19 c0 	movl   $0xc019f0a4,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c010796d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107972:	c9                   	leave  
c0107973:	c3                   	ret    

c0107974 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107974:	55                   	push   %ebp
c0107975:	89 e5                	mov    %esp,%ebp
c0107977:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c010797a:	8b 45 08             	mov    0x8(%ebp),%eax
c010797d:	8b 40 14             	mov    0x14(%eax),%eax
c0107980:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0107983:	8b 45 10             	mov    0x10(%ebp),%eax
c0107986:	83 c0 14             	add    $0x14,%eax
c0107989:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c010798c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107990:	74 06                	je     c0107998 <_fifo_map_swappable+0x24>
c0107992:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107996:	75 24                	jne    c01079bc <_fifo_map_swappable+0x48>
c0107998:	c7 44 24 0c 40 d7 10 	movl   $0xc010d740,0xc(%esp)
c010799f:	c0 
c01079a0:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c01079a7:	c0 
c01079a8:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c01079af:	00 
c01079b0:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c01079b7:	e8 19 94 ff ff       	call   c0100dd5 <__panic>
c01079bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01079c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079c5:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01079c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079cb:	8b 00                	mov    (%eax),%eax
c01079cd:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01079d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01079d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01079d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01079dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01079df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01079e2:	89 10                	mov    %edx,(%eax)
c01079e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01079e7:	8b 10                	mov    (%eax),%edx
c01079e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01079ec:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01079ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01079f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01079f5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01079f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01079fb:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01079fe:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: 2012012617*/
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
	list_add_before(head, entry);
	return 0;
c0107a00:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107a05:	c9                   	leave  
c0107a06:	c3                   	ret    

c0107a07 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0107a07:	55                   	push   %ebp
c0107a08:	89 e5                	mov    %esp,%ebp
c0107a0a:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107a0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a10:	8b 40 14             	mov    0x14(%eax),%eax
c0107a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0107a16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a1a:	75 24                	jne    c0107a40 <_fifo_swap_out_victim+0x39>
c0107a1c:	c7 44 24 0c 87 d7 10 	movl   $0xc010d787,0xc(%esp)
c0107a23:	c0 
c0107a24:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107a2b:	c0 
c0107a2c:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0107a33:	00 
c0107a34:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107a3b:	e8 95 93 ff ff       	call   c0100dd5 <__panic>
     assert(in_tick==0);
c0107a40:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107a44:	74 24                	je     c0107a6a <_fifo_swap_out_victim+0x63>
c0107a46:	c7 44 24 0c 94 d7 10 	movl   $0xc010d794,0xc(%esp)
c0107a4d:	c0 
c0107a4e:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107a55:	c0 
c0107a56:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0107a5d:	00 
c0107a5e:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107a65:	e8 6b 93 ff ff       	call   c0100dd5 <__panic>
c0107a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a6d:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107a70:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a73:	8b 40 04             	mov    0x4(%eax),%eax
     /* Select the victim */
     /*LAB3 EXERCISE 2: 2012012617*/
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
     list_entry_t *le = list_next(head);
c0107a76:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0107a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a7c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107a7f:	75 24                	jne    c0107aa5 <_fifo_swap_out_victim+0x9e>
c0107a81:	c7 44 24 0c 9f d7 10 	movl   $0xc010d79f,0xc(%esp)
c0107a88:	c0 
c0107a89:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107a90:	c0 
c0107a91:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c0107a98:	00 
c0107a99:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107aa0:	e8 30 93 ff ff       	call   c0100dd5 <__panic>
     struct Page *p = le2page(le, pra_page_link);
c0107aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107aa8:	83 e8 14             	sub    $0x14,%eax
c0107aab:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ab1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0107ab4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107ab7:	8b 40 04             	mov    0x4(%eax),%eax
c0107aba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107abd:	8b 12                	mov    (%edx),%edx
c0107abf:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0107ac2:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0107ac5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107ac8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107acb:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107ace:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ad1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107ad4:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c0107ad6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107ada:	75 24                	jne    c0107b00 <_fifo_swap_out_victim+0xf9>
c0107adc:	c7 44 24 0c a8 d7 10 	movl   $0xc010d7a8,0xc(%esp)
c0107ae3:	c0 
c0107ae4:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107aeb:	c0 
c0107aec:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
c0107af3:	00 
c0107af4:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107afb:	e8 d5 92 ff ff       	call   c0100dd5 <__panic>
     *ptr_page = p;
c0107b00:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b03:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107b06:	89 10                	mov    %edx,(%eax)
     return 0;
c0107b08:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107b0d:	c9                   	leave  
c0107b0e:	c3                   	ret    

c0107b0f <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0107b0f:	55                   	push   %ebp
c0107b10:	89 e5                	mov    %esp,%ebp
c0107b12:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107b15:	c7 04 24 b4 d7 10 c0 	movl   $0xc010d7b4,(%esp)
c0107b1c:	e8 32 88 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107b21:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107b26:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0107b29:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107b2e:	83 f8 04             	cmp    $0x4,%eax
c0107b31:	74 24                	je     c0107b57 <_fifo_check_swap+0x48>
c0107b33:	c7 44 24 0c da d7 10 	movl   $0xc010d7da,0xc(%esp)
c0107b3a:	c0 
c0107b3b:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107b42:	c0 
c0107b43:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
c0107b4a:	00 
c0107b4b:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107b52:	e8 7e 92 ff ff       	call   c0100dd5 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107b57:	c7 04 24 ec d7 10 c0 	movl   $0xc010d7ec,(%esp)
c0107b5e:	e8 f0 87 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107b63:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107b68:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0107b6b:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107b70:	83 f8 04             	cmp    $0x4,%eax
c0107b73:	74 24                	je     c0107b99 <_fifo_check_swap+0x8a>
c0107b75:	c7 44 24 0c da d7 10 	movl   $0xc010d7da,0xc(%esp)
c0107b7c:	c0 
c0107b7d:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107b84:	c0 
c0107b85:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
c0107b8c:	00 
c0107b8d:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107b94:	e8 3c 92 ff ff       	call   c0100dd5 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107b99:	c7 04 24 14 d8 10 c0 	movl   $0xc010d814,(%esp)
c0107ba0:	e8 ae 87 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107ba5:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107baa:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0107bad:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107bb2:	83 f8 04             	cmp    $0x4,%eax
c0107bb5:	74 24                	je     c0107bdb <_fifo_check_swap+0xcc>
c0107bb7:	c7 44 24 0c da d7 10 	movl   $0xc010d7da,0xc(%esp)
c0107bbe:	c0 
c0107bbf:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107bc6:	c0 
c0107bc7:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0107bce:	00 
c0107bcf:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107bd6:	e8 fa 91 ff ff       	call   c0100dd5 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107bdb:	c7 04 24 3c d8 10 c0 	movl   $0xc010d83c,(%esp)
c0107be2:	e8 6c 87 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107be7:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107bec:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0107bef:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107bf4:	83 f8 04             	cmp    $0x4,%eax
c0107bf7:	74 24                	je     c0107c1d <_fifo_check_swap+0x10e>
c0107bf9:	c7 44 24 0c da d7 10 	movl   $0xc010d7da,0xc(%esp)
c0107c00:	c0 
c0107c01:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107c08:	c0 
c0107c09:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
c0107c10:	00 
c0107c11:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107c18:	e8 b8 91 ff ff       	call   c0100dd5 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107c1d:	c7 04 24 64 d8 10 c0 	movl   $0xc010d864,(%esp)
c0107c24:	e8 2a 87 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107c29:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107c2e:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0107c31:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107c36:	83 f8 05             	cmp    $0x5,%eax
c0107c39:	74 24                	je     c0107c5f <_fifo_check_swap+0x150>
c0107c3b:	c7 44 24 0c 8a d8 10 	movl   $0xc010d88a,0xc(%esp)
c0107c42:	c0 
c0107c43:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107c4a:	c0 
c0107c4b:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
c0107c52:	00 
c0107c53:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107c5a:	e8 76 91 ff ff       	call   c0100dd5 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107c5f:	c7 04 24 3c d8 10 c0 	movl   $0xc010d83c,(%esp)
c0107c66:	e8 e8 86 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107c6b:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107c70:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0107c73:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107c78:	83 f8 05             	cmp    $0x5,%eax
c0107c7b:	74 24                	je     c0107ca1 <_fifo_check_swap+0x192>
c0107c7d:	c7 44 24 0c 8a d8 10 	movl   $0xc010d88a,0xc(%esp)
c0107c84:	c0 
c0107c85:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107c8c:	c0 
c0107c8d:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c0107c94:	00 
c0107c95:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107c9c:	e8 34 91 ff ff       	call   c0100dd5 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107ca1:	c7 04 24 ec d7 10 c0 	movl   $0xc010d7ec,(%esp)
c0107ca8:	e8 a6 86 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107cad:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107cb2:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0107cb5:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107cba:	83 f8 06             	cmp    $0x6,%eax
c0107cbd:	74 24                	je     c0107ce3 <_fifo_check_swap+0x1d4>
c0107cbf:	c7 44 24 0c 99 d8 10 	movl   $0xc010d899,0xc(%esp)
c0107cc6:	c0 
c0107cc7:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107cce:	c0 
c0107ccf:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0107cd6:	00 
c0107cd7:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107cde:	e8 f2 90 ff ff       	call   c0100dd5 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107ce3:	c7 04 24 3c d8 10 c0 	movl   $0xc010d83c,(%esp)
c0107cea:	e8 64 86 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107cef:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107cf4:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0107cf7:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107cfc:	83 f8 07             	cmp    $0x7,%eax
c0107cff:	74 24                	je     c0107d25 <_fifo_check_swap+0x216>
c0107d01:	c7 44 24 0c a8 d8 10 	movl   $0xc010d8a8,0xc(%esp)
c0107d08:	c0 
c0107d09:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107d10:	c0 
c0107d11:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0107d18:	00 
c0107d19:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107d20:	e8 b0 90 ff ff       	call   c0100dd5 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107d25:	c7 04 24 b4 d7 10 c0 	movl   $0xc010d7b4,(%esp)
c0107d2c:	e8 22 86 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107d31:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107d36:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0107d39:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107d3e:	83 f8 08             	cmp    $0x8,%eax
c0107d41:	74 24                	je     c0107d67 <_fifo_check_swap+0x258>
c0107d43:	c7 44 24 0c b7 d8 10 	movl   $0xc010d8b7,0xc(%esp)
c0107d4a:	c0 
c0107d4b:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107d52:	c0 
c0107d53:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0107d5a:	00 
c0107d5b:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107d62:	e8 6e 90 ff ff       	call   c0100dd5 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107d67:	c7 04 24 14 d8 10 c0 	movl   $0xc010d814,(%esp)
c0107d6e:	e8 e0 85 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107d73:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107d78:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0107d7b:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107d80:	83 f8 09             	cmp    $0x9,%eax
c0107d83:	74 24                	je     c0107da9 <_fifo_check_swap+0x29a>
c0107d85:	c7 44 24 0c c6 d8 10 	movl   $0xc010d8c6,0xc(%esp)
c0107d8c:	c0 
c0107d8d:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107d94:	c0 
c0107d95:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c0107d9c:	00 
c0107d9d:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107da4:	e8 2c 90 ff ff       	call   c0100dd5 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107da9:	c7 04 24 64 d8 10 c0 	movl   $0xc010d864,(%esp)
c0107db0:	e8 9e 85 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107db5:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107dba:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0107dbd:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107dc2:	83 f8 0a             	cmp    $0xa,%eax
c0107dc5:	74 24                	je     c0107deb <_fifo_check_swap+0x2dc>
c0107dc7:	c7 44 24 0c d5 d8 10 	movl   $0xc010d8d5,0xc(%esp)
c0107dce:	c0 
c0107dcf:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107dd6:	c0 
c0107dd7:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c0107dde:	00 
c0107ddf:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107de6:	e8 ea 8f ff ff       	call   c0100dd5 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107deb:	c7 04 24 ec d7 10 c0 	movl   $0xc010d7ec,(%esp)
c0107df2:	e8 5c 85 ff ff       	call   c0100353 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0107df7:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107dfc:	0f b6 00             	movzbl (%eax),%eax
c0107dff:	3c 0a                	cmp    $0xa,%al
c0107e01:	74 24                	je     c0107e27 <_fifo_check_swap+0x318>
c0107e03:	c7 44 24 0c e8 d8 10 	movl   $0xc010d8e8,0xc(%esp)
c0107e0a:	c0 
c0107e0b:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107e12:	c0 
c0107e13:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0107e1a:	00 
c0107e1b:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107e22:	e8 ae 8f ff ff       	call   c0100dd5 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0107e27:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107e2c:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0107e2f:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107e34:	83 f8 0b             	cmp    $0xb,%eax
c0107e37:	74 24                	je     c0107e5d <_fifo_check_swap+0x34e>
c0107e39:	c7 44 24 0c 09 d9 10 	movl   $0xc010d909,0xc(%esp)
c0107e40:	c0 
c0107e41:	c7 44 24 08 5e d7 10 	movl   $0xc010d75e,0x8(%esp)
c0107e48:	c0 
c0107e49:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c0107e50:	00 
c0107e51:	c7 04 24 73 d7 10 c0 	movl   $0xc010d773,(%esp)
c0107e58:	e8 78 8f ff ff       	call   c0100dd5 <__panic>
    return 0;
c0107e5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107e62:	c9                   	leave  
c0107e63:	c3                   	ret    

c0107e64 <_fifo_init>:


static int
_fifo_init(void)
{
c0107e64:	55                   	push   %ebp
c0107e65:	89 e5                	mov    %esp,%ebp
    return 0;
c0107e67:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107e6c:	5d                   	pop    %ebp
c0107e6d:	c3                   	ret    

c0107e6e <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0107e6e:	55                   	push   %ebp
c0107e6f:	89 e5                	mov    %esp,%ebp
    return 0;
c0107e71:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107e76:	5d                   	pop    %ebp
c0107e77:	c3                   	ret    

c0107e78 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0107e78:	55                   	push   %ebp
c0107e79:	89 e5                	mov    %esp,%ebp
c0107e7b:	b8 00 00 00 00       	mov    $0x0,%eax
c0107e80:	5d                   	pop    %ebp
c0107e81:	c3                   	ret    

c0107e82 <lock_init>:
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
c0107e82:	55                   	push   %ebp
c0107e83:	89 e5                	mov    %esp,%ebp
    *lock = 0;
c0107e85:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e88:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
c0107e8e:	5d                   	pop    %ebp
c0107e8f:	c3                   	ret    

c0107e90 <mm_count>:
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm) {
c0107e90:	55                   	push   %ebp
c0107e91:	89 e5                	mov    %esp,%ebp
    return mm->mm_count;
c0107e93:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e96:	8b 40 18             	mov    0x18(%eax),%eax
}
c0107e99:	5d                   	pop    %ebp
c0107e9a:	c3                   	ret    

c0107e9b <set_mm_count>:

static inline void
set_mm_count(struct mm_struct *mm, int val) {
c0107e9b:	55                   	push   %ebp
c0107e9c:	89 e5                	mov    %esp,%ebp
    mm->mm_count = val;
c0107e9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ea1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107ea4:	89 50 18             	mov    %edx,0x18(%eax)
}
c0107ea7:	5d                   	pop    %ebp
c0107ea8:	c3                   	ret    

c0107ea9 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0107ea9:	55                   	push   %ebp
c0107eaa:	89 e5                	mov    %esp,%ebp
c0107eac:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0107eaf:	8b 45 08             	mov    0x8(%ebp),%eax
c0107eb2:	c1 e8 0c             	shr    $0xc,%eax
c0107eb5:	89 c2                	mov    %eax,%edx
c0107eb7:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0107ebc:	39 c2                	cmp    %eax,%edx
c0107ebe:	72 1c                	jb     c0107edc <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0107ec0:	c7 44 24 08 2c d9 10 	movl   $0xc010d92c,0x8(%esp)
c0107ec7:	c0 
c0107ec8:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0107ecf:	00 
c0107ed0:	c7 04 24 4b d9 10 c0 	movl   $0xc010d94b,(%esp)
c0107ed7:	e8 f9 8e ff ff       	call   c0100dd5 <__panic>
    }
    return &pages[PPN(pa)];
c0107edc:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0107ee1:	8b 55 08             	mov    0x8(%ebp),%edx
c0107ee4:	c1 ea 0c             	shr    $0xc,%edx
c0107ee7:	c1 e2 05             	shl    $0x5,%edx
c0107eea:	01 d0                	add    %edx,%eax
}
c0107eec:	c9                   	leave  
c0107eed:	c3                   	ret    

c0107eee <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0107eee:	55                   	push   %ebp
c0107eef:	89 e5                	mov    %esp,%ebp
c0107ef1:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0107ef4:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ef7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107efc:	89 04 24             	mov    %eax,(%esp)
c0107eff:	e8 a5 ff ff ff       	call   c0107ea9 <pa2page>
}
c0107f04:	c9                   	leave  
c0107f05:	c3                   	ret    

c0107f06 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0107f06:	55                   	push   %ebp
c0107f07:	89 e5                	mov    %esp,%ebp
c0107f09:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0107f0c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0107f13:	e8 da cc ff ff       	call   c0104bf2 <kmalloc>
c0107f18:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0107f1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107f1f:	74 79                	je     c0107f9a <mm_create+0x94>
        list_init(&(mm->mmap_list));
c0107f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f24:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107f2d:	89 50 04             	mov    %edx,0x4(%eax)
c0107f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f33:	8b 50 04             	mov    0x4(%eax),%edx
c0107f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f39:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0107f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f3e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0107f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f48:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0107f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f52:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0107f59:	a1 6c cf 19 c0       	mov    0xc019cf6c,%eax
c0107f5e:	85 c0                	test   %eax,%eax
c0107f60:	74 0d                	je     c0107f6f <mm_create+0x69>
c0107f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f65:	89 04 24             	mov    %eax,(%esp)
c0107f68:	e8 98 ee ff ff       	call   c0106e05 <swap_init_mm>
c0107f6d:	eb 0a                	jmp    c0107f79 <mm_create+0x73>
        else mm->sm_priv = NULL;
c0107f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f72:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        
        set_mm_count(mm, 0);
c0107f79:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107f80:	00 
c0107f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f84:	89 04 24             	mov    %eax,(%esp)
c0107f87:	e8 0f ff ff ff       	call   c0107e9b <set_mm_count>
        lock_init(&(mm->mm_lock));
c0107f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f8f:	83 c0 1c             	add    $0x1c,%eax
c0107f92:	89 04 24             	mov    %eax,(%esp)
c0107f95:	e8 e8 fe ff ff       	call   c0107e82 <lock_init>
    }    
    return mm;
c0107f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107f9d:	c9                   	leave  
c0107f9e:	c3                   	ret    

c0107f9f <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0107f9f:	55                   	push   %ebp
c0107fa0:	89 e5                	mov    %esp,%ebp
c0107fa2:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0107fa5:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0107fac:	e8 41 cc ff ff       	call   c0104bf2 <kmalloc>
c0107fb1:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0107fb4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107fb8:	74 1b                	je     c0107fd5 <vma_create+0x36>
        vma->vm_start = vm_start;
c0107fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fbd:	8b 55 08             	mov    0x8(%ebp),%edx
c0107fc0:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0107fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fc6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107fc9:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0107fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fcf:	8b 55 10             	mov    0x10(%ebp),%edx
c0107fd2:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0107fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107fd8:	c9                   	leave  
c0107fd9:	c3                   	ret    

c0107fda <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0107fda:	55                   	push   %ebp
c0107fdb:	89 e5                	mov    %esp,%ebp
c0107fdd:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0107fe0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0107fe7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107feb:	0f 84 95 00 00 00    	je     c0108086 <find_vma+0xac>
        vma = mm->mmap_cache;
c0107ff1:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ff4:	8b 40 08             	mov    0x8(%eax),%eax
c0107ff7:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0107ffa:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107ffe:	74 16                	je     c0108016 <find_vma+0x3c>
c0108000:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108003:	8b 40 04             	mov    0x4(%eax),%eax
c0108006:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108009:	77 0b                	ja     c0108016 <find_vma+0x3c>
c010800b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010800e:	8b 40 08             	mov    0x8(%eax),%eax
c0108011:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108014:	77 61                	ja     c0108077 <find_vma+0x9d>
                bool found = 0;
c0108016:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c010801d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108020:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108023:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108026:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0108029:	eb 28                	jmp    c0108053 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c010802b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010802e:	83 e8 10             	sub    $0x10,%eax
c0108031:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0108034:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108037:	8b 40 04             	mov    0x4(%eax),%eax
c010803a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010803d:	77 14                	ja     c0108053 <find_vma+0x79>
c010803f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108042:	8b 40 08             	mov    0x8(%eax),%eax
c0108045:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108048:	76 09                	jbe    c0108053 <find_vma+0x79>
                        found = 1;
c010804a:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0108051:	eb 17                	jmp    c010806a <find_vma+0x90>
c0108053:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108056:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0108059:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010805c:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c010805f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108062:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108065:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108068:	75 c1                	jne    c010802b <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c010806a:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c010806e:	75 07                	jne    c0108077 <find_vma+0x9d>
                    vma = NULL;
c0108070:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0108077:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010807b:	74 09                	je     c0108086 <find_vma+0xac>
            mm->mmap_cache = vma;
c010807d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108080:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0108083:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0108086:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108089:	c9                   	leave  
c010808a:	c3                   	ret    

c010808b <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c010808b:	55                   	push   %ebp
c010808c:	89 e5                	mov    %esp,%ebp
c010808e:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0108091:	8b 45 08             	mov    0x8(%ebp),%eax
c0108094:	8b 50 04             	mov    0x4(%eax),%edx
c0108097:	8b 45 08             	mov    0x8(%ebp),%eax
c010809a:	8b 40 08             	mov    0x8(%eax),%eax
c010809d:	39 c2                	cmp    %eax,%edx
c010809f:	72 24                	jb     c01080c5 <check_vma_overlap+0x3a>
c01080a1:	c7 44 24 0c 59 d9 10 	movl   $0xc010d959,0xc(%esp)
c01080a8:	c0 
c01080a9:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c01080b0:	c0 
c01080b1:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01080b8:	00 
c01080b9:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c01080c0:	e8 10 8d ff ff       	call   c0100dd5 <__panic>
    assert(prev->vm_end <= next->vm_start);
c01080c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01080c8:	8b 50 08             	mov    0x8(%eax),%edx
c01080cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080ce:	8b 40 04             	mov    0x4(%eax),%eax
c01080d1:	39 c2                	cmp    %eax,%edx
c01080d3:	76 24                	jbe    c01080f9 <check_vma_overlap+0x6e>
c01080d5:	c7 44 24 0c 9c d9 10 	movl   $0xc010d99c,0xc(%esp)
c01080dc:	c0 
c01080dd:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c01080e4:	c0 
c01080e5:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c01080ec:	00 
c01080ed:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c01080f4:	e8 dc 8c ff ff       	call   c0100dd5 <__panic>
    assert(next->vm_start < next->vm_end);
c01080f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080fc:	8b 50 04             	mov    0x4(%eax),%edx
c01080ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108102:	8b 40 08             	mov    0x8(%eax),%eax
c0108105:	39 c2                	cmp    %eax,%edx
c0108107:	72 24                	jb     c010812d <check_vma_overlap+0xa2>
c0108109:	c7 44 24 0c bb d9 10 	movl   $0xc010d9bb,0xc(%esp)
c0108110:	c0 
c0108111:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108118:	c0 
c0108119:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0108120:	00 
c0108121:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108128:	e8 a8 8c ff ff       	call   c0100dd5 <__panic>
}
c010812d:	c9                   	leave  
c010812e:	c3                   	ret    

c010812f <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c010812f:	55                   	push   %ebp
c0108130:	89 e5                	mov    %esp,%ebp
c0108132:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0108135:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108138:	8b 50 04             	mov    0x4(%eax),%edx
c010813b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010813e:	8b 40 08             	mov    0x8(%eax),%eax
c0108141:	39 c2                	cmp    %eax,%edx
c0108143:	72 24                	jb     c0108169 <insert_vma_struct+0x3a>
c0108145:	c7 44 24 0c d9 d9 10 	movl   $0xc010d9d9,0xc(%esp)
c010814c:	c0 
c010814d:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108154:	c0 
c0108155:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c010815c:	00 
c010815d:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108164:	e8 6c 8c ff ff       	call   c0100dd5 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0108169:	8b 45 08             	mov    0x8(%ebp),%eax
c010816c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c010816f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108172:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0108175:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108178:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c010817b:	eb 21                	jmp    c010819e <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c010817d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108180:	83 e8 10             	sub    $0x10,%eax
c0108183:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0108186:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108189:	8b 50 04             	mov    0x4(%eax),%edx
c010818c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010818f:	8b 40 04             	mov    0x4(%eax),%eax
c0108192:	39 c2                	cmp    %eax,%edx
c0108194:	76 02                	jbe    c0108198 <insert_vma_struct+0x69>
                break;
c0108196:	eb 1d                	jmp    c01081b5 <insert_vma_struct+0x86>
            }
            le_prev = le;
c0108198:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010819b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010819e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01081a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01081a7:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c01081aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01081ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081b0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01081b3:	75 c8                	jne    c010817d <insert_vma_struct+0x4e>
c01081b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01081bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01081be:	8b 40 04             	mov    0x4(%eax),%eax
                break;
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c01081c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c01081c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081c7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01081ca:	74 15                	je     c01081e1 <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c01081cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081cf:	8d 50 f0             	lea    -0x10(%eax),%edx
c01081d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081d5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081d9:	89 14 24             	mov    %edx,(%esp)
c01081dc:	e8 aa fe ff ff       	call   c010808b <check_vma_overlap>
    }
    if (le_next != list) {
c01081e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01081e4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01081e7:	74 15                	je     c01081fe <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c01081e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01081ec:	83 e8 10             	sub    $0x10,%eax
c01081ef:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081f6:	89 04 24             	mov    %eax,(%esp)
c01081f9:	e8 8d fe ff ff       	call   c010808b <check_vma_overlap>
    }

    vma->vm_mm = mm;
c01081fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108201:	8b 55 08             	mov    0x8(%ebp),%edx
c0108204:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0108206:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108209:	8d 50 10             	lea    0x10(%eax),%edx
c010820c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010820f:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108212:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0108215:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108218:	8b 40 04             	mov    0x4(%eax),%eax
c010821b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010821e:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0108221:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108224:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0108227:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010822a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010822d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108230:	89 10                	mov    %edx,(%eax)
c0108232:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108235:	8b 10                	mov    (%eax),%edx
c0108237:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010823a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010823d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108240:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0108243:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108246:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108249:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010824c:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c010824e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108251:	8b 40 10             	mov    0x10(%eax),%eax
c0108254:	8d 50 01             	lea    0x1(%eax),%edx
c0108257:	8b 45 08             	mov    0x8(%ebp),%eax
c010825a:	89 50 10             	mov    %edx,0x10(%eax)
}
c010825d:	c9                   	leave  
c010825e:	c3                   	ret    

c010825f <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c010825f:	55                   	push   %ebp
c0108260:	89 e5                	mov    %esp,%ebp
c0108262:	83 ec 38             	sub    $0x38,%esp
    assert(mm_count(mm) == 0);
c0108265:	8b 45 08             	mov    0x8(%ebp),%eax
c0108268:	89 04 24             	mov    %eax,(%esp)
c010826b:	e8 20 fc ff ff       	call   c0107e90 <mm_count>
c0108270:	85 c0                	test   %eax,%eax
c0108272:	74 24                	je     c0108298 <mm_destroy+0x39>
c0108274:	c7 44 24 0c f5 d9 10 	movl   $0xc010d9f5,0xc(%esp)
c010827b:	c0 
c010827c:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108283:	c0 
c0108284:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c010828b:	00 
c010828c:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108293:	e8 3d 8b ff ff       	call   c0100dd5 <__panic>

    list_entry_t *list = &(mm->mmap_list), *le;
c0108298:	8b 45 08             	mov    0x8(%ebp),%eax
c010829b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c010829e:	eb 36                	jmp    c01082d6 <mm_destroy+0x77>
c01082a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01082a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01082a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01082a9:	8b 40 04             	mov    0x4(%eax),%eax
c01082ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01082af:	8b 12                	mov    (%edx),%edx
c01082b1:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01082b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01082b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01082ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01082bd:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01082c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01082c3:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01082c6:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c01082c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01082cb:	83 e8 10             	sub    $0x10,%eax
c01082ce:	89 04 24             	mov    %eax,(%esp)
c01082d1:	e8 37 c9 ff ff       	call   c0104c0d <kfree>
c01082d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01082dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01082df:	8b 40 04             	mov    0x4(%eax),%eax
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c01082e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01082e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01082e8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01082eb:	75 b3                	jne    c01082a0 <mm_destroy+0x41>
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
    }
    kfree(mm); //kfree mm
c01082ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01082f0:	89 04 24             	mov    %eax,(%esp)
c01082f3:	e8 15 c9 ff ff       	call   c0104c0d <kfree>
    mm=NULL;
c01082f8:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c01082ff:	c9                   	leave  
c0108300:	c3                   	ret    

c0108301 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
c0108301:	55                   	push   %ebp
c0108302:	89 e5                	mov    %esp,%ebp
c0108304:	83 ec 38             	sub    $0x38,%esp
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
c0108307:	8b 45 0c             	mov    0xc(%ebp),%eax
c010830a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010830d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108310:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108315:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108318:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
c010831f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108322:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108325:	01 c2                	add    %eax,%edx
c0108327:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010832a:	01 d0                	add    %edx,%eax
c010832c:	83 e8 01             	sub    $0x1,%eax
c010832f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108335:	ba 00 00 00 00       	mov    $0x0,%edx
c010833a:	f7 75 e8             	divl   -0x18(%ebp)
c010833d:	89 d0                	mov    %edx,%eax
c010833f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108342:	29 c2                	sub    %eax,%edx
c0108344:	89 d0                	mov    %edx,%eax
c0108346:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!USER_ACCESS(start, end)) {
c0108349:	81 7d ec ff ff 1f 00 	cmpl   $0x1fffff,-0x14(%ebp)
c0108350:	76 11                	jbe    c0108363 <mm_map+0x62>
c0108352:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108355:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108358:	73 09                	jae    c0108363 <mm_map+0x62>
c010835a:	81 7d e0 00 00 00 b0 	cmpl   $0xb0000000,-0x20(%ebp)
c0108361:	76 0a                	jbe    c010836d <mm_map+0x6c>
        return -E_INVAL;
c0108363:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0108368:	e9 ae 00 00 00       	jmp    c010841b <mm_map+0x11a>
    }

    assert(mm != NULL);
c010836d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108371:	75 24                	jne    c0108397 <mm_map+0x96>
c0108373:	c7 44 24 0c 07 da 10 	movl   $0xc010da07,0xc(%esp)
c010837a:	c0 
c010837b:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108382:	c0 
c0108383:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c010838a:	00 
c010838b:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108392:	e8 3e 8a ff ff       	call   c0100dd5 <__panic>

    int ret = -E_INVAL;
c0108397:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
c010839e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01083a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01083a8:	89 04 24             	mov    %eax,(%esp)
c01083ab:	e8 2a fc ff ff       	call   c0107fda <find_vma>
c01083b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01083b3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01083b7:	74 0d                	je     c01083c6 <mm_map+0xc5>
c01083b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01083bc:	8b 40 04             	mov    0x4(%eax),%eax
c01083bf:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01083c2:	73 02                	jae    c01083c6 <mm_map+0xc5>
        goto out;
c01083c4:	eb 52                	jmp    c0108418 <mm_map+0x117>
    }
    ret = -E_NO_MEM;
c01083c6:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
c01083cd:	8b 45 14             	mov    0x14(%ebp),%eax
c01083d0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01083d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01083d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083db:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01083de:	89 04 24             	mov    %eax,(%esp)
c01083e1:	e8 b9 fb ff ff       	call   c0107f9f <vma_create>
c01083e6:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01083e9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01083ed:	75 02                	jne    c01083f1 <mm_map+0xf0>
        goto out;
c01083ef:	eb 27                	jmp    c0108418 <mm_map+0x117>
    }
    insert_vma_struct(mm, vma);
c01083f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01083f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01083fb:	89 04 24             	mov    %eax,(%esp)
c01083fe:	e8 2c fd ff ff       	call   c010812f <insert_vma_struct>
    if (vma_store != NULL) {
c0108403:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0108407:	74 08                	je     c0108411 <mm_map+0x110>
        *vma_store = vma;
c0108409:	8b 45 18             	mov    0x18(%ebp),%eax
c010840c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010840f:	89 10                	mov    %edx,(%eax)
    }
    ret = 0;
c0108411:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

out:
    return ret;
c0108418:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010841b:	c9                   	leave  
c010841c:	c3                   	ret    

c010841d <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
c010841d:	55                   	push   %ebp
c010841e:	89 e5                	mov    %esp,%ebp
c0108420:	56                   	push   %esi
c0108421:	53                   	push   %ebx
c0108422:	83 ec 40             	sub    $0x40,%esp
    assert(to != NULL && from != NULL);
c0108425:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108429:	74 06                	je     c0108431 <dup_mmap+0x14>
c010842b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010842f:	75 24                	jne    c0108455 <dup_mmap+0x38>
c0108431:	c7 44 24 0c 12 da 10 	movl   $0xc010da12,0xc(%esp)
c0108438:	c0 
c0108439:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108440:	c0 
c0108441:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0108448:	00 
c0108449:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108450:	e8 80 89 ff ff       	call   c0100dd5 <__panic>
    list_entry_t *list = &(from->mmap_list), *le = list;
c0108455:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108458:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010845b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010845e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_prev(le)) != list) {
c0108461:	e9 92 00 00 00       	jmp    c01084f8 <dup_mmap+0xdb>
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
c0108466:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108469:	83 e8 10             	sub    $0x10,%eax
c010846c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
c010846f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108472:	8b 48 0c             	mov    0xc(%eax),%ecx
c0108475:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108478:	8b 50 08             	mov    0x8(%eax),%edx
c010847b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010847e:	8b 40 04             	mov    0x4(%eax),%eax
c0108481:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108485:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108489:	89 04 24             	mov    %eax,(%esp)
c010848c:	e8 0e fb ff ff       	call   c0107f9f <vma_create>
c0108491:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (nvma == NULL) {
c0108494:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108498:	75 07                	jne    c01084a1 <dup_mmap+0x84>
            return -E_NO_MEM;
c010849a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010849f:	eb 76                	jmp    c0108517 <dup_mmap+0xfa>
        }

        insert_vma_struct(to, nvma);
c01084a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01084a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01084ab:	89 04 24             	mov    %eax,(%esp)
c01084ae:	e8 7c fc ff ff       	call   c010812f <insert_vma_struct>

        bool share = 0;
c01084b3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
c01084ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084bd:	8b 58 08             	mov    0x8(%eax),%ebx
c01084c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084c3:	8b 48 04             	mov    0x4(%eax),%ecx
c01084c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084c9:	8b 50 0c             	mov    0xc(%eax),%edx
c01084cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01084cf:	8b 40 0c             	mov    0xc(%eax),%eax
c01084d2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c01084d5:	89 74 24 10          	mov    %esi,0x10(%esp)
c01084d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01084dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01084e1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01084e5:	89 04 24             	mov    %eax,(%esp)
c01084e8:	e8 e8 d6 ff ff       	call   c0105bd5 <copy_range>
c01084ed:	85 c0                	test   %eax,%eax
c01084ef:	74 07                	je     c01084f8 <dup_mmap+0xdb>
            return -E_NO_MEM;
c01084f1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01084f6:	eb 1f                	jmp    c0108517 <dup_mmap+0xfa>
c01084f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c01084fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108501:	8b 00                	mov    (%eax),%eax

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
    assert(to != NULL && from != NULL);
    list_entry_t *list = &(from->mmap_list), *le = list;
    while ((le = list_prev(le)) != list) {
c0108503:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108506:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108509:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010850c:	0f 85 54 ff ff ff    	jne    c0108466 <dup_mmap+0x49>
        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
            return -E_NO_MEM;
        }
    }
    return 0;
c0108512:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108517:	83 c4 40             	add    $0x40,%esp
c010851a:	5b                   	pop    %ebx
c010851b:	5e                   	pop    %esi
c010851c:	5d                   	pop    %ebp
c010851d:	c3                   	ret    

c010851e <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
c010851e:	55                   	push   %ebp
c010851f:	89 e5                	mov    %esp,%ebp
c0108521:	83 ec 38             	sub    $0x38,%esp
    assert(mm != NULL && mm_count(mm) == 0);
c0108524:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108528:	74 0f                	je     c0108539 <exit_mmap+0x1b>
c010852a:	8b 45 08             	mov    0x8(%ebp),%eax
c010852d:	89 04 24             	mov    %eax,(%esp)
c0108530:	e8 5b f9 ff ff       	call   c0107e90 <mm_count>
c0108535:	85 c0                	test   %eax,%eax
c0108537:	74 24                	je     c010855d <exit_mmap+0x3f>
c0108539:	c7 44 24 0c 30 da 10 	movl   $0xc010da30,0xc(%esp)
c0108540:	c0 
c0108541:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108548:	c0 
c0108549:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0108550:	00 
c0108551:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108558:	e8 78 88 ff ff       	call   c0100dd5 <__panic>
    pde_t *pgdir = mm->pgdir;
c010855d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108560:	8b 40 0c             	mov    0xc(%eax),%eax
c0108563:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *list = &(mm->mmap_list), *le = list;
c0108566:	8b 45 08             	mov    0x8(%ebp),%eax
c0108569:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010856c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010856f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(le)) != list) {
c0108572:	eb 28                	jmp    c010859c <exit_mmap+0x7e>
        struct vma_struct *vma = le2vma(le, list_link);
c0108574:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108577:	83 e8 10             	sub    $0x10,%eax
c010857a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
c010857d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108580:	8b 50 08             	mov    0x8(%eax),%edx
c0108583:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108586:	8b 40 04             	mov    0x4(%eax),%eax
c0108589:	89 54 24 08          	mov    %edx,0x8(%esp)
c010858d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108591:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108594:	89 04 24             	mov    %eax,(%esp)
c0108597:	e8 3e d4 ff ff       	call   c01059da <unmap_range>
c010859c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010859f:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01085a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085a5:	8b 40 04             	mov    0x4(%eax),%eax
void
exit_mmap(struct mm_struct *mm) {
    assert(mm != NULL && mm_count(mm) == 0);
    pde_t *pgdir = mm->pgdir;
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
c01085a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01085ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085ae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01085b1:	75 c1                	jne    c0108574 <exit_mmap+0x56>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    while ((le = list_next(le)) != list) {
c01085b3:	eb 28                	jmp    c01085dd <exit_mmap+0xbf>
        struct vma_struct *vma = le2vma(le, list_link);
c01085b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085b8:	83 e8 10             	sub    $0x10,%eax
c01085bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        exit_range(pgdir, vma->vm_start, vma->vm_end);
c01085be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01085c1:	8b 50 08             	mov    0x8(%eax),%edx
c01085c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01085c7:	8b 40 04             	mov    0x4(%eax),%eax
c01085ca:	89 54 24 08          	mov    %edx,0x8(%esp)
c01085ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01085d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085d5:	89 04 24             	mov    %eax,(%esp)
c01085d8:	e8 f1 d4 ff ff       	call   c0105ace <exit_range>
c01085dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085e0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01085e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01085e6:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    while ((le = list_next(le)) != list) {
c01085e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01085ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085ef:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01085f2:	75 c1                	jne    c01085b5 <exit_mmap+0x97>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
    }
}
c01085f4:	c9                   	leave  
c01085f5:	c3                   	ret    

c01085f6 <copy_from_user>:

bool
copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable) {
c01085f6:	55                   	push   %ebp
c01085f7:	89 e5                	mov    %esp,%ebp
c01085f9:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)src, len, writable)) {
c01085fc:	8b 45 10             	mov    0x10(%ebp),%eax
c01085ff:	8b 55 18             	mov    0x18(%ebp),%edx
c0108602:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108606:	8b 55 14             	mov    0x14(%ebp),%edx
c0108609:	89 54 24 08          	mov    %edx,0x8(%esp)
c010860d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108611:	8b 45 08             	mov    0x8(%ebp),%eax
c0108614:	89 04 24             	mov    %eax,(%esp)
c0108617:	e8 c7 09 00 00       	call   c0108fe3 <user_mem_check>
c010861c:	85 c0                	test   %eax,%eax
c010861e:	75 07                	jne    c0108627 <copy_from_user+0x31>
        return 0;
c0108620:	b8 00 00 00 00       	mov    $0x0,%eax
c0108625:	eb 1e                	jmp    c0108645 <copy_from_user+0x4f>
    }
    memcpy(dst, src, len);
c0108627:	8b 45 14             	mov    0x14(%ebp),%eax
c010862a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010862e:	8b 45 10             	mov    0x10(%ebp),%eax
c0108631:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108635:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108638:	89 04 24             	mov    %eax,(%esp)
c010863b:	e8 a4 37 00 00       	call   c010bde4 <memcpy>
    return 1;
c0108640:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0108645:	c9                   	leave  
c0108646:	c3                   	ret    

c0108647 <copy_to_user>:

bool
copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len) {
c0108647:	55                   	push   %ebp
c0108648:	89 e5                	mov    %esp,%ebp
c010864a:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1)) {
c010864d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108650:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0108657:	00 
c0108658:	8b 55 14             	mov    0x14(%ebp),%edx
c010865b:	89 54 24 08          	mov    %edx,0x8(%esp)
c010865f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108663:	8b 45 08             	mov    0x8(%ebp),%eax
c0108666:	89 04 24             	mov    %eax,(%esp)
c0108669:	e8 75 09 00 00       	call   c0108fe3 <user_mem_check>
c010866e:	85 c0                	test   %eax,%eax
c0108670:	75 07                	jne    c0108679 <copy_to_user+0x32>
        return 0;
c0108672:	b8 00 00 00 00       	mov    $0x0,%eax
c0108677:	eb 1e                	jmp    c0108697 <copy_to_user+0x50>
    }
    memcpy(dst, src, len);
c0108679:	8b 45 14             	mov    0x14(%ebp),%eax
c010867c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108680:	8b 45 10             	mov    0x10(%ebp),%eax
c0108683:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108687:	8b 45 0c             	mov    0xc(%ebp),%eax
c010868a:	89 04 24             	mov    %eax,(%esp)
c010868d:	e8 52 37 00 00       	call   c010bde4 <memcpy>
    return 1;
c0108692:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0108697:	c9                   	leave  
c0108698:	c3                   	ret    

c0108699 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0108699:	55                   	push   %ebp
c010869a:	89 e5                	mov    %esp,%ebp
c010869c:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c010869f:	e8 02 00 00 00       	call   c01086a6 <check_vmm>
}
c01086a4:	c9                   	leave  
c01086a5:	c3                   	ret    

c01086a6 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01086a6:	55                   	push   %ebp
c01086a7:	89 e5                	mov    %esp,%ebp
c01086a9:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01086ac:	e8 53 ca ff ff       	call   c0105104 <nr_free_pages>
c01086b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c01086b4:	e8 13 00 00 00       	call   c01086cc <check_vma_struct>
    check_pgfault();
c01086b9:	e8 a7 04 00 00       	call   c0108b65 <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c01086be:	c7 04 24 50 da 10 c0 	movl   $0xc010da50,(%esp)
c01086c5:	e8 89 7c ff ff       	call   c0100353 <cprintf>
}
c01086ca:	c9                   	leave  
c01086cb:	c3                   	ret    

c01086cc <check_vma_struct>:

static void
check_vma_struct(void) {
c01086cc:	55                   	push   %ebp
c01086cd:	89 e5                	mov    %esp,%ebp
c01086cf:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01086d2:	e8 2d ca ff ff       	call   c0105104 <nr_free_pages>
c01086d7:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c01086da:	e8 27 f8 ff ff       	call   c0107f06 <mm_create>
c01086df:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c01086e2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01086e6:	75 24                	jne    c010870c <check_vma_struct+0x40>
c01086e8:	c7 44 24 0c 07 da 10 	movl   $0xc010da07,0xc(%esp)
c01086ef:	c0 
c01086f0:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c01086f7:	c0 
c01086f8:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c01086ff:	00 
c0108700:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108707:	e8 c9 86 ff ff       	call   c0100dd5 <__panic>

    int step1 = 10, step2 = step1 * 10;
c010870c:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0108713:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108716:	89 d0                	mov    %edx,%eax
c0108718:	c1 e0 02             	shl    $0x2,%eax
c010871b:	01 d0                	add    %edx,%eax
c010871d:	01 c0                	add    %eax,%eax
c010871f:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0108722:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108725:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108728:	eb 70                	jmp    c010879a <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c010872a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010872d:	89 d0                	mov    %edx,%eax
c010872f:	c1 e0 02             	shl    $0x2,%eax
c0108732:	01 d0                	add    %edx,%eax
c0108734:	83 c0 02             	add    $0x2,%eax
c0108737:	89 c1                	mov    %eax,%ecx
c0108739:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010873c:	89 d0                	mov    %edx,%eax
c010873e:	c1 e0 02             	shl    $0x2,%eax
c0108741:	01 d0                	add    %edx,%eax
c0108743:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010874a:	00 
c010874b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010874f:	89 04 24             	mov    %eax,(%esp)
c0108752:	e8 48 f8 ff ff       	call   c0107f9f <vma_create>
c0108757:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c010875a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010875e:	75 24                	jne    c0108784 <check_vma_struct+0xb8>
c0108760:	c7 44 24 0c 68 da 10 	movl   $0xc010da68,0xc(%esp)
c0108767:	c0 
c0108768:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c010876f:	c0 
c0108770:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0108777:	00 
c0108778:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c010877f:	e8 51 86 ff ff       	call   c0100dd5 <__panic>
        insert_vma_struct(mm, vma);
c0108784:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108787:	89 44 24 04          	mov    %eax,0x4(%esp)
c010878b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010878e:	89 04 24             	mov    %eax,(%esp)
c0108791:	e8 99 f9 ff ff       	call   c010812f <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c0108796:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010879a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010879e:	7f 8a                	jg     c010872a <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01087a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01087a3:	83 c0 01             	add    $0x1,%eax
c01087a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01087a9:	eb 70                	jmp    c010881b <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01087ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01087ae:	89 d0                	mov    %edx,%eax
c01087b0:	c1 e0 02             	shl    $0x2,%eax
c01087b3:	01 d0                	add    %edx,%eax
c01087b5:	83 c0 02             	add    $0x2,%eax
c01087b8:	89 c1                	mov    %eax,%ecx
c01087ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01087bd:	89 d0                	mov    %edx,%eax
c01087bf:	c1 e0 02             	shl    $0x2,%eax
c01087c2:	01 d0                	add    %edx,%eax
c01087c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01087cb:	00 
c01087cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01087d0:	89 04 24             	mov    %eax,(%esp)
c01087d3:	e8 c7 f7 ff ff       	call   c0107f9f <vma_create>
c01087d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c01087db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01087df:	75 24                	jne    c0108805 <check_vma_struct+0x139>
c01087e1:	c7 44 24 0c 68 da 10 	movl   $0xc010da68,0xc(%esp)
c01087e8:	c0 
c01087e9:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c01087f0:	c0 
c01087f1:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c01087f8:	00 
c01087f9:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108800:	e8 d0 85 ff ff       	call   c0100dd5 <__panic>
        insert_vma_struct(mm, vma);
c0108805:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108808:	89 44 24 04          	mov    %eax,0x4(%esp)
c010880c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010880f:	89 04 24             	mov    %eax,(%esp)
c0108812:	e8 18 f9 ff ff       	call   c010812f <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0108817:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010881b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010881e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108821:	7e 88                	jle    c01087ab <check_vma_struct+0xdf>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0108823:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108826:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0108829:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010882c:	8b 40 04             	mov    0x4(%eax),%eax
c010882f:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0108832:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0108839:	e9 97 00 00 00       	jmp    c01088d5 <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c010883e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108841:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108844:	75 24                	jne    c010886a <check_vma_struct+0x19e>
c0108846:	c7 44 24 0c 74 da 10 	movl   $0xc010da74,0xc(%esp)
c010884d:	c0 
c010884e:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108855:	c0 
c0108856:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c010885d:	00 
c010885e:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108865:	e8 6b 85 ff ff       	call   c0100dd5 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c010886a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010886d:	83 e8 10             	sub    $0x10,%eax
c0108870:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0108873:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108876:	8b 48 04             	mov    0x4(%eax),%ecx
c0108879:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010887c:	89 d0                	mov    %edx,%eax
c010887e:	c1 e0 02             	shl    $0x2,%eax
c0108881:	01 d0                	add    %edx,%eax
c0108883:	39 c1                	cmp    %eax,%ecx
c0108885:	75 17                	jne    c010889e <check_vma_struct+0x1d2>
c0108887:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010888a:	8b 48 08             	mov    0x8(%eax),%ecx
c010888d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108890:	89 d0                	mov    %edx,%eax
c0108892:	c1 e0 02             	shl    $0x2,%eax
c0108895:	01 d0                	add    %edx,%eax
c0108897:	83 c0 02             	add    $0x2,%eax
c010889a:	39 c1                	cmp    %eax,%ecx
c010889c:	74 24                	je     c01088c2 <check_vma_struct+0x1f6>
c010889e:	c7 44 24 0c 8c da 10 	movl   $0xc010da8c,0xc(%esp)
c01088a5:	c0 
c01088a6:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c01088ad:	c0 
c01088ae:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c01088b5:	00 
c01088b6:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c01088bd:	e8 13 85 ff ff       	call   c0100dd5 <__panic>
c01088c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088c5:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01088c8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01088cb:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01088ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c01088d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01088d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088d8:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01088db:	0f 8e 5d ff ff ff    	jle    c010883e <check_vma_struct+0x172>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c01088e1:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c01088e8:	e9 cd 01 00 00       	jmp    c0108aba <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c01088ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01088f7:	89 04 24             	mov    %eax,(%esp)
c01088fa:	e8 db f6 ff ff       	call   c0107fda <find_vma>
c01088ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0108902:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0108906:	75 24                	jne    c010892c <check_vma_struct+0x260>
c0108908:	c7 44 24 0c c1 da 10 	movl   $0xc010dac1,0xc(%esp)
c010890f:	c0 
c0108910:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108917:	c0 
c0108918:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c010891f:	00 
c0108920:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108927:	e8 a9 84 ff ff       	call   c0100dd5 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c010892c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010892f:	83 c0 01             	add    $0x1,%eax
c0108932:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108936:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108939:	89 04 24             	mov    %eax,(%esp)
c010893c:	e8 99 f6 ff ff       	call   c0107fda <find_vma>
c0108941:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c0108944:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0108948:	75 24                	jne    c010896e <check_vma_struct+0x2a2>
c010894a:	c7 44 24 0c ce da 10 	movl   $0xc010dace,0xc(%esp)
c0108951:	c0 
c0108952:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108959:	c0 
c010895a:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0108961:	00 
c0108962:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108969:	e8 67 84 ff ff       	call   c0100dd5 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c010896e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108971:	83 c0 02             	add    $0x2,%eax
c0108974:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108978:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010897b:	89 04 24             	mov    %eax,(%esp)
c010897e:	e8 57 f6 ff ff       	call   c0107fda <find_vma>
c0108983:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c0108986:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010898a:	74 24                	je     c01089b0 <check_vma_struct+0x2e4>
c010898c:	c7 44 24 0c db da 10 	movl   $0xc010dadb,0xc(%esp)
c0108993:	c0 
c0108994:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c010899b:	c0 
c010899c:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01089a3:	00 
c01089a4:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c01089ab:	e8 25 84 ff ff       	call   c0100dd5 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c01089b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089b3:	83 c0 03             	add    $0x3,%eax
c01089b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01089bd:	89 04 24             	mov    %eax,(%esp)
c01089c0:	e8 15 f6 ff ff       	call   c0107fda <find_vma>
c01089c5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c01089c8:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c01089cc:	74 24                	je     c01089f2 <check_vma_struct+0x326>
c01089ce:	c7 44 24 0c e8 da 10 	movl   $0xc010dae8,0xc(%esp)
c01089d5:	c0 
c01089d6:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c01089dd:	c0 
c01089de:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c01089e5:	00 
c01089e6:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c01089ed:	e8 e3 83 ff ff       	call   c0100dd5 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c01089f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089f5:	83 c0 04             	add    $0x4,%eax
c01089f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01089ff:	89 04 24             	mov    %eax,(%esp)
c0108a02:	e8 d3 f5 ff ff       	call   c0107fda <find_vma>
c0108a07:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c0108a0a:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0108a0e:	74 24                	je     c0108a34 <check_vma_struct+0x368>
c0108a10:	c7 44 24 0c f5 da 10 	movl   $0xc010daf5,0xc(%esp)
c0108a17:	c0 
c0108a18:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108a1f:	c0 
c0108a20:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0108a27:	00 
c0108a28:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108a2f:	e8 a1 83 ff ff       	call   c0100dd5 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0108a34:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108a37:	8b 50 04             	mov    0x4(%eax),%edx
c0108a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a3d:	39 c2                	cmp    %eax,%edx
c0108a3f:	75 10                	jne    c0108a51 <check_vma_struct+0x385>
c0108a41:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108a44:	8b 50 08             	mov    0x8(%eax),%edx
c0108a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a4a:	83 c0 02             	add    $0x2,%eax
c0108a4d:	39 c2                	cmp    %eax,%edx
c0108a4f:	74 24                	je     c0108a75 <check_vma_struct+0x3a9>
c0108a51:	c7 44 24 0c 04 db 10 	movl   $0xc010db04,0xc(%esp)
c0108a58:	c0 
c0108a59:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108a60:	c0 
c0108a61:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0108a68:	00 
c0108a69:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108a70:	e8 60 83 ff ff       	call   c0100dd5 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0108a75:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108a78:	8b 50 04             	mov    0x4(%eax),%edx
c0108a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a7e:	39 c2                	cmp    %eax,%edx
c0108a80:	75 10                	jne    c0108a92 <check_vma_struct+0x3c6>
c0108a82:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108a85:	8b 50 08             	mov    0x8(%eax),%edx
c0108a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a8b:	83 c0 02             	add    $0x2,%eax
c0108a8e:	39 c2                	cmp    %eax,%edx
c0108a90:	74 24                	je     c0108ab6 <check_vma_struct+0x3ea>
c0108a92:	c7 44 24 0c 34 db 10 	movl   $0xc010db34,0xc(%esp)
c0108a99:	c0 
c0108a9a:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108aa1:	c0 
c0108aa2:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0108aa9:	00 
c0108aaa:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108ab1:	e8 1f 83 ff ff       	call   c0100dd5 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0108ab6:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0108aba:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108abd:	89 d0                	mov    %edx,%eax
c0108abf:	c1 e0 02             	shl    $0x2,%eax
c0108ac2:	01 d0                	add    %edx,%eax
c0108ac4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108ac7:	0f 8d 20 fe ff ff    	jge    c01088ed <check_vma_struct+0x221>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0108acd:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0108ad4:	eb 70                	jmp    c0108b46 <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0108ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108add:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ae0:	89 04 24             	mov    %eax,(%esp)
c0108ae3:	e8 f2 f4 ff ff       	call   c0107fda <find_vma>
c0108ae8:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c0108aeb:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108aef:	74 27                	je     c0108b18 <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0108af1:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108af4:	8b 50 08             	mov    0x8(%eax),%edx
c0108af7:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108afa:	8b 40 04             	mov    0x4(%eax),%eax
c0108afd:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108b01:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b08:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b0c:	c7 04 24 64 db 10 c0 	movl   $0xc010db64,(%esp)
c0108b13:	e8 3b 78 ff ff       	call   c0100353 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0108b18:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108b1c:	74 24                	je     c0108b42 <check_vma_struct+0x476>
c0108b1e:	c7 44 24 0c 89 db 10 	movl   $0xc010db89,0xc(%esp)
c0108b25:	c0 
c0108b26:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108b2d:	c0 
c0108b2e:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0108b35:	00 
c0108b36:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108b3d:	e8 93 82 ff ff       	call   c0100dd5 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0108b42:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0108b46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108b4a:	79 8a                	jns    c0108ad6 <check_vma_struct+0x40a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c0108b4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b4f:	89 04 24             	mov    %eax,(%esp)
c0108b52:	e8 08 f7 ff ff       	call   c010825f <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c0108b57:	c7 04 24 a0 db 10 c0 	movl   $0xc010dba0,(%esp)
c0108b5e:	e8 f0 77 ff ff       	call   c0100353 <cprintf>
}
c0108b63:	c9                   	leave  
c0108b64:	c3                   	ret    

c0108b65 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0108b65:	55                   	push   %ebp
c0108b66:	89 e5                	mov    %esp,%ebp
c0108b68:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108b6b:	e8 94 c5 ff ff       	call   c0105104 <nr_free_pages>
c0108b70:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0108b73:	e8 8e f3 ff ff       	call   c0107f06 <mm_create>
c0108b78:	a3 ac f0 19 c0       	mov    %eax,0xc019f0ac
    assert(check_mm_struct != NULL);
c0108b7d:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c0108b82:	85 c0                	test   %eax,%eax
c0108b84:	75 24                	jne    c0108baa <check_pgfault+0x45>
c0108b86:	c7 44 24 0c bf db 10 	movl   $0xc010dbbf,0xc(%esp)
c0108b8d:	c0 
c0108b8e:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108b95:	c0 
c0108b96:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c0108b9d:	00 
c0108b9e:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108ba5:	e8 2b 82 ff ff       	call   c0100dd5 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0108baa:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c0108baf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0108bb2:	8b 15 e4 ce 19 c0    	mov    0xc019cee4,%edx
c0108bb8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108bbb:	89 50 0c             	mov    %edx,0xc(%eax)
c0108bbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108bc1:	8b 40 0c             	mov    0xc(%eax),%eax
c0108bc4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0108bc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108bca:	8b 00                	mov    (%eax),%eax
c0108bcc:	85 c0                	test   %eax,%eax
c0108bce:	74 24                	je     c0108bf4 <check_pgfault+0x8f>
c0108bd0:	c7 44 24 0c d7 db 10 	movl   $0xc010dbd7,0xc(%esp)
c0108bd7:	c0 
c0108bd8:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108bdf:	c0 
c0108be0:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
c0108be7:	00 
c0108be8:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108bef:	e8 e1 81 ff ff       	call   c0100dd5 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0108bf4:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0108bfb:	00 
c0108bfc:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0108c03:	00 
c0108c04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0108c0b:	e8 8f f3 ff ff       	call   c0107f9f <vma_create>
c0108c10:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0108c13:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108c17:	75 24                	jne    c0108c3d <check_pgfault+0xd8>
c0108c19:	c7 44 24 0c 68 da 10 	movl   $0xc010da68,0xc(%esp)
c0108c20:	c0 
c0108c21:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108c28:	c0 
c0108c29:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0108c30:	00 
c0108c31:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108c38:	e8 98 81 ff ff       	call   c0100dd5 <__panic>

    insert_vma_struct(mm, vma);
c0108c3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108c40:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c44:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c47:	89 04 24             	mov    %eax,(%esp)
c0108c4a:	e8 e0 f4 ff ff       	call   c010812f <insert_vma_struct>

    uintptr_t addr = 0x100;
c0108c4f:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0108c56:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108c59:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c60:	89 04 24             	mov    %eax,(%esp)
c0108c63:	e8 72 f3 ff ff       	call   c0107fda <find_vma>
c0108c68:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108c6b:	74 24                	je     c0108c91 <check_pgfault+0x12c>
c0108c6d:	c7 44 24 0c e5 db 10 	movl   $0xc010dbe5,0xc(%esp)
c0108c74:	c0 
c0108c75:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108c7c:	c0 
c0108c7d:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
c0108c84:	00 
c0108c85:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108c8c:	e8 44 81 ff ff       	call   c0100dd5 <__panic>

    int i, sum = 0;
c0108c91:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0108c98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108c9f:	eb 17                	jmp    c0108cb8 <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c0108ca1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108ca4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108ca7:	01 d0                	add    %edx,%eax
c0108ca9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108cac:	88 10                	mov    %dl,(%eax)
        sum += i;
c0108cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108cb1:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0108cb4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108cb8:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108cbc:	7e e3                	jle    c0108ca1 <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0108cbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108cc5:	eb 15                	jmp    c0108cdc <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c0108cc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108cca:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108ccd:	01 d0                	add    %edx,%eax
c0108ccf:	0f b6 00             	movzbl (%eax),%eax
c0108cd2:	0f be c0             	movsbl %al,%eax
c0108cd5:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0108cd8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108cdc:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108ce0:	7e e5                	jle    c0108cc7 <check_pgfault+0x162>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0108ce2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108ce6:	74 24                	je     c0108d0c <check_pgfault+0x1a7>
c0108ce8:	c7 44 24 0c ff db 10 	movl   $0xc010dbff,0xc(%esp)
c0108cef:	c0 
c0108cf0:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108cf7:	c0 
c0108cf8:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c0108cff:	00 
c0108d00:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108d07:	e8 c9 80 ff ff       	call   c0100dd5 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0108d0c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108d0f:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108d12:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108d15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108d1a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108d1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d21:	89 04 24             	mov    %eax,(%esp)
c0108d24:	e8 cf d0 ff ff       	call   c0105df8 <page_remove>
    free_page(pde2page(pgdir[0]));
c0108d29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d2c:	8b 00                	mov    (%eax),%eax
c0108d2e:	89 04 24             	mov    %eax,(%esp)
c0108d31:	e8 b8 f1 ff ff       	call   c0107eee <pde2page>
c0108d36:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108d3d:	00 
c0108d3e:	89 04 24             	mov    %eax,(%esp)
c0108d41:	e8 8c c3 ff ff       	call   c01050d2 <free_pages>
    pgdir[0] = 0;
c0108d46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d49:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0108d4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d52:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0108d59:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d5c:	89 04 24             	mov    %eax,(%esp)
c0108d5f:	e8 fb f4 ff ff       	call   c010825f <mm_destroy>
    check_mm_struct = NULL;
c0108d64:	c7 05 ac f0 19 c0 00 	movl   $0x0,0xc019f0ac
c0108d6b:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0108d6e:	e8 91 c3 ff ff       	call   c0105104 <nr_free_pages>
c0108d73:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108d76:	74 24                	je     c0108d9c <check_pgfault+0x237>
c0108d78:	c7 44 24 0c 08 dc 10 	movl   $0xc010dc08,0xc(%esp)
c0108d7f:	c0 
c0108d80:	c7 44 24 08 77 d9 10 	movl   $0xc010d977,0x8(%esp)
c0108d87:	c0 
c0108d88:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c0108d8f:	00 
c0108d90:	c7 04 24 8c d9 10 c0 	movl   $0xc010d98c,(%esp)
c0108d97:	e8 39 80 ff ff       	call   c0100dd5 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0108d9c:	c7 04 24 2f dc 10 c0 	movl   $0xc010dc2f,(%esp)
c0108da3:	e8 ab 75 ff ff       	call   c0100353 <cprintf>
}
c0108da8:	c9                   	leave  
c0108da9:	c3                   	ret    

c0108daa <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0108daa:	55                   	push   %ebp
c0108dab:	89 e5                	mov    %esp,%ebp
c0108dad:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0108db0:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0108db7:	8b 45 10             	mov    0x10(%ebp),%eax
c0108dba:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108dbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dc1:	89 04 24             	mov    %eax,(%esp)
c0108dc4:	e8 11 f2 ff ff       	call   c0107fda <find_vma>
c0108dc9:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0108dcc:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0108dd1:	83 c0 01             	add    $0x1,%eax
c0108dd4:	a3 78 cf 19 c0       	mov    %eax,0xc019cf78
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0108dd9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0108ddd:	74 0b                	je     c0108dea <do_pgfault+0x40>
c0108ddf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108de2:	8b 40 04             	mov    0x4(%eax),%eax
c0108de5:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108de8:	76 18                	jbe    c0108e02 <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0108dea:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ded:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108df1:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108df8:	e8 56 75 ff ff       	call   c0100353 <cprintf>
        goto failed;
c0108dfd:	e9 dc 01 00 00       	jmp    c0108fde <do_pgfault+0x234>
    }
    //check the error_code
    switch (error_code & 3) {
c0108e02:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e05:	83 e0 03             	and    $0x3,%eax
c0108e08:	85 c0                	test   %eax,%eax
c0108e0a:	74 36                	je     c0108e42 <do_pgfault+0x98>
c0108e0c:	83 f8 01             	cmp    $0x1,%eax
c0108e0f:	74 20                	je     c0108e31 <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0108e11:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e14:	8b 40 0c             	mov    0xc(%eax),%eax
c0108e17:	83 e0 02             	and    $0x2,%eax
c0108e1a:	85 c0                	test   %eax,%eax
c0108e1c:	75 11                	jne    c0108e2f <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0108e1e:	c7 04 24 7c dc 10 c0 	movl   $0xc010dc7c,(%esp)
c0108e25:	e8 29 75 ff ff       	call   c0100353 <cprintf>
            goto failed;
c0108e2a:	e9 af 01 00 00       	jmp    c0108fde <do_pgfault+0x234>
        }
        break;
c0108e2f:	eb 2f                	jmp    c0108e60 <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0108e31:	c7 04 24 dc dc 10 c0 	movl   $0xc010dcdc,(%esp)
c0108e38:	e8 16 75 ff ff       	call   c0100353 <cprintf>
        goto failed;
c0108e3d:	e9 9c 01 00 00       	jmp    c0108fde <do_pgfault+0x234>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0108e42:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e45:	8b 40 0c             	mov    0xc(%eax),%eax
c0108e48:	83 e0 05             	and    $0x5,%eax
c0108e4b:	85 c0                	test   %eax,%eax
c0108e4d:	75 11                	jne    c0108e60 <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0108e4f:	c7 04 24 14 dd 10 c0 	movl   $0xc010dd14,(%esp)
c0108e56:	e8 f8 74 ff ff       	call   c0100353 <cprintf>
            goto failed;
c0108e5b:	e9 7e 01 00 00       	jmp    c0108fde <do_pgfault+0x234>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0108e60:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0108e67:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e6a:	8b 40 0c             	mov    0xc(%eax),%eax
c0108e6d:	83 e0 02             	and    $0x2,%eax
c0108e70:	85 c0                	test   %eax,%eax
c0108e72:	74 04                	je     c0108e78 <do_pgfault+0xce>
        perm |= PTE_W;
c0108e74:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0108e78:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e7b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108e7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108e86:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0108e89:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0108e90:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
    ptep = get_pte(mm->pgdir, addr, 1);
c0108e97:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e9a:	8b 40 0c             	mov    0xc(%eax),%eax
c0108e9d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108ea4:	00 
c0108ea5:	8b 55 10             	mov    0x10(%ebp),%edx
c0108ea8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108eac:	89 04 24             	mov    %eax,(%esp)
c0108eaf:	e8 1a c9 ff ff       	call   c01057ce <get_pte>
c0108eb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (ptep == NULL) {
c0108eb7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108ebb:	75 11                	jne    c0108ece <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c0108ebd:	c7 04 24 77 dd 10 c0 	movl   $0xc010dd77,(%esp)
c0108ec4:	e8 8a 74 ff ff       	call   c0100353 <cprintf>
        goto failed;
c0108ec9:	e9 10 01 00 00       	jmp    c0108fde <do_pgfault+0x234>
    }

    if (*ptep == 0) {
c0108ece:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108ed1:	8b 00                	mov    (%eax),%eax
c0108ed3:	85 c0                	test   %eax,%eax
c0108ed5:	75 3b                	jne    c0108f12 <do_pgfault+0x168>
        struct Page* page = pgdir_alloc_page(mm->pgdir, addr, perm);
c0108ed7:	8b 45 08             	mov    0x8(%ebp),%eax
c0108eda:	8b 40 0c             	mov    0xc(%eax),%eax
c0108edd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108ee0:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108ee4:	8b 55 10             	mov    0x10(%ebp),%edx
c0108ee7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108eeb:	89 04 24             	mov    %eax,(%esp)
c0108eee:	e8 5f d0 ff ff       	call   c0105f52 <pgdir_alloc_page>
c0108ef3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if (page == NULL) {
c0108ef6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108efa:	75 11                	jne    c0108f0d <do_pgfault+0x163>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0108efc:	c7 04 24 98 dd 10 c0 	movl   $0xc010dd98,(%esp)
c0108f03:	e8 4b 74 ff ff       	call   c0100353 <cprintf>
            goto failed;
c0108f08:	e9 d1 00 00 00       	jmp    c0108fde <do_pgfault+0x234>
c0108f0d:	e9 c5 00 00 00       	jmp    c0108fd7 <do_pgfault+0x22d>
        }
    }

    else {
        if(swap_init_ok) {
c0108f12:	a1 6c cf 19 c0       	mov    0xc019cf6c,%eax
c0108f17:	85 c0                	test   %eax,%eax
c0108f19:	0f 84 a1 00 00 00    	je     c0108fc0 <do_pgfault+0x216>
            struct Page *page = NULL;
c0108f1f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
            ret = swap_in(mm, addr, &page);
c0108f26:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0108f29:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108f2d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f30:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f34:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f37:	89 04 24             	mov    %eax,(%esp)
c0108f3a:	e8 bf e0 ff ff       	call   c0106ffe <swap_in>
c0108f3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (ret != 0) {
c0108f42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108f46:	74 11                	je     c0108f59 <do_pgfault+0x1af>
                cprintf("swap_in in do_pgfault failed\n");
c0108f48:	c7 04 24 bf dd 10 c0 	movl   $0xc010ddbf,(%esp)
c0108f4f:	e8 ff 73 ff ff       	call   c0100353 <cprintf>
                goto failed;
c0108f54:	e9 85 00 00 00       	jmp    c0108fde <do_pgfault+0x234>
            }
            ret = page_insert(mm->pgdir, page, addr, perm);
c0108f59:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108f5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f5f:	8b 40 0c             	mov    0xc(%eax),%eax
c0108f62:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108f65:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0108f69:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0108f6c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108f70:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108f74:	89 04 24             	mov    %eax,(%esp)
c0108f77:	e8 c0 ce ff ff       	call   c0105e3c <page_insert>
c0108f7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (ret != 0) {
c0108f7f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108f83:	74 0f                	je     c0108f94 <do_pgfault+0x1ea>
                cprintf("page_insert in do_pgfault failed\n");
c0108f85:	c7 04 24 e0 dd 10 c0 	movl   $0xc010dde0,(%esp)
c0108f8c:	e8 c2 73 ff ff       	call   c0100353 <cprintf>
                goto failed;
c0108f91:	90                   	nop
c0108f92:	eb 4a                	jmp    c0108fde <do_pgfault+0x234>
            }
            swap_map_swappable(mm, addr, page, 1);
c0108f94:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108f97:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0108f9e:	00 
c0108f9f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108fa3:	8b 45 10             	mov    0x10(%ebp),%eax
c0108fa6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108faa:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fad:	89 04 24             	mov    %eax,(%esp)
c0108fb0:	e8 80 de ff ff       	call   c0106e35 <swap_map_swappable>
            page->pra_vaddr = addr;
c0108fb5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108fb8:	8b 55 10             	mov    0x10(%ebp),%edx
c0108fbb:	89 50 1c             	mov    %edx,0x1c(%eax)
c0108fbe:	eb 17                	jmp    c0108fd7 <do_pgfault+0x22d>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0108fc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108fc3:	8b 00                	mov    (%eax),%eax
c0108fc5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108fc9:	c7 04 24 04 de 10 c0 	movl   $0xc010de04,(%esp)
c0108fd0:	e8 7e 73 ff ff       	call   c0100353 <cprintf>
            goto failed;
c0108fd5:	eb 07                	jmp    c0108fde <do_pgfault+0x234>
        }
   }
   ret = 0;
c0108fd7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0108fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108fe1:	c9                   	leave  
c0108fe2:	c3                   	ret    

c0108fe3 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
c0108fe3:	55                   	push   %ebp
c0108fe4:	89 e5                	mov    %esp,%ebp
c0108fe6:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0108fe9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108fed:	0f 84 e0 00 00 00    	je     c01090d3 <user_mem_check+0xf0>
        if (!USER_ACCESS(addr, addr + len)) {
c0108ff3:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0108ffa:	76 1c                	jbe    c0109018 <user_mem_check+0x35>
c0108ffc:	8b 45 10             	mov    0x10(%ebp),%eax
c0108fff:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109002:	01 d0                	add    %edx,%eax
c0109004:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109007:	76 0f                	jbe    c0109018 <user_mem_check+0x35>
c0109009:	8b 45 10             	mov    0x10(%ebp),%eax
c010900c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010900f:	01 d0                	add    %edx,%eax
c0109011:	3d 00 00 00 b0       	cmp    $0xb0000000,%eax
c0109016:	76 0a                	jbe    c0109022 <user_mem_check+0x3f>
            return 0;
c0109018:	b8 00 00 00 00       	mov    $0x0,%eax
c010901d:	e9 e2 00 00 00       	jmp    c0109104 <user_mem_check+0x121>
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
c0109022:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109025:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109028:	8b 45 10             	mov    0x10(%ebp),%eax
c010902b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010902e:	01 d0                	add    %edx,%eax
c0109030:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (start < end) {
c0109033:	e9 88 00 00 00       	jmp    c01090c0 <user_mem_check+0xdd>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
c0109038:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010903b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010903f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109042:	89 04 24             	mov    %eax,(%esp)
c0109045:	e8 90 ef ff ff       	call   c0107fda <find_vma>
c010904a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010904d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109051:	74 0b                	je     c010905e <user_mem_check+0x7b>
c0109053:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109056:	8b 40 04             	mov    0x4(%eax),%eax
c0109059:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010905c:	76 0a                	jbe    c0109068 <user_mem_check+0x85>
                return 0;
c010905e:	b8 00 00 00 00       	mov    $0x0,%eax
c0109063:	e9 9c 00 00 00       	jmp    c0109104 <user_mem_check+0x121>
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
c0109068:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010906b:	8b 50 0c             	mov    0xc(%eax),%edx
c010906e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0109072:	74 07                	je     c010907b <user_mem_check+0x98>
c0109074:	b8 02 00 00 00       	mov    $0x2,%eax
c0109079:	eb 05                	jmp    c0109080 <user_mem_check+0x9d>
c010907b:	b8 01 00 00 00       	mov    $0x1,%eax
c0109080:	21 d0                	and    %edx,%eax
c0109082:	85 c0                	test   %eax,%eax
c0109084:	75 07                	jne    c010908d <user_mem_check+0xaa>
                return 0;
c0109086:	b8 00 00 00 00       	mov    $0x0,%eax
c010908b:	eb 77                	jmp    c0109104 <user_mem_check+0x121>
            }
            if (write && (vma->vm_flags & VM_STACK)) {
c010908d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0109091:	74 24                	je     c01090b7 <user_mem_check+0xd4>
c0109093:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109096:	8b 40 0c             	mov    0xc(%eax),%eax
c0109099:	83 e0 08             	and    $0x8,%eax
c010909c:	85 c0                	test   %eax,%eax
c010909e:	74 17                	je     c01090b7 <user_mem_check+0xd4>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
c01090a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090a3:	8b 40 04             	mov    0x4(%eax),%eax
c01090a6:	05 00 10 00 00       	add    $0x1000,%eax
c01090ab:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01090ae:	76 07                	jbe    c01090b7 <user_mem_check+0xd4>
                    return 0;
c01090b0:	b8 00 00 00 00       	mov    $0x0,%eax
c01090b5:	eb 4d                	jmp    c0109104 <user_mem_check+0x121>
                }
            }
            start = vma->vm_end;
c01090b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090ba:	8b 40 08             	mov    0x8(%eax),%eax
c01090bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!USER_ACCESS(addr, addr + len)) {
            return 0;
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
        while (start < end) {
c01090c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01090c3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01090c6:	0f 82 6c ff ff ff    	jb     c0109038 <user_mem_check+0x55>
                    return 0;
                }
            }
            start = vma->vm_end;
        }
        return 1;
c01090cc:	b8 01 00 00 00       	mov    $0x1,%eax
c01090d1:	eb 31                	jmp    c0109104 <user_mem_check+0x121>
    }
    return KERN_ACCESS(addr, addr + len);
c01090d3:	81 7d 0c ff ff ff bf 	cmpl   $0xbfffffff,0xc(%ebp)
c01090da:	76 23                	jbe    c01090ff <user_mem_check+0x11c>
c01090dc:	8b 45 10             	mov    0x10(%ebp),%eax
c01090df:	8b 55 0c             	mov    0xc(%ebp),%edx
c01090e2:	01 d0                	add    %edx,%eax
c01090e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01090e7:	76 16                	jbe    c01090ff <user_mem_check+0x11c>
c01090e9:	8b 45 10             	mov    0x10(%ebp),%eax
c01090ec:	8b 55 0c             	mov    0xc(%ebp),%edx
c01090ef:	01 d0                	add    %edx,%eax
c01090f1:	3d 00 00 00 f8       	cmp    $0xf8000000,%eax
c01090f6:	77 07                	ja     c01090ff <user_mem_check+0x11c>
c01090f8:	b8 01 00 00 00       	mov    $0x1,%eax
c01090fd:	eb 05                	jmp    c0109104 <user_mem_check+0x121>
c01090ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109104:	c9                   	leave  
c0109105:	c3                   	ret    

c0109106 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0109106:	55                   	push   %ebp
c0109107:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109109:	8b 55 08             	mov    0x8(%ebp),%edx
c010910c:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0109111:	29 c2                	sub    %eax,%edx
c0109113:	89 d0                	mov    %edx,%eax
c0109115:	c1 f8 05             	sar    $0x5,%eax
}
c0109118:	5d                   	pop    %ebp
c0109119:	c3                   	ret    

c010911a <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010911a:	55                   	push   %ebp
c010911b:	89 e5                	mov    %esp,%ebp
c010911d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0109120:	8b 45 08             	mov    0x8(%ebp),%eax
c0109123:	89 04 24             	mov    %eax,(%esp)
c0109126:	e8 db ff ff ff       	call   c0109106 <page2ppn>
c010912b:	c1 e0 0c             	shl    $0xc,%eax
}
c010912e:	c9                   	leave  
c010912f:	c3                   	ret    

c0109130 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0109130:	55                   	push   %ebp
c0109131:	89 e5                	mov    %esp,%ebp
c0109133:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0109136:	8b 45 08             	mov    0x8(%ebp),%eax
c0109139:	89 04 24             	mov    %eax,(%esp)
c010913c:	e8 d9 ff ff ff       	call   c010911a <page2pa>
c0109141:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109144:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109147:	c1 e8 0c             	shr    $0xc,%eax
c010914a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010914d:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0109152:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109155:	72 23                	jb     c010917a <page2kva+0x4a>
c0109157:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010915a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010915e:	c7 44 24 08 2c de 10 	movl   $0xc010de2c,0x8(%esp)
c0109165:	c0 
c0109166:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c010916d:	00 
c010916e:	c7 04 24 4f de 10 c0 	movl   $0xc010de4f,(%esp)
c0109175:	e8 5b 7c ff ff       	call   c0100dd5 <__panic>
c010917a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010917d:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0109182:	c9                   	leave  
c0109183:	c3                   	ret    

c0109184 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0109184:	55                   	push   %ebp
c0109185:	89 e5                	mov    %esp,%ebp
c0109187:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c010918a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109191:	e8 8f 89 ff ff       	call   c0101b25 <ide_device_valid>
c0109196:	85 c0                	test   %eax,%eax
c0109198:	75 1c                	jne    c01091b6 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c010919a:	c7 44 24 08 5d de 10 	movl   $0xc010de5d,0x8(%esp)
c01091a1:	c0 
c01091a2:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c01091a9:	00 
c01091aa:	c7 04 24 77 de 10 c0 	movl   $0xc010de77,(%esp)
c01091b1:	e8 1f 7c ff ff       	call   c0100dd5 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01091b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01091bd:	e8 a2 89 ff ff       	call   c0101b64 <ide_device_size>
c01091c2:	c1 e8 03             	shr    $0x3,%eax
c01091c5:	a3 7c f0 19 c0       	mov    %eax,0xc019f07c
}
c01091ca:	c9                   	leave  
c01091cb:	c3                   	ret    

c01091cc <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01091cc:	55                   	push   %ebp
c01091cd:	89 e5                	mov    %esp,%ebp
c01091cf:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01091d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01091d5:	89 04 24             	mov    %eax,(%esp)
c01091d8:	e8 53 ff ff ff       	call   c0109130 <page2kva>
c01091dd:	8b 55 08             	mov    0x8(%ebp),%edx
c01091e0:	c1 ea 08             	shr    $0x8,%edx
c01091e3:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01091e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01091ea:	74 0b                	je     c01091f7 <swapfs_read+0x2b>
c01091ec:	8b 15 7c f0 19 c0    	mov    0xc019f07c,%edx
c01091f2:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01091f5:	72 23                	jb     c010921a <swapfs_read+0x4e>
c01091f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01091fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01091fe:	c7 44 24 08 88 de 10 	movl   $0xc010de88,0x8(%esp)
c0109205:	c0 
c0109206:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c010920d:	00 
c010920e:	c7 04 24 77 de 10 c0 	movl   $0xc010de77,(%esp)
c0109215:	e8 bb 7b ff ff       	call   c0100dd5 <__panic>
c010921a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010921d:	c1 e2 03             	shl    $0x3,%edx
c0109220:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0109227:	00 
c0109228:	89 44 24 08          	mov    %eax,0x8(%esp)
c010922c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109230:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109237:	e8 67 89 ff ff       	call   c0101ba3 <ide_read_secs>
}
c010923c:	c9                   	leave  
c010923d:	c3                   	ret    

c010923e <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c010923e:	55                   	push   %ebp
c010923f:	89 e5                	mov    %esp,%ebp
c0109241:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0109244:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109247:	89 04 24             	mov    %eax,(%esp)
c010924a:	e8 e1 fe ff ff       	call   c0109130 <page2kva>
c010924f:	8b 55 08             	mov    0x8(%ebp),%edx
c0109252:	c1 ea 08             	shr    $0x8,%edx
c0109255:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109258:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010925c:	74 0b                	je     c0109269 <swapfs_write+0x2b>
c010925e:	8b 15 7c f0 19 c0    	mov    0xc019f07c,%edx
c0109264:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109267:	72 23                	jb     c010928c <swapfs_write+0x4e>
c0109269:	8b 45 08             	mov    0x8(%ebp),%eax
c010926c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109270:	c7 44 24 08 88 de 10 	movl   $0xc010de88,0x8(%esp)
c0109277:	c0 
c0109278:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c010927f:	00 
c0109280:	c7 04 24 77 de 10 c0 	movl   $0xc010de77,(%esp)
c0109287:	e8 49 7b ff ff       	call   c0100dd5 <__panic>
c010928c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010928f:	c1 e2 03             	shl    $0x3,%edx
c0109292:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0109299:	00 
c010929a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010929e:	89 54 24 04          	mov    %edx,0x4(%esp)
c01092a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01092a9:	e8 37 8b ff ff       	call   c0101de5 <ide_write_secs>
}
c01092ae:	c9                   	leave  
c01092af:	c3                   	ret    

c01092b0 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c01092b0:	52                   	push   %edx
    call *%ebx              # call fn
c01092b1:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c01092b3:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c01092b4:	e8 79 0c 00 00       	call   c0109f32 <do_exit>

c01092b9 <test_and_set_bit>:
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
c01092b9:	55                   	push   %ebp
c01092ba:	89 e5                	mov    %esp,%ebp
c01092bc:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01092bf:	8b 55 0c             	mov    0xc(%ebp),%edx
c01092c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01092c5:	0f ab 02             	bts    %eax,(%edx)
c01092c8:	19 c0                	sbb    %eax,%eax
c01092ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01092cd:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01092d1:	0f 95 c0             	setne  %al
c01092d4:	0f b6 c0             	movzbl %al,%eax
}
c01092d7:	c9                   	leave  
c01092d8:	c3                   	ret    

c01092d9 <test_and_clear_bit>:
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
c01092d9:	55                   	push   %ebp
c01092da:	89 e5                	mov    %esp,%ebp
c01092dc:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01092df:	8b 55 0c             	mov    0xc(%ebp),%edx
c01092e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01092e5:	0f b3 02             	btr    %eax,(%edx)
c01092e8:	19 c0                	sbb    %eax,%eax
c01092ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01092ed:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01092f1:	0f 95 c0             	setne  %al
c01092f4:	0f b6 c0             	movzbl %al,%eax
}
c01092f7:	c9                   	leave  
c01092f8:	c3                   	ret    

c01092f9 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c01092f9:	55                   	push   %ebp
c01092fa:	89 e5                	mov    %esp,%ebp
c01092fc:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01092ff:	9c                   	pushf  
c0109300:	58                   	pop    %eax
c0109301:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0109304:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109307:	25 00 02 00 00       	and    $0x200,%eax
c010930c:	85 c0                	test   %eax,%eax
c010930e:	74 0c                	je     c010931c <__intr_save+0x23>
        intr_disable();
c0109310:	e8 18 8d ff ff       	call   c010202d <intr_disable>
        return 1;
c0109315:	b8 01 00 00 00       	mov    $0x1,%eax
c010931a:	eb 05                	jmp    c0109321 <__intr_save+0x28>
    }
    return 0;
c010931c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109321:	c9                   	leave  
c0109322:	c3                   	ret    

c0109323 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0109323:	55                   	push   %ebp
c0109324:	89 e5                	mov    %esp,%ebp
c0109326:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109329:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010932d:	74 05                	je     c0109334 <__intr_restore+0x11>
        intr_enable();
c010932f:	e8 f3 8c ff ff       	call   c0102027 <intr_enable>
    }
}
c0109334:	c9                   	leave  
c0109335:	c3                   	ret    

c0109336 <try_lock>:
lock_init(lock_t *lock) {
    *lock = 0;
}

static inline bool
try_lock(lock_t *lock) {
c0109336:	55                   	push   %ebp
c0109337:	89 e5                	mov    %esp,%ebp
c0109339:	83 ec 08             	sub    $0x8,%esp
    return !test_and_set_bit(0, lock);
c010933c:	8b 45 08             	mov    0x8(%ebp),%eax
c010933f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109343:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010934a:	e8 6a ff ff ff       	call   c01092b9 <test_and_set_bit>
c010934f:	85 c0                	test   %eax,%eax
c0109351:	0f 94 c0             	sete   %al
c0109354:	0f b6 c0             	movzbl %al,%eax
}
c0109357:	c9                   	leave  
c0109358:	c3                   	ret    

c0109359 <lock>:

static inline void
lock(lock_t *lock) {
c0109359:	55                   	push   %ebp
c010935a:	89 e5                	mov    %esp,%ebp
c010935c:	83 ec 18             	sub    $0x18,%esp
    while (!try_lock(lock)) {
c010935f:	eb 05                	jmp    c0109366 <lock+0xd>
        schedule();
c0109361:	e8 31 1c 00 00       	call   c010af97 <schedule>
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
c0109366:	8b 45 08             	mov    0x8(%ebp),%eax
c0109369:	89 04 24             	mov    %eax,(%esp)
c010936c:	e8 c5 ff ff ff       	call   c0109336 <try_lock>
c0109371:	85 c0                	test   %eax,%eax
c0109373:	74 ec                	je     c0109361 <lock+0x8>
        schedule();
    }
}
c0109375:	c9                   	leave  
c0109376:	c3                   	ret    

c0109377 <unlock>:

static inline void
unlock(lock_t *lock) {
c0109377:	55                   	push   %ebp
c0109378:	89 e5                	mov    %esp,%ebp
c010937a:	83 ec 18             	sub    $0x18,%esp
    if (!test_and_clear_bit(0, lock)) {
c010937d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109380:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109384:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010938b:	e8 49 ff ff ff       	call   c01092d9 <test_and_clear_bit>
c0109390:	85 c0                	test   %eax,%eax
c0109392:	75 1c                	jne    c01093b0 <unlock+0x39>
        panic("Unlock failed.\n");
c0109394:	c7 44 24 08 a8 de 10 	movl   $0xc010dea8,0x8(%esp)
c010939b:	c0 
c010939c:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
c01093a3:	00 
c01093a4:	c7 04 24 b8 de 10 c0 	movl   $0xc010deb8,(%esp)
c01093ab:	e8 25 7a ff ff       	call   c0100dd5 <__panic>
    }
}
c01093b0:	c9                   	leave  
c01093b1:	c3                   	ret    

c01093b2 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01093b2:	55                   	push   %ebp
c01093b3:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01093b5:	8b 55 08             	mov    0x8(%ebp),%edx
c01093b8:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c01093bd:	29 c2                	sub    %eax,%edx
c01093bf:	89 d0                	mov    %edx,%eax
c01093c1:	c1 f8 05             	sar    $0x5,%eax
}
c01093c4:	5d                   	pop    %ebp
c01093c5:	c3                   	ret    

c01093c6 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01093c6:	55                   	push   %ebp
c01093c7:	89 e5                	mov    %esp,%ebp
c01093c9:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01093cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01093cf:	89 04 24             	mov    %eax,(%esp)
c01093d2:	e8 db ff ff ff       	call   c01093b2 <page2ppn>
c01093d7:	c1 e0 0c             	shl    $0xc,%eax
}
c01093da:	c9                   	leave  
c01093db:	c3                   	ret    

c01093dc <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01093dc:	55                   	push   %ebp
c01093dd:	89 e5                	mov    %esp,%ebp
c01093df:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01093e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01093e5:	c1 e8 0c             	shr    $0xc,%eax
c01093e8:	89 c2                	mov    %eax,%edx
c01093ea:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c01093ef:	39 c2                	cmp    %eax,%edx
c01093f1:	72 1c                	jb     c010940f <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01093f3:	c7 44 24 08 cc de 10 	movl   $0xc010decc,0x8(%esp)
c01093fa:	c0 
c01093fb:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0109402:	00 
c0109403:	c7 04 24 eb de 10 c0 	movl   $0xc010deeb,(%esp)
c010940a:	e8 c6 79 ff ff       	call   c0100dd5 <__panic>
    }
    return &pages[PPN(pa)];
c010940f:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0109414:	8b 55 08             	mov    0x8(%ebp),%edx
c0109417:	c1 ea 0c             	shr    $0xc,%edx
c010941a:	c1 e2 05             	shl    $0x5,%edx
c010941d:	01 d0                	add    %edx,%eax
}
c010941f:	c9                   	leave  
c0109420:	c3                   	ret    

c0109421 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0109421:	55                   	push   %ebp
c0109422:	89 e5                	mov    %esp,%ebp
c0109424:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0109427:	8b 45 08             	mov    0x8(%ebp),%eax
c010942a:	89 04 24             	mov    %eax,(%esp)
c010942d:	e8 94 ff ff ff       	call   c01093c6 <page2pa>
c0109432:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109435:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109438:	c1 e8 0c             	shr    $0xc,%eax
c010943b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010943e:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0109443:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109446:	72 23                	jb     c010946b <page2kva+0x4a>
c0109448:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010944b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010944f:	c7 44 24 08 fc de 10 	movl   $0xc010defc,0x8(%esp)
c0109456:	c0 
c0109457:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c010945e:	00 
c010945f:	c7 04 24 eb de 10 c0 	movl   $0xc010deeb,(%esp)
c0109466:	e8 6a 79 ff ff       	call   c0100dd5 <__panic>
c010946b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010946e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0109473:	c9                   	leave  
c0109474:	c3                   	ret    

c0109475 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0109475:	55                   	push   %ebp
c0109476:	89 e5                	mov    %esp,%ebp
c0109478:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c010947b:	8b 45 08             	mov    0x8(%ebp),%eax
c010947e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109481:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0109488:	77 23                	ja     c01094ad <kva2page+0x38>
c010948a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010948d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109491:	c7 44 24 08 20 df 10 	movl   $0xc010df20,0x8(%esp)
c0109498:	c0 
c0109499:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01094a0:	00 
c01094a1:	c7 04 24 eb de 10 c0 	movl   $0xc010deeb,(%esp)
c01094a8:	e8 28 79 ff ff       	call   c0100dd5 <__panic>
c01094ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094b0:	05 00 00 00 40       	add    $0x40000000,%eax
c01094b5:	89 04 24             	mov    %eax,(%esp)
c01094b8:	e8 1f ff ff ff       	call   c01093dc <pa2page>
}
c01094bd:	c9                   	leave  
c01094be:	c3                   	ret    

c01094bf <mm_count_inc>:

static inline int
mm_count_inc(struct mm_struct *mm) {
c01094bf:	55                   	push   %ebp
c01094c0:	89 e5                	mov    %esp,%ebp
    mm->mm_count += 1;
c01094c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01094c5:	8b 40 18             	mov    0x18(%eax),%eax
c01094c8:	8d 50 01             	lea    0x1(%eax),%edx
c01094cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01094ce:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01094d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01094d4:	8b 40 18             	mov    0x18(%eax),%eax
}
c01094d7:	5d                   	pop    %ebp
c01094d8:	c3                   	ret    

c01094d9 <mm_count_dec>:

static inline int
mm_count_dec(struct mm_struct *mm) {
c01094d9:	55                   	push   %ebp
c01094da:	89 e5                	mov    %esp,%ebp
    mm->mm_count -= 1;
c01094dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01094df:	8b 40 18             	mov    0x18(%eax),%eax
c01094e2:	8d 50 ff             	lea    -0x1(%eax),%edx
c01094e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01094e8:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01094eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01094ee:	8b 40 18             	mov    0x18(%eax),%eax
}
c01094f1:	5d                   	pop    %ebp
c01094f2:	c3                   	ret    

c01094f3 <lock_mm>:

static inline void
lock_mm(struct mm_struct *mm) {
c01094f3:	55                   	push   %ebp
c01094f4:	89 e5                	mov    %esp,%ebp
c01094f6:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c01094f9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01094fd:	74 0e                	je     c010950d <lock_mm+0x1a>
        lock(&(mm->mm_lock));
c01094ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0109502:	83 c0 1c             	add    $0x1c,%eax
c0109505:	89 04 24             	mov    %eax,(%esp)
c0109508:	e8 4c fe ff ff       	call   c0109359 <lock>
    }
}
c010950d:	c9                   	leave  
c010950e:	c3                   	ret    

c010950f <unlock_mm>:

static inline void
unlock_mm(struct mm_struct *mm) {
c010950f:	55                   	push   %ebp
c0109510:	89 e5                	mov    %esp,%ebp
c0109512:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109515:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109519:	74 0e                	je     c0109529 <unlock_mm+0x1a>
        unlock(&(mm->mm_lock));
c010951b:	8b 45 08             	mov    0x8(%ebp),%eax
c010951e:	83 c0 1c             	add    $0x1c,%eax
c0109521:	89 04 24             	mov    %eax,(%esp)
c0109524:	e8 4e fe ff ff       	call   c0109377 <unlock>
    }
}
c0109529:	c9                   	leave  
c010952a:	c3                   	ret    

c010952b <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c010952b:	55                   	push   %ebp
c010952c:	89 e5                	mov    %esp,%ebp
c010952e:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0109531:	c7 04 24 7c 00 00 00 	movl   $0x7c,(%esp)
c0109538:	e8 b5 b6 ff ff       	call   c0104bf2 <kmalloc>
c010953d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0109540:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109544:	0f 84 cd 00 00 00    	je     c0109617 <alloc_proc+0xec>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
c010954a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010954d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c0109553:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109556:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c010955d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109560:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c0109567:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010956a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c0109571:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109574:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c010957b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010957e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c0109585:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109588:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c010958f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109592:	83 c0 1c             	add    $0x1c,%eax
c0109595:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c010959c:	00 
c010959d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01095a4:	00 
c01095a5:	89 04 24             	mov    %eax,(%esp)
c01095a8:	e8 55 27 00 00       	call   c010bd02 <memset>
        proc->tf = NULL;
c01095ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095b0:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c01095b7:	8b 15 c8 ef 19 c0    	mov    0xc019efc8,%edx
c01095bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095c0:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c01095c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095c6:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c01095cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095d0:	83 c0 48             	add    $0x48,%eax
c01095d3:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01095da:	00 
c01095db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01095e2:	00 
c01095e3:	89 04 24             	mov    %eax,(%esp)
c01095e6:	e8 17 27 00 00       	call   c010bd02 <memset>
    /*
     * below fields(add in LAB5) in proc_struct need to be initialized	
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
	 */
        proc->wait_state = 0;
c01095eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095ee:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
        proc->cptr = proc->yptr = proc->optr = NULL;
c01095f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095f8:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
c01095ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109602:	8b 50 78             	mov    0x78(%eax),%edx
c0109605:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109608:	89 50 74             	mov    %edx,0x74(%eax)
c010960b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010960e:	8b 50 74             	mov    0x74(%eax),%edx
c0109611:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109614:	89 50 70             	mov    %edx,0x70(%eax)
    }
    return proc;
c0109617:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010961a:	c9                   	leave  
c010961b:	c3                   	ret    

c010961c <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c010961c:	55                   	push   %ebp
c010961d:	89 e5                	mov    %esp,%ebp
c010961f:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0109622:	8b 45 08             	mov    0x8(%ebp),%eax
c0109625:	83 c0 48             	add    $0x48,%eax
c0109628:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010962f:	00 
c0109630:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109637:	00 
c0109638:	89 04 24             	mov    %eax,(%esp)
c010963b:	e8 c2 26 00 00       	call   c010bd02 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0109640:	8b 45 08             	mov    0x8(%ebp),%eax
c0109643:	8d 50 48             	lea    0x48(%eax),%edx
c0109646:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c010964d:	00 
c010964e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109651:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109655:	89 14 24             	mov    %edx,(%esp)
c0109658:	e8 87 27 00 00       	call   c010bde4 <memcpy>
}
c010965d:	c9                   	leave  
c010965e:	c3                   	ret    

c010965f <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c010965f:	55                   	push   %ebp
c0109660:	89 e5                	mov    %esp,%ebp
c0109662:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0109665:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010966c:	00 
c010966d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109674:	00 
c0109675:	c7 04 24 a4 ef 19 c0 	movl   $0xc019efa4,(%esp)
c010967c:	e8 81 26 00 00       	call   c010bd02 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0109681:	8b 45 08             	mov    0x8(%ebp),%eax
c0109684:	83 c0 48             	add    $0x48,%eax
c0109687:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c010968e:	00 
c010968f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109693:	c7 04 24 a4 ef 19 c0 	movl   $0xc019efa4,(%esp)
c010969a:	e8 45 27 00 00       	call   c010bde4 <memcpy>
}
c010969f:	c9                   	leave  
c01096a0:	c3                   	ret    

c01096a1 <set_links>:

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
c01096a1:	55                   	push   %ebp
c01096a2:	89 e5                	mov    %esp,%ebp
c01096a4:	83 ec 20             	sub    $0x20,%esp
    list_add(&proc_list, &(proc->list_link));
c01096a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01096aa:	83 c0 58             	add    $0x58,%eax
c01096ad:	c7 45 fc b0 f0 19 c0 	movl   $0xc019f0b0,-0x4(%ebp)
c01096b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01096b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01096ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01096bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01096c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01096c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096c6:	8b 40 04             	mov    0x4(%eax),%eax
c01096c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01096cc:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01096cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01096d2:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01096d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01096d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01096db:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01096de:	89 10                	mov    %edx,(%eax)
c01096e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01096e3:	8b 10                	mov    (%eax),%edx
c01096e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01096e8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01096eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01096ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01096f1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01096f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01096f7:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01096fa:	89 10                	mov    %edx,(%eax)
    proc->yptr = NULL;
c01096fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01096ff:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    if ((proc->optr = proc->parent->cptr) != NULL) {
c0109706:	8b 45 08             	mov    0x8(%ebp),%eax
c0109709:	8b 40 14             	mov    0x14(%eax),%eax
c010970c:	8b 50 70             	mov    0x70(%eax),%edx
c010970f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109712:	89 50 78             	mov    %edx,0x78(%eax)
c0109715:	8b 45 08             	mov    0x8(%ebp),%eax
c0109718:	8b 40 78             	mov    0x78(%eax),%eax
c010971b:	85 c0                	test   %eax,%eax
c010971d:	74 0c                	je     c010972b <set_links+0x8a>
        proc->optr->yptr = proc;
c010971f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109722:	8b 40 78             	mov    0x78(%eax),%eax
c0109725:	8b 55 08             	mov    0x8(%ebp),%edx
c0109728:	89 50 74             	mov    %edx,0x74(%eax)
    }
    proc->parent->cptr = proc;
c010972b:	8b 45 08             	mov    0x8(%ebp),%eax
c010972e:	8b 40 14             	mov    0x14(%eax),%eax
c0109731:	8b 55 08             	mov    0x8(%ebp),%edx
c0109734:	89 50 70             	mov    %edx,0x70(%eax)
    nr_process ++;
c0109737:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c010973c:	83 c0 01             	add    $0x1,%eax
c010973f:	a3 a0 ef 19 c0       	mov    %eax,0xc019efa0
}
c0109744:	c9                   	leave  
c0109745:	c3                   	ret    

c0109746 <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
c0109746:	55                   	push   %ebp
c0109747:	89 e5                	mov    %esp,%ebp
c0109749:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c010974c:	8b 45 08             	mov    0x8(%ebp),%eax
c010974f:	83 c0 58             	add    $0x58,%eax
c0109752:	89 45 fc             	mov    %eax,-0x4(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0109755:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109758:	8b 40 04             	mov    0x4(%eax),%eax
c010975b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010975e:	8b 12                	mov    (%edx),%edx
c0109760:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109763:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0109766:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109769:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010976c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010976f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109772:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109775:	89 10                	mov    %edx,(%eax)
    if (proc->optr != NULL) {
c0109777:	8b 45 08             	mov    0x8(%ebp),%eax
c010977a:	8b 40 78             	mov    0x78(%eax),%eax
c010977d:	85 c0                	test   %eax,%eax
c010977f:	74 0f                	je     c0109790 <remove_links+0x4a>
        proc->optr->yptr = proc->yptr;
c0109781:	8b 45 08             	mov    0x8(%ebp),%eax
c0109784:	8b 40 78             	mov    0x78(%eax),%eax
c0109787:	8b 55 08             	mov    0x8(%ebp),%edx
c010978a:	8b 52 74             	mov    0x74(%edx),%edx
c010978d:	89 50 74             	mov    %edx,0x74(%eax)
    }
    if (proc->yptr != NULL) {
c0109790:	8b 45 08             	mov    0x8(%ebp),%eax
c0109793:	8b 40 74             	mov    0x74(%eax),%eax
c0109796:	85 c0                	test   %eax,%eax
c0109798:	74 11                	je     c01097ab <remove_links+0x65>
        proc->yptr->optr = proc->optr;
c010979a:	8b 45 08             	mov    0x8(%ebp),%eax
c010979d:	8b 40 74             	mov    0x74(%eax),%eax
c01097a0:	8b 55 08             	mov    0x8(%ebp),%edx
c01097a3:	8b 52 78             	mov    0x78(%edx),%edx
c01097a6:	89 50 78             	mov    %edx,0x78(%eax)
c01097a9:	eb 0f                	jmp    c01097ba <remove_links+0x74>
    }
    else {
       proc->parent->cptr = proc->optr;
c01097ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01097ae:	8b 40 14             	mov    0x14(%eax),%eax
c01097b1:	8b 55 08             	mov    0x8(%ebp),%edx
c01097b4:	8b 52 78             	mov    0x78(%edx),%edx
c01097b7:	89 50 70             	mov    %edx,0x70(%eax)
    }
    nr_process --;
c01097ba:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c01097bf:	83 e8 01             	sub    $0x1,%eax
c01097c2:	a3 a0 ef 19 c0       	mov    %eax,0xc019efa0
}
c01097c7:	c9                   	leave  
c01097c8:	c3                   	ret    

c01097c9 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c01097c9:	55                   	push   %ebp
c01097ca:	89 e5                	mov    %esp,%ebp
c01097cc:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c01097cf:	c7 45 f8 b0 f0 19 c0 	movl   $0xc019f0b0,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c01097d6:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c01097db:	83 c0 01             	add    $0x1,%eax
c01097de:	a3 80 aa 12 c0       	mov    %eax,0xc012aa80
c01097e3:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c01097e8:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01097ed:	7e 0c                	jle    c01097fb <get_pid+0x32>
        last_pid = 1;
c01097ef:	c7 05 80 aa 12 c0 01 	movl   $0x1,0xc012aa80
c01097f6:	00 00 00 
        goto inside;
c01097f9:	eb 13                	jmp    c010980e <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c01097fb:	8b 15 80 aa 12 c0    	mov    0xc012aa80,%edx
c0109801:	a1 84 aa 12 c0       	mov    0xc012aa84,%eax
c0109806:	39 c2                	cmp    %eax,%edx
c0109808:	0f 8c ac 00 00 00    	jl     c01098ba <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c010980e:	c7 05 84 aa 12 c0 00 	movl   $0x2000,0xc012aa84
c0109815:	20 00 00 
    repeat:
        le = list;
c0109818:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010981b:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c010981e:	eb 7f                	jmp    c010989f <get_pid+0xd6>
            proc = le2proc(le, list_link);
c0109820:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109823:	83 e8 58             	sub    $0x58,%eax
c0109826:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0109829:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010982c:	8b 50 04             	mov    0x4(%eax),%edx
c010982f:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c0109834:	39 c2                	cmp    %eax,%edx
c0109836:	75 3e                	jne    c0109876 <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c0109838:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c010983d:	83 c0 01             	add    $0x1,%eax
c0109840:	a3 80 aa 12 c0       	mov    %eax,0xc012aa80
c0109845:	8b 15 80 aa 12 c0    	mov    0xc012aa80,%edx
c010984b:	a1 84 aa 12 c0       	mov    0xc012aa84,%eax
c0109850:	39 c2                	cmp    %eax,%edx
c0109852:	7c 4b                	jl     c010989f <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c0109854:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c0109859:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c010985e:	7e 0a                	jle    c010986a <get_pid+0xa1>
                        last_pid = 1;
c0109860:	c7 05 80 aa 12 c0 01 	movl   $0x1,0xc012aa80
c0109867:	00 00 00 
                    }
                    next_safe = MAX_PID;
c010986a:	c7 05 84 aa 12 c0 00 	movl   $0x2000,0xc012aa84
c0109871:	20 00 00 
                    goto repeat;
c0109874:	eb a2                	jmp    c0109818 <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0109876:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109879:	8b 50 04             	mov    0x4(%eax),%edx
c010987c:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c0109881:	39 c2                	cmp    %eax,%edx
c0109883:	7e 1a                	jle    c010989f <get_pid+0xd6>
c0109885:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109888:	8b 50 04             	mov    0x4(%eax),%edx
c010988b:	a1 84 aa 12 c0       	mov    0xc012aa84,%eax
c0109890:	39 c2                	cmp    %eax,%edx
c0109892:	7d 0b                	jge    c010989f <get_pid+0xd6>
                next_safe = proc->pid;
c0109894:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109897:	8b 40 04             	mov    0x4(%eax),%eax
c010989a:	a3 84 aa 12 c0       	mov    %eax,0xc012aa84
c010989f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01098a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01098a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01098a8:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c01098ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01098ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01098b1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01098b4:	0f 85 66 ff ff ff    	jne    c0109820 <get_pid+0x57>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c01098ba:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
}
c01098bf:	c9                   	leave  
c01098c0:	c3                   	ret    

c01098c1 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c01098c1:	55                   	push   %ebp
c01098c2:	89 e5                	mov    %esp,%ebp
c01098c4:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c01098c7:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c01098cc:	39 45 08             	cmp    %eax,0x8(%ebp)
c01098cf:	74 63                	je     c0109934 <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c01098d1:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c01098d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01098d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01098dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c01098df:	e8 15 fa ff ff       	call   c01092f9 <__intr_save>
c01098e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c01098e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01098ea:	a3 88 cf 19 c0       	mov    %eax,0xc019cf88
            load_esp0(next->kstack + KSTACKSIZE);
c01098ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01098f2:	8b 40 0c             	mov    0xc(%eax),%eax
c01098f5:	05 00 20 00 00       	add    $0x2000,%eax
c01098fa:	89 04 24             	mov    %eax,(%esp)
c01098fd:	e8 17 b6 ff ff       	call   c0104f19 <load_esp0>
            lcr3(next->cr3);
c0109902:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109905:	8b 40 40             	mov    0x40(%eax),%eax
c0109908:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010990b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010990e:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c0109911:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109914:	8d 50 1c             	lea    0x1c(%eax),%edx
c0109917:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010991a:	83 c0 1c             	add    $0x1c,%eax
c010991d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109921:	89 04 24             	mov    %eax,(%esp)
c0109924:	e8 76 15 00 00       	call   c010ae9f <switch_to>
        }
        local_intr_restore(intr_flag);
c0109929:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010992c:	89 04 24             	mov    %eax,(%esp)
c010992f:	e8 ef f9 ff ff       	call   c0109323 <__intr_restore>
    }
}
c0109934:	c9                   	leave  
c0109935:	c3                   	ret    

c0109936 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0109936:	55                   	push   %ebp
c0109937:	89 e5                	mov    %esp,%ebp
c0109939:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c010993c:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0109941:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109944:	89 04 24             	mov    %eax,(%esp)
c0109947:	e8 2d 91 ff ff       	call   c0102a79 <forkrets>
}
c010994c:	c9                   	leave  
c010994d:	c3                   	ret    

c010994e <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c010994e:	55                   	push   %ebp
c010994f:	89 e5                	mov    %esp,%ebp
c0109951:	53                   	push   %ebx
c0109952:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0109955:	8b 45 08             	mov    0x8(%ebp),%eax
c0109958:	8d 58 60             	lea    0x60(%eax),%ebx
c010995b:	8b 45 08             	mov    0x8(%ebp),%eax
c010995e:	8b 40 04             	mov    0x4(%eax),%eax
c0109961:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109968:	00 
c0109969:	89 04 24             	mov    %eax,(%esp)
c010996c:	e8 e4 18 00 00       	call   c010b255 <hash32>
c0109971:	c1 e0 03             	shl    $0x3,%eax
c0109974:	05 a0 cf 19 c0       	add    $0xc019cfa0,%eax
c0109979:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010997c:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c010997f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109982:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109985:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109988:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010998b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010998e:	8b 40 04             	mov    0x4(%eax),%eax
c0109991:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109994:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109997:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010999a:	89 55 e0             	mov    %edx,-0x20(%ebp)
c010999d:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01099a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01099a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01099a6:	89 10                	mov    %edx,(%eax)
c01099a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01099ab:	8b 10                	mov    (%eax),%edx
c01099ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01099b0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01099b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01099b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01099b9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01099bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01099bf:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01099c2:	89 10                	mov    %edx,(%eax)
}
c01099c4:	83 c4 34             	add    $0x34,%esp
c01099c7:	5b                   	pop    %ebx
c01099c8:	5d                   	pop    %ebp
c01099c9:	c3                   	ret    

c01099ca <unhash_proc>:

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc) {
c01099ca:	55                   	push   %ebp
c01099cb:	89 e5                	mov    %esp,%ebp
c01099cd:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->hash_link));
c01099d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01099d3:	83 c0 60             	add    $0x60,%eax
c01099d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01099d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01099dc:	8b 40 04             	mov    0x4(%eax),%eax
c01099df:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01099e2:	8b 12                	mov    (%edx),%edx
c01099e4:	89 55 f8             	mov    %edx,-0x8(%ebp)
c01099e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01099ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01099ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01099f0:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01099f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01099f6:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01099f9:	89 10                	mov    %edx,(%eax)
}
c01099fb:	c9                   	leave  
c01099fc:	c3                   	ret    

c01099fd <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c01099fd:	55                   	push   %ebp
c01099fe:	89 e5                	mov    %esp,%ebp
c0109a00:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0109a03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109a07:	7e 5f                	jle    c0109a68 <find_proc+0x6b>
c0109a09:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109a10:	7f 56                	jg     c0109a68 <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109a12:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a15:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109a1c:	00 
c0109a1d:	89 04 24             	mov    %eax,(%esp)
c0109a20:	e8 30 18 00 00       	call   c010b255 <hash32>
c0109a25:	c1 e0 03             	shl    $0x3,%eax
c0109a28:	05 a0 cf 19 c0       	add    $0xc019cfa0,%eax
c0109a2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a33:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0109a36:	eb 19                	jmp    c0109a51 <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0109a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a3b:	83 e8 60             	sub    $0x60,%eax
c0109a3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109a41:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a44:	8b 40 04             	mov    0x4(%eax),%eax
c0109a47:	3b 45 08             	cmp    0x8(%ebp),%eax
c0109a4a:	75 05                	jne    c0109a51 <find_proc+0x54>
                return proc;
c0109a4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a4f:	eb 1c                	jmp    c0109a6d <find_proc+0x70>
c0109a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a54:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0109a57:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109a5a:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
c0109a5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a63:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0109a66:	75 d0                	jne    c0109a38 <find_proc+0x3b>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c0109a68:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109a6d:	c9                   	leave  
c0109a6e:	c3                   	ret    

c0109a6f <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0109a6f:	55                   	push   %ebp
c0109a70:	89 e5                	mov    %esp,%ebp
c0109a72:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0109a75:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0109a7c:	00 
c0109a7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109a84:	00 
c0109a85:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109a88:	89 04 24             	mov    %eax,(%esp)
c0109a8b:	e8 72 22 00 00       	call   c010bd02 <memset>
    tf.tf_cs = KERNEL_CS;
c0109a90:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109a96:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109a9c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109aa0:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109aa4:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109aa8:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109aac:	8b 45 08             	mov    0x8(%ebp),%eax
c0109aaf:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109ab2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ab5:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109ab8:	b8 b0 92 10 c0       	mov    $0xc01092b0,%eax
c0109abd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109ac0:	8b 45 10             	mov    0x10(%ebp),%eax
c0109ac3:	80 cc 01             	or     $0x1,%ah
c0109ac6:	89 c2                	mov    %eax,%edx
c0109ac8:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109acb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109acf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109ad6:	00 
c0109ad7:	89 14 24             	mov    %edx,(%esp)
c0109ada:	e8 25 03 00 00       	call   c0109e04 <do_fork>
}
c0109adf:	c9                   	leave  
c0109ae0:	c3                   	ret    

c0109ae1 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109ae1:	55                   	push   %ebp
c0109ae2:	89 e5                	mov    %esp,%ebp
c0109ae4:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109ae7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0109aee:	e8 74 b5 ff ff       	call   c0105067 <alloc_pages>
c0109af3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109af6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109afa:	74 1a                	je     c0109b16 <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0109afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109aff:	89 04 24             	mov    %eax,(%esp)
c0109b02:	e8 1a f9 ff ff       	call   c0109421 <page2kva>
c0109b07:	89 c2                	mov    %eax,%edx
c0109b09:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b0c:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109b0f:	b8 00 00 00 00       	mov    $0x0,%eax
c0109b14:	eb 05                	jmp    c0109b1b <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0109b16:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109b1b:	c9                   	leave  
c0109b1c:	c3                   	ret    

c0109b1d <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109b1d:	55                   	push   %ebp
c0109b1e:	89 e5                	mov    %esp,%ebp
c0109b20:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0109b23:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b26:	8b 40 0c             	mov    0xc(%eax),%eax
c0109b29:	89 04 24             	mov    %eax,(%esp)
c0109b2c:	e8 44 f9 ff ff       	call   c0109475 <kva2page>
c0109b31:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109b38:	00 
c0109b39:	89 04 24             	mov    %eax,(%esp)
c0109b3c:	e8 91 b5 ff ff       	call   c01050d2 <free_pages>
}
c0109b41:	c9                   	leave  
c0109b42:	c3                   	ret    

c0109b43 <setup_pgdir>:

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm) {
c0109b43:	55                   	push   %ebp
c0109b44:	89 e5                	mov    %esp,%ebp
c0109b46:	83 ec 28             	sub    $0x28,%esp
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
c0109b49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109b50:	e8 12 b5 ff ff       	call   c0105067 <alloc_pages>
c0109b55:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109b58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109b5c:	75 0a                	jne    c0109b68 <setup_pgdir+0x25>
        return -E_NO_MEM;
c0109b5e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0109b63:	e9 80 00 00 00       	jmp    c0109be8 <setup_pgdir+0xa5>
    }
    pde_t *pgdir = page2kva(page);
c0109b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b6b:	89 04 24             	mov    %eax,(%esp)
c0109b6e:	e8 ae f8 ff ff       	call   c0109421 <page2kva>
c0109b73:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memcpy(pgdir, boot_pgdir, PGSIZE);
c0109b76:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0109b7b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0109b82:	00 
c0109b83:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b8a:	89 04 24             	mov    %eax,(%esp)
c0109b8d:	e8 52 22 00 00       	call   c010bde4 <memcpy>
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
c0109b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b95:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0109b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109ba1:	81 7d ec ff ff ff bf 	cmpl   $0xbfffffff,-0x14(%ebp)
c0109ba8:	77 23                	ja     c0109bcd <setup_pgdir+0x8a>
c0109baa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109bad:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109bb1:	c7 44 24 08 20 df 10 	movl   $0xc010df20,0x8(%esp)
c0109bb8:	c0 
c0109bb9:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0109bc0:	00 
c0109bc1:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c0109bc8:	e8 08 72 ff ff       	call   c0100dd5 <__panic>
c0109bcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109bd0:	05 00 00 00 40       	add    $0x40000000,%eax
c0109bd5:	83 c8 03             	or     $0x3,%eax
c0109bd8:	89 02                	mov    %eax,(%edx)
    mm->pgdir = pgdir;
c0109bda:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bdd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109be0:	89 50 0c             	mov    %edx,0xc(%eax)
    return 0;
c0109be3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109be8:	c9                   	leave  
c0109be9:	c3                   	ret    

c0109bea <put_pgdir>:

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm) {
c0109bea:	55                   	push   %ebp
c0109beb:	89 e5                	mov    %esp,%ebp
c0109bed:	83 ec 18             	sub    $0x18,%esp
    free_page(kva2page(mm->pgdir));
c0109bf0:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bf3:	8b 40 0c             	mov    0xc(%eax),%eax
c0109bf6:	89 04 24             	mov    %eax,(%esp)
c0109bf9:	e8 77 f8 ff ff       	call   c0109475 <kva2page>
c0109bfe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109c05:	00 
c0109c06:	89 04 24             	mov    %eax,(%esp)
c0109c09:	e8 c4 b4 ff ff       	call   c01050d2 <free_pages>
}
c0109c0e:	c9                   	leave  
c0109c0f:	c3                   	ret    

c0109c10 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109c10:	55                   	push   %ebp
c0109c11:	89 e5                	mov    %esp,%ebp
c0109c13:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm, *oldmm = current->mm;
c0109c16:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0109c1b:	8b 40 18             	mov    0x18(%eax),%eax
c0109c1e:	89 45 ec             	mov    %eax,-0x14(%ebp)

    /* current is a kernel thread */
    if (oldmm == NULL) {
c0109c21:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109c25:	75 0a                	jne    c0109c31 <copy_mm+0x21>
        return 0;
c0109c27:	b8 00 00 00 00       	mov    $0x0,%eax
c0109c2c:	e9 f9 00 00 00       	jmp    c0109d2a <copy_mm+0x11a>
    }
    if (clone_flags & CLONE_VM) {
c0109c31:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c34:	25 00 01 00 00       	and    $0x100,%eax
c0109c39:	85 c0                	test   %eax,%eax
c0109c3b:	74 08                	je     c0109c45 <copy_mm+0x35>
        mm = oldmm;
c0109c3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c40:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto good_mm;
c0109c43:	eb 78                	jmp    c0109cbd <copy_mm+0xad>
    }

    int ret = -E_NO_MEM;
c0109c45:	c7 45 f0 fc ff ff ff 	movl   $0xfffffffc,-0x10(%ebp)
    if ((mm = mm_create()) == NULL) {
c0109c4c:	e8 b5 e2 ff ff       	call   c0107f06 <mm_create>
c0109c51:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109c58:	75 05                	jne    c0109c5f <copy_mm+0x4f>
        goto bad_mm;
c0109c5a:	e9 c8 00 00 00       	jmp    c0109d27 <copy_mm+0x117>
    }
    if (setup_pgdir(mm) != 0) {
c0109c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c62:	89 04 24             	mov    %eax,(%esp)
c0109c65:	e8 d9 fe ff ff       	call   c0109b43 <setup_pgdir>
c0109c6a:	85 c0                	test   %eax,%eax
c0109c6c:	74 05                	je     c0109c73 <copy_mm+0x63>
        goto bad_pgdir_cleanup_mm;
c0109c6e:	e9 a9 00 00 00       	jmp    c0109d1c <copy_mm+0x10c>
    }

    lock_mm(oldmm);
c0109c73:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c76:	89 04 24             	mov    %eax,(%esp)
c0109c79:	e8 75 f8 ff ff       	call   c01094f3 <lock_mm>
    {
        ret = dup_mmap(mm, oldmm);
c0109c7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c81:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c88:	89 04 24             	mov    %eax,(%esp)
c0109c8b:	e8 8d e7 ff ff       	call   c010841d <dup_mmap>
c0109c90:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    unlock_mm(oldmm);
c0109c93:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c96:	89 04 24             	mov    %eax,(%esp)
c0109c99:	e8 71 f8 ff ff       	call   c010950f <unlock_mm>

    if (ret != 0) {
c0109c9e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109ca2:	74 19                	je     c0109cbd <copy_mm+0xad>
        goto bad_dup_cleanup_mmap;
c0109ca4:	90                   	nop
    mm_count_inc(mm);
    proc->mm = mm;
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
c0109ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ca8:	89 04 24             	mov    %eax,(%esp)
c0109cab:	e8 6e e8 ff ff       	call   c010851e <exit_mmap>
    put_pgdir(mm);
c0109cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cb3:	89 04 24             	mov    %eax,(%esp)
c0109cb6:	e8 2f ff ff ff       	call   c0109bea <put_pgdir>
c0109cbb:	eb 5f                	jmp    c0109d1c <copy_mm+0x10c>
    if (ret != 0) {
        goto bad_dup_cleanup_mmap;
    }

good_mm:
    mm_count_inc(mm);
c0109cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cc0:	89 04 24             	mov    %eax,(%esp)
c0109cc3:	e8 f7 f7 ff ff       	call   c01094bf <mm_count_inc>
    proc->mm = mm;
c0109cc8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ccb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109cce:	89 50 18             	mov    %edx,0x18(%eax)
    proc->cr3 = PADDR(mm->pgdir);
c0109cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cd4:	8b 40 0c             	mov    0xc(%eax),%eax
c0109cd7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109cda:	81 7d e8 ff ff ff bf 	cmpl   $0xbfffffff,-0x18(%ebp)
c0109ce1:	77 23                	ja     c0109d06 <copy_mm+0xf6>
c0109ce3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109ce6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109cea:	c7 44 24 08 20 df 10 	movl   $0xc010df20,0x8(%esp)
c0109cf1:	c0 
c0109cf2:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
c0109cf9:	00 
c0109cfa:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c0109d01:	e8 cf 70 ff ff       	call   c0100dd5 <__panic>
c0109d06:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109d09:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109d0f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d12:	89 50 40             	mov    %edx,0x40(%eax)
    return 0;
c0109d15:	b8 00 00 00 00       	mov    $0x0,%eax
c0109d1a:	eb 0e                	jmp    c0109d2a <copy_mm+0x11a>
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c0109d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d1f:	89 04 24             	mov    %eax,(%esp)
c0109d22:	e8 38 e5 ff ff       	call   c010825f <mm_destroy>
bad_mm:
    return ret;
c0109d27:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0109d2a:	c9                   	leave  
c0109d2b:	c3                   	ret    

c0109d2c <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0109d2c:	55                   	push   %ebp
c0109d2d:	89 e5                	mov    %esp,%ebp
c0109d2f:	57                   	push   %edi
c0109d30:	56                   	push   %esi
c0109d31:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0109d32:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d35:	8b 40 0c             	mov    0xc(%eax),%eax
c0109d38:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0109d3d:	89 c2                	mov    %eax,%edx
c0109d3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d42:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0109d45:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d48:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109d4b:	8b 55 10             	mov    0x10(%ebp),%edx
c0109d4e:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0109d53:	89 c1                	mov    %eax,%ecx
c0109d55:	83 e1 01             	and    $0x1,%ecx
c0109d58:	85 c9                	test   %ecx,%ecx
c0109d5a:	74 0e                	je     c0109d6a <copy_thread+0x3e>
c0109d5c:	0f b6 0a             	movzbl (%edx),%ecx
c0109d5f:	88 08                	mov    %cl,(%eax)
c0109d61:	83 c0 01             	add    $0x1,%eax
c0109d64:	83 c2 01             	add    $0x1,%edx
c0109d67:	83 eb 01             	sub    $0x1,%ebx
c0109d6a:	89 c1                	mov    %eax,%ecx
c0109d6c:	83 e1 02             	and    $0x2,%ecx
c0109d6f:	85 c9                	test   %ecx,%ecx
c0109d71:	74 0f                	je     c0109d82 <copy_thread+0x56>
c0109d73:	0f b7 0a             	movzwl (%edx),%ecx
c0109d76:	66 89 08             	mov    %cx,(%eax)
c0109d79:	83 c0 02             	add    $0x2,%eax
c0109d7c:	83 c2 02             	add    $0x2,%edx
c0109d7f:	83 eb 02             	sub    $0x2,%ebx
c0109d82:	89 d9                	mov    %ebx,%ecx
c0109d84:	c1 e9 02             	shr    $0x2,%ecx
c0109d87:	89 c7                	mov    %eax,%edi
c0109d89:	89 d6                	mov    %edx,%esi
c0109d8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109d8d:	89 f2                	mov    %esi,%edx
c0109d8f:	89 f8                	mov    %edi,%eax
c0109d91:	b9 00 00 00 00       	mov    $0x0,%ecx
c0109d96:	89 de                	mov    %ebx,%esi
c0109d98:	83 e6 02             	and    $0x2,%esi
c0109d9b:	85 f6                	test   %esi,%esi
c0109d9d:	74 0b                	je     c0109daa <copy_thread+0x7e>
c0109d9f:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0109da3:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0109da7:	83 c1 02             	add    $0x2,%ecx
c0109daa:	83 e3 01             	and    $0x1,%ebx
c0109dad:	85 db                	test   %ebx,%ebx
c0109daf:	74 07                	je     c0109db8 <copy_thread+0x8c>
c0109db1:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0109db5:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0109db8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dbb:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109dbe:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0109dc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dc8:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109dcb:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109dce:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0109dd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dd4:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109dd7:	8b 55 08             	mov    0x8(%ebp),%edx
c0109dda:	8b 52 3c             	mov    0x3c(%edx),%edx
c0109ddd:	8b 52 40             	mov    0x40(%edx),%edx
c0109de0:	80 ce 02             	or     $0x2,%dh
c0109de3:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0109de6:	ba 36 99 10 c0       	mov    $0xc0109936,%edx
c0109deb:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dee:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0109df1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109df4:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109df7:	89 c2                	mov    %eax,%edx
c0109df9:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dfc:	89 50 20             	mov    %edx,0x20(%eax)
}
c0109dff:	5b                   	pop    %ebx
c0109e00:	5e                   	pop    %esi
c0109e01:	5f                   	pop    %edi
c0109e02:	5d                   	pop    %ebp
c0109e03:	c3                   	ret    

c0109e04 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0109e04:	55                   	push   %ebp
c0109e05:	89 e5                	mov    %esp,%ebp
c0109e07:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_NO_FREE_PROC;
c0109e0a:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0109e11:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c0109e16:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0109e1b:	7e 05                	jle    c0109e22 <do_fork+0x1e>
        goto fork_out;
c0109e1d:	e9 fc 00 00 00       	jmp    c0109f1e <do_fork+0x11a>
    }
    ret = -E_NO_MEM;
c0109e22:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    *    -------------------
	*    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
	*    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
    */

    proc = alloc_proc();
c0109e29:	e8 fd f6 ff ff       	call   c010952b <alloc_proc>
c0109e2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (proc == NULL)
c0109e31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109e35:	75 05                	jne    c0109e3c <do_fork+0x38>
        goto fork_out;
c0109e37:	e9 e2 00 00 00       	jmp    c0109f1e <do_fork+0x11a>

    int ret2;
    ret2 = setup_kstack(proc);
c0109e3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e3f:	89 04 24             	mov    %eax,(%esp)
c0109e42:	e8 9a fc ff ff       	call   c0109ae1 <setup_kstack>
c0109e47:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (ret2 != 0)
c0109e4a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109e4e:	74 05                	je     c0109e55 <do_fork+0x51>
        goto bad_fork_cleanup_proc;
c0109e50:	e9 ce 00 00 00       	jmp    c0109f23 <do_fork+0x11f>

    ret2 = copy_mm(clone_flags, proc);
c0109e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e58:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109e5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e5f:	89 04 24             	mov    %eax,(%esp)
c0109e62:	e8 a9 fd ff ff       	call   c0109c10 <copy_mm>
c0109e67:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (ret2 != 0)
c0109e6a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109e6e:	74 11                	je     c0109e81 <do_fork+0x7d>
        goto bad_fork_cleanup_kstack;
c0109e70:	90                   	nop

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c0109e71:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e74:	89 04 24             	mov    %eax,(%esp)
c0109e77:	e8 a1 fc ff ff       	call   c0109b1d <put_kstack>
c0109e7c:	e9 a2 00 00 00       	jmp    c0109f23 <do_fork+0x11f>

    ret2 = copy_mm(clone_flags, proc);
    if (ret2 != 0)
        goto bad_fork_cleanup_kstack;

    copy_thread(proc, stack, tf);
c0109e81:	8b 45 10             	mov    0x10(%ebp),%eax
c0109e84:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109e88:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109e8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e92:	89 04 24             	mov    %eax,(%esp)
c0109e95:	e8 92 fe ff ff       	call   c0109d2c <copy_thread>

    bool intr_flag;
    local_intr_save(intr_flag);
c0109e9a:	e8 5a f4 ff ff       	call   c01092f9 <__intr_save>
c0109e9f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        proc->pid = get_pid();
c0109ea2:	e8 22 f9 ff ff       	call   c01097c9 <get_pid>
c0109ea7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109eaa:	89 42 04             	mov    %eax,0x4(%edx)
        proc->parent = current;
c0109ead:	8b 15 88 cf 19 c0    	mov    0xc019cf88,%edx
c0109eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109eb6:	89 50 14             	mov    %edx,0x14(%eax)
        assert(current->wait_state == 0);
c0109eb9:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0109ebe:	8b 40 6c             	mov    0x6c(%eax),%eax
c0109ec1:	85 c0                	test   %eax,%eax
c0109ec3:	74 24                	je     c0109ee9 <do_fork+0xe5>
c0109ec5:	c7 44 24 0c 58 df 10 	movl   $0xc010df58,0xc(%esp)
c0109ecc:	c0 
c0109ecd:	c7 44 24 08 71 df 10 	movl   $0xc010df71,0x8(%esp)
c0109ed4:	c0 
c0109ed5:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
c0109edc:	00 
c0109edd:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c0109ee4:	e8 ec 6e ff ff       	call   c0100dd5 <__panic>

        set_links(proc);
c0109ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109eec:	89 04 24             	mov    %eax,(%esp)
c0109eef:	e8 ad f7 ff ff       	call   c01096a1 <set_links>
        hash_proc(proc);
c0109ef4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ef7:	89 04 24             	mov    %eax,(%esp)
c0109efa:	e8 4f fa ff ff       	call   c010994e <hash_proc>
    }
    local_intr_restore(intr_flag);
c0109eff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109f02:	89 04 24             	mov    %eax,(%esp)
c0109f05:	e8 19 f4 ff ff       	call   c0109323 <__intr_restore>

    wakeup_proc(proc);
c0109f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f0d:	89 04 24             	mov    %eax,(%esp)
c0109f10:	e8 fe 0f 00 00       	call   c010af13 <wakeup_proc>

    ret = proc->pid;
c0109f15:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f18:	8b 40 04             	mov    0x4(%eax),%eax
c0109f1b:	89 45 f4             	mov    %eax,-0xc(%ebp)

fork_out:
    return ret;
c0109f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f21:	eb 0d                	jmp    c0109f30 <do_fork+0x12c>

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
c0109f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f26:	89 04 24             	mov    %eax,(%esp)
c0109f29:	e8 df ac ff ff       	call   c0104c0d <kfree>
    goto fork_out;
c0109f2e:	eb ee                	jmp    c0109f1e <do_fork+0x11a>
}
c0109f30:	c9                   	leave  
c0109f31:	c3                   	ret    

c0109f32 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c0109f32:	55                   	push   %ebp
c0109f33:	89 e5                	mov    %esp,%ebp
c0109f35:	83 ec 28             	sub    $0x28,%esp
    if (current == idleproc) {
c0109f38:	8b 15 88 cf 19 c0    	mov    0xc019cf88,%edx
c0109f3e:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c0109f43:	39 c2                	cmp    %eax,%edx
c0109f45:	75 1c                	jne    c0109f63 <do_exit+0x31>
        panic("idleproc exit.\n");
c0109f47:	c7 44 24 08 86 df 10 	movl   $0xc010df86,0x8(%esp)
c0109f4e:	c0 
c0109f4f:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
c0109f56:	00 
c0109f57:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c0109f5e:	e8 72 6e ff ff       	call   c0100dd5 <__panic>
    }
    if (current == initproc) {
c0109f63:	8b 15 88 cf 19 c0    	mov    0xc019cf88,%edx
c0109f69:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c0109f6e:	39 c2                	cmp    %eax,%edx
c0109f70:	75 1c                	jne    c0109f8e <do_exit+0x5c>
        panic("initproc exit.\n");
c0109f72:	c7 44 24 08 96 df 10 	movl   $0xc010df96,0x8(%esp)
c0109f79:	c0 
c0109f7a:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
c0109f81:	00 
c0109f82:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c0109f89:	e8 47 6e ff ff       	call   c0100dd5 <__panic>
    }
    
    struct mm_struct *mm = current->mm;
c0109f8e:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0109f93:	8b 40 18             	mov    0x18(%eax),%eax
c0109f96:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (mm != NULL) {
c0109f99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109f9d:	74 4a                	je     c0109fe9 <do_exit+0xb7>
        lcr3(boot_cr3);
c0109f9f:	a1 c8 ef 19 c0       	mov    0xc019efc8,%eax
c0109fa4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109fa7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109faa:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c0109fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fb0:	89 04 24             	mov    %eax,(%esp)
c0109fb3:	e8 21 f5 ff ff       	call   c01094d9 <mm_count_dec>
c0109fb8:	85 c0                	test   %eax,%eax
c0109fba:	75 21                	jne    c0109fdd <do_exit+0xab>
            exit_mmap(mm);
c0109fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fbf:	89 04 24             	mov    %eax,(%esp)
c0109fc2:	e8 57 e5 ff ff       	call   c010851e <exit_mmap>
            put_pgdir(mm);
c0109fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fca:	89 04 24             	mov    %eax,(%esp)
c0109fcd:	e8 18 fc ff ff       	call   c0109bea <put_pgdir>
            mm_destroy(mm);
c0109fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fd5:	89 04 24             	mov    %eax,(%esp)
c0109fd8:	e8 82 e2 ff ff       	call   c010825f <mm_destroy>
        }
        current->mm = NULL;
c0109fdd:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0109fe2:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    current->state = PROC_ZOMBIE;
c0109fe9:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0109fee:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
    current->exit_code = error_code;
c0109ff4:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0109ff9:	8b 55 08             	mov    0x8(%ebp),%edx
c0109ffc:	89 50 68             	mov    %edx,0x68(%eax)
    
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c0109fff:	e8 f5 f2 ff ff       	call   c01092f9 <__intr_save>
c010a004:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        proc = current->parent;
c010a007:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a00c:	8b 40 14             	mov    0x14(%eax),%eax
c010a00f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (proc->wait_state == WT_CHILD) {
c010a012:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a015:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a018:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a01d:	75 10                	jne    c010a02f <do_exit+0xfd>
            wakeup_proc(proc);
c010a01f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a022:	89 04 24             	mov    %eax,(%esp)
c010a025:	e8 e9 0e 00 00       	call   c010af13 <wakeup_proc>
        }
        while (current->cptr != NULL) {
c010a02a:	e9 8b 00 00 00       	jmp    c010a0ba <do_exit+0x188>
c010a02f:	e9 86 00 00 00       	jmp    c010a0ba <do_exit+0x188>
            proc = current->cptr;
c010a034:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a039:	8b 40 70             	mov    0x70(%eax),%eax
c010a03c:	89 45 ec             	mov    %eax,-0x14(%ebp)
            current->cptr = proc->optr;
c010a03f:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a044:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a047:	8b 52 78             	mov    0x78(%edx),%edx
c010a04a:	89 50 70             	mov    %edx,0x70(%eax)
    
            proc->yptr = NULL;
c010a04d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a050:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
            if ((proc->optr = initproc->cptr) != NULL) {
c010a057:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010a05c:	8b 50 70             	mov    0x70(%eax),%edx
c010a05f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a062:	89 50 78             	mov    %edx,0x78(%eax)
c010a065:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a068:	8b 40 78             	mov    0x78(%eax),%eax
c010a06b:	85 c0                	test   %eax,%eax
c010a06d:	74 0e                	je     c010a07d <do_exit+0x14b>
                initproc->cptr->yptr = proc;
c010a06f:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010a074:	8b 40 70             	mov    0x70(%eax),%eax
c010a077:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a07a:	89 50 74             	mov    %edx,0x74(%eax)
            }
            proc->parent = initproc;
c010a07d:	8b 15 84 cf 19 c0    	mov    0xc019cf84,%edx
c010a083:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a086:	89 50 14             	mov    %edx,0x14(%eax)
            initproc->cptr = proc;
c010a089:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010a08e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a091:	89 50 70             	mov    %edx,0x70(%eax)
            if (proc->state == PROC_ZOMBIE) {
c010a094:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a097:	8b 00                	mov    (%eax),%eax
c010a099:	83 f8 03             	cmp    $0x3,%eax
c010a09c:	75 1c                	jne    c010a0ba <do_exit+0x188>
                if (initproc->wait_state == WT_CHILD) {
c010a09e:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010a0a3:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a0a6:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a0ab:	75 0d                	jne    c010a0ba <do_exit+0x188>
                    wakeup_proc(initproc);
c010a0ad:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010a0b2:	89 04 24             	mov    %eax,(%esp)
c010a0b5:	e8 59 0e 00 00       	call   c010af13 <wakeup_proc>
    {
        proc = current->parent;
        if (proc->wait_state == WT_CHILD) {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL) {
c010a0ba:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a0bf:	8b 40 70             	mov    0x70(%eax),%eax
c010a0c2:	85 c0                	test   %eax,%eax
c010a0c4:	0f 85 6a ff ff ff    	jne    c010a034 <do_exit+0x102>
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
c010a0ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a0cd:	89 04 24             	mov    %eax,(%esp)
c010a0d0:	e8 4e f2 ff ff       	call   c0109323 <__intr_restore>
    
    schedule();
c010a0d5:	e8 bd 0e 00 00       	call   c010af97 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c010a0da:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a0df:	8b 40 04             	mov    0x4(%eax),%eax
c010a0e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a0e6:	c7 44 24 08 a8 df 10 	movl   $0xc010dfa8,0x8(%esp)
c010a0ed:	c0 
c010a0ee:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c010a0f5:	00 
c010a0f6:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010a0fd:	e8 d3 6c ff ff       	call   c0100dd5 <__panic>

c010a102 <load_icode>:
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {
c010a102:	55                   	push   %ebp
c010a103:	89 e5                	mov    %esp,%ebp
c010a105:	83 ec 78             	sub    $0x78,%esp
    if (current->mm != NULL) {
c010a108:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a10d:	8b 40 18             	mov    0x18(%eax),%eax
c010a110:	85 c0                	test   %eax,%eax
c010a112:	74 1c                	je     c010a130 <load_icode+0x2e>
        panic("load_icode: current->mm must be empty.\n");
c010a114:	c7 44 24 08 c8 df 10 	movl   $0xc010dfc8,0x8(%esp)
c010a11b:	c0 
c010a11c:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c010a123:	00 
c010a124:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010a12b:	e8 a5 6c ff ff       	call   c0100dd5 <__panic>
    }

    int ret = -E_NO_MEM;
c010a130:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
c010a137:	e8 ca dd ff ff       	call   c0107f06 <mm_create>
c010a13c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a13f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010a143:	75 06                	jne    c010a14b <load_icode+0x49>
        goto bad_mm;
c010a145:	90                   	nop
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
c010a146:	e9 ef 05 00 00       	jmp    c010a73a <load_icode+0x638>
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
c010a14b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a14e:	89 04 24             	mov    %eax,(%esp)
c010a151:	e8 ed f9 ff ff       	call   c0109b43 <setup_pgdir>
c010a156:	85 c0                	test   %eax,%eax
c010a158:	74 05                	je     c010a15f <load_icode+0x5d>
        goto bad_pgdir_cleanup_mm;
c010a15a:	e9 f6 05 00 00       	jmp    c010a755 <load_icode+0x653>
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
c010a15f:	8b 45 08             	mov    0x8(%ebp),%eax
c010a162:	89 45 cc             	mov    %eax,-0x34(%ebp)
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
c010a165:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a168:	8b 50 1c             	mov    0x1c(%eax),%edx
c010a16b:	8b 45 08             	mov    0x8(%ebp),%eax
c010a16e:	01 d0                	add    %edx,%eax
c010a170:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
c010a173:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a176:	8b 00                	mov    (%eax),%eax
c010a178:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
c010a17d:	74 0c                	je     c010a18b <load_icode+0x89>
        ret = -E_INVAL_ELF;
c010a17f:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
        goto bad_elf_cleanup_pgdir;
c010a186:	e9 bf 05 00 00       	jmp    c010a74a <load_icode+0x648>
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
c010a18b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a18e:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010a192:	0f b7 c0             	movzwl %ax,%eax
c010a195:	c1 e0 05             	shl    $0x5,%eax
c010a198:	89 c2                	mov    %eax,%edx
c010a19a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a19d:	01 d0                	add    %edx,%eax
c010a19f:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; ph < ph_end; ph ++) {
c010a1a2:	e9 13 03 00 00       	jmp    c010a4ba <load_icode+0x3b8>
    //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
c010a1a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1aa:	8b 00                	mov    (%eax),%eax
c010a1ac:	83 f8 01             	cmp    $0x1,%eax
c010a1af:	74 05                	je     c010a1b6 <load_icode+0xb4>
            continue ;
c010a1b1:	e9 00 03 00 00       	jmp    c010a4b6 <load_icode+0x3b4>
        }
        if (ph->p_filesz > ph->p_memsz) {
c010a1b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1b9:	8b 50 10             	mov    0x10(%eax),%edx
c010a1bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1bf:	8b 40 14             	mov    0x14(%eax),%eax
c010a1c2:	39 c2                	cmp    %eax,%edx
c010a1c4:	76 0c                	jbe    c010a1d2 <load_icode+0xd0>
            ret = -E_INVAL_ELF;
c010a1c6:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
            goto bad_cleanup_mmap;
c010a1cd:	e9 6d 05 00 00       	jmp    c010a73f <load_icode+0x63d>
        }
        if (ph->p_filesz == 0) {
c010a1d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1d5:	8b 40 10             	mov    0x10(%eax),%eax
c010a1d8:	85 c0                	test   %eax,%eax
c010a1da:	75 05                	jne    c010a1e1 <load_icode+0xdf>
            continue ;
c010a1dc:	e9 d5 02 00 00       	jmp    c010a4b6 <load_icode+0x3b4>
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U;
c010a1e1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010a1e8:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
c010a1ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1f2:	8b 40 18             	mov    0x18(%eax),%eax
c010a1f5:	83 e0 01             	and    $0x1,%eax
c010a1f8:	85 c0                	test   %eax,%eax
c010a1fa:	74 04                	je     c010a200 <load_icode+0xfe>
c010a1fc:	83 4d e8 04          	orl    $0x4,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
c010a200:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a203:	8b 40 18             	mov    0x18(%eax),%eax
c010a206:	83 e0 02             	and    $0x2,%eax
c010a209:	85 c0                	test   %eax,%eax
c010a20b:	74 04                	je     c010a211 <load_icode+0x10f>
c010a20d:	83 4d e8 02          	orl    $0x2,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
c010a211:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a214:	8b 40 18             	mov    0x18(%eax),%eax
c010a217:	83 e0 04             	and    $0x4,%eax
c010a21a:	85 c0                	test   %eax,%eax
c010a21c:	74 04                	je     c010a222 <load_icode+0x120>
c010a21e:	83 4d e8 01          	orl    $0x1,-0x18(%ebp)
        if (vm_flags & VM_WRITE) perm |= PTE_W;
c010a222:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a225:	83 e0 02             	and    $0x2,%eax
c010a228:	85 c0                	test   %eax,%eax
c010a22a:	74 04                	je     c010a230 <load_icode+0x12e>
c010a22c:	83 4d e4 02          	orl    $0x2,-0x1c(%ebp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
c010a230:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a233:	8b 50 14             	mov    0x14(%eax),%edx
c010a236:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a239:	8b 40 08             	mov    0x8(%eax),%eax
c010a23c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a243:	00 
c010a244:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010a247:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010a24b:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a24f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a253:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a256:	89 04 24             	mov    %eax,(%esp)
c010a259:	e8 a3 e0 ff ff       	call   c0108301 <mm_map>
c010a25e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a261:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a265:	74 05                	je     c010a26c <load_icode+0x16a>
            goto bad_cleanup_mmap;
c010a267:	e9 d3 04 00 00       	jmp    c010a73f <load_icode+0x63d>
        }
        unsigned char *from = binary + ph->p_offset;
c010a26c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a26f:	8b 50 04             	mov    0x4(%eax),%edx
c010a272:	8b 45 08             	mov    0x8(%ebp),%eax
c010a275:	01 d0                	add    %edx,%eax
c010a277:	89 45 e0             	mov    %eax,-0x20(%ebp)
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
c010a27a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a27d:	8b 40 08             	mov    0x8(%eax),%eax
c010a280:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a283:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a286:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010a289:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a28c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010a291:	89 45 d4             	mov    %eax,-0x2c(%ebp)

        ret = -E_NO_MEM;
c010a294:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
c010a29b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a29e:	8b 50 08             	mov    0x8(%eax),%edx
c010a2a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2a4:	8b 40 10             	mov    0x10(%eax),%eax
c010a2a7:	01 d0                	add    %edx,%eax
c010a2a9:	89 45 c0             	mov    %eax,-0x40(%ebp)
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a2ac:	e9 90 00 00 00       	jmp    c010a341 <load_icode+0x23f>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a2b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a2b4:	8b 40 0c             	mov    0xc(%eax),%eax
c010a2b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a2ba:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a2be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a2c1:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a2c5:	89 04 24             	mov    %eax,(%esp)
c010a2c8:	e8 85 bc ff ff       	call   c0105f52 <pgdir_alloc_page>
c010a2cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a2d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a2d4:	75 05                	jne    c010a2db <load_icode+0x1d9>
                goto bad_cleanup_mmap;
c010a2d6:	e9 64 04 00 00       	jmp    c010a73f <load_icode+0x63d>
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a2db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a2de:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a2e1:	29 c2                	sub    %eax,%edx
c010a2e3:	89 d0                	mov    %edx,%eax
c010a2e5:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a2e8:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a2ed:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a2f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a2f3:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a2fa:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a2fd:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a300:	73 0d                	jae    c010a30f <load_icode+0x20d>
                size -= la - end;
c010a302:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a305:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a308:	29 c2                	sub    %eax,%edx
c010a30a:	89 d0                	mov    %edx,%eax
c010a30c:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memcpy(page2kva(page) + off, from, size);
c010a30f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a312:	89 04 24             	mov    %eax,(%esp)
c010a315:	e8 07 f1 ff ff       	call   c0109421 <page2kva>
c010a31a:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a31d:	01 c2                	add    %eax,%edx
c010a31f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a322:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a326:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a329:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a32d:	89 14 24             	mov    %edx,(%esp)
c010a330:	e8 af 1a 00 00       	call   c010bde4 <memcpy>
            start += size, from += size;
c010a335:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a338:	01 45 d8             	add    %eax,-0x28(%ebp)
c010a33b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a33e:	01 45 e0             	add    %eax,-0x20(%ebp)
        ret = -E_NO_MEM;

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a341:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a344:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a347:	0f 82 64 ff ff ff    	jb     c010a2b1 <load_icode+0x1af>
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }

      //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
c010a34d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a350:	8b 50 08             	mov    0x8(%eax),%edx
c010a353:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a356:	8b 40 14             	mov    0x14(%eax),%eax
c010a359:	01 d0                	add    %edx,%eax
c010a35b:	89 45 c0             	mov    %eax,-0x40(%ebp)
        if (start < la) {
c010a35e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a361:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a364:	0f 83 b0 00 00 00    	jae    c010a41a <load_icode+0x318>
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
c010a36a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a36d:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a370:	75 05                	jne    c010a377 <load_icode+0x275>
                continue ;
c010a372:	e9 3f 01 00 00       	jmp    c010a4b6 <load_icode+0x3b4>
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
c010a377:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a37a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a37d:	29 c2                	sub    %eax,%edx
c010a37f:	89 d0                	mov    %edx,%eax
c010a381:	05 00 10 00 00       	add    $0x1000,%eax
c010a386:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a389:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a38e:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a391:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (end < la) {
c010a394:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a397:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a39a:	73 0d                	jae    c010a3a9 <load_icode+0x2a7>
                size -= la - end;
c010a39c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a39f:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a3a2:	29 c2                	sub    %eax,%edx
c010a3a4:	89 d0                	mov    %edx,%eax
c010a3a6:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a3a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a3ac:	89 04 24             	mov    %eax,(%esp)
c010a3af:	e8 6d f0 ff ff       	call   c0109421 <page2kva>
c010a3b4:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a3b7:	01 c2                	add    %eax,%edx
c010a3b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a3bc:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a3c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a3c7:	00 
c010a3c8:	89 14 24             	mov    %edx,(%esp)
c010a3cb:	e8 32 19 00 00       	call   c010bd02 <memset>
            start += size;
c010a3d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a3d3:	01 45 d8             	add    %eax,-0x28(%ebp)
            assert((end < la && start == end) || (end >= la && start == la));
c010a3d6:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a3d9:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a3dc:	73 08                	jae    c010a3e6 <load_icode+0x2e4>
c010a3de:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a3e1:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a3e4:	74 34                	je     c010a41a <load_icode+0x318>
c010a3e6:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a3e9:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a3ec:	72 08                	jb     c010a3f6 <load_icode+0x2f4>
c010a3ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a3f1:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a3f4:	74 24                	je     c010a41a <load_icode+0x318>
c010a3f6:	c7 44 24 0c f0 df 10 	movl   $0xc010dff0,0xc(%esp)
c010a3fd:	c0 
c010a3fe:	c7 44 24 08 71 df 10 	movl   $0xc010df71,0x8(%esp)
c010a405:	c0 
c010a406:	c7 44 24 04 60 02 00 	movl   $0x260,0x4(%esp)
c010a40d:	00 
c010a40e:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010a415:	e8 bb 69 ff ff       	call   c0100dd5 <__panic>
        }
        while (start < end) {
c010a41a:	e9 8b 00 00 00       	jmp    c010a4aa <load_icode+0x3a8>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a41f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a422:	8b 40 0c             	mov    0xc(%eax),%eax
c010a425:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a428:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a42c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a42f:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a433:	89 04 24             	mov    %eax,(%esp)
c010a436:	e8 17 bb ff ff       	call   c0105f52 <pgdir_alloc_page>
c010a43b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a43e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a442:	75 05                	jne    c010a449 <load_icode+0x347>
                goto bad_cleanup_mmap;
c010a444:	e9 f6 02 00 00       	jmp    c010a73f <load_icode+0x63d>
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a449:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a44c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a44f:	29 c2                	sub    %eax,%edx
c010a451:	89 d0                	mov    %edx,%eax
c010a453:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a456:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a45b:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a45e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a461:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a468:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a46b:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a46e:	73 0d                	jae    c010a47d <load_icode+0x37b>
                size -= la - end;
c010a470:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a473:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a476:	29 c2                	sub    %eax,%edx
c010a478:	89 d0                	mov    %edx,%eax
c010a47a:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a47d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a480:	89 04 24             	mov    %eax,(%esp)
c010a483:	e8 99 ef ff ff       	call   c0109421 <page2kva>
c010a488:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a48b:	01 c2                	add    %eax,%edx
c010a48d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a490:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a494:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a49b:	00 
c010a49c:	89 14 24             	mov    %edx,(%esp)
c010a49f:	e8 5e 18 00 00       	call   c010bd02 <memset>
            start += size;
c010a4a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a4a7:	01 45 d8             	add    %eax,-0x28(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
c010a4aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a4ad:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a4b0:	0f 82 69 ff ff ff    	jb     c010a41f <load_icode+0x31d>
        goto bad_elf_cleanup_pgdir;
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
    for (; ph < ph_end; ph ++) {
c010a4b6:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c010a4ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a4bd:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010a4c0:	0f 82 e1 fc ff ff    	jb     c010a1a7 <load_icode+0xa5>
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
c010a4c6:	c7 45 e8 0b 00 00 00 	movl   $0xb,-0x18(%ebp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
c010a4cd:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a4d4:	00 
c010a4d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a4d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a4dc:	c7 44 24 08 00 00 10 	movl   $0x100000,0x8(%esp)
c010a4e3:	00 
c010a4e4:	c7 44 24 04 00 00 f0 	movl   $0xaff00000,0x4(%esp)
c010a4eb:	af 
c010a4ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a4ef:	89 04 24             	mov    %eax,(%esp)
c010a4f2:	e8 0a de ff ff       	call   c0108301 <mm_map>
c010a4f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a4fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a4fe:	74 05                	je     c010a505 <load_icode+0x403>
        goto bad_cleanup_mmap;
c010a500:	e9 3a 02 00 00       	jmp    c010a73f <load_icode+0x63d>
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
c010a505:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a508:	8b 40 0c             	mov    0xc(%eax),%eax
c010a50b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a512:	00 
c010a513:	c7 44 24 04 00 f0 ff 	movl   $0xaffff000,0x4(%esp)
c010a51a:	af 
c010a51b:	89 04 24             	mov    %eax,(%esp)
c010a51e:	e8 2f ba ff ff       	call   c0105f52 <pgdir_alloc_page>
c010a523:	85 c0                	test   %eax,%eax
c010a525:	75 24                	jne    c010a54b <load_icode+0x449>
c010a527:	c7 44 24 0c 2c e0 10 	movl   $0xc010e02c,0xc(%esp)
c010a52e:	c0 
c010a52f:	c7 44 24 08 71 df 10 	movl   $0xc010df71,0x8(%esp)
c010a536:	c0 
c010a537:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
c010a53e:	00 
c010a53f:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010a546:	e8 8a 68 ff ff       	call   c0100dd5 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
c010a54b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a54e:	8b 40 0c             	mov    0xc(%eax),%eax
c010a551:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a558:	00 
c010a559:	c7 44 24 04 00 e0 ff 	movl   $0xafffe000,0x4(%esp)
c010a560:	af 
c010a561:	89 04 24             	mov    %eax,(%esp)
c010a564:	e8 e9 b9 ff ff       	call   c0105f52 <pgdir_alloc_page>
c010a569:	85 c0                	test   %eax,%eax
c010a56b:	75 24                	jne    c010a591 <load_icode+0x48f>
c010a56d:	c7 44 24 0c 70 e0 10 	movl   $0xc010e070,0xc(%esp)
c010a574:	c0 
c010a575:	c7 44 24 08 71 df 10 	movl   $0xc010df71,0x8(%esp)
c010a57c:	c0 
c010a57d:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
c010a584:	00 
c010a585:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010a58c:	e8 44 68 ff ff       	call   c0100dd5 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
c010a591:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a594:	8b 40 0c             	mov    0xc(%eax),%eax
c010a597:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a59e:	00 
c010a59f:	c7 44 24 04 00 d0 ff 	movl   $0xafffd000,0x4(%esp)
c010a5a6:	af 
c010a5a7:	89 04 24             	mov    %eax,(%esp)
c010a5aa:	e8 a3 b9 ff ff       	call   c0105f52 <pgdir_alloc_page>
c010a5af:	85 c0                	test   %eax,%eax
c010a5b1:	75 24                	jne    c010a5d7 <load_icode+0x4d5>
c010a5b3:	c7 44 24 0c b4 e0 10 	movl   $0xc010e0b4,0xc(%esp)
c010a5ba:	c0 
c010a5bb:	c7 44 24 08 71 df 10 	movl   $0xc010df71,0x8(%esp)
c010a5c2:	c0 
c010a5c3:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
c010a5ca:	00 
c010a5cb:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010a5d2:	e8 fe 67 ff ff       	call   c0100dd5 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
c010a5d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a5da:	8b 40 0c             	mov    0xc(%eax),%eax
c010a5dd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a5e4:	00 
c010a5e5:	c7 44 24 04 00 c0 ff 	movl   $0xafffc000,0x4(%esp)
c010a5ec:	af 
c010a5ed:	89 04 24             	mov    %eax,(%esp)
c010a5f0:	e8 5d b9 ff ff       	call   c0105f52 <pgdir_alloc_page>
c010a5f5:	85 c0                	test   %eax,%eax
c010a5f7:	75 24                	jne    c010a61d <load_icode+0x51b>
c010a5f9:	c7 44 24 0c f8 e0 10 	movl   $0xc010e0f8,0xc(%esp)
c010a600:	c0 
c010a601:	c7 44 24 08 71 df 10 	movl   $0xc010df71,0x8(%esp)
c010a608:	c0 
c010a609:	c7 44 24 04 76 02 00 	movl   $0x276,0x4(%esp)
c010a610:	00 
c010a611:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010a618:	e8 b8 67 ff ff       	call   c0100dd5 <__panic>
    
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
c010a61d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a620:	89 04 24             	mov    %eax,(%esp)
c010a623:	e8 97 ee ff ff       	call   c01094bf <mm_count_inc>
    current->mm = mm;
c010a628:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a62d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a630:	89 50 18             	mov    %edx,0x18(%eax)
    current->cr3 = PADDR(mm->pgdir);
c010a633:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a638:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a63b:	8b 52 0c             	mov    0xc(%edx),%edx
c010a63e:	89 55 b8             	mov    %edx,-0x48(%ebp)
c010a641:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c010a648:	77 23                	ja     c010a66d <load_icode+0x56b>
c010a64a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010a64d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a651:	c7 44 24 08 20 df 10 	movl   $0xc010df20,0x8(%esp)
c010a658:	c0 
c010a659:	c7 44 24 04 7b 02 00 	movl   $0x27b,0x4(%esp)
c010a660:	00 
c010a661:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010a668:	e8 68 67 ff ff       	call   c0100dd5 <__panic>
c010a66d:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010a670:	81 c2 00 00 00 40    	add    $0x40000000,%edx
c010a676:	89 50 40             	mov    %edx,0x40(%eax)
    lcr3(PADDR(mm->pgdir));
c010a679:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a67c:	8b 40 0c             	mov    0xc(%eax),%eax
c010a67f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010a682:	81 7d b4 ff ff ff bf 	cmpl   $0xbfffffff,-0x4c(%ebp)
c010a689:	77 23                	ja     c010a6ae <load_icode+0x5ac>
c010a68b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a68e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a692:	c7 44 24 08 20 df 10 	movl   $0xc010df20,0x8(%esp)
c010a699:	c0 
c010a69a:	c7 44 24 04 7c 02 00 	movl   $0x27c,0x4(%esp)
c010a6a1:	00 
c010a6a2:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010a6a9:	e8 27 67 ff ff       	call   c0100dd5 <__panic>
c010a6ae:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a6b1:	05 00 00 00 40       	add    $0x40000000,%eax
c010a6b6:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010a6b9:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010a6bc:	0f 22 d8             	mov    %eax,%cr3

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
c010a6bf:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a6c4:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a6c7:	89 45 b0             	mov    %eax,-0x50(%ebp)
    memset(tf, 0, sizeof(struct trapframe));
c010a6ca:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c010a6d1:	00 
c010a6d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a6d9:	00 
c010a6da:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6dd:	89 04 24             	mov    %eax,(%esp)
c010a6e0:	e8 1d 16 00 00       	call   c010bd02 <memset>
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    tf->tf_cs = USER_CS;
c010a6e5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6e8:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
c010a6ee:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6f1:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c010a6f7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6fa:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c010a6fe:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a701:	66 89 50 28          	mov    %dx,0x28(%eax)
c010a705:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a708:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010a70c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a70f:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    tf->tf_esp = USTACKTOP;
c010a713:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a716:	c7 40 44 00 00 00 b0 	movl   $0xb0000000,0x44(%eax)
    tf->tf_eip = elf->e_entry;
c010a71d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a720:	8b 50 18             	mov    0x18(%eax),%edx
c010a723:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a726:	89 50 38             	mov    %edx,0x38(%eax)
    tf->tf_eflags = FL_IF;
c010a729:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a72c:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)

    ret = 0;
c010a733:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
out:
    return ret;
c010a73a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a73d:	eb 23                	jmp    c010a762 <load_icode+0x660>
bad_cleanup_mmap:
    exit_mmap(mm);
c010a73f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a742:	89 04 24             	mov    %eax,(%esp)
c010a745:	e8 d4 dd ff ff       	call   c010851e <exit_mmap>
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
c010a74a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a74d:	89 04 24             	mov    %eax,(%esp)
c010a750:	e8 95 f4 ff ff       	call   c0109bea <put_pgdir>
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c010a755:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a758:	89 04 24             	mov    %eax,(%esp)
c010a75b:	e8 ff da ff ff       	call   c010825f <mm_destroy>
bad_mm:
    goto out;
c010a760:	eb d8                	jmp    c010a73a <load_icode+0x638>
}
c010a762:	c9                   	leave  
c010a763:	c3                   	ret    

c010a764 <do_execve>:

// do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
c010a764:	55                   	push   %ebp
c010a765:	89 e5                	mov    %esp,%ebp
c010a767:	83 ec 38             	sub    $0x38,%esp
    struct mm_struct *mm = current->mm;
c010a76a:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a76f:	8b 40 18             	mov    0x18(%eax),%eax
c010a772:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
c010a775:	8b 45 08             	mov    0x8(%ebp),%eax
c010a778:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010a77f:	00 
c010a780:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a783:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a787:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a78b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a78e:	89 04 24             	mov    %eax,(%esp)
c010a791:	e8 4d e8 ff ff       	call   c0108fe3 <user_mem_check>
c010a796:	85 c0                	test   %eax,%eax
c010a798:	75 0a                	jne    c010a7a4 <do_execve+0x40>
        return -E_INVAL;
c010a79a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a79f:	e9 f4 00 00 00       	jmp    c010a898 <do_execve+0x134>
    }
    if (len > PROC_NAME_LEN) {
c010a7a4:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
c010a7a8:	76 07                	jbe    c010a7b1 <do_execve+0x4d>
        len = PROC_NAME_LEN;
c010a7aa:	c7 45 0c 0f 00 00 00 	movl   $0xf,0xc(%ebp)
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
c010a7b1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010a7b8:	00 
c010a7b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a7c0:	00 
c010a7c1:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a7c4:	89 04 24             	mov    %eax,(%esp)
c010a7c7:	e8 36 15 00 00       	call   c010bd02 <memset>
    memcpy(local_name, name, len);
c010a7cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a7cf:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a7d3:	8b 45 08             	mov    0x8(%ebp),%eax
c010a7d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a7da:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a7dd:	89 04 24             	mov    %eax,(%esp)
c010a7e0:	e8 ff 15 00 00       	call   c010bde4 <memcpy>

    if (mm != NULL) {
c010a7e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a7e9:	74 4a                	je     c010a835 <do_execve+0xd1>
        lcr3(boot_cr3);
c010a7eb:	a1 c8 ef 19 c0       	mov    0xc019efc8,%eax
c010a7f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a7f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a7f6:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a7f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a7fc:	89 04 24             	mov    %eax,(%esp)
c010a7ff:	e8 d5 ec ff ff       	call   c01094d9 <mm_count_dec>
c010a804:	85 c0                	test   %eax,%eax
c010a806:	75 21                	jne    c010a829 <do_execve+0xc5>
            exit_mmap(mm);
c010a808:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a80b:	89 04 24             	mov    %eax,(%esp)
c010a80e:	e8 0b dd ff ff       	call   c010851e <exit_mmap>
            put_pgdir(mm);
c010a813:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a816:	89 04 24             	mov    %eax,(%esp)
c010a819:	e8 cc f3 ff ff       	call   c0109bea <put_pgdir>
            mm_destroy(mm);
c010a81e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a821:	89 04 24             	mov    %eax,(%esp)
c010a824:	e8 36 da ff ff       	call   c010825f <mm_destroy>
        }
        current->mm = NULL;
c010a829:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a82e:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
c010a835:	8b 45 14             	mov    0x14(%ebp),%eax
c010a838:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a83c:	8b 45 10             	mov    0x10(%ebp),%eax
c010a83f:	89 04 24             	mov    %eax,(%esp)
c010a842:	e8 bb f8 ff ff       	call   c010a102 <load_icode>
c010a847:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a84a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a84e:	74 2f                	je     c010a87f <do_execve+0x11b>
        goto execve_exit;
c010a850:	90                   	nop
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
c010a851:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a854:	89 04 24             	mov    %eax,(%esp)
c010a857:	e8 d6 f6 ff ff       	call   c0109f32 <do_exit>
    panic("already exit: %e.\n", ret);
c010a85c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a85f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a863:	c7 44 24 08 3b e1 10 	movl   $0xc010e13b,0x8(%esp)
c010a86a:	c0 
c010a86b:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
c010a872:	00 
c010a873:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010a87a:	e8 56 65 ff ff       	call   c0100dd5 <__panic>
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
        goto execve_exit;
    }
    set_proc_name(current, local_name);
c010a87f:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a884:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010a887:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a88b:	89 04 24             	mov    %eax,(%esp)
c010a88e:	e8 89 ed ff ff       	call   c010961c <set_proc_name>
    return 0;
c010a893:	b8 00 00 00 00       	mov    $0x0,%eax

execve_exit:
    do_exit(ret);
    panic("already exit: %e.\n", ret);
}
c010a898:	c9                   	leave  
c010a899:	c3                   	ret    

c010a89a <do_yield>:

// do_yield - ask the scheduler to reschedule
int
do_yield(void) {
c010a89a:	55                   	push   %ebp
c010a89b:	89 e5                	mov    %esp,%ebp
    current->need_resched = 1;
c010a89d:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a8a2:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    return 0;
c010a8a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a8ae:	5d                   	pop    %ebp
c010a8af:	c3                   	ret    

c010a8b0 <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
c010a8b0:	55                   	push   %ebp
c010a8b1:	89 e5                	mov    %esp,%ebp
c010a8b3:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = current->mm;
c010a8b6:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a8bb:	8b 40 18             	mov    0x18(%eax),%eax
c010a8be:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (code_store != NULL) {
c010a8c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a8c5:	74 30                	je     c010a8f7 <do_wait+0x47>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
c010a8c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a8ca:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010a8d1:	00 
c010a8d2:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
c010a8d9:	00 
c010a8da:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a8de:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a8e1:	89 04 24             	mov    %eax,(%esp)
c010a8e4:	e8 fa e6 ff ff       	call   c0108fe3 <user_mem_check>
c010a8e9:	85 c0                	test   %eax,%eax
c010a8eb:	75 0a                	jne    c010a8f7 <do_wait+0x47>
            return -E_INVAL;
c010a8ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a8f2:	e9 4b 01 00 00       	jmp    c010aa42 <do_wait+0x192>
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
c010a8f7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if (pid != 0) {
c010a8fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a902:	74 39                	je     c010a93d <do_wait+0x8d>
        proc = find_proc(pid);
c010a904:	8b 45 08             	mov    0x8(%ebp),%eax
c010a907:	89 04 24             	mov    %eax,(%esp)
c010a90a:	e8 ee f0 ff ff       	call   c01099fd <find_proc>
c010a90f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (proc != NULL && proc->parent == current) {
c010a912:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a916:	74 54                	je     c010a96c <do_wait+0xbc>
c010a918:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a91b:	8b 50 14             	mov    0x14(%eax),%edx
c010a91e:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a923:	39 c2                	cmp    %eax,%edx
c010a925:	75 45                	jne    c010a96c <do_wait+0xbc>
            haskid = 1;
c010a927:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010a92e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a931:	8b 00                	mov    (%eax),%eax
c010a933:	83 f8 03             	cmp    $0x3,%eax
c010a936:	75 34                	jne    c010a96c <do_wait+0xbc>
                goto found;
c010a938:	e9 80 00 00 00       	jmp    c010a9bd <do_wait+0x10d>
            }
        }
    }
    else {
        proc = current->cptr;
c010a93d:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a942:	8b 40 70             	mov    0x70(%eax),%eax
c010a945:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (; proc != NULL; proc = proc->optr) {
c010a948:	eb 1c                	jmp    c010a966 <do_wait+0xb6>
            haskid = 1;
c010a94a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010a951:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a954:	8b 00                	mov    (%eax),%eax
c010a956:	83 f8 03             	cmp    $0x3,%eax
c010a959:	75 02                	jne    c010a95d <do_wait+0xad>
                goto found;
c010a95b:	eb 60                	jmp    c010a9bd <do_wait+0x10d>
            }
        }
    }
    else {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
c010a95d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a960:	8b 40 78             	mov    0x78(%eax),%eax
c010a963:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a966:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a96a:	75 de                	jne    c010a94a <do_wait+0x9a>
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    if (haskid) {
c010a96c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a970:	74 41                	je     c010a9b3 <do_wait+0x103>
        current->state = PROC_SLEEPING;
c010a972:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a977:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010a97d:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a982:	c7 40 6c 01 00 00 80 	movl   $0x80000001,0x6c(%eax)
        schedule();
c010a989:	e8 09 06 00 00       	call   c010af97 <schedule>
        if (current->flags & PF_EXITING) {
c010a98e:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a993:	8b 40 44             	mov    0x44(%eax),%eax
c010a996:	83 e0 01             	and    $0x1,%eax
c010a999:	85 c0                	test   %eax,%eax
c010a99b:	74 11                	je     c010a9ae <do_wait+0xfe>
            do_exit(-E_KILLED);
c010a99d:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c010a9a4:	e8 89 f5 ff ff       	call   c0109f32 <do_exit>
        }
        goto repeat;
c010a9a9:	e9 49 ff ff ff       	jmp    c010a8f7 <do_wait+0x47>
c010a9ae:	e9 44 ff ff ff       	jmp    c010a8f7 <do_wait+0x47>
    }
    return -E_BAD_PROC;
c010a9b3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c010a9b8:	e9 85 00 00 00       	jmp    c010aa42 <do_wait+0x192>

found:
    if (proc == idleproc || proc == initproc) {
c010a9bd:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010a9c2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010a9c5:	74 0a                	je     c010a9d1 <do_wait+0x121>
c010a9c7:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010a9cc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010a9cf:	75 1c                	jne    c010a9ed <do_wait+0x13d>
        panic("wait idleproc or initproc.\n");
c010a9d1:	c7 44 24 08 4e e1 10 	movl   $0xc010e14e,0x8(%esp)
c010a9d8:	c0 
c010a9d9:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
c010a9e0:	00 
c010a9e1:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010a9e8:	e8 e8 63 ff ff       	call   c0100dd5 <__panic>
    }
    if (code_store != NULL) {
c010a9ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a9f1:	74 0b                	je     c010a9fe <do_wait+0x14e>
        *code_store = proc->exit_code;
c010a9f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9f6:	8b 50 68             	mov    0x68(%eax),%edx
c010a9f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a9fc:	89 10                	mov    %edx,(%eax)
    }
    local_intr_save(intr_flag);
c010a9fe:	e8 f6 e8 ff ff       	call   c01092f9 <__intr_save>
c010aa03:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        unhash_proc(proc);
c010aa06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa09:	89 04 24             	mov    %eax,(%esp)
c010aa0c:	e8 b9 ef ff ff       	call   c01099ca <unhash_proc>
        remove_links(proc);
c010aa11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa14:	89 04 24             	mov    %eax,(%esp)
c010aa17:	e8 2a ed ff ff       	call   c0109746 <remove_links>
    }
    local_intr_restore(intr_flag);
c010aa1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010aa1f:	89 04 24             	mov    %eax,(%esp)
c010aa22:	e8 fc e8 ff ff       	call   c0109323 <__intr_restore>
    put_kstack(proc);
c010aa27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa2a:	89 04 24             	mov    %eax,(%esp)
c010aa2d:	e8 eb f0 ff ff       	call   c0109b1d <put_kstack>
    kfree(proc);
c010aa32:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa35:	89 04 24             	mov    %eax,(%esp)
c010aa38:	e8 d0 a1 ff ff       	call   c0104c0d <kfree>
    return 0;
c010aa3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aa42:	c9                   	leave  
c010aa43:	c3                   	ret    

c010aa44 <do_kill>:

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int
do_kill(int pid) {
c010aa44:	55                   	push   %ebp
c010aa45:	89 e5                	mov    %esp,%ebp
c010aa47:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
c010aa4a:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa4d:	89 04 24             	mov    %eax,(%esp)
c010aa50:	e8 a8 ef ff ff       	call   c01099fd <find_proc>
c010aa55:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010aa58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010aa5c:	74 41                	je     c010aa9f <do_kill+0x5b>
        if (!(proc->flags & PF_EXITING)) {
c010aa5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa61:	8b 40 44             	mov    0x44(%eax),%eax
c010aa64:	83 e0 01             	and    $0x1,%eax
c010aa67:	85 c0                	test   %eax,%eax
c010aa69:	75 2d                	jne    c010aa98 <do_kill+0x54>
            proc->flags |= PF_EXITING;
c010aa6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa6e:	8b 40 44             	mov    0x44(%eax),%eax
c010aa71:	83 c8 01             	or     $0x1,%eax
c010aa74:	89 c2                	mov    %eax,%edx
c010aa76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa79:	89 50 44             	mov    %edx,0x44(%eax)
            if (proc->wait_state & WT_INTERRUPTED) {
c010aa7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa7f:	8b 40 6c             	mov    0x6c(%eax),%eax
c010aa82:	85 c0                	test   %eax,%eax
c010aa84:	79 0b                	jns    c010aa91 <do_kill+0x4d>
                wakeup_proc(proc);
c010aa86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa89:	89 04 24             	mov    %eax,(%esp)
c010aa8c:	e8 82 04 00 00       	call   c010af13 <wakeup_proc>
            }
            return 0;
c010aa91:	b8 00 00 00 00       	mov    $0x0,%eax
c010aa96:	eb 0c                	jmp    c010aaa4 <do_kill+0x60>
        }
        return -E_KILLED;
c010aa98:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
c010aa9d:	eb 05                	jmp    c010aaa4 <do_kill+0x60>
    }
    return -E_INVAL;
c010aa9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
c010aaa4:	c9                   	leave  
c010aaa5:	c3                   	ret    

c010aaa6 <kernel_execve>:

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
c010aaa6:	55                   	push   %ebp
c010aaa7:	89 e5                	mov    %esp,%ebp
c010aaa9:	57                   	push   %edi
c010aaaa:	56                   	push   %esi
c010aaab:	53                   	push   %ebx
c010aaac:	83 ec 2c             	sub    $0x2c,%esp
    int ret, len = strlen(name);
c010aaaf:	8b 45 08             	mov    0x8(%ebp),%eax
c010aab2:	89 04 24             	mov    %eax,(%esp)
c010aab5:	e8 19 0f 00 00       	call   c010b9d3 <strlen>
c010aaba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile (
c010aabd:	b8 04 00 00 00       	mov    $0x4,%eax
c010aac2:	8b 55 08             	mov    0x8(%ebp),%edx
c010aac5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c010aac8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010aacb:	8b 75 10             	mov    0x10(%ebp),%esi
c010aace:	89 f7                	mov    %esi,%edi
c010aad0:	cd 80                	int    $0x80
c010aad2:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL), "0" (SYS_exec), "d" (name), "c" (len), "b" (binary), "D" (size)
        : "memory");
    return ret;
c010aad5:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
c010aad8:	83 c4 2c             	add    $0x2c,%esp
c010aadb:	5b                   	pop    %ebx
c010aadc:	5e                   	pop    %esi
c010aadd:	5f                   	pop    %edi
c010aade:	5d                   	pop    %ebp
c010aadf:	c3                   	ret    

c010aae0 <user_main>:

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
c010aae0:	55                   	push   %ebp
c010aae1:	89 e5                	mov    %esp,%ebp
c010aae3:	83 ec 18             	sub    $0x18,%esp
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
c010aae6:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010aaeb:	8b 40 04             	mov    0x4(%eax),%eax
c010aaee:	c7 44 24 08 6a e1 10 	movl   $0xc010e16a,0x8(%esp)
c010aaf5:	c0 
c010aaf6:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aafa:	c7 04 24 74 e1 10 c0 	movl   $0xc010e174,(%esp)
c010ab01:	e8 4d 58 ff ff       	call   c0100353 <cprintf>
c010ab06:	b8 e2 78 00 00       	mov    $0x78e2,%eax
c010ab0b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010ab0f:	c7 44 24 04 79 f8 15 	movl   $0xc015f879,0x4(%esp)
c010ab16:	c0 
c010ab17:	c7 04 24 6a e1 10 c0 	movl   $0xc010e16a,(%esp)
c010ab1e:	e8 83 ff ff ff       	call   c010aaa6 <kernel_execve>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
c010ab23:	c7 44 24 08 9b e1 10 	movl   $0xc010e19b,0x8(%esp)
c010ab2a:	c0 
c010ab2b:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
c010ab32:	00 
c010ab33:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010ab3a:	e8 96 62 ff ff       	call   c0100dd5 <__panic>

c010ab3f <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010ab3f:	55                   	push   %ebp
c010ab40:	89 e5                	mov    %esp,%ebp
c010ab42:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010ab45:	e8 ba a5 ff ff       	call   c0105104 <nr_free_pages>
c010ab4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t kernel_allocated_store = kallocated();
c010ab4d:	e8 83 9f ff ff       	call   c0104ad5 <kallocated>
c010ab52:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int pid = kernel_thread(user_main, NULL, 0);
c010ab55:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010ab5c:	00 
c010ab5d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ab64:	00 
c010ab65:	c7 04 24 e0 aa 10 c0 	movl   $0xc010aae0,(%esp)
c010ab6c:	e8 fe ee ff ff       	call   c0109a6f <kernel_thread>
c010ab71:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c010ab74:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010ab78:	7f 1c                	jg     c010ab96 <init_main+0x57>
        panic("create user_main failed.\n");
c010ab7a:	c7 44 24 08 b5 e1 10 	movl   $0xc010e1b5,0x8(%esp)
c010ab81:	c0 
c010ab82:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
c010ab89:	00 
c010ab8a:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010ab91:	e8 3f 62 ff ff       	call   c0100dd5 <__panic>
    }

    while (do_wait(0, NULL) == 0) {
c010ab96:	eb 05                	jmp    c010ab9d <init_main+0x5e>
        schedule();
c010ab98:	e8 fa 03 00 00       	call   c010af97 <schedule>
    int pid = kernel_thread(user_main, NULL, 0);
    if (pid <= 0) {
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
c010ab9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010aba4:	00 
c010aba5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010abac:	e8 ff fc ff ff       	call   c010a8b0 <do_wait>
c010abb1:	85 c0                	test   %eax,%eax
c010abb3:	74 e3                	je     c010ab98 <init_main+0x59>
        schedule();
    }

    cprintf("all user-mode processes have quit.\n");
c010abb5:	c7 04 24 d0 e1 10 c0 	movl   $0xc010e1d0,(%esp)
c010abbc:	e8 92 57 ff ff       	call   c0100353 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
c010abc1:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010abc6:	8b 40 70             	mov    0x70(%eax),%eax
c010abc9:	85 c0                	test   %eax,%eax
c010abcb:	75 18                	jne    c010abe5 <init_main+0xa6>
c010abcd:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010abd2:	8b 40 74             	mov    0x74(%eax),%eax
c010abd5:	85 c0                	test   %eax,%eax
c010abd7:	75 0c                	jne    c010abe5 <init_main+0xa6>
c010abd9:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010abde:	8b 40 78             	mov    0x78(%eax),%eax
c010abe1:	85 c0                	test   %eax,%eax
c010abe3:	74 24                	je     c010ac09 <init_main+0xca>
c010abe5:	c7 44 24 0c f4 e1 10 	movl   $0xc010e1f4,0xc(%esp)
c010abec:	c0 
c010abed:	c7 44 24 08 71 df 10 	movl   $0xc010df71,0x8(%esp)
c010abf4:	c0 
c010abf5:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
c010abfc:	00 
c010abfd:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010ac04:	e8 cc 61 ff ff       	call   c0100dd5 <__panic>
    assert(nr_process == 2);
c010ac09:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c010ac0e:	83 f8 02             	cmp    $0x2,%eax
c010ac11:	74 24                	je     c010ac37 <init_main+0xf8>
c010ac13:	c7 44 24 0c 3f e2 10 	movl   $0xc010e23f,0xc(%esp)
c010ac1a:	c0 
c010ac1b:	c7 44 24 08 71 df 10 	movl   $0xc010df71,0x8(%esp)
c010ac22:	c0 
c010ac23:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
c010ac2a:	00 
c010ac2b:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010ac32:	e8 9e 61 ff ff       	call   c0100dd5 <__panic>
c010ac37:	c7 45 e8 b0 f0 19 c0 	movl   $0xc019f0b0,-0x18(%ebp)
c010ac3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ac41:	8b 40 04             	mov    0x4(%eax),%eax
    assert(list_next(&proc_list) == &(initproc->list_link));
c010ac44:	8b 15 84 cf 19 c0    	mov    0xc019cf84,%edx
c010ac4a:	83 c2 58             	add    $0x58,%edx
c010ac4d:	39 d0                	cmp    %edx,%eax
c010ac4f:	74 24                	je     c010ac75 <init_main+0x136>
c010ac51:	c7 44 24 0c 50 e2 10 	movl   $0xc010e250,0xc(%esp)
c010ac58:	c0 
c010ac59:	c7 44 24 08 71 df 10 	movl   $0xc010df71,0x8(%esp)
c010ac60:	c0 
c010ac61:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
c010ac68:	00 
c010ac69:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010ac70:	e8 60 61 ff ff       	call   c0100dd5 <__panic>
c010ac75:	c7 45 e4 b0 f0 19 c0 	movl   $0xc019f0b0,-0x1c(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c010ac7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010ac7f:	8b 00                	mov    (%eax),%eax
    assert(list_prev(&proc_list) == &(initproc->list_link));
c010ac81:	8b 15 84 cf 19 c0    	mov    0xc019cf84,%edx
c010ac87:	83 c2 58             	add    $0x58,%edx
c010ac8a:	39 d0                	cmp    %edx,%eax
c010ac8c:	74 24                	je     c010acb2 <init_main+0x173>
c010ac8e:	c7 44 24 0c 80 e2 10 	movl   $0xc010e280,0xc(%esp)
c010ac95:	c0 
c010ac96:	c7 44 24 08 71 df 10 	movl   $0xc010df71,0x8(%esp)
c010ac9d:	c0 
c010ac9e:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
c010aca5:	00 
c010aca6:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010acad:	e8 23 61 ff ff       	call   c0100dd5 <__panic>

    cprintf("init check memory pass.\n");
c010acb2:	c7 04 24 b0 e2 10 c0 	movl   $0xc010e2b0,(%esp)
c010acb9:	e8 95 56 ff ff       	call   c0100353 <cprintf>
    return 0;
c010acbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010acc3:	c9                   	leave  
c010acc4:	c3                   	ret    

c010acc5 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c010acc5:	55                   	push   %ebp
c010acc6:	89 e5                	mov    %esp,%ebp
c010acc8:	83 ec 28             	sub    $0x28,%esp
c010accb:	c7 45 ec b0 f0 19 c0 	movl   $0xc019f0b0,-0x14(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010acd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010acd5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010acd8:	89 50 04             	mov    %edx,0x4(%eax)
c010acdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010acde:	8b 50 04             	mov    0x4(%eax),%edx
c010ace1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ace4:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010ace6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010aced:	eb 26                	jmp    c010ad15 <proc_init+0x50>
        list_init(hash_list + i);
c010acef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010acf2:	c1 e0 03             	shl    $0x3,%eax
c010acf5:	05 a0 cf 19 c0       	add    $0xc019cfa0,%eax
c010acfa:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010acfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad00:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010ad03:	89 50 04             	mov    %edx,0x4(%eax)
c010ad06:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad09:	8b 50 04             	mov    0x4(%eax),%edx
c010ad0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad0f:	89 10                	mov    %edx,(%eax)
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010ad11:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010ad15:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010ad1c:	7e d1                	jle    c010acef <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010ad1e:	e8 08 e8 ff ff       	call   c010952b <alloc_proc>
c010ad23:	a3 80 cf 19 c0       	mov    %eax,0xc019cf80
c010ad28:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ad2d:	85 c0                	test   %eax,%eax
c010ad2f:	75 1c                	jne    c010ad4d <proc_init+0x88>
        panic("cannot alloc idleproc.\n");
c010ad31:	c7 44 24 08 c9 e2 10 	movl   $0xc010e2c9,0x8(%esp)
c010ad38:	c0 
c010ad39:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
c010ad40:	00 
c010ad41:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010ad48:	e8 88 60 ff ff       	call   c0100dd5 <__panic>
    }

    idleproc->pid = 0;
c010ad4d:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ad52:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010ad59:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ad5e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010ad64:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ad69:	ba 00 80 12 c0       	mov    $0xc0128000,%edx
c010ad6e:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010ad71:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ad76:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010ad7d:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ad82:	c7 44 24 04 e1 e2 10 	movl   $0xc010e2e1,0x4(%esp)
c010ad89:	c0 
c010ad8a:	89 04 24             	mov    %eax,(%esp)
c010ad8d:	e8 8a e8 ff ff       	call   c010961c <set_proc_name>
    nr_process ++;
c010ad92:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c010ad97:	83 c0 01             	add    $0x1,%eax
c010ad9a:	a3 a0 ef 19 c0       	mov    %eax,0xc019efa0

    current = idleproc;
c010ad9f:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ada4:	a3 88 cf 19 c0       	mov    %eax,0xc019cf88

    int pid = kernel_thread(init_main, NULL, 0);
c010ada9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010adb0:	00 
c010adb1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010adb8:	00 
c010adb9:	c7 04 24 3f ab 10 c0 	movl   $0xc010ab3f,(%esp)
c010adc0:	e8 aa ec ff ff       	call   c0109a6f <kernel_thread>
c010adc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010adc8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010adcc:	7f 1c                	jg     c010adea <proc_init+0x125>
        panic("create init_main failed.\n");
c010adce:	c7 44 24 08 e6 e2 10 	movl   $0xc010e2e6,0x8(%esp)
c010add5:	c0 
c010add6:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
c010addd:	00 
c010adde:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010ade5:	e8 eb 5f ff ff       	call   c0100dd5 <__panic>
    }

    initproc = find_proc(pid);
c010adea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010aded:	89 04 24             	mov    %eax,(%esp)
c010adf0:	e8 08 ec ff ff       	call   c01099fd <find_proc>
c010adf5:	a3 84 cf 19 c0       	mov    %eax,0xc019cf84
    set_proc_name(initproc, "init");
c010adfa:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010adff:	c7 44 24 04 00 e3 10 	movl   $0xc010e300,0x4(%esp)
c010ae06:	c0 
c010ae07:	89 04 24             	mov    %eax,(%esp)
c010ae0a:	e8 0d e8 ff ff       	call   c010961c <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010ae0f:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ae14:	85 c0                	test   %eax,%eax
c010ae16:	74 0c                	je     c010ae24 <proc_init+0x15f>
c010ae18:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ae1d:	8b 40 04             	mov    0x4(%eax),%eax
c010ae20:	85 c0                	test   %eax,%eax
c010ae22:	74 24                	je     c010ae48 <proc_init+0x183>
c010ae24:	c7 44 24 0c 08 e3 10 	movl   $0xc010e308,0xc(%esp)
c010ae2b:	c0 
c010ae2c:	c7 44 24 08 71 df 10 	movl   $0xc010df71,0x8(%esp)
c010ae33:	c0 
c010ae34:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
c010ae3b:	00 
c010ae3c:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010ae43:	e8 8d 5f ff ff       	call   c0100dd5 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010ae48:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010ae4d:	85 c0                	test   %eax,%eax
c010ae4f:	74 0d                	je     c010ae5e <proc_init+0x199>
c010ae51:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010ae56:	8b 40 04             	mov    0x4(%eax),%eax
c010ae59:	83 f8 01             	cmp    $0x1,%eax
c010ae5c:	74 24                	je     c010ae82 <proc_init+0x1bd>
c010ae5e:	c7 44 24 0c 30 e3 10 	movl   $0xc010e330,0xc(%esp)
c010ae65:	c0 
c010ae66:	c7 44 24 08 71 df 10 	movl   $0xc010df71,0x8(%esp)
c010ae6d:	c0 
c010ae6e:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
c010ae75:	00 
c010ae76:	c7 04 24 44 df 10 c0 	movl   $0xc010df44,(%esp)
c010ae7d:	e8 53 5f ff ff       	call   c0100dd5 <__panic>
}
c010ae82:	c9                   	leave  
c010ae83:	c3                   	ret    

c010ae84 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010ae84:	55                   	push   %ebp
c010ae85:	89 e5                	mov    %esp,%ebp
c010ae87:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010ae8a:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010ae8f:	8b 40 10             	mov    0x10(%eax),%eax
c010ae92:	85 c0                	test   %eax,%eax
c010ae94:	74 07                	je     c010ae9d <cpu_idle+0x19>
            schedule();
c010ae96:	e8 fc 00 00 00       	call   c010af97 <schedule>
        }
    }
c010ae9b:	eb ed                	jmp    c010ae8a <cpu_idle+0x6>
c010ae9d:	eb eb                	jmp    c010ae8a <cpu_idle+0x6>

c010ae9f <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c010ae9f:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010aea3:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010aea5:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c010aea8:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c010aeab:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c010aeae:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c010aeb1:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010aeb4:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c010aeb7:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c010aeba:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c010aebe:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c010aec1:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010aec4:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c010aec7:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c010aeca:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c010aecd:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c010aed0:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010aed3:	ff 30                	pushl  (%eax)

    ret
c010aed5:	c3                   	ret    

c010aed6 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c010aed6:	55                   	push   %ebp
c010aed7:	89 e5                	mov    %esp,%ebp
c010aed9:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010aedc:	9c                   	pushf  
c010aedd:	58                   	pop    %eax
c010aede:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010aee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010aee4:	25 00 02 00 00       	and    $0x200,%eax
c010aee9:	85 c0                	test   %eax,%eax
c010aeeb:	74 0c                	je     c010aef9 <__intr_save+0x23>
        intr_disable();
c010aeed:	e8 3b 71 ff ff       	call   c010202d <intr_disable>
        return 1;
c010aef2:	b8 01 00 00 00       	mov    $0x1,%eax
c010aef7:	eb 05                	jmp    c010aefe <__intr_save+0x28>
    }
    return 0;
c010aef9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aefe:	c9                   	leave  
c010aeff:	c3                   	ret    

c010af00 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010af00:	55                   	push   %ebp
c010af01:	89 e5                	mov    %esp,%ebp
c010af03:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010af06:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010af0a:	74 05                	je     c010af11 <__intr_restore+0x11>
        intr_enable();
c010af0c:	e8 16 71 ff ff       	call   c0102027 <intr_enable>
    }
}
c010af11:	c9                   	leave  
c010af12:	c3                   	ret    

c010af13 <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c010af13:	55                   	push   %ebp
c010af14:	89 e5                	mov    %esp,%ebp
c010af16:	83 ec 28             	sub    $0x28,%esp
    assert(proc->state != PROC_ZOMBIE);
c010af19:	8b 45 08             	mov    0x8(%ebp),%eax
c010af1c:	8b 00                	mov    (%eax),%eax
c010af1e:	83 f8 03             	cmp    $0x3,%eax
c010af21:	75 24                	jne    c010af47 <wakeup_proc+0x34>
c010af23:	c7 44 24 0c 57 e3 10 	movl   $0xc010e357,0xc(%esp)
c010af2a:	c0 
c010af2b:	c7 44 24 08 72 e3 10 	movl   $0xc010e372,0x8(%esp)
c010af32:	c0 
c010af33:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c010af3a:	00 
c010af3b:	c7 04 24 87 e3 10 c0 	movl   $0xc010e387,(%esp)
c010af42:	e8 8e 5e ff ff       	call   c0100dd5 <__panic>
    bool intr_flag;
    local_intr_save(intr_flag);
c010af47:	e8 8a ff ff ff       	call   c010aed6 <__intr_save>
c010af4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        if (proc->state != PROC_RUNNABLE) {
c010af4f:	8b 45 08             	mov    0x8(%ebp),%eax
c010af52:	8b 00                	mov    (%eax),%eax
c010af54:	83 f8 02             	cmp    $0x2,%eax
c010af57:	74 15                	je     c010af6e <wakeup_proc+0x5b>
            proc->state = PROC_RUNNABLE;
c010af59:	8b 45 08             	mov    0x8(%ebp),%eax
c010af5c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
            proc->wait_state = 0;
c010af62:	8b 45 08             	mov    0x8(%ebp),%eax
c010af65:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
c010af6c:	eb 1c                	jmp    c010af8a <wakeup_proc+0x77>
        }
        else {
            warn("wakeup runnable process.\n");
c010af6e:	c7 44 24 08 9d e3 10 	movl   $0xc010e39d,0x8(%esp)
c010af75:	c0 
c010af76:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c010af7d:	00 
c010af7e:	c7 04 24 87 e3 10 c0 	movl   $0xc010e387,(%esp)
c010af85:	e8 b7 5e ff ff       	call   c0100e41 <__warn>
        }
    }
    local_intr_restore(intr_flag);
c010af8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010af8d:	89 04 24             	mov    %eax,(%esp)
c010af90:	e8 6b ff ff ff       	call   c010af00 <__intr_restore>
}
c010af95:	c9                   	leave  
c010af96:	c3                   	ret    

c010af97 <schedule>:

void
schedule(void) {
c010af97:	55                   	push   %ebp
c010af98:	89 e5                	mov    %esp,%ebp
c010af9a:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c010af9d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c010afa4:	e8 2d ff ff ff       	call   c010aed6 <__intr_save>
c010afa9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c010afac:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010afb1:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c010afb8:	8b 15 88 cf 19 c0    	mov    0xc019cf88,%edx
c010afbe:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010afc3:	39 c2                	cmp    %eax,%edx
c010afc5:	74 0a                	je     c010afd1 <schedule+0x3a>
c010afc7:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010afcc:	83 c0 58             	add    $0x58,%eax
c010afcf:	eb 05                	jmp    c010afd6 <schedule+0x3f>
c010afd1:	b8 b0 f0 19 c0       	mov    $0xc019f0b0,%eax
c010afd6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010afd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010afdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010afdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010afe2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010afe5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010afe8:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010afeb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010afee:	81 7d f4 b0 f0 19 c0 	cmpl   $0xc019f0b0,-0xc(%ebp)
c010aff5:	74 15                	je     c010b00c <schedule+0x75>
                next = le2proc(le, list_link);
c010aff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010affa:	83 e8 58             	sub    $0x58,%eax
c010affd:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c010b000:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b003:	8b 00                	mov    (%eax),%eax
c010b005:	83 f8 02             	cmp    $0x2,%eax
c010b008:	75 02                	jne    c010b00c <schedule+0x75>
                    break;
c010b00a:	eb 08                	jmp    c010b014 <schedule+0x7d>
                }
            }
        } while (le != last);
c010b00c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b00f:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010b012:	75 cb                	jne    c010afdf <schedule+0x48>
        if (next == NULL || next->state != PROC_RUNNABLE) {
c010b014:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b018:	74 0a                	je     c010b024 <schedule+0x8d>
c010b01a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b01d:	8b 00                	mov    (%eax),%eax
c010b01f:	83 f8 02             	cmp    $0x2,%eax
c010b022:	74 08                	je     c010b02c <schedule+0x95>
            next = idleproc;
c010b024:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010b029:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c010b02c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b02f:	8b 40 08             	mov    0x8(%eax),%eax
c010b032:	8d 50 01             	lea    0x1(%eax),%edx
c010b035:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b038:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010b03b:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010b040:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b043:	74 0b                	je     c010b050 <schedule+0xb9>
            proc_run(next);
c010b045:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b048:	89 04 24             	mov    %eax,(%esp)
c010b04b:	e8 71 e8 ff ff       	call   c01098c1 <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010b050:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b053:	89 04 24             	mov    %eax,(%esp)
c010b056:	e8 a5 fe ff ff       	call   c010af00 <__intr_restore>
}
c010b05b:	c9                   	leave  
c010b05c:	c3                   	ret    

c010b05d <sys_exit>:
#include <stdio.h>
#include <pmm.h>
#include <assert.h>

static int
sys_exit(uint32_t arg[]) {
c010b05d:	55                   	push   %ebp
c010b05e:	89 e5                	mov    %esp,%ebp
c010b060:	83 ec 28             	sub    $0x28,%esp
    int error_code = (int)arg[0];
c010b063:	8b 45 08             	mov    0x8(%ebp),%eax
c010b066:	8b 00                	mov    (%eax),%eax
c010b068:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_exit(error_code);
c010b06b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b06e:	89 04 24             	mov    %eax,(%esp)
c010b071:	e8 bc ee ff ff       	call   c0109f32 <do_exit>
}
c010b076:	c9                   	leave  
c010b077:	c3                   	ret    

c010b078 <sys_fork>:

static int
sys_fork(uint32_t arg[]) {
c010b078:	55                   	push   %ebp
c010b079:	89 e5                	mov    %esp,%ebp
c010b07b:	83 ec 28             	sub    $0x28,%esp
    struct trapframe *tf = current->tf;
c010b07e:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010b083:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b086:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uintptr_t stack = tf->tf_esp;
c010b089:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b08c:	8b 40 44             	mov    0x44(%eax),%eax
c010b08f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_fork(0, stack, tf);
c010b092:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b095:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b099:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b09c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b0a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010b0a7:	e8 58 ed ff ff       	call   c0109e04 <do_fork>
}
c010b0ac:	c9                   	leave  
c010b0ad:	c3                   	ret    

c010b0ae <sys_wait>:

static int
sys_wait(uint32_t arg[]) {
c010b0ae:	55                   	push   %ebp
c010b0af:	89 e5                	mov    %esp,%ebp
c010b0b1:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b0b4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0b7:	8b 00                	mov    (%eax),%eax
c010b0b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int *store = (int *)arg[1];
c010b0bc:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0bf:	83 c0 04             	add    $0x4,%eax
c010b0c2:	8b 00                	mov    (%eax),%eax
c010b0c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_wait(pid, store);
c010b0c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b0ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b0ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b0d1:	89 04 24             	mov    %eax,(%esp)
c010b0d4:	e8 d7 f7 ff ff       	call   c010a8b0 <do_wait>
}
c010b0d9:	c9                   	leave  
c010b0da:	c3                   	ret    

c010b0db <sys_exec>:

static int
sys_exec(uint32_t arg[]) {
c010b0db:	55                   	push   %ebp
c010b0dc:	89 e5                	mov    %esp,%ebp
c010b0de:	83 ec 28             	sub    $0x28,%esp
    const char *name = (const char *)arg[0];
c010b0e1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0e4:	8b 00                	mov    (%eax),%eax
c010b0e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t len = (size_t)arg[1];
c010b0e9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0ec:	8b 40 04             	mov    0x4(%eax),%eax
c010b0ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned char *binary = (unsigned char *)arg[2];
c010b0f2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0f5:	83 c0 08             	add    $0x8,%eax
c010b0f8:	8b 00                	mov    (%eax),%eax
c010b0fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t size = (size_t)arg[3];
c010b0fd:	8b 45 08             	mov    0x8(%ebp),%eax
c010b100:	8b 40 0c             	mov    0xc(%eax),%eax
c010b103:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return do_execve(name, len, binary, size);
c010b106:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b109:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b10d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b110:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b114:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b117:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b11b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b11e:	89 04 24             	mov    %eax,(%esp)
c010b121:	e8 3e f6 ff ff       	call   c010a764 <do_execve>
}
c010b126:	c9                   	leave  
c010b127:	c3                   	ret    

c010b128 <sys_yield>:

static int
sys_yield(uint32_t arg[]) {
c010b128:	55                   	push   %ebp
c010b129:	89 e5                	mov    %esp,%ebp
c010b12b:	83 ec 08             	sub    $0x8,%esp
    return do_yield();
c010b12e:	e8 67 f7 ff ff       	call   c010a89a <do_yield>
}
c010b133:	c9                   	leave  
c010b134:	c3                   	ret    

c010b135 <sys_kill>:

static int
sys_kill(uint32_t arg[]) {
c010b135:	55                   	push   %ebp
c010b136:	89 e5                	mov    %esp,%ebp
c010b138:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b13b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b13e:	8b 00                	mov    (%eax),%eax
c010b140:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_kill(pid);
c010b143:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b146:	89 04 24             	mov    %eax,(%esp)
c010b149:	e8 f6 f8 ff ff       	call   c010aa44 <do_kill>
}
c010b14e:	c9                   	leave  
c010b14f:	c3                   	ret    

c010b150 <sys_getpid>:

static int
sys_getpid(uint32_t arg[]) {
c010b150:	55                   	push   %ebp
c010b151:	89 e5                	mov    %esp,%ebp
    return current->pid;
c010b153:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010b158:	8b 40 04             	mov    0x4(%eax),%eax
}
c010b15b:	5d                   	pop    %ebp
c010b15c:	c3                   	ret    

c010b15d <sys_putc>:

static int
sys_putc(uint32_t arg[]) {
c010b15d:	55                   	push   %ebp
c010b15e:	89 e5                	mov    %esp,%ebp
c010b160:	83 ec 28             	sub    $0x28,%esp
    int c = (int)arg[0];
c010b163:	8b 45 08             	mov    0x8(%ebp),%eax
c010b166:	8b 00                	mov    (%eax),%eax
c010b168:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cputchar(c);
c010b16b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b16e:	89 04 24             	mov    %eax,(%esp)
c010b171:	e8 03 52 ff ff       	call   c0100379 <cputchar>
    return 0;
c010b176:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b17b:	c9                   	leave  
c010b17c:	c3                   	ret    

c010b17d <sys_pgdir>:

static int
sys_pgdir(uint32_t arg[]) {
c010b17d:	55                   	push   %ebp
c010b17e:	89 e5                	mov    %esp,%ebp
c010b180:	83 ec 08             	sub    $0x8,%esp
    print_pgdir();
c010b183:	e8 e4 b9 ff ff       	call   c0106b6c <print_pgdir>
    return 0;
c010b188:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b18d:	c9                   	leave  
c010b18e:	c3                   	ret    

c010b18f <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
c010b18f:	55                   	push   %ebp
c010b190:	89 e5                	mov    %esp,%ebp
c010b192:	83 ec 48             	sub    $0x48,%esp
    struct trapframe *tf = current->tf;
c010b195:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010b19a:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b19d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t arg[5];
    int num = tf->tf_regs.reg_eax;
c010b1a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1a3:	8b 40 1c             	mov    0x1c(%eax),%eax
c010b1a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num >= 0 && num < NUM_SYSCALLS) {
c010b1a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b1ad:	78 5e                	js     c010b20d <syscall+0x7e>
c010b1af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1b2:	83 f8 1f             	cmp    $0x1f,%eax
c010b1b5:	77 56                	ja     c010b20d <syscall+0x7e>
        if (syscalls[num] != NULL) {
c010b1b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1ba:	8b 04 85 a0 aa 12 c0 	mov    -0x3fed5560(,%eax,4),%eax
c010b1c1:	85 c0                	test   %eax,%eax
c010b1c3:	74 48                	je     c010b20d <syscall+0x7e>
            arg[0] = tf->tf_regs.reg_edx;
c010b1c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1c8:	8b 40 14             	mov    0x14(%eax),%eax
c010b1cb:	89 45 dc             	mov    %eax,-0x24(%ebp)
            arg[1] = tf->tf_regs.reg_ecx;
c010b1ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1d1:	8b 40 18             	mov    0x18(%eax),%eax
c010b1d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
            arg[2] = tf->tf_regs.reg_ebx;
c010b1d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1da:	8b 40 10             	mov    0x10(%eax),%eax
c010b1dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            arg[3] = tf->tf_regs.reg_edi;
c010b1e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1e3:	8b 00                	mov    (%eax),%eax
c010b1e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
            arg[4] = tf->tf_regs.reg_esi;
c010b1e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1eb:	8b 40 04             	mov    0x4(%eax),%eax
c010b1ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
            tf->tf_regs.reg_eax = syscalls[num](arg);
c010b1f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1f4:	8b 04 85 a0 aa 12 c0 	mov    -0x3fed5560(,%eax,4),%eax
c010b1fb:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010b1fe:	89 14 24             	mov    %edx,(%esp)
c010b201:	ff d0                	call   *%eax
c010b203:	89 c2                	mov    %eax,%edx
c010b205:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b208:	89 50 1c             	mov    %edx,0x1c(%eax)
            return ;
c010b20b:	eb 46                	jmp    c010b253 <syscall+0xc4>
        }
    }
    print_trapframe(tf);
c010b20d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b210:	89 04 24             	mov    %eax,(%esp)
c010b213:	e8 d2 71 ff ff       	call   c01023ea <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
c010b218:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010b21d:	8d 50 48             	lea    0x48(%eax),%edx
c010b220:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010b225:	8b 40 04             	mov    0x4(%eax),%eax
c010b228:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b22c:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b230:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b233:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b237:	c7 44 24 08 b8 e3 10 	movl   $0xc010e3b8,0x8(%esp)
c010b23e:	c0 
c010b23f:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c010b246:	00 
c010b247:	c7 04 24 e4 e3 10 c0 	movl   $0xc010e3e4,(%esp)
c010b24e:	e8 82 5b ff ff       	call   c0100dd5 <__panic>
            num, current->pid, current->name);
}
c010b253:	c9                   	leave  
c010b254:	c3                   	ret    

c010b255 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010b255:	55                   	push   %ebp
c010b256:	89 e5                	mov    %esp,%ebp
c010b258:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010b25b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b25e:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010b264:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010b267:	b8 20 00 00 00       	mov    $0x20,%eax
c010b26c:	2b 45 0c             	sub    0xc(%ebp),%eax
c010b26f:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010b272:	89 c1                	mov    %eax,%ecx
c010b274:	d3 ea                	shr    %cl,%edx
c010b276:	89 d0                	mov    %edx,%eax
}
c010b278:	c9                   	leave  
c010b279:	c3                   	ret    

c010b27a <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010b27a:	55                   	push   %ebp
c010b27b:	89 e5                	mov    %esp,%ebp
c010b27d:	83 ec 58             	sub    $0x58,%esp
c010b280:	8b 45 10             	mov    0x10(%ebp),%eax
c010b283:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010b286:	8b 45 14             	mov    0x14(%ebp),%eax
c010b289:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010b28c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010b28f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010b292:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b295:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010b298:	8b 45 18             	mov    0x18(%ebp),%eax
c010b29b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b29e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b2a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b2a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b2a7:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b2aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b2ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b2b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b2b4:	74 1c                	je     c010b2d2 <printnum+0x58>
c010b2b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b2b9:	ba 00 00 00 00       	mov    $0x0,%edx
c010b2be:	f7 75 e4             	divl   -0x1c(%ebp)
c010b2c1:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010b2c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b2c7:	ba 00 00 00 00       	mov    $0x0,%edx
c010b2cc:	f7 75 e4             	divl   -0x1c(%ebp)
c010b2cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b2d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b2d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b2d8:	f7 75 e4             	divl   -0x1c(%ebp)
c010b2db:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b2de:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010b2e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b2e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b2e7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b2ea:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010b2ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b2f0:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010b2f3:	8b 45 18             	mov    0x18(%ebp),%eax
c010b2f6:	ba 00 00 00 00       	mov    $0x0,%edx
c010b2fb:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010b2fe:	77 56                	ja     c010b356 <printnum+0xdc>
c010b300:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010b303:	72 05                	jb     c010b30a <printnum+0x90>
c010b305:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010b308:	77 4c                	ja     c010b356 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010b30a:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010b30d:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b310:	8b 45 20             	mov    0x20(%ebp),%eax
c010b313:	89 44 24 18          	mov    %eax,0x18(%esp)
c010b317:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b31b:	8b 45 18             	mov    0x18(%ebp),%eax
c010b31e:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b322:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b325:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b328:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b32c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010b330:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b333:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b337:	8b 45 08             	mov    0x8(%ebp),%eax
c010b33a:	89 04 24             	mov    %eax,(%esp)
c010b33d:	e8 38 ff ff ff       	call   c010b27a <printnum>
c010b342:	eb 1c                	jmp    c010b360 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010b344:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b347:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b34b:	8b 45 20             	mov    0x20(%ebp),%eax
c010b34e:	89 04 24             	mov    %eax,(%esp)
c010b351:	8b 45 08             	mov    0x8(%ebp),%eax
c010b354:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010b356:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010b35a:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010b35e:	7f e4                	jg     c010b344 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010b360:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b363:	05 04 e5 10 c0       	add    $0xc010e504,%eax
c010b368:	0f b6 00             	movzbl (%eax),%eax
c010b36b:	0f be c0             	movsbl %al,%eax
c010b36e:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b371:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b375:	89 04 24             	mov    %eax,(%esp)
c010b378:	8b 45 08             	mov    0x8(%ebp),%eax
c010b37b:	ff d0                	call   *%eax
}
c010b37d:	c9                   	leave  
c010b37e:	c3                   	ret    

c010b37f <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010b37f:	55                   	push   %ebp
c010b380:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b382:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b386:	7e 14                	jle    c010b39c <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010b388:	8b 45 08             	mov    0x8(%ebp),%eax
c010b38b:	8b 00                	mov    (%eax),%eax
c010b38d:	8d 48 08             	lea    0x8(%eax),%ecx
c010b390:	8b 55 08             	mov    0x8(%ebp),%edx
c010b393:	89 0a                	mov    %ecx,(%edx)
c010b395:	8b 50 04             	mov    0x4(%eax),%edx
c010b398:	8b 00                	mov    (%eax),%eax
c010b39a:	eb 30                	jmp    c010b3cc <getuint+0x4d>
    }
    else if (lflag) {
c010b39c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b3a0:	74 16                	je     c010b3b8 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010b3a2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3a5:	8b 00                	mov    (%eax),%eax
c010b3a7:	8d 48 04             	lea    0x4(%eax),%ecx
c010b3aa:	8b 55 08             	mov    0x8(%ebp),%edx
c010b3ad:	89 0a                	mov    %ecx,(%edx)
c010b3af:	8b 00                	mov    (%eax),%eax
c010b3b1:	ba 00 00 00 00       	mov    $0x0,%edx
c010b3b6:	eb 14                	jmp    c010b3cc <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010b3b8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3bb:	8b 00                	mov    (%eax),%eax
c010b3bd:	8d 48 04             	lea    0x4(%eax),%ecx
c010b3c0:	8b 55 08             	mov    0x8(%ebp),%edx
c010b3c3:	89 0a                	mov    %ecx,(%edx)
c010b3c5:	8b 00                	mov    (%eax),%eax
c010b3c7:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010b3cc:	5d                   	pop    %ebp
c010b3cd:	c3                   	ret    

c010b3ce <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010b3ce:	55                   	push   %ebp
c010b3cf:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b3d1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b3d5:	7e 14                	jle    c010b3eb <getint+0x1d>
        return va_arg(*ap, long long);
c010b3d7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3da:	8b 00                	mov    (%eax),%eax
c010b3dc:	8d 48 08             	lea    0x8(%eax),%ecx
c010b3df:	8b 55 08             	mov    0x8(%ebp),%edx
c010b3e2:	89 0a                	mov    %ecx,(%edx)
c010b3e4:	8b 50 04             	mov    0x4(%eax),%edx
c010b3e7:	8b 00                	mov    (%eax),%eax
c010b3e9:	eb 28                	jmp    c010b413 <getint+0x45>
    }
    else if (lflag) {
c010b3eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b3ef:	74 12                	je     c010b403 <getint+0x35>
        return va_arg(*ap, long);
c010b3f1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3f4:	8b 00                	mov    (%eax),%eax
c010b3f6:	8d 48 04             	lea    0x4(%eax),%ecx
c010b3f9:	8b 55 08             	mov    0x8(%ebp),%edx
c010b3fc:	89 0a                	mov    %ecx,(%edx)
c010b3fe:	8b 00                	mov    (%eax),%eax
c010b400:	99                   	cltd   
c010b401:	eb 10                	jmp    c010b413 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010b403:	8b 45 08             	mov    0x8(%ebp),%eax
c010b406:	8b 00                	mov    (%eax),%eax
c010b408:	8d 48 04             	lea    0x4(%eax),%ecx
c010b40b:	8b 55 08             	mov    0x8(%ebp),%edx
c010b40e:	89 0a                	mov    %ecx,(%edx)
c010b410:	8b 00                	mov    (%eax),%eax
c010b412:	99                   	cltd   
    }
}
c010b413:	5d                   	pop    %ebp
c010b414:	c3                   	ret    

c010b415 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010b415:	55                   	push   %ebp
c010b416:	89 e5                	mov    %esp,%ebp
c010b418:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010b41b:	8d 45 14             	lea    0x14(%ebp),%eax
c010b41e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010b421:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b424:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b428:	8b 45 10             	mov    0x10(%ebp),%eax
c010b42b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b42f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b432:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b436:	8b 45 08             	mov    0x8(%ebp),%eax
c010b439:	89 04 24             	mov    %eax,(%esp)
c010b43c:	e8 02 00 00 00       	call   c010b443 <vprintfmt>
    va_end(ap);
}
c010b441:	c9                   	leave  
c010b442:	c3                   	ret    

c010b443 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010b443:	55                   	push   %ebp
c010b444:	89 e5                	mov    %esp,%ebp
c010b446:	56                   	push   %esi
c010b447:	53                   	push   %ebx
c010b448:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b44b:	eb 18                	jmp    c010b465 <vprintfmt+0x22>
            if (ch == '\0') {
c010b44d:	85 db                	test   %ebx,%ebx
c010b44f:	75 05                	jne    c010b456 <vprintfmt+0x13>
                return;
c010b451:	e9 d1 03 00 00       	jmp    c010b827 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c010b456:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b459:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b45d:	89 1c 24             	mov    %ebx,(%esp)
c010b460:	8b 45 08             	mov    0x8(%ebp),%eax
c010b463:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b465:	8b 45 10             	mov    0x10(%ebp),%eax
c010b468:	8d 50 01             	lea    0x1(%eax),%edx
c010b46b:	89 55 10             	mov    %edx,0x10(%ebp)
c010b46e:	0f b6 00             	movzbl (%eax),%eax
c010b471:	0f b6 d8             	movzbl %al,%ebx
c010b474:	83 fb 25             	cmp    $0x25,%ebx
c010b477:	75 d4                	jne    c010b44d <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010b479:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010b47d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010b484:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b487:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010b48a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010b491:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b494:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010b497:	8b 45 10             	mov    0x10(%ebp),%eax
c010b49a:	8d 50 01             	lea    0x1(%eax),%edx
c010b49d:	89 55 10             	mov    %edx,0x10(%ebp)
c010b4a0:	0f b6 00             	movzbl (%eax),%eax
c010b4a3:	0f b6 d8             	movzbl %al,%ebx
c010b4a6:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010b4a9:	83 f8 55             	cmp    $0x55,%eax
c010b4ac:	0f 87 44 03 00 00    	ja     c010b7f6 <vprintfmt+0x3b3>
c010b4b2:	8b 04 85 28 e5 10 c0 	mov    -0x3fef1ad8(,%eax,4),%eax
c010b4b9:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010b4bb:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010b4bf:	eb d6                	jmp    c010b497 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010b4c1:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010b4c5:	eb d0                	jmp    c010b497 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010b4c7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010b4ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b4d1:	89 d0                	mov    %edx,%eax
c010b4d3:	c1 e0 02             	shl    $0x2,%eax
c010b4d6:	01 d0                	add    %edx,%eax
c010b4d8:	01 c0                	add    %eax,%eax
c010b4da:	01 d8                	add    %ebx,%eax
c010b4dc:	83 e8 30             	sub    $0x30,%eax
c010b4df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010b4e2:	8b 45 10             	mov    0x10(%ebp),%eax
c010b4e5:	0f b6 00             	movzbl (%eax),%eax
c010b4e8:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010b4eb:	83 fb 2f             	cmp    $0x2f,%ebx
c010b4ee:	7e 0b                	jle    c010b4fb <vprintfmt+0xb8>
c010b4f0:	83 fb 39             	cmp    $0x39,%ebx
c010b4f3:	7f 06                	jg     c010b4fb <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010b4f5:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c010b4f9:	eb d3                	jmp    c010b4ce <vprintfmt+0x8b>
            goto process_precision;
c010b4fb:	eb 33                	jmp    c010b530 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c010b4fd:	8b 45 14             	mov    0x14(%ebp),%eax
c010b500:	8d 50 04             	lea    0x4(%eax),%edx
c010b503:	89 55 14             	mov    %edx,0x14(%ebp)
c010b506:	8b 00                	mov    (%eax),%eax
c010b508:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010b50b:	eb 23                	jmp    c010b530 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c010b50d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b511:	79 0c                	jns    c010b51f <vprintfmt+0xdc>
                width = 0;
c010b513:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010b51a:	e9 78 ff ff ff       	jmp    c010b497 <vprintfmt+0x54>
c010b51f:	e9 73 ff ff ff       	jmp    c010b497 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010b524:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010b52b:	e9 67 ff ff ff       	jmp    c010b497 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010b530:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b534:	79 12                	jns    c010b548 <vprintfmt+0x105>
                width = precision, precision = -1;
c010b536:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b539:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b53c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010b543:	e9 4f ff ff ff       	jmp    c010b497 <vprintfmt+0x54>
c010b548:	e9 4a ff ff ff       	jmp    c010b497 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010b54d:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010b551:	e9 41 ff ff ff       	jmp    c010b497 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010b556:	8b 45 14             	mov    0x14(%ebp),%eax
c010b559:	8d 50 04             	lea    0x4(%eax),%edx
c010b55c:	89 55 14             	mov    %edx,0x14(%ebp)
c010b55f:	8b 00                	mov    (%eax),%eax
c010b561:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b564:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b568:	89 04 24             	mov    %eax,(%esp)
c010b56b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b56e:	ff d0                	call   *%eax
            break;
c010b570:	e9 ac 02 00 00       	jmp    c010b821 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010b575:	8b 45 14             	mov    0x14(%ebp),%eax
c010b578:	8d 50 04             	lea    0x4(%eax),%edx
c010b57b:	89 55 14             	mov    %edx,0x14(%ebp)
c010b57e:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010b580:	85 db                	test   %ebx,%ebx
c010b582:	79 02                	jns    c010b586 <vprintfmt+0x143>
                err = -err;
c010b584:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010b586:	83 fb 18             	cmp    $0x18,%ebx
c010b589:	7f 0b                	jg     c010b596 <vprintfmt+0x153>
c010b58b:	8b 34 9d a0 e4 10 c0 	mov    -0x3fef1b60(,%ebx,4),%esi
c010b592:	85 f6                	test   %esi,%esi
c010b594:	75 23                	jne    c010b5b9 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c010b596:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010b59a:	c7 44 24 08 15 e5 10 	movl   $0xc010e515,0x8(%esp)
c010b5a1:	c0 
c010b5a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b5a5:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b5a9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5ac:	89 04 24             	mov    %eax,(%esp)
c010b5af:	e8 61 fe ff ff       	call   c010b415 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010b5b4:	e9 68 02 00 00       	jmp    c010b821 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010b5b9:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010b5bd:	c7 44 24 08 1e e5 10 	movl   $0xc010e51e,0x8(%esp)
c010b5c4:	c0 
c010b5c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b5c8:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b5cc:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5cf:	89 04 24             	mov    %eax,(%esp)
c010b5d2:	e8 3e fe ff ff       	call   c010b415 <printfmt>
            }
            break;
c010b5d7:	e9 45 02 00 00       	jmp    c010b821 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010b5dc:	8b 45 14             	mov    0x14(%ebp),%eax
c010b5df:	8d 50 04             	lea    0x4(%eax),%edx
c010b5e2:	89 55 14             	mov    %edx,0x14(%ebp)
c010b5e5:	8b 30                	mov    (%eax),%esi
c010b5e7:	85 f6                	test   %esi,%esi
c010b5e9:	75 05                	jne    c010b5f0 <vprintfmt+0x1ad>
                p = "(null)";
c010b5eb:	be 21 e5 10 c0       	mov    $0xc010e521,%esi
            }
            if (width > 0 && padc != '-') {
c010b5f0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b5f4:	7e 3e                	jle    c010b634 <vprintfmt+0x1f1>
c010b5f6:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010b5fa:	74 38                	je     c010b634 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010b5fc:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010b5ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b602:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b606:	89 34 24             	mov    %esi,(%esp)
c010b609:	e8 ed 03 00 00       	call   c010b9fb <strnlen>
c010b60e:	29 c3                	sub    %eax,%ebx
c010b610:	89 d8                	mov    %ebx,%eax
c010b612:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b615:	eb 17                	jmp    c010b62e <vprintfmt+0x1eb>
                    putch(padc, putdat);
c010b617:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010b61b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b61e:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b622:	89 04 24             	mov    %eax,(%esp)
c010b625:	8b 45 08             	mov    0x8(%ebp),%eax
c010b628:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c010b62a:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010b62e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b632:	7f e3                	jg     c010b617 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010b634:	eb 38                	jmp    c010b66e <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c010b636:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010b63a:	74 1f                	je     c010b65b <vprintfmt+0x218>
c010b63c:	83 fb 1f             	cmp    $0x1f,%ebx
c010b63f:	7e 05                	jle    c010b646 <vprintfmt+0x203>
c010b641:	83 fb 7e             	cmp    $0x7e,%ebx
c010b644:	7e 15                	jle    c010b65b <vprintfmt+0x218>
                    putch('?', putdat);
c010b646:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b649:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b64d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010b654:	8b 45 08             	mov    0x8(%ebp),%eax
c010b657:	ff d0                	call   *%eax
c010b659:	eb 0f                	jmp    c010b66a <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c010b65b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b65e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b662:	89 1c 24             	mov    %ebx,(%esp)
c010b665:	8b 45 08             	mov    0x8(%ebp),%eax
c010b668:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010b66a:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010b66e:	89 f0                	mov    %esi,%eax
c010b670:	8d 70 01             	lea    0x1(%eax),%esi
c010b673:	0f b6 00             	movzbl (%eax),%eax
c010b676:	0f be d8             	movsbl %al,%ebx
c010b679:	85 db                	test   %ebx,%ebx
c010b67b:	74 10                	je     c010b68d <vprintfmt+0x24a>
c010b67d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010b681:	78 b3                	js     c010b636 <vprintfmt+0x1f3>
c010b683:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010b687:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010b68b:	79 a9                	jns    c010b636 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010b68d:	eb 17                	jmp    c010b6a6 <vprintfmt+0x263>
                putch(' ', putdat);
c010b68f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b692:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b696:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010b69d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6a0:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010b6a2:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010b6a6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b6aa:	7f e3                	jg     c010b68f <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c010b6ac:	e9 70 01 00 00       	jmp    c010b821 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010b6b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b6b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b6b8:	8d 45 14             	lea    0x14(%ebp),%eax
c010b6bb:	89 04 24             	mov    %eax,(%esp)
c010b6be:	e8 0b fd ff ff       	call   c010b3ce <getint>
c010b6c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b6c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010b6c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b6cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b6cf:	85 d2                	test   %edx,%edx
c010b6d1:	79 26                	jns    c010b6f9 <vprintfmt+0x2b6>
                putch('-', putdat);
c010b6d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b6d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b6da:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010b6e1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6e4:	ff d0                	call   *%eax
                num = -(long long)num;
c010b6e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b6e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b6ec:	f7 d8                	neg    %eax
c010b6ee:	83 d2 00             	adc    $0x0,%edx
c010b6f1:	f7 da                	neg    %edx
c010b6f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b6f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010b6f9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010b700:	e9 a8 00 00 00       	jmp    c010b7ad <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010b705:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b708:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b70c:	8d 45 14             	lea    0x14(%ebp),%eax
c010b70f:	89 04 24             	mov    %eax,(%esp)
c010b712:	e8 68 fc ff ff       	call   c010b37f <getuint>
c010b717:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b71a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010b71d:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010b724:	e9 84 00 00 00       	jmp    c010b7ad <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010b729:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b72c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b730:	8d 45 14             	lea    0x14(%ebp),%eax
c010b733:	89 04 24             	mov    %eax,(%esp)
c010b736:	e8 44 fc ff ff       	call   c010b37f <getuint>
c010b73b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b73e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010b741:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010b748:	eb 63                	jmp    c010b7ad <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c010b74a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b74d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b751:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010b758:	8b 45 08             	mov    0x8(%ebp),%eax
c010b75b:	ff d0                	call   *%eax
            putch('x', putdat);
c010b75d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b760:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b764:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010b76b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b76e:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010b770:	8b 45 14             	mov    0x14(%ebp),%eax
c010b773:	8d 50 04             	lea    0x4(%eax),%edx
c010b776:	89 55 14             	mov    %edx,0x14(%ebp)
c010b779:	8b 00                	mov    (%eax),%eax
c010b77b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b77e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010b785:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010b78c:	eb 1f                	jmp    c010b7ad <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010b78e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b791:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b795:	8d 45 14             	lea    0x14(%ebp),%eax
c010b798:	89 04 24             	mov    %eax,(%esp)
c010b79b:	e8 df fb ff ff       	call   c010b37f <getuint>
c010b7a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b7a3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010b7a6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010b7ad:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010b7b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b7b4:	89 54 24 18          	mov    %edx,0x18(%esp)
c010b7b8:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b7bb:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b7bf:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b7c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b7c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b7c9:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b7cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010b7d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b7d8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7db:	89 04 24             	mov    %eax,(%esp)
c010b7de:	e8 97 fa ff ff       	call   c010b27a <printnum>
            break;
c010b7e3:	eb 3c                	jmp    c010b821 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010b7e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b7ec:	89 1c 24             	mov    %ebx,(%esp)
c010b7ef:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7f2:	ff d0                	call   *%eax
            break;
c010b7f4:	eb 2b                	jmp    c010b821 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010b7f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7f9:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b7fd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010b804:	8b 45 08             	mov    0x8(%ebp),%eax
c010b807:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010b809:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010b80d:	eb 04                	jmp    c010b813 <vprintfmt+0x3d0>
c010b80f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010b813:	8b 45 10             	mov    0x10(%ebp),%eax
c010b816:	83 e8 01             	sub    $0x1,%eax
c010b819:	0f b6 00             	movzbl (%eax),%eax
c010b81c:	3c 25                	cmp    $0x25,%al
c010b81e:	75 ef                	jne    c010b80f <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c010b820:	90                   	nop
        }
    }
c010b821:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b822:	e9 3e fc ff ff       	jmp    c010b465 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c010b827:	83 c4 40             	add    $0x40,%esp
c010b82a:	5b                   	pop    %ebx
c010b82b:	5e                   	pop    %esi
c010b82c:	5d                   	pop    %ebp
c010b82d:	c3                   	ret    

c010b82e <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010b82e:	55                   	push   %ebp
c010b82f:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010b831:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b834:	8b 40 08             	mov    0x8(%eax),%eax
c010b837:	8d 50 01             	lea    0x1(%eax),%edx
c010b83a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b83d:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010b840:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b843:	8b 10                	mov    (%eax),%edx
c010b845:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b848:	8b 40 04             	mov    0x4(%eax),%eax
c010b84b:	39 c2                	cmp    %eax,%edx
c010b84d:	73 12                	jae    c010b861 <sprintputch+0x33>
        *b->buf ++ = ch;
c010b84f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b852:	8b 00                	mov    (%eax),%eax
c010b854:	8d 48 01             	lea    0x1(%eax),%ecx
c010b857:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b85a:	89 0a                	mov    %ecx,(%edx)
c010b85c:	8b 55 08             	mov    0x8(%ebp),%edx
c010b85f:	88 10                	mov    %dl,(%eax)
    }
}
c010b861:	5d                   	pop    %ebp
c010b862:	c3                   	ret    

c010b863 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010b863:	55                   	push   %ebp
c010b864:	89 e5                	mov    %esp,%ebp
c010b866:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010b869:	8d 45 14             	lea    0x14(%ebp),%eax
c010b86c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010b86f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b872:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b876:	8b 45 10             	mov    0x10(%ebp),%eax
c010b879:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b87d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b880:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b884:	8b 45 08             	mov    0x8(%ebp),%eax
c010b887:	89 04 24             	mov    %eax,(%esp)
c010b88a:	e8 08 00 00 00       	call   c010b897 <vsnprintf>
c010b88f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010b892:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010b895:	c9                   	leave  
c010b896:	c3                   	ret    

c010b897 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010b897:	55                   	push   %ebp
c010b898:	89 e5                	mov    %esp,%ebp
c010b89a:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010b89d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b8a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b8a6:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b8a9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8ac:	01 d0                	add    %edx,%eax
c010b8ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b8b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010b8b8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b8bc:	74 0a                	je     c010b8c8 <vsnprintf+0x31>
c010b8be:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b8c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b8c4:	39 c2                	cmp    %eax,%edx
c010b8c6:	76 07                	jbe    c010b8cf <vsnprintf+0x38>
        return -E_INVAL;
c010b8c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010b8cd:	eb 2a                	jmp    c010b8f9 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010b8cf:	8b 45 14             	mov    0x14(%ebp),%eax
c010b8d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b8d6:	8b 45 10             	mov    0x10(%ebp),%eax
c010b8d9:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b8dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010b8e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b8e4:	c7 04 24 2e b8 10 c0 	movl   $0xc010b82e,(%esp)
c010b8eb:	e8 53 fb ff ff       	call   c010b443 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010b8f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b8f3:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010b8f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010b8f9:	c9                   	leave  
c010b8fa:	c3                   	ret    

c010b8fb <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010b8fb:	55                   	push   %ebp
c010b8fc:	89 e5                	mov    %esp,%ebp
c010b8fe:	57                   	push   %edi
c010b8ff:	56                   	push   %esi
c010b900:	53                   	push   %ebx
c010b901:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010b904:	a1 20 ab 12 c0       	mov    0xc012ab20,%eax
c010b909:	8b 15 24 ab 12 c0    	mov    0xc012ab24,%edx
c010b90f:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010b915:	6b f0 05             	imul   $0x5,%eax,%esi
c010b918:	01 f7                	add    %esi,%edi
c010b91a:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c010b91f:	f7 e6                	mul    %esi
c010b921:	8d 34 17             	lea    (%edi,%edx,1),%esi
c010b924:	89 f2                	mov    %esi,%edx
c010b926:	83 c0 0b             	add    $0xb,%eax
c010b929:	83 d2 00             	adc    $0x0,%edx
c010b92c:	89 c7                	mov    %eax,%edi
c010b92e:	83 e7 ff             	and    $0xffffffff,%edi
c010b931:	89 f9                	mov    %edi,%ecx
c010b933:	0f b7 da             	movzwl %dx,%ebx
c010b936:	89 0d 20 ab 12 c0    	mov    %ecx,0xc012ab20
c010b93c:	89 1d 24 ab 12 c0    	mov    %ebx,0xc012ab24
    unsigned long long result = (next >> 12);
c010b942:	a1 20 ab 12 c0       	mov    0xc012ab20,%eax
c010b947:	8b 15 24 ab 12 c0    	mov    0xc012ab24,%edx
c010b94d:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010b951:	c1 ea 0c             	shr    $0xc,%edx
c010b954:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b957:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010b95a:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010b961:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b964:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b967:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010b96a:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010b96d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b970:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b973:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b977:	74 1c                	je     c010b995 <rand+0x9a>
c010b979:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b97c:	ba 00 00 00 00       	mov    $0x0,%edx
c010b981:	f7 75 dc             	divl   -0x24(%ebp)
c010b984:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010b987:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b98a:	ba 00 00 00 00       	mov    $0x0,%edx
c010b98f:	f7 75 dc             	divl   -0x24(%ebp)
c010b992:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b995:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b998:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b99b:	f7 75 dc             	divl   -0x24(%ebp)
c010b99e:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010b9a1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010b9a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b9a7:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b9aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b9ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010b9b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010b9b3:	83 c4 24             	add    $0x24,%esp
c010b9b6:	5b                   	pop    %ebx
c010b9b7:	5e                   	pop    %esi
c010b9b8:	5f                   	pop    %edi
c010b9b9:	5d                   	pop    %ebp
c010b9ba:	c3                   	ret    

c010b9bb <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010b9bb:	55                   	push   %ebp
c010b9bc:	89 e5                	mov    %esp,%ebp
    next = seed;
c010b9be:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9c1:	ba 00 00 00 00       	mov    $0x0,%edx
c010b9c6:	a3 20 ab 12 c0       	mov    %eax,0xc012ab20
c010b9cb:	89 15 24 ab 12 c0    	mov    %edx,0xc012ab24
}
c010b9d1:	5d                   	pop    %ebp
c010b9d2:	c3                   	ret    

c010b9d3 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010b9d3:	55                   	push   %ebp
c010b9d4:	89 e5                	mov    %esp,%ebp
c010b9d6:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010b9d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010b9e0:	eb 04                	jmp    c010b9e6 <strlen+0x13>
        cnt ++;
c010b9e2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c010b9e6:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9e9:	8d 50 01             	lea    0x1(%eax),%edx
c010b9ec:	89 55 08             	mov    %edx,0x8(%ebp)
c010b9ef:	0f b6 00             	movzbl (%eax),%eax
c010b9f2:	84 c0                	test   %al,%al
c010b9f4:	75 ec                	jne    c010b9e2 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c010b9f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b9f9:	c9                   	leave  
c010b9fa:	c3                   	ret    

c010b9fb <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010b9fb:	55                   	push   %ebp
c010b9fc:	89 e5                	mov    %esp,%ebp
c010b9fe:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010ba01:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010ba08:	eb 04                	jmp    c010ba0e <strnlen+0x13>
        cnt ++;
c010ba0a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010ba0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010ba11:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010ba14:	73 10                	jae    c010ba26 <strnlen+0x2b>
c010ba16:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba19:	8d 50 01             	lea    0x1(%eax),%edx
c010ba1c:	89 55 08             	mov    %edx,0x8(%ebp)
c010ba1f:	0f b6 00             	movzbl (%eax),%eax
c010ba22:	84 c0                	test   %al,%al
c010ba24:	75 e4                	jne    c010ba0a <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c010ba26:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010ba29:	c9                   	leave  
c010ba2a:	c3                   	ret    

c010ba2b <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010ba2b:	55                   	push   %ebp
c010ba2c:	89 e5                	mov    %esp,%ebp
c010ba2e:	57                   	push   %edi
c010ba2f:	56                   	push   %esi
c010ba30:	83 ec 20             	sub    $0x20,%esp
c010ba33:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba36:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ba39:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010ba3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010ba42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ba45:	89 d1                	mov    %edx,%ecx
c010ba47:	89 c2                	mov    %eax,%edx
c010ba49:	89 ce                	mov    %ecx,%esi
c010ba4b:	89 d7                	mov    %edx,%edi
c010ba4d:	ac                   	lods   %ds:(%esi),%al
c010ba4e:	aa                   	stos   %al,%es:(%edi)
c010ba4f:	84 c0                	test   %al,%al
c010ba51:	75 fa                	jne    c010ba4d <strcpy+0x22>
c010ba53:	89 fa                	mov    %edi,%edx
c010ba55:	89 f1                	mov    %esi,%ecx
c010ba57:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010ba5a:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010ba5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010ba60:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010ba63:	83 c4 20             	add    $0x20,%esp
c010ba66:	5e                   	pop    %esi
c010ba67:	5f                   	pop    %edi
c010ba68:	5d                   	pop    %ebp
c010ba69:	c3                   	ret    

c010ba6a <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010ba6a:	55                   	push   %ebp
c010ba6b:	89 e5                	mov    %esp,%ebp
c010ba6d:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010ba70:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba73:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010ba76:	eb 21                	jmp    c010ba99 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c010ba78:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba7b:	0f b6 10             	movzbl (%eax),%edx
c010ba7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010ba81:	88 10                	mov    %dl,(%eax)
c010ba83:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010ba86:	0f b6 00             	movzbl (%eax),%eax
c010ba89:	84 c0                	test   %al,%al
c010ba8b:	74 04                	je     c010ba91 <strncpy+0x27>
            src ++;
c010ba8d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010ba91:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010ba95:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c010ba99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010ba9d:	75 d9                	jne    c010ba78 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010ba9f:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010baa2:	c9                   	leave  
c010baa3:	c3                   	ret    

c010baa4 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010baa4:	55                   	push   %ebp
c010baa5:	89 e5                	mov    %esp,%ebp
c010baa7:	57                   	push   %edi
c010baa8:	56                   	push   %esi
c010baa9:	83 ec 20             	sub    $0x20,%esp
c010baac:	8b 45 08             	mov    0x8(%ebp),%eax
c010baaf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bab2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bab5:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c010bab8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010babb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010babe:	89 d1                	mov    %edx,%ecx
c010bac0:	89 c2                	mov    %eax,%edx
c010bac2:	89 ce                	mov    %ecx,%esi
c010bac4:	89 d7                	mov    %edx,%edi
c010bac6:	ac                   	lods   %ds:(%esi),%al
c010bac7:	ae                   	scas   %es:(%edi),%al
c010bac8:	75 08                	jne    c010bad2 <strcmp+0x2e>
c010baca:	84 c0                	test   %al,%al
c010bacc:	75 f8                	jne    c010bac6 <strcmp+0x22>
c010bace:	31 c0                	xor    %eax,%eax
c010bad0:	eb 04                	jmp    c010bad6 <strcmp+0x32>
c010bad2:	19 c0                	sbb    %eax,%eax
c010bad4:	0c 01                	or     $0x1,%al
c010bad6:	89 fa                	mov    %edi,%edx
c010bad8:	89 f1                	mov    %esi,%ecx
c010bada:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010badd:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010bae0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c010bae3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010bae6:	83 c4 20             	add    $0x20,%esp
c010bae9:	5e                   	pop    %esi
c010baea:	5f                   	pop    %edi
c010baeb:	5d                   	pop    %ebp
c010baec:	c3                   	ret    

c010baed <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010baed:	55                   	push   %ebp
c010baee:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010baf0:	eb 0c                	jmp    c010bafe <strncmp+0x11>
        n --, s1 ++, s2 ++;
c010baf2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010baf6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bafa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010bafe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bb02:	74 1a                	je     c010bb1e <strncmp+0x31>
c010bb04:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb07:	0f b6 00             	movzbl (%eax),%eax
c010bb0a:	84 c0                	test   %al,%al
c010bb0c:	74 10                	je     c010bb1e <strncmp+0x31>
c010bb0e:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb11:	0f b6 10             	movzbl (%eax),%edx
c010bb14:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb17:	0f b6 00             	movzbl (%eax),%eax
c010bb1a:	38 c2                	cmp    %al,%dl
c010bb1c:	74 d4                	je     c010baf2 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010bb1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bb22:	74 18                	je     c010bb3c <strncmp+0x4f>
c010bb24:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb27:	0f b6 00             	movzbl (%eax),%eax
c010bb2a:	0f b6 d0             	movzbl %al,%edx
c010bb2d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb30:	0f b6 00             	movzbl (%eax),%eax
c010bb33:	0f b6 c0             	movzbl %al,%eax
c010bb36:	29 c2                	sub    %eax,%edx
c010bb38:	89 d0                	mov    %edx,%eax
c010bb3a:	eb 05                	jmp    c010bb41 <strncmp+0x54>
c010bb3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010bb41:	5d                   	pop    %ebp
c010bb42:	c3                   	ret    

c010bb43 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010bb43:	55                   	push   %ebp
c010bb44:	89 e5                	mov    %esp,%ebp
c010bb46:	83 ec 04             	sub    $0x4,%esp
c010bb49:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb4c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010bb4f:	eb 14                	jmp    c010bb65 <strchr+0x22>
        if (*s == c) {
c010bb51:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb54:	0f b6 00             	movzbl (%eax),%eax
c010bb57:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010bb5a:	75 05                	jne    c010bb61 <strchr+0x1e>
            return (char *)s;
c010bb5c:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb5f:	eb 13                	jmp    c010bb74 <strchr+0x31>
        }
        s ++;
c010bb61:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c010bb65:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb68:	0f b6 00             	movzbl (%eax),%eax
c010bb6b:	84 c0                	test   %al,%al
c010bb6d:	75 e2                	jne    c010bb51 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c010bb6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010bb74:	c9                   	leave  
c010bb75:	c3                   	ret    

c010bb76 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010bb76:	55                   	push   %ebp
c010bb77:	89 e5                	mov    %esp,%ebp
c010bb79:	83 ec 04             	sub    $0x4,%esp
c010bb7c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb7f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010bb82:	eb 11                	jmp    c010bb95 <strfind+0x1f>
        if (*s == c) {
c010bb84:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb87:	0f b6 00             	movzbl (%eax),%eax
c010bb8a:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010bb8d:	75 02                	jne    c010bb91 <strfind+0x1b>
            break;
c010bb8f:	eb 0e                	jmp    c010bb9f <strfind+0x29>
        }
        s ++;
c010bb91:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c010bb95:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb98:	0f b6 00             	movzbl (%eax),%eax
c010bb9b:	84 c0                	test   %al,%al
c010bb9d:	75 e5                	jne    c010bb84 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c010bb9f:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010bba2:	c9                   	leave  
c010bba3:	c3                   	ret    

c010bba4 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010bba4:	55                   	push   %ebp
c010bba5:	89 e5                	mov    %esp,%ebp
c010bba7:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010bbaa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010bbb1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010bbb8:	eb 04                	jmp    c010bbbe <strtol+0x1a>
        s ++;
c010bbba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010bbbe:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbc1:	0f b6 00             	movzbl (%eax),%eax
c010bbc4:	3c 20                	cmp    $0x20,%al
c010bbc6:	74 f2                	je     c010bbba <strtol+0x16>
c010bbc8:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbcb:	0f b6 00             	movzbl (%eax),%eax
c010bbce:	3c 09                	cmp    $0x9,%al
c010bbd0:	74 e8                	je     c010bbba <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c010bbd2:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbd5:	0f b6 00             	movzbl (%eax),%eax
c010bbd8:	3c 2b                	cmp    $0x2b,%al
c010bbda:	75 06                	jne    c010bbe2 <strtol+0x3e>
        s ++;
c010bbdc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bbe0:	eb 15                	jmp    c010bbf7 <strtol+0x53>
    }
    else if (*s == '-') {
c010bbe2:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbe5:	0f b6 00             	movzbl (%eax),%eax
c010bbe8:	3c 2d                	cmp    $0x2d,%al
c010bbea:	75 0b                	jne    c010bbf7 <strtol+0x53>
        s ++, neg = 1;
c010bbec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bbf0:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010bbf7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bbfb:	74 06                	je     c010bc03 <strtol+0x5f>
c010bbfd:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010bc01:	75 24                	jne    c010bc27 <strtol+0x83>
c010bc03:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc06:	0f b6 00             	movzbl (%eax),%eax
c010bc09:	3c 30                	cmp    $0x30,%al
c010bc0b:	75 1a                	jne    c010bc27 <strtol+0x83>
c010bc0d:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc10:	83 c0 01             	add    $0x1,%eax
c010bc13:	0f b6 00             	movzbl (%eax),%eax
c010bc16:	3c 78                	cmp    $0x78,%al
c010bc18:	75 0d                	jne    c010bc27 <strtol+0x83>
        s += 2, base = 16;
c010bc1a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010bc1e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010bc25:	eb 2a                	jmp    c010bc51 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c010bc27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bc2b:	75 17                	jne    c010bc44 <strtol+0xa0>
c010bc2d:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc30:	0f b6 00             	movzbl (%eax),%eax
c010bc33:	3c 30                	cmp    $0x30,%al
c010bc35:	75 0d                	jne    c010bc44 <strtol+0xa0>
        s ++, base = 8;
c010bc37:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bc3b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010bc42:	eb 0d                	jmp    c010bc51 <strtol+0xad>
    }
    else if (base == 0) {
c010bc44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bc48:	75 07                	jne    c010bc51 <strtol+0xad>
        base = 10;
c010bc4a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010bc51:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc54:	0f b6 00             	movzbl (%eax),%eax
c010bc57:	3c 2f                	cmp    $0x2f,%al
c010bc59:	7e 1b                	jle    c010bc76 <strtol+0xd2>
c010bc5b:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc5e:	0f b6 00             	movzbl (%eax),%eax
c010bc61:	3c 39                	cmp    $0x39,%al
c010bc63:	7f 11                	jg     c010bc76 <strtol+0xd2>
            dig = *s - '0';
c010bc65:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc68:	0f b6 00             	movzbl (%eax),%eax
c010bc6b:	0f be c0             	movsbl %al,%eax
c010bc6e:	83 e8 30             	sub    $0x30,%eax
c010bc71:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bc74:	eb 48                	jmp    c010bcbe <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010bc76:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc79:	0f b6 00             	movzbl (%eax),%eax
c010bc7c:	3c 60                	cmp    $0x60,%al
c010bc7e:	7e 1b                	jle    c010bc9b <strtol+0xf7>
c010bc80:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc83:	0f b6 00             	movzbl (%eax),%eax
c010bc86:	3c 7a                	cmp    $0x7a,%al
c010bc88:	7f 11                	jg     c010bc9b <strtol+0xf7>
            dig = *s - 'a' + 10;
c010bc8a:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc8d:	0f b6 00             	movzbl (%eax),%eax
c010bc90:	0f be c0             	movsbl %al,%eax
c010bc93:	83 e8 57             	sub    $0x57,%eax
c010bc96:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bc99:	eb 23                	jmp    c010bcbe <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010bc9b:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc9e:	0f b6 00             	movzbl (%eax),%eax
c010bca1:	3c 40                	cmp    $0x40,%al
c010bca3:	7e 3d                	jle    c010bce2 <strtol+0x13e>
c010bca5:	8b 45 08             	mov    0x8(%ebp),%eax
c010bca8:	0f b6 00             	movzbl (%eax),%eax
c010bcab:	3c 5a                	cmp    $0x5a,%al
c010bcad:	7f 33                	jg     c010bce2 <strtol+0x13e>
            dig = *s - 'A' + 10;
c010bcaf:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcb2:	0f b6 00             	movzbl (%eax),%eax
c010bcb5:	0f be c0             	movsbl %al,%eax
c010bcb8:	83 e8 37             	sub    $0x37,%eax
c010bcbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010bcbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bcc1:	3b 45 10             	cmp    0x10(%ebp),%eax
c010bcc4:	7c 02                	jl     c010bcc8 <strtol+0x124>
            break;
c010bcc6:	eb 1a                	jmp    c010bce2 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c010bcc8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bccc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bccf:	0f af 45 10          	imul   0x10(%ebp),%eax
c010bcd3:	89 c2                	mov    %eax,%edx
c010bcd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bcd8:	01 d0                	add    %edx,%eax
c010bcda:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010bcdd:	e9 6f ff ff ff       	jmp    c010bc51 <strtol+0xad>

    if (endptr) {
c010bce2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010bce6:	74 08                	je     c010bcf0 <strtol+0x14c>
        *endptr = (char *) s;
c010bce8:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bceb:	8b 55 08             	mov    0x8(%ebp),%edx
c010bcee:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010bcf0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010bcf4:	74 07                	je     c010bcfd <strtol+0x159>
c010bcf6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bcf9:	f7 d8                	neg    %eax
c010bcfb:	eb 03                	jmp    c010bd00 <strtol+0x15c>
c010bcfd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010bd00:	c9                   	leave  
c010bd01:	c3                   	ret    

c010bd02 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010bd02:	55                   	push   %ebp
c010bd03:	89 e5                	mov    %esp,%ebp
c010bd05:	57                   	push   %edi
c010bd06:	83 ec 24             	sub    $0x24,%esp
c010bd09:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd0c:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010bd0f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010bd13:	8b 55 08             	mov    0x8(%ebp),%edx
c010bd16:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010bd19:	88 45 f7             	mov    %al,-0x9(%ebp)
c010bd1c:	8b 45 10             	mov    0x10(%ebp),%eax
c010bd1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010bd22:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010bd25:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010bd29:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010bd2c:	89 d7                	mov    %edx,%edi
c010bd2e:	f3 aa                	rep stos %al,%es:(%edi)
c010bd30:	89 fa                	mov    %edi,%edx
c010bd32:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010bd35:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010bd38:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010bd3b:	83 c4 24             	add    $0x24,%esp
c010bd3e:	5f                   	pop    %edi
c010bd3f:	5d                   	pop    %ebp
c010bd40:	c3                   	ret    

c010bd41 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010bd41:	55                   	push   %ebp
c010bd42:	89 e5                	mov    %esp,%ebp
c010bd44:	57                   	push   %edi
c010bd45:	56                   	push   %esi
c010bd46:	53                   	push   %ebx
c010bd47:	83 ec 30             	sub    $0x30,%esp
c010bd4a:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bd50:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd53:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bd56:	8b 45 10             	mov    0x10(%ebp),%eax
c010bd59:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010bd5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bd5f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010bd62:	73 42                	jae    c010bda6 <memmove+0x65>
c010bd64:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bd67:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010bd6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bd6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bd70:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bd73:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010bd76:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010bd79:	c1 e8 02             	shr    $0x2,%eax
c010bd7c:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010bd7e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bd81:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bd84:	89 d7                	mov    %edx,%edi
c010bd86:	89 c6                	mov    %eax,%esi
c010bd88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010bd8a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010bd8d:	83 e1 03             	and    $0x3,%ecx
c010bd90:	74 02                	je     c010bd94 <memmove+0x53>
c010bd92:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010bd94:	89 f0                	mov    %esi,%eax
c010bd96:	89 fa                	mov    %edi,%edx
c010bd98:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010bd9b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010bd9e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010bda1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bda4:	eb 36                	jmp    c010bddc <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010bda6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bda9:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bdac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bdaf:	01 c2                	add    %eax,%edx
c010bdb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bdb4:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010bdb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bdba:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010bdbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bdc0:	89 c1                	mov    %eax,%ecx
c010bdc2:	89 d8                	mov    %ebx,%eax
c010bdc4:	89 d6                	mov    %edx,%esi
c010bdc6:	89 c7                	mov    %eax,%edi
c010bdc8:	fd                   	std    
c010bdc9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010bdcb:	fc                   	cld    
c010bdcc:	89 f8                	mov    %edi,%eax
c010bdce:	89 f2                	mov    %esi,%edx
c010bdd0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010bdd3:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010bdd6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c010bdd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010bddc:	83 c4 30             	add    $0x30,%esp
c010bddf:	5b                   	pop    %ebx
c010bde0:	5e                   	pop    %esi
c010bde1:	5f                   	pop    %edi
c010bde2:	5d                   	pop    %ebp
c010bde3:	c3                   	ret    

c010bde4 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010bde4:	55                   	push   %ebp
c010bde5:	89 e5                	mov    %esp,%ebp
c010bde7:	57                   	push   %edi
c010bde8:	56                   	push   %esi
c010bde9:	83 ec 20             	sub    $0x20,%esp
c010bdec:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdef:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bdf2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bdf5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bdf8:	8b 45 10             	mov    0x10(%ebp),%eax
c010bdfb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010bdfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010be01:	c1 e8 02             	shr    $0x2,%eax
c010be04:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010be06:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010be09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010be0c:	89 d7                	mov    %edx,%edi
c010be0e:	89 c6                	mov    %eax,%esi
c010be10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010be12:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010be15:	83 e1 03             	and    $0x3,%ecx
c010be18:	74 02                	je     c010be1c <memcpy+0x38>
c010be1a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010be1c:	89 f0                	mov    %esi,%eax
c010be1e:	89 fa                	mov    %edi,%edx
c010be20:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010be23:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010be26:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010be29:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010be2c:	83 c4 20             	add    $0x20,%esp
c010be2f:	5e                   	pop    %esi
c010be30:	5f                   	pop    %edi
c010be31:	5d                   	pop    %ebp
c010be32:	c3                   	ret    

c010be33 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010be33:	55                   	push   %ebp
c010be34:	89 e5                	mov    %esp,%ebp
c010be36:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010be39:	8b 45 08             	mov    0x8(%ebp),%eax
c010be3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010be3f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be42:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010be45:	eb 30                	jmp    c010be77 <memcmp+0x44>
        if (*s1 != *s2) {
c010be47:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010be4a:	0f b6 10             	movzbl (%eax),%edx
c010be4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010be50:	0f b6 00             	movzbl (%eax),%eax
c010be53:	38 c2                	cmp    %al,%dl
c010be55:	74 18                	je     c010be6f <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010be57:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010be5a:	0f b6 00             	movzbl (%eax),%eax
c010be5d:	0f b6 d0             	movzbl %al,%edx
c010be60:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010be63:	0f b6 00             	movzbl (%eax),%eax
c010be66:	0f b6 c0             	movzbl %al,%eax
c010be69:	29 c2                	sub    %eax,%edx
c010be6b:	89 d0                	mov    %edx,%eax
c010be6d:	eb 1a                	jmp    c010be89 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010be6f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010be73:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c010be77:	8b 45 10             	mov    0x10(%ebp),%eax
c010be7a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010be7d:	89 55 10             	mov    %edx,0x10(%ebp)
c010be80:	85 c0                	test   %eax,%eax
c010be82:	75 c3                	jne    c010be47 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c010be84:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010be89:	c9                   	leave  
c010be8a:	c3                   	ret    
