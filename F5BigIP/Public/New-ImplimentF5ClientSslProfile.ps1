function New-ImplimentF5ClientSslProfile
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(SupportsShouldprocess, ConfirmImpact = "High")]
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
            Mandatory=$false, 
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
            Mandatory=$false,
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
        if ($PSCmdlet.Shouldprocess("Will validate\create\update Client SSL Profile: $ClientSslProfileName on F5: $F5Name"))
        {
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            Write-Verbose "Checking whether $ClientSslProfileName already exist on $F5Name"
            $ClientSSLProfileParams = @{            
                ClientSslProfileName = $ClientSslProfileName          
            }
            
            if($CertificateName){$ClientSSLProfileParams.add("CertificateName", $CertificateName)}            
            if($CABundleName){$ClientSSLProfileParams.add("CABundleName", $CABundleName)}
            if($DefaultSni){$ClientSSLProfileParams.add("DefaultSni", $DefaultSni)}            
            
            $allPools = Get-F5Pool -F5Name $F5Name -Token $Token -GetAllPools
            if($allPools | Where-Object {$_.name -like $ClientSslProfileName}){
                Write-Verbose "Pool already exist"                
            }
            else {
                Write-Verbose "Adding new Client SSL Profile"
                New-F5ClientSslProfile -F5Name $F5Name -Token $Token -ClientSslProfileName $ClientSslProfileName @ClientSSLProfileParams
            }
        }        
    }
    end
    {
    }
}