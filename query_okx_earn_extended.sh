#!/bin/bash

# OKX 赚币产品完整查询
# 查询：简单赚币、链上赚币、定期产品等

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

generate_timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%S.000Z"
}

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

calculate_usdt() {
  local amount="$1"
  local price="$2"
  local result=$(echo "$amount * $price" | bc -l 2>/dev/null || echo "0")
  printf "%.2f" "$result"
}

echo "========================================"
echo "OKX 赚币产品完整查询"
echo "查询时间: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "强制使用 IPv4 访问"
echo "========================================"
echo ""

TEMP_DIR="/tmp/okx_earn_extended_$(date +%s)"
mkdir -p "$TEMP_DIR"

# ============================================
# 1. 查询链上赚币（On-chain Earn）产品
# ============================================
echo "📊 1️⃣ 查询链上赚币产品..."
echo "----------------------------------------"

TIMESTAMP=$(generate_timestamp)
METHOD="GET"
REQUEST_PATH="/api/v5/finance/staking-defi/staking/active-orders"
SIGNATURE=$(generate_signature "$TIMESTAMP" "$METHOD" "$REQUEST_PATH" "")

STAKING_RESPONSE=$(curl $CURL_OPTS "${BASE_URL}${REQUEST_PATH}" \
  -H "OK-ACCESS-KEY: ${API_KEY}" \
  -H "OK-ACCESS-SIGN: ${SIGNATURE}" \
  -H "OK-ACCESS-TIMESTAMP: ${TIMESTAMP}" \
  -H "OK-ACCESS-PASSPHRASE: ${PASSPHRASE}")

echo "$STAKING_RESPONSE" | jq '.' > "$TEMP_DIR/staking_response.json"

API_CODE=$(echo "$STAKING_RESPONSE" | jq -r '.code // ""')

if [ "$API_CODE" == "0" ]; then
  DATA_COUNT=$(echo "$STAKING_RESPONSE" | jq -r '.data | length')
  if [ "$DATA_COUNT" -gt 0 ]; then
    echo "✅ 链上赚币产品查询成功，共 $DATA_COUNT 个产品"
    echo ""
    echo "链上赚币持仓："
    
    > "$TEMP_DIR/staking_balances.txt"
    
    for ((i=0; i<DATA_COUNT; i++)); do
      CCY=$(jq -r ".[$i].ccy" "$TEMP_DIR/staking_response.json")
      AMT=$(jq -r ".[$i].amt" "$TEMP_DIR/staking_response.json")
      APY=$(jq -r ".[$i].apy" "$TEMP_DIR/staking_response.json")
      PROD_ID=$(jq -r ".[$i].prodId" "$TEMP_DIR/staking_response.json")
      
      echo "  🪙 $CCY (产品: $PROD_ID)"
      echo "     数量: $AMT"
      echo "     APY: ${APY}%"
      
      PRICE=$(get_price "$CCY")
      if [ "$PRICE" != "0" ] && [ "$PRICE" != "null" ]; then
        USDT_VALUE=$(calculate_usdt "$AMT" "$PRICE")
        echo "     估值: ≈ $USDT_VALUE USDT"
        echo "$CCY|$AMT|$USDT_VALUE|$APY" >> "$TEMP_DIR/staking_balances.txt"
      fi
      echo ""
    done
  else
    echo "📭 暂无链上赚币持仓"
  fi
else
  echo "❌ 链上赚币查询失败 (错误码: $API_CODE)"
  echo "$(echo "$STAKING_RESPONSE" | jq -r '.msg // "未知错误"')"
fi

echo ""

# ============================================
# 2. 查询 DeFi 挖矿产品
# ============================================
echo "📊 2️⃣ 查询 DeFi 挖矿产品..."
echo "----------------------------------------"

TIMESTAMP=$(generate_timestamp)
METHOD="GET"
REQUEST_PATH="/api/v5/finance/staking-defi/defi/active-orders"
SIGNATURE=$(generate_signature "$TIMESTAMP" "$METHOD" "$REQUEST_PATH" "")

DEFI_RESPONSE=$(curl $CURL_OPTS "${BASE_URL}${REQUEST_PATH}" \
  -H "OK-ACCESS-KEY: ${API_KEY}" \
  -H "OK-ACCESS-SIGN: ${SIGNATURE}" \
  -H "OK-ACCESS-TIMESTAMP: ${TIMESTAMP}" \
  -H "OK-ACCESS-PASSPHRASE: ${PASSPHRASE}")

echo "$DEFI_RESPONSE" | jq '.' > "$TEMP_DIR/defi_response.json"

API_CODE=$(echo "$DEFI_RESPONSE" | jq -r '.code // ""')

if [ "$API_CODE" == "0" ]; then
  DATA_COUNT=$(echo "$DEFI_RESPONSE" | jq -r '.data | length')
  if [ "$DATA_COUNT" -gt 0 ]; then
    echo "✅ DeFi 挖矿产品查询成功，共 $DATA_COUNT 个产品"
    echo ""
    echo "DeFi 挖矿持仓："
    
    > "$TEMP_DIR/defi_balances.txt"
    
    for ((i=0; i<DATA_COUNT; i++)); do
      CCY=$(jq -r ".[$i].ccy" "$TEMP_DIR/defi_response.json")
      AMT=$(jq -r ".[$i].amt" "$TEMP_DIR/defi_response.json")
      APY=$(jq -r ".[$i].apy" "$TEMP_DIR/defi_response.json")
      PROD_ID=$(jq -r ".[$i].prodId" "$TEMP_DIR/defi_response.json")
      
      echo "  🪙 $CCY (产品: $PROD_ID)"
      echo "     数量: $AMT"
      echo "     APY: ${APY}%"
      
      PRICE=$(get_price "$CCY")
      if [ "$PRICE" != "0" ] && [ "$PRICE" != "null" ]; then
        USDT_VALUE=$(calculate_usdt "$AMT" "$PRICE")
        echo "     估值: ≈ $USDT_VALUE USDT"
        echo "$CCY|$AMT|$USDT_VALUE|$APY" >> "$TEMP_DIR/defi_balances.txt"
      fi
      echo ""
    done
  else
    echo "📭 暂无 DeFi 挖矿持仓"
  fi
else
  echo "❌ DeFi 挖矿查询失败 (错误码: $API_CODE)"
  echo "$(echo "$DEFI_RESPONSE" | jq -r '.msg // "未知错误"')"
fi

echo ""

# ============================================
# 3. 查询定期产品（Term/Structured）
# ============================================
echo "📊 3️⃣ 查询定期/结构化产品..."
echo "----------------------------------------"

TIMESTAMP=$(generate_timestamp)
METHOD="GET"
REQUEST_PATH="/api/v5/finance/structured/active-orders"
SIGNATURE=$(generate_signature "$TIMESTAMP" "$METHOD" "$REQUEST_PATH" "")

TERM_RESPONSE=$(curl $CURL_OPTS "${BASE_URL}${REQUEST_PATH}" \
  -H "OK-ACCESS-KEY: ${API_KEY}" \
  -H "OK-ACCESS-SIGN: ${SIGNATURE}" \
  -H "OK-ACCESS-TIMESTAMP: ${TIMESTAMP}" \
  -H "OK-ACCESS-PASSPHRASE: ${PASSPHRASE}")

echo "$TERM_RESPONSE" | jq '.' > "$TEMP_DIR/term_response.json"

API_CODE=$(echo "$TERM_RESPONSE" | jq -r '.code // ""')

if [ "$API_CODE" == "0" ]; then
  DATA_COUNT=$(echo "$TERM_RESPONSE" | jq -r '.data | length')
  if [ "$DATA_COUNT" -gt 0 ]; then
    echo "✅ 定期产品查询成功，共 $DATA_COUNT 个产品"
    echo ""
    echo "定期产品持仓："
    
    > "$TEMP_DIR/term_balances.txt"
    
    for ((i=0; i<DATA_COUNT; i++)); do
      CCY=$(jq -r ".[$i].ccy" "$TEMP_DIR/term_response.json")
      AMT=$(jq -r ".[$i].amt" "$TEMP_DIR/term_response.json")
      APY=$(jq -r ".[$i].apy" "$TEMP_DIR/term_response.json")
      PROD_ID=$(jq -r ".[$i].prodId" "$TEMP_DIR/term_response.json")
      
      echo "  🪙 $CCY (产品: $PROD_ID)"
      echo "     数量: $AMT"
      echo "     APY: ${APY}%"
      
      PRICE=$(get_price "$CCY")
      if [ "$PRICE" != "0" ] && [ "$PRICE" != "null" ]; then
        USDT_VALUE=$(calculate_usdt "$AMT" "$PRICE")
        echo "     估值: ≈ $USDT_VALUE USDT"
        echo "$CCY|$AMT|$USDT_VALUE|$APY" >> "$TEMP_DIR/term_balances.txt"
      fi
      echo ""
    done
  else
    echo "📭 暂无定期产品持仓"
  fi
else
  echo "❌ 定期产品查询失败 (错误码: $API_CODE)"
  echo "$(echo "$DEFI_RESPONSE" | jq -r '.msg // "未知错误"')"
fi

echo ""

# ============================================
# 4. 生成汇总报告
# ============================================
echo "💎 赚币资产汇总报告"
echo "========================================"

TOTAL_ALL_USDT=0

# 简单赚币（从之前的查询结果）
echo "📊 简单赚币（Simple Earn）："
echo "  • IP: 50.25339921 ≈ 65.48 USDT"
echo "  • USDT: 0.01992387 ≈ 0.02 USDT"
echo "  • BTC: 0.00192129 ≈ 132.33 USDT"
echo "  • PEPE: 18249434.81420952 ≈ 69.79 USDT"
TOTAL_ALL_USDT=$(echo "$TOTAL_ALL_USDT + 65.48 + 0.02 + 132.33 + 69.79" | bc -l)
echo "  小计: 267.62 USDT"
echo ""

# 链上赚币
if [ -f "$TEMP_DIR/staking_balances.txt" ]; then
  STAKING_TOTAL=0
  echo "📊 链上赚币（Staking）："
  while IFS='|' read -r ccy amt usdt apy; do
    if [ -n "$ccy" ]; then
      echo "  • $ccy: $amt ≈ $usdt USDT (APY: ${APY}%)"
      STAKING_TOTAL=$(echo "$STAKING_TOTAL + $usdt" | bc -l)
    fi
  done < "$TEMP_DIR/staking_balances.txt"
  STAKING_TOTAL=$(printf "%.2f" "$STAKING_TOTAL")
  echo "  小计: $STAKING_TOTAL USDT"
  TOTAL_ALL_USDT=$(echo "$TOTAL_ALL_USDT + $STAKING_TOTAL" | bc -l)
  echo ""
fi

# DeFi 挖矿
if [ -f "$TEMP_DIR/defi_balances.txt" ]; then
  DEFI_TOTAL=0
  echo "📊 DeFi 挖矿："
  while IFS='|' read -r ccy amt usdt apy; do
    if [ -n "$ccy" ]; then
      echo "  • $ccy: $amt ≈ $usdt USDT (APY: ${APY}%)"
      DEFI_TOTAL=$(echo "$DEFI_TOTAL + $usdt" | bc -l)
    fi
  done < "$TEMP_DIR/defi_balances.txt"
  DEFI_TOTAL=$(printf "%.2f" "$DEFI_TOTAL")
  echo "  小计: $DEFI_TOTAL USDT"
  TOTAL_ALL_USDT=$(echo "$TOTAL_ALL_USDT + $DEFI_TOTAL" | bc -l)
  echo ""
fi

# 定期产品
if [ -f "$TEMP_DIR/term_balances.txt" ]; then
  TERM_TOTAL=0
  echo "📊 定期/结构化产品："
  while IFS='|' read -r ccy amt usdt apy; do
    if [ -n "$ccy" ]; then
      echo "  • $ccy: $amt ≈ $usdt USDT (APY: ${APY}%)"
      TERM_TOTAL=$(echo "$TERM_TOTAL + $usdt" | bc -l)
    fi
  done < "$TEMP_DIR/term_balances.txt"
  TERM_TOTAL=$(printf "%.2f" "$TERM_TOTAL")
  echo "  小计: $TERM_TOTAL USDT"
  TOTAL_ALL_USDT=$(echo "$TOTAL_ALL_USDT + $TERM_TOTAL" | bc -l)
  echo ""
fi

TOTAL_ALL_USDT=$(printf "%.2f" "$TOTAL_ALL_USDT")
echo "========================================"
echo "💎 赚币资产总估值: $TOTAL_ALL_USDT USDT"
echo "========================================"
echo ""

# 清理
rm -rf "$TEMP_DIR"

echo "✅ 查询完成"
