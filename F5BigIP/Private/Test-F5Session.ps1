function Test-F5Session
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding()]
    param
    (        
    )
    begin
    {                        
    }
    process
    {        
        if (-not $script:F5Session)
        {
            throw "A valid F5Session was not found. Please create a new session using New-F5Session."
        }
        
        if ($script:F5Session.TimeStamp -ge (Get-Date).AddMinutes(-15))
        {
            New-F5Session -F5Name $script:F5Session.F5Name -Credential $script:F5Session.Credential
        }
    }
    end
    {
    }
}

