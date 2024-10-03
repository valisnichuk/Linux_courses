# -*- mode: ruby -*-
# vim: set ft=ruby :

home = ENV['HOME']

MACHINES = {
  :otuslinux => {
    :box_name => "generic/centos9s",
    :ip_addr => '192.168.11.101',
    :disks => {
      :sata1 => {
        :dfile => 'disks/sata1.vdi',
        :size => 2048, # Megabytes
        :port => 1
      },
      :sata2 => {
        :dfile => 'disks/sata2.vdi',
        :size => 2048, # Megabytes
        :port => 2
      },
      :sata3 => {
        :dfile => 'disks/sata3.vdi',
        :size => 2048, # Megabytes
        :port => 3
      },
      :sata4 => {
        :dfile => 'disks/sata4.vdi',
        :size => 2048, # Megabytes
        :port => 4
      },
      :sata5 => {
        :dfile => 'disks/sata5.vdi',
        :size => 2048, # Megabytes
        :port => 5
      }
    },
    # Конфигурация RAID: выберите уровень RAID (0,1,5,10)
    raid_level: 10,    # Можно изменить на 0, 5, 10
    raid_devices: 5   # Количество устройств для RAID
  }
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.hostname = boxname.to_s

      # Настройка приватной сети
      box.vm.network "private_network", ip: boxconfig[:ip_addr]

      box.vm.provider :virtualbox do |vb|
        vb.memory = 2048

        # Определяем абсолютный путь к директории дисков
        disk_dir = File.join(home, 'VirtualBox VMs')
        unless Dir.exist?(disk_dir)
          puts "Создаем директорию для дисков: #{disk_dir}"
          Dir.mkdir(disk_dir)
        end

        # Добавляем SATA контроллер
        #vb.customize ["storagectl", :id, "--name", "SATA Controller", "--add", "sata", "--controller", "IntelAHCI"]

        # Цикл для добавления дисков
        boxconfig[:disks].each do |dname, dconf|
          disk_path = File.expand_path(dconf[:dfile], disk_dir)

          # Проверяем, существует ли уже диск
          unless File.exist?(disk_path)
            puts "Создаем диск #{disk_path}"
            vb.customize [
              'createhd',
              '--filename', disk_path,
              '--variant', 'Fixed',
              '--size', dconf[:size]
            ]
          else
            puts "Диск #{disk_path} уже существует. Пропускаем создание."
          end

          # Присоединяем диск к контроллеру
          vb.customize [
            'storageattach', :id,
            '--storagectl', 'SATA Controller',
            '--port', dconf[:port],
            '--device', 0,
            '--type', 'hdd',
            '--medium', disk_path
          ]
        end
      end

      # Provisioning скрипт
      box.vm.provision "shell", path: "scripts/provision.sh", env: {
        RAID_LEVEL: MACHINES[:otuslinux][:raid_level],
        RAID_DEVICES: MACHINES[:otuslinux][:raid_devices]
      }


      box.vm.provision "shell", inline: <<-SHELL
        # Настройка SSH для root
        mkdir -p /root/.ssh
        cp /home/vagrant/.ssh/authorized_keys /root/.ssh/

      SHELL
    end
  end

  # Синхронизация с использованием rsync
  config.vm.synced_folder "scripts", "/home/vagrant/scripts", type: "rsync", rsync__auto: true

end
