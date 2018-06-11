class F5Session
{
    # F5 Name 
    [string]$F5Name

    # F5 Auth Token
    [string]$Token

    # F5 User Name
    [string]$UserName

    # F5 Header
    [hashtable]$Header

    # Credentials to F5    
    [PSCredential]$Credential

    # TimeStamp
    hidden [datetime]$TimeStamp
    
    F5Session () 
    {
        $this.TimeStamp = Get-Date
    }

    F5Session ([string]$f5name, [PSCredential]$credential)
    {
        $this.F5Name = $f5name
        $this.Token = [F5Session]::GetToken($this.f5name, $credential)
        $this.UserName = $credential.UserName
        $this.Header = @{
            'X-F5-Auth-Token' = $this.Token
        }
        $this.Credential = $credential
        $this.TimeStamp = Get-Date
    }

    static [string] GetToken([string]$f5name, [PSCredential]$credential)
    {
        $psObjectBody = [PSCustomObject] @{
            username          = $($credential.UserName)
            password          = $($credential.GetNetworkCredential().Password)
            loginProviderName = 'tmos'
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