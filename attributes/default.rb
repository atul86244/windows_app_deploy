
# IIS attributes
default['iis']['components'] = [ "NetFx4Extended-ASPNET45", "IIS-WebServerManagementTools", "IIS-ManagementConsole", "IIS-NetFxExtensibility45", "IIS-ASPNET45", "IIS-ManagementScriptingTools" ]

# Deployment specific details
default['windows_app_deploy']['provider_name'] = "RBC"
default['windows_app_deploy']['manifest_version'] = "8.0.0.4"
default['windows_app_deploy']['manifest_name'] = "ReleaseManifest_Acorn_UK_" + "#{node['windows_app_deploy']['provider_name']}" + "_" + "#{node['windows_app_deploy']['manifest_version']}.xml"
default['windows_app_deploy']['manifest_url'] = ""
default['windows_app_deploy']['application_parameter_url'] = ""
default['windows_app_deploy']['release_folder_path'] = "c:/release"