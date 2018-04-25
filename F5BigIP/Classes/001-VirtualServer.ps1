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

    VirtualServer ([string]$virtualServer, [string]$virtualIpAddress)
    {
        $this.VirtualServer = $virtualServer
        $this.VirtualIpAddress = $virtualIpAddress
    }

    VirtualServer ([string]$virtualServer, [string]$virtualIpAddress, [ServicePort]$servicePort)
    {
        $this.VirtualServer = $virtualServer
        $this.VirtualIpAddress = $virtualIpAddress
        $this.ServicePort = $servicePort
    }
}
