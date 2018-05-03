function New-F5Session
{
    <#
    .Synopsis
        Generate a token for BigIP Rest API access
    .DESCRIPTION
        Generate a token for authenticating to BigIP F5 via the REST API interface.
    .EXAMPLE
        New-F5Session -F5Name 'myF5.mydomain.com' -Credential (Get-Credential MyUser) -ErrorAction Stop -Verbose
    .EXAMPLE
       
    #>
    [OutputType('F5Session')]
    [CmdletBinding(
        SupportsShouldProcess, 
        ConfirmImpact = "Low"
    )]    
    param
    (
        # F5Name
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]        
        [string]$F5Name,

        # Credentials to F5
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]
        [PSCredential]$Credential
    )
    begin
    {
    }
    process
    {
        if ($PSCmdlet.ShouldProcess("Generate Rest API Token for User: $($Credential.UserName) on F5: $F5Name"))
        {    
            $script:F5ApiSession = [F5Session]::New($F5Name, $Credential)
        }
    }
    end
    {
    }
}

