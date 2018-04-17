function Update-F5Node
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
            address = "$IpV4Address"
        }
        $nodeInfo = $nodeInfo | ConvertTo-Json        

        $url = "https://$F5Name/mgmt/tm/ltm/node/~Common~$NodeName"
        Write-Verbose "Invoke Rest Method to: $url"
        try {
            Write-Verbose "Invoke-RestMethod -Method Patch -Uri $url -Body $nodeInfo -Headers $headers -ContentType ""application/json"" -ErrorAction $errorAction"
            #Still not working
            Invoke-RestMethod -Method Patch -Uri $url -Body $nodeInfo -Headers $headers -ContentType "application/json" -ErrorAction $errorAction    
        }
        catch {
            Write-Host $Error[0]
        }
        
    }
    end
    {
    }
}

