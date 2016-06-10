# The profile to set up the endpoints, auth, and database for Glance
# Because of the include, api must come before auth if colocated
class openstack::profile::glance::auth {
  openstack::resources::controller { 'glance': }
  openstack::resources::database { 'glance': }
  $loadbalancer_ip_list = $::contrail::params::loadbalancer_ip_list

  if (size($loadbalancer_ip_list) != 0) {
    $keystone_public_address = $::contrail::params::keystone_public_address
    $keystone_internal_address = "localhost"
    $keystone_admin_address = "localhost"
    # this will not create endpoints as configure_endpoint is set false
    class  { '::glance::keystone::auth':
      configure_endpoint => false,
      password         => $::openstack::config::glance_password,
      public_address   => $keystone_public_address,
      admin_address    => $keystone_admin_address,
      internal_address => $keystone_internal_address,
      region           => $::openstack::config::region,
    }
    # now create endpoints
    $region = $::openstack::config::region
    $real_service_name = 'glance'

    keystone_endpoint { "${region}/${real_service_name}":
      ensure       => present,
      public_url   => "http://${keystone_public_address}:9292",
      admin_url    => "http://${keystone_admin_address}:9393",
      internal_url => "http://${keystone_internal_address}:9393",
    }
  } else {
    class  { '::glance::keystone::auth':
      password         => $::openstack::config::glance_password,
      public_address   => $::openstack::config::storage_address_api,
      admin_address    => $::openstack::config::storage_address_management,
      internal_address => $::openstack::config::storage_address_management,
      region           => $::openstack::config::region,
    }
  }
  include ::openstack::common::glance
}
