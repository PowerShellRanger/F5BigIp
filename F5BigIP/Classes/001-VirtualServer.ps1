
class IpAddress 
{
    # IP Address
    [ValidatePattern("\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\z")]        
    [string]$IpAddress

    IpAddress ([string]$ip)
    {
        $this.IpAddress = $ip
    }
}

class VirtualServer
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
    # /Comon/$pool
    [string]$Pool

    # Client SSL Profile Name    
    [string]$ClientSslProfileName

    # Profiles
    [hashtable[]]$Profiles

    # Rules
    [array]$Rules

    VirtualServer () {}    

    VirtualServer ([string]$name, [IpAddress]$vip)
    {
        $this.Name = $name
        $this.Destination = [VirtualServer]::GetDestination($vip, $this.ServicePort)
        $this.Rules = [VirtualServer]::GetRules($this.ServicePort)
        $this.Profiles = [VirtualServer]::GetProfiles($this.ClientSslProfileName, $this.ServicePort)
    }

    VirtualServer ([string]$name, [IpAddress]$vip, [string]$clientSslProfileName)
    {
        $this.Name = $name
        $this.Destination = [VirtualServer]::GetDestination($vip, $this.ServicePort)
        $this.ServicePort = $this.ServicePort
        $this.ClientSslProfileName = $clientSslProfileName
        $this.Rules = [VirtualServer]::GetRules($this.ServicePort)
        $this.Profiles = [VirtualServer]::GetProfiles($clientSslProfileName, $this.ServicePort)
    }

    VirtualServer ([string]$name, [IpAddress]$vip, [string]$servicePort, [string]$clientSslProfileName)
    {
        $this.Name = $name
        $this.Destination = [VirtualServer]::GetDestination($vip, $servicePort)
        $this.ServicePort = $servicePort
        $this.ClientSslProfileName = $clientSslProfileName
        $this.Rules = [VirtualServer]::GetRules($servicePort)
        $this.Profiles = [VirtualServer]::GetProfiles($clientSslProfileName, $servicePort)
    }

    static [string] GetDestination([string]$destination, [string]$servicePort)
    {                
        if ($servicePort -eq 'HTTP') {return "/Common/$($destination):80"}
        
        return "/Common/$($destination):443"
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
