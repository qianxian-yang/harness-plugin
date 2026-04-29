# 异常与日志规约

> 来源：[Alibaba Java Coding Guidelines - Exception and Logs](https://alibaba.github.io/Alibaba-Java-Coding-Guidelines/#2-exception-and-logs)

## Exception

### Mandatory

1. **预检查优于 try-catch**：不要捕获 JDK 定义的运行时异常（如 `NullPointerException`、`IndexOutOfBoundsException`），应通过预检查避免。仅在难以预检查时使用 try-catch（如 `NumberFormatException`）。

2. **禁止用异常做流程控制**：异常不能用于普通的控制流，效率低且可读性差。

3. **try-catch 精准化**：不要对大段代码做 try-catch，区分稳定代码和不稳定代码，尽量精确捕获特定异常。

4. **不允许吞掉异常**：不要抑制或忽略异常。不处理则重新抛出，最上层必须处理并转化为用户可理解的信息。

5. **异常时确保回滚**：方法抛出异常时，必须确保事务回滚。

6. **资源必须在 finally 中关闭**：流、连接等可关闭资源必须在 finally 块中处理。Java 7+ 推荐使用 try-with-resources。

7. **finally 中禁止 return**：finally 块中的 return 会导致 try-catch 中的异常丢失或返回值被覆盖。

8. **捕获类型一致性**：捕获的异常类型必须是抛出异常的同类或父类。

### Recommended

9. **null 返回值需文档说明**：方法可以返回 null，但需在 Javadoc 中明确说明，调用方负责空检查。

10. **NPE 高危场景**：
   - 返回包装类拆箱可能 NPE
   - 数据库查询结果可能为 null
   - 集合不为空不代表元素非 null
   - RPC 返回值可能为 null
   - Session 中数据可能为 null
   - 链式调用 `obj.getA().getB().getC()` 易 NPE
   - Java 8+ 推荐使用 `Optional`

11. **错误码 vs 异常**：HTTP/Open API 使用错误码；应用内部推荐抛异常；跨应用 RPC 调用封装 Result（含 isSuccess、错误码、错误信息）。

12. **自定义异常**：不要直接抛出 `RuntimeException`/`Exception`/`Throwable`，使用 `DAOException`、`ServiceException` 等自定义异常。

13. **DRY 原则**：避免重复代码，提取公共逻辑到方法、抽象类或共享模块。

## Logs

### Mandatory

1. **使用 SLF4J 门面**：禁止直接使用 Log4j、Logback 的 API，统一使用 SLF4J：

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
private static final Logger logger = LoggerFactory.getLogger(Abc.class);
```

2. **日志至少保留 15 天**：某些异常可能以周为周期发生。

3. **扩展日志命名**：`appName_logType_logName.log`，如 `mppserver_monitor_timeZoneConvert.log`。错误日志和业务日志分开存储。

4. **TRACE/DEBUG/INFO 级别必须用条件输出或占位符**：

```java
// 条件输出
if (logger.isDebugEnabled()) {
    logger.debug("Processing trade with id: " + id + " symbol: " + symbol);
}

// 占位符（推荐）
logger.debug("Processing trade with id: {} and symbol: {}", id, symbol);
```

5. **Log4j 的 additivity 设为 false**：避免日志重复输出。

6. **异常日志包含上下文和堆栈**：

```java
logger.error(各参数toString + "_" + e.getMessage(), e);
```

### Recommended

7. **谨慎记录日志**：生产环境不用 Debug 级别。Warn 记录业务行为时注意日志量，防止磁盘写满。

8. **Warn vs Error**：Warn 记录无效参数（用于问题追踪），Error 仅记录系统逻辑错误和重要异常。


## 新增异常处理规约（Tongdun）

### Mandatory

1. **禁止吞异常**：catch 后必须记录日志或重新抛出。

2. **禁止用异常控制业务流程**：`try-catch` 不能替代 `if-else`。

3. **finally 中禁止 return**：避免覆盖 `try` 返回值或吞掉异常。

4. **资源处理必须使用 try-with-resources**：`InputStream`、`Connection`、`Session` 等都必须可靠关闭。

5. **分层异常语义必须清晰**：DAO 层抛出 `DAOException`，Service 层抛业务语义异常，Web 层统一转换响应，禁止向外暴露技术异常。

6. **日志门面统一使用 SLF4J**：禁止直接调用 Log4j/Logback API。

7. **日志必须使用占位符并携带异常对象**：

```java
// 正例
log.error("[OrderService#create] failed, orderId={}", orderId, e);

// 反例
log.error("failed, orderId=" + orderId + ", error=" + e.getMessage());
```

8. **生产日志级别要克制**：谨慎开启 `DEBUG`；`WARN` 用于可自愈告警；`ERROR` 用于需人工介入的异常。

### Recommended

9. **异常信息带上下文**：日志中包含入参、关键 ID、业务状态，便于排障。

10. **对外异常信息必须脱敏**：禁止暴露内部堆栈和实现细节。

## 新增注释规约（Tongdun）

### Mandatory

1. **每个 `.java` 文件必须具备完整头部结构**：正确的 `package`、`import` 和类级别 Javadoc（职责、作者）。

2. **`public`/`protected` 方法必须有 Javadoc**：包含 `@param`、`@return`、`@throws`（有异常时）。

3. **接口方法必须有 Javadoc**：并且不显式声明 `public` 修饰符。

4. **代码变更必须同步注释**：禁止注释与代码逻辑不一致。

5. **禁止在代码中维护作者和修改历史**：变更历史由 Git 管理；Javadoc 的 `@author` 可保留邮箱/工号。

### Recommended

6. **注释优先解释“为什么”**：语义清晰的代码不必强行注释“做了什么”。

7. **TODO/FIXME 要有责任人和计划时间**：避免长期悬而未决。

8. **优先使用 `//` 行注释**：除 Javadoc 外不建议使用 `/* */` 块注释。
