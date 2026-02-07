#!/usr/bin/env python3
"""
OKX Asset Price Monitor
监控 BTC, PEPE, IP 价格，当较基准价格上涨超过 50% 时发送报警
"""

import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path

# 配置
BASELINE_FILE = "/home/ubuntu/.openclaw/workspace/PARA/Projects/OKX资产监控/price_baseline.json"
WHATSAPP_NUMBER = "+8613220103449"
ALERT_THRESHOLD = 0.50  # 50% 涨幅阈值

# 监控的币种
SYMBOLS = ["BTC", "PEPE", "IP"]


def fetch_price(symbol: str) -> float:
    """从 OKX 获取指定币种的当前价格（强制使用 IPv4）"""
    try:
        cmd = [
            "curl", "-4", "-s",
            f"https://www.okx.com/api/v5/market/ticker?instId={symbol}-USDT"
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        
        if result.returncode != 0:
            print(f"❌ curl 命令失败: {result.stderr}", file=sys.stderr)
            return None
        
        data = json.loads(result.stdout)
        
        if data.get("code") != "0" or not data.get("data"):
            print(f"❌ API 返回错误: {data}", file=sys.stderr)
            return None
        
        price = float(data["data"][0]["last"])
        return price
    
    except Exception as e:
        print(f"❌ 获取 {symbol} 价格时出错: {e}", file=sys.stderr)
        return None


def load_baseline() -> dict:
    """加载基准价格"""
    try:
        with open(BASELINE_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"❌ 加载基准价格失败: {e}", file=sys.stderr)
        sys.exit(1)


def send_alert(symbol: str, baseline: float, current: float, increase_pct: float):
    """发送报警信息到 WhatsApp 和飞书"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # 构建报警消息
    message = f"""🚨 *OKX 价格报警*

📊 币种: {symbol}-USDT
💰 基准价格: {baseline:.6f}
📈 当前价格: {current:.6f}
📊 涨幅: +{increase_pct:.2f}%
⏰ 时间: {timestamp}

⚠️ 价格较基准上涨超过 {ALERT_THRESHOLD*100}%！"""

    print(f"\n{'='*60}")
    print(f"🚨 {symbol} 价格上涨 {increase_pct:.2f}%，触发报警！")
    print(f"{'='*60}")
    print(f"基准: {baseline:.6f} → 当前: {current:.6f}")
    
    # 调用 message 工具发送到 WhatsApp
    try:
        cmd = [
            "openclaw", "message", "send",
            "--channel", "whatsapp",
            "--target", WHATSAPP_NUMBER,
            "--message", message
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ WhatsApp 报警已发送")
        else:
            print(f"❌ WhatsApp 发送失败: {result.stderr}", file=sys.stderr)
    except Exception as e:
        print(f"❌ WhatsApp 报警发送出错: {e}", file=sys.stderr)
    
    # 调用 message 工具发送到飞书
    try:
        # 使用飞书的 channel
        cmd = [
            "openclaw", "message", "send",
            "--channel", "feishu",
            "--message", message
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ 飞书报警已发送")
        else:
            print(f"❌ 飞书发送失败: {result.stderr}", file=sys.stderr)
    except Exception as e:
        print(f"❌ 飞书报警发送出错: {e}", file=sys.stderr)


def main():
    """主函数"""
    print(f"\n{'='*60}")
    print(f"🔍 OKX 资产价格监控")
    print(f"{'='*60}")
    print(f"⏰ 启动时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"📊 监控币种: {', '.join(SYMBOLS)}")
    print(f"⚠️ 报警阈值: +{ALERT_THRESHOLD*100}%\n")
    
    # 加载基准价格
    baseline = load_baseline()
    baseline_ts = baseline.get("timestamp", "未知")
    print(f"📅 基准时间: {baseline_ts}\n")
    
    alert_triggered = False
    
    # 检查每个币种
    for symbol in SYMBOLS:
        if symbol not in baseline:
            print(f"⚠️  警告: 基准价格中没有 {symbol}", file=sys.stderr)
            continue
        
        baseline_price = baseline[symbol]
        print(f"🔎 检查 {symbol}-USDT...")
        print(f"   基准价格: {baseline_price:.6f}")
        
        # 获取当前价格
        current_price = fetch_price(symbol)
        
        if current_price is None:
            print(f"   ❌ 无法获取当前价格\n")
            continue
        
        print(f"   当前价格: {current_price:.6f}")
        
        # 计算涨幅
        increase_pct = (current_price - baseline_price) / baseline_price
        
        if increase_pct > ALERT_THRESHOLD:
            print(f"   🚨 涨幅: +{increase_pct*100:.2f}% (超过阈值!)\n")
            send_alert(symbol, baseline_price, current_price, increase_pct * 100)
            alert_triggered = True
        else:
            print(f"   ✅ 涨幅: +{increase_pct*100:.2f}% (正常)\n")
    
    print(f"{'='*60}")
    if alert_triggered:
        print("⚠️  检测到价格异常，已发送报警")
    else:
        print("✅ 所有币种价格正常")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    main()
