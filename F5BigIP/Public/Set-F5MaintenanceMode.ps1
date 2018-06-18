function Set-F5MaintenanceMode
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        SupportsShouldProcess, 
        ConfirmImpact = "High"
    )]
    param
    (
        # Name of iRule
        [Parameter(
            Mandatory,
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName           
        )]
        [string[]]$Name,

        # MaintenanceMode On/Off
        [Parameter(
            Mandatory,
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName            
        )]
        [ValidateSet('On', 'Off')]
        [string]$MaintenanceMode        
    )
    begin
    {
        Test-F5Session
    }
    process
    {
        foreach ($iRuleName in $Name)
        {
            if ($PSCmdlet.ShouldProcess("Set Maintenance Mode '$MaintenanceMode' for iRule: $iRuleName"))
            {
                $errorAction = $ErrorActionPreference        
                if ($PSBoundParameters["ErrorAction"])
                {
                    $errorAction = $PSBoundParameters["ErrorAction"]
                }

                $iRule = Get-F5iRule -Name $iRuleName

                if (-not $iRule)
                {
                    Write-Warning "iRule: $iRuleName was not found on F5: $($Script:F5Session.F5Name)."
                    continue
                }

                try 
                {
                    Write-Verbose "Trying to set Maintenance Mode '$MaintenanceMode' for iRule: $iRuleName"
                    $iRule.SetMaintenanceMode($MaintenanceMode, $Script:F5Session)
                }
                catch
                {
                    throw $_
                }
            }        
        }        
    }
    end
    {
    }
}

