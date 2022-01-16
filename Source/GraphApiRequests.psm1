$Public  = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)

foreach ($Import in $Public) {
    try {
        . $Import.Fullname -ErrorAction Stop
    }
    catch {
        Write-Error -Message "Failed to import function $($Import.Fullname): $_" -ErrorAction Continue
    }
}

Export-ModuleMember -Function $Public.Basename