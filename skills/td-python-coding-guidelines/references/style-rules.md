# Google PyGuide 样式规则速查（§3）

来源：<https://google.github.io/styleguide/pyguide.html>
适用：格式、空白、命名、注释/docstring、字符串、日志、imports 组织。
配套文件：类型标注详见 `type-annotations.md`。

## 3.1 Semicolons

- 不用分号终止行，也不用分号把两条语句写在一行。

## 3.2 Line length

- 行宽上限 **80 字符**。
- 明确允许的例外：
  - 长 `import` 语句；
  - 注释中的 URL、路径、长 flag；
  - 不含空白的长字符串模块级常量（如 URL / 路径）；
  - Pylint 指令注释（如 `# pylint: disable=invalid-name`）。
- **禁止** 用反斜杠做显式续行；用括号隐式续行。
- 长字符串在括号内拆行：
  ```python
  x = ('This will build a very long long '
       'long long long long long long string')
  ```
- 优先在最高语法层级换行；多次换行保持同一层级。
- docstring 摘要行必须在 80 列内。
- 无法在 80 内放下且 auto-formatter 帮不上时，可以超出，但尽量手工拆行。

## 3.3 Parentheses

- 仅在必要时使用括号：隐式续行、表示元组、消除歧义。
- `return` 和 `if/while` 条件不要额外套括号。
- 单元素元组需要写 `(foo,)`。

## 3.4 Indentation

- 缩进 **4 空格**，禁止 tab。
- 隐式续行时：
  - 要么与开括号对齐，
  - 要么用 4 空格悬挂缩进（第一行不写内容），闭括号单独一行对齐到 `def` / 变量所在行。
- 示例：
  ```python
  foo = long_function_name(
      var_one, var_two, var_three,
      var_four,
  )
  ```

### 3.4.1 Trailing commas

- 只有当闭合符号 `]` / `)` / `}` 与最后一个元素不在同一行时才加尾随逗号。
- 单元素元组除外，永远要逗号：`(foo,)`。
- 尾随逗号是向 Black/Pyink 的提示：触发「每个元素一行」的格式化。

## 3.5 Blank Lines

- 顶级定义（函数/类）之间留 **2 空行**。
- 类中方法之间留 **1 空行**；类 docstring 与第一个方法之间留 1 空行。
- `def` 行后面不空行。
- 函数内部按需插入单空行分段。

## 3.6 Whitespace

- 括号/方括号/花括号内部不留空格。
- 逗号、分号、冒号前不留空格，后面留一个（行末除外）。
- 函数调用参数列表、索引、切片前的 `(` / `[` 不留空格：`spam(1)`、`dict['key']`。
- 二元运算符两侧各一个空格：`=`、`==`、`<`、`<=`、`in`、`is`、`and`、`or`、`not` 等；算术符号按可读性自行判断。
- 无尾随空格。
- 传关键字参数或定义默认参数时，`=` 两侧**不加空格**；**但** 如果同时带类型标注，`=` 两侧**要加空格**：
  ```python
  def complex(real, imag=0.0): ...
  def complex(real, imag: float = 0.0): ...
  ```
- 不要用多余空格纵向对齐 `:` / `#` / `=`，维护成本高。

## 3.7 Shebang Line

- 普通 `.py` 文件不需要 `#!` 开头。
- 要作为可执行脚本直接运行时，第一行写：
  - `#!/usr/bin/env python3`（推荐，兼容 virtualenv）；或
  - `#!/usr/bin/python3`（遵循 PEP-394）。

## 3.8 Comments and Docstrings

### 3.8.1 Docstrings 通用

- 所有模块、类、函数使用 `"""..."""`（三双引号），符合 PEP 257。
- 首行是一句摘要（≤80 列），以 `.`、`?` 或 `!` 结尾。
- 摘要行之后空一行，再写详细说明，缩进对齐首行起始位置。

### 3.8.2 Modules

- 文件开头放 license 样板（Apache 2.0 / BSD / 等，项目要求而定）。
- 模块 docstring 结构：
  ```python
  """A one-line summary of the module or program, terminated by a period.

  Leave one blank line. The rest of this docstring should contain an
  overall description of the module or program. Optionally include brief
  descriptions of exported classes/functions and usage examples.

  Typical usage example:

      foo = ClassFoo()
      bar = foo.function_bar()
  """
  ```

#### 3.8.2.1 Test modules

- 测试文件的模块 docstring 不是必须的；只有当有特殊信息（如运行方式、环境依赖、golden file 更新步骤）时才写。
- 不写空洞的 `"""Tests for foo.bar."""`。

### 3.8.3 Functions and Methods

以下任一成立时必须写 docstring：
- 属于公共 API；
- 非平凡体量；
- 逻辑非显而易见。

Docstring 描述「做什么 / 调用语义」，而非实现细节（副作用要写清，比如会修改入参）。风格可以是描述式（`"""Fetches rows ..."""`）或命令式（`"""Fetch rows ..."""`），**但同一文件内保持一致**。

标准小节（标题行以冒号结尾）：

- **Args:** 按参数名逐条写描述；描述过长用 2 或 4 空格悬挂缩进（全文件一致）。没有类型注解时在描述里写类型。`*args` / `**kwargs` 按原名列出。
- **Returns:**（生成器用 **Yields:**）描述返回语义。只返回 `None` 可省略；若首句以 "Return/Returns/Yield/Yields" 开头且能概括返回值也可省略专门段。不要模仿旧 NumPy 风格把元组拆成多个命名返回。
- **Raises:** 列出与接口契约相关的异常；**不要** 把 API 误用触发的异常写进去（否则等同把误用当契约）。

示例：

```python
def fetch_smalltable_rows(
    table_handle: smalltable.Table,
    keys: Sequence[bytes | str],
    require_all_keys: bool = False,
) -> Mapping[bytes, tuple[str, ...]]:
    """Fetches rows from a Smalltable.

    Retrieves rows pertaining to the given keys from the Table instance
    represented by table_handle. String keys will be UTF-8 encoded.

    Args:
        table_handle: An open smalltable.Table instance.
        keys: A sequence of strings representing the key of each table
          row to fetch. String keys will be UTF-8 encoded.
        require_all_keys: If True only rows with values set for all keys
          will be returned.

    Returns:
        A dict mapping keys to the corresponding table row data fetched.
        Each row is represented as a tuple of strings. For example:

        {b'Serak': ('Rigel VII', 'Preparer'),
         b'Zim': ('Irk', 'Invader')}

        Returned keys are always bytes.

    Raises:
        IOError: An error occurred accessing the smalltable.
    """
```

#### 3.8.3.1 Overridden Methods

- 方法覆盖父类方法时，如果显式标注了 `@override`（来自 `typing_extensions` 或 `typing`），且行为没有实质细化，则可以不写 docstring。
- 没有 `@override` 时必须写 docstring。
- 行为有细化/新增副作用，即使有 `@override` 也要补充差异。
- 占位写法 `"""See base class."""` 可与 `@override` 配合使用。

### 3.8.4 Classes

- 类 docstring 写在 `class` 行下方，首句概括「这个实例代表什么」。
- 不要写 `Class that describes ...`、`Raised when ...` 这类把「类本身是类」也说出来的冗余描述。
- 公共属性（不含 property）写在 `Attributes:` 小节，格式同 `Args:`。
- 示例：
  ```python
  class SampleClass:
      """Summary of class here.

      Longer class information...

      Attributes:
          likes_spam: A boolean indicating if we like SPAM or not.
          eggs: An integer count of the eggs we have laid.
      """

      def __init__(self, likes_spam: bool = False):
          """Initializes the instance based on spam preference.

          Args:
              likes_spam: Defines if instance exhibits this preference.
          """
          self.likes_spam = likes_spam
          self.eggs = 0

      @property
      def butter_sticks(self) -> int:
          """The number of butter sticks we have."""
  ```
- 自定义异常类的 docstring 描述「代表什么错误」，不写 `Raised when ...`。

### 3.8.5 Block and Inline Comments

- 复杂或反直觉的代码块加注释；不要描述「代码做什么」，要解释「为什么这样做」。
- 行内注释距离代码至少 2 空格，`#` 后至少 1 空格：`if i & (i-1) == 0:  # True if i is 0 or a power of 2.`。
- 反例：`# Now go through the b array and make sure ...`（描述式、无信息量）。

### 3.8.6 Punctuation, Spelling, and Grammar

- 注释要像散文一样可读；注意大小写、标点、拼写、语法。
- 长句优先写完整句子；行尾短注释可稍随意，但文件内保持一致。

## 3.10 Strings

- 格式化字符串用 **f-string / `%` / `.format` 之一**；参数全是字符串时也是；不要用 `+` 拼接来格式化；单次 `+` 可以，避免连续 `+`。
  ```python
  # Yes
  x = f'name: {name}; score: {n}'
  x = '%s, %s!' % (imperative, expletive)
  x = '{}, {}'.format(first, second)
  x = a + b
  # No
  x = 'name: ' + name + '; score: ' + str(n)
  ```
- 禁止在循环内用 `+` / `+=` 累积字符串（可能退化成 O(n²)）。改为 `list.append` + `''.join` 或 `io.StringIO`。
- 引号：同一文件保持一致的 `'` 或 `"`；允许为了避免转义切换引号。
- 多行字符串用 `"""`；项目也可约定普通字符串 `'` + 多行 `'''` 的搭配，但 docstring 必须是 `"""`。
- 多行字符串不会跟随缩进；若要去掉首空格用 `textwrap.dedent()` 或改为连接若干单行字符串。

### 3.10.1 Logging

- 对接受 `%` pattern 的 logging 方法：**第一个参数必须是字面量 pattern**，参数作为后续参数传入，**不能用 f-string**。这样：
  - 日志实现可以以 pattern 为维度聚合；
  - 未启用的 log 级别不需要做字符串渲染。

  ```python
  # Yes
  logging.info('Current $PAGER is: %s', os.getenv('PAGER', default=''))
  logging.error('Cannot write to home directory, $HOME=%r', homedir)

  # No
  logging.info(f'Current $PAGER is: {os.getenv("PAGER", "")}')
  logging.info('Current $PAGER is:')
  logging.info(os.getenv('PAGER', default=''))
  ```

### 3.10.2 Error Messages

错误消息（异常 message、面向用户的消息）遵守三条：
1. **消息要精准匹配真实错误条件**（注意 `float('nan')` 等边界）。
2. **插值片段要明显**（优先 `f'... {p=}'` 或 `%r`）。
3. **支持 grep**（避免把可变内容直接嵌入描述主干）。

反例：`logging.warning('The %s directory could not be deleted.', workdir)`——若 `workdir='deleted'`，消息会变成 "The deleted directory could not be deleted."，难以 grep。

## 3.11 Files, Sockets, and similar Stateful Resources

- 文件、socket、DB 连接、`mmap`、`h5py.File`、`matplotlib` figure 等必须显式关闭。
- 首选 `with`：
  ```python
  with open('hello.txt') as f:
      for line in f:
          print(line)
  ```
- 不支持 `with` 的对象用 `contextlib.closing()`：
  ```python
  with contextlib.closing(urllib.urlopen('...')) as page:
      ...
  ```
- 不要依赖 `__del__` 或进程退出来清理关键资源——不同解释器实现 GC 策略不同，生命周期不可控。
- 极少数无法用 context 管理的情况，必须在文档里写清资源生命周期如何管理。

## 3.12 TODO Comments

- 新格式（推荐）：`# TODO: <link-or-ticket> - <description>`
  ```python
  # TODO: crbug.com/192795 - Investigate cpufreq optimizations.
  ```
- 旧格式（不再推荐在新代码使用）：
  ```python
  # TODO(crbug.com/192795): Investigate cpufreq optimizations.
  # TODO(yourusername): ...
  ```
- **避免** `TODO: @yourusername - ...` 这种以个人 / 团队名作 context 的写法。
- 形如「以后某时做某事」的 TODO 必须给出具体日期或具体触发事件（例如「所有客户端支持 XML 响应后删除」），issue 追踪更佳。

## 3.13 Imports formatting

- 每个 import 独占一行；例外：`typing` 和 `collections.abc` 可以一行多符号。
  ```python
  from collections.abc import Mapping, Sequence
  from typing import Any, NewType
  import os
  import sys
  ```
- Imports 放在文件顶部、模块 docstring / license 之后，module-level 常量和代码之前。
- 分组顺序（由泛到专）：
  1. `from __future__` imports；
  2. Python 标准库；
  3. 第三方模块；
  4. 仓库内子包（`from otherproject.ai import mind`）。
  5. **（已弃用）** 同顶层子包下的应用内导入。**新代码不再单独分第 5 组**，统一并入第 4 组。
- 组与组之间可以空一行（可选）。
- 组内按「完整包路径」字典序（忽略大小写）排序，排序基准是 `from path import ...` 中的 `path`。

## 3.14 Statements

- 一般每行一条语句。
- 允许的特例：整条语句能在一行放下时，`if cond: do()` 可以；但不能带 `else`，也不能写 `try: ... except X: ...` 在一行。

## 3.15 Getters and Setters

- 仅当 get/set 具有非平凡的行为（校验、缓存、状态失效、重建）或当前/未来可能非廉价时，使用 getter/setter。
- 只是单纯读/写内部属性——**直接把属性暴露为公有**。
- 命名：`get_foo()` / `set_foo()`，遵循 §3.16 命名规则。
- 不要把新加的 getter/setter 反手绑成 property 来兼容旧代码；旧用法应当可见地失败，提醒调用方适配复杂度变化。

## 3.16 Naming

约定范式：

```
module_name, package_name, ClassName, method_name, ExceptionName,
function_name, GLOBAL_CONSTANT_NAME, global_var_name, instance_var_name,
function_parameter_name, local_var_name, query_proper_noun_for_thing,
send_acronym_via_https
```

- 名字要有描述性；避免删字母式缩写、项目外不通用的缩写。
- 文件名必须 `.py`，不能包含 `-`。

### 3.16.1 Names to Avoid

- 单字符名，除这些允许场景：
  - 计数器 / 迭代器（`i`、`j`、`k`、`v`…）；
  - `try/except` 中的异常变量 `e`；
  - `with` 里的文件句柄 `f`；
  - 无约束的私有 `TypeVar` / `ParamSpec`（如 `_T = TypeVar("_T")`、`_P = ParamSpec("_P")`）；
  - 与论文/算法约定匹配的命名（见 3.16.5）。
- 可见范围越大，名字越要描述性；深层嵌套中 `i` 可能太模糊。
- 禁止：
  - 包/模块名含 `-`；
  - `__双下划线双端__` 名字（Python 保留）；
  - 冒犯性名字；
  - 把类型写进变量名（如 `id_to_name_dict`）。

### 3.16.2 Naming Conventions

- 「Internal」指模块内部，或类内 protected / private。
- 单下划线 `_foo`：有限的 protected 语义，linter 会标注越界访问；**单元测试允许访问被测模块的 protected 常量**。
- 双下划线 `__foo`（dunder 前缀）：类级 name mangling，不推荐，可读性/可测性差，仍非真私有，改用单下划线。
- 一个模块可以放多个类和顶层函数，不需要一 Java 那样一个文件一个类。
- 类名 `CapWords`，模块名 `lower_with_under.py`。
- 测试文件遵循 PEP 8，方法名 `test_<method>_<state>`；兼容使用 `CapWords` 方法名的旧模块时可以用 `test<MethodUnderTest>_<state>`。

### 3.16.3 File Naming

- 扩展名 `.py`，不能含 `-`，以便可导入和单元测试。
- 需要对外提供无扩展名可执行？用软链接或简单 bash wrapper：`exec "$0.py" "$@"`。

### 3.16.4 完整命名约定表

| 类型 | Public | Internal |
| --- | --- | --- |
| Packages | `lower_with_under` | |
| Modules | `lower_with_under` | `_lower_with_under` |
| Classes | `CapWords` | `_CapWords` |
| Exceptions | `CapWords` | |
| Functions | `lower_with_under()` | `_lower_with_under()` |
| Global / Class Constants | `CAPS_WITH_UNDER` | `_CAPS_WITH_UNDER` |
| Global / Class Variables | `lower_with_under` | `_lower_with_under` |
| Instance Variables | `lower_with_under` | `_lower_with_under`（protected） |
| Method Names | `lower_with_under()` | `_lower_with_under()`（protected） |
| Function / Method Parameters | `lower_with_under` | |
| Local Variables | `lower_with_under` | |

### 3.16.5 Mathematical Notation

- 数学密集型代码允许使用与论文/算法约定一致的短名字。
- 使用时必须：
  1. 在注释或 docstring 里写明命名来源（优先附上学术引用链接）；
  2. 公共 API 仍优先用 `descriptive_name`（因为会被脱离上下文使用）；
  3. 用窄作用域的 `# pylint: disable=invalid-name` 消除警告（少量用行末指令，多处用块首指令）。

## 3.17 Main

- 可执行文件把主逻辑放进 `main()`，并用 `if __name__ == '__main__':` 保护，保证模块可被 `pydoc` / 测试 / 静态分析工具 import。
- absl 项目：
  ```python
  from absl import app

  def main(argv: Sequence[str]):
      ...

  if __name__ == '__main__':
      app.run(main)
  ```
- 非 absl：
  ```python
  def main():
      ...

  if __name__ == '__main__':
      main()
  ```
- 文件顶层代码在 import 时都会执行；import 时不应有副作用（别在顶层创建对象、连数据库、调函数等）。

## 3.18 Function length

- 优先小而聚焦的函数；**不硬性设行数限制**。
- 当函数超过 ~40 行时思考是否能拆分；不要因为「现在能跑」就放任长函数，修改者容易引入难排查的 bug。
- 接手长函数时不要畏惧拆分：如果调试困难或想在多处复用局部逻辑，就拆。

## 3.19 Type Annotations（概要）

详见 `type-annotations.md`。关键点：
- 公共 API 带类型标注；`self` / `cls` / `__init__` 返回类型一般不标。
- 可空类型用显式 `X | None`，不要写 `a: str = None`。
- 优先 `collections.abc.Sequence`、`collections.abc.Mapping`，不要再用 `typing.List` / `typing.Tuple`。
- 参数前带类型注解时 `=` 两侧要加空格。
- `typing` / `collections.abc` 中的符号当作关键字，不要在自己代码里重名（重名就用 `as` 别名）。

## Parting Words（§4）

- 「保持一致」优先；改动现有文件时先看周围风格。
- 但一致性不应成为保留旧风格的借口——新风格明显更好时就向新风格收敛。
