# Google PyGuide 语言规则速查（§2）

来源：<https://google.github.io/styleguide/pyguide.html>
适用：语义/行为层面的规则，覆盖 PyGuide §2.1–§2.21。
配套文件：异常详见 `exceptions.md`；类型标注详见 `type-annotations.md`。

## 2.1 Lint

- 用 `pylint` 并使用官方 `pylintrc`，不要忽略警告。
- 需要抑制警告时使用行级或块级 `# pylint: disable=<symbolic-name>`；如果抑制原因不能从告警名看出，必须补一句说明：
  ```python
  def do_PUT(self):  # WSGI name, so pylint: disable=invalid-name
      ...
  ```
- 优先 `pylint: disable`，不要使用旧写法 `pylint: disable-msg`。
- 用 `pylint --list-msgs` 查全部消息，`pylint --help-msg=<name>` 查单条说明。
- 未使用参数的推荐写法：在函数开头用 `del` 删除并写明原因；`_` / `unused_` 前缀允许但不再推荐（会破坏命名参数调用、也不强制检查真正未使用）。
  ```python
  def viking_cafe_order(spam: str, beans: str, eggs: str | None = None) -> str:
      del beans, eggs  # Unused by vikings.
      return spam + spam + spam
  ```

## 2.2 Imports

- `import` 只用于包和模块，不用于单个函数、类、常量。
- 导入方式：
  - `import x`（导入包或模块）
  - `from x import y`（`x` 是包前缀，`y` 是模块名）
  - `from x import y as z` 仅限以下情况：
    - 同名模块冲突；
    - `y` 与当前模块已有顶层名冲突；
    - `y` 与公共 API 中常用参数名冲突（如 `features`）；
    - `y` 名字过长；
    - `y` 在当前上下文语义过泛（如 `from storage.file_system import options as fs_options`）。
  - `import y as z` 只用于业界标准缩写（如 `import numpy as np`）。
- 禁止相对导入（即使在同包内也用完整包路径）。
- 例外允许按符号名直接导入的模块：`typing`、`collections.abc`、`typing_extensions`，以及 `six.moves` 重定向。

## 2.3 Packages

- 每个模块必须以完整包路径导入。
- 不要假定主程序所在目录在 `sys.path` 中；`import jodie` 应视为指向第三方或顶级 `jodie` 包，而不是本目录下的 `jodie.py`。
- 正反例：
  ```python
  # Yes
  import absl.flags
  from doctor.who import jodie

  # No (依赖 sys.path，歧义)
  import jodie
  ```

## 2.4 Exceptions（概要，详见 `exceptions.md`）

核心原则：
- 优先使用内置异常（如参数错误用 `ValueError`）。
- `assert` 不能承担业务校验与前置条件校验；它可能被优化移除。litmus test：把 `assert` 删掉业务是否还正确？必须「删掉无影响」。pytest 测试中 `assert` 是允许并预期的用法。
- 自定义异常必须继承现有异常类，名字以 `Error` 结尾，避免 `foo.FooError` 这种重复。
- 禁止 `except:` / `except Exception` / `except StandardError`，两种例外：
  1. 立刻 `re-raise`；
  2. 显式隔离点（如线程最外层，防崩溃并记录日志）。
- `try` 块要尽量小，只包住可能抛出的那几行，避免误捕获。
- 用 `finally` 做必要清理。
- `Raises:` docstring 里只列 API 正确使用时可能抛出的异常；API 使用错误触发的异常不应写进去，否则等同把误用当契约。

## 2.5 Mutable Global State

- 避免可变的模块级 / 类级全局状态（破坏封装、难以并行、import 时会改变行为）。
- 确实需要时：
  - 以 `_` 前缀私有化；
  - 外部访问走公共函数或类方法；
  - 在注释或 doc 里写明为什么需要可变全局。
- 模块级常量鼓励使用，命名全大写下划线：`_MAX_HOLY_HANDGRENADE_COUNT = 3`、`SIR_LANCELOTS_FAVORITE_COLOR = "blue"`。

## 2.6 Nested / Local / Inner Classes and Functions

- 允许嵌套，但仅在确实需要闭包（捕获 `self` / `cls` 之外的局部变量）时使用。
- 不要为了「隐藏」而嵌套函数；改为模块级函数，用 `_` 前缀私有化，这样测试仍可访问。
- 内部类（inner class）可以用于小工具类或装饰器实现。

## 2.7 Comprehensions & Generator Expressions

- 简单场景可用；优先可读性而非简洁。
- **不允许** 同一个推导式里有多个 `for` 子句或多个 `filter` 表达式——此时改成普通循环。
- 单个 `for` + 单个 `if` 是允许的；复杂的 mapping/filter 拆多行。
- dict / set 推导、生成器表达式同理。

## 2.8 Default Iterators and Operators

- 容器直接迭代：`for key in adict`、`for line in afile`、`if obj in alist`。
- 不要写 `for key in adict.keys()`、`for line in afile.readlines()`。
- 迭代容器时不要同时修改它。

## 2.9 Generators

- 可按需使用。
- 生成器函数 docstring 用 `Yields:`（不是 `Returns:`）。
- 如果生成器持有昂贵资源，显式强制清理；可用 `contextlib` 包一层（PEP-0533）。

## 2.10 Lambda Functions

- 只用于单行简单表达式。
- 超过 60–80 字符或跨行时改写为具名嵌套函数。
- 常见运算优先用 `operator`：`operator.mul` 好于 `lambda x, y: x * y`。
- 优先用生成器表达式替代 `map()` / `filter()` 配 `lambda`。

## 2.11 Conditional Expressions（三元表达式）

- 简单场景可用，格式：`x = 'yes' if predicate else 'no'`。
- 三部分（true-expr / if-expr / else-expr）必须各自一行可容下；否则改写为完整 `if` 语句。
- 换行时整体用括号包起来：
  ```python
  result = (
      'yes'
      if predicate(value)
      else 'no, false, negative, nay'
  )
  ```

## 2.12 Default Argument Values

- 默认值不能是可变对象（`[]`、`{}`、`set()`）。
- 默认值在模块加载时求值一次，不要用 `time.time()` / `_FLAG.value` 这类「运行时才有意义」的表达式。
- 推荐写法：
  ```python
  def foo(a, b: Sequence | None = None):
      if b is None:
          b = []
  # 空元组因为不可变，可作为默认值
  def foo(a, b: Sequence = ()):
      ...
  ```

## 2.13 Properties

- 仅在 getter/setter 逻辑简单、行为符合属性访问直觉（便宜、不神秘、无副作用）时使用 `@property`。
- 仅读写内部属性时，不要包一层 property——直接暴露公共属性；复杂或有副作用的逻辑就写显式方法（遵循 §3.15 Getters/Setters）。
- 不要用 property 实现子类可能想覆盖/扩展的计算，会引入不直观的继承行为。
- 手写 property descriptor 属于 power feature，除非有强理由否则不用。

## 2.14 True / False Evaluations

- 允许隐式布尔：`if foo:`、`if not foo:`。
- 但必须遵守的例外：
  - 判断 `None` 要显式：`if x is None:` / `if x is not None:`。
  - 布尔变量不要与 `False` 做 `==` 比较，用 `if not x:`；要区分 `False` 与 `None`，写 `if not x and x is not None:`。
  - 容器空否：`if seq:` / `if not seq:`，不要写 `if len(seq):`。
  - 整数小心，不要把 `None` 误当成 `0`；确知是整数时可以直接与 `0` 比较。
  - 注意 `'0'`（字符串）为真。
  - NumPy 数组在布尔上下文可能抛异常，空判用 `if not users.size`。

## 2.16 Lexical Scoping

- 允许使用闭包，但注意：任何一处对某变量赋值就会让它在整个函数作用域内被视为局部变量，哪怕赋值发生在使用之后。
- 常见坑：
  ```python
  i = 4
  def foo(x):
      def bar():
          print(i, end='')
      for i in x:   # 这里让 i 变成 foo 的局部变量，bar 看到的是循环结尾的值
          print(i, end='')
      bar()
  # foo([1, 2, 3]) 打印 1 2 3 3，不是 1 2 3 4
  ```

## 2.17 Function and Method Decorators

- 有清晰收益时再用装饰器。
- 装饰器 docstring 必须说明「这是一个装饰器」；为装饰器写单元测试。
- 装饰器在定义时（通常是模块 import 时）执行；**不要依赖 import 时不可用的外部资源**（文件、socket、数据库、网络）。参数正确时，装饰器应尽可能保证一定成功。
- 装饰器属于顶层代码，参考 §3.17 Main。
- `staticmethod`：除非为了与既有库 API 集成，否则不用，改写模块级函数。
- `classmethod`：仅用于命名构造器，或有进程级缓存这类确实与类强相关的全局状态。

## 2.18 Threading

- 不要依赖内建类型「看起来原子」的行为（`__hash__` / `__eq__` 为 Python 方法时可能不再原子；变量赋值也不保证原子）。
- 线程间通信优先 `queue.Queue`。
- 其他同步用 `threading` 的原语；优先条件变量 `threading.Condition`，而不是手写底层锁。

## 2.19 Power Features

- 避免使用「强力但晦涩」的特性：自定义 metaclass、字节码操作、动态继承、对象 reparenting、import hacks、`getattr` 滥用、修改系统内部、自定义 `__del__` 清理等。
- 标准库内部使用这些特性是可以的，例如 `abc.ABCMeta`、`dataclasses`、`enum`——你可以放心用这些库，不必把自己写的 metaclass 排进来。

## 2.20 Modern Python: from \_\_future\_\_ imports

- 鼓励使用 `from __future__ import ...` 来按文件启用更新语法/语义。
- 当所有运行环境都已原生支持某特性时可以移除；否则哪怕你现在没用到那个特性，保留 `__future__` 行可以防止以后有人无意中回退到旧语义。
- 常见例子（支持 Python 3.5–3.6）：`from __future__ import generator_stop`。
- 新代码中较常用的是 `from __future__ import annotations`（延迟求值注解）。

## 2.21 Type Annotated Code（概要，详见 `type-annotations.md`）

- 鼓励启用 Python 类型分析；公共 API 必须带类型标注。
- 推荐构建期用 pytype 等工具做类型检查。
- 类型标注首选放在源文件里；第三方/扩展模块可用 `.pyi` stub 文件。
- 不可避免的地方可以用 `Any`，并视情况写 TODO/链接说明为何尚未标注。

## 快速记忆口诀

- Import 要绝对、要完整路径。
- `assert` 只是文档，不是门闸。
- 自定义异常结尾 `Error`，继承要基于现有异常。
- 默认参数不写可变对象。
- `None` 用 `is`，空容器用隐式布尔。
- Lambda 一行够、循环一次 `for`、生成器别漏清理。
- 避免可变全局、避免 power features。
- 装饰器别依赖运行时资源。
