# 架构设计原则 - SOLID详解

[[toc]]

# 简介

1. 定义
    * 由5大原则组成
    * 用来指导如何将数据和函数组织成类、模块等
    * 组件设计原则与它一脉相承

2. 历史
    * 由Robert C. Martin汇总提出并推广
    * 1980 → 2000 → 2004 → 2018

| 中文名称     | 英文名称及其简写                      | 含义                                                         |
| ------------ | ------------------------------------- | ------------------------------------------------------------ |
| 单一职责原则 | SRP (Single Responsibility Principle)  | 初始(2004)定义:任何一个软件模块都应该只有一个职责;或者说任何一个软件模块都应该只有一个发生变化的原因；修订(2018)定义:任何一个软件模块都应该只对某一类行为者负责 |
| 开放关闭原则 | OCP (Open-Close Principle)            | 软件实体(类、模块、函数等)应该是可以扩展的，但是不可修改     |
| 里氏替换原则 | LSP (Liskov Substitution Principle)   | 子类型(subtype)必须能够替换掉它们的基类型(basetype)，且不改变原有逻辑 |
| 接口隔离原则 | ISP (Interface Segregation Principle) | 接口应该是内聚的;不应该强迫客户依赖于它们不用的方法          |
| 依赖倒置原则 | DIP(Dependency Inversion Principle)   | a.高层模块不应该依赖于底层模块，二者都应该依赖于抽象; b.抽象不应该依赖于细节。细节应该依赖于抽象。 |


## 单一职责原则(SRP)

> 初始(2004)定义:任何一个软件模块都应该只有**一个职责**;或者说任何一个软件模块都应该**只有一个发生变化的原因**；

> 修订(2018)定义:任何一个软件模块都应该只对**某一类行为者负责**

应用范围：不仅仅局限在模块、类，函数(方法)上也是适用的。下面的解读我们以类为例子，模块/函数与类相似，请读者自行扩展。也不仅局限在面向对象编程上，面向过程编程也是适用的，是一条普适性的准则。

例如，用户信息类

```cpp
class UserInfo {
    private:
        //ID
        long userId;
        std::string userName;
        //Login
        std::string userAccount;
        std::string userPassword;
        std::string createTime;
        std::string lastLoginTime;
        std::string avatarUrl;
        //Contact
        std::string email;
        std::string phoneNumber;
        std::string address;
}

可以拆分成三个类，这样涉及到用户登陆的修改或联系方式的修改，不会直接波及到用户ID信息的修改。
```

![计算工时](/_images/method/arch-principle/计算工时.png)

### 设计初衷

单一职责原则的目的是设计出**更内聚**的概念(模块、类、函数)，从而**降低多个调用者之间的耦合**。


耦合有2类表现：

1. 被迫影响: 上述例子中Userlnfo有多类调用者的情况，假如不拆分为多个类，当调用者A需要增加新的用户标识(例如登录第三方系统的用户名)时，调用者B会间接受影响:被迫重新编译或构建、被迫重新测试等

2. 直接影响: 考虑Employee类，假如CFO团队需要修改工时计算规则，而COO团队不需要修改。由于两者共用了同一个工时计算函数(regularHours)，如果修改者能发现共用而将其拆开修改则大吉，但如果没发现呢(没有用例保护)?

### 落地指引

* 类中含有过多的属性或者方法，或者代码行比较多，可能是一个类需要拆分的提示

* 依赖它的类比较多，且依赖的接口大多不重合;或者它依赖的类比较多，也是一个类需要拆分的提示

* 比较难给类起名字，只能用比较笼统的agent/manager来命名，也从侧面说明该类职责过多，需要拆分

* 类中过半的方法都是集中操作某几个属性，那么这些属性和方法可能需要拆分出一个单独的类

* 从被复用的粒度考虑，如果该类中有部分概念总是被单独复用，那么这些概念可能需要单独拆分出来

### 防止过度设计

从行为者(使用者)角度来指导设计的，还需要从提供者(维护者)角度思考：易于修改

```cpp
编解码类，可以放在一起
Serializer
Deserializer

如果分开，会导致其共同依赖对象变更后，忘记修改其中一个的值
std::string IDENTIFIER_STRING = "UEUEUE";
```

## 开放关闭原则(OCP)

> 软件实体(模块、类、方法等), 应该对 `扩展开放、对修改关闭`

进一步描述就是 `添加一个新的功能` 时应该在现有代码基础上扩展代码(新增模块、类、方法等)而非修改现有代码(修改模块、类、方法等)

应用范围:也不仅局限在面向对象编程上，面向过程编程也是适用的，是一条普适性的准则。

### 理解难点

> 修改:在现有函数、类中改动，且**原有代码的使用者被迫感知这一变化**

* 被迫编译、构建
* 被迫对齐修改(接口重新适配、对齐)
* 被迫重新测试(修改现有用例)

> 扩展:新增函数、类等，原有代码的使用者不感知

关键点:对老用户的影响

### 举例

```cpp
class Shape
{
public:
    virtual void draw() const = 0;
    virtual void error(const std::string& msg);
    int objectID() const;
    ...
};

class Rectangle : public Shape {...};
class Ellipse: public Shape {...};

//新增三角形时，只需同步实现draw方法即可
class Triangle: public Shape {...};
```

### 设计初衷

开放封闭原则的目的是**设计出可扩展性更好**的架构，从而**降低或消除高层组件对低层组件的依赖**

* 可扩展性是衡量架构设计质量的重要维度之一，大部分的设计模式方法都是为了解决可扩展性问题而总结提炼出来的

* 为了低成本的应对需求变化，需要对扩展开放;为了保证现有代码的稳定性，需要对修改关闭。

* 修改不可避免，需要做的是尽量让最核心、最复杂的哪部分逻辑满足OCP，将易变的部分通过抽象隔离在低阶组件上

### 落地指引&防止过度设计

* 备扩展意识、抽象意识、封装意识(高层原则) 
    * 需要熟悉业务，了解业务的变化方向 
    * 需要熟悉常见的设计模式或方法
    * “分离关注点”是关键:基于接口或抽象实现“封闭”，基于实现接口或继承实现“开放

* 低层方法论(设计模式)
    * 设计方法:常用的方法有多态、依赖注入、基于接口或抽象编程
    * 设计模式:就更多了，常用的有策略、装饰、职责链等

* OCP是有代价的
    * **抽象后会影响代码的可读性，特别是对于复杂逻辑来说，为了达到OCP会引入很多的中间层降低依赖**

## 里氏替换原则(LSP)

> 子类对象(objectofsubtype/derivedclass)能够替换程序(program)中任何地方出现的父类对象(object ofbase/parent class)，并且保证原来程序的逻辑行为(behavior)不变(正确性不被破坏)

应用范围: 面向对象编程中的类和它的子类、接口和它的实现

### 理解难点

* 疑惑点：
    * 一定是多态
    * 一定符合LSP么?

* 难点(原则中的限制):
    * 替换后没有改变原来程序的逻辑行为及其约束，可能包括
        * 功能约定 
        * 输入约定 
        * 输出约定(例如是否抛出异常) users 
        * 以及在父类的注释中提及的其他约束
        

核心: `design by contract，按照契约来设计`

```cpp
例如，普通用户和VIP用户购买商品的计费函数 calcCharge()
普通账号可能账户余额不足就会抛出错误；
VIP账号可能账户余额不足仍然能够透支；
这样对应同一个父类对象接口calcCharge，不同的子类逻辑就存在差异了
```

### 落地指引

* 子类是否违背父类声明要实现的功能
    * 父类中提供的sortOrdersByAmount()订单排序函数，是按照金额从小到大来给订单排序的，
    * 而子类重写这个sortOrdersByAmount()订单排序函数之后，是按照创建日期来给订单排序的

* 子类违背父类对输入、输出、异常的约定
    * 在父类中，某个函数约定:运行出错的时候返回null;获取数据为空的时候返回空集合(emptycollection)
    * 而子类重载函数之后，实现变了，运行出错返回异常(exception)，获取不到数据返回 null

* 子类违背父类注释中所罗列的任何特殊说明

    * 父类中定义的withdraw()提现函数的注释是这么写的:“用户的提现金额不得超过账户余额.……"
    * 而子类重写withdraw()函数之后，针对VIP账号实现了透支提现的功能，也就是提现金额可以大于账户余额

**一旦违反了LSP，系统就不得不为此添加大量复杂的应对机制**

## 接口隔离原则(ISP)

> 用户不应该被迫依赖它不需要的接口

应用范围： 不限于编程范式，API接口，类，模块

### 设计初衷

接口隔离原则是为了**降低多个调用者之间的耦合**(被迫依赖导致的耦合):

* 被迫编译、构建
* 被迫对齐修改(接口重新适配、对齐)
* 被迫重新测试(修改现有用例)

### 和单一职责的区别?

更具体:可以说是单一职责在接口上的应用

如果说单一职责原则是为了更好的“内聚”，那么接口隔离原则是为了更好的“解耦”

    * 单一职责面向的是模块、类、函数，且是从**自身设计出发**不要设计出大而全的模块/类/函数，强调内聚。 
    * 而接口隔离原则面向的是接口，**更多的是从接口的用户(调用者)出发**，避免用户依赖了它不需要的逻辑，强调解耦
    * 可以说**它提供了一种判定接口设计是否满足单一职责原则的方法**

### 落地指引

通过多继承方式或Facade模式提供接口给用户

```cpp
Color color = city.streets["Nanjing Avenue"].houses[109].color;

可以通过CityMapFacade去封装City,Street,Houses
Color color = colorOfHouseInStreet("Nanjing Avenue",109);
```

### 如何防止过度设计

* 为了达到接口隔离而把大接口拆分为多个小接口可能会导致接口逻辑离散化。
* 接口的粒度大小取决于调用者的需求和内聚性概念，如果用户只有1个，基本上所需既所得，一般不会存在接口隔离的需要;
* 为了满足接口隔离原则进行物理拆分时，不能仅从各个用户的需求出发，而是要回时考虑接口逻辑的内聚性

## 依赖倒置原则(DIP)

> 高层模块(类)不应该依赖于低层模块(类)，二者都应该依赖于抽象;抽象不应该依赖于细节。细节应该依赖于抽象。

应用范围:不限于编程范式，适用于类、模块等各层次设计

### 理解难点

关键概念
    * 什么是高层、什么是低层
        * 在一个调用链层次中，我们称调用者(用户)为高层概念，被调用者(提供服务者)为低层概念
    * 什么是抽象、什么是细节: 
        * 抽象是现实概念背后的本质，细节是当前用到的现实概念;抽象可以用接口/抽象类来代替;细节可以用具体类或实现来代替
    * 依赖倒置/反转
        * 依赖:调用既依赖。代码依赖方向和程序控制流方向相同，称为正常依赖
        * 倒置:如果相反，就是依赖倒置

### 设计初衷

保持核心逻辑的稳定

    * 高层为业务逻辑层(策略层)，低层为实现层，一般来说高层的变动比低层频繁，因此不期望频繁的变化影响低层实现，虽然这些频繁变动是可以带来价值的
    * 低层的变动一般是技术选型、外部依赖等导致的变动，一般是不带来价值的，因此我们也期望低层的变动尽量不影响高层业务逻辑
    * 核心逻辑一般是稳定的，所以它应该被找出来，作为高层和低层共同的依赖
        * 分离关注点

### 落地指引

* 依赖倒置原则的核心是面向接口编程:
    * 应在代码中多使用抽象接口，尽量避免使用那些多变的具体实现类
    * 任何变量都不应该指向一个具体类
    * 任何类都不应继承自具体类
    * 任何方法都不应该改写父类中已经实现的方法
* 可以采用一些工具生成项目的依赖关系，作为架构重构的指引
* 依赖倒置可以通过依赖注入来实现

### 防止过度设计

* 前文提及的落地指引比较绝对，现实中是无法做到的，因为最终都是要靠具体类来完成具体业务执行的
* 折衷的判断原则是依赖的对象是否稳定(正因为抽象是稳定的，我们才会去依赖抽象)，例如标准库中的类相对是稳定的，String/Vector等，我们就可以直接依赖
