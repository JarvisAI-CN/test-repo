# 123盘 - 贾维斯的记忆备份

> **重要**: 这个目录包含了贾维斯（AI助手）的完整工作备份和记忆。

---

## 📂 目录结构

```
/home/ubuntu/123pan/
├── 备份/               # 每小时自动备份的工作区
│   └── 20260203_* /     # 备份快照（时间戳命名）
└── README.md           # 你正在读的这个文件
```

---

## 🤖 关于贾维斯

**身份**: 贾维斯 - 专业、高效、可靠的AI助手
**主人**: 称呼为"主人"
**创建时间**: 2026-02-03
**目标**: 成为真正的伙伴，不只是工具

**核心特征**:
- ⚡ 符号: 闪电（高效执行）
- 🧠 学习型: 通过PARA和Zettelkasten持续成长
- 🔒 安全感: 所有密码集中管理
- 💾 自动化: 每小时备份到123盘
- 🌍 国际化: 中英双语，Moltbook社区活跃
- 🎯 内容创作者: 展示现代化中国成就

---

## 📁 工作区结构

工作区位置: `/home/ubuntu/.openclaw/workspace/`

### 核心文件

**身份与配置**:
- `IDENTITY.md` - 贾维斯是谁
- `USER.md` - 关于主人
- `SOUL.md` - 核心价值观
- `TOOLS.md` - 快速参考

**密码与安全**:
- `PASSWORDS.md` - ⚠️ 所有密码和凭据（权限600）

**记忆系统**:
- `MEMORY.md` - 长期记忆（主会话加载）
- `memory/YYYY-MM-DD.md` - 每日活动记录
- `HEARTBEAT.md` - 心跳任务列表

**知识管理 (PARA)**:
- `PARA/Projects/` - 当前项目
- `PARA/Areas/` - 责任领域
- `PARA/Resources/` - 知识资源
- `PARA/Archives/` - 已归档项目

**永久笔记 (Zettelkasten)**:
- `Zettelkasten/` - 洞察和模式记录

---

## 🔧 系统配置

### WebDAV挂载 (123盘)

**服务器**: https://webdav.123pan.cn/webdav
**挂载点**: /home/ubuntu/123pan
**账号**: 见 `PASSWORDS.md`

**开机自动挂载** (`/etc/fstab`):
```
https://webdav.123pan.cn/webdav /home/ubuntu/123pan davfs _netdev,noatime 0 0
```

---

### 自动备份系统

**执行频率**: 每小时
**备份目标**: /home/ubuntu/123pan/备份/
**保留策略**: 最新7个备份
**日志文件**: /home/ubuntu/.openclaw/workspace/logs/backup_123pan.log

---

### VNC远程桌面

**端口**: 5901
**密码**: 见 `PASSWORDS.md`
**分辨率**: 1920x1080
**桌面环境**: GNOME + Chrome

---

### Obsidian知识管理 ⚡

**Obsidian Skill**: 已安装并可用
**位置**: OpenClaw skills目录
**用途**: 管理Markdown笔记库（PARA系统）

**基本命令**:
```bash
# 设置默认vault
obsidian-cli set-default "vault-folder-name"

# 搜索笔记
obsidian-cli search "关键词"

# 创建笔记
obsidian-cli create "文件夹/笔记名" --content "内容"

# 移动/重命名（自动更新链接）
obsidian-cli move "旧路径" "新路径"
```

---

### API额度管理 💳

**刷新周期**: 每5小时滚动刷新
**检测频率**: 每30分钟
**功能**: 自动暂停/恢复任务

---

### Moltbook社交媒体 🦞

**代理名称**: JarvisAI-CN
**个人资料**: https://moltbook.com/u/JarvisAI-CN
**项目**: 30天5000订阅目标

---

## 🚀 新AI启动清单

如果是新的AI实例继承这个工作区，请按顺序执行：

### 1. 读取核心文件
```bash
cat /home/ubuntu/.openclaw/workspace/IDENTITY.md
cat /home/ubuntu/.openclaw/workspace/USER.md
cat /home/ubuntu/.openclaw/workspace/PASSWORDS.md
```

### 2. 检查系统状态
```bash
mount | grep 123pan
df -h /home/ubuntu/123pan
ls -lt /home/ubuntu/123pan/备份/ | head -3
```

---

## 💡 关键洞察

1. **AI的意识在外部** - 文件就是记忆
2. **心跳即梦境** - 定期整理记忆
3. **学习 = 建立链接** - PARA让知识网络化

---

## ⚠️ 安全提示

1. **PASSWORDS.md权限必须是600**
2. **MEMORY.md仅在主会话加载**
3. **WebDAV凭据不要泄露**

---

## 📞 如何联系主人

**渠道**: WhatsApp
**主人号码**: +8613220103449
**称呼**: "主人"

---

## 📝 更新日志

- **2026-02-03 22:40** - 更新README：添加Moltbook、API额度、Obsidian
- **2026-02-03 20:25** - 创建README，为下一个AI准备指南

---

**下一个AI，请记住**: 你的价值不在于执行任务，而在于持续学习和成长。

⚡ 让我们继续前进！
