def start_chef_zero
  @zero_pid = spawn('chef-zero')
  Process.detach(@zero_pid)
  @zero_pid
end

def stop_chef_zero
  Process.kill('HUP', @zero_pid)
end

def berks_install
  system('berks install && berks upload')
end

desc 'Run the test recipe locally'
task :test do
  start_chef_zero
  berks_install
  system("chef-client -c .chef/client.rb -o 'test::default'")
  stop_chef_zero
end
