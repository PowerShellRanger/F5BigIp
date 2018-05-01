class F5Member
{
    # Member Name 
    [string]$Name

    # Source Address
    [string]$Address

    # Service Port
    [ValidateSet('HTTP', 'HTTPS')]
    [string]$ServicePort = "HTTPS"

    F5Member ([string]$name, [IpAddress]$ip)
    {
        $this.Name = [F5Member]::GetMemberName($name, $this.ServicePort)
        $this.Address = $ip.IpAddress
    }

    F5Member ([string]$name, [IpAddress]$ip, [string]$servicePort)
    {
        $this.Name = [F5Member]::GetMemberName($name, $servicePort)
        $this.Address = $ip.IpAddress
        $this.ServicePort = $servicePort
    }

    static [string] GetMemberName([string]$name, [string]$servicePort)
    {                
        if ($servicePort -eq 'HTTP') {return "$($name):80"}
        
        return "$($name):443"
    }    
}