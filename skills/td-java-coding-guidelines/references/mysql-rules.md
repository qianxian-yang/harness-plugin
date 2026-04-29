# MySQL 规约

> 来源：[Alibaba Java Coding Guidelines - MySQL Rules](https://alibaba.github.io/Alibaba-Java-Coding-Guidelines/#3-mysql-rules)

## 建表规约（Table Schema）

### Mandatory

1. **布尔字段**：命名为 `is_xxx`，类型 `unsigned tinyint`（1=True, 0=False）。非负值字段一律 `unsigned`。

2. **表名/列名**：小写字母、数字、下划线，禁止数字开头。

3. **禁止复数表名**。

4. **禁止使用 MySQL 关键字**：如 `desc`、`range`、`match`、`delayed` 等。

5. **索引命名**：
   - 主键索引：`pk_列名`
   - 唯一索引：`uk_列名`
   - 普通索引：`idx_列名`

6. **小数用 `decimal`**：禁止 `float`/`double`（有精度丢失风险）。

7. **定长数据用 `char`**。

8. **`varchar` 长度不超过 5000**：超过用 `text`，且建议独立表存储。

9. **必备三字段**：`id`（unsigned bigint 自增主键）、`gmt_create`（DATETIME）、`gmt_modified`（DATETIME）。

### Recommended

10. 表名格式：`[业务名]_[表用途]`，如 `tiger_task`。
11. 数据库名尽量与应用名一致。
12. 列含义变更时及时更新注释。
13. 适当冗余字段提升查询性能（不冗余频繁修改和大字段）。
14. 单表超 500 万行或 2GB 才考虑分库分表。

## 索引规约（Index Rules）

### Mandatory

1. **业务上有唯一特性的字段必须建唯一索引**。
2. **超过三张表禁止 JOIN**：JOIN 的字段类型必须一致且有索引。
3. **varchar 索引必须指定长度**：通常 20 个字符能区分 90%+ 的数据。
4. **禁止左模糊或全模糊**：`LIKE '%xxx'` 或 `LIKE '%xxx%'` 无法使用索引。

### Recommended

5. **ORDER BY 利用索引顺序**：如 `where a=? and b=? order by c`，建索引 `a_b_c`。
6. **利用覆盖索引**避免回表查询。
7. **深分页优化**：用延迟关联或子查询，如 `select a.* from t a, (select id from t where ... LIMIT 100000, 20) b where a.id=b.id`。
8. **EXPLAIN 目标**：至少 RANGE 级别，最好 REF 或 CONSTS。
9. **联合索引把区分度最高的列放最左**；等值条件列优先于范围条件列。

## SQL 规约（SQL Rules）

### Mandatory

1. **用 `COUNT(*)`**：不要用 `COUNT(列名)` 或 `COUNT(1)` 替代。`COUNT(*)` 会统计 NULL 行，`COUNT(列名)` 不会。
2. `COUNT(distinct col1, col2)` 中若某列全为 NULL，即使另一列有值也返回 0。
3. **SUM 注意 NPE**：全 NULL 时 `SUM()` 返回 NULL，用 `IF(ISNULL(SUM(g)), 0, SUM(g))` 规避。
4. **判断 NULL 用 `ISNULL()`**：`NULL=NULL` 返回 NULL 而非 true。
5. **分页查询先判断 count**：count 为 0 立即返回，不执行分页 SQL。
6. **禁止外键和级联更新**：外键逻辑在应用层处理。
7. **禁止存储过程**。
8. **修正数据前先 SELECT 确认**。

### Recommended

9. **IN 子句控制在 1000 以内**。
10. 国际化场景使用 UTF-8，emoji 用 UTF8MB4。
11. 慎用 `TRUNCATE`（无事务、不触发 trigger）。

## ORM 规约（ORM Rules）

### Mandatory

1. **查询指定具体列名**：禁止 `SELECT *`。
2. **POJO 布尔属性不用 is 前缀**，但数据库列名用 `is_` 前缀，需在 resultMap 做映射。
3. **不用 resultClass 做返回参数**：必须定义对应 DO 并配置映射。
4. **禁止 `${}`**：使用 `#{}` 防止 SQL 注入。
5. **不用 iBatis 的 `queryForList(statementName, start, size)`**：会先查全部再 subList，有 OOM 风险。
6. **禁止用 HashMap/HashTable 做查询结果类型**。
7. **更新记录时同步更新 `gmt_modified`**。

### Recommended

8. **不定义万能更新接口**：只更新需要变更的字段，避免误更新和 binlog 膨胀。
9. 慎用 `@Transactional`：影响 QPS，需考虑缓存、搜索引擎、消息等回滚。

## 数据库事务规约（Tongdun）

### Mandatory

1. **严禁**使用自定义 AOP 切点表达式或自定义注解切面批量拦截 Service/方法来管理事务。  
   - 切点表达式配置错误时，无需数据库连接的方法（如纯计算、缓存读取、远程调用）也会获取 DB 连接，导致接口响应慢、连接池耗尽、超时雪崩。  
   - 事务边界隐藏在切面配置中，代码 Review 时无法直观感知事务范围，容易造成大事务或事务嵌套问题。  
   - 切面执行顺序难以预测，与其他 AOP（如权限、日志、缓存）叠加时行为复杂。  
   典型违规：在 Spring XML 或 `@Configuration` 中配置 `<tx:advice>` + `<aop:advisor>` 指向 `execution(* com.tongdun.*.service..*(..))`，或使用自定义 `@TxRequired` + `@Aspect` 处理事务。

2. 事务内操作时间尽量短，**禁止**在事务内调用 RPC/Dubbo、发送 Kafka 消息、执行大批量查询、调用外部 HTTP 接口等耗时操作，防止长事务锁表。

3. 事务回滚必须记录日志（包含业务上下文和异常堆栈），便于追踪数据一致性问题。

4. 禁止跨服务（跨 JVM）使用分布式事务注解；分布式一致性需通过可靠消息（Outbox 模式）或 Saga 方案实现。

### Recommended

5. 推荐在 Service 实现类方法上使用 Spring `@Transactional` 声明事务，事务边界清晰可见。  
   - 必须指定 `rollbackFor = Exception.class`，否则受检异常默认不回滚。  
   - 同一类内部方法调用不走代理，`@Transactional` 不生效（需通过 `ApplicationContext.getBean()` 或重构为独立类）。  
   - 不要在 `public` 方法以外使用（Spring AOP 不代理非 public 方法）。

```java
@Service
public class OrderServiceImpl implements OrderService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createOrder(OrderDTO dto) {
        orderDao.insert(convert(dto));
        inventoryDao.deduct(dto.getSkuId(), dto.getQty());
    }
}
```

6. 对于复杂事务编排（多数据源、条件回滚、嵌套事务等），建议使用编程式事务（`TransactionTemplate`）获得更精细控制。

```java
transactionTemplate.execute(status -> {
    try {
        orderDao.insert(order);
        inventoryDao.deduct(order.getSkuId(), order.getQty());
        return Boolean.TRUE;
    } catch (Exception e) {
        status.setRollbackOnly();
        log.error("[OrderService#create] tx failed, order={}", order, e);
        throw e;
    }
});
```
