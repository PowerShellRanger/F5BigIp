function Get-F5Irule
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'OnlyGetIrulesRequested'
    )]
    param
    (
        # F5Name
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetIrulesRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllIrules'
        )]
        [string]$F5Name,

        # Token Based Authentication
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetIrulesRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllIrules'
        )]
        [string]$Token,

        # Name of iRule to get
        [Parameter(
            ParameterSetName = 'OnlyGetIrulesRequested'
        )]
        [string[]]$IruleName,
        
        # Switch to get all iRules
        [Parameter(            
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllIrules'
        )]
        [switch]$GetAllIrules
    )
    begin
    {
    }
    process
    {
        $errorAction = $ErrorActionPreference        
        if ($PSBoundParameters["ErrorAction"])
        {
            $errorAction = $PSBoundParameters["ErrorAction"]
        }

        $headers = @{
            'X-F5-Auth-Token' = $Token
        }
        if ($PSBoundParameters['GetAllIrules'])
        {
            $splatGetAllIrules = @{                    
                Headers     = $headers
                Method      = "GET"
                ContentType = "application/json"                
                Uri         = "https://$F5Name/mgmt/tm/ltm/rule"
                ErrorAction = $errorAction
            }
            Write-Verbose "Invoke Rest Method to: https://$F5Name/mgmt/tm/ltm/rule"
            (Invoke-RestMethod @splatGetAllIrules).items
        }
        else
        {
            foreach ($Irule in $IruleName)
            {                
                $splatGetIrules = @{                    
                    Headers     = $headers
                    Method      = "GET"
                    ContentType = "application/json"                
                    Uri         = "https://$F5Name/mgmt/tm/ltm/rule/~Common~$Irule"
                    ErrorAction = $errorAction
                }
                Write-Verbose "Invoke Rest Method to: https://$F5Name/mgmt/tm/ltm/rule/~Common~$Irule"
                Invoke-RestMethod @splatGetIrules
            }
        }        
    }
    end
    {
    }
}

