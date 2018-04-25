function Update-F5PoolMember
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
        [PSCustomObject]$Members   
    )
    begin
    {
    }
    process
    {
        if ($PSCmdlet.ShouldProcess("Updates pool: $PoolName on F5: $F5Name"))
        {         
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            $headers = @{
                'X-F5-Auth-Token' = $Token
            }
            
            foreach ($member in $Members)
            {
                $psObjectBody.members += $member
            }
            $body = $psObjectBody | ConvertTo-Json        

            $splatInvokeRestMethod = @{
                Uri         = "https://$F5Name/mgmt/tm/ltm/pool/~Common~$PoolName"
                ContentType = 'application/json'
                Method      = 'Patch'
                Body        = $body
                Headers     = $headers
                ErrorAction = $errorAction
            }
            Invoke-RestMethod @splatInvokeRestMethod
        }
    }
    end
    {
    }
}

