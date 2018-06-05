
class F5iRule
{        
    # iRule Kind
    [string]$Kind

    # iRule Name
    [string]$Name

    # iRule Partition
    [string]$Partition

    # iRule FullPath
    [string]$FullPath

    # iRule Generation
    [string]$Generation

    # iRule SelfLink
    [string]$SelfLink

    # iRule ApiAnonymous
    [string]$ApiAnonymous

    hidden [string]$Uri
  
    F5iRule () {}

    static [F5iRule[]] GetiRule([string[]]$iRuleName, [F5Session]$f5Session)
    {        
        $f5iRules = New-Object 'System.Collections.Generic.List[PSCustomObject]'
        foreach ($name in $iRuleName)
        {
            $_uri = "https://$($f5Session.F5Name)/mgmt/tm/ltm/rule/~Common~$name"

            $splatGetiRule = @{                    
                Headers     = $f5Session.Header
                Method      = "GET"
                ContentType = "application/json"                
                Uri         = $_uri                
            }
            Write-Verbose "Invoke Rest Method to: $_uri"
            $response = Invoke-RestMethod @splatGetiRule

            $iRule = [F5iRule]::New()
            $iRule.Kind = $response.Kind
            $iRule.Name = $response.Name
            $iRule.Partition = $response.Partition
            $iRule.FullPath = $response.FullPath
            $iRule.Generation = $response.Generation
            $iRule.SelfLink = $response.SelfLink
            $iRule.ApiAnonymous = $response.ApiAnonymous
            $iRule.Uri = $_uri

            [void]$f5iRules.Add($iRule)
        }
        return $f5iRules
    }

    static [F5iRule[]] GetiRules([F5Session]$f5Session)
    {
        $_uri = "https://$($f5Session.F5Name)/mgmt/tm/ltm/rule/"

        $splatGetiRules = @{                    
            Headers     = $f5Session.Header
            Method      = "GET"
            ContentType = "application/json"                
            Uri         = $_uri
        }
        Write-Verbose "Invoke Rest Method to: $_uri"
        $responses = Invoke-RestMethod @splatGetiRules

        $f5iRules = New-Object 'System.Collections.Generic.List[PSCustomObject]'
        foreach ($response in $responses.items)
        {
            $iRule = [F5iRule]::New()
            $iRule.Kind = $response.Kind
            $iRule.Name = $response.Name
            $iRule.Partition = $response.Partition
            $iRule.FullPath = $response.FullPath
            $iRule.Generation = $response.Generation
            $iRule.SelfLink = $response.SelfLink
            $iRule.ApiAnonymous = $response.ApiAnonymous
            $iRule.Uri = "$_uri~Common~$($response.Name)"

            [void]$f5iRules.Add($iRule)
        }
        return $f5iRules
    }

    [void] SetMaintenanceMode([MaintenanceMode]$maintenanceMode, [F5Session]$f5Session)
    {
        $currentMode = 'OFF'
        if ($maintenanceMode.MaintenanceMode -eq 'Off')
        {
            $currentMode = 'ON'
        }        

        $this.ApiAnonymous = $this.apiAnonymous -replace "#Maintenance\s+Options\s+OFF/ON`n\s+set\s+maint\s+`"$currentMode`"",
        "#Maintenance Options OFF/ON`n  set maint `"$($maintenanceMode.MaintenanceMode.ToUpper())`""

        $payload = [PSCustomObject] @{
            apiAnonymous = $this.ApiAnonymous
        }
        
        $body = $payload | ConvertTo-Json

        # Caused by a bug in ConvertTo-Json https://windowsserver.uservoice.com/forums/301869-powershell/suggestions/11088243-provide-option-to-not-encode-html-special-characte
        # '<', '>', ''' and '&' are replaced by ConvertTo-Json to \\u003c, \\u003e, \\u0027, and \\u0026. The F5 API doesn't understand this. Change them back.
        $replaceChars = @{
            '\\u003c' = '<'
            '\\u003e' = '>'
            '\\u0027' = "'"
            '\\u0026' = "&"
        }
        
        foreach ($char in $replaceChars.GetEnumerator()) 
        {
            $body = $body -replace $char.Key, $char.Value
        }
        
        $splatInvokeRestMethod = @{
            Uri         = $this.Uri
            ContentType = 'application/json'
            Method      = 'PATCH'
            Body        = $body
            Headers     = $f5Session.Header
            ErrorAction = 'Stop'
        }
        
        Write-Verbose "Invoke Rest Method to: $($this.Uri)"
        Invoke-RestMethod @splatInvokeRestMethod        
    }
}

class MaintenanceMode
{
    [ValidateSet('On', 'Off')]
    [string]$MaintenanceMode

    MaintenanceMode ([string]$maintenanceMode)
    {
        $this.MaintenanceMode = $maintenanceMode
    }
}