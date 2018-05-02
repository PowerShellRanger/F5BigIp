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
        # F5Name
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetNodesRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllNodes'
        )]
        [string]$F5Name,

        # Token Based Authentication
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetNodesRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllNodes'
        )]
        [string]$Token,

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

        $headers = @{
            'X-F5-Auth-Token' = $Token
        }
        if ($PSBoundParameters['GetAllNodes'])
        {
            $splatGetAllNodes = @{                    
                Headers     = $headers
                Method      = "GET"
                ContentType = "application/json"                
                Uri         = "https://$F5Name/mgmt/tm/ltm/node"
            }
            Write-Verbose "Invoke Rest Method to: https://$F5Name/mgmt/tm/ltm/node"
            (Invoke-RestMethod @splatGetAllNodes -ErrorAction $errorAction).items
        }
        else
        {
            foreach ($Node in $NodeName)
            {                
                $splatGetNode = @{                    
                    Headers     = $headers
                    Method      = "GET"
                    ContentType = "application/json"                
                    Uri         = "https://$F5Name/mgmt/tm/ltm/node/~Common~$NodeName"
                }
                Write-Verbose "Invoke Rest Method to: https://$F5Name/mgmt/tm/ltm/node/~Common~$NodeName"
                Invoke-RestMethod @splatGetNode -ErrorAction $errorAction
            }
        }        
    }
    end
    {
    }
}

