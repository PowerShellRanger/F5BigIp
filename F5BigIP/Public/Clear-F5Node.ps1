function Clear-F5Node
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
        [string]$NodeName
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

            $node = [F5Node]::New()
            $node.Name = $NodeName

            $node.Delete($script:F5Session)
    }
    end
    {
    }
}

