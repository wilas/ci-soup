stage { "base": before => Stage["main"] }
stage { "last": require => Stage["main"] }

# basic config
class { "install_repos": stage => "base" }
class { "basic_package": stage => "base" }
class { "user::root": stage    => "base"}

# /etc/hosts
host { "$fqdn":
    ip           => "$ipaddress_eth1",
    host_aliases => "$hostname",
}

# firewall manage
service { "iptables":
    ensure => running,
    enable => true,
}
exec { 'clear-firewall':
    command     => '/sbin/iptables -F',
    refreshonly => true,
}
exec { 'persist-firewall':
    command     => '/sbin/iptables-save >/etc/sysconfig/iptables',
    refreshonly => true,
}
Firewall {
    subscribe => Exec['clear-firewall'],
    notify    => Exec['persist-firewall'],
}
class { "basic_firewall": }


# GIT
/*
class { "git": }
git::authorized_key { "elk":
    key => "AAAAB3NzaC1yc2EAAAABIwAAAQEAzklfofBRMF0doSKawOD0NQaq2z5VJUnsE3KNvEOln+l2BwHM2k2IdEXIfgR+BGUy+wz2wbDSiHVSEoqxX9tfnZSYxdI3IH8goNkkjdKy16r/cm/QEn5sSXgu0RowegTIKplFYU1CWNPlCViGXoUVatwEC2Byo9tz7/kMebQetAoeEMkRH0t/3pkgWqNHy8PDYUASp8PUnKUFcWhUyEokzfPxFllDBjdcMKpx6Iwk/iX/3LNmkXZvSQ6fbNj4a4oCKyx8BJBosUX/bopa0rhCZ6NGP0FHZsLZ9STO8fM5O921kMn7cDxe1MQwDTzvTl9ZJIfCzgZoySqHQ82JzR4nSQ==",
}
git::repo { "trout": 
    ensure => present,
}
*/

# GITOLITE
class {"gitolite3":}
# repos
gitolite3::repo { "blue":
    conf_file => "/vagrant/samples/repos_garden/blue.conf",
    ensure    => present,
}
gitolite3::repo { "red":
    conf_file => "/vagrant/samples/repos_garden/red.conf",
    ensure    => present,
    bare_src  => "/vagrant/samples/repos_garden/red.git",
}
gitolite3::repo { "green":
    conf_file => "/vagrant/samples/repos_garden/green.conf",
    ensure    => absent,
}
# users
gitolite3::guser { "redman":
    key_file => "/vagrant/samples/repos_garden/id_rsa.redman.pub",
    ensure   => present,
}

# GITWEB + GIT-DAEMON
class {"gitolite3::gitweb":}
firewall { "100 allow gitweb-apache":
    state  => ['NEW'],
    dport  => '80',
    proto  => 'tcp',
    action => accept,
}
firewall { "100 allow git-deamon":
    state  => ['NEW'],
    dport  => '9418',
    proto  => 'tcp',
    action => accept,
}