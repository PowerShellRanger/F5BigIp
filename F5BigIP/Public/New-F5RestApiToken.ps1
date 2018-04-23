function New-F5RestApiToken
{
    <#
    .Synopsis
        Generate a token for BigIP Rest API access
    .DESCRIPTION
        Generate a token for authenticating to BigIP F5 via the REST API interface.
    .EXAMPLE
        New-F5RestApiToken -F5Name 'myF5.mydomain.com' -Credential (Get-Credential MyUser) -ErrorAction Stop -Verbose
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

        # Credentials to F5
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [PSCredential]$Credential
    )
    begin
    {
    }
    process
    {
        if ($PSCmdlet.ShouldProcess("Generate Rest API Token for User: $($Credential.UserName) on F5: $F5Name"))
        {    
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            $psObjectBody = [PSCustomObject] @{
                username          = $($Credential.UserName)
                password          = $($Credential.GetNetworkCredential().Password)
                loginProviderName = "tmos"
            }
            $body = $psobjectBody | ConvertTo-Json

            Write-Verbose "Starting Invoke-WebRequest: $F5Name to generate a token for $($Credential.UserName)."
            $splatInvokeRestMethod = @{
                Uri         = "https://$F5Name/mgmt/shared/authn/login"
                ContentType = 'application/json'
                Method      = 'POST'
                Body        = $body
                ErrorAction = $errorAction
            }
            $response = Invoke-RestMethod @splatInvokeRestMethod
            
            [PSCustomObject] @{
                UserName = $response.token.userName
                Token    = $response.token.token
            }
        }
    }
    end
    {
    }
}

