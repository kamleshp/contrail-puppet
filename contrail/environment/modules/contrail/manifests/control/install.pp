class contrail::control::install() {
    package { 'contrail-openstack-control' :
        ensure => latest
    }
}
