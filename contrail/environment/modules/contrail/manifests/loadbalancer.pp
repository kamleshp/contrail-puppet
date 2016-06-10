class contrail::loadbalancer (
) {
    contrail::lib::report_status { 'loadbalancer_started': } ->
    Class['::contrail::loadbalancer::install'] ->
    Class['::contrail::loadbalancer::config'] ~>
    Class['::contrail::loadbalancer::service'] ->
    contrail::lib::report_status { 'loadbalancer_completed': }
    contain ::contrail::loadbalancer::install
    contain ::contrail::loadbalancer::config
    contain ::contrail::loadbalancer::service
}

