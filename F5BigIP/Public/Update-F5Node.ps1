function Update-F5Node
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(SupportsShouldprocess, ConfirmImpact = "High")]
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
        if ($PSCmdlet.Shouldprocess("Updates node: $($Credential.UserName) on F5: $F5Name"))
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
            Write-Verbose "Invoke-RestMethod -Method Patch -Uri $url -Body $nodeInfo -Headers $headers -ContentType ""application/json"" -ErrorAction $errorAction"
            #Still not working
            Invoke-RestMethod -Method Patch -Uri $url -Body $nodeInfo -Headers $headers -ContentType "application/json" -ErrorAction $errorAction
        }
    }
    end
    {
    }
}

