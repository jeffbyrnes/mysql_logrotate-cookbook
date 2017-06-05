if defined? ChefSpec
  def create_mysql_logrotate_agent(name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_logrotate_agent, :create, name)
  end

  def delete_mysql_logrotate_agent(name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_logrotate_agent, :delete, name)
  end
end
