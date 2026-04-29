# 工程规约

> 来源：[Alibaba Java Coding Guidelines - Project Specification](https://alibaba.github.io/Alibaba-Java-Coding-Guidelines/#4-project-specification)

## 应用分层（Application Layers）

### 推荐分层结构（自上而下）

| 层次 | 职责 |
|------|------|
| **Open Interface** | 封装 Service 对外暴露为 RPC/HTTP 接口，网关安全控制、流量控制 |
| **View** | 各终端的模板渲染（Velocity/JS/JSP/移动端） |
| **Web Layer** | 转发访问控制、基本参数校验、不可复用的业务逻辑 |
| **Service Layer** | 具体业务逻辑实现 |
| **Manager Layer** | 通用业务处理层：1) 封装第三方服务并预处理返回值和异常 2) Service 层通用能力下沉（缓存、中间件） 3) 组合复用多个 DAO |
| **DAO Layer** | 数据访问层，与 MySQL/Oracle/HBase 交互 |

### 异常处理分层

- **DAO 层**：`catch (Exception e)` + `throw new DAOException(e)`，不打日志
- **Service/Manager 层**：记录日志，尽量包含参数信息便于排查
- **Web 层**：不允许抛异常，异常时跳转友好错误页
- **Open Interface**：用错误码 + 错误信息处理异常

### 领域模型

| 模型 | 说明 |
|------|------|
| **DO** | Data Object，对应数据库表结构，通过 DAO 层向上传输 |
| **DTO** | Data Transfer Object，Service/Manager 层向上传输的对象 |
| **BO** | Business Object，封装业务逻辑的对象，由 Service 层输出 |
| **Query** | 查询对象，承载上层查询请求。超过 2 个查询条件禁止用 Map |
| **VO** | View Object，展示层对象，通常由 Web 层传输 |

## 二方库规约（Library Specification）

### Mandatory

1. **GAV 规范**：
   - GroupID：`com.{公司/BU}.{业务线}.{子业务线}`（最多 4 级）
   - ArtifactID：`产品名-模块名`（如 `tc-client`、`uic-api`）
   - Version：`主版本号.次版本号.修订号`

2. **版本号规则**：
   - 主版本号：不兼容的 API 修改
   - 次版本号：向下兼容的功能新增
   - 修订号：向下兼容的 bug 修复
   - 初始版本必须 `1.0.0`

3. **线上应用禁止依赖 SNAPSHOT 版本**（安全包除外）。

4. **升级依赖时保持传递依赖版本不变**：用 `dependency:resolve` 和 `dependency:tree` 对比差异。

5. **二方库可以定义枚举类型，但接口返回值禁止用枚举**（含包含枚举的 POJO）。

6. **同组库统一版本变量**：如 `${spring.version}`。

7. **子项目同 GroupId + ArtifactId 必须同 Version**。

### Recommended

8. 依赖声明放 `<dependencies>`，版本指定放 `<dependencyManagement>`。
9. 二方库尽量不包含配置项。

## 服务器规约（Server Specification）

### Recommended

1. **高并发服务器减小 `time_wait`**：默认 240 秒，高并发场景需调小（如 `net.ipv4.tcp_fin_timeout = 30`）。

2. **调大文件描述符上限**：Linux 默认 1024，高并发时容易触发 "open too many files"。

3. **JVM 设置 `-XX:+HeapDumpOnOutOfMemoryError`**：OOM 时自动输出 dump 信息。

4. 内部重定向用 forward，外部重定向用 URL 拼装工具。
