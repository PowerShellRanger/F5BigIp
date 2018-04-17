function Get-F5PoolMember
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
        [string[]]$PoolName
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
            
        $url = "https://$F5Name/mgmt/tm/ltm/pool/~Common~$PoolName/members"
        Write-Verbose "Invoke Rest Method to: $url"
        Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ContentType "application/json" -ErrorAction $errorAction
    }
    end
    {
    }
}

