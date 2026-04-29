# 类型标注专题（PyGuide §2.21 + §3.19）

来源：<https://google.github.io/styleguide/pyguide.html#s3.19-type-annotations>
本文覆盖类型标注的全部细则（§3.19.1–§3.19.16）及 §2.21 总则。

## 0. 总则（§2.21）

- 鼓励启用 Python 类型分析；**公共 API 必须带类型标注**。
- 构建期用 pytype / mypy 等工具做类型检查。
- 标注首选写在源文件里；第三方/扩展模块可放在 `.pyi` stub。
- 标注有误导时可加 `# TODO` + 链接，解释当前为何没有标注（例如推断错误）。

## 3.19.1 General Rules

- 熟悉 [type hints](https://docs.python.org/3/library/typing.html)。
- `self`、`cls` 通常无需标注。确实需要时用 `typing.Self`：
  ```python
  from typing import Self
  class BaseClass:
      @classmethod
      def create(cls) -> Self: ...
      def difference(self, other: Self) -> float: ...
  ```
- 不要去标注 `__init__` 的返回类型（`None` 是唯一合法值）。
- 实在无法表达的类型用 `Any`。
- 不必标注模块中所有函数，但至少：
  - 公共 API；
  - 容易出类型错误的代码（历史 bug 或复杂逻辑）；
  - 难理解的代码；
  - 已经稳定不再频繁改动的代码。

## 3.19.2 Line Breaking

- 标注后函数签名常常变成「一参数一行」。为了让返回类型也独占一行，在最后一个参数后加尾逗号：
  ```python
  def my_method(
      self,
      first_var: int,
      second_var: Foo,
      third_var: Bar | None,
  ) -> int:
      ...
  ```
- 首选在参数之间换行，不要在「参数名」和「类型注解」之间换行。
- 如果签名整行能放下，就一行：
  ```python
  def my_method(self, first_var: int) -> int: ...
  ```
- 需要换行时 4 空格悬挂缩进，闭括号对齐 `def`。可选：返回类型与最后一个参数同行。
- 不推荐 pylint 允许的「右括号与左括号对齐」写法。
- 类型尽量不要自行拆分；长到必须拆时，优先拆外层容器、保持子类型完整。
- 单个「参数名:类型」过长时可使用类型别名（见 3.19.6），最后才用「冒号后换行 + 缩进 4」。

## 3.19.3 Forward Declarations

- 引用尚未定义的同文件类时，两种写法二选一：
  - 文件开头 `from __future__ import annotations`（推荐）；
  - 用字符串字面量：`Sequence['MyClass']`。

## 3.19.4 Default Values

- **带类型标注 + 默认值时**，`=` 两侧**加空格**：
  ```python
  def func(a: int = 0) -> int: ...
  ```
- 无类型标注时 `=` 两侧**不加空格**：
  ```python
  def func(a=0): ...
  ```

## 3.19.5 NoneType

- 类型系统里 `None` 就是 `NoneType`。如果一个参数可以为 `None`，**必须显式声明**。
- 推荐 `X | None`（Python 3.10+）；也允许 `Optional[X]` / `Union[X, None]`。
- **禁止隐式可空**：
  ```python
  # No
  def f(a: str = None) -> str: ...
  def f(a: Union[None, str]) -> str: ...
  # Yes
  def f(a: str | None = None) -> str: ...
  def f(a: Optional[str] = None) -> str: ...
  ```

## 3.19.6 Type Aliases

- 复杂类型可以定义别名。
- 别名命名：`CapWords`；仅模块内使用时前缀 `_`。
- 使用 `TypeAlias`（Python 3.10+）：
  ```python
  from typing import TypeAlias

  _LossAndGradient: TypeAlias = tuple[tf.Tensor, tf.Tensor]
  ComplexTFMap: TypeAlias = Mapping[str, _LossAndGradient]
  ```

## 3.19.7 Ignoring Types

- 单行禁用类型检查：`# type: ignore`。
- pytype 允许按错误类别禁用：`# pytype: disable=attribute-error`。
- 禁用要就地写原因注释，否则就是「静默忽略」。

## 3.19.8 Typing Variables

- **内部变量难以推断时用 Annotated Assignment**：
  ```python
  a: Foo = SomeUndecoratedFunction()
  ```
- **不要再用 type comment**（Python 3.6 前的写法，仅在历史代码中存在）：
  ```python
  a = SomeUndecoratedFunction()  # type: Foo   # 不再新增
  ```

## 3.19.9 Tuples vs Lists

- `list[X]`：同构序列，元素类型相同。
- `tuple[X, ...]`：任意长度、同类型元组。
- `tuple[X, Y, Z]`：定长、异构元组（常见于多返回值）。
  ```python
  a: list[int] = [1, 2, 3]
  b: tuple[int, ...] = (1, 2, 3)
  c: tuple[int, str, float] = (1, '2', 3.5)
  ```

## 3.19.10 Type Variables

- 泛型通过 `TypeVar` / `ParamSpec` 表达。
- 命名规则：
  - **有描述性的名字**优先（`AddableType`、`AnyFunction`）。
  - 仅在「不对外可见 **且** 无约束」时可用短名 `_T`、`_P`。
  - 有约束的 `TypeVar` 必须描述性命名。
  ```python
  # Yes
  _T = TypeVar('_T')
  _P = ParamSpec('_P')
  AddableType = TypeVar('AddableType', int, float, str)
  AnyFunction = TypeVar('AnyFunction', bound=Callable)

  # No
  T = TypeVar('T')                          # 对外可见但无下划线前缀
  _T = TypeVar('_T', int, float, str)       # 有约束却没有描述性名
  _F = TypeVar('_F', bound=Callable)        # 同上
  ```
- `typing.AnyStr` 用于同一函数里多个需要同为 `str` 或同为 `bytes` 的参数。

## 3.19.11 String Types

- 新代码不用 `typing.Text`（Python 2/3 兼容历史）。
- 文本用 `str`；二进制用 `bytes`。
- 若多个参数/返回类型必须同为文本或同为字节，用 `AnyStr`。

## 3.19.12 Imports for Typing

- `typing` 和 `collections.abc` 中的符号**直接 import 符号本身**（可一行多个）：
  ```python
  from collections.abc import Mapping, Sequence
  from typing import Any, Generic, cast, TYPE_CHECKING
  ```
- 把这些名字当作关键字；**不要在自己的代码里重用这些名字**。如果冲突，用别名：
  ```python
  from typing import Any as AnyType
  ```
- 在签名标注中**优先抽象容器类型**（`collections.abc.Sequence`、`collections.abc.Mapping`），而不是具体类型 `list` / `dict`。
- 必须用具体类型时（如明确要 `tuple` 定长元组），优先内建 `list` / `tuple`，**不要再用已弃用的 `typing.List` / `typing.Tuple`**。
  ```python
  # Yes
  from collections.abc import Sequence
  def transform(xs: Sequence[tuple[float, float]]) -> Sequence[tuple[float, float]]: ...

  # No
  from typing import List, Tuple
  def transform(xs: List[Tuple[float, float]]) -> List[Tuple[float, float]]: ...
  ```

## 3.19.13 Conditional Imports

- 仅在「运行时必须不能 import，但类型检查时需要」这类特殊情况下使用。
- 优先重构为顶层 import。
- 写法：
  ```python
  import typing

  if typing.TYPE_CHECKING:
      import sketch

  def f(x: 'sketch.Sketch'): ...
  ```
- 约束：
  - 条件导入的类型必须以**字符串**形式被引用；
  - 块内只能放仅用于类型标注的符号（包括别名）；否则运行时会 `NameError`；
  - 块紧跟普通 imports 之后；
  - 块内不留空行；
  - 按普通 imports 排序规则排序。

## 3.19.14 Circular Dependencies

- 由类型标注引起的循环依赖属于代码坏味，优先重构。
- 无法重构时，用 `Any` 作为别名替代循环侧的真实类型：
  ```python
  from typing import Any

  some_mod = Any  # some_mod.py imports this module.

  def my_method(self, var: 'some_mod.SomeType') -> None: ...
  ```
- 别名定义与最后一行 import 之间空一行。

## 3.19.15 Generics

- 使用泛型时**必须显式给出类型参数**，否则视作 `Any`。
  ```python
  # Yes
  def get_names(employee_ids: Sequence[int]) -> Mapping[int, str]: ...

  # No（被解释为 Sequence[Any] -> Mapping[Any, Any]）
  def get_names(employee_ids: Sequence) -> Mapping: ...
  ```
- 最佳类型参数确为 `Any` 时要显式标出；但很多情况下 `TypeVar` 更合适：
  ```python
  # No
  def get_names(employee_ids: Sequence[Any]) -> Mapping[Any, str]: ...

  # Yes
  _T = TypeVar('_T')
  def get_names(employee_ids: Sequence[_T]) -> Mapping[_T, str]: ...
  ```

## 3.19.16 Build Dependencies

- 如果使用 pytype / mypy 做构建期类型检查，把类型检查规则加入构建系统（比如 BUILD 文件），避免误报长期累积。
- 使用了第三方 typing 库时（如 `typing_extensions`），把它列为构建依赖。

## 常见坑 Checklist

- [ ] 参数可以为 `None` 却没写 `| None`？
- [ ] 用 `list` / `dict` 作返回值类型但未参数化？
- [ ] 用了 `typing.List` / `typing.Tuple` 这种已弃用别名？
- [ ] `TypeVar` 名字与规则不符（对外/有约束仍用 `_T`）？
- [ ] 自定义 `TypeAlias` 未以 CapWords / `_Private` 命名？
- [ ] `if TYPE_CHECKING:` 块内引用未用字符串？
- [ ] `__init__` 多余地标了 `-> None`（风格上可选，不强制要求）？
- [ ] `self` / `cls` 被不必要地标注？
- [ ] 带类型标注的默认值没有在 `=` 两侧留空格？
- [ ] 复杂签名是否考虑类型别名？
