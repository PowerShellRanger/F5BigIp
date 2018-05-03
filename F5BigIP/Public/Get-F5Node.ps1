function Get-F5Node
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'OnlyGetNodesRequested'
    )]
    param
    (
        # Name of Nodes to get
        [Parameter(
            ParameterSetName = 'OnlyGetNodesRequested'
        )]
        [string[]]$NodeName,
        
        # Switch to get all Nodes
        [Parameter(            
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllNodes'
        )]
        [switch]$GetAllNodes
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

        if ($PSBoundParameters['GetAllNodes'])
        {
            Write-Verbose "Invoke Rest Method to: https://$($Script:F5Session.F5Name)/mgmt/tm/ltm/node"
            [F5Node]::GetAllNodes($Script:F5Session)

        }
        else
        {
            foreach ($Node in $NodeName)
            {                
                Write-Verbose "Invoke Rest Method to: https://$($Script:F5Session.F5Name)/mgmt/tm/ltm/node/~Common~$NodeName"                
                [F5Node]::Get($nodeName, $Script:F5Session)
            }
        }        
    }
    end
    {
    }
}

