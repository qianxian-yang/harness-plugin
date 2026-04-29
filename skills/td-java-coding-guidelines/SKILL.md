---
name: td-java-coding-guidelines
description: Tongdun Java 开发规约助手。当用户编写 Java 代码、进行 Java 代码审查（Code Review）、询问 Java 编码规范或最佳实践、创建 Java 项目结构、编写 SQL/MyBatis 相关代码、处理 Java 异常和日志时激活。基于《Alibaba Java Coding Guidelines》提供命名、OOP、集合、并发、异常、日志、MySQL、项目分层、安全等方面的编码指导。
---

# TONGDUN Java 开发规约

基于 [Alibaba Java Coding Guidelines](https://alibaba.github.io/Alibaba-Java-Coding-Guidelines/) 提供 Java 编码规范指导。

规约按严重性分为三个级别：
- **[Mandatory]**：必须遵守
- **[Recommended]**：建议遵守
- **[For Reference]**：参考建议

## 1. 编程规约（Programming Specification）

涵盖命名风格、常量定义、代码格式、OOP 规约、集合处理、并发处理、控制语句、注释规约等内容。

**详细规则：** 阅读 [references/programming-specification.md](references/programming-specification.md)

## 2. 异常与日志

涵盖异常处理和日志记录的规范。

**详细规则：** 阅读 [references/exception-and-logs.md](references/exception-and-logs.md)

## 3. MySQL 规约

涵盖建表规约、索引规约、SQL 规约、ORM 映射规约。

**详细规则：** 阅读 [references/mysql-rules.md](references/mysql-rules.md)

## 4. 工程规约

涵盖应用分层、二方库依赖、服务器配置。

**详细规则：** 阅读 [references/project-specification.md](references/project-specification.md)

## 5. 安全规约

涵盖权限校验、数据脱敏、SQL 注入防护、CSRF 防护等。

**详细规则：** 阅读 [references/security-specification.md](references/security-specification.md)

## 中间件与框架规约

涵盖 Dubbo、Kafka、ZooKeeper/Curator、InfluxDB、APEXDB、HBase 的专项规约。

**详细规则：** 阅读 [references/middleware-framework-specification.md](references/middleware-framework-specification.md)


### SPRING数据库事务规约

数据库事务相关规则已并入 MySQL 规约文档。

**详细规则：** 阅读 [references/mysql-rules.md](references/mysql-rules.md)

### JDK 21 虚拟线程规约

涵盖 Pinning 防护、第三方库兼容性排查、线程池配置等虚拟线程专项规则。

**详细规则：** 阅读 [references/virtual-thread-specification.md](references/virtual-thread-specification.md)


## 使用方式

1. **代码编写/审查时**：阅读 `references/programming-specification.md`
2. **处理异常和日志、注解时**：阅读 `references/exception-and-logs.md`
3. **涉及数据库操作/Sring事务规约时**：阅读 `references/mysql-rules.md`
4. **项目架构设计时**：阅读 `references/project-specification.md`
5. **涉及安全相关功能时**：阅读 `references/security-specification.md`
6. **涉及 Dubbo/Kafka/ZK/HBase/APEXDB 等中间件时**：阅读 `references/middleware-framework-specification.md`
7. **涉及事务、JDK 21 虚拟线程时**：阅读 `references/mysql-rules.md` 与 `references/virtual-thread-specification.md`



