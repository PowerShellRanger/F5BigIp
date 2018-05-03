function New-F5Node
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = "High"
    )]
    param
    (        
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
        [string]$IpV4Address
    )
    begin
    {                
        Test-F5Session
    }
    process
    {
        if ($PSCmdlet.ShouldProcess("Creates new node: $NodeName on F5: $F5Name"))
        {                
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            $node = [F5Node]::New($NodeName, $IpV4Address)
            try
            {
                $node.Create($script:F5Session)
            }
            catch
            {
                throw $_
            }
        }    
    }
    end
    {
    }
}

