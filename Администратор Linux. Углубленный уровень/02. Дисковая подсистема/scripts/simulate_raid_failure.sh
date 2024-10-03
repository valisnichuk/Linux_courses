#!/bin/bash

set -e

RAID_NAME="/dev/md0"

# Функция для вывода состояния RAID
show_raid_status() {
  echo "Текущее состояние RAID:"
  sudo mdadm --detail $RAID_NAME
  echo "Статус /proc/mdstat:"
  cat /proc/mdstat
}

# Симулировать сбой диска
simulate_failure() {
  local failed_disk=$1
  echo "Симуляция сбоя диска $failed_disk в RAID массиве $RAID_NAME..."
  sudo mdadm --manage $RAID_NAME --fail $failed_disk
  sudo mdadm --manage $RAID_NAME --remove $failed_disk
}

# Восстановить диск
recover_disk() {
  local new_disk=$1
  echo "Восстановление диска $new_disk в RAID массиве $RAID_NAME..."
  sudo mdadm --manage $RAID_NAME --add $new_disk
}

# Проверка аргументов
if [ "$#" -ne 2 ]; then
  echo "Использование: $0 <fail|recover> <disk>"
  exit 1
fi

ACTION=$1
DISK=$2

case $ACTION in
  fail)
    simulate_failure $DISK
    ;;
  recover)
    recover_disk $DISK
    ;;
  *)
    echo "Неподдерживаемое действие: $ACTION. Используйте 'fail' или 'recover'."
    exit1
    ;;
esac

# Показываем состояние после действия
show_raid_status
