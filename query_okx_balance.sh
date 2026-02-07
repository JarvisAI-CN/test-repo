#!/bin/bash

# OKX 账户资产查询脚本
# 功能：获取所有余额、计算 USDT 估值、报告前三大持仓

# API 凭据
API_KEY="73b8a24a-232a-4df4-82d1-77b12e8b8e37"
SECRET="BBDA511D164D3C088BDCCE96D4D4340B"
PASSPHRASE="Fs123456."
BASE_URL="https://www.okx.com"

# 签名生成函数
generate_signature() {
  local timestamp="$1"
  local method="$2"
  local request_path="$3"
  local body="$4"
  local sign_string="${timestamp}${method}${request_path}${body}"
  echo -n "$sign_string" | openssl dgst -sha256 -hmac "$SECRET" -binary | base64
}

# 生成时间戳
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

echo "==================================="
echo "OKX 账户资产查询"
echo "查询时间: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "==================================="
echo ""

# 1. 获取账户余额
METHOD="GET"
REQUEST_PATH="/api/v5/account/balance"
SIGNATURE=$(generate_signature "$TIMESTAMP" "$METHOD" "$REQUEST_PATH" "")

echo "📊 正在获取账户余额..."
BALANCE_RESPONSE=$(curl -s "${BASE_URL}${REQUEST_PATH}" \
  -H "OK-ACCESS-KEY: ${API_KEY}" \
  -H "OK-ACCESS-SIGN: ${SIGNATURE}" \
  -H "OK-ACCESS-TIMESTAMP: ${TIMESTAMP}" \
  -H "OK-ACCESS-PASSPHRASE: ${PASSPHRASE}")

# 检查 API 响应
echo "$BALANCE_RESPONSE" | jq '.' > /tmp/okx_balance_response.json
API_CODE=$(echo "$BALANCE_RESPONSE" | jq -r '.code // ""')

if [ "$API_CODE" != "0" ]; then
  echo "❌ API 错误 (代码: $API_CODE)"
  echo "$BALANCE_RESPONSE" | jq -r '.msg // "未知错误"'
  exit 1
fi

echo "✅ 余额获取成功"
echo ""

# 2. 提取所有非零余额
echo "📝 账户余额详情："
echo "----------------------------------------"

# 获取所有币种及其余额
BALANCES=$(echo "$BALANCE_RESPONSE" | jq -r '.data[0].details[] | select(.cashBal != "0") | {ccy: .ccy, cashBal: .cashBal, availBal: .availBal, frozenBal: .frozenBal}')

# 创建临时文件存储数据
TEMP_FILE="/tmp/okx_balances_$(date +%s).json"
echo "$BALANCES" | jq -s '.' > "$TEMP_FILE"

# 显示原始余额
echo "$BALANCES" | jq -r '"\(.ccy):\n  总余额: \(.cashBal)\n  可用: \(.availBal)\n  冻结: \(.frozenBal)"' | while read line; do
  if [ -n "$line" ]; then
    echo "$line"
  fi
done

echo ""

# 3. 获取价格并计算 USDT 估值
echo "💰 正在计算 USDT 估值..."
echo "----------------------------------------"

TOTAL_USDT_VALUE=0
declare -A USDT_VALUES

# 读取每个币种
CCY_COUNT=$(echo "$BALANCES" | jq -s '. | length')

for ((i=0; i<CCY_COUNT; i++)); do
  CCY=$(echo "$BALANCES" | jq -s ".[$i].ccy")
  BAL=$(echo "$BALANCES" | jq -s ".[$i].cashBal")
  
  # 去掉引号
  CCY=$(echo "$CCY" | tr -d '"')
  BAL=$(echo "$BAL" | tr -d '"')
  
  # 转换为浮点数
  BAL=$(echo "$BAL" | bc -l)
  
  if [ $(echo "$BAL == 0" | bc) -eq 1 ]; then
    continue
  fi
  
  # 如果是 USDT，直接等于余额
  if [ "$CCY" == "USDT" ]; then
    USDT_VALUE=$BAL
  else
    # 获取交易对价格 (CCY-USDT)
    INST_ID="${CCY}-USDT"
    
    # 更新时间戳
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    
    # 获取 ticker 价格
    PRICE_RESPONSE=$(curl -s "${BASE_URL}/api/v5/market/ticker?instId=${INST_ID}")
    PRICE=$(echo "$PRICE_RESPONSE" | jq -r '.data[0].last // "0"')
    
    if [ "$PRICE" == "0" ] || [ "$PRICE" == "null" ]; then
      USDT_VALUE=0
      echo "⚠️  $CCY: 无法获取价格 (交易对 $INST_ID 可能不存在)"
    else
      # 计算 USDT 价值
      USDT_VALUE=$(echo "$BAL * $PRICE" | bc -l)
    fi
  fi
  
  USDT_VALUE=$(printf "%.2f" $(echo "$USDT_VALUE" | bc -l))
  USDT_VALUES[$CCY]=$USDT_VALUE
  TOTAL_USDT_VALUE=$(echo "$TOTAL_USDT_VALUE + $USDT_VALUE" | bc -l)
  
  # 显示单个币种估值
  if [ "$CCY" != "USDT" ]; then
    echo "$CCY: $BAL ≈ $USDT_VALUE USDT"
  fi
done

echo ""

# 4. 显示 USDT 余额
USDT_BAL=$(echo "$BALANCES" | jq -r 'select(.ccy == "USDT") | .cashBal')
if [ "$USDT_BAL" != "null" ] && [ -n "$USDT_BAL" ]; then
  USDT_VALUE=${USDT_VALUES["USDT"]}
  echo "USDT: $USDT_BAL ≈ $USDT_VALUE USDT"
  echo ""
fi

# 5. 汇总总资产
TOTAL_USDT_VALUE=$(printf "%.2f" $(echo "$TOTAL_USDT_VALUE" | bc -l))
echo "==================================="
echo "💎 总资产估值: $TOTAL_USDT_VALUE USDT"
echo "==================================="
echo ""

# 6. 排序并显示前三大持仓
echo "🏆 前三大持仓币种："
echo "----------------------------------------"

# 创建排序数据文件
SORT_FILE="/tmp/okx_sorted_$(date +%s).txt"
for ccy in "${!USDT_VALUES[@]}"; do
  value="${USDT_VALUES[$ccy]}"
  echo "$value $ccy" >> "$SORT_FILE"
done

# 按价值排序（降序）
SORTED=$(sort -rn "$SORT_FILE" | head -3)
RANK=1

echo "$SORTED" | while read line; do
  value=$(echo "$line" | awk '{print $1}')
  ccy=$(echo "$line" | awk '{print $2}')
  percent=$(echo "scale=2; $value * 100 / $TOTAL_USDT_VALUE" | bc)
  printf "第%d名: %s - %.2f USDT (%.2f%%)\n" $RANK "$ccy" "$value" "$percent"
  RANK=$((RANK + 1))
done

echo ""

# 清理临时文件
rm -f "$TEMP_FILE" "$SORT_FILE" /tmp/okx_balance_response.json

echo "✅ 查询完成"
