function Get-F5PoolMember
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding()]
    param
    (
        # F5Name
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [string]$F5Name,

        # Token Based Authentication
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [string]$Token,

        # Name of Pools to get Memebrs from
        [string]$PoolName
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
            
        $splatGetPoolMembers = @{                    
            Headers     = $headers
            Method      = "GET"
            ContentType = "application/json"                
            Uri         = "https://$F5Name/mgmt/tm/ltm/pool/~Common~$PoolName/members"
            ErrorAction = $errorAction
        }
        Write-Verbose "Invoke Rest Method to: https://$F5Name/mgmt/tm/ltm/pool/~Common~$PoolName/members"
        Invoke-RestMethod @splatGetPoolMembers
    }
    end
    {
    }
}

