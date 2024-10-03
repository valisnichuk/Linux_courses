#!/bin/bash

set -e

# Переменные
RAID_LEVEL=${RAID_LEVEL:-1}      # Уровень RAID по умолчанию RAID1
RAID_DEVICES=${RAID_DEVICES:-2}  # Количество устройств в RAID
RAID_NAME="/dev/md0"

# Установка необходимых пакетов
echo "Установка необходимых пакетов..."
sudo yum install -y mdadm smartmontools hdparm gdisk

# Настройка RAID
echo "Настройка RAID..."
case $RAID_LEVEL in
  0)
    RAID_PARAMS="--level=0 --raid-devices=$RAID_DEVICES"
    ;;
  1)
    RAID_PARAMS="--level=1 --raid-devices=$RAID_DEVICES"
    ;;
  5)
    RAID_PARAMS="--level=5 --raid-devices=$RAID_DEVICES"
    ;;
  10)
    RAID_PARAMS="--level=10 --raid-devices=$RAID_DEVICES"
    ;;
  *)
    echo "Неподдерживаемый уровень RAID: $RAID_LEVEL. Используем RAID1."
    RAID_PARAMS="--level=1 --raid-devices=2"
    ;;
esac

# Определение устройств для RAID
RAID_DEVICES_LIST=()
for i in $(seq 1 $RAID_DEVICES); do
  char=$(printf "\\$(printf '%03o' $((97 + i)))")
  sudo mdadm --zero-superblock --force /dev/sd$char
  RAID_DEVICES_LIST+=("/dev/sd$char")
done

echo "Создание RAID массива $RAID_NAME с параметрами: $RAID_PARAMS"
sudo mdadm --create --metadata=0.90 --verbose $RAID_NAME $RAID_PARAMS "${RAID_DEVICES_LIST[@]}"

# Сохранение конфигурации mdadm...
echo "Сохранение конфигурации mdadm..."
sudo mkdir /etc/mdadm
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo dracut --force

# Создание GPT разделов и партиций
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%

for i in $(seq 1 5); do
  sudo mkfs.ext4 /dev/md0p$i;
done

# Создание точек монтирования
sudo mkdir -p /mnt/part{1,2,3,4,5}

# Монтирование партиций
echo "Монтирование партиций"
for i in $(seq 1 5); do
  mount /dev/md0p$i /mnt/part$i
done

# Добавление в fstab
echo "Добавление партиций в /etc/fstab..."
sudo bash -c "echo '/dev/md0p1 /mnt/part1 ext4 defaults,nofail,auto 0 0' >> /etc/fstab"
sudo bash -c "echo '/dev/md0p2 /mnt/part2 ext4 defaults,nofail,auto 0 0' >> /etc/fstab"
sudo bash -c "echo '/dev/md0p3 /mnt/part3 ext4 defaults,nofail,auto 0 0' >> /etc/fstab"
sudo bash -c "echo '/dev/md0p4 /mnt/part4 ext4 defaults,nofail,auto 0 0' >> /etc/fstab"
sudo bash -c "echo '/dev/md0p5 /mnt/part5 ext4 defaults,nofail,auto 0 0' >> /etc/fstab"

# Проверка
echo "Проверка состояния системы..."
lsblk
