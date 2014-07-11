


#Just use the first redis node found
redis_node = search(:node, "role:redis_server_new AND chef_environment:#{node.chef_environment}")[0]

if redis_node then
    node.override["redisio"]["sentinels"] = [{
          :sentinel_port => '26379',
          :name => 'kotr',
          :master_ip => redis_node['fqdn'],
          :master_port => 6379
        }]

    include_recipe "redisio::sentinel"
    include_recipe "redisio::sentinel_enable"
end

execute "restart_sentinel" do
  command "sudo /etc/init.d/redis_sentinel_kotr restart"
end
