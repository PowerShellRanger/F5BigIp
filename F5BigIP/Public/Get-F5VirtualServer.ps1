function Get-F5VirtualServer
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'OnlyGetVirtualServersRequested'
    )]
    param
    (
        # F5Name
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetVirtualServersRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllVirtualServers'
        )]
        [string]$F5Name,

        # Token Based Authentication
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetVirtualServersRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllVirtualServers'
        )]
        [string]$Token,

        # Name of Virtual Servers to get
        [Parameter(
            ParameterSetName = 'OnlyGetVirtualServersRequested'
        )]
        [string[]]$VirtualServerName,
        
        # Switch to get all Virtual Servers
        [Parameter(            
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllVirtualServers'
        )]
        [switch]$GetAllVirtualServers
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
        if ($PSBoundParameters['GetAllVirtualServers'])
        {
            $url = "https://$F5Name/mgmt/tm/ltm/virtual"
            Write-Verbose "Invoke Rest Method to: $url"
            (Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ContentType "application/json" -ErrorAction $errorAction).items
        }
        else
        {
            foreach ($VirtualServer in $VirtualServerName)
            {                
                $url = "https://$F5Name/mgmt/tm/ltm/virtual/~Common~$VirtualServer"
                Write-Verbose "Invoke Rest Method to: $url"
                Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ContentType "application/json" -ErrorAction $errorAction
            }
        }        
    }
    end
    {
    }
}

