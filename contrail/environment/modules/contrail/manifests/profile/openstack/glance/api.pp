# The profile to install the Glance API and Registry services
# Note that for this configuration API controls the storage,
# so it is on the storage node instead of the control node
class contrail::profile::openstack::glance::api {
  $api_network = $::openstack::config::network_api
  $api_address = ip_for_network($api_network)

  $internal_vip = $::contrail::params::internal_vip
  $sync_db = $::contrail::params::sync_db
  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)

  $explicit_management_address = $::openstack::config::storage_address_management
  $explicit_api_address = $::openstack::config::storage_address_api

  $controller_address = $::openstack::config::controller_address_management
  $openstack_rabbit_servers = $::contrail::params::openstack_rabbit_servers

  $host_roles = $::contrail::params::host_roles

  # if this is OS node use openstack_rabbit_server_list
  # if this is CFGM node use contrail_rabbit_server_list
  # if it is both use openstack_rabbit_server_list
  if ('openstack' in $host_roles) {
    $rabbit_host = $::contrail::params::openstack_rabbit_servers
    $rabbit_port = $::contrail::params::openstack_rabbit_port
  } else {
    $rabbit_host = $::contrail::params::contrail_rabbit_servers
    $rabbit_port = $::contrail::params::contrail_rabbit_port
  }

  include ::openstack::common::glance

  class { '::glance::backend::file': }

  if ($internal_vip != '' and $internal_vip != undef) {
    $database_idle_timeout = "180"
  } else {
    $database_idle_timeout = ""
  }

  class { '::glance::registry':
    keystone_password     => $::openstack::config::glance_password,
    sql_connection        => $::openstack::resources::connectors::glance,
    auth_host             => $::contrail::params::keystone_ip_to_use,
    keystone_tenant       => 'services',
    keystone_user         => 'glance',
    verbose               => $::openstack::config::verbose,
    debug                 => $::openstack::config::debug,
    database_idle_timeout => $database_idle_timeout,
    mysql_module          => '2.2',
    sync_db               => $sync_db,
  }
  class { '::glance::notify::rabbitmq':
    rabbit_password => $::openstack::config::rabbitmq_password,
    rabbit_userid   => $::openstack::config::rabbitmq_user,
    rabbit_host     => $rabbit_host,
    rabbit_port     => $rabbit_port,
  }
  contrail::lib::augeas_conf_rm { "registry_remove_idenity_uri":
      key => 'identity_uri',
      config_file => '/etc/glance/glance-registry.conf',
      lens_to_use => 'properties.lns',
  }
  contrail::lib::augeas_conf_rm { "api_remove_idenity_uri":
      key => 'identity_uri',
      config_file => '/etc/glance/glance-api.conf',
      lens_to_use => 'properties.lns',
  }
}
