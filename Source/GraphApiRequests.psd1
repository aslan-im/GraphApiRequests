﻿#
# Module manifest for module 'GraphApiRequests'
#
# Generated by: Aslan Imanalin
#
# Generated on: 09.08.2021
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule = "GraphApiRequests.psm1"

    # Version number of this module.
    ModuleVersion = '0.1.20'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID = '40d5ebc0-d232-463c-bc2d-d56795ce1b59'

    # Author of this module
    Author = 'Aslan Imanalin'

    # Company or vendor of this module
    CompanyName = ''

    # Copyright statement for this module
    Copyright = '(c) 2021 Aslan Imanalin. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Module for GraphApi requests invocation.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @('Invoke-GraphApiRequest','Get-GraphDeviceAuthToken','Get-GraphToken')

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @('Invoke-GraphApiRequest','Get-GraphDeviceAuthToken','Get-GraphToken')

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    FileList = @(
        ".\Private\Get-GraphDeviceAuthCode.ps1",
        ".\Private\New-GraphAuthFormWindow.ps1",
        ".\Public\Get-GraphToken.ps1",
        ".\Public\Get-GraphDeviceAuthToken.ps1",
        ".\Public\Invoke-GraphApiRequest.ps1"
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('GraphAPI','Microsoft365','SharepointOnline','ExchangeOnline','Teams','AzureActiveDirectory','AzureAD','MicrosoftEndpointManager','Intune')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/aslan-im/GraphApiRequests/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/aslan-im/GraphApiRequests'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/aslan-im/GraphApiRequests/blob/main/README.md'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    HelpInfoURI = 'https://github.com/aslan-im/GraphApiRequests/blob/main/README.md'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}