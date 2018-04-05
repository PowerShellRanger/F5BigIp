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

        # Credentials to F5
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
        [PSCredential]$Credential,

        # Name of Certificates to get
        [Parameter(
            ParameterSetName = 'OnlyGetCertsRequested'
        )]
        [ValidateScript({        
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
        if ($PSBoundParameters['GetAllCertificates'])
        {
            $url = "https://$F5Name/mgmt/tm/sys/file/ssl-cert"
            Write-Verbose "Invoke Rest Method to: $url"
            (Invoke-RestMethod -Method Get -Uri $url -Credential $Credential -ContentType "application/json" -ErrorAction Stop).items
        }
        else
        {
            foreach ($certificate in $CertificateName)
            {                
                $url = "https://$F5Name/mgmt/tm/sys/file/ssl-cert/~Common~$certificate"
                Write-Verbose "Invoke Rest Method to: $url"
                Invoke-RestMethod -Method Get -Uri $url -Credential $Credential -ContentType "application/json" -ErrorAction Stop
            }
        }        
    }
    end
    {
    }
}

