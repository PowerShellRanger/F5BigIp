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
        [VirtualServer[]]$VirtualServer,

        # Pool Name
        [Parameter(
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName           
        )]        
        [string]$PoolName        
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
                
                $psObjectBody = @{
                    name    = $server.Name
                    source = "0.0.0.0/0"
                    sourceAddressTranslation = @{type = "automap"}
                    ipProtocol = "tcp"                    
                }                

                if($PoolName){$psObjectBody.Add("pool", "/Common/$PoolName")}

                switch("$($server.ServicePort)"){
                    "HTTP"{
                        $psObjectBody.Add("destination", "/Common/$($server.Destination):80")
                        $psObjectBody.Add("rules", @("/Common/_sys_https_redirect"))
                    }
                    default{
                        $psObjectBody.Add("destination", "/Common/$($server.Destination):443")
                        $psObjectBody.Add("rules",  @("/Common/Security","/Common/Standard"))
                    }
                }

                $body = $psObjectBody | ConvertTo-Json 
                
                $splatInvokeRestMethod = @{
                    Uri         = "https://$F5Name/mgmt/tm/ltm/virtual-address"
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