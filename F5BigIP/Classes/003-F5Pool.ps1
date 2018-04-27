
class F5Pool
{
    # Virtual Server Name 
    [string]$Name

    # Source Address/Mask
    # TODO: Add Validate Pattern for IP and Mask
    [string]$Monitor = '/Common/https_443'

    [string]$ServicePort = "HTTPS"

    # Member Class
    [F5Member[]]$Member

    
    #VirtualServer () {}

    VirtualServer ([string]$name, [string]$Monitor)
    {
        $this.Name = $name
        $this.Monitor
    }
}

    