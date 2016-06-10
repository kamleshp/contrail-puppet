class contrail::provision_encap_type (
    $contrail_logoutput = $::contrail::params::contrail_logoutput,
    $keystone_admin_user = $::contrail::params::keystone_admin_user,
    $keystone_admin_password = $::contrail::params::keystone_admin_password,
    $encap_priority = $::contrail::params::encap_priority,
    $api_server_ip = $::contrail::params::config_ip_to_use,
    $api_server_port = "8082"
) {
    exec { 'provision-encap-type' :
            command   => "python /opt/contrail/utils/provision_encap.py --api_server_ip \"${api_server_ip}\" --api_server_port \"${api_server_port}\" --admin_user \"${keystone_admin_user}\" --admin_password \"${keystone_admin_password}\" --encap_priority ${encap_priority} --oper add && echo provision-encap-type >> /etc/contrail/contrail_config_exec.out",
            unless    => 'grep -qx provision-encap-type /etc/contrail/contrail_config_exec.out',
            provider  => shell,
            logoutput => $contrail_logoutput,
    }
    ->
    notify { "executed provision_encap_type":; }
}

