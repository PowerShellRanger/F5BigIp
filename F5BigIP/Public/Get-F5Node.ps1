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
        # Token Based Authentication
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [F5Authentication]$F5Auth,

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
            Write-Verbose "Invoke Rest Method to: https://$F5Name/mgmt/tm/ltm/node"
            #(Invoke-RestMethod @splatGetAllNodes).items
            [F5Node]::GetAllNodes($F5Auth)
        }
        else
        {
            foreach ($Node in $NodeName)
            {                
                Write-Verbose "Invoke Rest Method to: https://$F5Name/mgmt/tm/ltm/node/~Common~$NodeName"
                [F5Node]::Get($nodeName, $F5Auth)
            }
        }        
    }
    end
    {
    }
}

