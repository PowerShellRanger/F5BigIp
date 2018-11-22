class F5HighAvailability
{
    static [bool] IsActiveHaNode([F5Session]$f5Session)
    {
        $uri = "https://$($f5Session.F5Name)/mgmt/tm/cm/failover-status"

        $splatGetHaNode = @{
            Headers     = $f5Session.Header
            Method      = 'GET'
            ContentType = 'application/json'
            Uri         = $uri
        }
        Write-Verbose "Invoke Rest Method to: $uri"
        $response = Invoke-RestMethod @splatGetHaNode

        if ($response.entries.'https://localhost/mgmt/tm/cm/failover-status/0'.nestedStats.entries.status.description -eq 'ACTIVE')
        {
            return $true
        }

        return $false
    }
}