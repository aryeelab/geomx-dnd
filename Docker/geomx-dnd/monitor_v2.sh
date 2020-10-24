#!/bin/bash
echo ==================================
echo =========== MONITORING ===========
echo ==================================
echo --- General Information ---
echo \#CPU: $(nproc)
echo Total Memory: $(free -h | grep Mem | awk '{ print $2 }')
echo Total Disk space: $(df -h | grep cromwell_root | awk '{ print $2}')
echo 
echo --- Runtime Information ---

echo "time cpu_usage memory_usage disk_usage"

function runtimeInfo() {
        datetime=$(date "+%F_%T")
        cpu=$(top -bn 2 -d 0.01 | grep '^%Cpu' | tail -n 1 | awk '{print $2}')%
        mem=$(free -m | grep Mem | awk '{ OFMT="%.0f"; print ($3/$2)*100; }')%
        disk=$(df | grep cromwell_root | awk '{ print $5 }')
        echo $datetime $cpu $mem $disk
}

while true; do runtimeInfo; sleep 60; done
