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
        [string]$PoolName,

        #Members of Pool to create
        [Parameter(
            Mandatory,            
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [PSCustomObject]$Members,

        # Type of Monitor
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]  
        [ValidateSet('HTTP', 'HTTPS', 'Custom')]
        $Monitor
    )
    begin
    {
    }
    process
    {
        if ($PSCmdlet.ShouldProcess("Will validate\create\update Pool : $PoolName on F5: $F5Name"))
        {
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            Write-Verbose "Checking whether $PoolName already exist on $F5Name"
            $allPools = Get-F5Pool -F5Name $F5Name -Token $Token -GetAllPools
            if ($allPools | Where-Object {$_.name -like $PoolName})
            {
                Write-Verbose "Pool already exist"                
            }
            else
            {
                $splatNewF5Pool = @{
                    F5Name   = $F5Name
                    Token    = $Token
                    PoolName = $PoolName
                    Monitor  = $Monitor
                }
                Write-Verbose "Adding new pool"
                New-F5Pool @splatNewF5Pool -Confirm:$false
            }
            
            Write-Verbose "Adding pool members"
            $updatePoolMembers = $false
            $newMembers = @()
            
            $activeMembers = (Get-F5PoolMember -F5Name $F5Name -Token $Token -PoolName $PoolName).items
            foreach ($member in $Members)
            {
                if ($activeMembers | Where-Object {$_.name -like "$($member.name)*"})
                {
                    Write-Verbose "Pool Member: $($member.name) already exist in Pool: $PoolName"
                    $newMembers += $activeMembers | Select-Object kind, name, partition, address, connectionLimit, dynamicRatio, ephemeral, logging, monitor, priorityGroup, rateLimit, ratio | Where-Object {$_.name -like "$($member.name)*"}
                }
                else
                {
                    Write-Verbose "Adding Pool Member: $($member.name) to Pool: $PoolName"
                    $newMembers += $member
                    $updatePoolMembers = $true
                }
            }

            if ($updatePoolMembers) {
                $splatUpdateF5PoolMember = @{
                    F5Name   = $F5Name
                    Token    = $Token
                    PoolName = $PoolName
                    Members  = $newMembers
                }
                Update-F5PoolMember @splatUpdateF5PoolMember -Confirm:$false
            }             
        }        
    }
    end
    {
    }
}