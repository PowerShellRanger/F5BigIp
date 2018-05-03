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
        if ($script:F5Session.TimeStamp -ge (Get-Date).AddMinutes(-15))
        {
            throw "A valid F5Session was not found. Please create a new session using New-F5Session."
        }
        elseif ($script:F5Session.TimeStamp -ge (Get-Date).AddMinutes(-15))
        {
            New-F5Session -F5Name $Script:F5Session.F5Name -Credential $Script:F5Session.Credential -Confirm:$false
        }
    }
    end
    {
    }
}

