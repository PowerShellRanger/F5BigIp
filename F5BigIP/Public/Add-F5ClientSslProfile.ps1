function Add-F5ClientSslProfile
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
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
        [string]$DefaultSni = "false"
    )
    begin
    {
    }
    process
    {
        if ($PSCmdlet.ShouldProcess("Will validate\create\update Client SSL Profile: $ClientSslProfileName on F5: $F5Name"))
        {
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            Write-Verbose "Checking whether $ClientSslProfileName already exist on $F5Name"
            $splatGetAllClientSSLProfile = @{            
                F5Name               = $F5Name
                Token                = $Token
            }
            
            $allClientSslProfiles = Get-F5ClientSslProfile @splatGetAllClientSSLProfile -GetAllClientSslProfiles
            if ($allClientSslProfiles | Where-Object {$_.name -like $ClientSslProfileName})
            {
                $splatUpdateClientSSLProfile = @{
                    F5Name               = $F5Name
                    Token                = $Token         
                    ClientSslProfileName = $ClientSslProfileName
                    CertificateName      = $CertificateName
                    CABundleName         = $CABundleName
                    DefaultSni           = $DefaultSni
                }
                Write-Verbose "Client SSL Profile already exist"
                Update-F5ClientSslProfile @splatUpdateClientSSLProfile -Confirm:$false
            }
            else
            {
                $splatNewClientSSLProfile = @{
                    F5Name               = $F5Name
                    Token                = $Token                                
                    ClientSslProfileName = $ClientSslProfileName
                    CertificateName      = $CertificateName
                    CABundleName         = $CABundleName
                    DefaultSni           = $DefaultSni
                }
                Write-Verbose "Adding new Client SSL Profile"
                New-F5ClientSslProfile @splatNewClientSSLProfile -Confirm:$false
            }
        }        
    }
    end
    {
    }
}