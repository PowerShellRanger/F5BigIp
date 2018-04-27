
class F5Member
{
    # Virtual Server Name 
    [string]$Name

    # Source Address
    [string]$Address = '/Common/https_443'

    [string]$ServicePort = "HTTPS"


    F5Member ([string]$name, [string]$Address)
    {
        $this.Name = = [F5Member]::GetMemberName($this.Name, $this.ServicePort)
        $this.Address = $Address
    }

    static [string] GetMemberName([string]$name, [string]$servicePort)
    {                
        if ($servicePort -eq 'HTTP') {return "$($name):80"}
        
        return "$($name):443"
    }    
}

    