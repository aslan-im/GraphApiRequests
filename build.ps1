param (
    [ValidateSet("Release", "debug")]$Configuration = "debug",
    [Parameter(Mandatory=$false)][String]$NugetAPIKey,
    [Parameter(Mandatory=$false)][Switch]$ExportAlias
)

task Init {
    Write-Verbose -Message "Initializing Module PSScriptAnalyzer"
    if (-not(Get-Module -Name PSScriptAnalyzer -ListAvailable )){
        Write-Warning "Module 'PSScriptAnalyzer' is missing or out of date. Installing module now."
        Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
    }

    Write-Verbose -Message "Initializing Module Pester"
    if (-not(Get-Module -Name Pester -ListAvailable)){
        Write-Warning "Module 'Pester' is missing or out of date. Installing module now."
        Install-Module -Name Pester -Scope CurrentUser -Force
    }
    else{
        $RequiredPesterVersion = New-Object -TypeName System.Version -ArgumentList "5.3.1"
        $PesterVersion = (Get-Module -Name Pester -ListAvailable | Sort-object Version -Descending)[0].Version
        if($PesterVersion -lt  $RequiredPesterVersion){
            Install-Module -Name Pester -Scope CurrentUser -Force
        }
    }

    Write-Verbose -Message "Initializing platyPS"
    if (-not(Get-Module -Name platyPS -ListAvailable)){
        Write-Warning "Module 'platyPS' is missing or out of date. Installing module now."
        Install-Module -Name platyPS -Scope CurrentUser -Force
    }

    Write-Verbose -Message "Initializing PowerShellGet"
    if (-not(Get-Module -Name PowerShellGet -ListAvailable)){
        Write-Warning "Module 'PowerShellGet' is missing or out of date. Installing module now."
        Install-Module -Name PowerShellGet -Scope CurrentUser -Force
    }
}

task Test {
    Write-Verbose -Message "Running Pester Tests"
    $Results = Invoke-Pester -Script ".\Tests\*.Tests.ps1" -OutputFormat NUnitXml -OutputFile ".\Tests\TestResults.xml"
    if($Results.FailedCount -gt 0){
        throw "$($Results.FailedCount) Tests failed"
    }
}

task DebugBuild -if ($Configuration -eq "debug") {
    $Script:ModuleName = (Test-ModuleManifest -Path ".\Source\*.psd1").Name
    Write-Verbose $ModuleName
    if(Test-Path ".\Output\temp\$($ModuleName)") {
        Write-Verbose -Message "Output temp folder does exist, continuing build."

    }
    else {
        Write-Verbose -Message "Output temp folder does not exist. Creating it now"
        New-Item -Path ".\Output\temp\$($ModuleName)" -ItemType Directory -Force
    }

    if(!($ModuleVersion)) {
        Write-Verbose -Message "No new ModuleVersion was provided, locating existing version from psd file."
        $ModuleVersion = (Test-ModuleManifest -Path ".\Source\$($ModuleName).psd1").Version
        $ModuleVersion = "$($ModuleVersion.Major).$($ModuleVersion.Minor).$($ModuleVersion.Build)"
        Write-Verbose "ModuleVersion found from psd file: $ModuleVersion"
    }

    if(Test-Path ".\Output\temp\$($ModuleName)\$($ModuleVersion)"){
        Write-Warning -Message "Version: $($ModuleVersion) - folder was detected in .\Output\temp\$($ModuleName). Removing old temp folder."
        Remove-Item ".\Output\temp\$($ModuleName)\$($ModuleVersion)" -Recurse -Force
    }

    Write-Verbose -Message "Creating new temp module version folder: .\Output\temp\$($ModuleName)\$($ModuleVersion)."
    try {
        New-Item -Path ".\Output\temp\$($ModuleName)\$($ModuleVersion)" -ItemType Directory
    }
    catch {
        throw "Failed creating the new temp module folder: .\Output\temp\$($ModuleName)\$($ModuleVersion)"
    }

    Write-Verbose -Message "Generating the Module Manifest for temp build and generating new Module File"
    try {
        Copy-Item -Path ".\Source\$($ModuleName).psd1" -Destination ".\Output\temp\$($ModuleName)\$ModuleVersion\"
        New-Item -Path ".\Output\temp\$($ModuleName)\$ModuleVersion\$($ModuleName).psm1" -ItemType File
    }
    catch {
        throw "Failed copying Module Manifest from: .\Source\$($ModuleName).psd1 to .\Output\temp\$($ModuleName)\$ModuleVersion\ or Generating the new psm file."
    }

    Write-Verbose -Message "Updating Module Manifest with Public Functions"
    $publicFunctions = Get-ChildItem -Path ".\Source\Public\*.ps1"
    $privateFunctions = Get-ChildItem -Path ".\Source\Private\*.ps1"
    try {
        Write-Verbose -Message "Appending Public functions to the psm file"
        $functionsToExport = New-Object -TypeName System.Collections.ArrayList
        foreach($function in $publicFunctions.Name){
            write-Verbose -Message "Exporting function: $(($function.split('.')[0]).ToString())"
            $functionsToExport.Add(($function.split('.')[0]).ToString())
        }
        Update-ModuleManifest -Path ".\Output\temp\$($ModuleName)\$($ModuleVersion)\$($ModuleName).psd1" -FunctionsToExport $functionsToExport
    }
    catch {
        throw "Failed updating Module manifest with public functions"
    }
    $ModuleFile = ".\Output\temp\$($ModuleName)\$($ModuleVersion)\$($ModuleName).psm1"
    Write-Verbose -Message "Building the .psm1 file"
    Write-Verbose -Message "Appending Public Functions"
    Add-Content -Path $ModuleFile -Value "### --- PUBLIC FUNCTIONS --- ###"
    foreach($function in $publicFunctions.Name){
        try {
            Write-Verbose -Message "Updating the .psm1 file with function: $($function)"
            $content = Get-Content -Path ".\Source\Public\$($function)"
            Add-Content -Path $ModuleFile -Value "#Region - $function"
            Add-Content -Path $ModuleFile -Value $content
            if($ExportAlias.IsPresent){
                $AliasSwitch = $false
                $Sel = Select-String -Path ".\Source\Public\$($function)" -Pattern "CmdletBinding" -Context 0,1
                $mylist = $Sel.ToString().Split([Environment]::NewLine)
                foreach($s in $mylist){
                    if($s -match "Alias"){
                        $alias = (($s.split(":")[2]).split("(")[1]).split(")")[0]
                        Write-Verbose -Message "Exporting Alias: $($alias) to Function: $($function)"
                        Add-Content -Path $ModuleFile -Value "Export-ModuleMember -Function $(($function.split('.')[0]).ToString()) -Alias $alias"
                        $AliasSwitch = $true
                    }
                }
                if($AliasSwitch -eq $false){
                    Write-Verbose -Message "No alias was found in function: $($function))"
                    Add-Content -Path $ModuleFile -Value "Export-ModuleMember -Function $(($function.split('.')[0]).ToString())"
                }
            }
            else {
                Add-Content -Path $ModuleFile -Value "Export-ModuleMember -Function $(($function.split('.')[0]).ToString())"
            }
            Add-Content -Path $ModuleFile -Value "#EndRegion - $function"            
        }
        catch {
            throw "Failed adding content to .psm1 for function: $($function)"
        }
    }

    Write-Verbose -Message "Appending Private functions"
    Add-Content -Path $ModuleFile -Value "### --- PRIVATE FUNCTIONS --- ###"
    foreach($function in $privateFunctions.Name){
        try {
            Write-Verbose -Message "Updating the .psm1 file with function: $($function)"
            $content = Get-Content -Path ".\Source\Private\$($function)"
            Add-Content -Path $ModuleFile -Value "#Region - $function"
            Add-Content -Path $ModuleFile -Value $content
            Add-Content -Path $ModuleFile -Value "#EndRegion - $function"            
        }
        catch {
            throw "Failed adding content to .psm1 for function: $($function)"
        }
    }
}

task Build -if($Configuration -eq "Release"){
    $Script:ModuleName = (Test-ModuleManifest -Path ".\Source\*.psd1").Name
    $publicFunctions = Get-ChildItem -Path ".\Source\Public\*.ps1"
    $privateFunctions = Get-ChildItem -Path ".\Source\Private\*.ps1"
    Write-Verbose $ModuleName
    if(Test-Path ".\Output\$($ModuleName)") {
        Write-Verbose -Message "Output folder does exist, continuing build."
    }
    else {
        Write-Verbose -Message "Output folder does not exist. Creating it now"
        New-Item -Path ".\Output\$($ModuleName)" -ItemType Directory -Force
    }

    if(!($ModuleVersion)) {
        Write-Verbose -Message "No new ModuleVersion was provided, locating existing version from psd file."
        $oldModuleVersion = (Test-ModuleManifest -Path ".\Source\$($ModuleName).psd1").Version
        $ModuleBuildNumber = $oldModuleVersion.Build + 1
        Write-Verbose -Message "Updating the Moduleversion"
        $Script:ModuleVersion = "$($oldModuleVersion.Major).$($oldModuleVersion.minor).$ModuleBuildNumber"
        Write-Verbose "Mew ModuleVersion: $ModuleVersion"
        Update-ModuleManifest -Path ".\Source\$($ModuleName).psd1" -ModuleVersion $ModuleVersion
    }

    if(Test-Path ".\Output\$($ModuleName)\$($ModuleVersion)"){
        Write-Warning -Message "Version: $($ModuleVersion) - folder was detected in .\Output\$($ModuleName). Removing old temp folder."
        Remove-Item ".\Output\$($ModuleName)\$($ModuleVersion)" -Recurse -Force
    }

    Write-Verbose -Message "Creating new temp module version folder: .\Output\$($ModuleName)\$($ModuleVersion)"
    if(Test-Path ".\Output\$($ModuleName)"){
        Write-Verbose -Message "Detected old folder, removing it from output folder"
        Remove-Item -Path ".\Output\$($ModuleName)" -Recurse -Force
    }
    try {
        New-Item -Path ".\Output\$($ModuleName)\$($ModuleVersion)" -ItemType Directory
    }
    catch {
        throw "Failed creating the new temp module folder: .\Output\$($ModuleName)\$($ModuleVersion)"
    }

    Write-Verbose -Message "Generating the Module Manifest for temp build and generating new Module File"
    try {
        Copy-Item -Path ".\Source\$($ModuleName).psd1" -Destination ".\Output\$($ModuleName)\$ModuleVersion\"
        New-Item -Path ".\Output\$($ModuleName)\$ModuleVersion\$($ModuleName).psm1" -ItemType File
    }
    catch {
        throw "Failed copying Module Manifest from: .\Source\$($ModuleName).psd1 to .\Output\$($ModuleName)\$ModuleVersion\ or Generating the new psm file."
    }

    Write-Verbose -Message "Updating Module Manifest with Public Functions"
    try {
        Write-Verbose -Message "Appending Public functions to the psm file"
        $functionsToExport = New-Object -TypeName System.Collections.ArrayList
        foreach($function in $($publicFunctions.Name)){
            write-Verbose -Message "Exporting function: $(($function.split('.')[0]).ToString())"
            $functionsToExport.Add(($function.split('.')[0]).ToString())
        }
        Update-ModuleManifest -Path ".\Output\$($ModuleName)\$($ModuleVersion)\$($ModuleName).psd1" -FunctionsToExport $functionsToExport -ErrorAction Stop
    }
    catch {
        Write-Output $($_.Exception | Select-object *)
        throw "Failed updating Module manifest with public functions"
    }
    
    $ModuleFile = ".\Output\$($ModuleName)\$($ModuleVersion)\$($ModuleName).psm1"
    Write-Verbose -Message "Building the .psm1 file"
    Write-Verbose -Message "Appending Public Functions"
    Add-Content -Path $ModuleFile -Value "### --- PUBLIC FUNCTIONS --- ###"
    foreach($function in $publicFunctions.Name){
        try {
            Write-Verbose -Message "Updating the .psm1 file with function: $($function)"
            $content = Get-Content -Path ".\Source\Public\$($function)"
            Add-Content -Path $ModuleFile -Value "#Region - $function"
            Add-Content -Path $ModuleFile -Value $content
            if($ExportAlias.IsPresent){
                $AliasSwitch = $false
                $Sel = Select-String -Path ".\Source\Public\$($function)" -Pattern "CmdletBinding" -Context 0,1
                $mylist = $Sel.ToString().Split([Environment]::NewLine)
                foreach($s in $mylist){
                    if($s -match "Alias"){
                        $alias = (($s.split(":")[2]).split("(")[1]).split(")")[0]
                        Write-Verbose -Message "Exporting Alias: $($alias) to Function: $($function)"
                        Add-Content -Path $ModuleFile -Value "Export-ModuleMember -Function $(($function.split('.')[0]).ToString()) -Alias $alias"
                        $AliasSwitch = $true
                    }
                }
                if($AliasSwitch -eq $false){
                    Write-Verbose -Message "No alias was found in function: $($function))"
                    Add-Content -Path $ModuleFile -Value "Export-ModuleMember -Function $(($function.split('.')[0]).ToString())"
                }
            }
            else {
                Add-Content -Path $ModuleFile -Value "Export-ModuleMember -Function $(($function.split('.')[0]).ToString())"
            }
            Add-Content -Path $ModuleFile -Value "#EndRegion - $function"            
        }
        catch {
            throw "Failed adding content to .psm1 for function: $($function)"
        }
    }

    Write-Verbose -Message "Appending Private functions"
    Add-Content -Path $ModuleFile -Value "### --- PRIVATE FUNCTIONS --- ###"
    foreach($function in $privateFunctions.Name){
        try {
            Write-Verbose -Message "Updating the .psm1 file with function: $($function)"
            $content = Get-Content -Path ".\Source\Private\$($function)"
            Add-Content -Path $ModuleFile -Value "#Region - $function"
            Add-Content -Path $ModuleFile -Value $content
            Add-Content -Path $ModuleFile -Value "#EndRegion - $function"            
        }
        catch {
            throw "Failed adding content to .psm1 for function: $($function)"
        }
    }

    Write-Verbose -Message "Removing dotsource links"
    $ModuleFileContentWithDotSource = Get-Content $ModuleFile
    $ModuleFileContentWithoutDotSource = $ModuleFileContentWithDotSource -replace '\. \$PSScriptRoot\\.*\.ps1$'
    $ModuleFileContentWithoutDotSource | Out-File $ModuleFile

    Write-Verbose -Message "Updating Module Manifest with root module"
    try {
        Write-Verbose -Message "Updating the Module Manifest"
        Update-ModuleManifest -Path ".\Output\$($ModuleName)\$($ModuleVersion)\$($ModuleName).psd1" -RootModule "$($ModuleName).psm1"
    }
    catch {
        Write-Warning -Message "Failed appinding the rootmodule to the Module Manifest"
    }

    Write-Verbose -Message "Compiling Help files"
    Write-Verbose -Message "Importing the module to be able to output documentation"
    Try {
        Write-Verbose -Message "Importing the module to be able to output documentation"
        Import-Module ".\Output\$($ModuleName)\$ModuleVersion\$($ModuleName).psm1"
    }
    catch {
        throw "Failed importing the module: $($ModuleName)"
    }

    if(!(Get-ChildItem -Path ".\Docs")){
        Write-Verbose -Message "Docs folder is empty, generating new fiiles"
        if(Get-Module -Name $($ModuleName)) {
            Write-Verbose -Message "Module: $($ModuleName) is imported into session, generating Help Files"
            New-MarkdownHelp -Module $ModuleName -OutputFolder ".\Docs"
            New-MarkdownAboutHelp -OutputFolder ".\Docs" -AboutName $ModuleName
            New-ExternalHelp ".\Docs" -OutputPath ".\Output\$($ModuleName)\$($ModuleVersion)\en-US\"
        }
        else {
            throw "Module is not imported, cannot generate help files"
        }
    }
    else {
        Write-Verbose -Message "Removing old Help files, to generate new files."
        Remove-Item -Path ".\Docs\*.*" -Exclude "about_*"
        if(Get-Module -Name $($ModuleName)) {
            Write-Verbose -Message "Module: $($ModuleName) is imported into session, generating Help Files"
            New-MarkdownHelp -Module $ModuleName -OutputFolder ".\Docs"
            New-ExternalHelp ".\Docs" -OutputPath ".\Output\$($ModuleName)\$($ModuleVersion)\en-US\"
        }
    }


}


task Clean -if($Configuration -eq "Release") {
    if(Test-Path ".\Output\temp"){
        Write-Verbose -Message "Removing temp folders"
        Remove-Item ".\Output\temp" -Recurse -Force
    }
}

task Publish -if($Configuration -eq "Release"){

    Write-Verbose -Message "Publishing Module to PowerShell gallery"
    Write-Verbose -Message "Importing Module .\Output\$($ModuleName)\$ModuleVersion\$($ModuleName).psm1"
    Import-Module ".\Output\$($ModuleName)\$ModuleVersion\$($ModuleName).psm1"
    If((Get-Module -Name $ModuleName) -and ($NugetAPIKey)) {
        try {
            write-Verbose -Message "Publishing Module: $($ModuleName)"
            Publish-Module -Name $ModuleName -NuGetApiKey $NugetAPIKey
        }
        catch {
            throw "Failed publishing module to PowerShell Gallery"
        }
    }
    else {
        Write-Warning -Message "Something went wrong, couldn't publish module to PSGallery. Did you provide a NugetKey?."
    }
}

task . Init, Test, DebugBuild, Build, Clean 