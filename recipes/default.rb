#
# Cookbook Name:: windows_app_deploy
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'windows_app_deploy::install'

# Create the Release folder
directory node['windows_app_deploy']['release_folder_path'] do
  rights :write, 'Administrator'
  action :nothing
  recursive true
  inherits true
end.run_action(:create)

manifest_location = "#{node['windows_app_deploy']['release_folder_path']}/#{node['windows_app_deploy']['manifest_name']}"
application_parameter_file_location = "#{node['windows_app_deploy']['release_folder_path']}/File_name"

# Download the manifest from nexus
remote_file manifest_location do
  rights :read, 'Administrator'
  source node['windows_app_deploy']['manifest_url']
  action :nothing
end.run_action(:create)

# Download the Application Parameter file
remote_file application_parameter_file_location do
  rights :read, "Administrator"
  source node['windows_app_deploy']['application_parameter_url']
  action :nothing
end.run_action(:create)

# Read the manifest and obtain the MSI path and version
#node.default['windows_app_deploy']['msi_data'] = read_manifest(manifest_location)

msi_data = read_manifest(manifest_location)

puts msi_data

# Download MSIs
msi_data.each do | msi |
	
	# Download MSI
	remote_file "#{node['windows_app_deploy']['release_folder_path']}/#{msi['msi_name']}" do
	  rights :full_control, "Administrator"
	  source msi['msi_url']
	end
	
	# Read the registry name from the Application Parameter
	ruby_block 'read_registry_name' do
	  block do
	    node.run_state['registry_name'] = read_registry_name(application_parameter_file_location, msi['component_name'])
	    # Get current version number from Registry 
   		node.run_state['installed_version'] = registry_get_values("HKEY_LOCAL_MACHINE\\Software\\Wow6432Node\\Tesco\\#{node.run_state['registry_name']}", :machine).at(0)[:data]

		# Compare Version
		node.run_state['msi_version'] = msi['version']
	  end
	end
    
	# Archive MSI if versions are same
    file "#{node['windows_app_deploy']['release_folder_path']}/#{msi['msi_name']}" do
      action :delete
      only_if { node.run_state['installed_version'] == node.run_state['msi_version'] }
    end
    
    # Install MSI	
    package msi['component_name'] do
      action :install
      source "#{node['windows_app_deploy']['release_folder_path']}/#{msi['msi_name']}"
      provider Chef::Provider::Package::Windows
      not_if { node.run_state['installed_version'] == node.run_state['msi_version'] }
    end
end

# Update web.config
template "D:\\Tesco.com\\RBCWebSite\\Web.config" do
  source 'Web.config.erb'
  variables({
  	:app_settings => get_app_settings(application_parameter_file_location)
  })
end









