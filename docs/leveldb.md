# Tair及Leveldb调研测试结论 #

## 简介 ##
1. leveldb

    leveldb是由谷歌两位工程师开源的一个基于磁盘的KV数据库.其中Key和
    value均以byte arrays存储，支持batch writes,前向和反向遍历，也支持
    Snappy压缩.leveldb只是一个数据库引擎，没有附带的客户端和服务器端网
    络支持。目前已有不少产品可以leveldb作为存储引擎,如下所示:
    - *ssdb*

            基于leveldb开发，支持redis客户端，目前有不少用户.功能简单，
            各方面均不是很成熟，需要进行二次开发。
    - *Riak*

            分布式，可水平扩展性，容错性较好。主要由Erlang实现，产品成
            熟度较高。
    - Tair

            淘宝开源产品，支持多种存储引擎.文档方面不够全面。

2. Tair

    Tair是淘宝内部开源产品，支持不同的后台存储引擎，适用于持久化和非持
    久化的场景。非持久化的 tair 可以看成是一个分布式缓存. 持久化的
    tair将数据存放于磁盘中. 为了解决磁盘损坏导致数据丢失, tair 可以配
    置数据的备份数目, tair 自动将一份数据的不同备份放到不同的主机上,
    当有主机发生异常, 无法正常提供服务的时候, 其余的备份会继续提供服务.


## leveldb架构介绍 ##
1. 图示总览

    ![leveldb](/Users/yayu/Pictures/IT/leveldb-structure.png)

2. 介绍

    从图中可以看出，构成leveldb静态结构的包括六个部分，内存中的
    memtable以及Immutable memtable,磁盘上的current文件,log文件,Manifest文
    件,SSTable文件。存储流程如下所示：

    - 当插入一条key-value数据时,leveldb先将数据插入到log文件(追加)中，成功后
      写入memtable中，既保证了高效写入,也保证了数据的稳定性
    - 当memtable插入的数据到了一个界限之后，会转为Immutable memtable,
      由新的memtable支持写入操作.同时，leveldb在后台会通过调度程序将
      Immutable memtable dump到磁盘上的sstable文件中。
    - sstable内部的数据是key有序的。由Immutable memtable不断dump出来的
      sstable文件越来越多，会进行compact操作，形成新的level的sstable文
      件。

## Tair架构介绍 ##
1. 图示总览

    ![tair](/Users/yayu/Pictures/IT/tair.jpg)

2. 介绍

    tair 作为一个分布式系统, 是由一个中心控制节点和一系列的服务节点组
    成. 我们称中心控制节点为config server. 服务节点是data
    server. config server 负责管理所有的data server, 维护data server的
    状态信息. data server 对外提供各种数据服务, 并以心跳的形式将自身状
    况汇报给config server . config server是控制点, 而且是单点, 目前采
    用一主一备的形式来保证其可靠性. 所有的 data server 地位都是等价的.

    tair 的分布采用的是一致性哈希算法, 对于所有的key, 分到Q个桶中, 桶
    是负载均衡和数据迁移的基本单位. config server 根据一定的策略把每个
    桶指派到不同的data server上. 因为数据按照key做hash算法, 所以可以认
    为每个桶中的数据基本是平衡的. 保证了桶分布的均衡性, 就保证了数据分
    布的均衡性.

    tair目前支持三种存储引擎:
    - mdb

            定位于cache缓存，类似于memcache。支持k/v存取和prefix操作.适
            合做缓存
    - rdb

            定位于cache缓存，采用了redis的内存存储结构。支持k/v，list，
            hash，set，sortedset等数据结构。适用于需要高速访问某些数据
            结构的应用
    - ldb

            定位于高性能存储，并可选择内嵌mdb cache加速，这种情况下
            cache与持久化存储的数据一致性由tair进行维护。 支持k/v，
            prefix等数据结构。今后将支持list，hash，set，sortedset等
            redis支持的数据结构。

            适用于持续大数据量的存入读取，高频度的更新读取,离线大批量
            数据导入后做查询.数据量大，响应时间敏感度不高的cache需求可
            以采用


## 具体适用性分析 ##
1. 数据结构

    现网的结构化日志为一条sid对应多条日志,且因为包含音频,经常会有较大
    的日志出现。leveldb本身只支持简单的byte数组，不支持list等数据结
    构.Tair提供了对二级key的支持，可以以sid为主key,uuid为二级key.

2. 写入操作

    tair提供的java api中，对于二级key的put,没有提供batch操作。所以
    flume在写入时只能单个写入，导致效率较低.

3. 过期时间

    leveldb本身不支持此操作,tair提供了此接口，但在以leveldb做后台引擎
    时不起作用.tair本身提供namesapce的概念，写入数据时可以指定
    namespace。flume可以在取到event header中的sid后，解析出小时,并以此
    为namespace.在一定时间之后，可以通过客户端程序(tair提供)删除整个
    namespace,以达到过期删除效果.

## 测试数据 ##
1. 写入

    现网数据中，合肥的单台汇聚flume每秒钟写入大约 **1500** 条日志(非高
    峰期),北京的单台汇聚flume每秒钟大约写入 **3000** 条日志(非高峰期).测试时，合肥的所有数
    据均全部接入,北京以单台测试.最终测试的写入速度为 **1500** 每秒,仅
    能承接合肥的非高峰期流量.写入的速度提高受制于如下因素:
    - 日志大小. 有音频的日志数据较大，写入较慢
    - 无法以batch 方式put.
    - flume sink 为单线程架构,多线程的稳定性不好.

2. 读取

    测试了合肥的数据读取.因为数据按小时分在不同的namesapce中,如果不考
    虑边界问题，一个sid可以只读取某一个小时的数据. 查询的时间均在
    **200~300** ms左右.

3. 对比

    ssdb公布了一些读写的性能数据，如下图所示:
        
    ![ssdb](/Users/yayu/Pictures/IT/ssdb.png)

    可以看出其在put性能上均差于redis,在get性能上和redis类似.

## 问题 ##
1. leveldb

    leveldb的主要问题在于对各种数据结构的支持较为匮乏,如果在上面封装,
    会影响到写入的效率，这是由其存储结构所决定的.而redis支持的数据结构
    和操作较为丰富

2. tair

    tair的结构较为复杂,也提供一些对复杂数据结构的支持，但还不够完善.其
    结构较为复杂，依赖于淘宝的一些基层库/组件，难以进行二次开发。文档
    较少，使用起来不很便利

3. 日志量大小

    现网的日志有音频的较大，对于网络交互以及存储和读取性能都有不利影响

4. 磁盘损毁

    在缓存系统的选择上，基于机械磁盘并不是很好的考量.以现网为例，每天
    21亿+的数据写入和删除,对磁盘的损耗比较大.leveldb设计之初的应用场景
    就是基于flash storage(SSD).

## 考虑 ##
1. 资源与log分离

    如果能将音频（资源）与日志分开存储，日志存于redis中，音频存于磁盘中，
    单独设计索引结构。这样现有redis应该完全够用,查询效率应该也不会有多
    大损失.在MspLog中，可以依靠flume event header中的callname将ats日志
    过滤出来，但anylog中则很难分离出音频信息。

2. Redis

    Redis各方面成熟度较高,仍是现在做缓存的最佳选择。如有可能，还是尽量增
    加redis的集群规模，同时考虑后续缩减存储数据的大小.
    

    

    
    

    
    

            

