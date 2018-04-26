enum ServicePort
{
    HTTP
    HTTPS
}

enum SourceAddressTranslation
{
    SNAT
    AutoMap
    None
}

enum IpProtocol
{
    TCP
    UDP
    SCTP
}

class VirtualServer
{
    # Virtual Server Name 
    [string]$Name

    # Source Address/Mask
    # TODO: Add Validate Pattern for IP and Mask
    [string]$Source = '0.0.0.0/0'

    # Virtual IP Address
    [ValidatePattern("\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\z")]
    [string]$Destination

    # Virtual Server Type (HTTP / HTTPS)
    [ServicePort]$ServicePort = 'HTTPS'

    # Source Address Translation
    [SourceAddressTranslation]$SourceAddressTranslation = 'AutoMap'

    # Protocol
    [IpProtocol]$IpProtocol = 'TCP'

    # Pool Name
    [string]$PoolName

    # Client SSL Profile Name    
    [string]$ClientSslProfileName

    # Body Hashtable for API
    [hashtable]$Body


    VirtualServer () {}    

    VirtualServer ([string]$Name, [string]$Destination)        
    {
        $this.Name = $Name
        $this.Destination = $Destination                
        $this.Body = [VirtualServer]::GenerateBody($this.Name, $this.Source, $this.SourceAddressTranslation, 
            $this.IpProtocol, $this.ClientSslProfileName, $this.ServicePort, $this.PoolName, $this.Destination)
    }

    VirtualServer ([string]$Name, [string]$Source, [string]$Destination, [ServicePort]$ServicePort,
        [SourceAddressTranslation]$SourceAddressTranslation, [IpProtocol]$IpProtocol)
    {
        $this.Name = $Name
        $this.Source = $Source
        $this.Destination = $Destination
        $this.ServicePort = $ServicePort
        $this.SourceAddressTranslation = $SourceAddressTranslation
        $this.IpProtocol = $IpProtocol
        $this.Body = [VirtualServer]::GenerateBody($this.Name, $this.Source, $this.SourceAddressTranslation, 
            $this.IpProtocol, $this.ClientSslProfileName, $this.ServicePort, $this.PoolName, $this.Destination)
    }

    VirtualServer ([string]$Name, [string]$Source, [string]$Destination, [ServicePort]$ServicePort,
        [SourceAddressTranslation]$SourceAddressTranslation, [IpProtocol]$IpProtocol,
        [string]$PoolName)
    {
        $this.Name = $Name
        $this.Source = $Source
        $this.Destination = $Destination
        $this.ServicePort = $ServicePort
        $this.SourceAddressTranslation = $SourceAddressTranslation
        $this.IpProtocol = $IpProtocol
        $this.PoolName = $PoolName
        $this.Body = [VirtualServer]::GenerateBody($this.Name, $this.Source, $this.SourceAddressTranslation, 
            $this.IpProtocol, $this.ClientSslProfileName, $this.ServicePort, $this.PoolName, $this.Destination)
    }

    VirtualServer ([string]$Name, [string]$Source, [string]$Destination, [ServicePort]$ServicePort,
        [SourceAddressTranslation]$SourceAddressTranslation, [IpProtocol]$IpProtocol,
        [string]$PoolName, [string]$ClientSslProfileName)
    {
        $this.Name = $Name
        $this.Source = $Source
        $this.Destination = $Destination
        $this.ServicePort = $ServicePort
        $this.SourceAddressTranslation = $SourceAddressTranslation
        $this.IpProtocol = $IpProtocol
        $this.PoolName = $PoolName
        $this.ClientSslProfileName = $ClientSslProfileName
        $this.Body = [VirtualServer]::GenerateBody($this.Name, $this.Source, $this.SourceAddressTranslation, 
            $this.IpProtocol, $this.ClientSslProfileName, $this.ServicePort, $this.PoolName, $this.Destination)
    }

    static [hashtable] GenerateBody([string]$name, [string]$source, 
        [SourceAddressTranslation]$sourceAddressTranslation, [IpProtocol]$ipProtocol, [string]$clientSslProfileName, 
        [ServicePort]$servicePort, [string]$poolName, [string]$destination)
    {
        $hashtableBody = @{
            name                     = $name
            source                   = $source
            sourceAddressTranslation = $sourceAddressTranslation
            ipProtocol               = $ipProtocol                    
        }

        if ($poolName) {$hashtableBody.Add("pool", "/Common/$poolName)")}

        switch ($servicePort)
        {
            "HTTP"
            {
                $hashtableBody.Add("destination", "/Common/$($destination):80")
                $hashtableBody.Add("rules", @("/Common/_sys_https_redirect"))
            }
            default
            {
                $hashtableBody.Add("destination", "/Common/$($destination):443")
                $hashtableBody.Add("rules", @("/Common/Security", "/Common/Standard"))
            }
        }

        $profiles = [VirtualServer]::GenerateProfiles($clientSslProfileName, $servicePort)
        $hashtableBody.Add("profiles", $profiles)
        
        return $hashtableBody
    }

    static [System.Collections.Generic.List[hashtable]] GenerateProfiles([string]$clientSslProfileName, [ServicePort]$servicePort)
    {
        $profiles = New-Object 'System.Collections.Generic.List[hashtable]'                
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
        $hashtableProfiles | ForEach-Object { $profiles.Add($_) }

        if ($clientSslProfileName)
        {
            $profile = @{
                name    = $clientSslProfileName
                context = "clientside"
                kind    = "ltm:virtual:profile"
            }
            $profiles.Add($profile)
        }

        if ($servicePort -ne 'HTTP')
        {
            $profile = @{
                name    = "serverssl";
                context = "serverside";
                kind    = "ltm:virtual:profile"                    
            }
            $profiles.Add($profile)
        }

        return $profiles
    }
}
