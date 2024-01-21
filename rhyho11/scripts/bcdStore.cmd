@echo off
bcdedit /set disabledynamictick yes
bcdedit /timeout 5
bcdedit /set nx OptIn
bcdedit /set bootux disabled
bcdedit /set bootmenupolicy legacy
bcdedit /set tscsyncpolicy Default
bcdedit /set quietboot yes
bcdedit /set {globalsettings} custom:16000067 true
bcdedit /set {globalsettings} custom:16000069 true
bcdedit /set {globalsettings} custom:16000068 true
bcdedit /set {current} description "rhyho11"
