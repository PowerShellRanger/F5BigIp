class F5Authentication
{
    # F5 Name 
    [string]$F5Name

    # F5 Auth Token
    [string]$F5Token
    
    F5Token () {}

    F5Token ([string]$name, [PSCredential]$credential)
    {
        $this.F5Name = $name
        $this.Token = (New-F5RestApiToken -F5Name $name -Credential $credential).Token
    }    

    static [string] GetToken([string]$name, [PSCredential]$credential)
    {                  
        return (New-F5RestApiToken -F5Name $name -Credential $credential).Token
    }    
}