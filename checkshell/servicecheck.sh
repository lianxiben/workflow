#!/bin/bash

export TZ='Asia/Shanghai'

KEYSARRAY=()
URLSARRAY=()

# 读取urls.cfg配置文件
urlsConfig="./src/urls.cfg"
while read -r line; do
    if [[ ${line} =~ ^\s*# ]] ; then
        continue
    fi
    echo "[$line] 正在检测中······"
    IFS='=' read -ra TOKENS <<<"$line"
    KEYSARRAY+=(${TOKENS[0]})
    URLSARRAY+=(${TOKENS[1]})
done <"$urlsConfig"

# 创建所需文件夹
mkdir -p ./logs
mkdir -p ./tmp

# 保存所有子shell PID
pids=()

# 检测每个 URL
for ((index = 0; index < ${#KEYSARRAY[@]}; index++)); do
  key="${KEYSARRAY[index]}"
  url="${URLSARRAY[index]}"

  (
    result="failed"

    for i in 1 2 3; do
      # 检测状态码时加 User-Agent（防403）
      response=$(curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" \
         -H "Cookie: over18=1" \
         --write-out '%{http_code}' --silent --output /dev/null --max-time 7 "$url")
      echo "检测 [$key] 第 $i 次返回状态码: $response"
      if [[ "$response" =~ ^(200|201|202|301|302|307)$ ]]; then
        result="success"
        break
      fi
      sleep 5
    done

    # 成功后获取连接耗时
    if [[ $result == "success" ]]; then
      connect_time_seconds=$(curl -o /dev/null -s -w "%{time_connect}\n" "$url")
      connect_time_ms=$(awk '{printf "%.0f\n", ($1 * 1000 + 0.5)}' <<<"$connect_time_seconds")
    else
      connect_time_ms="null"
    fi

    dateTime=$(date +'%Y-%m-%d %H:%M')
    echo "$dateTime, $result, $connect_time_ms" >> "./logs/${key}_report.log"
    echo "$(tail -30000 ./logs/${key}_report.log)" > "./logs/${key}_report.log"
  ) &
  pids+=($!)
done

# 等待所有子进程完成
for pid in "${pids[@]}"; do
  wait $pid
done
