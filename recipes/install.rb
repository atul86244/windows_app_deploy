#
# Cookbook Name:: windows_app_deploy
# Recipe:: install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Install IIS
include_recipe 'iis'

# Install ASP.NET MVC 4.0


# Install 7-zip
package '7zip' do
  source 'http://www.7-zip.org/a/7z938-x64.msi'
  provider Chef::Provider::Package::Windows
end

# Install Fontware
