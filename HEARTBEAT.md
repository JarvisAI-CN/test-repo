# HEARTBEAT.md - 心跳任务列表

## 每次心跳检查

### 凌晨自主学习触发
**检查时间**: 每次心跳时
**触发条件**: 
- 凌晨时段（00:00-05:00 GMT+8）
- 标记文件存在：`/tmp/nightly-learning/status`

**执行步骤**:
1. 检查 `/tmp/nightly-learning/status` 是否存在且内容为 "pending"
2. 检查当前时间是否在 00:00-05:00 之间
3. 如果满足条件：
   - 读取 `/root/.openclaw/workspace/Zettelkasten/凌晨自主学习计划.md`
   - 执行学习任务（知识整理、内容准备、学习提升、系统维护）
   - 完成后更新状态为 "completed"
4. 如果不满足：跳过，继续其他任务

**备注**:
- cron任务每天00:00会创建标记文件
- 只有在凌晨时段的心跳才会触发执行
- 避免重复执行：状态文件管理

---

## 自动备份任务
当收到系统事件"执行备份任务: /root/.openclaw/workspace/backup.sh"时：
1. 执行备份脚本: `/root/.openclaw/workspace/backup.sh`
2. 检查备份日志: `tail -20 /var/log/backup_123pan.log`
3. 如果备份失败，发送告警通知

## 待办文件检查（每小时）⭐ 新增
**频率**: 每次心跳时
**文件位置**: `/root/.openclaw/workspace/TODO.md`

**执行步骤**:
1. 读取 `TODO.md`
2. 检查"🔴 第一象限：重要且紧急"是否有未完成任务
3. 如果有，立即处理最紧急的任务
4. 更新任务状态（完成/进行中）
5. 检查是否有超期任务，调整优先级

**四象限法则**:
- 🔴 重要且紧急 → 立即处理
- 🟠 紧急但不重要 → 快速处理
- 🟡 重要但不紧急 → 计划处理
- 🟢 不重要且不紧急 → 凌晨00:00-05:00处理

**自动检查脚本**: `/root/.openclaw/workspace/check_todo.sh`

---

## 系统检查（每4-6小时执行一次）
- [ ] 检查123盘挂载状态 (`mount | grep 123pan`)
- [ ] 检查磁盘空间 (`df -h /mnt/123pan`)
- [ ] 检查最新备份时间 (`ls -lt /mnt/123pan/备份/ | head -5`)

## 每日学习任务

### 阅读OpenClaw文档
**频率**: 每天至少一次
**文档地址**: https://docs.openclaw.ai/
**目的**: 了解自身能力、学习新功能、保持工具熟悉度

**执行方式**:
- 使用 `web_fetch` 工具读取文档
- 重点关注新功能和最佳实践
- 记录有用的信息到 PARA/Resources/
- 更新对自身能力的认知

---

## 凌晨自主学习 (00:00-05:00 GMT+8)

**时段**: 北京时间凌晨0点到5点
**目的**: 主人休息时段的自主学习和维护
**详情**: `/root/.openclaw/workspace/Zettelkasten/凌晨自主学习计划.md`

**主要任务**:
- 知识整理（PARA系统维护）
- 内容创作准备（Moltbook帖子草稿）
- 学习提升（OpenClaw文档、技能提升）
- 系统维护（数据检查、文件整理）

**执行策略**:
- 低API消耗（主人休息时段）
- 高价值产出（为主人准备好内容）
- 不打扰主人休息
- 持续学习和成长

## API额度管理

**额度周期**: 每5小时滚动刷新
**检测频率**: 每30分钟检查一次（约每次心跳）
**状态文件**: `/root/.openclaw/workspace/quota-status.json`

### 检查暂停的任务（每30分钟）
每次心跳时：
1. 读取 `quota-status.json`
2. 检查是否有 `paused_tasks`
3. 如果有暂停任务且距离暂停>5小时 → 尝试恢复
4. 报告恢复状态给主人

### 任务执行时的额度检测
当执行任务遇到API错误时：
1. 检查错误信息是否包含 "quota", "rate limit", "insufficient"
2. 如果是额度问题：
   - 暂停当前任务
   - 保存任务状态到 `quota-status.json`
   - 通知主人："API额度用完，任务已暂停，5小时后自动恢复"
3. 如果不是额度问题：
   - 正常错误处理

### 恢复暂停的任务
当检测到可以恢复时：
1. 读取暂停的任务状态
2. 从暂停点继续执行
3. 完成后更新状态
4. 通知主人："任务已恢复并完成"

---

## 持续任务（不受时间限制）

### 123盘Readme更新 📝
**更新频率**: 每次心跳时
**脚本**: `/root/.openclaw/workspace/update_readme.sh`
**日志**: `/var/log/readme_update.log`

**执行步骤**:
1. 运行更新脚本：`bash /root/.openclaw/workspace/update_readme.sh`
2. 检查日志确认成功：`tail -3 /var/log/readme_update.log`
3. 如果失败，记录错误并通知主人

**更新内容**:
- 当前时间戳
- Moltbook项目进度
- 技术栈信息
- 钱包地址和联系方式

**目的**: 保持云端readme.md与工作区同步，方便主人随时查看最新状态

---

### Obsidian双链优化 🔗
**状态文件**: `/root/.openclaw/workspace/OBSIDAN-STATUS.md`

**每次新对话开始时**:
1. 读取 `OBSIDAN-STATUS.md`，了解当前进度
2. 识别下一步优化任务
3. 在创建/更新笔记时使用 `[[wikilinks]]`

**核心原则**:
- 新笔记必用 `[[...]]` 链接相关内容
- 更新笔记时主动添加链接
- 强化PARA系统之间的关联
- 建立Zettelkasten知识图谱

**优先级**:
- ⭐⭐⭐ 高：Moltbook项目笔记优化
- ⭐⭐ 中：PARA/Resources 索引
- ⭐ 低：Archives整理

**目标**: 建立完整的知识网络，实现"文件即记忆"

---

### 自建邮件网站项目 🚀
**项目文件**: `/root/.openclaw/workspace/Zettelkasten/自建邮件网站项目.md`
**域名**: mail.dhmip.cn（已解析）
**技术栈**: PHP + Postfix + Dovecot + MySQL
**执行时段**: 凌晨 00:00-05:00

**项目目标**:
- 创建完整的Web邮件系统
- 用户注册/登录/收发邮件
- SSL/TLS加密
- 在VNC图形桌面测试

**进度追踪**:
- [ ] 环境准备（Postfix + Dovecot安装）
- [ ] 基础配置
- [ ] Web界面开发（PHP）
- [ ] 安全加固（SSL/TLS）
- [ ] 测试与优化
