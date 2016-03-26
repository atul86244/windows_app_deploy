#
# Cookbook Name:: windows_app_deploy
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'windows_app_deploy::install'

# Create the Release folder
directory node['windows_app_deploy']['release_folder_path'] do
  rights :write, 'Administrator'
  action :create
  recursive true
  inherits true
end

manifest_location = "#{node['windows_app_deploy']['release_folder_path']}/#{node['windows_app_deploy']['manifest_name']}"
application_parameter_file_location = "#{node['windows_app_deploy']['release_folder_path']}/File_name"

# Download the manifest from nexus
remote_file manifest_location do
  rights :read, 'Administrator'
  source node['windows_app_deploy']['manifest_url']
end

# Download the Application Parameter file
remote_file application_parameter_file_location do
  rights :read, "Administrator"
  source node['windows_app_deploy']['application_parameter_url']
end

# Read the manifest and obtain the MSI path and version
msi_data = read_manifest(manifest_location)

# Download MSIs
msi_data.each do | msi |
	
	# Download MSI
	remote_file "#{node['windows_app_deploy']['release_folder_path']}/#{msi['msi_name']}" do
	  rights :full_control, "Administrator"
	  source msi['msi_url']
	end
	
	# Read the registry name from the Application Parameter
	registry_name = read_registry_name(application_parameter_file_location, msi['component_name'])
    
    # Get current version number from Registry 
    installed_version = registry_get_values(("HKEY_LOCAL_MACHINE\\Software\\Wow6432Node\\Tesco\\#{registry_name}", :machine).at(0)[:data]
    
	# Compare Version
	msi_version = msi['version']
    
    if installed_version.to_s == msi_version.to_s
	  # Archive MSI if versions are same
      file "#{node['windows_app_deploy']['release_folder_path']}/#{msi['msi_name']}" do
        action :delete
      end
    else
      # Install MSI	
      package msi['component_name'] do
        action :install
        source "#{node['windows_app_deploy']['release_folder_path']}/#{msi['msi_name']}"
        provider Chef::Provider::Package::Windows
      end
    end
end








