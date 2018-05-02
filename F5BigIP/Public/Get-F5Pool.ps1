function Get-F5Pool
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'OnlyGetPoolsRequested'
    )]
    param
    (
        # F5Name
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetPoolsRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllPools'
        )]
        [string]$F5Name,

        # Token Based Authentication
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetPoolsRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllPools'
        )]
        [string]$Token,

        # Name of Certificates to get
        [Parameter(
            ParameterSetName = 'OnlyGetPoolsRequested'
        )]
        [string[]]$PoolName,
        
        # Switch to get all Certificates
        [Parameter(            
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllPools'
        )]
        [switch]$GetAllPools
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
        if ($PSBoundParameters['GetAllPools'])
        {
            $splatGetAllPools = @{                    
                Headers     = $headers
                Method      = "GET"
                ContentType = "application/json"                
                Uri         = "https://$F5Name/mgmt/tm/ltm/pool"
            }
            Write-Verbose "Invoke Rest Method to: https://$F5Name/mgmt/tm/ltm/pool"
            (Invoke-RestMethod @splatGetAllPools -ErrorAction $errorAction).items
        }
        else
        {
            foreach ($Pool in $PoolName)
            {                
                $splatGetPool = @{                    
                    Headers     = $headers
                    Method      = "GET"
                    ContentType = "application/json"                
                    Uri         = "https://$F5Name/mgmt/tm/ltm/pool/~Common~$Pool"
                }
                Write-Verbose "Invoke Rest Method to: https://$F5Name/mgmt/tm/ltm/pool/~Common~$Pool"
                Invoke-RestMethod @splatGetPool -ErrorAction $errorAction
            }
        }        
    }
    end
    {
    }
}

