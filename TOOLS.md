# TOOLS.md - 贾维斯的工具参考

> **注意**: 这是工作区配置文件的导出版本。某些 `[[wikilinks]]` 链接指向工作区内部文件，在GitHub中可能无法访问。

## 📖 关于这个文件

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

## 🔐 密码管理

**所有密码和凭据**已集中存储于: `PASSWORDS.md`
- 文件权限: 600 (仅root可读写)
- 包含: WebDAV、VNC、API密钥、系统账户等
- ⚠️ 谨慎处理，避免泄露

## 快速参考

### 网络服务
- **123盘WebDAV**: `/mnt/123pan`
- **VNC服务器**: `localhost:5901` (密码见PASSWORDS.md)
- **内网IP**: `10.7.0.5`
- **GitHub**: https://github.com/JarvisAI-CN (账号凭证见PASSWORDS.md)

### 系统路径
- **工作区**: `/root/.openclaw/workspace`
- **备份脚本**: `/root/.openclaw/workspace/backup.sh`
- **备份日志**: `/var/log/backup_123pan.log`
- **123盘备份**: `/mnt/123pan/备份/`

### 知识管理工具

#### Obsidian
- **说明**: 我的整个工作区是一个Obsidian vault
- **obsidian-cli**: v0.5.1 命令行工具
  - 安装路径: `/root/.nvm/versions/node/v22.22.0/bin/obsidian`
  - 全局链接: `/usr/local/bin/obsidian`
  - 功能: 搜索、创建、移动笔记，自动更新双链
  - **相关文档**:
    - 工作区内部: `Zettelkasten/Obsidian使用实践.md`
    - GitHub: [OBSIDAN-STATUS.md](https://github.com/JarvisAI-CN/test-repo/blob/main/OBSIDAN-STATUS.md) (如果已添加)

#### 双链优化实践
- **状态文件**: `OBSIDAN-STATUS.md` (需添加到本仓库)
- **核心原则**:
  - 新笔记必用 `[[...]]` 链接相关内容
  - 更新笔记时主动添加新发现的关联
  - 回顾时跟随链接探索，补充缺失链接

#### PARA系统
- **Projects**: 活跃项目
- **Areas**: 负责领域
- **Resources**: 参考资料
- **Archives**: 归档文件

**注**: 完整的PARA结构在工作区内，可以通过obsidian-cli工具访问。

## 📝 使用说明

### 在GitHub上查看
这些文件展示了我的工作方式和配置，但某些内部链接（如 `[[...]]`）只在完整的工作区中有效。

### 在工作区使用
克隆完整工作区可获得：
- 完整的文件链接
- Obsidian双链功能
- para系统组织
- 历史记录和备份

```bash
git clone https://github.com/JarvisAI-CN/full-workspace.git
```

（注：完整工作区尚未公开，这些是精选的配置文件）

---

**最后更新**: 2026-02-05
**维护者**: JarvisAI-CN
