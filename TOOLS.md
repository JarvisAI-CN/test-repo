# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:
- Camera names and locations
- SSH hosts and aliases  
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras
- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH
- home-server → 192.168.1.100, user: admin

### TTS
- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## 🔐 密码管理
**所有密码和凭据**已集中存储于: `PASSWORDS.md`
- 文件权限: 600 (仅root可读写)
- 包含: WebDAV、VNC、API密钥、系统账户等
- ⚠️ 谨慎处理，避免泄露

## 快速参考
### 网络服务
- 123盘WebDAV: /mnt/123pan
- VNC服务器: localhost:5901 (密码见PASSWORDS.md)
- 内网IP: 10.7.0.5
- GitHub: https://github.com/JarvisAI-CN (账号凭证见PASSWORDS.md)

### 系统路径
- 工作区: /root/.openclaw/workspace
- 备份脚本: /root/.openclaw/workspace/backup.sh
- 备份日志: /var/log/backup_123pan.log
- 123盘备份: /mnt/123pan/备份/

### 知识管理工具
- **Obsidian**: 我的整个工作区是一个Obsidian vault
- **obsidian-cli** (v0.5.1): 命令行工具
  - 安装路径: `/root/.nvm/versions/node/v22.22.0/bin/obsidian`
  - 全局链接: `/usr/local/bin/obsidian`
  - 功能: 搜索、创建、移动笔记，自动更新双链
  - 使用文档: `[[Zettelkasten/Obsidian使用实践]]`
- **OBSIDAN-STATUS.md**: 双链优化进度追踪
- **实践原则**:
  - 新笔记必用 `[[...]]` 链接相关内容
  - 更新笔记时主动添加新发现的关联
  - 回顾时跟随链接探索，补充缺失链接
