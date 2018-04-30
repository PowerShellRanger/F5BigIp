
class F5Pool
{
    # Pool Name 
    [string]$Name

    # Monitor Name
    [string]$MonitorName = "https_443"

    # Monitor Name
    [string]$Monitor = "https_443"

    [ValidateSet('HTTP', 'HTTPS')]
    [string]$ServicePort = "HTTPS"

    # Member Class
    [F5Member[]]$Members
    
    #F5Pool () {}

    F5Pool ([string]$name)
    {
        $this.Name = $name
        $this.Monitor = [F5Pool]::GetMonitorName($this.MonitorName)        
    }

    F5Pool ([string]$name, [F5Member[]]$members)
    {
        $this.Name = $name
        $this.Monitor = "/Common/" + $this.MonitorName
        $this.Members = $members
    }

    static [string] GetMonitorName([string]$monitorName)
    {                
        return  "/Common/" + $monitorName      
    }    
}
