function Update-F5PoolMember
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        SupportsShouldprocess,
        ConfirmImpact = "High"
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

        # Name of pool adding member to
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]        
        [string]$PoolName,

        #Members of pool to add
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]        
        [pscustomobject]$Members   
    )
    begin
    {
    }
    process
    {
        if ($PSCmdlet.Shouldprocess("Updates pool: $PoolName on F5: $F5Name"))
        {         
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            $headers = @{
                'X-F5-Auth-Token' = $Token
            }

            $poolInfo = [pscustomobject]@{
                members = @(                
                )
            }
            foreach ($member in $Members)
            {
                $poolInfo.members += $member
            }
            $poolInfo         
            $poolInfo = $poolInfo | ConvertTo-Json        

            $url = "https://$F5Name/mgmt/tm/ltm/pool/~Common~$PoolName"
            Write-Verbose "Invoke Rest Method to: $url"
            Write-Verbose "Invoke-RestMethod -Method Patch -Uri $url -Body $poolInfo -Headers $headers -ContentType ""application/json"" -ErrorAction $errorAction"
            Invoke-RestMethod -Method Patch -Uri $url -Body $poolInfo -Headers $headers -ContentType "application/json" -ErrorAction $errorAction
        }
    }
    end
    {
    }
}

