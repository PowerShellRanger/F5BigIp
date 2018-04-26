function New-F5VirtualServer
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

        # Virtual Server
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName           
        )]        
        [VirtualServer[]]$VirtualServer
    )
    begin
    {
    }
    process
    {
        foreach ($server in $VirtualServer)
        {
            if ($PSCmdlet.ShouldProcess("Creates new virtual server: $Name on F5: $F5Name"))
            { 
                $errorAction = $ErrorActionPreference        
                if ($PSBoundParameters["ErrorAction"])
                {
                    $errorAction = $PSBoundParameters["ErrorAction"]
                }

                $headers = @{
                    'X-F5-Auth-Token' = $Token
                }
                                

                $body = $server | ConvertTo-Json 
                Write-Verbose $body
                $splatInvokeRestMethod = @{
                    Uri         = "https://$F5Name/mgmt/tm/ltm/virtual"
                    ContentType = 'application/json'
                    Method      = 'POST'
                    Body        = $body
                    Headers     = $headers
                    ErrorAction = $errorAction
                }
                Invoke-RestMethod @splatInvokeRestMethod
            }
        }
    }
    end
    {
    }
}