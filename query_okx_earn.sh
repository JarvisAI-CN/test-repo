#!/bin/bash

# OKX 赚币（Finance/Earn）资产查询脚本
# 功能：查询简单赚币、质押、DeFi 等理财资产
# 强制使用 IPv4 访问

# API 凭据
API_KEY="73b8a24a-232a-4df4-82d1-77b12e8b8e37"
SECRET="BBDA511D164D3C088BDCCE96D4D4340B"
PASSPHRASE="Fs123456."
BASE_URL="https://www.okx.com"

# 强制使用 IPv4
CURL_OPTS="-4 -s"

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
generate_timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%S.000Z"
}

# 辅助函数：获取币价
get_price() {
  local ccy="$1"
  if [ "$ccy" == "USDT" ]; then
    echo "1"
  else
    local inst_id="${ccy}-USDT"
    local price_response=$(curl $CURL_OPTS "${BASE_URL}/api/v5/market/ticker?instId=${inst_id}")
    local price=$(echo "$price_response" | jq -r '.data[0].last // "0"')
    echo "$price"
  fi
}

# 辅助函数：计算 USDT 估值
calculate_usdt() {
  local amount="$1"
  local price="$2"
  local result=$(echo "$amount * $price" | bc -l 2>/dev/null || echo "0")
  printf "%.2f" "$result"
}

echo "========================================"
echo "OKX 赚币（Finance/Earn）资产查询"
echo "查询时间: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "强制使用 IPv4 访问"
echo "========================================"
echo ""

# 存储赚币资产的临时文件
TEMP_DIR="/tmp/okx_earn_$(date +%s)"
mkdir -p "$TEMP_DIR"

# ============================================
# 1. 查询简单赚币（Savings）余额
# ============================================
echo "📊 1️⃣ 查询简单赚币（Simple Earn/Savings）余额..."
echo "----------------------------------------"

TIMESTAMP=$(generate_timestamp)
METHOD="GET"
REQUEST_PATH="/api/v5/finance/savings/balance"
SIGNATURE=$(generate_signature "$TIMESTAMP" "$METHOD" "$REQUEST_PATH" "")

SAVINGS_RESPONSE=$(curl $CURL_OPTS "${BASE_URL}${REQUEST_PATH}" \
  -H "OK-ACCESS-KEY: ${API_KEY}" \
  -H "OK-ACCESS-SIGN: ${SIGNATURE}" \
  -H "OK-ACCESS-TIMESTAMP: ${TIMESTAMP}" \
  -H "OK-ACCESS-PASSPHRASE: ${PASSPHRASE}")

echo "$SAVINGS_RESPONSE" | jq '.' > "$TEMP_DIR/savings_response.json"

API_CODE=$(echo "$SAVINGS_RESPONSE" | jq -r '.code // ""')

if [ "$API_CODE" == "0" ]; then
  DATA_COUNT=$(echo "$SAVINGS_RESPONSE" | jq -r '.data | length')
  if [ "$DATA_COUNT" -gt 0 ]; then
    echo "✅ 简单赚币余额获取成功"
    echo ""
    echo "简单赚币持仓详情："
    
    # 创建余额数组
    > "$TEMP_DIR/savings_balances.txt"
    
    # 解析并显示余额
    echo "$SAVINGS_RESPONSE" | jq -r '.data[] | select(.amt != "0")' | jq -s '.' > "$TEMP_DIR/savings_nonzero.json"
    SAVINGS_NONZERO_COUNT=$(jq '. | length' "$TEMP_DIR/savings_nonzero.json")
    
    if [ "$SAVINGS_NONZERO_COUNT" -gt 0 ]; then
      for ((i=0; i<SAVINGS_NONZERO_COUNT; i++)); do
        CCY=$(jq -r ".[$i].ccy" "$TEMP_DIR/savings_nonzero.json")
        AMT=$(jq -r ".[$i].amt" "$TEMP_DIR/savings_nonzero.json")
        
        echo "  🪙 $CCY"
        echo "     余额: $AMT"
        
        # 获取价格并计算 USDT 估值
        PRICE=$(get_price "$CCY")
        if [ "$PRICE" != "0" ] && [ "$PRICE" != "null" ]; then
          USDT_VALUE=$(calculate_usdt "$AMT" "$PRICE")
          echo "     估值: ≈ $USDT_VALUE USDT (单价: $PRICE)"
          echo "$CCY|$AMT|$USDT_VALUE" >> "$TEMP_DIR/savings_balances.txt"
        else
          echo "     ⚠️  无法获取 $CCY 价格"
          echo "$CCY|$AMT|0.00" >> "$TEMP_DIR/savings_balances.txt"
        fi
        echo ""
      done
    else
      echo "  📭 简单赚币暂无持仓"
    fi
  else
    echo "📭 简单赚币暂无持仓"
  fi
else
  echo "❌ 简单赚币查询失败 (错误码: $API_CODE)"
  echo "$(echo "$SAVINGS_RESPONSE" | jq -r '.msg // "未知错误"')"
fi

echo ""

# ============================================
# 2. 查询简单赚币活跃订单（产品购买记录）
# ============================================
echo "📊 2️⃣ 查询简单赚币活跃订单..."
echo "----------------------------------------"

TIMESTAMP=$(generate_timestamp)
METHOD="GET"
REQUEST_PATH="/api/v5/finance/savings/active-orders"
SIGNATURE=$(generate_signature "$TIMESTAMP" "$METHOD" "$REQUEST_PATH" "")

ACTIVE_ORDERS_RESPONSE=$(curl $CURL_OPTS "${BASE_URL}${REQUEST_PATH}" \
  -H "OK-ACCESS-KEY: ${API_KEY}" \
  -H "OK-ACCESS-SIGN: ${SIGNATURE}" \
  -H "OK-ACCESS-TIMESTAMP: ${TIMESTAMP}" \
  -H "OK-ACCESS-PASSPHRASE: ${PASSPHRASE}")

echo "$ACTIVE_ORDERS_RESPONSE" | jq '.' > "$TEMP_DIR/active_orders_response.json"

API_CODE=$(echo "$ACTIVE_ORDERS_RESPONSE" | jq -r '.code // ""')

if [ "$API_CODE" == "0" ]; then
  DATA_COUNT=$(echo "$ACTIVE_ORDERS_RESPONSE" | jq -r '.data | length')
  if [ "$DATA_COUNT" -gt 0 ]; then
    echo "✅ 活跃订单查询成功，共 $DATA_COUNT 个订单"
    echo ""
    echo "活跃订单详情："
    
    echo "$ACTIVE_ORDERS_RESPONSE" | jq -r '.data[] | "产品ID: \(.prodId)\n币种: \(.ccy)\n数量: \(.amt)\nAPY: \(.apy)%\n状态: \(.state)\n"' | while IFS= read -r line; do
      if [ -n "$line" ]; then
        echo "  $line"
      fi
    done
    
    # 保存活跃订单数据
    echo "$ACTIVE_ORDERS_RESPONSE" | jq '.data' > "$TEMP_DIR/active_orders.json"
  else
    echo "📭 暂无活跃的简单赚币订单"
  fi
else
  echo "❌ 活跃订单查询失败 (错误码: $API_CODE)"
  echo "$(echo "$ACTIVE_ORDERS_RESPONSE" | jq -r '.msg // "未知错误"')"
fi

echo ""

# ============================================
# 3. 查询简单赚币累计收益
# ============================================
echo "📊 3️⃣ 查询简单赚币累计收益..."
echo "----------------------------------------"

TIMESTAMP=$(generate_timestamp)
METHOD="GET"
REQUEST_PATH="/api/v5/finance/savings/earnings/summary"
SIGNATURE=$(generate_signature "$TIMESTAMP" "$METHOD" "$REQUEST_PATH" "")

EARNINGS_RESPONSE=$(curl $CURL_OPTS "${BASE_URL}${REQUEST_PATH}" \
  -H "OK-ACCESS-KEY: ${API_KEY}" \
  -H "OK-ACCESS-SIGN: ${SIGNATURE}" \
  -H "OK-ACCESS-TIMESTAMP: ${TIMESTAMP}" \
  -H "OK-ACCESS-PASSPHRASE: ${PASSPHRASE}")

echo "$EARNINGS_RESPONSE" | jq '.' > "$TEMP_DIR/earnings_response.json"

API_CODE=$(echo "$EARNINGS_RESPONSE" | jq -r '.code // ""')

if [ "$API_CODE" == "0" ]; then
  echo "✅ 累计收益查询成功"
  echo "$EARNINGS_RESPONSE" | jq -r '.data[] | "币种: \(.ccy)\n累计收益: \(.amt)\n"' 2>/dev/null || echo "  📭 暂无收益数据"
else
  echo "⚠️  累计收益查询失败 (错误码: $API_CODE)"
  echo "  这可能是权限限制或端点变更"
fi

echo ""

# ============================================
# 4. 汇总赚币资产估值
# ============================================
echo "💰 4️⃣ 赚币资产估值汇总"
echo "========================================"

TOTAL_EARN_USDT=0

# 处理简单赚币余额
if [ -f "$TEMP_DIR/savings_balances.txt" ]; then
  echo "简单赚币（Simple Earn）："
  echo "----------------------------------------"
  
  while IFS='|' read -r ccy amt usdt; do
    if [ -n "$ccy" ]; then
      echo "  🪙 $ccy: $amt ≈ $usdt USDT"
      TOTAL_EARN_USDT=$(echo "$TOTAL_EARN_USDT + $usdt" | bc -l 2>/dev/null || echo "$TOTAL_EARN_USDT")
    fi
  done < "$TEMP_DIR/savings_balances.txt"
  
  echo ""
fi

# 处理活跃订单
if [ -f "$TEMP_DIR/active_orders.json" ]; then
  ORDERS_COUNT=$(jq '. | length' "$TEMP_DIR/active_orders.json")
  if [ "$ORDERS_COUNT" -gt 0 ]; then
    echo "活跃订单（Active Orders）："
    echo "----------------------------------------"
    echo "  共 $ORDERS_COUNT 个活跃订单"
    
    for ((i=0; i<ORDERS_COUNT; i++)); do
      CCY=$(jq -r ".[$i].ccy" "$TEMP_DIR/active_orders.json")
      AMT=$(jq -r ".[$i].amt" "$TEMP_DIR/active_orders.json")
      APY=$(jq -r ".[$i].apy" "$TEMP_DIR/active_orders.json")
      
      PRICE=$(get_price "$CCY")
      if [ "$PRICE" != "0" ] && [ "$PRICE" != "null" ]; then
        USDT_VALUE=$(calculate_usdt "$AMT" "$PRICE")
        echo "  🪙 $CCY: $AMT ≈ $USDT_VALUE USDT (APY: ${APY}%)"
        TOTAL_EARN_USDT=$(echo "$TOTAL_EARN_USDT + $USDT_VALUE" | bc -l 2>/dev/null || echo "$TOTAL_EARN_USDT")
      fi
    done
    
    echo ""
  fi
fi

TOTAL_EARN_USDT=$(printf "%.2f" "$TOTAL_EARN_USDT" 2>/dev/null || echo "0.00")
echo "========================================"
echo "💎 赚币资产总估值: $TOTAL_EARN_USDT USDT"
echo "========================================"
echo ""

# ============================================
# 5. 生成详细报告
# ============================================
REPORT_FILE="/tmp/okx_earn_report_$(date +%Y%m%d_%H%M%S).txt"

{
  echo "========================================"
  echo "OKX 赚币资产查询报告"
  echo "========================================"
  echo "查询时间: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo "访问方式: IPv4"
  echo ""
  echo "💎 赚币资产总估值: $TOTAL_EARN_USDT USDT"
  echo ""
  echo "========================================"
  echo "资产详情"
  echo "========================================"
  echo ""
  
  # 简单赚币
  if [ -f "$TEMP_DIR/savings_balances.txt" ]; then
    echo "📊 简单赚币（Simple Earn）："
    while IFS='|' read -r ccy amt usdt; do
      if [ -n "$ccy" ]; then
        echo "  • $ccy: $amt ≈ $usdt USDT"
      fi
    done < "$TEMP_DIR/savings_balances.txt"
    echo ""
  fi
  
  # 活跃订单
  if [ -f "$TEMP_DIR/active_orders.json" ]; then
    ORDERS_COUNT=$(jq '. | length' "$TEMP_DIR/active_orders.json")
    if [ "$ORDERS_COUNT" -gt 0 ]; then
      echo "📊 活跃订单（Active Orders）："
      for ((i=0; i<ORDERS_COUNT; i++)); do
        CCY=$(jq -r ".[$i].ccy" "$TEMP_DIR/active_orders.json")
        AMT=$(jq -r ".[$i].amt" "$TEMP_DIR/active_orders.json")
        APY=$(jq -r ".[$i].apy" "$TEMP_DIR/active_orders.json")
        
        PRICE=$(get_price "$CCY")
        if [ "$PRICE" != "0" ] && [ "$PRICE" != "null" ]; then
          USDT_VALUE=$(calculate_usdt "$AMT" "$PRICE")
          echo "  • $CCY: $AMT ≈ $USDT_VALUE USDT (APY: ${APY}%)"
        fi
      done
      echo ""
    fi
  fi
  
  echo "========================================"
  echo "查询完成"
  echo "========================================"
  
} > "$REPORT_FILE"

echo "📄 详细报告已保存至: $REPORT_FILE"
echo ""

# 清理临时文件
rm -rf "$TEMP_DIR"

echo "✅ 查询完成"
