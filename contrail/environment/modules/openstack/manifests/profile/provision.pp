# The puppet module to set up a Contrail Config server
class openstack::profile::provision {
    require ::openstack::profile::keystone

    $internal_vip = $::contrail::params::internal_vip
    $external_vip = $::contrail::params::external_vip
    $contrail_internal_vip = $::contrail::params::contrail_internal_vip
    $tenants = $::openstack::config::keystone_tenants
    $users   = $::openstack::config::keystone_users
    $contrail_external_vip = $::contrail::params::contrail_external_vip

    # if contrail_external_vip use it for public address for neutron
    # if contrail_internal_vip use it for internal/admin for neutron
    # if external_vip use it for public addr for openstack services
    # if internal_vip use it for internal/admin addr for openstack services
    # else first cfgm node
    $neutron_public_address = $::contrail::params::neutron_public_address
    $neutron_internal_address = $::contrail::params::neutron_internal_address
    $neutron_admin_address = $::contrail::params::neutron_admin_address
    $keystone_public_address = $::contrail::params::keystone_public_address
    $keystone_internal_address = $::contrail::params::keystone_internal_address
    $keystone_admin_address = $::contrail::params::keystone_admin_address
    class { 'keystone::endpoint':
      public_address   => $keystone_public_address,
      admin_address    => $keystone_admin_address,
      internal_address => $keystone_internal_address,
      region           => $::openstack::config::region,
    } ->
    class { '::keystone::roles::admin':
      email        => $::openstack::config::keystone_admin_email,
      password     => $::openstack::config::keystone_admin_password,
      admin_tenant => 'admin',
    } ->
    class { '::cinder::keystone::auth':
      password         => $::openstack::config::cinder_password,
      public_address   => $keystone_public_address,
      admin_address    => "localhost",
      internal_address => "localhost",
      region           => $::openstack::config::region,
    } ->
    class { '::openstack::profile::glance::auth':
    }
    class { '::nova::keystone::auth':
      password         => $::openstack::config::nova_password,
      public_address   => $keystone_public_address,
      admin_address    => $keystone_admin_address,
      internal_address => $keystone_internal_address,
      region           => $::openstack::config::region,
      cinder           => true,
    }
    class { '::neutron::keystone::auth':
      password         => $::openstack::config::neutron_password,
      public_address   => $neutron_public_address,
      admin_address    => $neutron_admin_address,
      internal_address => $neutron_internal_address,
      region           => $::openstack::config::region,
    }
    create_resources('openstack::resources::tenant', $tenants)
    create_resources('openstack::resources::user', $users)
}
