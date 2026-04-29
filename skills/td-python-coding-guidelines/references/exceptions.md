# 异常处理专题（PyGuide §2.4 深度展开）

来源：<https://google.github.io/styleguide/pyguide.html#s2.4-exceptions>
配套：`language-rules.md` §2.4 给概要，本文给落地细节与反模式清单。

## 1. 何时用异常

- 异常是把控制流从正常路径「跳出」去处理错误或异常情况的机制。
- 优点：正常路径不被错误处理搅乱；一次跳多层，避免透传错误码。
- 风险：控制流不直观；容易漏掉真正需要处理的错误。

## 2. 优先使用内置异常

- 参数错误 / 前置条件违反：`ValueError`
- 类型错误：`TypeError`
- 键 / 索引缺失：`KeyError`、`IndexError`
- 未实现接口：`NotImplementedError`
- IO / 连接失败：`IOError`、`OSError`、自定义 `ConnectionError`
- 操作在当前状态下不被允许：`RuntimeError`（无更贴切的异常时）

> 原则：**内置异常能表达语义时，不要新造**。

## 3. `assert` 的边界

### 能用的场景
- 仅用来「表达代码内部的不变量」，移除后代码仍然正确。
- **pytest 测试里** 鼓励用 `assert` 校验期望值。

### 不能用的场景
- 校验函数参数 / 调用者契约。
- 业务前置条件（`assert port >= 1024`）。
- 类型缩窄（依赖 `assert port is not None` 让 type checker 推断）。

### Litmus test
> 如果把这行 `assert` 删掉，代码还能正确运行吗？
> - 能 → 允许保留；
> - 不能 → 必须换成 `if` + `raise`。

### 正例

```python
def connect_to_next_port(self, minimum: int) -> int:
    """Connects to the next available port.

    Args:
        minimum: A port value greater or equal to 1024.

    Returns:
        The new minimum port.

    Raises:
        ConnectionError: If no available port is found.
    """
    if minimum < 1024:
        # ValueError 不进 Raises，因为它属于 API 误用而非契约行为
        raise ValueError(f'Min. port must be at least 1024, not {minimum}.')
    port = self._find_next_open_port(minimum)
    if port is None:
        raise ConnectionError(
            f'Could not connect to service on port {minimum} or higher.')
    assert port >= minimum, (
        f'Unexpected port {port} when minimum was {minimum}.')
    return port
```

### 反例

```python
def connect_to_next_port(self, minimum: int) -> int:
    # ❌ 用 assert 校验业务参数
    assert minimum >= 1024, 'Minimum port must be at least 1024.'
    port = self._find_next_open_port(minimum)
    # ❌ 依赖 assert 做类型缩窄
    assert port is not None
    return port
```

> 在 `-O` 优化模式下，`assert` 会被移除；带来被忽略的前置条件失败——很难排查。

## 4. 自定义异常

当内置异常表达不出语义时才自定义，规则：

1. **必须继承现有异常类**（通常是 `Exception` 或其子类；更精确时继承 `ValueError`、`IOError` 等）。
2. **类名以 `Error` 结尾**。
3. **不要引入重复词**：反例 `foo.FooError`、`order.OrderError`。
4. **docstring 描述「这个异常代表什么错误」**，而不是「什么时候被 raise」。

```python
# Yes
class OutOfCheeseError(Exception):
    """No more cheese is available."""

class InvalidOrderStateError(ValueError):
    """The order cannot be transitioned to the requested state."""

# No
class OutOfCheeseError(Exception):
    """Raised when no more cheese is available."""  # 描述发生场景而非语义

class cheese.CheeseError(Exception):  # 重复词
    ...
```

## 5. 禁止 catch-all

- 禁止以下写法：
  - `except:`（捕获一切，包括 `SystemExit`、`KeyboardInterrupt`）；
  - `except Exception:` / `except StandardError:`（吞掉几乎所有错误）。
- **仅两个例外允许**：
  1. **立即 re-raise**：
     ```python
     try:
         do_work()
     except Exception:
         logging.exception('Unexpected failure during do_work')
         raise
     ```
  2. **隔离点**：防止线程、请求 handler、插件等外层崩溃，捕获后记录并继续。此类位置要少而集中。
     ```python
     def run_plugin(plugin):
         try:
             plugin.run()
         except Exception as exc:
             logging.exception('Plugin %s crashed: %r', plugin.name, exc)
             # 隔离点：不让单个插件失败影响整个宿主
     ```

## 6. 最小化 try 块

- `try` 块只包「真正会抛出你关心异常」的那几行。
- 反例：把数据准备、业务处理、日志写入全塞进一个 `try`，`except FooError` 可能意外抓到别处抛的同名异常，掩盖真正的 bug。

```python
# Yes
def load(path: str) -> Config:
    try:
        with open(path) as f:
            raw = f.read()
    except OSError as exc:
        raise ConfigLoadError(f'Cannot read {path!r}') from exc
    return parse_config(raw)  # parse 的异常不在 try 内

# No
def load(path: str) -> Config:
    try:
        with open(path) as f:
            raw = f.read()
        return parse_config(raw)   # parse 抛 ValueError 会被误当成读文件失败
    except OSError as exc:
        raise ConfigLoadError(f'Cannot read {path!r}') from exc
```

## 7. 使用 `finally` 与 `else`

- `finally`：无论是否抛异常都要执行的清理动作（文件关闭、锁释放）。能用 `with` 就优先用 `with`，不得已再用 `finally`。
- `else`：`try` 成功后才执行的动作；能减少 `try` 块体积，让 `except` 只覆盖真正可能抛错的代码。

```python
lock.acquire()
try:
    do_critical_section()
finally:
    lock.release()

try:
    data = fetch(url)
except RequestError as exc:
    handle_fetch_failure(exc)
else:
    # 只有 fetch 成功才会进来；这行如果抛了异常不会被上面的 except 吞掉
    process(data)
```

## 8. 异常链：`raise ... from ...`

- 捕获底层异常后，向上重新抛出更贴合接口语义的异常时，保留原因链：
  ```python
  try:
      raw = db.fetch(key)
  except db.DriverError as exc:
      raise CacheMissError(f'lookup for {key!r} failed') from exc
  ```
- 完全不想保留低层原因：`raise NewError(...) from None`。
- 不要 `except X: raise Y(...)`（丢失 `__cause__`），也不要把底层异常消息强行 `str()` 拼接替代。

## 9. `Raises:` docstring 规则

- 只写 **API 正确使用时** 可能抛出、调用方需要处理的异常。
- **不写 API 误用触发的异常**（例如参数非法抛 `ValueError`）——写进去等同于把误用承诺为 API 行为。
- 包装第三方异常时要说明是否会透传，避免「沉默契约」。

```python
def open_port(minimum: int) -> int:
    """...

    Returns:
        ...

    Raises:
        ConnectionError: If no available port is found.
    # 不要写：ValueError: If minimum < 1024.
    """
```

## 10. 常见反模式清单

- ❌ 用 `assert` 校验入参。
- ❌ `except Exception: pass` / `except: pass`。
- ❌ 一个大 `try` 包整段业务逻辑。
- ❌ 自定义异常不继承已有异常类。
- ❌ `class FooError(Exception): "Raised when foo fails."`（应当描述语义）。
- ❌ 捕获异常后 `raise Other(str(exc))` 丢链。
- ❌ 日志里 `logging.error(f'fail: {exc}')` 丢堆栈——应当 `logging.exception(...)` 或 `logging.error(..., exc_info=True)`。
- ❌ 在 `Raises:` 里写参数非法的 `ValueError`。
- ❌ 返回 `None` 代替抛异常来表达「失败」；调用方忘判断就埋雷。
- ❌ 异常消息里直接插入可变 token 导致无法 grep：`f'user {name} not found'` 若 `name='not'` 就歧义；写 `f'user not found: {name=}'` 更好。

## 11. 审查清单（可直接复用）

- [ ] 优先使用内置异常？
- [ ] `assert` 是否通过 litmus test？业务校验是否换成 `if + raise`？
- [ ] 自定义异常：继承合适基类、`Error` 结尾、无重复词、docstring 描述语义？
- [ ] 是否有 `except:` / `except Exception`？若有，是否属于「re-raise」或「隔离点」例外？
- [ ] `try` 块是否最小化？是否可以把无关代码挪进 `else`？
- [ ] 清理资源是否优先 `with`，其次 `finally`？
- [ ] 跨层异常是否用 `raise ... from exc` 保留链？
- [ ] docstring 的 `Raises:` 是否只列接口契约异常？
- [ ] 异常消息是否满足三要素：精准、插值清晰、可 grep？
