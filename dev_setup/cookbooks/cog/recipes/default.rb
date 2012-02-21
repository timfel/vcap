# 
# Cookbook Name:: cog 
# Recipe:: default 
# 
# Copyright 2012, VMware 
# 
Chef::Log.debug("Installing ia32-libs for CogVM")
package "ia32-libs"

smalltalk_home = File.expand_path("~/smalltalk")
cogvm_url = "http://www.mirandabanda.org/files/Cog/VM/VM.r2522/coglinux.tgz"
squeak_image_url = "http://ftp.squeak.org/4.4/Squeak4.4-11860.zip"
squeak_sources_url = "http://ftp.squeak.org/sources_files/SqueakV41.sources.gz"

if not File.exists?(smalltalk_home)
  Dir.mkdir smalltalk_home
end

bash "Install CogVM from #{cogvm_url}" do
  code <<-BASH
    mkdir #{smalltalk_home}; cd #{smalltalk_home}
    curl #{cogvm_url} > CogVM.tgz
    tar xzf CogVM.tgz
    mv cog* cog
    rm CogVM.tgz
  BASH
  not_if { ::File.exists?(File.join(smalltalk_home, "cog")) }
end

bash "Install Squeak from #{squeak_image_url}" do
  code <<-BASH
    mkdir #{smalltalk_home}/squeak; cd #{smalltalk_home}/squeak
    curl #{squeak_image_url} > Squeak.zip
    unzip Squeak.zip; rm Squeak.zip
    curl -O #{squeak_sources_url}
    mv *.image Squeak.image
    mv *.changes Squeak.changes
    gunzip *.sources.gz
  BASH
  not_if { ::File.exists?(File.join(smalltalk_home, "squeak")) }
end

