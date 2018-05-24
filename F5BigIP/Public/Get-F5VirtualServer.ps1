function Get-F5VirtualServer
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [OutputType('F5VirtualServer')]
    [CmdletBinding(
        DefaultParameterSetName = 'OnlyGetVirtualServersRequested'
    )]
    param
    (                
        # Name of Virtual Servers to get
        [Parameter(
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
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
        
        if ($PSBoundParameters['GetAllVirtualServers'])
        {            
            Write-Verbose "Invoke Rest Method to: https://$($Script:F5Session.F5Name)/mgmt/tm/ltm/virtual"
            [F5VirtualServer]::GetAllVirtualServers($Script:F5Session)
        }
        else
        {
            foreach ($virtualServer in $VirtualServerName)
            {                                
                Write-Verbose "Invoke Rest Method to: https://$($Script:F5Session.F5Name)/mgmt/tm/ltm/virtual/~Common~$virtualServer"
                [F5VirtualServer]::GetVirtualServer($virtualServer, $Script:F5Session)
            }
        }        
    }
    end
    {
    }
}

