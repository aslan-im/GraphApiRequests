Import-Module Pester -Version 5.2.2

Invoke-Pester $PSScriptRoot\*.Tests.ps1 -Output Detailed