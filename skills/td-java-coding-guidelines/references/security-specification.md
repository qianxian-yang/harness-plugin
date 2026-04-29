# 安全规约

> 来源：[Alibaba Java Coding Guidelines - Security Specification](https://alibaba.github.io/Alibaba-Java-Coding-Guidelines/#5-security-specification)

## Mandatory

1. **权限校验**：用户页面或功能必须做权限验证，防止越权访问或篡改他人数据（如查看/修改他人订单）。

2. **敏感数据脱敏**：用户敏感信息禁止直接展示，必须脱敏处理（如手机号 `158****9119`）。

3. **SQL 注入防护**：用户输入的 SQL 参数必须严格检查或通过 METADATA 限制，禁止通过字符串拼接访问数据库。

4. **用户输入校验**：任何用户输入参数都必须经过校验。忽略参数校验可能导致：
   - 过大 page size 导致内存泄漏
   - 恶意 order by 导致慢查询
   - 任意重定向
   - SQL 注入
   - 反序列化注入
   - ReDoS（正则表达式拒绝服务）

5. **输出转义**：用户数据输出到 HTML 页面时，必须做安全过滤或转义，防止 XSS。

6. **CSRF 防护**：表单和 AJAX 提交必须通过 CSRF 安全校验。

7. **防重放限制**：对短信、邮件、电话、订单、支付等操作，必须使用次数限制、疲劳度控制、验证码等防重放措施，避免平台资源被滥用。

## Recommended

8. **用户生成内容风控**：发帖、评论、即时通讯等场景必须做反垃圾/敏感词过滤及其他风控策略。
