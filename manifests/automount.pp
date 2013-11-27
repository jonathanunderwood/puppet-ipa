# Note that these are very rough and ready - these should be
# implemented properly as custom types. The challenge of that is
# parsing the output of the ipa commands in Ruby. Or, better, using
# the JSON interface.

define ipa::automount::location (
  $location_name,
  $ensure,
)
{
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  if $ensure == 'present' {
    exec {"automountlocation-$location_name":
      command => "runuser -l admin -c 'ipa automountlocation-add $location_name'",
      unless  => "runuser -l admin -c 'ipa automountlocation-show $location_name > /dev/null 2>&1'",
    }
  } else {
    exec {"automountlocation-remove-$location_name":
      command => "runuser -l admin -c 'ipa automountlocation-del $location_name'",
      onlyif  => "runuser -l admin -c 'ipa automountlocation-show $location_name > /dev/null 2>&1'",
    }
  }
}

define ipa::automount::map (
  $map_name,
  $ensure,
  $location = 'default',
  $indirect = false,
  $mount_location = undef,
  $parent_map = undef,
)
{
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  if $ensure == 'present' {
    if $indirect == false {
      exec {"automountmap-$map_name":
        command => "runuser -l admin -c 'ipa automountmap-add $location $map_name'",
        unless  => "runuser -l admin -c 'ipa automountmap-show $location $map_name > /dev/null 2>&1'",
      }
    } else {
      if $parent_map {
        $parentmap = "--parentmap=$parent_map"
      } else {
        $parentmap = ""
      }
        
      exec {"automountmap-$map_name":
        command => "runuser -l admin -c 'ipa automountmap-add-indirect $location $map_name --mount=$mount_location $parentmap'",
        unless  => "runuser -l admin -c 'ipa automountmap-show $location $map_name > /dev/null 2>&1'",
      }
    }
  } else {
    exec {"automountmap-remove-$map_name":
      command => "runuser -l admin -c 'ipa automountmap-del $location $map_name'",
      onlyif  => "runuser -l admin -c 'ipa automountmap-show $location $map_name > /dev/null 2>&1'",
    }
  }
}

define ipa::automount::key (
  $ensure,
  $location = 'default',
  $map,
  $key_name,
  $mount_info
)
{
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  if $ensure == 'present' {
    exec {"automountkey-$key_name":
      command => "runuser -l admin -c 'ipa automountkey-add $location $map --key=$key_name --info=$mount_info'",
      unless  => "runuser -l admin -c 'ipa automountkey-show $location $map --key=$key_name >/dev/null 2>&1'",
    }
  } else {
    exec {"automountkey-remove-$key_name":
      command => "runuser -l admin -c 'ipa automountkey-del $location $map --key=$key_name'",
      onlyif  => "runuser -l admin -c 'ipa automountkey-show $location $map --key=$key_name >/dev/null 2>&1'",
    }
  }
}
