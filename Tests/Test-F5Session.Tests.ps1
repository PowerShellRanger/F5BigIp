
$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Get-Module -Name $moduleName -All | Remove-Module -Force
Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force

InModuleScope -ModuleName $moduleName {

    $sut = Split-Path $MyInvocation.MyCommand.ScriptBlock.File -Leaf
    $cmdletName = $sut.Split('.')[0]
    $cmdlet = Get-Command -Name $cmdletName

    Describe 'Test-F5Session' {

        $f5User = 'f5.user'
        $f5Pass = 'f5.pass'

        # build a credential object
        $securePass = ConvertTo-SecureString -String $f5Pass -AsPlainText -Force
        $credential = New-Object -TypeName System.Management.Automation.PSCredential ($f5User, $securePass)
                
        Context 'Testing first if block' {

            It 'Should throw when a session is not found' {
                {Test-F5Session} | should throw
            }            
        }

        Context 'Testing New-F5Session is called when session has expired' {

            Mock -CommandName New-F5Session -MockWith {} -Verifiable

            $script:F5Session = [F5Session]::New()
            $script:F5Session.TimeStamp = (Get-Date).AddMinutes(-30)
            $script:F5Session.F5Name = 'foo'
            $script:F5Session.Credential = $credential

            Test-F5Session

            It 'Should call New-F5Session function 1 time' {
                Assert-MockCalled -CommandName New-F5Session -Times 1 -Scope Context -ParameterFilter {
                    $F5Name -eq $script:F5Session.F5Name `
                        -and $Credential -eq $script:F5Session.Credential
                }
            }
        }
    }
}
