function Add-F5Node
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param
    (
        # F5Name
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [string]$F5Name,

        # Token Based Authentication
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [string]$Token,

        # Name of Node to create
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [string]$NodeName,

        #Ip Address of Node to create
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [ValidatePattern("\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\z")]
        [string]$IpV4Address,

        #Force IP Address correction
        [Parameter( 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [switch]$Force
    )
    begin
    {
    }
    process
    {
        #Modify response later
        if ($PSCmdlet.ShouldProcess("Will validate\create\update node : $NodeName with ipaddress: $IpV4Address on F5: $F5Name"))
        {
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            Write-Verbose "Checking whether $NodeName already exist on $F5Name"
            $allNodes = Get-F5Node -F5Name $F5Name -Token $Token -GetAllNodes
            if ($allNodes | Where-Object {$_.name -like $NodeName -and $_.address -like $IpV4Address})
            {
                Write-Verbose "Node already exist and has the correct IP"
            }
            elseif ($allNodes | Where-Object {$_.name -like $NodeName})
            {
                Write-Verbose "Node already exist. Validating the IP Address is the same."
                if ($allNodes | Where-Object {$_.name -notlike $NodeName -and $_.address -like $IpV4Address})
                {
                    if ($PSBoundParameters['Force'])
                    {
                        Write-Verbose "Node already exist. Force switch accepted"
                        $splatUpdateNode = @{
                            F5Name      = $F5Name 
                            Token       = $Token
                            NodeName    = $NodeName
                            IpV4Address = $IpV4Address
                            ErrorAction = $errorAction
                        }
                        Update-F5Node @splatUpdateNode
                    }
                    else 
                    {
                        Write-Verbose "Node already exist, but... IP is already in use by another node"    
                    }                    
                }
                
            }
            elseif ($allNodes | Where-Object {$_.address -like $IpV4Address})
            {
                if ($PSBoundParameters['Force'])
                {
                    Write-Verbose "Node already exist. Force switch accepted"
                    $splatUpdateNode = @{
                        F5Name      = $F5Name 
                        Token       = $Token
                        NodeName    = $NodeName
                        IpV4Address = $IpV4Address
                        ErrorAction = $errorAction
                    }
                    Update-F5Node @splatUpdateNode
                }
                else 
                {
                    Write-Verbose "Node is new, but... IP is already in use by another node"
                }
                
            }
            else
            {
                Write-Verbose "Creating new node with provided IP"
                $splatNewNode = @{
                    F5Name      = $F5Name 
                    Token       = $Token
                    NodeName    = $NodeName
                    IpV4Address = $IpV4Address
                    ErrorAction = $errorAction
                }
                New-F5Node @splatNewNode
            }
        }        
    }
    end
    {
    }
}