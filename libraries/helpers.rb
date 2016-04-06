 
 module WindowsAppDeploy
  module Helpers
    require 'rexml/document'
    include REXML

    def read_manifest( path )
      xmlfile = File.new(path)
      xmldoc = Document.new(xmlfile)
      msi = []

      # Extract msi path and version
      XPath.each(xmldoc, "//Component[@Name]") do |p|
        path = p.attributes["Path"]
        name = p.attributes["Name"]
        msi_path = "#{path}"
        msi_version = "#{path}".match(/(\d+.\d+.\d+.\d+).msi$/)[1]
        msi_name = "#{path}".split(/\\/).last
        msi_details = {
          "msi_url" => "#{msi_path}",
          "version" => "#{msi_version}",
          "msi_name" => "#{msi_name}",
          "component_name" => "#{name}"
        }
        msi.push(msi_details)
      end
      msi
    end

    def read_registry_name( path, component_name )

      xmlfile = File.new(path)
      xmldoc = Document.new(xmlfile)

      # Extract Registry name for provided component
      XPath.first(xmldoc, "//Component[@Name=\"#{component_name}\"]").attributes["Registry_Name"]
    end

    def get_app_settings( path )

      xmlfile = File.new(path)
      xmldoc = Document.new(xmlfile)
      app_settings = []

      # Extract msi path and version
      XPath.each(xmldoc, "//add[@key]") do |p|
        key = p.attributes["key"]
        value = p.attributes["value"]
        settings = {
          "key" => "#{key}",
          "value" => "#{value}"
        }
        app_settings.push(settings)  
      end
    end
  end
end

Chef::Recipe.send(:include, WindowsAppDeploy::Helpers)
Chef::Resource.send(:include, WindowsAppDeploy::Helpers)