define ipa::automount::map (
  $ensure,
  $location = 'default',
  $indirect = false,
  $mount_location = undef,
  $parent_map = undef,
)
{
  if $ensure == 'present' {
    if $indirect == false {
      exec {"automountmap-$name":
        command => "ipa automountmap-add $location $name",
        unless  => "ipa automountmap-show $location $name > /dev/null 2>&1",
      }
    } else {
      if $parent_map {
        $parentmap = "--parentmap=$parent_map"
      } else {
        $parentmap = ""
      }
        
      exec {"automountmap-$name":
        command => "ipa automountmap-add-indirect $location $name --mount=$mount_location $parentmap",
        unless  => "ipa automountmap-show $location $name > /dev/null 2>&1",
      }

    } else {
      exec {"automountmap-remove-$name":
        command => "ipa automountmap-del $location $name",
        onlyif  => "ipa automountmap-show $location $name > /dev/null 2>&1",
      }
  }
}
