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
                
                $hashtableBody = @{
                    name                     = $server.Name
                    source                   = $server.source
                    sourceAddressTranslation = $server.sourceAddressTranslation
                    ipProtocol               = $server.ipProtocol                    
                }                

                if ($server.PoolName) {$hashtableBody.Add("pool", "/Common/$($server.PoolName)")}

                $hashtableProfiles = @(
                    @{
                        name = "http";
                        kind = "ltm:virtual:profile";
                    },
                    @{
                        name    = "tcp-lan-optimized";
                        context = "clientside";
                        kind    = "ltm:virtual:profile";
                    },
                    @{
                        name    = "tcp-wan-optimized";
                        context = "serverside";
                        kind    = "ltm:virtual:profile";
                    },
                    @{
                        name = "wan-optimized-compression";
                        kind = "ltm:virtual:profile";
                    }
                )

                switch ("$($server.ServicePort)")
                {
                    "HTTP"
                    {
                        $hashtableBody.Add("destination", "/Common/$($server.Destination):80")
                        $hashtableBody.Add("rules", @("/Common/_sys_https_redirect"))
                    }
                    default
                    {
                        $hashtableBody.Add("destination", "/Common/$($server.Destination):443")
                        $hashtableBody.Add("rules", @("/Common/Security", "/Common/Standard"))
                        if ($server.ClientSslProfileName)
                        {
                            $hashtableProfiles += @{
                                name    = $server.ClientSslProfileName;
                                context = "clientside";
                                kind    = "ltm:virtual:profile";
                            }
                        }
                        $hashtableProfiles += @{
                            name    = "serverssl";
                            context = "serverside";
                            kind    = "ltm:virtual:profile"                    
                        }   
                        
                    }
                }
                $hashtableBody.Add("profiles", $hashtableProfiles)

                $body = $hashtableBody | ConvertTo-Json 
                write-verbose $body
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