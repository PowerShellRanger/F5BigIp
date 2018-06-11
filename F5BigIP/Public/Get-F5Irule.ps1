function Get-F5iRule
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [OutputType(
        [F5iRule],
        [F5iRule[]]
    )]
    [CmdletBinding(
        DefaultParameterSetName = 'OnlyGetiRulesRequested'
    )]
    param
    (
        # Name of iRule to get
        [Parameter(
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
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
            [F5iRule]::GetiRules($Script:F5Session)
        }
        else
        {
            foreach ($iRule in $Name)
            {                
                [F5iRule]::GetiRule($iRule, $Script:F5Session)
            }
        }        
    }
    end
    {
    }
}

