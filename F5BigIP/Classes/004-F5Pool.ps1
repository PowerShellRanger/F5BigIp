
class F5Pool
{
    # Pool Name 
    [string]$Name

    # Monitor Name
    [string]$MonitorName = "https_443"

    # Monitor path
    #[ValidatePattern("^\/Common\/(?:[^\/]+)")] 
    [string]$Monitor = "/Common/https_443"

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
        $this.Monitor = [F5Pool]::GetMonitorName($this.MonitorName)
        $this.Members = $members
    }

    F5Pool ([string]$name, [string]$monitor )
    {
        $this.Name = $name
        $this.Monitor = $monitor
    }
    
    F5Pool ([string]$name, [F5Member[]]$members, [string]$monitor)
    {
        $this.Name = $name
        $this.Monitor = $monitor
        $this.Members = $members
    }

    static [string] GetMonitorName([string]$monitorName)
    {                
        return  "/Common/" + $monitorName      
    }    
}
