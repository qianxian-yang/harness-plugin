---
name: td-python-coding-guidelines
description: 基于 Google Python Style Guide 的 Python 编码与 Code Review 规范技能。当用户编写 Python 代码、评审 Python 代码、修复 lint/docstring/import/naming/exception/type annotation 问题、统一团队 Python 风格、或将既有代码迁移到 Google 风格时使用。适用于 `.py` 源码、测试文件、模块导入与命名规范、异常处理与类型标注场景。
---

# Google Python 编码规约（Google PyGuide）

完整对标官方文档：<https://google.github.io/styleguide/pyguide.html>。
覆盖范围：§2 语言规则（§2.1–§2.21）+ §3 样式规则（§3.1–§3.19）。

## 参考文件结构

| 文件 | 覆盖范围 | 何时加载 |
| --- | --- | --- |
| `references/language-rules.md` | §2.1–§2.21 语言层规则（lint、imports、异常、默认值、真值、装饰器、threading、`__future__`、类型标注总则…） | 编写 / 重构代码前 |
| `references/style-rules.md` | §3.1–§3.18 样式层规则（分号、行宽、空白、注释、docstring、字符串、日志、TODO、imports 格式、命名表、main、函数长度…） | 编写 / 格式化 / 统一风格时 |
| `references/exceptions.md` | §2.4 深度展开：`assert` 边界、自定义异常、catch-all 两个例外、异常链、`Raises:` 约束、反模式清单 | 处理异常、审查错误路径时 |
| `references/type-annotations.md` | §2.21 + §3.19.1–§3.19.16 全部类型标注细节（NoneType、TypeAlias、TypeVar、Generics、`TYPE_CHECKING` …） | 公共 API 标注、重构类型、迁移 typing 用法时 |
| `references/review-checklist.md` | 覆盖 A–N 共 14 组逐项审查清单，附输出模板 | 做 Code Review 时 |

## 执行流程

1. **识别任务类型**
   - 编写 / 重构代码 → 先 `style-rules.md` + `language-rules.md`。
   - 异常处理相关 → 直接读 `exceptions.md`。
   - 类型标注 / typing 迁移 → 直接读 `type-annotations.md`。
   - Code Review → 直接用 `review-checklist.md` 逐项核对。
   - 批量风格迁移 → 先 imports / naming / docstring，再异常与类型标注，最后跑 lint + 测试。

2. **按需加载参考文件**
   - 不要一次性加载全部——按任务类型选择 1–2 个最相关文件。

3. **实施改动或给出审查意见**
   - 给出可执行的修改建议，不只是描述问题。
   - 与仓库已有约定冲突时，优先遵循目标仓库约定，并明确说明与 PyGuide 的差异点。
   - 每条修改在 commit / PR description 中注明所属主题（imports / naming / docstring / exceptions / typing / …）。

4. **输出结果保持可追溯**
   - 审查意见按 `Critical / Major / Minor` 分级（见 `review-checklist.md` 末尾的输出模板）。
   - 在变更总结中说明行为是否改变（默认不改变行为）。

## 使用约束

- 优先提供小步、低风险改动，避免无关重构。
- 保持导入、命名、docstring、异常与类型注解风格一致。
- 需要抑制 lint 时写明原因，并尽量最小化作用范围（`# pylint: disable=xxx` 行级/块级）。
- 测试模块允许比生产代码更精简（docstring、覆盖方法说明），但禁止写无信息量注释。
- 公共 API 必须带类型标注；可空类型用显式 `X | None`；优先 `collections.abc.*` 抽象容器。
- 异常 `Raises:` 只列接口契约异常，不列 API 误用触发的异常。

## 快速入口

- **要写/改代码**：先读 `references/style-rules.md`，再读 `references/language-rules.md`。
- **要处理异常或审查错误路径**：直接读 `references/exceptions.md`。
- **要做类型标注 / 迁移 typing**：直接读 `references/type-annotations.md`。
- **要做 Code Review**：直接使用 `references/review-checklist.md` 的 A–N 清单，按输出模板给结论。
- **批量风格迁移**：imports / naming / docstring → 异常 → 类型标注 → lint / 测试。
