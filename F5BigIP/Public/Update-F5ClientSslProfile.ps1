function Update-F5ClientSslProfile
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = "High"
    )]
    param
    (
        # F5Name
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]        
        [string]$F5Name,

        # Token Based Authentication
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]        
        [string]$Token,

        # Name of Client SSL Profile to create
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]        
        [string]$ClientSslProfileName,

        # Name of client SSL certificate
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [ValidateScript( {        
                if ($_ -notmatch "(\.crt)")
                {
                    throw "$_`nThe CertificateName specified must be of type .crt"
                }
                return $true
            })]        
        [string]$CertificateName,

        # Name of certificate bundle name
        [Parameter(
            Mandatory = $false, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [ValidateScript( {        
                if ($_ -notmatch "(\.crt)")
                {
                    throw "The CABundleName specified must be of type .crt"
                }
                return $true
            })]
        [string]$CABundleName = "ca-bundle.crt",        

        # SNI setting
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]        
        [String]$DefaultSni = "false"
    )
    begin
    {
    }
    process
    {
        if ($PSCmdlet.ShouldProcess("Updates node: $CertificateName on F5: $F5Name"))
        { 
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            $headers = @{
                'X-F5-Auth-Token' = $Token
            }

            $newCertificateName = $CertificateName.Replace(".crt", "")

            $clientSslProfileInfo = @{
                name       = "$ClientSslProfileName"
                cert       = "/Common/$($newCertificateName).crt"
                key        = "/Common/$($newCertificateName).key"
                chain      = "/Common/$($CABundleName)"
                sniDefault = $DefaultSni  
            }
            $clientSslProfileInfo
            $clientSslProfileInfo = $clientSslProfileInfo | ConvertTo-Json        

            $url = "https://$F5Name/mgmt/tm/ltm/profile/client-ssl/~Common~$ClientSslProfileName"
            Write-Verbose "Invoke Rest Method to: $url"
            Invoke-RestMethod -Method PATCH -Uri $url -Body $clientSslProfileInfo -Headers $headers -ContentType "application/json" -ErrorAction $errorAction
        }
    }
    end
    {
    }
}

