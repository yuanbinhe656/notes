# 从零开始学架构 - 高可用架构

[[toc]]

# CAP

* CAP理论
* BASE理论

# 高可用的本质是通过冗余来实现

# 存储高可用

* 常用的高可用存储架构有主备、主从、主主、集群、分区。

  + 主备复制：客户端的操作都是通过主机完成，备机仅起到备份作用，不参与实际业务读写操作。
  + 主从复制：主机负责读写操作，从机只负责读操作，不负责写操作。
  + 主备倒换与主从倒换

    - 设计关键

			- 1.主备间状态判断：包括状态传递的渠道和状态检测的内容。
			- 2.倒换决策：倒换时机、倒换策略、自动程度。
			- 3.数据冲突解决：故障主机恢复后，数据如何同步。

    - 常见架构

			- 互连式：主备直接建立状态传递的渠道。
			- 中介式：主备机之间不直接连接，而都去连接中介，并且通过中介来传递状态信息。
			- 模拟式：主备之间并不传递任何状态数据，而是备机模拟成一个客户端，向主机发起模拟的读写操作，根据读写的响应情况来判断主机的状态。

  + 主主复制

    - 概念：两台主机都是主机，互相将数据复制给对方，客户端可以任意挑选其中的一台机器进行读写操作。
    - 很多数据不能双向复制：例如用户注册ID、库存等。

  + 数据集群

    - 概念：集群就是多台机器组合在一起形成一个统一的系统。(主备、主从、主主架构本质上隐含一个假设：主机能够存储所有数据。)
    - 集群分类

			- 数据集中集群
			- 数据分散集群

				- Elasticsearch集群

    - 分布式事务算法

			- 目的：保证分散在多个节点上的数据统一提交或回滚，以满足ACID要求。
			- 二阶段提交(Two-Phase Commit Protocol,2PC)

				- Commit请求阶段和Commit提交阶段

			- 三阶段提交(Three-Phase Commit Protocol,3PC)

				- 提交判断阶段；提交准备阶段；提交执行阶段。(针对二阶段提交算法存在的协调者单点故障导致参与者长期阻塞问题，引入准备阶段（超时机制)，当协调者故障后，参与者可以通过超时提交来避免一直阻塞。)

    - 分布式一致性算法

			- 目的：保证同一份数据在多个节点上的一致性
			- 机制：复制状态机

				- 副本：多个分布式服务器组成一个集群，每个服务器都包含完整状态机的一个副本。
				- 状态机：状态机接受输入，然后执行操作，将状态改变为下一个状态。
				- 算法：使用算法来协调各个副本的处理逻辑，使得副本的状态机保持一致。

			- 算法：Paxos、Raft、ZAB

  + 数据分区

    - 概念：指将数据按照一定的规则进行分区，不同分区分布在不同的地理位置上，每个分区存储一部分数据，通过这种方式来规避地理级别的故障所造成的巨大影响。
    - 需要考虑的问题

			- 数据量：数据量越大，分区规则会越复杂，考虑的情况也越多。
			- 分区规则：洲际分区、国家分区、城市分区
			- 复制规则

				- 集中式：存在一个总的备份中心，所有分区的数据备份到备份中心。
				- 互备式：每个分区备份另外一个分区的数据。
				- 独立式：每个分区自己有独立的备份中心。

# 计算高可用

* 主备

  + 冷备：备机业务未启动
  + 热备：备机业务已启动

* 主从
* 对称集群：集群中每个服务器的角色一致，可以执行所有任务。
* 非对称集群：集群中的服务器分为多个不同的角色，不同的角色执行不同的任务。

# 业务高可用

* 异地多活

  + 目的：应对系统级的故障。
  + 架构：同城异区、跨城异地、跨国异地。
  + 设计技巧

    - 1.保证核心业务的异地多活
    - 2.核心数据的最终一致性
    - 3.采用多种手段同步数据

			- 消息队列
			- 二次读取
			- 存储系统同步
			- 回溯读取
			- 重新生成数据方式

    - 4.只保证绝大部分用户的异地多活

  + 设计步骤：业务分级、数据分类、数据同步、异常处理

* 接口级的故障应对方案

  + 降级：将某些业务或接口的功能降低，可以是只提供部分功能，也可以是完全停掉所有功能。

    - 系统后门降级
    - 独立降级系统

  + 熔断：通过设定阈值，来应对依赖的外部系统故障的情况。
  + 限流：只允许系统能够承受的访问量进入，超出部分的请求将丢弃。

    - 基于请求限流
    - 基于资源限流

  + 排队：让用户等待很长时间，才能得到处理或长时间等待后仍然无法得到响应。
