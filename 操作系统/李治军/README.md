# Operating_System_Study
基于B站李治军老师的操作系统视频自学笔记

视频链接：https://www.bilibili.com/video/BV1d4411v7u7?p=12&spm_id_from=333.337.0.0

# 目录
* [1. 什么是操作系统](#1-什么是操作系统)
* [2. 揭开“钢琴”的盖子](#2-揭开钢琴的盖子)
* [3. 操作系统启动](#3-操作系统启动)
* [4. 操作系统接口](#4-操作系统接口)
* [5. 系统调用的实现](#5-系统调用的实现)
* [6. 操作系统历史](#6-操作系统历史)
* [7. CPU管理的直观想法](#7-cpu管理的直观想法)
* [8. 多进程图像](#8-多进程图像)
* [9. 用户级线程](#9-用户级线程)
* [10. 内核级线程](#10-内核级线程)
* [11. 内核级线程实现（代码实现）](#11-内核级线程实现代码实现)
* [12. CPU调度策略](#12-cpu调度策略)
* [13. 一个实际的schedule函数](#13一个实际的schedule函数)
* [14. 进程同步与信号量](#14-进程同步与信号量)
* [15. 信号量临界区保护](#15-信号量临界区保护)
* [16. 死锁处理](#16-死锁处理)
* [17. 内存使用与分段](#17-内存使用与分段)
* [18. 内存分区与分页](#18-内存分区与分页)
* [19. 多级页表与快表](#19-多级页表与快表)
* [20. 段页结合的实际内存管理](#20-段页结合的实际内存管理)
* [21. 内存换入-请求调页](#21-内存换入-请求调页)
* [22. 内存换出](#22-内存换出)
* [23. IO与显示器](#23-io与显示器)
* [24. 键盘](#24-键盘)
* [25. 生磁盘的使用](#25-生磁盘的使用)
* [26. 从生磁盘到文件](#26-从生磁盘到文件)
* [27. 目录与文件系统](#27-目录与文件系统)
* [28. 目录解析代码实现](#28-目录解析代码实现)

# 1. 什么是操作系统
## 1.1 计算机有什么作用？
计算机可以帮助人们解决一些实际的问题。<br>
以在屏幕上输出“Hello”举例：
   - 若内存的寄存器地址为300，使显示器显示的寄存器地址为777
   - 其执行步骤即：CPU将计算结果输出至内存，并存入300；并通过总线控制器将数据传输至PCI总线，并将数据存入777。

只有计算机硬件的机器可被称为裸机，若要使用户更好地使用计算机，需要使用操作系统来控制底层的计算机硬件和软件使得上层的应用软件进行工作。

## 1.2 什么是操作系统？
是计算机硬件和应用之间的一层软件，方便我们使用硬件，如显存、CPU、终端、磁盘等。<br>
同时也可以帮助我们高效地使用硬件，如开多个终端（窗口）等

## 1.3 如何学习操作系统
学习操作系统可以有很多层次：
  - 从应用软件出发”探到操作系统“：即操作系统和应用软件的中间层
    - 集中在使用计算机的接口上
    - 使用显示器：printf；使用CPU：fork，使用文件：open、read...
  - 从应用软件出发“进入操作系统”：即中间层和操作系统
    - 一段文字是如何写到磁盘上的。。。
    - 目标：使大家可以使用操作系统并添加自己的代码，能改操作系统
  - 从硬件出发“设计并实现操作系统”
    - 给你一个板子，配一个操作系统。。。

本课程目标：
  - 能理解真实操作系统的运转
  - 能在真实的基本操作系统上动手实践
  - 改CPU管理；改屏幕输出；改系统接口；改内存管理

# 2. 揭开“钢琴”的盖子
操作系统如同结构复杂的钢琴，如果只是停留在如何使用操作系统，就如同打开钢琴弹奏一样简单。但是要知道钢琴内部的组成，就需要揭开钢琴的盖子，知晓其是如何进行发音的。

打开电源后，电脑的黑色背景后发生了什么？
  - 打开电源即计算机要开始工作了，要回答这个问题，就需要知道计算机是怎么工作的？

## 2.1 计算机是怎么工作的？
### 2.1.1 从白纸到图灵机
计算机怎么工作，说到底就是一个计算模型。<br>
借助人在日常生活中的计算模型：人借助笔，在纸上进行计算，如3+2。
自动化设备模拟该工作：先在纸带上写上3，2，+，使用控制器模拟大脑，用读写器模拟眼睛和笔，控制器知道答案是5，则控制其在纸带上写5。<br>

### 2.1.2 从图灵机到通用图灵机
上述系统局限于只会使用加法进行计算，所以我们需要去设计一款能够进行各种计算的通用机器。<br>
图灵机与通用图灵机的区别：
  - 图灵机：一个会做一道菜的厨师
  - 通用图灵机：一个能看懂菜谱的厨师

通用图灵机：需要在纸带上设置控制器的动作和控制器的状态，控制器在读取后修改控制器逻辑，之后再输入数据对象进行数据处理。

### 2.1.3 从通用图灵机到计算机
冯诺依曼存储程序思想：
  - 存储程序的主要思想：将程序和数据存放到计算机内部的存储器中，计算机在程序的控制下一步一步进行处理；（即，取指令->执行）
  - 计算机由五大部件组成：输入设备、输出设备、存储器、运算器、控制器

## 2.2 打开电源，计算机执行的第一句指令是什么
我们要关注指针IP及其指向的内容<br>
对于X86 PC：
  - X86 PC刚开机时CPU处于实模式（和保护模式对应，实模式的寻址CS:IP（CS左移4位+IP），和保护模式不一样）
  - 开机时，CS=0xFFFF; IP=0x0000
  - 寻址0xFFFF0（ROM BIOS映射区）【BIOS：Basic Input Output System】
  - 检查RAM，键盘，显示器，软硬磁盘（这一段代码通不过表示硬件出问题，还没进入操作系统）
  - 将磁盘0磁道0扇区读入0x7c00处（一个硬盘扇区大小为512字节，0磁道0扇区就是操作系统的引导扇区，用于存放操作系统的第一段代码）
  - 设置cs=0x07c0，IP=0x0000  

启动设备信息被设置在CMOS中。

CMOS:互补金属氧化物半导体(64B-128B)。用来存储实时钟和硬件配置信息。

MBR（Master Boot Record，主引导记录）为什么存入地址0x7c00？
  - MBR是引导操作系统进入内存的一段小程序，大小不超过一个扇区（512字节），0x7c00这个地址来自Intel第一代个人电脑芯片8088，以后的CPU为了保持兼容，一直使用这个地址。

0x7c00是怎么来的？
  - 当时的操作系统是86-DOS，这个操作系统需要的内存最少是32KB，即0000-7FFF；8088芯片本身需要占用0x0000-0x03FF，用来保存各种中断处理程序的存储位置。所以，内存只剩下0x0400-0x7FFF可以使用。
  - 为了把尽量多的连续内存留给操作系统，MBR就被放到了内存地址的尾部。由于一个扇区是512字节，MBR本身也会产生数据，需要另外留出512字节保存。所以它的预留位置就变成了：0x7FFF-512-512=0x7c00。
  - 计算器启动后，32KB内存的使用情况如下：

```
+——————— 0x0
| Interrupts vectors
+——————— 0x400
| BIOS data area
+——————— 0x5??
| OS load area
+——————— 0x7C00
| Boot sector
+——————— 0x7E00
| Boot data/stack
+——————— 0x7FFF
| (not used)
+——————— (…)
```

## 2.3 0x7c00处存放的代码是什么？
引导扇区代码：bootsect.s（.s表示汇编代码）<br>
使用汇编代码的原因：
  - 汇编代码会变成真正的机器指令，而高级编程语言产生的变量等，我们无法控制其产生在内存当中的哪个位置。
  - 在引导过程中我们需要对其进行完整的控制，不能有任何出入。所以任何不能出错的代码都是使用汇编语言写的。

关于如下汇编语言寄存器的讲解，参考链接如下：https://www.cnblogs.com/zhaoyl/archive/2012/05/15/2501972.html
<br>
相关知识：<br>
通用寄存器：
  - AX (Accumulator)：累加寄存器，也称之为累加器；
  - BX (Base)：基地址寄存器；
  - CX (Count)：计数器寄存器；
  - DX (Data)：数据寄存器；
<br>SP 和 BP 又称作为指针寄存器：
  - SP (Stack Pointer)：堆栈指针寄存器；
  - BP (Base Pointer)：基指针寄存器；
<br>SI 和 DI 又称作为变址寄存器：
  - SI (Source Index)：源变址寄存器；
  - DI (Destination Index)：目的变址寄存器；

控制寄存器：
  - IP (Instruction Pointer)：指令指针寄存器；
  - FLAG：标志寄存器；

段寄存器：
  - CS (Code Segment)：代码段寄存器；
  - DS (Data Segment)：数据段寄存器；
  - SS (Stack Segment)：堆栈段寄存器；
  - ES (Extra Segment)：附加段寄存器；

引导扇区(boot sector)代码：
```
.globl begtext,begdata,begbss,begtext,enddata,endbss
.text //文本段
begtext:
.data //数据段
begdata:
.bss //未初始化数据段
begbss:
entry start //关键字entry告诉链接器“程序入口”
start:
    mov ax, #BOOTSEG    mov ds, ax  //此条语句就是0x7c00处存放的语句
    mov ax, #INITSEG    mov es, ax
    mov cx, #256
    sub si, si          sub di, di  //将0x7c0:0x0000处的256个字节移动到0x9000:0x0000处
    rep    movw
    jmpi   go, INITSEG  //jump intersegment段间跳转：cs=INITSEG,ip=go
go: mov ax,cs //cs=0x9000
    mov ds,ax  mov es,ax  mov ss,ax  mov sp,#0xff00
load_setup:  //载入setup模块
    mov dx,#0x0000  mov cx,#0x0002  mov bx,#0x0200
    mov ax,#0x0200+SETUPLEN   int 0x13 //BIOS中断
    jnc ok_load_setup
    mov dx,#0x0000
    mov dx,#0x0000  //复位
    int 0x13
    j   load_setup  //重读
ok_load_setup:  //载入setup模块
    mov dl,#0x00  mov ax,#0x0800  //ah=8获得磁盘参数
    int 0x13      mov ch,#0x00     mov sectors,cx
    mov ah,#0x03  xor bh,bh        int 0x10  //读光标
    mov cx,#24    mov bx,#0x0007  
    mov bp,#msg1  mov ax,#1301     int 0x10  //显示字符
    mov ax,#SYSSEG  //SYSSEG=0x1000
    mov es,ax
    call read_it  //读入system模块
    jumpi 0,SETUPSEG
read_it: //读入system模块
    mov ax,es  cmp ax,#ENDSEG  jb ok1_read
    ret
ok1_read:
    mov ax,sectors
    sub ax,sread //sread是当前磁道已读扇区数，ax未读扇区数
    call read_track  //读磁道
.org 510
    .word 0xAA55  //扇区的最后两个字节
```

- .text等是伪操作符，告诉编译器产生文本段，.text用于表示文本段的开始位置。此处的.text、.data、.bss表明这3个段重叠，不分段。
- BOOTSEG = 0x07c0
- INITSEG = 0x9000
- SETUPSEG = 0x9020
- 0x13是BIOS读磁盘扇区的中断：ah=0x02-读磁盘，al=扇区数量(SETUPLEN=4), ch=柱面号， cl=开始扇区， dh=磁头号， dl=驱动器号， es:bx=内存地址

# 3. 操作系统启动
## 3.1 Setup.s
计算机的工作原理：取址执行。<br>
所以在操作系统启动的时候，需要将装在硬盘中的操作系统载入内存进行执行。

在运行完bootsect.s汇编代码之后，系统将运行setup模块，即setup.s。setup.s将完成OS启动前的设置。

该文件用途：操作系统需要知道硬件的各项参数，以此来更好地管理硬件。在该程序中，操作系统需要知道内存的大小，显卡的参数，光标位置等等各种信息，以此来接管硬件。即，初始化。

```
内存地址    长度    名称
0x90000     2      光标位置
0x90002     2      扩展内存
0x9000C     2      显卡参数
0x901FC     2      根设备号
```

## 3.2 进入保护模式
要将计算机的内存从1MB切换至4GB，传统的16位机已无法满足需求。所以需要切换至32位机，又可以被称为保护模式，启动32位的寻址模式。

16位机与32位机的主要区别：CPU内部的解释程序不同了。

传统的CS<<4+IP的寻址方式已经无法使用，需要使用：
  - mov ax,#0x0001
  - mov cr0,ax

cr0是一个非常酷的寄存器：
  - 该寄存器的第0位为PE，第31位为PG；
  - 当PE=1时，启动保护模式，即启用32位寄存器。
  - 当PE=0时，启动实模式，即启用16位寄存器。
  - 当PG=1时，启动分页。

### 3.2.1 保护模式下的地址翻译和中断处理
保护模式下的地址翻译：即**gdt**的作用
  - GDT：Global Discription Table（全局描述表）
  - t是table，所以实模式下：cs<<4+IP。保护模式下：**根据cs查表+ip**。
  - 在保护模式下，cs为选择子，cs不在作为基地址，真正的地址被存放在表项中。

保护模式下中断处理函数入口：即**idt**的作用
  - IDT：interrupt discription table（中断描述表）
  - t仍是table，仿照gdt，通过int n的n进行查表

```
gdt: .word 0,0,0,0
     .word 0x07FF,0x0000,0x9A00,0x00C0
     .word 0x07FF,0x0000,0x9200,0x00C0
```

GDT表项：
```
4|段基址31..24|G|   |段限长19..16|P|DPL|      |段基址23..16      |
 |______________________________|______________________________|
0|段基址15..0                    |段限长15..0                   |
 |_____________________________________________________________|
 31                             16                             0
```

jmpi 0,8//查gdt中的8
  - GDT表中的0x00C09A00000007FFF，基地址为0x0000
  - 即jmp到内存0x0000处

## 3.3 跳到system模块执行
system模块（目标代码）中的第一部分代码是什么？
  - head.s,setup.s文件将跳到head.s文件中执行

system由许多文件编译而成，为什么是head.s？
  - 在Makefile文件中观察可知

setup是进入保护模式，head是进入之后的初始化。

在操作系统中会使用到多种汇编代码：
  - as86汇编：能产生16位代码的Intel 8086汇编
  - GNU as汇编：产生32位代码，使用AT&T系统V语法
  - 内嵌汇编，gcc、编译x.c会产生中间结果as汇编文件x.s

从汇编到C：
```
after_page_tables:
  pushl $0
  pushl $0
  pushl $0
  pushl $L6
  pushl $_main
  jmp set_paging
L6:
  jmp L6
setup_paging:
  设置页表 //将来学到
  ret
```

上述代码将完成从head.s文件跳转到操作系统运行的第一个main.c文件：
  - setup_paging执行ret后，会执行函数main()
  - 进入main()后的栈为0，0，0，L6
  - main()函数的三个参数是0，0，0；三个参数分别是envp，argv，argc，但是此处main并没有使用
  - 若main()函数返回时进入L6，将死循环，即表示电脑死机
  - main的工作就是xx_init:内存、中断、设备、时钟、CPU等内容的初始化。

以内存的操作为例：在系统启动的过程中，操作系统一共做了两件事：
  - 读入内存
  - 初始化内存

但是在内存当中，有一部分内存当中已经有数据了，这一部分内容就是操作系统。在内存当中，从0地址开始的部分就是操作系统的内容。

## 3.4 实验笔记
解压文件：
```
tar -zxvf <文件名> \
>-C <解压路径>
```

删除文件：rm <文件名>
<br>
进入文件夹：cd <文件夹名>
<br>
编辑文件：vi file（在vi中，i表示插入字符，若要保存退出，先ESC，再:wq）<br>
复制文件：cp <源文件名> <目标文件名>

当有多个文件都要编译、链接时，一个个手工编译，效率低下，所以可以借助Makefile。
  - make BootImage

make命令出现错误的原因：make根据Makefile的指引执行了tools/build.c，它是为生成整个内核的镜像文件而设计的，没考虑我们只需要bootsect.s和setup.s的情况。

# 4. 操作系统接口
## 4.1 接口
日常生活中有很多接口：电源插头、汽车油门。。。

什么是接口？
  - 连接两个东西，信号转换，屏蔽细节等。。。

## 4.2 什么是操作系统接口？
通常情况下，操作系统接口都是命令，但不是所有的接口都是命令。

用户如何使用计算机，一般是三类：
  - 命令行
  - 图形按钮
  - 应用程序

### 4.2.1 命令行
命令是什么？命令输入后发生了什么？
  - 命令是一个用C语言写的程序，命令指示一段程序而已。
### 4.2.2 图形按钮
图形按钮基于消息机制

图形界面是什么：
  - 一个包括画图的C程序。

### 4.2.3 小结
命令行：命令程序

图形界面：消息框架程序+消息处理程序

用户如何使用计算机？
  - 通过一些C语言程序再加上一些操作系统提供的重要函数

操作系统接口即为：接口表现为函数调用，又由系统提供，所以称为系统调用(system call)。

POSIX：Portable Operating System Interface of Unix（IEEE指定的一个标准族）

定义成一个标准的原因：刚才讲到过，应用程序为一些C语言程序再加上一些操作系统提供的重要函数；所以当这些重要的函数被制定成一个标准，在所有操作系统上都一样时，这样应用程序就可以在各种操作系统上运行。（如同不同公司生产的插排可以被插在所有人家的插座上）

# 5. 系统调用的实现
是否可以直接调用内存中内核的数据？
  - 不可以，应用程序不能随意调用数据，不能随意使用jmp，不然应用程序就可以看到root密码并修改等。

如何才能让上层应用程序不随意调用底层数据呢？
  - 将内核程序和用户程序**隔离**。
  - 区分内核态和用户态：一种处理器“硬件设计”。

## 5.1 内核（用户）态，内核（用户）段
处理器保护环（数字越小越核心）：该部分由处理器硬件设计
- 0.核心态
- 1.OS服务
- 2.OS服务
- 3.用户态

由于使用CS:IP来表示当前指令，所以用CS的最低两位来表示：0是内核态，3是用户态。

两个重要的段寄存器：CPL,DPL；通过这两个段寄存器来判断当前代码是否可以访问内核态数据
  - DPL用来描述目标内存段的优先级
  - CPL用来描述当前内存段的优先级
  - 必须当CPL=<DPL时，才能执行目标代码

## 5.2 计算机提供了“主动进入内核的方法”
对于Intel x86，那就是中断指令int
  - int指令将使CS中的CPL改成0，“进入内核”
  - 这是用户程序发起的调用内核代码的唯一方式

系统调用的核心：
  - 用户程序中包含一段包含int指令的代码
  - 操作系统写中断处理，获取想调程序的编号
  - 操作系统根据编号执行相应代码

系统中断根据IDT表查询中断处理的位置等。

应用程序在使用int 80号中断进行处理，进入内核时，需要将DPL的值置为3，由此CPL和DPL都为3，所以应用程序才可以访问内核。

调用过程：<br>
用户态：用户调用printf->printf展成int 0x80-><br>
内核态：中断处理system_call->查表sys_call_table->__NR_write=4->调用sys_write

### 系统调用过程

对于使用printf函数将文本打印到屏幕上过程

1. ​	应用程序调用c库函数

2. c库函数调用库函数write

3. 库函数write调用系统函数write

   1. ```
      #include <unistd.h>
      _syscall3(int, write, int, fd, const char, *buf, off_t, count)
      ```

4. _syscall3系统库函数最终展开为

   1. ```
      #define _syscall3(type,name,atype,a,btype,b,ctype,c)\
      type name(atype a, btype b, ctype c) \
      { long __res;\
      __asm__ volatile(“int 0x80”:”=a”(__res):””(__NR_##name),
      ”b”((long)(a)),”c”((long)(b)),“d”((long)(c)))); if(__res>=0) return 
      (type)__res; errno=-__res; return -1;}
      ```

   2. 参数：

      1. type 中断类型
      2. name：具体操作 write，read
      3. atype ：文件描述符类型
      4. a：文件描述符
      5. btype：偏移量类型
      6. b：偏移量具体值
      7. ctype:计数类型
      8. c：计数

   3. ```
      __asm__ volatile(“int 0x80”:”=a”(__res):””(__NR_##name)
      ```

      1. 内嵌汇编代码，默认为%EX寄存器，先将name参数代入到__ NR_##name，再将 __ NR_##name存入%EX。最后将返回值设为%EX
      2. 调用int 0x80中断

   4. 显然，__ NR_write是系统调用号，放在eax中 

      1. 在linux/include/unistd.h中 #define __NR_write 4 //一堆连续正整数(数组下标, 函数表索引) 
      2. 同时eax也存放返回值，ebx，ecx，edx存放3个参数

5. int 0x80中断展开

   1. ```
      void sched_init(void) { set_system_gate(0x80,&system_call); }
      #define set_system_gate(n, addr) \
      _set_gate(&idt[n],15,3,addr); //idt是中断向量表基址
      #define _set_gate(gate_addr, type, dpl, addr)\
      __asm__(“movw %%dx,%%ax\n\t” “movw %0,%%dx\n\t”\
      “movl %%eax,%1\n\t” “movl %%edx,%2”:\
      :”i”((short)(0x8000+(dpl<<13)+type<<8))),“o”(*(( \
      char*)(gate_addr))),”o”(*(4+(char*)(gate_addr))),\
      “d”((char*)(addr),”a”(0x00080000)
      ```

      1. 通过调用gate函数，实现进入内核前的处理工作，gate函数即为处理函数的入口地址![image-20230322192145838](res/README/image-20230322192145838.png)
      2. 先将DPL设为3，此时cpl和dpl均为3，可以执行中断代码，进而进入内核，再将根据段选择符cs = 8，代表内核态，处理函数入口偏移地址设为系统调用地址，通过中断表来找系统调用地址

6. 总结：![image-20230322192611910](res/README/image-20230322192611910.png)

## 6.1 操作系统的历史

- 1955-1965：计算机非常昂贵，上古神机IBM7094，造价在250万美元以上
  - 计算机使用原则：只专注于计算
  - 使用**批处理操作系统**
    - 批操作系统：输入作业队列，执行完一个作业才执行下一个作业，当本作业出现错误时，将错误信息打印到纸带上，然后继续执行下一个作业
  - 典型代表：IBSYS监控系统
  
- 从IBSYS到OS/360（1965-1980）
  - 需要让一台计算机干多种事
  - 多道程序
  - 作业之间的切换和调度称为核心：因为既有IO任务，又有计算任务，需要让CPU忙碌（多进程结构和进程管理概念萌芽）
  - 典型代表：IBM OS/360

- 从OS/360到MULTICS（1965-1980）
  - 如果每个人启动一个作业，作业之间快速切换
  - 分时系统
  - 代表：MIT MULTICS
  - 核心仍然是任务切换，但是资源复用的思想对操作系统影响很大，虚拟内存就是一种复用

- 从MULTICS到UNIX（1980-1990）
  - 越来越多的个人可以使用计算机
  - 1969年：UNIX
  - UNIX是一个简化的MULTICS，核心概念差不多，但更灵活和成功

- 从UNIX到Linux（1990-2000）
  - 1981，IBM推出IBM PC；个人计算机开始普及
  - 1994年，Linux 1.0发布并采用GPL协议，1998年以后互联网世界里展开了一场历史性的Linux产业化运动

总结历史：
  - 用户通过执行程序来使用计算机（温和冯诺依曼的思想）
  - 作为管理者，操作系统要让多个程序合理推进，就是进程管理
  - 多进程（用户）推进时需要内存复用等等

**任务：掌握操作系统的多进程图谱并实现它**

## 6.2 历史是多线条的：PC与DOS
PC机的诞生一定会导致百花齐放。IBM推出PC，自然要给这个机器配一个操作系统
  - 1975年开发了操作系统CP/M
  - CP/M：写命令让用户用，执行命令对应的程序，单任务执行
  - 1980年出现了8086 16位芯片，从CP/M基础上开发了QDOS

从QDOS到MS-DOS
  - 1975年，Bill Gates开发了BASIC解释器，据此开创了微软
  - 1977年Gates开发FAT管理磁盘
  - QDOS的成功在于以CP/M为基础将BASIC和FAT包含了进来
  - 1981微软买下QDOS，改名为MS-DOS，和IBM PC打包一起出售

从MS-DOS到Windows
  - MS-DOS的磁盘、文件、命令让用方便，但似乎可以更方便
  - 1989年，MS-DOS 4.0出现，支持了鼠标和键盘，此时微软已经决定要放弃MS-DOS
  - 不久后Windows 3.0大获成功
  - 文件、开发环境、图形界面对于OS的重要性

总结历史：
  - 仍然是程序执行、多进程、程序执行带动其他设备使用的基本结构
  - 但用户的使用感觉倍加重视了：各种文件、编程环境、图形界面
  - 如何通过文件存储代码、执行代码、操作屏幕。。。
  - 如何让文件和操作变成图标、点击或触碰。。。

任务：
1. 掌握、实现操作系统的多进程图谱；
2. 掌握、实现操作系统的文件操作视图。

# 7. CPU管理的直观想法
## 7.1 CPU的工作原理
CPU上电以后发生了什么？
  - 自动地取指执行
  - 设好PC初值，剩下的CPU自动往下取指执行就可以。

在一段程序中，将IO指令替换成普通的计算指令，CPU执行的速度将会快很多，由此可以得出：
  - IO指令执行的速度很慢，因为需要控制机械磁盘，机械速度慢于电子的速度。
  - IO指令执行一次大概相当于10的5次方个计算数据时间
  - 以此种方式进行工作，由于CPU执行速度快，绝大部分时间都是在等待IO进行工作，CPU的工作利用率将会变得很低。

如何解决以上问题：
  - 当前程序执行不下去时，转去执行其他的程序，来回进行切换，以此来提高CPU的利用率。
  - 多道程序的概念

一个CPU上交替地执行多个程序：并发

## 7.2 如何管理CPU的并发？
核心思想在于控制PC执行指令的指针的切换，即控制CPU在不同程序间的执行。

在切换PC寄存器的同时，同样需要记录前一个程序运行中断处的执行结果。

引入进程的概念：
  - 运行的程序和静态的程序不一样
  - 需要引入进程的概念来描述这些不一样的东西
  - 进程是进行（执行）中的程序
  - 进程有开始、有结束，程序没有
  - 进程会走走停停，走停对程序无意义
  - 进程需要记录ax，bx。。。，程序不用

# 8. 多进程图像
## 8.1 什么是多进程图像
如何使用CPU？
  - 让程序执行起来

如何充分利用CPU？
  - 启动多个程序，交替执行

启动了的程序就是进程，所以是多个进程推进：
  - 操作系统只需要把这些记录好、要按照合理的次序推进（分配资源、进行调度），这就是多进程图像

多进程图像从启动开始到关机结束：
  - main中的fork()创建了第1个进程:if (!fork()){init();}

用户使用计算机就是启动了一堆进程，用户管理计算机就是管理一堆进程。

## 8.2 如何实现多进程图像
### 8.2.1 多进程如何组织？
多进程如何组织？
  - Process Control Bloack：用来记录进程信息的数据结构（结构体）
  - 操作系统感知和组织进程全靠PCB

多进程的组织：PCB+状态+队列

进程的状态：新建态、就绪态、运行态、阻塞态、终止态
 - 进程状态是认识操作系统进程管理的一个窗口

### 8.2.2 多进程如何交替？
多进程如何交替？
  - 调用schedule();进行切换
  - 交替的三个部分：队列操作+调度+切换

```
schedule()
{
  pNew = getNext(ReadyQueue); //从就绪队列中找到下一个进程
  switch_to(pCur,pNew);       //pCur和pNew是PCB
}
```

### 8.2.3 如何解决多进程互相影响的问题？
多进程同时运行时，它们之间有可能会互相影响，如：进程A和进程B对内存当中的同一地址进行了操作，如何解决这一问题？
  - 解决办法：限制对同一地址的读写
  - 多进程的地址空间分离：内存管理的主要内容
  - 每个进程使用映射表在物理内存中进行映射，就算使用同一块内存空间，在映射表中将会被映射到不同的物理内存当中。（虚拟内存）

### 8.2.4 多进程如何合作？
核心在于进程同步（合理地推进顺序）；

最简单的方法在于写counter时阻断其他进程访问counter；（给counter上锁）

# 9. 用户级线程
是否可以资源不动而切换指令序列？
  - 进程 = 资源 + 指令执行序列
  - 将资源和指令执行分开
  - 一个资源 + 多个指令执行序列
  - 从而引出了线程了概念

![image-20230331180420109](res/README/image-20230331180420109.png)

当一个进程中的两个线程共用一个栈时，其两个线程中函数在栈中的返回地址会混淆，导致函数返回时切换到对方函数执行

因此，必须一个线程使用一个栈，用户级线程相当于在用户态，有程序员进行编写线程的切换函数yield（），由于其在调用yield函数时，该线程的下一条指令会保存到该线程的栈中，因此当切换到另一个线程，直接将对方返回栈设置为自己的，再将当前栈指针设置为对方的，即可跳入对方进行执行，此时在整个另一个线程中执行的全部过程对于线程一来说就相当于执行了一个yield函数，此时其直接使用栈中的返回值即可，不需要在yield函数中显示写出执行的目标pc，若显示写出，则会导致多余栈中的数据。相当于其要执行两次。

线程：保留了并发的优点，避免了进程切换改变映射表影响执行速度的代价。

  - 实质就是映射表不变而PC指针变

以一个网页浏览器的例子来了解线程是否有用：
  - 一个线程用来从服务器接收数据
  - 一个线程用来显示文本
  - 一个线程用来处理图片（如解压缩）
  - 一个线程用来显示图片

以如上方式运行的网页，用户的交互性更好。

在进行线程切换时，核心是yield：
  - 能切换了就知道切换时需要是个什么样子
  - create就是要制造出第一次切换时应该的样子

如何进行切换？
  - 用yield和栈的配合，实现线程的切换
  - 每个执行序列使用一个栈（用户级线程的核心），这样才能保证线程间切换的时候不会出错。
  - 在yield切换时要先切换栈，然后再执行程序。
  - 所以需要使用一个数据结构来存放栈的指针。
  - 从而引出一个数据结构：TCB（Thread Control Block，全局的用于存放栈指针的数据结构）

两个线程的样子：两个TCB、两个栈、切换的PC在栈中
  - ThreadCreate的核心就是用程序做出这三样东西![image-20230331181332486](res/README/image-20230331181332486.png)

```
void ThreadCreate(A)
{
  TCB *tcb = malloc();
  *stack = malloc();
  *stack = A;
  tcb.esp = stack;
}
```

用户级线程和内核级线程的区别：
  - 用户级线程：线程在用户程序中被创建，如果进程的某个线程进入内核并阻塞，则内核将会切换到另一个进程执行任务，当前被阻塞的进程的后续线程将被阻塞不运行。
    - tcb表在用户态存储，此时若一个线程阻塞，相当于整个进程阻塞

  - 内核级线程：内核级线程的ThreadCreate是系统调用，会进入内核，内核知道TCB。线程将在内核中被创建，若当前线程被阻塞，内核将会执行当前进程下的其他线程。它的**并发性**会更好！！
    - 


# 10. 内核级线程
建议反复观看

为什么没有用户级进程？
  - 因为进程需要访问、分配计算机资源，进行文件操作等，这些都必须在内核中进行。

多核如果要发挥作用，必须要支持核心级线程。

多处理器和多核的区别在于：
  - 多处理器有自己的一套缓存和MMU，但是多核是多个CPU共用缓存和MMU

和用户级相比，核心级线程有什么不同？
  - ThreadCreate是系统调用，内核管理TCB，内核负责切换线程。
  - 用户栈是否还要使用？
    - 执行的代码仍然在用户态，还要进行函数调用，所以用户栈还得有。
  - 核心级线程有两套栈（内核级线程的核心）：
    - 用户栈和内核栈：由于线程在内核中调用，用户栈没有办法在内核中使用，所以需要在内核中创建一个内核栈。

用户栈和内核栈之间的关联：
  - 进入内核的唯一方法：中断
  - INT进入内核栈，IRET返回用户栈

内核栈中的内容（栈底到栈顶）：
  - 源SS
  - 源SP
  - EFLAGS
  - 源PC
  - 源CS

线程在内核中切换时：
  - 使用switch_to：仍然是通过TCB找到内核栈指针；然后通过ret切到某个内核程序；最后再用CS:PC切到用户程序。

内核线程switch_to五段论：
  - 中断入口：进入切换
    - 一些代码。。。（压栈）
    - call 中断处理
  - 中断处理：引发切换
    - 启动磁盘读或时钟中断
    - schedule()；
    - ret
  - call swtich_to：
  - switch_to：进行内核栈切换
    - TCB[cur].esp=%esp;
    - %esp=TCB[next].esp;
    - ret
  - 中断出口：第二级切换
    - pop...
    - iret
  - 即：线程S的用户栈->线程S的内核栈->切换->线程T的内核栈->线程T的用户栈
  - 若两个线程不属于同一个进程，还需要额外增加一段：地址切换
    - 要首先切换地址映射表

在编写ThreadCreate的时候，要把程序写成一套栈的样子：
```
void ThreadCreate(...)
{
  TCB tcb=get_free_page();
  *krlstack=...;
  *userstack传入；
  填写两个stack；
  tcb.esp=krlstack;
  tcb.状态=就绪；
  tcb入队；
}
```

用户级线程、核心级线程的对比：
```
              用户级线程      核心级线程      用户+核心级
利用多核        差              好              好
并发度          低              高              高
代价            小              大              中
内核改动        无              大              大
用户灵活性      大              小              大
```

# 11. 内核级线程实现（代码实现）
建议反复观看

从进入内核的中断开始：fork();
  - fork是创建进程系统调用

TSS：Task Struct Segment

如何寻找下一个线程执行序列会在调度中讲解，目前先存疑。

TSS与kernelstack切换(switch_to)方式的对比：
  - TSS方式指令简单，但是执行效率慢
  - 目前的操作系统都使用的是kernelstack

copy_process的细节：创建栈
  - 申请内存空间：4K
  - 创建RCB
  - 创建内核栈和用户栈；
  - 填写两个stack
  - 关联栈和TCBs

# 12. CPU调度策略
CPU调度（进程调度）的直观想法
  - FIFO：谁先进入，先调度谁（简单有效）
  - Priority：任务短可以适当优先（但你怎么知道这个任务将来会执行多长时间呢？）

如何设计调度算法？
  - CPU调度的目标应该是进程满意

如何满意？
  - 尽快结束任务：周转时间（从任务进入到任务结束）短
  - 用户操作尽快响应：响应时间（从操作发生到响应）短
  - 系统内耗时间少：吞吐量（完成的任务量）

总原则：系统专注于任务执行，又能合理调配任务。

如何做到合理？需要这种，需要综合
  - 吞吐量和响应时间之间有矛盾
    - 响应时间小->切换次数多->系统内耗大（任务切换需要时间）->吞吐量小
  - 前台任务和后台任务的关注点不同
    - 前台任务关注响应时间，后台任务关注周转时间
  - IO约束型任务和CPU约束型任务有各自的特点
    - 操作系统应优先执行IO约束型任务，以此达到IO与CPU并行，IO约束性任务指代的是直接与用户交互的那一类任务。
  - 折中和综合让操作系统变得复杂，但有效的系统又要求尽量简单。

调度方式一：First Come，First Served(FCFS)
  - 如何缩短周转时间？SJF：短作业优先
    - 周转时间：对一个进程来说，一个重要的指标是它执行所需要的时间。从进程提交到进程完成的时间间隔为周转时间，也就是等待进入内存的时间，在就绪队列中等待的时间，在CPU中执行的时间和IO操作的时间的总和。
    - 如果调度结果是p1p2p3...pn，则平均周转时间为：(p1+p1+p2+p1+p2+p3+...)/n
    - 因为放在后面的任务要等到前面的任务执行完之后才能被执行，所以放在前面的任务在计算周转时间时会被计算多次。
    - 所以短任务优先执行可以有效缩短周转时间。
  - 如何缩短响应时间？RR(Round Robin)：按时间片来轮转调度
    - 时间片太大：响应时间太长；时间片太小：吞吐量小
    - 折中：时间片10-100ms，切换时间0.1-1ms(1%)

如果响应时间和周转时间同时存在，怎么办？
  - 如何使一个调度算法让多种类型的任务同时都满意？
  - 直观想法：定义前台任务和后台任务两个队列，前台RR，后台SJF，只有前台任务没有时才调度后台任务。在前台任务和后台任务之间，使用优先级进行调度：前台任务优先级高，后台任务优先级低。
  - 那么这样会造成什么问题？
    - 一个故事：1973年关闭MIT的IBM 7094时，发现有一个进程在1967年提交但一直未运行。（进程饥饿：只要有前台任务存在，后台任务永远不会执行）
  - 如何解决？（动态优先级）
    - 后台任务优先级动态升高，但后台任务（用SJF调度，CPU执行时间很长的任务）一旦执行，前台的响应时间没法保证
  - 如何解决上述问题？
    - 前后台任务都用时间片，但有退化为了RR，后台任务的SJF如何体现？前台任务如何照顾？
  - 还有很多任务仍需解决：
    - 我们怎么知道哪些是前台任务，哪些是后台任务，fork时告诉我们吗？
    - gcc就一点不需要交互吗？Ctrl+C按键怎么工作？word就不会执行一段批处理吗？ctrl+F按键？
    - SJF中的短作业优先如何体现？如何判断作业的长度？

# 13.一个实际的schedule函数
Linux 0.11的调度函数schedule():
```
void schedule(void)  //在kernel/sched.c中
{
  while(1)
  {
    c=-1;
    next=0;
    i=NR_TASKS;
    p=&task[NR_TASKS];
    while(--i)
    {
      //下列代码是为了求最大counter（既是优先级又是时间片，这里是优先级）的进程，然后跳出去给switch_to执行
      if (*p->state == TASK_RUNNING&&(*P)->conter>c)  //TASK_RUNNING就是就绪
        c=(*p)->counter;
        next=i;
    }
    if (c)
      break; //找到了最大的counter
    for (p=&LAST_TASK;p>&FIRST_TASK;--p) //所有counter都等于0，意味着所有就绪态的进程的counter都用完了
      (*p)->counter=((*p)->counter>>1)+(*p)->priority; //将所有counter（时间片）为0的就绪态进程的counter重新设置为初值，这行代码将所有未就绪的进程的时间片增加，使他们的counter（时间片/优先级）大于就绪态进程（未就绪进程的counter有初值不为0，因此counter/2+初值一定大于初值）。这样做恢复了时间片，且让阻塞态恢复就绪态的counter比直接等待转就绪的大
  }
  switch_to(next);
}
```

代码总结：
  - 首先找到所有就绪态任务的最大counter，大于零则switch_to
  - 否则更新所有任务的counter，即右移以为再加上priority
  - 然后进入下一次找最大counter大于零则切否则更新counter
  - 所以没在就绪态的counter就一直在更新，数学证明得出等的时间越长counter越大
  - 等他们变成就绪态了，由于counter大，也就可以优先切过去了

counter作用的整理：
  - counter保证了响应时间的界限：
    - c(t)=c(t-1)/2+p
    - c(0)=p
    - c(inf)<2p
  - 经过IO以后，counter就会变大；IO时间越长，counter越大，照顾了IO进程，变相的照顾了前台进程
  - 后台进程一直按照counter轮转，近似了SJF调度
  - 每个进程只用维护一个counter变量，简单、高效
  - 这个算法折中了大多数任务的需求，这就是实际工作的schedule函数

# 14. 进程同步与信号量
需要让“进程走走停停”来保证多进程合作的合理有序
  - 这就是进程同步

信号量：用一个新增的变量来记录当前阻塞及空闲的生产者个数，来使其进入睡眠状态或唤醒状态。

问题：一种资源的数量是8，这个资源对应的信号量的当前值是2，说明：**有2个资源可以使用**。

信号量的定义：是一种特殊的整型变量，量用来记录，信号用来sleep和wakeup。

# 15. 信号量临界区保护
什么是信号量？
  - 通过这个量的访问和修改，让大家有序推进。

竞争条件：和调度有关的共享数据语义错误
  - 错误有多个进程并发操作共享数据引起
  - 错误和调度顺序有关，难于发现和调试
  - 共享数据不保护，就会出错，因为程序执行顺序是未知的，所以信号量需要临界区保护

解决竞争条件的直观想法：在写共享变量empty时阻止其他进程也访问empty（原子操作）

临界区：一次只允许一个进程进入该进程的那一段代码。
  - 读写信号量的代码一定是临界区

一个非常重要的工作：找出进程中的临界区代码

临界区代码的访问原则：
  - 如果一个进程在临界区中执行，则其他进程不允许进入
    - 这些进程间的约束关系成为互斥
  - 好的临界区保护原则
    - 有空让进：若干进程要求进入空闲临界区时，应尽快使一进程进入临界区
    - 有限等待：从进程发出进入请求到允许进入，不能无限等待

两个进程间的临界区保护：Perterson算法
  - 标记和轮转的结合
  - 进程1要进入之前flag[0]=true，turn=0；
  - 进程2要进入之前flag[1]=true，turn=1；

多个进程的临界区保护：面包店算法（饭店取号）
  - 仍然是标记和轮转的结合
    - 如何轮转：每个进程都获得一个序号，需要最小的进入
    - 如何标记：进程离开时需要为0，不为0的需要即标记
  - 每个进入商店的客户都获得一个号码，号码最小的先得到服务；号码相同时，名字靠前的先服务。

临界区保护的另一类解法： 
  - 临界区只允许一个进程进入，另一个进程只有被掉地才能执行，才可能进入临界区。
  - 所以阻止调度就能阻止其他进程执行，即关闭中断。
  - 该方式在多CPU（多核）时不好用：没有办法控制其他的CPU执行另一进程语句

另一种方法：临界区保护的硬件原子指令法

# 16. 死锁处理
我们将这种多个进程由于**互相等待对方持有的资源**而造成的谁都无法执行的情况叫死锁。

## 16.1 死锁的成因
死锁的成因：
  - 资源互斥使用，一旦占有别人无法使用
  - 进程占有了一些资源，又不释放，再去申请其他资源
  - 各自占有的资源和互相申请的资源形成了环路等待

## 16.2 死锁的必要条件
死锁的四个必要条件：
  - 互斥使用
    - 资源的固有特性
  - 不可抢占
    - 资源只能资源放弃
  - 请求和保持
    - 进程必须占有资源，再去申请
  - 循环等待
    - 在资源分配图中存在环路

## 16.3 死锁的处理方式
死锁处理方法概述
  - 死锁预防
    - 破坏死锁出现的条件
  - 死锁避免
    - 检测每个资源请求，如果造成死锁就拒绝
  - 死锁检测+恢复
    - 检测到死锁出现时，让一些进程回滚，让出资源
  - 死锁忽略
    - 就好像没有出现死锁一样（造成死锁后就重启，普通PC机可以使用这种方式）

### 16.3.1 死锁预防的方法例子
在进程执行前，一次性申请所有需要的资源，不会占有资源再去申请其他资源
  - 缺点1：需要预知未来，编程困难
  - 缺点2：许多资源分配后很长时间后才使用，资源利用率低

对资源类型进行排序，资源申请必须按序进行，不会出现环路等待
  - 缺点：仍然造成资源浪费

### 16.3.2 死锁避免：判断此次请求是否引起死锁
如果系统中的所有进程存在一个可完成的执行序列P1,...Pn，则称系统处于安全状态（**银行家算法**）

银行家算法：<br>
申请一个变量，每次判断需要的资源是否小于现有的资源，就结束这个进程，将结束后进程的资源累加。
  - T(n)=O(m*n*n) 时间复杂度高，m是资源的个数，n是进程的个数

请求出现时：首先假装分配，然后调用银行家算法
  - 缺点：每次申请时，都需要调用算法进行计算，时间复杂度太高

### 16.3.3 死锁检测+恢复：发现问题再处理
基本原因：每次申请都执行银行家算法，效率低。发现问题再处理
  - 定时检测或者是发现资源利用率低时检测
  - 挑一个进程回滚（将执行的程序退回）
    - 选择哪些进程回滚？
    - 如何实现回滚？那些已经修改的文件怎么办？
    - 实现起来会很复杂

许多通用操作系统，如PC机上安装的Windows和Linux，都采用死锁忽略方法，对其原因，下面哪个说法不正确：(D)
  - A、死锁忽略的处理代价最小
  - B、这种机器上出现死锁的概率比其他机器低
  - C、死锁可以用重启来解决，PC重启造成的影响小
  - D、死锁预防让编程变得困难

### 16.3.4 死锁忽略
死锁出现不是确定的，可以用重新启动的方式来处理死锁

# 17. 内存使用与分段
## 17.1 内存使用
内存使用的方法：将程序放到内存中，PC指向开始地址（取指执行）

所有的应用程序代码的entry都需要放在0地址处执行才能确保代码有效，但是0地址处只有一个（0地址处放的是操作系统），且不能使用，并且也不能保证0地址处是空闲的，该如何解决这个问题？
  - 重定位：修改程序中的地址（是相对地址，又称逻辑地址）

什么时候进行重定位？如何做？
  - 什么时候：载入时
    - 如果是在编译的时候进行重定位，不能保证实际运行的时候编译时候的内存地址位置一定是空闲的。
    - 编译时重定位的程序只能放在内存固定位置，但效率高
    - 载入时重定位的程序一旦载入内存就不能动了，但灵活（PC机更合适）

程序在载入后仍需要移动怎么办？
  - 重定位的最佳时机：运行时进行重定位（在运行每条指令时才完成重定位）
  - 每个进程有各自的基地址，放在PCB中，执行指令时第一步先从PCB中取出基地址
  - 每执行一条指令都要从逻辑地址算出物理地址，将地址进行翻译。
  - 物理地址=基地址+偏移（逻辑地址），基地址放在PCB中

## 17.2 分段
分段：
  - 程序是一整个都一起放入内存中的吗？不是
  - 程序是由若干部分组成，每个段有各自的特点、用途：代码段只读，代码/数据段不会动态增长。。。
  - 如何用户观点：用户可以独立考虑每个段（分治）
  - 怎么定位具体指令：<段号，段内偏移>

分段之后的重定位需要记录每个段的基址，所以就需要一个表来记录每一个段的基址，这个表就是LDT(Local Discriptor Table)。GDT表是操作系统对应的段表。（LDT在PCB中）

# 18. 内存分区与分页
## 18.1 内存分区
内存如何进行分割？
  - 固定分区与可变分区

固定分区：
  - 等分，操作系统初始化时将内存等分成k个分区
  - 但是段有大有小，需求不一定

可变分区：
  - 按照需求进行分割

可变分区的管理过程————核心：数据结构
  - 请求分配
  - 释放内存
  - 再次申请（当有多个空闲内存时，如何进行选择？）算法：
    - 首先适配：分配最快
    - 最佳适配：选择与内存请求大小最接近的分区
      - 特点：剩余的内存分区会越来越细
    - 最差适配：在空闲分区中选择最大一块内存
      - 特点：最后会得到比较均匀的内存分区

问题：如果某操作系统中的段内存请求很不规则，有时候需要很大的一个内存块，有时候又很小，此时用那种分区分配算法最好？(B)
  - A.最先适配
  - B.最佳适配
  - C.最差适配
  - D.没有区别

内存分区其实是用于虚拟内存的管理

## 18.2 内存分页
分页：解决内存分区导致的内存效率问题

可变分区造成的问题：内存碎片

如何解决内存碎片？
  - 将空闲分区合并，需要移动一个段：内存紧缩
  - 内存紧缩的缺点：花时间
    - 内存紧缩需要花费大量时间，如果复制速度1M/s，则1G内存的紧缩时间为1000s=17 min
    - 在内存紧缩的过程中，段都要进行移动，导致所有进程的LDT表都在修改中，无法进行地址翻译并取指执行，所以所有的进程都处于用不了的状态，用户会觉得计算机处于死机状态。

分页：从连续到离散
  - 将内存分成页
  - 针对每个段内存请求，系统一页一页地分配给这个段
  - 内存初始化时，每4K分为一页
  - 此时最大的内存浪费是4K
  - 特点：没有内存外部碎片，但是有内存内部碎片，然而内部碎片最大最大也就4K

因此，物理内存希望采用分页的特点，因为内存碎片少，然而，用户希望采用分段的特点，因为程序由多个段组成。

页表重定位：
  - 分段有段表，分页有页表，来帮助重定位
  - 在页表中根据页号找出页框号得出物理地址，这就是MMU硬件做的事情。

# 19. 多级页表与快表
## 19.1 多级页表
为了提高内存空间利用率，页应该小，但是页小了页表就大了。

页表很大，页表的放置就很成问题。
  - 页面尺寸通常为4K，而地址是32位的
  - 1M个页表项都得放在内存中，需要4M内存；系统中并发10个进程，就需要40M内存。（显然是一种内存的浪费）
  - 实际上大部分逻辑地址根本不会用到

解决方法尝试1：删除不使用的页号，只存放用到的页
  - 如果页表中的页号不连续，就需要比较、查找
  - 每执行一条指令都需要查找页表对应的物理地址，如果页表中共有1000个页号，需要访问内存500次，速度太慢
  - 折半查找呢？
  - 4M大小需要10次，需要额外访问内存10次，也很慢
  - **CPU执行命令做计算的时间很快，主要花费的时间都在访问内存上**
  - 所以页号必须要连续，连续的时候只需要知道初始地址和偏移就可以
  - 既要连续，又要让页表占用内存少，怎么办？
    - 多级页表：用书的章目录和节目录来类比思考

解决方法尝试2：多级页表，即页目录表+页表
  - 逻辑地址：10 bits页目录号 + 10 bits页号 + 12 bits offset
  - 实际存放需要使用12M，但是中间有很多不使用的空间可以不记录
  - 多级页表提高了空间效率，但在时间上引入了额外的代价。（每增加一级会增加一次访存）
    - 对于64位系统会消耗很多时间

## 19.2 快表
TLB是一组相联快速存储，是寄存器。（类似于缓存）

快表可以理解成高速缓存（ARP高速缓存，DNS高速缓存等）

将最近访问过的逻辑地址和物理地址的映射存入快表，每次要转换时，先查快表，快表中没有，再查多级页表。

TLB得以发挥作用的原因：
  - TLB命中时效率会很高，未命中时效率降低
  - 要向真正实现“近似访存一次”，TLB的命中率应该很高
  - TLB越大越好，但TLB很贵，通常只有64~1024之间

为什么TLB条目数可以在64-1024之间？
  - 相比20^2个页，64很小，为什么TLB就能起作用？
    - 程序的地址访问存在局部性：要多次访问内存的地址就只有局部的一点
    - 因为程序多体现为循环、顺序结构

# 20. 段页结合的实际内存管理
段、页结合：程序员希望用段，物理内存希望用页，所以需要段页结合。

如何需要实现段页结合，首先需要将用户程序分成的段先映射到一个位置，然后在把这个位置上的内容以页的方式映射到物理内存中，这个位置就是虚拟内存。

段、页同时存在：段面向用户/页面向硬件
  - 物理地址与用户隔离，即应用程序只能看见虚拟内存，无法直接操作物理内存

段、页同时存在时的重定位（地址翻译）：
  - 第一层地址翻译是支持段的地址翻译，根据段表找到虚拟地址
  - 第二层地址翻译是支持页的地址翻译，根据页表找到物理地址

内存管理核心就是内存分配，所以从程序放入内存、使用内存开始
  - 分配段、建段表；分配页，建页表
  - 进程带动内存使用的图谱
  - 从进程fork中的内存分配开始

载入内存的步骤：
  - 分配虚存
  - 建段表
  - 分配内存
  - 建页表

父子进程内存写时分离。（因为只读）

# 21. 内存换入-请求调页
用户可以随意使用虚拟内存，就像单独拥有内存。

但是虚拟内存需要与物理内存进行映射，不然用户用不了实际内存。

如何用换入、换出实现“大内存”？
  - 用户视角下的虚拟内存有4G，但实际物理内存只有1G怎么办？
  - 访问p(=0G-1G)时，将这部分映射到物理内存
  - 再访问p(=3G-4G)时，再映射这一部分

用户使用逻辑地址，映射到虚拟内存，实现重定位，转换成虚拟地址，虚拟地址映射物理地址，发现需执行的指令或访问的数据尚未在内存（要访问的页面不在内存中）。
  - 此时发生缺页中断从而由处理器通知操作系统将相应的页面或段调入到内存

采用请求调页而不是请求掉段，是因为？(C)
  - A.请求调页对用户更透明
  - B.用户程序需要因为请求掉段而重写
  - C.请求调页的粒度更细，更能提高内存效率
  - D.请求掉段不工作在内核态

cr2：页错误线性地址

# 22. 内存换出
并不能在换入的时候总获得新的页，内存是有限的<br>
需要选择一页淘汰，换出到磁盘，选择哪一页？
  - FIFO：先进先出
  - MIN：选最远将使用的页淘汰，是最优方案
    - 这种方案可以有效减少缺页次数
    - 但是如何知道将来发生的事？无法使用
  - LRU：现实使用的方法，用过去的历史预测将来（局部性原理）
    - 选最近最长一段时间没有使用的页淘汰（最近最少使用）

在对每一种方法进行评价时，应确定评价准则：缺页次数，应当减少缺页的次数。

LRU的准确实现1，用时间戳
  - 每页维护一个时间戳
  - 每次地址访问都需要修改时间戳，需维护一个全局时钟，需找到最小值，实现代价较大

LRU的准确实现2，用页码栈
  - 维护一个页码栈
  - 这里的关键是维护时间
  - 如果不缺页，程序应该是直接通过MMU访问物理地址，内核没有机会进行时间戳或者栈的维护
  - 只有在缺页中断的时候内核才有机会接触处理页换出
  - 任何在不缺页的时候的数据结构维护都会带来巨大开销
  - 每次地址访问都需要修改栈（修改10次左右栈指针），实现代价仍然较大，LRU准确实现用得少

LRU近似实现，将时间计数变为是和否
  - 每个页加一个引用位
    - 每次访问一页时，硬件自动设置该位
    - 选择淘汰页：扫描该位，是1时清零，并继续扫描；是0时淘汰改页
    - 即Second Chance Replacement：时钟算法

clock算法的分析与改造
  - 如何缺页很少，所有的引用位都变为1
    - hand scan一圈后淘汰当前页，将调入页插入hand位置，hand前移一位；最终将退化为FIFO
    - 原因：记录了太长的历史信息。。。怎么办？
    - 定时清除R位，再定义一个扫描指针

应该给进程分配多少页框呢？
  - 分配得多，请求调页导致的内存高效利用就没用了
  - 分配太少，会造成颠簸

调入调出就是硬盘中的swap分区

# 23. IO与显示器
需反复看

计算机如何让外设工作？
  - 发出写命令
  - 向CPU发出中断
  - 读数据到内存

CPU项控制器中的寄存器读写数据。

控制器完成真正的工作，并向CPU发中断信号。

为了让用户操作简单，操作系统要给用户提供一个简单视图——文件视图。

一段操纵外设的程序：
```
int fd = open("/dev*xxx");
for (int i = 0;i<10;i++)
{
  write(fd,i,sizeof(int));  

}
close(fd)
```

不论什么设备都是open，read，write，close；操作系统为用户提供统一的接口。

不同的设备对应不通过的设备文件(/dev/xxx)，根据设备文件找到控制器的地址、内容格式等等。~~~~

printf的整个过程：
  - 函数库printf
  - 系统调用write
  - 字符设备接口crw_table[]
  - tty设备写tty_write
  - 显示器写con_write

# 24. 键盘
如何使用键盘？~~~~
  - 对于使用者：敲键盘、看结果
  - 对于操作系统：等着用户敲键盘，发出中断

# 25. 生磁盘的使用
磁盘管理

使用磁盘从认识磁盘开始：
  - 盘面、扇区、磁道
  - 磁盘的访问单位是扇区
  - 扇区大小：512字节
  - 扇区的大小是传输时间和碎片浪费的折中

磁盘IO过程：
  - 移动磁头（寻道）
  - 旋转磁盘（旋转）
  - 进行读写（数据传输）

最直接的使用磁盘：
  - 只要往控制器中写柱面、磁头、扇区、缓存位置（写入内存的什么位置）
  - 但是太麻烦，操作系统需要将磁盘进行抽象

第一层抽象：通过盘块号读写磁盘
  - 磁盘驱动负责从block（盘块号）计算出cyl,head,sec(CHS)
  - 磁盘访问时间=写入控制器时间+寻道时间+旋转时间+传输时间
  - 寻道所要花费时间过长，所以我们需要让磁盘少寻道
  - 当一个盘面记录满的时候，盘面将移动到初始位置并使用下一个盘面的磁头，以此来节省时间
  - CHS得到的扇区号LBA（逻辑扇区号）：C*Heads*Sectors+H*Sectors+S
    - 所以S=block%sectors

由于每次访问磁盘的时间是固定的，所以当读写速度增加时，碎片将增大，所以扇区的大小是读写速度和空间利用率的折中。

第二层抽象：多个进程通过队列使用磁盘
  - 多个磁盘访问请求出现在请求队列怎么办？
    - 调度
  - 调度的目标是什么？
    - 目标当然是平均访问延迟小
  - 调度时主要考察什么？
    - 寻道时间是主要矛盾
  - 调度算法：从FCFS开始

FCFS调度：在队列中先来的先调度

SSTF磁盘调度：Shortest seek time first
  - 磁头移动的少
  - 存在饥饿问题：边缘的请求很难得到执行

SCAN磁盘调度：
  - SSTF+中途不回折：每个请求都有处理机会（电梯算法）

生磁盘的使用整理：
  1. 进程“得到盘块号”，算出扇区号
  2. 用扇区号make req，用电梯算法add_request
  3. 进程sleep_on
  4. 磁盘中断处理
  5. do_hd_request算出cyl,head,sector
  6. hd_out调用outp(...)完成端口写

# 26. 从生磁盘到文件
引入文件，对磁盘使用的第三层抽象：
  - 用户眼里文件：字符序列（字符流）
  - 磁盘上的文件：盘块集合
  - 文件：建立字符流到盘块集合的映射关系

操作系统来维护这层映射的关系

使用连续结构（其中一种映射方式）来实现文件，通过FCB(File Control Block)来存储文件信息，FCB中记录了文件的起始块和块数。
  - 结构特点
  - 存取快
  - 动态变化慢

链式结构也可以实现文件：使用链表实现
  - 可以动态增长
  - 但是读取时必须顺序读取，存取比较慢

使用索引结构实现文件：通过索引块寻找盘块号，用一个额外的盘块来存储索引

实际系统中使用的是多级索引：
  - 可以表示很大的文件
  - 很小的文件高效访问
  - 中等大小的文件访问速度也不慢

如果专门为向词霸这样的词典设计文件存储，此时采用哪种结构最好？（A）
  - A.顺序
  - B.链式
  - C.索引
  - D.都一样

因为词典中单词数据固定，没有频繁的动态变化。

# 27. 目录与文件系统
需反复看

第四层抽象：文件系统，抽象整个磁盘

目录怎么用？
  - 根据路径名找到FCB

目录中应该存什么？
  - FCB的编号

树状目录的完整实现：
  - FCB数组+数据盘块集合
  - 根目录的编号放在固定位置
  - 目录项：文件名+对应的FCB的“地址”

磁盘当中的信息：
  - 引导块
  - 超级块：记录两个位图有多大等信息
  - i节点位图：哪些inode空闲，哪些被占用
  - 盘块位图：哪些盘块是空闲的，硬盘大小不通过这个位图的大小也不同
  - i节点：FCB数组+数据盘块集合
  - 数据区

# 28. 目录解析代码实现
get_dir完成真正的目录解析：
  - 核心的正好对应目录树的四个重点：
    - root：找到根目录
    - find_entry：从目录中读取目录项
    - inr：是目录项中的索引节点号
    - iget：再读下一层目录

