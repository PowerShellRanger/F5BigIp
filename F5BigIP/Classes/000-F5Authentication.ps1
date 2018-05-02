class F5Authentication
{
    # F5 Name 
    [string]$F5Name

    # F5 Auth Token
    [string]$Token

    # F5 User Name
    [string]$UserName

    # F5 Header
    [hashtable]$Header
    
    F5Authentication () {}

    F5Authentication ([string]$f5name, [PSCredential]$credential)
    {
        $this.F5Name = $f5name
        $this.Token = [F5Authentication]::GetToken($this.f5name, $credential)
        $this.UserName = $credential.UserName
        $this.Header = @{
            'X-F5-Auth-Token' = $this.Token
        }
    }

    static [string] GetToken([string]$f5name, [PSCredential]$credential)
    {
        $psObjectBody = [PSCustomObject] @{
            username          = $($credential.UserName)
            password          = $($credential.GetNetworkCredential().Password)
            loginProviderName = "tmos"
        }
        $body = $psobjectBody | ConvertTo-Json

        Write-Verbose "Starting Invoke-WebRequest: $f5Name to generate a token for $($credential.UserName)."
        $splatInvokeRestMethod = @{
            Uri         = "https://$f5Name/mgmt/shared/authn/login"
            ContentType = 'application/json'
            Method      = 'POST'
            Body        = $body            
        }
        $response = Invoke-RestMethod @splatInvokeRestMethod
                
        return $response.token.token
    }
}