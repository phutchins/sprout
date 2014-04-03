package_zip = node['sprout']['apps']['alfred']['package_zip']
package_zip_checksum = node['sprout']['apps']['alfred']['package_zip_checksum']
package_source = node['sprout']['apps']['alfred']['package_source']
app_destination = node['sprout']['apps']['alfred']['app_destination']
downloaded_file = "#{Chef::Config[:file_cache_path]}/#{package_zip}"

remote_file downloaded_file do
  Chef::Log.info("Downloading file: #{File.join(package_source, package_zip)}")
  source File.join(package_source, package_zip)
  checksum package_zip_checksum
  notifies :run, "execute[extract_alfred]", :immediately
end

execute "extract_alfred" do
  Chef::Log.info("Extracting File: #{downloaded_file}")
  cwd app_destination
  command %{unzip -ou -d '#{app_destination}' '#{downloaded_file}'}
  action :nothing
  notifies :run, "execute[start_alfred]", :immediately
end

execute "check_alfred_running" do
  Chef::Log.info("Checking if Alfred is running...")
  command %{osascript -e 'if application "Alfred 2" is running then' -e 'return 0' -e 'end if'}
end

# Check to see if alfred needs to be launched before launching
execute "start_alfred" do
  Chef::Log.info("Starting Alfred")
  command %{osascript -e 'tell application "Alfred 2" to activate'}
  not_if { !node['sprout']['apps']['alfred']['launch_after_install'] && 'osascript -e \'if application "Alfred 2" is running then\' -e \'return 0\' -e \'end if\''}
  action :nothing
end
