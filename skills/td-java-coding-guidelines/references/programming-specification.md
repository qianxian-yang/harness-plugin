# 编程规约（Programming Specification）

> 来源：[Alibaba Java Coding Guidelines - Programming Specification](https://alibaba.github.io/Alibaba-Java-Coding-Guidelines/#1-programming-specification)

## 目录

- [命名规约](#命名规约naming-conventions)
- [常量定义](#常量定义constant-conventions)
- [代码格式](#代码格式formatting-style)
- [OOP 规约](#oop-规约)
- [集合处理](#集合处理collection)
- [并发处理](#并发处理concurrency)
- [控制语句](#控制语句flow-control-statements)
- [注释规约](#注释规约code-comments)
- [其他](#其他other)

---

## 命名规约（Naming Conventions）

### Mandatory

1. **禁止下划线/美元符号开头或结尾**：如 `_name`、`$Object`、`name_` 均不合规。

2. **禁止拼音与英文混用**：必须使用准确的英文拼写（中国专有名词拼音如 `alibaba`、`taobao` 除外）。

3. **类名用 UpperCamelCase**：领域模型除外（DO/BO/DTO/VO 等）。
   - 正例：`MarcoPolo`、`UserDO`、`HtmlDTO`、`XmlService`、`TcpUdpDeal`
   - 反例：`marcoPolo`、`UserDo`、`HTMLDto`、`XMLService`、`TCPUDPDeal`

4. **方法名/参数名/成员变量/局部变量用 lowerCamelCase**。

5. **常量全大写下划线分隔**，语义完整清晰：`MAX_STOCK_COUNT`，而非 `MAX_COUNT`。

6. **抽象类以 Abstract/Base 开头，异常类以 Exception 结尾，测试类以被测类名开头 + Test 结尾**。

7. **数组类型括号跟类型**：`String[] args`，而非 `String args[]`。

8. **Boolean 变量禁止 is 前缀**：`boolean isSuccess` 会导致框架序列化时推断属性名为 `success`，引发序列化错误。

9. **包名全小写**，每个点号后仅一个英文单词，包名单数，类名可复数。

10. **禁止不常见缩写**：`AbsClass`（应为 `AbstractClass`）、`condi`（应为 `Condition`）。

### Recommended

11. **类名体现设计模式**：`OrderFactory`、`LoginProxy`、`ResourceObserver`。

12. **接口方法不加修饰符**（不加 `public`），加 Javadoc 注释。接口中只定义应用级通用常量。

13. **Service/DAO 必须是接口**，实现类以 Impl 结尾（如 `CacheServiceImpl`）。表示能力的接口用形容词命名（如 `Translatable`）。

14. **枚举类名以 Enum 结尾**，成员名全大写下划线分隔：`DealStatusEnum`，成员 `SUCCESS`/`UNKNOWN_REASON`。

15. **分层命名**：
   - Service/DAO 方法：`get`（单个）、`list`（多个）、`count`（统计）、`save`/`insert`（保存）、`remove`/`delete`（删除）、`update`（更新）
   - 领域模型：DO（表名）、DTO（领域名）、VO（页面名），禁止命名为 `*POJO`

## 常量定义（Constant Conventions）

### Mandatory

1. **禁止魔法值**：如 `"Id#taobao_" + tradeId` 中的字符串应定义为常量。

2. **long 类型用大写 `L`**：`Long a = 2l` 容易与 `21` 混淆，应写 `2L`。

### Recommended

3. **按功能拆分常量类**：`CacheConsts`、`ConfigConsts`，不要一个大常量类。

4. **常量共享层级**：
   - 多应用共享 → client.jar 的 `constant` 目录
   - 应用内共享 → 公共模块的 `constant` 目录
   - 子项目/包/类内共享 → 对应层级的 `constant` 目录或 `private static final`

5. **固定范围的值用枚举类**，枚举可附加属性信息：

```java
public Enum {
    MONDAY(1), TUESDAY(2), WEDNESDAY(3), THURSDAY(4),
    FRIDAY(5), SATURDAY(6), SUNDAY(7);
}
```

## 代码格式（Formatting Style）

### Mandatory

1. **大括号规则**：
   - 空代码块直接 `{}`
   - 左括号前不换行，后换行
   - 右括号前换行；右括号后换行（除非后面是 `else` 或逗号）

2. **小括号内侧不加空格**：`if (flag == 0)` 而非 `if ( flag == 0 )`。

3. **关键字与括号间一个空格**：`if (`、`for (`、`while (`。

4. **运算符两侧各一个空格**：`=`、`&&`、`+`、`-`、三元运算符等。

5. **缩进用 4 个空格，禁止 Tab**。

6. **行宽上限 120 字符**（import 语句除外），换行规则：
   - 第二行相对第一行缩进 4 空格，第三行起与第二行对齐
   - 运算符随下文换行
   - `.` 随方法名换行
   - 多参数在逗号后换行
   - 括号前不换行

7. **逗号后加一个空格**：`f("a", "b", "c")`。

8. **文件编码 UTF-8，换行符用 Unix 格式**。

### Recommended

9. 变量声明不必对齐空格。
10. 用单个空行分隔逻辑段，不要连续多个空行。

## OOP 规约

### Mandatory

1. **静态成员通过类名引用**，不通过对象引用。

2. **重写方法必须加 `@Override`**。

3. **可变参数仅用于同类型同语义的场景**，禁止 `Object` 类型可变参数。可变参数放参数列表末尾。

4. **已废弃接口必须加 `@Deprecated` 注解并说明替代方案**，禁止使用已废弃的类或方法。

5. **equals 安全调用**：常量或确定非 null 的对象放前面，如 `"test".equals(object)`。推荐使用 `java.util.Objects#equals`（JDK 7+）。

6. **包装类比较用 `equals`，不用 `==`**：`Integer` 仅在 -128~127 范围内缓存复用对象。

7. **浮点数比较**：基本类型不能用 `==`，包装类不能用 `equals`。方案：
   - 指定误差范围：`Math.abs(a - b) < 1e-6f`
   - 使用 `BigDecimal`（构造时传字符串）

8. **POJO 成员必须用包装类**，RPC 方法参数和返回值必须用包装类，局部变量建议用基本类型。

9. **POJO 类（DO/DTO/VO）成员不设默认值**。

10. **序列化类更新时不要改 `serialVersionUID`**（完全不兼容才改）。

11. **构造方法禁止业务逻辑**，初始化放 `init` 方法。

12. **POJO 类必须实现 `toString`**，继承其他 POJO 时先调 `super.toString`。

### Recommended

13. `String.split()` 结果用下标访问前，检查末尾分隔符是否导致数组长度不符预期。

14. 同名方法放在一起，方法声明顺序：`public/protected` → `private` → `getter/setter`。

15. setter 参数名与字段名一致，getter/setter 中不要放业务逻辑。

16. **循环内拼接字符串用 `StringBuilder.append`**：

```java
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 100; i++) {
    sb.append("hello");
}
```

17. **合理使用 `final`**：不可继承的类、不可重新赋值的变量、不可修改的参数、不可重写的方法。

18. **`clone` 默认浅拷贝**，需深拷贝时注意重写。

19. **严格控制访问级别**：
   - 禁止外部 new → 构造方法 `private`
   - 工具类构造方法不允许 `public`/`default`
   - 子类访问 → `protected`；仅自身访问 → `private`

## 集合处理（Collection）

### Mandatory

1. **重写 `hashCode` 和 `equals`**：Set 元素和 Map 的 key 必须重写。

2. **`keySet()`/`values()`/`entrySet()` 返回的集合不能添加元素**（`UnsupportedOperationException`）。

3. **`Collections.emptyList()`/`singletonList()` 返回的不可变集合不能增删**。

4. **`ArrayList.subList` 不能强转为 `ArrayList`**：它是内部类视图，操作会影响原 list。修改原 list 大小后操作 subList 会 `ConcurrentModificationException`。

5. **list 转数组用 `toArray(T[] array)`**：传入与 list 同大小的数组。禁止无参 `toArray()`（返回 `Object[]`）。

```java
String[] array = new String[list.size()];
array = list.toArray(array);
```

6. **`Arrays.asList` 返回的 list 不支持增删**（底层仍是数组）。修改原数组会影响 asList 的结果。

7. **PECS 原则**：`<? extends T>` 适合频繁读取，`<? super T>` 适合频繁插入。

8. **foreach 中禁止增删元素**，用 `Iterator` 并在并发时同步：

```java
Iterator<String> it = a.iterator();
while (it.hasNext()) {
    String temp = it.next();
    if (删除条件) {
        it.remove();
    }
}
```

9. **`Comparator` 必须满足三规则**（JDK 7+），否则 `Arrays.sort` / `Collections.sort` 抛 `IllegalArgumentException`：
   - x 与 y 比较和 y 与 x 比较结果相反
   - 传递性：x>y 且 y>z 则 x>z
   - 等值一致性：x=y 时，x 与 z 的比较结果和 y 与 z 一致

### Recommended

10. **初始化集合时指定容量**：`new ArrayList<>(initialCapacity)`。

11. **遍历 Map 用 `entrySet`**，不用 `keySet`（keySet 遍历两次）。JDK 8 用 `Map.forEach`。

12. **注意集合对 null 的支持**：

| 集合 | Key | Value | 线程安全 |
|------|-----|-------|---------|
| Hashtable | 不允许 null | 不允许 null | 安全 |
| ConcurrentHashMap | 不允许 null | 不允许 null | 分段锁 |
| TreeMap | 不允许 null | 允许 null | 不安全 |
| HashMap | 允许 null | 允许 null | 不安全 |

13. 去重操作用 Set，不要用 List 的 `contains` 遍历去重。

## 并发处理（Concurrency）

### Mandatory

1. **单例初始化和方法必须线程安全**。

2. **线程必须命名**，便于错误追踪：`super.setName("TimerTaskThread")`。

3. **线程必须通过线程池提供**，禁止显式创建线程。

4. **线程池用 `ThreadPoolExecutor` 创建**，禁止用 `Executors`：
   - `FixedThreadPool`/`SingleThreadPool`：队列上限 `Integer.MAX_VALUE`，可能 OOM
   - `CachedThreadPool`/`ScheduledThreadPool`：线程数上限 `Integer.MAX_VALUE`，可能 OOM

5. **`SimpleDateFormat` 线程不安全**，禁止定义为 static 变量。方案：

```java
private static final ThreadLocal<DateFormat> df = new ThreadLocal<DateFormat>() {
    @Override
    protected DateFormat initialValue() {
        return new SimpleDateFormat("yyyy-MM-dd");
    }
};
```

   JDK 8+ 用 `Instant` 替代 `Date`，`LocalDateTime` 替代 `Calendar`，`DateTimeFormatter` 替代 `SimpleDateFormat`。

6. **`ThreadLocal` 必须在 finally 中 `remove()`**，尤其线程池场景，防止内存泄漏和业务污染：

```java
objectThreadLocal.set(someObject);
try {
    ...
} finally {
    objectThreadLocal.remove();
}
```

7. **锁粒度**：块锁优于方法锁，对象锁优于类锁。

8. **多资源加锁顺序一致**，防止死锁。

9. **`lock()` 放在 try 块外面**，lock 与 try 之间不放其他代码，确保 finally 能正确释放锁。

10. **并发修改同一记录必须加锁**（应用层/缓存/数据库乐观锁）。冲突率 <20% 用乐观锁（重试 ≥3 次），否则用悲观锁。

11. **多定时任务用 `ScheduledExecutorService`**，不用 `Timer`（`Timer` 一个任务异常会杀死所有线程）。

### Recommended

12. `CountDownLatch` 每个线程必须在异常时也调 `countdown`，主线程设超时。

13. **多线程避免共享 `Random` 实例**，JDK 7+ 用 `ThreadLocalRandom`。

14. **双重检查锁定中对象声明为 `volatile`**：

```java
class Foo {
    private volatile Helper helper = null;
    public Helper getHelper() {
        if (helper == null) {
            synchronized (this) {
                if (helper == null)
                    helper = new Helper();
            }
        }
        return helper;
    }
}
```

15. `volatile` 解决多线程内存可见性，写少读多场景有效。写多场景用 `AtomicInteger`，JDK 8+ 推荐 `LongAdder`。

16. 高并发下 HashMap 扩容可能导致死链和 CPU 飙高。

17. `ThreadLocal` 不能解决共享对象的更新问题，推荐使用 `static ThreadLocal`。

## 控制语句（Flow Control Statements）

### Mandatory

1. **switch 每个 case 以 break/return 结束**，必须有 default（即使为空）。

2. **if/else/for/do/while 必须用大括号**，即使只有一行：禁止 `if (condition) statements;`。

3. **if-else 嵌套不超过 3 层**，超过用卫语句或状态模式：

```java
public void today() {
    if (isBusy()) {
        System.out.println("Change time.");
        return;
    }
    if (isFree()) {
        System.out.println("Go to travel.");
        return;
    }
    System.out.println("Stay at home.");
}
```

### Recommended

4. **复杂条件提取为布尔变量**：

```java
boolean existed = (file.open(fileName, "w") != null) && (...) || (...);
if (existed) {
    ...
}
```

5. **循环内避免**：对象/变量声明、数据库连接、try-catch，移到循环外。

6. **批量操作检查入参大小**。

7. **需要参数校验的场景**：低频方法、长时间执行方法、高稳定性方法、Open API、权限相关方法。

8. **可省略参数校验的场景**：高频循环内方法（注释说明）、同机部署的底层 DAO、仅内部调用且参数可控的 private 方法。

## 注释规约（Code Comments）

### Mandatory

1. **类、类变量、方法用 Javadoc**：`/** */` 格式，不用 `// xxx`。

2. **抽象方法/接口方法必须 Javadoc**：包含方法说明、参数描述、返回值、可能的异常。

3. **每个类注明 author 和 date**。

4. **方法内单行注释用 `//` 放代码上方，多行注释用 `/* */`**，注意对齐。

5. **枚举的每个成员都要 Javadoc 注释**。

### Recommended

6. 英文无法清晰表达时可用中文注释，但关键字和专有名词保持英文。

7. 代码逻辑变更时同步更新注释。

8. 注释掉的代码要加说明原因，不用的直接删除（git 有历史记录）。

9. 注释要能准确表达设计思路和业务逻辑，帮助他人快速理解。

10. 命名清晰和结构清晰的代码本身就是自解释的，避免过度注释：

```java
// 不需要这种注释
// put elephant into fridge
put(elephant, fridge);
```

11. **TODO/FIXME 必须注明 author 和时间**，定期清理。

## 其他（Other）

### Mandatory

1. **正则表达式预编译**：`Pattern.compile(...)` 不要放在方法体内，定义为类级常量。

2. **Velocity 中用属性名**：引擎会自动调用 getter。Boolean 类型不要用 is 前缀（包装类 `Boolean` 优先调 `getXxx()`）。

3. **Velocity 变量加感叹号**：`$!{var}`，避免 null 时页面直接显示 `${var}`。

4. **随机整数用 `Random.nextInt()`/`nextLong()`**：不要用 `Math.random() * 10` 取整。

5. **获取当前毫秒用 `System.currentTimeMillis()`**：不用 `new Date().getTime()`。更精确用 `System.nanoTime()`，JDK 8 用 `Instant`。

### Recommended

6. Velocity 模板中不要包含变量声明、逻辑运算符或复杂逻辑。

7. 数据结构初始化时尽量指定大小，避免无限增长导致内存问题。

8. 已废弃的代码或配置及时删除，不要留在项目中。临时移除的代码用 `///` 注释并说明原因。
