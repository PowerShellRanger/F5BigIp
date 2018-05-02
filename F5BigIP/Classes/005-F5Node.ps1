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

    static [F5Node] Get([string]$nodeName, [F5Authentication]$f5Auth)
    {                          
        $uri = "https://$($f5Auth.F5Name)/mgmt/tm/ltm/node/~Common~$nodeName"

        $splatGetNode = @{                    
            Headers     = $f5Auth.Header
            Method      = "GET"
            ContentType = "application/json"                
            Uri         = $uri
        }
        Write-Verbose "Invoke Rest Method to: $uri"
        $response = Invoke-RestMethod @splatGetNode
                
        return [F5Node]::New($response.name, $response.address)
    }

    static [F5Node[]] GetAllNodes([F5Authentication]$f5Auth)
    {                        
        $uri = "https://$($f5Auth.F5Name)/mgmt/tm/ltm/node" 

        $splatGetAllNodes = @{                    
            Headers     = $f5Auth.Header
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

    [void] New([F5Authentication]$f5Auth)
    {
        $uri = "https://$($f5Auth.F5Name)/mgmt/tm/ltm/node" 

        $psObjectBody = [PSCustomObject] @{
            name    = $this.Name
            address = $this.IpAddress
        }
        $body = $psObjectBody | ConvertTo-Json        
        
        $splatInvokeRestMethod = @{
            Uri         = $uri
            ContentType = 'application/json'
            Method      = 'POST'
            Body        = $body
            Headers     = $f5Auth.Header
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