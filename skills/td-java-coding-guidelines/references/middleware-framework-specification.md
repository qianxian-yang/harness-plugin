# 中间件与框架规约

## 第八章 Dubbo 框架规约

> 适用范围：所有通过 Dubbo 暴露或消费的接口。

### 8.1 JDK 17+ 必需 JVM 参数

使用 JDK 17+ 时，preboot 脚本或启动命令必须添加：

```shell
--add-exports java.base/sun.nio.ch=ALL-UNNAMED
--add-exports java.base/sun.security.util=ALL-UNNAMED
--add-opens java.base/java.lang=ALL-UNNAMED
--add-opens java.base/java.math=ALL-UNNAMED
--add-opens java.base/java.net=ALL-UNNAMED
--add-opens java.base/java.nio=ALL-UNNAMED
--add-opens java.base/java.security=ALL-UNNAMED
--add-opens java.base/java.text=ALL-UNNAMED
--add-opens java.base/java.util=ALL-UNNAMED
--add-opens java.base/java.util.concurrent=ALL-UNNAMED
--add-opens java.base/java.util.concurrent.atomic=ALL-UNNAMED
--add-opens java.base/sun.net.www.protocol.http=ALL-UNNAMED
--add-opens java.base/sun.net.www.protocol.https=ALL-UNNAMED
--add-opens java.base/sun.net.www.protocol.jar=ALL-UNNAMED
--add-opens jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED
```

### 8.2 序列化

- **【强制】** 统一使用 **Hessian2** 序列化，禁止使用 Java 原生序列化或 JSON 序列化。
- **【强制】** Dubbo 接口入参及返回值的实体类必须实现 `Serializable`，并显式声明 `serialVersionUID`。

### 8.3 生产环境约束

- **【强制】** Dubbo 接口**仅限公司内网使用**，严禁对外暴露（不得配置公网可达的注册中心地址）。
- **【强制】** 接口单次入参与返回值总大小**不超过 1MB**；大批量数据传输改用**内网 HTTP + MinIO**。
- **【强制】** 调用方必须捕获并记录所有异常日志，无论接口是否声明 `throws`：
  ```java
  try {
      result = xxxService.query(request);
  } catch (Exception e) {
      log.error("[xxxService#query] failed, request={}", request, e);
      // 降级处理
  }
  ```
- **【强制】** 接口命名必须符合标准 Java 接口规范，并携带具体业务名称，**禁止通用命名**如 `DataService`、`CommonService`。
- **【强制】** 禁止在两个不同应用中定义**相同包名+相同接口名**的 Dubbo 接口。
- **【强制】** 服务版本号格式必须为 `X.X.X`（纯数字语义化版本），如 `1.0.0`。
- **【强制】** Dubbo 服务端口统一使用 **20880**，禁止自定义端口。

## 第九章 Kafka 框架规约

### 9.1 客户端

- **【强制】** 发送和消费消息必须使用公司内部 **`module-kafka`** 组件，禁止直接使用原生 Kafka 客户端。
- **【强制】** 公司 Kafka 版本固定为 **3.9.1**，禁止使用其他版本依赖。

### 9.2 Producer 配置（强制）

```properties
compression.type=zstd
acks=1
```

### 9.3 Topic 与 Group 规范

- **【强制】** Topic 命名只允许：小写字母、数字、下划线、连字符（`-`），禁止其他字符。
- **【强制】** 生产环境 Topic 需**提前 2 个工作日申请**，不得擅自创建。
- **【强制】** Consumer Group 名称一旦投产**不可变更**；单个业务原则上只允许申请**一个** Group。
- **【强制】** Topic 和 Group 均需通过工单提前申请报备。

### 9.4 容量评估（强制）

使用 Kafka 前必须评估以下指标，并记录在需求文档中：

| 指标 | 说明 | 阈值 |
|------|------|------|
| MPS | 每秒消息数 | > 1000 需联系基础架构评估独立集群 |
| MSZ | 单条消息字节长度 | 一般 ≤ 999KB；> 64KB 需提前沟通 |

## 第十章 ZooKeeper / Curator 规约

- **【强制】** 永远不直接使用原生 ZooKeeper 客户端，必须使用 **Apache Curator** 封装。
- **【强制】** 应用内必须**共享同一个** `CuratorFramework` 实例，禁止重复创建（浪费连接数）。
- **【强制】** 不再使用的 Client 和 Watcher 必须及时关闭，防止连接泄漏。
- **【强制】** **绝对禁止**高频写入（QPS > 10）。
- **【强制】** 单次写入数据最好小于 4KB；单应用写入总量不超过 5MB。
- **【强制】** 不允许擅自创建 ZK Path，必须提前申请报备。
- **【强制】** 单个 Path 下子节点数量禁止超过 **1024**。
- **【强制】** Path 命名只允许：小写字母、数字、下划线、连字符。
- **【强制】** 禁止将 ZooKeeper 当作数据库使用，不适合存储大批量数据或高频读写数据。

## 第十一章 InfluxDB / 监控打点规约

- **【强制】** 强烈建议使用公司 **`module-metric`** 组件打点，禁止自行拼接原始数据直接写入 InfluxDB。
- **【强制】** 任何监控项的 **Tag 值必须可枚举**（如状态码、环境标、服务名），**严禁**将用户 ID、TraceID、SequenceID 等非枚举值作为 Tag，否则会导致 Influx 集群宕机（Cardinality 爆炸）。
- **【强制】** 单机数据上报频率**不高于 6 次/分钟**。

## 第十二章 APEXDB（原 TDKV / AS）规约

- **【强制】** 新集群统一使用 **APEXDB**，老集群尽快迁移。
- **【强制】** Java 应用一律使用 **`tdkv-client`** 客户端。
- **【强制】** 使用前必须走 ZEUS 工单与基础架构沟通，禁止擅自接入。
- **【强制】** 单 Key 对应数据 P999 长度**不超过 64KB**（推荐 4KB 以内）。
- **【强制】** 持久化集群单条数据长度**不低于 0.5KB**（过小浪费存储元数据）。
- **【强制】** 禁止对同一 Key 高频反复写入。
- **【强制】** 持久化删除使用 **APEXDB v3.23.5.19+**；老版本 AS 的 `delete` 操作不可靠。
- **【强制】** 禁止将自己的集群转借给其他业务团队。

## 第十三章 HBase 规约

- **【强制】** 公司 HBase 版本基于 **2.2.4**，1.x 版本不再维护，禁止使用。
- **【强制】** 必须使用 **`module-hbase`** 客户端，禁止使用原生 HBase 客户端。
- **【强制】** RowKey 必须保证**离散**（避免热点），建议前 6 位为 Hash 值。
- **【强制】** 所有表必须设置 **TTL**。
- **【强制】** Region 大小统一 50G；通过 HFile 导入的单个 Region 不超过 25G。
- **【强制】** 数据总量低于 100G 不建议使用 HBase，优先考虑 MySQL。
- **【强制】** RowKey 和列名尽量精简（HBase 存储中列名与数据同存，冗长列名增大存储开销）。
- **【强制】** Client Timeout 建议设置为 RPC Timeout 的 2 倍以上。
- **【推荐】** 写入并发高时使用批量写（`BufferedMutator`）；读并发高时建议前置 Redis/APEXDB 缓存。
- **【推荐】** 批量 Get 单次不要查询过多行（推荐不超过 200 条/批）。
