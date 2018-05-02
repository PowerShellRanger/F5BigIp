function Get-F5SslCertificate
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'OnlyGetCertsRequested'
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
            $splatGetSslCerts = @{                    
                Headers     = $headers
                Method      = "GET"
                ContentType = "application/json"                
                Uri         = "https://$F5Name/mgmt/tm/sys/file/ssl-cert"
                ErrorAction = $errorAction
            }
            Write-Verbose "Invoke Rest Method to: https://$F5Name/mgmt/tm/sys/file/ssl-cert"
            (Invoke-RestMethod @splatGetSslCerts).items
        }
        else
        {
            foreach ($certificate in $CertificateName)
            {                
                $splatCertificate = @{                    
                    Headers     = $headers
                    Method      = "GET"
                    ContentType = "application/json"                
                    Uri         = "https://$F5Name/mgmt/tm/sys/file/ssl-cert/~Common~$certificate"
                    ErrorAction = $errorAction
                }
                Write-Verbose "Invoke Rest Method to: https://$F5Name/mgmt/tm/sys/file/ssl-cert/~Common~$certificate"
                Invoke-RestMethod @splatCertificate
            }
        }        
    }
    end
    {
    }
}

