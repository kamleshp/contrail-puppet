# == Class: contrail::profile::keepalived
# The puppet module to set up keepalived for contrail
#
# === Parameters:
#
# [*enable_module*]
#     Flag to indicate if profile is enabled. If true, the module is invoked.
#     (optional) - Defaults to true.
#
class contrail::profile::keepalived (
    $enable_module = $::contrail::params::enable_keepalived,
    $host_roles = $::contrail::params::host_roles,
    $ext_lb_method = $::contrail::params::loadbalancer_method,
    $loadbalancer_ip_list = $::contrail::params::loadbalancer_ip_list,
) {
    if (('loadbalancer' in $host_roles) and ($ext_lb_method == 'keepalived')) {
        notify { "External LB required installing keepalived AND ext_lb_method: ${ext_lb_method}: contrail_roles: ${contrail_roles}: loadbalancer_ip_list len is: ${loadbalancer_ip_list}":; } ->
        contrail::lib::report_status { 'keepalived_started': state => 'keepalived_started' } ->
        Class['::contrail::keepalived'] ->
        contrail::lib::report_status { 'keepalived_completed': state => 'keepalived_completed' }
        contain ::contrail::keepalived
    } elsif ($enable_module and ('config' in $host_roles or 'openstack' in $host_roles)
             and (size($loadbalancer_ip_list) == 0)) {
        notify { "ext_lb_method is $ext_lb_method":; } ->
        contrail::lib::report_status { 'keepalived_started': state => 'keepalived_started' } ->
        Class['::contrail::keepalived'] ->
        contrail::lib::report_status { 'keepalived_completed': state => 'keepalived_completed' }
        contain ::contrail::keepalived
    } elsif (((!('config' in $host_roles)) and ($contrail_roles['config'] == true)) or
             ((!('openstack' in $host_roles)) and ($contrail_roles['openstack'] == true)) 
            ) {
        notify { 'uninstalling keepalived':; } ->
        contrail::lib::report_status { 'uinstall_keepalived_started': state => 'uninstall_keepalived_started' } ->
        Class['::contrail::uninstall_keepalived'] ->
        contrail::lib::report_status { 'uninstall_keepalived_completed': state => 'uninstall_keepalived_completed' }
        contain ::contrail::uninstall_keepalived
    }
}
