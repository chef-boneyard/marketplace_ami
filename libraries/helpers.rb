# Some helpers
module MarketplaceAMIHelpers
  class << self
    def user_directories
      Etc::Passwd.each_with_object({}) do |user, memo|
        next if %w(halt sync shutdown).include?(user.name) ||
                user.shell =~ %r{(/sbin/nologin|/bin/false)}
        memo[user.name] = user.dir
      end
    end

    def system_ssh_keys
      %w(key key.pub dsa_key dsa_key.pub rsa_key.pub rsa_key).map do |key|
        "/etc/ssh/ssh_host_#{key}"
      end
    end

    def sudoers
      Dir['/etc/sudoers.d/*']
    end

    def cloud_init?(node)
      node['marketplace_ami']['controls']['cloud_init_enabled']
    end

    def default_user(node)
      node['marketplace_ami']['controls']['default_user']
    end

    def login_shell(node)
      node['marketplace_ami']['controls']['login_shell']
    end
  end
end
