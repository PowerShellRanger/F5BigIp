function Get-F5Member
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'OnlyGetMembersRequested'
    )]
    param
    (
        # F5Name
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetMembersRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllMembers'
        )]
        [string]$F5Name,

        # Token Based Authentication
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetMembersRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllMembers'
        )]
        [string]$Token,

        # Name of Certificates to get
        [Parameter(
            ParameterSetName = 'OnlyGetMembersRequested'
        )]
        [string[]]$MemberName,
        
        # Switch to get all Certificates
        [Parameter(            
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllMembers'
        )]
        [switch]$GetAllMembers
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
        if ($PSBoundParameters['GetAllMembers'])
        {
            $url = "https://$F5Name/mgmt/tm/ltm/node"
            Write-Verbose "Invoke Rest Method to: $url"
            (Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ContentType "application/json" -ErrorAction $errorAction).items
        }
        else
        {
            foreach ($member in $MemberName)
            {                
                $url = "https://$F5Name/mgmt/tm/ltm/node/~Common~*"
                Write-Verbose "Invoke Rest Method to: $url"
                Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ContentType "application/json" -ErrorAction $errorAction
            }
        }        
    }
    end
    {
    }
}

