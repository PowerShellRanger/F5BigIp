enum ServicePort
{
    HTTP
    HTTPS
}

class VirtualServer
{
    # Virtual Server Name 
    [string]$Name

    # Virtual IP Address
    [ValidatePattern("\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\z")]
    [string]$Destination

    # Source IP range 
    [string]$Source = "0.0.0.0/0"

    [hashtable]$SourceAddressTranslation = @{type = "automap"}

    # Pool name
    [string]$PoolName

    #IP Protocol
    [string]$IpProtocol = "tcp"

    [hashtable[]]$profiles

    # Virtual Server Type (HTTP / HTTPS)
    [ServicePort]$ServicePort = 'HTTPS'

    VirtualServer () {}        

    VirtualServer ([string]$Name, [string]$Destination)
    {
        $this.Name = $Name
        $this.Destination = $Destination
    }

    VirtualServer ([string]$Name, [string]$Destination, [ServicePort]$ServicePort)
    {
        $this.Name = $Name
        $this.Destination = $Destination
        $this.ServicePort = $ServicePort
    }
}
