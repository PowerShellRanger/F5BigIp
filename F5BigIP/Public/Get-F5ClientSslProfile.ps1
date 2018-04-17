function Get-F5ClientSslProfile
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'OnlyGetClientSslProfilesRequested'
    )]
    param
    (
        # F5Name
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetClientSslProfilesRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllClientSslProfiles'
        )]
        [string]$F5Name,

        # Token Based Authentication
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetClientSslProfilesRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllClientSslProfiles'
        )]
        [string]$Token,

        # Name of Client SSL Profiles to get
        [Parameter(
            ParameterSetName = 'OnlyGetClientSslProfilesRequested'
        )]
        [string[]]$ClientSslProfileName,
        
        # Switch to get all Client SSL Profiles
        [Parameter(            
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllClientSslProfiles'
        )]
        [switch]$GetAllClientSslProfiles
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
        if ($PSBoundParameters['GetAllClientSslProfiles'])
        {
            $url = "https://$F5Name/mgmt/tm/ltm/profile/client-ssl"
            Write-Verbose "Invoke Rest Method to: $url"
            (Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ContentType "application/json" -ErrorAction $errorAction).items
        }
        else
        {
            foreach ($ClientSslProfile in $ClientSslProfileName)
            {                
                $url = "https://$F5Name/mgmt/tm/ltm/profile/client-ssl/~Common~$ClientSslProfile"
                Write-Verbose "Invoke Rest Method to: $url"
                Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ContentType "application/json" -ErrorAction $errorAction
            }
        }        
    }
    end
    {
    }
}

