# JDK 21 虚拟线程规约

> 仅适用于已明确使用 JDK 21 并启用虚拟线程的模块。

## 15.1 Pinning 防护

- **【强制】** 虚拟线程调度器遇到 `synchronized` 同步块时会发生 **Pinning**（虚拟线程被钉在平台线程上），导致平台线程无法被其他虚拟线程复用，吞吐量严重下降。所有在虚拟线程中执行的代码，**将 `synchronized` 替换为 `ReentrantLock`**。

  ```java
  // 反例（虚拟线程中）
  synchronized (lock) { ... }
  
  // 正例
  private final ReentrantLock lock = new ReentrantLock();
  lock.lock();
  try { ... } finally { lock.unlock(); }
  ```

- **【强制】** 排查所有第三方库中的 `synchronized`，重点关注：
  - **JDBC 驱动**：部分驱动内部大量使用 `synchronized`，升级到支持虚拟线程的版本。
  - **连接池**：HikariCP 需 **>= 5.1.0** 才对虚拟线程友好（低版本内部 `synchronized` 导致严重 Pinning）。
  - **Apache Commons Pool**（`commons-pool2`）：`GenericObjectPool`/`GenericKeyedObjectPool` 内部使用 `synchronized` 锁，若调用链路中存在虚拟线程，**整条链路的对象借出/归还操作均会触发 Pinning**。使用 Jedis（基于 commons-pool2）、DBCP2、部分连接池时需格外注意。**解决方案**：将使用 commons-pool2 的调用迁移到平台线程执行器，或替换为原生支持虚拟线程的实现（如 Lettuce + Netty、HikariCP 5.1+）。
  - **SLF4J/Logback**：部分版本的 `ConsoleAppender` 有 `synchronized`，高并发日志场景需升级或切换 Async Appender。

  > **排查命令**：启动时添加 JVM 参数 `-Djdk.tracePinnedThreads=full`，一旦发生 Pinning 会在控制台打印完整调用栈，据此定位第三方库。

- **【强制】** 不可替换 `synchronized` 的第三方库（如旧版 JDBC 驱动），必须**隔离在专用平台线程池**中执行，禁止在虚拟线程直接调用：

  ```java
  // 将阻塞调用提交到平台线程池，虚拟线程等待结果但不被 Pinned
  ExecutorService platformPool = Executors.newFixedThreadPool(cpuCount * 2);
  CompletableFuture.supplyAsync(() -> legacyJdbcCall(), platformPool).join();
  ```

## 15.2 虚拟线程池配置

- **【强制】** 虚拟线程池不设置 `core/max` 限制（虚拟线程轻量，不需要复用），使用 `Executors.newVirtualThreadPerTaskExecutor()`。
- **【强制】** 不要将虚拟线程用于 CPU 密集型任务，只适合 I/O 密集型场景。
- **【强制】** 虚拟线程中禁止使用 `ThreadLocal` 存储大对象（虚拟线程数量极大，`ThreadLocal` 会放大内存占用）。
