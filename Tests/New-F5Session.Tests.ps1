<#
$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Get-Module -Name $moduleName -All | Remove-Module -Force
Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force

InModuleScope -ModuleName $moduleName {

    Describe 'New-F5Session' {

        class F5Session
        {
            # F5 Name 
            [string]$F5Name

            # F5 Auth Token
            [string]$Token

            F5Session ([string]$f5name, [PSCredential]$credential)
            {
                $this.F5Name = $f5name
                $this.Token = 'SomeToken'
            }
        }

        Context 'Testing function - Calls F5Session class' {

            $f5User = 'f5.user'
            $f5Pass = 'f5.pass'

            # build a credential object
            $securePass = ConvertTo-SecureString -String $f5Pass -AsPlainText -Force
            $credential = New-Object -TypeName System.Management.Automation.PSCredential ($f5User, $securePass)
            
            New-F5Session -F5Name 'F5Name' -Credential $credential

            It 'Should call the F5Session Class' {
                $Script:F5Session.F5Name | should be 'F5Name'
                $Script:F5Session.Token | should be 'SomeToken'
            }            
        }        
    }
}
#>