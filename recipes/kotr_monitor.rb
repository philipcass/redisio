redis_node = search(:node, "role:redis_server_new AND chef_environment:#{node.chef_environment}")[0]
cache_node = search(:node, "role:cache_server_new AND chef_environment:#{node.chef_environment}")[0]
quigit_node = search(:node, "role:quigit_db AND chef_environment:#{node.chef_environment}")[0]

if redis_node and cache_node and quigit_node then
    node.override["redisio"]["sentinels"] = [{
          :sentinel_port => '26379',
          :name => 'kotr',
          :master_ip => redis_node['fqdn'],
          :master_port => 6379
        },{
          :sentinel_port => '26379',
          :name => 'cache',
          :master_ip => cache_node['fqdn'],
          :master_port => 6379
        },{
          :sentinel_port => '26379',
          :name => 'quigit',
          :master_ip => quigit_node['fqdn'],
          :master_port => 6379
        }]

    include_recipe "redisio::sentinel"
    include_recipe "redisio::sentinel_enable"
end

execute "restart_sentinel" do
  command <<-EOH
  sudo /etc/init.d/redis_sentinel_kotr stop && sudo /etc/init.d/redis_sentinel_kotr start &&
  sudo /etc/init.d/redis_sentinel_cache stop && sudo /etc/init.d/redis_sentinel_cache start &&
  sudo /etc/init.d/redis_sentinel_quigit stop && sudo /etc/init.d/redis_sentinel_quigit start
  EOH
end
