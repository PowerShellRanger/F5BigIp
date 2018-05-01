function Add-F5Pool
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

        # Name of Pool to create
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [F5Pool]$F5Pool,

        #Members of Pool to create
        [Parameter(
            Mandatory,            
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [F5Member[]]$Members
    )
    begin
    {
    }
    process
    {
        if ($PSCmdlet.ShouldProcess("Will validate\create\update Pool : $($F5Pool.Name) on F5: $F5Name"))
        {
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            Write-Verbose "Checking whether $($F5Pool.Name) already exist on $F5Name"
            $allPools = Get-F5Pool -F5Name $F5Name -Token $Token -GetAllPools
            if ($allPools | Where-Object {$_.name -like $($F5Pool.Name)})
            {
                Write-Verbose "Pool already exist"                
            }
            else
            {
                $splatNewF5Pool = @{
                    F5Name = $F5Name
                    Token  = $Token
                    F5Pool = $F5Pool
                }
                Write-Verbose "Adding new pool"
                New-F5Pool @splatNewF5Pool -Confirm:$false
            }
            
            Write-Verbose "Adding pool members"            
            $newMembers = @()
            
            $activeMembers = (Get-F5PoolMember -F5Name $F5Name -Token $Token -PoolName $($F5Pool.Name)).items            
            foreach ($member in $Members)
            {
                if ($activeMembers | Where-Object {$_.name -like "$($member.name)*"})
                {
                    Write-Verbose "Pool Member: $($member.name) already exist in Pool: $($F5Pool.Name)"
                    $newMembers += $activeMembers | Select-Object kind, name, partition, address, connectionLimit, dynamicRatio, ephemeral, logging, monitor, priorityGroup, rateLimit, ratio | Where-Object {$_.name -like "$($member.name)*"}
                }
                else
                {
                    Write-Verbose "Adding Pool Member: $($member.Name) to Pool: $($F5Pool.Name)"
                    $F5Pool.Members += [F5Member]::New($member.Name, $member.IpAddress, $member.ServicePort)                    

                    $splatUpdateF5PoolMember = @{
                        F5Name = $F5Name
                        Token  = $Token                    
                        F5Pool = $F5Pool
                    }
                    Update-F5PoolMember @splatUpdateF5PoolMember -Confirm:$false
                }
            }                      
        }        
    }
    end
    {
    }
}