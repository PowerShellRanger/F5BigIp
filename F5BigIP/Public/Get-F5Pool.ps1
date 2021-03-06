function Get-F5Pool
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [OutputType(
        [F5Pool],
        [F5Pool[]]
    )]
    [CmdletBinding(
        DefaultParameterSetName = 'OnlyGetPoolsRequested'
    )]
    param
    (
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
        
        if ($PSBoundParameters['GetAllPools'])
        {
            Write-Verbose "Invoke Rest Method to: https://$($Script:F5Session.F5Name)/mgmt/tm/ltm/pool"
            [F5Pool]::GetAllNodes($Script:F5Session)
        }
        else
        {
            foreach ($pool in $PoolName)
            {                
                Write-Verbose "Invoke Rest Method to: https://$($Script:F5Session.F5Name)/mgmt/tm/ltm/pool/~Common~$pool"
                [F5Pool]::Get($pool, $Script:F5Session)
            }
        }        
    }
    end
    {
    }
}

