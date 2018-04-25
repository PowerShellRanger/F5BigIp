enum ServicePort
{
    HTTP
    HTTPS
}

class VirtualServer
{
    # Virtual Server Name 
    [string]$VirtualServer

    # Virtual IP Address
    [ValidatePattern("\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\z")]
    [string]$VirtualIpAddress

    # Virtual Server Type (HTTP / HTTPS)
    [ServicePort]$ServicePort = 'HTTPS'

    VirtualServer () {}        

    VirtualServer ([string]$VirtualServer, [string]$VirtualIpAddress)
    {
        $this.VirtualServer = $VirtualServer
        $this.VirtualIpAddress = $VirtualIpAddress
    }

    VirtualServer ([string]$VirtualServer, [string]$VirtualIpAddress, [ServicePort]$ServicePort)
    {
        $this.VirtualServer = $VirtualServer
        $this.VirtualIpAddress = $VirtualIpAddress
        $this.ServicePort = $ServicePort
    }
}
