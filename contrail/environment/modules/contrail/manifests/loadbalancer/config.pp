class contrail::loadbalancer::config (
  $loadbalancer_cidr = $::contrail::params::loadbalancer_cidr,
  $loadbalancer_method = $::contrail::params::loadbalancer_method,
  $internal_vip = $::contrail::params::internal_vip,
  $external_vip = $::contrail::params::external_vip,
  $contrail_internal_vip = $::contrail::params::contrail_internal_vip,
  $contrail_external_vip = $::contrail::params::contrail_external_vip
) {
    if ($loadbalancer_method == "bird") {
        # setup loopback interfaces for vips
        file { '/etc/contrail/set_interface_bird.py' :
                mode   => '0755',
                group  => root,
                source => "puppet:///modules/${module_name}/set_interface_bird.py"
        } ->
        exec { 'setup-interface-bird' :
                command   => "python set_interface_bird.py -i ${internal_vip} ${external_vip} ${contrail_internal_vip} ${contrail_external_vip} && echo setup_bird_interfaces >> /etc/contrail/contrail_setup_bird_interfaces_exec.out",
                unless    => 'grep -qx setup_bird_interfaces /etc/contrail/contrail_setup_bird_interfaces_exec.out',
                provider  => shell,
                logoutput => true,
        }
        file { '/etc/bird/bird.conf':
          ensure  => present,
          content => template("${module_name}/bird.conf.erb"),
        } 
    } 
}
