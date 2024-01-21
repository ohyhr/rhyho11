Start-Transcript -Path "$Env:ProgramData\rhyho11\TCPOptimizer.log" -Append | Out-Null

Import-Module "$Env:rhyho11\scripts\modules\Helper-Registry"

function Set-NetSettings {
    param([string]$GUID)

    if (Test-RegistryValueExistNot "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" TcpAckFrequency) {
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" -Name TcpAckFrequency -Value 1
    }
    else {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" -Name TcpAckFrequency -Value 1
    }

    if (Test-RegistryValueExistNot "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" TcpDelAckTicks) {
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" -Name TcpDelAckTicks -Value 0
    }
    else {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" -Name TcpDelAckTicks -Value 0
    }

    if (Test-RegistryValueExistNot "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" TCPNoDelay) {
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" -Name TCPNoDelay -Value 1
    }
    else {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" -Name TCPNoDelay -Value 1
    }
}

$randomGUID = (New-Guid).Guid

@"
Windows Registry Editor Version 5.00

; TCPSettings
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider]
"LocalPriority"=dword:00000004
"HostsPriority"=dword:00000005
"DnsPriority"=dword:00000006
"NetbtPriority"=dword:00000007

[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\QoS]
"Do not use NLA"="1"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile]
"NetworkThrottlingIndex"=dword:ffffffff
"SystemResponsiveness"=dword:0

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters]
"Size"=dword:00000001

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management]
"LargeSystemCache"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters]
"MaxUserPort"=dword:0000fffe
"TcpTimedWaitDelay"=dword:0000001e
"DefaultTTL"=dword:00000040

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSMQ\Parameters]
"TCPNoDelay"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER]
"explorer.exe"=dword:0000000a
"iexplore.exe"=dword:0000000a

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER]
"explorer.exe"=dword:0000000a
"iexplore.exe"=dword:0000000a

; UDPIP Parameters
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters]

"NegativeCacheTime" = dword:00000000
"NegativeSOACacheTime" = dword:00000000
"NetFailureCacheTime" = dword:00000000
"MaximumUdpPacketSize" = dword:00001300

; TCPIP Parameters
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters]

"DefaultTTL" = dword:00000040
"KeepAliveTime" = dword:006ddd00
"MaxUserPort" = dword:0000fffe
"QualifyingDestinationThreshold" = dword:00000003
"SynAttackProtect" = dword:00000001
"Tcp1323Opts" = dword:00000001
"TcpCreateAndConnectTcbRateLimitDepth" = dword:00000000
"TcpMaxDataRetransmissions" = dword:00000005

; Networkadaptersettings
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0000]
"*FlowControl"="0"
"*TransmitBuffers"="2048"
"*ReceiveBuffers"="2048"
"*TCPChecksumOffloadIPv4"="0"
"*TCPChecksumOffloadIPv6"="0"
"*UDPChecksumOffloadIPv4"="0"
"*UDPChecksumOffloadIPv6"="0"
"*IPChecksumOffloadIPv4"="0"
"WaitAutoNegComplete"="0"
"ITR"="0"
"*InterruptModeration"="0"
"*PriorityVLANTag"="0"
"EnablePME"="0"
"*LsoV2IPv4"="0"
"*LsoV2IPv6"="0"
"*JumboPacket"="1514"
"*SpeedDuplex"="0"
"MasterSlave"="0"
"*WakeOnPattern"="0"
"*WakeOnMagicPacket"="0"
"WakeOnLink"="0"
"*NumRssQueues"="4"
"EEELinkAdvertisement"="0"
"DMACoalescing"="0"
"*PMARPOffload"="0"
"*PMNSOffload"="0"
"@ | Out-File -FilePath $env:TEMP\$randomGUID.reg

reg import $env:TEMP\$randomGUID.reg

Remove-Item $env:TEMP\$randomGUID.reg

Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" | ForEach-Object {
    Set-NetSettings (Get-ItemProperty -Path $_.PSPath -Name "ServiceName").ServiceName
}

Set-NetTCPSetting -SettingName internet -EcnCapability disabled `
    -Timestamps disabled `
    -MaxSynRetransmissions 2 `
    -NonSackRttResiliency disabled `
    -InitialRto 3000 `
    -MinRto 300 `
    -AutoTuningLevelLocal normal `
    -ScalingHeuristics disabled `
    -CongestionProvider CUBIC

Disable-NetAdapterLso -Name *
Disable-NetAdapterChecksumOffload -Name *

Set-NetOffloadGlobalSetting -ReceiveSegmentCoalescing disabled `
    -ReceiveSideScaling enabled `
    -Chimney disabled

Stop-Transcript | Out-Null