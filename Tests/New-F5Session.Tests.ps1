
$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Get-Module -Name $moduleName -All | Remove-Module -Force
Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force

InModuleScope -ModuleName $moduleName {

    $sut = Split-Path $MyInvocation.MyCommand.ScriptBlock.File -Leaf
    $cmdletName = $sut.Split('.')[0]
    $cmdlet = Get-Command -Name $cmdletName

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

        Context 'Testing Parameters' {            

            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Credential.Attributes.Mandatory | should be $true
            }        
        }

        Context 'Testing function - Calls F5Session class' {

            $f5User = 'f5.user'
            $f5Pass = 'f5.pass'

            # build a credential object
            $securePass = ConvertTo-SecureString -String $f5Pass -AsPlainText -Force
            $credential = New-Object -TypeName System.Management.Automation.PSCredential ($f5User, $securePass)
            
            $session = New-F5Session -F5Name 'F5Name' -Credential $credential

            It 'Should call the F5Session Class' {
                $session.F5Name | should be 'F5Name'
                $session.Token | should be 'SomeToken'
            }
            It 'Should create an object of the correct type' {
                $session -is [F5Session] | should be $true
            }
        }        
    }
}
