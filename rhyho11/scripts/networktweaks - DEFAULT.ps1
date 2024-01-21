Start-Transcript -Path "$Env:ProgramData\rhyho11\TCPOptimizer_DEFAULT.log" -Append | Out-Null

Import-Module "$Env:rhyho11\scripts\modules\Helper-Registry"

function Remove-NetSettings {
    param([string]$GUID)

    if (Test-RegistryValueExist "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" TcpAckFrequency) {
        Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" -Name TcpAckFrequency
    }

    if (Test-RegistryValueExistNot "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" TcpDelAckTicks) {
        Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" -Name TcpDelAckTicks
    }

    if (Test-RegistryValueExistNot "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" TCPNoDelay) {
        Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$GUID" -Name TCPNoDelay
    }
}

$randomGUID = (New-Guid).Guid

@"
Windows Registry Editor Version 5.00

; TCPSettings
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider]
"DnsPriority"=dword:000007d0
"HostsPriority"=dword:000001f4
"LocalPriority"=dword:000001f3
"NetbtPriority"=dword:000007d1

-[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\QoS]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile]
"NetworkThrottlingIndex"=dword:0000000a
"SystemResponsiveness"=dword:00000014

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters]
"Size"=-

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management]
"LargeSystemCache"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters]
"MaxUserPort"=-
"TcpTimedWaitDelay"=-
"DefaultTTL"=-

-[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSMQ\Parameters]

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER]
"explorer.exe"=dword:00000002
"iexplore.exe"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER]
"explorer.exe"=dword:00000004
"iexplore.exe"=-

; UDPIP Parameters
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters]

"NegativeCacheTime"=-
"NegativeSOACacheTime"=-
"NetFailureCacheTime"=-
"MaximumUdpPacketSize"=-

; TCPIP Parameters
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters]

"DefaultTTL"=-
"KeepAliveTime"=-
"MaxUserPort"=-
"QualifyingDestinationThreshold"=-
"SynAttackProtect"=-
"Tcp1323Opts"=-
"TcpCreateAndConnectTcbRateLimitDepth"=-
"TcpMaxDataRetransmissions"=-

; Networkadaptersettings
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0000]
"*FlowControl"="3"
"*TransmitBuffers"="512"
"*ReceiveBuffers"="256"
"*TCPChecksumOffloadIPv4"="3"
"*TCPChecksumOffloadIPv6"="3"
"*UDPChecksumOffloadIPv4"="3"
"*UDPChecksumOffloadIPv6"="3"
"*IPChecksumOffloadIPv4"="3"
"WaitAutoNegComplete"="2"
"ITR"="65535"
"*InterruptModeration"="1"
"*PriorityVLANTag"="3"
"EnablePME"="1"
"*LsoV2IPv4"="1"
"*LsoV2IPv6"="1"
"*JumboPacket"="1514"
"*SpeedDuplex"="0"
"MasterSlave"="0"
"*WakeOnPattern"="1"
"*WakeOnMagicPacket"="1"
"WakeOnLink"="0"
"*NumRssQueues"="2"
"EEELinkAdvertisement"="1"
"DMACoalescing"="0"
"*PMARPOffload"="1"
"*PMNSOffload"="1"
"@ | Out-File -FilePath $env:TEMP\$randomGUID.reg

reg import $env:TEMP\$randomGUID.reg

Remove-Item $env:TEMP\$randomGUID.reg

Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" | ForEach-Object {
    Remove-NetSettings (Get-ItemProperty -Path $_.PSPath -Name "ServiceName").ServiceName
}

Set-NetTCPSetting -SettingName internet -EcnCapability disabled `
    -Timestamps disabled `
    -MaxSynRetransmissions 4 `
    -NonSackRttResiliency disabled `
    -InitialRto 1000 `
    -MinRto 300 `
    -AutoTuningLevelLocal normal `
    -ScalingHeuristics disabled `
    -CongestionProvider CUBIC

Enable-NetAdapterLso -Name *
Enable-NetAdapterChecksumOffload -Name *

Set-NetOffloadGlobalSetting -ReceiveSegmentCoalescing enabled `
    -ReceiveSideScaling enabled `
    -Chimney disabled

Stop-Transcript | Out-Null