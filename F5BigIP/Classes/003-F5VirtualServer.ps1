
class F5VirtualServer
{
    # Virtual Server Name 
    [string]$Name

    # Source Address/Mask
    [ValidatePattern("\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\/\b(0?[0-9]|[1-2][0-9]|3[0-2])\b\z")] 
    [string]$Source = '0.0.0.0/0'

    # Virtual IP Address    
    [string]$Destination

    # Virtual Server Type (HTTP / HTTPS)
    [ValidateSet('HTTP', 'HTTPS')]
    [string]$ServicePort = 'HTTPS'

    # Source Address Translation    
    [hashtable]$SourceAddressTranslation = @{type = 'AutoMap'}

    # Protocol
    [ValidateSet('TCP', 'UDP', 'SCTP')]
    [string]$IpProtocol = 'TCP'

    # Pool Name
    # /Common/$Pool
    [ValidatePattern("^\/Common\/(?:[^\/]+)")]
    [string]$Pool

    # Client SSL Profile Name    
    [string]$ClientSslProfileName

    # Profiles
    [hashtable[]]$Profiles

    # Rules
    [array]$Rules

    #VirtualServer () {}

    F5VirtualServer ([string]$Name, [IpAddress]$Ip)
    {
        $this.Name = $Name
        $this.Destination = [F5VirtualServer]::GenerateDestination($Ip.IpAddress, $this.ServicePort)
        $this.Rules = [F5VirtualServer]::GenerateRules($this.ServicePort)
        $this.Profiles = [F5VirtualServer]::GenerateProfiles($this.ClientSslProfileName, $this.ServicePort)
    }

    F5VirtualServer ([string]$Name, [IpAddress]$Ip, [string]$ClientSslProfileName)
    {
        $this.Name = $Name
        $this.Destination = [F5VirtualServer]::GenerateDestination($Ip.IpAddress, $this.ServicePort)
        $this.ServicePort = $this.ServicePort
        $this.ClientSslProfileName = $ClientSslProfileName
        $this.Rules = [F5VirtualServer]::GenerateRules($this.ServicePort)
        $this.Profiles = [F5VirtualServer]::GenerateProfiles($ClientSslProfileName, $this.ServicePort)
    }

    F5VirtualServer ([string]$Name, [IpAddress]$Ip, [string]$ServicePort, [string]$ClientSslProfileName)
    {
        $this.Name = $Name
        $this.Destination = [F5VirtualServer]::GenerateDestination($Ip.IpAddress, $ServicePort)
        $this.ServicePort = $ServicePort
        $this.ClientSslProfileName = $ClientSslProfileName
        $this.Rules = [F5VirtualServer]::GenerateRules($ServicePort)
        $this.Profiles = [F5VirtualServer]::GenerateProfiles($ClientSslProfileName, $ServicePort)
    }

    F5VirtualServer ([string]$Name, [string]$source, [IpAddress]$Ip, [string]$ServicePort,
        [snat]$Snat, [string]$IpProtocol, [string]$Pool, [string]$ClientSslProfileName)
    {
        $this.Name = $Name
        $this.Source = $source
        $this.Destination = [F5VirtualServer]::GenerateDestination($Ip.IpAddress, $ServicePort)
        $this.ServicePort = $ServicePort
        $this.SourceAddressTranslation = @{type = $Snat.SourceAddressTranslation}
        $this.IpProtocol = $IpProtocol
        $this.Pool = $Pool
        $this.ClientSslProfileName = $ClientSslProfileName
        $this.Rules = [F5VirtualServer]::GenerateRules($ServicePort)
        $this.Profiles = [F5VirtualServer]::GenerateProfiles($ClientSslProfileName, $ServicePort)
    }

    hidden static [string] GenerateDestination([IpAddress]$Ip, [string]$ServicePort)
    {                
        if ($ServicePort -eq 'HTTP') {return "/Common/$($Ip.IpAddress):80"}
        
        return "/Common/$($Ip.IpAddress):443"
    }

    hidden static [string[]] GenerateRules([string]$ServicePort)
    {                
        if ($ServicePort -eq 'HTTP') {return "/Common/_sys_https_redirect"}

        return @("/Common/Security", "/Common/Standard")
    }

    hidden static [hashtable[]] GenerateProfiles([string]$ClientSslProfileName, [string]$ServicePort)
    {
        $_profiles = New-Object 'System.Collections.Generic.List[hashtable]'                
        $hashtableProfiles = 
        @{
            name = "http"
            kind = "ltm:virtual:profile"
        },
        @{
            name    = "tcp-lan-optimized"
            context = "clientside"
            kind    = "ltm:virtual:profile"
        },
        @{
            name    = "tcp-wan-optimized"
            context = "serverside"
            kind    = "ltm:virtual:profile"
        },
        @{
            name = "wan-optimized-compression"
            kind = "ltm:virtual:profile"
        }
        $hashtableProfiles | ForEach-Object { $_profiles.Add($_) }

        if ($ClientSslProfileName)
        {
            $profile = @{
                name    = $ClientSslProfileName
                context = "clientside"
                kind    = "ltm:virtual:profile"
            }
            $_profiles.Add($profile)
        }

        if ($ServicePort -ne 'HTTP')
        {
            $profile = @{
                name    = "serverssl";
                context = "serverside";
                kind    = "ltm:virtual:profile"                    
            }
            $_profiles.Add($profile)
        }

        return $_profiles
    }

    static [F5VirtualServer[]] GetVirtualServer([string[]]$VirtualServerName, [F5Session]$F5Session)
    {
        $_f5VirtualServers = New-Object 'System.Collections.Generic.List[F5VirtualServer]'

        foreach ($server in $VirtualServerName)
        {
            $uri = "https://$($F5Session.F5Name)/mgmt/tm/ltm/virtual/~Common~$server"

            $splatGetVirtualServer = @{                    
                Headers     = $F5Session.Header
                Method      = "GET"
                ContentType = "application/json"
                Uri         = $uri
            }
            Write-Verbose "Invoke Rest Method to: $uri"
            $response = Invoke-RestMethod @splatGetVirtualServer
                    
            $_f5VirtualServers.Add([F5VirtualServer]::New($response.name, $response.address))
        }
        return $_f5VirtualServers
    }

    static [F5VirtualServer[]] GetAllVirtualServers([F5Session]$F5Session)
    {                        
        $uri = "https://$($F5Session.F5Name)/mgmt/tm/ltm/virtual"

        $splatGetAllVirtualServers = @{
            Headers     = $F5Session.Header
            Method      = "GET"
            ContentType = "application/json"                
            Uri         = $uri
        }
        Write-Verbose "Invoke Rest Method to: $uri"
        $response = Invoke-RestMethod @splatGetAllVirtualServers

        $_f5VirtualServers = New-Object 'System.Collections.Generic.List[F5VirtualServer]'
        foreach ($server in $response.items)
        {                        
            $_f5VirtualServers.Add([F5VirtualServer]::New($server.name, $server.address))
        }
        return $_f5VirtualServers
    }
}

class snat
{
    # Source Address Translation
    [ValidateSet('SNAT', 'AutoMap', 'None')]
    [string]$SourceAddressTranslation

    snat ([string]$Snat)
    {
        $this.SourceAddressTranslation = $Snat
    }
}
