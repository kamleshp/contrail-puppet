class contrail::profile::openstack::nova(
  $host_control_ip   = $::contrail::params::host_ip,
  $internal_vip      = $::contrail::params::internal_vip,
  $nova_password     = $::contrail::params::os_nova_password,
  $neutron_password  = $::contrail::params::os_neutron_password,
  $openstack_verbose = $::contrail::params::os_verbose,
  $openstack_debug   = $::contrail::params::os_debug,
  $region_name       = $::contrail::params::os_region,
  $allowed_hosts     = $::contrail::params::os_mysql_allowed_hosts,
  $rabbitmq_user     = $::contrail::params::os_rabbitmq_user,
  $rabbitmq_password = $::contrail::params::os_rabbitmq_password,
  $sync_db           = $::contrail::params::sync_db,
  $service_password  = $::contrail::params::os_mysql_service_password,
  $address_api       = $::contrail::params::os_controller_api_address ,
  $sriov_enable      = $::contrail::params::sriov_enable,
  $enable_ceilometer = $::contrail::params::enable_ceilometer,
  $contrail_internal_vip      = $::contrail::params::contrail_internal_vip,
  $openstack_rabbit_servers   = $::contrail::params::openstack_rabbit_ip_list,
  $neutron_shared_secret      = $::contrail::params::os_neutron_shared_secret,
  $storage_management_address = $::contrail::params::os_glance_mgmt_address,
  $controller_mgmt_address    = $::contrail::params::os_controller_mgmt_address,
) {

  $database_credentials = join([$service_password, "@", $host_control_ip],'')
  $keystone_db_conn = join(["mysql://nova:",$database_credentials,"/nova"],'')
  $auth_uri = "http://${controller_mgmt_address}:5000/"

  class {'::nova::db::mysql':
    password      => $service_password,
    allowed_hosts => $allowed_hosts,
  }

  $compute_ip_list = $::contrail::params::compute_ip_list
  $tmp_index = inline_template('<%= @compute_ip_list.index(@host_control_ip) %>')

  if ($tmp_index != nil and $tmp_index != undef and $tmp_index != "" ) {
    $contrail_is_compute = true
  } else {
    $contrail_is_compute = false
  }
  notify { "openstack::common::nova -contrail_is_compute  = $contrail_is_compute":;}
  notify { "openstack::common::nova - tmp_index = X$tmp_index X":;}
  notify { "openstack::common::nova - controller_mgmt_address = $controller_mgmt_address":; }

  if ($internal_vip != "" and $internal_vip != undef) {
    $neutron_ip_address = $controller_mgmt_address
    $vncproxy_port = '6999'
    $vncproxy_host = $host_control_ip
  } else {
    $neutron_ip_address = $::contrail::params::config_ip_list[0]
    $vncproxy_port = '5999'
    $vncproxy_host = $address_api
  }

#  $contrail_internal_vip = $::contrail::params::internal_vip
#  $external_vip = $::contrail::params::internal_vip
#  $contrail_external_vip = $::contrail::params::contrail_internal_vip

  class { '::nova':
    database_connection => $keystone_db_conn,
    glance_api_servers  => "http://${storage_management_address}:9292",
    memcached_servers   => ["${controller_mgmt_address}:11211"],
    rabbit_hosts        => $openstack_rabbit_servers,
    rabbit_userid       => $rabbitmq_user,
    rabbit_password     => $rabbitmq_password,
    verbose             => $openstack_verbose,
    debug               => $openstack_debug,
    notification_driver => "nova.openstack.common.notifier.rpc_notifier",
  }


  if ($enable_ceilometer) {
    $instance_usage_audit = 'True'
    $instance_usage_audit_period = 'hour'
  }

  class { '::nova::api':
    admin_password                       => $nova_password,
    auth_host                            => $controller_mgmt_address,
    enabled                              => 'true',
    neutron_metadata_proxy_shared_secret => $neutron_shared_secret,
    sync_db                              => $sync_db,
  }

  class { '::nova::vncproxy':
    host    => $vncproxy_host,
    enabled => 'true',
    port    => $vncproxy_port,
  }

  class { [
    'nova::scheduler',
    'nova::objectstore',
    'nova::consoleauth',
    'nova::conductor'
  ]:
    enabled => 'true',
  }

  # TODO: it's important to set up the vnc properly
  class { '::nova::compute':
    enabled                       => $contrail_is_compute,
    vnc_enabled                   => true,
    vncserver_proxyclient_address => $management_address,
    vncproxy_host                 => $address_api,
    instance_usage_audit          => $instance_usage_audit,
    instance_usage_audit_period  => $instance_usage_audit_period
  }

  #TODO make sure we have vif package

  class { '::nova::compute::neutron':
    libvirt_vif_driver => "nova_contrail_vif.contrailvif.VRouterVIFDriver"
  }

  class { '::nova::network::neutron':
    neutron_admin_password => $neutron_password,
    neutron_region_name    => $region_name,
    neutron_admin_auth_url => "http://${controller_mgmt_address}:35357/v2.0",
    neutron_url            => "http://${neutron_ip_address}:9696",
    vif_plugging_is_fatal  => false,
    vif_plugging_timeout   => '0',
  }

  notify { "sriov = ${sriov}":; }
  if ($sriov_enable) {
    file_line_after {
      'scheduler_default_filters':
        line   => 'scheduler_default_filters=PciPassthroughFilter',
        path   => '/etc/nova/nova.conf',
        after  => '^\s*\[DEFAULT\]';
      'scheduler_available_filters':
        line   => 'scheduler_available_filters=nova.scheduler.filters.pci_passthrough_filter.PciPassthroughFilter',
        path   => '/etc/nova/nova.conf',
        after  => '^\s*\[DEFAULT\]';
      'scheduler_available_filters2':
        line   => 'scheduler_available_filters=nova.scheduler.filters.all_filters',
        path   => '/etc/nova/nova.conf',
        after  => '^\s*\[DEFAULT\]';
    }
  }
}
