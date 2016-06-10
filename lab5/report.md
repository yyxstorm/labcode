# 操作系统Lab5实验报告

2012011289
计22
姚宇轩

# 重要知识点及关系
系统调用的全过程，对应从操作系统函数或用户进程syscall调用int指令、到trap函数、到操作系统syscall分发系统调用、到trapentry中iret结束调用的诸多函数
新建内核线程改造为用户进程的过程，对应do_execve、load_icode函数
trapframe的概念和作用，对应trapframe结构体、load_icode、trap系列函数

# 未涉及重要知识点
用户进程代码的编译过程，编译后的代码可以和操作系统配合工作，对应initcode.S、umain.c、ulib.c、user/libs/syscall.c等文件，实验中未体现
wait系统调用的行为，对应do_wait函数，实验中未体现
用户进程的退出过程，对应do_exit函数，实验中未体现

# 练习0：填写已有实验
用meld

# 练习1: 加载应用程序并执行

# 我的设计实现过程
对照trapframe结构体的定义和注释，一句一句实现过来就可以了

# 和标准答案的差别
注释手把手教的，没差别

# 描述当创建一个用户态进程并加载了应用程序后，CPU是如何让这个应用程序最终在用户态执行起来的。即这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过
以user_main进程的执行为例：init_main调用do_wait(proc.c)-schedule(sched.c)-proc_run(proc.c)-user_main函数开始运行-kernel_execve(proc.c)-vector128(vectors.S)-__alltraps(trapentry.S)-trap(trap.c)（以上两步中保存了执行现场到trapframe，是返回时的依据。不过这是一般系统调用的情况，本次被后面运行的load_icode覆盖了）-trap_dispatch(trap.c)-syscall(syscall/syscall.c)-sys_exec（syscall/syscall.c）-do_execve(proc.c)-load_icode(proc.c 申请mm并初始化，申请页目录表并把boot_pgdir拷贝过来以正确映射内核空间即建立内核态运行时的合法虚拟地址空间，根据elf信息建立各段的vma即建立用户态运行时的合法虚拟地址空间，分配相应物理内存空间、建立页表、拷贝内容，设置用户栈的vma、分配物理内存、建立页表，清空并重设trapframe使得iret后能回到用户态正确继续执行)-依次返回-__trapret(trapentry.S)最后执行iret时切换到用户进程第一句_start(initcode.S 在用户进程代码过程中被加入)
此处有一个问题：根据实验书user_main中是KERNEL_EXECVE(hello);，那么以上过程和实验指导书都能说得通。可实际代码中是KERNEL_EXECVE(exit);，似乎没有调用编译的hello代码？那就都说不通了。

# 练习2: 父进程复制自己的内存空间给子进程

# 我的设计实现过程
根据注释一句一句实现过来就可以了，注意想明白page_insert是要把to页目录表和npage、start链接起来

# 和标准答案的差别
注释手把手教的，没差别

# 请在实验报告中简要说明如何设计实现”Copy on Write 机制“，给出概要设计，鼓励给出详细设计。
在do_pgfault函数中实现cow机制。如果页面在内存中且可写则直接写；如果页面在内存中但不可写则先将页面拷贝一份并修改页表指向新拷贝，然后写；如果页面不在内存中则换入内存，此时该页面被进程独占，因此可写，直接写即可。

# 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现

# 简要说明你对 fork/exec/wait/exit函数的分析
fork：分配新进程控制块，分配内核栈，共享或拷贝父进程内存，设置trapframe和context，连入进程链表，改为就绪状态，返回子进程pid
exec：调用load_icode申请mm并初始化，申请页目录表并把boot_pgdir拷贝过来以正确映射内核空间，根据elf信息建立各段的vma，分配相应物理内存空间、建立页表、拷贝内容，设置用户栈的vma、分配物理内存、建立页表，清空并重设trapframe使得iret后能回到用户态正确继续执行
wait：如果有子进程已完成则释放其内核栈、进程管理块，如果有子进程但仍在运行则接着等
exit：回收内存空间，更新状态为僵尸，给出退出码，如果父进程在等则唤醒，如自己有子进程则交给initproc、如果这个子进程是僵尸还要唤醒initproc，调用schedule

# 请分析fork/exec/wait/exit在实现中是如何影响进程的执行状态的？
fork申请新进程控制块时状态是PROC_UNINIT，fork完成时状态是PROC_RUNNABLE（此后被proc_run时状态标识不变但实际上是正在运行）
exec不改变执行状态，只是进程执行过程中的一段代码
wait时状态变为PROC_SLEEPING，等待子进程，后在被唤醒时尝试清理僵尸子进程。
exit时状态变为PROC_ZOMBIE，唤醒父进程清理自己

# 请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）
  PROC_UNINIT--(do_fork)-->PROC_RUNNABLE(ready)--(schedule,proc_run)-->PROC_RUNNABLE(running)--(do_exit)-->PROC_ZOMBIE
                                              \                        /
                                            (schedule)          (do_wait)
                                                    \           /
                                                    PROC_SLEEPING
