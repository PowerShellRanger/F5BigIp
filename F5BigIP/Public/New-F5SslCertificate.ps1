function New-F5SslCertificate
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'OnlyGetCertsRequested',
        SupportsShouldProcess,
        ConfirmImpact = "High"
    )]
    param
    (
        # F5Name
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetCertsRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllCerts'
        )]
        [string]$F5Name,

        # Token Based Authentication
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'OnlyGetCertsRequested'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllCerts'
        )]
        [string]$Token,

        # Name of Certificates to get
        [Parameter(
            ParameterSetName = 'OnlyGetCertsRequested'
        )]
        [ValidateScript( {        
                if ($_ -notmatch "(\.crt)")
                {
                    throw "The CertificateName specified must be of type .crt"
                }
                return $true
            })]
        [string[]]$CertificateName,
        
        # Switch to get all Certificates
        [Parameter(            
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GetAllCerts'
        )]
        [switch]$GetAllCertificates
    )
    begin
    {
    }
    process
    {<# TODO: Rewrite so this works
        if ($PSCmdlet.ShouldProcess("Create new SSL Certificate: $CertificateName on F5: $F5Name"))
        {
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            $headers = @{
                'X-F5-Auth-Token' = $Token
            }
            if ($PSBoundParameters['GetAllCertificates'])
            {
                $url = "https://$F5Name/mgmt/tm/sys/file/ssl-cert"
                Write-Verbose "Invoke Rest Method to: $url"
                (Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ContentType "application/json" -ErrorAction $errorAction).items
            }
            else
            {
                foreach ($certificate in $CertificateName)
                {                
                    $url = "https://$F5Name/mgmt/tm/sys/file/ssl-cert/~Common~$certificate"
                    Write-Verbose "Invoke Rest Method to: $url"
                    Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ContentType "application/json" -ErrorAction $errorAction
                }
            }
        }#>
    }
    end
    {
    }
}

