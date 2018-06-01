function Get-F5iRule
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'OnlyGetiRulesRequested'
    )]
    param
    (
        # Name of iRule to get
        [Parameter(
            ParameterSetName = 'OnlyGetiRulesRequested'
        )]
        [string[]]$Name,
        
        # Switch to get all iRules
        [Parameter(            
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetiRules'
        )]
        [switch]$GetiRules
    )
    begin
    {
        Test-F5Session
    }
    process
    {
        $errorAction = $ErrorActionPreference        
        if ($PSBoundParameters["ErrorAction"])
        {
            $errorAction = $PSBoundParameters["ErrorAction"]
        }

        if ($PSBoundParameters['GetiRules'])
        {
            [F5iRule]::GetiRules($script:F5Session)
        }
        else
        {
            foreach ($iRule in $Name)
            {                
                [F5iRule]::GetiRule($iRule, $script:F5Session)
            }
        }        
    }
    end
    {
    }
}

