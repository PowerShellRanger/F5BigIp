
$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Get-Module -Name $moduleName -All | Remove-Module -Force
Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force

InModuleScope -ModuleName $moduleName {

    $sut = Split-Path $MyInvocation.MyCommand.ScriptBlock.File -Leaf
    $cmdletName = $sut.Split('.')[0]
    $cmdlet = Get-Command -Name $cmdletName

    Describe 'Set-F5MaintenanceMode' {        

        Context 'Testing Parameters' {            

            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.MaintenanceMode.Attributes.Mandatory | should be $true
            }        
        }
        
        Context 'Testing function does not continue if iRule does not exist' {

            Mock -CommandName Test-F5Session -MockWith {} -Verifiable
            Mock -CommandName Get-F5iRule -MockWith {} -Verifiable
            Mock -CommandName Write-Warning -MockWith {} -Verifiable

            Set-F5MaintenanceMode -Name foo -MaintenanceMode Off -Confirm:$false

            It 'Should call the Get-F5iRule function 1 time' {
                Assert-MockCalled -CommandName Get-F5iRule -Times 1 -Exactly -Scope Context
            }
            It 'Should call the Write-Warning cmdlet 1 time' {
                Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly -Scope Context
            }
            It 'Should call the Test-F5Session function 1 time' {
                Assert-MockCalled -CommandName Test-F5Session -Times 1 -Exactly -Scope Context
            }
        }        
    }
}
