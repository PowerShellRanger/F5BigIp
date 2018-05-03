class F5State
{
    [ValidateSet("Enable","Disable","ForceOffline")]
    [string]$State

    F5State ([string]$state)
    {
        $this.State = $state
    }
}

class F5Node
{
    # Node Name 
    [string]$Name

    # Ip Address
    [string]$IpAddress
  
    F5Node () {}

    F5Node ([string]$name, [IpAddress]$ipAddress)
    {
        $this.Name = $name
        $this.IpAddress = $ipAddress.IpAddress
    }

    static [F5Node] Get([string]$nodeName, [F5Session]$f5Session)
    {                          
        $uri = "https://$($f5Session.F5Name)/mgmt/tm/ltm/node/~Common~$nodeName"

        $splatGetNode = @{                    
            Headers = $f5Session.Header
            Method = "GET"
            ContentType = "application/json"                
            Uri = $uri
        }
        Write-Verbose "Invoke Rest Method to: $uri"
        $response = Invoke-RestMethod @splatGetNode
                
        return [F5Node]::New($response.name, $response.address)
    }

    static [F5Node[]] GetAllNodes([F5Session]$f5Session)
    {                        
        $uri = "https://$($f5Session.F5Name)/mgmt/tm/ltm/node" 

        $splatGetAllNodes = @{                    
            Headers     = $f5Session.Header
            Method      = "GET"
            ContentType = "application/json"                
            Uri         = $uri
        }
        Write-Verbose "Invoke Rest Method to: $uri"
        $response = Invoke-RestMethod @splatGetAllNodes

        $f5Nodes = New-Object 'System.Collections.Generic.List[F5Node]'
        foreach ($node in $response.items)
        {
            if ($node.address -match [IpAddress].DeclaredProperties.CustomAttributes.ConstructorArguments.Value)
            {
                $f5Nodes.Add([F5Node]::New($node.name, $node.address))
            }            
        }
        return $f5Nodes
    }

    [void] Create([F5Session]$f5Session)
    {
        $uri = "https://$($f5Session.F5Name)/mgmt/tm/ltm/node" 

        $hashBody = [PSCustomObject] @{
            name    = $this.Name
            address = $this.IpAddress
        }
        $body = $hashBody | ConvertTo-Json        
        
        $splatInvokeRestMethod = @{
            Uri         = $uri
            ContentType = 'application/json'
            Method      = 'POST'
            Body        = $body
            Headers     = $f5Session.Header
            ErrorAction = 'Stop'
        }

        try
        {
            [void](Invoke-RestMethod @splatInvokeRestMethod)
        }
        catch
        {
            Write-Error $_
        }
    }

    #Not Fullly Functional
    hidden [void] Update([F5Session]$f5Session)
    {
        $uri = "https://$($f5Session.F5Name)/mgmt/tm/ltm/node/~Common~$($this.Name)" 
        
        $hashBody = [PSCustomObject] @{
            address = $this.IpAddress
        }
        $body = $hashBody | ConvertTo-Json  
        
        $splatInvokeRestMethod = @{
            Uri         = $uri
            ContentType = 'application/json'
            Method      = 'PUT'
            Body        = $body
            Headers     = $f5Session.Header
            ErrorAction = 'Stop'
        }

        try
        {
            [void](Invoke-RestMethod @splatInvokeRestMethod)
        }
        catch
        {
            Write-Error $_
        }
    }
    
    [void] SetState([F5State]$state,[F5Session]$f5Session)
    {
        $uri = "https://$($f5Session.F5Name)/mgmt/tm/ltm/node/~Common~$($this.Name)" 
        

        $hashBody = @{} 
        switch($State.state){
            "Enable" {
                $hashBody.Add("state","user-up")
                $hashBody.Add("session","user-enabled")
            }
            "Disable" {
                $hashBody.Add("session","user-disabled")
            }
            "ForceOffline" {
                $hashBody.Add("state","user-down")
                $hashBody.Add("session","user-disabled")
            }
        } 
        $body = $hashBody | ConvertTo-Json
        
        $splatInvokeRestMethod = @{
            Uri         = $uri
            ContentType = 'application/json'
            Method      = 'PATCH'
            Body        = $body
            Headers     = $f5Session.Header
            ErrorAction = 'Stop'
        }

        try
        {
            [void](Invoke-RestMethod @splatInvokeRestMethod)
        }
        catch
        {
            Write-Error $_
        }
    }

    [void] Delete([F5Session]$f5Session)
    {
        $uri = "https://$($f5Session.F5Name)/mgmt/tm/ltm/node/~Common~$($this.Name)" 
        
        $splatInvokeRestMethod = @{
            Uri         = $uri
            ContentType = 'application/json'
            Method      = 'DELETE'
            Headers     = $f5Session.Header
            ErrorAction = 'Stop'
        }

        try
        {
            [void](Invoke-RestMethod @splatInvokeRestMethod)
        }
        catch
        {
            Write-Error $_
        }
    }    
}