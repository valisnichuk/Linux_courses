# С чего начинается Linux

## Домашнее задание

>Обновить ядро в базовой системе
>
>Цель: Студент получит навыки работы с Git, Vagrant, Packer и публикацией готовых образов в Vagrant Cloud.
>
>В материалах к занятию есть методичка (manual_kernel_update/manual/manual.md), в которой описана процедура обновления ядра из репозитория. По данной методичке требуется выполнить необходимые действия. Полученный в ходе выполнения ДЗ Vagrantfile должен быть залит в ваш репозиторий. Для проверки ДЗ необходимо прислать ссылку на него.

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

С помощью команды `wget` скачайте архив с исходным кодом ядра Linux:

```
[root@manual-kernel-update kernels]# wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.11.tar.xz
```

#### Шаг №2: Распаковка архива с исходным кодом

Распакуем архив, применив команду `tar`.

```
[root@manual-kernel-update kernels]# tar --xz -xvf linux-6.11.tar.xz
```

#### Шаг №3: Установка необходимых пакетов

Нам потребуются дополнительные утилиты, с помощью которых мы произведем компиляцию и установку ядра. Для этого выполните следующую команду:

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

**Debian/Ubuntu/Linux Mint:**

```
root@manual-kernel-update:~# apt update
root@manual-kernel-update:~# apt install git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison
```

Данная команда установит следуюшие пакеты:

<table>
    <thead>
        <tr>
            <th align="center">Пакет</th>
            <th align="center">Описание</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td align="center"><strong>git</strong></td>
            <td>Утилита, помогающая отслеживать изменения в файлах исходного кода. А в случае какой-либо ошибки, эти изменения можно будет откатить.</td>
        </tr>
        <tr>
            <td align="center"><strong>fakeroot</strong></td>
            <td>Позволяет запускать команду в среде, имитирующей привилегии root.</td>
        </tr>
        <tr>
            <td align="center"><strong>build-essential</strong></td>
            <td>Набор различных утилит для компиляции программ (компиляторы gcc, g++ и пр.).</td>
        </tr>
        <tr>
            <td align="center"><strong>ncurses-dev</strong></td>
            <td>Библиотека, предоставляющая API для программирования текстовых терминалов.</td>
        </tr>
        <tr>
            <td align="center"><strong>xz-utils</strong></td>
            <td>Утилита для работы с архивами в .xz-формате.</td>
        </tr>
        <tr>
            <td align="center"><strong>libssl-dev</strong></td>
            <td>Библиотека для разработки и поддержки протоколов шифрования SSL и TLS.</td>
        </tr>
        <tr>
            <td align="center"><strong>bc</strong> (Basic Calculator)</td>
            <td>Интерактивный интерпретатор, позволяющий выполнять скрипты с различными математическими выражениями.</td>
        </tr>
        <tr>
            <td align="center"><strong>flex</strong> (Fast Lexical Analyzer Generator)</td>
            <td>Утилита генерации программ, которые могут распознавать в тексте шаблоны.</td>
        </tr>
        <tr>
            <td align="center"><strong>libelf-dev</strong></td>
            <td>Библиотека, используемая для работы с ELF-файлами (исполняемые файлы, файлы объектного кода и дампы ядра).</td>
        </tr>
        <tr>
            <td align="center"><strong>bison</strong></td>
            <td>Создает из набора правил программу анализа структуры текстовых файлов.</td>
        </tr>
    </tbody>
</table>

#### Шаг №4: Конфигурирование ядра

Исходный код ядра Linux уже содержит стандартный файл конфигурации с набором различных настроек. Однако вы можете сами изменить его в соответствии с вашими потребностями.

Для этого перейдите с помощью команды `cd` в каталог `/usr/src/kernels/linux-6.11`:

```
[root@manual-kernel-update ~]# cd /usr/src/kernels/linux-6.11/
[root@manual-kernel-update linux-6.11]# 
```

Скопируйте существующий файл конфигурации с помощью команды `cp`:

```
[root@manual-kernel-update linux-6.11]# cp -v /boot/config-$(uname -r) .config
```

Запускаем команды для перечитывания настроек с действующего ядра и запихиваем в новое ядро, по умолчанию всегда нажимаем на `Enter` или выбираем `y/n`.

```
[root@manual-kernel-update linux-6.11]# make olddefconfig
```

Затем открываем граф. интерфейс для выбора доп. модулей если надо

```
[root@manual-kernel-update linux-6.11]# make menuconfig
```

Данная команда запускает несколько сценариев, которые далее откроют перед вами меню конфигурации.

Меню конфигурации включает в себя такие параметры, как:

* **Firmware Drivers** - настройка прошивки/драйверов для различных устройств;
* **Virtualization** - настройки виртуализации;
* **File systems** - настройки различных файловых систем;
* **и пр.**

Для навигации по меню применяются стрелки на клавиатуре. Пункт `<Help>` поможет вам узнать больше о различных параметрах. Когда вы закончите вносить изменения, выберите пункт `<Save>`, а затем выйдите из меню с помощью пункта `<Exit>`.

> **Примечание:** Изменение настроек некоторых параметров может привести к тому, что в вашем новом ядре будет отсутствовать поддержка жизненно важных для системы функций. Если вы не уверены, что нужно изменить, то оставьте заданные по умолчанию настройки.

> **Примечание:** Если вы использовали вариант с копированием файла конфигурации, то перед переходом к следующему шагу, откройте этот файл и проверьте, что параметр `CONFIG_SYSTEM_TRUSTED_KEYS` у вас определен так же, как указано на следующем скриншоте:
> 
> ![image](https://github.com/user-attachments/assets/6d27cb48-db37-4fb8-8053-e8bad9e4d83f)
>
> В противном случае вы можете получить ошибку:
>
> `make[4]: *** No rule to make target 'debian/certs/test-signing-certs.pem', needed by 'certs/x509_certificate_list'. Stop.`
>
> `make[4]: *** Waiting for unfinished jobs....`

> **Примечание:** В процессе сборки ядра может появится ошибка:
> 
> `BTF: .tmp_vmlinux1: pahole (pahole) is not available`
> 
> `Failed to generate BTF for vmlinux`
> 
> `Try to disable CONFIG_DEBUG_INFO_BTF`
> 
> `make[2]: *** [scripts/Makefile.vmlinux:34: vmlinux] Error 1`
> 
> `make[1]: *** [/usr/src/kernels/linux-6.11/Makefile:1157: vmlinux] Error 2`
> 
> `make: *** [Makefile:224: __sub-make] Error 2`
>
> Исправить эту ошибку можно, откройте файл `.config`, отключите параметр `CONFIG_DEBUG_INFO_BTF` (по умолчанию, `CONFIG_DEBUG_INFO_BTF=y`)
>
> ![image](https://github.com/user-attachments/assets/abc5ab8d-603d-445a-8739-3066402285c6)
>
> или попробуйте установить dwarves (Debugging Information Manipulation Tools (pahole & friends))
>
> `$ sudo yum install dwarves`
>
> или
>
> `$ sudo apt install dwarves`

#### Шаг №5: Сборка ядра

Процесс сборки и компиляции ядра Linux занимает довольно продолжительное время.

Во время этого процесса в терминале будут перечисляться все выбранные компоненты ядра Linux: компонент управления памятью, компонент управления процессами, драйверы аппаратных устройств, драйверы файловых систем, драйверы сетевых карт и пр.

Приступая к сборке, используйте ключ `-j4` для разделения процесса сборки на несколько потоков, чтобы по максимуму использовать выделенные мощности. Собираем неспосредственно ядро и упаковываем его, производим сборку модулей, устанавливаем все по очереди, не забываем про хедеры, чтобы встали vb guest additions.

```
[root@manual-kernel-update linux-6.11]# make -j4 bzImage
[root@manual-kernel-update linux-6.11]# make -j4 modules  
[root@manual-kernel-update linux-6.11]# make -j4
[root@manual-kernel-update linux-6.11]# make -j4 modules_install
[root@manual-kernel-update linux-6.11]# make -j4 headers_install
[root@manual-kernel-update linux-6.11]# make -j4 install
```

```
output:

  INSTALL /boot
VirtualBox Guest Additions: Building the modules for kernel 6.11.0.
VirtualBox Guest Additions: Look at /var/log/vboxadd-setup.log to find out what went wrong
```

Проверяем, установились ли vb guest additions

```
[vagrant@manual-kernel-update ~]$ sudo lsmod | grep vbox
```

#### Шаг №6: Обновление загрузчика

Загрузчик GRUB - это первая программа, которая запускается при включении системы.

**CentOS/RHEL/Scientific Linux:**

```
[root@manual-kernel-update ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
[root@manual-kernel-update ~]# grubby --set-default /boot/vmlinuz-6.11.0
```

Вы можете подтвердить детали с помощью следующих команд

```
[root@manual-kernel-update ~]# grubby --info=ALL | more
[root@manual-kernel-update ~]# grubby --default-index
[root@manual-kernel-update ~]# grubby --default-kernel
```

**Debian/Ubuntu/Linux Mint:**

Команда `make install` автоматически обновит загрузчик.

Для того, чтобы обновить загрузчик вручную, вам необходимо сначала обновить `initramfs` до новой версии ядра:

```
$ sudo update-initramfs -c -k 6.11.0
```

Затем обновить загрузчик GRUB с помощью следующей команды:

```
$ sudo update-grub2
```

#### Шаг №7: Перезагрузка системы

После выполнения вышеописанных действий перезагрузите свой компьютер. Когда система загрузится, проверьте версию используемого ядра с помощью следующей команды:

```
[root@manual-kernel-update ~]# reboot
```

Проверим версию ядра

```
$ vagrant ssh
[root@manual-kernel-update ~]# uname -rs
```

```
output:

Linux 6.11.0
```

Как видите, теперь в системе установлено собранное нами ядро Linux 6.11.0









