start-process -filepath python -argumentlist $PSScriptRoot\RebootModem.py
start-sleep -seconds 15
get-process -name iexplore | stop-process
get-process -name IEDriverServer| stop-process