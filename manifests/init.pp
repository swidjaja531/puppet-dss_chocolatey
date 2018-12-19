# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include dss_chocolatey
class dss_chocolatey (
  $chocomgmt = undef,
) {
  # install and configure chocolatey if chocomgmt is true
  if $chocomgmt {
    $chocosrc = lookup('internal_choco_repo')

    #include chocolatey

    class { 'chocolatey':
      chocolatey_download_url       => $chocosrc,
      use_7zip                      => false,
      choco_install_timeout_seconds => 2700,
    }

    # Add choco source hosted internally on nexus
    chocolateysource { 'internal_chocolatey':
      ensure   => present,
      location => $chocosrc,
      priority => 1,
    }

    file { ['c:/programdata/chocolatey', 'c:/programdata/chocolatey/license']:
      ensure => directory,
    }

    file { 'c:/programdata/chocolatey/license/chocolatey.license.xml':
      ensure             => file,
      source             => 'puppet:///modules/dss_chocolatey/chocolatey.license.xml',
      source_permissions => ignore,
      require            => File['c:/programdata/chocolatey/license'],
    }

    package { [
      'chocolatey.extension',
      'chocolatey-core.extension',
    ]:
      ensure          => present,
      install_options => ['-pre'],
      provider        => chocolatey,
      require         => [
        Chocolateysource['internal_chocolatey'],
        File['c:/programdata/chocolatey/license/chocolatey.license.xml'],
      ],
    }

    # remove/disable community and licensed choco repos respectively to ensure packages
    # can only be retrieved from the internally repository
    chocolateysource { 'chocolatey':
      ensure   => absent,
      location => 'https://chocolatey.org/api/v2/',
    }

    chocolateysource { 'chocolatey.licensed':
      ensure   => disabled,
      user     => 'customer',
      password => '1234',
      priority => '10',
      require  => Package['chocolatey.extension'],
    }
  }
}
