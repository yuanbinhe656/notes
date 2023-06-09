## 条款1：仔细区别 pointer 和 reference 

* 没有所谓的 null reference，一个 reference 必须总代表某个对象。
* 如果你有一个变量，其目的是用来指向另一个对象，但是也有可能它不指向任何对象，那么使用 pointer。
* 如果这个变量总是必须代表一个对象，不允许这个变量为 null，那么使用 reference。
* pointer 可以被重新赋值，指向另一个对象；reference 却总是指向它最初获得的那个对象。
* 当实现一个操作符而其语法需求无法由 pointer 达成，就选择 reference。 例如 operator[]

使用reference条件

1. 该对象一定存在
   1. ref不能指向一个空对象
2. 该ref一直指向该对象
   1. 指正也可以满足，常指针
3. 直接像使用该对象一样使用该ref
   1. 比如在赋值中，直接使用即可，若是指针，需要加*地址解析符

## 条款2：最好使用 C++ 转型操作符

形参与实参是否为常量并不影响参数的传递，重要的是是否发生了改变常量的动作，如果没发生则正确，否则则错误。

* static_cast<type>(expression)         基本转型
  1. 类型转换

* const_cast<type>(expression)          将某个对象的常量性去除掉
  1. 常量转化

* dynamic_cast<type>(expression)        用来执行继承体系中“安全的向下转型或跨系转型动作”
  1. 继承转化，必须含有继承关系，且其父类含有虚函数

* reinterpret_cast<type>(expression)    与编译平台息息相关，不具移植性，最常用用途是转换“函数指针”类型
  1. 用于将不同系统的类型转化，同时可以转化函数指针
  2. 首先从英文字面的意思理解，interpret是“解释，诠释”的意思，加上前缀“re”，就是“重新诠释”的意思；cast在这里可以翻译成“转型”（在侯捷大大翻译的《深度探索C++对象模型》、《Effective C++（第三版）》中，cast都被翻译成了转型），这样整个词顺下来就是“重新诠释的转型”。我们知道变量在内存中是以“…0101…”二进制格式存储的，一个int型变量一般占用32个位（bit)，参考下面的代码首先从英文字面的意思理解，interpret是“解释，诠释”的意思，加上前缀“re”，就是“重新诠释”的意思；cast在这里可以翻译成“转型”（在侯捷大大翻译的《深度探索C++对象模型》、《Effective C++（第三版）》中，cast都被翻译成了转型），这样整个词顺下来就是“重新诠释的转型”。我们知道变量在内存中是以“…0101…”二进制格式存储的，一个int型变量一般占用32个位（bit)
  3. reinterpret_cast 运算符并不会改变括号中运算对象的值，而是对该对象从位模式上进行重新解释”
  4. 从其内存模型本质进行转化，其他相当于仅在外表转化


```cpp
typedef void (*FuncPtr)();
FuncPtr funcPtrArray[10];

int doSomething();
funcPtrArray[0] = reinterpret_cast<FuncPtr>(&doSomething);
```

## 条款3：绝对不要以多态方式处理数组

* 多态的实现是由虚函数执行的，因此若未使用虚函数则多态不能执行，父类指针指向的函数依旧是父类的函数，而非子类的函数

* 多态和指针算术不能混用。

  * 对于指针来说，在指针上相加是其指针类型的大小，因此，若使用父类指针指向子类对象，则其每次增加的距离是父类对象的大小而非子类对象的大小，导致指针指向错误

* 数组对象几乎总是会涉及指针的算术运算，所以数组和多态不要混用。

  

## 条款4：非必要不提供 default constructor

* 添加无意义的 default constructor，会影响 class 的效率。
* 如果 class constructor 可以确保对象的所有字段都会被正确地初始化，付出时间代价和空间代价成本便可以免除。
