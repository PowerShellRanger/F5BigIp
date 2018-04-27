
class F5Pool
{
    # Pool Name 
    [string]$Name

    # Monitor Name
    [string]$MonitorName = "https_443"

    [ValidateSet('HTTP', 'HTTPS')]
    [string]$ServicePort = "HTTPS"

    # Member Class
    [F5Member[]]$Members
    
    #F5Pool () {}

    F5Pool ([string]$name)
    {
        $this.Name = $name
        $this.MonitorName = "/Common/$($this.MonitorName)"
    }

    F5Pool ([string]$name, [F5Member[]]$members)
    {
        $this.Name = $name
        $this.MonitorName = "/Common/$($this.MonitorName)"
        $this.Members = $members
    }

}    