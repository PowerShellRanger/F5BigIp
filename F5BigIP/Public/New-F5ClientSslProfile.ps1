function New-F5ClientSslProfile
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
        if ($PSCmdlet.ShouldProcess("Create new Client SSL Profile: $ClientSslProfileName on F5: $F5Name"))
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

            $psObjectBody = @{
                name       = "$ClientSslProfileName"
                cert       = "/Common/$($newCertificateName).crt"
                key        = "/Common/$($newCertificateName).key"
                chain      = "/Common/$($CABundleName)"
                sniDefault = $DefaultSni  
            }            
            $body = $psObjectBody | ConvertTo-Json

            $splatInvokeRestMethod = @{
                Uri         = "https://$F5Name/mgmt/tm/ltm/profile/client-ssl"
                ContentType = 'application/json'
                Method      = 'POST'
                Body        = $body
                Headers     = $headers
                ErrorAction = $errorAction
            }
            Invoke-RestMethod @splatInvokeRestMethod
        }
    }
    end
    {
    }
}

