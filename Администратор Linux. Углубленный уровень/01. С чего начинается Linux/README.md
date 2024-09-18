# С чего начинается Linux
## Домашнее задание

>Обновить ядро в базовой системе
>
>Цель: Студент получит навыки работы с Git, Vagrant, Packer и публикацией готовых образов в Vagrant Cloud.
>
>В материалах к занятию есть методичка, в которой описана процедура обновления ядра из репозитория. По данной методичке требуется выполнить необходимые действия. Полученный в ходе выполнения ДЗ Vagrantfile должен быть залит в ваш репозиторий. Для проверки ДЗ необходимо прислать ссылку на него.

## Рабочее окружение

* Debian 12
* Vagrant 2.4.1
* Oracle VirtualBox 7.0.20 r163906
* Packer v1.11.2
* модифицированный Vagrant файл из ДЗ: увеличено в 4 раза количество ядер и в 8 раз увеличена оперативная память, чтобы сократить время сборки ядра и модулей.

## Подготовка рабочего окружения

### 1. Установка Vagrant

`$ sudo apt update`

`$ sudo apt install vagrant`

### 2. Установка VirtualBox
`$ wget -O- -q https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmour -o /usr/share/keyrings/oracle_vbox_2016.gpg`

`$ sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle_vbox_2016.gpg] http://download.virtualbox.org/virtualbox/debian bookworm contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list`

`$ sudo apt update`

`$ sudo apt install virtualbox-7.0`

### 3. Установка packer

sudo apt install packer

### 4. В домашней директории создаю поддиректорию и перехожу в нее

`$ mkdir -p ./otus/hw01 && cd ./otus/hw01`

### 5. Создать Vagrantfile

`vi Vagrantfile`

uname -rs
Linux 6.1.0-25-amd64
