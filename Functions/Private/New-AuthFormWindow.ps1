function New-AuthFormWindow {
    [CmdletBinding()]
    param (     
    )
    Add-Type -AssemblyName System.Windows.Forms
    
    $Form = New-Object -TypeName System.Windows.Forms.Form -Property @{ Width = 440; Height = 640 }
    $Web = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{ Width = 440; Height = 600; Url = "https://www.microsoft.com/devicelogin" }
    
    $Web.Add_DocumentCompleted($DocComp)
    $Web.DocumentText
    
    $Form.Controls.Add($Web)
    $Form.Add_Shown({ $Form.Activate()})
    $Web.ScriptErrorsSuppressed = $true
    
    $Form.AutoScaleMode = 'Dpi'
    $Form.Text = "Graph API Authentication"
    $Form.ShowIcon = $False
    $Form.AutoSizeMode = 'GrowAndShrink'
    $Form.StartPosition = 'CenterScreen'
    
    $Form.ShowDialog() | Out-Null
}