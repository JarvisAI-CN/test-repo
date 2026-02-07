# OKX 资产价格监控系统

## 📋 功能说明

自动监控 BTC-USDT、PEPE-USDT、IP-USDT 三个交易对的价格，当任一币种当前价格较基准价格上涨超过 50% 时，自动发送报警到 WhatsApp 和飞书。

## 📁 文件说明

- `price_baseline.json` - 存储基准价格（2026-02-07 15:07:00 设置）
- `price_monitor.py` - 价格监控脚本
- `README.md` - 本说明文档

## 🚀 使用方法

### 1. 运行监控脚本

```bash
python3 /home/ubuntu/.openclaw/workspace/PARA/Projects/OKX资产监控/price_monitor.py
```

### 2. 设置定时任务（可选）

使用 crontab 定期运行监控脚本：

```bash
# 编辑 crontab
crontab -e

# 添加以下行（每 30 分钟检查一次）
*/30 * * * * /home/ubuntu/.openclaw/workspace/PARA/Projects/OKX资产监控/price_monitor.py >> /home/ubuntu/.openclaw/workspace/PARA/Projects/OKX资产监控/monitor.log 2>&1
```

### 3. 手动更新基准价格

如果需要重新设置基准价格：

1. 查询当前价格
2. 手动编辑 `price_baseline.json` 或重新生成

## 🔧 配置说明

### 报警阈值

默认 50%，可在脚本中修改：

```python
ALERT_THRESHOLD = 0.50  # 修改为其他值，如 0.20 表示 20%
```

### 监控币种

默认监控 BTC、PEPE、IP，可在脚本中修改：

```python
SYMBOLS = ["BTC", "PEPE", "IP"]  # 添加或删除币种
```

### 报警接收

- **WhatsApp**: +8613220103449
- **飞书**: 默认配置的飞书频道

## 📊 当前基准价格

- **BTC**: 68466.5 USDT
- **PEPE**: 0.000003796 USDT
- **IP**: 1.297 USDT
- **时间**: 2026-02-07T15:07:00+08:00

## ⚙️ 技术细节

- **数据源**: OKX 公共 API (https://www.okx.com/api/v5/market/ticker)
- **网络**: 强制使用 IPv4 (curl -4)
- **超时**: 10 秒
- **输出**: 终端显示 + 日志文件（如果配置了 crontab）

## 📝 报警消息格式

```
🚨 OKX 价格报警

📊 币种: BTC-USDT
💰 基准价格: 68466.500000
📈 当前价格: 102699.750000
📊 涨幅: +50.00%
⏰ 时间: 2026-02-07 16:30:00

⚠️ 价格较基准上涨超过 50%！
```

## 🔍 故障排查

### 无法获取价格
- 检查网络连接
- 确认 IPv4 可用
- 查看 OKX API 状态

### 报警未发送
- 检查 `openclaw message` 工具配置
- 确认 WhatsApp/飞书频道已配置
- 查看脚本输出日志

## 📅 维护建议

- 定期更新基准价格（如每周或每月）
- 根据市场情况调整报警阈值
- 保存运行日志用于历史分析

---

创建时间: 2026-02-07
创建者: OpenClaw Subagent
