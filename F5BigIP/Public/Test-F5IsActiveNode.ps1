function Test-F5IsActiveNode
{
    <#
    .Synopsis
        Test to see if F5 Node is Active in HA Cluster.
    .DESCRIPTION
        Use this function to test an F5 Node to see if it is the Active member in an F5 Cluster.
    .EXAMPLE
        New-F5Session -F5Name 'foo.f5' -Credential (Get-Credential) -Confirm:$false -Verbose
        Test-F5IsActiveNode -Verbose

        Description
        -----------
        Test if node 'foo.f5' is the Active node in the F5 Cluster.        
    .EXAMPLE

    #>
    [CmdletBinding()]
    param
    (
    )
    begin
    {
        Test-F5Session
    }
    process
    {
        Write-Verbose "Checking if node: $($Script:F5Session.F5Name) is Active Node in HA Cluster."
        [F5HighAvailability]::IsActiveHaNode($Script:F5Session)
    }
    end
    {
    }
}

