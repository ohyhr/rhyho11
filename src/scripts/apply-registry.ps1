param(
    [Parameter(Mandatory = $true)][ValidateSet(11)]
    [int]$winver
)

function Is-Admin() {
    $current_principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $current_principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Apply-Registry($file_path) {
    if (!(Test-Path $file)) {
        return 1
    }

    $user_merge_result = (Start-Process "reg.exe" -ArgumentList "import $($file_path)" -PassThru -Wait -WindowStyle Hidden).ExitCode
    $trustedinstaller_merge_result = [int](C:\bin\MinSudo.exe --NoLogo --TrustedInstaller --Privileged cmd /c "reg import $($file_path) > nul 2>&1 && echo 0 || echo 1")

    return $user_merge_result -band $trustedinstaller_merge_result
}

function main() {
    if (-not (Is-Admin)) {
        Write-Host "error: administrator privileges required"
        return 1
    }

    $hasErrors = $false

    Write-Host "info: please wait..."

    foreach ($file in @("11.reg")) {
        $file_name = $file.replace(".reg", "")
        $file = "C:\bin\registry\$($file)"
        $is_successful = 0

        if ([int]$file_name -eq $winver) {
            $is_successful = Apply-Registry -file_path $file
        }

        if ($is_successful -ne 0) {
            Write-Host "error: failed merging $($file)"
            $hasErrors = $true
        }
    }

    Write-Host "$(if ($hasErrors) {"error: failed"} else {"info: succeeded"}) merging registry settings for windows $($winver)"

    return [int]$hasErrors
}

exit main
