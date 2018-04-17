function New-F5Node
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
        [string]$F5Name,

        # Token Based Authentication
        [string]$Token,

        # Name of Node to create
        [string]$NodeName,

        #Ip Address of Node to create
        [ValidatePattern("\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\z")]
        $IpV4Address
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

        $nodeInfo = @{
            name = "$NodeName"
            address = "$IpV4Address"
        }
        $nodeInfo = $nodeInfo | ConvertFrom-Json        

        $url = "https://$F5Name/mgmt/tm/ltm/node"
        Write-Verbose "Invoke Rest Method to: $url"
        Invoke-RestMethod -Method POST -Uri $url -Body $nodeInfo -Headers $headers -ContentType "application/json" -ErrorAction $errorAction
    }
    end
    {
    }
}

