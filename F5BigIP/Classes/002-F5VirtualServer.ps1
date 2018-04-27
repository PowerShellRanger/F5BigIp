
class F5VirtualServer
{
    # Virtual Server Name 
    [string]$Name

    # Source Address/Mask
    # TODO: Add Validate Pattern for IP and Mask
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
    # /Common/$pool
    [string]$Pool

    # Client SSL Profile Name    
    [string]$ClientSslProfileName

    # Profiles
    [hashtable[]]$Profiles

    # Rules
    [array]$Rules

    #VirtualServer () {}

    F5VirtualServer ([string]$name, [IpAddress]$ip)
    {
        $this.Name = $name
        $this.Destination = [F5VirtualServer]::GetDestination($ip.IpAddress, $this.ServicePort)
        $this.Rules = [F5VirtualServer]::GetRules($this.ServicePort)
        $this.Profiles = [F5VirtualServer]::GetProfiles($this.ClientSslProfileName, $this.ServicePort)
    }

    VirtualServer ([string]$name, [IpAddress]$ip, [string]$clientSslProfileName)
    {
        $this.Name = $name
        $this.Destination = [F5VirtualServer]::GetDestination($ip.IpAddress, $this.ServicePort)
        $this.ServicePort = $this.ServicePort
        $this.ClientSslProfileName = $clientSslProfileName
        $this.Rules = [F5VirtualServer]::GetRules($this.ServicePort)
        $this.Profiles = [F5VirtualServer]::GetProfiles($clientSslProfileName, $this.ServicePort)
    }

    VirtualServer ([string]$name, [IpAddress]$ip, [string]$servicePort, [string]$clientSslProfileName)
    {
        $this.Name = $name
        $this.Destination = [F5VirtualServer]::GetDestination($ip.IpAddress, $servicePort)
        $this.ServicePort = $servicePort
        $this.ClientSslProfileName = $clientSslProfileName
        $this.Rules = [F5VirtualServer]::GetRules($servicePort)
        $this.Profiles = [F5VirtualServer]::GetProfiles($clientSslProfileName, $servicePort)
    }

    VirtualServer ([string]$name, [string]$source, [IpAddress]$ip, [string]$servicePort,
        [snat]$snat, [string]$ipProtocol, [string]$pool, [string]$clientSslProfileName)
    {
        $this.Name = $name
        $this.Source = $source
        $this.Destination = [F5VirtualServer]::GetDestination($ip.IpAddress, $servicePort)
        $this.ServicePort = $servicePort
        $this.SourceAddressTranslation = @{type = $snat.SourceAddressTranslation}
        $this.IpProtocol = $ipProtocol
        $this.Pool = "/Common/$pool"
        $this.ClientSslProfileName = $clientSslProfileName
        $this.Rules = [F5VirtualServer]::GetRules($servicePort)
        $this.Profiles = [F5VirtualServer]::GetProfiles($clientSslProfileName, $servicePort)
    }

    static [string] GetDestination([IpAddress]$ip, [string]$servicePort)
    {                
        if ($servicePort -eq 'HTTP') {return "/Common/$($ip.IpAddress):80"}
        
        return "/Common/$($ip.IpAddress):443"
    }

    static [string[]] GetRules([string]$servicePort)
    {                
        if ($servicePort -eq 'HTTP') {return "/Common/_sys_https_redirect"}

        return @("/Common/Security", "/Common/Standard")
    }

    static [hashtable[]] GetProfiles([string]$clientSslProfileName, [string]$servicePort)
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

        if ($clientSslProfileName)
        {
            $profile = @{
                name    = $clientSslProfileName
                context = "clientside"
                kind    = "ltm:virtual:profile"
            }
            $_profiles.Add($profile)
        }

        if ($servicePort -ne 'HTTP')
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
}

class snat
{
    # Source Address Translation
    [ValidateSet('SNAT', 'AutoMap', 'None')]
    [string]$SourceAddressTranslation

    snat ([string]$snat)
    {
        $this.SourceAddressTranslation = $snat
    }
}
