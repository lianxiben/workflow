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

# 创建需要的文件夹
mkdir -p ./logs
mkdir -p ./tmp

# 创建一个数组来保存所有子shell的PID
pids=()

# 对于每一个URL，启动一个子shell来执行检测
for ((index = 0; index < ${#KEYSARRAY[@]}; index++)); do
  key="${KEYSARRAY[index]}"
  url="${URLSARRAY[index]}"

  # 在子shell中执行检测
  (
    result="failed"
    http_code="000"
    connect_time_ms="null"

    for i in 1 2 3; do
      response=$(curl --write-out '%{http_code}' --silent --output /dev/null --max-time 7 "$url")
      http_code="$response"
      echo "检测 [$key] 第 $i 次返回状态码: $http_code"
      if [[ "$http_code" =~ ^(200|201|202|301|302|307|403)$ ]]; then
        result="success"
        break
      fi
      sleep 5
    done

    if [[ $result == "success" ]]; then
      connect_time_seconds=$(curl -o /dev/null -s -w "%{time_connect}\n" "$url")
      connect_time_ms=$(awk '{printf "%.0f\n", ($1 * 1000 + 0.5)}' <<<"$connect_time_seconds")
    fi

    # 写入日志文件：只保留时间、结果、连接时间
    dateTime=$(date +'%Y-%m-%d %H:%M')
    echo "$dateTime, $result, $connect_time_ms" >> "./logs/${key}_report.log"
    # 保留最新30000条日志
    echo "$(tail -30000 ./logs/${key}_report.log)" > "./logs/${key}_report.log"
  ) &
  pids+=($!)
done

# 等待所有子shell完成
for pid in "${pids[@]}"; do
  wait $pid
done
