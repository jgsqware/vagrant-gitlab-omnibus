#
# Cookbook Name:: gitlab-omnibus-dev
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

packages = ['curl', 'openssh-server', 'ca-certificates', 'postfix', 'git', 'emacs24-nox']


package packages do
  action :install
end

install_dir = "#{Chef::Config[:file_cache_path]}/gitlab-ce"

directory install_dir do
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  recursive true
end


connection_is_up = false

ruby_block "check sayc" do
  block do
    server = 'packages.gitlab.com'
    port = 80

    begin
      Timeout.timeout(5) do
        Socket.tcp(server,port){}
      end
      connection_is_up = true
      Chef::Log.info 'Connection open'
    rescue
      connection_is_up = false
      Chef::Log.fatal 'Connection timeout'
    end
  end
end

ruby_block "test" do
  block do
    p "CONNECTION::#{connection_is_up}"
  end
end

remote_file "#{install_dir}/script.deb.sh" do
  source 'https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh'
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  action :create
end unless !connection_is_up

bash 'install_repo_gitlab_ce' do
  cwd install_dir.to_s
  # user 'vagrant'
  # group 'vagrant'
  code <<-EOH
    ./script.deb.sh
    EOH
end unless !connection_is_up

apt_package 'gitlab-ce' do
  version '8.10.5-ce.0'
  action :install
  options '--force-yes'
end unless !connection_is_up

# sudo mv /opt/gitlab/embedded/cookbooks/gitlab /opt/gitlab/embedded/cookbooks/gitlab.$(date +%s)
remote_directory "/opt/gitlab/embedded/cookbooks/gitlab.#{Time.new.to_i}" do
  source "/opt/gitlab/embedded/cookbooks/gitlab"

end
