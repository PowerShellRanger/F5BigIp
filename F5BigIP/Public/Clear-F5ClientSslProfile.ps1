function Clear-F5ClientSslProfile
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

        # Name of Client SSL Profile to create
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]        
        [string]$ClientSslProfileName
    )
    begin
    {
    }
    process
    {
        if ($PSCmdlet.ShouldProcess("Deletes Client SSL Profile: $ClientSslProfileName on F5: $F5Name"))
        { 
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            $headers = @{
                'X-F5-Auth-Token' = $Token
            }

            $splatInvokeRestMethod = @{
                Uri         = "https://$F5Name/mgmt/tm/ltm/profile/client-ssl/~Common~$ClientSslProfileName"
                ContentType = 'application/json'
                Method      = 'Delete'
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

