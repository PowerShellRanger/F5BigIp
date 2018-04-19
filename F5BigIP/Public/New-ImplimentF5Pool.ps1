function New-ImplimentF5Pool
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(SupportsShouldprocess, ConfirmImpact = "High")]
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
            Mandatory=$false, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [pscustomobject]$Members
    )
    begin
    {
    }
    process
    {
        if ($PSCmdlet.Shouldprocess("Will validate\create\update Pool : $PoolName on F5: $F5Name"))
        {
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            Write-Verbose "Checking whether $PoolName already exist on $F5Name"
            $allPools = Get-F5Pool -F5Name $F5Name -Token $Token -GetAllPools
            if($allPools | Where-Object {$_.name -like $PoolName}){
                Write-Verbose "Pool already exist"
                $activeMembers = (Get-F5PoolMember -F5Name $F5Name -Token $Token -PoolName $PoolName).items
                foreach($Member in $Members){
                    if($activeMembers | Where-Object {$_.name -like "$($Member.name)*"}){
                        Write-Verbose "Pool Member: $($Member.name) already exist in Pool: $PoolName"
                    }
                    else{
                        Write-Verbose "Adding Pool Member: $($Member.name) to Pool: $PoolName"
                    }
                }                
            }            
        }        
    }
    end
    {
    }
}