## **1\. 什么是Makefile**

一个企业级项目，通常会有很多源文件，有时也会按功能、类型、模块分门别类的放在不同的目录中，有时候也会在一个目录里存放了多个程序的源代码。

这时，如何对这些代码的编译就成了个问题。Makefle就是为这个问题而生的，它定义了一套规则，决定了哪些文件要先编译，哪些文件后编译，哪些文件要重新编译。

整个工程通常只要一个**make**命令就可以完成编译、链接，甚至更复杂的功能。可以说，任何一个Linux源程序都带有一个Makefile文件。

**2\. Makefile的优点**

1. 管理代码的编译，决定该编译什么文件，编译顺序，以及是否需要重新编译；
2. 节省编译时间。如果文件有更改，只需重新编译此文件即可，无需重新编译整个工程；
3. 一劳永逸。Makefile通常只需编写一次，后期就不用过多更改。

**3\. 命名规则**

一般来说将Makefile命名为**Makefile**或**makefile**都可以，但很多源文件的名字是小写的，所以更多程序员采用的是Makefile的名字，因为这样可以将Makefile居前显示。

如果将Makefile命为其它名字，比如Makefile\_demo，也是允许的，但使用的时候应该采用以下方式：

> make -f Makefile\_demo

**4\. 基本规则**

Makefile的基本规则为：

目标：依赖

(tab)规则

目标 --> 需要生成的目标文件 依赖 --> 生成该目标所需的一些文件 规则 --> 由依赖文件生成目标文件的手段 tab --> **每条规则必须以tab开头**，使用空格不行

例如我们经常写的gcc test.c -o test，使用Makefile可以写成：

> test: test.c  gcc test.c -o test

其中，第一行中的test就是要生成的目标，test.c就是依赖，第二行就是由test.c生成test的规则。

Makefile中有时会有多个目标，但Makefile会**将第一个目标定为终极目标**。

**5\. 工作原理**

> **目标的生成：** a. 检查规则中的依赖文件是否存在； b. 若依赖文件不存在，则寻找是否有规则用来生成该依赖文件。

![](res/makefile.assets/v2-c818aa04205e2b120a0adadc20d513b6_b.jpg)

![](res/makefile.assets/v2-c818aa04205e2b120a0adadc20d513b6_720w.webp)

比如上图中，生成calculator的规则是gcc main.o add.o sub.o mul.o div.o -o，Makefil会先检查main.o, add.o, sub.o, mul.o, div.o是否存在，如果不存在，就会再寻找是否有规则可以生成该依赖文件。

比如缺少了main.o这个依赖，Makefile就会在下面寻找是否有规则生成main.o。当它发现gcc main.c -o main.o这条规则可以生成main.o时，它就利用此规则生成main.o，然后再生成终极目标calculator。

整个过程是向下寻找依赖，再向上执行命令，生成终极目标。

> **目标的更新：** a. 检查目标的所有依赖，任何一个依赖有更新时，就重新生成目标； b. 目标文件比依赖文件时间晚，则需要更新。

![](res/makefile.assets/v2-898e9b8060577381c03abb43dacb1898_b.jpg)

![](res/makefile.assets/v2-898e9b8060577381c03abb43dacb1898_720w.webp)

  

比如，修改了main.c，则main.o目标会被重新编译，当main.o更新时，终极目标calculator也会被重新编译。其它文件的更新也是类推。

**6\. 命令执行**

**make:** 使用此命令即可按预定的规则生成目标文件。 如果Makefile文件的名字不为Makefile或makefile，则应加上**\-f**选项，比如：

> make -f Makefile\_demo

**make clean:**

清除编译过程中产生的中间文件（.o文件）及最终目标文件。

如果当前目录下存在名为clean的文件，则该命令不执行。

\-->解决办法：伪目标声明：.PHONY:clean。

**特殊符号：**

**\-** ：表示此命令即使执行出错，也依然继续执行后续命令。如：

\-rm a.o build/

**@**：表示该命令只执行，不回显。一般规则执行时会在终端打印出正在执行的规则，而加上此符号后将只执行命令，不回显执行的规则。如：

> @echo $(SOURCE)

**7\. 普通变量**

**变量定义及赋值：**

变量直接采用赋值的方法即可完成定义，如：

> INCLUDE = ./include/

**变量取值：**

用括号括起来再加个美元符，如：

> FOO = $(OBJ)

系统自带变量：

通常都是大写，比如**CC，PWD，CFLAG**，等等。

有些有默认值，有些没有。比如常见的几个：

> CPPFLAGS : 预处理器需要的选项 如：-I CFLAGS：编译的时候使用的参数 –Wall –g -c LDFLAGS ：链接库使用的选项 –L -l

变量的默认值可以修改，比如CC默认值是cc，但可以修改为gcc：**CC=gcc**

**8\. 自动变量**

**常用自动变量：**

Makefile提供了很多自动变量，但常用的为以下三个。这些自动变量只能在规则中的命令中使用，其它地方使用都不行。

$@ --> 规则中的目标

$< --> 规则中的第一个依赖条件

$^ --> 规则中的所有依赖条件

例如：

> ```
> app: main.c func1.c fun2.c gcc $^ - o $@
> ```
>
> 

其中：$^表示main.c func1.c fun2.c，$<表示main.c，$@表示app。

**模式规则：**

模式规则是在目标及依赖条件中使用%来匹配对应的文件，比如在目录下有main.c, func1.c, func2.c三个文件，对这三个文件的编译可以由一条规则完成：

> ```
> %.o:%.c  $(CC) –c $< -o $@
> ```
>
> 

这条模式规则表示：

main.o由main.c生成，  func1.o由func1.c生成，  func2.o由func2.c生成

这就是模式规则的作用，可以一次匹配目录下的所有文件。

**9\. 函数**

makefile也为我们提供了大量的函数，同样经常使用到的函数为以下两个。需要注意的是，**makefile中所有的函数必须都有返回值**。在以下的例子中，假如目录下有main.c，func1.c，func2.c三个文件。

**wildcard:**

用于查找指定目录下指定类型的文件，跟的参数就是目录+文件类型，比如：

> src = $（wildcard ./src/\*.c)

这句话表示：找到./src 目录下所有后缀为.c的文件，并赋给变量src。

命令执行完成后，src的值为：main.c func1.c fun2.c。

**patsubst:**

匹配替换，例如以下例子，用于从src目录中找到所有.c 结尾的文件，并将其替换为.o文件，并赋值给obj。

```text
obj = $(patsubst %.c ,%.o ,$(src))
```

把src变量中所有后缀为.c的文件替换成.o。

命令执行完成后，obj的值为main.o func1.o func2.o

特别地，如果要把所有.o文件放在obj目录下，可用以下方法：

```text
ob = $(patsubst ./src/%.c, ./obj/%.o, $(src))
```

**10\. -I静态库依赖**

静态库依赖可在Makefile中使用-I统一给出，

```bash
# 预处理参数
CPPLFAGS=-I./include					\
		 -I/usr/include/fastdfs			\
		 -I/usr/include/fastcommon		\
		 -I/usr/local/include/hiredis/  \
		 -I/usr/include/mysql/   \
		-I/home/yuan/packages/fcgi-2.4.1-SNAP-0910052249/ \
		-I/home/yuan/packages/fcgi-2.4.1-SNAP-0910052249/include/

```

1. 格式
    1. -I 头文件所在路径 \ 
2. 当编译缺少该依赖时操作步骤
    1. 首先找到缺失头文件的位置：sudo find / -name “头文件名字”
    2. 将该头文件所在文件夹路径加入编译依赖路径