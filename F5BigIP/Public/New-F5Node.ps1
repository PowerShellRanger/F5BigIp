function New-F5Node
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

        # Name of Node to create
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]        
        [string]$NodeName,

        #Ip Address of Node to create
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]        
        [ValidatePattern("\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\z")]
        [string]$IpV4Address
    )
    begin
    {
    }
    process
    {
        if ($PSCmdlet.ShouldProcess("Creates new node: $NodeName on F5: $F5Name"))
        {                
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            $headers = @{
                'X-F5-Auth-Token' = $Token
            }

            $psObjectBody = [PSCustomObject] @{
                name    = "$NodeName"
                address = "$IpV4Address"
            }
            $body = $psObjectBody | ConvertTo-Json        

            $splatInvokeRestMethod = @{
                Uri         = "https://$F5Name/mgmt/tm/ltm/node"
                ContentType = 'application/json'
                Method      = 'POST'
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

