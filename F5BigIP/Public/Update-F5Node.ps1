function Update-F5Node
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        SupportsShouldprocess,
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
        $IpV4Address       
    )
    begin
    {
        Test-F5Session
    }
    process
    {
        if ($PSCmdlet.ShouldProcess("Creates new node: $NodeName on F5: $($Script:F5Session.F5Name)"))
        {                
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }
            # Needs work to make function correctly
            $node = [F5Node]::New( $NodeName, $IpV4Address)
            try
            {
                $node.Update($Script:F5Session)
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

