# Cat - 概述

> 主要是参考官网的内容描述。

[[toc]]

# 内容

<img src="/_images/micro-services/middleware/cat/logo/cat_logo03.png" width="50%">

**CAT**

* [GitHub code](https://github.com/dianping/cat)
* [GitHub wiki](https://github.com/dianping/cat/wiki)
* [GitHub C++](https://github.com/dianping/cat/tree/master/lib/cpp)

# CAT 简介 

- CAT 是基于 Java 开发的<font color='red'>实时应用监控平台</font>，为美团点评提供了全面的实时监控告警服务。
- CAT 作为服务端项目基础组件，提供了 Java, C/C++, Node.js, Python, Go 等多语言客户端，已经在美团点评的基础架构中间件框架（MVC框架，RPC框架，数据库框架，缓存框架等，消息队列，配置系统等）深度集成，为美团点评各业务线提供系统丰富的性能指标、健康状况、实时告警等。
- CAT 很大的优势是它是一个实时系统，CAT 大部分系统是分钟级统计，但是从数据生成到服务端处理结束是秒级别，秒级定义是48分钟40秒，基本上看到48分钟38秒数据，整体报表的统计粒度是分钟级；第二个优势，监控数据是全量统计，客户端预计算；链路数据是采样计算。

## Cat 产品价值

- 减少故障发现时间
- 降低故障定位成本
- 辅助应用程序优化

## Cat 优势

- 实时处理：信息的价值会随时间锐减，尤其是事故处理过程中
- 全量数据：全量采集指标数据，便于深度分析故障案例
- 高可用：故障的还原与问题定位，需要高可用监控来支撑
- 故障容忍：故障不影响业务正常运转、对业务透明
- 高吞吐：海量监控数据的收集，需要高吞吐能力做保证
- 可扩展：支持分布式、跨 IDC 部署，横向扩展的监控系统

## 更新日志

- [**最新版本特性一览**](new)
    - 多语言客户端：Java、C/C++、Node.js、Python、Go [传送门](https://github.com/dianping/cat/tree/master/lib)
    
        * [**Java**](https://github.com/dianping/cat/blob/master/lib/java)
        * [**C**](https://github.com/dianping/cat/blob/master/lib/c)
        * [**C++**](https://github.com/dianping/cat/blob/master/lib/cpp)
        * [**Python**](https://github.com/dianping/cat/blob/master/lib/python)
        * [**Go**](https://github.com/dianping/cat/blob/master/lib/go)
        * [**Node.js**](https://github.com/dianping/cat/blob/master/lib/node.js)
    
    - 消息采样聚合
    - 序列化协议升级
    - 全新文件存储引擎

## 监控模型：

支持 <font color='red'>**Transaction、Event、Heartbeat、Metric**</font> 四种消息模型。 [**模型设计**](model)

## 模块简介

### 功能模块

- cat-client: 客户端，上报监控数据
- cat-consumer: 服务端，收集监控数据进行统计分析，构建丰富的统计报表
- cat-alarm: 实时告警，提供报表指标的监控告警
- cat-hadoop: 数据存储，logview 存储至 Hdfs
- cat-home: 管理端，报表展示、配置管理等

> 1. 根目录下 cat-client 模块以后不再维护，下个大版本更新计划移除。新版Java客户端参考：lib/java
> 2. 管理端、服务端、告警服务均使用 cat-home 模块部署即可

### 其他模块

- cat-doc：服务端报表使用文档
- integration：cat和一些第三方工具集成的内容（此部分一部分是由社区贡献，一部分官方贡献）
- lib：CAT 的客户端，包括 Java、C/C++、Python、Node.js、Go
- script：CAT 数据库脚本

## Quick Start

### 服务端

- [集群部署](readme_server)
- [报表介绍](readme_report)
- [配置手册](readme_config)

### 项目设计

- [项目架构](overall)
- [客户端设计](client)
- [服务端设计](server)
- [模型设计](model)

### Copyright and License

[Apache 2.0 License.](LICENSE)

### CAT 接入公司

 ![companys](/_images/micro-services/middleware/cat/logo/companys.png)

