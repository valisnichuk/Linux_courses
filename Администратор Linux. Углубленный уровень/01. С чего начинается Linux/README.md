# С чего начинается Linux

## Домашнее задание

>Обновить ядро в базовой системе
>
>Цель: Студент получит навыки работы с Git, Vagrant, Packer и публикацией готовых образов в Vagrant Cloud.
>
>В материалах к занятию есть [методичка](https://github.com/valisnichuk/manual_kernel_update/blob/master/manual/manual.md), в которой описана процедура обновления ядра из репозитория. По данной методичке требуется выполнить необходимые действия. Полученный в ходе выполнения ДЗ Vagrantfile должен быть залит в ваш репозиторий. Для проверки ДЗ необходимо прислать ссылку на него.

## Рабочее окружение

* Debian 12
* Vagrant 2.4.1
* Oracle VirtualBox 7.0.20 r163906
* Packer v1.11.2
* модифицированный Vagrant файл из ДЗ: увеличено в 4 раза количество ядер и в 8 раз увеличена оперативная память, чтобы сократить время сборки ядра и модулей.

## Подготовка рабочего окружения

### 1. Установка Vagrant
```
$ sudo apt update
$ sudo apt install vagrant
```

### 2. Установка VirtualBox

```
$ wget -O- -q https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmour -o /usr/share/keyrings/oracle_vbox_2016.gpg
$ sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle_vbox_2016.gpg] http://download.virtualbox.org/virtualbox/debian bookworm contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
$ sudo apt update
$ sudo apt install virtualbox-7.0
```

### 3. Установка packer

```
$ sudo apt install packer
```

### 4. В домашней директории создаю поддиректорию и перехожу в нее

```
$ mkdir -p ./otus/hw01 && cd ./otus/hw01
```

### 5. Создать Vagrantfile

```
$ vi Vagrantfile
```

## Выполнение Домашнего задания

### Обновление ядра в базовой системе

Ядро Linux является основой дистрибутивов Linux. Оно связывает аппаратное и программное обеспечение компьютера, а также отвечает за распределение доступных ресурсов.

Если вы хотите отключить несколько опций и драйверов или попробовать экпериментальные исправления, то вам необходимо будет собрать ядро вручную. В этой статье вы узнаете, как с нуля самостоятельно скомпилировать и установить ядро Linux.

### Запустим виртуальную машину и залогинимся

`vagrant up`, `vagrant ssh`, проверяю версию рабочего ядра и ставлю все необходимые пакеты для обновления ядра вручную

```
$ vagrant up
```
```
output:

Bringing machine 'manual-kernel-update' up with 'virtualbox' provider...
==> manual-kernel-update: Importing base box 'generic/centos9s'...
==> manual-kernel-update: Matching MAC address for NAT networking...
==> manual-kernel-update: Checking if box 'generic/centos9s' version '4.3.12' is up to date...
==> manual-kernel-update: Setting the name of the VM: hw01_manual-kernel-update_1726747239703_69141
==> manual-kernel-update: Clearing any previously set network interfaces...
==> manual-kernel-update: Preparing network interfaces based on configuration...
    manual-kernel-update: Adapter 1: nat
==> manual-kernel-update: Forwarding ports...
    manual-kernel-update: 22 (guest) => 2222 (host) (adapter 1)
==> manual-kernel-update: Running 'pre-boot' VM customizations...
==> manual-kernel-update: Booting VM...
==> manual-kernel-update: Waiting for machine to boot. This may take a few minutes...
    manual-kernel-update: SSH address: 127.0.0.1:2222
    manual-kernel-update: SSH username: vagrant
    manual-kernel-update: SSH auth method: private key
==> manual-kernel-update: Machine booted and ready!
==> manual-kernel-update: Checking for guest additions in VM...
==> manual-kernel-update: Setting hostname...
==> manual-kernel-update: Running provisioner: shell...
    manual-kernel-update: Running: inline script
```

```
$ vargant ssh
[vagrant@manual-kernel-update ~]$ uname -rs
```

```
output:

Linux 5.14.0-391.el9.x86_64
```

### Сборка ядра Linux

Процесс сборки ядра Linux состоит из семи простых шагов. Однако для выполнения этой процедуры вам потребуется значительное количество времени (зависящее от характеристик вашего компьютера).

#### Шаг №1: Загрузка исходного кода

Откройте сайт kernel.org и найдите архив с исходными кодами самой свежей версии ядра (Latest Realease).

![image](https://github.com/user-attachments/assets/4f441be8-31ef-4ba6-9670-87798f7c867d)

> **Примечание:** Не пугайтесь, если версия ядра на сайте kernel.org не совпадает с той, которую я использовал на данном уроке. Все рассмотренные шаги/команды работоспособны, просто вам придеться заменить цифры и версии ядра на свои.

Переходим в директорию, где будем собирать ядро, скачав архив с исходниками.

```
[vagrant@manual-kernel-update ~]$ sudo passwd root
```

```
output:

Changing password for user root.
New password: 
BAD PASSWORD: The password fails the dictionary check - it is based on a (reversed) dictionary word
Retype new password: 
passwd: all authentication tokens updated successfully.
```

```
[vagrant@manual-kernel-update ~]$ su -
```

```
output:

Password: 
Last login: Thu Sep 19 12:58:16 UTC 2024 on pts/0
```

```
[root@manual-kernel-update ~]# cd /usr/src/kernels/
```

С помощью команды wget скачайте архив с исходным кодом ядра Linux:

```
[root@manual-kernel-update kernels]# wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.11.tar.xz
```

#### Шаг №2: Распаковка архива с исходным кодом

Распакуем архив, применив команду tar.

```
[root@manual-kernel-update kernels]# tar --xz -xvf linux-6.11.tar.xz
```

#### Шаг №3: Установка необходимых пакетов

Нам потребуются дополнительные утилиты, с помощью которых мы произведем компиляцию у установку ядра. Для этого выполните следующую команду:

**CentOS/RHEL/Scientific Linux:**

```
[root@manual-kernel-update ~]# yum group install "Development Tools"
```

или

```
[root@manual-kernel-update ~]# yum groupinstall "Development Tools"
```

Также необходимо установить дополнительные пакеты:

```
[root@manual-kernel-update ~]# yum install ncurses-devel bison flex elfutils-libelf-devel openssl-devel hmaccalc zlib-devel binutils-devel bc vim make gcc grub2
```

#### Шаг №4: Конфигурирование ядра




