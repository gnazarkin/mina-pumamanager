namespace :pumamanager do

  set :puma_role,         -> { user }
  set :puma_app_list,     "/etc/puma.conf"
  set :upstart_dir,       "/etc/init"

  desc 'Setup puma-manager'
  task :setup => :environment do
    command %(echo "-----> Setup the puma-manager")

    puma_conf_content = erb(puma_conf_template).gsub(/(["$])/){"\\#{$1}"}
    puma_conf_temp = "#{deploy_to}/#{shared_path}/puma.conf"
    command %[
      if [ -e '#{upstart_dir}/puma.conf' ]; then
        echo '#{upstart_dir}/puma.conf is existed!';
      else
        echo "#{puma_conf_content}" > #{puma_conf_temp}
        sudo cp #{puma_conf_temp} #{upstart_dir}
      fi
    ]

    puma_manager_conf_content = erb(puma_manager_conf_template).gsub(/(["$])/){"\\#{$1}"}
    puma_manager_conf_temp = "#{deploy_to}/#{shared_path}/puma-manager.conf"
    command %[
      if [ -e '#{upstart_dir}/puma_manager.conf' ]; then
        echo '#{upstart_dir}/puma_manager.conf is existed!';
      else
        echo "#{puma_manager_conf_content}" > #{puma_manager_conf_temp}
        sudo cp #{puma_manager_conf_temp} #{upstart_dir}
      fi
    ]

    app_path = "#{deploy_to}/current"
    command %[
      if ! [ -e '#{puma_app_list}' ]; then
        sudo touch #{puma_app_list}
        sudo chmod o+rw #{puma_app_list}
      fi

      if ! grep -q #{app_path} #{puma_app_list}; then
        sudo echo #{app_path} >> #{puma_app_list}
      fi
    ]
  end

  task :start => :environment do
    command %(sudo start puma-manager)
  end

  task :stop => :environment do
    command %(sudo stop puma-manager)
  end

  task :restart => :environment do
    command %(sudo restart puma-manager)
  end

  private
  def puma_conf_template
    File.expand_path('../puma.conf.erb', __FILE__)
  end

  def puma_manager_conf_template
    File.expand_path('../puma-manager.conf.erb', __FILE__)
  end
end
