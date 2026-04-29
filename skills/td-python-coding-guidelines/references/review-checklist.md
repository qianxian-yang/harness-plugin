# Google PyGuide Code Review Checklist

用于 Python 代码评审时逐项核对。覆盖 PyGuide §2（语言）+ §3（样式）。
若某项深度不足，跳转参考：
- 异常：`exceptions.md`
- 类型标注：`type-annotations.md`
- 语言规则：`language-rules.md`
- 样式规则：`style-rules.md`

## A. 结构、导入与包

- [ ] 是否使用 **绝对导入**，以完整包路径引入？
- [ ] 导入是否放在文件顶部（模块 docstring 之后、常量与代码之前）？
- [ ] 按「future → 标准库 → 三方 → 仓库内」分组，组内按路径字典序排序？
- [ ] 是否避免了「导入单个函数/类」（`typing` / `collections.abc` / `typing_extensions` / `six.moves` 除外）？
- [ ] `from x import y as z` 的使用是否符合允许场景（冲突/歧义/过长/过泛）？
- [ ] 是否避免依赖 `sys.path` 隐式定位模块？
- [ ] 每行只放一个 import（除 `typing` / `collections.abc` 的符号可合并）？

## B. 命名与可读性

- [ ] 模块 / 类 / 函数 / 常量 / 变量 命名是否符合约定表（`lower_with_under` / `CapWords` / `CAPS_WITH_UNDER` / `_protected`）？
- [ ] 文件名是 `.py` 且不含 `-`？
- [ ] 没有把类型塞进变量名（`id_to_name_dict`）？
- [ ] 单字符名是否在允许场景（`i/j/k`、`e`、`f`、`_T`）？可见范围大时是否换为描述性名？
- [ ] 保留机制 `__double_and_trailing__` 没有被误用？
- [ ] 数学记号型短名是否在注释 / docstring 注明来源，并窄作用域 `pylint: disable=invalid-name`？

## C. 注释与 Docstring

- [ ] 模块首行 docstring：摘要句 + 空行 + 详情（测试模块可省，仅当有信息量才写）？
- [ ] 公共函数 / 类 / 方法 / 生成器 是否有 docstring？
- [ ] `Args:` / `Returns:` / `Raises:` 小节格式是否统一（悬挂缩进 2 或 4 空格，文件内一致）？
- [ ] 生成器 docstring 用 `Yields:` 而非 `Returns:`？
- [ ] 覆盖方法：有 `@override` 且无行为细化时可省 docstring；否则必写差异？
- [ ] 类 docstring 首句描述「实例代表什么」，公共属性（非 property）放在 `Attributes:`？
- [ ] 异常类 docstring 描述「代表什么错误」而不是「什么时候被 raise」？
- [ ] 行内注释与代码至少 2 空格分隔，`#` 后至少 1 空格？
- [ ] 注释解释「为什么」，而非描述「代码在做什么」？
- [ ] TODO 采用新格式 `TODO: <link> - <desc>`，避免 `TODO: @user` / `TODO(user)`？

## D. 异常处理

详见 `exceptions.md`。

- [ ] 优先使用内置异常（`ValueError` / `TypeError` / …）？
- [ ] `assert` 通过 litmus test（删除不影响业务）？业务校验改为 `if + raise`？
- [ ] 自定义异常：继承已有异常、名字以 `Error` 结尾、无重复词（`foo.FooError`）？
- [ ] 没有出现 `except:` / `except Exception`（除 re-raise 或显式隔离点）？
- [ ] `try` 块是否最小化？与异常无关的代码挪到 `else` 或 `try` 外？
- [ ] 资源清理优先 `with`；必要时用 `finally`？
- [ ] 跨层抛出用 `raise ... from exc` 保留异常链？
- [ ] `Raises:` 里仅列接口契约异常，不列 API 误用触发的异常？
- [ ] 异常 / 错误消息满足：精准 / 插值清晰 / 可 grep？

## E. 正确性与鲁棒性

- [ ] 默认参数不含可变对象 / 运行时求值表达式？
- [ ] `None` 判断用 `is` / `is not`；布尔用 `if not x:`；容器空否用 `if seq:`？
- [ ] 整数场景不误用隐式布尔（防止 `None` 被当成 0）？
- [ ] NumPy 数组空判用 `.size`？
- [ ] 没有依赖「可变全局状态」；不得已时加 `_` 前缀并在 doc 注释说明？
- [ ] 没有使用 Power Features（自定义 metaclass / 动态继承 / `__del__` 清理 / getattr hack）？
- [ ] 没有依赖「内建类型原子性」；线程间通信首选 `queue.Queue`，同步首选 `threading.Condition`？

## F. 控制流与表达式

- [ ] 推导式不含多个 `for` 或多个 filter；复杂情况改普通循环？
- [ ] 用默认迭代器：`for k in d`、`for line in f`、`if x in lst`？
- [ ] Lambda 只用于简单单行；>60–80 字符改为具名函数；常见运算优先 `operator`？
- [ ] 三元表达式每段独占一行可容下？否则改为完整 `if`？
- [ ] 一行一语句（`if cond: do()` 允许，但不能带 `else` 或 `try/except`）？
- [ ] 闭包没有踩「局部变量在 for 里重新绑定」的坑？

## G. Getter / Setter / Property

- [ ] Getter/Setter 仅在有非平凡行为（校验 / 缓存 / 失效 / 重建）时存在；纯读写直接公开属性？
- [ ] `@property` 仅用于廉价、无副作用、符合属性访问直觉的逻辑？
- [ ] 没有用 property 实现「子类想覆盖的计算」？
- [ ] 新加 getter/setter 没有为兼容旧代码而反向绑到 property？

## H. 装饰器与顶层代码

- [ ] 装饰器有清晰收益、docstring 声明「这是一个装饰器」、有单测？
- [ ] 装饰器不依赖 import 时不可用的外部资源（文件/socket/数据库/网络）？
- [ ] 避免 `staticmethod`（换成模块级函数）？`classmethod` 仅用于命名构造器或类级状态？
- [ ] `main()` + `if __name__ == '__main__':` 保护；absl 项目使用 `app.run(main)`？
- [ ] 模块顶层不执行副作用代码（连接、读文件、调用 API 等）？

## I. 资源与 IO

- [ ] 文件 / socket / DB 连接 / mmap / h5py / matplotlib 等使用 `with`？
- [ ] 不支持 `with` 的对象用 `contextlib.closing()`？
- [ ] 生成器管理的昂贵资源有显式强制清理（`contextlib` 包装）？
- [ ] 循环内避免 `+` / `+=` 字符串累积；改用 `list.append` + `''.join` 或 `io.StringIO`？

## J. 字符串、日志与错误消息

- [ ] 字符串格式化用 f-string / `%` / `.format`，不是 `+`？
- [ ] 文件内引号风格一致；多行字符串用 `"""`？
- [ ] logging 调用第一个参数是字面量 pattern，参数作为后续参数（**不是 f-string**）？
- [ ] 错误消息精准匹配实际条件（注意 `float('nan')` 等边界）？
- [ ] 错误消息中的插值清晰（`{p=}` 或 `%r`），便于 grep（避免把可变内容嵌入主干）？

## K. 类型标注

详见 `type-annotations.md`。

- [ ] 公共 API 有类型标注？
- [ ] 可空类型显式用 `X | None`，避免 `a: str = None` 这类隐式写法？
- [ ] 签名偏好抽象容器 `collections.abc.Sequence` / `Mapping`？
- [ ] 没有使用已弃用的 `typing.List` / `typing.Tuple`？
- [ ] 带类型标注的默认值 `=` 两侧有空格；不带类型标注时没有空格？
- [ ] 前向引用用 `from __future__ import annotations` 或字符串字面量？
- [ ] `TypeVar` / `ParamSpec` 命名符合规则（对外 / 有约束必须描述性名）？
- [ ] 类型别名 CapWords；仅模块内使用时前缀 `_`？
- [ ] `if TYPE_CHECKING:` 仅用于运行时必须禁止 import 的情况，且块内符号仅用于标注、被引用时用字符串？
- [ ] 泛型都指定了类型参数（否则会被解释为 `Any`）？
- [ ] `# type: ignore` / `# pytype: disable=...` 都带原因注释？

## L. 格式与空白

- [ ] 行宽 ≤ 80（允许例外：长 URL / 长 import / `# pylint: disable=...`）？
- [ ] 没有反斜杠显式续行？
- [ ] 缩进 4 空格，无 tab？
- [ ] 尾随逗号仅在闭括号不与最后元素同行时使用？
- [ ] 顶级定义之间 2 空行、方法之间 1 空行？
- [ ] 括号/方括号/花括号内无空格，`=`、`,`、`:` 空格遵循规则？
- [ ] 无尾随空白、不用空格对齐 token？
- [ ] 没有分号结尾或一行多语句？
- [ ] `return` / `if` 没有不必要的括号；`1-tuple` 写 `(x,)`？

## M. 函数体量

- [ ] 函数是否小而聚焦？>40 行时有评估是否可拆？
- [ ] 长函数是否存在多重职责？

## N. `__future__` 与现代语法

- [ ] 视需要使用 `from __future__ import ...`（典型：`annotations`）？
- [ ] 未必要时不要删除已有 `__future__` 导入？

---

## 审查意见输出模板

按严重度排序：

1. **Critical**：可能导致错误行为、数据损坏或严重可维护性问题。
2. **Major**：违反核心规范且显著增加后续维护成本。
3. **Minor**：风格一致性 / 可读性改进项。

每条意见包含：

- 问题位置（文件 / 行）；
- 违反的主题（imports / naming / docstring / exceptions / typing / whitespace / logging / resources …）；
- 最小可执行修复建议（给出替代代码或 diff 级别建议，不只是描述问题）。
