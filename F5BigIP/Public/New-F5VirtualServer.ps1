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
        [string[]]$VirtualServer,

        # Virtual IP Address
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName           
        )]        
        [string]$VirtualIpAddress
    )
    begin
    {
    }
    process
    {
        foreach ($virtualServ in $VirtualServer) 
        {
            <# TODO: Need to finish
            if ($PSCmdlet.ShouldProcess("Creates new virtual server: $VirtualServer on F5: $F5Name"))
            { 
                $errorAction = $ErrorActionPreference        
                if ($PSBoundParameters["ErrorAction"])
                {
                    $errorAction = $PSBoundParameters["ErrorAction"]
                }

                $headers = @{
                    'X-F5-Auth-Token' = $Token
                }        

                $url = "https://$F5Name/mgmt/tm/ltm/pool"
                Write-Verbose "Invoke Rest Method to: $url"
                Invoke-RestMethod -Method POST -Uri $url -Body $poolInfo -Headers $headers -ContentType "application/json" -ErrorAction $errorAction
            }
            #>
        }
    }
    end
    {
    }
}

