# -*- mode: ruby -*-
# vi: set ft=ruby :

username = "rmanhart"
username = "#{ENV['USERNAME'] || `whoami`}"


require 'yaml'

dir = File.dirname(File.expand_path(__FILE__))
servers = YAML.load_file("#{dir}/config.yml")

Vagrant.configure("2") do |config|
  required_plugins = %w( vagrant-proxyconf vagrant-disksize vagrant-vbguest )
  _retry = false
  required_plugins.each do |plugin|
    unless Vagrant.has_plugin? plugin
      system "vagrant plugin install #{plugin}"
      _retry = true
    end
  end
  if (_retry)
    exec "vagrant " + ARGV.join(' ')
  end

  servers["vms"].each do |server|
    config.vm.define server["name"] do |srv|

      if Vagrant.has_plugin?("vagrant-vbguest")
        srv.vbguest.auto_update = true
        srv.vbguest.no_install = server["vbguest"]["no_install"]
        srv.vbguest.no_remote = false
      end

      srv.vm.box = "ubuntu/disco64"
	  srv.vm.boot_timeout = 9999

      if server["disk_resize"]["should_resize"]
        if Vagrant.has_plugin?("vagrant-disksize")
          srv.disksize.size = server["disk_resize"]["disksize"]
        end
      end

      if server["box_version"]
        srv.vm.box_version = server["box_version"]
      end

      if server["box_check_update"]
        srv.vm.box_check_update = server["box_check_update"]
      end

      srv.vm.provider :virtualbox do |vb|
        vb.name = server["name"]
        if server["gui"]
          vb.gui = server["gui"]
        end
		vb.gui = true
        vb.memory = server["ram"]
        vb.cpus = server["cpus"]
		vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
		vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end

      if server["ports"]
        server['ports'].each do |ports|
          srv.vm.network "forwarded_port",
                         guest: ports["guest"],
                         host: ports["host"]
        end
      end

      if server["syncDir"]
        server['syncDir'].each do |syncDir|
          srv.vm.synced_folder syncDir['host'],
                               syncDir['guest'],
                               create: true
        end
      end

      srv.vm.provision "shell" do |script|
        script.args = "#{username}"
		script.path = "provision.sh"
		
      end
    end
  end
end