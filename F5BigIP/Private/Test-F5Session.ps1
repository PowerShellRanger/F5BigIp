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
        
        if ($script:F5Session.TimeStamp -le (Get-Date).AddMinutes(-15))
        {
            Write-Verbose "F5Session timed out. Creating a new session to F5: $($script:F5Session.F5Name)."
            New-F5Session -F5Name $script:F5Session.F5Name -Credential $script:F5Session.Credential
        }
    }
    end
    {
    }
}

