Function Test-RegistryValueExist ($regkey, $name) {
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-itemproperty
    if (Get-ItemProperty -Path $regkey -Name $name -ErrorAction Ignore) {
        $true
    }
    else {
        $false
    }
}

Function Test-RegistryValueExistNot ($regkey, $name) {
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-itemproperty
    if (Get-ItemProperty -Path $regkey -Name $name -ErrorAction Ignore) {
        $false
    }
    else {
        $true
    }
}

Function Test-RegistryKeyExist ($regkey) {
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path
    if ((Test-Path -LiteralPath $regkey) -eq $true) {
        $true
    }
    else {
        $false
    }
}

Function Test-RegistryKeyExistNot($regkey) {
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path
    if ((Test-Path -LiteralPath $regkey) -eq $false) {
        $true
    }
    else {
        $false
    }
}
